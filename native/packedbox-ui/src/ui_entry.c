/* ui_entry.c: dispatches headless flags and the GTK application entry. */

#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#include "packedbox_ui.h"

#ifdef PACKEDBOX_UI_HAVE_GTK
packedbox_ui_status_t packedbox_ui_app_run(int argc, char **argv);
#endif

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

/* True when flag is an exact match for --help or -h. Pure. */
static bool packedbox_ui_flag_is_help(const char *flag);

/* True when flag is an exact match for --version or -V. Pure. */
static bool packedbox_ui_flag_is_version(const char *flag);

/* Prints usage to stdout. */
static void packedbox_ui_print_usage(void);

/* Prints the version line to stdout. */
static void packedbox_ui_print_version(void);

#ifndef PACKEDBOX_UI_HAVE_GTK
/* Prints the headless stub banner when GTK is unavailable. */
static void packedbox_ui_print_stub_banner(void);
#endif

packedbox_ui_status_t packedbox_ui_run(int argc, char **argv)
{
    PACKEDBOX_UI_TRY(packedbox_ui_validate_args(argc, argv));

    if (argc > 1) {
        const char *flag = argv[1];
        if (packedbox_ui_flag_is_help(flag)) {
            packedbox_ui_print_usage();
            return PACKEDBOX_UI_OK;
        }
        if (packedbox_ui_flag_is_version(flag)) {
            packedbox_ui_print_version();
            return PACKEDBOX_UI_OK;
        }
    }

#ifdef PACKEDBOX_UI_HAVE_GTK
    return packedbox_ui_app_run(argc, argv);
#else
    packedbox_ui_print_stub_banner();
    return PACKEDBOX_UI_OK;
#endif
}

static packedbox_ui_status_t packedbox_ui_validate_args(int argc, char **argv)
{
    if (argc < 0)
        return PACKEDBOX_UI_ERR_ARG;
    if (argc > 0 && argv == NULL)
        return PACKEDBOX_UI_ERR_ARG;
    return PACKEDBOX_UI_OK;
}

static bool packedbox_ui_flag_is_help(const char *flag)
{
    assert(flag != NULL);
    return strcmp(flag, "--help") == 0 || strcmp(flag, "-h") == 0;
}

static bool packedbox_ui_flag_is_version(const char *flag)
{
    assert(flag != NULL);
    return strcmp(flag, "--version") == 0 || strcmp(flag, "-V") == 0;
}

static void packedbox_ui_print_usage(void)
{
    printf("Usage: packedbox-ui [--version|-V] [--help|-h]\n");
    printf("  Launch the packedbox GTK4/libadwaita job shell (when built with GTK).\n");
    printf("  Headless flags work without a display.\n");
}

static void packedbox_ui_print_version(void)
{
    assert(PACKEDBOX_UI_VERSION[0] != '\0');
    printf("packedbox-ui %s\n", PACKEDBOX_UI_VERSION);
}

#ifndef PACKEDBOX_UI_HAVE_GTK
/* Prints the headless stub banner when GTK is unavailable. */
static void packedbox_ui_print_stub_banner(void)
{
    assert(PACKEDBOX_UI_VERSION[0] != '\0');
    printf(
        "packedbox-ui %s (GTK4/libadwaita — rebuild with gtk4 + libadwaita-1)\n",
        PACKEDBOX_UI_VERSION);
}
#endif
