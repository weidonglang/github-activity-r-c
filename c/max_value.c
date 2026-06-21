#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>

static int parse_integer(const char *text, long *result) {
    char *endptr = NULL;

    errno = 0;
    long value = strtol(text, &endptr, 10);

    if (text == endptr || *endptr != '\0') {
        return 0;
    }

    if ((errno == ERANGE) || value < INT_MIN || value > INT_MAX) {
        return 0;
    }

    *result = value;
    return 1;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: ./max_value <integer1> [integer2 ...]\n");
        return 1;
    }

    long max_value = 0;

    if (!parse_integer(argv[1], &max_value)) {
        fprintf(stderr, "Error: invalid integer input\n");
        return 1;
    }

    for (int i = 2; i < argc; i++) {
        long current = 0;

        if (!parse_integer(argv[i], &current)) {
            fprintf(stderr, "Error: invalid integer input\n");
            return 1;
        }

        if (current > max_value) {
            max_value = current;
        }
    }

    printf("%ld\n", max_value);
    return 0;
}