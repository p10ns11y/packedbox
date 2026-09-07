/* jobs.c: catalog of packedbox UI jobs that shell out to existing backends. */

#include <assert.h>
#include <stdio.h>
#include <string.h>

#include "packedbox_ui_jobs.h"
#include "packedbox_ui_paths.h"

typedef struct {
    packedbox_ui_job_kind_t kind;
    const char             *title;
    const char             *relative_script;
    const char             *args[PACKEDBOX_UI_JOB_ARG_COUNT];
    size_t                  arg_count;
    int                     is_shell_job;
} packedbox_ui_job_spec_t;

static const packedbox_ui_job_spec_t packedbox_ui_job_specs[PACKEDBOX_UI_JOB_COUNT] = {
    {
        PACKEDBOX_UI_JOB_FIX_PATH,
        "Fix PATH",
        "installers/fix-path.sh",
        { NULL },
        0U,
        1
    },
    {
        PACKEDBOX_UI_JOB_CHECK_PATH,
        "Check PATH",
        "core/check-path.sh",
        { NULL },
        0U,
        1
    },
    {
        PACKEDBOX_UI_JOB_INSTALL_CORE,
        "Install core",
        "installers/fix-path.sh",
        { "--install", NULL },
        1U,
        1
    },
    {
        PACKEDBOX_UI_JOB_INSTALL_TERMINAL,
        "Install terminal pack",
        "packs/terminal/install.sh",
        { NULL },
        0U,
        1
    },
    {
        PACKEDBOX_UI_JOB_ABOUT,
        "About",
        "",
        { NULL },
        0U,
        0
    }
};

/* Copies args from spec into job_out. */
static void packedbox_ui_jobs_copy_args(
    packedbox_ui_job_t             *job_out,
    const packedbox_ui_job_spec_t  *spec);

size_t packedbox_ui_jobs_count(void)
{
    return PACKEDBOX_UI_JOB_COUNT;
}

packedbox_ui_status_t packedbox_ui_jobs_describe(
    packedbox_ui_job_kind_t  kind,
    const char              *root,
    packedbox_ui_job_t        *job_out)
{
    const packedbox_ui_job_spec_t *spec = NULL;

    if (job_out == NULL)
        return PACKEDBOX_UI_ERR_ARG;
    if ((size_t)kind >= PACKEDBOX_UI_JOB_COUNT)
        return PACKEDBOX_UI_ERR_ARG;

    spec = &packedbox_ui_job_specs[kind];
    memset(job_out, 0, sizeof(*job_out));
    job_out->kind = kind;
    job_out->is_shell_job = spec->is_shell_job;
    job_out->arg_count = spec->arg_count;
    (void)snprintf(job_out->title, sizeof(job_out->title), "%s", spec->title);
    packedbox_ui_jobs_copy_args(job_out, spec);

    if (!spec->is_shell_job)
        return PACKEDBOX_UI_OK;

    if (root == NULL)
        return PACKEDBOX_UI_ERR_IO;

    return packedbox_ui_paths_join(
        job_out->script,
        sizeof(job_out->script),
        root,
        spec->relative_script);
}

packedbox_ui_status_t packedbox_ui_jobs_about_text(char *buf, size_t buf_len)
{
    if (buf == NULL || buf_len == 0U)
        return PACKEDBOX_UI_ERR_ARG;

    (void)snprintf(
        buf,
        buf_len,
        "packedbox-ui %s\n"
        "GTK4 + libadwaita thin shell over packedbox shell backends.\n\n"
        "Jobs call installers/fix-path.sh, core/check-path.sh, and\n"
        "packs/terminal/install.sh — the same paths as the CLI and adapters.\n\n"
        "Set PACKEDBOX_ROOT to override repository discovery.\n",
        PACKEDBOX_UI_VERSION);
    return PACKEDBOX_UI_OK;
}

static void packedbox_ui_jobs_copy_args(
    packedbox_ui_job_t            *job_out,
    const packedbox_ui_job_spec_t *spec)
{
    size_t index = 0U;

    assert(job_out != NULL);
    assert(spec != NULL);

    for (index = 0U; index < spec->arg_count; index++) {
        assert(spec->args[index] != NULL);
        (void)snprintf(
            job_out->args[index],
            sizeof(job_out->args[index]),
            "%s",
            spec->args[index]);
    }
}
