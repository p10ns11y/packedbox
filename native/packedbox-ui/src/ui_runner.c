/* ui_runner.c: runs packedbox UI jobs via bash subprocesses. */

#include <assert.h>
#include <gio/gio.h>
#include <glib.h>
#include <stdio.h>
#include <string.h>

#include "packedbox_ui_jobs.h"
#include "packedbox_ui_runner.h"

enum {
    PACKEDBOX_UI_RUNNER_ARGV_MAX = 8
};

/* Builds argv for bash script execution into argv_out. Returns argc or -1. */
static int packedbox_ui_runner_build_argv(
    const packedbox_ui_job_t *job,
    const char              *argv_out[PACKEDBOX_UI_RUNNER_ARGV_MAX]);

/* Appends captured stdout to the text buffer. */
static void packedbox_ui_runner_finish(
    GObject      *source,
    GAsyncResult *result,
    gpointer      user_data);

/* Starts communicate_async on the running subprocess. */
static void packedbox_ui_runner_read_output(packedbox_ui_runner_t *runner);

/* Launches argv with merged stdout/stderr pipes. */
static void packedbox_ui_runner_launch_argv(
    const char *const            *argv,
    packedbox_ui_runner_done_fn   on_done,
    gpointer                      user_data,
    packedbox_ui_runner_t        *runner_out);

void packedbox_ui_runner_start(
    const packedbox_ui_job_t     *job,
    packedbox_ui_runner_done_fn   on_done,
    gpointer                      user_data,
    packedbox_ui_runner_t        *runner_out)
{
    const char *argv[PACKEDBOX_UI_RUNNER_ARGV_MAX];
    int         argc = 0;

    assert(job != NULL);
    argc = packedbox_ui_runner_build_argv(job, argv);
    if (argc < 0) {
        on_done("error: failed to build job argv\n", 1, user_data);
        return;
    }

    packedbox_ui_runner_launch_argv(argv, on_done, user_data, runner_out);
}

void packedbox_ui_runner_start_argv(
    const char *const            *argv,
    packedbox_ui_runner_done_fn   on_done,
    gpointer                      user_data,
    packedbox_ui_runner_t        *runner_out)
{
    assert(argv != NULL);
    packedbox_ui_runner_launch_argv(argv, on_done, user_data, runner_out);
}

void packedbox_ui_runner_cancel(packedbox_ui_runner_t *runner)
{
    if (runner == NULL || runner->process == NULL)
        return;

    g_subprocess_force_exit(runner->process);
    g_clear_object(&runner->process);
}

static void packedbox_ui_runner_launch_argv(
    const char *const            *argv,
    packedbox_ui_runner_done_fn   on_done,
    gpointer                      user_data,
    packedbox_ui_runner_t        *runner_out)
{
    GError *error = NULL;

    assert(on_done != NULL);
    assert(runner_out != NULL);

    runner_out->on_done = on_done;
    runner_out->user_data = user_data;
    runner_out->process = NULL;

    runner_out->process = g_subprocess_newv(
        argv,
        (GSubprocessFlags)(G_SUBPROCESS_FLAGS_STDOUT_PIPE | G_SUBPROCESS_FLAGS_STDERR_MERGE),
        &error);
    if (runner_out->process == NULL) {
        char message[256];
        (void)snprintf(
            message,
            sizeof(message),
            "error: %s\n",
            error != NULL ? error->message : "subprocess start failed");
        g_clear_error(&error);
        on_done(message, 1, user_data);
        return;
    }

    packedbox_ui_runner_read_output(runner_out);
}

static int packedbox_ui_runner_build_argv(
    const packedbox_ui_job_t *job,
    const char              *argv_out[PACKEDBOX_UI_RUNNER_ARGV_MAX])
{
    size_t slot = 0U;

    assert(job != NULL);
    assert(argv_out != NULL);

    argv_out[slot++] = "/bin/bash";
    argv_out[slot++] = job->script;
    for (size_t index = 0U; index < job->arg_count; index++)
        argv_out[slot++] = job->args[index];
    if (slot >= PACKEDBOX_UI_RUNNER_ARGV_MAX)
        return -1;

    argv_out[slot] = NULL;
    return (int)slot;
}

static void packedbox_ui_runner_read_output(packedbox_ui_runner_t *runner)
{
    assert(runner != NULL);
    assert(runner->process != NULL);

    g_subprocess_communicate_async(
        runner->process,
        NULL,
        NULL,
        packedbox_ui_runner_finish,
        runner);
}

static void packedbox_ui_runner_finish(
    GObject      *source,
    GAsyncResult *result,
    gpointer      user_data)
{
    packedbox_ui_runner_t *runner = (packedbox_ui_runner_t *)user_data;
    GSubprocess           *process = G_SUBPROCESS(source);
    GBytes                *stdout_bytes = NULL;
    GError                *error = NULL;
    int                    exit_code = 1;
    const char            *output = "";
    gsize                  output_len = 0U;

    if (!g_subprocess_communicate_finish(process, result, &stdout_bytes, NULL, &error)) {
        char message[256];
        (void)snprintf(
            message,
            sizeof(message),
            "error: %s\n",
            error != NULL ? error->message : "communicate failed");
        g_clear_error(&error);
        runner->on_done(message, 1, runner->user_data);
        g_clear_object(&runner->process);
        return;
    }

    exit_code = (int)g_subprocess_get_exit_status(process);
    if (stdout_bytes != NULL)
        output = (const char *)g_bytes_get_data(stdout_bytes, &output_len);
    runner->on_done(output != NULL ? output : "", exit_code, runner->user_data);
    if (stdout_bytes != NULL)
        g_bytes_unref(stdout_bytes);
    g_clear_object(&runner->process);
}
