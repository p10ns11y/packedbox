#ifndef PACKEDBOX_UI_JOBS_H
#define PACKEDBOX_UI_JOBS_H

#include <stddef.h>

#include "packedbox_ui.h"

#define PACKEDBOX_UI_PAGE_TAG_HOME              "home"
#define PACKEDBOX_UI_PAGE_TAG_INSTALL_FIX_PATH  "install-fix-path"
#define PACKEDBOX_UI_PAGE_TAG_ADAPTERS          "adapters"
#define PACKEDBOX_UI_PAGE_TAG_TERMINAL_PACK     "terminal-pack"
#define PACKEDBOX_UI_PAGE_TAG_STATUS            "status"

enum {
    PACKEDBOX_UI_JOB_TITLE_BYTES  = 64,
    PACKEDBOX_UI_JOB_SCRIPT_BYTES = 512,
    PACKEDBOX_UI_JOB_ARG_BYTES    = 64,
    PACKEDBOX_UI_JOB_ARG_COUNT    = 4
};

typedef enum {
    PACKEDBOX_UI_PAGE_INSTALL_FIX_PATH = 0,
    PACKEDBOX_UI_PAGE_ADAPTERS         = 1,
    PACKEDBOX_UI_PAGE_TERMINAL_PACK    = 2,
    PACKEDBOX_UI_PAGE_STATUS           = 3,
    PACKEDBOX_UI_PAGE_COUNT            = 4
} packedbox_ui_page_kind_t;

typedef enum {
    PACKEDBOX_UI_ADAPTER_ARCH   = 0,
    PACKEDBOX_UI_ADAPTER_DEBIAN   = 1,
    PACKEDBOX_UI_ADAPTER_UBUNTU   = 2,
    PACKEDBOX_UI_ADAPTER_COUNT    = 3
} packedbox_ui_adapter_t;

typedef struct {
    const char *title;
    const char *subtitle;
    const char *page_tag;
} packedbox_ui_home_entry_t;

typedef struct {
    packedbox_ui_page_kind_t kind;
    char                     title[PACKEDBOX_UI_JOB_TITLE_BYTES];
    char                     script[PACKEDBOX_UI_JOB_SCRIPT_BYTES];
    char                     args[PACKEDBOX_UI_JOB_ARG_COUNT][PACKEDBOX_UI_JOB_ARG_BYTES];
    size_t                   arg_count;
} packedbox_ui_job_t;

/* Returns home navigation entry count. Pure. */
size_t packedbox_ui_jobs_home_count(void);

/* Copies home entry index into entry_out. Fails with PACKEDBOX_UI_ERR_ARG. */
packedbox_ui_status_t packedbox_ui_jobs_home_entry(
    size_t                   index,
    packedbox_ui_home_entry_t *entry_out);

/* Returns navigation page count (excludes home). Pure. */
size_t packedbox_ui_jobs_page_count(void);

/* Returns the page tag for kind. NULL when invalid. */
const char *packedbox_ui_jobs_page_tag(packedbox_ui_page_kind_t kind);

/* Returns the page title for kind. NULL when invalid. */
const char *packedbox_ui_jobs_page_title(packedbox_ui_page_kind_t kind);

/* Builds a bash job for installers/fix-path.sh. install nonzero adds --install. */
packedbox_ui_status_t packedbox_ui_jobs_build_fix_path(
    const char        *root,
    int                install,
    packedbox_ui_job_t *job_out);

/* Builds a bash job for adapters/<name>/install.sh. */
packedbox_ui_status_t packedbox_ui_jobs_build_adapter(
    const char             *root,
    packedbox_ui_adapter_t  adapter,
    packedbox_ui_job_t     *job_out);

/* Builds a bash job for packs/terminal/install.sh. */
packedbox_ui_status_t packedbox_ui_jobs_build_terminal_pack(
    const char        *root,
    packedbox_ui_job_t *job_out);

/* Builds a bash job for core/check-path.sh. */
packedbox_ui_status_t packedbox_ui_jobs_build_check_path(
    const char        *root,
    packedbox_ui_job_t *job_out);

/* Resolves packedbox CLI binary into bin_out when present on PATH or under
 * root/native/packedbox-cli/build*. Fails with PACKEDBOX_UI_ERR_IO when not
 * found. */
packedbox_ui_status_t packedbox_ui_jobs_resolve_cli(
    const char *root,
    char       *bin_out,
    size_t      bin_len);

/* Returns adapter display name. NULL when invalid. */
const char *packedbox_ui_jobs_adapter_name(packedbox_ui_adapter_t adapter);

#endif /* PACKEDBOX_UI_JOBS_H */
