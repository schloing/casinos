#ifndef MBR_H
#define MBR_H

#include <stdint.h>

struct mbr_partition_table_entry {
    uint8_t  boot_indicator;
    uint8_t  start_chs[3];
    uint8_t  partition_type;
    uint8_t  end_chs[3];
    uint32_t start_lba;
    uint32_t num_sectors;
} __attribute__((packed));

struct mbr_partition_table {
    struct mbr_partition_table_entry entries[4];
    uint16_t signature;
};

#define MBR_PARTITION_TABLE_ADDR (0x7c00 + 0x1be)

#endif
