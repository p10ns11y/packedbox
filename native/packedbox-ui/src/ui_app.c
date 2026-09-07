/* ui_app.c: AdwNavigationView shell with tagged job pages and backend output. */

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

#define PACKEDBOX_UI_HOME_TAG "home"

typedef struct packedbox_ui_app_s packedbox_ui_app_t;

typedef struct {
    packedbox_ui_app_t     *app;
    packedbox_ui_job_kind_t kind;
    GtkTextView            *output_view;
    GtkLabel               *status_label;
    GtkButton              *run_button;
    packedbox_ui_runner_t   runner;
    int                     job_running;
} packedbox_ui_job_ctx_t;

struct packedbox_ui_app_s {
    AdwApplicationWindow *window;
    AdwNavigationView    *navigation;
    GtkListBox           *job_list;
    char                  root[PACKEDBOX_UI_PATH_BUF_BYTES];
};

/* AdwApplication activate handler. */
static void packedbox_ui_app_activate(AdwApplication *application, gpointer user_data);

/* AdwApplication startup handler. */
static void packedbox_ui_app_startup(AdwApplication *application, gpointer user_data);

/* Builds the window with AdwNavigationView and registers all pages. */
static void packedbox_ui_app_build_ui(packedbox_ui_app_t *app, AdwApplication *application);

/* Creates the home navigation page tagged home. */
static AdwNavigationPage *packedbox_ui_app_create_home_page(packedbox_ui_app_t *app);

/* Creates a job detail navigation page with toolbar and output pane. */
static AdwNavigationPage *packedbox_ui_app_create_job_page(
    packedbox_ui_app_t     *app,
    packedbox_ui_job_kind_t kind);

/* Populates the home job list. */
static void packedbox_ui_app_fill_job_list(packedbox_ui_app_t *app);

/* Pushes the navigation page for kind via push_by_tag. */
static void packedbox_ui_app_open_job(packedbox_ui_app_t *app, packedbox_ui_job_kind_t kind);

/* Sets output text and scrolls the job page text view to the end. */
static void packedbox_ui_job_set_output(packedbox_ui_job_ctx_t *ctx, const char *text);

/* Writes the intro or About body into the job page output view. */
static void packedbox_ui_job_show_intro(packedbox_ui_job_ctx_t *ctx);

/* Enables or disables run while a subprocess is active. */
static void packedbox_ui_job_set_running(packedbox_ui_job_ctx_t *ctx, int running);

/* GtkListBox row-activated handler on the home page. */
static void packedbox_ui_app_on_row_activated(
    GtkListBox    *list_box,
    GtkListBoxRow *row,
    gpointer       user_data);

/* Run button handler on a job page. */
static void packedbox_ui_job_on_run_clicked(GtkButton *button, gpointer user_data);

/* Subprocess completion handler for a job page. */
static void packedbox_ui_job_on_done(const char *output, int exit_code, gpointer user_data);

/* AdwNavigationPage showing handler — refresh intro when page opens. */
static void packedbox_ui_job_on_showing(AdwNavigationPage *page, gpointer user_data);

/* AdwNavigationPage hiding handler — cancel running subprocess on pop. */
static void packedbox_ui_job_on_hiding(AdwNavigationPage *page, gpointer user_data);

packedbox_ui_status_t packedbox_ui_app_run(int argc, char **argv)
{
    AdwApplication *application = NULL;
    int             status = 0;

    application = adw_application_new("com.packedbox.ui", G_APPLICATION_DEFAULT_FLAGS);
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
    packedbox_ui_app_t *app = NULL;

    (void)user_data;
    app = g_new0(packedbox_ui_app_t, 1);

    if (packedbox_ui_paths_resolve_root(app->root, sizeof(app->root)) != PACKEDBOX_UI_OK)
        (void)snprintf(app->root, sizeof(app->root), "%s", ".");

    packedbox_ui_app_build_ui(app, application);
    packedbox_ui_app_fill_job_list(app);
    gtk_window_present(GTK_WINDOW(app->window));
}

