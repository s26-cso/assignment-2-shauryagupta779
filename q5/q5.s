.section .rodata
input_name: .string "input.txt"
yes_msg: .string "Yes\n"
no_msg: .string "No\n"

.text
.globl main
.type main, @function
main:
    addi sp, sp, -64
    sd ra, 56(sp)
    sd s0, 48(sp)
    sd s1, 40(sp)
    sd s2, 32(sp)
    sd s3, 24(sp)
    sd s4, 16(sp)
    
    la a0, input_name
    li a1, 0
    call open
    mv s0, a0
    bltz s0, .print_no
    
    mv a0, s0
    li a1, 0
    li a2, 2
    call lseek
    mv s1, a0
    bltz s1, .close_no
    blez s1, .print_no_close
    
    li a0, 0
    mv a1, s1
    li a2, 1
    li a3, 2
    mv a4, s0
    li a5, 0
    call mmap
    li a1, -1
    beq a0, a1, .close_no
    
    mv s2, a0
    li s3, 0
    addi s4, s1, -1
    
.cmp_loop:
    bge s3, s4, .pal_yes
    add a0, s2, s3
    lbu a0, 0(a0)
    add a1, s2, s4
    lbu a1, 0(a1)
    bne a0, a1, .pal_no
    addi s3, s3, 1
    addi s4, s4, -1
    j .cmp_loop
    
.print_no:
    la a0, no_msg
    call printf
    li a0, 0
    call exit

.pal_yes:
    mv a0, s2
    mv a1, s1
    call munmap
    mv a0, s0
    call close
    la a0, yes_msg
    call printf
    li a0, 0
    call exit
    
.pal_no:
    mv a0, s2
    mv a1, s1
    call munmap
    
.close_no:
    mv a0, s0
    call close
    
.print_no_close:
    la a0, no_msg
    call printf
    li a0, 0
    call exit

.section .note.GNU-stack,"",@progbits
