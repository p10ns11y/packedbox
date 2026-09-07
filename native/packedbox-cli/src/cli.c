/* cli.c: owns packedbox CLI argument dispatch and version reporting. */

#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#include "packedbox.h"
#include "packedbox_app.h"

enum {
    PACKEDBOX_VERSION_BUF_BYTES = 32
};

/* Propagates any non-OK status to the caller. Permitted only in
 * functions that acquire nothing. Sole macro allowed to return. */
#define PACKEDBOX_TRY(expr)                             \
    do {                                                \
        packedbox_status_t packedbox_try_s_ = (expr);   \
        if (packedbox_try_s_ != PACKEDBOX_OK)           \
            return packedbox_try_s_;                    \
    } while (0)

/* Rejects a NULL argv when argc is positive. Fails with PACKEDBOX_ERR_ARG. */
static packedbox_status_t packedbox_validate_cli_args(int argc, char **argv);

/* True when flag is an exact match for --help or -h. Pure. */
static bool packedbox_flag_is_help(const char *flag);

/* True when flag is an exact match for --version or -V. Pure. */
static bool packedbox_flag_is_version(const char *flag);

/* True when flag requests the status command. Pure. */
static bool packedbox_flag_is_status(const char *flag);

/* True when flag requests the audit command. Pure. */
static bool packedbox_flag_is_audit(const char *flag);

/* Prints usage to stdout. */
static void packedbox_print_usage(void);

/* Prints the version line to stdout. */
static void packedbox_print_version(void);

/* Reports an unknown flag on stderr and prints usage. */
static void packedbox_report_unknown_flag(const char *flag);

packedbox_status_t packedbox_cli_run(int argc, char **argv)
{
    PACKEDBOX_TRY(packedbox_validate_cli_args(argc, argv));

    if (argc <= 1) {
        packedbox_print_version();
        return PACKEDBOX_OK;
    }

    const char *flag = argv[1];
    if (packedbox_flag_is_help(flag)) {
        packedbox_print_usage();
        return PACKEDBOX_OK;
    }
    if (packedbox_flag_is_version(flag)) {
        packedbox_print_version();
        return PACKEDBOX_OK;
    }
    if (packedbox_flag_is_status(flag))
        return packedbox_app_run_status();
    if (packedbox_flag_is_audit(flag))
        return packedbox_app_run_audit();

    packedbox_report_unknown_flag(flag);
    return PACKEDBOX_ERR_UNKNOWN;
}

packedbox_status_t packedbox_version_copy(char *buf, size_t buf_len)
{
    if (buf == NULL)
        return PACKEDBOX_ERR_ARG;
    if (buf_len == 0)
        return PACKEDBOX_ERR_ARG;

    (void)snprintf(buf, buf_len, "%s", PACKEDBOX_VERSION);
    return PACKEDBOX_OK;
}

static packedbox_status_t packedbox_validate_cli_args(int argc, char **argv)
{
    if (argc < 0)
        return PACKEDBOX_ERR_ARG;
    if (argc > 0 && argv == NULL)
        return PACKEDBOX_ERR_ARG;
    return PACKEDBOX_OK;
}

static bool packedbox_flag_is_help(const char *flag)
{
    assert(flag != NULL);
    return strcmp(flag, "--help") == 0 || strcmp(flag, "-h") == 0;
}

static bool packedbox_flag_is_version(const char *flag)
{
    assert(flag != NULL);
    return strcmp(flag, "--version") == 0 || strcmp(flag, "-V") == 0;
}

static bool packedbox_flag_is_status(const char *flag)
{
    assert(flag != NULL);
    return strcmp(flag, "status") == 0;
}

static bool packedbox_flag_is_audit(const char *flag)
{
    assert(flag != NULL);
    return strcmp(flag, "audit") == 0;
}

static void packedbox_print_usage(void)
{
    printf("Usage: packedbox [--version|-V] [--help|-h] [status|audit]\n");
    printf("  status  Probe installed core and terminal pack\n");
    printf("  audit   Summarize install completeness\n");
}

static void packedbox_print_version(void)
{
    char version[PACKEDBOX_VERSION_BUF_BYTES];
    packedbox_status_t status = packedbox_version_copy(version, sizeof(version));

    assert(status == PACKEDBOX_OK);
    (void)status;
    printf("packedbox %s\n", version);
}

static void packedbox_report_unknown_flag(const char *flag)
{
    assert(flag != NULL);
    fprintf(stderr, "packedbox: unknown argument '%s'\n", flag);
    packedbox_print_usage();
}
