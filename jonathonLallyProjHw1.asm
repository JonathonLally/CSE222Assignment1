# Homework 1
#name: Jonathon_Lally
#sccid: 00748854

.data
.align 2
arg1: .word 0
arg2: .word 0
error: .asciiz "Incorrect argument provided.\n"
sm: .asciiz "Signed Magnitude: "
one: .asciiz "One's Complement: "
gray: .asciiz "Gray Code: "
dbl: .asciiz "Double Dabble: "
msg1: .asciiz "You entered "
msg2: .asciiz " which parsed to "
msg3: .asciiz "In hex it looks like "
space: .asciiz "\n"

.macro load_args		#Macro to load ARGS
	lw $t0,0($a1)
	sw $t0, arg1
	lw $t0,4($a1)
	sw $t0, arg2
.end_macro
.text
main:
	load_args()		#Loading Args
	li $t3, 0 		#t3 is the sum which is initially zero
	li $t4, 0		#t4 isNegative where 0 is false and currently false				
	lw $t0, arg1		#t0 = string arg1 t1 = char t3 = sum t4 = isNegative
	
	lw $s0, arg2		#load arg2 into s0
	beq $s0, 49, get_sign		#if so = 1 then one_comp THIS IS SPAGETTI TO SKIP PARSING
	beq $s0, 115, get_sign		#if s0 = s then sign_mag BECAUSE OF SCRIPT GRADING
	beq $s0, 103, get_sign		#if s0 = g then gray_code
	beq $s0, 100, get_sign		#if s0 = d then double_dabble
	j second_arg
	
get_sign:
	lb $t1, ($t0)		#load first byte to T1
	beq $t1, '-', negative	#if t1 = - NEGATIVE
	j loop			#if not negative jump to loop

negative:
	addu $t0, $t0, 1	#Skip first char because it is negative sign
	lb $t1, ($t0)		#load next char, skip neg
	li $t4, 1		#Sets isNegative to 1 (true)
	
loop:	
	beq $t1, 10, exit_loop	#Exit loop if char is 10
	blt $t1, '0', exit_loop #Exit loop is char is less then 0
	bgt $t1, '9', exit_loop	#Exit loop if char is greater then 9
	mul $t3, $t3, 10	#Multiple sum by 10
	sub $t1, $t1, '0'	#Subtract '0' from char
	add $t3, $t3, $t1	#Add byte to sum
	addu $t0, $t0, 1	#Increment loop
	lb $t1, ($t0)		#load next byte
	b loop			#loop
	
exit_loop:
	beq $t4, 1, is_negative 	#if t4 isNegative =1 then is_negative
	j print				#jump to print if positive
	
is_negative:
	li $t6 0		#t6 = 0 setup for subtraction
	sub $t3, $t6, $t3	#t4 = 0 - sum because negative
	
print:
	la $a0, msg1		#Print msg1
	li $v0, 4
	syscall
	lw $a0, arg1		#Print arg1
	li $v0, 4
	syscall
	la $a0, msg2		#Print msg2
	li $v0, 4
	syscall
	la $a0, ($t3)		#Print parsed value
	li $v0, 1
	syscall
	la $a0, space		#Print newline
	li $v0, 4
	syscall
	la $a0, msg3		#Print msg3
	li $v0, 4
	syscall
	la $a0, ($t3)		#Print value as HEX
	li $v0, 34
	syscall
	la $a0, space		#Print newline
	li $v0, 4
	syscall
	
second_arg:			#Start of part 2
	lw $s0, arg2		#load arg2 to s0
	lbu $s0, ($s0)		#load byte(flag) from arg2
	beq $s0, 49, one_comp	#if so = 1 then one_comp
	beq $s0, 115, sign_mag	#if s0 = s then sign_mag
	beq $s0, 103, gray_code	#if s0 = g then gray_code
	beq $s0, 100, double_dabble	#if s0 = d then double_dabble
	
	#If This is reached then we have an error

	la $a0, error		#Prints error message
	li $v0, 4
	syscall
	j exit			#Exit

one_comp:				#One's Comp
	xori $t3, $t3, 0xFFFFFFFF	#Use Bitwise execlusive or Immediate to flip signs
	la $a0, one			#Print one's comp message
	li $v0, 4
	syscall
	la $a0, ($t3)			#Print one_comp value in HEX
	li $v0, 34
	syscall
	j exit

