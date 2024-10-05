; https://wiki.osdev.org/Ext2
; assemble and link binary with bootloader to emulate ext2fs
; INCOMPLETE
superblock:
    dd 0        ; Total number of inodes in file system
    dd 0        ; Total number of blocks in file system
    dd 0        ; Number of blocks reserved for superuser (see offset 80)
    dd 0        ; Total number of unallocated blocks
    dd 0        ; Total number of unallocated inodes
    dd 0        ; Block number of the block containing the superblock (also the starting block number, NOT always zero.)
    dd 1        ; log2 (block size) - 10. (In other words, the number to shift 1,024 to the left by to obtain the block size)
    dd 0        ; log2 (fragment size) - 10. (In other words, the number to shift 1,024 to the left by to obtain the fragment size)
    dd 0        ; Number of blocks in each block group
    dd 0        ; Number of fragments in each block group
    dd 0        ; Number of inodes in each block group
    dd 0        ; Last mount time (in POSIX time)
    dd 0        ; Last written time (in POSIX time)
    dw 0        ; Number of times the volume has been mounted since its last consistency check (fsck)
    dw 0        ; Number of mounts allowed before a consistency check (fsck) must be done
    dw 0xef53   ; Ext2 signature (0xef53), used to help confirm the presence of Ext2 on a volume
    dw 0        ; File system state (see below)
    dw 0        ; What to do when an error is detected (see below)
    dw 0        ; Minor portion of version (combine with Major portion below to construct full version field)
    dd 0        ; POSIX time of last consistency check (fsck)
    dd 0        ; Interval (in POSIX time) between forced consistency checks (fsck)
    dd 0        ; Operating system ID from which the filesystem on this volume was created (see below)
    dd 0        ; Major portion of version (combine with Minor portion above to construct full version field)
    dw 0        ; User ID that can use reserved blocks
    dw 0        ; Group ID that can use reserved blocks

times 2048-($-$$) db 0

block_group_descriptor:
    dd 0        ; Block address of block usage bitmap
    dd 0        ; Block address of inode usage bitmap
    dd inode_table ; Starting block address of inode table
    dw 0        ; Number of unallocated blocks in group
    dw 0        ; Number of unallocated inodes in group
    dw 0        ; Number of directories in group
    dd 0        ; (Unused)

inode_table:
    dw 0        ; Type and Permissions (see below)
    dw 0        ; User ID
    dd 0        ; Lower 32 bits of size in bytes
    dd 0        ; ast Access Time (in POSIX time)
    dd 0        ; Creation Time (in POSIX time)
    dd 0        ; Last Modification time (in POSIX time)
    dd 0        ; Deletion time (in POSIX time)
    dw 0        ; Group ID
    dw 0        ; Count of hard links (directory entries) to this inode. When this reaches 0, the data blocks are marked as unallocated.
    dd 0        ; Count of disk sectors (not Ext2 blocks) in use by this inode, not counting the actual inode structure nor directory entries linking to the inode.
    dd 0        ; Flags (see below)
    dd 0        ; Operating System Specific value #1
    dd 0        ; Direct Block Pointer 0
    dd 0        ; Direct Block Pointer 1
    dd 0        ; Direct Block Pointer 2
    dd 0        ; Direct Block Pointer 3
    dd 0        ; Direct Block Pointer 4
    dd 0        ; Direct Block Pointer 5
    dd 0        ; Direct Block Pointer 6
    dd 0        ; Direct Block Pointer 7
    dd 0        ; Direct Block Pointer 8
    dd 0        ; Direct Block Pointer 9
    dd 0        ; Direct Block Pointer 10
    dd 0        ; Direct Block Pointer 11
    dd 0        ; Singly Indirect Block Pointer (Points to a block that is a list of block pointers to data)
    dd 0        ; Doubly Indirect Block Pointer (Points to a block that is a list of block pointers to Singly Indirect Blocks)
    dd 0        ; Triply Indirect Block Pointer (Points to a block that is a list of block pointers to Doubly Indirect Blocks)
    dd 0        ; Generation number (Primarily used for NFS)
    dd 0        ; In Ext2 version 0, this field is reserved. In version >= 1, Extended attribute block (File ACL).
    dd 0        ; In Ext2 version 0, this field is reserved. In version >= 1, Upper 32 bits of file size (if feature bit set) if it's a file, Directory ACL if it's a directory
    dd 0        ; Block address of fragment
os_specific_value:
    db 0        ; Operating System Specific Value #2 (low 8)
    dd 0        ; Operating System Specific Value #2 (high 4)