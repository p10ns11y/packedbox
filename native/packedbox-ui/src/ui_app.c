/* ui_app.c: GTK4/libadwaita shell with job list and backend output pane. */

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

typedef struct {
    AdwApplicationWindow *window;
    GtkStack             *stack;
    GtkListBox           *job_list;
    GtkTextView          *output_view;
    GtkLabel             *detail_title;
    GtkButton            *run_button;
    GtkButton            *back_button;
    GtkLabel             *status_label;
    char                  root[PACKEDBOX_UI_PATH_BUF_BYTES];
    packedbox_ui_job_kind_t selected;
    packedbox_ui_runner_t   runner;
    int                   job_running;
} packedbox_ui_app_t;

/* Creates widgets and wires signals for the application window. */
static void packedbox_ui_app_build_ui(packedbox_ui_app_t *app, AdwApplication *application);

/* Populates the job list from the catalog. */
static void packedbox_ui_app_fill_job_list(packedbox_ui_app_t *app);

/* Switches to the detail page for the selected job kind. */
static void packedbox_ui_app_show_detail(packedbox_ui_app_t *app, packedbox_ui_job_kind_t kind);

/* Appends text to the output view and scrolls to the end. */
static void packedbox_ui_app_set_output(packedbox_ui_app_t *app, const char *text);

/* Enables or disables run/back controls while a job runs. */
static void packedbox_ui_app_set_running(packedbox_ui_app_t *app, int running);

/* GtkListBox row-activated handler. */
static void packedbox_ui_app_on_row_activated(
    GtkListBox    *list_box,
    GtkListBoxRow *row,
    gpointer       user_data);

/* Run button clicked handler. */
static void packedbox_ui_app_on_run_clicked(GtkButton *button, gpointer user_data);

/* Back button clicked handler. */
static void packedbox_ui_app_on_back_clicked(GtkButton *button, gpointer user_data);

/* Subprocess completion callback. */
static void packedbox_ui_app_on_job_done(const char *output, int exit_code, gpointer user_data);

/* AdwApplication activate handler. */
static void packedbox_ui_app_activate(AdwApplication *application, gpointer user_data);

/* AdwApplication startup handler — load libadwaita. */
static void packedbox_ui_app_startup(AdwApplication *application, gpointer user_data);

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
    app->selected = PACKEDBOX_UI_JOB_FIX_PATH;

    if (packedbox_ui_paths_resolve_root(app->root, sizeof(app->root)) != PACKEDBOX_UI_OK)
        (void)snprintf(app->root, sizeof(app->root), "%s", ".");

    packedbox_ui_app_build_ui(app, application);
    packedbox_ui_app_fill_job_list(app);
    gtk_window_present(GTK_WINDOW(app->window));
}

