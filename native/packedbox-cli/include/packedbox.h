#ifndef PACKEDBOX_H
#define PACKEDBOX_H

#include <stddef.h>

enum {
    PACKEDBOX_VERSION_MAJOR = 0,
    PACKEDBOX_VERSION_MINOR = 1,
    PACKEDBOX_VERSION_PATCH = 0
};

#define PACKEDBOX_VERSION "0.1.0"

typedef enum {
    PACKEDBOX_OK          = 0,
    PACKEDBOX_ERR_ARG     = 1,
    PACKEDBOX_ERR_UNKNOWN = 2
} packedbox_status_t;

/* Runs the CLI. argc/argv are borrowed. Returns PACKEDBOX_OK on success,
 * PACKEDBOX_ERR_ARG on bad usage, PACKEDBOX_ERR_UNKNOWN for unknown flags. */
packedbox_status_t packedbox_cli_run(int argc, char **argv);

/* Writes a NUL-terminated version string into buf. Fails with
 * PACKEDBOX_ERR_ARG when buf is NULL or buf_len is zero. */
packedbox_status_t packedbox_version_copy(char *buf, size_t buf_len);

#endif /* PACKEDBOX_H */
