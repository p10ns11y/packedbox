#ifndef PACKEDBOX_APP_H
#define PACKEDBOX_APP_H

#include "packedbox.h"

/* Runs a one-shot status probe through the elomaxz program and prints the
 * view. Fails with PACKEDBOX_ERR_ARG on internal setup failure. */
packedbox_status_t packedbox_app_run_status(void);

/* Runs a one-shot audit probe through the elomaxz program and prints the
 * view. Fails with PACKEDBOX_ERR_ARG on internal setup failure. */
packedbox_status_t packedbox_app_run_audit(void);

#endif /* PACKEDBOX_APP_H */
