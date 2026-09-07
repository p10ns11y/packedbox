/* paths.c: resolves packedbox repository root for backend script dispatch. */

#include <assert.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "packedbox_ui_paths.h"

enum {
    PACKEDBOX_UI_PATH_WALK_MAX = 12
};

/* True when candidate contains core/path.contract. Pure. */
static int packedbox_ui_paths_is_root(const char *candidate);

/* Copies the current executable directory into dir_out. Fails with
 * PACKEDBOX_UI_ERR_IO when the path cannot be resolved. */
static packedbox_ui_status_t packedbox_ui_paths_exe_dir(char *dir_out, size_t dir_len);

/* Walks parent directories from start_dir looking for a packedbox root. */
static packedbox_ui_status_t packedbox_ui_paths_walk_up(
    char       *root_out,
    size_t      root_len,
    const char *start_dir);

packedbox_ui_status_t packedbox_ui_paths_resolve_root(char *root_out, size_t root_len)
{
    const char *env_root = NULL;
    char        exe_dir[PACKEDBOX_UI_PATH_BUF_BYTES];

    if (root_out == NULL || root_len == 0U)
        return PACKEDBOX_UI_ERR_ARG;

    env_root = getenv("PACKEDBOX_ROOT");
    if (env_root != NULL && packedbox_ui_paths_is_root(env_root)) {
        (void)snprintf(root_out, root_len, "%s", env_root);
        return PACKEDBOX_UI_OK;
    }

    if (packedbox_ui_paths_exe_dir(exe_dir, sizeof(exe_dir)) != PACKEDBOX_UI_OK)
        return PACKEDBOX_UI_ERR_IO;

    return packedbox_ui_paths_walk_up(root_out, root_len, exe_dir);
}

packedbox_ui_status_t packedbox_ui_paths_join(
    char       *script_out,
    size_t      script_len,
    const char *root,
    const char *relative)
{
    int written = 0;

    if (script_out == NULL || root == NULL || relative == NULL)
        return PACKEDBOX_UI_ERR_ARG;
    if (script_len == 0U)
        return PACKEDBOX_UI_ERR_ARG;

    written = snprintf(script_out, script_len, "%s/%s", root, relative);
    if (written < 0 || (size_t)written >= script_len)
        return PACKEDBOX_UI_ERR_IO;

    return PACKEDBOX_UI_OK;
}

static int packedbox_ui_paths_is_root(const char *candidate)
{
    char marker[PACKEDBOX_UI_PATH_BUF_BYTES];
    int  written = 0;

    assert(candidate != NULL);
    written = snprintf(marker, sizeof(marker), "%s/core/path.contract", candidate);
    if (written < 0 || (size_t)written >= sizeof(marker))
        return 0;

    return access(marker, R_OK) == 0;
}

static packedbox_ui_status_t packedbox_ui_paths_exe_dir(char *dir_out, size_t dir_len)
{
    char   exe_path[PATH_MAX];
    char  *slash = NULL;
    ssize_t read_len = 0;

    assert(dir_out != NULL);
    read_len = readlink("/proc/self/exe", exe_path, sizeof(exe_path) - 1U);
    if (read_len < 0)
        return PACKEDBOX_UI_ERR_IO;

    exe_path[(size_t)read_len] = '\0';
    slash = strrchr(exe_path, '/');
    if (slash == NULL)
        return PACKEDBOX_UI_ERR_IO;

    *slash = '\0';
    (void)snprintf(dir_out, dir_len, "%s", exe_path);
    return PACKEDBOX_UI_OK;
}

static packedbox_ui_status_t packedbox_ui_paths_walk_up(
    char       *root_out,
    size_t      root_len,
    const char *start_dir)
{
    char current[PACKEDBOX_UI_PATH_BUF_BYTES];
    char resolved[PACKEDBOX_UI_PATH_BUF_BYTES];
    char parent[PACKEDBOX_UI_PATH_BUF_BYTES];
    int  depth = 0;
    int  written = 0;

    assert(start_dir != NULL);
    (void)snprintf(current, sizeof(current), "%s", start_dir);

    for (depth = 0; depth < PACKEDBOX_UI_PATH_WALK_MAX; depth++) {
        if (realpath(current, resolved) == NULL)
            return PACKEDBOX_UI_ERR_IO;

        if (packedbox_ui_paths_is_root(resolved)) {
            (void)snprintf(root_out, root_len, "%s", resolved);
            return PACKEDBOX_UI_OK;
        }

        if (strcmp(resolved, "/") == 0)
            break;

        written = snprintf(parent, sizeof(parent), "%s/..", resolved);
        if (written < 0 || (size_t)written >= sizeof(parent))
            return PACKEDBOX_UI_ERR_IO;

        if (realpath(parent, current) == NULL)
            return PACKEDBOX_UI_ERR_IO;
    }

    return PACKEDBOX_UI_ERR_IO;
}
