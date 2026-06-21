#include <errno.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char name[128];
    double revenue;
} RevenueGroup;

typedef struct {
    int order_count;
    long total_quantity;
    double total_revenue;
    RevenueGroup products[128];
    int product_count;
    RevenueGroup categories[128];
    int category_count;
} SalesSummary;

static void trim_newline(char *text) {
    size_t len = strlen(text);
    while (len > 0 && (text[len - 1] == '\n' || text[len - 1] == '\r')) {
        text[len - 1] = '\0';
        len--;
    }
}

static int parse_positive_long(const char *text, long *result) {
    char *endptr = NULL;

    errno = 0;
    long value = strtol(text, &endptr, 10);

    if (text == endptr || *endptr != '\0') {
        return 0;
    }

    if (errno == ERANGE || value <= 0) {
        return 0;
    }

    *result = value;
    return 1;
}

static int parse_double(const char *text, double *result) {
    char *endptr = NULL;

    errno = 0;
    double value = strtod(text, &endptr);

    if (text == endptr || *endptr != '\0') {
        return 0;
    }

    if (errno == ERANGE) {
        return 0;
    }

    *result = value;
    return 1;
}

static int validate_header(const char *line) {
    return strcmp(line, "order_id,product,category,quantity,unit_price") == 0;
}

static int split_sales_row(char *line, char **order_id, char **product,
                           char **category, char **quantity, char **unit_price) {
    *order_id = strtok(line, ",");
    *product = strtok(NULL, ",");
    *category = strtok(NULL, ",");
    *quantity = strtok(NULL, ",");
    *unit_price = strtok(NULL, ",");
    char *extra = strtok(NULL, ",");

    if (*order_id == NULL || *product == NULL || *category == NULL ||
        *quantity == NULL || *unit_price == NULL || extra != NULL) {
        return 0;
    }

    if ((*product)[0] == '\0' || (*category)[0] == '\0') {
        return 0;
    }

    return 1;
}

static int find_revenue_group(const RevenueGroup groups[], int group_count,
                              const char *name) {
    for (int i = 0; i < group_count; i++) {
        if (strcmp(groups[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

static void add_revenue_group(RevenueGroup groups[], int *group_count,
                              const char *name, double revenue) {
    int idx = find_revenue_group(groups, *group_count, name);
    if (idx >= 0) {
        groups[idx].revenue += revenue;
    } else {
        strncpy(groups[*group_count].name, name,
                sizeof(groups[*group_count].name) - 1);
        groups[*group_count].name[sizeof(groups[*group_count].name) - 1] = '\0';
        groups[*group_count].revenue = revenue;
        (*group_count)++;
    }
}

static int find_top_group(const RevenueGroup groups[], int group_count) {
    if (group_count <= 0) {
        return -1;
    }
    int top_idx = 0;
    for (int i = 1; i < group_count; i++) {
        if (groups[i].revenue > groups[top_idx].revenue) {
            top_idx = i;
        }
    }
    return top_idx;
}

static int analyze_sales_csv(const char *file_path) {
    FILE *file = fopen(file_path, "r");
    if (file == NULL) {
        fprintf(stderr, "Error: unable to open file\n");
        return 1;
    }

    char line[512];
    if (fgets(line, sizeof(line), file) == NULL) {
        fprintf(stderr, "Error: no sales records found\n");
        fclose(file);
        return 1;
    }

    trim_newline(line);

    if (!validate_header(line)) {
        fprintf(stderr, "Error: invalid CSV header\n");
        fclose(file);
        return 1;
    }

    SalesSummary summary;
    summary.order_count = 0;
    summary.total_quantity = 0;
    summary.total_revenue = 0.0;
    summary.product_count = 0;
    summary.category_count = 0;

    while (fgets(line, sizeof(line), file) != NULL) {
        trim_newline(line);

        if (line[0] == '\0') {
            continue;
        }

        char *order_id_field, *product_field, *category_field;
        char *quantity_field, *unit_price_field;

        if (!split_sales_row(line, &order_id_field, &product_field,
                             &category_field, &quantity_field,
                             &unit_price_field)) {
            fprintf(stderr, "Error: invalid CSV row\n");
            fclose(file);
            return 1;
        }

        long quantity = 0;
        if (!parse_positive_long(quantity_field, &quantity)) {
            fprintf(stderr, "Error: invalid quantity\n");
            fclose(file);
            return 1;
        }

        double unit_price = 0.0;
        if (!parse_double(unit_price_field, &unit_price)) {
            fprintf(stderr, "Error: invalid unit price\n");
            fclose(file);
            return 1;
        }

        if (unit_price < 0) {
            fprintf(stderr, "Error: unit price cannot be negative\n");
            fclose(file);
            return 1;
        }

        double revenue = (double)quantity * unit_price;

        summary.order_count++;
        summary.total_quantity += quantity;
        summary.total_revenue += revenue;

        add_revenue_group(summary.products, &summary.product_count,
                          product_field, revenue);
        add_revenue_group(summary.categories, &summary.category_count,
                          category_field, revenue);
    }

    fclose(file);

    if (summary.order_count == 0) {
        fprintf(stderr, "Error: no sales records found\n");
        return 1;
    }

    double average_revenue = summary.total_revenue / summary.order_count;

    int top_product_idx = find_top_group(summary.products, summary.product_count);
    int top_category_idx = find_top_group(summary.categories, summary.category_count);

    printf("Order Count: %d\n", summary.order_count);
    printf("Total Quantity: %ld\n", summary.total_quantity);
    printf("Total Revenue: %.2f\n", summary.total_revenue);
    printf("Average Order Revenue: %.2f\n", average_revenue);

    if (top_product_idx >= 0) {
        printf("Top Product: %s (%.2f)\n",
               summary.products[top_product_idx].name,
               summary.products[top_product_idx].revenue);
    }

    if (top_category_idx >= 0) {
        printf("Top Category: %s (%.2f)\n",
               summary.categories[top_category_idx].name,
               summary.categories[top_category_idx].revenue);
    }

    return 0;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: ./sales_report <csv_file_path>\n");
        return 1;
    }

    return analyze_sales_csv(argv[1]);
}