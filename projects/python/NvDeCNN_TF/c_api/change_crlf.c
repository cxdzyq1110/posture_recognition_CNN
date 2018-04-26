#include <stdio.h>

unsigned char BUF[1024*1024*8];	// 8MB

int main(int argc,char *argv[])
{
	FILE *fp;
	// Ê×ÏÈÊÇinst.txt
	fp = fopen(argv[1], "rb");
	int head = 0;
	while(!feof(fp)){
		unsigned char data;
		fread(&data, 1, 1, fp);
		if(data!=0x0D){
			BUF[head++] = data;
		}
	} 
	fclose(fp);
	// 
	fp = fopen(argv[1], "wb");
	int N = head;
	for(head=0; head<N; head++){
		fwrite(BUF+head, 1, 1, fp);
	}
	fclose(fp);
	
	return 0;
}
