/* app.c: owns packedbox elomaxz model for status and audit one-shots. */

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "elomaxz.h"
#include "packedbox_app.h"

enum {
    PACKEDBOX_SUMMARY_BYTES = 256,
    PACKEDBOX_PATH_BYTES    = 512,
    PACKEDBOX_BATCH_MSGS    = 1
};

typedef enum {
    PACKEDBOX_MSG_STATUS = 1,
    PACKEDBOX_MSG_AUDIT  = 2
} packedbox_msg_type_t;

typedef struct {
    packedbox_msg_type_t type;
} packedbox_msg_t;

typedef struct {
    int  core_present;
    int  pack_present;
    char summary[PACKEDBOX_SUMMARY_BYTES];
} packedbox_model_t;

/* Builds the elomaxz program table for packedbox. */
static ElomaxzProgram packedbox_make_program(void);

/* Runs one message through elomaxz_run_batch. */
static packedbox_status_t packedbox_run_one_msg(packedbox_msg_type_t type);

/* elomaxz callbacks — foreign void* boundary; see deviation notes below. */
static Model packedbox_app_init(void);
static Model packedbox_app_update(Model current, Msg msg, Cmd *cmds_out, size_t *num_cmds_out);
static void packedbox_app_view(Model model);
static void packedbox_app_free_model(Model model);
static void packedbox_app_free_msg(Msg msg);
static void packedbox_app_free_cmd(Cmd cmd);
static const char *packedbox_app_msg_name(Msg msg);

/* Probes whether the PATH core is installed under ~/.config/packedbox. */
static int packedbox_probe_core_present(void);

/* Probes whether the terminal pack tree is installed. */
static int packedbox_probe_pack_present(void);

/* Writes a status summary into the model. */
static void packedbox_model_apply_status(packedbox_model_t *model);

/* Writes an audit summary into the model. */
static void packedbox_model_apply_audit(packedbox_model_t *model);

packedbox_status_t packedbox_app_run_status(void)
{
    return packedbox_run_one_msg(PACKEDBOX_MSG_STATUS);
}

packedbox_status_t packedbox_app_run_audit(void)
{
    return packedbox_run_one_msg(PACKEDBOX_MSG_AUDIT);
}

static packedbox_status_t packedbox_run_one_msg(packedbox_msg_type_t type)
{
    packedbox_msg_t *msg = malloc(sizeof(*msg));
    if (msg == NULL)
        return PACKEDBOX_ERR_ARG;

    msg->type = type;

    Msg batch[PACKEDBOX_BATCH_MSGS];
    batch[0] = (Msg)msg;

    ElomaxzProgram prog = packedbox_make_program();
    elomaxz_run_batch(&prog, batch, PACKEDBOX_BATCH_MSGS);
    return PACKEDBOX_OK;
}

static ElomaxzProgram packedbox_make_program(void)
{
    /* Deviation: elomaxz public API uses untyped Model/Msg/Cmd pointers and
     * function-pointer fields on a mutable program struct (foreign MVU ABI). */
    ElomaxzProgram prog = {
        .init = packedbox_app_init,
        .update = packedbox_app_update,
        .view = packedbox_app_view,
        .free_model = packedbox_app_free_model,
        .free_msg = packedbox_app_free_msg,
        .free_cmd = packedbox_app_free_cmd,
        .msg_name = packedbox_app_msg_name,
        .debug_model = NULL,
        .handle_cmd = NULL,
        .parent = NULL,
        .message_bus = NULL,
        .debug = false,
        .user_data = NULL
    };
    return prog;
}

static Model packedbox_app_init(void)
{
    packedbox_model_t *model = calloc(1, sizeof(*model));
    if (model == NULL)
        return NULL;

    (void)snprintf(model->summary, sizeof(model->summary), "packedbox ready");
    return (Model)model;
}

static Model packedbox_app_update(Model current, Msg msg, Cmd *cmds_out, size_t *num_cmds_out)
{
    packedbox_model_t *old_model = (packedbox_model_t *)current;
    packedbox_msg_t *app_msg = (packedbox_msg_t *)msg;
    packedbox_model_t *new_model = malloc(sizeof(*new_model));

    if (cmds_out != NULL && num_cmds_out != NULL)
        *num_cmds_out = 0;

    /* elomaxz_run_batch always frees the previous model, so failure must not
     * return current — return NULL and let the runner stop cleanly. */
    if (old_model == NULL || app_msg == NULL) {
        free(new_model);
        return NULL;
    }
    if (new_model == NULL)
        return NULL;

    *new_model = *old_model;

    switch (app_msg->type) {
    case PACKEDBOX_MSG_STATUS:
        packedbox_model_apply_status(new_model);
        break;
    case PACKEDBOX_MSG_AUDIT:
        packedbox_model_apply_audit(new_model);
        break;
    default:
        (void)snprintf(new_model->summary, sizeof(new_model->summary), "unknown message");
        break;
    }

    return (Model)new_model;
}

static void packedbox_app_view(Model model)
{
    packedbox_model_t *app_model = (packedbox_model_t *)model;
    if (app_model == NULL) {
        printf("packedbox: (no model)\n");
        return;
    }
    printf("%s\n", app_model->summary);
}

static void packedbox_app_free_model(Model model)
{
    free(model);
}

static void packedbox_app_free_msg(Msg msg)
{
    free(msg);
}

static void packedbox_app_free_cmd(Cmd cmd)
{
    free(cmd);
}

static const char *packedbox_app_msg_name(Msg msg)
{
    packedbox_msg_t *app_msg = (packedbox_msg_t *)msg;
    if (app_msg == NULL)
        return "NULL";

    switch (app_msg->type) {
    case PACKEDBOX_MSG_STATUS:
        return "STATUS";
    case PACKEDBOX_MSG_AUDIT:
        return "AUDIT";
    default:
        return "UNKNOWN";
    }
}

static int packedbox_probe_core_present(void)
{
    char path[PACKEDBOX_PATH_BYTES];
    const char *home = getenv("HOME");

    if (home == NULL)
        return 0;

    (void)snprintf(path, sizeof(path), "%s/.config/packedbox/core/path.contract", home);
    return access(path, R_OK) == 0;
}

static int packedbox_probe_pack_present(void)
{
    char path[PACKEDBOX_PATH_BYTES];
    const char *home = getenv("HOME");

    if (home == NULL)
        return 0;

    (void)snprintf(
        path,
        sizeof(path),
        "%s/.config/packedbox/packs/terminal/ghostty/fragment.conf",
        home);
    return access(path, R_OK) == 0;
}

static void packedbox_model_apply_status(packedbox_model_t *model)
{
    assert(model != NULL);
    model->core_present = packedbox_probe_core_present();
    model->pack_present = packedbox_probe_pack_present();
    (void)snprintf(
        model->summary,
        sizeof(model->summary),
        "packedbox status: core=%s pack=%s version=%s",
        model->core_present ? "yes" : "no",
        model->pack_present ? "yes" : "no",
        PACKEDBOX_VERSION);
}

static void packedbox_model_apply_audit(packedbox_model_t *model)
{
    assert(model != NULL);
    packedbox_model_apply_status(model);

    if (model->core_present && model->pack_present) {
        (void)snprintf(
            model->summary,
            sizeof(model->summary),
            "packedbox audit: ok (core + terminal pack)");
        return;
    }

    (void)snprintf(
        model->summary,
        sizeof(model->summary),
        "packedbox audit: incomplete (core=%s pack=%s)",
        model->core_present ? "yes" : "no",
        model->pack_present ? "yes" : "no");
}
