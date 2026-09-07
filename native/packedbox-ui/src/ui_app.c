/* ui_app.c: AdwNavigationView CoS pages wired to packedbox shell backends. */

#include <adwaita.h>
#include <assert.h>
#include <glib.h>
#include <gtk/gtk.h>
#include <stdio.h>
#include <string.h>

#include "packedbox_ui.h"
#include "packedbox_ui_jobs.h"
#include "packedbox_ui_paths.h"
#include "packedbox_ui_runner.h"

enum {
    PACKEDBOX_UI_OUTPUT_BYTES = 65536
};

typedef struct packedbox_ui_app_s packedbox_ui_app_t;

typedef struct {
    packedbox_ui_app_t *app;
    GtkTextView        *output_view;
    GtkLabel           *status_label;
    GtkWidget          *actions_box;
    packedbox_ui_runner_t runner;
    int                 job_running;
} packedbox_ui_page_ctx_t;

struct packedbox_ui_app_s {
    AdwApplicationWindow *window;
    AdwNavigationView    *navigation;
    GtkListBox           *entry_list;
    char                  root[PACKEDBOX_UI_PATH_BUF_BYTES];
};

static void packedbox_ui_app_activate(AdwApplication *application, gpointer user_data);
static void packedbox_ui_app_startup(AdwApplication *application, gpointer user_data);
static void packedbox_ui_app_build_ui(packedbox_ui_app_t *app, AdwApplication *application);
static AdwNavigationPage *packedbox_ui_app_create_home_page(packedbox_ui_app_t *app);
static void packedbox_ui_app_fill_entry_list(packedbox_ui_app_t *app);
static void packedbox_ui_app_push_tag(packedbox_ui_app_t *app, const char *tag);
static AdwNavigationPage *packedbox_ui_app_create_page_shell(
    packedbox_ui_app_t     *app,
    const char             *title,
    const char             *tag,
    packedbox_ui_page_ctx_t *ctx_out);
static AdwNavigationPage *packedbox_ui_app_create_install_fix_path_page(packedbox_ui_app_t *app);
static AdwNavigationPage *packedbox_ui_app_create_adapters_page(packedbox_ui_app_t *app);
static AdwNavigationPage *packedbox_ui_app_create_terminal_pack_page(packedbox_ui_app_t *app);
static AdwNavigationPage *packedbox_ui_app_create_status_page(packedbox_ui_app_t *app);
static void packedbox_ui_page_set_output(packedbox_ui_page_ctx_t *ctx, const char *text);
static void packedbox_ui_page_set_running(packedbox_ui_page_ctx_t *ctx, int running);
static void packedbox_ui_page_run_bash(
    packedbox_ui_page_ctx_t *ctx,
    const packedbox_ui_job_t *job);
static void packedbox_ui_page_on_done(const char *output, int exit_code, gpointer user_data);
static void packedbox_ui_page_on_hiding(AdwNavigationPage *page, gpointer user_data);
static void packedbox_ui_app_on_row_activated(
    GtkListBox *list_box, GtkListBoxRow *row, gpointer user_data);
static void packedbox_ui_fix_path_on_apply(GtkButton *button, gpointer user_data);
static void packedbox_ui_fix_path_on_install(GtkButton *button, gpointer user_data);
static void packedbox_ui_adapters_on_run(GtkButton *button, gpointer user_data);
static void packedbox_ui_terminal_on_run(GtkButton *button, gpointer user_data);
static void packedbox_ui_status_on_check(GtkButton *button, gpointer user_data);
static void packedbox_ui_status_on_cli(GtkButton *button, gpointer user_data);

packedbox_ui_status_t packedbox_ui_app_run(int argc, char **argv)
{
    AdwApplication *application = adw_application_new("com.packedbox.ui", G_APPLICATION_DEFAULT_FLAGS);
    int             status = 0;

    g_signal_connect(application, "startup", G_CALLBACK(packedbox_ui_app_startup), NULL);
    g_signal_connect(application, "activate", G_CALLBACK(packedbox_ui_app_activate), NULL);
    status = g_application_run(G_APPLICATION(application), argc, argv);
    g_object_unref(application);
    return status == 0 ? PACKEDBOX_UI_OK : PACKEDBOX_UI_ERR_IO;
}

static void packedbox_ui_app_startup(AdwApplication *application, gpointer user_data)
{
    (void)application;
    (void)user_data;
    adw_init();
}

