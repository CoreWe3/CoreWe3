#include <stdio.h>
#include <byteswap.h>
#include <stdint.h>

int main(int argc, char* argv[])
{
	if(argc < 3){
		printf("Need input and output filename\n");
		return 1;
	}

	FILE *fpr = fopen(argv[1],"rb");
	if(fpr == NULL){
		printf("Can't open %s\n",argv[1]);
		return 1;
	}

	FILE *fpw = fopen(argv[2],"wb");
	if(fpw == NULL){
		printf("Can't open %s\n",argv[2]);
		return 1;
	}

	uint32_t tmp1,tmp2;
	while(fread(&tmp1,sizeof(uint32_t),1,fpr) > 0){
		tmp2 = __bswap_32(tmp1);
		fwrite(&tmp2,sizeof(uint32_t),1,fpw);
	}
	fclose(fpw);
	fclose(fpr);
	return 0;
}

