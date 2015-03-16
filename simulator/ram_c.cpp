#include <fstream>
#include <iostream>
#include <vector>
#include "ram.h"
#include "isa.h"

RAM::RAM(char* filename):
	ram(RAMSIZE, 0), tag1(CACHEWIDTH1, -1), tag2(CACHEWIDTH2, -1),
	tags1(CACHEWIDTH3, vector<uint32_t>(WAYSIZE1 ,-1)), age1(CACHEWIDTH3, vector<uint32_t>(WAYSIZE1,1))
{
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
	hitcounter1 = hitcounter2 = hitcounter3 = counter = 0;
}

uint32_t RAM::read(uint32_t addr){
	counter++;
	//Type 1
	/*uint32_t line1 = (addr/LINESIZE1) % CACHEWIDTH1;
	uint32_t t1 =  (addr/LINESIZE1)/CACHEWIDTH1;
	if (tag1[line1] == t1) hitcounter1++;
	else tag1[line1] = t1;
	//Type 2
	uint32_t line2 = (addr/LINESIZE2) % CACHEWIDTH2;
	uint32_t t2 =  (addr/LINESIZE2)/CACHEWIDTH2;
	if (tag2[line2] == t2) hitcounter2++;
	else tag2[line2] = t2;*/
	//Type 3
	uint32_t line3 = (addr/LINESIZE3) % CACHEWIDTH3;
	uint32_t t3 =  (addr/LINESIZE3)/CACHEWIDTH3;
	int index = -1;
	for(unsigned int i = 0; i<tags1[line3].size();i++){
		if (tags1[line3][i] == t3){
			index = i;
		}
	}
	uint32_t maxage = 0;
	unsigned int oldestindex = 0;
	for(unsigned int i = 0; i< age1[line3].size();i++){
		age1[line3][i]++;
		if(maxage < age1[line3][i]) {
			maxage = age1[line3][i];
			oldestindex = i;
		}
	}
	if (index == -1){
		tags1[line3][oldestindex]=t3;
		age1[line3][oldestindex]=0;
	}else{
		hitcounter3++;
		age1[line3][index] = 0;
	}

	return ram[addr];
}

void RAM::write(uint32_t addr, uint32_t v){
	/*//Type 1
	uint32_t line1 = (addr/LINESIZE1)% CACHEWIDTH1;
	uint32_t t1 =  (addr/LINESIZE1)/CACHEWIDTH1;
	tag1[line1] = t1;
	//Type 2
	uint32_t line2 = (addr/LINESIZE2)% CACHEWIDTH2;
	uint32_t t2 =  (addr/LINESIZE2)/CACHEWIDTH2;
	tag2[line2] = t2;*/
	//Type 3
	uint32_t line3 = (addr/LINESIZE3) % CACHEWIDTH3;
	uint32_t t3 =  (addr/LINESIZE3)/CACHEWIDTH3;
	uint32_t maxage = 0;
	unsigned int oldestindex = 0;
	for(unsigned int i = 0; i< age1[line3].size();i++){
		age1[line3][i]++;
		if(maxage < age1[line3][i]) {
			maxage = age1[line3][i];
			oldestindex = i;
		}
	}
	tags1[line3][oldestindex]=t3;
	age1[line3][oldestindex]=0;
	
	ram[addr] = v;
}

vector<uint32_t>::const_iterator RAM::begin() const{
	return ram.begin();
}

vector<uint32_t>::const_iterator RAM::end() const{
	return ram.end();
}

void RAM::printramstatus(){
	//cerr << "hitrate1 (linesize=" << LINESIZE1 << "word line=" << CACHEWIDTH1 << ") :" << hitcounter1*1.0/counter << endl;
	//cerr << "hitrate2 (linesize=" << LINESIZE2 << "word line=" << CACHEWIDTH2 << ") :" << hitcounter2*1.0/counter << endl;
	cerr << WAYSIZE1 <<"way (linesize=" << LINESIZE3 << "word line=" << CACHEWIDTH3 << ") :" << hitcounter3*1.0/counter << endl;
}