static void packedbox_ui_app_activate(AdwApplication *application, gpointer user_data)
{
    packedbox_ui_app_t *app = g_new0(packedbox_ui_app_t, 1);

    (void)user_data;
    if (packedbox_ui_paths_resolve_root(app->root, sizeof(app->root)) != PACKEDBOX_UI_OK)
        (void)snprintf(app->root, sizeof(app->root), "%s", ".");

    packedbox_ui_app_build_ui(app, application);
    packedbox_ui_app_fill_entry_list(app);
    gtk_window_present(GTK_WINDOW(app->window));
}

static void packedbox_ui_app_build_ui(packedbox_ui_app_t *app, AdwApplication *application)
{
    AdwNavigationPage *home = NULL;

    app->window = ADW_APPLICATION_WINDOW(
        adw_application_window_new(GTK_APPLICATION(application)));
    gtk_window_set_title(GTK_WINDOW(app->window), "packedbox");
    gtk_window_set_default_size(GTK_WINDOW(app->window), 720, 520);

    app->navigation = ADW_NAVIGATION_VIEW(adw_navigation_view_new());
    adw_application_window_set_content(app->window, GTK_WIDGET(app->navigation));

    home = packedbox_ui_app_create_home_page(app);
    adw_navigation_view_add(app->navigation, home);
    adw_navigation_view_push(app->navigation, home);

    adw_navigation_view_add(app->navigation, packedbox_ui_app_create_install_fix_path_page(app));
    adw_navigation_view_add(app->navigation, packedbox_ui_app_create_adapters_page(app));
    adw_navigation_view_add(app->navigation, packedbox_ui_app_create_terminal_pack_page(app));
    adw_navigation_view_add(app->navigation, packedbox_ui_app_create_status_page(app));
}

static AdwNavigationPage *packedbox_ui_app_create_home_page(packedbox_ui_app_t *app)
{
    GtkWidget          *toolbar = adw_toolbar_view_new();
    GtkWidget          *header = adw_header_bar_new();
    GtkWidget          *scroll = gtk_scrolled_window_new();
    AdwPreferencesPage *prefs = ADW_PREFERENCES_PAGE(adw_preferences_page_new());
    AdwPreferencesGroup *group = ADW_PREFERENCES_GROUP(adw_preferences_group_new());

    adw_header_bar_set_title_widget(ADW_HEADER_BAR(header), gtk_label_new("packedbox"));
    adw_toolbar_view_add_top_bar(ADW_TOOLBAR_VIEW(toolbar), header);

    gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scroll), GTK_POLICY_NEVER, GTK_POLICY_AUTOMATIC);
    app->entry_list = GTK_LIST_BOX(gtk_list_box_new());
    gtk_list_box_set_selection_mode(app->entry_list, GTK_SELECTION_NONE);
    g_signal_connect(app->entry_list, "row-activated", G_CALLBACK(packedbox_ui_app_on_row_activated), app);
    gtk_scrolled_window_set_child(GTK_SCROLLED_WINDOW(scroll), GTK_WIDGET(app->entry_list));

    adw_preferences_group_set_title(group, "Jobs");
    adw_preferences_group_add(group, scroll);
    adw_preferences_page_add(prefs, group);
    adw_toolbar_view_set_content(ADW_TOOLBAR_VIEW(toolbar), GTK_WIDGET(prefs));
    return adw_navigation_page_new_with_tag(toolbar, "packedbox", PACKEDBOX_UI_PAGE_TAG_HOME);
}

static void packedbox_ui_app_fill_entry_list(packedbox_ui_app_t *app)
{
    size_t index = 0U;

    for (index = 0U; index < packedbox_ui_jobs_home_count(); index++) {
        packedbox_ui_home_entry_t entry;
        GtkWidget                *row = NULL;

        if (packedbox_ui_jobs_home_entry(index, &entry) != PACKEDBOX_UI_OK)
            continue;

        row = adw_action_row_new();
        adw_preferences_row_set_title(ADW_PREFERENCES_ROW(row), entry.title);
        adw_action_row_set_subtitle(ADW_ACTION_ROW(row), entry.subtitle);
        gtk_list_box_append(app->entry_list, row);
        g_object_set_data(G_OBJECT(row), "packedbox-page-tag", (gpointer)entry.page_tag);
    }
}

static void packedbox_ui_app_push_tag(packedbox_ui_app_t *app, const char *tag)
{
    if (app == NULL || tag == NULL)
        return;

    adw_navigation_view_push_by_tag(app->navigation, tag);
}

