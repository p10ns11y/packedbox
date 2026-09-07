#ifndef PACKEDBOX_UI_RUNNER_H
#define PACKEDBOX_UI_RUNNER_H

#include <glib.h>

#include "packedbox_ui_jobs.h"

typedef void (*packedbox_ui_runner_done_fn)(
    const char *output,
    int         exit_code,
    gpointer    user_data);

typedef struct {
    GSubprocess              *process;
    packedbox_ui_runner_done_fn on_done;
    gpointer                  user_data;
} packedbox_ui_runner_t;

/* Starts job via bash and invokes on_done with merged stdout/stderr. */
void packedbox_ui_runner_start(
    const packedbox_ui_job_t     *job,
    packedbox_ui_runner_done_fn   on_done,
    gpointer                      user_data,
    packedbox_ui_runner_t        *runner_out);

/* Starts argv directly (e.g. packedbox status). argv must be NULL-terminated. */
void packedbox_ui_runner_start_argv(
    const char *const            *argv,
    packedbox_ui_runner_done_fn   on_done,
    gpointer                      user_data,
    packedbox_ui_runner_t        *runner_out);

/* Cancels a running subprocess if any. */
void packedbox_ui_runner_cancel(packedbox_ui_runner_t *runner);

#endif /* PACKEDBOX_UI_RUNNER_H */
