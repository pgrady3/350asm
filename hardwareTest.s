.text

lw $19, vgaStart($0)
lw $11, delayCont($0)
jal delay1S	#NEED THIS DONT KNOW WHY
j begin

#FUNCTION blankScreen----------------------------------------------
#Delays for 1 second
#Dicks with registers: 10
#---------------------------
blankScreen:
addi $9, $19, 15360
addi $8, $19, 0

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

#FUNCTION delay1S----------------------------------------------
#Delays for 1 second
#Dicks with registers: 10
#---------------------------
delay1S:
addi $10, $11, 0
addi $20, $10, 0
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
#lw $9, screenWidth($0)		#Load width into $9
#mul $9, $9, $26				#Mutiply width * Y
#add $8, $8, $9				#Add Y offset to $8
add $8, $19, $25				#Add X offset to $8
sw $27, 0($8)				#Draw the pixel

jr $31
#FUNCTION END------------------------------------------------

begin:

#lw $9, screenWidth($0)		#Load width into $9
#addi $20, $20, 1
#mul $21, $20, $20

addi $25, $25, 1
addi $26, $0, 0
addi $27, $0, 1

jal blankScreen
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
#delayCont: .word 0x000F4240
delayCont:  .word 0x00004240
screenWidth: .word 640
vgaStart:  .word 0x40000000