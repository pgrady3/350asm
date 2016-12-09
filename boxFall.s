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
		lw $4, playerX 	#
		lw $5, playerY
		jal coordToAddr		# Convert player position to address

		add $16, $0, $2		# Store player start position in $16

		add $4, $0, $16
		lw $5, bgndColor
		jal drawPlayer
loopPlayer:
		lw $5, gravity
		jal addDown		# Down
		
		# erase old player position by retracing with background color
		add $4, $0, $16
		lw $5, bgndColor
		jal drawPlayer

		# update player with new position
		add $16, $0, $2 		# Update address
		add $4, $0, $16
		jal drawPlayer		# Update player's location on screen
		
		j loopPlayer

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
		jr $31	
###########################################################################################
# Function to add a given stage memory address down by a given number of tiles
# Takes $4 = address, $5 = distance
# Returns $2 = new address
addDown:
		#address += distance*width*4
		add $2, $0, $4			# Similar to MoveUp
		lw $4, stageWidth		#
		multu $4, $5			#
		mflo $4				#
		sll $4, $4, 2			#
		addu $2, $2, $4			#
		jr $31				#
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