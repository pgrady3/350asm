.text

lw $3, vgaStart($0)
lw $2, delayConst($0)
jal delay		#NEED THIS DONT KNOW WHY
j begin

#FUNCTION blankScreen----------------------------------------------
#Clears the screen faster
#---------------------------
blankScreen:
addi $9, $3, 15360
addi $8, $3, 0

blankLoop:
sw $0, 0($8)
sw $0, 1($8)
sw $0, 2($8)
sw $0, 3($8)
sw $0, 4($8)
sw $0, 5($8)
sw $0, 6($8)
sw $0, 7($8)
addi $8, $8, 8
blt $8, $9, blankLoop

jr $31
#FUNCTION END------------------------------------------------

#FUNCTION delay----------------------------------------------
#Delays for roughly 100ms
#---------------------------
delay:
addi $8, $2, 0
delayLoop:
addi $8, $8, -1
bne $0, $8, delayLoop
jr $31
#FUNCTION END------------------------------------------------

#FUNCTION drawPixel------------------------------------------
#Draws the pixel at x = $4, y = $5, color = $6
#---------------------------
drawPixel:
sll $8, $5, 7
add $8, $8, $4				#Add X offset to $8
#sll $8, $8, 2				#FOR MARS$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
add $8, $8, $3				#Add VGA offset
sw $6, 0($8)				#Draw the pixel

jr $31
#FUNCTION END------------------------------------------------

#FUNCTION drawRect------------------------------------------
#Draws the rectangle at x=16, y=17, w=18, h=19, color=6
#---------------------------
drawRect:
addi $30, $31, 0	#back up the RA

add $9, $16, $18	#calc end X
add $10, $17, $19	#calc end Y

addi $4, $16, 0	#load cur X
addi $5, $17, 0	#load cur Y

drawLoop:
jal drawPixel
addi $4, $4, 1
blt $4, $9, drawLoop

addi $5, $5, 1
addi $4, $16, 0	#load cur X
blt $5, $10, drawLoop

addi $31, $30, 0	#Load back the RA
jr $31
#FUNCTION END------------------------------------------------



begin:

addi $16, $16, 1
addi $17, $16, 0
addi $18, $16, 0
addi $19, $16, 0
addi $6, $0, 0xFF

jal drawRect
jal delay

j begin


quit:
j quit

.data
#delayCont: .word 0x000F4240
delayConst:  .word 0x00044240
vgaStart:  .word 0x40000000

#delayConst: .word 1						#FOR MARS$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#vgaStart: .word 0x10010000				#FOR MARS$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$