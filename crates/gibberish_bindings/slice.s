.text
is_eof:
	pushq %rbp
	movq %rsp, %rbp
	movq 8(%rdi), %rax
	movq 48(%rdi), %rcx
	cmpq %rax, %rcx
	setz %al
	movzbl %al, %eax
	leave
	ret
.type is_eof, @function
.size is_eof, .-is_eof
/* end function is_eof */

.text
.globl bumpN
bumpN:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
.Lbb3:
	cmpl $0, %esi
	jz .Lbb5
	movq %rsi, %r12
	subq $1, %r12
	movq %rdi, %rbx
	callq bump
	movq %r12, %rsi
	movq %rbx, %rdi
	jmp .Lbb3
.Lbb5:
	movl $1, %eax
	popq %r12
	popq %rbx
	leave
	ret
.type bumpN, @function
.size bumpN, .-bumpN
/* end function bumpN */

.text
.globl enter_group
enter_group:
	pushq %rbp
	movq %rsp, %rbp
	subq $40, %rsp
	pushq %rbx
	addq $24, %rdi
	movq %rdi, %rbx
	leaq -32(%rbp), %rdi
	callq new_group_node
	movq %rbx, %rdi
	movq %rax, %rdx
	movl $32, %esi
	callq push
	movl $1, %eax
	popq %rbx
	leave
	ret
.type enter_group, @function
.size enter_group, .-enter_group
/* end function enter_group */

.text
.globl exit_group
exit_group:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	addq $24, %rdi
	movl $32, %esi
	movq %rdi, %rbx
	callq pop
	movq %rbx, %rdi
	movq %rax, %rbx
	movl $32, %esi
	callq last
	movq %rbx, %rdx
	movq %rax, %rdi
	addq $8, %rdi
	movl $32, %esi
	callq push
	movl $1, %eax
	popq %rbx
	leave
	ret
.type exit_group, @function
.size exit_group, .-exit_group
/* end function exit_group */

.text
.globl bump
bump:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq 48(%rdi), %rbx
	movq %rbx, %rdx
	movl $24, %esi
	movq %rdi, %r12
	callq get
	movq %r12, %rdi
	movq %rbx, %rcx
	addq $1, %rcx
	movq %rcx, 48(%rdi)
	movq (%rax), %rsi
	movq 8(%rax), %rdx
	movq 16(%rax), %rcx
	movq %rdi, %rbx
	leaq -32(%rbp), %rdi
	callq new_token_node
	movq %rbx, %rdi
	movq %rax, %rbx
	addq $24, %rdi
	movl $32, %esi
	callq last
	movq %rbx, %rdx
	movq %rax, %rdi
	addq $8, %rdi
	movl $32, %esi
	callq push
	movl $1, %eax
	popq %r12
	popq %rbx
	leave
	ret
.type bump, @function
.size bump, .-bump
/* end function bump */

.text
.globl default_state_ptr
default_state_ptr:
	pushq %rbp
	movq %rsp, %rbp
	subq $72, %rsp
	pushq %rbx
	movq %rsi, %rdx
	movq %rdi, %rsi
	leaq -56(%rbp), %rdi
	callq default_state
	movq %rax, %rbx
	movl $56, %edi
	callq malloc
	movq %rbx, %rsi
	movq %rax, %rbx
	movl $56, %edx
	movq %rbx, %rdi
	callq memcpy
	movq %rbx, %rax
	popq %rbx
	leave
	ret
.type default_state_ptr, @function
.size default_state_ptr, .-default_state_ptr
/* end function default_state_ptr */

