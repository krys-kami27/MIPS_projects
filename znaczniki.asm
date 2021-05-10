#only 24-bits 320x240 pixels BMP files are supported
.eqv BMP_FILE_SIZE 230522
.eqv BYTES_PER_ROW 960

.data
#space for the 320x240 24-bits bmp image
.align 4
res:	.space 2
image:	.space BMP_FILE_SIZE
open:	.asciiz "("
next:	.asciiz ", "
end:	.asciiz ")\n"
error_opening: .asciiz "Error while opening file!\n"
fname:	.asciiz "input.bmp"
.text

start:
        jal	read_bmp
        li $s0, -1
        li $s1, 0
        li $s6, 0 # counter of points
    # ============================================================================
        
loop_x:
	
        add $s0, $s0, 1
        beq $s0, 319, loop_y

    # get pixel color
        la	$a0, ($s0)
        la	$a1, ($s1)
        jal get_pixel
            
        bne $v0, 0, loop_x
        beq $s1, 0, down
        beq $s0, 0, left
        j start_pixel_in
    # ============================================================================
loop_y:
        li $s0, -1
        add $s1, $s1, 1
        beq $s1, 239, exit
        j loop_x
    # ============================================================================
start_pixel_in:
	
	la $s2, ($s0)
	la $s3, ($s1)
	li $s4, 1
	li $s5, 1
    
	sub $s2, $s2, 1
	la $a0, ($s2)
	la $a1, ($s3)
	jal get_pixel
	beq $v0, 0, loop_x
	add $s2, $s2, 1
	j check_down_and_move_right
    # ============================================================================	    
check_down_and_move_right:
	
	sub $s3, $s3, 1
	la $a0, ($s2)
	la $a1, ($s3)
	jal get_pixel
    
	beq $v0, 0, loop_x
    
	add $s2, $s2, 1
	add $s3, $s3, 1
	beq $s2, 320, back_one_position_before_up
    
	la $a0, ($s2)
	la $a1, ($s3)
	jal get_pixel
    
	bne $v0, 0, back_one_position_before_up
	add $s4, $s4, 1
	j check_down_and_move_right
    # ============================================================================
back_one_position_before_up:
	
	sub $s2, $s2, 1
	j move_up
    # ============================================================================
move_up:
	add $s3, $s3, 1
	
    	beq $s3, 240, compare_length
	la $a0, ($s2)
	la $a1, ($s3)
	jal get_pixel
    
    	
    	
	bne $v0, 0, compare_length
    	add $s5, $s5, 1
	add $s2, $s2, 1
	beq $s2, 320, compare_length
	la $a0, ($s2)
	la $a1, ($s3)
	jal get_pixel
	beq $v0, 0, loop_x
	
	sub $s2, $s2, 1
	j move_up
    # ============================================================================   
left:
    #beq $s1, 0, left_check_down_and_right
	la $s2, ($s0)
	la $s3, ($s1)
	li $s4, 1
	li $s5, 1
	j check_down_and_move_right
    # ============================================================================  
down:

	la $s2, ($s0)
	la $s3, ($s1)
	li $s4, 1
	li $s5, 1
	beq $s2, 0, down_move_right
	sub $s2, $s2, 1
	la	$a0, ($s2)
	la	$a1, ($s3)
	jal get_pixel
	beq $v0, 0, loop_x
	add $s2, $s2, 1
	li $s4, 1
	li $s5, 1
	j down_move_right
    # ============================================================================	    
down_move_right:
	add $s2, $s2, 1
	la $a0, ($s2)
	la $a1, ($s3)
	jal get_pixel
	bne $v0, 0, back_one_position_before_up
	add $s4, $s4, 1
	beq $s2, 319, move_up
	j down_move_right
    # ============================================================================	    
compare_length:
	
	bne $s4, $s5, loop_x
	beq $s4, 1, loop_x
	li $s5, 0	# number of pixels above $s1
	la $s7, ($s4)
	j check_pixels_inside
    # ============================================================================	 
check_pixels_inside:
	la $s2, ($s0)
	la $s3, ($s1)
	add $s5, $s5, 1
	sub $s7, $s7, 1
	beq $s7, 1, one_pixel
	li $t9, 0
	
	beq $s7, 0, loop_x
	add $s3, $s3, $s5
	beq $s2, 0, check_pixels_inside_loop_right
	sub $s2, $s2, 1
	la $a0, ($s2)
	la $a1, ($s3)
	jal get_pixel
	beq $v0, 0, loop_x
	add $s2, $s2, 1
	j check_pixels_inside_loop_right
one_pixel:
	la $s2, ($s0)
	add $s3, $s1, $s5
	la $a0, ($s2)
	la $a1, ($s3)
	jal get_pixel
	
	bne $v0, 0, print_sign_point
	sub $s2, $s2, 1
	la $a0, ($s2)
	la $a1, ($s3)
	jal get_pixel
	beq $v0, 0, loop_x
	add $s2, $s2, 1
	add $s3, $s3, 1
	la $a0, ($s2)
	la $a1, ($s3)
	jal get_pixel
	beq $v0, 0, loop_x
	j print_sign_point
	
	
