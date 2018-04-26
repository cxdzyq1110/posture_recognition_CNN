#include "mt9d111_config.h"
#include <stdio.h>
#include "adv7513_config.h"
int main(void)
{
	printf("mt9d111 : length = %d\n", (sizeof(mt9d111_init_reg_tbl)>>3)*4);
	FILE * fp = fopen("../04_scripts/mt9d111_i2c_setting.mif", "w");
	fprintf(fp, "DEPTH=1024;\nWIDTH=32;\nADDRESS_RADIX=DEC;\nDATA_RADIX=HEX;\nCONTENT\nBEGIN\n");
	int i;
	for(i=0; i<(sizeof(mt9d111_init_reg_tbl)>>3); i++){
		// first write page to 0xF0
		if(mt9d111_init_reg_tbl[i][1]!=256){
			fprintf(fp, "%d:%02X%02X%02X%02X;\n", i*4+0, 0, 0, 0xf0, mt9d111_init_reg_tbl[i][1]>>8);
			fprintf(fp, "%d:%02X%02X%02X%02X;\n", i*4+1, 0, 0, 0xf1, mt9d111_init_reg_tbl[i][1]&0xFF);
			// then read/write register HIGH.8-bit 
			fprintf(fp, "%d:%02X%02X%02X%02X;\n", i*4+2, 0, mt9d111_init_reg_tbl[i][0]&0xFF, mt9d111_init_reg_tbl[i][2]&0xFF, mt9d111_init_reg_tbl[i][3]>>8);
			// then read/write register LOW.8-bit 
			fprintf(fp, "%d:%02X%02X%02X%02X;\n", i*4+3, 0, mt9d111_init_reg_tbl[i][0]&0xFF, 0xF1, mt9d111_init_reg_tbl[i][3]&0xFF);
		}
		else
		{
			fprintf(fp, "%d:%08X;\n", i*4+0, 0xFFFFFFFF);
			fprintf(fp, "%d:%08X;\n", i*4+1, 0xFFFFFFFF);
			fprintf(fp, "%d:%08X;\n", i*4+2, 0xFFFFFFFF);
			fprintf(fp, "%d:%08X;\n", i*4+3, 0xFFFFFFFF);
		}
	}
	fprintf(fp, "END;\n");
	fclose(fp);
	//
	// ADV7513
	
	printf("adv7513 : length = %d\n", sizeof(adv7513_init_reg_tbl)/3);
	fp = fopen("../04_scripts/adv7513_i2c_setting.mif", "w");
	fprintf(fp, "DEPTH=128;\nWIDTH=32;\nADDRESS_RADIX=DEC;\nDATA_RADIX=HEX;\nCONTENT\nBEGIN\n");
	//int i;
	for(i=0; i<sizeof(adv7513_init_reg_tbl)/3; ++i){
		if(adv7513_init_reg_tbl[i][0]!=0xFF)
			fprintf(fp, "%d:%02X%02X%02X%02X;\n", i, 0, adv7513_init_reg_tbl[i][0], adv7513_init_reg_tbl[i][1], adv7513_init_reg_tbl[i][2]);
		else
			fprintf(fp, "%d:%08X;\n", i, 0xFFFFFFFF);
	}
	fprintf(fp, "END;\n");
	fclose(fp);
	
	return 1;
}
