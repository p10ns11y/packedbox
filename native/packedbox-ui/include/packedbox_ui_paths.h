#ifndef PACKEDBOX_UI_PATHS_H
#define PACKEDBOX_UI_PATHS_H

#include <stddef.h>

#include "packedbox_ui.h"

enum {
    PACKEDBOX_UI_PATH_BUF_BYTES = 512
};

/* Resolves the packedbox repository root into root_out. Prefers PACKEDBOX_ROOT
 * when it contains core/path.contract, else walks up from the executable.
 * Fails with PACKEDBOX_UI_ERR_IO when no root is found. */
packedbox_ui_status_t packedbox_ui_paths_resolve_root(char *root_out, size_t root_len);

/* Joins root and a relative script path into script_out. Fails with
 * PACKEDBOX_UI_ERR_ARG on invalid buffers or PACKEDBOX_UI_ERR_IO when the
 * joined path is too long. */
packedbox_ui_status_t packedbox_ui_paths_join(
    char *script_out,
    size_t script_len,
    const char *root,
    const char *relative);

#endif /* PACKEDBOX_UI_PATHS_H */
