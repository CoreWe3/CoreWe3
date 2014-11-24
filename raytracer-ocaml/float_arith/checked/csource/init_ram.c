#include <stdio.h>
#include <stdlib.h>

#define RAMSIZE 0x100000

unsigned int bits2ui(char *buf) {
    int j;
    unsigned int data = 0;
    for(j = 0; j < 32; j++){
	data = (data << 1) | (buf[j]-'0');
    }
    return data;
}

int main () {
    FILE *out, *tbl1, *tbl2, *tbl3, *tbl4;
    char buf[64];
    unsigned int data = 0;
    int i = 0;
    out = fopen("init.bit","wb+");
    tbl1 = fopen("./finv/a.txt","r");
    tbl2 = fopen("./finv/b.txt","r");
    tbl3 = fopen("./a_fsqrt.txt","r");
    tbl4 = fopen("./b_fsqrt.txt","r");
    for(i = 0; i < RAMSIZE; i++){
	data = 0;
	if (0xEF000 <= i && i <= 0xEF3FF) {
	    if(fscanf(tbl1, "%s", buf) >= 0) {
		data = bits2ui(buf);
	    }
	}
	if (0xEF400 <= i && i <= 0xEF7FF) {
	    if(fscanf(tbl2, "%s", buf) >= 0) {
		data = bits2ui(buf);
	    }
	}
	if (0xEF800 <= i && i <= 0xEFBFF) {
	    if(fscanf(tbl3, "%s", buf) >= 0) {
		data = bits2ui(buf);
	    }
	}
	if (0xEFC00 <= i && i <= 0xEFFFF) {
	    if(fscanf(tbl4, "%s", buf) >= 0) {
		data = bits2ui(buf);
	    }
	}
	fwrite(&data, sizeof(unsigned int), 1, out);
    }
    fclose(out);
    fclose(tbl1);
    fclose(tbl2);
    fclose(tbl3);
    fclose(tbl4);
    return 0;
}
