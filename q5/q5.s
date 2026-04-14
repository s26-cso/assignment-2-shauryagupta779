.section .rodata
input_name:
	.string "input.txt"
yes_msg:
	.string "Yes\n"
no_msg:
	.string "No\n"

.text
.globl main
.type main, @function
main:
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15

	leaq input_name(%rip), %rdi
	xorl %esi, %esi
	call open@PLT
	movl %eax, %ebx
	testl %ebx, %ebx
	js .print_no

	movl %ebx, %edi
	xorl %esi, %esi
	movl $2, %edx
	call lseek@PLT
	testq %rax, %rax
	js .cleanup_fd_no

	movq %rax, %r12
	cmpq $1, %r12
	jle .print_yes_close

	xorl %edi, %edi
	movq %r12, %rsi
	movl $1, %edx
	movl $2, %ecx
	movl %ebx, %r8d
	xorl %r9d, %r9d
	call mmap@PLT
	cmpq $-1, %rax
	je .cleanup_fd_no

	movq %rax, %r13
	xorl %r14d, %r14d
	movq %r12, %r15
	decq %r15

.trim_trailing:
	cmpq $0, %r15
	jl .pal_yes_unmap

	movzbl (%r13,%r15,1), %eax
	cmpb $10, %al
	je .trim_dec
	cmpb $13, %al
	je .trim_dec
	jmp .cmp_loop

.trim_dec:
	decq %r15
	jmp .trim_trailing

.cmp_loop:
	cmpq %r15, %r14
	jge .pal_yes_unmap

	movzbl (%r13,%r14,1), %eax
	movzbl (%r13,%r15,1), %edx
	cmpb %dl, %al
	jne .pal_no_unmap

	incq %r14
	decq %r15
	jmp .cmp_loop

.pal_yes_unmap:
	movq %r13, %rdi
	movq %r12, %rsi
	call munmap@PLT
	jmp .print_yes_close

.pal_no_unmap:
	movq %r13, %rdi
	movq %r12, %rsi
	call munmap@PLT
	jmp .cleanup_fd_no

.print_yes_close:
	movl $1, %edi
	leaq yes_msg(%rip), %rsi
	movl $4, %edx
	call write@PLT
	movl %ebx, %edi
	call close@PLT
	xorl %edi, %edi
	call exit@PLT
	xorl %eax, %eax
	jmp .done

.cleanup_fd_no:
	movl %ebx, %edi
	call close@PLT
	jmp .print_no

.print_no:
	movl $1, %edi
	leaq no_msg(%rip), %rsi
	movl $3, %edx
	call write@PLT
	xorl %edi, %edi
	call exit@PLT
	xorl %eax, %eax

.done:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	ret

.section .note.GNU-stack,"",@progbits
