.data
stageWidth:		.word 64		# Stage size
stageHeight:		.word 64		# Settings: use $gp, 64x64, 8x Scaling, 512x512

playerX:		.word 5			# Position of bird
playerY:		.word 32		# Half of stageHeight
playerSize:		.word 3			# Dimensions of bird; bird is a square

defaultDir: 		.word 0xFFFF0004
gravity: 		.word 3			# Downward force
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
			jal coordToAddr		# Convert player position to address

			add $16, $0, $2		# Store player start position in $16

			lw $20, defaultDir	# Store default dir in $20

			# Load color info
			lw $22, playerColor	# Store drawing color in $22
			lw $23, bgndColor	# Store background color in $23

			# Prepare the arena
			add $4, $0, $23		# Fill stage with background color
			jal fillColor
			jal AddBounds		# Add walls

			# Draw initial player
			add $4, $0, $16
			jal drawPlayer

			# Draw initial pipes
			lw $4, pipeSpace	# start first pipe
			add $5, $0, $0
			jal coordToAddr

			add $17, $0, $2		# Store address of first pipe
			add $4, $0, $17
			lw $6, playerColor
			jal drawPipe

			lw $18, pipeSpace
			sll $18, $18, 2
			add $17, $17, $18	# Go to next pipe
			add $4, $0, $17
			lw $6, playerColor
			jal drawPipe

			add $17, $17, $18	# Go to next pipe
			add $4, $0, $17
			lw $6, playerColor
			jal drawPipe

			add $17, $17, $18	# Go to next pipe
			add $4, $0, $17
			lw $6, playerColor
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
			add $4, $0, $16 		# Load position

			# Move up or add down based on if button pressed
mainMoveUp:
			bne, $20, 0x02000000, mainMoveDown
			lw $5, boost
			jal addUp		# Up
			j mainGameCtd

mainMoveDown:
			lw $5, gravity
			jal addDown		# Down

mainGameCtd:

			# erase old player position by retracing with background color
			add $4, $0, $16
			lw $5, bgndColor
			jal drawPlayer

			# update player with new position
			add $16, $0, $2 		# Update address
			add $4, $0, $16
			jal drawPlayer		# Update player's location on screen

			# clear pipes by tracing them with background color
			lw $6, bgndColor
			jal drawPipe		# Draw the rightmost pipe

			lw $18, pipeSpace
			sll $18, $18, 2
			sub $17, $17, $18	# Go to next pipe
			add $4, $0, $17
			lw $6, bgndColor
			jal drawPipe

			sub $17, $17, $18	# Go to next pipe
			add $4, $0, $17
			lw $6, bgndColor
			jal drawPipe

			sub $17, $17, $18	# Go to next pipe
			add $4, $0, $17
			lw $6, bgndColor
			jal drawPipe

			# draw in updated pipes
			add $4, $0, $17
			addi $5, $0, 1
			jal addLeft		# Move rightmost pipe left by 1 unit

			add $17, $0, $2
			add $4, $0, $17
			lw $6, playerColor
			jal drawPipe		# Draw the leftmost pipe

			lw $18, pipeSpace
			sll $18, $18, 2
			add $17, $17, $18	# Go to next pipe
			add $4, $0, $17
			lw $6, playerColor
			jal drawPipe

			add $17, $17, $18	# Go to next pipe
			add $4, $0, $17
			lw $6, playerColor
			jal drawPipe

			add $17, $17, $18	# Go to next pipe
			add $4, $0, $17
			lw $6, playerColor
			jal drawPipe

			jal collisionDetect	# Check for collisions

			#bne $2, $0, mainGameOver
			b mainGame

mainGameOver:
			b mainInit

###########################################################################################
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
# Function to add a given stage memory address right by a given number of tiles
# Takes a0 = address, a1 = distance
# Returns v0 = new address
addLeft:
		#address -= distance*4
		add $2, $0, $4			# Move address to $2
		sll $4, $5, 2			# Multiply distance by 4
		sub $2, $2, $4			# Add result to $2
		jr $31				#
###########################################################################################
# Function to add a given stage memory address up by a given number of tiles
# Takes $4 = address, $5 = distance
# Returns $2 = new address
addUp:
		#address -= distance*width*4
		add $2, $0, $4			# Move address to $2
		lw $4, stageWidth		# Load the screen width into $4
		multu $4, $5			# Multiply distance by screen width
		mflo $4				# Retrieve result
		sll $4, $4, 2			# Multiply $2 by 4
		sub $2, $2, $4			# Sub result from $2
		jr $31				#

###########################################################################################
# Function to add a given stage memory address down by a given number of tiles
# Takes $4 = address, $5 = distance
# Returns $2 = new address
addDown:
		#address += distance*width*4
		add $2, $0, $4			# Similar to MoveUp
		lw $4, stageWidth		#
		multu $4, $5			#
		mflo $4			#
		sll $4, $4, 2			#
		addu $2, $2, $4		#
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
		lw $5, stageWidth		# Calculate ending position
		lw $6, stageHeight
		multu $5, $6			# Multiply screen width by screen height
		mflo $6				# Set end point
		sll $6, $6, 2			# Multiply by 4
		add $6, $6, $28			# Add global pointer
		add $5, $0, $28			# Set start point
