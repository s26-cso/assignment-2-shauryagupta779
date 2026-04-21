.section .rodata
fmt_first:
    .string "%d"
fmt_next:
    .string " %d"

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

    mv s1, a1
    addiw s0, a0, -1

    blez s0, .print_newline_only

    slli a0, s0, 2
    call malloc
    mv s2, a0
    beqz s2, .main_err

    slli a0, s0, 2
    call malloc
    mv s3, a0
    beqz s3, .free_arr_err

    slli a0, s0, 2
    call malloc
    mv s4, a0
    beqz s4, .free_res_arr_err

    li s6, 0
.parse_loop:
    bge s6, s0, .compute_nge
    addi t0, s6, 1
    slli t0, t0, 3
    add t0, s1, t0
    ld a0, 0(t0)
    call atoi

    slli t1, s6, 2
    add t2, s2, t1
    sw a0, 0(t2)
    add t2, s3, t1
    li t3, -1
    sw t3, 0(t2)

    addi s6, s6, 1
    j .parse_loop

.compute_nge:
    li s5, -1
    addi s6, s0, -1

.outer_loop:
    blt s6, x0, .print_result

.pop_loop:
    blt s5, x0, .after_pop
    slli t0, s5, 2
    add t0, s4, t0
    lw t1, 0(t0)

    slli t2, t1, 2
    add t2, s2, t2
    lw t3, 0(t2)

    slli t4, s6, 2
    add t4, s2, t4
    lw t5, 0(t4)

    ble t3, t5, .do_pop
    j .after_pop

.do_pop:
    addi s5, s5, -1
    j .pop_loop

.after_pop:
    blt s5, x0, .push_current
    slli t0, s5, 2
    add t0, s4, t0
    lw t1, 0(t0)
    slli t2, s6, 2
    add t2, s3, t2
    sw t1, 0(t2)

.push_current:
    addi s5, s5, 1
    slli t0, s5, 2
    add t0, s4, t0
    sw s6, 0(t0)

    addi s6, s6, -1
    j .outer_loop

.print_result:
    li s6, 0

.print_loop:
    bge s6, s0, .print_done
    slli t0, s6, 2
    add t0, s3, t0
    lw a1, 0(t0)

    beq s6, x0, .print_first
    la a0, fmt_next
    call printf
    j .print_advance

.print_first:
    la a0, fmt_first
    call printf

.print_advance:
    addi s6, s6, 1
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

.print_newline_only:
    li a0, 10
    call putchar
    li a0, 0
    j .main_done

.free_res_arr_err:
    mv a0, s3
    call free

.free_arr_err:
    mv a0, s2
    call free

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

.section .note.GNU-stack,"",@progbits
