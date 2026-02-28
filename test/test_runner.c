#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>

/* read an entire file into a malloc'd buffer, returns NULL on failure */
static char *read_file(const char *path) {
    FILE *f = fopen(path, "r");
    if (!f) return NULL;

    fseek(f, 0, SEEK_END);
    long len = ftell(f);
    rewind(f);

    char *buf = malloc(len + 1);
    if (!buf) { fclose(f); return NULL; }

    size_t nread = fread(buf, 1, len, f);
    buf[nread] = '\0';
    fclose(f);
    return buf;
}

/* run the scanner on a test file and capture its stdout */
static char *run_scanner(const char *scanner, const char *input) {
    char cmd[1024];
    snprintf(cmd, sizeof(cmd), "%s %s", scanner, input);

    FILE *pipe = popen(cmd, "r");
    if (!pipe) return NULL;

    size_t cap = 4096, len = 0;
    char *buf = malloc(cap);

    while (!feof(pipe)) {
        if (len + 256 > cap) {
            cap *= 2;
            buf = realloc(buf, cap);
        }
        len += fread(buf + len, 1, 256, pipe);
    }
    buf[len] = '\0';
    pclose(pipe);
    return buf;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <scanner_binary>\n", argv[0]);
        return 1;
    }

    const char *scanner = argv[1];
    const char *testdir = "test/cases";
    const char *expdir  = "test/exp";
    int passed = 0, failed = 0;

    DIR *dir = opendir(testdir);
    if (!dir) {
        fprintf(stderr, "Cannot open %s\n", testdir);
        return 1;
    }

    struct dirent *ent;
    while ((ent = readdir(dir)) != NULL) {
        /* only process .mC files */
        char *dot = strrchr(ent->d_name, '.');
        if (!dot || strcmp(dot, ".mC") != 0) continue;

        /* build file paths */
        char input_path[512], exp_path[512];
        snprintf(input_path, sizeof(input_path), "%s/%s", testdir, ent->d_name);

        /* strip .mC and append .exp for expected output */
        char basename[256];
        strncpy(basename, ent->d_name, dot - ent->d_name);
        basename[dot - ent->d_name] = '\0';
        snprintf(exp_path, sizeof(exp_path), "%s/%s.exp", expdir, basename);

        /* read expected output */
        char *expected = read_file(exp_path);
        if (!expected) {
            printf("  SKIP  %s (no expected output)\n", basename);
            continue;
        }

        /* run scanner and capture output */
        char *actual = run_scanner(scanner, input_path);
        if (!actual) {
            printf("  FAIL  %s (could not run scanner)\n", basename);
            free(expected);
            failed++;
            continue;
        }

        /* compare */
        if (strcmp(actual, expected) == 0) {
            printf("  PASS  %s\n", basename);
            passed++;
        } else {
            printf("  FAIL  %s\n", basename);
            failed++;
        }

        free(actual);
        free(expected);
    }
    closedir(dir);

    printf("\n%d passed, %d failed\n", passed, failed);
    return (failed > 0) ? 1 : 0;
}