fillColorLoop:
		sw $4, 0($5)
		add $5, $5, 4			# Add 4
		bne $5, $6, fillColorLoop	# Keep looping until reached end
		jr $31
###########################################################################################
# Add bot wall
AddBounds:	
		add $12, $0, $31			# Back up $31 
		
		lw $8, stageWidth		# Calculate final ending position
		lw $9, stageHeight
		addi $8, $8, -1
		addi $9, $9, -1

		add $4, $0, $0			# Convert (0, stageHeight) to address
		add $5, $0, $9
		jal coordToAddr

		add $10, $0, $2			# Save the address to $10

		add $4, $0, $8			# Convert (stageWidth, stageHeight) to address
		add $5, $0, $9
		jal coordToAddr

		add $11, $0, $2			# Save the address to $11

		add $4, $0, $10			
		add $5, $0, $11
		lw $6, playerColor
		jal drawLineHoriz		# draw line from (0, stageHeight) to (stageWidth, stageHeight)
		
		add $31, $0, $12
		jr $31
###########################################################################################
# Draw horizontal line from $4 to $5 in color $6
drawLineHoriz:
		sw $6, 0($4)			# color
		addi $4, $4, 4			# add 4 to go to next pixel on the right
		bne $4, $5, drawLineHoriz	# keep doing this until $5
		jr $31
###########################################################################################
# Draw vertical line from $4 to $5 in color $6
drawLineVert:
		sw $6, 0($4)			# color
		lw $7, stageWidth		
		sll $7, $7, 2			# stageWidth*4 stored in $7
		add $4, $4, $7			# add to next pixel downwards
		bne $4, $5, drawLineVert	# keep doing this until $5
		jr $31
###########################################################################################
# Draw the player given an address, $4, of top left corner, in the color $5
drawPlayer:
		add $14, $0, $31			# back up $31
		
		add $8, $0, $4			# back up start address (top left coord)
		add $13, $0, $5			# back up color
		lw $9, playerSize
		sll $9, $9, 2			# playerSize*4 stored in $9
		add $10, $8, $9			# player top right coord
		lw $11, stageWidth
		multu $9, $11			# for player vertical distance in pixels
		mflo $11
		add $11, $11, $8		# player bottom left coord
		add $12, $11, $9		# player bottom right coord

		add $6, $0, $13			
		add $5, $0, $10
		jal drawLineHoriz		# draw top line of player

		add $4, $0, $8			
		add $5, $0, $11
		jal drawLineVert		# draw left line of player

		add $4, $0, $11
		add $5, $0, $12
		jal drawLineHoriz		# draw bottom line of player

		add $4, $0, $10
		add $5, $0, $12
		jal drawLineVert		# draw right line of player
		
		add $31, $0, $14
		jr $31
###########################################################################################
# Draw pipe from an address $4 in top left corner with height $5 in color $6
drawPipe:
		add $24, $0, $31 			# back up $31
		
		add $8, $0, $4			# Back up $4-$6 bc will call other functions
		add $9, $0, $5
		lw $11, pipeWidth
		sll $11, $11, 2			# pipeWidth*4 stored in $11

		lw $12, pipeHeight
		lw $10, stageWidth
		multu $12, $10
		mflo $12
		sll $12, $12, 2			# pipeHeight*stageWidth*4 stored in $12

		add $13, $8, $12		# $13 is bottom left corner of top part of pipe
		add $5, $0, $13
		jal drawLineVert		# draw line from $8/$4 down to $13

		add $14, $13, $11		# $14 is bottom right corner of top part of pipe
		add $4, $0, $13
		add $5, $0, $14
		jal drawLineHoriz		# draw line from $13 to $14

		add $15, $8, $11		# $15 is top right corner of top part of pipe
		add $4, $0, $15
		add $5, $0, $14
		jal drawLineVert		# draw line from $15 down to $14

		lw $12, pipeGap
		lw $10, stageWidth
		multu $12, $10
		mflo $12
		sll $12, $12, 2 		# pipeGap*stageWidth*4 stored in $12

		add $14, $13, $12		# $14 is now top left corner of bot part of pipe
		add $15, $14, $11		# $15 is now top right corner of bot part of pipe
		add $4, $0, $14
		add $5, $0, $15
		jal drawLineHoriz		# draw line from $14 to $15

		lw $12, stageHeight
		subi $12, $12, 1
		lw $13, stageWidth
		multu $12, $13
		mflo $12
		sll $12, $12, 2			# (stageHeight-1)*stageWidth*4 stored in $12
		add $13, $12, $8		# $13 is now bottom left corner of bot part of pipe
		add $4, $0, $14
		add $5, $0, $13
		jal drawLineVert 		# draw line from $14 to $13

		add $12, $13, $11		# $12 is now bottom right corner of bot part of pipe
		add $4, $0, $15
		add $5, $0, $12
		jal drawLineVert		# draw line from $15 to $12
		
		add $31, $0, $24
		jr $31
###########################################################################################
# Detects collision between bird and pipe
collisionDetect:
		jr $31