sign_mag:			#Sign Magnitutde
	abs $t3, $t3		#Get Absolute value of parsed value
	bnez $t4, neg_sign_mag	#If parsedvalue is negative neg_sign_mag instead
	la $a0, sm		#Print sign_mag message
	li $v0, 4
	syscall
	la $a0, ($t3)		#Print sign_mag in hex
	li $v0, 34
	syscall
	j exit
	
neg_sign_mag:
	xori $t3, $t3, 0x80000000	#Flips the first bit because negative
	la $a0, sm			#Prints sign_mag message
	li $v0, 4
	syscall
	la $a0, ($t3)			#Prints sign_mag in hex
	li $v0, 34
	syscall
	j exit	

gray_code:			#Gray Code
	li $t1, 0		#load 0 into t1
	srl $t1, $t3, 1		#Shift right logical t3 by 1
	xor $t3, $t3, $t1	#Bitwise exclusive or t3, t1	
	la $a0, gray		#Print graycode message
	li $v0, 4
	syscall
	la $a0, ($t3)		#Print gray_code
	li $v0, 34
	syscall
	j exit			#Jump to exit

double_dabble:			#Start of double_dabble
	move $s1, $t3		#v = 0x00000013 S1
	li $s2, 0x00000000	#r = 0x00000000 S2
	li $s3, 0		#k = 0		S3 12??
	li $s4, 0		#msb = 0 (false)S4	
	bnez $t4, to_positive	#if parsed value is negative, convert to positive
	j outer_loop		#start outer_loop
	
to_positive:
	abs $t3, $t3		#Absolute value
	
outer_loop:				#Double_dabble outerloop
	bgt $s3, 32, exit_outerloop	#Branch if s1 = 0 to exit_outerloop
	li $s4, 0			#s4 (msb) = false
		# If the msb of V is set the value will be negative
	blt $s1, 0, msb_true		#if s1 (v) < 0 branch
	j skip_1
	msb_true:
		li $s4, 1		#set s4 (msb) true (1)	
	skip_1:
	sll $s1, $s1, 1			#shift left logical s1(v) by 1
	sll $s2, $s2, 1			#shift left logical s2(r) by 1
	bnez $s4, msb_add		#if s4(msb) isn't zero then msb_add
	j skip_2
	msb_add:
		addu $s2, $s2, 1	#s2 (r)++
	skip_2:
	
	#Inner Loop
	blt $s3, 31, check_r		#branch if s3(k) < 31
	j skip_3
	check_r:
		bnez $s2, nibble	#if s2(r) != 0 branch nibble
		j skip_3
		nibble:
			li $s5, 0x00000000	#mask = 0000000000 S5
			li $s6, 0x40000000	#cmp = 4000000000 S6
			li $s7, 0x30000000	#add = 3000000000 S7
			li $t8, 0		#i = 0 S8
			blt $t8, 8, nibble_for	#for t8(i) < 8 then nibble_for  
			addu $t8, $t8, 1	#Increment t8(i)++
			b nibble		#loop
			nibble_for:
				#li $t9, 0			#mv = - S9
				and $t9, $s5, $s2		#t9(mv) = s5(mask) & s2(r)
				bgt $t9, $s6, inner_nibble	#if t9(mv) > s6(cmp) branch inner_nibble
				j skip_in1
				inner_nibble:
					add $s2, $s2, $s7		#s2(r) = s2(r) + s7(add)
				skip_in1:
				srl $s5, $s5, 4		#Shift right logical s5(mask) by 4
				srl $s6, $s6, 4		#Shift right logical s6(cmp) by 4
				srl $s7, $s7, 4		#Shift right logical s7(add) by 4
	
	skip_3:
	add $s3, $s3, 1			#Increment loop s3 (k)++
	b outer_loop			#loop
	
exit_outerloop:	
	la $a0, dbl		#Print double_dabble message
	li $v0, 4
	syscall
	la $a0, ($s1)		#Print double_dabble(maybe)
	li $v0, 34
	syscall
	j exit			#Jump to exit
	

exit:				#Exit
