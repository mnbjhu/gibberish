.data
.balign 8
match_just:
	.ascii "Matched just %d\n"
	.byte 0
/* end data */

.data
.balign 8
eof_just:
	.ascii "Eof just %d\n"
	.byte 0
/* end data */

.data
.balign 8
skipped_just:
	.ascii "Skipped just %d\n"
	.byte 0
/* end data */

.data
.balign 8
break_just:
	.ascii "Break just %d\n"
	.byte 0
/* end data */

.data
.balign 8
err_just:
	.ascii "Err just %d\n"
	.byte 0
/* end data */

.text
.globl test_vec_contains
test_vec_contains:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $8, %esi
	leaq -24(%rbp), %rdi
	callq new_vec
	movq %rax, %rbx
	movl $0, %esi
	movq %rbx, %rdi
	callq push_long
	movl $1, %esi
	movq %rbx, %rdi
	callq push_long
	movl $2, %esi
	movq %rbx, %rdi
	callq push_long
	movq %r12, %rax
	movq 0(%rbx), %rcx
	movq %rcx, 0(%rax)
	movq 8(%rbx), %rcx
	movq %rcx, 8(%rax)
	movq 16(%rbx), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type test_vec_contains, @function
.size test_vec_contains, .-test_vec_contains
/* end function test_vec_contains */

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

.data
.balign 8
skipping_token:
	.ascii "Skipping token %u\n"
	.byte 0
/* end data */

.text
.globl skip
skip:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	addq $80, %rdi
	movq %rsi, %r12
	movq %rdi, %rbx
	callq contains_long
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb6
	callq push_long
	movl $1, %eax
	jmp .Lbb7
.Lbb6:
	movl $0, %eax
.Lbb7:
	popq %r12
	popq %rbx
	leave
	ret
.type skip, @function
.size skip, .-skip
/* end function skip */

.text
.globl unskip
unskip:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	addq $80, %rdi
	movq %rdi, %rbx
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb10
	movq %rax, %rsi
	subq $1, %rsi
	callq remove_long
	movl $1, %eax
	jmp .Lbb11
.Lbb10:
	movl $0, %eax
.Lbb11:
	popq %rbx
	leave
	ret
.type unskip, @function
.size unskip, .-unskip
/* end function unskip */

.text
remove_long:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq 8(%rdi), %rbx
	imulq $8, %rbx, %rax
	movq %rdi, %r12
	imulq $8, %rsi, %rdi
	addq $8, %rsi
	movq %rax, %rdx
	subq %rsi, %rdx
	callq memcpy
	movq %r12, %rdi
	movq %rbx, %rax
	subq $1, %rax
	movq %rax, 8(%rdi)
	movl $1, %eax
	popq %r12
	popq %rbx
	leave
	ret
.type remove_long, @function
.size remove_long, .-remove_long
/* end function remove_long */

.data
.balign 8
checking_skipped:
	.ascii "Checking %u == %u\n"
	.byte 0
/* end data */

.data
.balign 8
found_skipped:
	.ascii "Found %d\n"
	.byte 0
/* end data */

.data
.balign 8
info_msg:
	.ascii "Checking contains long for arr %u, len: %u\n"
/* end data */

.text
contains_long:
	pushq %rbp
	movq %rsp, %rbp
	movq (%rdi), %rcx
	movq 8(%rdi), %rdx
	cmpl $0, %edx
	jz .Lbb19
	movl $0, %eax
.Lbb16:
	movq (%rcx), %rdi
	cmpq %rsi, %rdi
	jz .Lbb18
	addq $1, %rax
	addq $8, %rcx
	cmpq %rdx, %rax
	jnz .Lbb16
	jmp .Lbb19
.Lbb18:
	addq $1, %rax
	jmp .Lbb20
.Lbb19:
	movl $0, %eax
.Lbb20:
	leave
	ret
.type contains_long, @function
.size contains_long, .-contains_long
/* end function contains_long */

.text
push_delim:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq %rdi, %rbx
	addq $56, %rdi
	callq push_long
	movq %rbx, %rdi
	movq 64(%rdi), %rax
	addq $2, %rax
	popq %rbx
	leave
	ret
.type push_delim, @function
.size push_delim, .-push_delim
/* end function push_delim */

.text
pop_delim:
	pushq %rbp
	movq %rsp, %rbp
	addq $56, %rdi
	movl $8, %esi
	callq pop
	movl $1, %eax
	leave
	ret
.type pop_delim, @function
.size pop_delim, .-pop_delim
/* end function pop_delim */

.text
.globl bumpN
bumpN:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
.Lbb26:
	cmpl $0, %esi
	jz .Lbb28
	movq %rsi, %r12
	subq $1, %r12
	movq %rdi, %rbx
	callq bump
	movq %r12, %rsi
	movq %rbx, %rdi
	jmp .Lbb26
.Lbb28:
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
current_kind:
	pushq %rbp
	movq %rsp, %rbp
	movq 48(%rdi), %rdx
	movl $24, %esi
	callq get
	movq (%rax), %rax
	leave
	ret
.type current_kind, @function
.size current_kind, .-current_kind
/* end function current_kind */

.text
.globl kind_at_offset
kind_at_offset:
	pushq %rbp
	movq %rsp, %rbp
	movq 48(%rdi), %rax
	movq %rax, %rdx
	addq %rsi, %rdx
	movl $24, %esi
	callq get
	movq (%rax), %rax
	leave
	ret
.type kind_at_offset, @function
.size kind_at_offset, .-kind_at_offset
/* end function kind_at_offset */

.data
.balign 8
skipped_msg:
	.ascii "SKIPPED\n"
	.byte 0
/* end data */

.text
after_skipped:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movq 48(%rdi), %r12
	movq 8(%rdi), %r13
	movq %rdi, %r14
	addq $80, %r14
	movl $0, %ebx
.Lbb38:
	movq %rbx, %rax
	addq %r12, %rax
	cmpq %rax, %r13
	jz .Lbb41
	movq %rbx, %rsi
	movq %rdi, %r15
	callq kind_at_offset
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	movq %r14, %rdi
	callq contains_long
	movq %r15, %rdi
	cmpl $0, %eax
	jz .Lbb41
	addq $1, %rbx
	jmp .Lbb38
.Lbb41:
	movq %rbx, %rax
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type after_skipped, @function
.size after_skipped, .-after_skipped
/* end function after_skipped */

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
.globl missing
missing:
	pushq %rbp
	movq %rsp, %rbp
	subq $40, %rsp
	pushq %rbx
	addq $24, %rdi
	movq %rsi, %rbx
	movl $32, %esi
	callq last
	movq %rbx, %rsi
	movq %rax, %rdi
	addq $8, %rdi
	movq %rdi, %rbx
	leaq -32(%rbp), %rdi
	callq new_missing_node
	movq %rbx, %rdi
	movq %rax, %rdx
	movl $32, %esi
	callq push
	movl $1, %eax
	popq %rbx
	leave
	ret
.type missing, @function
.size missing, .-missing
/* end function missing */

.text
.globl bump_err
bump_err:
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
	movq %rax, %r12
	movq %rbx, %rax
	addq $1, %rax
	movq %rax, 48(%rdi)
	addq $24, %rdi
	movl $32, %esi
	callq last
	movq %rax, %rdi
	addq $8, %rdi
	movl $32, %esi
	movq %rdi, %rbx
	callq last
	movq %rbx, %rdi
	movq (%rax), %rcx
	cmpq $2, %rcx
	jz .Lbb51
	movq %rdi, %rbx
	leaq -32(%rbp), %rdi
	callq new_error_node
	movq %r12, %rdx
	movq %rbx, %rdi
	movq %rax, %r12
	movq %rdi, %rbx
	movq %r12, %rdi
	addq $8, %rdi
	movl $24, %esi
	callq push
	movq %r12, %rdx
	movq %rbx, %rdi
	movl $32, %esi
	callq push
	movl $1, %eax
	jmp .Lbb53
.Lbb51:
	movq %r12, %rdx
	movq %rax, %rdi
	addq $8, %rdi
	movl $24, %esi
	callq push
	movl $1, %eax
.Lbb53:
	popq %r12
	popq %rbx
	leave
	ret
.type bump_err, @function
.size bump_err, .-bump_err
/* end function bump_err */