check_pixels_inside_loop_right:
	add $t9, $t9, 1
	la $a0, ($s2)
	la $a1, ($s3)
	jal get_pixel
	bne $v0, 0, last_floor
	beq $t9, $s7, check_pixels_inside_loop_up
	add $s2, $s2, 1
	j check_pixels_inside_loop_right
check_pixels_inside_loop_up:

	add $s3, $s3, 1
	sub $t9, $t9, 1
	la $a0, ($s2)
	la $a1, ($s3)
	jal get_pixel
	bne $v0, 0, loop_x
	beq $t9, 1, check_over
	j check_pixels_inside_loop_up
check_over:
	add $s3, $s3, 1
	la $a0, ($s2)
	la $a1, ($s3)
	jal get_pixel
	beq $v0, 0, loop_x
	j check_pixels_inside
last_floor:
	beq $s7, 1, one_pixel
	bgt $s2, $s0, loop_x
	j last_floor_continue
last_floor_continue:

	add $t9, $t9, 1
	la $a0, ($s2)
	la $a1, ($s3)
	jal get_pixel
	beq $v0, 0, loop_x
	add $s2, $s2, 1
	beq $t9, $s7, check_pixels_inside_loop_up_last_floor
	j last_floor_continue
check_pixels_inside_loop_up_last_floor:
	
	add $s3, $s3, 1
	sub $t9, $t9, 1
	la $a0, ($s2)
	la $a1, ($s3)
	jal get_pixel
	beq $v0, 0, loop_x
	beq $t9, 1, print_sign_point
	j check_pixels_inside_loop_up_last_floor
last_pixel:
	beq $s3, 239, print_sign_point
	add $s3, $s3, 1
	la $a0, ($s2)
	la $a1, ($s3)
	jal get_pixel
	beq $v0, 0, loop_x
	j print_sign_point

    # ============================================================================
print_sign_point:	    
	li $v0, 4
	la $a0, open
	syscall

	li $v0, 1
	add $s2, $s0, $s4
	sub $s2, $s2, 1
	la $a0, ($s2)
	syscall

	li $v0, 4
	la $a0, next
	syscall
	
	li $v0, 1
	li $s3, 239
	sub $s3, $s3, $s1
	la $a0, ($s3)
	syscall

	li $v0, 4
	la $a0, end
	syscall

	add $s6, $s6, 1
	beq $s6, 50, exit

	j loop_x      
    # ============================================================================
exit:	
        li 	$v0,10		#Terminate the program
        syscall

    # ============================================================================
read_bmp:
    #description: 
    #	reads the contents of a bmp file into memory
    #arguments:
    #	none
    #return value: none
        sub $sp, $sp, 4		#push $ra to the stack
        sw $ra,4($sp)
        sub $sp, $sp, 4		#push $s1
        sw $s1, 4($sp)
    #open file
        li $v0, 13
            la $a0, fname		#file name 
            li $a1, 0		#flags: 0-read file
            li $a2, 0		#mode: ignored
            syscall
        move $s1, $v0      # save the file descriptor
        
    #check for errors - if the file was opened
        blt $v0, 0, exit_error

    #read file
        li $v0, 14
        move $a0, $s1
        la $a1, image
        li $a2, BMP_FILE_SIZE
        syscall

    #close file
        li $v0, 16
        move $a0, $s1
            syscall
        
        lw $s1, 4($sp)		#restore (pop) $s1
        add $sp, $sp, 4
        lw $ra, 4($sp)		#restore (pop) $ra
        add $sp, $sp, 4
        jr $ra

    # ============================================================================
exit_error:
li $v0, 4
la $a0, error_opening
syscall

li $v0, 10
syscall
    # ============================================================================
get_pixel:
    #description: 
    #	returns color of specified pixel
    #arguments:
    #	$a0 - x coordinate
    #	$a1 - y coordinate - (0,0) - bottom left corner
    #return value:
    #	$v0 - 0RGB - pixel color

        sub $sp, $sp, 4		#push $ra to the stack
        sw $ra,4($sp)

        la $t1, image + 10	#adress of file offset to pixel array
        lw $t2, ($t1)		#file offset to pixel array in $t2
        la $t1, image		#adress of bitmap
        add $t2, $t1, $t2	#adress of pixel array in $t2
        
        #pixel address calculation
        mul $t1, $a1, BYTES_PER_ROW #t1= y*BYTES_PER_ROW
        move $t3, $a0		
        sll $a0, $a0, 1
        add $t3, $t3, $a0	#$t3= 3*x
        add $t1, $t1, $t3	#$t1 = 3x + y*BYTES_PER_ROW
        add $t2, $t2, $t1	#pixel address 
        
        #get color
        lbu $v0,($t2)		#load B
        lbu $t1,1($t2)		#load G
        sll $t1,$t1,8
        or $v0, $v0, $t1
        lbu $t1,2($t2)		#load R
            sll $t1,$t1,16
        or $v0, $v0, $t1
            
        lw $ra, 4($sp)		#restore (pop) $ra
        add $sp, $sp, 4
        jr $ra
