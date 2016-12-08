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
			lw $a0, playerX 	#
			lw $a1, playerY
			jal coordToAddr		# Convert player position to address

			move $s0, $v0		# Store player start position in s0

			lw $s4, defaultDir	# Store default dir in s4

			# Load color info
			lw $s6, playerColor	# Store drawing color in s6
			lw $s7, bgndColor	# Store background color in s7

			# Prepare the arena
			move $a0, $s7		# Fill stage with background color
			jal fillColor
			jal AddBounds		# Add walls

			# Draw initial player
			move $a0, $s0
			jal drawPlayer

			# Draw initial pipes
			lw $a0, pipeSpace	# start first pipe
			move $a1, $0
			jal coordToAddr

			move $s1, $v0		# Store address of first pipe
			move $a0, $s1
			lw $a2, playerColor
			jal drawPipe

			lw $s2, pipeSpace
			sll $s2, $s2, 2
			add $s1, $s1, $s2	# Go to next pipe
			move $a0, $s1
			lw $a2, playerColor
			jal drawPipe

			add $s1, $s1, $s2	# Go to next pipe
			move $a0, $s1
			lw $a2, playerColor
			jal drawPipe

			add $s1, $s1, $s2	# Go to next pipe
			move $a0, $s1
			lw $a2, playerColor
			jal drawPipe

#mainWaitToStart:
			# Wait for the player to press key to start game
#			lw $t0, 0xFFFF0000			# Retrieve transmitter control ready bit
#			blez $t0, mainWaitToStart		# Check if a key was pressed

mainGame:
			# Actual game

			# Update bird
			jal GetDir		# Get direction from keyboard
			move $s4, $v0		# $s4 is direction from keyboard
			move $a0, $s0 		# Load position

			# Move up or move down based on if button pressed
mainMoveUp:
			bne, $s4, 0x02000000, mainMoveDown
			lw $a1, boost
			jal moveUp		# Up
			j mainGameCtd

mainMoveDown:
			lw $a1, gravity
			jal moveDown		# Down

mainGameCtd:

			# erase old player position by retracing with background color
			move $a0, $s0
			lw $a1, bgndColor
			jal drawPlayer

			# update player with new position
			move $s0, $v0 		# Update address
			move $a0, $s0
			jal drawPlayer		# Update player's location on screen

			# clear pipes by tracing them with background color
			lw $a2, bgndColor
			jal drawPipe		# Draw the rightmost pipe

			lw $s2, pipeSpace
			sll $s2, $s2, 2
			sub $s1, $s1, $s2	# Go to next pipe
			move $a0, $s1
			lw $a2, bgndColor
			jal drawPipe

			sub $s1, $s1, $s2	# Go to next pipe
			move $a0, $s1
			lw $a2, bgndColor
			jal drawPipe

			sub $s1, $s1, $s2	# Go to next pipe
			move $a0, $s1
			lw $a2, bgndColor
			jal drawPipe

			# draw in updated pipes
			move $a0, $s1
			addi $a1, $0, 1
			jal moveLeft		# Move rightmost pipe left by 1 unit

			move $s1, $v0
			move $a0, $s1
			lw $a2, playerColor
			jal drawPipe		# Draw the leftmost pipe

			lw $s2, pipeSpace
			sll $s2, $s2, 2
			add $s1, $s1, $s2	# Go to next pipe
			move $a0, $s1
			lw $a2, playerColor
			jal drawPipe

			add $s1, $s1, $s2	# Go to next pipe
			move $a0, $s1
			lw $a2, playerColor
			jal drawPipe

			add $s1, $s1, $s2	# Go to next pipe
			move $a0, $s1
			lw $a2, playerColor
			jal drawPipe

			jal collisionDetect	# Check for collisions

			bnez $v0, mainGameOver
			b mainGame

mainGameOver:
			b mainInit

