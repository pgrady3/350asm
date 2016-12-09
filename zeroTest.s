.text

j begin
#-----------------------------------------------------------------

delay1S:
sub $0, $0, $0
lw $10, delayCont($0)
delayLoop:
addi $10, $10, -1

bne $0, $10, delayLoop

jr $31
#-------------------------------------------------------------

begin:
#addi $0, $0, 5
nop
nop
nop
nop
nop
nop
nop
addi $20, $0, 5

mainLoop:
jal delay1S
addi $20, $20, 1
j mainLoop



quit:
j quit

.data
d0:  .word 0
d1:  .word 1
d2:  .word 2
d3:  .word 3
d4:  .word 4
d5:  .word 5
d6:  .word 6
d7:  .word 7
d8:  .word 8
d9:  .word 9
d10:  .word 10
d11:  .word 11
d12:  .word 12
delayCont: .word 0x000F4240