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

.text
.globl free_node
free_node:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq %rdi, %rax
	movl (%rax), %ecx
	cmpl $0, %ecx
	jz .Lbb106
	cmpl $1, %ecx
	jz .Lbb100
	cmpl $2, %ecx
	jz .Lbb99
	cmpl $3, %ecx
	jnz .Lbb106
	movq 8(%rax), %rdi
	callq free
	jmp .Lbb106
.Lbb99:
	movq 8(%rax), %rdi
	callq free
	jmp .Lbb106
.Lbb100:
	movq 8(%rax), %rdi
	movq 16(%rax), %r13
	movq %rdi, %r12
	movl $0, %ebx
.Lbb102:
	cmpq %r13, %rbx
	jae .Lbb104
	imulq $32, %rbx, %rax
	movq %r12, %rdi
	addq %rax, %rdi
	callq free_node
	addq $1, %rbx
	jmp .Lbb102
.Lbb104:
	movq %r12, %rdi
	callq free
.Lbb106:
	movl $1, %eax
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type free_node, @function
.size free_node, .-free_node
/* end function free_node */

.text
.globl free_state
free_state:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	movq %rdi, %rbx
	movq (%rdi), %rdi
	callq free
	movq %rbx, %rdi
	movq %rdi, %rbx
	movq 24(%rdi), %rdi
	movq 32(%rbx), %r13
	movq %rdi, %r12
	movq %rbx, %rdi
	movl $0, %ebx
.Lbb110:
	cmpq %r13, %rbx
	jae .Lbb112
	imulq $32, %rbx, %rax
	movq %rdi, %r14
	movq %r12, %rdi
	addq %rax, %rdi
	callq free_node
	movq %r14, %rdi
	addq $1, %rbx
	jmp .Lbb110
.Lbb112:
	movq %rdi, %rbx
	movq %r12, %rdi
	callq free
	movq %rbx, %rdi
	movq %rdi, %rbx
	movq 56(%rdi), %rdi
	callq free
	movq %rbx, %rdi
	movq 80(%rdi), %rdi
	callq free
	movl $1, %eax
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type free_state, @function
.size free_state, .-free_state
/* end function free_state */

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
lex_1:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	movq offset_ptr(%rip), %rbx
	movl $107, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb127
	movl $101, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb127
	movl $121, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb127
	movl $119, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb127
	movl $111, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb127
	movl $114, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb127
	movl $100, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb128
.Lbb127:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb129
.Lbb128:
	movl $1, %eax
.Lbb129:
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_1, @function
.size lex_1, .-lex_1
/* end function lex_1 */

.text
lex_3:
	pushq %rbp
	movq %rsp, %rbp
	movl $95, %edx
	callq cmp_current
	cmpl $0, %eax
	jnz .Lbb132
	movl $0, %eax
	jmp .Lbb133
.Lbb132:
	callq inc_offset
	movl $1, %eax
.Lbb133:
	leave
	ret
.type lex_3, @function
.size lex_3, .-lex_3
/* end function lex_3 */

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
	jnz .Lbb136
	movl $0, %eax
	jmp .Lbb137
.Lbb136:
	callq inc_offset
	movl $1, %eax
.Lbb137:
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
	jnz .Lbb140
	movl $0, %eax
	jmp .Lbb141
.Lbb140:
	callq inc_offset
	movl $1, %eax
.Lbb141:
	leave
	ret
.type lex_5, @function
.size lex_5, .-lex_5
/* end function lex_5 */

.text
lex_2:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq offset_ptr(%rip), %rbx
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_3
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb147
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_4
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb147
	callq lex_5
	cmpl $0, %eax
	jnz .Lbb147
	callq inc_offset
	movl $1, %eax
	jmp .Lbb148
.Lbb147:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb148:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_2, @function
.size lex_2, .-lex_2
/* end function lex_2 */

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
	jz .Lbb152
	callq lex_2
	cmpl $0, %eax
	jnz .Lbb153
.Lbb152:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb154
.Lbb153:
	movl $1, %eax
.Lbb154:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_0, @function
.size lex_0, .-lex_0
/* end function lex_0 */

.text
lex_KEYWORD:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_0
	cmpl $0, %eax
	jnz .Lbb157
	movl $0, %eax
	jmp .Lbb159
.Lbb157:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb159
	movq offset_ptr(%rip), %rax
.Lbb159:
	leave
	ret
.type lex_KEYWORD, @function
.size lex_KEYWORD, .-lex_KEYWORD
/* end function lex_KEYWORD */

.text
lex_7:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	movq offset_ptr(%rip), %rbx
	movl $112, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb167
	movl $97, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb167
	movl $114, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb167
	movl $115, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb167
	movl $101, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb167
	movl $114, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb168
.Lbb167:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb169
.Lbb168:
	movl $1, %eax
.Lbb169:
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_7, @function
.size lex_7, .-lex_7
/* end function lex_7 */

.text
lex_9:
	pushq %rbp
	movq %rsp, %rbp
	movl $95, %edx
	callq cmp_current
	cmpl $0, %eax
	jnz .Lbb172
	movl $0, %eax
	jmp .Lbb173
.Lbb172:
	callq inc_offset
	movl $1, %eax
.Lbb173:
	leave
	ret
.type lex_9, @function
.size lex_9, .-lex_9
/* end function lex_9 */

.text
lex_10:
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
	jnz .Lbb176
	movl $0, %eax
	jmp .Lbb177
.Lbb176:
	callq inc_offset
	movl $1, %eax
.Lbb177:
	leave
	ret
.type lex_10, @function
.size lex_10, .-lex_10
/* end function lex_10 */

.text
lex_11:
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
	jnz .Lbb180
	movl $0, %eax
	jmp .Lbb181
.Lbb180:
	callq inc_offset
	movl $1, %eax
.Lbb181:
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
	jnz .Lbb187
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_10
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb187
	callq lex_11
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
.type lex_8, @function
.size lex_8, .-lex_8
/* end function lex_8 */

.text
lex_6:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq offset_ptr(%rip), %rbx
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_7
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb192
	callq lex_8
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
.type lex_6, @function
.size lex_6, .-lex_6
/* end function lex_6 */

.text
lex_PARSER:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_6
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
.type lex_PARSER, @function
.size lex_PARSER, .-lex_PARSER
/* end function lex_PARSER */

.text
lex_13:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	movq offset_ptr(%rip), %rbx
	movl $116, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb206
	movl $111, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb206
	movl $107, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb206
	movl $101, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb206
	movl $110, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb207
.Lbb206:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb208
.Lbb207:
	movl $1, %eax
.Lbb208:
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_13, @function
.size lex_13, .-lex_13
/* end function lex_13 */

.text
lex_15:
	pushq %rbp
	movq %rsp, %rbp
	movl $95, %edx
	callq cmp_current
	cmpl $0, %eax
	jnz .Lbb211
	movl $0, %eax
	jmp .Lbb212
.Lbb211:
	callq inc_offset
	movl $1, %eax
.Lbb212:
	leave
	ret
.type lex_15, @function
.size lex_15, .-lex_15
/* end function lex_15 */

.text
lex_16:
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
	jnz .Lbb215
	movl $0, %eax
	jmp .Lbb216
.Lbb215:
	callq inc_offset
	movl $1, %eax
.Lbb216:
	leave
	ret
.type lex_16, @function
.size lex_16, .-lex_16
/* end function lex_16 */

.text
lex_17:
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
	jnz .Lbb219
	movl $0, %eax
	jmp .Lbb220
.Lbb219:
	callq inc_offset
	movl $1, %eax
.Lbb220:
	leave
	ret
.type lex_17, @function
.size lex_17, .-lex_17
/* end function lex_17 */

.text
lex_14:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq offset_ptr(%rip), %rbx
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_15
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb226
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_16
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb226
	callq lex_17
	cmpl $0, %eax
	jnz .Lbb226
	callq inc_offset
	movl $1, %eax
	jmp .Lbb227
.Lbb226:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb227:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_14, @function
.size lex_14, .-lex_14
/* end function lex_14 */

.text
lex_12:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq offset_ptr(%rip), %rbx
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_13
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb231
	callq lex_14
	cmpl $0, %eax
	jnz .Lbb232
.Lbb231:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb233
.Lbb232:
	movl $1, %eax
.Lbb233:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_12, @function
.size lex_12, .-lex_12
/* end function lex_12 */

.text
lex_TOKEN:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_12
	cmpl $0, %eax
	jnz .Lbb236
	movl $0, %eax
	jmp .Lbb238
.Lbb236:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb238
	movq offset_ptr(%rip), %rax
.Lbb238:
	leave
	ret
.type lex_TOKEN, @function
.size lex_TOKEN, .-lex_TOKEN
/* end function lex_TOKEN */

.text
lex_19:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	movq offset_ptr(%rip), %rbx
	movl $104, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb249
	movl $105, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb249
	movl $103, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb249
	movl $104, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb249
	movl $108, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb249
	movl $105, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb249
	movl $103, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb249
	movl $104, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb249
	movl $116, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb250
.Lbb249:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb251
.Lbb250:
	movl $1, %eax
.Lbb251:
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_19, @function
.size lex_19, .-lex_19
/* end function lex_19 */

.text
lex_21:
	pushq %rbp
	movq %rsp, %rbp
	movl $95, %edx
	callq cmp_current
	cmpl $0, %eax
	jnz .Lbb254
	movl $0, %eax
	jmp .Lbb255
.Lbb254:
	callq inc_offset
	movl $1, %eax
.Lbb255:
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
	cmpl $97, %ecx
	setae %al
	movzbl %al, %eax
	cmpl $122, %ecx
	setbe %cl
	movzbl %cl, %ecx
	testl %eax, %ecx
	jnz .Lbb258
	movl $0, %eax
	jmp .Lbb259
.Lbb258:
	callq inc_offset
	movl $1, %eax
.Lbb259:
	leave
	ret
.type lex_22, @function
.size lex_22, .-lex_22
/* end function lex_22 */

.text
lex_23:
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
	jnz .Lbb262
	movl $0, %eax
	jmp .Lbb263
.Lbb262:
	callq inc_offset
	movl $1, %eax
.Lbb263:
	leave
	ret
.type lex_23, @function
.size lex_23, .-lex_23
/* end function lex_23 */

.text
lex_20:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq offset_ptr(%rip), %rbx
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_21
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb269
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_22
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb269
	callq lex_23
	cmpl $0, %eax
	jnz .Lbb269
	callq inc_offset
	movl $1, %eax
	jmp .Lbb270
.Lbb269:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb270:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_20, @function
.size lex_20, .-lex_20
/* end function lex_20 */

.text
lex_18:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq offset_ptr(%rip), %rbx
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_19
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb274
	callq lex_20
	cmpl $0, %eax
	jnz .Lbb275
.Lbb274:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb276
.Lbb275:
	movl $1, %eax
.Lbb276:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_18, @function
.size lex_18, .-lex_18
/* end function lex_18 */

.text
lex_HIGHTLIGHT:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_18
	cmpl $0, %eax
	jnz .Lbb279
	movl $0, %eax
	jmp .Lbb281
.Lbb279:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb281
	movq offset_ptr(%rip), %rax
.Lbb281:
	leave
	ret
.type lex_HIGHTLIGHT, @function
.size lex_HIGHTLIGHT, .-lex_HIGHTLIGHT
/* end function lex_HIGHTLIGHT */

.text
lex_25:
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
	jz .Lbb287
	movl $111, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb287
	movl $108, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb287
	movl $100, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb288
.Lbb287:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb289
.Lbb288:
	movl $1, %eax
.Lbb289:
	popq %r14
	popq %r13
	popq %r12
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
	movl $95, %edx
	callq cmp_current
	cmpl $0, %eax
	jnz .Lbb292
	movl $0, %eax
	jmp .Lbb293
.Lbb292:
	callq inc_offset
	movl $1, %eax
.Lbb293:
	leave
	ret
.type lex_27, @function
.size lex_27, .-lex_27
/* end function lex_27 */

.text
lex_28:
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
	jnz .Lbb296
	movl $0, %eax
	jmp .Lbb297
.Lbb296:
	callq inc_offset
	movl $1, %eax
.Lbb297:
	leave
	ret
.type lex_28, @function
.size lex_28, .-lex_28
/* end function lex_28 */

.text
lex_29:
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
	jnz .Lbb300
	movl $0, %eax
	jmp .Lbb301
.Lbb300:
	callq inc_offset
	movl $1, %eax
.Lbb301:
	leave
	ret
.type lex_29, @function
.size lex_29, .-lex_29
/* end function lex_29 */

.text
lex_26:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq offset_ptr(%rip), %rbx
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_27
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb307
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_28
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb307
	callq lex_29
	cmpl $0, %eax
	jnz .Lbb307
	callq inc_offset
	movl $1, %eax
	jmp .Lbb308
.Lbb307:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb308:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_26, @function
.size lex_26, .-lex_26
/* end function lex_26 */

.text
lex_24:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq offset_ptr(%rip), %rbx
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_25
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb312
	callq lex_26
	cmpl $0, %eax
	jnz .Lbb313
.Lbb312:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb314
.Lbb313:
	movl $1, %eax
.Lbb314:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_24, @function
.size lex_24, .-lex_24
/* end function lex_24 */

.text
lex_FOLD:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_24
	cmpl $0, %eax
	jnz .Lbb317
	movl $0, %eax
	jmp .Lbb319
.Lbb317:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb319
	movq offset_ptr(%rip), %rax
.Lbb319:
	leave
	ret
.type lex_FOLD, @function
.size lex_FOLD, .-lex_FOLD
/* end function lex_FOLD */

.text
lex_32:
	pushq %rbp
	movq %rsp, %rbp
	movl $32, %edx
	callq cmp_current
	cmpl $0, %eax
	jnz .Lbb322
	movl $0, %eax
	jmp .Lbb323
.Lbb322:
	callq inc_offset
	movl $1, %eax
.Lbb323:
	leave
	ret
.type lex_32, @function
.size lex_32, .-lex_32
/* end function lex_32 */

.text
lex_33:
	pushq %rbp
	movq %rsp, %rbp
	movl $9, %edx
	callq cmp_current
	cmpl $0, %eax
	jnz .Lbb326
	movl $0, %eax
	jmp .Lbb327
.Lbb326:
	callq inc_offset
	movl $1, %eax
.Lbb327:
	leave
	ret
.type lex_33, @function
.size lex_33, .-lex_33
/* end function lex_33 */

.text
lex_34:
	pushq %rbp
	movq %rsp, %rbp
	movl $10, %edx
	callq cmp_current
	cmpl $0, %eax
	jnz .Lbb330
	movl $0, %eax
	jmp .Lbb331
.Lbb330:
	callq inc_offset
	movl $1, %eax
.Lbb331:
	leave
	ret
.type lex_34, @function
.size lex_34, .-lex_34
/* end function lex_34 */

.text
lex_31:
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
	callq lex_32
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb337
	movq %rbx, offset_ptr(%rip)
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_33
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb337
	movq %rbx, offset_ptr(%rip)
	callq lex_34
	cmpl $0, %eax
	jnz .Lbb337
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb338
.Lbb337:
	movl $1, %eax
.Lbb338:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_31, @function
.size lex_31, .-lex_31
/* end function lex_31 */

.text
lex_35:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jz .Lbb344
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_31
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb344
.Lbb341:
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jz .Lbb343
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_31
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb341
.Lbb343:
	movl $1, %eax
	jmp .Lbb345
.Lbb344:
	movl $0, %eax
.Lbb345:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_35, @function
.size lex_35, .-lex_35
/* end function lex_35 */

.text
lex_30:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_35
	cmpl $0, %eax
	jnz .Lbb349
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb350
.Lbb349:
	movl $1, %eax
.Lbb350:
	popq %rbx
	leave
	ret
.type lex_30, @function
.size lex_30, .-lex_30
/* end function lex_30 */

.text
lex_whitespace:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_30
	cmpl $0, %eax
	jnz .Lbb353
	movl $0, %eax
	jmp .Lbb355
.Lbb353:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb355
	movq offset_ptr(%rip), %rax
.Lbb355:
	leave
	ret
.type lex_whitespace, @function
.size lex_whitespace, .-lex_whitespace
/* end function lex_whitespace */

.text
lex_38:
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
	jnz .Lbb358
	movl $0, %eax
	jmp .Lbb359
.Lbb358:
	callq inc_offset
	movl $1, %eax
.Lbb359:
	leave
	ret
.type lex_38, @function
.size lex_38, .-lex_38
/* end function lex_38 */

.text
lex_37:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	movq %rbx, offset_ptr(%rip)
	callq lex_38
	cmpl $0, %eax
	jnz .Lbb363
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb364
.Lbb363:
	movl $1, %eax
.Lbb364:
	popq %rbx
	leave
	ret
.type lex_37, @function
.size lex_37, .-lex_37
/* end function lex_37 */

.text
lex_39:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jz .Lbb370
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_37
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb370
.Lbb367:
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jz .Lbb369
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_37
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb367
.Lbb369:
	movl $1, %eax
	jmp .Lbb371
.Lbb370:
	movl $0, %eax
.Lbb371:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_39, @function
.size lex_39, .-lex_39
/* end function lex_39 */

.text
lex_36:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_39
	cmpl $0, %eax
	jnz .Lbb375
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb376
.Lbb375:
	movl $1, %eax
.Lbb376:
	popq %rbx
	leave
	ret
.type lex_36, @function
.size lex_36, .-lex_36
/* end function lex_36 */

.text
lex_int:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_36
	cmpl $0, %eax
	jnz .Lbb379
	movl $0, %eax
	jmp .Lbb381
.Lbb379:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb381
	movq offset_ptr(%rip), %rax
.Lbb381:
	leave
	ret
.type lex_int, @function
.size lex_int, .-lex_int
/* end function lex_int */

.text
lex_41:
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
	jnz .Lbb385
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb386
.Lbb385:
	movl $1, %eax
.Lbb386:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_41, @function
.size lex_41, .-lex_41
/* end function lex_41 */

.text
lex_40:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_41
	cmpl $0, %eax
	jnz .Lbb390
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb391
.Lbb390:
	movl $1, %eax
.Lbb391:
	popq %rbx
	leave
	ret
.type lex_40, @function
.size lex_40, .-lex_40
/* end function lex_40 */

.text
lex_colon:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_40
	cmpl $0, %eax
	jnz .Lbb394
	movl $0, %eax
	jmp .Lbb396
.Lbb394:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb396
	movq offset_ptr(%rip), %rax
.Lbb396:
	leave
	ret
.type lex_colon, @function
.size lex_colon, .-lex_colon
/* end function lex_colon */

.text
lex_43:
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
	jnz .Lbb400
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb401
.Lbb400:
	movl $1, %eax
.Lbb401:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_43, @function
.size lex_43, .-lex_43
/* end function lex_43 */

.text
lex_42:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_43
	cmpl $0, %eax
	jnz .Lbb405
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb406
.Lbb405:
	movl $1, %eax
.Lbb406:
	popq %rbx
	leave
	ret
.type lex_42, @function
.size lex_42, .-lex_42
/* end function lex_42 */

.text
lex_comma:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_42
	cmpl $0, %eax
	jnz .Lbb409
	movl $0, %eax
	jmp .Lbb411
.Lbb409:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb411
	movq offset_ptr(%rip), %rax
.Lbb411:
	leave
	ret
.type lex_comma, @function
.size lex_comma, .-lex_comma
/* end function lex_comma */

.text
lex_45:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rbx
	movl $124, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb415
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb416
.Lbb415:
	movl $1, %eax
.Lbb416:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_45, @function
.size lex_45, .-lex_45
/* end function lex_45 */

.text
lex_44:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_45
	cmpl $0, %eax
	jnz .Lbb420
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb421
.Lbb420:
	movl $1, %eax
.Lbb421:
	popq %rbx
	leave
	ret
.type lex_44, @function
.size lex_44, .-lex_44
/* end function lex_44 */

.text
lex_bar:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_44
	cmpl $0, %eax
	jnz .Lbb424
	movl $0, %eax
	jmp .Lbb426
.Lbb424:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb426
	movq offset_ptr(%rip), %rax
.Lbb426:
	leave
	ret
.type lex_bar, @function
.size lex_bar, .-lex_bar
/* end function lex_bar */

.text
lex_47:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rbx
	movl $46, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb430
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb431
.Lbb430:
	movl $1, %eax