static AdwNavigationPage *packedbox_ui_app_create_page_shell(
    packedbox_ui_app_t      *app,
    const char              *title,
    const char              *tag,
    packedbox_ui_page_ctx_t *ctx_out)
{
    GtkWidget         *toolbar = adw_toolbar_view_new();
    GtkWidget         *header = adw_header_bar_new();
    GtkWidget         *content = gtk_box_new(GTK_ORIENTATION_VERTICAL, 12);
    GtkWidget         *scroll = gtk_scrolled_window_new();
    AdwNavigationPage *page = NULL;

    gtk_widget_set_margin_top(content, 12);
    gtk_widget_set_margin_bottom(content, 12);
    gtk_widget_set_margin_start(content, 12);
    gtk_widget_set_margin_end(content, 12);

    adw_header_bar_set_title_widget(ADW_HEADER_BAR(header), gtk_label_new(title));
    adw_toolbar_view_add_top_bar(ADW_TOOLBAR_VIEW(toolbar), header);

    gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scroll), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC);
    gtk_widget_set_vexpand(scroll, TRUE);
    ctx_out->app = app;
    ctx_out->output_view = GTK_TEXT_VIEW(gtk_text_view_new());
    gtk_text_view_set_editable(ctx_out->output_view, FALSE);
    gtk_text_view_set_monospace(ctx_out->output_view, TRUE);
    gtk_text_view_set_wrap_mode(ctx_out->output_view, GTK_WRAP_WORD_CHAR);
    gtk_scrolled_window_set_child(GTK_SCROLLED_WINDOW(scroll), GTK_WIDGET(ctx_out->output_view));
    gtk_box_append(GTK_BOX(content), scroll);

    ctx_out->status_label = GTK_LABEL(gtk_label_new("Ready"));
    gtk_widget_add_css_class(GTK_WIDGET(ctx_out->status_label), "dim-label");
    gtk_box_append(GTK_BOX(content), GTK_WIDGET(ctx_out->status_label));

    ctx_out->actions_box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 6);
    gtk_box_append(GTK_BOX(content), ctx_out->actions_box);

    adw_toolbar_view_set_content(ADW_TOOLBAR_VIEW(toolbar), content);
    page = adw_navigation_page_new_with_tag(toolbar, title, tag);
    g_object_set_data_full(G_OBJECT(page), "packedbox-page-ctx", ctx_out, g_free);
    g_signal_connect(page, "hiding", G_CALLBACK(packedbox_ui_page_on_hiding), ctx_out);
    packedbox_ui_page_set_output(ctx_out, "Press a button to run the backend.\n");
    return page;
}

static AdwNavigationPage *packedbox_ui_app_create_install_fix_path_page(packedbox_ui_app_t *app)
{
    packedbox_ui_page_ctx_t *ctx = g_new0(packedbox_ui_page_ctx_t, 1);
    AdwNavigationPage       *page = NULL;
    GtkWidget               *apply = gtk_button_new_with_label("Apply PATH");
    GtkWidget               *install = gtk_button_new_with_label("Install core");

    page = packedbox_ui_app_create_page_shell(
        app, "Install fix-path", PACKEDBOX_UI_PAGE_TAG_INSTALL_FIX_PATH, ctx);
    gtk_widget_add_css_class(install, "suggested-action");
    g_signal_connect(apply, "clicked", G_CALLBACK(packedbox_ui_fix_path_on_apply), ctx);
    g_signal_connect(install, "clicked", G_CALLBACK(packedbox_ui_fix_path_on_install), ctx);
    gtk_box_append(GTK_BOX(ctx->actions_box), apply);
    gtk_box_append(GTK_BOX(ctx->actions_box), install);
    return page;
}

static AdwNavigationPage *packedbox_ui_app_create_adapters_page(packedbox_ui_app_t *app)
{
    packedbox_ui_page_ctx_t *ctx = g_new0(packedbox_ui_page_ctx_t, 1);
    AdwNavigationPage       *page = NULL;
    GtkStringList           *names = gtk_string_list_new((const char *[]) { "arch", "debian", "ubuntu", NULL });
    GtkWidget               *dropdown = gtk_drop_down_new(G_LIST_MODEL(names), NULL);
    GtkWidget               *run = gtk_button_new_with_label("Run adapter install");

    page = packedbox_ui_app_create_page_shell(app, "Adapters", PACKEDBOX_UI_PAGE_TAG_ADAPTERS, ctx);
    g_object_unref(names);
    gtk_widget_add_css_class(run, "suggested-action");
    g_object_set_data(G_OBJECT(run), "packedbox-adapter-dropdown", dropdown);
    g_signal_connect(run, "clicked", G_CALLBACK(packedbox_ui_adapters_on_run), ctx);
    gtk_box_append(GTK_BOX(ctx->actions_box), dropdown);
    gtk_box_append(GTK_BOX(ctx->actions_box), run);
    return page;
}

