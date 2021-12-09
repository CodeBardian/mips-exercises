.data

char_digit:    .ascii   "5"
char_no_digit: .ascii   "R"
str_squeeze:   .asciiz  "Herea, ita shoulda nota bea possiblea toa seea thea lettera: 'a', aaarightaaa?"
table:         .word     1 -2 3 -4 5 -6 7 -8 9 -10 11 -12 13 -14
table_len:     .word     14


.text

##########################################
##  Aufgabe 5.3  #########################
##########################################
# int isdigit(int c)
# {
#       if (c >= '0' && c <= '9')
#               return 1;
#       else
#               return 0;
# }
##########################################

isdigit:
	li  $v0, 0
	blt $a0, '0', isdigit_end
	bgt $a0, '9', isdigit_end
	li  $v0, 1
isdigit_end:
	jr  $ra


##########################################
##  Aufgabe 5.4  #########################
##########################################
# void squeeze(char str[], char c)
# {
#       int i,j;
#       j = 0;
#       for (i=0; str[i]!= '\0'; i++) {
#               if (str[i] != c) {
#                       str[j] = str[i];
#                       j++;
#               }
#       }
#       str[j] = '\0';
# }
##########################################

squeeze:
	li  $t0, 0		# i = 0
	li  $t1, 0		# j = 0
sq_loop:
	add $t2, $a0, $t0	# t2* = &str + i
	lb  $t2, 0($t2)
	beq $t2, $zero, sq_end_loop
	
	beq $t2, $a1, sq_end_if
	add $t3, $a0, $t1	# t3* = &str + j
	sb  $t2, 0($t3)		# str[j] = str[i]
	addi $t1, $t1, 1	# j++

sq_end_if:
	addi $t0, $t0, 1	# i++
	j sq_loop

sq_end_loop:
	add $t3, $a0, $t1
	sb  $zero, 0($t3)
	jr  $ra


##########################################
##  Aufgabe 5.5  #########################
##########################################
# int count_negatives(int table [], int n)
# {
#       int count = 0;
#       int i;
#       for (i=0; i<n; i++) {
#               if( table[i] < 0) {
#                       count ++;
#               }
#       }
#       return count;
# }
##########################################

count_negatives:
	li  $v0, 0			# count = 0
	li  $t0, 0 			# i=0
	
cn_loop:
	bge $t0, $a1, cn_end_loop	# i >= n
	
	sll $t1, $t0, 2
	add $t1, $a0, $t1
	lw  $t1, 0($t1)
	bge $t1, $zero, cn_end_if       # table[i] >= 0
	addi $v0, $v0, 1		# count++

cn_end_if:
	addi $t0, $t0, 1		# i++
	j cn_loop
	
cn_end_loop:
	jr  $ra


##########################################
##  Aufgabe 5.6  #########################
##########################################
# run-length encoding
# int rle(char *str_in, char *buf_out)
# 
# for implementation see Aufgabenblatt 5
##########################################

.data

str_test_input: .asciiz "BBBBZZABB111"

.text

rle:
	li $v0, 0			# clear output
	li $t1, 0			# i = 0, used to loop over characters in str_in
	li $t3, 0			# count = 0
	add $t4, $a1, 0			# &buf_out, used to address buf_out positions
	add $t0, $a0, $t1		# t0 = &str_in + 0
	lb  $t2, 0($t0)			# keep str_in[0] in $t2
	
rle_loop:
	add $t0, $a0, $t1		# t0 = &str_in + i
	lb  $t0, 0($t0)			# store str_in[i] in $t0
	beq $t0, $t2, rle_same_char	# if previous read char is the same as current
	sb  $t2, 0($t4)			# store character
	sb  $t3, 1($t4)			# store count 
	addi $v0, $v0, 1		# increase number of written byte pairs
	beq $t0, 0, rle_end_loop	# if end of str_in is reached 
	add $t4, $t4, 2			# &buf_out + 2
	li  $t3, 0			# reset char count to 0
	
rle_same_char:
	addi $t1, $t1, 1		# i++
	add  $t2, $t0, 0		# keep current char for next iteration
	addi $t3, $t3, 1		# count++
	j rle_loop