.Lbb431:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_47, @function
.size lex_47, .-lex_47
/* end function lex_47 */

.text
lex_46:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_47
	cmpl $0, %eax
	jnz .Lbb435
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb436
.Lbb435:
	movl $1, %eax
.Lbb436:
	popq %rbx
	leave
	ret
.type lex_46, @function
.size lex_46, .-lex_46
/* end function lex_46 */

.text
lex_dot:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_46
	cmpl $0, %eax
	jnz .Lbb439
	movl $0, %eax
	jmp .Lbb441
.Lbb439:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb441
	movq offset_ptr(%rip), %rax
.Lbb441:
	leave
	ret
.type lex_dot, @function
.size lex_dot, .-lex_dot
/* end function lex_dot */

.text
lex_49:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rbx
	movl $91, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb445
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb446
.Lbb445:
	movl $1, %eax
.Lbb446:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_49, @function
.size lex_49, .-lex_49
/* end function lex_49 */

.text
lex_48:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_49
	cmpl $0, %eax
	jnz .Lbb450
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb451
.Lbb450:
	movl $1, %eax
.Lbb451:
	popq %rbx
	leave
	ret
.type lex_48, @function
.size lex_48, .-lex_48
/* end function lex_48 */

.text
lex_l_bracket:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_48
	cmpl $0, %eax
	jnz .Lbb454
	movl $0, %eax
	jmp .Lbb456
.Lbb454:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb456
	movq offset_ptr(%rip), %rax
.Lbb456:
	leave
	ret
.type lex_l_bracket, @function
.size lex_l_bracket, .-lex_l_bracket
/* end function lex_l_bracket */

.text
lex_51:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rbx
	movl $93, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb460
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb461
.Lbb460:
	movl $1, %eax
.Lbb461:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_51, @function
.size lex_51, .-lex_51
/* end function lex_51 */

.text
lex_50:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_51
	cmpl $0, %eax
	jnz .Lbb465
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb466
.Lbb465:
	movl $1, %eax
.Lbb466:
	popq %rbx
	leave
	ret
.type lex_50, @function
.size lex_50, .-lex_50
/* end function lex_50 */

.text
lex_r_bracket:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_50
	cmpl $0, %eax
	jnz .Lbb469
	movl $0, %eax
	jmp .Lbb471
.Lbb469:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb471
	movq offset_ptr(%rip), %rax
.Lbb471:
	leave
	ret
.type lex_r_bracket, @function
.size lex_r_bracket, .-lex_r_bracket
/* end function lex_r_bracket */

.text
lex_53:
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
	jnz .Lbb475
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb476
.Lbb475:
	movl $1, %eax
.Lbb476:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_53, @function
.size lex_53, .-lex_53
/* end function lex_53 */

.text
lex_52:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_53
	cmpl $0, %eax
	jnz .Lbb480
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb481
.Lbb480:
	movl $1, %eax
.Lbb481:
	popq %rbx
	leave
	ret
.type lex_52, @function
.size lex_52, .-lex_52
/* end function lex_52 */

.text
lex_l_paren:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_52
	cmpl $0, %eax
	jnz .Lbb484
	movl $0, %eax
	jmp .Lbb486
.Lbb484:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb486
	movq offset_ptr(%rip), %rax
.Lbb486:
	leave
	ret
.type lex_l_paren, @function
.size lex_l_paren, .-lex_l_paren
/* end function lex_l_paren */

.text
lex_55:
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
	jnz .Lbb490
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb491
.Lbb490:
	movl $1, %eax
.Lbb491:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_55, @function
.size lex_55, .-lex_55
/* end function lex_55 */

.text
lex_54:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_55
	cmpl $0, %eax
	jnz .Lbb495
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb496
.Lbb495:
	movl $1, %eax
.Lbb496:
	popq %rbx
	leave
	ret
.type lex_54, @function
.size lex_54, .-lex_54
/* end function lex_54 */

.text
lex_r_paren:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_54
	cmpl $0, %eax
	jnz .Lbb499
	movl $0, %eax
	jmp .Lbb501
.Lbb499:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb501
	movq offset_ptr(%rip), %rax
.Lbb501:
	leave
	ret
.type lex_r_paren, @function
.size lex_r_paren, .-lex_r_paren
/* end function lex_r_paren */

.text
lex_57:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rbx
	movl $123, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb505
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb506
.Lbb505:
	movl $1, %eax
.Lbb506:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_57, @function
.size lex_57, .-lex_57
/* end function lex_57 */

.text
lex_56:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_57
	cmpl $0, %eax
	jnz .Lbb510
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb511
.Lbb510:
	movl $1, %eax
.Lbb511:
	popq %rbx
	leave
	ret
.type lex_56, @function
.size lex_56, .-lex_56
/* end function lex_56 */

.text
lex_l_brace:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_56
	cmpl $0, %eax
	jnz .Lbb514
	movl $0, %eax
	jmp .Lbb516
.Lbb514:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb516
	movq offset_ptr(%rip), %rax
.Lbb516:
	leave
	ret
.type lex_l_brace, @function
.size lex_l_brace, .-lex_l_brace
/* end function lex_l_brace */

.text
lex_59:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rbx
	movl $125, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb520
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb521
.Lbb520:
	movl $1, %eax
.Lbb521:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_59, @function
.size lex_59, .-lex_59
/* end function lex_59 */

.text
lex_58:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_59
	cmpl $0, %eax
	jnz .Lbb525
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb526
.Lbb525:
	movl $1, %eax
.Lbb526:
	popq %rbx
	leave
	ret
.type lex_58, @function
.size lex_58, .-lex_58
/* end function lex_58 */

.text
lex_r_brace:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_58
	cmpl $0, %eax
	jnz .Lbb529
	movl $0, %eax
	jmp .Lbb531
.Lbb529:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb531
	movq offset_ptr(%rip), %rax
.Lbb531:
	leave
	ret
.type lex_r_brace, @function
.size lex_r_brace, .-lex_r_brace
/* end function lex_r_brace */

.text
lex_61:
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
	jnz .Lbb535
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb536
.Lbb535:
	movl $1, %eax
.Lbb536:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_61, @function
.size lex_61, .-lex_61
/* end function lex_61 */

.text
lex_60:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_61
	cmpl $0, %eax
	jnz .Lbb540
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb541
.Lbb540:
	movl $1, %eax
.Lbb541:
	popq %rbx
	leave
	ret
.type lex_60, @function
.size lex_60, .-lex_60
/* end function lex_60 */

.text
lex_plus:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_60
	cmpl $0, %eax
	jnz .Lbb544
	movl $0, %eax
	jmp .Lbb546
.Lbb544:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb546
	movq offset_ptr(%rip), %rax
.Lbb546:
	leave
	ret
.type lex_plus, @function
.size lex_plus, .-lex_plus
/* end function lex_plus */

.text
lex_63:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rbx
	movl $61, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb550
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb551
.Lbb550:
	movl $1, %eax
.Lbb551:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_63, @function
.size lex_63, .-lex_63
/* end function lex_63 */

.text
lex_62:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_63
	cmpl $0, %eax
	jnz .Lbb555
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb556
.Lbb555:
	movl $1, %eax
.Lbb556:
	popq %rbx
	leave
	ret
.type lex_62, @function
.size lex_62, .-lex_62
/* end function lex_62 */

.text
lex_eq:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_62
	cmpl $0, %eax
	jnz .Lbb559
	movl $0, %eax
	jmp .Lbb561
.Lbb559:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb561
	movq offset_ptr(%rip), %rax
.Lbb561:
	leave
	ret
.type lex_eq, @function
.size lex_eq, .-lex_eq
/* end function lex_eq */

.text
lex_66:
	pushq %rbp
	movq %rsp, %rbp
	movl $95, %edx
	callq cmp_current
	cmpl $0, %eax
	jnz .Lbb564
	movl $0, %eax
	jmp .Lbb565
.Lbb564:
	callq inc_offset
	movl $1, %eax
.Lbb565:
	leave
	ret
.type lex_66, @function
.size lex_66, .-lex_66
/* end function lex_66 */

.text
lex_67:
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
	jnz .Lbb568
	movl $0, %eax
	jmp .Lbb569
.Lbb568:
	callq inc_offset
	movl $1, %eax
.Lbb569:
	leave
	ret
.type lex_67, @function
.size lex_67, .-lex_67
/* end function lex_67 */

.text
lex_68:
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
	jnz .Lbb572
	movl $0, %eax
	jmp .Lbb573
.Lbb572:
	callq inc_offset
	movl $1, %eax
.Lbb573:
	leave
	ret
.type lex_68, @function
.size lex_68, .-lex_68
/* end function lex_68 */

.text
lex_65:
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
	callq lex_66
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb579
	movq %rbx, offset_ptr(%rip)
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_67
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb579
	movq %rbx, offset_ptr(%rip)
	callq lex_68
	cmpl $0, %eax
	jnz .Lbb579
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb580
.Lbb579:
	movl $1, %eax
.Lbb580:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_65, @function
.size lex_65, .-lex_65
/* end function lex_65 */

.text
lex_70:
	pushq %rbp
	movq %rsp, %rbp
	movl $95, %edx
	callq cmp_current
	cmpl $0, %eax
	jnz .Lbb583
	movl $0, %eax
	jmp .Lbb584
.Lbb583:
	callq inc_offset
	movl $1, %eax
.Lbb584:
	leave
	ret
.type lex_70, @function
.size lex_70, .-lex_70
/* end function lex_70 */

.text
lex_71:
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
	jnz .Lbb587
	movl $0, %eax
	jmp .Lbb588
.Lbb587:
	callq inc_offset
	movl $1, %eax
.Lbb588:
	leave
	ret
.type lex_71, @function
.size lex_71, .-lex_71
/* end function lex_71 */

.text
lex_72:
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
	jnz .Lbb591
	movl $0, %eax
	jmp .Lbb592
.Lbb591:
	callq inc_offset
	movl $1, %eax
.Lbb592:
	leave
	ret
.type lex_72, @function
.size lex_72, .-lex_72
/* end function lex_72 */

.text
lex_73:
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
	jnz .Lbb595
	movl $0, %eax
	jmp .Lbb596
.Lbb595:
	callq inc_offset
	movl $1, %eax
.Lbb596:
	leave
	ret
.type lex_73, @function
.size lex_73, .-lex_73
/* end function lex_73 */

.text
lex_69:
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
	callq lex_70
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb603
	movq %rbx, offset_ptr(%rip)
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_71
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb603
	movq %rbx, offset_ptr(%rip)
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_72
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb603
	movq %rbx, offset_ptr(%rip)
	callq lex_73
	cmpl $0, %eax
	jnz .Lbb603
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb604
.Lbb603:
	movl $1, %eax
.Lbb604:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_69, @function
.size lex_69, .-lex_69
/* end function lex_69 */

.text
lex_74:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
.Lbb606:
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_69
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb608
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jnz .Lbb606
.Lbb608:
	movl $1, %eax
	popq %r12
	popq %rbx
	leave
	ret
.type lex_74, @function
.size lex_74, .-lex_74
/* end function lex_74 */

.text
lex_64:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq offset_ptr(%rip), %rbx
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_65
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb613
	callq lex_74
	cmpl $0, %eax
	jnz .Lbb614
.Lbb613:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb615
.Lbb614:
	movl $1, %eax
.Lbb615:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_64, @function
.size lex_64, .-lex_64
/* end function lex_64 */

.text
lex_ident:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_64
	cmpl $0, %eax
	jnz .Lbb618
	movl $0, %eax
	jmp .Lbb620
.Lbb618:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb620
	movq offset_ptr(%rip), %rax
.Lbb620:
	leave
	ret
.type lex_ident, @function
.size lex_ident, .-lex_ident
/* end function lex_ident */

.text
lex_76:
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
	jnz .Lbb624
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb625
.Lbb624:
	movl $1, %eax
.Lbb625:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_76, @function
.size lex_76, .-lex_76
/* end function lex_76 */

.text
lex_75:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_76
	cmpl $0, %eax
	jnz .Lbb629
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb630
.Lbb629:
	movl $1, %eax
.Lbb630:
	popq %rbx
	leave
	ret
.type lex_75, @function
.size lex_75, .-lex_75
/* end function lex_75 */

.text
lex_semi:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_75
	cmpl $0, %eax
	jnz .Lbb633
	movl $0, %eax
	jmp .Lbb635
.Lbb633:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb635
	movq offset_ptr(%rip), %rax
.Lbb635:
	leave
	ret
.type lex_semi, @function
.size lex_semi, .-lex_semi
/* end function lex_semi */

.text
lex_78:
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
	jnz .Lbb639
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb640
.Lbb639:
	movl $1, %eax
.Lbb640:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_78, @function
.size lex_78, .-lex_78
/* end function lex_78 */

.text
lex_81:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rbx
	movl $92, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb644
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb645
.Lbb644:
	movl $1, %eax
.Lbb645:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_81, @function
.size lex_81, .-lex_81
/* end function lex_81 */

.text
lex_82:
	pushq %rbp
	movq %rsp, %rbp
	callq inc_offset
	movl $1, %eax
	leave
	ret
.type lex_82, @function
.size lex_82, .-lex_82
/* end function lex_82 */

.text
lex_80:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq offset_ptr(%rip), %rbx
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_81
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb651
	callq lex_82
	cmpl $0, %eax
	jnz .Lbb652
.Lbb651:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb653
.Lbb652:
	movl $1, %eax
.Lbb653:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_80, @function
.size lex_80, .-lex_80
/* end function lex_80 */

.text
lex_85:
	pushq %rbp
	movq %rsp, %rbp
	movl $34, %edx
	callq cmp_current
	cmpl $0, %eax
	jnz .Lbb656
	movl $0, %eax
	jmp .Lbb657
.Lbb656:
	callq inc_offset
	movl $1, %eax
.Lbb657:
	leave
	ret
.type lex_85, @function
.size lex_85, .-lex_85
/* end function lex_85 */

.text
lex_87:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rbx
	movl $92, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb661
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb662
.Lbb661:
	movl $1, %eax
.Lbb662:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_87, @function
.size lex_87, .-lex_87
/* end function lex_87 */

.text
lex_86:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_87
	leave
	ret
.type lex_86, @function
.size lex_86, .-lex_86
/* end function lex_86 */

.text
lex_84:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq offset_ptr(%rip), %rbx
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_85
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb669
	callq lex_86
	cmpl $0, %eax
	jnz .Lbb669
	callq inc_offset
	movl $1, %eax
	jmp .Lbb670
.Lbb669:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb670:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_84, @function
.size lex_84, .-lex_84
/* end function lex_84 */

.text
lex_83:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_84
	cmpl $0, %eax
	jnz .Lbb674
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb675
.Lbb674:
	movl $1, %eax
.Lbb675:
	popq %rbx
	leave
	ret
.type lex_83, @function
.size lex_83, .-lex_83
/* end function lex_83 */

.text
lex_79:
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
	callq lex_80
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb680
	movq %rbx, offset_ptr(%rip)
	callq lex_83
	cmpl $0, %eax
	jnz .Lbb680
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb681
.Lbb680:
	movl $1, %eax
.Lbb681:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_79, @function
.size lex_79, .-lex_79
/* end function lex_79 */

.text
lex_88:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
.Lbb683:
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_79
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb685
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jnz .Lbb683
.Lbb685:
	movl $1, %eax
	popq %r12
	popq %rbx
	leave
	ret
.type lex_88, @function
.size lex_88, .-lex_88
/* end function lex_88 */

.text
lex_89:
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
	jnz .Lbb690
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb691
.Lbb690:
	movl $1, %eax
.Lbb691:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_89, @function
.size lex_89, .-lex_89
/* end function lex_89 */

.text
lex_77:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movq offset_ptr(%rip), %rbx
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_78
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb696
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_88
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb696
	callq lex_89
	cmpl $0, %eax
	jnz .Lbb697
.Lbb696:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb698
.Lbb697:
	movl $1, %eax
.Lbb698:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type lex_77, @function
.size lex_77, .-lex_77
/* end function lex_77 */

.text
lex_string:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_77
	cmpl $0, %eax
	jnz .Lbb701
	movl $0, %eax
	jmp .Lbb703
.Lbb701:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb703
	movq offset_ptr(%rip), %rax
.Lbb703:
	leave
	ret
.type lex_string, @function
.size lex_string, .-lex_string
/* end function lex_string */

.text
lex_91:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movq offset_ptr(%rip), %rbx
	movl $64, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb707
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb708
.Lbb707:
	movl $1, %eax
.Lbb708:
	popq %r12
	popq %rbx
	leave
	ret
.type lex_91, @function
.size lex_91, .-lex_91
/* end function lex_91 */

.text
lex_90:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	movq offset_ptr(%rip), %rbx
	callq lex_91
	cmpl $0, %eax
	jnz .Lbb712
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb713
.Lbb712:
	movl $1, %eax
.Lbb713:
	popq %rbx
	leave
	ret
.type lex_90, @function
.size lex_90, .-lex_90
/* end function lex_90 */

.text
lex_at:
	pushq %rbp
	movq %rsp, %rbp
	callq lex_90
	cmpl $0, %eax
	jnz .Lbb716
	movl $0, %eax
	jmp .Lbb718
.Lbb716:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb718
	movq offset_ptr(%rip), %rax
.Lbb718:
	leave
	ret
.type lex_at, @function
.size lex_at, .-lex_at
/* end function lex_at */

.text
.globl lex
lex:
	pushq %rbp
	movq %rsp, %rbp
	subq $632, %rsp
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
.Lbb721:
	movq %rdx, %r14
	movq offset_ptr(%rip), %rax
	cmpq %r14, %rax
	jz .Lbb792
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_KEYWORD
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb790
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_PARSER
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb788
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_TOKEN
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb786
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_HIGHTLIGHT
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb784
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_FOLD
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb782
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_whitespace
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb780
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_int
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb778
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_colon
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb776
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_comma
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb774
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_bar
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb772
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_dot
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb770
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_l_bracket
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb768
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_r_bracket
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb766
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_l_paren
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb764
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_r_paren
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb762
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_l_brace
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb760
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_r_brace
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb758
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_plus
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb756
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_eq
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb754
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_ident
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb752
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_semi
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb750
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_string
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb748
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_at
	movq %r14, %rdx
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jz .Lbb746
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $22, %esi
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
	jmp .Lbb721
.Lbb746:
	movq %r12, %rdx
	movq -16(%rbp), %r12
	movq %rdx, %rcx
	addq $1, %rcx
	movl $23, %esi
	leaq -64(%rbp), %rdi
	callq new_token
	movq %rax, %rdx
	movl $24, %esi
	movq %rbx, %rdi
	callq push
	movq %r12, %rax
	movq $0, offset_ptr(%rip)
	movq $0, group_end(%rip)
	jmp .Lbb793
.Lbb748:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $21, %esi
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
	jmp .Lbb721
.Lbb750:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $20, %esi
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
	jmp .Lbb721
.Lbb752:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $19, %esi
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
	jmp .Lbb721
.Lbb754:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $18, %esi
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
	jmp .Lbb721
.Lbb756:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $17, %esi
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
	jmp .Lbb721
.Lbb758:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $16, %esi
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
	jmp .Lbb721
.Lbb760:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $15, %esi
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
	jmp .Lbb721
.Lbb762:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $14, %esi
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
	jmp .Lbb721
.Lbb764:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $13, %esi
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
	jmp .Lbb721
.Lbb766:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $12, %esi
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
	jmp .Lbb721
.Lbb768:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $11, %esi
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
	jmp .Lbb721
.Lbb770:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $10, %esi
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
	jmp .Lbb721
.Lbb772:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $9, %esi
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
	jmp .Lbb721
.Lbb774:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $8, %esi
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
	jmp .Lbb721
.Lbb776:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $7, %esi
	leaq -448(%rbp), %rdi
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
	jmp .Lbb721
.Lbb778:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $6, %esi
	leaq -472(%rbp), %rdi
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
	jmp .Lbb721
.Lbb780:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $5, %esi
	leaq -496(%rbp), %rdi
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
	jmp .Lbb721
.Lbb782:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $4, %esi
	leaq -520(%rbp), %rdi
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
	jmp .Lbb721
.Lbb784:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $3, %esi
	leaq -544(%rbp), %rdi
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
	jmp .Lbb721
