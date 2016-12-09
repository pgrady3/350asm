.text

#------------------------------
#0 Zero, but don't write to it, not sure protection works
#1 VGA start address
#2 Screen width
#3 Rect X
#4 Rect Y
#5 Rect W
#6 Rech H
#
#10 Current V addr
#11 Current V pos
#12 Current H pos
#13 Current color
#14 Pixel addr
#
#16 Temp 1 (used by clearScreen)
#17 Temp 2 (used by clearScreen)
#
#20 Delay counter
#29 Stack pointer
#31 Return address, NO TOUCH
#------------------------------

initializeVga:
lw $1, vgaStart($0)		#Load the beginning VGA addr into $1
lw $2, screenWidth($0)

jal delay1S				#Processor doest work if you don't delay a little at first?

lw $5, rectW($0)

beginMainLoop:

lw $3, rectX($0)
lw $4, rectY($0)
addi $5, $5, 1
lw $6, rectH($0)

add $10, $0, $0
add $11, $0, $0
add $12, $0, $0
addi $13, $0, 200

drawRow:
add $12, $0, $0			#Reset X position

drawPixel:
add $14, $12, $10		#Add X to Y
add $14, $14, $1		#Add the screen offset
sw $13, 0($14)			#Set the pixel
addi $12, $12, 1		#Increment X
blt $12, $5, drawPixel	#End drawPixel loop

addi $11, $11, 1
add $10, $10, $2

blt $11, $6, drawRow	#End drawRow loop

#jal delay1S
nop
nop
nop
nop
nop

#jal clearScreen
nop
nop
nop
nop
nop

jal delay1S
nop
nop
nop
nop
nop

j beginMainLoop
nop
nop
nop
nop
nop
nop


#j quit					#If we're all done, jump to quit

#----------------------------------------------------------------
clearScreen:
lw $16, vgaEnd($0)		#Load the end address
lw $17, vgaStart($0)	#Load the begin address

clearScreenLoop:
sw $0, 0($17)
addi $17, $17, 1
blt $17, $16, clearScreenLoop

jr $31
#-----------------------------------------------------------------

delay1S:
sub $0, $0, $0
lw $20, delayCont($0)
delayLoop:
addi $20, $20, -1

nop
nop
nop
nop
nop
nop

bne $0, $20, delayLoop
nop
nop
nop
nop
nop
nop

jr $31

quit:
j quit					#Endless loop

.data
vgaStart:  .word 0x40000000
vgaEnd:    .word 0x4004B000
screenWidth: .word 640
rectX: .word 0
rectY: .word 0
rectW: .word 80
rectH: .word 80
delayCont: .word 0x003F4240
zero: .word 0
