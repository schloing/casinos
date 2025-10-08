#include <stdint.h>
#include <textmode.h>
#include <mem.h>

uint8_t buffer[MEM_BUFFER_SIZE];
struct alloc_head* root;

static void* init_root_alloc_head(void* p, uint32_t size)
{
    void* addr = p;

    while (root->next) {
        addr += root->size;
        root->next = (struct alloc_head*)addr;
        root = root->next;
    }

    root = (struct alloc_head*)addr;
    root->size = size;
    root->status = BLOCK_STATUS_RESERVED;

    return root + sizeof(struct alloc_head);
}

void* malloc(uint32_t size)
{
    if (!root) {
        return init_root_alloc_head(buffer, size);
    }

    return init_root_alloc_head(buffer, size);
}

void* calloc(uint32_t n, uint32_t size)
{
    void* new = malloc(n * size);

    for (int b = 0; b < n * size; b++) {
        ((uint32_t*)new)[b] = 0;
    }

    return new;
}

void* realloc(void* p, uint32_t size)
{
    if (!p) {
        return malloc(size);
    }

    struct alloc_head* head = (struct alloc_head*)(p - sizeof(struct alloc_head));

    if (!head) {
        // pointer was a fake allocation
        return NULL;
    }

    void* new = malloc(size);

    if (!new) {
        return NULL;
    }

    uint32_t copy_size = size > head->size ? size : head->size;

    for (int b = 0; b < copy_size; b++) {
        ((uint32_t*)new)[b] = ((uint32_t*)p)[b];
    }

    return new;
}
