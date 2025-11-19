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
	movq (%rsi), %rax
	cmpl $0, %eax
	jnz .Lbb49
	movl $1, %eax
	jmp .Lbb50
.Lbb49:
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
.Lbb50:
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
	jz .Lbb53
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
	jmp .Lbb55
.Lbb53:
	movq %r12, %rdx
	movq %rax, %rdi
	addq $8, %rdi
	movl $24, %esi
	callq push
	movl $1, %eax
.Lbb55:
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
	jz .Lbb86
	movq %r13, %rsi
	movq %rbx, %r13
	movq %r15, %rbx
	jmp .Lbb87
.Lbb86:
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
.Lbb87:
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
	jz .Lbb91
	movq %r15, %rdx
	xchgq %r13, %rbx
	jmp .Lbb92
.Lbb91:
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
.Lbb92:
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
	jz .Lbb105
	movl $101, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb105
	movl $108, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb105
	movl $101, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb105
	movl $99, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb105
	movl $116, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb106
.Lbb105:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb107
.Lbb106:
	movl $1, %eax
.Lbb107:
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
	jnz .Lbb111
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb112
.Lbb111:
	movq offset_ptr(%rip), %rax
	movq %rax, group_end(%rip)
	movl $1, %eax
.Lbb112:
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
	jnz .Lbb115
	movl $0, %eax
	jmp .Lbb116
.Lbb115:
	callq inc_offset
	movl $1, %eax
.Lbb116:
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
	jnz .Lbb119
	movl $0, %eax
	jmp .Lbb120
.Lbb119:
	callq inc_offset
	movl $1, %eax
.Lbb120:
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
	jnz .Lbb123
	movl $0, %eax
	jmp .Lbb124
.Lbb123:
	callq inc_offset
	movl $1, %eax
.Lbb124:
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
	jnz .Lbb127
	movl $0, %eax
	jmp .Lbb128
.Lbb127:
	callq inc_offset
	movl $1, %eax
.Lbb128:
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
	jnz .Lbb135
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_5
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb135
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_6
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb135
	callq lex_7
	cmpl $0, %eax
	jnz .Lbb135
	callq inc_offset
	movl $1, %eax
	jmp .Lbb136
.Lbb135:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb136:
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
	jz .Lbb140
	callq lex_3
	cmpl $0, %eax
	jnz .Lbb141
.Lbb140:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb142
.Lbb141:
	movl $1, %eax
.Lbb142:
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
	jnz .Lbb145
	movl $0, %eax
	jmp .Lbb147
.Lbb145:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb147
	movq offset_ptr(%rip), %rax
.Lbb147:
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
	jz .Lbb153
	movl $114, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb153
	movl $111, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb153
	movl $109, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb154
.Lbb153:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb155
.Lbb154:
	movl $1, %eax
.Lbb155:
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
	jnz .Lbb159
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb160
.Lbb159:
	movq offset_ptr(%rip), %rax
	movq %rax, group_end(%rip)
	movl $1, %eax
.Lbb160:
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
	jnz .Lbb163
	movl $0, %eax
	jmp .Lbb164
.Lbb163:
	callq inc_offset
	movl $1, %eax
.Lbb164:
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
	jnz .Lbb167
	movl $0, %eax
	jmp .Lbb168
.Lbb167:
	callq inc_offset
	movl $1, %eax
.Lbb168:
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
	jnz .Lbb171
	movl $0, %eax
	jmp .Lbb172
.Lbb171:
	callq inc_offset
	movl $1, %eax
.Lbb172:
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
	jnz .Lbb175
	movl $0, %eax
	jmp .Lbb176
.Lbb175:
	callq inc_offset
	movl $1, %eax
.Lbb176:
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
	jnz .Lbb183
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_13
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb183
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_14
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb183
	callq lex_15
	cmpl $0, %eax
	jnz .Lbb183
	callq inc_offset
	movl $1, %eax
	jmp .Lbb184
.Lbb183:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb184:
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
	jz .Lbb188
	callq lex_11
	cmpl $0, %eax
	jnz .Lbb189
.Lbb188:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb190
.Lbb189:
	movl $1, %eax
.Lbb190:
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
	jnz .Lbb193
	movl $0, %eax
	jmp .Lbb195
.Lbb193:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb195
	movq offset_ptr(%rip), %rax
.Lbb195:
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
	jz .Lbb203
	movl $101, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb203
	movl $108, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb203
	movl $101, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb203
	movl $116, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb203
	movl $101, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb204
.Lbb203:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb205
.Lbb204:
	movl $1, %eax
.Lbb205:
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
	jnz .Lbb209
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb210
.Lbb209:
	movq offset_ptr(%rip), %rax
	movq %rax, group_end(%rip)
	movl $1, %eax
.Lbb210:
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
	jnz .Lbb213
	movl $0, %eax
	jmp .Lbb214
.Lbb213:
	callq inc_offset
	movl $1, %eax
.Lbb214:
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
	jnz .Lbb217
	movl $0, %eax
	jmp .Lbb218
.Lbb217:
	callq inc_offset
	movl $1, %eax
.Lbb218:
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
	jnz .Lbb221
	movl $0, %eax
	jmp .Lbb222
.Lbb221:
	callq inc_offset
	movl $1, %eax
.Lbb222:
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
	jnz .Lbb225
	movl $0, %eax
	jmp .Lbb226
.Lbb225:
	callq inc_offset
	movl $1, %eax
.Lbb226:
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
	jnz .Lbb233
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_21
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb233
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_22
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb233
	callq lex_23
	cmpl $0, %eax
	jnz .Lbb233
	callq inc_offset
	movl $1, %eax
	jmp .Lbb234
.Lbb233:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb234:
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
	jz .Lbb238
	callq lex_19
	cmpl $0, %eax
	jnz .Lbb239
.Lbb238:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb240
.Lbb239:
	movl $1, %eax
.Lbb240:
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
	jnz .Lbb243
	movl $0, %eax
	jmp .Lbb245
.Lbb243:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb245
	movq offset_ptr(%rip), %rax
