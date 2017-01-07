#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

extern void start(int width, int height, char *board);
extern void run(int steps);

char * read_board(const char *filename, int *height, int *width) {
	FILE * file = fopen(filename, "r");
    char *board;
	int i, j, c;
    if (file != NULL) {
        fscanf(file, "%d %d", height, width);
        c = fgetc(file);
        board = (char *) malloc((*height) * (*width) * sizeof(char));
		for (i = 0; i < *height; i++) {
			for (j = 0; j < *width; j++) {
				c = fgetc(file);
				board[i * (*width) + j] = (char) c;		
			}
			c = fgetc(file);
		}
		fclose(file);
	} else {
		fclose(file);
		printf("Error reading file\n");
	}
    return board;
}

void print_board(int height, int width, char * board) {
	int i, j;
	for (i = 0; i < height; i++) {
		for (j = 0; j < width; j++) {
			printf("%c", board[i * width + j]);		
		}
		printf("\n");
	}
}

void clear_screen() {
    printf("\e[1;1H\e[2J");
}

void run_simulation(const char *filename) {
    char * board;
    int height, width;
	board = read_board(filename, &height, &width);
    print_board(height, width, board);
	start(width, height, board);
    clear_screen();
    while (1) {
        print_board(height, width, board);
        run(1);
        usleep(200000);
        clear_screen();
    }
}
