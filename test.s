.data
delayConst: .word 0x000F4240

.text
jal delay1s
j main

notTaken: 
addi $20, $0, 500	# $20 = 500
jal delay1s

taken: 
addi $20, $20, 4	# $20 = 180
jal delay1s
j loop

main: 
addi $4, $0, 1		# $4 = 1
jal delay1s
addi $20, $0, 5		# $20 = 5
jal delay1s
add $20, $20, $4	# $20 = 6
jal delay1s
addi $4, $4, 3		# $4 = 4
jal delay1s
sub $20, $20, $4	# $20 = 2
jal delay1s
or $20, $20, $4		# $20 = 6
jal delay1s
addi $5, $0, 11		# $5 = 11
jal delay1s
and $20, $20, $5	# $20 = 2
jal delay1s
sll $20, $20, 4		# $20 = 32
jal delay1s
sra $20, $20, 1		# $20 = 16
jal delay1s
mul $20, $20, $5	# $20 = 176
jal delay1s
bne $20, $20, notTaken	# branch not taken
jal delay1s
addi $21, $0, 177	# $21 = 177
jal delay1s
blt $20, $21, taken	# branch taken
jal delay1s

loop:
addi $20, $20, 16	# add by 16
jal delay1s
j loop

delay1s:
lw $10, delayConst($0)
delayLoop:
addi $10, $10, -1
bne $0, $10, delayLoop
jr $31