.Lbb245:
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
	jnz .Lbb248
	movl $0, %eax
	jmp .Lbb249
.Lbb248:
	callq inc_offset
	movl $1, %eax
.Lbb249:
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
	jnz .Lbb253
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb254
.Lbb253:
	movl $1, %eax
.Lbb254:
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
	jz .Lbb260
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_25
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb260
.Lbb257:
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jz .Lbb259
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_25
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb257
.Lbb259:
	movl $1, %eax
	jmp .Lbb261
.Lbb260:
	movl $0, %eax
.Lbb261:
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
	jnz .Lbb265
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb266
.Lbb265:
	movl $1, %eax
.Lbb266:
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
	jnz .Lbb269
	movl $0, %eax
	jmp .Lbb271
.Lbb269:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb271
	movq offset_ptr(%rip), %rax
.Lbb271:
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
	jnz .Lbb275
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb276
.Lbb275:
	movl $1, %eax
.Lbb276:
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
	jnz .Lbb279
	movl $0, %eax
	jmp .Lbb280
.Lbb279:
	callq inc_offset
	movl $1, %eax
.Lbb280:
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
	jnz .Lbb284
	callq inc_offset
	movl $1, %eax
	jmp .Lbb285
.Lbb284:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb285:
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
.Lbb287:
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_30
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb289
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jnz .Lbb287
.Lbb289:
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
	jnz .Lbb294
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb295
.Lbb294:
	movl $1, %eax
.Lbb295:
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
	jz .Lbb300
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_32
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb300
	callq lex_33
	cmpl $0, %eax
	jnz .Lbb301
.Lbb300:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb302
.Lbb301:
	movl $1, %eax
.Lbb302:
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
	jnz .Lbb305
	movl $0, %eax
	jmp .Lbb307
.Lbb305:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb307
	movq offset_ptr(%rip), %rax
.Lbb307:
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
	jnz .Lbb310
	movl $0, %eax
	jmp .Lbb311
.Lbb310:
	callq inc_offset
	movl $1, %eax
.Lbb311:
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
	jz .Lbb317
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_35
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb317
.Lbb314:
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jz .Lbb316
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_35
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb314
.Lbb316:
	movl $1, %eax
	jmp .Lbb318
.Lbb317:
	movl $0, %eax
.Lbb318:
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
	jnz .Lbb322
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb323
.Lbb322:
	movl $1, %eax
.Lbb323:
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
	jnz .Lbb326
	movl $0, %eax
	jmp .Lbb328
.Lbb326:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb328
	movq offset_ptr(%rip), %rax
.Lbb328:
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
	jnz .Lbb331
	movl $0, %eax
	jmp .Lbb332
.Lbb331:
	callq inc_offset
	movl $1, %eax
.Lbb332:
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
	jnz .Lbb335
	movl $0, %eax
	jmp .Lbb336
.Lbb335:
	callq inc_offset
	movl $1, %eax
.Lbb336:
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
	jnz .Lbb339
	movl $0, %eax
	jmp .Lbb340
.Lbb339:
	callq inc_offset
	movl $1, %eax
.Lbb340:
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
	jnz .Lbb346
	movq %rbx, offset_ptr(%rip)
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_40
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb346
	movq %rbx, offset_ptr(%rip)
	callq lex_41
	cmpl $0, %eax
	jnz .Lbb346
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb347
.Lbb346:
	movl $1, %eax
.Lbb347:
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
	jz .Lbb353
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_38
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb353
.Lbb350:
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jz .Lbb352
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_38
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb350
.Lbb352:
	movl $1, %eax
	jmp .Lbb354
.Lbb353:
	movl $0, %eax
.Lbb354:
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
	jnz .Lbb358
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb359
.Lbb358:
	movl $1, %eax
.Lbb359:
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
	jnz .Lbb362
	movl $0, %eax
	jmp .Lbb364
.Lbb362:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb364
	movq offset_ptr(%rip), %rax
.Lbb364:
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
	jnz .Lbb368
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb369
.Lbb368:
	movl $1, %eax
.Lbb369:
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
	jnz .Lbb373
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb374
.Lbb373:
	movl $1, %eax
.Lbb374:
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
	jnz .Lbb377
	movl $0, %eax
	jmp .Lbb379
.Lbb377:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb379
	movq offset_ptr(%rip), %rax
.Lbb379:
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
	jnz .Lbb383
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb384
.Lbb383:
	movl $1, %eax
.Lbb384:
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
	jnz .Lbb388
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb389
.Lbb388:
	movl $1, %eax
.Lbb389:
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
	jnz .Lbb392
	movl $0, %eax
	jmp .Lbb394
.Lbb392:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb394
	movq offset_ptr(%rip), %rax
.Lbb394:
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
	jnz .Lbb398
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb399
.Lbb398:
	movl $1, %eax
.Lbb399:
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
	jnz .Lbb403
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb404
.Lbb403:
	movl $1, %eax
.Lbb404:
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
	jnz .Lbb407
	movl $0, %eax
	jmp .Lbb409
.Lbb407:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb409
	movq offset_ptr(%rip), %rax
.Lbb409:
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
	jnz .Lbb413
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb414
.Lbb413:
	movl $1, %eax
.Lbb414:
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
	jnz .Lbb418
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb419
.Lbb418:
	movl $1, %eax
.Lbb419:
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
	jnz .Lbb422
	movl $0, %eax
	jmp .Lbb424
.Lbb422:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb424
	movq offset_ptr(%rip), %rax
.Lbb424:
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
	jnz .Lbb428
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb429
.Lbb428:
	movl $1, %eax
.Lbb429:
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
	jnz .Lbb433
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb434
.Lbb433:
	movl $1, %eax
.Lbb434:
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
	jnz .Lbb437
	movl $0, %eax
	jmp .Lbb439
.Lbb437:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb439
	movq offset_ptr(%rip), %rax
.Lbb439:
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
	jnz .Lbb443
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb444
.Lbb443:
	movl $1, %eax
.Lbb444:
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
	jnz .Lbb448
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb449
.Lbb448:
	movl $1, %eax
.Lbb449:
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
	jnz .Lbb452
	movl $0, %eax
	jmp .Lbb454