.text
.globl default_state_ptr
default_state_ptr:
	pushq %rbp
	movq %rsp, %rbp
	subq $120, %rsp
	pushq %rbx
	movq %rsi, %rdx
	movq %rdi, %rsi
	leaq -104(%rbp), %rdi
	callq default_state
	movq %rax, %rbx
	movl $104, %edi
	callq malloc
	movq %rbx, %rsi
	movq %rax, %rbx
	movl $104, %edx
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
	subq $112, %rsp
	movq %rdi, %rax
	movq 0(%rsi), %rcx
	movq %rcx, -104(%rbp)
	movq 8(%rsi), %rcx
	movq %rcx, -96(%rbp)
	movq 16(%rsi), %rcx
	movq %rcx, -88(%rbp)
	movq 24(%rsi), %rcx
	movq %rcx, -80(%rbp)
	movq 32(%rsi), %rcx
	movq %rcx, -72(%rbp)
	movq 40(%rsi), %rcx
	movq %rcx, -64(%rbp)
	movq 48(%rsi), %rcx
	movq %rcx, -56(%rbp)
	movq 56(%rsi), %rcx
	movq %rcx, -48(%rbp)
	movq 64(%rsi), %rcx
	movq %rcx, -40(%rbp)
	movq 72(%rsi), %rcx
	movq %rcx, -32(%rbp)
	movq 80(%rsi), %rcx
	movq %rcx, -24(%rbp)
	movq 88(%rsi), %rcx
	movq %rcx, -16(%rbp)
	movq 96(%rsi), %rcx
	movq %rcx, -8(%rbp)
	movq -104(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -96(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -88(%rbp), %rcx
	movq %rcx, 16(%rax)
	movq -80(%rbp), %rcx
	movq %rcx, 24(%rax)
	movq -72(%rbp), %rcx
	movq %rcx, 32(%rax)
	movq -64(%rbp), %rcx
	movq %rcx, 40(%rax)
	movq -56(%rbp), %rcx
	movq %rcx, 48(%rax)
	movq -48(%rbp), %rcx
	movq %rcx, 56(%rax)
	movq -40(%rbp), %rcx
	movq %rcx, 64(%rax)
	movq -32(%rbp), %rcx
	movq %rcx, 72(%rax)
	movq -24(%rbp), %rcx
	movq %rcx, 80(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 88(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 96(%rax)
	leave
	ret
.type get_state, @function
.size get_state, .-get_state
/* end function get_state */

.text
.globl last
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
	subq $136, %rsp
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
	leaq -128(%rbp), %rdi
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
	movq 48(%rcx), %rdx
	movq %rdx, 48(%rax)
	movq 56(%rcx), %rdx
	movq %rdx, 56(%rax)
	movq 64(%rcx), %rdx
	movq %rdx, 64(%rax)
	movq 72(%rcx), %rdx
	movq %rdx, 72(%rax)
	movq 80(%rcx), %rdx
	movq %rdx, 80(%rax)
	movq 88(%rcx), %rdx
	movq %rdx, 88(%rax)
	movq 96(%rcx), %rcx
	movq %rcx, 96(%rax)
	popq %rbx
	leave
	ret
.type default_state, @function
.size default_state, .-default_state
/* end function default_state */

.text
new_state:
	pushq %rbp
	movq %rsp, %rbp
	subq $216, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq %rdi, %r13
	movl root_group_id(%rip), %esi
	leaq -136(%rbp), %rdi
	callq new_group_node
	movq %rax, %rbx
	movl $32, %esi
	leaq -160(%rbp), %rdi
	callq new_vec
	movq %rbx, %rdx
	movq %rax, %r12
	movl $32, %esi
	movq %r12, %rdi
	callq push
	movl $8, %esi
	leaq -184(%rbp), %rdi
	callq new_vec
	movq %rax, %rbx
	movl $8, %esi
	leaq -208(%rbp), %rdi
	callq new_vec
	movq %rax, %rcx
	movq %r13, %rax
	movq 16(%rbp), %rdx
	movq %rdx, -104(%rbp)
	movq 24(%rbp), %rdx
	movq %rdx, -96(%rbp)
	movq 32(%rbp), %rdx
	movq %rdx, -88(%rbp)
	movq 0(%r12), %rdx
	movq %rdx, -80(%rbp)
	movq 8(%r12), %rdx
	movq %rdx, -72(%rbp)
	movq 16(%r12), %rdx
	movq %rdx, -64(%rbp)
	movq 0(%rbx), %rdx
	movq %rdx, -48(%rbp)
	movq 8(%rbx), %rdx
	movq %rdx, -40(%rbp)
	movq 16(%rbx), %rdx
	movq %rdx, -32(%rbp)
	movq 0(%rcx), %rdx
	movq %rdx, -24(%rbp)
	movq 8(%rcx), %rdx
	movq %rdx, -16(%rbp)
	movq 16(%rcx), %rcx
	movq %rcx, -8(%rbp)
	movq $0, -56(%rbp)
	movq -104(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -96(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -88(%rbp), %rcx
	movq %rcx, 16(%rax)
	movq -80(%rbp), %rcx
	movq %rcx, 24(%rax)
	movq -72(%rbp), %rcx
	movq %rcx, 32(%rax)
	movq -64(%rbp), %rcx
	movq %rcx, 40(%rax)
	movq -56(%rbp), %rcx
	movq %rcx, 48(%rax)
	movq -48(%rbp), %rcx
	movq %rcx, 56(%rax)
	movq -40(%rbp), %rcx
	movq %rcx, 64(%rax)
	movq -32(%rbp), %rcx
	movq %rcx, 72(%rax)
	movq -24(%rbp), %rcx
	movq %rcx, 80(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 88(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 96(%rax)
	popq %r13
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
.globl new_token_node
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
.globl new_missing_node
new_missing_node:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	movq %rdi, %rax
	movq 0(%rsi), %rcx
	movq %rcx, -24(%rbp)
	movq 8(%rsi), %rcx
	movq %rcx, -16(%rbp)
	movq 16(%rsi), %rcx
	movq %rcx, -8(%rbp)
	movl $3, -32(%rbp)
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
.type new_missing_node, @function
.size new_missing_node, .-new_missing_node
/* end function new_missing_node */

.text
.globl new_group_node
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
.globl new_error_node
new_error_node:
	pushq %rbp
	movq %rsp, %rbp
	subq $72, %rsp
	pushq %rbx
	movq %rdi, %rbx
	movl $24, %esi
	leaq -56(%rbp), %rdi
	callq new_vec
	movq %rax, %rcx
	movq %rbx, %rax
	movq 0(%rcx), %rdx
	movq %rdx, -24(%rbp)
	movq 8(%rcx), %rdx
	movq %rdx, -16(%rbp)
	movq 16(%rcx), %rcx
	movq %rcx, -8(%rbp)
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
.globl new_token
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
.globl pop
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
.globl push_long
push_long:
	pushq %rbp
	movq %rsp, %rbp
	subq $24, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movq %rsi, %r13
	movq %rdi, %rbx
	addq $8, %rbx
	movq %rbx, -16(%rbp)
	movq %rdi, %rax
	addq $16, %rax
	movq %rax, -8(%rbp)
	movq (%rdi), %r15
	movq 8(%rdi), %r12
	movq 16(%rdi), %rax
	cmpq %rax, %r12
	jz .Lbb84
	movq %r13, %rsi
	movq %rbx, %r13
	movq %r15, %rbx
	jmp .Lbb85
.Lbb84:
	imulq $4, %rax, %r14
	movq %rdi, %rbx
	imulq $8, %r14, %rdi
	callq malloc
	movq %r13, %rsi
	movq %rbx, %rdi
	movq %rax, %rbx
	movq -8(%rbp), %rax
	movq -16(%rbp), %r13
	movq %r14, (%rax)
	movq %rbx, (%rdi)
	imulq $8, %r12, %rdx
	movq %rsi, %r14
	movq %r15, %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r15, %rdi
	callq free
	movq %r14, %rsi
.Lbb85:
	movq %r12, %rax
	addq $1, %rax
	movq %rax, (%r13)
	movq %rsi, (%rbx, %r12, 8)
	movl $1, %eax
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type push_long, @function
.size push_long, .-push_long
/* end function push_long */

.text
.globl push
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
	jz .Lbb89
	movq %r15, %rdx
	xchgq %r13, %rbx
	jmp .Lbb90
.Lbb89:
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
.Lbb90:
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
	jz .Lbb103
	movl $101, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb103
	movl $108, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb103
	movl $101, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb103
	movl $99, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb103
	movl $116, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb104
.Lbb103:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb105
.Lbb104:
	movl $1, %eax
.Lbb105:
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
	jnz .Lbb109
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb110
.Lbb109:
	movq offset_ptr(%rip), %rax
	movq %rax, group_end(%rip)
	movl $1, %eax
.Lbb110:
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
	jnz .Lbb113
	movl $0, %eax
	jmp .Lbb114
.Lbb113:
	callq inc_offset
	movl $1, %eax
.Lbb114:
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
	jnz .Lbb117
	movl $0, %eax
	jmp .Lbb118
.Lbb117:
	callq inc_offset
	movl $1, %eax
.Lbb118:
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
	jnz .Lbb121
	movl $0, %eax
	jmp .Lbb122
.Lbb121:
	callq inc_offset
	movl $1, %eax
.Lbb122:
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
	jnz .Lbb125
	movl $0, %eax
	jmp .Lbb126
.Lbb125:
	callq inc_offset
	movl $1, %eax
.Lbb126:
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
	jnz .Lbb133
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_5
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb133
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_6
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb133
	callq lex_7
	cmpl $0, %eax
	jnz .Lbb133
	callq inc_offset
	movl $1, %eax
	jmp .Lbb134
.Lbb133:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb134:
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
	jz .Lbb138
	callq lex_3
	cmpl $0, %eax
	jnz .Lbb139
.Lbb138:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb140
.Lbb139:
	movl $1, %eax
.Lbb140:
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
	jnz .Lbb143
	movl $0, %eax
	jmp .Lbb145
.Lbb143:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb145
	movq offset_ptr(%rip), %rax
.Lbb145:
	leave
	ret
.type lex_select, @function
.size lex_select, .-lex_select
/* end function lex_select */

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
	jz .Lbb151
	movl $114, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb151
	movl $111, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb151
	movl $109, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb152
.Lbb151:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb153
.Lbb152:
	movl $1, %eax
.Lbb153:
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
	jnz .Lbb157
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb158
.Lbb157:
	movq offset_ptr(%rip), %rax
	movq %rax, group_end(%rip)
	movl $1, %eax
.Lbb158:
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
	jnz .Lbb161
	movl $0, %eax
	jmp .Lbb162
.Lbb161:
	callq inc_offset
	movl $1, %eax
.Lbb162:
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
	jnz .Lbb165
	movl $0, %eax
	jmp .Lbb166
.Lbb165:
	callq inc_offset
	movl $1, %eax
.Lbb166:
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
	jnz .Lbb169
	movl $0, %eax
	jmp .Lbb170
.Lbb169:
	callq inc_offset
	movl $1, %eax
.Lbb170:
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
	jnz .Lbb173
	movl $0, %eax
	jmp .Lbb174
.Lbb173:
	callq inc_offset
	movl $1, %eax
.Lbb174:
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
	jnz .Lbb181
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_13
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb181
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_14
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb181
	callq lex_15
	cmpl $0, %eax
	jnz .Lbb181
	callq inc_offset
	movl $1, %eax
	jmp .Lbb182
.Lbb181:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb182:
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
	jz .Lbb186
	callq lex_11
	cmpl $0, %eax
	jnz .Lbb187
.Lbb186:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb188
.Lbb187:
	movl $1, %eax
.Lbb188:
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
	jnz .Lbb191
	movl $0, %eax
	jmp .Lbb193
.Lbb191:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb193
	movq offset_ptr(%rip), %rax
.Lbb193:
	leave
	ret
.type lex_from, @function
.size lex_from, .-lex_from
/* end function lex_from */

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
	jz .Lbb201
	movl $101, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb201
	movl $108, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb201
	movl $101, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb201
	movl $116, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb201
	movl $101, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb202
.Lbb201:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb203
.Lbb202:
	movl $1, %eax
.Lbb203:
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
	jnz .Lbb207
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb208
.Lbb207:
	movq offset_ptr(%rip), %rax
	movq %rax, group_end(%rip)
	movl $1, %eax
.Lbb208:
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
	jnz .Lbb211
	movl $0, %eax
	jmp .Lbb212
.Lbb211:
	callq inc_offset
	movl $1, %eax
.Lbb212:
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
	jnz .Lbb215
	movl $0, %eax
	jmp .Lbb216
.Lbb215:
	callq inc_offset
	movl $1, %eax
.Lbb216:
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
	jnz .Lbb219
	movl $0, %eax
	jmp .Lbb220
.Lbb219:
	callq inc_offset
	movl $1, %eax
.Lbb220:
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
	jnz .Lbb223
	movl $0, %eax
	jmp .Lbb224
.Lbb223:
	callq inc_offset
	movl $1, %eax
.Lbb224:
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
	jnz .Lbb231
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_21
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb231
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_22
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb231
	callq lex_23
	cmpl $0, %eax
	jnz .Lbb231
	callq inc_offset
	movl $1, %eax
	jmp .Lbb232
.Lbb231:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb232:
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
	jz .Lbb236
	callq lex_19
	cmpl $0, %eax
	jnz .Lbb237
.Lbb236:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb238
.Lbb237:
	movl $1, %eax
.Lbb238:
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
	jnz .Lbb241
	movl $0, %eax
	jmp .Lbb243
.Lbb241:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb243
	movq offset_ptr(%rip), %rax
.Lbb243:
	leave
	ret
.type lex_delete, @function
.size lex_delete, .-lex_delete
/* end function lex_delete */

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
	jnz .Lbb246
	movl $0, %eax
	jmp .Lbb247
.Lbb246:
	callq inc_offset
	movl $1, %eax
.Lbb247:
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
	jnz .Lbb251
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb252
.Lbb251:
	movl $1, %eax
.Lbb252:
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
	jz .Lbb258
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_25
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb258
.Lbb255:
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jz .Lbb257
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_25
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb255
.Lbb257:
	movl $1, %eax
	jmp .Lbb259
.Lbb258:
	movl $0, %eax
.Lbb259:
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
	jnz .Lbb263
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb264
.Lbb263:
	movl $1, %eax
.Lbb264:
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
	jnz .Lbb267
	movl $0, %eax
	jmp .Lbb269
.Lbb267:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb269
	movq offset_ptr(%rip), %rax
.Lbb269:
	leave
	ret
.type lex_NUM, @function
.size lex_NUM, .-lex_NUM
/* end function lex_NUM */

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
	jnz .Lbb273
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb274
.Lbb273:
	movl $1, %eax
.Lbb274:
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
	jnz .Lbb277
	movl $0, %eax
	jmp .Lbb278
.Lbb277:
	callq inc_offset
	movl $1, %eax
.Lbb278:
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
	jnz .Lbb282
	callq inc_offset
	movl $1, %eax
	jmp .Lbb283
.Lbb282:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb283:
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
.Lbb285:
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_30
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb287
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jnz .Lbb285
.Lbb287:
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
	jnz .Lbb292
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb293
.Lbb292:
	movl $1, %eax
.Lbb293:
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
	jz .Lbb298
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_32
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb298
	callq lex_33
	cmpl $0, %eax
	jnz .Lbb299
.Lbb298:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb300
.Lbb299:
	movl $1, %eax
.Lbb300:
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
	jnz .Lbb303
	movl $0, %eax
	jmp .Lbb305
.Lbb303:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb305
	movq offset_ptr(%rip), %rax
.Lbb305:
	leave
	ret
.type lex_STR, @function
.size lex_STR, .-lex_STR
/* end function lex_STR */

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
	jnz .Lbb308
	movl $0, %eax
	jmp .Lbb309
.Lbb308:
	callq inc_offset
	movl $1, %eax
.Lbb309:
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
	jz .Lbb315
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_35
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb315
.Lbb312:
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jz .Lbb314
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_35
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb312
.Lbb314:
	movl $1, %eax
	jmp .Lbb316
.Lbb315:
	movl $0, %eax
.Lbb316:
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
	jnz .Lbb320
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb321
.Lbb320:
	movl $1, %eax
.Lbb321:
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
	jnz .Lbb324
	movl $0, %eax
	jmp .Lbb326
.Lbb324:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb326
	movq offset_ptr(%rip), %rax
.Lbb326:
	leave
	ret
.type lex_WHITESPACE, @function
.size lex_WHITESPACE, .-lex_WHITESPACE
/* end function lex_WHITESPACE */

.text
lex_39:
	pushq %rbp
	movq %rsp, %rbp
	movl $95, %edx
	callq cmp_current
	cmpl $0, %eax
	jnz .Lbb329
	movl $0, %eax
	jmp .Lbb330
.Lbb329:
	callq inc_offset
	movl $1, %eax
.Lbb330:
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
	jnz .Lbb333
	movl $0, %eax
	jmp .Lbb334
.Lbb333:
	callq inc_offset
	movl $1, %eax
.Lbb334:
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
	jnz .Lbb337
	movl $0, %eax
	jmp .Lbb338
.Lbb337:
	callq inc_offset
	movl $1, %eax
.Lbb338:
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
	jnz .Lbb344
	movq %rbx, offset_ptr(%rip)
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_40
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb344
	movq %rbx, offset_ptr(%rip)
	callq lex_41
	cmpl $0, %eax
	jnz .Lbb344
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb345
.Lbb344:
	movl $1, %eax
.Lbb345:
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
	jz .Lbb351
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_38
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb351
.Lbb348:
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jz .Lbb350
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_38
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb348
.Lbb350:
	movl $1, %eax
	jmp .Lbb352
.Lbb351:
	movl $0, %eax
.Lbb352:
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
	jnz .Lbb356
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb357
.Lbb356:
	movl $1, %eax
.Lbb357:
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
	jnz .Lbb360
	movl $0, %eax
	jmp .Lbb362
.Lbb360:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb362
	movq offset_ptr(%rip), %rax
.Lbb362:
	leave
	ret
.type lex_IDENT, @function
.size lex_IDENT, .-lex_IDENT
/* end function lex_IDENT */

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
	jnz .Lbb366
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb367
.Lbb366:
	movl $1, %eax
.Lbb367:
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
	jnz .Lbb371
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb372
.Lbb371:
	movl $1, %eax
.Lbb372:
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
	jnz .Lbb375
	movl $0, %eax
	jmp .Lbb377
.Lbb375:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb377
	movq offset_ptr(%rip), %rax
.Lbb377:
	leave
	ret
.type lex_COLON, @function
.size lex_COLON, .-lex_COLON
/* end function lex_COLON */

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
	jnz .Lbb381
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb382
.Lbb381:
	movl $1, %eax
.Lbb382:
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
	jnz .Lbb386
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb387
.Lbb386:
	movl $1, %eax
.Lbb387:
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
	jnz .Lbb390
	movl $0, %eax
	jmp .Lbb392
.Lbb390:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb392
	movq offset_ptr(%rip), %rax
.Lbb392:
	leave
	ret
.type lex_COMMA, @function
.size lex_COMMA, .-lex_COMMA
/* end function lex_COMMA */

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
	jnz .Lbb396
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb397
.Lbb396:
	movl $1, %eax
.Lbb397:
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
	jnz .Lbb401
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb402
.Lbb401:
	movl $1, %eax
.Lbb402:
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
	jnz .Lbb405
	movl $0, %eax
	jmp .Lbb407
.Lbb405:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb407
	movq offset_ptr(%rip), %rax
.Lbb407:
	leave
	ret
.type lex_SEMI, @function
.size lex_SEMI, .-lex_SEMI
/* end function lex_SEMI */

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
	jnz .Lbb411
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb412
.Lbb411:
	movl $1, %eax
.Lbb412:
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
	jnz .Lbb416
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb417
.Lbb416:
	movl $1, %eax
.Lbb417:
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
	jnz .Lbb420
	movl $0, %eax
	jmp .Lbb422
.Lbb420:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb422
	movq offset_ptr(%rip), %rax
.Lbb422:
	leave
	ret
.type lex_PLUS, @function
.size lex_PLUS, .-lex_PLUS
/* end function lex_PLUS */

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
	jnz .Lbb426
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb427
.Lbb426:
	movl $1, %eax
.Lbb427:
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
	jnz .Lbb431
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb432
.Lbb431:
	movl $1, %eax
.Lbb432:
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
	jnz .Lbb435
	movl $0, %eax
	jmp .Lbb437
.Lbb435:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb437
	movq offset_ptr(%rip), %rax
.Lbb437:
	leave
	ret
.type lex_TIMES, @function
.size lex_TIMES, .-lex_TIMES
/* end function lex_TIMES */

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
	jnz .Lbb441
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb442
.Lbb441:
	movl $1, %eax
.Lbb442:
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
	jnz .Lbb446
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb447
.Lbb446:
	movl $1, %eax
.Lbb447:
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
	jnz .Lbb450
	movl $0, %eax
	jmp .Lbb452
.Lbb450:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb452
	movq offset_ptr(%rip), %rax
.Lbb452:
	leave
	ret
.type lex_LParen, @function
.size lex_LParen, .-lex_LParen
/* end function lex_LParen */

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
	jnz .Lbb456
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb457
.Lbb456:
	movl $1, %eax
.Lbb457:
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
	jnz .Lbb461
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb462
.Lbb461:
	movl $1, %eax
.Lbb462:
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
	jnz .Lbb465
	movl $0, %eax
	jmp .Lbb467
.Lbb465:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb467
	movq offset_ptr(%rip), %rax
.Lbb467:
	leave
	ret
.type lex_RParen, @function
.size lex_RParen, .-lex_RParen
/* end function lex_RParen */

.text
lex_58:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rbx
	movl $33, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb471
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb472
.Lbb471:
	movl $1, %eax
.Lbb472:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_58, @function
.size lex_58, .-lex_58
/* end function lex_58 */

.text
lex_57:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_58
	cmpl $0, %eax
	jnz .Lbb476
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb477
.Lbb476:
	movl $1, %eax
.Lbb477:
	popq %rbx
	leave
	ret
.type lex_57, @function
.size lex_57, .-lex_57
/* end function lex_57 */

.text
lex_BANG:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_57
	cmpl $0, %eax
	jnz .Lbb480
	movl $0, %eax
	jmp .Lbb482
.Lbb480:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb482
	movq offset_ptr(%rip), %rax
.Lbb482:
	leave
	ret
.type lex_BANG, @function
.size lex_BANG, .-lex_BANG
/* end function lex_BANG */

.text
.globl lex
lex:
	pushq %rbp
	movq %rsp, %rbp
	subq $440, %rsp
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
.Lbb485:
	movq %rdx, %r14
	movq offset_ptr(%rip), %rax
	cmpq %r14, %rax
	jz .Lbb532
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_select
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb530
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_from
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb528
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_delete
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb526
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_NUM
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb524
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_STR
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb522
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_WHITESPACE
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb520
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_IDENT
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb518
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_COLON
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb516
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_COMMA
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb514
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_SEMI
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb512
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_PLUS
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb510
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_TIMES
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb508
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_LParen
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb506
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_RParen
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb504
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_BANG
	movq %r14, %rdx
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jz .Lbb502
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $14, %esi
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
	jmp .Lbb485
.Lbb502:
	movq %r12, %rdx
	movq -16(%rbp), %r12
	movq %rdx, %rcx
	addq $1, %rcx
	movl $15, %esi
	leaq -64(%rbp), %rdi
	callq new_token
	movq %rax, %rdx
	movl $24, %esi
	movq %rbx, %rdi
	callq push
	movq %r12, %rax
	movq $0, offset_ptr(%rip)
	movq $0, group_end(%rip)
	jmp .Lbb533
.Lbb504:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $13, %esi
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
	jmp .Lbb485
.Lbb506:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $12, %esi
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
	jmp .Lbb485
.Lbb508:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $11, %esi
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
	jmp .Lbb485
.Lbb510:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $10, %esi
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
	jmp .Lbb485
.Lbb512:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $9, %esi
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
	jmp .Lbb485
.Lbb514:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $8, %esi
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
	jmp .Lbb485
.Lbb516:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $7, %esi
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
	jmp .Lbb485
.Lbb518:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $6, %esi
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
	jmp .Lbb485
.Lbb520:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $5, %esi
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
	jmp .Lbb485
.Lbb522:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $4, %esi
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
	jmp .Lbb485
.Lbb524:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $3, %esi
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
	jmp .Lbb485
.Lbb526:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $2, %esi
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
	jmp .Lbb485
.Lbb528:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $1, %esi
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
	jmp .Lbb485
.Lbb530:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $0, %esi
	leaq -424(%rbp), %rdi
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
	jmp .Lbb485
.Lbb532:
	movq -16(%rbp), %rax
.Lbb533:
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
NUM_token_name:
	.ascii "NUM"
	.byte 0
/* end data */

.data
.balign 8
NUM_token_name_len:
	.quad 3
/* end data */

.data
.balign 8
STR_token_name:
	.ascii "STR"
	.byte 0
/* end data */

.data
.balign 8
STR_token_name_len:
	.quad 3
/* end data */

.data
.balign 8
WHITESPACE_token_name:
	.ascii "WHITESPACE"
	.byte 0
/* end data */

.data
.balign 8
WHITESPACE_token_name_len:
	.quad 10
/* end data */

.data
.balign 8
IDENT_token_name:
	.ascii "IDENT"
	.byte 0
/* end data */

.data
.balign 8
IDENT_token_name_len:
	.quad 5
/* end data */

.data
.balign 8
COLON_token_name:
	.ascii "COLON"
	.byte 0
/* end data */

.data
.balign 8
COLON_token_name_len:
	.quad 5
/* end data */

.data
.balign 8
COMMA_token_name:
	.ascii "COMMA"
	.byte 0
/* end data */

.data
.balign 8
COMMA_token_name_len:
	.quad 5
/* end data */

.data
.balign 8
SEMI_token_name:
	.ascii "SEMI"
	.byte 0
/* end data */

.data
.balign 8
SEMI_token_name_len:
	.quad 4
/* end data */

.data
.balign 8
PLUS_token_name:
	.ascii "PLUS"
	.byte 0
/* end data */

.data
.balign 8
PLUS_token_name_len:
	.quad 4
/* end data */

.data
.balign 8
TIMES_token_name:
	.ascii "TIMES"
	.byte 0
/* end data */

.data
.balign 8
TIMES_token_name_len:
	.quad 5
/* end data */

.data
.balign 8
LParen_token_name:
	.ascii "LParen"
	.byte 0
/* end data */

.data
.balign 8
LParen_token_name_len:
	.quad 6
/* end data */

.data
.balign 8
RParen_token_name:
	.ascii "RParen"
	.byte 0
/* end data */

.data
.balign 8
RParen_token_name_len:
	.quad 6
/* end data */

.data
.balign 8
BANG_token_name:
	.ascii "BANG"
	.byte 0
/* end data */

.data
.balign 8
BANG_token_name_len:
	.quad 4
/* end data */

.data
.balign 8
err_token_name:
	.ascii "token_error"
	.byte 0
/* end data */

.text
.globl token_name
token_name:
	pushq %rbp
	movq %rsp, %rbp
	cmpl $0, %edi
	leaq select_token_name(%rip), %rax
	jz .Lbb566
	cmpl $1, %edi
	leaq from_token_name(%rip), %rax
	jz .Lbb565
	cmpl $2, %edi
	leaq delete_token_name(%rip), %rax
	jz .Lbb564
	cmpl $3, %edi
	leaq NUM_token_name(%rip), %rax
	jz .Lbb563
	cmpl $4, %edi
	leaq STR_token_name(%rip), %rax
	jz .Lbb562
	cmpl $5, %edi
	leaq WHITESPACE_token_name(%rip), %rax
	jz .Lbb561
	cmpl $6, %edi
	leaq IDENT_token_name(%rip), %rax
	jz .Lbb560
	cmpl $7, %edi
	leaq COLON_token_name(%rip), %rax
	jz .Lbb559
	cmpl $8, %edi
	leaq COMMA_token_name(%rip), %rax
	jz .Lbb558
	cmpl $9, %edi
	leaq SEMI_token_name(%rip), %rax
	jz .Lbb557
	cmpl $10, %edi
	leaq PLUS_token_name(%rip), %rax
	jz .Lbb556
	cmpl $11, %edi
	leaq TIMES_token_name(%rip), %rax
	jz .Lbb555
	cmpl $12, %edi
	leaq LParen_token_name(%rip), %rax
	jz .Lbb554
	cmpl $13, %edi
	leaq RParen_token_name(%rip), %rax
	jz .Lbb553
	cmpl $14, %edi
	leaq BANG_token_name(%rip), %rax
	jz .Lbb552
	leaq err_token_name(%rip), %rax
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb567
.Lbb552:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb567
.Lbb553:
	movq %rax, %rdx
	movl $6, %eax
	jmp .Lbb567
.Lbb554:
	movq %rax, %rdx
	movl $6, %eax
	jmp .Lbb567
.Lbb555:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb567
.Lbb556:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb567
.Lbb557:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb567
.Lbb558:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb567
.Lbb559:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb567
.Lbb560:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb567
.Lbb561:
	movq %rax, %rdx
	movl $10, %eax
	jmp .Lbb567
.Lbb562:
	movq %rax, %rdx
	movl $3, %eax
	jmp .Lbb567
.Lbb563:
	movq %rax, %rdx
	movl $3, %eax
	jmp .Lbb567
.Lbb564:
	movq %rax, %rdx
	movl $6, %eax
	jmp .Lbb567
.Lbb565:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb567
.Lbb566:
	movq %rax, %rdx
	movl $6, %eax
.Lbb567:
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
.type token_name, @function
.size token_name, .-token_name
/* end function token_name */

.text
peak_by_id:
	pushq %rbp
	movq %rsp, %rbp
	cmpq $0, %rcx
	jz .Lbb611
	cmpq $1, %rcx
	jz .Lbb610
	cmpq $2, %rcx
	jz .Lbb609
	cmpq $3, %rcx
	jz .Lbb608
	cmpq $4, %rcx
	jz .Lbb607
	cmpq $5, %rcx
	jz .Lbb606
	cmpq $6, %rcx
	jz .Lbb605
	cmpq $7, %rcx
	jz .Lbb604
	cmpq $8, %rcx
	jz .Lbb603
	cmpq $9, %rcx
	jz .Lbb602
	cmpq $10, %rcx
	jz .Lbb601
	cmpq $11, %rcx
	jz .Lbb600
	cmpq $12, %rcx
	jz .Lbb599
	cmpq $13, %rcx
	jz .Lbb598
	cmpq $14, %rcx
	jz .Lbb597
	cmpq $15, %rcx
	jz .Lbb596
	cmpq $16, %rcx
	jz .Lbb595
	cmpq $17, %rcx
	jz .Lbb594
	cmpq $18, %rcx
	jz .Lbb593
	cmpq $19, %rcx
	jz .Lbb592
	cmpq $20, %rcx
	jz .Lbb591
	movl $0, %eax
	jmp .Lbb612
.Lbb591:
	callq peak_20
	jmp .Lbb612
.Lbb592:
	callq peak_19
	jmp .Lbb612
.Lbb593:
	callq peak_18
	jmp .Lbb612
.Lbb594:
	callq peak_17
	jmp .Lbb612
.Lbb595:
	callq peak_16
	jmp .Lbb612
.Lbb596:
	callq peak_15
	jmp .Lbb612
.Lbb597:
	callq peak_14
	jmp .Lbb612
.Lbb598:
	callq peak_13
	jmp .Lbb612
.Lbb599:
	callq peak_12
	jmp .Lbb612
.Lbb600:
	callq peak_11
	jmp .Lbb612
.Lbb601:
	callq peak_10
	jmp .Lbb612
.Lbb602:
	callq peak_9
	jmp .Lbb612
.Lbb603:
	callq peak_8
	jmp .Lbb612
.Lbb604:
	callq peak_7
	jmp .Lbb612
.Lbb605:
	callq peak_6
	jmp .Lbb612
.Lbb606:
	callq peak_5
	jmp .Lbb612
.Lbb607:
	callq peak_4
	jmp .Lbb612
.Lbb608:
	callq peak_3
	jmp .Lbb612
.Lbb609:
	callq peak_2
	jmp .Lbb612
.Lbb610:
	callq peak_1
	jmp .Lbb612
.Lbb611:
	callq peak_0
.Lbb612:
	leave
	ret
.type peak_by_id, @function
.size peak_by_id, .-peak_by_id
/* end function peak_by_id */

.text
parse_0:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb614:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb626
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $4, %rsi
	jz .Lbb625
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb619
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb614
.Lbb619:
	cmpl $0, %r12d
	jz .Lbb624
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb624
.Lbb621:
	subq $1, %rbx
	movq %rbx, %rdx
	movl $8, %esi
	movq %rdi, %r13
	movq %r12, %rdi
	callq get
	movq %r13, %rdi
	movq (%rax), %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r13
	callq peak_by_id
	movq %r13, %rdi
	cmpl $0, %eax
	jz .Lbb623
	cmpl $0, %ebx
	jz .Lbb624
	jmp .Lbb621
.Lbb623:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb627
.Lbb624:
	movl $1, %eax
	jmp .Lbb627
.Lbb625:
	callq bump
	movl $0, %eax
	jmp .Lbb627
.Lbb626:
	movl $2, %eax
.Lbb627:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_0, @function
.size parse_0, .-parse_0
/* end function parse_0 */

.text
peak_0:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %edx, %r12d
	movq %rsi, %r13
	movq %rdi, %rbx
	callq is_eof
	movq %r13, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb637
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $4, %rax
	jz .Lbb636
	cmpl $0, %edx
	jz .Lbb635
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb635
.Lbb632:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb634
	cmpl $0, %ebx
	jz .Lbb635
	jmp .Lbb632
.Lbb634:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb638
.Lbb635:
	movl $1, %eax
	jmp .Lbb638
.Lbb636:
	movl $0, %eax
	jmp .Lbb638
.Lbb637:
	movl $2, %eax
.Lbb638:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_0, @function
.size peak_0, .-peak_0
/* end function peak_0 */

.data
.balign 8
expected_0_data:
	.quad 0
	.quad 4
/* end data */

.text
expected_0:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $16, %edi
	callq malloc
	movq %rax, %rbx
	movl $16, %edx
	leaq expected_0_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $1, -16(%rbp)
	movq $1, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type expected_0, @function
.size expected_0, .-expected_0
/* end function expected_0 */

.text
parse_1:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movl $0, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rdi, %rbx
	callq parse_0
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb643
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb644
.Lbb643:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb644:
	popq %r12
	popq %rbx
	leave
	ret
.type parse_1, @function
.size parse_1, .-parse_1
/* end function parse_1 */

.text
peak_1:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_0
	leave
	ret
.type peak_1, @function
.size peak_1, .-peak_1
/* end function peak_1 */

.data
.balign 8
expected_1_data:
	.quad 1
	.quad 0
/* end data */

.text
expected_1:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $16, %edi
	callq malloc
	movq %rax, %rbx
	movl $16, %edx
	leaq expected_1_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $1, -16(%rbp)
	movq $1, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type expected_1, @function
.size expected_1, .-expected_1
/* end function expected_1 */

.text
parse_2:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb650:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb662
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $3, %rsi
	jz .Lbb661
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb655
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb650
.Lbb655:
	cmpl $0, %r12d
	jz .Lbb660
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb660
.Lbb657:
	subq $1, %rbx
	movq %rbx, %rdx
	movl $8, %esi
	movq %rdi, %r13
	movq %r12, %rdi
	callq get
	movq %r13, %rdi
	movq (%rax), %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r13
	callq peak_by_id
	movq %r13, %rdi
	cmpl $0, %eax
	jz .Lbb659
	cmpl $0, %ebx
	jz .Lbb660
	jmp .Lbb657
.Lbb659:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb663
.Lbb660:
	movl $1, %eax
	jmp .Lbb663
.Lbb661:
	callq bump
	movl $0, %eax
	jmp .Lbb663
.Lbb662:
	movl $2, %eax
.Lbb663:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_2, @function
.size parse_2, .-parse_2
/* end function parse_2 */

.text
peak_2:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %edx, %r12d
	movq %rsi, %r13
	movq %rdi, %rbx
	callq is_eof
	movq %r13, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb673
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $3, %rax
	jz .Lbb672
	cmpl $0, %edx
	jz .Lbb671
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb671
.Lbb668:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb670
	cmpl $0, %ebx
	jz .Lbb671
	jmp .Lbb668
.Lbb670:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb674
.Lbb671:
	movl $1, %eax
	jmp .Lbb674
.Lbb672:
	movl $0, %eax
	jmp .Lbb674
.Lbb673:
	movl $2, %eax
.Lbb674:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_2, @function
.size peak_2, .-peak_2
/* end function peak_2 */

.data
.balign 8
expected_2_data:
	.quad 0
	.quad 3
/* end data */

.text
expected_2:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $16, %edi
	callq malloc
	movq %rax, %rbx
	movl $16, %edx
	leaq expected_2_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $1, -16(%rbp)
	movq $1, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type expected_2, @function
.size expected_2, .-expected_2
/* end function expected_2 */

.text
parse_3:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movl $1, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rdi, %rbx
	callq parse_2
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb679
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb680
.Lbb679:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb680:
	popq %r12
	popq %rbx
	leave
	ret
.type parse_3, @function
.size parse_3, .-parse_3
/* end function parse_3 */

.text
peak_3:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_2
	leave
	ret
.type peak_3, @function
.size peak_3, .-peak_3
/* end function peak_3 */

.data
.balign 8
expected_3_data:
	.quad 1
	.quad 1
/* end data */

.text
expected_3:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $16, %edi
	callq malloc
	movq %rax, %rbx
	movl $16, %edx
	leaq expected_3_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $1, -16(%rbp)
	movq $1, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type expected_3, @function
.size expected_3, .-expected_3
/* end function expected_3 */

.text
parse_4:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb686:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb698
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $14, %rsi
	jz .Lbb697
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb691
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb686
.Lbb691:
	cmpl $0, %r12d
	jz .Lbb696
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb696
.Lbb693:
	subq $1, %rbx
	movq %rbx, %rdx
	movl $8, %esi
	movq %rdi, %r13
	movq %r12, %rdi
	callq get
	movq %r13, %rdi
	movq (%rax), %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r13
	callq peak_by_id
	movq %r13, %rdi
	cmpl $0, %eax
	jz .Lbb695
	cmpl $0, %ebx
	jz .Lbb696
	jmp .Lbb693
.Lbb695:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb699
.Lbb696:
	movl $1, %eax
	jmp .Lbb699
.Lbb697:
	callq bump
	movl $0, %eax
	jmp .Lbb699
.Lbb698:
	movl $2, %eax
.Lbb699:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_4, @function
.size parse_4, .-parse_4
/* end function parse_4 */

.text
peak_4:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %edx, %r12d
	movq %rsi, %r13
	movq %rdi, %rbx
	callq is_eof
	movq %r13, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb709
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $14, %rax
	jz .Lbb708
	cmpl $0, %edx
	jz .Lbb707
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb707
.Lbb704:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb706
	cmpl $0, %ebx
	jz .Lbb707
	jmp .Lbb704
.Lbb706:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb710
.Lbb707:
	movl $1, %eax
	jmp .Lbb710
.Lbb708:
	movl $0, %eax
	jmp .Lbb710
.Lbb709:
	movl $2, %eax
.Lbb710:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_4, @function
.size peak_4, .-peak_4
/* end function peak_4 */

.data
.balign 8
expected_4_data:
	.quad 0
	.quad 14
/* end data */

.text
expected_4:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $16, %edi
	callq malloc
	movq %rax, %rbx
	movl $16, %edx
	leaq expected_4_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $1, -16(%rbp)
	movq $1, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type expected_4, @function
.size expected_4, .-expected_4
/* end function expected_4 */

.text
parse_5:
	pushq %rbp
	movq %rsp, %rbp
	callq parse_4
	movl $0, %eax
	leave
	ret
.type parse_5, @function
.size parse_5, .-parse_5
/* end function parse_5 */

.text
peak_5:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_4
	leave
	ret
.type peak_5, @function
.size peak_5, .-peak_5
/* end function peak_5 */

.data
.balign 8
expected_5_data:
	.quad 0
	.quad 14
/* end data */

.text
expected_5:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $16, %edi
	callq malloc
	movq %rax, %rbx
	movl $16, %edx
	leaq expected_5_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $1, -16(%rbp)
	movq $1, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type expected_5, @function
.size expected_5, .-expected_5
/* end function expected_5 */

.text
parse_6:
	pushq %rbp
	movq %rsp, %rbp
	subq $88, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movq %rdi, %r12
	addq $56, %rdi
	movq 64(%r12), %rax
	movq %rax, %rbx
	addq $4, %rbx
	movl %esi, %r13d
	movl $5, %esi
	callq push_long
	movl %r13d, %esi
	movq %r12, %rdi
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_1
	movq %r12, %rdi
	movq %rax, %r12
	cmpl $0, %r12d
	jnz .Lbb734
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb723
	movl %r13d, %esi
	jmp .Lbb727
.Lbb723:
	cmpq $2, %rax
	jz .Lbb726
	movq %rax, %r14
	movq %rbx, %rax
	subq $1, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -72(%rbp), %rdi
	callq expected_1
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jz .Lbb730
	movl %r13d, %esi
	jmp .Lbb727
.Lbb726:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_1
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb727:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_5
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb729
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb727
.Lbb729:
	movq %r12, %rax
.Lbb730:
	cmpq $2, %rax
	jz .Lbb732
	movq %rbx, %rcx
	subq $1, %rcx
	cmpq %rcx, %rax
	jnz .Lbb733
.Lbb732:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_5
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb733:
	movl $0, %eax
	jmp .Lbb735
.Lbb734:
	movq %r12, %rax
.Lbb735:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_6, @function
.size parse_6, .-parse_6
/* end function parse_6 */

.text
peak_6:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_1
	leave
	ret
.type peak_6, @function
.size peak_6, .-peak_6
/* end function peak_6 */

.data
.balign 8
expected_6_data:
	.quad 1
	.quad 0
/* end data */

.text
expected_6:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $16, %edi
	callq malloc
	movq %rax, %rbx
	movl $16, %edx
	leaq expected_6_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $1, -16(%rbp)
	movq $1, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type expected_6, @function
.size expected_6, .-expected_6
/* end function expected_6 */

.text
parse_7:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_3
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb742
	callq parse_6
.Lbb742:
	popq %r12
	popq %rbx
	leave
	ret
.type parse_7, @function
.size parse_7, .-parse_7
/* end function parse_7 */

.text
peak_7:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %edx, %r13d
	movq %rsi, %r12
	movq %rdi, %rbx
	callq peak_3
	movl %r13d, %edx
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb745
	callq peak_6
.Lbb745:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_7, @function
.size peak_7, .-peak_7
/* end function peak_7 */

.data
.balign 8
expected_7_data:
	.quad 1
	.quad 1
	.quad 1
	.quad 0
/* end data */

.text
expected_7:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $32, %edi
	callq malloc
	movq %rax, %rbx
	movl $32, %edx
	leaq expected_7_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $2, -16(%rbp)
	movq $2, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type expected_7, @function
.size expected_7, .-expected_7
/* end function expected_7 */

.text
parse_8:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movl $2, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rdi, %rbx
	callq parse_7
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb750
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb751
.Lbb750:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb751:
	popq %r12
	popq %rbx
	leave
	ret
.type parse_8, @function
.size parse_8, .-parse_8
/* end function parse_8 */

.text
peak_8:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_7
	leave
	ret
.type peak_8, @function
.size peak_8, .-peak_8
/* end function peak_8 */

.data
.balign 8
expected_8_data:
	.quad 1
	.quad 2
/* end data */

.text
expected_8:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $16, %edi
	callq malloc
	movq %rax, %rbx
	movl $16, %edx
	leaq expected_8_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $1, -16(%rbp)
	movq $1, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type expected_8, @function
.size expected_8, .-expected_8
/* end function expected_8 */

.text
parse_9:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb757:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb769
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $8, %rsi
	jz .Lbb768
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb762
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb757
.Lbb762:
	cmpl $0, %r12d
	jz .Lbb767
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb767
.Lbb764:
	subq $1, %rbx
	movq %rbx, %rdx
	movl $8, %esi
	movq %rdi, %r13
	movq %r12, %rdi
	callq get
	movq %r13, %rdi
	movq (%rax), %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r13
	callq peak_by_id
	movq %r13, %rdi
	cmpl $0, %eax
	jz .Lbb766
	cmpl $0, %ebx
	jz .Lbb767
	jmp .Lbb764
.Lbb766:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb770
.Lbb767:
	movl $1, %eax
	jmp .Lbb770
.Lbb768:
	callq bump
	movl $0, %eax
	jmp .Lbb770
.Lbb769:
	movl $2, %eax
.Lbb770:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_9, @function
.size parse_9, .-parse_9
/* end function parse_9 */

.text
peak_9:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %edx, %r12d
	movq %rsi, %r13
	movq %rdi, %rbx
	callq is_eof
	movq %r13, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb780
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $8, %rax
	jz .Lbb779
	cmpl $0, %edx
	jz .Lbb778
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb778
.Lbb775:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb777
	cmpl $0, %ebx
	jz .Lbb778
	jmp .Lbb775
.Lbb777:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb781
.Lbb778:
	movl $1, %eax
	jmp .Lbb781
.Lbb779:
	movl $0, %eax
	jmp .Lbb781
.Lbb780:
	movl $2, %eax
.Lbb781:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_9, @function
.size peak_9, .-peak_9
/* end function peak_9 */

.data
.balign 8
expected_9_data:
	.quad 0
	.quad 8
/* end data */

.text
expected_9:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $16, %edi
	callq malloc
	movq %rax, %rbx
	movl $16, %edx
	leaq expected_9_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $1, -16(%rbp)
	movq $1, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type expected_9, @function
.size expected_9, .-expected_9
/* end function expected_9 */

.text
parse_10:
	pushq %rbp
	movq %rsp, %rbp
	subq $56, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movl %esi, %r12d
	movl $8, %esi
	movq %rdi, %rbx
	callq push_delim
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rax, %rbx
	movl %esi, %r13d
	movl $9, %esi
	movq %rdi, %r12
	callq push_delim
	movl %r13d, %esi
	movq %r12, %rdi
	movq %rax, %r12
	movl %esi, %r14d
	movq %rdi, %r13
	callq parse_8
	movl %r14d, %esi
	movq %r13, %rdi
	cmpl $0, %eax
	jnz .Lbb801
.Lbb785:
	movl %esi, %r14d
	movq %rdi, %r13
	callq parse_9
	movq %r13, %rdi
	cmpq $1, %rax
	jz .Lbb800
	cmpl $0, %eax
	jnz .Lbb788
	movl %r14d, %esi
	jmp .Lbb792
.Lbb788:
	cmpq $2, %rax
	jz .Lbb799
	cmpq %rax, %rbx
	jnz .Lbb799
	movq %rdi, %r13
	leaq -48(%rbp), %rdi
	callq expected_9
	movq %r13, %rdi
	movq %rax, %rsi
	movq %rdi, %r13
	callq missing
	movq %r13, %rdi
	movl %r14d, %esi
.Lbb792:
	movl %esi, %r14d
	movq %rdi, %r13
	callq parse_8
	movq %r13, %rdi
	movq %rax, %r13
	cmpq $1, %r13
	jnz .Lbb794
	movq %rdi, %r13
	callq bump_err
	movl %r14d, %esi
	movq %r13, %rdi
	jmp .Lbb792
.Lbb794:
	cmpl $0, %r13d
	jnz .Lbb796
	movl %r14d, %esi
	jmp .Lbb785
.Lbb796:
	movq %rdi, %r15
	leaq -24(%rbp), %rdi
	callq expected_8
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	cmpq $2, %r13
	jz .Lbb799
	cmpq %r13, %r12
	jnz .Lbb799
	movl %r14d, %esi
	jmp .Lbb785
.Lbb799:
	callq pop_delim
	movl $0, %eax
	jmp .Lbb803
.Lbb800:
	movq %rdi, %r13
	callq bump_err
	movl %r14d, %esi
	movq %r13, %rdi
	jmp .Lbb785
.Lbb801:
	movq %rax, %rbx
	callq pop_delim
	movq %rbx, %rax
.Lbb803:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_10, @function
.size parse_10, .-parse_10
/* end function parse_10 */

.text
peak_10:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_8
	leave
	ret
.type peak_10, @function
.size peak_10, .-peak_10
/* end function peak_10 */

.data
.balign 8
expected_10_data:
	.quad 1
	.quad 2
/* end data */

.text
expected_10:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $16, %edi
	callq malloc
	movq %rax, %rbx
	movl $16, %edx
	leaq expected_10_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $1, -16(%rbp)
	movq $1, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type expected_10, @function
.size expected_10, .-expected_10
/* end function expected_10 */

.text
parse_11:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movl $3, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rdi, %rbx
	callq parse_10
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb810
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb811
.Lbb810:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb811:
	popq %r12
	popq %rbx
	leave
	ret
.type parse_11, @function
.size parse_11, .-parse_11
/* end function parse_11 */

.text
peak_11:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_10
	leave
	ret
.type peak_11, @function
.size peak_11, .-peak_11
/* end function peak_11 */

.data
.balign 8
expected_11_data:
	.quad 1
	.quad 3
/* end data */

.text
expected_11:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $16, %edi
	callq malloc
	movq %rax, %rbx
	movl $16, %edx
	leaq expected_11_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $1, -16(%rbp)
	movq $1, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type expected_11, @function
.size expected_11, .-expected_11
/* end function expected_11 */

.text
parse_12:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb817:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb829
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $0, %rsi
	jz .Lbb828
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb822
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb817
.Lbb822:
	cmpl $0, %r12d
	jz .Lbb827
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb827
.Lbb824:
	subq $1, %rbx
	movq %rbx, %rdx
	movl $8, %esi
	movq %rdi, %r13
	movq %r12, %rdi
	callq get
	movq %r13, %rdi
	movq (%rax), %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r13
	callq peak_by_id
	movq %r13, %rdi
	cmpl $0, %eax
	jz .Lbb826
	cmpl $0, %ebx
	jz .Lbb827
	jmp .Lbb824
.Lbb826:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb830
.Lbb827:
	movl $1, %eax
	jmp .Lbb830
.Lbb828:
	callq bump
	movl $0, %eax
	jmp .Lbb830
.Lbb829:
	movl $2, %eax
.Lbb830:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_12, @function
.size parse_12, .-parse_12
/* end function parse_12 */

.text
peak_12:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %edx, %r12d
	movq %rsi, %r13
	movq %rdi, %rbx
	callq is_eof
	movq %r13, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb840
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $0, %rax
	jz .Lbb839
	cmpl $0, %edx
	jz .Lbb838
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb838
.Lbb835:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb837
	cmpl $0, %ebx
	jz .Lbb838
	jmp .Lbb835
.Lbb837:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb841
.Lbb838:
	movl $1, %eax
	jmp .Lbb841
.Lbb839:
	movl $0, %eax
	jmp .Lbb841
.Lbb840:
	movl $2, %eax
.Lbb841:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_12, @function
.size peak_12, .-peak_12
/* end function peak_12 */

.data
.balign 8
expected_12_data:
	.quad 0
	.quad 0
/* end data */

.text
expected_12:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $16, %edi
	callq malloc
	movq %rax, %rbx
	movl $16, %edx
	leaq expected_12_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $1, -16(%rbp)
	movq $1, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type expected_12, @function
.size expected_12, .-expected_12
/* end function expected_12 */

.text
parse_13:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb845:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb857
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $1, %rsi
	jz .Lbb856
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb850
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb845
.Lbb850:
	cmpl $0, %r12d
	jz .Lbb855
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb855
.Lbb852:
	subq $1, %rbx
	movq %rbx, %rdx
	movl $8, %esi
	movq %rdi, %r13
	movq %r12, %rdi
	callq get
	movq %r13, %rdi
	movq (%rax), %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r13
	callq peak_by_id
	movq %r13, %rdi
	cmpl $0, %eax
	jz .Lbb854
	cmpl $0, %ebx
	jz .Lbb855
	jmp .Lbb852
.Lbb854:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb858
.Lbb855:
	movl $1, %eax
	jmp .Lbb858
.Lbb856:
	callq bump
	movl $0, %eax
	jmp .Lbb858
.Lbb857:
	movl $2, %eax
.Lbb858:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_13, @function
.size parse_13, .-parse_13
/* end function parse_13 */

.text
peak_13:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %edx, %r12d
	movq %rsi, %r13
	movq %rdi, %rbx
	callq is_eof
	movq %r13, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb868
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $1, %rax
	jz .Lbb867
	cmpl $0, %edx
	jz .Lbb866
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb866
.Lbb863:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb865
	cmpl $0, %ebx
	jz .Lbb866
	jmp .Lbb863
.Lbb865:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb869
.Lbb866:
	movl $1, %eax
	jmp .Lbb869
.Lbb867:
	movl $0, %eax
	jmp .Lbb869
.Lbb868:
	movl $2, %eax
.Lbb869:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_13, @function
.size peak_13, .-peak_13
/* end function peak_13 */

.data
.balign 8
expected_13_data:
	.quad 0
	.quad 1
/* end data */

.text
expected_13:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $16, %edi
	callq malloc
	movq %rax, %rbx
	movl $16, %edx
	leaq expected_13_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $1, -16(%rbp)
	movq $1, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type expected_13, @function
.size expected_13, .-expected_13
/* end function expected_13 */

.text
parse_14:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb873:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb885
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $6, %rsi
	jz .Lbb884
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb878
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb873
.Lbb878:
	cmpl $0, %r12d
	jz .Lbb883
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb883
.Lbb880:
	subq $1, %rbx
	movq %rbx, %rdx
	movl $8, %esi
	movq %rdi, %r13
	movq %r12, %rdi
	callq get
	movq %r13, %rdi
	movq (%rax), %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r13
	callq peak_by_id
	movq %r13, %rdi
	cmpl $0, %eax
	jz .Lbb882
	cmpl $0, %ebx
	jz .Lbb883
	jmp .Lbb880
.Lbb882:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb886
.Lbb883:
	movl $1, %eax
	jmp .Lbb886
.Lbb884:
	callq bump
	movl $0, %eax
	jmp .Lbb886
.Lbb885:
	movl $2, %eax
.Lbb886:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_14, @function
.size parse_14, .-parse_14
/* end function parse_14 */

.text
peak_14:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %edx, %r12d
	movq %rsi, %r13
	movq %rdi, %rbx
	callq is_eof
	movq %r13, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb896
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $6, %rax
	jz .Lbb895
	cmpl $0, %edx
	jz .Lbb894
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb894
.Lbb891:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb893
	cmpl $0, %ebx
	jz .Lbb894
	jmp .Lbb891
.Lbb893:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb897
.Lbb894:
	movl $1, %eax
	jmp .Lbb897
.Lbb895:
	movl $0, %eax
	jmp .Lbb897
.Lbb896:
	movl $2, %eax
.Lbb897:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_14, @function
.size peak_14, .-peak_14
/* end function peak_14 */

.data
.balign 8
expected_14_data:
	.quad 0
	.quad 6
/* end data */

.text
expected_14:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $16, %edi
	callq malloc
	movq %rax, %rbx
	movl $16, %edx
	leaq expected_14_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $1, -16(%rbp)
	movq $1, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type expected_14, @function
.size expected_14, .-expected_14
/* end function expected_14 */

.text
parse_15:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb901:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb913
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $9, %rsi
	jz .Lbb912
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb906
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb901
.Lbb906:
	cmpl $0, %r12d
	jz .Lbb911
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb911
.Lbb908:
	subq $1, %rbx
	movq %rbx, %rdx
	movl $8, %esi
	movq %rdi, %r13
	movq %r12, %rdi
	callq get
	movq %r13, %rdi
	movq (%rax), %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r13
	callq peak_by_id
	movq %r13, %rdi
	cmpl $0, %eax
	jz .Lbb910
	cmpl $0, %ebx
	jz .Lbb911
	jmp .Lbb908
.Lbb910:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb914
.Lbb911:
	movl $1, %eax
	jmp .Lbb914
.Lbb912:
	callq bump
	movl $0, %eax
	jmp .Lbb914
.Lbb913:
	movl $2, %eax
.Lbb914:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_15, @function
.size parse_15, .-parse_15
/* end function parse_15 */

.text
peak_15:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %edx, %r12d
	movq %rsi, %r13
	movq %rdi, %rbx
	callq is_eof
	movq %r13, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb924
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $9, %rax
	jz .Lbb923
	cmpl $0, %edx
	jz .Lbb922
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb922
.Lbb919:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb921
	cmpl $0, %ebx
	jz .Lbb922
	jmp .Lbb919
.Lbb921:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb925
.Lbb922:
	movl $1, %eax
	jmp .Lbb925
.Lbb923:
	movl $0, %eax
	jmp .Lbb925
.Lbb924:
	movl $2, %eax
.Lbb925:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_15, @function
.size peak_15, .-peak_15
/* end function peak_15 */

.data
.balign 8
expected_15_data:
	.quad 0
	.quad 9
/* end data */

.text
expected_15:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $16, %edi
	callq malloc
	movq %rax, %rbx
	movl $16, %edx
	leaq expected_15_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $1, -16(%rbp)
	movq $1, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type expected_15, @function
.size expected_15, .-expected_15
/* end function expected_15 */

.text
parse_16:
	pushq %rbp
	movq %rsp, %rbp
	subq $232, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movq %rdi, %r12
	movq %r12, %rdi
	addq $56, %rdi
	movq 64(%r12), %rax
	movq %rax, %rbx
	addq $7, %rbx
	movl %esi, %r14d
	movl $15, %esi
	movq %rdi, %r13
	callq push_long
	movl %r14d, %esi
	movq %r13, %rdi
	movl %esi, %r14d
	movl $14, %esi
	movq %rdi, %r13
	callq push_long
	movl %r14d, %esi
	movq %r13, %rdi
	movl %esi, %r14d
	movl $13, %esi
	movq %rdi, %r13
	callq push_long
	movl %r14d, %esi
	movq %r13, %rdi
	movl %esi, %r13d
	movl $11, %esi
	callq push_long
	movl %r13d, %esi
	movq %r12, %rdi
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_12
	movq %r12, %rdi
	movq %rax, %r12
	cmpl $0, %r12d
	jnz .Lbb974
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb932
	movl %r13d, %esi
	jmp .Lbb938
.Lbb932:
	cmpq $2, %rax
	jz .Lbb936
	movq %rax, %r14
	movq %rbx, %rax
	subq $1, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -216(%rbp), %rdi
	callq expected_12
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jz .Lbb935
	movl %r13d, %esi
	jmp .Lbb938
.Lbb935:
	movq %rax, %r12
	jmp .Lbb942
.Lbb936:
	movq %rdi, %r12
	leaq -192(%rbp), %rdi
	callq expected_12
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movq %r12, %rdi
	movl %r13d, %esi
.Lbb938:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_11
	movl %r13d, %esi
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb941
	movl %esi, %r13d
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb938
.Lbb941:
	movl %esi, %r13d
.Lbb942:
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jz .Lbb947
	cmpq $2, %rax
	jz .Lbb946
	movq %rax, %r14
	movq %rbx, %rax
	subq $2, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -168(%rbp), %rdi
	callq expected_11
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jnz .Lbb947
	movq %rax, %r12
	jmp .Lbb951
.Lbb946:
	movq %rdi, %r12
	leaq -144(%rbp), %rdi
	callq expected_11
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movq %r12, %rdi
.Lbb947:
	movl %r13d, %esi
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_13
	movl %r13d, %esi
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb950
	movl %esi, %r13d
	movq %rdi, %r12
	callq bump_err
	movq %r12, %rdi
	jmp .Lbb947
.Lbb950:
	movl %esi, %r13d
.Lbb951:
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jz .Lbb956
	cmpq $2, %rax
	jz .Lbb955
	movq %rax, %r14
	movq %rbx, %rax
	subq $3, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -120(%rbp), %rdi
	callq expected_13
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jnz .Lbb956
	movq %rax, %r12
	jmp .Lbb960
.Lbb955:
	movq %rdi, %r12
	leaq -96(%rbp), %rdi
	callq expected_13
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movq %r12, %rdi
.Lbb956:
	movl %r13d, %esi
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_14
	movl %r13d, %esi
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb959
	movl %esi, %r13d
	movq %rdi, %r12
	callq bump_err
	movq %r12, %rdi
	jmp .Lbb956
.Lbb959:
	movl %esi, %r13d
.Lbb960:
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb962
	movl %r13d, %esi
	jmp .Lbb966
.Lbb962:
	cmpq $2, %rax
	jz .Lbb965
	movq %rax, %r14
	movq %rbx, %rax
	subq $4, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -72(%rbp), %rdi
	callq expected_14
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jz .Lbb970
	movl %r13d, %esi
	jmp .Lbb966
.Lbb965:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_14
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb966:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_15
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb969
	movq %rdi, %r12
	callq bump_err
	movq %r12, %rdi
	movl %r13d, %esi
	jmp .Lbb966
.Lbb969:
	movq %r12, %rax
.Lbb970:
	cmpq $2, %rax
	jz .Lbb972
	movq %rbx, %rcx
	subq $4, %rcx
	cmpq %rcx, %rax
	jnz .Lbb973
.Lbb972:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_15
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb973:
	movl $0, %eax
	jmp .Lbb975
.Lbb974:
	movq %r12, %rax
.Lbb975:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_16, @function
.size parse_16, .-parse_16
/* end function parse_16 */

.text
peak_16:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_12
	leave
	ret
.type peak_16, @function
.size peak_16, .-peak_16
/* end function peak_16 */

.data
.balign 8
expected_16_data:
	.quad 0
	.quad 0
/* end data */

.text
expected_16:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $16, %edi
	callq malloc
	movq %rax, %rbx
	movl $16, %edx
	leaq expected_16_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $1, -16(%rbp)
	movq $1, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type expected_16, @function
.size expected_16, .-expected_16
/* end function expected_16 */

.text
parse_17:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movl $4, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rdi, %rbx
	callq parse_16
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb982
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb983
.Lbb982:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb983:
	popq %r12
	popq %rbx
	leave
	ret
.type parse_17, @function
.size parse_17, .-parse_17
/* end function parse_17 */

.text
peak_17:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_16
	leave
	ret
.type peak_17, @function
.size peak_17, .-peak_17
/* end function peak_17 */

.data
.balign 8
expected_17_data:
	.quad 1
	.quad 4
/* end data */

.text
expected_17:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $16, %edi
	callq malloc
	movq %rax, %rbx
	movl $16, %edx
	leaq expected_17_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $1, -16(%rbp)
	movq $1, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type expected_17, @function
.size expected_17, .-expected_17
/* end function expected_17 */

.text
parse_18:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movl $17, %esi
	movq %rdi, %rbx
	callq push_delim
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_17
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb995
	movq %rdi, %rbx
	callq is_eof
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb994
.Lbb990:
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_17
	movq %rbx, %rdi
	cmpq $1, %rax
	jz .Lbb993
	cmpl $0, %eax
	jnz .Lbb994
	movl %r12d, %esi
	jmp .Lbb990
.Lbb993:
	movq %rdi, %rbx
	callq bump_err
	movl %r12d, %esi
	movq %rbx, %rdi
	jmp .Lbb990
.Lbb994:
	callq pop_delim
	movl $0, %eax
	jmp .Lbb996
.Lbb995:
	callq pop_delim
	movq %rbx, %rax
.Lbb996:
	popq %r12
	popq %rbx
	leave
	ret
.type parse_18, @function
.size parse_18, .-parse_18
/* end function parse_18 */

.text
peak_18:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_17
	leave
	ret
.type peak_18, @function
.size peak_18, .-peak_18
/* end function peak_18 */

.data
.balign 8
expected_18_data:
	.quad 1
	.quad 4
/* end data */

.text
expected_18:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $16, %edi
	callq malloc
	movq %rax, %rbx
	movl $16, %edx
	leaq expected_18_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $1, -16(%rbp)
	movq $1, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type expected_18, @function
.size expected_18, .-expected_18
/* end function expected_18 */

.text
parse_19:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb1002:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1014
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $5, %rsi
	jz .Lbb1013
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1007
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1002
.Lbb1007:
	cmpl $0, %r12d
	jz .Lbb1012
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1012
.Lbb1009:
	subq $1, %rbx
	movq %rbx, %rdx
	movl $8, %esi
	movq %rdi, %r13
	movq %r12, %rdi
	callq get
	movq %r13, %rdi
	movq (%rax), %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r13
	callq peak_by_id
	movq %r13, %rdi
	cmpl $0, %eax
	jz .Lbb1011
	cmpl $0, %ebx
	jz .Lbb1012
	jmp .Lbb1009
.Lbb1011:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1015
.Lbb1012:
	movl $1, %eax
	jmp .Lbb1015
.Lbb1013:
	callq bump
	movl $0, %eax
	jmp .Lbb1015
.Lbb1014:
	movl $2, %eax
.Lbb1015:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_19, @function
.size parse_19, .-parse_19
/* end function parse_19 */

.text
peak_19:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %edx, %r12d
	movq %rsi, %r13
	movq %rdi, %rbx
	callq is_eof
	movq %r13, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1025
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $5, %rax
	jz .Lbb1024
	cmpl $0, %edx
	jz .Lbb1023
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1023
.Lbb1020:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1022
	cmpl $0, %ebx
	jz .Lbb1023
	jmp .Lbb1020
.Lbb1022:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1026
.Lbb1023:
	movl $1, %eax
	jmp .Lbb1026
.Lbb1024:
	movl $0, %eax
	jmp .Lbb1026
.Lbb1025:
	movl $2, %eax
.Lbb1026:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_19, @function
.size peak_19, .-peak_19
/* end function peak_19 */

.data
.balign 8
expected_19_data:
	.quad 0
	.quad 5
/* end data */

.text
expected_19:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $16, %edi
	callq malloc
	movq %rax, %rbx
	movl $16, %edx
	leaq expected_19_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $1, -16(%rbp)
	movq $1, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type expected_19, @function
.size expected_19, .-expected_19
/* end function expected_19 */

.text
parse_20:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movq %rdi, %rbx
	callq after_skipped
	movq %rbx, %rdi
	movq %rax, %rsi
	movl $1, %edx
	movq %rdi, %rbx
	callq peak_18
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1033
	movl %esi, %r12d
	movl $5, %esi
	movq %rdi, %rbx
	callq skip
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rax, %r12
	movq %rdi, %rbx
	callq parse_18
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %r12d
	jnz .Lbb1032
	movq %rbx, %rax
	jmp .Lbb1033
.Lbb1032:
	movl $5, %esi
	callq unskip
	movq %rbx, %rax
.Lbb1033:
	popq %r12
	popq %rbx
	leave
	ret
.type parse_20, @function
.size parse_20, .-parse_20
/* end function parse_20 */

.text
peak_20:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_18
	leave
	ret
.type peak_20, @function
.size peak_20, .-peak_20
/* end function peak_20 */

.data
.balign 8
expected_20_data:
	.quad 1
	.quad 4
/* end data */

.text
expected_20:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $16, %edi
	callq malloc
	movq %rax, %rbx
	movl $16, %edx
	leaq expected_20_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $1, -16(%rbp)
	movq $1, -8(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
	popq %r12
	popq %rbx
	leave
	ret
.type expected_20, @function
.size expected_20, .-expected_20
/* end function expected_20 */

.data
.balign 8
root_group_id:
	.int 6
/* end data */

.text
.globl parse
parse:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
.Lbb1039:
	movl $1, %esi
	movq %rdi, %rbx
	callq parse_20
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1042
	cmpq $2, %rax
	jz .Lbb1042
	movq %rdi, %rbx
	callq bump_err
	movq %rbx, %rdi
	jmp .Lbb1039
.Lbb1042:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1044
	movq %rdi, %rbx
	callq bump_err
	movq %rbx, %rdi
	jmp .Lbb1042
.Lbb1044:
	movl $1, %eax
	popq %rbx
	leave
	ret
.type parse, @function
.size parse, .-parse
/* end function parse */

.data
.balign 8
string_group_name:
	.ascii "string"
	.byte 0
/* end data */

.data
.balign 8
string_group_name_len:
	.quad 6
/* end data */

.data
.balign 8
num_group_name:
	.ascii "num"
	.byte 0
/* end data */

.data
.balign 8
num_group_name_len:
	.quad 3
/* end data */

.data
.balign 8
literal_group_name:
	.ascii "literal"
	.byte 0
/* end data */

.data
.balign 8
literal_group_name_len:
	.quad 7
/* end data */

.data
.balign 8
args_group_name:
	.ascii "args"
	.byte 0
/* end data */

.data
.balign 8
args_group_name_len:
	.quad 4
/* end data */

.data
.balign 8
stmt_group_name:
	.ascii "stmt"
	.byte 0
/* end data */

.data
.balign 8
stmt_group_name_len:
	.quad 4
/* end data */

.data
.balign 8
_root_group_name:
	.ascii "_root"
	.byte 0
/* end data */

.data
.balign 8
_root_group_name_len:
	.quad 5
/* end data */

.data
.balign 8
root_group_name:
	.ascii "root"
	.byte 0
/* end data */

.data
.balign 8
root_group_name_len:
	.quad 4
/* end data */

.data
.balign 8
err_group_name:
	.ascii "group_error"
	.byte 0
/* end data */

.text
.globl group_name
group_name:
	pushq %rbp
	movq %rsp, %rbp
	cmpl $0, %edi
	leaq string_group_name(%rip), %rax
	jz .Lbb1061
	cmpl $1, %edi
	leaq num_group_name(%rip), %rax
	jz .Lbb1060
	cmpl $2, %edi
	leaq literal_group_name(%rip), %rax
	jz .Lbb1059
	cmpl $3, %edi
	leaq args_group_name(%rip), %rax
	jz .Lbb1058
	cmpl $4, %edi
	leaq stmt_group_name(%rip), %rax
	jz .Lbb1057
	cmpl $5, %edi
	leaq _root_group_name(%rip), %rax
	jz .Lbb1056
	cmpl $6, %edi
	leaq root_group_name(%rip), %rax
	jz .Lbb1055
	leaq err_group_name(%rip), %rax
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb1062
.Lbb1055:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb1062
.Lbb1056:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb1062
.Lbb1057:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb1062
.Lbb1058:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb1062
.Lbb1059:
	movq %rax, %rdx
	movl $7, %eax
	jmp .Lbb1062
.Lbb1060:
	movq %rax, %rdx
	movl $3, %eax
	jmp .Lbb1062
.Lbb1061:
	movq %rax, %rdx
	movl $6, %eax
.Lbb1062:
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
.type group_name, @function
.size group_name, .-group_name
/* end function group_name */

.section .note.GNU-stack,"",@progbits
