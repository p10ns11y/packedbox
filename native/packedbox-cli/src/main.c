/* main.c: process entry for packedbox-cli. Adapts status to exit codes. */

#include "packedbox.h"

enum {
    PACKEDBOX_EXIT_OK      = 0,
    PACKEDBOX_EXIT_FAILURE = 1,
    PACKEDBOX_EXIT_USAGE   = 2
};

/* Maps a module status to a process exit code. Pure. */
static int packedbox_status_to_exit(packedbox_status_t status);

int main(int argc, char **argv)
{
    packedbox_status_t status = packedbox_cli_run(argc, argv);
    return packedbox_status_to_exit(status);
}

static int packedbox_status_to_exit(packedbox_status_t status)
{
    switch (status) {
    case PACKEDBOX_OK:
        return PACKEDBOX_EXIT_OK;
    case PACKEDBOX_ERR_ARG:
        return PACKEDBOX_EXIT_USAGE;
    case PACKEDBOX_ERR_UNKNOWN:
        return PACKEDBOX_EXIT_USAGE;
    default:
        return PACKEDBOX_EXIT_FAILURE;
    }
}