.Lbb452:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb454
	movq offset_ptr(%rip), %rax
.Lbb454:
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
	jnz .Lbb458
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb459
.Lbb458:
	movl $1, %eax
.Lbb459:
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
	jnz .Lbb463
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb464
.Lbb463:
	movl $1, %eax
.Lbb464:
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
	jnz .Lbb467
	movl $0, %eax
	jmp .Lbb469
.Lbb467:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb469
	movq offset_ptr(%rip), %rax
.Lbb469:
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
	jnz .Lbb473
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb474
.Lbb473:
	movl $1, %eax
.Lbb474:
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
	jnz .Lbb478
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb479
.Lbb478:
	movl $1, %eax
.Lbb479:
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
	jnz .Lbb482
	movl $0, %eax
	jmp .Lbb484
.Lbb482:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb484
	movq offset_ptr(%rip), %rax
.Lbb484:
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
.Lbb487:
	movq %rdx, %r14
	movq offset_ptr(%rip), %rax
	cmpq %r14, %rax
	jz .Lbb534
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_select
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb532
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_from
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb530
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_delete
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb528
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_NUM
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb526
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_STR
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb524
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_WHITESPACE
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb522
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_IDENT
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb520
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_COLON
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb518
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_COMMA
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb516
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_SEMI
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb514
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_PLUS
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb512
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_TIMES
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb510
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_LParen
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb508
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_RParen
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb506
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_BANG
	movq %r14, %rdx
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jz .Lbb504
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
	jmp .Lbb487
.Lbb504:
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
	jmp .Lbb535
.Lbb506:
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
	jmp .Lbb487
.Lbb508:
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
	jmp .Lbb487
.Lbb510:
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
	jmp .Lbb487
.Lbb512:
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
	jmp .Lbb487
.Lbb514:
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
	jmp .Lbb487
.Lbb516:
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
	jmp .Lbb487
.Lbb518:
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
	jmp .Lbb487
.Lbb520:
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
	jmp .Lbb487
.Lbb522:
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
	jmp .Lbb487
.Lbb524:
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
	jmp .Lbb487
.Lbb526:
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
	jmp .Lbb487
.Lbb528:
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
	jmp .Lbb487
.Lbb530:
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
	jmp .Lbb487
.Lbb532:
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
	jmp .Lbb487
.Lbb534:
	movq -16(%rbp), %rax
.Lbb535:
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
	jz .Lbb568
	cmpl $1, %edi
	leaq from_token_name(%rip), %rax
	jz .Lbb567
	cmpl $2, %edi
	leaq delete_token_name(%rip), %rax
	jz .Lbb566
	cmpl $3, %edi
	leaq NUM_token_name(%rip), %rax
	jz .Lbb565
	cmpl $4, %edi
	leaq STR_token_name(%rip), %rax
	jz .Lbb564
	cmpl $5, %edi
	leaq WHITESPACE_token_name(%rip), %rax
	jz .Lbb563
	cmpl $6, %edi
	leaq IDENT_token_name(%rip), %rax
	jz .Lbb562
	cmpl $7, %edi
	leaq COLON_token_name(%rip), %rax
	jz .Lbb561
	cmpl $8, %edi
	leaq COMMA_token_name(%rip), %rax
	jz .Lbb560
	cmpl $9, %edi
	leaq SEMI_token_name(%rip), %rax
	jz .Lbb559
	cmpl $10, %edi
	leaq PLUS_token_name(%rip), %rax
	jz .Lbb558
	cmpl $11, %edi
	leaq TIMES_token_name(%rip), %rax
	jz .Lbb557
	cmpl $12, %edi
	leaq LParen_token_name(%rip), %rax
	jz .Lbb556
	cmpl $13, %edi
	leaq RParen_token_name(%rip), %rax
	jz .Lbb555
	cmpl $14, %edi
	leaq BANG_token_name(%rip), %rax
	jz .Lbb554
	leaq err_token_name(%rip), %rax
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb569
.Lbb554:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb569
.Lbb555:
	movq %rax, %rdx
	movl $6, %eax
	jmp .Lbb569
.Lbb556:
	movq %rax, %rdx
	movl $6, %eax
	jmp .Lbb569
.Lbb557:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb569
.Lbb558:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb569
.Lbb559:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb569
.Lbb560:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb569
.Lbb561:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb569
.Lbb562:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb569
.Lbb563:
	movq %rax, %rdx
	movl $10, %eax
	jmp .Lbb569
.Lbb564:
	movq %rax, %rdx
	movl $3, %eax
	jmp .Lbb569
.Lbb565:
	movq %rax, %rdx
	movl $3, %eax
	jmp .Lbb569
.Lbb566:
	movq %rax, %rdx
	movl $6, %eax
	jmp .Lbb569
.Lbb567:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb569
.Lbb568:
	movq %rax, %rdx
	movl $6, %eax
.Lbb569:
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
	jz .Lbb621
	cmpq $1, %rcx
	jz .Lbb620
	cmpq $2, %rcx
	jz .Lbb619
	cmpq $3, %rcx
	jz .Lbb618
	cmpq $4, %rcx
	jz .Lbb617
	cmpq $5, %rcx
	jz .Lbb616
	cmpq $6, %rcx
	jz .Lbb615
	cmpq $7, %rcx
	jz .Lbb614
	cmpq $8, %rcx
	jz .Lbb613
	cmpq $9, %rcx
	jz .Lbb612
	cmpq $10, %rcx
	jz .Lbb611
	cmpq $11, %rcx
	jz .Lbb610
	cmpq $12, %rcx
	jz .Lbb609
	cmpq $13, %rcx
	jz .Lbb608
	cmpq $14, %rcx
	jz .Lbb607
	cmpq $15, %rcx
	jz .Lbb606
	cmpq $16, %rcx
	jz .Lbb605
	cmpq $17, %rcx
	jz .Lbb604
	cmpq $18, %rcx
	jz .Lbb603
	cmpq $19, %rcx
	jz .Lbb602
	cmpq $20, %rcx
	jz .Lbb601
	cmpq $21, %rcx
	jz .Lbb600
	cmpq $22, %rcx
	jz .Lbb599
	cmpq $23, %rcx
	jz .Lbb598
	cmpq $24, %rcx
	jz .Lbb597
	movl $0, %eax
	jmp .Lbb622
