.text

jal delay1S	#NEED THIS DONT KNOW WHY
j begin


#FUNCTION delay1S----------------------------------------------
#Delays for 1 second
#Dicks with registers: 10
#---------------------------
delay1S:
sub $0, $0, $0
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
mul $9, $9, $26				#Mutiply width * Y
add $8, $8, $9				#Add Y offset to $8
add $8, $8, $25				#Add X offset to $8
sw $27, 0($8)				#Draw the pixel

jr $31
#FUNCTION END------------------------------------------------


begin:

addi $20, $0, 1

addi $25, $20, 0
addi $26, $20, 0
addi $27, $20, 0
jal drawPixel

jal delay1S

j begin


quit:
j quit

.data
delayCont: .word 0x000F4240
screenWidth: .word 640
vgaStart:  .word 0x40000000