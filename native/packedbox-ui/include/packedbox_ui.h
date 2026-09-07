#ifndef PACKEDBOX_UI_H
#define PACKEDBOX_UI_H

enum {
    PACKEDBOX_UI_VERSION_MAJOR = 0,
    PACKEDBOX_UI_VERSION_MINOR = 2,
    PACKEDBOX_UI_VERSION_PATCH = 0
};

#define PACKEDBOX_UI_VERSION "0.2.0"

typedef enum {
    PACKEDBOX_UI_OK      = 0,
    PACKEDBOX_UI_ERR_ARG = 1
} packedbox_ui_status_t;

/* Runs the UI stub entry. argc/argv are borrowed. Fails with
 * PACKEDBOX_UI_ERR_ARG on invalid arguments. Phase 4 replaces the body
 * with GtkApplication + AdwApplicationWindow. */
packedbox_ui_status_t packedbox_ui_run(int argc, char **argv);

#endif /* PACKEDBOX_UI_H */
