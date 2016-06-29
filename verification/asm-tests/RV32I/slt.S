#include "riscv_test.h"

RVTEST_DATA_DUMP_BEGIN
RVTEST_CODE_BEGIN

.text
#test asm code goes here
main:
    lui x4, 0x70000
    lui x5, 0xf0000

    #rtype unsigned
    la x4, tdat0
    slt x6, x5, x4
    sw x6, 0(x4)

    la x4, tdat1
    slt x6, x4, x5
    sw x6, 0(x4)

    #rtype signed
    la x4, tdat2
    sltu x6, x5, x4
    sw x6, 0(x4)

    la x4, tdat3
    sltu x6, x4, x5
    sw x6, 0(x4)

    #itype signed
    la x4, tdat4
    slti x6, x5, 0x700
    sw x6, 0(x4)

    la x4, tdat5
    slti x6, x4, 0x700
    sw x6, 0(x4)
    
    la x4, tdat6
    slti x6, x5, 0x300
    sw x6, 0(x4)

    la x4, tdat7
    slti x6, x4, 0x300
    sw x6, 0(x4)

    #itype unsigned
    la x4, tdat8
    sltiu x6, x5, 0x700
    sw x6, 0(x4)

    la x4, tdat9
    sltiu x6, x4, 0x700
    sw x6, 0(x4)
    
    la x4, tdat10
    sltiu x6, x5, 0x300
    sw x6, 0(x4)

    la x4, tdat11
    sltiu x6, x4, 0x300
    sw x6, 0(x4)

RVTEST_CODE_END

.data
#test data goes here
tdat0:  .word 0xbad0bad0
tdat1:  .word 0xbad1bad1
tdat2:  .word 0xbad2bad2
tdat3:  .word 0xbad3bad3
tdat4:  .word 0xbad4bad4
tdat5:  .word 0xbad5bad5
tdat6:  .word 0xbad6bad6
tdat7:  .word 0xbad7bad7
tdat8:  .word 0xbad8bad8
tdat9:  .word 0xbad9bad9
tdat10: .word 0xbad0bad0
tdat11: .word 0xbad1bad1
RVTEST_DATA_DUMP_END


