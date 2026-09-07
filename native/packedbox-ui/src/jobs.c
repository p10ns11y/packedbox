/* jobs.c: CoS navigation pages and bash backend descriptors. */

#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "packedbox_ui_jobs.h"
#include "packedbox_ui_paths.h"

static const packedbox_ui_home_entry_t packedbox_ui_home_entries[] = {
    {
        "Install fix-path",
        "installers/fix-path.sh (apply or --install)",
        PACKEDBOX_UI_PAGE_TAG_INSTALL_FIX_PATH
    },
    {
        "Adapters",
        "adapters/arch|debian|ubuntu install.sh",
        PACKEDBOX_UI_PAGE_TAG_ADAPTERS
    },
    {
        "Terminal pack",
        "packs/terminal/install.sh",
        PACKEDBOX_UI_PAGE_TAG_TERMINAL_PACK
    },
    {
        "Status",
        "core/check-path.sh and packedbox status|audit",
        PACKEDBOX_UI_PAGE_TAG_STATUS
    }
};

static const char *packedbox_ui_page_titles[PACKEDBOX_UI_PAGE_COUNT] = {
    "Install fix-path",
    "Adapters",
    "Terminal pack",
    "Status"
};

static const char *packedbox_ui_page_tags[PACKEDBOX_UI_PAGE_COUNT] = {
    PACKEDBOX_UI_PAGE_TAG_INSTALL_FIX_PATH,
    PACKEDBOX_UI_PAGE_TAG_ADAPTERS,
    PACKEDBOX_UI_PAGE_TAG_TERMINAL_PACK,
    PACKEDBOX_UI_PAGE_TAG_STATUS
};

static const char *packedbox_ui_adapter_names[PACKEDBOX_UI_ADAPTER_COUNT] = {
    "arch",
    "debian",
    "ubuntu"
};

/* Initializes job_out title and zeros script/args. */
static void packedbox_ui_jobs_init_job(
    packedbox_ui_job_t       *job_out,
    packedbox_ui_page_kind_t  kind);

/* Joins root and relative script into job_out. */
static packedbox_ui_status_t packedbox_ui_jobs_set_script(
    packedbox_ui_job_t *job_out,
    const char        *root,
    const char        *relative);

size_t packedbox_ui_jobs_home_count(void)
{
    return sizeof(packedbox_ui_home_entries) / sizeof(packedbox_ui_home_entries[0]);
}

packedbox_ui_status_t packedbox_ui_jobs_home_entry(
    size_t                    index,
    packedbox_ui_home_entry_t *entry_out)
{
    if (entry_out == NULL)
        return PACKEDBOX_UI_ERR_ARG;
    if (index >= packedbox_ui_jobs_home_count())
        return PACKEDBOX_UI_ERR_ARG;

    *entry_out = packedbox_ui_home_entries[index];
    return PACKEDBOX_UI_OK;
}

size_t packedbox_ui_jobs_page_count(void)
{
    return PACKEDBOX_UI_PAGE_COUNT;
}

const char *packedbox_ui_jobs_page_tag(packedbox_ui_page_kind_t kind)
{
    if ((size_t)kind >= PACKEDBOX_UI_PAGE_COUNT)
        return NULL;

    return packedbox_ui_page_tags[kind];
}

const char *packedbox_ui_jobs_page_title(packedbox_ui_page_kind_t kind)
{
    if ((size_t)kind >= PACKEDBOX_UI_PAGE_COUNT)
        return NULL;

    return packedbox_ui_page_titles[kind];
}

packedbox_ui_status_t packedbox_ui_jobs_build_fix_path(
    const char        *root,
    int                install,
    packedbox_ui_job_t *job_out)
{
    packedbox_ui_status_t status = PACKEDBOX_UI_OK;

    if (job_out == NULL || root == NULL)
        return PACKEDBOX_UI_ERR_ARG;

    packedbox_ui_jobs_init_job(job_out, PACKEDBOX_UI_PAGE_INSTALL_FIX_PATH);
    status = packedbox_ui_jobs_set_script(job_out, root, "installers/fix-path.sh");
    if (status != PACKEDBOX_UI_OK)
        return status;

    if (install) {
        job_out->arg_count = 1U;
        (void)snprintf(job_out->args[0], sizeof(job_out->args[0]), "%s", "--install");
    }

    return PACKEDBOX_UI_OK;
}

