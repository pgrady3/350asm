.text

jal delay1S	#NEED THIS DONT KNOW WHY
j begin


#FUNCTION delay1S----------------------------------------------
#Delays for 1 second
#Dicks with registers: 10
#---------------------------
delay1S:
lw $10, delayCont($0)
delayLoop:
addi $10, $10, -1

bne $0, $10, delayLoop

jr $31
#FUNCTION END------------------------------------------------

#FUNCTION drawPixel------------------------------------------
#Draws the pixel at x = $25, y = $26, color = $27
#Dicks with registers: all the T registers from 8 to 15
#---------------------------
drawPixel:
lw $8, vgaStart($0)			#Load VGAStart into $8
lw $9, screenWidth($0)		#Load width into $9
mul $9, $9, $26				#Multiply width * Y
add $8, $8, $9				#Add Y offset to $8
add $8, $8, $25				#Add X offset to $8
sw $27, 0($8)				#Draw the pixel

jr $31
#FUNCTION END------------------------------------------------

#FUNCTION drawRect------------------------------------------
#Draws the rect at x = $20, y = $21, w = $22, h = $23, color = $24
#Dicks with registers: all the T registers from 8 to 15
#---------------------------
drawRect:
addi $15, $31, 0	#BACK DAT STACK

addi $25, $20, 0
addi $26, $21, 0
addi $27, $24, 0

add $10, $20, $22	#The end limit in X
add $11, $21, $23	#The end limit in Y

drawRow:
jal drawPixel
addi $25, $25, 1
blt $25, $10, drawRow

addi $26, $26, 1
addi $25, $20, 0
blt $26, $11, drawRow

addi $31, $15, 0	#UNBACK DAT STACK
jr $31
#FUNCTION END------------------------------------------------


begin:

addi $20, $20, 1

addi $21, $20, 0
addi $22, $20, 0
addi $23, $20, 0
addi $24, $20, 0
jal drawRect

jal delay1S

j begin


quit:
j quit

.data
delayCont: .word 0x000F4240
screenWidth: .word 640
vgaStart:  .word 0x40000000
