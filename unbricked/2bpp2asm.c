#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

int main(int argc, char ** argv) {
	if (argc != 4) {
		fprintf(stderr, "Expected 4 arguments\nUsage: %s <pixel chars> <input> <output>", argv[0]);
		exit(1);
	}

	FILE * infile = fopen(argv[2], "rb");
	FILE * outfile = fopen(argv[3], "w");

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
		uint8_t light_row = fgetc(infile);
		uint8_t dark_row = fgetc(infile);
		if (feof(infile)) break;
		fputs("\tdw `", outfile);
		for (int i = 0; i < 8; i++) {
			uint8_t shade = (light_row & 0x80) >> 7 | (dark_row & 0x80) >> 6;
			fputc(pixels[shade], outfile);
			light_row <<= 1;
			dark_row <<= 1;
		}
		fputc('\n', outfile);
	}
}