.text
.globl get_state
get_state:
	pushq %rbp
	movq %rsp, %rbp
	subq $64, %rsp
	movq %rdi, %rax
	movq 0(%rsi), %rcx
	movq %rcx, -56(%rbp)
	movq 8(%rsi), %rcx
	movq %rcx, -48(%rbp)
	movq 16(%rsi), %rcx
	movq %rcx, -40(%rbp)
	movq 24(%rsi), %rcx
	movq %rcx, -32(%rbp)
	movq 32(%rsi), %rcx
	movq %rcx, -24(%rbp)
	movq 40(%rsi), %rcx
	movq %rcx, -16(%rbp)
	movq 48(%rsi), %rcx
	movq %rcx, -8(%rbp)
	movq -56(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -48(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -40(%rbp), %rcx
	movq %rcx, 16(%rax)
	movq -32(%rbp), %rcx
	movq %rcx, 24(%rax)
	movq -24(%rbp), %rcx
	movq %rcx, 32(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 40(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 48(%rax)
	leave
	ret
.type get_state, @function
.size get_state, .-get_state
/* end function get_state */

.text
last:
	pushq %rbp
	movq %rsp, %rbp
	movq (%rdi), %rax
	movq 8(%rdi), %rcx
	subq $1, %rcx
	imulq %rsi, %rcx
	addq %rcx, %rax
	leave
	ret
.type last, @function
.size last, .-last
/* end function last */

.text
.globl default_state
default_state:
	pushq %rbp
	movq %rsp, %rbp
	subq $88, %rsp
	pushq %rbx
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq lex
	subq $32, %rsp
	movq %rsp, %rcx
	movq 0(%rax), %rdx
	movq %rdx, 0(%rcx)
	movq 8(%rax), %rdx
	movq %rdx, 8(%rcx)
	movq 16(%rax), %rax
	movq %rax, 16(%rcx)
	leaq -80(%rbp), %rdi
	callq new_state
	movq %rax, %rcx
	movq %rbx, %rax
	subq $-32, %rsp
	movq 0(%rcx), %rdx
	movq %rdx, 0(%rax)
	movq 8(%rcx), %rdx
	movq %rdx, 8(%rax)
	movq 16(%rcx), %rdx
	movq %rdx, 16(%rax)
	movq 24(%rcx), %rdx
	movq %rdx, 24(%rax)
	movq 32(%rcx), %rdx
	movq %rdx, 32(%rax)
	movq 40(%rcx), %rdx
	movq %rdx, 40(%rax)
	movq 48(%rcx), %rcx
	movq %rcx, 48(%rax)
	popq %rbx
	leave
	ret
.type default_state, @function
.size default_state, .-default_state
/* end function default_state */

.text
.globl test_state
test_state:
	pushq %rbp
	movq %rsp, %rbp
	subq $104, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq %rdi, %r12
	leaq -56(%rbp), %rdi
	callq default_state
	movq %rax, %rbx
	movq 48(%rbx), %r13
	movq %r13, %rdx
	movl $24, %esi
	movq %rbx, %rdi
	callq get
	movq %r13, %rcx
	addq $1, %rcx
	movq %rcx, 48(%rbx)
	movq (%rax), %rsi
	movq 8(%rax), %rdx
	movq 16(%rax), %rcx
	leaq -88(%rbp), %rdi
	callq new_token_node
	movq %rax, %r13
	movq %rbx, %rdi
	addq $24, %rdi
	movl $32, %esi
	callq last
	movq %r13, %rdx
	movq %rax, %rdi
	addq $8, %rdi
	movl $32, %esi
	callq push
	movq %r12, %rax
	movq 0(%rbx), %rcx
	movq %rcx, 0(%rax)
	movq 8(%rbx), %rcx
	movq %rcx, 8(%rax)
	movq 16(%rbx), %rcx
	movq %rcx, 16(%rax)
	movq 24(%rbx), %rcx
	movq %rcx, 24(%rax)
	movq 32(%rbx), %rcx
	movq %rcx, 32(%rax)
	movq 40(%rbx), %rcx
	movq %rcx, 40(%rax)
	movq 48(%rbx), %rcx
	movq %rcx, 48(%rax)
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type test_state, @function
.size test_state, .-test_state
/* end function test_state */

.text
.globl test_node
test_node:
	pushq %rbp
	movq %rsp, %rbp
	subq $96, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	leaq AHH(%rip), %rdi
	callq printf
	movl $3, %ecx
	movl $2, %edx
	movl $1, %esi
	leaq -32(%rbp), %rdi
	callq new_token_node
	movq %rax, %rbx
	movl $32, %esi
	leaq -56(%rbp), %rdi
	callq new_vec
	movl $123, %esi
	leaq -88(%rbp), %rdi
	callq new_group_node
	movq %rbx, %rdx
	movq %rax, %rbx
	movq %rbx, %rdi
	addq $8, %rdi
	movl $32, %esi
	callq push
	movq %r12, %rax
	movq 0(%rbx), %rcx
	movq %rcx, 0(%rax)
	movq 8(%rbx), %rcx
	movq %rcx, 8(%rax)
	movq 16(%rbx), %rcx
	movq %rcx, 16(%rax)
	movq 24(%rbx), %rcx
	movq %rcx, 24(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type test_node, @function
.size test_node, .-test_node
/* end function test_node */

.text
new_state:
	pushq %rbp
	movq %rsp, %rbp
	subq $112, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $0, %esi
	leaq -88(%rbp), %rdi
	callq new_group_node
	movq %rax, %rbx
	movl $32, %esi
	leaq -112(%rbp), %rdi
	callq new_vec
	movq %rbx, %rdx
	movq %rax, %rbx
	movl $32, %esi
	movq %rbx, %rdi
	callq push
	movq %r12, %rax
	movq 16(%rbp), %rcx
	movq %rcx, -56(%rbp)
	movq 24(%rbp), %rcx
	movq %rcx, -48(%rbp)
	movq 32(%rbp), %rcx
	movq %rcx, -40(%rbp)
	movq 0(%rbx), %rcx
	movq %rcx, -32(%rbp)
	movq 8(%rbx), %rcx
	movq %rcx, -24(%rbp)
	movq 16(%rbx), %rcx
	movq %rcx, -16(%rbp)
	movq $0, -8(%rbp)
	movq -56(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -48(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -40(%rbp), %rcx
	movq %rcx, 16(%rax)
	movq -32(%rbp), %rcx
	movq %rcx, 24(%rax)
	movq -24(%rbp), %rcx
	movq %rcx, 32(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 40(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 48(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type new_state, @function
.size new_state, .-new_state
/* end function new_state */

.data
.balign 8
debug_group:
	.ascii "Group { kind: %d, group_kind: %d, ptr: %d, len: %d, cap: %d, }"
	.byte 0
/* end data */

.text
print_group:
	pushq %rbp
	movq %rsp, %rbp
	movslq 16(%rbp), %rsi
	movslq 20(%rbp), %rdx
	movq 24(%rbp), %rcx
	movq 32(%rbp), %r8
	movq 40(%rbp), %r9
	leaq debug_group(%rip), %rdi
	callq printf
	movl $1, %eax
	leave
	ret
.type print_group, @function
.size print_group, .-print_group
/* end function print_group */

.text
.globl get
get:
	pushq %rbp
	movq %rsp, %rbp
	movq (%rdi), %rax
	movq %rsi, %rcx
	imulq %rdx, %rcx
	addq %rcx, %rax
	leave
	ret
.type get, @function
.size get, .-get
/* end function get */

.data
.balign 8
AHH:
	.ascii "AHHH"
	.byte 0
/* end data */

.text
new_token_node:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	movq %rdi, %rax
	movq $0, -32(%rbp)
	movq %rsi, -24(%rbp)
	movq %rdx, -16(%rbp)
	movq %rcx, -8(%rbp)
	movq -32(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -24(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 16(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 24(%rax)
	leave
	ret
.type new_token_node, @function
.size new_token_node, .-new_token_node
/* end function new_token_node */

.text
new_group_node:
	pushq %rbp
	movq %rsp, %rbp
	subq $64, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %rbx
	movl %esi, %r12d
	movl $32, %esi
	leaq -56(%rbp), %rdi
	callq new_vec
	movl %r12d, %esi
	movq %rax, %rcx
	movq %rbx, %rax
	movq 0(%rcx), %rdx
	movq %rdx, -24(%rbp)
	movq 8(%rcx), %rdx
	movq %rdx, -16(%rbp)
	movq 16(%rcx), %rcx
	movq %rcx, -8(%rbp)
	movl $1, -32(%rbp)
	movl %esi, -28(%rbp)
	movq -32(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -24(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 16(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 24(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type new_group_node, @function
.size new_group_node, .-new_group_node
/* end function new_group_node */

.text
new_error_node:
	pushq %rbp
	movq %rsp, %rbp
	subq $40, %rsp
	pushq %rbx
	movq %rdi, %rbx
	movl $24, %edi
	callq new_vec
	movq %rax, %rdx
	movq %rbx, %rax
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rdx)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rdx)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rdx)
	movq $2, -32(%rbp)
	movq -32(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -24(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 16(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 24(%rax)
	popq %rbx
	leave
	ret
.type new_error_node, @function
.size new_error_node, .-new_error_node
/* end function new_error_node */

.text
.globl new_vec
new_vec:
	pushq %rbp
	movq %rsp, %rbp
	subq $40, %rsp
	pushq %rbx
	movq %rdi, %rbx
	imulq $4, %rsi, %rdi
	callq malloc
	movq %rax, %rcx
	movq %rbx, %rax
	movq %rcx, -24(%rbp)
	movq $0, -16(%rbp)
	movq $4, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %rbx
	leave
	ret
.type new_vec, @function
.size new_vec, .-new_vec
/* end function new_vec */

.text
new_token:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	movq %rdi, %rax
	movq %rsi, -24(%rbp)
	movq %rdx, -16(%rbp)
	movq %rcx, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	leave
	ret
.type new_token, @function
.size new_token, .-new_token
/* end function new_token */

.text
pop:
	pushq %rbp
	movq %rsp, %rbp
	movq (%rdi), %rcx
	movq 8(%rdi), %rax
	subq $1, %rax
	movq %rax, 8(%rdi)
	imulq %rsi, %rax
	addq %rcx, %rax
	leave
	ret
.type pop, @function
.size pop, .-pop
/* end function pop */

.text
push:
	pushq %rbp
	movq %rsp, %rbp
	subq $40, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movq %rsi, %r15
	movq %rdx, %rsi
	movq %rsi, -24(%rbp)
	movq %rdi, %rbx
	addq $8, %rbx
	movq %rbx, -32(%rbp)
	movq %rdi, %rax
	addq $16, %rax
	movq %rax, -16(%rbp)
	movq %rbx, %r13
	movq (%rdi), %rbx
	movq 8(%rdi), %r12
	movq 16(%rdi), %rax
	cmpq %rax, %r12
	jz .Lbb45
	movq %r15, %rdx
	xchgq %r13, %rbx
	jmp .Lbb46
.Lbb45:
	imulq $4, %rax, %r14
	movq %rdi, %r13
	movq %r14, %rdi
	imulq %r15, %rdi
	callq malloc
	movq %r15, %rdx
	movq %r13, %rdi
	movq %rax, %r13
	movq -16(%rbp), %rax
	movq -24(%rbp), %rsi
	movq %r14, (%rax)
	movq %r13, (%rdi)
	movq %rdx, %r15
	imulq %r12, %rdx
	movq %rsi, %r14
	movq %rbx, %rsi
	movq %r13, %rdi
	callq memcpy
	movq %rbx, %rax
	movq -32(%rbp), %rbx
	movq %rax, %rdi
	callq free
	movq %r15, %rdx
	movq %r14, %rsi
.Lbb46:
	movq %r12, %rax
	imulq %rdx, %rax
	movq %rax, %rdi
	addq %r13, %rdi
	movq %r12, %rax
	addq $1, %rax
	movq %rax, (%rbx)
	callq memcpy
	movl $1, %eax
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type push, @function
.size push, .-push
/* end function push */

.data
.balign 8
error_token:
	.ascii "ERROR\n"
	.byte 0
/* end data */

.data
.balign 8
offset_ptr:
	.quad 0
/* end data */

.data
.balign 8
group_end:
	.quad 0
/* end data */

.text
cmp_current:
	pushq %rbp
	movq %rsp, %rbp
	movq offset_ptr(%rip), %rax
	movzbl (%rdi, %rax, 1), %eax
	cmpl %edx, %eax
	setz %al
	movzbl %al, %eax
	leave
	ret
.type cmp_current, @function
.size cmp_current, .-cmp_current
/* end function cmp_current */

.text
inc_offset:
	pushq %rbp
	movq %rsp, %rbp
	movq offset_ptr(%rip), %rax
	addq $1, %rax
	movq %rax, offset_ptr(%rip)
	movl $0, %eax
	leave
	ret
.type inc_offset, @function
.size inc_offset, .-inc_offset
/* end function inc_offset */

.data
.balign 8
select_token_name:
	.ascii "select"
	.byte 0
/* end data */

.data
.balign 8
select_token_name_len:
	.quad 6
/* end data */

.data
.balign 8
lex_select_text:
	.ascii "select %d\n"
	.byte 0
/* end data */

.text
lex_2:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	movq offset_ptr(%rip), %rbx
	movl $115, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb59
	movl $101, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb59
	movl $108, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb59
	movl $101, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb59
	movl $99, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb59
	movl $116, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb60
.Lbb59:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb61
.Lbb60:
	movl $1, %eax
.Lbb61:
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_2, @function
.size lex_2, .-lex_2
/* end function lex_2 */

.text
lex_1:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	movq %rbx, offset_ptr(%rip)
	callq lex_2
	cmpl $0, %eax
	jnz .Lbb65
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb66
.Lbb65:
	movq offset_ptr(%rip), %rax
	movq %rax, group_end(%rip)
	movl $1, %eax
.Lbb66:
	popq %rbx
	leave
	ret
.type lex_1, @function
.size lex_1, .-lex_1
/* end function lex_1 */

.text
lex_4:
	pushq %rbp
	movq %rsp, %rbp
	movq offset_ptr(%rip), %rax
	movzbl (%rax, %rdi, 1), %ecx
	cmpl $97, %ecx
	setae %al
	movzbl %al, %eax
	cmpl $122, %ecx
	setbe %cl
	movzbl %cl, %ecx
	testl %eax, %ecx
	jnz .Lbb69
	movl $0, %eax
	jmp .Lbb70
.Lbb69:
	callq inc_offset
	movl $1, %eax
.Lbb70:
	leave
	ret
.type lex_4, @function
.size lex_4, .-lex_4
/* end function lex_4 */

.text
lex_5:
	pushq %rbp
	movq %rsp, %rbp
	movq offset_ptr(%rip), %rax
	movzbl (%rax, %rdi, 1), %ecx
	cmpl $65, %ecx
	setae %al
	movzbl %al, %eax
	cmpl $90, %ecx
	setbe %cl
	movzbl %cl, %ecx
	testl %eax, %ecx
	jnz .Lbb73
	movl $0, %eax
	jmp .Lbb74
.Lbb73:
	callq inc_offset
	movl $1, %eax
.Lbb74:
	leave
	ret
.type lex_5, @function
.size lex_5, .-lex_5
/* end function lex_5 */

.text
lex_6:
	pushq %rbp
	movq %rsp, %rbp
	movq offset_ptr(%rip), %rax
	movzbl (%rax, %rdi, 1), %ecx
	cmpl $48, %ecx
	setae %al
	movzbl %al, %eax
	cmpl $57, %ecx
	setbe %cl
	movzbl %cl, %ecx
	testl %eax, %ecx
	jnz .Lbb77
	movl $0, %eax
	jmp .Lbb78
.Lbb77:
	callq inc_offset
	movl $1, %eax
.Lbb78:
	leave
	ret
.type lex_6, @function
.size lex_6, .-lex_6
/* end function lex_6 */

.text
lex_7:
	pushq %rbp
	movq %rsp, %rbp
	movl $95, %edx
	callq cmp_current
	cmpl $0, %eax
	jnz .Lbb81
	movl $0, %eax
	jmp .Lbb82
.Lbb81:
	callq inc_offset
	movl $1, %eax
.Lbb82:
	leave
	ret
.type lex_7, @function
.size lex_7, .-lex_7
/* end function lex_7 */

.text
lex_3:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq offset_ptr(%rip), %rbx
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_4
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb89
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_5
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb89
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_6
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb89
	callq lex_7
	cmpl $0, %eax
	jnz .Lbb89
	callq inc_offset
	movl $1, %eax
	jmp .Lbb90
.Lbb89:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb90:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_3, @function
.size lex_3, .-lex_3
/* end function lex_3 */

.text
lex_0:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq offset_ptr(%rip), %rbx
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_1
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb94
	callq lex_3
	cmpl $0, %eax
	jnz .Lbb95
.Lbb94:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb96
.Lbb95:
	movl $1, %eax
.Lbb96:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_0, @function
.size lex_0, .-lex_0
/* end function lex_0 */

.text
lex_select:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_0
	cmpl $0, %eax
	jnz .Lbb99
	movl $0, %eax
	jmp .Lbb101
.Lbb99:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb101
	movq offset_ptr(%rip), %rax
.Lbb101:
	leave
	ret
.type lex_select, @function
.size lex_select, .-lex_select
/* end function lex_select */

.data
.balign 8
from_token_name:
	.ascii "from"
	.byte 0
/* end data */

.data
.balign 8
from_token_name_len:
	.quad 4
/* end data */

.data
.balign 8
lex_from_text:
	.ascii "from %d\n"
	.byte 0
/* end data */

.text
lex_10:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	movq offset_ptr(%rip), %rbx
	movl $102, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb107
	movl $114, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb107
	movl $111, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb107
	movl $109, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb108
.Lbb107:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb109
.Lbb108:
	movl $1, %eax
.Lbb109:
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_10, @function
.size lex_10, .-lex_10
/* end function lex_10 */

.text
lex_9:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	movq %rbx, offset_ptr(%rip)
	callq lex_10
	cmpl $0, %eax
	jnz .Lbb113
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb114
.Lbb113:
	movq offset_ptr(%rip), %rax
	movq %rax, group_end(%rip)
	movl $1, %eax
.Lbb114:
	popq %rbx
	leave
	ret
.type lex_9, @function
.size lex_9, .-lex_9
/* end function lex_9 */

.text
lex_12:
	pushq %rbp
	movq %rsp, %rbp
	movq offset_ptr(%rip), %rax
	movzbl (%rax, %rdi, 1), %ecx
	cmpl $97, %ecx
	setae %al
	movzbl %al, %eax
	cmpl $122, %ecx
	setbe %cl
	movzbl %cl, %ecx
	testl %eax, %ecx
	jnz .Lbb117
	movl $0, %eax
	jmp .Lbb118
.Lbb117:
	callq inc_offset
	movl $1, %eax
.Lbb118:
	leave
	ret
.type lex_12, @function
.size lex_12, .-lex_12
/* end function lex_12 */

.text
lex_13:
	pushq %rbp
	movq %rsp, %rbp
	movq offset_ptr(%rip), %rax
	movzbl (%rax, %rdi, 1), %ecx
	cmpl $65, %ecx
	setae %al
	movzbl %al, %eax
	cmpl $90, %ecx
	setbe %cl
	movzbl %cl, %ecx
	testl %eax, %ecx
	jnz .Lbb121
	movl $0, %eax
	jmp .Lbb122
.Lbb121:
	callq inc_offset
	movl $1, %eax
.Lbb122:
	leave
	ret
.type lex_13, @function
.size lex_13, .-lex_13
/* end function lex_13 */

.text
lex_14:
	pushq %rbp
	movq %rsp, %rbp
	movq offset_ptr(%rip), %rax
	movzbl (%rax, %rdi, 1), %ecx
	cmpl $48, %ecx
	setae %al
	movzbl %al, %eax
	cmpl $57, %ecx
	setbe %cl
	movzbl %cl, %ecx
	testl %eax, %ecx
	jnz .Lbb125
	movl $0, %eax
	jmp .Lbb126
.Lbb125:
	callq inc_offset
	movl $1, %eax
.Lbb126:
	leave
	ret
.type lex_14, @function
.size lex_14, .-lex_14
/* end function lex_14 */

.text
lex_15:
	pushq %rbp
	movq %rsp, %rbp
	movl $95, %edx
	callq cmp_current
	cmpl $0, %eax
	jnz .Lbb129
	movl $0, %eax
	jmp .Lbb130
.Lbb129:
	callq inc_offset
	movl $1, %eax
.Lbb130:
	leave
	ret
.type lex_15, @function
.size lex_15, .-lex_15
/* end function lex_15 */

.text
lex_11:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq offset_ptr(%rip), %rbx
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_12
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb137
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_13
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb137
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_14
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb137
	callq lex_15
	cmpl $0, %eax
	jnz .Lbb137
	callq inc_offset
	movl $1, %eax
	jmp .Lbb138
.Lbb137:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb138:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_11, @function
.size lex_11, .-lex_11
/* end function lex_11 */

.text
lex_8:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq offset_ptr(%rip), %rbx
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_9
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb142
	callq lex_11
	cmpl $0, %eax
	jnz .Lbb143
.Lbb142:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb144
.Lbb143:
	movl $1, %eax
.Lbb144:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_8, @function
.size lex_8, .-lex_8
/* end function lex_8 */

.text
lex_from:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_8
	cmpl $0, %eax
	jnz .Lbb147
	movl $0, %eax
	jmp .Lbb149
.Lbb147:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb149
	movq offset_ptr(%rip), %rax
.Lbb149:
	leave
	ret
.type lex_from, @function
.size lex_from, .-lex_from
/* end function lex_from */

.data
.balign 8
delete_token_name:
	.ascii "delete"
	.byte 0
/* end data */

.data
.balign 8
delete_token_name_len:
	.quad 6
/* end data */

.data
.balign 8
lex_delete_text:
	.ascii "delete %d\n"
	.byte 0
/* end data */

.text
lex_18:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	movq offset_ptr(%rip), %rbx
	movl $100, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb157
	movl $101, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb157
	movl $108, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb157
	movl $101, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb157
	movl $116, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb157
	movl $101, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb158
.Lbb157:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb159
.Lbb158:
	movl $1, %eax
.Lbb159:
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_18, @function
.size lex_18, .-lex_18
/* end function lex_18 */

.text
lex_17:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	movq %rbx, offset_ptr(%rip)
	callq lex_18
	cmpl $0, %eax
	jnz .Lbb163
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb164
.Lbb163:
	movq offset_ptr(%rip), %rax
	movq %rax, group_end(%rip)
	movl $1, %eax
.Lbb164:
	popq %rbx
	leave
	ret
.type lex_17, @function
.size lex_17, .-lex_17
/* end function lex_17 */

.text
lex_20:
	pushq %rbp
	movq %rsp, %rbp
	movq offset_ptr(%rip), %rax
	movzbl (%rax, %rdi, 1), %ecx
	cmpl $97, %ecx
	setae %al
	movzbl %al, %eax
	cmpl $122, %ecx
	setbe %cl
	movzbl %cl, %ecx
	testl %eax, %ecx
	jnz .Lbb167
	movl $0, %eax
	jmp .Lbb168
.Lbb167:
	callq inc_offset
	movl $1, %eax
.Lbb168:
	leave
	ret
.type lex_20, @function
.size lex_20, .-lex_20
/* end function lex_20 */

.text
lex_21:
	pushq %rbp
	movq %rsp, %rbp
	movq offset_ptr(%rip), %rax
	movzbl (%rax, %rdi, 1), %ecx
	cmpl $65, %ecx
	setae %al
	movzbl %al, %eax
	cmpl $90, %ecx
	setbe %cl
	movzbl %cl, %ecx
	testl %eax, %ecx
	jnz .Lbb171
	movl $0, %eax
	jmp .Lbb172
.Lbb171:
	callq inc_offset
	movl $1, %eax
.Lbb172:
	leave
	ret
.type lex_21, @function
.size lex_21, .-lex_21
/* end function lex_21 */

.text
lex_22:
	pushq %rbp
	movq %rsp, %rbp
	movq offset_ptr(%rip), %rax
	movzbl (%rax, %rdi, 1), %ecx
	cmpl $48, %ecx
	setae %al
	movzbl %al, %eax
	cmpl $57, %ecx
	setbe %cl
	movzbl %cl, %ecx
	testl %eax, %ecx
	jnz .Lbb175
	movl $0, %eax
	jmp .Lbb176
.Lbb175:
	callq inc_offset
	movl $1, %eax
.Lbb176:
	leave
	ret
.type lex_22, @function
.size lex_22, .-lex_22
/* end function lex_22 */

.text
lex_23:
	pushq %rbp
	movq %rsp, %rbp
	movl $95, %edx
	callq cmp_current
	cmpl $0, %eax
	jnz .Lbb179
	movl $0, %eax
	jmp .Lbb180
.Lbb179:
	callq inc_offset
	movl $1, %eax
.Lbb180:
	leave
	ret
.type lex_23, @function
.size lex_23, .-lex_23
/* end function lex_23 */

.text
lex_19:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq offset_ptr(%rip), %rbx
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_20
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb187
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_21
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb187
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_22
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb187
	callq lex_23
	cmpl $0, %eax
	jnz .Lbb187
	callq inc_offset
	movl $1, %eax
	jmp .Lbb188
.Lbb187:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb188:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_19, @function
.size lex_19, .-lex_19
/* end function lex_19 */

.text
lex_16:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq offset_ptr(%rip), %rbx
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_17
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb192
	callq lex_19
	cmpl $0, %eax
	jnz .Lbb193
.Lbb192:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb194
.Lbb193:
	movl $1, %eax
.Lbb194:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_16, @function
.size lex_16, .-lex_16
/* end function lex_16 */

.text
lex_delete:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_16
	cmpl $0, %eax
	jnz .Lbb197
	movl $0, %eax
	jmp .Lbb199
.Lbb197:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb199
	movq offset_ptr(%rip), %rax
.Lbb199:
	leave
	ret
.type lex_delete, @function
.size lex_delete, .-lex_delete
/* end function lex_delete */

.data
.balign 8
NUM_token_name:
	.ascii "NUM"
	.byte 0
/* end data */

.data
.balign 8
lex_NUM_text:
	.ascii "NUM %d\n"
	.byte 0
/* end data */

.text
lex_26:
	pushq %rbp
	movq %rsp, %rbp
	movq offset_ptr(%rip), %rax
	movzbl (%rax, %rdi, 1), %ecx
	cmpl $48, %ecx
	setae %al
	movzbl %al, %eax
	cmpl $57, %ecx
	setbe %cl
	movzbl %cl, %ecx
	testl %eax, %ecx
	jnz .Lbb202
	movl $0, %eax
	jmp .Lbb203
.Lbb202:
	callq inc_offset
	movl $1, %eax
.Lbb203:
	leave
	ret
.type lex_26, @function
.size lex_26, .-lex_26
/* end function lex_26 */

.text
lex_25:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	movq %rbx, offset_ptr(%rip)
	callq lex_26
	cmpl $0, %eax
	jnz .Lbb207
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb208
.Lbb207:
	movl $1, %eax
.Lbb208:
	popq %rbx
	leave
	ret
.type lex_25, @function
.size lex_25, .-lex_25
/* end function lex_25 */

.text
lex_27:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jz .Lbb214
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_25
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb214
.Lbb211:
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jz .Lbb213
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_25
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb211
.Lbb213:
	movl $1, %eax
	jmp .Lbb215
.Lbb214:
	movl $0, %eax
.Lbb215:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_27, @function
.size lex_27, .-lex_27
/* end function lex_27 */

.text
lex_24:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_27
	cmpl $0, %eax
	jnz .Lbb219
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb220
.Lbb219:
	movl $1, %eax
.Lbb220:
	popq %rbx
	leave
	ret
.type lex_24, @function
.size lex_24, .-lex_24
/* end function lex_24 */

.text
lex_NUM:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_24
	cmpl $0, %eax
	jnz .Lbb223
	movl $0, %eax
	jmp .Lbb225
.Lbb223:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb225
	movq offset_ptr(%rip), %rax
.Lbb225:
	leave
	ret
.type lex_NUM, @function
.size lex_NUM, .-lex_NUM
/* end function lex_NUM */

.data
.balign 8
STR_token_name:
	.ascii "STR"
	.byte 0
/* end data */

.data
.balign 8
lex_STR_text:
	.ascii "STR %d\n"
	.byte 0
/* end data */

.text
lex_29:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rbx
	movl $34, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb229
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb230
.Lbb229:
	movl $1, %eax
.Lbb230:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_29, @function
.size lex_29, .-lex_29
/* end function lex_29 */

.text
lex_31:
	pushq %rbp
	movq %rsp, %rbp
	movl $34, %edx
	callq cmp_current
	cmpl $0, %eax
	jnz .Lbb233
	movl $0, %eax
	jmp .Lbb234
.Lbb233:
	callq inc_offset
	movl $1, %eax
.Lbb234:
	leave
	ret
.type lex_31, @function
.size lex_31, .-lex_31
/* end function lex_31 */

.text
lex_30:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_31
	cmpl $0, %eax
	jnz .Lbb238
	callq inc_offset
	movl $1, %eax
	jmp .Lbb239
.Lbb238:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb239:
	popq %rbx
	leave
	ret
.type lex_30, @function
.size lex_30, .-lex_30
/* end function lex_30 */

.text
lex_32:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
.Lbb241:
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_30
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb243
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jnz .Lbb241
.Lbb243:
	movl $1, %eax
	popq %r12
	popq %rbx
	leave
	ret
.type lex_32, @function
.size lex_32, .-lex_32
/* end function lex_32 */

.text
lex_33:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rbx
	movl $34, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb248
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb249
.Lbb248:
	movl $1, %eax
.Lbb249:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_33, @function
.size lex_33, .-lex_33
/* end function lex_33 */

.text
lex_28:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq offset_ptr(%rip), %rbx
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_29
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb254
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_32
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb254
	callq lex_33
	cmpl $0, %eax
	jnz .Lbb255
.Lbb254:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb256
.Lbb255:
	movl $1, %eax
.Lbb256:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_28, @function
.size lex_28, .-lex_28
/* end function lex_28 */

.text
lex_STR:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_28
	cmpl $0, %eax
	jnz .Lbb259
	movl $0, %eax
	jmp .Lbb261
.Lbb259:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb261
	movq offset_ptr(%rip), %rax
.Lbb261:
	leave
	ret
.type lex_STR, @function
.size lex_STR, .-lex_STR
/* end function lex_STR */

.data
.balign 8
WHITESPACE_token_name:
	.ascii "WHITESPACE"
	.byte 0
/* end data */

.data
.balign 8
lex_WHITESPACE_text:
	.ascii "WHITESPACE %d\n"
	.byte 0
/* end data */

.text
lex_35:
	pushq %rbp
	movq %rsp, %rbp
	movq offset_ptr(%rip), %rax
	movzbl (%rax, %rdi, 1), %edx
	cmpl $32, %edx
	setz %cl
	movzbl %cl, %ecx
	cmpl $9, %edx
	setae %al
	movzbl %al, %eax
	cmpl $13, %edx
	setbe %dl
	movzbl %dl, %edx
	andl %edx, %eax
	orl %ecx, %eax
	jnz .Lbb264
	movl $0, %eax
	jmp .Lbb265
.Lbb264:
	callq inc_offset
	movl $1, %eax
.Lbb265:
	leave
	ret
.type lex_35, @function
.size lex_35, .-lex_35
/* end function lex_35 */

.text
lex_36:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jz .Lbb271
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_35
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb271
.Lbb268:
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jz .Lbb270
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_35
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb268
.Lbb270:
	movl $1, %eax
	jmp .Lbb272
.Lbb271:
	movl $0, %eax
.Lbb272:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_36, @function
.size lex_36, .-lex_36
/* end function lex_36 */

.text
lex_34:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_36
	cmpl $0, %eax
	jnz .Lbb276
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb277
.Lbb276:
	movl $1, %eax
.Lbb277:
	popq %rbx
	leave
	ret
.type lex_34, @function
.size lex_34, .-lex_34
/* end function lex_34 */

.text
lex_WHITESPACE:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_34
	cmpl $0, %eax
	jnz .Lbb280
	movl $0, %eax
	jmp .Lbb282
.Lbb280:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb282
	movq offset_ptr(%rip), %rax
.Lbb282:
	leave
	ret
.type lex_WHITESPACE, @function
.size lex_WHITESPACE, .-lex_WHITESPACE
/* end function lex_WHITESPACE */

.data
.balign 8
IDENT_token_name:
	.ascii "IDENT"
	.byte 0
/* end data */

.data
.balign 8
lex_IDENT_text:
	.ascii "IDENT %d\n"
	.byte 0
/* end data */

.text
lex_39:
	pushq %rbp
	movq %rsp, %rbp
	movl $95, %edx
	callq cmp_current
	cmpl $0, %eax
	jnz .Lbb285
	movl $0, %eax
	jmp .Lbb286
.Lbb285:
	callq inc_offset
	movl $1, %eax
.Lbb286:
	leave
	ret
.type lex_39, @function
.size lex_39, .-lex_39
/* end function lex_39 */

.text
lex_40:
	pushq %rbp
	movq %rsp, %rbp
	movq offset_ptr(%rip), %rax
	movzbl (%rax, %rdi, 1), %ecx
	cmpl $97, %ecx
	setae %al
	movzbl %al, %eax
	cmpl $122, %ecx
	setbe %cl
	movzbl %cl, %ecx
	testl %eax, %ecx
	jnz .Lbb289
	movl $0, %eax
	jmp .Lbb290
.Lbb289:
	callq inc_offset
	movl $1, %eax
.Lbb290:
	leave
	ret
.type lex_40, @function
.size lex_40, .-lex_40
/* end function lex_40 */

.text
lex_41:
	pushq %rbp
	movq %rsp, %rbp
	movq offset_ptr(%rip), %rax
	movzbl (%rax, %rdi, 1), %ecx
	cmpl $65, %ecx
	setae %al
	movzbl %al, %eax
	cmpl $90, %ecx
	setbe %cl
	movzbl %cl, %ecx
	testl %eax, %ecx
	jnz .Lbb293
	movl $0, %eax
	jmp .Lbb294
.Lbb293:
	callq inc_offset
	movl $1, %eax
.Lbb294:
	leave
	ret
.type lex_41, @function
.size lex_41, .-lex_41
/* end function lex_41 */

.text
lex_38:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq offset_ptr(%rip), %rbx
	movq %rbx, offset_ptr(%rip)
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_39
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb300
	movq %rbx, offset_ptr(%rip)
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_40
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb300
	movq %rbx, offset_ptr(%rip)
	callq lex_41
	cmpl $0, %eax
	jnz .Lbb300
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb301
.Lbb300:
	movl $1, %eax
.Lbb301:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_38, @function
.size lex_38, .-lex_38
/* end function lex_38 */

.text
lex_42:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jz .Lbb307
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_38
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb307
.Lbb304:
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jz .Lbb306
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_38
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb304
.Lbb306:
	movl $1, %eax
	jmp .Lbb308
.Lbb307:
	movl $0, %eax
.Lbb308:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_42, @function
.size lex_42, .-lex_42
/* end function lex_42 */

.text
lex_37:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_42
	cmpl $0, %eax
	jnz .Lbb312
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb313
.Lbb312:
	movl $1, %eax
.Lbb313:
	popq %rbx
	leave
	ret
.type lex_37, @function
.size lex_37, .-lex_37
/* end function lex_37 */

.text
lex_IDENT:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_37
	cmpl $0, %eax
	jnz .Lbb316
	movl $0, %eax
	jmp .Lbb318
.Lbb316:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb318
	movq offset_ptr(%rip), %rax
.Lbb318:
	leave
	ret
.type lex_IDENT, @function
.size lex_IDENT, .-lex_IDENT
/* end function lex_IDENT */

.data
.balign 8
COLON_token_name:
	.ascii "COLON"
	.byte 0
/* end data */

.data
.balign 8
lex_COLON_text:
	.ascii "COLON %d\n"
	.byte 0
/* end data */

.text
lex_44:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rbx
	movl $58, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb322
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb323
.Lbb322:
	movl $1, %eax
.Lbb323:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_44, @function
.size lex_44, .-lex_44
/* end function lex_44 */

.text
lex_43:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_44
	cmpl $0, %eax
	jnz .Lbb327
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb328
.Lbb327:
	movl $1, %eax
.Lbb328:
	popq %rbx
	leave
	ret
.type lex_43, @function
.size lex_43, .-lex_43
/* end function lex_43 */

.text
lex_COLON:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_43
	cmpl $0, %eax
	jnz .Lbb331
	movl $0, %eax
	jmp .Lbb333
.Lbb331:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb333
	movq offset_ptr(%rip), %rax
.Lbb333:
	leave
	ret
.type lex_COLON, @function
.size lex_COLON, .-lex_COLON
/* end function lex_COLON */

.data
.balign 8
COMMA_token_name:
	.ascii "COMMA"
	.byte 0
/* end data */

.data
.balign 8
lex_COMMA_text:
	.ascii "COMMA %d\n"
	.byte 0
/* end data */

.text
lex_46:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rbx
	movl $44, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb337
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb338
.Lbb337:
	movl $1, %eax
.Lbb338:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_46, @function
.size lex_46, .-lex_46
/* end function lex_46 */

.text
lex_45:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_46
	cmpl $0, %eax
	jnz .Lbb342
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb343
.Lbb342:
	movl $1, %eax
.Lbb343:
	popq %rbx
	leave
	ret
.type lex_45, @function
.size lex_45, .-lex_45
/* end function lex_45 */

.text
lex_COMMA:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_45
	cmpl $0, %eax
	jnz .Lbb346
	movl $0, %eax
	jmp .Lbb348
.Lbb346:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb348
	movq offset_ptr(%rip), %rax
.Lbb348:
	leave
	ret
.type lex_COMMA, @function
.size lex_COMMA, .-lex_COMMA
/* end function lex_COMMA */

.data
.balign 8
SEMI_token_name:
	.ascii "SEMI"
	.byte 0
/* end data */

.data
.balign 8
lex_SEMI_text:
	.ascii "SEMI %d\n"
	.byte 0
/* end data */

.text
lex_48:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rbx
	movl $59, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb352
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb353
.Lbb352:
	movl $1, %eax
.Lbb353:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_48, @function
.size lex_48, .-lex_48
/* end function lex_48 */

.text
lex_47:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_48
	cmpl $0, %eax
	jnz .Lbb357
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb358
.Lbb357:
	movl $1, %eax
.Lbb358:
	popq %rbx
	leave
	ret
.type lex_47, @function
.size lex_47, .-lex_47
/* end function lex_47 */

.text
lex_SEMI:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_47
	cmpl $0, %eax
	jnz .Lbb361
	movl $0, %eax
	jmp .Lbb363
.Lbb361:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb363
	movq offset_ptr(%rip), %rax
.Lbb363:
	leave
	ret
.type lex_SEMI, @function
.size lex_SEMI, .-lex_SEMI
/* end function lex_SEMI */

.data
.balign 8
PLUS_token_name:
	.ascii "PLUS"
	.byte 0
/* end data */

.data
.balign 8
lex_PLUS_text:
	.ascii "PLUS %d\n"
	.byte 0
/* end data */

.text
lex_50:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rbx
	movl $43, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb367
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb368
.Lbb367:
	movl $1, %eax
.Lbb368:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_50, @function
.size lex_50, .-lex_50
/* end function lex_50 */

.text
lex_49:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_50
	cmpl $0, %eax
	jnz .Lbb372
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb373
.Lbb372:
	movl $1, %eax
.Lbb373:
	popq %rbx
	leave
	ret
.type lex_49, @function
.size lex_49, .-lex_49
/* end function lex_49 */

.text
lex_PLUS:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_49
	cmpl $0, %eax
	jnz .Lbb376
	movl $0, %eax
	jmp .Lbb378
.Lbb376:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb378
	movq offset_ptr(%rip), %rax
.Lbb378:
	leave
	ret
.type lex_PLUS, @function
.size lex_PLUS, .-lex_PLUS
/* end function lex_PLUS */

.data
.balign 8
TIMES_token_name:
	.ascii "TIMES"
	.byte 0
/* end data */

.data
.balign 8
lex_TIMES_text:
	.ascii "TIMES %d\n"
	.byte 0
/* end data */

.text
lex_52:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rbx
	movl $42, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb382
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb383
.Lbb382:
	movl $1, %eax
.Lbb383:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_52, @function
.size lex_52, .-lex_52
/* end function lex_52 */

.text
lex_51:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_52
	cmpl $0, %eax
	jnz .Lbb387
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb388
.Lbb387:
	movl $1, %eax
.Lbb388:
	popq %rbx
	leave
	ret
.type lex_51, @function
.size lex_51, .-lex_51
/* end function lex_51 */

.text
lex_TIMES:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_51
	cmpl $0, %eax
	jnz .Lbb391
	movl $0, %eax
	jmp .Lbb393
.Lbb391:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb393
	movq offset_ptr(%rip), %rax
.Lbb393:
	leave
	ret
.type lex_TIMES, @function
.size lex_TIMES, .-lex_TIMES
/* end function lex_TIMES */

.data
.balign 8
LParen_token_name:
	.ascii "LParen"
	.byte 0
/* end data */

.data
.balign 8
lex_LParen_text:
	.ascii "LParen %d\n"
	.byte 0
/* end data */

.text
lex_54:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rbx
	movl $40, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb397
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb398
.Lbb397:
	movl $1, %eax
.Lbb398:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_54, @function
.size lex_54, .-lex_54
/* end function lex_54 */

.text
lex_53:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_54
	cmpl $0, %eax
	jnz .Lbb402
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb403
.Lbb402:
	movl $1, %eax
.Lbb403:
	popq %rbx
	leave
	ret
.type lex_53, @function
.size lex_53, .-lex_53
/* end function lex_53 */

.text
lex_LParen:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_53
	cmpl $0, %eax
	jnz .Lbb406
	movl $0, %eax
	jmp .Lbb408
.Lbb406:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb408
	movq offset_ptr(%rip), %rax
.Lbb408:
	leave
	ret
.type lex_LParen, @function
.size lex_LParen, .-lex_LParen
/* end function lex_LParen */

.data
.balign 8
RParen_token_name:
	.ascii "RParen"
	.byte 0
/* end data */

.data
.balign 8
lex_RParen_text:
	.ascii "RParen %d\n"
	.byte 0
/* end data */

.text
lex_56:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rbx
	movl $41, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb412
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb413
.Lbb412:
	movl $1, %eax
.Lbb413:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_56, @function
.size lex_56, .-lex_56
/* end function lex_56 */

.text
lex_55:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_56
	cmpl $0, %eax
	jnz .Lbb417
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb418
.Lbb417:
	movl $1, %eax
.Lbb418:
	popq %rbx
	leave
	ret
.type lex_55, @function
.size lex_55, .-lex_55
/* end function lex_55 */

.text
lex_RParen:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_55
	cmpl $0, %eax
	jnz .Lbb421
	movl $0, %eax
	jmp .Lbb423
.Lbb421:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb423
	movq offset_ptr(%rip), %rax
.Lbb423:
	leave
	ret
.type lex_RParen, @function
.size lex_RParen, .-lex_RParen
/* end function lex_RParen */

.text
.globl lex
lex:
	pushq %rbp
	movq %rsp, %rbp
	subq $408, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movq %rdx, %r12
	movq %rdi, -16(%rbp)
	movq %rsi, %rbx
	movl $24, %esi
	leaq -40(%rbp), %rdi
	callq new_vec
	movq %r12, %rdx
	movq %rbx, %rsi
	movq %rax, %rbx
	movl $0, %r12d
.Lbb426:
	movq %rdx, %r14
	movq offset_ptr(%rip), %rax
	cmpq %r14, %rax
	jz .Lbb470
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_select
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb468
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_from
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb466
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_delete
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb464
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_NUM
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb462
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_STR
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb460
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_WHITESPACE
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb458
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_IDENT
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb456
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_COLON
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb454
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_COMMA
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb452
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_SEMI
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb450
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_PLUS
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb448
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_TIMES
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb446
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_LParen
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb444
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_RParen
	movq %r14, %rdx
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jz .Lbb442
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $13, %esi
	leaq -88(%rbp), %rdi
	callq new_token
	movq %r14, %rsi
	movq %rax, %rdx
	movq %rsi, %r14
	movl $24, %esi
	movq %rbx, %rdi
	callq push
	movq %r15, %rdx
	movq %r14, %rsi
	addq %r13, %rsi
	subq %r13, %rdx
	movq $0, offset_ptr(%rip)
	movq $0, group_end(%rip)
	jmp .Lbb426
.Lbb442:
	movq %r12, %r13
	movq -16(%rbp), %r12
	leaq error_token(%rip), %rdi
	callq printf
	movq %r13, %rdx
	movq %rdx, %rcx
	addq $1, %rcx
	movl $14, %esi
	leaq -64(%rbp), %rdi
	callq new_token
	movq %rax, %rdx
	movl $24, %esi
	movq %rbx, %rdi
	callq push
	movq %r12, %rax
	movq $0, offset_ptr(%rip)
	movq $0, group_end(%rip)
	jmp .Lbb471
.Lbb444:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $12, %esi
	leaq -112(%rbp), %rdi
	callq new_token
	movq %r14, %rsi
	movq %rax, %rdx
	movq %rsi, %r14
	movl $24, %esi
	movq %rbx, %rdi
	callq push
	movq %r15, %rdx
	movq %r14, %rsi
	addq %r13, %rsi
	subq %r13, %rdx
	movq $0, offset_ptr(%rip)
	movq $0, group_end(%rip)
	jmp .Lbb426
.Lbb446:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $11, %esi
	leaq -136(%rbp), %rdi
	callq new_token
	movq %r14, %rsi
	movq %rax, %rdx
	movq %rsi, %r14
	movl $24, %esi
	movq %rbx, %rdi
	callq push
	movq %r15, %rdx
	movq %r14, %rsi
	addq %r13, %rsi
	subq %r13, %rdx
	movq $0, offset_ptr(%rip)
	movq $0, group_end(%rip)
	jmp .Lbb426
.Lbb448:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $10, %esi
	leaq -160(%rbp), %rdi
	callq new_token
	movq %r14, %rsi
	movq %rax, %rdx
	movq %rsi, %r14
	movl $24, %esi
	movq %rbx, %rdi
	callq push
	movq %r15, %rdx
	movq %r14, %rsi
	addq %r13, %rsi
	subq %r13, %rdx
	movq $0, offset_ptr(%rip)
	movq $0, group_end(%rip)
	jmp .Lbb426
.Lbb450:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $9, %esi
	leaq -184(%rbp), %rdi
	callq new_token
	movq %r14, %rsi
	movq %rax, %rdx
	movq %rsi, %r14
	movl $24, %esi
	movq %rbx, %rdi
	callq push
	movq %r15, %rdx
	movq %r14, %rsi
	addq %r13, %rsi
	subq %r13, %rdx
	movq $0, offset_ptr(%rip)
	movq $0, group_end(%rip)
	jmp .Lbb426
.Lbb452:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $8, %esi
	leaq -208(%rbp), %rdi
	callq new_token
	movq %r14, %rsi
	movq %rax, %rdx
	movq %rsi, %r14
	movl $24, %esi
	movq %rbx, %rdi
	callq push
	movq %r15, %rdx
	movq %r14, %rsi
	addq %r13, %rsi
	subq %r13, %rdx
	movq $0, offset_ptr(%rip)
	movq $0, group_end(%rip)
	jmp .Lbb426
.Lbb454:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $7, %esi
	leaq -232(%rbp), %rdi
	callq new_token
	movq %r14, %rsi
	movq %rax, %rdx
	movq %rsi, %r14
	movl $24, %esi
	movq %rbx, %rdi
	callq push
	movq %r15, %rdx
	movq %r14, %rsi
	addq %r13, %rsi
	subq %r13, %rdx
	movq $0, offset_ptr(%rip)
	movq $0, group_end(%rip)
	jmp .Lbb426
.Lbb456:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $6, %esi
	leaq -256(%rbp), %rdi
	callq new_token
	movq %r14, %rsi
	movq %rax, %rdx
	movq %rsi, %r14
	movl $24, %esi
	movq %rbx, %rdi
	callq push
	movq %r15, %rdx
	movq %r14, %rsi
	addq %r13, %rsi
	subq %r13, %rdx
	movq $0, offset_ptr(%rip)
	movq $0, group_end(%rip)
	jmp .Lbb426
.Lbb458:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $5, %esi
	leaq -280(%rbp), %rdi
	callq new_token
	movq %r14, %rsi
	movq %rax, %rdx
	movq %rsi, %r14
	movl $24, %esi
	movq %rbx, %rdi
	callq push
	movq %r15, %rdx
	movq %r14, %rsi
	addq %r13, %rsi
	subq %r13, %rdx
	movq $0, offset_ptr(%rip)
	movq $0, group_end(%rip)
	jmp .Lbb426
.Lbb460:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $4, %esi
	leaq -304(%rbp), %rdi
	callq new_token
	movq %r14, %rsi
	movq %rax, %rdx
	movq %rsi, %r14
	movl $24, %esi
	movq %rbx, %rdi
	callq push
	movq %r15, %rdx
	movq %r14, %rsi
	addq %r13, %rsi
	subq %r13, %rdx
	movq $0, offset_ptr(%rip)
	movq $0, group_end(%rip)
	jmp .Lbb426
.Lbb462:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $3, %esi
	leaq -328(%rbp), %rdi
	callq new_token
	movq %r14, %rsi
	movq %rax, %rdx
	movq %rsi, %r14
	movl $24, %esi
	movq %rbx, %rdi
	callq push
	movq %r15, %rdx
	movq %r14, %rsi
	addq %r13, %rsi
	subq %r13, %rdx
	movq $0, offset_ptr(%rip)
	movq $0, group_end(%rip)
	jmp .Lbb426
.Lbb464:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $2, %esi
	leaq -352(%rbp), %rdi
	callq new_token
	movq %r14, %rsi
	movq %rax, %rdx
	movq %rsi, %r14
	movl $24, %esi
	movq %rbx, %rdi
	callq push
	movq %r15, %rdx
	movq %r14, %rsi
	addq %r13, %rsi
	subq %r13, %rdx
	movq $0, offset_ptr(%rip)
	movq $0, group_end(%rip)
	jmp .Lbb426
.Lbb466:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $1, %esi
	leaq -376(%rbp), %rdi
	callq new_token
	movq %r14, %rsi
	movq %rax, %rdx
	movq %rsi, %r14
	movl $24, %esi
	movq %rbx, %rdi
	callq push
	movq %r15, %rdx
	movq %r14, %rsi
	addq %r13, %rsi
	subq %r13, %rdx
	movq $0, offset_ptr(%rip)
	movq $0, group_end(%rip)
	jmp .Lbb426
.Lbb468:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $0, %esi
	leaq -400(%rbp), %rdi
	callq new_token
	movq %r14, %rsi
	movq %rax, %rdx
	movq %rsi, %r14
	movl $24, %esi
	movq %rbx, %rdi
	callq push
	movq %r15, %rdx
	movq %r14, %rsi
	addq %r13, %rsi
	subq %r13, %rdx
	movq $0, offset_ptr(%rip)
	movq $0, group_end(%rip)
	jmp .Lbb426
.Lbb470:
	movq -16(%rbp), %rax
.Lbb471:
	movq 0(%rbx), %rcx
	movq %rcx, 0(%rax)
	movq 8(%rbx), %rcx
	movq %rcx, 8(%rax)
	movq 16(%rbx), %rcx
	movq %rcx, 16(%rax)
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex, @function
.size lex, .-lex
/* end function lex */

.data
.balign 8
err_token_name:
	.ascii "ERROR"
	.byte 0
/* end data */

.text
.globl name
name:
	pushq %rbp
	movq %rsp, %rbp
	cmpl $0, %edi
	leaq select_token_name(%rip), %rax
	jz .Lbb502
	cmpl $1, %edi
	leaq from_token_name(%rip), %rax
	jz .Lbb501
	cmpl $2, %edi
	leaq delete_token_name(%rip), %rax
	jz .Lbb500
	cmpl $3, %edi
	leaq NUM_token_name(%rip), %rax
	jz .Lbb499
	cmpl $4, %edi
	leaq STR_token_name(%rip), %rax
	jz .Lbb498
	cmpl $5, %edi
	leaq WHITESPACE_token_name(%rip), %rax
	jz .Lbb497
	cmpl $6, %edi
	leaq IDENT_token_name(%rip), %rax
	jz .Lbb496
	cmpl $7, %edi
	leaq COLON_token_name(%rip), %rax
	jz .Lbb495
	cmpl $8, %edi
	leaq COMMA_token_name(%rip), %rax
	jz .Lbb494
	cmpl $9, %edi
	leaq SEMI_token_name(%rip), %rax
	jz .Lbb493
	cmpl $10, %edi
	leaq PLUS_token_name(%rip), %rax
	jz .Lbb492
	cmpl $11, %edi
	leaq TIMES_token_name(%rip), %rax
	jz .Lbb491
	cmpl $12, %edi
	leaq LParen_token_name(%rip), %rax
	jz .Lbb490
	cmpl $13, %edi
	leaq RParen_token_name(%rip), %rax
	jz .Lbb489
	leaq err_token_name(%rip), %rax
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb503
.Lbb489:
	movq %rax, %rdx
	movl $6, %eax
	jmp .Lbb503
.Lbb490:
	movq %rax, %rdx
	movl $6, %eax
	jmp .Lbb503
.Lbb491:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb503
.Lbb492:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb503
.Lbb493:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb503
.Lbb494:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb503
.Lbb495:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb503
.Lbb496:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb503
.Lbb497:
	movq %rax, %rdx
	movl $10, %eax
	jmp .Lbb503
.Lbb498:
	movq %rax, %rdx
	movl $3, %eax
	jmp .Lbb503
.Lbb499:
	movq %rax, %rdx
	movl $3, %eax
	jmp .Lbb503
.Lbb500:
	movq %rax, %rdx
	movl $6, %eax
	jmp .Lbb503
.Lbb501:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb503
.Lbb502:
	movq %rax, %rdx
	movl $6, %eax
.Lbb503:
	subq $16, %rsp
	movq %rsp, %rcx
	movq %rdx, (%rcx)
	movq %rax, 8(%rcx)
	movq (%rcx), %rax
	movq 8(%rcx), %rdx
	movq %rbp, %rsp
	subq $0, %rsp
	leave
	ret
.type name, @function
.size name, .-name
/* end function name */

.section .note.GNU-stack,"",@progbits
