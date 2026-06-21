#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: ./string_length <text>\n");
        return 1;
    }

    printf("%zu\n", strlen(argv[1]));
    return 0;
}