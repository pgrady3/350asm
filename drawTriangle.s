.text

#1 is start, 2 is color, 3 is row, 4 is col

initializeVga:
lw $1, vgaStart($0)
addi $5, $0, 480

jal delay1S

inc:
addi $3, $3, 1
add $4, $3, $0
addi $1, $1, 640

rowLoop:
add $6, $4, $1
sw $3, 0($6)
addi $4, $4, -1
bne $4, $0, rowLoop

bne $3, $5, inc

j quit

delay1S:
lw $20, delayCont($0)
delayLoop:
addi $20, $20, -1
bne $0, $20, delayLoop
jr $31

quit:

.data
vgaStart:  .word 0x40000010
delayCont: .word 0x000F4240
