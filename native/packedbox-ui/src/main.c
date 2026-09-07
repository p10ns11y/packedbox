/* main.c: process entry for packedbox-ui. Adapts status to exit codes. */

#include "packedbox_ui.h"

enum {
    PACKEDBOX_UI_EXIT_OK      = 0,
    PACKEDBOX_UI_EXIT_FAILURE = 1,
    PACKEDBOX_UI_EXIT_USAGE   = 2
};

/* Maps a module status to a process exit code. Pure. */
static int packedbox_ui_status_to_exit(packedbox_ui_status_t status);

int main(int argc, char **argv)
{
    packedbox_ui_status_t status = packedbox_ui_run(argc, argv);
    return packedbox_ui_status_to_exit(status);
}

static int packedbox_ui_status_to_exit(packedbox_ui_status_t status)
{
    switch (status) {
    case PACKEDBOX_UI_OK:
        return PACKEDBOX_UI_EXIT_OK;
    case PACKEDBOX_UI_ERR_ARG:
        return PACKEDBOX_UI_EXIT_USAGE;
    default:
        return PACKEDBOX_UI_EXIT_FAILURE;
    }
}