.Lbb786:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $2, %esi
	leaq -568(%rbp), %rdi
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
	jmp .Lbb721
.Lbb788:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $1, %esi
	leaq -592(%rbp), %rdi
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
	jmp .Lbb721
.Lbb790:
	movq %r14, %rdx
	movq offset_ptr(%rip), %rax
	movq %r12, %r14
	addq %rax, %r12
	movq %r12, %rcx
	movq %rdx, %r15
	movq %r14, %rdx
	movq %rsi, %r14
	movl $0, %esi
	leaq -616(%rbp), %rdi
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
	jmp .Lbb721
.Lbb792:
	movq -16(%rbp), %rax
.Lbb793:
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
KEYWORD_token_name:
	.ascii "KEYWORD"
	.byte 0
/* end data */

.data
.balign 8
KEYWORD_token_name_len:
	.quad 7
/* end data */

.data
.balign 8
PARSER_token_name:
	.ascii "PARSER"
	.byte 0
/* end data */

.data
.balign 8
PARSER_token_name_len:
	.quad 6
/* end data */

.data
.balign 8
TOKEN_token_name:
	.ascii "TOKEN"
	.byte 0
/* end data */

.data
.balign 8
TOKEN_token_name_len:
	.quad 5
/* end data */

.data
.balign 8
HIGHTLIGHT_token_name:
	.ascii "HIGHTLIGHT"
	.byte 0
/* end data */

.data
.balign 8
HIGHTLIGHT_token_name_len:
	.quad 10
/* end data */

.data
.balign 8
FOLD_token_name:
	.ascii "FOLD"
	.byte 0
/* end data */

.data
.balign 8
FOLD_token_name_len:
	.quad 4
/* end data */

.data
.balign 8
whitespace_token_name:
	.ascii "whitespace"
	.byte 0
/* end data */

.data
.balign 8
whitespace_token_name_len:
	.quad 10
/* end data */

.data
.balign 8
int_token_name:
	.ascii "int"
	.byte 0
/* end data */

.data
.balign 8
int_token_name_len:
	.quad 3
/* end data */

.data
.balign 8
colon_token_name:
	.ascii "colon"
	.byte 0
/* end data */

.data
.balign 8
colon_token_name_len:
	.quad 5
/* end data */

.data
.balign 8
comma_token_name:
	.ascii "comma"
	.byte 0
/* end data */

.data
.balign 8
comma_token_name_len:
	.quad 5
/* end data */

.data
.balign 8
bar_token_name:
	.ascii "bar"
	.byte 0
/* end data */

.data
.balign 8
bar_token_name_len:
	.quad 3
/* end data */

.data
.balign 8
dot_token_name:
	.ascii "dot"
	.byte 0
/* end data */

.data
.balign 8
dot_token_name_len:
	.quad 3
/* end data */

.data
.balign 8
l_bracket_token_name:
	.ascii "l_bracket"
	.byte 0
/* end data */

.data
.balign 8
l_bracket_token_name_len:
	.quad 9
/* end data */

.data
.balign 8
r_bracket_token_name:
	.ascii "r_bracket"
	.byte 0
/* end data */

.data
.balign 8
r_bracket_token_name_len:
	.quad 9
/* end data */

.data
.balign 8
l_paren_token_name:
	.ascii "l_paren"
	.byte 0
/* end data */

.data
.balign 8
l_paren_token_name_len:
	.quad 7
/* end data */

.data
.balign 8
r_paren_token_name:
	.ascii "r_paren"
	.byte 0
/* end data */

.data
.balign 8
r_paren_token_name_len:
	.quad 7
/* end data */

.data
.balign 8
l_brace_token_name:
	.ascii "l_brace"
	.byte 0
/* end data */

.data
.balign 8
l_brace_token_name_len:
	.quad 7
/* end data */

.data
.balign 8
r_brace_token_name:
	.ascii "r_brace"
	.byte 0
/* end data */

.data
.balign 8
r_brace_token_name_len:
	.quad 7
/* end data */

.data
.balign 8
plus_token_name:
	.ascii "plus"
	.byte 0
/* end data */

.data
.balign 8
plus_token_name_len:
	.quad 4
/* end data */

.data
.balign 8
eq_token_name:
	.ascii "eq"
	.byte 0
/* end data */

.data
.balign 8
eq_token_name_len:
	.quad 2
/* end data */

.data
.balign 8
ident_token_name:
	.ascii "ident"
	.byte 0
/* end data */

.data
.balign 8
ident_token_name_len:
	.quad 5
/* end data */

.data
.balign 8
semi_token_name:
	.ascii "semi"
	.byte 0
/* end data */

.data
.balign 8
semi_token_name_len:
	.quad 4
/* end data */

.data
.balign 8
string_token_name:
	.ascii "string"
	.byte 0
/* end data */

.data
.balign 8
string_token_name_len:
	.quad 6
/* end data */

.data
.balign 8
at_token_name:
	.ascii "at"
	.byte 0
/* end data */

.data
.balign 8
at_token_name_len:
	.quad 2
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
	leaq KEYWORD_token_name(%rip), %rax
	jz .Lbb842
	cmpl $1, %edi
	leaq PARSER_token_name(%rip), %rax
	jz .Lbb841
	cmpl $2, %edi
	leaq TOKEN_token_name(%rip), %rax
	jz .Lbb840
	cmpl $3, %edi
	leaq HIGHTLIGHT_token_name(%rip), %rax
	jz .Lbb839
	cmpl $4, %edi
	leaq FOLD_token_name(%rip), %rax
	jz .Lbb838
	cmpl $5, %edi
	leaq whitespace_token_name(%rip), %rax
	jz .Lbb837
	cmpl $6, %edi
	leaq int_token_name(%rip), %rax
	jz .Lbb836
	cmpl $7, %edi
	leaq colon_token_name(%rip), %rax
	jz .Lbb835
	cmpl $8, %edi
	leaq comma_token_name(%rip), %rax
	jz .Lbb834
	cmpl $9, %edi
	leaq bar_token_name(%rip), %rax
	jz .Lbb833
	cmpl $10, %edi
	leaq dot_token_name(%rip), %rax
	jz .Lbb832
	cmpl $11, %edi
	leaq l_bracket_token_name(%rip), %rax
	jz .Lbb831
	cmpl $12, %edi
	leaq r_bracket_token_name(%rip), %rax
	jz .Lbb830
	cmpl $13, %edi
	leaq l_paren_token_name(%rip), %rax
	jz .Lbb829
	cmpl $14, %edi
	leaq r_paren_token_name(%rip), %rax
	jz .Lbb828
	cmpl $15, %edi
	leaq l_brace_token_name(%rip), %rax
	jz .Lbb827
	cmpl $16, %edi
	leaq r_brace_token_name(%rip), %rax
	jz .Lbb826
	cmpl $17, %edi
	leaq plus_token_name(%rip), %rax
	jz .Lbb825
	cmpl $18, %edi
	leaq eq_token_name(%rip), %rax
	jz .Lbb824
	cmpl $19, %edi
	leaq ident_token_name(%rip), %rax
	jz .Lbb823
	cmpl $20, %edi
	leaq semi_token_name(%rip), %rax
	jz .Lbb822
	cmpl $21, %edi
	leaq string_token_name(%rip), %rax
	jz .Lbb821
	cmpl $22, %edi
	leaq at_token_name(%rip), %rax
	jz .Lbb820
	leaq err_token_name(%rip), %rax
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb843
.Lbb820:
	movq %rax, %rdx
	movl $2, %eax
	jmp .Lbb843
.Lbb821:
	movq %rax, %rdx
	movl $6, %eax
	jmp .Lbb843
.Lbb822:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb843
.Lbb823:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb843
.Lbb824:
	movq %rax, %rdx
	movl $2, %eax
	jmp .Lbb843
.Lbb825:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb843
.Lbb826:
	movq %rax, %rdx
	movl $7, %eax
	jmp .Lbb843
.Lbb827:
	movq %rax, %rdx
	movl $7, %eax
	jmp .Lbb843
.Lbb828:
	movq %rax, %rdx
	movl $7, %eax
	jmp .Lbb843
.Lbb829:
	movq %rax, %rdx
	movl $7, %eax
	jmp .Lbb843
.Lbb830:
	movq %rax, %rdx
	movl $9, %eax
	jmp .Lbb843
.Lbb831:
	movq %rax, %rdx
	movl $9, %eax
	jmp .Lbb843
.Lbb832:
	movq %rax, %rdx
	movl $3, %eax
	jmp .Lbb843
.Lbb833:
	movq %rax, %rdx
	movl $3, %eax
	jmp .Lbb843
.Lbb834:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb843
.Lbb835:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb843
.Lbb836:
	movq %rax, %rdx
	movl $3, %eax
	jmp .Lbb843
.Lbb837:
	movq %rax, %rdx
	movl $10, %eax
	jmp .Lbb843
.Lbb838:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb843
.Lbb839:
	movq %rax, %rdx
	movl $10, %eax
	jmp .Lbb843
.Lbb840:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb843
.Lbb841:
	movq %rax, %rdx
	movl $6, %eax
	jmp .Lbb843
.Lbb842:
	movq %rax, %rdx
	movl $7, %eax
.Lbb843:
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
	jz .Lbb987
	cmpq $1, %rcx
	jz .Lbb986
	cmpq $2, %rcx
	jz .Lbb985
	cmpq $3, %rcx
	jz .Lbb984
	cmpq $4, %rcx
	jz .Lbb983
	cmpq $5, %rcx
	jz .Lbb982
	cmpq $6, %rcx
	jz .Lbb981
	cmpq $7, %rcx
	jz .Lbb980
	cmpq $8, %rcx
	jz .Lbb979
	cmpq $9, %rcx
	jz .Lbb978
	cmpq $10, %rcx
	jz .Lbb977
	cmpq $11, %rcx
	jz .Lbb976
	cmpq $12, %rcx
	jz .Lbb975
	cmpq $13, %rcx
	jz .Lbb974
	cmpq $14, %rcx
	jz .Lbb973
	cmpq $15, %rcx
	jz .Lbb972
	cmpq $16, %rcx
	jz .Lbb971
	cmpq $17, %rcx
	jz .Lbb970
	cmpq $18, %rcx
	jz .Lbb969
	cmpq $19, %rcx
	jz .Lbb968
	cmpq $20, %rcx
	jz .Lbb967
	cmpq $21, %rcx
	jz .Lbb966
	cmpq $22, %rcx
	jz .Lbb965
	cmpq $23, %rcx
	jz .Lbb964
	cmpq $24, %rcx
	jz .Lbb963
	cmpq $25, %rcx
	jz .Lbb962
	cmpq $26, %rcx
	jz .Lbb961
	cmpq $27, %rcx
	jz .Lbb960
	cmpq $28, %rcx
	jz .Lbb959
	cmpq $29, %rcx
	jz .Lbb958
	cmpq $30, %rcx
	jz .Lbb957
	cmpq $31, %rcx
	jz .Lbb956
	cmpq $32, %rcx
	jz .Lbb955
	cmpq $33, %rcx
	jz .Lbb954
	cmpq $34, %rcx
	jz .Lbb953
	cmpq $35, %rcx
	jz .Lbb952
	cmpq $36, %rcx
	jz .Lbb951
	cmpq $37, %rcx
	jz .Lbb950
	cmpq $38, %rcx
	jz .Lbb949
	cmpq $39, %rcx
	jz .Lbb948
	cmpq $40, %rcx
	jz .Lbb947
	cmpq $41, %rcx
	jz .Lbb946
	cmpq $42, %rcx
	jz .Lbb945
	cmpq $43, %rcx
	jz .Lbb944
	cmpq $44, %rcx
	jz .Lbb943
	cmpq $45, %rcx
	jz .Lbb942
	cmpq $46, %rcx
	jz .Lbb941
	cmpq $47, %rcx
	jz .Lbb940
	cmpq $48, %rcx
	jz .Lbb939
	cmpq $49, %rcx
	jz .Lbb938
	cmpq $50, %rcx
	jz .Lbb937
	cmpq $51, %rcx
	jz .Lbb936
	cmpq $52, %rcx
	jz .Lbb935
	cmpq $53, %rcx
	jz .Lbb934
	cmpq $54, %rcx
	jz .Lbb933
	cmpq $55, %rcx
	jz .Lbb932
	cmpq $56, %rcx
	jz .Lbb931
	cmpq $57, %rcx
	jz .Lbb930
	cmpq $58, %rcx
	jz .Lbb929
	cmpq $59, %rcx
	jz .Lbb928
	cmpq $60, %rcx
	jz .Lbb927
	cmpq $61, %rcx
	jz .Lbb926
	cmpq $62, %rcx
	jz .Lbb925
	cmpq $63, %rcx
	jz .Lbb924
	cmpq $64, %rcx
	jz .Lbb923
	cmpq $65, %rcx
	jz .Lbb922
	cmpq $66, %rcx
	jz .Lbb921
	cmpq $67, %rcx
	jz .Lbb920
	cmpq $68, %rcx
	jz .Lbb919
	cmpq $69, %rcx
	jz .Lbb918
	cmpq $70, %rcx
	jz .Lbb917
	movl $0, %eax
	jmp .Lbb988
.Lbb917:
	callq peak_70
	jmp .Lbb988
.Lbb918:
	callq peak_69
	jmp .Lbb988
.Lbb919:
	callq peak_68
	jmp .Lbb988
.Lbb920:
	callq peak_67
	jmp .Lbb988
.Lbb921:
	callq peak_66
	jmp .Lbb988
.Lbb922:
	callq peak_65
	jmp .Lbb988
.Lbb923:
	callq peak_64
	jmp .Lbb988
.Lbb924:
	callq peak_63
	jmp .Lbb988
.Lbb925:
	callq peak_62
	jmp .Lbb988
.Lbb926:
	callq peak_61
	jmp .Lbb988
.Lbb927:
	callq peak_60
	jmp .Lbb988
.Lbb928:
	callq peak_59
	jmp .Lbb988
.Lbb929:
	callq peak_58
	jmp .Lbb988
.Lbb930:
	callq peak_57
	jmp .Lbb988
.Lbb931:
	callq peak_56
	jmp .Lbb988
.Lbb932:
	callq peak_55
	jmp .Lbb988
.Lbb933:
	callq peak_54
	jmp .Lbb988
.Lbb934:
	callq peak_53
	jmp .Lbb988
.Lbb935:
	callq peak_52
	jmp .Lbb988
.Lbb936:
	callq peak_51
	jmp .Lbb988
.Lbb937:
	callq peak_50
	jmp .Lbb988
.Lbb938:
	callq peak_49
	jmp .Lbb988
.Lbb939:
	callq peak_48
	jmp .Lbb988
.Lbb940:
	callq peak_47
	jmp .Lbb988
.Lbb941:
	callq peak_46
	jmp .Lbb988
.Lbb942:
	callq peak_45
	jmp .Lbb988
.Lbb943:
	callq peak_44
	jmp .Lbb988
.Lbb944:
	callq peak_43
	jmp .Lbb988
.Lbb945:
	callq peak_42
	jmp .Lbb988
.Lbb946:
	callq peak_41
	jmp .Lbb988
.Lbb947:
	callq peak_40
	jmp .Lbb988
.Lbb948:
	callq peak_39
	jmp .Lbb988
.Lbb949:
	callq peak_38
	jmp .Lbb988
.Lbb950:
	callq peak_37
	jmp .Lbb988
.Lbb951:
	callq peak_36
	jmp .Lbb988
.Lbb952:
	callq peak_35
	jmp .Lbb988
.Lbb953:
	callq peak_34
	jmp .Lbb988
.Lbb954:
	callq peak_33
	jmp .Lbb988
.Lbb955:
	callq peak_32
	jmp .Lbb988
.Lbb956:
	callq peak_31
	jmp .Lbb988
.Lbb957:
	callq peak_30
	jmp .Lbb988
.Lbb958:
	callq peak_29
	jmp .Lbb988
.Lbb959:
	callq peak_28
	jmp .Lbb988
.Lbb960:
	callq peak_27
	jmp .Lbb988
.Lbb961:
	callq peak_26
	jmp .Lbb988
.Lbb962:
	callq peak_25
	jmp .Lbb988
.Lbb963:
	callq peak_24
	jmp .Lbb988
.Lbb964:
	callq peak_23
	jmp .Lbb988
.Lbb965:
	callq peak_22
	jmp .Lbb988
.Lbb966:
	callq peak_21
	jmp .Lbb988
.Lbb967:
	callq peak_20
	jmp .Lbb988
.Lbb968:
	callq peak_19
	jmp .Lbb988
.Lbb969:
	callq peak_18
	jmp .Lbb988
.Lbb970:
	callq peak_17
	jmp .Lbb988
.Lbb971:
	callq peak_16
	jmp .Lbb988
.Lbb972:
	callq peak_15
	jmp .Lbb988
.Lbb973:
	callq peak_14
	jmp .Lbb988
.Lbb974:
	callq peak_13
	jmp .Lbb988
.Lbb975:
	callq peak_12
	jmp .Lbb988
.Lbb976:
	callq peak_11
	jmp .Lbb988
.Lbb977:
	callq peak_10
	jmp .Lbb988
.Lbb978:
	callq peak_9
	jmp .Lbb988
.Lbb979:
	callq peak_8
	jmp .Lbb988
.Lbb980:
	callq peak_7
	jmp .Lbb988
.Lbb981:
	callq peak_6
	jmp .Lbb988
.Lbb982:
	callq peak_5
	jmp .Lbb988
.Lbb983:
	callq peak_4
	jmp .Lbb988
.Lbb984:
	callq peak_3
	jmp .Lbb988
.Lbb985:
	callq peak_2
	jmp .Lbb988
.Lbb986:
	callq peak_1
	jmp .Lbb988
.Lbb987:
	callq peak_0
.Lbb988:
	leave
	ret
.type peak_by_id, @function
.size peak_by_id, .-peak_by_id
/* end function peak_by_id */

.text
parse_0:
	pushq %rbp
	movq %rsp, %rbp
	subq $40, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movl %esi, %r12d
	movl $7, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_22
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb993
	movq %rdi, %rbx
	callq parse_25
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb992
	callq exit_group
	movq %rbx, %rax
	jmp .Lbb994
.Lbb992:
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
	imulq $64, %r13, %rdi
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
	jmp .Lbb994
.Lbb993:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb994:
	popq %r15
	popq %r14
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
	callq peak_22
	leave
	ret
.type peak_0, @function
.size peak_0, .-peak_0
/* end function peak_0 */

.data
.balign 8
expected_0_data:
	.quad 0
	.quad 13
	.quad 1
	.quad 1
/* end data */

.text
expected_0:
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
	leaq expected_0_data(%rip), %rsi
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
.type expected_0, @function
.size expected_0, .-expected_0
/* end function expected_0 */

.text
parse_1:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb1000:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1012
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $19, %rsi
	jz .Lbb1011
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1005
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1000
.Lbb1005:
	cmpl $0, %r12d
	jz .Lbb1010
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1010
.Lbb1007:
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
	jz .Lbb1009
	cmpl $0, %ebx
	jz .Lbb1010
	jmp .Lbb1007
.Lbb1009:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1013
.Lbb1010:
	movl $1, %eax
	jmp .Lbb1013
.Lbb1011:
	callq bump
	movl $0, %eax
	jmp .Lbb1013
.Lbb1012:
	movl $2, %eax
.Lbb1013:
	popq %r13
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
	jnz .Lbb1023
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $19, %rax
	jz .Lbb1022
	cmpl $0, %edx
	jz .Lbb1021
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1021
.Lbb1018:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1020
	cmpl $0, %ebx
	jz .Lbb1021
	jmp .Lbb1018
.Lbb1020:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1024
.Lbb1021:
	movl $1, %eax
	jmp .Lbb1024
.Lbb1022:
	movl $0, %eax
	jmp .Lbb1024
.Lbb1023:
	movl $2, %eax
.Lbb1024:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_1, @function
.size peak_1, .-peak_1
/* end function peak_1 */

.data
.balign 8
expected_1_data:
	.quad 0
	.quad 19
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
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movl $1, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rdi, %rbx
	callq parse_1
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1029
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb1030
.Lbb1029:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1030:
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
	callq peak_1
	leave
	ret
.type peak_2, @function
.size peak_2, .-peak_2
/* end function peak_2 */