.Lbb597:
	callq peak_24
	jmp .Lbb622
.Lbb598:
	callq peak_23
	jmp .Lbb622
.Lbb599:
	callq peak_22
	jmp .Lbb622
.Lbb600:
	callq peak_21
	jmp .Lbb622
.Lbb601:
	callq peak_20
	jmp .Lbb622
.Lbb602:
	callq peak_19
	jmp .Lbb622
.Lbb603:
	callq peak_18
	jmp .Lbb622
.Lbb604:
	callq peak_17
	jmp .Lbb622
.Lbb605:
	callq peak_16
	jmp .Lbb622
.Lbb606:
	callq peak_15
	jmp .Lbb622
.Lbb607:
	callq peak_14
	jmp .Lbb622
.Lbb608:
	callq peak_13
	jmp .Lbb622
.Lbb609:
	callq peak_12
	jmp .Lbb622
.Lbb610:
	callq peak_11
	jmp .Lbb622
.Lbb611:
	callq peak_10
	jmp .Lbb622
.Lbb612:
	callq peak_9
	jmp .Lbb622
.Lbb613:
	callq peak_8
	jmp .Lbb622
.Lbb614:
	callq peak_7
	jmp .Lbb622
.Lbb615:
	callq peak_6
	jmp .Lbb622
.Lbb616:
	callq peak_5
	jmp .Lbb622
.Lbb617:
	callq peak_4
	jmp .Lbb622
.Lbb618:
	callq peak_3
	jmp .Lbb622
.Lbb619:
	callq peak_2
	jmp .Lbb622
.Lbb620:
	callq peak_1
	jmp .Lbb622
.Lbb621:
	callq peak_0
.Lbb622:
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
.Lbb624:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb636
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $4, %rsi
	jz .Lbb635
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb629
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb624
.Lbb629:
	cmpl $0, %r12d
	jz .Lbb634
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb634
.Lbb631:
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
	jz .Lbb633
	cmpl $0, %ebx
	jz .Lbb634
	jmp .Lbb631
.Lbb633:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb637
.Lbb634:
	movl $1, %eax
	jmp .Lbb637
.Lbb635:
	callq bump
	movl $0, %eax
	jmp .Lbb637
.Lbb636:
	movl $2, %eax
.Lbb637:
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
	jnz .Lbb647
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $4, %rax
	jz .Lbb646
	cmpl $0, %edx
	jz .Lbb645
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb645
.Lbb642:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb644
	cmpl $0, %ebx
	jz .Lbb645
	jmp .Lbb642
.Lbb644:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb648
.Lbb645:
	movl $1, %eax
	jmp .Lbb648
.Lbb646:
	movl $0, %eax
	jmp .Lbb648
.Lbb647:
	movl $2, %eax
.Lbb648:
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
	jnz .Lbb653
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb654
.Lbb653:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb654:
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
.Lbb660:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb672
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $3, %rsi
	jz .Lbb671
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb665
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb660
.Lbb665:
	cmpl $0, %r12d
	jz .Lbb670
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb670
.Lbb667:
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
	jz .Lbb669
	cmpl $0, %ebx
	jz .Lbb670
	jmp .Lbb667
.Lbb669:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb673
.Lbb670:
	movl $1, %eax
	jmp .Lbb673
.Lbb671:
	callq bump
	movl $0, %eax
	jmp .Lbb673
.Lbb672:
	movl $2, %eax
.Lbb673:
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
	jnz .Lbb683
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $3, %rax
	jz .Lbb682
	cmpl $0, %edx
	jz .Lbb681
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb681
.Lbb678:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb680
	cmpl $0, %ebx
	jz .Lbb681
	jmp .Lbb678
.Lbb680:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb684
.Lbb681:
	movl $1, %eax
	jmp .Lbb684
.Lbb682:
	movl $0, %eax
	jmp .Lbb684
.Lbb683:
	movl $2, %eax
.Lbb684:
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
	jnz .Lbb689
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb690
.Lbb689:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb690:
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
.Lbb696:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb708
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $14, %rsi
	jz .Lbb707
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb701
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb696
.Lbb701:
	cmpl $0, %r12d
	jz .Lbb706
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb706
.Lbb703:
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
	jz .Lbb705
	cmpl $0, %ebx
	jz .Lbb706
	jmp .Lbb703
.Lbb705:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb709
.Lbb706:
	movl $1, %eax
	jmp .Lbb709
.Lbb707:
	callq bump
	movl $0, %eax
	jmp .Lbb709
.Lbb708:
	movl $2, %eax
.Lbb709:
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
	jnz .Lbb719
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $14, %rax
	jz .Lbb718
	cmpl $0, %edx
	jz .Lbb717
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb717
.Lbb714:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb716
	cmpl $0, %ebx
	jz .Lbb717
	jmp .Lbb714
.Lbb716:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb720
.Lbb717:
	movl $1, %eax
	jmp .Lbb720
.Lbb718:
	movl $0, %eax
	jmp .Lbb720
.Lbb719:
	movl $2, %eax
.Lbb720:
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

.text
expected_5:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	movq %rdi, %rax
	movq $0, -24(%rbp)
	movq -24(%rbp), %rcx
	movq %rcx, 0(%rax)
	movq -16(%rbp), %rcx
	movq %rcx, 8(%rax)
	movq -8(%rbp), %rcx
	movq %rcx, 16(%rax)
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
	jnz .Lbb745
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb733
	movl %r13d, %esi
	jmp .Lbb737
.Lbb733:
	cmpq $2, %rax
	jz .Lbb736
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
	jz .Lbb740
	movl %r13d, %esi
	jmp .Lbb737
.Lbb736:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_1
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb737:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_5
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb739
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb737
.Lbb739:
	movq %r12, %rax
