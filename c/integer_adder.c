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
    if (argc != 3) {
        fprintf(stderr, "Usage: ./integer_adder <integer1> <integer2>\n");
        return 1;
    }

    long first = 0;
    long second = 0;

    if (!parse_integer(argv[1], &first) || !parse_integer(argv[2], &second)) {
        fprintf(stderr, "Error: invalid integer input\n");
        return 1;
    }

    printf("%ld\n", first + second);
    return 0;
}