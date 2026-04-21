.text
.globl main
.type main, @function
main:
    addi sp, sp, -80
    sd ra, 72(sp)
    sd s0, 64(sp)
    sd s1, 56(sp)
    sd s2, 48(sp)
    sd s3, 40(sp)
    sd s4, 32(sp)
    sd s5, 24(sp)
    sd s6, 16(sp)
    
    # a0 = argc, a1 = argv
    mv s0, a0
    mv s1, a1
    addi s0, s0, -1
    
    bgt s0, x0, .alloc_arrays
    li a0, 10
    call putchar
    li a0, 0
    j .main_done
    
.alloc_arrays:
    slli a0, s0, 2
    sd a0, 0(sp)
    call malloc
    mv s2, a0
    beq s2, x0, .main_err
    
    ld a0, 0(sp)
    call malloc
    mv s3, a0
    beq s3, x0, .main_err
    
    ld a0, 0(sp)
    call malloc
    mv s4, a0
    beq s4, x0, .main_err
    
.parse_loop:
    li s5, 0
    
.parse_loop_iter:
    bge s5, s0, .compute_nge
    li a0, 1
    add a0, a0, s5
    slli a0, a0, 3
    add a0, a1, a0
    ld a0, 0(a0)
    call atoi
    
    slli a1, s5, 2
    add a2, s2, a1
    sw a0, 0(a2)
    li a0, -1
    add a2, s3, a1
    sw a0, 0(a2)
    
    addi s5, s5, 1
    j .parse_loop_iter
    
.compute_nge:
    li s5, -1
    addi a0, s0, -1
    
.nge_loop:
    bltz a0, .print_result
    
.nge_pop:
    blez s5, .nge_push
    slli a1, s5, 2
    add a2, s4, a1
    lw a1, 0(a2)
    slli a2, a1, 2
    add a3, s2, a2
    lw a1, 0(a3)
    slli a2, a0, 2
    add a3, s2, a2
    lw a2, 0(a3)
    bgt a1, a2, .nge_push
    addi s5, s5, -1
    j .nge_pop
    
.nge_push:
    slli a1, a0, 2
    blez s5, .nge_store
    slli a2, s5, 2
    add a3, s4, a2
    lw a2, 0(a3)
    add a3, s3, a1
    sw a2, 0(a3)
    
.nge_store:
    addi s5, s5, 1
    slli a1, s5, 2
    add a2, s4, a1
    sw a0, 0(a2)
    
    addi a0, a0, -1
    j .nge_loop
    
.print_result:
    li s5, 0
    
.print_loop:
    bge s5, s0, .print_done
    slli a0, s5, 2
    add a1, s3, a0
    lw a1, 0(a1)
    beq s5, x0, .print_first
    li a0, ' '
    call putchar
    
.print_first:
    mv a0, a1
    call print_int
    addi s5, s5, 1
    j .print_loop
    
.print_done:
    li a0, 10
    call putchar
    
    mv a0, s4
    call free
    mv a0, s3
    call free
    mv a0, s2
    call free
    
    li a0, 0
    j .main_done
    
.main_err:
    li a0, 1
    
.main_done:
    ld s6, 16(sp)
    ld s5, 24(sp)
    ld s4, 32(sp)
    ld s3, 40(sp)
    ld s2, 48(sp)
    ld s1, 56(sp)
    ld s0, 64(sp)
    ld ra, 72(sp)
    addi sp, sp, 80
    ret

.globl print_int
.type print_int, @function
print_int:
    addi sp, sp, -16
    sd ra, 8(sp)
    
    mv a1, a0
    li a0, 10
    call printf
    
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

.section .note.GNU-stack,"",@progbits