static void packedbox_ui_app_build_ui(packedbox_ui_app_t *app, AdwApplication *application)
{
    AdwNavigationPage *home_page = NULL;
    size_t             index = 0U;

    assert(app != NULL);
    app->window = ADW_APPLICATION_WINDOW(
        adw_application_window_new(GTK_APPLICATION(application)));
    gtk_window_set_title(GTK_WINDOW(app->window), "packedbox");
    gtk_window_set_default_size(GTK_WINDOW(app->window), 720, 520);

    app->navigation = ADW_NAVIGATION_VIEW(adw_navigation_view_new());
    adw_application_window_set_content(app->window, GTK_WIDGET(app->navigation));

    home_page = packedbox_ui_app_create_home_page(app);
    adw_navigation_view_add(app->navigation, home_page);
    adw_navigation_view_push(app->navigation, home_page);

    for (index = 0U; index < packedbox_ui_jobs_count(); index++) {
        AdwNavigationPage *job_page = packedbox_ui_app_create_job_page(
            app,
            (packedbox_ui_job_kind_t)index);
        adw_navigation_view_add(app->navigation, job_page);
    }
}

static AdwNavigationPage *packedbox_ui_app_create_home_page(packedbox_ui_app_t *app)
{
    GtkWidget          *toolbar_view = NULL;
    GtkWidget          *header = NULL;
    GtkWidget          *list_scroll = NULL;
    AdwNavigationPage  *page = NULL;
    AdwPreferencesPage *prefs_page = NULL;

    toolbar_view = adw_toolbar_view_new();
    header = adw_header_bar_new();
    adw_header_bar_set_title_widget(
        ADW_HEADER_BAR(header),
        gtk_label_new("packedbox"));
    adw_toolbar_view_add_top_bar(ADW_TOOLBAR_VIEW(toolbar_view), header);

    list_scroll = gtk_scrolled_window_new();
    gtk_scrolled_window_set_policy(
        GTK_SCROLLED_WINDOW(list_scroll),
        GTK_POLICY_NEVER,
        GTK_POLICY_AUTOMATIC);
    app->job_list = GTK_LIST_BOX(gtk_list_box_new());
    gtk_list_box_set_selection_mode(app->job_list, GTK_SELECTION_NONE);
    g_signal_connect(app->job_list, "row-activated", G_CALLBACK(packedbox_ui_app_on_row_activated), app);
    gtk_scrolled_window_set_child(GTK_SCROLLED_WINDOW(list_scroll), GTK_WIDGET(app->job_list));

    prefs_page = ADW_PREFERENCES_PAGE(adw_preferences_page_new());
    {
        AdwPreferencesGroup *group = ADW_PREFERENCES_GROUP(adw_preferences_group_new());
        adw_preferences_group_set_title(group, "Jobs");
        adw_preferences_group_add(group, list_scroll);
        adw_preferences_page_add(prefs_page, group);
    }

    adw_toolbar_view_set_content(ADW_TOOLBAR_VIEW(toolbar_view), GTK_WIDGET(prefs_page));
    page = adw_navigation_page_new_with_tag(toolbar_view, "packedbox", PACKEDBOX_UI_HOME_TAG);
    return page;
}