.data
.balign 8
expected_2_data:
	.quad 1
	.quad 1
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
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb1036:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1048
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $13, %rsi
	jz .Lbb1047
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1041
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1036
.Lbb1041:
	cmpl $0, %r12d
	jz .Lbb1046
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1046
.Lbb1043:
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
	jz .Lbb1045
	cmpl $0, %ebx
	jz .Lbb1046
	jmp .Lbb1043
.Lbb1045:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1049
.Lbb1046:
	movl $1, %eax
	jmp .Lbb1049
.Lbb1047:
	callq bump
	movl $0, %eax
	jmp .Lbb1049
.Lbb1048:
	movl $2, %eax
.Lbb1049:
	popq %r13
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
	jnz .Lbb1059
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $13, %rax
	jz .Lbb1058
	cmpl $0, %edx
	jz .Lbb1057
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1057
.Lbb1054:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1056
	cmpl $0, %ebx
	jz .Lbb1057
	jmp .Lbb1054
.Lbb1056:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1060
.Lbb1057:
	movl $1, %eax
	jmp .Lbb1060
.Lbb1058:
	movl $0, %eax
	jmp .Lbb1060
.Lbb1059:
	movl $2, %eax
.Lbb1060:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_3, @function
.size peak_3, .-peak_3
/* end function peak_3 */

.data
.balign 8
expected_3_data:
	.quad 0
	.quad 13
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
.Lbb1064:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1076
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $14, %rsi
	jz .Lbb1075
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1069
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1064
.Lbb1069:
	cmpl $0, %r12d
	jz .Lbb1074
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1074
.Lbb1071:
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
	jz .Lbb1073
	cmpl $0, %ebx
	jz .Lbb1074
	jmp .Lbb1071
.Lbb1073:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1077
.Lbb1074:
	movl $1, %eax
	jmp .Lbb1077
.Lbb1075:
	callq bump
	movl $0, %eax
	jmp .Lbb1077
.Lbb1076:
	movl $2, %eax
.Lbb1077:
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
	jnz .Lbb1087
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $14, %rax
	jz .Lbb1086
	cmpl $0, %edx
	jz .Lbb1085
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1085
.Lbb1082:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1084
	cmpl $0, %ebx
	jz .Lbb1085
	jmp .Lbb1082
.Lbb1084:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1088
.Lbb1085:
	movl $1, %eax
	jmp .Lbb1088
.Lbb1086:
	movl $0, %eax
	jmp .Lbb1088
.Lbb1087:
	movl $2, %eax
.Lbb1088:
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
	subq $40, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_3
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1105
	movl %esi, %r12d
	movl $4, %esi
	movq %rdi, %rbx
	callq push_delim
	movl %r12d, %esi
	movq %rbx, %rdi
.Lbb1093:
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_0
	movq %rbx, %rdi
	cmpq $1, %rax
	jnz .Lbb1095
	movq %rdi, %rbx
	callq bump_err
	movl %r12d, %esi
	movq %rbx, %rdi
	jmp .Lbb1093
.Lbb1095:
	movl %r12d, %esi
	movq 64(%rdi), %rcx
	movq %rcx, %rbx
	addq $2, %rbx
	cmpq %rax, %rbx
	jnz .Lbb1100
	movl %esi, %r12d
.Lbb1098:
	movq %rdi, %r13
	leaq -24(%rbp), %rdi
	callq expected_0
	movq %r13, %rdi
	movq %rax, %rsi
	movq %rdi, %r13
	callq missing
	movq %r13, %rdi
	movl %r12d, %esi
.Lbb1100:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_4
	movq %r12, %rdi
	cmpq $1, %rax
	jnz .Lbb1102
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb1100
.Lbb1102:
	movl %r13d, %r12d
	cmpq %rax, %rbx
	jz .Lbb1098
	callq pop_delim
	movl $0, %eax
.Lbb1105:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_5, @function
.size parse_5, .-parse_5
/* end function parse_5 */

.text
peak_5:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_3
	leave
	ret
.type peak_5, @function
.size peak_5, .-peak_5
/* end function peak_5 */

.data
.balign 8
expected_5_data:
	.quad 0
	.quad 13
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
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_5
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1112
	callq parse_2
.Lbb1112:
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
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %edx, %r13d
	movq %rsi, %r12
	movq %rdi, %rbx
	callq peak_5
	movl %r13d, %edx
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1115
	callq peak_2
.Lbb1115:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_6, @function
.size peak_6, .-peak_6
/* end function peak_6 */

.data
.balign 8
expected_6_data:
	.quad 0
	.quad 13
	.quad 1
	.quad 1
/* end data */

.text
expected_6:
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
	leaq expected_6_data(%rip), %rsi
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
.type expected_6, @function
.size expected_6, .-expected_6
/* end function expected_6 */

.text
parse_7:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb1119:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1131
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $19, %rsi
	jz .Lbb1130
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1124
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1119
.Lbb1124:
	cmpl $0, %r12d
	jz .Lbb1129
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1129
.Lbb1126:
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
	jz .Lbb1128
	cmpl $0, %ebx
	jz .Lbb1129
	jmp .Lbb1126
.Lbb1128:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1132
.Lbb1129:
	movl $1, %eax
	jmp .Lbb1132
.Lbb1130:
	callq bump
	movl $0, %eax
	jmp .Lbb1132
.Lbb1131:
	movl $2, %eax
.Lbb1132:
	popq %r13
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
	movl %edx, %r12d
	movq %rsi, %r13
	movq %rdi, %rbx
	callq is_eof
	movq %r13, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1142
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $19, %rax
	jz .Lbb1141
	cmpl $0, %edx
	jz .Lbb1140
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1140
.Lbb1137:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1139
	cmpl $0, %ebx
	jz .Lbb1140
	jmp .Lbb1137
.Lbb1139:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1143
.Lbb1140:
	movl $1, %eax
	jmp .Lbb1143
.Lbb1141:
	movl $0, %eax
	jmp .Lbb1143
.Lbb1142:
	movl $2, %eax
.Lbb1143:
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
	.quad 0
	.quad 19
/* end data */

.text
expected_7:
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
	leaq expected_7_data(%rip), %rsi
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
	movl $3, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rdi, %rbx
	callq parse_7
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1148
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb1149
.Lbb1148:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1149:
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
	.quad 3
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
.Lbb1155:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1167
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $10, %rsi
	jz .Lbb1166
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1160
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1155
.Lbb1160:
	cmpl $0, %r12d
	jz .Lbb1165
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1165
.Lbb1162:
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
	jz .Lbb1164
	cmpl $0, %ebx
	jz .Lbb1165
	jmp .Lbb1162
.Lbb1164:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1168
.Lbb1165:
	movl $1, %eax
	jmp .Lbb1168
.Lbb1166:
	callq bump
	movl $0, %eax
	jmp .Lbb1168
.Lbb1167:
	movl $2, %eax
.Lbb1168:
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
	jnz .Lbb1178
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $10, %rax
	jz .Lbb1177
	cmpl $0, %edx
	jz .Lbb1176
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1176
.Lbb1173:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1175
	cmpl $0, %ebx
	jz .Lbb1176
	jmp .Lbb1173
.Lbb1175:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1179
.Lbb1176:
	movl $1, %eax
	jmp .Lbb1179
.Lbb1177:
	movl $0, %eax
	jmp .Lbb1179
.Lbb1178:
	movl $2, %eax
.Lbb1179:
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
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb1183:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1195
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $8, %rsi
	jz .Lbb1194
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1188
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1183
.Lbb1188:
	cmpl $0, %r12d
	jz .Lbb1193
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1193
.Lbb1190:
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
	jz .Lbb1192
	cmpl $0, %ebx
	jz .Lbb1193
	jmp .Lbb1190
.Lbb1192:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1196
.Lbb1193:
	movl $1, %eax
	jmp .Lbb1196
.Lbb1194:
	callq bump
	movl $0, %eax
	jmp .Lbb1196
.Lbb1195:
	movl $2, %eax
.Lbb1196:
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
	jnz .Lbb1206
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $8, %rax
	jz .Lbb1205
	cmpl $0, %edx
	jz .Lbb1204
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1204
.Lbb1201:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1203
	cmpl $0, %ebx
	jz .Lbb1204
	jmp .Lbb1201
.Lbb1203:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1207
.Lbb1204:
	movl $1, %eax
	jmp .Lbb1207
.Lbb1205:
	movl $0, %eax
	jmp .Lbb1207
.Lbb1206:
	movl $2, %eax
.Lbb1207:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_10, @function
.size peak_10, .-peak_10
/* end function peak_10 */

.data
.balign 8
expected_10_data:
	.quad 0
	.quad 8
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
	subq $56, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movl %esi, %r12d
	movl $0, %esi
	movq %rdi, %rbx
	callq push_delim
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rax, %rbx
	movl %esi, %r13d
	movl $10, %esi
	movq %rdi, %r12
	callq push_delim
	movl %r13d, %esi
	movq %r12, %rdi
	movq %rax, %r12
	movl %esi, %r14d
	movq %rdi, %r13
	callq parse_0
	movl %r14d, %esi
	movq %r13, %rdi
	cmpl $0, %eax
	jnz .Lbb1227
.Lbb1211:
	movl %esi, %r14d
	movq %rdi, %r13
	callq parse_10
	movq %r13, %rdi
	cmpq $1, %rax
	jz .Lbb1226
	cmpl $0, %eax
	jnz .Lbb1214
	movl %r14d, %esi
	jmp .Lbb1218
.Lbb1214:
	cmpq $2, %rax
	jz .Lbb1225
	cmpq %rax, %rbx
	jnz .Lbb1225
	movq %rdi, %r13
	leaq -48(%rbp), %rdi
	callq expected_10
	movq %r13, %rdi
	movq %rax, %rsi
	movq %rdi, %r13
	callq missing
	movq %r13, %rdi
	movl %r14d, %esi
.Lbb1218:
	movl %esi, %r14d
	movq %rdi, %r13
	callq parse_0
	movq %r13, %rdi
	movq %rax, %r13
	cmpq $1, %r13
	jnz .Lbb1220
	movq %rdi, %r13
	callq bump_err
	movl %r14d, %esi
	movq %r13, %rdi
	jmp .Lbb1218
.Lbb1220:
	cmpl $0, %r13d
	jnz .Lbb1222
	movl %r14d, %esi
	jmp .Lbb1211
.Lbb1222:
	movq %rdi, %r15
	leaq -24(%rbp), %rdi
	callq expected_0
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	cmpq $2, %r13
	jz .Lbb1225
	cmpq %r13, %r12
	jnz .Lbb1225
	movl %r14d, %esi
	jmp .Lbb1211
.Lbb1225:
	callq pop_delim
	movl $0, %eax
	jmp .Lbb1229
.Lbb1226:
	movq %rdi, %r13
	callq bump_err
	movl %r14d, %esi
	movq %r13, %rdi
	jmp .Lbb1211
.Lbb1227:
	movq %rax, %rbx
	callq pop_delim
	movq %rbx, %rax
.Lbb1229:
	popq %r15
	popq %r14
	popq %r13
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
	callq peak_0
	leave
	ret
.type peak_11, @function
.size peak_11, .-peak_11
/* end function peak_11 */

.data
.balign 8
expected_11_data:
	.quad 0
	.quad 13
	.quad 1
	.quad 1
/* end data */

.text
expected_11:
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
	leaq expected_11_data(%rip), %rsi
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
.Lbb1235:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1247
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $13, %rsi
	jz .Lbb1246
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1240
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1235
.Lbb1240:
	cmpl $0, %r12d
	jz .Lbb1245
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1245
.Lbb1242:
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
	jz .Lbb1244
	cmpl $0, %ebx
	jz .Lbb1245
	jmp .Lbb1242
.Lbb1244:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1248
.Lbb1245:
	movl $1, %eax
	jmp .Lbb1248
.Lbb1246:
	callq bump
	movl $0, %eax
	jmp .Lbb1248
.Lbb1247:
	movl $2, %eax
.Lbb1248:
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
	jnz .Lbb1258
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $13, %rax
	jz .Lbb1257
	cmpl $0, %edx
	jz .Lbb1256
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1256
.Lbb1253:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1255
	cmpl $0, %ebx
	jz .Lbb1256
	jmp .Lbb1253
.Lbb1255:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1259
.Lbb1256:
	movl $1, %eax
	jmp .Lbb1259
.Lbb1257:
	movl $0, %eax
	jmp .Lbb1259
.Lbb1258:
	movl $2, %eax
.Lbb1259:
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
	.quad 13
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
.Lbb1263:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1275
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $14, %rsi
	jz .Lbb1274
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1268
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1263
.Lbb1268:
	cmpl $0, %r12d
	jz .Lbb1273
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1273
.Lbb1270:
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
	jz .Lbb1272
	cmpl $0, %ebx
	jz .Lbb1273
	jmp .Lbb1270
.Lbb1272:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1276
.Lbb1273:
	movl $1, %eax
	jmp .Lbb1276
.Lbb1274:
	callq bump
	movl $0, %eax
	jmp .Lbb1276
.Lbb1275:
	movl $2, %eax
.Lbb1276:
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
	jnz .Lbb1286
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $14, %rax
	jz .Lbb1285
	cmpl $0, %edx
	jz .Lbb1284
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1284
.Lbb1281:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1283
	cmpl $0, %ebx
	jz .Lbb1284
	jmp .Lbb1281
.Lbb1283:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1287
.Lbb1284:
	movl $1, %eax
	jmp .Lbb1287
.Lbb1285:
	movl $0, %eax
	jmp .Lbb1287
.Lbb1286:
	movl $2, %eax
.Lbb1287:
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
	.quad 14
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
	subq $40, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_12
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1304
	movl %esi, %r12d
	movl $13, %esi
	movq %rdi, %rbx
	callq push_delim
	movl %r12d, %esi
	movq %rbx, %rdi
.Lbb1292:
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_11
	movq %rbx, %rdi
	cmpq $1, %rax
	jnz .Lbb1294
	movq %rdi, %rbx
	callq bump_err
	movl %r12d, %esi
	movq %rbx, %rdi
	jmp .Lbb1292
.Lbb1294:
	movl %r12d, %esi
	movq 64(%rdi), %rcx
	movq %rcx, %rbx
	addq $2, %rbx
	cmpq %rax, %rbx
	jnz .Lbb1299
	movl %esi, %r12d
.Lbb1297:
	movq %rdi, %r13
	leaq -24(%rbp), %rdi
	callq expected_11
	movq %r13, %rdi
	movq %rax, %rsi
	movq %rdi, %r13
	callq missing
	movq %r13, %rdi
	movl %r12d, %esi
.Lbb1299:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_13
	movq %r12, %rdi
	cmpq $1, %rax
	jnz .Lbb1301
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb1299
.Lbb1301:
	movl %r13d, %r12d
	cmpq %rax, %rbx
	jz .Lbb1297
	callq pop_delim
	movl $0, %eax
.Lbb1304:
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
	.quad 0
	.quad 13
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
	subq $136, %rsp
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
	addq $5, %rbx
	movl %esi, %r14d
	movl $14, %esi
	movq %rdi, %r13
	callq push_long
	movl %r14d, %esi
	movq %r13, %rdi
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
	jnz .Lbb1338
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1313
	movl %r13d, %esi
	jmp .Lbb1319
.Lbb1313:
	cmpq $2, %rax
	jz .Lbb1317
	movq %rax, %r14
	movq %rbx, %rax
	subq $1, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -120(%rbp), %rdi
	callq expected_9
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jz .Lbb1316
	movl %r13d, %esi
	jmp .Lbb1319
.Lbb1316:
	movq %rax, %r12
	jmp .Lbb1323
.Lbb1317:
	movq %rdi, %r12
	leaq -96(%rbp), %rdi
	callq expected_9
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movq %r12, %rdi
	movl %r13d, %esi
.Lbb1319:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_8
	movl %r13d, %esi
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1322
	movl %esi, %r13d
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb1319
.Lbb1322:
	movl %esi, %r13d
.Lbb1323:
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1325
	movl %r13d, %esi
	jmp .Lbb1329
.Lbb1325:
	cmpq $2, %rax
	jz .Lbb1328
	movq %rax, %r14
	movq %rbx, %rax
	subq $2, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -72(%rbp), %rdi
	callq expected_8
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jz .Lbb1333
	movl %r13d, %esi
	jmp .Lbb1329
.Lbb1328:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_8
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb1329:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_14
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1332
	movq %rdi, %r12
	callq bump_err
	movq %r12, %rdi
	movl %r13d, %esi
	jmp .Lbb1329
.Lbb1332:
	movq %r12, %rax
.Lbb1333:
	cmpl $0, %eax
	jz .Lbb1337
	cmpq $2, %rax
	jz .Lbb1336
	movq %rbx, %rcx
	subq $2, %rcx
	cmpq %rcx, %rax
	jz .Lbb1337
.Lbb1336:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_14
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb1337:
	movl $0, %eax
	jmp .Lbb1339
.Lbb1338:
	movq %r12, %rax
.Lbb1339:
	popq %r15
	popq %r14
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
	callq peak_9
	leave
	ret
.type peak_15, @function
.size peak_15, .-peak_15
/* end function peak_15 */

.data
.balign 8
expected_15_data:
	.quad 0
	.quad 10
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
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movl $4, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rdi, %rbx
	callq parse_15
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1346
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb1347
.Lbb1346:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1347:
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
	callq peak_15
	leave
	ret
.type peak_16, @function
.size peak_16, .-peak_16
/* end function peak_16 */

.data
.balign 8
expected_16_data:
	.quad 1
	.quad 4
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
	movl $16, %esi
	movq %rdi, %rbx
	callq push_delim
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_16
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1359
	movq %rdi, %rbx
	callq is_eof
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1358
.Lbb1354:
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_16
	movq %rbx, %rdi
	cmpq $1, %rax
	jz .Lbb1357
	cmpl $0, %eax
	jnz .Lbb1358
	movl %r12d, %esi
	jmp .Lbb1354
.Lbb1357:
	movq %rdi, %rbx
	callq bump_err
	movl %r12d, %esi
	movq %rbx, %rdi
	jmp .Lbb1354
.Lbb1358:
	callq pop_delim
	movl $0, %eax
	jmp .Lbb1360
.Lbb1359:
	callq pop_delim
	movq %rbx, %rax
.Lbb1360:
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
	subq $40, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movl %esi, %r12d
	movl $5, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_6
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1369
	movq %rdi, %rbx
	callq parse_17
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1368
	callq exit_group
	movq %rbx, %rax
	jmp .Lbb1370
.Lbb1368:
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
	imulq $64, %r13, %rdi
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
	jmp .Lbb1370
.Lbb1369:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1370:
	popq %r15
	popq %r14
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
	callq peak_6
	leave
	ret
.type peak_18, @function
.size peak_18, .-peak_18
/* end function peak_18 */

.data
.balign 8
expected_18_data:
	.quad 0
	.quad 13
	.quad 1
	.quad 1
/* end data */

.text
expected_18:
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
	leaq expected_18_data(%rip), %rsi
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
.Lbb1376:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1388
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $17, %rsi
	jz .Lbb1387
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1381
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1376
.Lbb1381:
	cmpl $0, %r12d
	jz .Lbb1386
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1386
.Lbb1383:
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
	jz .Lbb1385
	cmpl $0, %ebx
	jz .Lbb1386
	jmp .Lbb1383
.Lbb1385:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1389
.Lbb1386:
	movl $1, %eax
	jmp .Lbb1389
.Lbb1387:
	callq bump
	movl $0, %eax
	jmp .Lbb1389
.Lbb1388:
	movl $2, %eax
.Lbb1389:
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
	jnz .Lbb1399
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $17, %rax
	jz .Lbb1398
	cmpl $0, %edx
	jz .Lbb1397
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1397
.Lbb1394:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1396
	cmpl $0, %ebx
	jz .Lbb1397
	jmp .Lbb1394
.Lbb1396:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1400
.Lbb1397:
	movl $1, %eax
	jmp .Lbb1400
.Lbb1398:
	movl $0, %eax
	jmp .Lbb1400
.Lbb1399:
	movl $2, %eax
.Lbb1400:
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
	.quad 17
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
	movl $18, %esi
	callq push_long
	movl %r13d, %esi
	movq %r12, %rdi
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_19
	movq %r12, %rdi
	movq %rax, %r12
	cmpl $0, %r12d
	jnz .Lbb1419
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1407
	movl %r13d, %esi
	jmp .Lbb1411
