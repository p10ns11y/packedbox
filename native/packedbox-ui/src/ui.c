/* ui.c: owns packedbox-ui stub entry until GTK4 lands in Phase 4. */

#include <assert.h>
#include <stdio.h>

#include "packedbox_ui.h"

/* Propagates any non-OK status to the caller. Permitted only in
 * functions that acquire nothing. Sole macro allowed to return. */
#define PACKEDBOX_UI_TRY(expr)                                  \
    do {                                                        \
        packedbox_ui_status_t packedbox_ui_try_s_ = (expr);     \
        if (packedbox_ui_try_s_ != PACKEDBOX_UI_OK)             \
            return packedbox_ui_try_s_;                         \
    } while (0)

/* Rejects a NULL argv when argc is positive. Fails with PACKEDBOX_UI_ERR_ARG. */
static packedbox_ui_status_t packedbox_ui_validate_args(int argc, char **argv);

/* Prints the stub banner to stdout. */
static void packedbox_ui_print_banner(void);

packedbox_ui_status_t packedbox_ui_run(int argc, char **argv)
{
    PACKEDBOX_UI_TRY(packedbox_ui_validate_args(argc, argv));
    packedbox_ui_print_banner();
    return PACKEDBOX_UI_OK;
}

static packedbox_ui_status_t packedbox_ui_validate_args(int argc, char **argv)
{
    if (argc < 0)
        return PACKEDBOX_UI_ERR_ARG;
    if (argc > 0 && argv == NULL)
        return PACKEDBOX_UI_ERR_ARG;
    return PACKEDBOX_UI_OK;
}

static void packedbox_ui_print_banner(void)
{
    assert(PACKEDBOX_UI_VERSION[0] != '\0');
    printf("packedbox-ui %s (GTK4/libadwaita — Phase 4)\n", PACKEDBOX_UI_VERSION);
}
