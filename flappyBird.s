.data
stageWidth:		.word 64		# Stage size
stageHeight:		.word 64		# Settings: use $gp, 64x64, 8x Scaling, 512x512

playerX:		.word 5			# Position of bird
playerY:		.word 32		# Half of stageHeight
playerSize:		.word 3			# Dimensions of bird; bird is a square

#defaultDir: 		.word 0xFFFF0004
gravity: 		.word 1			# Downward force
boost: 			.word 5			# Upwards force when button is pressed
pipeWidth: 		.word 6			# Pipe width
pipeGap:		.word 16		# Space between top and bottom pipes
pipeSpace: 		.word 16		# Space between each set of top/bottom pipes
pipeHeight:   		.word 20		# Pipe height

playerColor:		.word 0x0022CC22	# Store color to draw objects
#bgndColor:		.word 0xFF003300	# Store color to draw background

vgaStart:  .word 0x40000000

.text
main:

mainInit:
			# addi $29, $0, 1024	# $sp = 1024
			# Prepare the arena
			lw $29, vgaStart($0)
			lw $4, bgndColor	# Fill stage with background color
			jal fillColor
			jal AddBounds		# Add walls
			
			# Load player info
			lw $4, playerX 		#
			lw $5, playerY
			lw $6, playerColor
			
			# draw initial player
			jal drawPlayer		# Convert player position to address

			lw $20, defaultDir	# Store default dir in $20

			# Store player location
			add $22, $0, $4		# Store playerX in $22
			add $23, $0, $5		# Store playerY in $23
			
			# Draw initial pipes
			lw $16, pipeSpace	# store x of first pipe 
			add $4, $0, $16 	# redraw the pipes
			lw $5, playerColor 
			jal drawAllPipe

#mainWaitToStart:
			# Wait for the player to press key to start game
#			lw $8, 0xFFFF0000		# Retrieve transmitter control ready bit
#			blez $8, mainWaitToStart	# Check if a key was pressed

mainGame:
			# Actual game
			# Update bird
			jal GetDir		# Get direction from keyboard
			add $20, $0, $2		# $20 is direction from keyboard
			add $4, $0, $16 	# Load position

			# Move up or add down based on if button pressed
mainMoveUp:
			bne, $20, 0x02000000, mainMoveDown
			lw $5, boost
			add $23, $23, $5		# update bird y
			j mainGameCtd

mainMoveDown:
			lw $5, gravity
			add $23, $23, $5		# Down

mainGameCtd:
			# update player with new position
			add $4, $0, $22
			add $5, $0, $23
			lw $6, playerColor
			jal drawPlayer		# Update player's location on screen

			# draw in updated pipes
			addi $16, $16, -1	# move pipes left 
			add $4, $0, $16 	# redraw the pipes
			lw $5, playerColor 
			jal drawAllPipe

			jal collisionDetect	# Check for collisions

			#bne $2, $0, mainGameOver
			j mainGame

mainGameOver:
			j mainInit

#FUNCTION drawPixel------------------------------------------
#Draws the pixel at x = $4, y = $5, color = $6
#Dicks with registers: all the T registers from 8 to 15
#---------------------------
drawPixel:
sll $8, $5, 7
add $8, $8, $4				#Add X offset to $8
add $8, $8, $29
sw $6, 0($8)				#Draw the pixel

jr $31
#FUNCTION END------------------------------------------------
		#
###########################################################################################
# Function to retrieve input from the keyboard and return it as an alpha channel direction
# Takes none
# Returns $2 = direction
GetDir:
		addi $8, $0, 0xFFFF0004		# Load input value
upPressed:
		bne $8, 119, GetDir_done
		addi $2, $0, 0x02000000		# Up was pressed
GetDir_done:
		jr $31
###########################################################################################
# Fill stage with color, $4
fillColor:
		add $24, $0, $31		# back up $31
		add $30, $0, $4			# back up color 
		
		add $4, $0, $0
		add $5, $0, $0
		lw $6, stageWidth		
		lw $7, stageHeight
		
		jal drawRect			# fill screen 
		
		add $31, $0, $24
		jr $31