.Lbb1407:
	cmpq $2, %rax
	jz .Lbb1410
	movq %rax, %r14
	movq %rbx, %rax
	subq $1, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -72(%rbp), %rdi
	callq expected_19
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jz .Lbb1414
	movl %r13d, %esi
	jmp .Lbb1411
.Lbb1410:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_19
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb1411:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_18
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1413
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb1411
.Lbb1413:
	movq %r12, %rax
.Lbb1414:
	cmpl $0, %eax
	jz .Lbb1418
	cmpq $2, %rax
	jz .Lbb1417
	movq %rbx, %rcx
	subq $1, %rcx
	cmpq %rcx, %rax
	jz .Lbb1418
.Lbb1417:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_18
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb1418:
	movl $0, %eax
	jmp .Lbb1420
.Lbb1419:
	movq %r12, %rax
.Lbb1420:
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
	callq peak_19
	leave
	ret
.type peak_20, @function
.size peak_20, .-peak_20
/* end function peak_20 */

.data
.balign 8
expected_20_data:
	.quad 0
	.quad 17
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
	movl $20, %esi
	movq %rdi, %rbx
	callq push_delim
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_20
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1432
	movq %rdi, %rbx
	callq is_eof
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1431
.Lbb1427:
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_20
	movq %rbx, %rdi
	cmpq $1, %rax
	jz .Lbb1430
	cmpl $0, %eax
	jnz .Lbb1431
	movl %r12d, %esi
	jmp .Lbb1427
.Lbb1430:
	movq %rdi, %rbx
	callq bump_err
	movl %r12d, %esi
	movq %rbx, %rdi
	jmp .Lbb1427
.Lbb1431:
	callq pop_delim
	movl $0, %eax
	jmp .Lbb1433
.Lbb1432:
	callq pop_delim
	movq %rbx, %rax
.Lbb1433:
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
	.quad 0
	.quad 17
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
	subq $40, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movl %esi, %r12d
	movl $6, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_18
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1442
	movq %rdi, %rbx
	callq parse_21
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1441
	callq exit_group
	movq %rbx, %rax
	jmp .Lbb1443
.Lbb1441:
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
	imulq $64, %r13, %rdi
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
	jmp .Lbb1443
.Lbb1442:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1443:
	popq %r15
	popq %r14
	popq %r13
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
	callq peak_18
	leave
	ret
.type peak_22, @function
.size peak_22, .-peak_22
/* end function peak_22 */

.data
.balign 8
expected_22_data:
	.quad 0
	.quad 13
	.quad 1
	.quad 1
/* end data */

.text
expected_22:
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
	leaq expected_22_data(%rip), %rsi
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
.Lbb1449:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1461
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $9, %rsi
	jz .Lbb1460
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1454
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1449
.Lbb1454:
	cmpl $0, %r12d
	jz .Lbb1459
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1459
.Lbb1456:
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
	jz .Lbb1458
	cmpl $0, %ebx
	jz .Lbb1459
	jmp .Lbb1456
.Lbb1458:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1462
.Lbb1459:
	movl $1, %eax
	jmp .Lbb1462
.Lbb1460:
	callq bump
	movl $0, %eax
	jmp .Lbb1462
.Lbb1461:
	movl $2, %eax
.Lbb1462:
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
	jnz .Lbb1472
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $9, %rax
	jz .Lbb1471
	cmpl $0, %edx
	jz .Lbb1470
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1470
.Lbb1467:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1469
	cmpl $0, %ebx
	jz .Lbb1470
	jmp .Lbb1467
.Lbb1469:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1473
.Lbb1470:
	movl $1, %eax
	jmp .Lbb1473
.Lbb1471:
	movl $0, %eax
	jmp .Lbb1473
.Lbb1472:
	movl $2, %eax
.Lbb1473:
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
	.quad 9
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
	movl $22, %esi
	callq push_long
	movl %r13d, %esi
	movq %r12, %rdi
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_23
	movq %r12, %rdi
	movq %rax, %r12
	cmpl $0, %r12d
	jnz .Lbb1492
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1480
	movl %r13d, %esi
	jmp .Lbb1484
.Lbb1480:
	cmpq $2, %rax
	jz .Lbb1483
	movq %rax, %r14
	movq %rbx, %rax
	subq $1, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -72(%rbp), %rdi
	callq expected_23
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jz .Lbb1487
	movl %r13d, %esi
	jmp .Lbb1484
.Lbb1483:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_23
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb1484:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_22
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1486
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb1484
.Lbb1486:
	movq %r12, %rax
.Lbb1487:
	cmpl $0, %eax
	jz .Lbb1491
	cmpq $2, %rax
	jz .Lbb1490
	movq %rbx, %rcx
	subq $1, %rcx
	cmpq %rcx, %rax
	jz .Lbb1491
.Lbb1490:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_22
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb1491:
	movl $0, %eax
	jmp .Lbb1493
.Lbb1492:
	movq %r12, %rax
.Lbb1493:
	popq %r15
	popq %r14
	popq %r13
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
	callq peak_23
	leave
	ret
.type peak_24, @function
.size peak_24, .-peak_24
/* end function peak_24 */

.data
.balign 8
expected_24_data:
	.quad 0
	.quad 9
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

.text
parse_25:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movl $24, %esi
	movq %rdi, %rbx
	callq push_delim
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_24
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1505
	movq %rdi, %rbx
	callq is_eof
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1504
.Lbb1500:
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_24
	movq %rbx, %rdi
	cmpq $1, %rax
	jz .Lbb1503
	cmpl $0, %eax
	jnz .Lbb1504
	movl %r12d, %esi
	jmp .Lbb1500
.Lbb1503:
	movq %rdi, %rbx
	callq bump_err
	movl %r12d, %esi
	movq %rbx, %rdi
	jmp .Lbb1500
.Lbb1504:
	callq pop_delim
	movl $0, %eax
	jmp .Lbb1506
.Lbb1505:
	callq pop_delim
	movq %rbx, %rax
.Lbb1506:
	popq %r12
	popq %rbx
	leave
	ret
.type parse_25, @function
.size parse_25, .-parse_25
/* end function parse_25 */

.text
peak_25:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_24
	leave
	ret
.type peak_25, @function
.size peak_25, .-peak_25
/* end function peak_25 */

.data
.balign 8
expected_25_data:
	.quad 0
	.quad 9
/* end data */

.text
expected_25:
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
	leaq expected_25_data(%rip), %rsi
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
.type expected_25, @function
.size expected_25, .-expected_25
/* end function expected_25 */

.text
parse_26:
	pushq %rbp
	movq %rsp, %rbp
	subq $40, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movl %esi, %r12d
	movl $7, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_22
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1515
	movq %rdi, %rbx
	callq parse_25
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1514
	callq exit_group
	movq %rbx, %rax
	jmp .Lbb1516
.Lbb1514:
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
	imulq $64, %r13, %rdi
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
	jmp .Lbb1516
.Lbb1515:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1516:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_26, @function
.size parse_26, .-parse_26
/* end function parse_26 */

.text
peak_26:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_22
	leave
	ret
.type peak_26, @function
.size peak_26, .-peak_26
/* end function peak_26 */

.data
.balign 8
expected_26_data:
	.quad 0
	.quad 13
	.quad 1
	.quad 1
/* end data */

.text
expected_26:
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
	leaq expected_26_data(%rip), %rsi
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
.type expected_26, @function
.size expected_26, .-expected_26
/* end function expected_26 */

.text
parse_27:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb1522:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1534
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $0, %rsi
	jz .Lbb1533
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1527
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1522
.Lbb1527:
	cmpl $0, %r12d
	jz .Lbb1532
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1532
.Lbb1529:
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
	jz .Lbb1531
	cmpl $0, %ebx
	jz .Lbb1532
	jmp .Lbb1529
.Lbb1531:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1535
.Lbb1532:
	movl $1, %eax
	jmp .Lbb1535
.Lbb1533:
	callq bump
	movl $0, %eax
	jmp .Lbb1535
.Lbb1534:
	movl $2, %eax
.Lbb1535:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_27, @function
.size parse_27, .-parse_27
/* end function parse_27 */

.text
peak_27:
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
	jnz .Lbb1545
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $0, %rax
	jz .Lbb1544
	cmpl $0, %edx
	jz .Lbb1543
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1543
.Lbb1540:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1542
	cmpl $0, %ebx
	jz .Lbb1543
	jmp .Lbb1540
.Lbb1542:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1546
.Lbb1543:
	movl $1, %eax
	jmp .Lbb1546
.Lbb1544:
	movl $0, %eax
	jmp .Lbb1546
.Lbb1545:
	movl $2, %eax
.Lbb1546:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_27, @function
.size peak_27, .-peak_27
/* end function peak_27 */

.data
.balign 8
expected_27_data:
	.quad 0
	.quad 0
/* end data */

.text
expected_27:
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
	leaq expected_27_data(%rip), %rsi
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
.type expected_27, @function
.size expected_27, .-expected_27
/* end function expected_27 */

.text
parse_28:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb1550:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1562
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $19, %rsi
	jz .Lbb1561
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1555
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1550
.Lbb1555:
	cmpl $0, %r12d
	jz .Lbb1560
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1560
.Lbb1557:
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
	jz .Lbb1559
	cmpl $0, %ebx
	jz .Lbb1560
	jmp .Lbb1557
.Lbb1559:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1563
.Lbb1560:
	movl $1, %eax
	jmp .Lbb1563
.Lbb1561:
	callq bump
	movl $0, %eax
	jmp .Lbb1563
.Lbb1562:
	movl $2, %eax
.Lbb1563:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_28, @function
.size parse_28, .-parse_28
/* end function parse_28 */

.text
peak_28:
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
	jnz .Lbb1573
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $19, %rax
	jz .Lbb1572
	cmpl $0, %edx
	jz .Lbb1571
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1571
.Lbb1568:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1570
	cmpl $0, %ebx
	jz .Lbb1571
	jmp .Lbb1568
.Lbb1570:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1574
.Lbb1571:
	movl $1, %eax
	jmp .Lbb1574
.Lbb1572:
	movl $0, %eax
	jmp .Lbb1574
.Lbb1573:
	movl $2, %eax
.Lbb1574:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_28, @function
.size peak_28, .-peak_28
/* end function peak_28 */

.data
.balign 8
expected_28_data:
	.quad 0
	.quad 19
/* end data */

.text
expected_28:
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
	leaq expected_28_data(%rip), %rsi
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
.type expected_28, @function
.size expected_28, .-expected_28
/* end function expected_28 */

.text
parse_29:
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
	movl $28, %esi
	callq push_long
	movl %r13d, %esi
	movq %r12, %rdi
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_27
	movq %r12, %rdi
	movq %rax, %r12
	cmpl $0, %r12d
	jnz .Lbb1593
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1581
	movl %r13d, %esi
	jmp .Lbb1585
.Lbb1581:
	cmpq $2, %rax
	jz .Lbb1584
	movq %rax, %r14
	movq %rbx, %rax
	subq $1, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -72(%rbp), %rdi
	callq expected_27
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jz .Lbb1588
	movl %r13d, %esi
	jmp .Lbb1585
.Lbb1584:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_27
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb1585:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_28
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1587
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb1585
.Lbb1587:
	movq %r12, %rax
.Lbb1588:
	cmpl $0, %eax
	jz .Lbb1592
	cmpq $2, %rax
	jz .Lbb1591
	movq %rbx, %rcx
	subq $1, %rcx
	cmpq %rcx, %rax
	jz .Lbb1592
.Lbb1591:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_28
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb1592:
	movl $0, %eax
	jmp .Lbb1594
.Lbb1593:
	movq %r12, %rax
.Lbb1594:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_29, @function
.size parse_29, .-parse_29
/* end function parse_29 */

.text
peak_29:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_27
	leave
	ret
.type peak_29, @function
.size peak_29, .-peak_29
/* end function peak_29 */

.data
.balign 8
expected_29_data:
	.quad 0
	.quad 0
/* end data */

.text
expected_29:
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
	leaq expected_29_data(%rip), %rsi
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
.type expected_29, @function
.size expected_29, .-expected_29
/* end function expected_29 */

.text
parse_30:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movl $8, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rdi, %rbx
	callq parse_29
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1601
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb1602
.Lbb1601:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1602:
	popq %r12
	popq %rbx
	leave
	ret
.type parse_30, @function
.size parse_30, .-parse_30
/* end function parse_30 */

.text
peak_30:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_29
	leave
	ret
.type peak_30, @function
.size peak_30, .-peak_30
/* end function peak_30 */

.data
.balign 8
expected_30_data:
	.quad 1
	.quad 8
/* end data */

.text
expected_30:
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
	leaq expected_30_data(%rip), %rsi
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
.type expected_30, @function
.size expected_30, .-expected_30
/* end function expected_30 */

.text
parse_31:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb1608:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1620
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $2, %rsi
	jz .Lbb1619
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1613
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1608
.Lbb1613:
	cmpl $0, %r12d
	jz .Lbb1618
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1618
.Lbb1615:
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
	jz .Lbb1617
	cmpl $0, %ebx
	jz .Lbb1618
	jmp .Lbb1615
.Lbb1617:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1621
.Lbb1618:
	movl $1, %eax
	jmp .Lbb1621
.Lbb1619:
	callq bump
	movl $0, %eax
	jmp .Lbb1621
.Lbb1620:
	movl $2, %eax
.Lbb1621:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_31, @function
.size parse_31, .-parse_31
/* end function parse_31 */

.text
peak_31:
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
	jnz .Lbb1631
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $2, %rax
	jz .Lbb1630
	cmpl $0, %edx
	jz .Lbb1629
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1629
.Lbb1626:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1628
	cmpl $0, %ebx
	jz .Lbb1629
	jmp .Lbb1626
.Lbb1628:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1632
.Lbb1629:
	movl $1, %eax
	jmp .Lbb1632
.Lbb1630:
	movl $0, %eax
	jmp .Lbb1632
.Lbb1631:
	movl $2, %eax
.Lbb1632:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_31, @function
.size peak_31, .-peak_31
/* end function peak_31 */

.data
.balign 8
expected_31_data:
	.quad 0
	.quad 2
/* end data */

.text
expected_31:
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
	leaq expected_31_data(%rip), %rsi
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
.type expected_31, @function
.size expected_31, .-expected_31
/* end function expected_31 */

.text
parse_32:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb1636:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1648
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $19, %rsi
	jz .Lbb1647
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1641
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1636
.Lbb1641:
	cmpl $0, %r12d
	jz .Lbb1646
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1646
.Lbb1643:
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
	jz .Lbb1645
	cmpl $0, %ebx
	jz .Lbb1646
	jmp .Lbb1643
.Lbb1645:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1649
.Lbb1646:
	movl $1, %eax
	jmp .Lbb1649
.Lbb1647:
	callq bump
	movl $0, %eax
	jmp .Lbb1649
.Lbb1648:
	movl $2, %eax
.Lbb1649:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_32, @function
.size parse_32, .-parse_32
/* end function parse_32 */

.text
peak_32:
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
	jnz .Lbb1659
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $19, %rax
	jz .Lbb1658
	cmpl $0, %edx
	jz .Lbb1657
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1657
.Lbb1654:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1656
	cmpl $0, %ebx
	jz .Lbb1657
	jmp .Lbb1654
.Lbb1656:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1660
.Lbb1657:
	movl $1, %eax
	jmp .Lbb1660
.Lbb1658:
	movl $0, %eax
	jmp .Lbb1660
.Lbb1659:
	movl $2, %eax
.Lbb1660:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_32, @function
.size peak_32, .-peak_32
/* end function peak_32 */

.data
.balign 8
expected_32_data:
	.quad 0
	.quad 19
/* end data */

.text
expected_32:
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
	leaq expected_32_data(%rip), %rsi
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
.type expected_32, @function
.size expected_32, .-expected_32
/* end function expected_32 */

.text
parse_33:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb1664:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1676
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $18, %rsi
	jz .Lbb1675
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1669
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1664
.Lbb1669:
	cmpl $0, %r12d
	jz .Lbb1674
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1674
.Lbb1671:
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
	jz .Lbb1673
	cmpl $0, %ebx
	jz .Lbb1674
	jmp .Lbb1671
.Lbb1673:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1677
.Lbb1674:
	movl $1, %eax
	jmp .Lbb1677
.Lbb1675:
	callq bump
	movl $0, %eax
	jmp .Lbb1677
.Lbb1676:
	movl $2, %eax
.Lbb1677:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_33, @function
.size parse_33, .-parse_33
/* end function parse_33 */

.text
peak_33:
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
	jnz .Lbb1687
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $18, %rax
	jz .Lbb1686
	cmpl $0, %edx
	jz .Lbb1685
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1685
.Lbb1682:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1684
	cmpl $0, %ebx
	jz .Lbb1685
	jmp .Lbb1682
.Lbb1684:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1688
.Lbb1685:
	movl $1, %eax
	jmp .Lbb1688
.Lbb1686:
	movl $0, %eax
	jmp .Lbb1688
.Lbb1687:
	movl $2, %eax
.Lbb1688:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_33, @function
.size peak_33, .-peak_33
/* end function peak_33 */

.data
.balign 8
expected_33_data:
	.quad 0
	.quad 18
/* end data */

.text
expected_33:
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
	leaq expected_33_data(%rip), %rsi
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
.type expected_33, @function
.size expected_33, .-expected_33
/* end function expected_33 */

.text
parse_34:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb1692:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1704
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $21, %rsi
	jz .Lbb1703
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1697
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1692
.Lbb1697:
	cmpl $0, %r12d
	jz .Lbb1702
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1702
.Lbb1699:
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
	jz .Lbb1701
	cmpl $0, %ebx
	jz .Lbb1702
	jmp .Lbb1699
.Lbb1701:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1705
.Lbb1702:
	movl $1, %eax
	jmp .Lbb1705
.Lbb1703:
	callq bump
	movl $0, %eax
	jmp .Lbb1705
.Lbb1704:
	movl $2, %eax
.Lbb1705:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_34, @function
.size parse_34, .-parse_34
/* end function parse_34 */

.text
peak_34:
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
	jnz .Lbb1715
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $21, %rax
	jz .Lbb1714
	cmpl $0, %edx
	jz .Lbb1713
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1713
.Lbb1710:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1712
	cmpl $0, %ebx
	jz .Lbb1713
	jmp .Lbb1710
.Lbb1712:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1716
.Lbb1713:
	movl $1, %eax
	jmp .Lbb1716
.Lbb1714:
	movl $0, %eax
	jmp .Lbb1716
.Lbb1715:
	movl $2, %eax
.Lbb1716:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_34, @function
.size peak_34, .-peak_34
/* end function peak_34 */

.data
.balign 8
expected_34_data:
	.quad 0
	.quad 21
/* end data */

.text
expected_34:
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
	leaq expected_34_data(%rip), %rsi
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
.type expected_34, @function
.size expected_34, .-expected_34
/* end function expected_34 */

.text
parse_35:
	pushq %rbp
	movq %rsp, %rbp
	subq $184, %rsp
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
	addq $6, %rbx
	movl %esi, %r14d
	movl $34, %esi
	movq %rdi, %r13
	callq push_long
	movl %r14d, %esi
	movq %r13, %rdi
	movl %esi, %r14d
	movl $33, %esi
	movq %rdi, %r13
	callq push_long
	movl %r14d, %esi
	movq %r13, %rdi
	movl %esi, %r13d
	movl $32, %esi
	callq push_long
	movl %r13d, %esi
	movq %r12, %rdi
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_31
	movq %r12, %rdi
	movq %rax, %r12
	cmpl $0, %r12d
	jnz .Lbb1757
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1723
	movl %r13d, %esi
	jmp .Lbb1729
.Lbb1723:
	cmpq $2, %rax
	jz .Lbb1727
	movq %rax, %r14
	movq %rbx, %rax
	subq $1, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -168(%rbp), %rdi
	callq expected_31
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jz .Lbb1726
	movl %r13d, %esi
	jmp .Lbb1729
.Lbb1726:
	movq %rax, %r12
	jmp .Lbb1733
.Lbb1727:
	movq %rdi, %r12
	leaq -144(%rbp), %rdi
	callq expected_31
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movq %r12, %rdi
	movl %r13d, %esi
.Lbb1729:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_32
	movl %r13d, %esi
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1732
	movl %esi, %r13d
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb1729
.Lbb1732:
	movl %esi, %r13d
