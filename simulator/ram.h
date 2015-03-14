#pragma once
#include <iostream>
#include <vector>
#include <string>
#include <stdint.h>
#include "isa.h"

using namespace std;

#define LINESIZE1 1
#define CACHEWIDTH1 256

#define LINESIZE2 2
#define CACHEWIDTH2 256

class RAM {
	private:
		vector<uint32_t> ram;
		//vector<tuple<uint32_t, vector<uint32_t>>> cache;
		vector<uint32_t> tag1;
		vector<uint32_t> tag2;
		unsigned long long counter, hitcounter1, hitcounter2;
	public:
		RAM(char*);
		vector<uint32_t>::const_iterator begin() const;
		vector<uint32_t>::const_iterator end() const;
		uint32_t read(uint32_t);
		void write(uint32_t, uint32_t);
		void printramstatus();
};

