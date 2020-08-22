################# Data segment #####################
.data
buff:      .space 32
reverse_string: .space 32

msg:	 .asciiz "the biggest continuity:"
msg1:	 .asciiz "The number of occurrences of the char in the string is: "
msg2:	 .asciiz "Please enter a char to look for in the string: "
msg4:	 .asciiz "The number of occurrences of the char in the string is: "
msg5:	 .asciiz "The string after reduction in reverse is: "
endLine:	 .asciiz "\n"
################# Code segment #########################
.text	
.globl main
main:
# question 1:
li	 $v0,8
la	 $a0,buff
li	 $a1,33
syscall
jal	 count_abc

# question2:
li $v0, 4
la	 $a0,endLine # "/n"
syscall 
li	 $v0,4
la	 $a0,msg2
syscall
li	 $v0,12
syscall
la	 $a0,buff
jal	 count_char

#question3:
la	 $a0,buff
jal	 input_number
la	 $a0, buff
jal	 delete

# question4:
la	 $a0,buff
li	 $v0,4
la	 $a0,msg5
syscall
la	 $a0,buff
jal	 str_len # help function
jal	 reverse
li	 $v0,4
la	 $a0, reverse_string
syscall

exit:
li	 $v0,10
syscall	

############## functions ####################

####### q1 #######
count_abc:
li	 $t0,1 # counter continuity, one char count as continuity
li	 $t4,0 # counter string

loop:
lb	 $t2,0($a0) # load charAt(i) in string.
addi	 $a0,$a0,1 # adress buff +1 : string from user
lb	 $t3,0($a0) # load charAt(i+1) in string
beq	 $t3,0xA, get_out # end of the string. 0xA= new line
bgt	 $t3,0x7A,check_length # not in limit stop count
ble	 $t2,0x60,check_length # not in limit stop count
addi 	 $t2,$t2,1 # add +1 for check if t2 is bigger only by 1
bne	 $t2,$t3,check_length # if t2 and t3 not equals go check_length
addi	 $t0,$t0,1 # counter continuity +1
beq	 $t0,26, get_out # Maximum continuity
beq	 $t4,32, get_out # Maximum String
j	 loop

check_length: 
bgt	 $t0,$t1, move_to
j	 count_abc

move_to: #backup the size and start again the process of check the continuity
move	 $t1,$t0
beq	 $t3,0xA, get_out
beq	 $t0,26, get_out # Maximum continuity
beq	 $t4,32, get_out # Maximum String
j count_abc

get_out:
bgt	 $t0,$t1,move_to
li	 $v0,4
la	 $a0,msg
syscall
li	 $v0,1
add	 $a0,$t1,$0
syscall 
jr	 $ra

####### q2 #######
count_char:
li	 $t0,0 # counter char
move	 $t1,$v0

loop2:
lb	 $t2,0($a0) # load charAt(i) in string.
addi	 $a0,$a0,1 # adress buff +1 : string from user
beq	 $t1,$t2, counter2
beq	 $t2,0xA,out
j	 loop2

counter2:
addi	 $t0,$t0,1
j	 loop2

out:
li	 $v0, 4
la	 $a0,msg4
syscall 
li	 $v0,1
add	 $a0,$t0,$0
syscall
jr	 $ra

####### q3 #######
input_number:
li	 $s0,1 # Min limit 
li	 $s1,9 # Max limit
li	 $v0,5
syscall
sgt	 $a2,$v0,$s1 # if input greater then 9, a2=1, else a2=0
beq	 $a2,$s0,input_number
slt	 $a2,$v0,$s0
beq	 $a2,$s0,input_number
move	 $a1,$v0
jr	 $ra

delete:
li	 $s0, 0x20 # $t0 = space
add	 $a0,$a0,$a1 # go to X for the next loaction in string.
lb	 $t1,0($a0)
beq	 $t1,0xA,all_deleted
beqz	 $t1,all_deleted
sb	 $s0,0($a0)
j delete

all_deleted:
la	 $a0, buff # load the string with speces
loop3:
lb	 $t1,0($a0) # load first char in string
li	 $t2,0 #counter spaces
compare:
beq	 $t1,0xA,insert_back_space
beq	 $t1,$s0, count_space

save:
sub	 $t4,$a0,$t2
sb	 $t1, ($t4)
j	 step

count_space:
addi	 $t2,$t2,1 # add to counter spaces +1

step:
addi	 $a0,$a0,1 # next char
lb	 $t1,0($a0) # load next char
j compare

insert_back_space:
sub	 $t4,$a0,$t2 # sub from the adress and the counter spaces
sb	 $t1, ($t4)
addi	 $t2,$t2,-1
insert_zero:
sub	 $t4,$a0,$t2
sb	 $0, ($t4)
addi	 $t2,$t2,-1
bne	 $t4,$a0,insert_zero
no_spaces:
jr	 $ra

####### q4 #######
str_len:
li	$t0, 0 # counter len string
li	$t2, 0
strlen_loop:
add	$t2, $a0, $t0
lb	$t1, 0($t2)
beqz	$t1, strlen_exit
addiu	$t0, $t0, 1
j	strlen_loop	
strlen_exit:
subi	$t0, $t0, 2
add	$v0, $0, $t0
add	$t0, $0, $0
jr	$ra

reverse:
li	$t0, 0			# reset the register
li	$t3, 0			# and the same for t3
	
reverse_loop:
	add	$t3, $a0, $t0		# $a0 is the base address for our 'buff' array, add loop index
	lb	$t4, 0($t3)		# load a byte(char) at a time according to counter
	beqz	$t4, finish_reverse	# when we get the "\n" in string
	addi	$t0, $t0, 1		# Advance our counter (i++)
	lb	$t4,0($t3)
	sb	$t4, reverse_string($v0)
	addi	$v0, $v0,-1		# sub our overall string length by 1 (j--)
	j	reverse_loop		# Loop
	
finish_reverse:
jr	 $ra
