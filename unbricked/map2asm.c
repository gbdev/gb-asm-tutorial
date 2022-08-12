#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

int main(int argc, char ** argv) {
	if (argc != 4) {
		fprintf(stderr, "Expected 4 arguments\nUsage: %s <input> <output>", argv[0]);
		exit(1);
	}

	FILE * infile = fopen(argv[1], "rb");
	FILE * outfile = fopen(argv[2], "w");

	if (!infile) {
		perror("infile");
		exit(1);
	}

	if (!outfile) {
		perror("outfile");
		exit(1);
	}

	char * pixels = argv[1];

	while (1) {
		fputs("\tdb ", outfile);
		for (int i = 0; i < 20; i++) {
			int byte = fgetc(infile);
			if (byte == EOF) exit(0);
			fprintf(outfile, "$%X, ", byte);
		}
		fputs("0,0,0,0,0,0,0,0,0,0,0,0\n", outfile);
	}
}
