#pragma once
#include <iostream>
#include <vector>
#include <string>
#include <stdint.h>
#include "isa.h"

using namespace std;

#define LINESIZE1 1
#define CACHEWIDTH1 256

#define LINESIZE2 16
#define CACHEWIDTH2 256

#define LINESIZE3 16
#define CACHEWIDTH3 128
#define WAYSIZE 2

class RAM {
	private:
		vector<uint32_t> ram;
		vector<uint32_t> tag1, tag2;
		vector<vector<uint32_t>> tags, age;
		unsigned long long counter, hitcounter1, hitcounter2, hitcounter3;
	public:
		RAM(char*);
		vector<uint32_t>::const_iterator begin() const;
		vector<uint32_t>::const_iterator end() const;
		uint32_t read(uint32_t);
		void write(uint32_t, uint32_t);
		void printramstatus();
};