.Lbb1733:
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jz .Lbb1738
	cmpq $2, %rax
	jz .Lbb1737
	movq %rax, %r14
	movq %rbx, %rax
	subq $2, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -120(%rbp), %rdi
	callq expected_32
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jnz .Lbb1738
	movq %rax, %r12
	jmp .Lbb1742
.Lbb1737:
	movq %rdi, %r12
	leaq -96(%rbp), %rdi
	callq expected_32
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movq %r12, %rdi
.Lbb1738:
	movl %r13d, %esi
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_33
	movl %r13d, %esi
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1741
	movl %esi, %r13d
	movq %rdi, %r12
	callq bump_err
	movq %r12, %rdi
	jmp .Lbb1738
.Lbb1741:
	movl %esi, %r13d
.Lbb1742:
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1744
	movl %r13d, %esi
	jmp .Lbb1748
.Lbb1744:
	cmpq $2, %rax
	jz .Lbb1747
	movq %rax, %r14
	movq %rbx, %rax
	subq $3, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -72(%rbp), %rdi
	callq expected_33
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jz .Lbb1752
	movl %r13d, %esi
	jmp .Lbb1748
.Lbb1747:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_33
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb1748:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_34
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1751
	movq %rdi, %r12
	callq bump_err
	movq %r12, %rdi
	movl %r13d, %esi
	jmp .Lbb1748
.Lbb1751:
	movq %r12, %rax
.Lbb1752:
	cmpl $0, %eax
	jz .Lbb1756
	cmpq $2, %rax
	jz .Lbb1755
	movq %rbx, %rcx
	subq $3, %rcx
	cmpq %rcx, %rax
	jz .Lbb1756
.Lbb1755:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_34
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb1756:
	movl $0, %eax
	jmp .Lbb1758
.Lbb1757:
	movq %r12, %rax
.Lbb1758:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_35, @function
.size parse_35, .-parse_35
/* end function parse_35 */

.text
peak_35:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_31
	leave
	ret
.type peak_35, @function
.size peak_35, .-peak_35
/* end function peak_35 */

.data
.balign 8
expected_35_data:
	.quad 0
	.quad 2
/* end data */

.text
expected_35:
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
	leaq expected_35_data(%rip), %rsi
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
.type expected_35, @function
.size expected_35, .-expected_35
/* end function expected_35 */

.text
parse_36:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movl $9, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rdi, %rbx
	callq parse_35
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1765
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb1766
.Lbb1765:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1766:
	popq %r12
	popq %rbx
	leave
	ret
.type parse_36, @function
.size parse_36, .-parse_36
/* end function parse_36 */

.text
peak_36:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_35
	leave
	ret
.type peak_36, @function
.size peak_36, .-peak_36
/* end function peak_36 */

.data
.balign 8
expected_36_data:
	.quad 1
	.quad 9
/* end data */

.text
expected_36:
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
	leaq expected_36_data(%rip), %rsi
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
.type expected_36, @function
.size expected_36, .-expected_36
/* end function expected_36 */

.text
parse_37:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb1772:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1784
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $4, %rsi
	jz .Lbb1783
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1777
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1772
.Lbb1777:
	cmpl $0, %r12d
	jz .Lbb1782
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1782
.Lbb1779:
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
	jz .Lbb1781
	cmpl $0, %ebx
	jz .Lbb1782
	jmp .Lbb1779
.Lbb1781:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1785
.Lbb1782:
	movl $1, %eax
	jmp .Lbb1785
.Lbb1783:
	callq bump
	movl $0, %eax
	jmp .Lbb1785
.Lbb1784:
	movl $2, %eax
.Lbb1785:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_37, @function
.size parse_37, .-parse_37
/* end function parse_37 */

.text
peak_37:
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
	jnz .Lbb1795
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $4, %rax
	jz .Lbb1794
	cmpl $0, %edx
	jz .Lbb1793
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1793
.Lbb1790:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1792
	cmpl $0, %ebx
	jz .Lbb1793
	jmp .Lbb1790
.Lbb1792:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1796
.Lbb1793:
	movl $1, %eax
	jmp .Lbb1796
.Lbb1794:
	movl $0, %eax
	jmp .Lbb1796
.Lbb1795:
	movl $2, %eax
.Lbb1796:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_37, @function
.size peak_37, .-peak_37
/* end function peak_37 */

.data
.balign 8
expected_37_data:
	.quad 0
	.quad 4
/* end data */

.text
expected_37:
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
	leaq expected_37_data(%rip), %rsi
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
.type expected_37, @function
.size expected_37, .-expected_37
/* end function expected_37 */

.text
parse_38:
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
	movl $0, %esi
	callq push_long
	movl %r13d, %esi
	movq %r12, %rdi
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_37
	movq %r12, %rdi
	movq %rax, %r12
	cmpl $0, %r12d
	jnz .Lbb1815
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1803
	movl %r13d, %esi
	jmp .Lbb1807
.Lbb1803:
	cmpq $2, %rax
	jz .Lbb1806
	movq %rax, %r14
	movq %rbx, %rax
	subq $1, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -72(%rbp), %rdi
	callq expected_37
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jz .Lbb1810
	movl %r13d, %esi
	jmp .Lbb1807
.Lbb1806:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_37
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb1807:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_0
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1809
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb1807
.Lbb1809:
	movq %r12, %rax
.Lbb1810:
	cmpl $0, %eax
	jz .Lbb1814
	cmpq $2, %rax
	jz .Lbb1813
	movq %rbx, %rcx
	subq $1, %rcx
	cmpq %rcx, %rax
	jz .Lbb1814
.Lbb1813:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_0
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb1814:
	movl $0, %eax
	jmp .Lbb1816
.Lbb1815:
	movq %r12, %rax
.Lbb1816:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_38, @function
.size parse_38, .-parse_38
/* end function parse_38 */

.text
peak_38:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_37
	leave
	ret
.type peak_38, @function
.size peak_38, .-peak_38
/* end function peak_38 */

.data
.balign 8
expected_38_data:
	.quad 0
	.quad 4
/* end data */

.text
expected_38:
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
	leaq expected_38_data(%rip), %rsi
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
.type expected_38, @function
.size expected_38, .-expected_38
/* end function expected_38 */

.text
parse_39:
	pushq %rbp
	movq %rsp, %rbp
	subq $40, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movl %esi, %r12d
	movl $10, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_0
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1825
	movq %rdi, %rbx
	callq parse_38
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1824
	callq exit_group
	movq %rbx, %rax
	jmp .Lbb1826
.Lbb1824:
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
	imulq $64, %r13, %rdi
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
	jmp .Lbb1826
.Lbb1825:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1826:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_39, @function
.size parse_39, .-parse_39
/* end function parse_39 */

.text
peak_39:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_0
	leave
	ret
.type peak_39, @function
.size peak_39, .-peak_39
/* end function peak_39 */

.data
.balign 8
expected_39_data:
	.quad 0
	.quad 13
	.quad 1
	.quad 1
/* end data */

.text
expected_39:
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
	leaq expected_39_data(%rip), %rsi
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
.type expected_39, @function
.size expected_39, .-expected_39
/* end function expected_39 */

.text
parse_40:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb1832:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1844
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $1, %rsi
	jz .Lbb1843
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1837
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1832
.Lbb1837:
	cmpl $0, %r12d
	jz .Lbb1842
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1842
.Lbb1839:
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
	jz .Lbb1841
	cmpl $0, %ebx
	jz .Lbb1842
	jmp .Lbb1839
.Lbb1841:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1845
.Lbb1842:
	movl $1, %eax
	jmp .Lbb1845
.Lbb1843:
	callq bump
	movl $0, %eax
	jmp .Lbb1845
.Lbb1844:
	movl $2, %eax
.Lbb1845:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_40, @function
.size parse_40, .-parse_40
/* end function parse_40 */

.text
peak_40:
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
	jnz .Lbb1855
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $1, %rax
	jz .Lbb1854
	cmpl $0, %edx
	jz .Lbb1853
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1853
.Lbb1850:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1852
	cmpl $0, %ebx
	jz .Lbb1853
	jmp .Lbb1850
.Lbb1852:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1856
.Lbb1853:
	movl $1, %eax
	jmp .Lbb1856
.Lbb1854:
	movl $0, %eax
	jmp .Lbb1856
.Lbb1855:
	movl $2, %eax
.Lbb1856:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_40, @function
.size peak_40, .-peak_40
/* end function peak_40 */

.data
.balign 8
expected_40_data:
	.quad 0
	.quad 1
/* end data */

.text
expected_40:
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
	leaq expected_40_data(%rip), %rsi
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
.type expected_40, @function
.size expected_40, .-expected_40
/* end function expected_40 */

.text
parse_41:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb1860:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1872
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $19, %rsi
	jz .Lbb1871
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1865
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1860
.Lbb1865:
	cmpl $0, %r12d
	jz .Lbb1870
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1870
.Lbb1867:
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
	jz .Lbb1869
	cmpl $0, %ebx
	jz .Lbb1870
	jmp .Lbb1867
.Lbb1869:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1873
.Lbb1870:
	movl $1, %eax
	jmp .Lbb1873
.Lbb1871:
	callq bump
	movl $0, %eax
	jmp .Lbb1873
.Lbb1872:
	movl $2, %eax
.Lbb1873:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_41, @function
.size parse_41, .-parse_41
/* end function parse_41 */

.text
peak_41:
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
	jnz .Lbb1883
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $19, %rax
	jz .Lbb1882
	cmpl $0, %edx
	jz .Lbb1881
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1881
.Lbb1878:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1880
	cmpl $0, %ebx
	jz .Lbb1881
	jmp .Lbb1878
.Lbb1880:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1884
.Lbb1881:
	movl $1, %eax
	jmp .Lbb1884
.Lbb1882:
	movl $0, %eax
	jmp .Lbb1884
.Lbb1883:
	movl $2, %eax
.Lbb1884:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_41, @function
.size peak_41, .-peak_41
/* end function peak_41 */

.data
.balign 8
expected_41_data:
	.quad 0
	.quad 19
/* end data */

.text
expected_41:
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
	leaq expected_41_data(%rip), %rsi
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
.type expected_41, @function
.size expected_41, .-expected_41
/* end function expected_41 */

.text
parse_42:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb1888:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1900
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $18, %rsi
	jz .Lbb1899
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1893
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1888
.Lbb1893:
	cmpl $0, %r12d
	jz .Lbb1898
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1898
.Lbb1895:
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
	jz .Lbb1897
	cmpl $0, %ebx
	jz .Lbb1898
	jmp .Lbb1895
.Lbb1897:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1901
.Lbb1898:
	movl $1, %eax
	jmp .Lbb1901
.Lbb1899:
	callq bump
	movl $0, %eax
	jmp .Lbb1901
.Lbb1900:
	movl $2, %eax
.Lbb1901:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_42, @function
.size parse_42, .-parse_42
/* end function parse_42 */

.text
peak_42:
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
	jnz .Lbb1911
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $18, %rax
	jz .Lbb1910
	cmpl $0, %edx
	jz .Lbb1909
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1909
.Lbb1906:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1908
	cmpl $0, %ebx
	jz .Lbb1909
	jmp .Lbb1906
.Lbb1908:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1912
.Lbb1909:
	movl $1, %eax
	jmp .Lbb1912
.Lbb1910:
	movl $0, %eax
	jmp .Lbb1912
.Lbb1911:
	movl $2, %eax
.Lbb1912:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_42, @function
.size peak_42, .-peak_42
/* end function peak_42 */

.data
.balign 8
expected_42_data:
	.quad 0
	.quad 18
/* end data */

.text
expected_42:
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
	leaq expected_42_data(%rip), %rsi
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
.type expected_42, @function
.size expected_42, .-expected_42
/* end function expected_42 */

.text
parse_43:
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
	movl $39, %esi
	callq push_long
	movl %r13d, %esi
	movq %r12, %rdi
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_42
	movq %r12, %rdi
	movq %rax, %r12
	cmpl $0, %r12d
	jnz .Lbb1931
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1919
	movl %r13d, %esi
	jmp .Lbb1923
.Lbb1919:
	cmpq $2, %rax
	jz .Lbb1922
	movq %rax, %r14
	movq %rbx, %rax
	subq $1, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -72(%rbp), %rdi
	callq expected_42
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jz .Lbb1926
	movl %r13d, %esi
	jmp .Lbb1923
.Lbb1922:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_42
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb1923:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_39
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1925
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb1923
.Lbb1925:
	movq %r12, %rax
.Lbb1926:
	cmpl $0, %eax
	jz .Lbb1930
	cmpq $2, %rax
	jz .Lbb1929
	movq %rbx, %rcx
	subq $1, %rcx
	cmpq %rcx, %rax
	jz .Lbb1930
.Lbb1929:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_39
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb1930:
	movl $0, %eax
	jmp .Lbb1932
.Lbb1931:
	movq %r12, %rax
.Lbb1932:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_43, @function
.size parse_43, .-parse_43
/* end function parse_43 */

.text
peak_43:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_42
	leave
	ret
.type peak_43, @function
.size peak_43, .-peak_43
/* end function peak_43 */

.data
.balign 8
expected_43_data:
	.quad 0
	.quad 18
/* end data */

.text
expected_43:
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
	leaq expected_43_data(%rip), %rsi
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
.type expected_43, @function
.size expected_43, .-expected_43
/* end function expected_43 */

.text
parse_44:
	pushq %rbp
	movq %rsp, %rbp
	callq parse_43
	movl $0, %eax
	leave
	ret
.type parse_44, @function
.size parse_44, .-parse_44
/* end function parse_44 */

.text
peak_44:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_43
	leave
	ret
.type peak_44, @function
.size peak_44, .-peak_44
/* end function peak_44 */

.text
expected_44:
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
.type expected_44, @function
.size expected_44, .-expected_44
/* end function expected_44 */

.text
parse_45:
	pushq %rbp
	movq %rsp, %rbp
	subq $136, %rsp
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
	addq $5, %rbx
	movl %esi, %r14d
	movl $44, %esi
	movq %rdi, %r13
	callq push_long
	movl %r14d, %esi
	movq %r13, %rdi
	movl %esi, %r13d
	movl $41, %esi
	callq push_long
	movl %r13d, %esi
	movq %r12, %rdi
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_40
	movq %r12, %rdi
	movq %rax, %r12
	cmpl $0, %r12d
	jnz .Lbb1972
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1947
	movl %r13d, %esi
	jmp .Lbb1953
.Lbb1947:
	cmpq $2, %rax
	jz .Lbb1951
	movq %rax, %r14
	movq %rbx, %rax
	subq $1, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -120(%rbp), %rdi
	callq expected_40
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jz .Lbb1950
	movl %r13d, %esi
	jmp .Lbb1953
.Lbb1950:
	movq %rax, %r12
	jmp .Lbb1957
.Lbb1951:
	movq %rdi, %r12
	leaq -96(%rbp), %rdi
	callq expected_40
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movq %r12, %rdi
	movl %r13d, %esi
.Lbb1953:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_41
	movl %r13d, %esi
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1956
	movl %esi, %r13d
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb1953
.Lbb1956:
	movl %esi, %r13d
.Lbb1957:
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1959
	movl %r13d, %esi
	jmp .Lbb1963
.Lbb1959:
	cmpq $2, %rax
	jz .Lbb1962
	movq %rax, %r14
	movq %rbx, %rax
	subq $2, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -72(%rbp), %rdi
	callq expected_41
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jz .Lbb1967
	movl %r13d, %esi
	jmp .Lbb1963
.Lbb1962:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_41
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb1963:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_44
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1966
	movq %rdi, %r12
	callq bump_err
	movq %r12, %rdi
	movl %r13d, %esi
	jmp .Lbb1963
.Lbb1966:
	movq %r12, %rax
.Lbb1967:
	cmpl $0, %eax
	jz .Lbb1971
	cmpq $2, %rax
	jz .Lbb1970
	movq %rbx, %rcx
	subq $2, %rcx
	cmpq %rcx, %rax
	jz .Lbb1971
.Lbb1970:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_44
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb1971:
	movl $0, %eax
	jmp .Lbb1973
.Lbb1972:
	movq %r12, %rax
.Lbb1973:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_45, @function
.size parse_45, .-parse_45
/* end function parse_45 */

.text
peak_45:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_40
	leave
	ret
.type peak_45, @function
.size peak_45, .-peak_45
/* end function peak_45 */

.data
.balign 8
expected_45_data:
	.quad 0
	.quad 1
/* end data */

.text
expected_45:
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
	leaq expected_45_data(%rip), %rsi
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
.type expected_45, @function
.size expected_45, .-expected_45
/* end function expected_45 */

.text
parse_46:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movl $11, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rdi, %rbx
	callq parse_45
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1980
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb1981
.Lbb1980:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1981:
	popq %r12
	popq %rbx
	leave
	ret
.type parse_46, @function
.size parse_46, .-parse_46
/* end function parse_46 */

.text
peak_46:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_45
	leave
	ret
.type peak_46, @function
.size peak_46, .-peak_46
/* end function peak_46 */

.data
.balign 8
expected_46_data:
	.quad 1
	.quad 11
/* end data */

.text
expected_46:
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
	leaq expected_46_data(%rip), %rsi
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
.type expected_46, @function
.size expected_46, .-expected_46
/* end function expected_46 */

.text
parse_47:
	pushq %rbp
	movq %rsp, %rbp
	subq $40, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movl %esi, %r12d
	movl $15, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_58
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1990
	movq %rdi, %rbx
	callq parse_61
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1989
	callq exit_group
	movq %rbx, %rax
	jmp .Lbb1991
.Lbb1989:
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
	imulq $64, %r13, %rdi
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
	jmp .Lbb1991
.Lbb1990:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1991:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_47, @function
.size parse_47, .-parse_47
/* end function parse_47 */

.text
peak_47:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_58
	leave
	ret
.type peak_47, @function
.size peak_47, .-peak_47
/* end function peak_47 */

.data
.balign 8
expected_47_data:
	.quad 1
	.quad 14
/* end data */

.text
expected_47:
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
	leaq expected_47_data(%rip), %rsi
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
.type expected_47, @function
.size expected_47, .-expected_47
/* end function expected_47 */

.text
parse_48:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb1997:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb2009
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $8, %rsi
	jz .Lbb2008
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2002
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1997
.Lbb2002:
	cmpl $0, %r12d
	jz .Lbb2007
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2007
.Lbb2004:
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
	jz .Lbb2006
	cmpl $0, %ebx
	jz .Lbb2007
	jmp .Lbb2004
.Lbb2006:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2010
.Lbb2007:
	movl $1, %eax
	jmp .Lbb2010
.Lbb2008:
	callq bump
	movl $0, %eax
	jmp .Lbb2010
.Lbb2009:
	movl $2, %eax
.Lbb2010:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_48, @function
.size parse_48, .-parse_48
/* end function parse_48 */

.text
peak_48:
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
	jnz .Lbb2020
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $8, %rax
	jz .Lbb2019
	cmpl $0, %edx
	jz .Lbb2018
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2018
.Lbb2015:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb2017
	cmpl $0, %ebx
	jz .Lbb2018
	jmp .Lbb2015
.Lbb2017:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2021
.Lbb2018:
	movl $1, %eax
	jmp .Lbb2021
.Lbb2019:
	movl $0, %eax
	jmp .Lbb2021
.Lbb2020:
	movl $2, %eax
.Lbb2021:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_48, @function
.size peak_48, .-peak_48
/* end function peak_48 */

.data
.balign 8
expected_48_data:
	.quad 0
	.quad 8
/* end data */

.text
expected_48:
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
	leaq expected_48_data(%rip), %rsi
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
.type expected_48, @function
.size expected_48, .-expected_48
/* end function expected_48 */

.text
parse_49:
	pushq %rbp
	movq %rsp, %rbp
	subq $56, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movl %esi, %r12d
	movl $47, %esi
	movq %rdi, %rbx
	callq push_delim
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rax, %rbx
	movl %esi, %r13d
	movl $48, %esi
	movq %rdi, %r12
	callq push_delim
	movl %r13d, %esi
	movq %r12, %rdi
	movq %rax, %r12
	movl %esi, %r14d
	movq %rdi, %r13
	callq parse_47
	movl %r14d, %esi
	movq %r13, %rdi
	cmpl $0, %eax
	jnz .Lbb2041