###########################################################################################
# Get x,y coordinates stored in $a0,$a1 and returns pixel address in $v0
coordToAddr:
		#address = 4*(x + y*width) + gp
		move $v0, $a0			# Move x to $v0
		lw $a0, stageWidth		#
		multu $a0, $a1			# Multiply y by the stage width
		mflo $a0			# Get result of $a0*$a1
		addu $v0, $v0, $a0		# Add the result to the x coordinate and store in $v0
		sll $v0, $v0, 2			# Multiply $v0 by 4 bytes
		addu $v0, $v0, $gp		# Add gp to v0 to give stage memory address
		jr $ra				#
###########################################################################################
# Function to move a given stage memory address right by a given number of tiles
# Takes a0 = address, a1 = distance
# Returns v0 = new address
moveLeft:
		#address -= distance*4
		move $v0, $a0			# Move address to $v0
		sll $a0, $a1, 2			# Multiply distance by 4
		sub $v0, $v0, $a0		# Add result to $v0
		jr $ra				#
###########################################################################################
# Function to move a given stage memory address up by a given number of tiles
# Takes a0 = address, a1 = distance
# Returns v0 = new address
moveUp:
		#address -= distance*width*4
		move $v0, $a0			# Move address to $v0
		lw $a0, stageWidth		# Load the screen width into $a0
		multu $a0, $a1			# Multiply distance by screen width
		mflo $a0			# Retrieve result
		sll $a0, $a0, 2			# Multiply $v0 by 4
		subu $v0, $v0, $a0		# Sub result from $v0
		jr $ra				#

###########################################################################################
# Function to move a given stage memory address down by a given number of tiles
# Takes a0 = address, a1 = distance
# Returns v0 = new address
moveDown:
		#address += distance*width*4
		move $v0, $a0			# Similar to MoveUp
		lw $a0, stageWidth		#
		multu $a0, $a1			#
		mflo $a0			#
		sll $a0, $a0, 2			#
		addu $v0, $v0, $a0		#
		jr $ra				#
###########################################################################################
# Function to retrieve input from the keyboard and return it as an alpha channel direction
# Takes none
# Returns v0 = direction
GetDir:
		li $t0, 0xFFFF0004		# Load input value
upPressed:
		bne, $t0, 119, GetDir_done
		li $v0, 0x02000000		# Up was pressed
GetDir_done:
		jr $ra
###########################################################################################
# Fill stage with color, $a0
fillColor:
		lw $a1, stageWidth		# Calculate ending position
		lw $a2, stageHeight
		multu $a1, $a2			# Multiply screen width by screen height
		mflo $a2			# Set end point
		sll $a2, $a2, 2			# Multiply by 4
		add $a2, $a2, $gp		# Add global pointer
		move $a1, $gp			# Set start point
fillColorLoop:
		sw $a0, 0($a1)
		add $a1, $a1, 4			# Add 4
		bne $a1, $a2, fillColorLoop	# Keep looping until reached end
		jr $ra
###########################################################################################
# Add bot wall
AddBounds:	
		move $t4, $ra			# Back up $ra 
		
		lw $t0, stageWidth		# Calculate final ending position
		lw $t1, stageHeight
		subi $t0, $t0, 1
		subi $t1, $t1, 1

		move $a0, $0			# Convert (0, stageHeight) to address
		move $a1, $t1
		jal coordToAddr

		move $t2, $v0			# Save the address to $t2

		move $a0, $t0			# Convert (stageWidth, stageHeight) to address
		move $a1, $t1
		jal coordToAddr

		move $t3, $v0			# Save the address to $t3

		move $a0, $t2			
		move $a1, $t3
		lw $a2, playerColor
		jal drawLineHoriz		# draw line from (0, stageHeight) to (stageWidth, stageHeight)
		
		move $ra, $t4
		jr $ra
###########################################################################################
# Draw horizontal line from $a0 to $a1 in color $a2
drawLineHoriz:
		sw $a2, 0($a0)			# color
		addi $a0, $a0, 4		# add 4 to go to next pixel on the right
		bne $a0, $a1, drawLineHoriz	# keep doing this until $a1
		jr $ra