.Lbb740:
	cmpl $0, %eax
	jz .Lbb744
	cmpq $2, %rax
	jz .Lbb743
	movq %rbx, %rcx
	subq $1, %rcx
	cmpq %rcx, %rax
	jz .Lbb744
.Lbb743:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_5
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb744:
	movl $0, %eax
	jmp .Lbb746
.Lbb745:
	movq %r12, %rax
.Lbb746:
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
	jz .Lbb753
	callq parse_6
.Lbb753:
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
	jz .Lbb756
	callq peak_6
.Lbb756:
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
	jnz .Lbb761
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb762
.Lbb761:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb762:
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
.Lbb768:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb780
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $10, %rsi
	jz .Lbb779
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb773
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb768
.Lbb773:
	cmpl $0, %r12d
	jz .Lbb778
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb778
.Lbb775:
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
	callq bump
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
	jnz .Lbb791
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $10, %rax
	jz .Lbb790
	cmpl $0, %edx
	jz .Lbb789
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb789
.Lbb786:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb788
	cmpl $0, %ebx
	jz .Lbb789
	jmp .Lbb786
.Lbb788:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb792
.Lbb789:
	movl $1, %eax
	jmp .Lbb792
.Lbb790:
	movl $0, %eax
	jmp .Lbb792
.Lbb791:
	movl $2, %eax
.Lbb792:
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
	.quad 10
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
	movl $8, %esi
	callq push_long
	movl %r13d, %esi
	movq %r12, %rdi
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_9
	movq %r12, %rdi
	movq %rax, %r12
	cmpl $0, %r12d
	jnz .Lbb811
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb799
	movl %r13d, %esi
	jmp .Lbb803
.Lbb799:
	cmpq $2, %rax
	jz .Lbb802
	movq %rax, %r14
	movq %rbx, %rax
	subq $1, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -72(%rbp), %rdi
	callq expected_9
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jz .Lbb806
	movl %r13d, %esi
	jmp .Lbb803
.Lbb802:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_9
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb803:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_8
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb805
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb803
.Lbb805:
	movq %r12, %rax
.Lbb806:
	cmpl $0, %eax
	jz .Lbb810
	cmpq $2, %rax
	jz .Lbb809
	movq %rbx, %rcx
	subq $1, %rcx
	cmpq %rcx, %rax
	jz .Lbb810
.Lbb809:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_8
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb810:
	movl $0, %eax
	jmp .Lbb812
.Lbb811:
	movq %r12, %rax
.Lbb812:
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
	callq peak_9
	leave
	ret
.type peak_10, @function
.size peak_10, .-peak_10
/* end function peak_10 */

.data
.balign 8
expected_10_data:
	.quad 0
	.quad 10
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
	movl $10, %esi
	movq %rdi, %rbx
	callq push_delim
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_10
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb824
	movq %rdi, %rbx
	callq is_eof
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb823
.Lbb819:
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_10
	movq %rbx, %rdi
	cmpq $1, %rax
	jz .Lbb822
	cmpl $0, %eax
	jnz .Lbb823
	movl %r12d, %esi
	jmp .Lbb819
.Lbb822:
	movq %rdi, %rbx
	callq bump_err
	movl %r12d, %esi
	movq %rbx, %rdi
	jmp .Lbb819
.Lbb823:
	callq pop_delim
	movl $0, %eax
	jmp .Lbb825
.Lbb824:
	callq pop_delim
	movq %rbx, %rax
.Lbb825:
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
	.quad 0
	.quad 10
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
	subq $40, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movl %esi, %r12d
	movl $3, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_8
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb834
	movq %rdi, %rbx
	callq parse_11
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb833
	callq exit_group
	movq %rbx, %rax
	jmp .Lbb835
.Lbb833:
	addq $24, %rdi
	movl $32, %esi
	movq %rdi, %rbx
	callq last
	movq %rbx, %rdi
	movq %rax, %rbx
	movl $32, %esi
	movq %rdi, %r12
	callq pop
	movq %r12, %rdi
	movl $32, %esi
	callq last
	movq %rax, %r12
	movq 16(%rbx), %rax
	movq 8(%rbx), %r15
	imulq $32, %rax, %rdx
	movq %rdx, -24(%rbp)
	movq 16(%r12), %rcx
	movq 8(%r12), %rdi
	imulq $32, %rcx, %r14
	movq %rax, %r13
	addq %rcx, %r13
	imulq $2, %r13, %rbx
	movq %rbx, -32(%rbp)
	movq %rdi, %rbx
	imulq $32, %r13, %rdi
	callq malloc
	movq %r14, %rdx
	movq %rbx, %rdi
	movq %rax, %r14
	movq %r14, %rax
	addq %rdx, %rax
	movq %rax, -16(%rbp)
	movq %rdi, %rsi
	movq %rdi, %rbx
	movq %r14, %rdi
	callq memcpy
	movq %rbx, %rdi
	movq %rdi, %rbx
	movq -16(%rbp), %rdi
	movq -24(%rbp), %rdx
	movq %r15, %rsi
	callq memcpy
	movq %rbx, %rdi
	movq -32(%rbp), %rbx
	callq free
	movq %r15, %rdi
	callq free
	movq %r14, 8(%r12)
	movq %r13, 16(%r12)
	movq %rbx, 24(%r12)
	movl $0, %eax
	jmp .Lbb835
.Lbb834:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb835:
	popq %r15
	popq %r14
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
	callq peak_8
	leave
	ret
.type peak_12, @function
.size peak_12, .-peak_12
/* end function peak_12 */

.data
.balign 8
expected_12_data:
	.quad 1
	.quad 2
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
.Lbb841:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb853
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $8, %rsi
	jz .Lbb852
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb846
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb841
.Lbb846:
	cmpl $0, %r12d
	jz .Lbb851
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb851
.Lbb848:
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
	jz .Lbb850
	cmpl $0, %ebx
	jz .Lbb851
	jmp .Lbb848
.Lbb850:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb854
.Lbb851:
	movl $1, %eax
	jmp .Lbb854
.Lbb852:
	callq bump
	movl $0, %eax
	jmp .Lbb854
.Lbb853:
	movl $2, %eax