.Lbb2025:
	movl %esi, %r14d
	movq %rdi, %r13
	callq parse_48
	movq %r13, %rdi
	cmpq $1, %rax
	jz .Lbb2040
	cmpl $0, %eax
	jnz .Lbb2028
	movl %r14d, %esi
	jmp .Lbb2032
.Lbb2028:
	cmpq $2, %rax
	jz .Lbb2039
	cmpq %rax, %rbx
	jnz .Lbb2039
	movq %rdi, %r13
	leaq -48(%rbp), %rdi
	callq expected_48
	movq %r13, %rdi
	movq %rax, %rsi
	movq %rdi, %r13
	callq missing
	movq %r13, %rdi
	movl %r14d, %esi
.Lbb2032:
	movl %esi, %r14d
	movq %rdi, %r13
	callq parse_47
	movq %r13, %rdi
	movq %rax, %r13
	cmpq $1, %r13
	jnz .Lbb2034
	movq %rdi, %r13
	callq bump_err
	movl %r14d, %esi
	movq %r13, %rdi
	jmp .Lbb2032
.Lbb2034:
	cmpl $0, %r13d
	jnz .Lbb2036
	movl %r14d, %esi
	jmp .Lbb2025
.Lbb2036:
	movq %rdi, %r15
	leaq -24(%rbp), %rdi
	callq expected_47
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	cmpq $2, %r13
	jz .Lbb2039
	cmpq %r13, %r12
	jnz .Lbb2039
	movl %r14d, %esi
	jmp .Lbb2025
.Lbb2039:
	callq pop_delim
	movl $0, %eax
	jmp .Lbb2043
.Lbb2040:
	movq %rdi, %r13
	callq bump_err
	movl %r14d, %esi
	movq %r13, %rdi
	jmp .Lbb2025
.Lbb2041:
	movq %rax, %rbx
	callq pop_delim
	movq %rbx, %rax
.Lbb2043:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_49, @function
.size parse_49, .-parse_49
/* end function parse_49 */

.text
peak_49:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_47
	leave
	ret
.type peak_49, @function
.size peak_49, .-peak_49
/* end function peak_49 */

.data
.balign 8
expected_49_data:
	.quad 1
	.quad 14
/* end data */

.text
expected_49:
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
	leaq expected_49_data(%rip), %rsi
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
.type expected_49, @function
.size expected_49, .-expected_49
/* end function expected_49 */

.text
parse_50:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb2049:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb2061
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $13, %rsi
	jz .Lbb2060
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2054
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb2049
.Lbb2054:
	cmpl $0, %r12d
	jz .Lbb2059
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2059
.Lbb2056:
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
	jz .Lbb2058
	cmpl $0, %ebx
	jz .Lbb2059
	jmp .Lbb2056
.Lbb2058:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2062
.Lbb2059:
	movl $1, %eax
	jmp .Lbb2062
.Lbb2060:
	callq bump
	movl $0, %eax
	jmp .Lbb2062
.Lbb2061:
	movl $2, %eax
.Lbb2062:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_50, @function
.size parse_50, .-parse_50
/* end function parse_50 */

.text
peak_50:
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
	jnz .Lbb2072
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $13, %rax
	jz .Lbb2071
	cmpl $0, %edx
	jz .Lbb2070
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2070
.Lbb2067:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb2069
	cmpl $0, %ebx
	jz .Lbb2070
	jmp .Lbb2067
.Lbb2069:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2073
.Lbb2070:
	movl $1, %eax
	jmp .Lbb2073
.Lbb2071:
	movl $0, %eax
	jmp .Lbb2073
.Lbb2072:
	movl $2, %eax
.Lbb2073:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_50, @function
.size peak_50, .-peak_50
/* end function peak_50 */

.data
.balign 8
expected_50_data:
	.quad 0
	.quad 13
/* end data */

.text
expected_50:
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
	leaq expected_50_data(%rip), %rsi
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
.type expected_50, @function
.size expected_50, .-expected_50
/* end function expected_50 */

.text
parse_51:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb2077:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb2089
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $14, %rsi
	jz .Lbb2088
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2082
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb2077
.Lbb2082:
	cmpl $0, %r12d
	jz .Lbb2087
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2087
.Lbb2084:
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
	jz .Lbb2086
	cmpl $0, %ebx
	jz .Lbb2087
	jmp .Lbb2084
.Lbb2086:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2090
.Lbb2087:
	movl $1, %eax
	jmp .Lbb2090
.Lbb2088:
	callq bump
	movl $0, %eax
	jmp .Lbb2090
.Lbb2089:
	movl $2, %eax
.Lbb2090:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_51, @function
.size parse_51, .-parse_51
/* end function parse_51 */

.text
peak_51:
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
	jnz .Lbb2100
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $14, %rax
	jz .Lbb2099
	cmpl $0, %edx
	jz .Lbb2098
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2098
.Lbb2095:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb2097
	cmpl $0, %ebx
	jz .Lbb2098
	jmp .Lbb2095
.Lbb2097:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2101
.Lbb2098:
	movl $1, %eax
	jmp .Lbb2101
.Lbb2099:
	movl $0, %eax
	jmp .Lbb2101
.Lbb2100:
	movl $2, %eax
.Lbb2101:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_51, @function
.size peak_51, .-peak_51
/* end function peak_51 */

.data
.balign 8
expected_51_data:
	.quad 0
	.quad 14
/* end data */

.text
expected_51:
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
	leaq expected_51_data(%rip), %rsi
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
.type expected_51, @function
.size expected_51, .-expected_51
/* end function expected_51 */

.text
parse_52:
	pushq %rbp
	movq %rsp, %rbp
	subq $40, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_50
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb2118
	movl %esi, %r12d
	movl $51, %esi
	movq %rdi, %rbx
	callq push_delim
	movl %r12d, %esi
	movq %rbx, %rdi
.Lbb2106:
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_49
	movq %rbx, %rdi
	cmpq $1, %rax
	jnz .Lbb2108
	movq %rdi, %rbx
	callq bump_err
	movl %r12d, %esi
	movq %rbx, %rdi
	jmp .Lbb2106
.Lbb2108:
	movl %r12d, %esi
	movq 64(%rdi), %rcx
	movq %rcx, %rbx
	addq $2, %rbx
	cmpq %rax, %rbx
	jnz .Lbb2113
	movl %esi, %r12d
.Lbb2111:
	movq %rdi, %r13
	leaq -24(%rbp), %rdi
	callq expected_49
	movq %r13, %rdi
	movq %rax, %rsi
	movq %rdi, %r13
	callq missing
	movq %r13, %rdi
	movl %r12d, %esi
.Lbb2113:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_51
	movq %r12, %rdi
	cmpq $1, %rax
	jnz .Lbb2115
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb2113
.Lbb2115:
	movl %r13d, %r12d
	cmpq %rax, %rbx
	jz .Lbb2111
	callq pop_delim
	movl $0, %eax
.Lbb2118:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_52, @function
.size parse_52, .-parse_52
/* end function parse_52 */

.text
peak_52:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_50
	leave
	ret
.type peak_52, @function
.size peak_52, .-peak_52
/* end function peak_52 */

.data
.balign 8
expected_52_data:
	.quad 0
	.quad 13
/* end data */

.text
expected_52:
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
	leaq expected_52_data(%rip), %rsi
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
.type expected_52, @function
.size expected_52, .-expected_52
/* end function expected_52 */

.text
parse_53:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movl $13, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rdi, %rbx
	callq parse_52
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb2125
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb2126
.Lbb2125:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb2126:
	popq %r12
	popq %rbx
	leave
	ret
.type parse_53, @function
.size parse_53, .-parse_53
/* end function parse_53 */

.text
peak_53:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_52
	leave
	ret
.type peak_53, @function
.size peak_53, .-peak_53
/* end function peak_53 */

.data
.balign 8
expected_53_data:
	.quad 1
	.quad 13
/* end data */

.text
expected_53:
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
	leaq expected_53_data(%rip), %rsi
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
.type expected_53, @function
.size expected_53, .-expected_53
/* end function expected_53 */

.text
parse_54:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb2132:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb2144
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $7, %rsi
	jz .Lbb2143
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2137
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb2132
.Lbb2137:
	cmpl $0, %r12d
	jz .Lbb2142
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2142
.Lbb2139:
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
	jz .Lbb2141
	cmpl $0, %ebx
	jz .Lbb2142
	jmp .Lbb2139
.Lbb2141:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2145
.Lbb2142:
	movl $1, %eax
	jmp .Lbb2145
.Lbb2143:
	callq bump
	movl $0, %eax
	jmp .Lbb2145
.Lbb2144:
	movl $2, %eax
.Lbb2145:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_54, @function
.size parse_54, .-parse_54
/* end function parse_54 */

.text
peak_54:
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
	jnz .Lbb2155
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $7, %rax
	jz .Lbb2154
	cmpl $0, %edx
	jz .Lbb2153
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2153
.Lbb2150:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb2152
	cmpl $0, %ebx
	jz .Lbb2153
	jmp .Lbb2150
.Lbb2152:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2156
.Lbb2153:
	movl $1, %eax
	jmp .Lbb2156
.Lbb2154:
	movl $0, %eax
	jmp .Lbb2156
.Lbb2155:
	movl $2, %eax
.Lbb2156:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_54, @function
.size peak_54, .-peak_54
/* end function peak_54 */

.data
.balign 8
expected_54_data:
	.quad 0
	.quad 7
/* end data */

.text
expected_54:
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
	leaq expected_54_data(%rip), %rsi
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
.type expected_54, @function
.size expected_54, .-expected_54
/* end function expected_54 */

.text
parse_55:
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
	movl $53, %esi
	callq push_long
	movl %r13d, %esi
	movq %r12, %rdi
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_54
	movq %r12, %rdi
	movq %rax, %r12
	cmpl $0, %r12d
	jnz .Lbb2175
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb2163
	movl %r13d, %esi
	jmp .Lbb2167
.Lbb2163:
	cmpq $2, %rax
	jz .Lbb2166
	movq %rax, %r14
	movq %rbx, %rax
	subq $1, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -72(%rbp), %rdi
	callq expected_54
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jz .Lbb2170
	movl %r13d, %esi
	jmp .Lbb2167
.Lbb2166:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_54
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb2167:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_53
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb2169
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb2167
.Lbb2169:
	movq %r12, %rax
.Lbb2170:
	cmpl $0, %eax
	jz .Lbb2174
	cmpq $2, %rax
	jz .Lbb2173
	movq %rbx, %rcx
	subq $1, %rcx
	cmpq %rcx, %rax
	jz .Lbb2174
.Lbb2173:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_53
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb2174:
	movl $0, %eax
	jmp .Lbb2176
.Lbb2175:
	movq %r12, %rax
.Lbb2176:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_55, @function
.size parse_55, .-parse_55
/* end function parse_55 */

.text
peak_55:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_54
	leave
	ret
.type peak_55, @function
.size peak_55, .-peak_55
/* end function peak_55 */

.data
.balign 8
expected_55_data:
	.quad 0
	.quad 7
/* end data */

.text
expected_55:
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
	leaq expected_55_data(%rip), %rsi
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
.type expected_55, @function
.size expected_55, .-expected_55
/* end function expected_55 */

.text
parse_56:
	pushq %rbp
	movq %rsp, %rbp
	callq parse_55
	movl $0, %eax
	leave
	ret
.type parse_56, @function
.size parse_56, .-parse_56
/* end function parse_56 */

.text
peak_56:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_55
	leave
	ret
.type peak_56, @function
.size peak_56, .-peak_56
/* end function peak_56 */

.text
expected_56:
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
.type expected_56, @function
.size expected_56, .-expected_56
/* end function expected_56 */

.text
parse_57:
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
	movl $56, %esi
	callq push_long
	movl %r13d, %esi
	movq %r12, %rdi
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_2
	movq %r12, %rdi
	movq %rax, %r12
	cmpl $0, %r12d
	jnz .Lbb2203
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb2191
	movl %r13d, %esi
	jmp .Lbb2195
.Lbb2191:
	cmpq $2, %rax
	jz .Lbb2194
	movq %rax, %r14
	movq %rbx, %rax
	subq $1, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -72(%rbp), %rdi
	callq expected_2
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jz .Lbb2198
	movl %r13d, %esi
	jmp .Lbb2195
.Lbb2194:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_2
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb2195:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_56
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb2197
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb2195
.Lbb2197:
	movq %r12, %rax
.Lbb2198:
	cmpl $0, %eax
	jz .Lbb2202
	cmpq $2, %rax
	jz .Lbb2201
	movq %rbx, %rcx
	subq $1, %rcx
	cmpq %rcx, %rax
	jz .Lbb2202
.Lbb2201:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_56
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb2202:
	movl $0, %eax
	jmp .Lbb2204
.Lbb2203:
	movq %r12, %rax
.Lbb2204:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_57, @function
.size parse_57, .-parse_57
/* end function parse_57 */

.text
peak_57:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_2
	leave
	ret
.type peak_57, @function
.size peak_57, .-peak_57
/* end function peak_57 */

.data
.balign 8
expected_57_data:
	.quad 1
	.quad 1
/* end data */

.text
expected_57:
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
	leaq expected_57_data(%rip), %rsi
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
.type expected_57, @function
.size expected_57, .-expected_57
/* end function expected_57 */

.text
parse_58:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movl $14, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rdi, %rbx
	callq parse_57
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb2211
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb2212
.Lbb2211:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb2212:
	popq %r12
	popq %rbx
	leave
	ret
.type parse_58, @function
.size parse_58, .-parse_58
/* end function parse_58 */

.text
peak_58:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_57
	leave
	ret
.type peak_58, @function
.size peak_58, .-peak_58
/* end function peak_58 */

.data
.balign 8
expected_58_data:
	.quad 1
	.quad 14
/* end data */

.text
expected_58:
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
	leaq expected_58_data(%rip), %rsi
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
.type expected_58, @function
.size expected_58, .-expected_58
/* end function expected_58 */

.text
parse_59:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb2218:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb2230
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $22, %rsi
	jz .Lbb2229
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2223
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb2218
.Lbb2223:
	cmpl $0, %r12d
	jz .Lbb2228
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2228
.Lbb2225:
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
	jz .Lbb2227
	cmpl $0, %ebx
	jz .Lbb2228
	jmp .Lbb2225
.Lbb2227:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2231
.Lbb2228:
	movl $1, %eax
	jmp .Lbb2231
.Lbb2229:
	callq bump
	movl $0, %eax
	jmp .Lbb2231
.Lbb2230:
	movl $2, %eax
.Lbb2231:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_59, @function
.size parse_59, .-parse_59
/* end function parse_59 */

.text
peak_59:
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
	jnz .Lbb2241
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $22, %rax
	jz .Lbb2240
	cmpl $0, %edx
	jz .Lbb2239
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2239
.Lbb2236:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb2238
	cmpl $0, %ebx
	jz .Lbb2239
	jmp .Lbb2236
.Lbb2238:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2242
.Lbb2239:
	movl $1, %eax
	jmp .Lbb2242
.Lbb2240:
	movl $0, %eax
	jmp .Lbb2242
.Lbb2241:
	movl $2, %eax
.Lbb2242:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_59, @function
.size peak_59, .-peak_59
/* end function peak_59 */

.data
.balign 8
expected_59_data:
	.quad 0
	.quad 22
/* end data */

.text
expected_59:
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
	leaq expected_59_data(%rip), %rsi
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
.type expected_59, @function
.size expected_59, .-expected_59
/* end function expected_59 */

.text
parse_60:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb2246:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb2258
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $21, %rsi
	jz .Lbb2257
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2251
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb2246
.Lbb2251:
	cmpl $0, %r12d
	jz .Lbb2256
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2256
.Lbb2253:
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
	jz .Lbb2255
	cmpl $0, %ebx
	jz .Lbb2256
	jmp .Lbb2253
.Lbb2255:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2259
.Lbb2256:
	movl $1, %eax
	jmp .Lbb2259
.Lbb2257:
	callq bump
	movl $0, %eax
	jmp .Lbb2259
.Lbb2258:
	movl $2, %eax
.Lbb2259:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_60, @function
.size parse_60, .-parse_60
/* end function parse_60 */

.text
peak_60:
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
	jnz .Lbb2269
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $21, %rax
	jz .Lbb2268
	cmpl $0, %edx
	jz .Lbb2267
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2267
.Lbb2264:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb2266
	cmpl $0, %ebx
	jz .Lbb2267
	jmp .Lbb2264
.Lbb2266:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2270
.Lbb2267:
	movl $1, %eax
	jmp .Lbb2270
.Lbb2268:
	movl $0, %eax
	jmp .Lbb2270
.Lbb2269:
	movl $2, %eax
.Lbb2270:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_60, @function
.size peak_60, .-peak_60
/* end function peak_60 */

.data
.balign 8
expected_60_data:
	.quad 0
	.quad 21
/* end data */

.text
expected_60:
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
	leaq expected_60_data(%rip), %rsi
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
.type expected_60, @function
.size expected_60, .-expected_60
/* end function expected_60 */

.text
parse_61:
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
	movl $60, %esi
	callq push_long
	movl %r13d, %esi
	movq %r12, %rdi
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_59
	movq %r12, %rdi
	movq %rax, %r12
	cmpl $0, %r12d
	jnz .Lbb2289
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb2277
	movl %r13d, %esi
	jmp .Lbb2281
.Lbb2277:
	cmpq $2, %rax
	jz .Lbb2280
	movq %rax, %r14
	movq %rbx, %rax
	subq $1, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -72(%rbp), %rdi
	callq expected_59
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jz .Lbb2284
	movl %r13d, %esi
	jmp .Lbb2281
.Lbb2280:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_59
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb2281:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_60
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb2283
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb2281
.Lbb2283:
	movq %r12, %rax
.Lbb2284:
	cmpl $0, %eax
	jz .Lbb2288
	cmpq $2, %rax
	jz .Lbb2287
	movq %rbx, %rcx
	subq $1, %rcx
	cmpq %rcx, %rax
	jz .Lbb2288
.Lbb2287:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_60
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb2288:
	movl $0, %eax
	jmp .Lbb2290
.Lbb2289:
	movq %r12, %rax
.Lbb2290:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_61, @function
.size parse_61, .-parse_61
/* end function parse_61 */

.text
peak_61:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_59
	leave
	ret
.type peak_61, @function
.size peak_61, .-peak_61
/* end function peak_61 */

.data
.balign 8
expected_61_data:
	.quad 0
	.quad 22
/* end data */

.text
expected_61:
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
	leaq expected_61_data(%rip), %rsi
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
.type expected_61, @function
.size expected_61, .-expected_61
/* end function expected_61 */

.text
parse_62:
	pushq %rbp
	movq %rsp, %rbp
	subq $40, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movl %esi, %r12d
	movl $15, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_58
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb2299
	movq %rdi, %rbx
	callq parse_61
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb2298
	callq exit_group
	movq %rbx, %rax
	jmp .Lbb2300
.Lbb2298:
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
	imulq $64, %r13, %rdi
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
	jmp .Lbb2300
.Lbb2299:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb2300:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_62, @function
.size parse_62, .-parse_62
/* end function parse_62 */

.text
peak_62:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_58
	leave
	ret
.type peak_62, @function
.size peak_62, .-peak_62
/* end function peak_62 */

.data
.balign 8
expected_62_data:
	.quad 1
	.quad 14
/* end data */

.text
expected_62:
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
	leaq expected_62_data(%rip), %rsi
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
.type expected_62, @function
.size expected_62, .-expected_62
/* end function expected_62 */

.text
parse_63:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb2306:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb2318
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $3, %rsi
	jz .Lbb2317
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2311
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb2306
.Lbb2311:
	cmpl $0, %r12d
	jz .Lbb2316
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2316
.Lbb2313:
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
	jz .Lbb2315
	cmpl $0, %ebx
	jz .Lbb2316
	jmp .Lbb2313
.Lbb2315:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2319
.Lbb2316:
	movl $1, %eax
	jmp .Lbb2319
.Lbb2317:
	callq bump
	movl $0, %eax
	jmp .Lbb2319
.Lbb2318:
	movl $2, %eax
.Lbb2319:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_63, @function
.size parse_63, .-parse_63
/* end function parse_63 */

