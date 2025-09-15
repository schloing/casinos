#include <mbr.h>
#include <textmode.h>
#include <real.h>
#include <stdint.h>
#include <vbe.h>

void main_32()
{
    printf("casinoboot\n");

    struct vbe_info_structure vbe_info = {
        .signature = "VBE2"
    };

    if (vbe_controller_get_info(&vbe_info) == -1) {
        printf("failed to get vbe controller info\n");
    } else {
        printf("vbe controller get info success\n");
    }

    const struct mbr_partition_table* mbr_pt = (const struct mbr_partition_table*)MBR_PARTITION_TABLE_ADDR;
    
    for (int i = 0; i < 4; i++) {
        const struct mbr_partition_table_entry entry = mbr_pt->entries[i];
        if (entry.partition_type == 0) break;
    
        if (entry.partition_type == 0x83) {
            printf("linux partition\n");
        }
    }

//    rm_int(0x19, (void*)0, (void*)0); // reboot
}