###########################################################################################
# Draw vertical line from $a0 to $a1 in color $a2
drawLineVert:
		sw $a2, 0($a0)			# color
		lw $a3, stageWidth		
		sll $a3, $a3, 2			# stageWidth*4 stored in $a3
		add $a0, $a0, $a3		# move to next pixel downwards
		bne $a0, $a1, drawLineVert	# keep doing this until $a1
		jr $ra
###########################################################################################
# Draw the player given an address, $a0, of top left corner, in the color $a1
drawPlayer:
		move $t6, $ra			# back up $ra
		
		move $t0, $a0			# back up start address (top left coord)
		move $t5, $a1			# back up color
		lw $t1, playerSize
		sll $t1, $t1, 2			# playerSize*4 stored in $t1
		add $t2, $t0, $t1		# player top right coord
		lw $t3, stageWidth
		multu $t1, $t3			# for player vertical distance in pixels
		mflo $t3
		add $t3, $t3, $t0		# player bottom left coord
		add $t4, $t3, $t1		# player bottom right coord

		move $a2, $t5			
		move $a1, $t2
		jal drawLineHoriz		# draw top line of player

		move $a0, $t0			
		move $a1, $t3
		jal drawLineVert		# draw left line of player

		move $a0, $t3
		move $a1, $t4
		jal drawLineHoriz		# draw bottom line of player

		move $a0, $t2
		move $a1, $t4
		jal drawLineVert		# draw right line of player
		
		move $ra, $t6
		jr $ra
###########################################################################################
# Draw pipe from an address $a0 in top left corner with height $a1 in color $a2
drawPipe:
		move $t8, $ra 			# back up $ra
		
		move $t0, $a0			# Back up $a0-$a2 bc will call other functions
		move $t1, $a1
		lw $t3, pipeWidth
		sll $t3, $t3, 2			# pipeWidth*4 stored in $t3

		lw $t4, pipeHeight
		lw $t2, stageWidth
		multu $t4, $t2
		mflo $t4
		sll $t4, $t4, 2			# pipeHeight*stageWidth*4 stored in $t4

		add $t5, $t0, $t4		# $t5 is bottom left corner of top part of pipe
		move $a1, $t5
		jal drawLineVert		# draw line from $t0/$a0 down to $t5

		add $t6, $t5, $t3		# $t6 is bottom right corner of top part of pipe
		move $a0, $t5
		move $a1, $t6
		jal drawLineHoriz		# draw line from $t5 to $t6

		add $t7, $t0, $t3		# $t7 is top right corner of top part of pipe
		move $a0, $t7
		move $a1, $t6
		jal drawLineVert		# draw line from $t7 down to $t6

		lw $t4, pipeGap
		lw $t2, stageWidth
		multu $t4, $t2
		mflo $t4
		sll $t4, $t4, 2 		# pipeGap*stageWidth*4 stored in $t4

		add $t6, $t5, $t4		# $t6 is now top left corner of bot part of pipe
		add $t7, $t6, $t3		# $t7 is now top right corner of bot part of pipe
		move $a0, $t6
		move $a1, $t7
		jal drawLineHoriz		# draw line from $t6 to $t7

		lw $t4, stageHeight
		subi $t4, $t4, 1
		lw $t5, stageWidth
		multu $t4, $t5
		mflo $t4
		sll $t4, $t4, 2			# (stageHeight-1)*stageWidth*4 stored in $t4
		add $t5, $t4, $t0		# $t5 is now bottom left corner of bot part of pipe
		move $a0, $t6
		move $a1, $t5
		jal drawLineVert 		# draw line from $t6 to $t5

		add $t4, $t5, $t3		# $t4 is now bottom right corner of bot part of pipe
		move $a0, $t7
		move $a1, $t4
		jal drawLineVert		# draw line from $t7 to $t4
		
		move $ra, $t8
		jr $ra
###########################################################################################
# Detects collision between bird and pipe
collisionDetect:
		jr $ra
