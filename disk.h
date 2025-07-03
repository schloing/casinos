#ifndef DISK_H
#define DISK_H

#include "stdint.h"

typedef struct dapack {
    uint8_t size;
    uint8_t res;
    uint16_t sectors;
    uint32_t transfer;
    uint32_t lba_low;
    uint32_t lba_high;
} __attribute__((aligned(16))) dapack_t;

extern void diskread(void);
extern dapack_t dapack;

#endif