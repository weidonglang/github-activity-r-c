#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    int count;
    int min_score;
    int max_score;
    long sum_score;
    int passing_count;
    int failing_count;
    char top_student_name[128];
    int top_student_score;
} ScoreSummary;

static void trim_newline(char *text) {
    size_t len = strlen(text);
    while (len > 0 && (text[len - 1] == '\n' || text[len - 1] == '\r')) {
        text[len - 1] = '\0';
        len--;
    }
}

static int parse_score(const char *text, int *score) {
    char *endptr = NULL;

    errno = 0;
    long value = strtol(text, &endptr, 10);

    if (text == endptr || *endptr != '\0') {
        return 0;
    }

    if (errno == ERANGE || value < 0 || value > 100) {
        return 0;
    }

    *score = (int)value;
    return 1;
}

static int validate_header(const char *line) {
    return strcmp(line, "id,name,score") == 0;
}

static int analyze_csv(const char *file_path) {
    FILE *file = fopen(file_path, "r");
    if (file == NULL) {
        fprintf(stderr, "Error: unable to open file\n");
        return 1;
    }

    char line[512];
    if (fgets(line, sizeof(line), file) == NULL) {
        fprintf(stderr, "Error: no student records found\n");
        fclose(file);
        return 1;
    }

    trim_newline(line);

    if (!validate_header(line)) {
        fprintf(stderr, "Error: invalid CSV header\n");
        fclose(file);
        return 1;
    }

    ScoreSummary summary;
    summary.count = 0;
    summary.min_score = 0;
    summary.max_score = 0;
    summary.sum_score = 0;
    summary.passing_count = 0;
    summary.failing_count = 0;
    summary.top_student_name[0] = '\0';
    summary.top_student_score = 0;

    while (fgets(line, sizeof(line), file) != NULL) {
        trim_newline(line);

        if (line[0] == '\0') {
            continue;
        }

        char *id_field = strtok(line, ",");
        char *name_field = strtok(NULL, ",");
        char *score_field = strtok(NULL, ",");
        char *extra_field = strtok(NULL, ",");

        if (id_field == NULL || name_field == NULL || score_field == NULL || extra_field != NULL) {
            fprintf(stderr, "Error: invalid CSV row\n");
            fclose(file);
            return 1;
        }

        if (name_field[0] == '\0') {
            fprintf(stderr, "Error: invalid CSV row\n");
            fclose(file);
            return 1;
        }

        int score = 0;
        if (!parse_score(score_field, &score)) {
            fprintf(stderr, "Error: invalid score\n");
            fclose(file);
            return 1;
        }

        if (score < 0 || score > 100) {
            fprintf(stderr, "Error: score out of range\n");
            fclose(file);
            return 1;
        }

        if (summary.count == 0) {
            summary.min_score = score;
            summary.max_score = score;
        } else {
            if (score < summary.min_score) {
                summary.min_score = score;
            }
            if (score > summary.max_score) {
                summary.max_score = score;
            }
        }

        summary.sum_score += score;
        summary.count++;

        if (score >= 60) {
            summary.passing_count++;
        } else {
            summary.failing_count++;
        }

        if (summary.count == 1 || score > summary.top_student_score) {
            summary.top_student_score = score;
            strncpy(summary.top_student_name, name_field, sizeof(summary.top_student_name) - 1);
            summary.top_student_name[sizeof(summary.top_student_name) - 1] = '\0';
        }
    }

    fclose(file);

    if (summary.count == 0) {
        fprintf(stderr, "Error: no student records found\n");
        return 1;
    }

    double average = (double)summary.sum_score / summary.count;

    printf("Student Count: %d\n", summary.count);
    printf("Minimum Score: %d\n", summary.min_score);
    printf("Maximum Score: %d\n", summary.max_score);
    printf("Average Score: %.2f\n", average);
    printf("Passing Count: %d\n", summary.passing_count);
    printf("Failing Count: %d\n", summary.failing_count);
    printf("Top Student: %s (%d)\n", summary.top_student_name, summary.top_student_score);

    return 0;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: ./student_score_analyzer <csv_file_path>\n");
        return 1;
    }

    return analyze_csv(argv[1]);
}