.Lbb854:
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
	jnz .Lbb864
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $8, %rax
	jz .Lbb863
	cmpl $0, %edx
	jz .Lbb862
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb862
.Lbb859:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb861
	cmpl $0, %ebx
	jz .Lbb862
	jmp .Lbb859
.Lbb861:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb865
.Lbb862:
	movl $1, %eax
	jmp .Lbb865
.Lbb863:
	movl $0, %eax
	jmp .Lbb865
.Lbb864:
	movl $2, %eax
.Lbb865:
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
	.quad 8
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
	subq $56, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movl %esi, %r12d
	movl $12, %esi
	movq %rdi, %rbx
	callq push_delim
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rax, %rbx
	movl %esi, %r13d
	movl $13, %esi
	movq %rdi, %r12
	callq push_delim
	movl %r13d, %esi
	movq %r12, %rdi
	movq %rax, %r12
	movl %esi, %r14d
	movq %rdi, %r13
	callq parse_12
	movl %r14d, %esi
	movq %r13, %rdi
	cmpl $0, %eax
	jnz .Lbb885
.Lbb869:
	movl %esi, %r14d
	movq %rdi, %r13
	callq parse_13
	movq %r13, %rdi
	cmpq $1, %rax
	jz .Lbb884
	cmpl $0, %eax
	jnz .Lbb872
	movl %r14d, %esi
	jmp .Lbb876
.Lbb872:
	cmpq $2, %rax
	jz .Lbb883
	cmpq %rax, %rbx
	jnz .Lbb883
	movq %rdi, %r13
	leaq -48(%rbp), %rdi
	callq expected_13
	movq %r13, %rdi
	movq %rax, %rsi
	movq %rdi, %r13
	callq missing
	movq %r13, %rdi
	movl %r14d, %esi
.Lbb876:
	movl %esi, %r14d
	movq %rdi, %r13
	callq parse_12
	movq %r13, %rdi
	movq %rax, %r13
	cmpq $1, %r13
	jnz .Lbb878
	movq %rdi, %r13
	callq bump_err
	movl %r14d, %esi
	movq %r13, %rdi
	jmp .Lbb876
.Lbb878:
	cmpl $0, %r13d
	jnz .Lbb880
	movl %r14d, %esi
	jmp .Lbb869
.Lbb880:
	movq %rdi, %r15
	leaq -24(%rbp), %rdi
	callq expected_12
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	cmpq $2, %r13
	jz .Lbb883
	cmpq %r13, %r12
	jnz .Lbb883
	movl %r14d, %esi
	jmp .Lbb869
.Lbb883:
	callq pop_delim
	movl $0, %eax
	jmp .Lbb887
.Lbb884:
	movq %rdi, %r13
	callq bump_err
	movl %r14d, %esi
	movq %r13, %rdi
	jmp .Lbb869
.Lbb885:
	movq %rax, %rbx
	callq pop_delim
	movq %rbx, %rax
.Lbb887:
	popq %r15
	popq %r14
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
	callq peak_12
	leave
	ret
.type peak_14, @function
.size peak_14, .-peak_14
/* end function peak_14 */

.data
.balign 8
expected_14_data:
	.quad 1
	.quad 2
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
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movl $4, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rdi, %rbx
	callq parse_14
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb894
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb895
.Lbb894:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb895:
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
	callq peak_14
	leave
	ret
.type peak_15, @function
.size peak_15, .-peak_15
/* end function peak_15 */

.data
.balign 8
expected_15_data:
	.quad 1
	.quad 4
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
	cmpq $0, %rsi
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
.type parse_16, @function
.size parse_16, .-parse_16
/* end function parse_16 */

.text
peak_16:
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
	cmpq $0, %rax
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
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb929:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb941
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $1, %rsi
	jz .Lbb940
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb934
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb929
.Lbb934:
	cmpl $0, %r12d
	jz .Lbb939
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb939
.Lbb936:
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
	jz .Lbb938
	cmpl $0, %ebx
	jz .Lbb939
	jmp .Lbb936
.Lbb938:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb942
.Lbb939:
	movl $1, %eax
	jmp .Lbb942
.Lbb940:
	callq bump
	movl $0, %eax
	jmp .Lbb942
.Lbb941:
	movl $2, %eax
.Lbb942:
	popq %r13
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
	jnz .Lbb952
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $1, %rax
	jz .Lbb951
	cmpl $0, %edx
	jz .Lbb950
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb950
.Lbb947:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb949
	cmpl $0, %ebx
	jz .Lbb950
	jmp .Lbb947
.Lbb949:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb953
.Lbb950:
	movl $1, %eax
	jmp .Lbb953
.Lbb951:
	movl $0, %eax
	jmp .Lbb953
.Lbb952:
	movl $2, %eax
.Lbb953:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_17, @function
.size peak_17, .-peak_17
/* end function peak_17 */

.data
.balign 8
expected_17_data:
	.quad 0
	.quad 1
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
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb957:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb969
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $6, %rsi
	jz .Lbb968
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb962
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb957
.Lbb962:
	cmpl $0, %r12d
	jz .Lbb967
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb967
.Lbb964:
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
	jz .Lbb966
	cmpl $0, %ebx
	jz .Lbb967
	jmp .Lbb964
.Lbb966:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb970
.Lbb967:
	movl $1, %eax
	jmp .Lbb970
.Lbb968:
	callq bump
	movl $0, %eax
	jmp .Lbb970
.Lbb969:
	movl $2, %eax
.Lbb970:
	popq %r13
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
	jnz .Lbb980
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $6, %rax
	jz .Lbb979
	cmpl $0, %edx
	jz .Lbb978
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb978
.Lbb975:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb977
	cmpl $0, %ebx
	jz .Lbb978
	jmp .Lbb975
.Lbb977:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb981
.Lbb978:
	movl $1, %eax
	jmp .Lbb981
.Lbb979:
	movl $0, %eax
	jmp .Lbb981
.Lbb980:
	movl $2, %eax
.Lbb981:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_18, @function
.size peak_18, .-peak_18
/* end function peak_18 */