static AdwNavigationPage *packedbox_ui_app_create_job_page(
    packedbox_ui_app_t     *app,
    packedbox_ui_job_kind_t kind)
{
    packedbox_ui_job_t    job;
    packedbox_ui_job_ctx_t *ctx = NULL;
    GtkWidget             *toolbar_view = NULL;
    GtkWidget             *header = NULL;
    GtkWidget             *content = NULL;
    GtkWidget             *output_scroll = NULL;
    GtkWidget             *actions = NULL;
    AdwNavigationPage     *page = NULL;
    GtkTextBuffer         *buffer = NULL;
    const char            *tag = NULL;

    if (packedbox_ui_jobs_describe(kind, app->root, &job) != PACKEDBOX_UI_OK)
        return NULL;

    tag = packedbox_ui_jobs_page_tag(kind);
    if (tag == NULL)
        return NULL;

    ctx = g_new0(packedbox_ui_job_ctx_t, 1);
    ctx->app = app;
    ctx->kind = kind;

    toolbar_view = adw_toolbar_view_new();
    header = adw_header_bar_new();
    adw_header_bar_set_title_widget(ADW_HEADER_BAR(header), gtk_label_new(job.title));
    adw_toolbar_view_add_top_bar(ADW_TOOLBAR_VIEW(toolbar_view), header);

    content = gtk_box_new(GTK_ORIENTATION_VERTICAL, 12);
    gtk_widget_set_margin_top(content, 12);
    gtk_widget_set_margin_bottom(content, 12);
    gtk_widget_set_margin_start(content, 12);
    gtk_widget_set_margin_end(content, 12);

    output_scroll = gtk_scrolled_window_new();
    gtk_scrolled_window_set_policy(
        GTK_SCROLLED_WINDOW(output_scroll),
        GTK_POLICY_AUTOMATIC,
        GTK_POLICY_AUTOMATIC);
    gtk_widget_set_vexpand(output_scroll, TRUE);
    ctx->output_view = GTK_TEXT_VIEW(gtk_text_view_new());
    gtk_text_view_set_editable(ctx->output_view, FALSE);
    gtk_text_view_set_monospace(ctx->output_view, TRUE);
    gtk_text_view_set_wrap_mode(ctx->output_view, GTK_WRAP_WORD_CHAR);
    buffer = gtk_text_view_get_buffer(ctx->output_view);
    gtk_text_buffer_set_text(buffer, "", -1);
    gtk_scrolled_window_set_child(GTK_SCROLLED_WINDOW(output_scroll), GTK_WIDGET(ctx->output_view));
    gtk_box_append(GTK_BOX(content), output_scroll);

    ctx->status_label = GTK_LABEL(gtk_label_new("Ready"));
    gtk_widget_add_css_class(GTK_WIDGET(ctx->status_label), "dim-label");
    gtk_box_append(GTK_BOX(content), GTK_WIDGET(ctx->status_label));

    actions = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 6);
    ctx->run_button = GTK_BUTTON(gtk_button_new_with_label("Run"));
    gtk_widget_add_css_class(GTK_WIDGET(ctx->run_button), "suggested-action");
    g_signal_connect(ctx->run_button, "clicked", G_CALLBACK(packedbox_ui_job_on_run_clicked), ctx);
    gtk_box_append(GTK_BOX(actions), GTK_WIDGET(ctx->run_button));
    gtk_box_append(GTK_BOX(content), actions);

    adw_toolbar_view_set_content(ADW_TOOLBAR_VIEW(toolbar_view), content);
    page = adw_navigation_page_new_with_tag(toolbar_view, job.title, tag);
    g_object_set_data_full(G_OBJECT(page), "packedbox-job-ctx", ctx, g_free);
    g_signal_connect(page, "showing", G_CALLBACK(packedbox_ui_job_on_showing), ctx);
    g_signal_connect(page, "hiding", G_CALLBACK(packedbox_ui_job_on_hiding), ctx);
    packedbox_ui_job_show_intro(ctx);
    return page;
}

static void packedbox_ui_app_fill_job_list(packedbox_ui_app_t *app)
{
    size_t index = 0U;

    assert(app != NULL);
    for (index = 0U; index < packedbox_ui_jobs_count(); index++) {
        packedbox_ui_job_t job;
        GtkWidget         *row = NULL;

        if (packedbox_ui_jobs_describe((packedbox_ui_job_kind_t)index, app->root, &job) != PACKEDBOX_UI_OK)
            continue;

        row = adw_action_row_new();
        adw_preferences_row_set_title(ADW_PREFERENCES_ROW(row), job.title);
        gtk_list_box_append(app->job_list, row);
        g_object_set_data(G_OBJECT(row), "packedbox-job-kind", GUINT_TO_POINTER(job.kind));
    }
}

static void packedbox_ui_app_open_job(packedbox_ui_app_t *app, packedbox_ui_job_kind_t kind)
{
    const char *tag = NULL;

    assert(app != NULL);
    tag = packedbox_ui_jobs_page_tag(kind);
    if (tag == NULL)
        return;

    adw_navigation_view_push_by_tag(app->navigation, tag);
}

static void packedbox_ui_job_set_output(packedbox_ui_job_ctx_t *ctx, const char *text)
{
    GtkTextBuffer *buffer = NULL;
    GtkTextIter    end;

    assert(ctx != NULL);
    assert(text != NULL);
    buffer = gtk_text_view_get_buffer(ctx->output_view);
    gtk_text_buffer_set_text(buffer, text, -1);
    gtk_text_buffer_get_end_iter(buffer, &end);
    gtk_text_view_scroll_to_iter(ctx->output_view, &end, 0.0, FALSE, 0.0, 0.0);
}

