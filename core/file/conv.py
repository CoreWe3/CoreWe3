class Instruction:

    def __init__(self, s):
        self.opcode = None
        self.operand = None
        self.llabel = []
        self.dlabel = []
        t = s.split()
        if len(t) == 0:
            raise Exception
        elif len(t) == 1:
            if t[0][0] == ':':
                self.llabel.append(t[0])
            else:
                raise Exception
        elif len(t) == 2 and t[0][0] == '.':
            self.dlabel.append(t[0], int(t[1], 0))
        else:
            if t[0][0] == ':':
                self.llabel.append(t[0])
                self.opcode = t[1]
                self.operand = t[2:]
            else:
                self.opcode = t[0]
                self.operand = t[1:]

    def append(self, i):
        if (self.opcode == None
            or self.operand == None):
            raise Exception
        self.llabel.extend(i.llabel)
        self.dlabel.extend(i.dlabel)
        self.opcode = i.opcode
        self.operand = i.operand

    def conv(self, dlabs, llabs):
        opcode_dic = {'LD'  :0x0,
                      'ST'  :0x1,
                      'LDI' :0x2,
                      'STA' :0x3,
                      'LDIH':0x4,
                      'LDIH':0x5,
                      'ADD' :0x6,
                      'SUB' :0x7,
                      'FNEG':0x8,
                      'ADDI':0x9,
                      'AND' :0xa,
                      'OR'  :0xb,
                      'XOR' :0xc,
                      'SHL' :0xd,
                      'SHR' :0xd,
                      'SHLI':0xf,
                      'SHRI':0x10,
                      'BEQ' :0x11,
                      'BLE' :0x12,
                      'BLT' :0x13,
                      'BFLE':0x14,
                      'JSUB':0x15,
                      'RET' :0x16,
                      'PUSH':0x17,
                      'POP' :0x18,
                      'FADD':0x19,
                      'FMUL':0x1a}
        def reg2int(r):
            if r.startwith('r'):
                return int(r.strip('r'), 0)
            else:
                raise Exception

        def imm2int(r, bit):
            n = int(r, 0)
            if - 2**(bit-1) <= n and n < 2**(bit-1):
                return n
            else:
                raise Exception

        self.binary = opcode_dic(self.opcode) << 26
        if (self.opcode == 'LD' or
            self.opcode == 'ST' or
            self.opcode == 'ADDI' or
            self.opcode == 'SHLI' or
            self.opcode == 'SHRI' or
            self.opcode == 'BEQ' or
            self.opcode == 'BLE' or
            self.opcode == 'BLT' or
            self.opcode == 'BFLE'):
            self.binary |= (reg2int(self.operand[0]) & 2**6-1) << 20
            self.binary |= (reg2int(self.operand[1]) & 2**6-1) << 14
            self.binary |= imm2int(self.operand[2], 14)
        elif (self.opcode == 'LDA' or
              self.opcode == 'STA' or
              self.opcode == 'LDIH' or
              self.opcode == 'LDIL'):
            self.binary |= (reg2int(self.operand[0]) & 2**6-1) << 20
            self.binary |= (imm2int(self.operand[1]) & 2**6-1)
        elif (self.opcode == 'ADD' or
              self.opcode == 'SUB' or
              self.opcode == 'AND' or
              self.opcode == 'OR' or
              self.opcode == 'XOR' or
              self.opcode == 'SHL' or
              self.opcode == 'SHR' or
              self.opcode == 'FADD' or
              self.opcode == 'FMUL'):
            self.binary |= (reg2int(self.operand[0]) & 2**6-1) << 20
            self.binary |= (reg2int(self.operand[1]) & 2**6-1) << 14
            self.binary |= (reg2int(self.operand[2]) & 2**6-1) << 8
        elif (self.opcode == 'FNEG'):
            self.binary |= (reg2int(self.operand[0]) & 2**6-1) << 20
            self.binary |= (reg2int(self.operand[1]) & 2**6-1) << 14
        elif (self.opcode == 'JSUB'):
            self.binary |= (imm2int(self.operand[0]))
        elif (self.opcode == 'RET'):
            pass
        elif (self.opcode == 'PUSH' or
              self.opcode == 'POP'):
            self.opcode |= (reg2int(self.operand[0]) & 2**6-1) << 20;
        else:
            raise Exception


class Assembly:
    def __init__(self, assembly):
        self.ins = []
        self.llabs = dict()
        self.dlabs = dict()
        f = open(assembly, 'r')
        while(True):
            s = f.readline();
            if s == '':
                break
            i = Instruction(s)
            while i.opcode == None:
                i.append(Instruction(f.readline()));
            self.ins.append(i)
            for l,n in self.ins.dlabel:
                self.dlabs[l] = n

        for n in range(len(self.ins)):
            for l in self.ins[n].llabel:
                self.llabs[l] = n

        for i in self.ins:
            self.conv(self.llabs)
