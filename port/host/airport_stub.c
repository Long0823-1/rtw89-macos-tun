// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
// This build always uses a utun interface; the System Settings kext path of the full project is not present.
#include <stddef.h>
int airport_data_ready(void) { return 0; }
void airport_assoc_failed(void) {}
void airport_bounce_link(void) {}
void airport_data_active(int on) { (void)on; }
void airport_publish_start(const unsigned char mac[6]) { (void)mac; }
void airport_bridge_start(void) {}