rle_end_loop:
	jr  $ra


##########################################
##  Main  ################################
##########################################
.data
str_cmd_start:    .asciiz  "<<start assignment>>\n"
str_cmd_53:       .asciiz  "\nisdigit(\""
str_cmd_53_true:  .asciiz  "\") returned true"
str_cmd_53_false: .asciiz  "\") returned false"
str_cmd_54:       .asciiz  "\n\nchanged value after squeeze:\n"
str_cmd_55:       .asciiz  "\n\nreturn value of count_numbers: "
str_cmd_end:      .asciiz  "\n\n<<end assignment>>\n\n\n"

str_cmd_56:       .asciiz  "(*)assignment 5.6: RLE\n"
str_input:        .asciiz  "input: "
str_return_value: .asciiz  "\nreturn value: "
str_output:       .asciiz  "\noutput data:"

rle_compressed_output_buf: .space 100

.text

.eqv SYS_PUTSTR 4
.eqv SYS_PUTCHAR 11
.eqv SYS_PUTINT 1
.eqv SYS_EXIT 10

.globl main
main:
	li   $v0, SYS_PUTSTR
	la   $a0, str_cmd_start
	syscall
	la   $a0, str_cmd_53
	syscall

##########################################
#### put here input value for isdigit ####
	la   $a0, char_no_digit
	lb   $a0, 0($a0)
##########################################

	li   $v0, SYS_PUTCHAR
	syscall
	jal  isdigit

	beqz $v0, main_cmd_53_false
	la   $a0, str_cmd_53_true
	j    main_cmd_53

main_cmd_53_false:
	la   $a0, str_cmd_53_false
main_cmd_53:
	li   $v0, SYS_PUTSTR
	syscall

	la   $a0, str_cmd_54
	li   $v0, SYS_PUTSTR
	syscall

##########################################
#### put here input values for squeeze ###
	la   $a0, str_squeeze
	li   $a1, 'a'
##########################################
	jal  squeeze

	la   $a0, str_squeeze
	li   $v0, SYS_PUTSTR
	syscall

	la   $a0, str_cmd_55
	li   $v0, SYS_PUTSTR
	syscall

	la   $a0, table
	la   $a1, table_len
	lw   $a1, 0($a1)
	jal  count_negatives

	move $a0, $v0
	li   $v0, SYS_PUTINT
	syscall

	la   $a0, str_cmd_end
	li   $v0, SYS_PUTSTR
	syscall

##########################################
##  rle test loop ########################
##########################################
	# Eingabezeichenfolge anzeigen:
	la   $a0, str_cmd_56
	syscall
	la $a0, str_input
	syscall
	la $a0, str_test_input
	syscall
	
	# Aufruf der zu testenden Funktion rle:
	la $a0, str_test_input
	la $a1, rle_compressed_output_buf
	jal rle

	# Rueckgabewert anzeigen:
	move $t0, $v0
	la $a0, str_return_value
	li $v0, SYS_PUTSTR
	syscall
	li $v0, SYS_PUTINT
	move $a0, $t0
	syscall

	# Ausgabedaten anzeigen:
	li $v0, SYS_PUTSTR
	la $a0, str_output
	syscall
	
	la $t0, rle_compressed_output_buf
_main_output_loop:
	lb $t1, 0($t0)
	lb $t2, 1($t0)
	or $t3, $t1, $t2
	beqz $t3, _main_output_endloop
	
	li $v0, SYS_PUTCHAR
	li $a0, ' '
	syscall	
	li $a0, '('
	syscall
	li $a0, '\''
	syscall
	move $a0, $t1
	syscall
	li $a0, '\''
	syscall
	li $a0, ','
	syscall
	
	li $v0, SYS_PUTINT
	move $a0, $t2
	syscall
	
	li $v0, SYS_PUTCHAR
	li $a0, ')'
	syscall	
	
	addi $t0, $t0, 2
	j _main_output_loop

_main_output_endloop:
	li $v0, SYS_EXIT
	syscall
