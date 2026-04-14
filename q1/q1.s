.text

.globl make_node
.type make_node, @function
make_node:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx

	movl %edi, %ebx
	movl $24, %edi
	call malloc@PLT

	testq %rax, %rax
	je .make_node_done

	movl %ebx, (%rax)
	movq $0, 8(%rax)
	movq $0, 16(%rax)

.make_node_done:
	popq %rbx
	popq %rbp
	ret

.globl insert
.type insert, @function
insert:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13

	movq %rdi, %rbx
	movl %esi, %r12d

	testq %rbx, %rbx
	jne .insert_loop_setup

	movl %r12d, %edi
	call make_node
	jmp .insert_done

.insert_loop_setup:
	movq %rbx, %r13

.insert_loop:
	movl (%r13), %eax
	cmpl %eax, %r12d
	jl .insert_go_left
	jg .insert_go_right
	movq %rbx, %rax
	jmp .insert_done

.insert_go_left:
	movq 8(%r13), %rdx
	testq %rdx, %rdx
	jne .insert_descend_left

	movl %r12d, %edi
	call make_node
	movq %rax, 8(%r13)
	movq %rbx, %rax
	jmp .insert_done

.insert_descend_left:
	movq %rdx, %r13
	jmp .insert_loop

.insert_go_right:
	movq 16(%r13), %rdx
	testq %rdx, %rdx
	jne .insert_descend_right

	movl %r12d, %edi
	call make_node
	movq %rax, 16(%r13)
	movq %rbx, %rax
	jmp .insert_done

.insert_descend_right:
	movq %rdx, %r13
	jmp .insert_loop

.insert_done:
	popq %r13
	popq %r12
	popq %rbx
	popq %rbp
	ret

.globl get
.type get, @function
get:
	pushq %rbp
	movq %rsp, %rbp

	movq %rdi, %rax

.get_loop:
	testq %rax, %rax
	je .get_done

	movl (%rax), %edx
	cmpl %edx, %esi
	jl .get_left
	jg .get_right
	jmp .get_done

.get_left:
	movq 8(%rax), %rax
	jmp .get_loop

.get_right:
	movq 16(%rax), %rax
	jmp .get_loop

.get_done:
	popq %rbp
	ret

.globl getAtMost
.type getAtMost, @function
getAtMost:
	pushq %rbp
	movq %rsp, %rbp

	movq %rsi, %rdx
	movl $-1, %eax

.get_at_most_loop:
	testq %rdx, %rdx
	je .get_at_most_done

	movl (%rdx), %ecx
	cmpl %edi, %ecx
	jle .get_at_most_take

	movq 8(%rdx), %rdx
	jmp .get_at_most_loop

.get_at_most_take:
	movl %ecx, %eax
	movq 16(%rdx), %rdx
	jmp .get_at_most_loop

.get_at_most_done:
	popq %rbp
	ret
