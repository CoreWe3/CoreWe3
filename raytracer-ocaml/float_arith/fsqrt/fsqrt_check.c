#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>
#include<fcntl.h>
#include<stdint.h>
#include<math.h>
#include<sys/types.h>
#include<sys/stat.h>
#include"float_arith.h"

extern uint32_t fadd(uint32_t, uint32_t);
extern uint32_t fsqrt(uint32_t);
extern uint32_t div2(uint32_t);

int normal_pos(uint32_t a){
  uint32_t exp = 0x7f800000;
  uint32_t sig = 0x80000000;
  
  return ((a & exp) != 0) && ((a & exp) != exp) && ((a & sig) == 0);
}

int main(){
  
  uint32_t diff;
  uint32_t ua, ub, uc;

  int fd;

  if((fd = open("c_output", O_WRONLY | O_CREAT, S_IWRITE)) < 0){
    printf("open error\n");
  }
  
  for(ua = 0x00800000; ua<=0x7f7fffff; ua++){
    if((ua & 0xffffff) == 0) printf("%x\n", ua);
    ub = ftoui(sqrtf(uitof(ua)));
    uc = fsqrt(ua);
    diff = ub > uc ? ub - uc : uc - ub;
    write(fd, (void *)&ub, 4);
    if(diff > 2){ 
      printf("%x\n", ua);
      printf("sqrtf: 0x%x %e\n", ub, uitof(ub));
      printf("fsqrt: 0x%x %e\n", uc, uitof(uc));
      printf("diff: %x\n", diff);
      return 0;
    }
  }

  printf("ok\n");
  close(fd);
  chmod("c_output", S_IRWXU);

  return 0;

}  