static void packedbox_ui_job_show_intro(packedbox_ui_job_ctx_t *ctx)
{
    packedbox_ui_job_t job;
    char               about_buf[PACKEDBOX_UI_OUTPUT_BYTES];

    assert(ctx != NULL);
    if (packedbox_ui_jobs_describe(ctx->kind, ctx->app->root, &job) != PACKEDBOX_UI_OK)
        return;

    gtk_label_set_text(ctx->status_label, "Ready");

    if (ctx->kind == PACKEDBOX_UI_JOB_ABOUT) {
        if (packedbox_ui_jobs_about_text(about_buf, sizeof(about_buf)) == PACKEDBOX_UI_OK)
            packedbox_ui_job_set_output(ctx, about_buf);
        return;
    }

    {
        char intro[PACKEDBOX_UI_OUTPUT_BYTES];
        (void)snprintf(
            intro,
            sizeof(intro),
            "Backend: bash %s\nRepository: %s\n\nPress Run to start.\n",
            job.script,
            ctx->app->root);
        packedbox_ui_job_set_output(ctx, intro);
    }
}

static void packedbox_ui_job_set_running(packedbox_ui_job_ctx_t *ctx, int running)
{
    assert(ctx != NULL);
    ctx->job_running = running;
    gtk_widget_set_sensitive(GTK_WIDGET(ctx->run_button), running ? FALSE : TRUE);
}

static void packedbox_ui_app_on_row_activated(
    GtkListBox    *list_box,
    GtkListBoxRow *row,
    gpointer       user_data)
{
    packedbox_ui_app_t      *app = (packedbox_ui_app_t *)user_data;
    packedbox_ui_job_kind_t  kind = PACKEDBOX_UI_JOB_FIX_PATH;
    gpointer                 kind_ptr = NULL;

    (void)list_box;
    kind_ptr = g_object_get_data(G_OBJECT(row), "packedbox-job-kind");
    if (kind_ptr == NULL)
        return;

    kind = (packedbox_ui_job_kind_t)GPOINTER_TO_UINT(kind_ptr);
    packedbox_ui_app_open_job(app, kind);
}

static void packedbox_ui_job_on_run_clicked(GtkButton *button, gpointer user_data)
{
    packedbox_ui_job_ctx_t *ctx = (packedbox_ui_job_ctx_t *)user_data;
    packedbox_ui_job_t      job;

    (void)button;
    assert(ctx != NULL);

    if (ctx->job_running)
        return;

    if (packedbox_ui_jobs_describe(ctx->kind, ctx->app->root, &job) != PACKEDBOX_UI_OK)
        return;

    if (ctx->kind == PACKEDBOX_UI_JOB_ABOUT) {
        char about_buf[PACKEDBOX_UI_OUTPUT_BYTES];
        if (packedbox_ui_jobs_about_text(about_buf, sizeof(about_buf)) == PACKEDBOX_UI_OK)
            packedbox_ui_job_set_output(ctx, about_buf);
        gtk_label_set_text(ctx->status_label, "Done");
        return;
    }

    packedbox_ui_job_set_running(ctx, 1);
    gtk_label_set_text(ctx->status_label, "Running…");
    packedbox_ui_job_set_output(ctx, "Running backend…\n");
    packedbox_ui_runner_start(&job, packedbox_ui_job_on_done, ctx, &ctx->runner);
}

static void packedbox_ui_job_on_done(const char *output, int exit_code, gpointer user_data)
{
    packedbox_ui_job_ctx_t *ctx = (packedbox_ui_job_ctx_t *)user_data;
    char                    status[128];

    assert(ctx != NULL);
    packedbox_ui_job_set_output(ctx, output != NULL ? output : "");
    (void)snprintf(
        status,
        sizeof(status),
        exit_code == 0 ? "Done (exit 0) — use header back or Run again" :
                         "Failed (exit %d) — use header back or retry",
        exit_code);
    gtk_label_set_text(ctx->status_label, status);
    packedbox_ui_job_set_running(ctx, 0);
}

static void packedbox_ui_job_on_showing(AdwNavigationPage *page, gpointer user_data)
{
    packedbox_ui_job_ctx_t *ctx = (packedbox_ui_job_ctx_t *)user_data;

    (void)page;
    if (ctx == NULL || ctx->job_running)
        return;

    packedbox_ui_job_show_intro(ctx);
}

static void packedbox_ui_job_on_hiding(AdwNavigationPage *page, gpointer user_data)
{
    packedbox_ui_job_ctx_t *ctx = (packedbox_ui_job_ctx_t *)user_data;

    (void)page;
    if (ctx == NULL || !ctx->job_running)
        return;

    packedbox_ui_runner_cancel(&ctx->runner);
    packedbox_ui_job_set_running(ctx, 0);
    gtk_label_set_text(ctx->status_label, "Cancelled");
}
