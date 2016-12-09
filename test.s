.data
delayConst: .word 0x000F4240

.text

j main

notTaken: 
addi $20, $0, 500	# $20 = 500

taken: 
addi $20, $20, 4	# $20 = 180
j cont

testJr:
sub $20, $20, $5	# $20 = 174
jr $31

main: 
addi $4, $0, 1		# $4 = 1
addi $20, $0, 5		# $20 = 5
add $20, $20, $4	# $20 = 6
addi $4, $4, 3		# $4 = 4
sub $20, $20, $4	# $20 = 2
or $20, $20, $4		# $20 = 6
addi $5, $0, 11		# $5 = 11
and $20, $20, $5	# $20 = 2
sll $20, $20, 4		# $20 = 32
sra $20, $20, 1		# $20 = 16
mul $20, $20, $5	# $20 = 176
bne $20, $20, notTaken	# branch not taken
addi $21, $0, 177	# $21 = 177
blt $20, $21, taken	# branch taken

cont:
addi $20, $20, 5	# $20 = 185
jal testJr

loop:
addi $20, $20, 16	# add by 16
j loop

delay1s:
lw $10, delayConst($0)
delayLoop:
addi $10, $10, -1
bne $0, $10, delayLoop
jr $31
