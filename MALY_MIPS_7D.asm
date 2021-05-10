.data
	input: .space 256
	information_1: .asciiz "Input string      > "
	information_2: .asciiz "Conversion results> "
	input_copy: .space 256
	flag1: .space 256
	flag2: .space 256
.text
	#wczytanie stringa z klawiatury
	main:
		li $v0, 4
		la $a0, information_1
		syscall
		
		li $v0, 8
		la $a0, input
		la $a1, 256
		syscall
		
		la $t0, input
		la $t2, input_copy
	# zapisanie do flag1, 1 flagi
	first_sign:
		lbu $t1, ($t0)
		blt $t1, ' ', exit
		sb $t1, flag1
		sb $t1, ($t2)
		add $t0, $t0, 1
		add $t2, $t2, 1
		la $s1, flag1
		lbu $s3, ($s1)
	#zapisanie do flag2, 2 flagi
	second_sign:
		lbu $t1, ($t0)
		blt $t1, ' ', exit
		sb $t1, flag2
		sb $t1, ($t2)
		add $t0, $t0, 1
		add $t2, $t2, 1
		la $s2, flag2 
		lbu $s4, ($s2)
	
	third_sign:
		lbu $t1, ($t0)
		blt $t1, ' ', exit
		sb $t1, ($t2)
		add $t0, $t0, 1
		add $t2, $t2, 1
	#petla dopoki nie wystapi flaga, badz bedzie koniec stringa
	noflag_loop:
		lbu $t1, ($t0)
		blt $t1, ' ', exit
		beq $t1, $s3, end_copy_flag1
		beq $t1, $s4, end_copy_flag2
		sb $t1, ($t2)
		li $t1, '*'
		sb $t1, ($t0)
		add $t0, $t0, 1
		add $t2, $t2, 1
		j noflag_loop
	# przejscie do petli po wystapieniu flagi1
	end_copy_flag1:
		sb $t1, ($t0)
		add $t0, $t0, 1
		lbu $t1, ($t0)
		blt $t1, ' ', flag1_backward
		beq $t1, $s4, flag1_flag2
		j end_copy_flag1
	# przejscie do petli po wystapieniu flagi2
	end_copy_flag2:
		li $t1, '*'
		sb $t1, ($t0)
		add $t0, $t0, 1
		lbu $t1, ($t0)
		blt $t1, ' ', exit_new
		beq $t1, $s3, end_copy_flag1
		j end_copy_flag2
	# przejscie do petli po wystapieniu flagi1 i flagi2
	flag1_flag2:
		add $t0, $t0, 1
		lbu $t1, ($t0)
		blt $t1, ' ', two_flags_backward
		j flag1_flag2
	# po 2 flagach i dojsciu na koniec stringa wracamy i szukamy ostatniej flagi koncowej
	two_flags_backward:
		add $t0, $t0, -1
		lbu $t1, ($t0)
		beq $t1, $s4, flag1_backward
		li $t1, '*'
		sb $t1, ($t0)
		j two_flags_backward
	# sytuacja gdy tylko 1 flaga wystapila w ciagu
	flag1_backward:
		add $t0, $t0, -1
		lbu $t1, ($t0)
		beq $t1, $s3, other_sign
		j flag1_backward
	# zastapienie pozostalych charow '*'
	other_sign:
		add $t0, $t0, -1
		lbu $t1, ($t0)
		blt $t1, ' ', three_chars_space
		li $t1, '*'
		sb $t1, ($t0)
		j other_sign
	# trzy pierwsze znaki zamieniamy na spacje
	three_chars_space:
		add $t0, $t0, 1
		li $t1, ' '
		sb $t1, ($t0)
		add $t0, $t0, 1
		li $t1, ' '
		sb $t1, ($t0)
		add $t0, $t0, 1
		li $t1, ' '
		sb $t1, ($t0)
		j exit_new
	#exit dla niezmienionego stringa
	exit:
		li $v0, 4
		la $a0, information_1
		syscall
		
		li $v0, 4
		la $a0, input_copy
		syscall
		
		li $v0, 10
		syscall
	#exit gdy string ulegl modyfikacji
	exit_new:
		li $v0, 4
		la $a0, information_2
		syscall
		
		li $v0, 4
		la $a0, input
		syscall
		
		li $v0, 10
		syscall