static void packedbox_ui_app_build_ui(packedbox_ui_app_t *app, AdwApplication *application)
{
    GtkWidget     *toolbar_view = NULL;
    GtkWidget     *list_page = NULL;
    GtkWidget     *detail_page = NULL;
    GtkWidget     *list_scroll = NULL;
    GtkWidget     *output_scroll = NULL;
    GtkWidget     *detail_box = NULL;
    GtkWidget     *detail_actions = NULL;
    GtkTextBuffer *buffer = NULL;

    assert(app != NULL);
    app->window = ADW_APPLICATION_WINDOW(
        adw_application_window_new(GTK_APPLICATION(application)));
    gtk_window_set_title(GTK_WINDOW(app->window), "packedbox");

    toolbar_view = adw_toolbar_view_new();
    app->stack = GTK_STACK(gtk_stack_new());
    gtk_stack_set_transition_type(app->stack, GTK_STACK_TRANSITION_TYPE_SLIDE_LEFT_RIGHT);

    list_scroll = gtk_scrolled_window_new();
    gtk_scrolled_window_set_policy(
        GTK_SCROLLED_WINDOW(list_scroll),
        GTK_POLICY_NEVER,
        GTK_POLICY_AUTOMATIC);
    app->job_list = GTK_LIST_BOX(gtk_list_box_new());
    gtk_list_box_set_selection_mode(app->job_list, GTK_SELECTION_NONE);
    g_signal_connect(app->job_list, "row-activated", G_CALLBACK(packedbox_ui_app_on_row_activated), app);
    gtk_widget_add_css_class(GTK_WIDGET(app->job_list), "navigation-sidebar");
    gtk_scrolled_window_set_child(GTK_SCROLLED_WINDOW(list_scroll), GTK_WIDGET(app->job_list));

    list_page = adw_preferences_page_new();
    {
        AdwPreferencesGroup *group = ADW_PREFERENCES_GROUP(adw_preferences_group_new());
        adw_preferences_group_set_title(group, "Jobs");
        adw_preferences_group_add(group, list_scroll);
        adw_preferences_page_add(ADW_PREFERENCES_PAGE(list_page), group);
    }

    detail_box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 12);
    gtk_widget_set_margin_top(detail_box, 12);
    gtk_widget_set_margin_bottom(detail_box, 12);
    gtk_widget_set_margin_start(detail_box, 12);
    gtk_widget_set_margin_end(detail_box, 12);

    app->detail_title = GTK_LABEL(gtk_label_new(""));
    gtk_widget_add_css_class(GTK_WIDGET(app->detail_title), "title-2");
    gtk_box_append(GTK_BOX(detail_box), GTK_WIDGET(app->detail_title));

    output_scroll = gtk_scrolled_window_new();
    gtk_scrolled_window_set_policy(
        GTK_SCROLLED_WINDOW(output_scroll),
        GTK_POLICY_AUTOMATIC,
        GTK_POLICY_AUTOMATIC);
    gtk_widget_set_vexpand(output_scroll, TRUE);
    app->output_view = GTK_TEXT_VIEW(gtk_text_view_new());
    gtk_text_view_set_editable(app->output_view, FALSE);
    gtk_text_view_set_monospace(app->output_view, TRUE);
    gtk_text_view_set_wrap_mode(app->output_view, GTK_WRAP_WORD_CHAR);
    buffer = gtk_text_view_get_buffer(app->output_view);
    gtk_text_buffer_set_text(buffer, "Select Run to execute this job.", -1);
    gtk_scrolled_window_set_child(GTK_SCROLLED_WINDOW(output_scroll), GTK_WIDGET(app->output_view));
    gtk_box_append(GTK_BOX(detail_box), output_scroll);

    app->status_label = GTK_LABEL(gtk_label_new("Ready"));
    gtk_widget_add_css_class(GTK_WIDGET(app->status_label), "dim-label");
    gtk_box_append(GTK_BOX(detail_box), GTK_WIDGET(app->status_label));

    detail_actions = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 6);
    app->back_button = GTK_BUTTON(gtk_button_new_with_label("Back to jobs"));
    app->run_button = GTK_BUTTON(gtk_button_new_with_label("Run"));
    gtk_widget_add_css_class(GTK_WIDGET(app->run_button), "suggested-action");
    g_signal_connect(app->back_button, "clicked", G_CALLBACK(packedbox_ui_app_on_back_clicked), app);
    g_signal_connect(app->run_button, "clicked", G_CALLBACK(packedbox_ui_app_on_run_clicked), app);
    gtk_box_append(GTK_BOX(detail_actions), GTK_WIDGET(app->back_button));
    gtk_box_append(GTK_BOX(detail_actions), GTK_WIDGET(app->run_button));
    gtk_box_append(GTK_BOX(detail_box), detail_actions);

    detail_page = detail_box;

    gtk_stack_add_named(app->stack, list_page, "list");
    gtk_stack_add_named(app->stack, detail_page, "detail");
    adw_toolbar_view_set_content(ADW_TOOLBAR_VIEW(toolbar_view), GTK_WIDGET(app->stack));
    adw_application_window_set_content(app->window, toolbar_view);
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

