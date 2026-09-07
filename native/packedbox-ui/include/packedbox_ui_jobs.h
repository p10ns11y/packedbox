#ifndef PACKEDBOX_UI_JOBS_H
#define PACKEDBOX_UI_JOBS_H

#include <stddef.h>

#include "packedbox_ui.h"

enum {
    PACKEDBOX_UI_JOB_TITLE_BYTES = 64,
    PACKEDBOX_UI_JOB_SCRIPT_BYTES = 512,
    PACKEDBOX_UI_JOB_ARG_BYTES    = 64,
    PACKEDBOX_UI_JOB_ARG_COUNT    = 4
};

typedef enum {
    PACKEDBOX_UI_JOB_FIX_PATH          = 0,
    PACKEDBOX_UI_JOB_CHECK_PATH        = 1,
    PACKEDBOX_UI_JOB_INSTALL_CORE      = 2,
    PACKEDBOX_UI_JOB_INSTALL_TERMINAL  = 3,
    PACKEDBOX_UI_JOB_ABOUT             = 4,
    PACKEDBOX_UI_JOB_COUNT             = 5
} packedbox_ui_job_kind_t;

typedef struct {
    packedbox_ui_job_kind_t kind;
    char                    title[PACKEDBOX_UI_JOB_TITLE_BYTES];
    char                    script[PACKEDBOX_UI_JOB_SCRIPT_BYTES];
    char                    args[PACKEDBOX_UI_JOB_ARG_COUNT][PACKEDBOX_UI_JOB_ARG_BYTES];
    size_t                  arg_count;
    int                     is_shell_job;
} packedbox_ui_job_t;

/* Returns the number of jobs in the catalog. Pure. */
size_t packedbox_ui_jobs_count(void);

/* Copies metadata for job kind into job_out. Fails with PACKEDBOX_UI_ERR_ARG
 * when job_out is NULL or kind is invalid. Resolves script paths from root. */
packedbox_ui_status_t packedbox_ui_jobs_describe(
    packedbox_ui_job_kind_t kind,
    const char             *root,
    packedbox_ui_job_t     *job_out);

/* Writes the About panel body into buf. Fails with PACKEDBOX_UI_ERR_ARG when
 * buf is NULL or too small. */
packedbox_ui_status_t packedbox_ui_jobs_about_text(char *buf, size_t buf_len);

/* Returns the AdwNavigationView page tag for kind. NULL when invalid. */
const char *packedbox_ui_jobs_page_tag(packedbox_ui_job_kind_t kind);

#endif /* PACKEDBOX_UI_JOBS_H */