static AdwNavigationPage *packedbox_ui_app_create_terminal_pack_page(packedbox_ui_app_t *app)
{
    packedbox_ui_page_ctx_t *ctx = g_new0(packedbox_ui_page_ctx_t, 1);
    AdwNavigationPage       *page = NULL;
    GtkWidget               *run = gtk_button_new_with_label("Install terminal pack");

    page = packedbox_ui_app_create_page_shell(
        app, "Terminal pack", PACKEDBOX_UI_PAGE_TAG_TERMINAL_PACK, ctx);
    gtk_widget_add_css_class(run, "suggested-action");
    g_signal_connect(run, "clicked", G_CALLBACK(packedbox_ui_terminal_on_run), ctx);
    gtk_box_append(GTK_BOX(ctx->actions_box), run);
    return page;
}

static AdwNavigationPage *packedbox_ui_app_create_status_page(packedbox_ui_app_t *app)
{
    packedbox_ui_page_ctx_t *ctx = g_new0(packedbox_ui_page_ctx_t, 1);
    AdwNavigationPage       *page = NULL;
    GtkWidget               *check = gtk_button_new_with_label("Check PATH");
    GtkWidget               *cli_status = gtk_button_new_with_label("CLI status");
    GtkWidget               *cli_audit = gtk_button_new_with_label("CLI audit");

    page = packedbox_ui_app_create_page_shell(app, "Status", PACKEDBOX_UI_PAGE_TAG_STATUS, ctx);
    gtk_widget_add_css_class(check, "suggested-action");
    g_object_set_data(G_OBJECT(cli_status), "packedbox-cli-cmd", "status");
    g_object_set_data(G_OBJECT(cli_audit), "packedbox-cli-cmd", "audit");
    g_signal_connect(check, "clicked", G_CALLBACK(packedbox_ui_status_on_check), ctx);
    g_signal_connect(cli_status, "clicked", G_CALLBACK(packedbox_ui_status_on_cli), ctx);
    g_signal_connect(cli_audit, "clicked", G_CALLBACK(packedbox_ui_status_on_cli), ctx);
    gtk_box_append(GTK_BOX(ctx->actions_box), check);
    gtk_box_append(GTK_BOX(ctx->actions_box), cli_status);
    gtk_box_append(GTK_BOX(ctx->actions_box), cli_audit);
    return page;
}

static void packedbox_ui_page_set_output(packedbox_ui_page_ctx_t *ctx, const char *text)
{
    GtkTextBuffer *buffer = gtk_text_view_get_buffer(ctx->output_view);
    GtkTextIter    end;

    gtk_text_buffer_set_text(buffer, text, -1);
    gtk_text_buffer_get_end_iter(buffer, &end);
    gtk_text_view_scroll_to_iter(ctx->output_view, &end, 0.0, FALSE, 0.0, 0.0);
}

static void packedbox_ui_page_set_running(packedbox_ui_page_ctx_t *ctx, int running)
{
    GtkWidget *child = NULL;

    ctx->job_running = running;
    for (child = gtk_widget_get_first_child(ctx->actions_box);
         child != NULL;
         child = gtk_widget_get_next_sibling(child))
        gtk_widget_set_sensitive(child, running ? FALSE : TRUE);
}

static void packedbox_ui_page_run_bash(
    packedbox_ui_page_ctx_t *ctx,
    const packedbox_ui_job_t *job)
{
    if (ctx->job_running)
        return;

    packedbox_ui_page_set_running(ctx, 1);
    gtk_label_set_text(ctx->status_label, "Running…");
    packedbox_ui_page_set_output(ctx, "Running backend…\n");
    packedbox_ui_runner_start(job, packedbox_ui_page_on_done, ctx, &ctx->runner);
}

static void packedbox_ui_page_on_done(const char *output, int exit_code, gpointer user_data)
{
    packedbox_ui_page_ctx_t *ctx = (packedbox_ui_page_ctx_t *)user_data;
    char                     status[128];

    packedbox_ui_page_set_output(ctx, output != NULL ? output : "");
    (void)snprintf(
        status,
        sizeof(status),
        exit_code == 0 ? "Done (exit 0)" : "Failed (exit %d)",
        exit_code);
    gtk_label_set_text(ctx->status_label, status);
    packedbox_ui_page_set_running(ctx, 0);
}

static void packedbox_ui_page_on_hiding(AdwNavigationPage *page, gpointer user_data)
{
    packedbox_ui_page_ctx_t *ctx = (packedbox_ui_page_ctx_t *)user_data;

    (void)page;
    if (ctx == NULL || !ctx->job_running)
        return;

    packedbox_ui_runner_cancel(&ctx->runner);
    packedbox_ui_page_set_running(ctx, 0);
    gtk_label_set_text(ctx->status_label, "Cancelled");
}

