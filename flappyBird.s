.data
stageWidth:		.word 64		# Stage size
stageHeight:		.word 64		# Settings: use $gp, 64x64, 8x Scaling, 512x512

playerX:		.word 5			# Position of bird
playerY:		.word 32		# Half of stageHeight
playerSize:		.word 3			# Dimensions of bird; bird is a square

defaultDir: 		.word 0xFFFF0004
gravity: 		.word 1			# Downward force
boost: 			.word 5			# Upwards force when button is pressed
pipeWidth: 		.word 6			# Pipe width
pipeGap:		.word 16		# Space between top and bottom pipes
pipeSpace: 		.word 16		# Space between each set of top/bottom pipes
pipeHeight:   		.word 20		# Pipe height

playerColor:		.word 0x0022CC22	# Store color to draw objects
bgndColor:		.word 0xFF003300	# Store color to draw background

.text
main:

mainInit:
			# Load player info
			lw $4, playerX 	#
			lw $5, playerY
			lw $6, playerColor
			
			# draw initial player
			jal drawPlayer		# Convert player position to address

			lw $20, defaultDir	# Store default dir in $20

			# Store player location
			add $22, $0, $4		# Store playerX in $22
			add $23, $0, $5		# Store playerY in $23

			# Prepare the arena
			lw $4, bgndColor	# Fill stage with background color
			jal fillColor
			jal AddBounds		# Add walls

			# Draw initial pipes
			lw $16, pipeSpace	# store x of first pipe 
			add $4, $0, $16
			add $5, $0, $0
			lw $6, pipeHeight	
			lw $7, playerColor
			jal drawPipe
			
			lw $17, pipeWidth
			lw $18, pipeSpace
			add $16, $16, $17	# second pipe 
			add $16, $16, $18
			add $4, $0, $16
			add $5, $0, $0
			lw $6, pipeHeight	
			lw $7, playerColor
			jal drawPipe

			add $16, $16, $17	# third pipe 
			add $16, $16, $18
			add $4, $0, $16
			add $5, $0, $0
			lw $6, pipeHeight	
			lw $7, playerColor
			jal drawPipe
			
			add $16, $16, $17	# fourth pipe 
			add $16, $16, $18
			add $4, $0, $16
			add $5, $0, $0
			lw $6, pipeHeight	
			lw $7, playerColor
			jal drawPipe

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

			jal collisionDetect	# Check for collisions

			#bne $2, $0, mainGameOver
			b mainGame

mainGameOver:
			b mainInit

###########################################################################################
# Unused
# Get x,y coordinates stored in $4,$5 and returns pixel address in $2
coordToAddr:
		#address = 4*(x + y*width) + gp
		add $2, $0, $4			# Move x to $2
		lw $4, stageWidth		#
		multu $4, $5			# Multiply y by the stage width
		mflo $4				# Get result of $4*$5
		addu $2, $2, $4			# Add the result to the x coordinate and store in $2
		sll $2, $2, 2			# Multiply $2 by 4 bytes
		add $2, $2, $28			# Add $28 to $2 to give stage memory address
		jr $31				#
###########################################################################################
# Get x,y coordinates stored in $4,$5 and draws in color $6
drawPixel:
		#address = 4*(x + y*width) + gp
		add $8, $0, $4			# Move x to $8
		lw $4, stageWidth		#
		multu $4, $5			# Multiply y by the stage width
		mflo $4				# Get result of $4*$5
		addu $8, $8, $4			# Add the result to the x coordinate and store in $2
		sll $8, $8, 2			# Multiply $2 by 4 bytes
		add $8, $8, $28			# Add $28 to $2 to give stage memory address
		sw $6, 0($8)			# color in the pixel
		jr $31				#
###########################################################################################
# Unused
# Function to add a given stage memory address right by a given number of tiles
# Takes a0 = address, a1 = distance
# Returns v0 = new address
moveLeft:
		#address -= distance*4
		add $2, $0, $4			# Move address to $2
		sll $4, $5, 2			# Multiply distance by 4
		sub $2, $2, $4			# Add result to $2
		jr $31				#
###########################################################################################
# Unused
# Function to add a given stage memory address up by a given number of tiles
# Takes $4 = address, $5 = distance
# Returns $2 = new address
moveUp: 
		#address -= distance*width*4
		add $2, $0, $4			# Move address to $2
		lw $4, stageWidth		# Load the screen width into $4
		multu $4, $5			# Multiply distance by screen width
		mflo $4				# Retrieve result
		sll $4, $4, 2			# Multiply $2 by 4
		sub $2, $2, $4			# Sub result from $2
		jr $31				#

###########################################################################################
# Unused
# Function to add a given stage memory address down by a given number of tiles
# Takes $4 = address, $5 = distance
# Returns $2 = new address
moveDown:
		#address += distance*width*4
		add $2, $0, $4			# Similar to MoveUp
		lw $4, stageWidth		#
		multu $4, $5			#
		mflo $4				#
		sll $4, $4, 2			#
		addu $2, $2, $4			#
		jr $31				#
###########################################################################################
# Function to retrieve input from the keyboard and return it as an alpha channel direction
# Takes none
# Returns $2 = direction
GetDir:
		addi $8, $0, 0xFFFF0004		# Load input value
upPressed:
		bne, $8, 119, GetDir_done
		addi $2, $0, 0x02000000		# Up was pressed
GetDir_done:
		jr $31
###########################################################################################
# Fill stage with color, $4
fillColor:
		add $8, $0, $31			# back up $31
		add $30, $0, $4			# back up color 
		
		add $4, $0, $0
		add $5, $0, $0
		lw $6, stageWidth		
		lw $7, stageHeight
		
		jal drawRect			# fill screen 
		
		add $31, $0, $8
		jr $31
