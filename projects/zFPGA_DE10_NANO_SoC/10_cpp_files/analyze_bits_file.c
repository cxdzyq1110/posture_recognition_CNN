#include <stdio.h>

int main(void)
{
	FILE *fp = fopen("../12_linux_app/scripts/original_bits.ima", "rb");
	unsigned char high, low;
	int Height=600, Width=800;
	int r, g, b;
	FILE *fw = fopen("./rgb.txt", "w");
	int h, w;
	for(h=0; h<Height; ++h){
		for(w=0; w<Width; ++w){
			fread(&low, 1, 1, fp);
			fread(&high, 1, 1, fp);
			//
			//printf("%02X, %02X\n", high, low);
			//
			r = (high&0xF8);
			g = (((high&0x7)<<3)|(low>>5))<<2;
			b = (low&0x1F)<<3;
			fprintf(fw, "%d, %d, %d\n", r, g, b);
			//
			fseek(fp, 2, SEEK_CUR);
		}
		printf("line: %d\n", h);
	}
	//
	fclose(fp);
	fclose(fw);
	return 1;
}
