typedef signed char        int8_t;
typedef unsigned char      uint8_t;
typedef short              int16_t;
typedef unsigned short     uint16_t;
typedef int                int32_t;
typedef unsigned int       uint32_t;
typedef long long          int64_t;
typedef unsigned long long uint64_t;

struct rm_regs {
    uint16_t gs;
    uint16_t fs;
    uint16_t es;
    uint16_t ds;
    uint32_t eflags;
    uint32_t ebp;
    uint32_t edi;
    uint32_t esi;
    uint32_t edx;
    uint32_t ecx;
    uint32_t ebx;
    uint32_t eax;
} __attribute__((packed));

void rm_int(uint8_t int_no, struct rm_regs* in_regs, struct rm_regs* out_regs);

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
#define VIDEO_MEMORY 0xb8000
#define SCREEN_COLS 80
#define SCREEN_ROWS 25

static int cursor_row = 0;

void write_string(const char* string, int colour) {
    static char* video = (char*)VIDEO_MEMORY;

    while (*string != 0) {
        *video++ = *string++;
        *video++ = colour;
    }
}

void main_32() {
    write_string("casinoboot", 0x0f);

    const struct mbr_partition_table* mbr_pt = (const struct mbr_partition_table*)MBR_PARTITION_TABLE_ADDR;
    
    for (int i = 0; i < 4; i++) {
        const struct mbr_partition_table_entry entry = mbr_pt->entries[i];
        if (entry.partition_type == 0) break;
    
        if (entry.partition_type == 0x83) {
            write_string("linux partition", 0x0f);
        }
    }
}
