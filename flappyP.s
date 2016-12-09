.text

lw $3, vgaStart($0)
lw $2, delayConst($0)
addi $23, $0, 0	#init bird dY
addi $26, $0, 50 #init bird Y

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

###########################################################################################
# Fill stage with color, blank
fillColor:
		add $28, $0, $31		# back up $31
		
		addi $16, $0, 0
		addi $17, $0, 0
		addi $18, $0, 128
		addi $19, $0, 128
		addi  $6, $0, 0
		
		jal drawRect			# fill screen 
		
		add $31, $0, $28
		jr $31
###########################################################################################

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

###########################################################################################

drawPlayer:
	add $28, $0, $31		# back up $31
	
	lw $8, 0xFFF($0)
	addi $9, $0, -10
	and $9, $9, $8
	add $21, $21, $9
	addi $20, $8, 0

	addi $21, $21, 1		#increase down accel
	add $23, $23, $21		#make bird fall

	sra $17, $23, 5			#Set Y to a scaled down version

	addi $16, $0, 10		# X coord
	addi $18, $0, 5		# W
	addi $19, $0, 5		# H
	addi $6, $0, 0x1		# Color

	jal drawRect
	
	add $31, $0, $28
	jr $31

###########################################################################################
# Draw pipe from x at $16 gap at $19
drawPipe:
		add $28, $0, $31 	# back up $31
		
		addi $17, $0, 0
		addi $18, $0, 10	#CONST, PIPE WIDTH
		addi $6, $0, 0xFF

		jal drawRect
		
		addi $17, $19, 30	#CONST, GAP HEIGHT!!!!!!!!!
		addi $19, $0, 127	#Make H 127
		sub $19, $19, $17	#Subtract gap

		jal drawRect

		add $31, $0, $28
		jr $31

###########################################################################################
# Draw all pipes from x at $4 in top left corner in color $5
drawAllPipe:
		add $27, $0, $31 	#BACK IT UP

		addi $22, $22, -1	#CONST, pipe moving back in X
		
		addi $16, $22, 0
		addi $8, $0, 0x7F	#Load constant to and with
		and $16, $16, $8
		addi $19, $0, 30
		jal drawPipe
			
		addi $16, $22, 43
		addi $8, $0, 0x7F	#Load constant to and with
		and $16, $16, $8
		addi $19, $0, 40
		jal drawPipe

		addi $16, $22, 86
		addi $8, $0, 0x7F	#Load constant to and with
		and $16, $16, $8
		addi $19, $0, 50
		jal drawPipe
		
		add $31, $0, $27
		jr $31


begin:

jal blankScreen
jal drawAllPipe
jal drawPlayer
jal delay


j begin


quit:
j quit

.data
delayConst:  .word 0x00018240
vgaStart:  .word 0x40000000

#delayConst: .word 1000					#FOR MARS$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#vgaStart: .word 0x10010000				#FOR MARS$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$