.text
peak_63:
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
	jnz .Lbb2329
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $3, %rax
	jz .Lbb2328
	cmpl $0, %edx
	jz .Lbb2327
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2327
.Lbb2324:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb2326
	cmpl $0, %ebx
	jz .Lbb2327
	jmp .Lbb2324
.Lbb2326:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2330
.Lbb2327:
	movl $1, %eax
	jmp .Lbb2330
.Lbb2328:
	movl $0, %eax
	jmp .Lbb2330
.Lbb2329:
	movl $2, %eax
.Lbb2330:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_63, @function
.size peak_63, .-peak_63
/* end function peak_63 */

.data
.balign 8
expected_63_data:
	.quad 0
	.quad 3
/* end data */

.text
expected_63:
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
	leaq expected_63_data(%rip), %rsi
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
.type expected_63, @function
.size expected_63, .-expected_63
/* end function expected_63 */

.text
parse_64:
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
	movl $47, %esi
	callq push_long
	movl %r13d, %esi
	movq %r12, %rdi
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_63
	movq %r12, %rdi
	movq %rax, %r12
	cmpl $0, %r12d
	jnz .Lbb2349
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb2337
	movl %r13d, %esi
	jmp .Lbb2341
.Lbb2337:
	cmpq $2, %rax
	jz .Lbb2340
	movq %rax, %r14
	movq %rbx, %rax
	subq $1, %rax
	cmpq %rax, %r14
	setz %r12b
	movzbq %r12b, %r12
	movq %rdi, %r15
	leaq -72(%rbp), %rdi
	callq expected_63
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	movq %r14, %rax
	cmpl $0, %r12d
	jz .Lbb2344
	movl %r13d, %esi
	jmp .Lbb2341
.Lbb2340:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_63
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb2341:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_47
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb2343
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb2341
.Lbb2343:
	movq %r12, %rax
.Lbb2344:
	cmpl $0, %eax
	jz .Lbb2348
	cmpq $2, %rax
	jz .Lbb2347
	movq %rbx, %rcx
	subq $1, %rcx
	cmpq %rcx, %rax
	jz .Lbb2348
.Lbb2347:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_47
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb2348:
	movl $0, %eax
	jmp .Lbb2350
.Lbb2349:
	movq %r12, %rax
.Lbb2350:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_64, @function
.size parse_64, .-parse_64
/* end function parse_64 */

.text
peak_64:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_63
	leave
	ret
.type peak_64, @function
.size peak_64, .-peak_64
/* end function peak_64 */

.data
.balign 8
expected_64_data:
	.quad 0
	.quad 3
/* end data */

.text
expected_64:
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
	leaq expected_64_data(%rip), %rsi
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
.type expected_64, @function
.size expected_64, .-expected_64
/* end function expected_64 */

.text
parse_65:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movl $16, %esi
	movq %rdi, %rbx
	callq enter_group
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rdi, %rbx
	callq parse_64
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb2357
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb2358
.Lbb2357:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb2358:
	popq %r12
	popq %rbx
	leave
	ret
.type parse_65, @function
.size parse_65, .-parse_65
/* end function parse_65 */

.text
peak_65:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_64
	leave
	ret
.type peak_65, @function
.size peak_65, .-peak_65
/* end function peak_65 */

.data
.balign 8
expected_65_data:
	.quad 1
	.quad 16
/* end data */

.text
expected_65:
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
	leaq expected_65_data(%rip), %rsi
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
.type expected_65, @function
.size expected_65, .-expected_65
/* end function expected_65 */

.text
parse_66:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_30
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2367
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_36
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2367
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_46
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2367
	callq parse_65
.Lbb2367:
	popq %r12
	popq %rbx
	leave
	ret
.type parse_66, @function
.size parse_66, .-parse_66
/* end function parse_66 */

.text
peak_66:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %edx, %r13d
	movq %rsi, %r12
	movq %rdi, %rbx
	callq peak_30
	movl %r13d, %edx
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2372
	movl %edx, %r13d
	movq %rsi, %r12
	movq %rdi, %rbx
	callq peak_36
	movl %r13d, %edx
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2372
	movl %edx, %r13d
	movq %rsi, %r12
	movq %rdi, %rbx
	callq peak_46
	movl %r13d, %edx
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2372
	callq peak_65
.Lbb2372:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_66, @function
.size peak_66, .-peak_66
/* end function peak_66 */

.data
.balign 8
expected_66_data:
	.quad 1
	.quad 8
	.quad 1
	.quad 9
	.quad 1
	.quad 11
	.quad 1
	.quad 16
/* end data */

.text
expected_66:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $64, %edi
	callq malloc
	movq %rax, %rbx
	movl $64, %edx
	leaq expected_66_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $4, -16(%rbp)
	movq $4, -8(%rbp)
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
.type expected_66, @function
.size expected_66, .-expected_66
/* end function expected_66 */

.text
parse_67:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb2376:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb2388
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $20, %rsi
	jz .Lbb2387
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2381
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb2376
.Lbb2381:
	cmpl $0, %r12d
	jz .Lbb2386
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2386
.Lbb2383:
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
	jz .Lbb2385
	cmpl $0, %ebx
	jz .Lbb2386
	jmp .Lbb2383
.Lbb2385:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2389
.Lbb2386:
	movl $1, %eax
	jmp .Lbb2389
.Lbb2387:
	callq bump
	movl $0, %eax
	jmp .Lbb2389
.Lbb2388:
	movl $2, %eax
.Lbb2389:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_67, @function
.size parse_67, .-parse_67
/* end function parse_67 */

.text
peak_67:
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
	jnz .Lbb2399
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $20, %rax
	jz .Lbb2398
	cmpl $0, %edx
	jz .Lbb2397
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2397
.Lbb2394:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb2396
	cmpl $0, %ebx
	jz .Lbb2397
	jmp .Lbb2394
.Lbb2396:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2400
.Lbb2397:
	movl $1, %eax
	jmp .Lbb2400
.Lbb2398:
	movl $0, %eax
	jmp .Lbb2400
.Lbb2399:
	movl $2, %eax
.Lbb2400:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_67, @function
.size peak_67, .-peak_67
/* end function peak_67 */

.data
.balign 8
expected_67_data:
	.quad 0
	.quad 20
/* end data */

.text
expected_67:
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
	leaq expected_67_data(%rip), %rsi
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
.type expected_67, @function
.size expected_67, .-expected_67
/* end function expected_67 */

.text
parse_68:
	pushq %rbp
	movq %rsp, %rbp
	subq $56, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movl %esi, %r12d
	movl $66, %esi
	movq %rdi, %rbx
	callq push_delim
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rax, %rbx
	movl %esi, %r13d
	movl $67, %esi
	movq %rdi, %r12
	callq push_delim
	movl %r13d, %esi
	movq %r12, %rdi
	movq %rax, %r12
	movl %esi, %r14d
	movq %rdi, %r13
	callq parse_66
	movl %r14d, %esi
	movq %r13, %rdi
	cmpl $0, %eax
	jnz .Lbb2420
.Lbb2404:
	movl %esi, %r14d
	movq %rdi, %r13
	callq parse_67
	movq %r13, %rdi
	cmpq $1, %rax
	jz .Lbb2419
	cmpl $0, %eax
	jnz .Lbb2407
	movl %r14d, %esi
	jmp .Lbb2411
.Lbb2407:
	cmpq $2, %rax
	jz .Lbb2418
	cmpq %rax, %rbx
	jnz .Lbb2418
	movq %rdi, %r13
	leaq -48(%rbp), %rdi
	callq expected_67
	movq %r13, %rdi
	movq %rax, %rsi
	movq %rdi, %r13
	callq missing
	movq %r13, %rdi
	movl %r14d, %esi
.Lbb2411:
	movl %esi, %r14d
	movq %rdi, %r13
	callq parse_66
	movq %r13, %rdi
	movq %rax, %r13
	cmpq $1, %r13
	jnz .Lbb2413
	movq %rdi, %r13
	callq bump_err
	movl %r14d, %esi
	movq %r13, %rdi
	jmp .Lbb2411
.Lbb2413:
	cmpl $0, %r13d
	jnz .Lbb2415
	movl %r14d, %esi
	jmp .Lbb2404
.Lbb2415:
	movq %rdi, %r15
	leaq -24(%rbp), %rdi
	callq expected_66
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	cmpq $2, %r13
	jz .Lbb2418
	cmpq %r13, %r12
	jnz .Lbb2418
	movl %r14d, %esi
	jmp .Lbb2404
.Lbb2418:
	callq pop_delim
	movl $0, %eax
	jmp .Lbb2422
.Lbb2419:
	movq %rdi, %r13
	callq bump_err
	movl %r14d, %esi
	movq %r13, %rdi
	jmp .Lbb2404
.Lbb2420:
	movq %rax, %rbx
	callq pop_delim
	movq %rbx, %rax
.Lbb2422:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_68, @function
.size parse_68, .-parse_68
/* end function parse_68 */

.text
peak_68:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_66
	leave
	ret
.type peak_68, @function
.size peak_68, .-peak_68
/* end function peak_68 */

.data
.balign 8
expected_68_data:
	.quad 1
	.quad 8
	.quad 1
	.quad 9
	.quad 1
	.quad 11
	.quad 1
	.quad 16
/* end data */

.text
expected_68:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $64, %edi
	callq malloc
	movq %rax, %rbx
	movl $64, %edx
	leaq expected_68_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $4, -16(%rbp)
	movq $4, -8(%rbp)
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
.type expected_68, @function
.size expected_68, .-expected_68
/* end function expected_68 */

.text
parse_69:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	movl %esi, %r12d
.Lbb2428:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb2440
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $5, %rsi
	jz .Lbb2439
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2433
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb2428
.Lbb2433:
	cmpl $0, %r12d
	jz .Lbb2438
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2438
.Lbb2435:
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
	jz .Lbb2437
	cmpl $0, %ebx
	jz .Lbb2438
	jmp .Lbb2435
.Lbb2437:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2441
.Lbb2438:
	movl $1, %eax
	jmp .Lbb2441
.Lbb2439:
	callq bump
	movl $0, %eax
	jmp .Lbb2441
.Lbb2440:
	movl $2, %eax
.Lbb2441:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type parse_69, @function
.size parse_69, .-parse_69
/* end function parse_69 */

.text
peak_69:
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
	jnz .Lbb2451
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $5, %rax
	jz .Lbb2450
	cmpl $0, %edx
	jz .Lbb2449
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2449
.Lbb2446:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb2448
	cmpl $0, %ebx
	jz .Lbb2449
	jmp .Lbb2446
.Lbb2448:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2452
.Lbb2449:
	movl $1, %eax
	jmp .Lbb2452
.Lbb2450:
	movl $0, %eax
	jmp .Lbb2452
.Lbb2451:
	movl $2, %eax
.Lbb2452:
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type peak_69, @function
.size peak_69, .-peak_69
/* end function peak_69 */

.data
.balign 8
expected_69_data:
	.quad 0
	.quad 5
/* end data */

.text
expected_69:
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
	leaq expected_69_data(%rip), %rsi
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
.type expected_69, @function
.size expected_69, .-expected_69
/* end function expected_69 */

.text
parse_70:
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
	callq peak_68
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb2459
	movl %esi, %r12d
	movl $5, %esi
	movq %rdi, %rbx
	callq skip
	movl %r12d, %esi
	movq %rbx, %rdi
	movq %rax, %r12
	movq %rdi, %rbx
	callq parse_68
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %r12d
	jnz .Lbb2458
	movq %rbx, %rax
	jmp .Lbb2459
.Lbb2458:
	movl $5, %esi
	callq unskip
	movq %rbx, %rax
.Lbb2459:
	popq %r12
	popq %rbx
	leave
	ret
.type parse_70, @function
.size parse_70, .-parse_70
/* end function parse_70 */

.text
peak_70:
	pushq %rbp
	movq %rsp, %rbp
	callq peak_68
	leave
	ret
.type peak_70, @function
.size peak_70, .-peak_70
/* end function peak_70 */

.data
.balign 8
expected_70_data:
	.quad 1
	.quad 8
	.quad 1
	.quad 9
	.quad 1
	.quad 11
	.quad 1
	.quad 16
/* end data */

.text
expected_70:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	pushq %rbx
	pushq %r12
	movq %rdi, %r12
	movl $64, %edi
	callq malloc
	movq %rax, %rbx
	movl $64, %edx
	leaq expected_70_data(%rip), %rsi
	movq %rbx, %rdi
	callq memcpy
	movq %r12, %rax
	movq %rbx, -24(%rbp)
	movq $4, -16(%rbp)
	movq $4, -8(%rbp)
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
.type expected_70, @function
.size expected_70, .-expected_70
/* end function expected_70 */

.data
.balign 8
root_group_id:
	.int 19
/* end data */

.text
.globl parse
parse:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	pushq %rbx
.Lbb2465:
	movl $1, %esi
	movq %rdi, %rbx
	callq parse_70
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2468
	cmpq $2, %rax
	jz .Lbb2468
	movq %rdi, %rbx
	callq bump_err
	movq %rbx, %rdi
	jmp .Lbb2465
.Lbb2468:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb2470
	movq %rdi, %rbx
	callq bump_err
	movq %rbx, %rdi
	jmp .Lbb2468
.Lbb2470:
	movl $1, %eax
	popq %rbx
	leave
	ret
.type parse, @function
.size parse, .-parse
/* end function parse */

.data
.balign 8
_expr_group_name:
	.ascii "_expr"
	.byte 0
/* end data */

.data
.balign 8
_expr_group_name_len:
	.quad 5
/* end data */

.data
.balign 8
named_group_name:
	.ascii "named"
	.byte 0
/* end data */

.data
.balign 8
named_group_name_len:
	.quad 5
/* end data */

.data
.balign 8
_atom_group_name:
	.ascii "_atom"
	.byte 0
/* end data */

.data
.balign 8
_atom_group_name_len:
	.quad 5
/* end data */

.data
.balign 8
call_name_group_name:
	.ascii "call_name"
	.byte 0
/* end data */

.data
.balign 8
call_name_group_name_len:
	.quad 9
/* end data */

.data
.balign 8
call_group_name:
	.ascii "call"
	.byte 0
/* end data */

.data
.balign 8
call_group_name_len:
	.quad 4
/* end data */

.data
.balign 8
member_call_group_name:
	.ascii "member_call"
	.byte 0
/* end data */

.data
.balign 8
member_call_group_name_len:
	.quad 11
/* end data */

.data
.balign 8
seq_group_name:
	.ascii "seq"
	.byte 0
/* end data */

.data
.balign 8
seq_group_name_len:
	.quad 3
/* end data */

.data
.balign 8
choice_group_name:
	.ascii "choice"
	.byte 0
/* end data */

.data
.balign 8
choice_group_name_len:
	.quad 6
/* end data */

.data
.balign 8
kw_def_group_name:
	.ascii "kw_def"
	.byte 0
/* end data */

.data
.balign 8
kw_def_group_name_len:
	.quad 6
/* end data */

.data
.balign 8
token_def_group_name:
	.ascii "token_def"
	.byte 0
/* end data */

.data
.balign 8
token_def_group_name_len:
	.quad 9
/* end data */

.data
.balign 8
fold_stmt_group_name:
	.ascii "fold_stmt"
	.byte 0
/* end data */

.data
.balign 8
fold_stmt_group_name_len:
	.quad 9
/* end data */

.data
.balign 8
parser_def_group_name:
	.ascii "parser_def"
	.byte 0
/* end data */

.data
.balign 8
parser_def_group_name_len:
	.quad 10
/* end data */

.data
.balign 8
_query_group_name:
	.ascii "_query"
	.byte 0
/* end data */

.data
.balign 8
_query_group_name_len:
	.quad 6
/* end data */

.data
.balign 8
child_query_group_name:
	.ascii "child_query"
	.byte 0
/* end data */

.data
.balign 8
child_query_group_name_len:
	.quad 11
/* end data */

.data
.balign 8
group_query_group_name:
	.ascii "group_query"
	.byte 0
/* end data */

.data
.balign 8
group_query_group_name_len:
	.quad 11
/* end data */

.data
.balign 8
labelled_query_group_name:
	.ascii "labelled_query"
	.byte 0
/* end data */

.data
.balign 8
labelled_query_group_name_len:
	.quad 14
/* end data */

.data
.balign 8
highlight_def_group_name:
	.ascii "highlight_def"
	.byte 0
/* end data */

.data
.balign 8
highlight_def_group_name_len:
	.quad 13
/* end data */

.data
.balign 8
_stmt_group_name:
	.ascii "_stmt"
	.byte 0
/* end data */

.data
.balign 8
_stmt_group_name_len:
	.quad 5
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
	leaq _expr_group_name(%rip), %rax
	jz .Lbb2513
	cmpl $1, %edi
	leaq named_group_name(%rip), %rax
	jz .Lbb2512
	cmpl $2, %edi
	leaq _atom_group_name(%rip), %rax
	jz .Lbb2511
	cmpl $3, %edi
	leaq call_name_group_name(%rip), %rax
	jz .Lbb2510
	cmpl $4, %edi
	leaq call_group_name(%rip), %rax
	jz .Lbb2509
	cmpl $5, %edi
	leaq member_call_group_name(%rip), %rax
	jz .Lbb2508
	cmpl $6, %edi
	leaq seq_group_name(%rip), %rax
	jz .Lbb2507
	cmpl $7, %edi
	leaq choice_group_name(%rip), %rax
	jz .Lbb2506
	cmpl $8, %edi
	leaq kw_def_group_name(%rip), %rax
	jz .Lbb2505
	cmpl $9, %edi
	leaq token_def_group_name(%rip), %rax
	jz .Lbb2504
	cmpl $10, %edi
	leaq fold_stmt_group_name(%rip), %rax
	jz .Lbb2503
	cmpl $11, %edi
	leaq parser_def_group_name(%rip), %rax
	jz .Lbb2502
	cmpl $12, %edi
	leaq _query_group_name(%rip), %rax
	jz .Lbb2501
	cmpl $13, %edi
	leaq child_query_group_name(%rip), %rax
	jz .Lbb2500
	cmpl $14, %edi
	leaq group_query_group_name(%rip), %rax
	jz .Lbb2499
	cmpl $15, %edi
	leaq labelled_query_group_name(%rip), %rax
	jz .Lbb2498
	cmpl $16, %edi
	leaq highlight_def_group_name(%rip), %rax
	jz .Lbb2497
	cmpl $17, %edi
	leaq _stmt_group_name(%rip), %rax
	jz .Lbb2496
	cmpl $18, %edi
	leaq _root_group_name(%rip), %rax
	jz .Lbb2495
	cmpl $19, %edi
	leaq root_group_name(%rip), %rax
	jz .Lbb2494
	leaq err_group_name(%rip), %rax
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb2514
.Lbb2494:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb2514
.Lbb2495:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb2514
.Lbb2496:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb2514
.Lbb2497:
	movq %rax, %rdx
	movl $13, %eax
	jmp .Lbb2514
.Lbb2498:
	movq %rax, %rdx
	movl $14, %eax
	jmp .Lbb2514
.Lbb2499:
	movq %rax, %rdx
	movl $11, %eax
	jmp .Lbb2514
.Lbb2500:
	movq %rax, %rdx
	movl $11, %eax
	jmp .Lbb2514
.Lbb2501:
	movq %rax, %rdx
	movl $6, %eax
	jmp .Lbb2514
.Lbb2502:
	movq %rax, %rdx
	movl $10, %eax
	jmp .Lbb2514
.Lbb2503:
	movq %rax, %rdx
	movl $9, %eax
	jmp .Lbb2514
.Lbb2504:
	movq %rax, %rdx
	movl $9, %eax
	jmp .Lbb2514
.Lbb2505:
	movq %rax, %rdx
	movl $6, %eax
	jmp .Lbb2514
.Lbb2506:
	movq %rax, %rdx
	movl $6, %eax
	jmp .Lbb2514
.Lbb2507:
	movq %rax, %rdx
	movl $3, %eax
	jmp .Lbb2514
.Lbb2508:
	movq %rax, %rdx
	movl $11, %eax
	jmp .Lbb2514
.Lbb2509:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb2514
.Lbb2510:
	movq %rax, %rdx
	movl $9, %eax
	jmp .Lbb2514
.Lbb2511:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb2514
.Lbb2512:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb2514
.Lbb2513:
	movq %rax, %rdx
	movl $5, %eax
.Lbb2514:
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