.data
.balign 8
expected_18_data:
	.quad 0
	.quad 6
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
.Lbb985:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb997
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $9, %rsi
	jz .Lbb996
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb990
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb985
.Lbb990:
	cmpl $0, %r12d
	jz .Lbb995
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb995
.Lbb992:
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
	jz .Lbb994
	cmpl $0, %ebx
	jz .Lbb995
	jmp .Lbb992
.Lbb994:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb998
.Lbb995:
	movl $1, %eax
	jmp .Lbb998
.Lbb996:
	callq bump
	movl $0, %eax
	jmp .Lbb998
.Lbb997:
	movl $2, %eax
.Lbb998:
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
	jnz .Lbb1008
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $9, %rax
	jz .Lbb1007
	cmpl $0, %edx
	jz .Lbb1006
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1006
.Lbb1003:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1005
	cmpl $0, %ebx
	jz .Lbb1006
	jmp .Lbb1003
.Lbb1005:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1009
.Lbb1006:
	movl $1, %eax
	jmp .Lbb1009
.Lbb1007:
	movl $0, %eax
	jmp .Lbb1009
.Lbb1008:
	movl $2, %eax
.Lbb1009:
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
	.quad 9
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
	movl $19, %esi
	movq %rdi, %r13
	callq push_long
	movl %r14d, %esi
	movq %r13, %rdi
	movl %esi, %r14d
	movl $18, %esi
	movq %rdi, %r13
	callq push_long
	movl %r14d, %esi
	movq %r13, %rdi
	movl %esi, %r14d
	movl $17, %esi
	movq %rdi, %r13
	callq push_long
	movl %r14d, %esi
	movq %r13, %rdi
	movl %esi, %r13d
	movl $15, %esi
	callq push_long
	movl %r13d, %esi
	movq %r12, %rdi
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_16
	movq %r12, %rdi
	movq %rax, %r12
	cmpl $0, %r12d
	jnz .Lbb1059
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1016
	movl %r13d, %esi
	jmp .Lbb1022
.Lbb1016:
	cmpq $2, %rax
	jz .Lbb1020
	movq %rax, %r14
	movq %rbx, %rax
	subq $1, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -216(%rbp), %rdi
	callq expected_16
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jz .Lbb1019
	movl %r13d, %esi
	jmp .Lbb1022
.Lbb1019:
	movq %rax, %r12
	jmp .Lbb1026
.Lbb1020:
	movq %rdi, %r12
	leaq -192(%rbp), %rdi
	callq expected_16
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movq %r12, %rdi
	movl %r13d, %esi
.Lbb1022:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_15
	movl %r13d, %esi
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1025
	movl %esi, %r13d
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb1022
.Lbb1025:
	movl %esi, %r13d
.Lbb1026:
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jz .Lbb1031
	cmpq $2, %rax
	jz .Lbb1030
	movq %rax, %r14
	movq %rbx, %rax
	subq $2, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -168(%rbp), %rdi
	callq expected_15
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jnz .Lbb1031
	movq %rax, %r12
	jmp .Lbb1035
.Lbb1030:
	movq %rdi, %r12
	leaq -144(%rbp), %rdi
	callq expected_15
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movq %r12, %rdi
.Lbb1031:
	movl %r13d, %esi
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_17
	movl %r13d, %esi
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1034
	movl %esi, %r13d
	movq %rdi, %r12
	callq bump_err
	movq %r12, %rdi
	jmp .Lbb1031
.Lbb1034:
	movl %esi, %r13d
.Lbb1035:
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jz .Lbb1040
	cmpq $2, %rax
	jz .Lbb1039
	movq %rax, %r14
	movq %rbx, %rax
	subq $3, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -120(%rbp), %rdi
	callq expected_17
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jnz .Lbb1040
	movq %rax, %r12
	jmp .Lbb1044
.Lbb1039:
	movq %rdi, %r12
	leaq -96(%rbp), %rdi
	callq expected_17
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movq %r12, %rdi
.Lbb1040:
	movl %r13d, %esi
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_18
	movl %r13d, %esi
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1043
	movl %esi, %r13d
	movq %rdi, %r12
	callq bump_err
	movq %r12, %rdi
	jmp .Lbb1040
.Lbb1043:
	movl %esi, %r13d
.Lbb1044:
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1046
	movl %r13d, %esi
	jmp .Lbb1050
.Lbb1046:
	cmpq $2, %rax
	jz .Lbb1049
	movq %rax, %r14
	movq %rbx, %rax
	subq $4, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -72(%rbp), %rdi
	callq expected_18
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jz .Lbb1054
	movl %r13d, %esi
	jmp .Lbb1050
.Lbb1049:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_18
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb1050:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_19
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1053
	movq %rdi, %r12
	callq bump_err
	movq %r12, %rdi
	movl %r13d, %esi
	jmp .Lbb1050
.Lbb1053:
	movq %r12, %rax
.Lbb1054:
	cmpl $0, %eax
	jz .Lbb1058
	cmpq $2, %rax
	jz .Lbb1057
	movq %rbx, %rcx
	subq $4, %rcx
	cmpq %rcx, %rax
	jz .Lbb1058
.Lbb1057:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_19
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb1058:
	movl $0, %eax
	jmp .Lbb1060
.Lbb1059:
	movq %r12, %rax
.Lbb1060:
	popq %r15
	popq %r14
	popq %r13
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
	callq peak_16
	leave
	ret
.type peak_20, @function
.size peak_20, .-peak_20
/* end function peak_20 */

.data
.balign 8
expected_20_data:
	.quad 0
	.quad 0
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

.text
parse_21:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movl $5, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rdi, %rbx
	callq parse_20
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1067
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb1068
.Lbb1067:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1068:
	popq %r12
	popq %rbx
	leave
	ret
.type parse_21, @function
.size parse_21, .-parse_21
/* end function parse_21 */

.text
peak_21:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_20
	leave
	ret
.type peak_21, @function
.size peak_21, .-peak_21
/* end function peak_21 */

.data
.balign 8
expected_21_data:
	.quad 1
	.quad 5
/* end data */