static void packedbox_ui_app_on_row_activated(
    GtkListBox *list_box, GtkListBoxRow *row, gpointer user_data)
{
    packedbox_ui_app_t *app = (packedbox_ui_app_t *)user_data;
    const char         *tag = NULL;

    (void)list_box;
    tag = (const char *)g_object_get_data(G_OBJECT(row), "packedbox-page-tag");
    if (tag != NULL)
        packedbox_ui_app_push_tag(app, tag);
}

static void packedbox_ui_fix_path_on_apply(GtkButton *button, gpointer user_data)
{
    packedbox_ui_page_ctx_t *ctx = (packedbox_ui_page_ctx_t *)user_data;
    packedbox_ui_job_t       job;

    (void)button;
    if (packedbox_ui_jobs_build_fix_path(ctx->app->root, 0, &job) == PACKEDBOX_UI_OK)
        packedbox_ui_page_run_bash(ctx, &job);
}

static void packedbox_ui_fix_path_on_install(GtkButton *button, gpointer user_data)
{
    packedbox_ui_page_ctx_t *ctx = (packedbox_ui_page_ctx_t *)user_data;
    packedbox_ui_job_t       job;

    (void)button;
    if (packedbox_ui_jobs_build_fix_path(ctx->app->root, 1, &job) == PACKEDBOX_UI_OK)
        packedbox_ui_page_run_bash(ctx, &job);
}

static void packedbox_ui_adapters_on_run(GtkButton *button, gpointer user_data)
{
    packedbox_ui_page_ctx_t *ctx = (packedbox_ui_page_ctx_t *)user_data;
    GtkDropDown             *dropdown = NULL;
    guint                    selected = 0U;
    packedbox_ui_job_t       job;

    dropdown = GTK_DROP_DOWN(g_object_get_data(G_OBJECT(button), "packedbox-adapter-dropdown"));
    if (dropdown == NULL)
        return;

    selected = gtk_drop_down_get_selected(dropdown);
    if (selected >= PACKEDBOX_UI_ADAPTER_COUNT)
        return;

    if (packedbox_ui_jobs_build_adapter(
            ctx->app->root,
            (packedbox_ui_adapter_t)selected,
            &job) == PACKEDBOX_UI_OK)
        packedbox_ui_page_run_bash(ctx, &job);
}

static void packedbox_ui_terminal_on_run(GtkButton *button, gpointer user_data)
{
    packedbox_ui_page_ctx_t *ctx = (packedbox_ui_page_ctx_t *)user_data;
    packedbox_ui_job_t       job;

    (void)button;
    if (packedbox_ui_jobs_build_terminal_pack(ctx->app->root, &job) == PACKEDBOX_UI_OK)
        packedbox_ui_page_run_bash(ctx, &job);
}

static void packedbox_ui_status_on_check(GtkButton *button, gpointer user_data)
{
    packedbox_ui_page_ctx_t *ctx = (packedbox_ui_page_ctx_t *)user_data;
    packedbox_ui_job_t       job;

    (void)button;
    if (packedbox_ui_jobs_build_check_path(ctx->app->root, &job) == PACKEDBOX_UI_OK)
        packedbox_ui_page_run_bash(ctx, &job);
}

static void packedbox_ui_status_on_cli(GtkButton *button, gpointer user_data)
{
    packedbox_ui_page_ctx_t *ctx = (packedbox_ui_page_ctx_t *)user_data;
    const char              *cmd = NULL;
    char                     bin[PACKEDBOX_UI_JOB_SCRIPT_BYTES];
    const char              *argv[4];

    cmd = (const char *)g_object_get_data(G_OBJECT(button), "packedbox-cli-cmd");
    if (cmd == NULL || ctx->job_running)
        return;

    if (packedbox_ui_jobs_resolve_cli(ctx->app->root, bin, sizeof(bin)) != PACKEDBOX_UI_OK) {
        packedbox_ui_page_set_output(ctx, "error: packedbox CLI not found on PATH or under native/packedbox-cli/build\n");
        return;
    }

    argv[0] = bin;
    argv[1] = cmd;
    argv[2] = NULL;

    packedbox_ui_page_set_running(ctx, 1);
    gtk_label_set_text(ctx->status_label, "Running…");
    packedbox_ui_page_set_output(ctx, "Running backend…\n");
    packedbox_ui_runner_start_argv(argv, packedbox_ui_page_on_done, ctx, &ctx->runner);
}
