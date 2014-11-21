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
    FILE *out, *tbl1, *tbl2;
    char buf[64];
    unsigned int data = 0;
    int i = 0;
    out = fopen("init.bit","wb+");
    tbl1 = fopen("a.txt","r");
    tbl2 = fopen("b.txt","r");
    for(i = 0; i < RAMSIZE; i++){
	data = 0;
	if (0xEF000 <= i && i <= 0xEF3FF) {
	    fscanf(tbl1, "%s", buf);
	    data = bits2ui(buf);
	}
	if (0xEF400 <= i && i <= 0xEF7FF) {
	    fscanf(tbl2, "%s", buf);
	    data = bits2ui(buf);
	}
	fwrite(&data, sizeof(unsigned int), 1, out);
    }
    fclose(out);
    fclose(tbl1);
    fclose(tbl2);
    return 0;
}