.text
expected_21:
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
	leaq expected_21_data(%rip), %rsi
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
.type expected_21, @function
.size expected_21, .-expected_21
/* end function expected_21 */

.text
parse_22:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movl $21, %esi
	movq %rdi, %rbx
	callq push_delim
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_21
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1080
	movq %rdi, %rbx
	callq is_eof
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1079
.Lbb1075:
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_21
	movq %rbx, %rdi
	cmpq $1, %rax
	jz .Lbb1078
	cmpl $0, %eax
	jnz .Lbb1079
	movl %r12d, %esi
	jmp .Lbb1075
.Lbb1078:
	movq %rdi, %rbx
	callq bump_err
	movl %r12d, %esi
	movq %rbx, %rdi
	jmp .Lbb1075
.Lbb1079:
	callq pop_delim
	movl $0, %eax
	jmp .Lbb1081
.Lbb1080:
	callq pop_delim
	movq %rbx, %rax
.Lbb1081:
	popq %r12
	popq %rbx
	leave
	ret
.type parse_22, @function
.size parse_22, .-parse_22
/* end function parse_22 */

.text
peak_22:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_21
	leave
	ret
.type peak_22, @function
.size peak_22, .-peak_22
/* end function peak_22 */

.data
.balign 8
expected_22_data:
	.quad 1
	.quad 5
/* end data */

.text
expected_22:
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
	leaq expected_22_data(%rip), %rsi
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
.type expected_22, @function
.size expected_22, .-expected_22
/* end function expected_22 */

.text
parse_23:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb1087:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1099
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $5, %rsi
	jz .Lbb1098
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1092
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1087
.Lbb1092:
	cmpl $0, %r12d
	jz .Lbb1097
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1097
.Lbb1094:
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
	jz .Lbb1096
	cmpl $0, %ebx
	jz .Lbb1097
	jmp .Lbb1094
.Lbb1096:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1100
.Lbb1097:
	movl $1, %eax
	jmp .Lbb1100
.Lbb1098:
	callq bump
	movl $0, %eax
	jmp .Lbb1100
.Lbb1099:
	movl $2, %eax
.Lbb1100:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_23, @function
.size parse_23, .-parse_23
/* end function parse_23 */

.text
peak_23:
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
	jnz .Lbb1110
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $5, %rax
	jz .Lbb1109
	cmpl $0, %edx
	jz .Lbb1108
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1108
.Lbb1105:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1107
	cmpl $0, %ebx
	jz .Lbb1108
	jmp .Lbb1105
.Lbb1107:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1111
.Lbb1108:
	movl $1, %eax
	jmp .Lbb1111
.Lbb1109:
	movl $0, %eax
	jmp .Lbb1111
.Lbb1110:
	movl $2, %eax
.Lbb1111:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_23, @function
.size peak_23, .-peak_23
/* end function peak_23 */

.data
.balign 8
expected_23_data:
	.quad 0
	.quad 5
/* end data */

.text
expected_23:
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
	leaq expected_23_data(%rip), %rsi
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
.type expected_23, @function
.size expected_23, .-expected_23
/* end function expected_23 */

.text
parse_24:
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
	callq peak_22
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1118
	movl %esi, %r12d
	movl $5, %esi
	movq %rdi, %rbx
	callq skip
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rax, %r12
	movq %rdi, %rbx
	callq parse_22
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %r12d
	jnz .Lbb1117
	movq %rbx, %rax
	jmp .Lbb1118
.Lbb1117:
	movl $5, %esi
	callq unskip
	movq %rbx, %rax
.Lbb1118:
	popq %r12
	popq %rbx
	leave
	ret
.type parse_24, @function
.size parse_24, .-parse_24
/* end function parse_24 */

.text
peak_24:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_22
	leave
	ret
.type peak_24, @function
.size peak_24, .-peak_24
/* end function peak_24 */

.data
.balign 8
expected_24_data:
	.quad 1
	.quad 5
/* end data */

.text
expected_24:
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
	leaq expected_24_data(%rip), %rsi
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
.type expected_24, @function
.size expected_24, .-expected_24
/* end function expected_24 */

.data
.balign 8
root_group_id:
	.int 7
/* end data */

.text
.globl parse
parse:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
.Lbb1124:
	movl $1, %esi
	movq %rdi, %rbx
	callq parse_24
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1127
	cmpq $2, %rax
	jz .Lbb1127
	movq %rdi, %rbx
	callq bump_err
	movq %rbx, %rdi
	jmp .Lbb1124
.Lbb1127:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1129
	movq %rdi, %rbx
	callq bump_err
	movq %rbx, %rdi
	jmp .Lbb1127
.Lbb1129:
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
sum_group_name:
	.ascii "sum"
	.byte 0
/* end data */

.data
.balign 8
sum_group_name_len:
	.quad 3
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
	jz .Lbb1148
	cmpl $1, %edi
	leaq num_group_name(%rip), %rax
	jz .Lbb1147
	cmpl $2, %edi
	leaq literal_group_name(%rip), %rax
	jz .Lbb1146
	cmpl $3, %edi
	leaq sum_group_name(%rip), %rax
	jz .Lbb1145
	cmpl $4, %edi
	leaq args_group_name(%rip), %rax
	jz .Lbb1144
	cmpl $5, %edi
	leaq stmt_group_name(%rip), %rax
	jz .Lbb1143
	cmpl $6, %edi
	leaq _root_group_name(%rip), %rax
	jz .Lbb1142
	cmpl $7, %edi
	leaq root_group_name(%rip), %rax
	jz .Lbb1141
	leaq err_group_name(%rip), %rax
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb1149
.Lbb1141:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb1149
.Lbb1142:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb1149
.Lbb1143:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb1149
.Lbb1144:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb1149
.Lbb1145:
	movq %rax, %rdx
	movl $3, %eax
	jmp .Lbb1149
.Lbb1146:
	movq %rax, %rdx
	movl $7, %eax
	jmp .Lbb1149
.Lbb1147:
	movq %rax, %rdx
	movl $3, %eax
	jmp .Lbb1149
.Lbb1148:
	movq %rax, %rdx
	movl $6, %eax
.Lbb1149:
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