###########################################################################################
# Add bot wall
AddBounds:	
		add $24, $0, $31			# back up $31
		
		add $4, $0, $0			# draw line from x
		lw $5, stageWidth		# to end of screen
		lw $6, stageHeight		# at stageHeight
		addi $6, $6, -1			# minus 1
		lw $7, playerColor
		
		jal drawLineHorizXY
		
		add $31, $0, $24			
		jr $31
###########################################################################################
# Draw horizontal line from $4, $6 (x1, y) to $5, $6 (x2, y) in color $7
drawLineHorizXY:
		add $2, $0, $31			# back up $31
		
		add $9, $0, $4			# back up $4 (x1)
		add $10, $0, $5			# back up $5 (x2)
		add $11, $0, $6			# back up $6 (y)
		
		add $5, $0, $6			# move y to $5
		add $6, $0, $7
		jal drawPixel			# draw (x1, y)
keepMovingRight:	
		addi $9, $9, 1			# move x1 right by 1 coord
		add $4, $0, $9			# move x1 to $4
		add $5, $0, $11			# move y to $5
		add $6, $0, $7
		jal drawPixel
		blt $9, $10, keepMovingRight
	
		add $31, $0, $2
		jr $31
###########################################################################################
# Draw rectangle from $4, $5 (x, y) with width $6, and height $7, in color $30
drawRect:
		add $25, $0, $31		# back up $31
		
		add $12, $0, $4			# back up $4 (x)
		add $13, $0, $5			# back up $5 (y)
		
		add $14, $12, $6		# calculate end x
		add $15, $13, $7 		# calculate end y
		
		add $5, $0, $14			# move end x to $5
		add $6, $0, $13			# move y to $6
		add $7, $0, $30			# move color to $7
		jal drawLineHorizXY		# draw line from x, y to end x, y
keepDrawingAcross:	
		addi $13, $13, 1		# move y down by 1 coord
		add $4, $0, $12			# move x to $4
		add $5, $0, $14			# move end x to $5
		add $6, $0, $13			# move y to $6
		jal drawLineHorizXY
		blt $13, $15, keepDrawingAcross
		
		add $31, $0, $25
		jr $31
###########################################################################################
# Draw the player given an x, y coord $4, $5, of top left corner, in the color $6
drawPlayer:
		add $24, $0, $31		# back up $31
		lw $6, playerSize	# width
		lw $7, playerSize 	# heigth = width
		lw $30, playerColor
		jal drawRect
		
		add $31, $0, $24
		jr $31
###########################################################################################
# Draw pipe from x at $4 in top left corner with height $5 in color $6
drawPipe:
		add $24, $0, $31 	# back up $31
		
		add $26, $0, $4		# back up x
		add $27, $0, $5		# back up height
		add $30, $0, $6		# color 
		
		add $5, $0, $0
		lw $6, pipeWidth
		add $7, $0, $27		# height
		jal drawRect
		
		lw $11, pipeGap
		add $5, $5, $11		# move y to bottom half of pipe 
		add $5, $5, $27 
		add $4, $0, $26		# move x to $4
		lw $6, pipeWidth
		lw $12, stageHeight
		sub $7, $12, $5		# calculate height of this 
		jal drawRect
		
		add $31, $0, $24
		jr $31
###########################################################################################
# Draw all pipes from x at $4 in top left corner in color $5
drawAllPipe:
		add $21, $0, $31 
		add $17, $0, $4
		add $30, $0, $5
		
		lw $5, pipeHeight	
		lw $6, playerColor
		jal drawPipe
			
		lw $18, pipeWidth
		lw $19, pipeSpace
		add $17, $17, $18	# second pipe 
		add $17, $17, $19
		add $4, $0, $17
		lw $5, pipeHeight	
		lw $6, playerColor
		jal drawPipe

		add $17, $17, $18	# third pipe 
		add $17, $17, $19
		add $4, $0, $17
		lw $5, pipeHeight	
		lw $6, playerColor
		jal drawPipe
			
		add $17, $17, $18	# fourth pipe 
		add $17, $17, $19
		add $4, $0, $17
		lw $5, pipeHeight	
		lw $6, playerColor
		jal drawPipe
		
		add $31, $0, $21
		jr $31
###########################################################################################
# Detects collision between bird and pipe
collisionDetect:
		jr $31