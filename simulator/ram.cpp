#include <fstream>
#include <iostream>
#include <vector>
#include "ram.h"
#include "isa.h"

RAM::RAM(char* filename):ram(RAMSIZE, 0), tag1(CACHEWIDTH1, -1), tag2(CACHEWIDTH2, -1){
	if(filename != nullptr){
		ifstream fin;
		fin.open(filename, ios::in|ios::binary);
		if(fin.fail()){
			cerr << "Can't open file" << endl;
			exit(1);
		}
		int c = 0;
		uint32_t tmp;
		while(fin.read(reinterpret_cast<char*>(&tmp),sizeof(tmp)) && c < RAMSIZE){
			ram[c] = tmp;
			c++;
		}
	}else{
		cerr << "RAM is initilaized with zero." << endl;
	}
	hitcounter1 = hitcounter2 = counter = 0;
}

uint32_t RAM::read(uint32_t addr){
	counter++;
	int line1 = (addr/LINESIZE1)% CACHEWIDTH1;
	int t1 =  (addr/LINESIZE1)/CACHEWIDTH1;
	if (tag1[t1] == addr/LINESIZE1/CACHEWIDTH1) hitcounter1++;
	else tag1[line1] = t1;
	int line2 = (addr/LINESIZE2)% CACHEWIDTH2;
	int t2 =  (addr/LINESIZE2)/CACHEWIDTH2;
	if (tag2[t2] == addr/LINESIZE2/CACHEWIDTH2) hitcounter2++;
	else tag2[line2] = t2;
	return ram[addr];
}

void RAM::write(uint32_t addr, uint32_t v){
	int line1 = (addr/LINESIZE1)% CACHEWIDTH1;
	int t1 =  (addr/LINESIZE1)/CACHEWIDTH1;
	tag1[line1] = t1;
	int line2 = (addr/LINESIZE2)% CACHEWIDTH2;
	int t2 =  (addr/LINESIZE2)/CACHEWIDTH2;
	tag2[line2] = t2;
	ram[addr] = v;
}

vector<uint32_t>::const_iterator RAM::begin() const{
	return ram.begin();
}

vector<uint32_t>::const_iterator RAM::end() const{
	return ram.end();
}

void RAM::printramstatus(){
	cerr << "hitrate1 (linesize=" << LINESIZE1 << "word line=" << CACHEWIDTH1 << ") :" << hitcounter1*1.0/counter << endl;
	cerr << "hitrate2 (linesize=" << LINESIZE2 << "word line=" << CACHEWIDTH2 << ") :" << hitcounter2*1.0/counter << endl;
}