###########################################################################################
# Add bot wall
AddBounds:	
		add $8, $0, $31			# back up $31
		
		add $4, $0, $0			# draw line from x
		lw $5, stageWidth		# to end of screen
		lw $6, stageHeight		# at stageHeight
		addi $6, $6, -1			# minus 1
		lw $7, playerColor
		
		jal drawLineHorizXY
		
		add $31, $0, $8			
		jr $31
###########################################################################################
# Unused
# Draw horizontal line from $4 to $5 in color $6
drawLineHoriz:
		sw $6, 0($4)			# color
		addi $4, $4, 4			# add 4 to go to next pixel on the right
		bne $4, $5, drawLineHoriz	# keep doing this until $5
		jr $31
###########################################################################################
# Unused
# Draw vertical line from $4 to $5 in color $6
drawLineVert:
		sw $6, 0($4)			# color
		lw $7, stageWidth		
		sll $7, $7, 2			# stageWidth*4 stored in $7
		add $4, $4, $7			# add to next pixel downwards
		bne $4, $5, drawLineVert	# keep doing this until $5
		jr $31
###########################################################################################
# Draw horizontal line from $4, $6 (x1, y) to $5, $6 (x2, y) in color $7
drawLineHorizXY:
		add $8, $0, $31			# back up $31
		
		add $9, $0, $4			# back up $4 (x1)
		add $10, $0, $5			# back up $5 (x2)
		add $11, $0, $6			# back up $6 (y)
		
		add $5, $0, $6			# move y to $5
		jal drawPixel			# draw (x1, y)
keepMovingRight:	
		addi $9, $9, 1			# move x1 right by 1 coord
		add $4, $0, $9			# move x1 to $4
		add $5, $0, $11			# move y to $5
		jal drawPixel
		blt $9, $10, keepMovingRight
	
		add $31, $0, $8
		jr $31
###########################################################################################
# Unused 
# Draw vertical line from $4, $5 (x, y1) to $4, $6 (x, y2) in color $7
drawLineVertXY:
		add $8, $0, $31			# back up $31
		
		add $9, $0, $4			# back up $4 (x)
		add $10, $0, $5			# back up $5 (y1)
		add $11, $0, $6			# back up $6 (y2)
		
		jal drawPixel			# draw (x, y1)
keepMovingDown:	
		addi $10, $10, 1		# move y1 down by 1 coord
		add $4, $0, $9			# move x to $4
		add $5, $0, $10			# move y1 to $5
		jal drawPixel
		blt $10, $11, keepMovingDown
		
		add $31, $0, $8
		jr $31
###########################################################################################
# Draw rectangle from $4, $5 (x, y) with width $6, and height $7, in color $30
drawRect:
		add $8, $0, $31			# back up $31
		
		add $9, $0, $4			# back up $4 (x)
		add $10, $0, $5			# back up $5 (y)
		
		add $11, $9, $6			# calculate end x
		add $12, $10, $7 		# calculate end y
		
		add $5, $0, $11			# move end x to $5
		add $6, $0, $10			# move y to $6
		add $7, $0, $30			# move color to $7
		jal drawLineHorizXY		# draw line from x, y to end x, y
keepDrawingAcross:	
		addi $10, $10, 1		# move y down by 1 coord
		add $4, $0, $9			# move x to $4
		add $5, $0, $11			# move end x to $5
		add $6, $0, $10			# move y to $6
		jal drawLineHorizXY
		blt $10, $11, keepDrawingAcross
		
		add $31, $0, $8
		jr $31
###########################################################################################

# Draw the player given an x, y coord $4, $5, of top left corner, in the color $6
drawPlayer:
		add $8, $0, $31		# back up $31
		lw $6, playerSize	# width
		lw $7, playerSize 	# heigth = width
		add $30, $0, $6
		jal drawRect
		
		add $31, $0, $8
		jr $31
###########################################################################################
# Draw pipe from x at $4 in top left corner with height $5 in color $6
drawPipe:
		add $24, $0, $31 	# back up $31
		
		add $8, $0, $4		# back up x
		add $9, $0, $5		# back up height
		add $30, $0, $7		# color 
		
		add $5, $0, $0
		lw $6, pipeWidth
		add $7, $0, $9		# height
		jal drawRect
		
		lw $11, pipeGap
		add $5, $10, $11	# move y to bottom half of pipe 
		add $4, $0, $8		# move x to $4
		lw $6, pipeWidth
		lw $12, stageHeight
		sub $7, $12, $5		# calculate height of this 
		jal drawRect
		
		add $31, $0, $24
		jr $31
###########################################################################################
# Draw all pipes from x at $4 in top left corner in color $5
drawAllPipe:
		add $8, $0, $31 
		add $9, $0, $4
		add $10, $0, $5
		
		lw $5, pipeHeight	
		lw $6, playerColor
		jal drawPipe
			
		lw $11, pipeWidth
		lw $12, pipeSpace
		add $8, $8, $11		# second pipe 
		add $8, $8, $12
		add $4, $0, $8
		lw $5, pipeHeight	
		lw $6, playerColor
		jal drawPipe

		add $8, $8, $11		# second pipe 
		add $8, $8, $12
		add $4, $0, $8
		lw $5, pipeHeight	
		lw $6, playerColor
		jal drawPipe
			
		add $8, $8, $11		# second pipe 
		add $8, $8, $12
		add $4, $0, $8
		lw $5, pipeHeight	
		lw $6, playerColor
		jal drawPipe
		
		add $31, $0, $8
		jr $31
###########################################################################################
# Detects collision between bird and pipe
collisionDetect:
		jr $31