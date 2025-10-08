#ifndef MEM_H
#define MEM_H

#include <stdint.h>

#define MEM_BUFFER_SIZE 256

typedef uint8_t block_status;
#define BLOCK_STATUS_RESERVED 0
#define BLOCK_STATUS_FREED    1

struct alloc_head;

struct alloc_head {
    uint32_t size;
    block_status status;
    struct alloc_head* next;
};

void* malloc(uint32_t size);
void* calloc(uint32_t n, uint32_t size);
void* realloc(void* p, uint32_t size);

#endif
