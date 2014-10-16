#!/usr/bin/python
import re
import sys

if __name__ == "__main__":
    f = open(sys.argv[1])
    text = f.read()
    f.close()
    text = re.compile(r'\(\*NOMINCAML.*\*\)').sub('', text)
    text = re.compile(r'\(\*MINCAML\*\).*').sub('', text)
    text = re.compile(r' \* 4 ').sub(' lsl 2 ', text)
    text = re.compile(r' \/ 2').sub(' lsr 1', text)
    text = re.compile(r';\n[\s\t]*\)', re.M).sub(')', text)    
    text = re.compile(r'in 0$').sub('in ()', text)
    print(text)
