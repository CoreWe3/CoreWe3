//===-- Cpu0RegisterInfo.td - Cpu0 Register defs -----------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Declarations that describe the CPU0 register file
//===----------------------------------------------------------------------===//


// We have banks of 16 registers each.
class Cpu0Reg<string n> : Register<n> {
  field bits<4> Num;
  let Namespace = "Cpu0";
}

// Cpu0 CPU Registers
class Cpu0GPRReg<bits<4> num, string n> : Cpu0Reg<n> {
  let Num = num;
}

//===----------------------------------------------------------------------===//
//  Registers
//===----------------------------------------------------------------------===//
// The register string, such as "9" or "gp" will show on "llvm-objdump -d"
let Namespace = "Cpu0" in {
  // General Purpose Registers
  def R0   : Cpu0GPRReg<0,  "r0">,  DwarfRegNum<[0]>;
  def R1   : Cpu0GPRReg<1,  "r1">,  DwarfRegNum<[1]>;
  def R2   : Cpu0GPRReg<2,  "r2">,  DwarfRegNum<[2]>;
  def R3   : Cpu0GPRReg<3,  "r3">,  DwarfRegNum<[3]>;
  def R4   : Cpu0GPRReg<4,  "r4">,  DwarfRegNum<[4]>;
  def R5   : Cpu0GPRReg<5,  "r5">,  DwarfRegNum<[5]>;
  def R6   : Cpu0GPRReg<6,  "r6">,  DwarfRegNum<[6]>;
  def R7   : Cpu0GPRReg<7,  "r7">,  DwarfRegNum<[7]>;
  def R8   : Cpu0GPRReg<8,  "r8">,  DwarfRegNum<[8]>;
  def R9   : Cpu0GPRReg<9,  "r9">,  DwarfRegNum<[9]>;
  def R10  : Cpu0GPRReg<10, "r10">, DwarfRegNum<[10]>;
  def R11  : Cpu0GPRReg<11, "r11">, DwarfRegNum<[11]>;
  def R12  : Cpu0GPRReg<12, "r12">, DwarfRegNum<[12]>;
  def R13  : Cpu0GPRReg<13, "r13">, DwarfRegNum<[13]>;
  def R14  : Cpu0GPRReg<14, "r14">, DwarfRegNum<[14]>;
  def R15  : Cpu0GPRReg<15, "r15">, DwarfRegNum<[15]>;
  def SP   : Cpu0GPRReg<16, "sp">,  DwarfRegNum<[16]>;
  def LR   : Cpu0GPRReg<17, "lr">,  DwarfRegNum<[17]>;
  def PC   : Cpu0GPRReg<18, "pc">,  DwarfRegNum<[18]>;
}

//===----------------------------------------------------------------------===//
// Register Classes
//===----------------------------------------------------------------------===//

def CPURegs : RegisterClass<"Cpu0", [i32], 32, (add R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, SP, LR, PC)>;

// Status Registers class
//def SR      : RegisterClass<"Cpu0", [i32], 32, (add SP, LR, PC)>;
