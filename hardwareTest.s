.text

lw $19, vgaStart($0)
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
nop
nop
nop
nop
nop
nop
lw $8, vgaStart($0)			#Load VGAStart into $8
nop
nop
nop
nop
nop
nop


#lw $9, screenWidth($0)		#Load width into $9
#mul $9, $9, $26				#Mutiply width * Y
#add $8, $8, $9				#Add Y offset to $8
add $8, $19, $25				#Add X offset to $8
nop
nop
nop
nop
nop
nop
sw $27, 0($8)				#Draw the pixel
addi $20, $8, 0	#DOES JUMP WORK


jr $31
#FUNCTION END------------------------------------------------

begin:

#lw $9, screenWidth($0)		#Load width into $9
#addi $20, $20, 1
#mul $21, $20, $20

addi $25, $25, 1
addi $26, $0, 0
addi $27, $0, 1


jal drawPixel
jal delay1S
j begin

#addi $27, $0, 1
#addi $26, $0, 1
#addi $25, $25, 1

#jal drawPixel

#jal delay1S

j begin


quit:
j quit

.data
delayCont: .word 0x000F4240
screenWidth: .word 640
vgaStart:  .word 0x40000000