static void packedbox_ui_app_show_detail(packedbox_ui_app_t *app, packedbox_ui_job_kind_t kind)
{
    packedbox_ui_job_t job;
    char               about_buf[PACKEDBOX_UI_OUTPUT_BYTES];

    assert(app != NULL);
    app->selected = kind;

    if (packedbox_ui_jobs_describe(kind, app->root, &job) != PACKEDBOX_UI_OK)
        return;

    gtk_label_set_text(app->detail_title, job.title);
    gtk_label_set_text(app->status_label, "Ready");

    if (kind == PACKEDBOX_UI_JOB_ABOUT) {
        if (packedbox_ui_jobs_about_text(about_buf, sizeof(about_buf)) == PACKEDBOX_UI_OK)
            packedbox_ui_app_set_output(app, about_buf);
    } else {
        char intro[PACKEDBOX_UI_OUTPUT_BYTES];
        (void)snprintf(
            intro,
            sizeof(intro),
            "Backend: bash %s\nRepository: %s\n\nPress Run to start.\n",
            job.script,
            app->root);
        packedbox_ui_app_set_output(app, intro);
    }

    gtk_stack_set_visible_child_name(app->stack, "detail");
}

static void packedbox_ui_app_set_output(packedbox_ui_app_t *app, const char *text)
{
    GtkTextBuffer *buffer = NULL;
    GtkTextIter    end;

    assert(app != NULL);
    assert(text != NULL);
    buffer = gtk_text_view_get_buffer(app->output_view);
    gtk_text_buffer_set_text(buffer, text, -1);
    gtk_text_buffer_get_end_iter(buffer, &end);
    gtk_text_view_scroll_to_iter(app->output_view, &end, 0.0, FALSE, 0.0, 0.0);
}

static void packedbox_ui_app_set_running(packedbox_ui_app_t *app, int running)
{
    assert(app != NULL);
    app->job_running = running;
    gtk_widget_set_sensitive(GTK_WIDGET(app->run_button), running ? FALSE : TRUE);
    gtk_widget_set_sensitive(GTK_WIDGET(app->back_button), running ? FALSE : TRUE);
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
    packedbox_ui_app_show_detail(app, kind);
}

static void packedbox_ui_app_on_run_clicked(GtkButton *button, gpointer user_data)
{
    packedbox_ui_app_t *app = (packedbox_ui_app_t *)user_data;
    packedbox_ui_job_t  job;

    (void)button;
    assert(app != NULL);

    if (app->job_running)
        return;

    if (packedbox_ui_jobs_describe(app->selected, app->root, &job) != PACKEDBOX_UI_OK)
        return;

    if (app->selected == PACKEDBOX_UI_JOB_ABOUT) {
        char about_buf[PACKEDBOX_UI_OUTPUT_BYTES];
        if (packedbox_ui_jobs_about_text(about_buf, sizeof(about_buf)) == PACKEDBOX_UI_OK)
            packedbox_ui_app_set_output(app, about_buf);
        gtk_label_set_text(app->status_label, "Done");
        return;
    }

    packedbox_ui_app_set_running(app, 1);
    gtk_label_set_text(app->status_label, "Running…");
    packedbox_ui_app_set_output(app, "Running backend…\n");
    packedbox_ui_runner_start(&job, packedbox_ui_app_on_job_done, app, &app->runner);
}

static void packedbox_ui_app_on_back_clicked(GtkButton *button, gpointer user_data)
{
    packedbox_ui_app_t *app = (packedbox_ui_app_t *)user_data;

    (void)button;
    if (app->job_running)
        packedbox_ui_runner_cancel(&app->runner);

    gtk_stack_set_visible_child_name(app->stack, "list");
}

static void packedbox_ui_app_on_job_done(const char *output, int exit_code, gpointer user_data)
{
    packedbox_ui_app_t *app = (packedbox_ui_app_t *)user_data;
    char                status[128];

    assert(app != NULL);
    packedbox_ui_app_set_output(app, output != NULL ? output : "");
    (void)snprintf(
        status,
        sizeof(status),
        exit_code == 0 ? "Done (exit 0) — Back or Run again" : "Failed (exit %d) — Back or retry",
        exit_code);
    gtk_label_set_text(app->status_label, status);
    packedbox_ui_app_set_running(app, 0);
}