packedbox_ui_status_t packedbox_ui_jobs_build_adapter(
    const char             *root,
    packedbox_ui_adapter_t  adapter,
    packedbox_ui_job_t     *job_out)
{
    char relative[PACKEDBOX_UI_JOB_SCRIPT_BYTES];

    if (job_out == NULL || root == NULL)
        return PACKEDBOX_UI_ERR_ARG;
    if ((size_t)adapter >= PACKEDBOX_UI_ADAPTER_COUNT)
        return PACKEDBOX_UI_ERR_ARG;

    packedbox_ui_jobs_init_job(job_out, PACKEDBOX_UI_PAGE_ADAPTERS);
    (void)snprintf(
        relative,
        sizeof(relative),
        "adapters/%s/install.sh",
        packedbox_ui_adapter_names[adapter]);
    return packedbox_ui_jobs_set_script(job_out, root, relative);
}

packedbox_ui_status_t packedbox_ui_jobs_build_terminal_pack(
    const char        *root,
    packedbox_ui_job_t *job_out)
{
    if (job_out == NULL || root == NULL)
        return PACKEDBOX_UI_ERR_ARG;

    packedbox_ui_jobs_init_job(job_out, PACKEDBOX_UI_PAGE_TERMINAL_PACK);
    return packedbox_ui_jobs_set_script(job_out, root, "packs/terminal/install.sh");
}

packedbox_ui_status_t packedbox_ui_jobs_build_check_path(
    const char        *root,
    packedbox_ui_job_t *job_out)
{
    if (job_out == NULL || root == NULL)
        return PACKEDBOX_UI_ERR_ARG;

    packedbox_ui_jobs_init_job(job_out, PACKEDBOX_UI_PAGE_STATUS);
    return packedbox_ui_jobs_set_script(job_out, root, "core/check-path.sh");
}

packedbox_ui_status_t packedbox_ui_jobs_resolve_cli(
    const char *root,
    char       *bin_out,
    size_t      bin_len)
{
    char candidate[PACKEDBOX_UI_JOB_SCRIPT_BYTES];

    if (bin_out == NULL || bin_len == 0U)
        return PACKEDBOX_UI_ERR_ARG;

    if (access("/usr/local/bin/packedbox", X_OK) == 0) {
        (void)snprintf(bin_out, bin_len, "%s", "/usr/local/bin/packedbox");
        return PACKEDBOX_UI_OK;
    }

    (void)snprintf(
        candidate,
        sizeof(candidate),
        "%s/native/packedbox-cli/build-smoke/packedbox",
        root);
    if (access(candidate, X_OK) == 0) {
        (void)snprintf(bin_out, bin_len, "%s", candidate);
        return PACKEDBOX_UI_OK;
    }

    (void)snprintf(
        candidate,
        sizeof(candidate),
        "%s/native/packedbox-cli/build/packedbox",
        root);
    if (access(candidate, X_OK) == 0) {
        (void)snprintf(bin_out, bin_len, "%s", candidate);
        return PACKEDBOX_UI_OK;
    }

    return PACKEDBOX_UI_ERR_IO;
}

const char *packedbox_ui_jobs_adapter_name(packedbox_ui_adapter_t adapter)
{
    if ((size_t)adapter >= PACKEDBOX_UI_ADAPTER_COUNT)
        return NULL;

    return packedbox_ui_adapter_names[adapter];
}

static void packedbox_ui_jobs_init_job(
    packedbox_ui_job_t       *job_out,
    packedbox_ui_page_kind_t  kind)
{
    const char *title = packedbox_ui_jobs_page_title(kind);

    assert(job_out != NULL);
    memset(job_out, 0, sizeof(*job_out));
    job_out->kind = kind;
    if (title != NULL)
        (void)snprintf(job_out->title, sizeof(job_out->title), "%s", title);
}

static packedbox_ui_status_t packedbox_ui_jobs_set_script(
    packedbox_ui_job_t *job_out,
    const char        *root,
    const char        *relative)
{
    return packedbox_ui_paths_join(
        job_out->script,
        sizeof(job_out->script),
        root,
        relative);
}
