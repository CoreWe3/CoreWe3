#include <fstream>
#include <iostream>
#include <vector>
#include "ram.h"
#include "isa.h"



RAM::RAM(char* filename):
	ram(RAMSIZE, 0),
	tags1(CACHEWIDTH3, vector<uint32_t>(WAYSIZE1 ,-1)), 
	age1(CACHEWIDTH3, vector<uint32_t>(WAYSIZE1,1)){
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
	hitcounter = counter = swap = wait =  0;
}


int RAM::read(uint32_t addr, uint32_t &v){
	counter++;
	uint32_t line3 = (addr/LINESIZE3) % CACHEWIDTH3;
	uint32_t t3 =  (addr/LINESIZE3)/CACHEWIDTH3;
	int index = -1;
	for(unsigned int i = 0; i<tags1[line3].size();i++){
		if (tags1[line3][i] == t3){
			index = i;
		}
	}
	int l;
	if (index == -1){
		//SWAP
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
		l = 3+wait;
		wait += LINESIZE3+3;
	}else{
		hitcounter++;
		l = wait;
		age1[line3][index] = 0;
	}

	v = ram[addr];
	return l;
}

int RAM::write(uint32_t addr, uint32_t v){
	uint32_t line3 = (addr/LINESIZE3) % CACHEWIDTH3;
	uint32_t t3 =  (addr/LINESIZE3)/CACHEWIDTH3;
	uint32_t maxage = 0;
	unsigned int oldestindex = 0;
	int index = -1;
	for(unsigned int i = 0; i<tags1[line3].size();i++){
		if (tags1[line3][i] == t3){
			index = i;
		}
	}
	int l = wait;
	if (index != -1){
		tags1[line3][index]=t3;
		age1[line3][index]=0;
	}else{
		//SWAP
		swap++;
		for(unsigned int i = 0; i< age1[line3].size();i++){
			age1[line3][i]++;
			if(maxage < age1[line3][i]) {
				maxage = age1[line3][i];
				oldestindex = i;
			}
		}
		wait += LINESIZE3+3;
		tags1[line3][oldestindex]=t3;
		age1[line3][oldestindex]=0;
	}
	ram[addr] = v;
	return l;
}

vector<uint32_t>::const_iterator RAM::begin() const{
	return ram.begin();
}

vector<uint32_t>::const_iterator RAM::end() const{
	return ram.end();
}

void RAM::printramstatus(){
	cerr << WAYSIZE1 <<"way (linesize=" << LINESIZE3 << "word line=" << CACHEWIDTH3 << ") :" << hitcounter*1.0/counter << endl;
	cerr << "Cache Swap :" << swap << endl;
}

void RAM::update(int i){
	//cerr << "wait " << wait << " i "<<i << endl;
	wait -= i;
	if(wait < 0) wait = 0;
}
