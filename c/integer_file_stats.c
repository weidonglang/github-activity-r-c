#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: ./integer_file_stats <file_path>\n");
        return 1;
    }

    FILE *file = fopen(argv[1], "r");
    if (file == NULL) {
        fprintf(stderr, "Error: unable to open file\n");
        return 1;
    }

    long value = 0;
    long count = 0;
    long min_value = 0;
    long max_value = 0;
    long sum = 0;

    while (fscanf(file, "%ld", &value) == 1) {
        if (count == 0) {
            min_value = value;
            max_value = value;
        } else {
            if (value < min_value) {
                min_value = value;
            }

            if (value > max_value) {
                max_value = value;
            }
        }

        sum += value;
        count++;
    }

    fclose(file);

    if (count == 0) {
        fprintf(stderr, "Error: no integers found\n");
        return 1;
    }

    double mean = (double)sum / count;

    printf("Count: %ld\n", count);
    printf("Min: %ld\n", min_value);
    printf("Max: %ld\n", max_value);
    printf("Sum: %ld\n", sum);
    printf("Mean: %.2f\n", mean);

    return 0;
}