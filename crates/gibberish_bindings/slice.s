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
	jz .Lbb106
	movl $101, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb106
	movl $121, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb106
	movl $119, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb106
	movl $111, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb106
	movl $114, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb106
	movl $100, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb107
.Lbb106:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb108
.Lbb107:
	movl $1, %eax
.Lbb108:
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
	jnz .Lbb111
	movl $0, %eax
	jmp .Lbb112
.Lbb111:
	callq inc_offset
	movl $1, %eax
.Lbb112:
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
	jnz .Lbb126
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_4
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb126
	callq lex_5
	cmpl $0, %eax
	jnz .Lbb126
	callq inc_offset
	movl $1, %eax
	jmp .Lbb127
.Lbb126:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb127:
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
	jz .Lbb131
	callq lex_2
	cmpl $0, %eax
	jnz .Lbb132
.Lbb131:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb133
.Lbb132:
	movl $1, %eax
.Lbb133:
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
	jnz .Lbb136
	movl $0, %eax
	jmp .Lbb138
.Lbb136:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb138
	movq offset_ptr(%rip), %rax
.Lbb138:
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
	jz .Lbb146
	movl $97, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb146
	movl $114, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb146
	movl $115, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb146
	movl $101, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb146
	movl $114, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb147
.Lbb146:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb148
.Lbb147:
	movl $1, %eax
.Lbb148:
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
	jnz .Lbb151
	movl $0, %eax
	jmp .Lbb152
.Lbb151:
	callq inc_offset
	movl $1, %eax
.Lbb152:
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
	jnz .Lbb155
	movl $0, %eax
	jmp .Lbb156
.Lbb155:
	callq inc_offset
	movl $1, %eax
.Lbb156:
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
	jnz .Lbb159
	movl $0, %eax
	jmp .Lbb160
.Lbb159:
	callq inc_offset
	movl $1, %eax
.Lbb160:
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
	jnz .Lbb166
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_10
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb166
	callq lex_11
	cmpl $0, %eax
	jnz .Lbb166
	callq inc_offset
	movl $1, %eax
	jmp .Lbb167
.Lbb166:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb167:
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
	jz .Lbb171
	callq lex_8
	cmpl $0, %eax
	jnz .Lbb172
.Lbb171:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb173
.Lbb172:
	movl $1, %eax
.Lbb173:
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
	jnz .Lbb176
	movl $0, %eax
	jmp .Lbb178
.Lbb176:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb178
	movq offset_ptr(%rip), %rax
.Lbb178:
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
	jz .Lbb185
	movl $111, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb185
	movl $107, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb185
	movl $101, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb185
	movl $110, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb186
.Lbb185:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb187
.Lbb186:
	movl $1, %eax
.Lbb187:
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
	jnz .Lbb190
	movl $0, %eax
	jmp .Lbb191
.Lbb190:
	callq inc_offset
	movl $1, %eax
.Lbb191:
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
	jnz .Lbb194
	movl $0, %eax
	jmp .Lbb195
.Lbb194:
	callq inc_offset
	movl $1, %eax
.Lbb195:
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
	jnz .Lbb198
	movl $0, %eax
	jmp .Lbb199
.Lbb198:
	callq inc_offset
	movl $1, %eax
.Lbb199:
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
	jnz .Lbb205
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_16
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb205
	callq lex_17
	cmpl $0, %eax
	jnz .Lbb205
	callq inc_offset
	movl $1, %eax
	jmp .Lbb206
.Lbb205:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb206:
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
	jz .Lbb210
	callq lex_14
	cmpl $0, %eax
	jnz .Lbb211
.Lbb210:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb212
.Lbb211:
	movl $1, %eax
.Lbb212:
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
	jnz .Lbb215
	movl $0, %eax
	jmp .Lbb217
.Lbb215:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb217
	movq offset_ptr(%rip), %rax
.Lbb217:
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
	jz .Lbb228
	movl $105, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb228
	movl $103, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb228
	movl $104, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb228
	movl $108, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb228
	movl $105, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb228
	movl $103, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb228
	movl $104, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb228
	movl $116, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb229
.Lbb228:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb230
.Lbb229:
	movl $1, %eax
.Lbb230:
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
	jnz .Lbb233
	movl $0, %eax
	jmp .Lbb234
.Lbb233:
	callq inc_offset
	movl $1, %eax
.Lbb234:
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
	jnz .Lbb237
	movl $0, %eax
	jmp .Lbb238
.Lbb237:
	callq inc_offset
	movl $1, %eax
.Lbb238:
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
	jnz .Lbb241
	movl $0, %eax
	jmp .Lbb242
.Lbb241:
	callq inc_offset
	movl $1, %eax
.Lbb242:
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
	jnz .Lbb248
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_22
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb248
	callq lex_23
	cmpl $0, %eax
	jnz .Lbb248
	callq inc_offset
	movl $1, %eax
	jmp .Lbb249
.Lbb248:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb249:
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
	jz .Lbb253
	callq lex_20
	cmpl $0, %eax
	jnz .Lbb254
.Lbb253:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb255
.Lbb254:
	movl $1, %eax
.Lbb255:
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
	jnz .Lbb258
	movl $0, %eax
	jmp .Lbb260
.Lbb258:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb260
	movq offset_ptr(%rip), %rax
.Lbb260:
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
	jz .Lbb266
	movl $111, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb266
	movl $108, %edx
	movq %rsi, %r14
	movq %rdi, %r13
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	movq %r14, %rsi
	movq %r13, %rdi
	cmpl $0, %r12d
	jz .Lbb266
	movl $100, %edx
	callq cmp_current
	movl %eax, %r12d
	callq inc_offset
	cmpl $0, %r12d
	jnz .Lbb267
.Lbb266:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb268
.Lbb267:
	movl $1, %eax
.Lbb268:
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
	jnz .Lbb271
	movl $0, %eax
	jmp .Lbb272
.Lbb271:
	callq inc_offset
	movl $1, %eax
.Lbb272:
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
	jnz .Lbb275
	movl $0, %eax
	jmp .Lbb276
.Lbb275:
	callq inc_offset
	movl $1, %eax
.Lbb276:
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
	jnz .Lbb279
	movl $0, %eax
	jmp .Lbb280
.Lbb279:
	callq inc_offset
	movl $1, %eax
.Lbb280:
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
	jnz .Lbb286
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_28
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb286
	callq lex_29
	cmpl $0, %eax
	jnz .Lbb286
	callq inc_offset
	movl $1, %eax
	jmp .Lbb287
.Lbb286:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb287:
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
	jz .Lbb291
	callq lex_26
	cmpl $0, %eax
	jnz .Lbb292
.Lbb291:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb293
.Lbb292:
	movl $1, %eax
.Lbb293:
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
	jnz .Lbb296
	movl $0, %eax
	jmp .Lbb298
.Lbb296:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb298
	movq offset_ptr(%rip), %rax
.Lbb298:
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
	jnz .Lbb301
	movl $0, %eax
	jmp .Lbb302
.Lbb301:
	callq inc_offset
	movl $1, %eax
.Lbb302:
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
	jnz .Lbb305
	movl $0, %eax
	jmp .Lbb306
.Lbb305:
	callq inc_offset
	movl $1, %eax
.Lbb306:
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
	jnz .Lbb309
	movl $0, %eax
	jmp .Lbb310
.Lbb309:
	callq inc_offset
	movl $1, %eax
.Lbb310:
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
	jnz .Lbb316
	movq %rbx, offset_ptr(%rip)
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_33
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb316
	movq %rbx, offset_ptr(%rip)
	callq lex_34
	cmpl $0, %eax
	jnz .Lbb316
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb317
.Lbb316:
	movl $1, %eax
.Lbb317:
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
	jz .Lbb323
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_31
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb323
.Lbb320:
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jz .Lbb322
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_31
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb320
.Lbb322:
	movl $1, %eax
	jmp .Lbb324
.Lbb323:
	movl $0, %eax
.Lbb324:
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
	jnz .Lbb328
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb329
.Lbb328:
	movl $1, %eax
.Lbb329:
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
	jnz .Lbb332
	movl $0, %eax
	jmp .Lbb334
.Lbb332:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb334
	movq offset_ptr(%rip), %rax
.Lbb334:
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
	jnz .Lbb337
	movl $0, %eax
	jmp .Lbb338
.Lbb337:
	callq inc_offset
	movl $1, %eax
.Lbb338:
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
	jz .Lbb349
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_37
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb349
.Lbb346:
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jz .Lbb348
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_37
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb346
.Lbb348:
	movl $1, %eax
	jmp .Lbb350
.Lbb349:
	movl $0, %eax
.Lbb350:
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
	jnz .Lbb354
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb355
.Lbb354:
	movl $1, %eax
.Lbb355:
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
	jnz .Lbb358
	movl $0, %eax
	jmp .Lbb360
.Lbb358:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb360
	movq offset_ptr(%rip), %rax
.Lbb360:
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
	jnz .Lbb364
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb365
.Lbb364:
	movl $1, %eax
.Lbb365:
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
	jnz .Lbb369
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb370
.Lbb369:
	movl $1, %eax
.Lbb370:
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
	jnz .Lbb373
	movl $0, %eax
	jmp .Lbb375
.Lbb373:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb375
	movq offset_ptr(%rip), %rax
.Lbb375:
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
	jnz .Lbb379
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb380
.Lbb379:
	movl $1, %eax
.Lbb380:
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
	jnz .Lbb384
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb385
.Lbb384:
	movl $1, %eax
.Lbb385:
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
	jnz .Lbb388
	movl $0, %eax
	jmp .Lbb390
.Lbb388:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb390
	movq offset_ptr(%rip), %rax
.Lbb390:
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
	jnz .Lbb394
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb395
.Lbb394:
	movl $1, %eax
.Lbb395:
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
	jnz .Lbb399
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb400
.Lbb399:
	movl $1, %eax
.Lbb400:
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
	jnz .Lbb403
	movl $0, %eax
	jmp .Lbb405
.Lbb403:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb405
	movq offset_ptr(%rip), %rax
.Lbb405:
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
	jnz .Lbb409
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb410
.Lbb409:
	movl $1, %eax
.Lbb410:
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
	jnz .Lbb414
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb415
.Lbb414:
	movl $1, %eax
.Lbb415:
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
	jnz .Lbb418
	movl $0, %eax
	jmp .Lbb420
.Lbb418:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb420
	movq offset_ptr(%rip), %rax
.Lbb420:
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
	jnz .Lbb424
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb425
.Lbb424:
	movl $1, %eax
.Lbb425:
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
	jnz .Lbb429
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb430
.Lbb429:
	movl $1, %eax
.Lbb430:
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
	jnz .Lbb433
	movl $0, %eax
	jmp .Lbb435
.Lbb433:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb435
	movq offset_ptr(%rip), %rax
.Lbb435:
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
	jnz .Lbb439
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb440
.Lbb439:
	movl $1, %eax
.Lbb440:
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
	jnz .Lbb444
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb445
.Lbb444:
	movl $1, %eax
.Lbb445:
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
	jnz .Lbb448
	movl $0, %eax
	jmp .Lbb450
.Lbb448:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb450
	movq offset_ptr(%rip), %rax
.Lbb450:
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
	jnz .Lbb454
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb455
.Lbb454:
	movl $1, %eax
.Lbb455:
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
	jnz .Lbb459
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb460
.Lbb459:
	movl $1, %eax
.Lbb460:
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
	jnz .Lbb463
	movl $0, %eax
	jmp .Lbb465
.Lbb463:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb465
	movq offset_ptr(%rip), %rax
.Lbb465:
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
	jnz .Lbb469
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb470
.Lbb469:
	movl $1, %eax
.Lbb470:
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
	jnz .Lbb474
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb475
.Lbb474:
	movl $1, %eax
.Lbb475:
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
	jnz .Lbb478
	movl $0, %eax
	jmp .Lbb480
.Lbb478:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb480
	movq offset_ptr(%rip), %rax
.Lbb480:
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
	jnz .Lbb484
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb485
.Lbb484:
	movl $1, %eax
.Lbb485:
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
	jnz .Lbb489
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb490
.Lbb489:
	movl $1, %eax
.Lbb490:
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
	jnz .Lbb493
	movl $0, %eax
	jmp .Lbb495
.Lbb493:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb495
	movq offset_ptr(%rip), %rax
.Lbb495:
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
	jnz .Lbb499
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb500
.Lbb499:
	movl $1, %eax
.Lbb500:
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
	jnz .Lbb504
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb505
.Lbb504:
	movl $1, %eax
.Lbb505:
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
	jnz .Lbb508
	movl $0, %eax
	jmp .Lbb510
.Lbb508:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb510
	movq offset_ptr(%rip), %rax
.Lbb510:
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
	jnz .Lbb514
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb515
.Lbb514:
	movl $1, %eax
.Lbb515:
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
	jnz .Lbb519
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb520
.Lbb519:
	movl $1, %eax
.Lbb520:
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
	jnz .Lbb523
	movl $0, %eax
	jmp .Lbb525
.Lbb523:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb525
	movq offset_ptr(%rip), %rax
.Lbb525:
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
	jnz .Lbb529
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb530
.Lbb529:
	movl $1, %eax
.Lbb530:
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
	jnz .Lbb534
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb535
.Lbb534:
	movl $1, %eax
.Lbb535:
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
	jnz .Lbb538
	movl $0, %eax
	jmp .Lbb540
.Lbb538:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb540
	movq offset_ptr(%rip), %rax
.Lbb540:
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
	jnz .Lbb543
	movl $0, %eax
	jmp .Lbb544
.Lbb543:
	callq inc_offset
	movl $1, %eax
.Lbb544:
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
	jnz .Lbb547
	movl $0, %eax
	jmp .Lbb548
.Lbb547:
	callq inc_offset
	movl $1, %eax
.Lbb548:
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
	jnz .Lbb551
	movl $0, %eax
	jmp .Lbb552
.Lbb551:
	callq inc_offset
	movl $1, %eax
.Lbb552:
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
	jnz .Lbb558
	movq %rbx, offset_ptr(%rip)
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_67
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb558
	movq %rbx, offset_ptr(%rip)
	callq lex_68
	cmpl $0, %eax
	jnz .Lbb558
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb559
.Lbb558:
	movl $1, %eax
.Lbb559:
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
	jnz .Lbb562
	movl $0, %eax
	jmp .Lbb563
.Lbb562:
	callq inc_offset
	movl $1, %eax
.Lbb563:
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
	jnz .Lbb566
	movl $0, %eax
	jmp .Lbb567
.Lbb566:
	callq inc_offset
	movl $1, %eax
.Lbb567:
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
	jnz .Lbb570
	movl $0, %eax
	jmp .Lbb571
.Lbb570:
	callq inc_offset
	movl $1, %eax
.Lbb571:
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
	jnz .Lbb574
	movl $0, %eax
	jmp .Lbb575
.Lbb574:
	callq inc_offset
	movl $1, %eax
.Lbb575:
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
	jnz .Lbb582
	movq %rbx, offset_ptr(%rip)
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_71
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb582
	movq %rbx, offset_ptr(%rip)
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_72
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jnz .Lbb582
	movq %rbx, offset_ptr(%rip)
	callq lex_73
	cmpl $0, %eax
	jnz .Lbb582
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb583
.Lbb582:
	movl $1, %eax
.Lbb583:
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
.Lbb585:
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_69
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb587
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jnz .Lbb585
.Lbb587:
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
	jz .Lbb592
	callq lex_74
	cmpl $0, %eax
	jnz .Lbb593
.Lbb592:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb594
.Lbb593:
	movl $1, %eax
.Lbb594:
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
	jnz .Lbb597
	movl $0, %eax
	jmp .Lbb599
.Lbb597:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb599
	movq offset_ptr(%rip), %rax
.Lbb599:
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
	jnz .Lbb603
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb604
.Lbb603:
	movl $1, %eax
.Lbb604:
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
	jnz .Lbb608
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb609
.Lbb608:
	movl $1, %eax
.Lbb609:
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
	jnz .Lbb612
	movl $0, %eax
	jmp .Lbb614
.Lbb612:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb614
	movq offset_ptr(%rip), %rax
.Lbb614:
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
	jnz .Lbb618
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb619
.Lbb618:
	movl $1, %eax
.Lbb619:
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
	jnz .Lbb623
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb624
.Lbb623:
	movl $1, %eax
.Lbb624:
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
	jz .Lbb630
	callq lex_82
	cmpl $0, %eax
	jnz .Lbb631
.Lbb630:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb632
.Lbb631:
	movl $1, %eax
.Lbb632:
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
	jnz .Lbb635
	movl $0, %eax
	jmp .Lbb636
.Lbb635:
	callq inc_offset
	movl $1, %eax
.Lbb636:
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
	jnz .Lbb640
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb641
.Lbb640:
	movl $1, %eax
.Lbb641:
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
	jnz .Lbb648
	callq lex_86
	cmpl $0, %eax
	jnz .Lbb648
	callq inc_offset
	movl $1, %eax
	jmp .Lbb649
.Lbb648:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
.Lbb649:
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
	jnz .Lbb653
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb654
.Lbb653:
	movl $1, %eax
.Lbb654:
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
	jnz .Lbb659
	movq %rbx, offset_ptr(%rip)
	callq lex_83
	cmpl $0, %eax
	jnz .Lbb659
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb660
.Lbb659:
	movl $1, %eax
.Lbb660:
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
.Lbb662:
	movq %rsi, %r12
	movq %rdi, %rbx
	callq lex_79
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb664
	movq offset_ptr(%rip), %rax
	cmpq %rsi, %rax
	jnz .Lbb662
.Lbb664:
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
	jnz .Lbb669
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb670
.Lbb669:
	movl $1, %eax
.Lbb670:
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
	jz .Lbb675
	movq %rsi, %r13
	movq %rdi, %r12
	callq lex_88
	movq %r13, %rsi
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb675
	callq lex_89
	cmpl $0, %eax
	jnz .Lbb676
.Lbb675:
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb677
.Lbb676:
	movl $1, %eax
.Lbb677:
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
	jnz .Lbb680
	movl $0, %eax
	jmp .Lbb682
.Lbb680:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb682
	movq offset_ptr(%rip), %rax
.Lbb682:
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
	jnz .Lbb686
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb687
.Lbb686:
	movl $1, %eax
.Lbb687:
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
	jnz .Lbb691
	movq %rbx, offset_ptr(%rip)
	movl $0, %eax
	jmp .Lbb692
.Lbb691:
	movl $1, %eax
.Lbb692:
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
	jnz .Lbb695
	movl $0, %eax
	jmp .Lbb697
.Lbb695:
	movq group_end(%rip), %rax
	cmpl $0, %eax
	jnz .Lbb697
	movq offset_ptr(%rip), %rax
.Lbb697:
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
.Lbb700:
	movq %rdx, %r14
	movq offset_ptr(%rip), %rax
	cmpq %r14, %rax
	jz .Lbb771
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_KEYWORD
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb769
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_PARSER
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb767
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_TOKEN
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb765
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_HIGHTLIGHT
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb763
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_FOLD
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb761
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_whitespace
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb759
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_int
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb757
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_colon
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb755
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_comma
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb753
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_bar
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb751
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_dot
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb749
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_l_bracket
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb747
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_r_bracket
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb745
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_l_paren
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb743
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_r_paren
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb741
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_l_brace
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb739
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_r_brace
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb737
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_plus
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb735
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_eq
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb733
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_ident
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb731
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_semi
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb729
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_string
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jnz .Lbb727
	movq %rsi, %r13
	movq %r14, %rsi
	movq %r13, %rdi
	callq lex_at
	movq %r14, %rdx
	movq %r13, %rsi
	movq %rax, %r13
	cmpl $0, %r13d
	jz .Lbb725
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
	jmp .Lbb700
.Lbb725:
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
	jmp .Lbb772
.Lbb727:
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
	jmp .Lbb700
.Lbb729:
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
	jmp .Lbb700
.Lbb731:
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
	jmp .Lbb700
.Lbb733:
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
	jmp .Lbb700
.Lbb735:
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
	jmp .Lbb700
.Lbb737:
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
	jmp .Lbb700
.Lbb739:
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
	jmp .Lbb700
.Lbb741:
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
	jmp .Lbb700
.Lbb743:
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
	jmp .Lbb700
.Lbb745:
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
	jmp .Lbb700
.Lbb747:
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
	jmp .Lbb700
.Lbb749:
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
	jmp .Lbb700
.Lbb751:
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
	jmp .Lbb700
.Lbb753:
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
	jmp .Lbb700
.Lbb755:
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
	jmp .Lbb700
.Lbb757:
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
	jmp .Lbb700
.Lbb759:
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
	jmp .Lbb700
.Lbb761:
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
	jmp .Lbb700
.Lbb763:
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
	jmp .Lbb700
.Lbb765:
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
	jmp .Lbb700
.Lbb767:
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
	jmp .Lbb700
.Lbb769:
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
	jmp .Lbb700
.Lbb771:
	movq -16(%rbp), %rax
.Lbb772:
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
	jz .Lbb821
	cmpl $1, %edi
	leaq PARSER_token_name(%rip), %rax
	jz .Lbb820
	cmpl $2, %edi
	leaq TOKEN_token_name(%rip), %rax
	jz .Lbb819
	cmpl $3, %edi
	leaq HIGHTLIGHT_token_name(%rip), %rax
	jz .Lbb818
	cmpl $4, %edi
	leaq FOLD_token_name(%rip), %rax
	jz .Lbb817
	cmpl $5, %edi
	leaq whitespace_token_name(%rip), %rax
	jz .Lbb816
	cmpl $6, %edi
	leaq int_token_name(%rip), %rax
	jz .Lbb815
	cmpl $7, %edi
	leaq colon_token_name(%rip), %rax
	jz .Lbb814
	cmpl $8, %edi
	leaq comma_token_name(%rip), %rax
	jz .Lbb813
	cmpl $9, %edi
	leaq bar_token_name(%rip), %rax
	jz .Lbb812
	cmpl $10, %edi
	leaq dot_token_name(%rip), %rax
	jz .Lbb811
	cmpl $11, %edi
	leaq l_bracket_token_name(%rip), %rax
	jz .Lbb810
	cmpl $12, %edi
	leaq r_bracket_token_name(%rip), %rax
	jz .Lbb809
	cmpl $13, %edi
	leaq l_paren_token_name(%rip), %rax
	jz .Lbb808
	cmpl $14, %edi
	leaq r_paren_token_name(%rip), %rax
	jz .Lbb807
	cmpl $15, %edi
	leaq l_brace_token_name(%rip), %rax
	jz .Lbb806
	cmpl $16, %edi
	leaq r_brace_token_name(%rip), %rax
	jz .Lbb805
	cmpl $17, %edi
	leaq plus_token_name(%rip), %rax
	jz .Lbb804
	cmpl $18, %edi
	leaq eq_token_name(%rip), %rax
	jz .Lbb803
	cmpl $19, %edi
	leaq ident_token_name(%rip), %rax
	jz .Lbb802
	cmpl $20, %edi
	leaq semi_token_name(%rip), %rax
	jz .Lbb801
	cmpl $21, %edi
	leaq string_token_name(%rip), %rax
	jz .Lbb800
	cmpl $22, %edi
	leaq at_token_name(%rip), %rax
	jz .Lbb799
	leaq err_token_name(%rip), %rax
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb822
.Lbb799:
	movq %rax, %rdx
	movl $2, %eax
	jmp .Lbb822
.Lbb800:
	movq %rax, %rdx
	movl $6, %eax
	jmp .Lbb822
.Lbb801:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb822
.Lbb802:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb822
.Lbb803:
	movq %rax, %rdx
	movl $2, %eax
	jmp .Lbb822
.Lbb804:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb822
.Lbb805:
	movq %rax, %rdx
	movl $7, %eax
	jmp .Lbb822
.Lbb806:
	movq %rax, %rdx
	movl $7, %eax
	jmp .Lbb822
.Lbb807:
	movq %rax, %rdx
	movl $7, %eax
	jmp .Lbb822
.Lbb808:
	movq %rax, %rdx
	movl $7, %eax
	jmp .Lbb822
.Lbb809:
	movq %rax, %rdx
	movl $9, %eax
	jmp .Lbb822
.Lbb810:
	movq %rax, %rdx
	movl $9, %eax
	jmp .Lbb822
.Lbb811:
	movq %rax, %rdx
	movl $3, %eax
	jmp .Lbb822
.Lbb812:
	movq %rax, %rdx
	movl $3, %eax
	jmp .Lbb822
.Lbb813:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb822
.Lbb814:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb822
.Lbb815:
	movq %rax, %rdx
	movl $3, %eax
	jmp .Lbb822
.Lbb816:
	movq %rax, %rdx
	movl $10, %eax
	jmp .Lbb822
.Lbb817:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb822
.Lbb818:
	movq %rax, %rdx
	movl $10, %eax
	jmp .Lbb822
.Lbb819:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb822
.Lbb820:
	movq %rax, %rdx
	movl $6, %eax
	jmp .Lbb822
.Lbb821:
	movq %rax, %rdx
	movl $7, %eax
.Lbb822:
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
	jz .Lbb966
	cmpq $1, %rcx
	jz .Lbb965
	cmpq $2, %rcx
	jz .Lbb964
	cmpq $3, %rcx
	jz .Lbb963
	cmpq $4, %rcx
	jz .Lbb962
	cmpq $5, %rcx
	jz .Lbb961
	cmpq $6, %rcx
	jz .Lbb960
	cmpq $7, %rcx
	jz .Lbb959
	cmpq $8, %rcx
	jz .Lbb958
	cmpq $9, %rcx
	jz .Lbb957
	cmpq $10, %rcx
	jz .Lbb956
	cmpq $11, %rcx
	jz .Lbb955
	cmpq $12, %rcx
	jz .Lbb954
	cmpq $13, %rcx
	jz .Lbb953
	cmpq $14, %rcx
	jz .Lbb952
	cmpq $15, %rcx
	jz .Lbb951
	cmpq $16, %rcx
	jz .Lbb950
	cmpq $17, %rcx
	jz .Lbb949
	cmpq $18, %rcx
	jz .Lbb948
	cmpq $19, %rcx
	jz .Lbb947
	cmpq $20, %rcx
	jz .Lbb946
	cmpq $21, %rcx
	jz .Lbb945
	cmpq $22, %rcx
	jz .Lbb944
	cmpq $23, %rcx
	jz .Lbb943
	cmpq $24, %rcx
	jz .Lbb942
	cmpq $25, %rcx
	jz .Lbb941
	cmpq $26, %rcx
	jz .Lbb940
	cmpq $27, %rcx
	jz .Lbb939
	cmpq $28, %rcx
	jz .Lbb938
	cmpq $29, %rcx
	jz .Lbb937
	cmpq $30, %rcx
	jz .Lbb936
	cmpq $31, %rcx
	jz .Lbb935
	cmpq $32, %rcx
	jz .Lbb934
	cmpq $33, %rcx
	jz .Lbb933
	cmpq $34, %rcx
	jz .Lbb932
	cmpq $35, %rcx
	jz .Lbb931
	cmpq $36, %rcx
	jz .Lbb930
	cmpq $37, %rcx
	jz .Lbb929
	cmpq $38, %rcx
	jz .Lbb928
	cmpq $39, %rcx
	jz .Lbb927
	cmpq $40, %rcx
	jz .Lbb926
	cmpq $41, %rcx
	jz .Lbb925
	cmpq $42, %rcx
	jz .Lbb924
	cmpq $43, %rcx
	jz .Lbb923
	cmpq $44, %rcx
	jz .Lbb922
	cmpq $45, %rcx
	jz .Lbb921
	cmpq $46, %rcx
	jz .Lbb920
	cmpq $47, %rcx
	jz .Lbb919
	cmpq $48, %rcx
	jz .Lbb918
	cmpq $49, %rcx
	jz .Lbb917
	cmpq $50, %rcx
	jz .Lbb916
	cmpq $51, %rcx
	jz .Lbb915
	cmpq $52, %rcx
	jz .Lbb914
	cmpq $53, %rcx
	jz .Lbb913
	cmpq $54, %rcx
	jz .Lbb912
	cmpq $55, %rcx
	jz .Lbb911
	cmpq $56, %rcx
	jz .Lbb910
	cmpq $57, %rcx
	jz .Lbb909
	cmpq $58, %rcx
	jz .Lbb908
	cmpq $59, %rcx
	jz .Lbb907
	cmpq $60, %rcx
	jz .Lbb906
	cmpq $61, %rcx
	jz .Lbb905
	cmpq $62, %rcx
	jz .Lbb904
	cmpq $63, %rcx
	jz .Lbb903
	cmpq $64, %rcx
	jz .Lbb902
	cmpq $65, %rcx
	jz .Lbb901
	cmpq $66, %rcx
	jz .Lbb900
	cmpq $67, %rcx
	jz .Lbb899
	cmpq $68, %rcx
	jz .Lbb898
	cmpq $69, %rcx
	jz .Lbb897
	cmpq $70, %rcx
	jz .Lbb896
	movl $0, %eax
	jmp .Lbb967
.Lbb896:
	callq peak_70
	jmp .Lbb967
.Lbb897:
	callq peak_69
	jmp .Lbb967
.Lbb898:
	callq peak_68
	jmp .Lbb967
.Lbb899:
	callq peak_67
	jmp .Lbb967
.Lbb900:
	callq peak_66
	jmp .Lbb967
.Lbb901:
	callq peak_65
	jmp .Lbb967
.Lbb902:
	callq peak_64
	jmp .Lbb967
.Lbb903:
	callq peak_63
	jmp .Lbb967
.Lbb904:
	callq peak_62
	jmp .Lbb967
.Lbb905:
	callq peak_61
	jmp .Lbb967
.Lbb906:
	callq peak_60
	jmp .Lbb967
.Lbb907:
	callq peak_59
	jmp .Lbb967
.Lbb908:
	callq peak_58
	jmp .Lbb967
.Lbb909:
	callq peak_57
	jmp .Lbb967
.Lbb910:
	callq peak_56
	jmp .Lbb967
.Lbb911:
	callq peak_55
	jmp .Lbb967
.Lbb912:
	callq peak_54
	jmp .Lbb967
.Lbb913:
	callq peak_53
	jmp .Lbb967
.Lbb914:
	callq peak_52
	jmp .Lbb967
.Lbb915:
	callq peak_51
	jmp .Lbb967
.Lbb916:
	callq peak_50
	jmp .Lbb967
.Lbb917:
	callq peak_49
	jmp .Lbb967
.Lbb918:
	callq peak_48
	jmp .Lbb967
.Lbb919:
	callq peak_47
	jmp .Lbb967
.Lbb920:
	callq peak_46
	jmp .Lbb967
.Lbb921:
	callq peak_45
	jmp .Lbb967
.Lbb922:
	callq peak_44
	jmp .Lbb967
.Lbb923:
	callq peak_43
	jmp .Lbb967
.Lbb924:
	callq peak_42
	jmp .Lbb967
.Lbb925:
	callq peak_41
	jmp .Lbb967
.Lbb926:
	callq peak_40
	jmp .Lbb967
.Lbb927:
	callq peak_39
	jmp .Lbb967
.Lbb928:
	callq peak_38
	jmp .Lbb967
.Lbb929:
	callq peak_37
	jmp .Lbb967
.Lbb930:
	callq peak_36
	jmp .Lbb967
.Lbb931:
	callq peak_35
	jmp .Lbb967
.Lbb932:
	callq peak_34
	jmp .Lbb967
.Lbb933:
	callq peak_33
	jmp .Lbb967
.Lbb934:
	callq peak_32
	jmp .Lbb967
.Lbb935:
	callq peak_31
	jmp .Lbb967
.Lbb936:
	callq peak_30
	jmp .Lbb967
.Lbb937:
	callq peak_29
	jmp .Lbb967
.Lbb938:
	callq peak_28
	jmp .Lbb967
.Lbb939:
	callq peak_27
	jmp .Lbb967
.Lbb940:
	callq peak_26
	jmp .Lbb967
.Lbb941:
	callq peak_25
	jmp .Lbb967
.Lbb942:
	callq peak_24
	jmp .Lbb967
.Lbb943:
	callq peak_23
	jmp .Lbb967
.Lbb944:
	callq peak_22
	jmp .Lbb967
.Lbb945:
	callq peak_21
	jmp .Lbb967
.Lbb946:
	callq peak_20
	jmp .Lbb967
.Lbb947:
	callq peak_19
	jmp .Lbb967
.Lbb948:
	callq peak_18
	jmp .Lbb967
.Lbb949:
	callq peak_17
	jmp .Lbb967
.Lbb950:
	callq peak_16
	jmp .Lbb967
.Lbb951:
	callq peak_15
	jmp .Lbb967
.Lbb952:
	callq peak_14
	jmp .Lbb967
.Lbb953:
	callq peak_13
	jmp .Lbb967
.Lbb954:
	callq peak_12
	jmp .Lbb967
.Lbb955:
	callq peak_11
	jmp .Lbb967
.Lbb956:
	callq peak_10
	jmp .Lbb967
.Lbb957:
	callq peak_9
	jmp .Lbb967
.Lbb958:
	callq peak_8
	jmp .Lbb967
.Lbb959:
	callq peak_7
	jmp .Lbb967
.Lbb960:
	callq peak_6
	jmp .Lbb967
.Lbb961:
	callq peak_5
	jmp .Lbb967
.Lbb962:
	callq peak_4
	jmp .Lbb967
.Lbb963:
	callq peak_3
	jmp .Lbb967
.Lbb964:
	callq peak_2
	jmp .Lbb967
.Lbb965:
	callq peak_1
	jmp .Lbb967
.Lbb966:
	callq peak_0
.Lbb967:
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
	jnz .Lbb972
	movq %rdi, %rbx
	callq parse_25
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb971
	callq exit_group
	movq %rbx, %rax
	jmp .Lbb973
.Lbb971:
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
	jmp .Lbb973
.Lbb972:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb973:
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
.Lbb979:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb991
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $19, %rsi
	jz .Lbb990
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb984
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb979
.Lbb984:
	cmpl $0, %r12d
	jz .Lbb989
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb989
.Lbb986:
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
	jz .Lbb988
	cmpl $0, %ebx
	jz .Lbb989
	jmp .Lbb986
.Lbb988:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb992
.Lbb989:
	movl $1, %eax
	jmp .Lbb992
.Lbb990:
	callq bump
	movl $0, %eax
	jmp .Lbb992
.Lbb991:
	movl $2, %eax
.Lbb992:
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
	jnz .Lbb1002
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $19, %rax
	jz .Lbb1001
	cmpl $0, %edx
	jz .Lbb1000
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1000
.Lbb997:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb999
	cmpl $0, %ebx
	jz .Lbb1000
	jmp .Lbb997
.Lbb999:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1003
.Lbb1000:
	movl $1, %eax
	jmp .Lbb1003
.Lbb1001:
	movl $0, %eax
	jmp .Lbb1003
.Lbb1002:
	movl $2, %eax
.Lbb1003:
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
	jnz .Lbb1008
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb1009
.Lbb1008:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1009:
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
.Lbb1015:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1027
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $13, %rsi
	jz .Lbb1026
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1020
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1015
.Lbb1020:
	cmpl $0, %r12d
	jz .Lbb1025
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1025
.Lbb1022:
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
	jz .Lbb1024
	cmpl $0, %ebx
	jz .Lbb1025
	jmp .Lbb1022
.Lbb1024:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1028
.Lbb1025:
	movl $1, %eax
	jmp .Lbb1028
.Lbb1026:
	callq bump
	movl $0, %eax
	jmp .Lbb1028
.Lbb1027:
	movl $2, %eax
.Lbb1028:
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
	jnz .Lbb1038
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $13, %rax
	jz .Lbb1037
	cmpl $0, %edx
	jz .Lbb1036
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1036
.Lbb1033:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1035
	cmpl $0, %ebx
	jz .Lbb1036
	jmp .Lbb1033
.Lbb1035:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1039
.Lbb1036:
	movl $1, %eax
	jmp .Lbb1039
.Lbb1037:
	movl $0, %eax
	jmp .Lbb1039
.Lbb1038:
	movl $2, %eax
.Lbb1039:
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
.Lbb1043:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1055
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $14, %rsi
	jz .Lbb1054
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1048
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1043
.Lbb1048:
	cmpl $0, %r12d
	jz .Lbb1053
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1053
.Lbb1050:
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
	jz .Lbb1052
	cmpl $0, %ebx
	jz .Lbb1053
	jmp .Lbb1050
.Lbb1052:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1056
.Lbb1053:
	movl $1, %eax
	jmp .Lbb1056
.Lbb1054:
	callq bump
	movl $0, %eax
	jmp .Lbb1056
.Lbb1055:
	movl $2, %eax
.Lbb1056:
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
	jnz .Lbb1066
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $14, %rax
	jz .Lbb1065
	cmpl $0, %edx
	jz .Lbb1064
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1064
.Lbb1061:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1063
	cmpl $0, %ebx
	jz .Lbb1064
	jmp .Lbb1061
.Lbb1063:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1067
.Lbb1064:
	movl $1, %eax
	jmp .Lbb1067
.Lbb1065:
	movl $0, %eax
	jmp .Lbb1067
.Lbb1066:
	movl $2, %eax
.Lbb1067:
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
	jnz .Lbb1084
	movl %esi, %r12d
	movl $4, %esi
	movq %rdi, %rbx
	callq push_delim
	movl %r12d, %esi
	movq %rbx, %rdi
.Lbb1072:
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_0
	movq %rbx, %rdi
	cmpq $1, %rax
	jnz .Lbb1074
	movq %rdi, %rbx
	callq bump_err
	movl %r12d, %esi
	movq %rbx, %rdi
	jmp .Lbb1072
.Lbb1074:
	movl %r12d, %esi
	movq 64(%rdi), %rcx
	movq %rcx, %rbx
	addq $2, %rbx
	cmpq %rax, %rbx
	jnz .Lbb1079
	movl %esi, %r12d
.Lbb1077:
	movq %rdi, %r13
	leaq -24(%rbp), %rdi
	callq expected_0
	movq %r13, %rdi
	movq %rax, %rsi
	movq %rdi, %r13
	callq missing
	movq %r13, %rdi
	movl %r12d, %esi
.Lbb1079:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_4
	movq %r12, %rdi
	cmpq $1, %rax
	jnz .Lbb1081
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb1079
.Lbb1081:
	movl %r13d, %r12d
	cmpq %rax, %rbx
	jz .Lbb1077
	callq pop_delim
	movl $0, %eax
.Lbb1084:
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
	jz .Lbb1091
	callq parse_2
.Lbb1091:
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
	jz .Lbb1094
	callq peak_2
.Lbb1094:
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
.Lbb1098:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1110
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $19, %rsi
	jz .Lbb1109
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1103
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1098
.Lbb1103:
	cmpl $0, %r12d
	jz .Lbb1108
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1108
.Lbb1105:
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
	callq bump
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
	jnz .Lbb1121
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $19, %rax
	jz .Lbb1120
	cmpl $0, %edx
	jz .Lbb1119
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1119
.Lbb1116:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1118
	cmpl $0, %ebx
	jz .Lbb1119
	jmp .Lbb1116
.Lbb1118:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1122
.Lbb1119:
	movl $1, %eax
	jmp .Lbb1122
.Lbb1120:
	movl $0, %eax
	jmp .Lbb1122
.Lbb1121:
	movl $2, %eax
.Lbb1122:
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
	jnz .Lbb1127
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb1128
.Lbb1127:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1128:
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
.Lbb1134:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1146
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $10, %rsi
	jz .Lbb1145
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1139
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1134
.Lbb1139:
	cmpl $0, %r12d
	jz .Lbb1144
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1144
.Lbb1141:
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
	jz .Lbb1143
	cmpl $0, %ebx
	jz .Lbb1144
	jmp .Lbb1141
.Lbb1143:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1147
.Lbb1144:
	movl $1, %eax
	jmp .Lbb1147
.Lbb1145:
	callq bump
	movl $0, %eax
	jmp .Lbb1147
.Lbb1146:
	movl $2, %eax
.Lbb1147:
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
	jnz .Lbb1157
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $10, %rax
	jz .Lbb1156
	cmpl $0, %edx
	jz .Lbb1155
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1155
.Lbb1152:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1154
	cmpl $0, %ebx
	jz .Lbb1155
	jmp .Lbb1152
.Lbb1154:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1158
.Lbb1155:
	movl $1, %eax
	jmp .Lbb1158
.Lbb1156:
	movl $0, %eax
	jmp .Lbb1158
.Lbb1157:
	movl $2, %eax
.Lbb1158:
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
.Lbb1162:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1174
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $8, %rsi
	jz .Lbb1173
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1167
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1162
.Lbb1167:
	cmpl $0, %r12d
	jz .Lbb1172
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1172
.Lbb1169:
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
	jz .Lbb1171
	cmpl $0, %ebx
	jz .Lbb1172
	jmp .Lbb1169
.Lbb1171:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1175
.Lbb1172:
	movl $1, %eax
	jmp .Lbb1175
.Lbb1173:
	callq bump
	movl $0, %eax
	jmp .Lbb1175
.Lbb1174:
	movl $2, %eax
.Lbb1175:
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
	jnz .Lbb1185
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $8, %rax
	jz .Lbb1184
	cmpl $0, %edx
	jz .Lbb1183
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1183
.Lbb1180:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1182
	cmpl $0, %ebx
	jz .Lbb1183
	jmp .Lbb1180
.Lbb1182:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1186
.Lbb1183:
	movl $1, %eax
	jmp .Lbb1186
.Lbb1184:
	movl $0, %eax
	jmp .Lbb1186
.Lbb1185:
	movl $2, %eax
.Lbb1186:
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
	jnz .Lbb1206
.Lbb1190:
	movl %esi, %r14d
	movq %rdi, %r13
	callq parse_10
	movq %r13, %rdi
	cmpq $1, %rax
	jz .Lbb1205
	cmpl $0, %eax
	jnz .Lbb1193
	movl %r14d, %esi
	jmp .Lbb1197
.Lbb1193:
	cmpq $2, %rax
	jz .Lbb1204
	cmpq %rax, %rbx
	jnz .Lbb1204
	movq %rdi, %r13
	leaq -48(%rbp), %rdi
	callq expected_10
	movq %r13, %rdi
	movq %rax, %rsi
	movq %rdi, %r13
	callq missing
	movq %r13, %rdi
	movl %r14d, %esi
.Lbb1197:
	movl %esi, %r14d
	movq %rdi, %r13
	callq parse_0
	movq %r13, %rdi
	movq %rax, %r13
	cmpq $1, %r13
	jnz .Lbb1199
	movq %rdi, %r13
	callq bump_err
	movl %r14d, %esi
	movq %r13, %rdi
	jmp .Lbb1197
.Lbb1199:
	cmpl $0, %r13d
	jnz .Lbb1201
	movl %r14d, %esi
	jmp .Lbb1190
.Lbb1201:
	movq %rdi, %r15
	leaq -24(%rbp), %rdi
	callq expected_0
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	cmpq $2, %r13
	jz .Lbb1204
	cmpq %r13, %r12
	jnz .Lbb1204
	movl %r14d, %esi
	jmp .Lbb1190
.Lbb1204:
	callq pop_delim
	movl $0, %eax
	jmp .Lbb1208
.Lbb1205:
	movq %rdi, %r13
	callq bump_err
	movl %r14d, %esi
	movq %r13, %rdi
	jmp .Lbb1190
.Lbb1206:
	movq %rax, %rbx
	callq pop_delim
	movq %rbx, %rax
.Lbb1208:
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
.Lbb1214:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1226
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $13, %rsi
	jz .Lbb1225
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1219
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1214
.Lbb1219:
	cmpl $0, %r12d
	jz .Lbb1224
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1224
.Lbb1221:
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
	jz .Lbb1223
	cmpl $0, %ebx
	jz .Lbb1224
	jmp .Lbb1221
.Lbb1223:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1227
.Lbb1224:
	movl $1, %eax
	jmp .Lbb1227
.Lbb1225:
	callq bump
	movl $0, %eax
	jmp .Lbb1227
.Lbb1226:
	movl $2, %eax
.Lbb1227:
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
	jnz .Lbb1237
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $13, %rax
	jz .Lbb1236
	cmpl $0, %edx
	jz .Lbb1235
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1235
.Lbb1232:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1234
	cmpl $0, %ebx
	jz .Lbb1235
	jmp .Lbb1232
.Lbb1234:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1238
.Lbb1235:
	movl $1, %eax
	jmp .Lbb1238
.Lbb1236:
	movl $0, %eax
	jmp .Lbb1238
.Lbb1237:
	movl $2, %eax
.Lbb1238:
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
.Lbb1242:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1254
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $14, %rsi
	jz .Lbb1253
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1247
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1242
.Lbb1247:
	cmpl $0, %r12d
	jz .Lbb1252
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1252
.Lbb1249:
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
	jz .Lbb1251
	cmpl $0, %ebx
	jz .Lbb1252
	jmp .Lbb1249
.Lbb1251:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1255
.Lbb1252:
	movl $1, %eax
	jmp .Lbb1255
.Lbb1253:
	callq bump
	movl $0, %eax
	jmp .Lbb1255
.Lbb1254:
	movl $2, %eax
.Lbb1255:
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
	jnz .Lbb1265
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $14, %rax
	jz .Lbb1264
	cmpl $0, %edx
	jz .Lbb1263
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1263
.Lbb1260:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1262
	cmpl $0, %ebx
	jz .Lbb1263
	jmp .Lbb1260
.Lbb1262:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1266
.Lbb1263:
	movl $1, %eax
	jmp .Lbb1266
.Lbb1264:
	movl $0, %eax
	jmp .Lbb1266
.Lbb1265:
	movl $2, %eax
.Lbb1266:
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
	jnz .Lbb1283
	movl %esi, %r12d
	movl $13, %esi
	movq %rdi, %rbx
	callq push_delim
	movl %r12d, %esi
	movq %rbx, %rdi
.Lbb1271:
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_11
	movq %rbx, %rdi
	cmpq $1, %rax
	jnz .Lbb1273
	movq %rdi, %rbx
	callq bump_err
	movl %r12d, %esi
	movq %rbx, %rdi
	jmp .Lbb1271
.Lbb1273:
	movl %r12d, %esi
	movq 64(%rdi), %rcx
	movq %rcx, %rbx
	addq $2, %rbx
	cmpq %rax, %rbx
	jnz .Lbb1278
	movl %esi, %r12d
.Lbb1276:
	movq %rdi, %r13
	leaq -24(%rbp), %rdi
	callq expected_11
	movq %r13, %rdi
	movq %rax, %rsi
	movq %rdi, %r13
	callq missing
	movq %r13, %rdi
	movl %r12d, %esi
.Lbb1278:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_13
	movq %r12, %rdi
	cmpq $1, %rax
	jnz .Lbb1280
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb1278
.Lbb1280:
	movl %r13d, %r12d
	cmpq %rax, %rbx
	jz .Lbb1276
	callq pop_delim
	movl $0, %eax
.Lbb1283:
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
	jnz .Lbb1317
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1292
	movl %r13d, %esi
	jmp .Lbb1298
.Lbb1292:
	cmpq $2, %rax
	jz .Lbb1296
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
	jz .Lbb1295
	movl %r13d, %esi
	jmp .Lbb1298
.Lbb1295:
	movq %rax, %r12
	jmp .Lbb1302
.Lbb1296:
	movq %rdi, %r12
	leaq -96(%rbp), %rdi
	callq expected_9
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movq %r12, %rdi
	movl %r13d, %esi
.Lbb1298:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_8
	movl %r13d, %esi
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1301
	movl %esi, %r13d
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb1298
.Lbb1301:
	movl %esi, %r13d
.Lbb1302:
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1304
	movl %r13d, %esi
	jmp .Lbb1308
.Lbb1304:
	cmpq $2, %rax
	jz .Lbb1307
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
	jz .Lbb1312
	movl %r13d, %esi
	jmp .Lbb1308
.Lbb1307:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_8
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb1308:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_14
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1311
	movq %rdi, %r12
	callq bump_err
	movq %r12, %rdi
	movl %r13d, %esi
	jmp .Lbb1308
.Lbb1311:
	movq %r12, %rax
.Lbb1312:
	cmpl $0, %eax
	jz .Lbb1316
	cmpq $2, %rax
	jz .Lbb1315
	movq %rbx, %rcx
	subq $2, %rcx
	cmpq %rcx, %rax
	jz .Lbb1316
.Lbb1315:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_14
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb1316:
	movl $0, %eax
	jmp .Lbb1318
.Lbb1317:
	movq %r12, %rax
.Lbb1318:
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
	jnz .Lbb1325
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb1326
.Lbb1325:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1326:
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
	jnz .Lbb1338
	movq %rdi, %rbx
	callq is_eof
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1337
.Lbb1333:
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_16
	movq %rbx, %rdi
	cmpq $1, %rax
	jz .Lbb1336
	cmpl $0, %eax
	jnz .Lbb1337
	movl %r12d, %esi
	jmp .Lbb1333
.Lbb1336:
	movq %rdi, %rbx
	callq bump_err
	movl %r12d, %esi
	movq %rbx, %rdi
	jmp .Lbb1333
.Lbb1337:
	callq pop_delim
	movl $0, %eax
	jmp .Lbb1339
.Lbb1338:
	callq pop_delim
	movq %rbx, %rax
.Lbb1339:
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
	jnz .Lbb1348
	movq %rdi, %rbx
	callq parse_17
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1347
	callq exit_group
	movq %rbx, %rax
	jmp .Lbb1349
.Lbb1347:
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
	jmp .Lbb1349
.Lbb1348:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1349:
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
.Lbb1355:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1367
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $17, %rsi
	jz .Lbb1366
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1360
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1355
.Lbb1360:
	cmpl $0, %r12d
	jz .Lbb1365
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1365
.Lbb1362:
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
	jz .Lbb1364
	cmpl $0, %ebx
	jz .Lbb1365
	jmp .Lbb1362
.Lbb1364:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1368
.Lbb1365:
	movl $1, %eax
	jmp .Lbb1368
.Lbb1366:
	callq bump
	movl $0, %eax
	jmp .Lbb1368
.Lbb1367:
	movl $2, %eax
.Lbb1368:
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
	jnz .Lbb1378
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $17, %rax
	jz .Lbb1377
	cmpl $0, %edx
	jz .Lbb1376
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1376
.Lbb1373:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1375
	cmpl $0, %ebx
	jz .Lbb1376
	jmp .Lbb1373
.Lbb1375:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1379
.Lbb1376:
	movl $1, %eax
	jmp .Lbb1379
.Lbb1377:
	movl $0, %eax
	jmp .Lbb1379
.Lbb1378:
	movl $2, %eax
.Lbb1379:
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
	jnz .Lbb1398
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1386
	movl %r13d, %esi
	jmp .Lbb1390
.Lbb1386:
	cmpq $2, %rax
	jz .Lbb1389
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
	jz .Lbb1393
	movl %r13d, %esi
	jmp .Lbb1390
.Lbb1389:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_19
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb1390:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_18
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1392
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb1390
.Lbb1392:
	movq %r12, %rax
.Lbb1393:
	cmpl $0, %eax
	jz .Lbb1397
	cmpq $2, %rax
	jz .Lbb1396
	movq %rbx, %rcx
	subq $1, %rcx
	cmpq %rcx, %rax
	jz .Lbb1397
.Lbb1396:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_18
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb1397:
	movl $0, %eax
	jmp .Lbb1399
.Lbb1398:
	movq %r12, %rax
.Lbb1399:
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
	jnz .Lbb1411
	movq %rdi, %rbx
	callq is_eof
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1410
.Lbb1406:
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_20
	movq %rbx, %rdi
	cmpq $1, %rax
	jz .Lbb1409
	cmpl $0, %eax
	jnz .Lbb1410
	movl %r12d, %esi
	jmp .Lbb1406
.Lbb1409:
	movq %rdi, %rbx
	callq bump_err
	movl %r12d, %esi
	movq %rbx, %rdi
	jmp .Lbb1406
.Lbb1410:
	callq pop_delim
	movl $0, %eax
	jmp .Lbb1412
.Lbb1411:
	callq pop_delim
	movq %rbx, %rax
.Lbb1412:
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
	jnz .Lbb1421
	movq %rdi, %rbx
	callq parse_21
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1420
	callq exit_group
	movq %rbx, %rax
	jmp .Lbb1422
.Lbb1420:
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
	jmp .Lbb1422
.Lbb1421:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1422:
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
.Lbb1428:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1440
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $9, %rsi
	jz .Lbb1439
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1433
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1428
.Lbb1433:
	cmpl $0, %r12d
	jz .Lbb1438
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1438
.Lbb1435:
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
	jz .Lbb1437
	cmpl $0, %ebx
	jz .Lbb1438
	jmp .Lbb1435
.Lbb1437:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1441
.Lbb1438:
	movl $1, %eax
	jmp .Lbb1441
.Lbb1439:
	callq bump
	movl $0, %eax
	jmp .Lbb1441
.Lbb1440:
	movl $2, %eax
.Lbb1441:
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
	jnz .Lbb1451
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $9, %rax
	jz .Lbb1450
	cmpl $0, %edx
	jz .Lbb1449
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1449
.Lbb1446:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1448
	cmpl $0, %ebx
	jz .Lbb1449
	jmp .Lbb1446
.Lbb1448:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1452
.Lbb1449:
	movl $1, %eax
	jmp .Lbb1452
.Lbb1450:
	movl $0, %eax
	jmp .Lbb1452
.Lbb1451:
	movl $2, %eax
.Lbb1452:
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
	jnz .Lbb1471
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1459
	movl %r13d, %esi
	jmp .Lbb1463
.Lbb1459:
	cmpq $2, %rax
	jz .Lbb1462
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
	jz .Lbb1466
	movl %r13d, %esi
	jmp .Lbb1463
.Lbb1462:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_23
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb1463:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_22
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1465
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb1463
.Lbb1465:
	movq %r12, %rax
.Lbb1466:
	cmpl $0, %eax
	jz .Lbb1470
	cmpq $2, %rax
	jz .Lbb1469
	movq %rbx, %rcx
	subq $1, %rcx
	cmpq %rcx, %rax
	jz .Lbb1470
.Lbb1469:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_22
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb1470:
	movl $0, %eax
	jmp .Lbb1472
.Lbb1471:
	movq %r12, %rax
.Lbb1472:
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
	jnz .Lbb1484
	movq %rdi, %rbx
	callq is_eof
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1483
.Lbb1479:
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_24
	movq %rbx, %rdi
	cmpq $1, %rax
	jz .Lbb1482
	cmpl $0, %eax
	jnz .Lbb1483
	movl %r12d, %esi
	jmp .Lbb1479
.Lbb1482:
	movq %rdi, %rbx
	callq bump_err
	movl %r12d, %esi
	movq %rbx, %rdi
	jmp .Lbb1479
.Lbb1483:
	callq pop_delim
	movl $0, %eax
	jmp .Lbb1485
.Lbb1484:
	callq pop_delim
	movq %rbx, %rax
.Lbb1485:
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
	jnz .Lbb1494
	movq %rdi, %rbx
	callq parse_25
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1493
	callq exit_group
	movq %rbx, %rax
	jmp .Lbb1495
.Lbb1493:
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
	jmp .Lbb1495
.Lbb1494:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1495:
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
.Lbb1501:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1513
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $0, %rsi
	jz .Lbb1512
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1506
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1501
.Lbb1506:
	cmpl $0, %r12d
	jz .Lbb1511
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1511
.Lbb1508:
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
	jz .Lbb1510
	cmpl $0, %ebx
	jz .Lbb1511
	jmp .Lbb1508
.Lbb1510:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1514
.Lbb1511:
	movl $1, %eax
	jmp .Lbb1514
.Lbb1512:
	callq bump
	movl $0, %eax
	jmp .Lbb1514
.Lbb1513:
	movl $2, %eax
.Lbb1514:
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
	jnz .Lbb1524
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $0, %rax
	jz .Lbb1523
	cmpl $0, %edx
	jz .Lbb1522
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1522
.Lbb1519:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1521
	cmpl $0, %ebx
	jz .Lbb1522
	jmp .Lbb1519
.Lbb1521:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1525
.Lbb1522:
	movl $1, %eax
	jmp .Lbb1525
.Lbb1523:
	movl $0, %eax
	jmp .Lbb1525
.Lbb1524:
	movl $2, %eax
.Lbb1525:
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
.Lbb1529:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1541
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $19, %rsi
	jz .Lbb1540
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1534
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1529
.Lbb1534:
	cmpl $0, %r12d
	jz .Lbb1539
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1539
.Lbb1536:
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
	jz .Lbb1538
	cmpl $0, %ebx
	jz .Lbb1539
	jmp .Lbb1536
.Lbb1538:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1542
.Lbb1539:
	movl $1, %eax
	jmp .Lbb1542
.Lbb1540:
	callq bump
	movl $0, %eax
	jmp .Lbb1542
.Lbb1541:
	movl $2, %eax
.Lbb1542:
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
	jnz .Lbb1552
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $19, %rax
	jz .Lbb1551
	cmpl $0, %edx
	jz .Lbb1550
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1550
.Lbb1547:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1549
	cmpl $0, %ebx
	jz .Lbb1550
	jmp .Lbb1547
.Lbb1549:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1553
.Lbb1550:
	movl $1, %eax
	jmp .Lbb1553
.Lbb1551:
	movl $0, %eax
	jmp .Lbb1553
.Lbb1552:
	movl $2, %eax
.Lbb1553:
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
	jnz .Lbb1572
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1560
	movl %r13d, %esi
	jmp .Lbb1564
.Lbb1560:
	cmpq $2, %rax
	jz .Lbb1563
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
	jz .Lbb1567
	movl %r13d, %esi
	jmp .Lbb1564
.Lbb1563:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_27
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb1564:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_28
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1566
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb1564
.Lbb1566:
	movq %r12, %rax
.Lbb1567:
	cmpl $0, %eax
	jz .Lbb1571
	cmpq $2, %rax
	jz .Lbb1570
	movq %rbx, %rcx
	subq $1, %rcx
	cmpq %rcx, %rax
	jz .Lbb1571
.Lbb1570:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_28
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb1571:
	movl $0, %eax
	jmp .Lbb1573
.Lbb1572:
	movq %r12, %rax
.Lbb1573:
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
	jnz .Lbb1580
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb1581
.Lbb1580:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1581:
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
.Lbb1587:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1599
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $2, %rsi
	jz .Lbb1598
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1592
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1587
.Lbb1592:
	cmpl $0, %r12d
	jz .Lbb1597
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1597
.Lbb1594:
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
	jz .Lbb1596
	cmpl $0, %ebx
	jz .Lbb1597
	jmp .Lbb1594
.Lbb1596:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1600
.Lbb1597:
	movl $1, %eax
	jmp .Lbb1600
.Lbb1598:
	callq bump
	movl $0, %eax
	jmp .Lbb1600
.Lbb1599:
	movl $2, %eax
.Lbb1600:
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
	jnz .Lbb1610
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $2, %rax
	jz .Lbb1609
	cmpl $0, %edx
	jz .Lbb1608
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1608
.Lbb1605:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1607
	cmpl $0, %ebx
	jz .Lbb1608
	jmp .Lbb1605
.Lbb1607:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1611
.Lbb1608:
	movl $1, %eax
	jmp .Lbb1611
.Lbb1609:
	movl $0, %eax
	jmp .Lbb1611
.Lbb1610:
	movl $2, %eax
.Lbb1611:
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
.Lbb1615:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1627
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $19, %rsi
	jz .Lbb1626
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1620
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1615
.Lbb1620:
	cmpl $0, %r12d
	jz .Lbb1625
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1625
.Lbb1622:
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
	jz .Lbb1624
	cmpl $0, %ebx
	jz .Lbb1625
	jmp .Lbb1622
.Lbb1624:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1628
.Lbb1625:
	movl $1, %eax
	jmp .Lbb1628
.Lbb1626:
	callq bump
	movl $0, %eax
	jmp .Lbb1628
.Lbb1627:
	movl $2, %eax
.Lbb1628:
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
	jnz .Lbb1638
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $19, %rax
	jz .Lbb1637
	cmpl $0, %edx
	jz .Lbb1636
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1636
.Lbb1633:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1635
	cmpl $0, %ebx
	jz .Lbb1636
	jmp .Lbb1633
.Lbb1635:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1639
.Lbb1636:
	movl $1, %eax
	jmp .Lbb1639
.Lbb1637:
	movl $0, %eax
	jmp .Lbb1639
.Lbb1638:
	movl $2, %eax
.Lbb1639:
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
.Lbb1643:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1655
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $18, %rsi
	jz .Lbb1654
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1648
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1643
.Lbb1648:
	cmpl $0, %r12d
	jz .Lbb1653
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1653
.Lbb1650:
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
	jz .Lbb1652
	cmpl $0, %ebx
	jz .Lbb1653
	jmp .Lbb1650
.Lbb1652:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1656
.Lbb1653:
	movl $1, %eax
	jmp .Lbb1656
.Lbb1654:
	callq bump
	movl $0, %eax
	jmp .Lbb1656
.Lbb1655:
	movl $2, %eax
.Lbb1656:
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
	jnz .Lbb1666
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $18, %rax
	jz .Lbb1665
	cmpl $0, %edx
	jz .Lbb1664
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1664
.Lbb1661:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1663
	cmpl $0, %ebx
	jz .Lbb1664
	jmp .Lbb1661
.Lbb1663:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1667
.Lbb1664:
	movl $1, %eax
	jmp .Lbb1667
.Lbb1665:
	movl $0, %eax
	jmp .Lbb1667
.Lbb1666:
	movl $2, %eax
.Lbb1667:
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
.Lbb1671:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1683
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $21, %rsi
	jz .Lbb1682
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1676
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1671
.Lbb1676:
	cmpl $0, %r12d
	jz .Lbb1681
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1681
.Lbb1678:
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
	jz .Lbb1680
	cmpl $0, %ebx
	jz .Lbb1681
	jmp .Lbb1678
.Lbb1680:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1684
.Lbb1681:
	movl $1, %eax
	jmp .Lbb1684
.Lbb1682:
	callq bump
	movl $0, %eax
	jmp .Lbb1684
.Lbb1683:
	movl $2, %eax
.Lbb1684:
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
	jnz .Lbb1694
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $21, %rax
	jz .Lbb1693
	cmpl $0, %edx
	jz .Lbb1692
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1692
.Lbb1689:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1691
	cmpl $0, %ebx
	jz .Lbb1692
	jmp .Lbb1689
.Lbb1691:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1695
.Lbb1692:
	movl $1, %eax
	jmp .Lbb1695
.Lbb1693:
	movl $0, %eax
	jmp .Lbb1695
.Lbb1694:
	movl $2, %eax
.Lbb1695:
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
	jnz .Lbb1736
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1702
	movl %r13d, %esi
	jmp .Lbb1708
.Lbb1702:
	cmpq $2, %rax
	jz .Lbb1706
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
	jz .Lbb1705
	movl %r13d, %esi
	jmp .Lbb1708
.Lbb1705:
	movq %rax, %r12
	jmp .Lbb1712
.Lbb1706:
	movq %rdi, %r12
	leaq -144(%rbp), %rdi
	callq expected_31
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movq %r12, %rdi
	movl %r13d, %esi
.Lbb1708:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_32
	movl %r13d, %esi
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1711
	movl %esi, %r13d
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb1708
.Lbb1711:
	movl %esi, %r13d
.Lbb1712:
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jz .Lbb1717
	cmpq $2, %rax
	jz .Lbb1716
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
	jnz .Lbb1717
	movq %rax, %r12
	jmp .Lbb1721
.Lbb1716:
	movq %rdi, %r12
	leaq -96(%rbp), %rdi
	callq expected_32
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movq %r12, %rdi
.Lbb1717:
	movl %r13d, %esi
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_33
	movl %r13d, %esi
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1720
	movl %esi, %r13d
	movq %rdi, %r12
	callq bump_err
	movq %r12, %rdi
	jmp .Lbb1717
.Lbb1720:
	movl %esi, %r13d
.Lbb1721:
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1723
	movl %r13d, %esi
	jmp .Lbb1727
.Lbb1723:
	cmpq $2, %rax
	jz .Lbb1726
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
	jz .Lbb1731
	movl %r13d, %esi
	jmp .Lbb1727
.Lbb1726:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_33
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb1727:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_34
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1730
	movq %rdi, %r12
	callq bump_err
	movq %r12, %rdi
	movl %r13d, %esi
	jmp .Lbb1727
.Lbb1730:
	movq %r12, %rax
.Lbb1731:
	cmpl $0, %eax
	jz .Lbb1735
	cmpq $2, %rax
	jz .Lbb1734
	movq %rbx, %rcx
	subq $3, %rcx
	cmpq %rcx, %rax
	jz .Lbb1735
.Lbb1734:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_34
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb1735:
	movl $0, %eax
	jmp .Lbb1737
.Lbb1736:
	movq %r12, %rax
.Lbb1737:
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
	jnz .Lbb1744
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb1745
.Lbb1744:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1745:
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
.Lbb1751:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1763
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $4, %rsi
	jz .Lbb1762
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1756
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1751
.Lbb1756:
	cmpl $0, %r12d
	jz .Lbb1761
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1761
.Lbb1758:
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
	jz .Lbb1760
	cmpl $0, %ebx
	jz .Lbb1761
	jmp .Lbb1758
.Lbb1760:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1764
.Lbb1761:
	movl $1, %eax
	jmp .Lbb1764
.Lbb1762:
	callq bump
	movl $0, %eax
	jmp .Lbb1764
.Lbb1763:
	movl $2, %eax
.Lbb1764:
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
	jnz .Lbb1774
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $4, %rax
	jz .Lbb1773
	cmpl $0, %edx
	jz .Lbb1772
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1772
.Lbb1769:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1771
	cmpl $0, %ebx
	jz .Lbb1772
	jmp .Lbb1769
.Lbb1771:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1775
.Lbb1772:
	movl $1, %eax
	jmp .Lbb1775
.Lbb1773:
	movl $0, %eax
	jmp .Lbb1775
.Lbb1774:
	movl $2, %eax
.Lbb1775:
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
	jnz .Lbb1794
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1782
	movl %r13d, %esi
	jmp .Lbb1786
.Lbb1782:
	cmpq $2, %rax
	jz .Lbb1785
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
	jz .Lbb1789
	movl %r13d, %esi
	jmp .Lbb1786
.Lbb1785:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_37
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb1786:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_0
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1788
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb1786
.Lbb1788:
	movq %r12, %rax
.Lbb1789:
	cmpl $0, %eax
	jz .Lbb1793
	cmpq $2, %rax
	jz .Lbb1792
	movq %rbx, %rcx
	subq $1, %rcx
	cmpq %rcx, %rax
	jz .Lbb1793
.Lbb1792:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_0
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb1793:
	movl $0, %eax
	jmp .Lbb1795
.Lbb1794:
	movq %r12, %rax
.Lbb1795:
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
	jnz .Lbb1804
	movq %rdi, %rbx
	callq parse_38
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1803
	callq exit_group
	movq %rbx, %rax
	jmp .Lbb1805
.Lbb1803:
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
	jmp .Lbb1805
.Lbb1804:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1805:
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
.Lbb1811:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1823
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $1, %rsi
	jz .Lbb1822
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1816
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1811
.Lbb1816:
	cmpl $0, %r12d
	jz .Lbb1821
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1821
.Lbb1818:
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
	jz .Lbb1820
	cmpl $0, %ebx
	jz .Lbb1821
	jmp .Lbb1818
.Lbb1820:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1824
.Lbb1821:
	movl $1, %eax
	jmp .Lbb1824
.Lbb1822:
	callq bump
	movl $0, %eax
	jmp .Lbb1824
.Lbb1823:
	movl $2, %eax
.Lbb1824:
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
	jnz .Lbb1834
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $1, %rax
	jz .Lbb1833
	cmpl $0, %edx
	jz .Lbb1832
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1832
.Lbb1829:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1831
	cmpl $0, %ebx
	jz .Lbb1832
	jmp .Lbb1829
.Lbb1831:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1835
.Lbb1832:
	movl $1, %eax
	jmp .Lbb1835
.Lbb1833:
	movl $0, %eax
	jmp .Lbb1835
.Lbb1834:
	movl $2, %eax
.Lbb1835:
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
.Lbb1839:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1851
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $19, %rsi
	jz .Lbb1850
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1844
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1839
.Lbb1844:
	cmpl $0, %r12d
	jz .Lbb1849
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1849
.Lbb1846:
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
	jz .Lbb1848
	cmpl $0, %ebx
	jz .Lbb1849
	jmp .Lbb1846
.Lbb1848:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1852
.Lbb1849:
	movl $1, %eax
	jmp .Lbb1852
.Lbb1850:
	callq bump
	movl $0, %eax
	jmp .Lbb1852
.Lbb1851:
	movl $2, %eax
.Lbb1852:
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
	jnz .Lbb1862
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $19, %rax
	jz .Lbb1861
	cmpl $0, %edx
	jz .Lbb1860
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1860
.Lbb1857:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1859
	cmpl $0, %ebx
	jz .Lbb1860
	jmp .Lbb1857
.Lbb1859:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1863
.Lbb1860:
	movl $1, %eax
	jmp .Lbb1863
.Lbb1861:
	movl $0, %eax
	jmp .Lbb1863
.Lbb1862:
	movl $2, %eax
.Lbb1863:
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
.Lbb1867:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1879
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $18, %rsi
	jz .Lbb1878
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1872
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1867
.Lbb1872:
	cmpl $0, %r12d
	jz .Lbb1877
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1877
.Lbb1874:
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
	jz .Lbb1876
	cmpl $0, %ebx
	jz .Lbb1877
	jmp .Lbb1874
.Lbb1876:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1880
.Lbb1877:
	movl $1, %eax
	jmp .Lbb1880
.Lbb1878:
	callq bump
	movl $0, %eax
	jmp .Lbb1880
.Lbb1879:
	movl $2, %eax
.Lbb1880:
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
	jnz .Lbb1890
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $18, %rax
	jz .Lbb1889
	cmpl $0, %edx
	jz .Lbb1888
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1888
.Lbb1885:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1887
	cmpl $0, %ebx
	jz .Lbb1888
	jmp .Lbb1885
.Lbb1887:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1891
.Lbb1888:
	movl $1, %eax
	jmp .Lbb1891
.Lbb1889:
	movl $0, %eax
	jmp .Lbb1891
.Lbb1890:
	movl $2, %eax
.Lbb1891:
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
	jnz .Lbb1910
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1898
	movl %r13d, %esi
	jmp .Lbb1902
.Lbb1898:
	cmpq $2, %rax
	jz .Lbb1901
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
	jz .Lbb1905
	movl %r13d, %esi
	jmp .Lbb1902
.Lbb1901:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_42
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb1902:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_39
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1904
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb1902
.Lbb1904:
	movq %r12, %rax
.Lbb1905:
	cmpl $0, %eax
	jz .Lbb1909
	cmpq $2, %rax
	jz .Lbb1908
	movq %rbx, %rcx
	subq $1, %rcx
	cmpq %rcx, %rax
	jz .Lbb1909
.Lbb1908:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_39
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb1909:
	movl $0, %eax
	jmp .Lbb1911
.Lbb1910:
	movq %r12, %rax
.Lbb1911:
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
	jnz .Lbb1951
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1926
	movl %r13d, %esi
	jmp .Lbb1932
.Lbb1926:
	cmpq $2, %rax
	jz .Lbb1930
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
	jz .Lbb1929
	movl %r13d, %esi
	jmp .Lbb1932
.Lbb1929:
	movq %rax, %r12
	jmp .Lbb1936
.Lbb1930:
	movq %rdi, %r12
	leaq -96(%rbp), %rdi
	callq expected_40
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movq %r12, %rdi
	movl %r13d, %esi
.Lbb1932:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_41
	movl %r13d, %esi
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1935
	movl %esi, %r13d
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb1932
.Lbb1935:
	movl %esi, %r13d
.Lbb1936:
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb1938
	movl %r13d, %esi
	jmp .Lbb1942
.Lbb1938:
	cmpq $2, %rax
	jz .Lbb1941
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
	jz .Lbb1946
	movl %r13d, %esi
	jmp .Lbb1942
.Lbb1941:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_41
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb1942:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_44
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb1945
	movq %rdi, %r12
	callq bump_err
	movq %r12, %rdi
	movl %r13d, %esi
	jmp .Lbb1942
.Lbb1945:
	movq %r12, %rax
.Lbb1946:
	cmpl $0, %eax
	jz .Lbb1950
	cmpq $2, %rax
	jz .Lbb1949
	movq %rbx, %rcx
	subq $2, %rcx
	cmpq %rcx, %rax
	jz .Lbb1950
.Lbb1949:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_44
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb1950:
	movl $0, %eax
	jmp .Lbb1952
.Lbb1951:
	movq %r12, %rax
.Lbb1952:
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
	jnz .Lbb1959
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb1960
.Lbb1959:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1960:
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
	jnz .Lbb1969
	movq %rdi, %rbx
	callq parse_61
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb1968
	callq exit_group
	movq %rbx, %rax
	jmp .Lbb1970
.Lbb1968:
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
	jmp .Lbb1970
.Lbb1969:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb1970:
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
.Lbb1976:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb1988
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $8, %rsi
	jz .Lbb1987
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb1981
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb1976
.Lbb1981:
	cmpl $0, %r12d
	jz .Lbb1986
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1986
.Lbb1983:
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
	jz .Lbb1985
	cmpl $0, %ebx
	jz .Lbb1986
	jmp .Lbb1983
.Lbb1985:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb1989
.Lbb1986:
	movl $1, %eax
	jmp .Lbb1989
.Lbb1987:
	callq bump
	movl $0, %eax
	jmp .Lbb1989
.Lbb1988:
	movl $2, %eax
.Lbb1989:
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
	jnz .Lbb1999
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $8, %rax
	jz .Lbb1998
	cmpl $0, %edx
	jz .Lbb1997
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb1997
.Lbb1994:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb1996
	cmpl $0, %ebx
	jz .Lbb1997
	jmp .Lbb1994
.Lbb1996:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2000
.Lbb1997:
	movl $1, %eax
	jmp .Lbb2000
.Lbb1998:
	movl $0, %eax
	jmp .Lbb2000
.Lbb1999:
	movl $2, %eax
.Lbb2000:
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
	jnz .Lbb2020
.Lbb2004:
	movl %esi, %r14d
	movq %rdi, %r13
	callq parse_48
	movq %r13, %rdi
	cmpq $1, %rax
	jz .Lbb2019
	cmpl $0, %eax
	jnz .Lbb2007
	movl %r14d, %esi
	jmp .Lbb2011
.Lbb2007:
	cmpq $2, %rax
	jz .Lbb2018
	cmpq %rax, %rbx
	jnz .Lbb2018
	movq %rdi, %r13
	leaq -48(%rbp), %rdi
	callq expected_48
	movq %r13, %rdi
	movq %rax, %rsi
	movq %rdi, %r13
	callq missing
	movq %r13, %rdi
	movl %r14d, %esi
.Lbb2011:
	movl %esi, %r14d
	movq %rdi, %r13
	callq parse_47
	movq %r13, %rdi
	movq %rax, %r13
	cmpq $1, %r13
	jnz .Lbb2013
	movq %rdi, %r13
	callq bump_err
	movl %r14d, %esi
	movq %r13, %rdi
	jmp .Lbb2011
.Lbb2013:
	cmpl $0, %r13d
	jnz .Lbb2015
	movl %r14d, %esi
	jmp .Lbb2004
.Lbb2015:
	movq %rdi, %r15
	leaq -24(%rbp), %rdi
	callq expected_47
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	cmpq $2, %r13
	jz .Lbb2018
	cmpq %r13, %r12
	jnz .Lbb2018
	movl %r14d, %esi
	jmp .Lbb2004
.Lbb2018:
	callq pop_delim
	movl $0, %eax
	jmp .Lbb2022
.Lbb2019:
	movq %rdi, %r13
	callq bump_err
	movl %r14d, %esi
	movq %r13, %rdi
	jmp .Lbb2004
.Lbb2020:
	movq %rax, %rbx
	callq pop_delim
	movq %rbx, %rax
.Lbb2022:
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
.Lbb2028:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb2040
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $13, %rsi
	jz .Lbb2039
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2033
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb2028
.Lbb2033:
	cmpl $0, %r12d
	jz .Lbb2038
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2038
.Lbb2035:
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
	jz .Lbb2037
	cmpl $0, %ebx
	jz .Lbb2038
	jmp .Lbb2035
.Lbb2037:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2041
.Lbb2038:
	movl $1, %eax
	jmp .Lbb2041
.Lbb2039:
	callq bump
	movl $0, %eax
	jmp .Lbb2041
.Lbb2040:
	movl $2, %eax
.Lbb2041:
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
	jnz .Lbb2051
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $13, %rax
	jz .Lbb2050
	cmpl $0, %edx
	jz .Lbb2049
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2049
.Lbb2046:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb2048
	cmpl $0, %ebx
	jz .Lbb2049
	jmp .Lbb2046
.Lbb2048:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2052
.Lbb2049:
	movl $1, %eax
	jmp .Lbb2052
.Lbb2050:
	movl $0, %eax
	jmp .Lbb2052
.Lbb2051:
	movl $2, %eax
.Lbb2052:
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
.Lbb2056:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb2068
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $14, %rsi
	jz .Lbb2067
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2061
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb2056
.Lbb2061:
	cmpl $0, %r12d
	jz .Lbb2066
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2066
.Lbb2063:
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
	jz .Lbb2065
	cmpl $0, %ebx
	jz .Lbb2066
	jmp .Lbb2063
.Lbb2065:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2069
.Lbb2066:
	movl $1, %eax
	jmp .Lbb2069
.Lbb2067:
	callq bump
	movl $0, %eax
	jmp .Lbb2069
.Lbb2068:
	movl $2, %eax
.Lbb2069:
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
	jnz .Lbb2079
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $14, %rax
	jz .Lbb2078
	cmpl $0, %edx
	jz .Lbb2077
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2077
.Lbb2074:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb2076
	cmpl $0, %ebx
	jz .Lbb2077
	jmp .Lbb2074
.Lbb2076:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2080
.Lbb2077:
	movl $1, %eax
	jmp .Lbb2080
.Lbb2078:
	movl $0, %eax
	jmp .Lbb2080
.Lbb2079:
	movl $2, %eax
.Lbb2080:
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
	jnz .Lbb2097
	movl %esi, %r12d
	movl $51, %esi
	movq %rdi, %rbx
	callq push_delim
	movl %r12d, %esi
	movq %rbx, %rdi
.Lbb2085:
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_49
	movq %rbx, %rdi
	cmpq $1, %rax
	jnz .Lbb2087
	movq %rdi, %rbx
	callq bump_err
	movl %r12d, %esi
	movq %rbx, %rdi
	jmp .Lbb2085
.Lbb2087:
	movl %r12d, %esi
	movq 64(%rdi), %rcx
	movq %rcx, %rbx
	addq $2, %rbx
	cmpq %rax, %rbx
	jnz .Lbb2092
	movl %esi, %r12d
.Lbb2090:
	movq %rdi, %r13
	leaq -24(%rbp), %rdi
	callq expected_49
	movq %r13, %rdi
	movq %rax, %rsi
	movq %rdi, %r13
	callq missing
	movq %r13, %rdi
	movl %r12d, %esi
.Lbb2092:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_51
	movq %r12, %rdi
	cmpq $1, %rax
	jnz .Lbb2094
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb2092
.Lbb2094:
	movl %r13d, %r12d
	cmpq %rax, %rbx
	jz .Lbb2090
	callq pop_delim
	movl $0, %eax
.Lbb2097:
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
	jnz .Lbb2104
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb2105
.Lbb2104:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb2105:
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
.Lbb2111:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb2123
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $7, %rsi
	jz .Lbb2122
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2116
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb2111
.Lbb2116:
	cmpl $0, %r12d
	jz .Lbb2121
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2121
.Lbb2118:
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
	jz .Lbb2120
	cmpl $0, %ebx
	jz .Lbb2121
	jmp .Lbb2118
.Lbb2120:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2124
.Lbb2121:
	movl $1, %eax
	jmp .Lbb2124
.Lbb2122:
	callq bump
	movl $0, %eax
	jmp .Lbb2124
.Lbb2123:
	movl $2, %eax
.Lbb2124:
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
	jnz .Lbb2134
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $7, %rax
	jz .Lbb2133
	cmpl $0, %edx
	jz .Lbb2132
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2132
.Lbb2129:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb2131
	cmpl $0, %ebx
	jz .Lbb2132
	jmp .Lbb2129
.Lbb2131:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2135
.Lbb2132:
	movl $1, %eax
	jmp .Lbb2135
.Lbb2133:
	movl $0, %eax
	jmp .Lbb2135
.Lbb2134:
	movl $2, %eax
.Lbb2135:
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
	jnz .Lbb2154
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb2142
	movl %r13d, %esi
	jmp .Lbb2146
.Lbb2142:
	cmpq $2, %rax
	jz .Lbb2145
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
	jz .Lbb2149
	movl %r13d, %esi
	jmp .Lbb2146
.Lbb2145:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_54
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb2146:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_53
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb2148
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb2146
.Lbb2148:
	movq %r12, %rax
.Lbb2149:
	cmpl $0, %eax
	jz .Lbb2153
	cmpq $2, %rax
	jz .Lbb2152
	movq %rbx, %rcx
	subq $1, %rcx
	cmpq %rcx, %rax
	jz .Lbb2153
.Lbb2152:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_53
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb2153:
	movl $0, %eax
	jmp .Lbb2155
.Lbb2154:
	movq %r12, %rax
.Lbb2155:
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
	jnz .Lbb2182
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb2170
	movl %r13d, %esi
	jmp .Lbb2174
.Lbb2170:
	cmpq $2, %rax
	jz .Lbb2173
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
	jz .Lbb2177
	movl %r13d, %esi
	jmp .Lbb2174
.Lbb2173:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_2
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb2174:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_56
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb2176
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb2174
.Lbb2176:
	movq %r12, %rax
.Lbb2177:
	cmpl $0, %eax
	jz .Lbb2181
	cmpq $2, %rax
	jz .Lbb2180
	movq %rbx, %rcx
	subq $1, %rcx
	cmpq %rcx, %rax
	jz .Lbb2181
.Lbb2180:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_56
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb2181:
	movl $0, %eax
	jmp .Lbb2183
.Lbb2182:
	movq %r12, %rax
.Lbb2183:
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
	jnz .Lbb2190
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb2191
.Lbb2190:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb2191:
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
.Lbb2197:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb2209
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $22, %rsi
	jz .Lbb2208
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2202
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb2197
.Lbb2202:
	cmpl $0, %r12d
	jz .Lbb2207
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2207
.Lbb2204:
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
	jz .Lbb2206
	cmpl $0, %ebx
	jz .Lbb2207
	jmp .Lbb2204
.Lbb2206:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2210
.Lbb2207:
	movl $1, %eax
	jmp .Lbb2210
.Lbb2208:
	callq bump
	movl $0, %eax
	jmp .Lbb2210
.Lbb2209:
	movl $2, %eax
.Lbb2210:
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
	jnz .Lbb2220
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $22, %rax
	jz .Lbb2219
	cmpl $0, %edx
	jz .Lbb2218
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2218
.Lbb2215:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb2217
	cmpl $0, %ebx
	jz .Lbb2218
	jmp .Lbb2215
.Lbb2217:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2221
.Lbb2218:
	movl $1, %eax
	jmp .Lbb2221
.Lbb2219:
	movl $0, %eax
	jmp .Lbb2221
.Lbb2220:
	movl $2, %eax
.Lbb2221:
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
.Lbb2225:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb2237
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $21, %rsi
	jz .Lbb2236
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2230
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb2225
.Lbb2230:
	cmpl $0, %r12d
	jz .Lbb2235
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2235
.Lbb2232:
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
	jz .Lbb2234
	cmpl $0, %ebx
	jz .Lbb2235
	jmp .Lbb2232
.Lbb2234:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2238
.Lbb2235:
	movl $1, %eax
	jmp .Lbb2238
.Lbb2236:
	callq bump
	movl $0, %eax
	jmp .Lbb2238
.Lbb2237:
	movl $2, %eax
.Lbb2238:
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
	jnz .Lbb2248
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $21, %rax
	jz .Lbb2247
	cmpl $0, %edx
	jz .Lbb2246
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2246
.Lbb2243:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb2245
	cmpl $0, %ebx
	jz .Lbb2246
	jmp .Lbb2243
.Lbb2245:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2249
.Lbb2246:
	movl $1, %eax
	jmp .Lbb2249
.Lbb2247:
	movl $0, %eax
	jmp .Lbb2249
.Lbb2248:
	movl $2, %eax
.Lbb2249:
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
	jnz .Lbb2268
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb2256
	movl %r13d, %esi
	jmp .Lbb2260
.Lbb2256:
	cmpq $2, %rax
	jz .Lbb2259
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
	jz .Lbb2263
	movl %r13d, %esi
	jmp .Lbb2260
.Lbb2259:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_59
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb2260:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_60
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb2262
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb2260
.Lbb2262:
	movq %r12, %rax
.Lbb2263:
	cmpl $0, %eax
	jz .Lbb2267
	cmpq $2, %rax
	jz .Lbb2266
	movq %rbx, %rcx
	subq $1, %rcx
	cmpq %rcx, %rax
	jz .Lbb2267
.Lbb2266:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_60
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb2267:
	movl $0, %eax
	jmp .Lbb2269
.Lbb2268:
	movq %r12, %rax
.Lbb2269:
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
	jnz .Lbb2278
	movq %rdi, %rbx
	callq parse_61
	movq %rbx, %rdi
	movq %rax, %rbx
	cmpl $0, %ebx
	jnz .Lbb2277
	callq exit_group
	movq %rbx, %rax
	jmp .Lbb2279
.Lbb2277:
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
	jmp .Lbb2279
.Lbb2278:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb2279:
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
.Lbb2285:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb2297
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $3, %rsi
	jz .Lbb2296
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2290
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb2285
.Lbb2290:
	cmpl $0, %r12d
	jz .Lbb2295
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2295
.Lbb2292:
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
	jz .Lbb2294
	cmpl $0, %ebx
	jz .Lbb2295
	jmp .Lbb2292
.Lbb2294:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2298
.Lbb2295:
	movl $1, %eax
	jmp .Lbb2298
.Lbb2296:
	callq bump
	movl $0, %eax
	jmp .Lbb2298
.Lbb2297:
	movl $2, %eax
.Lbb2298:
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
	jnz .Lbb2308
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $3, %rax
	jz .Lbb2307
	cmpl $0, %edx
	jz .Lbb2306
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2306
.Lbb2303:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb2305
	cmpl $0, %ebx
	jz .Lbb2306
	jmp .Lbb2303
.Lbb2305:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2309
.Lbb2306:
	movl $1, %eax
	jmp .Lbb2309
.Lbb2307:
	movl $0, %eax
	jmp .Lbb2309
.Lbb2308:
	movl $2, %eax
.Lbb2309:
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
	jnz .Lbb2328
	movq %rdi, %r14
	callq pop_delim
	movq %r14, %rdi
	movq %r12, %rax
	cmpl $0, %eax
	jnz .Lbb2316
	movl %r13d, %esi
	jmp .Lbb2320
.Lbb2316:
	cmpq $2, %rax
	jz .Lbb2319
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
	jz .Lbb2323
	movl %r13d, %esi
	jmp .Lbb2320
.Lbb2319:
	movq %rdi, %r12
	leaq -48(%rbp), %rdi
	callq expected_63
	movq %r12, %rdi
	movq %rax, %rsi
	movq %rdi, %r12
	callq missing
	movl %r13d, %esi
	movq %r12, %rdi
.Lbb2320:
	movl %esi, %r13d
	movq %rdi, %r12
	callq parse_47
	movq %r12, %rdi
	movq %rax, %r12
	cmpq $1, %r12
	jnz .Lbb2322
	movq %rdi, %r12
	callq bump_err
	movl %r13d, %esi
	movq %r12, %rdi
	jmp .Lbb2320
.Lbb2322:
	movq %r12, %rax
.Lbb2323:
	cmpl $0, %eax
	jz .Lbb2327
	cmpq $2, %rax
	jz .Lbb2326
	movq %rbx, %rcx
	subq $1, %rcx
	cmpq %rcx, %rax
	jz .Lbb2327
.Lbb2326:
	movq %rdi, %rbx
	leaq -24(%rbp), %rdi
	callq expected_47
	movq %rbx, %rdi
	movq %rax, %rsi
	callq missing
.Lbb2327:
	movl $0, %eax
	jmp .Lbb2329
.Lbb2328:
	movq %r12, %rax
.Lbb2329:
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
	jnz .Lbb2336
	callq exit_group
	movq %rbx, %rax
	movq %rax, %rbx
	jmp .Lbb2337
.Lbb2336:
	addq $24, %rdi
	movl $32, %esi
	callq pop
	movq %rbx, %rax
.Lbb2337:
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
	jz .Lbb2346
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_36
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2346
	movl %esi, %r12d
	movq %rdi, %rbx
	callq parse_46
	movl %r12d, %esi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2346
	callq parse_65
.Lbb2346:
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
	jz .Lbb2351
	movl %edx, %r13d
	movq %rsi, %r12
	movq %rdi, %rbx
	callq peak_36
	movl %r13d, %edx
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2351
	movl %edx, %r13d
	movq %rsi, %r12
	movq %rdi, %rbx
	callq peak_46
	movl %r13d, %edx
	movq %r12, %rsi
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2351
	callq peak_65
.Lbb2351:
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
.Lbb2355:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb2367
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $20, %rsi
	jz .Lbb2366
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2360
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb2355
.Lbb2360:
	cmpl $0, %r12d
	jz .Lbb2365
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2365
.Lbb2362:
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
	jz .Lbb2364
	cmpl $0, %ebx
	jz .Lbb2365
	jmp .Lbb2362
.Lbb2364:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2368
.Lbb2365:
	movl $1, %eax
	jmp .Lbb2368
.Lbb2366:
	callq bump
	movl $0, %eax
	jmp .Lbb2368
.Lbb2367:
	movl $2, %eax
.Lbb2368:
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
	jnz .Lbb2378
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $20, %rax
	jz .Lbb2377
	cmpl $0, %edx
	jz .Lbb2376
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2376
.Lbb2373:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb2375
	cmpl $0, %ebx
	jz .Lbb2376
	jmp .Lbb2373
.Lbb2375:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2379
.Lbb2376:
	movl $1, %eax
	jmp .Lbb2379
.Lbb2377:
	movl $0, %eax
	jmp .Lbb2379
.Lbb2378:
	movl $2, %eax
.Lbb2379:
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
	jnz .Lbb2399
.Lbb2383:
	movl %esi, %r14d
	movq %rdi, %r13
	callq parse_67
	movq %r13, %rdi
	cmpq $1, %rax
	jz .Lbb2398
	cmpl $0, %eax
	jnz .Lbb2386
	movl %r14d, %esi
	jmp .Lbb2390
.Lbb2386:
	cmpq $2, %rax
	jz .Lbb2397
	cmpq %rax, %rbx
	jnz .Lbb2397
	movq %rdi, %r13
	leaq -48(%rbp), %rdi
	callq expected_67
	movq %r13, %rdi
	movq %rax, %rsi
	movq %rdi, %r13
	callq missing
	movq %r13, %rdi
	movl %r14d, %esi
.Lbb2390:
	movl %esi, %r14d
	movq %rdi, %r13
	callq parse_66
	movq %r13, %rdi
	movq %rax, %r13
	cmpq $1, %r13
	jnz .Lbb2392
	movq %rdi, %r13
	callq bump_err
	movl %r14d, %esi
	movq %r13, %rdi
	jmp .Lbb2390
.Lbb2392:
	cmpl $0, %r13d
	jnz .Lbb2394
	movl %r14d, %esi
	jmp .Lbb2383
.Lbb2394:
	movq %rdi, %r15
	leaq -24(%rbp), %rdi
	callq expected_66
	movq %r15, %rdi
	movq %rax, %rsi
	movq %rdi, %r15
	callq missing
	movq %r15, %rdi
	cmpq $2, %r13
	jz .Lbb2397
	cmpq %r13, %r12
	jnz .Lbb2397
	movl %r14d, %esi
	jmp .Lbb2383
.Lbb2397:
	callq pop_delim
	movl $0, %eax
	jmp .Lbb2401
.Lbb2398:
	movq %rdi, %r13
	callq bump_err
	movl %r14d, %esi
	movq %r13, %rdi
	jmp .Lbb2383
.Lbb2399:
	movq %rax, %rbx
	callq pop_delim
	movq %rbx, %rax
.Lbb2401:
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
.Lbb2407:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb2419
	movq %rdi, %rbx
	callq current_kind
	movq %rbx, %rdi
	movq %rax, %rsi
	cmpq $5, %rsi
	jz .Lbb2418
	movq %rdi, %rbx
	addq $80, %rdi
	callq contains_long
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2412
	movq %rdi, %rbx
	callq bump
	movl %r12d, %esi
	movq %rbx, %rdi
	movl %esi, %r12d
	jmp .Lbb2407
.Lbb2412:
	cmpl $0, %r12d
	jz .Lbb2417
	movq %rdi, %r12
	addq $56, %r12
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2417
.Lbb2414:
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
	jz .Lbb2416
	cmpl $0, %ebx
	jz .Lbb2417
	jmp .Lbb2414
.Lbb2416:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2420
.Lbb2417:
	movl $1, %eax
	jmp .Lbb2420
.Lbb2418:
	callq bump
	movl $0, %eax
	jmp .Lbb2420
.Lbb2419:
	movl $2, %eax
.Lbb2420:
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
	jnz .Lbb2430
	movq %rdi, %rbx
	callq kind_at_offset
	movl %r12d, %edx
	movq %rbx, %rdi
	cmpq $5, %rax
	jz .Lbb2429
	cmpl $0, %edx
	jz .Lbb2428
	movq 64(%rdi), %rbx
	cmpl $0, %ebx
	jz .Lbb2428
.Lbb2425:
	subq $1, %rbx
	movq %rbx, %rcx
	movl $0, %edx
	movl $0, %esi
	movq %rdi, %r12
	callq peak_by_id
	movq %r12, %rdi
	cmpl $0, %eax
	jz .Lbb2427
	cmpl $0, %ebx
	jz .Lbb2428
	jmp .Lbb2425
.Lbb2427:
	movq %rbx, %rax
	addq $3, %rax
	jmp .Lbb2431
.Lbb2428:
	movl $1, %eax
	jmp .Lbb2431
.Lbb2429:
	movl $0, %eax
	jmp .Lbb2431
.Lbb2430:
	movl $2, %eax
.Lbb2431:
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
	jnz .Lbb2438
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
	jnz .Lbb2437
	movq %rbx, %rax
	jmp .Lbb2438
.Lbb2437:
	movl $5, %esi
	callq unskip
	movq %rbx, %rax
.Lbb2438:
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
.Lbb2444:
	movl $1, %esi
	movq %rdi, %rbx
	callq parse_70
	movq %rbx, %rdi
	cmpl $0, %eax
	jz .Lbb2447
	cmpq $2, %rax
	jz .Lbb2447
	movq %rdi, %rbx
	callq bump_err
	movq %rbx, %rdi
	jmp .Lbb2444
.Lbb2447:
	movq %rdi, %rbx
	callq is_eof
	movq %rbx, %rdi
	cmpl $0, %eax
	jnz .Lbb2449
	movq %rdi, %rbx
	callq bump_err
	movq %rbx, %rdi
	jmp .Lbb2447
.Lbb2449:
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
	jz .Lbb2492
	cmpl $1, %edi
	leaq named_group_name(%rip), %rax
	jz .Lbb2491
	cmpl $2, %edi
	leaq _atom_group_name(%rip), %rax
	jz .Lbb2490
	cmpl $3, %edi
	leaq call_name_group_name(%rip), %rax
	jz .Lbb2489
	cmpl $4, %edi
	leaq call_group_name(%rip), %rax
	jz .Lbb2488
	cmpl $5, %edi
	leaq member_call_group_name(%rip), %rax
	jz .Lbb2487
	cmpl $6, %edi
	leaq seq_group_name(%rip), %rax
	jz .Lbb2486
	cmpl $7, %edi
	leaq choice_group_name(%rip), %rax
	jz .Lbb2485
	cmpl $8, %edi
	leaq kw_def_group_name(%rip), %rax
	jz .Lbb2484
	cmpl $9, %edi
	leaq token_def_group_name(%rip), %rax
	jz .Lbb2483
	cmpl $10, %edi
	leaq fold_stmt_group_name(%rip), %rax
	jz .Lbb2482
	cmpl $11, %edi
	leaq parser_def_group_name(%rip), %rax
	jz .Lbb2481
	cmpl $12, %edi
	leaq _query_group_name(%rip), %rax
	jz .Lbb2480
	cmpl $13, %edi
	leaq child_query_group_name(%rip), %rax
	jz .Lbb2479
	cmpl $14, %edi
	leaq group_query_group_name(%rip), %rax
	jz .Lbb2478
	cmpl $15, %edi
	leaq labelled_query_group_name(%rip), %rax
	jz .Lbb2477
	cmpl $16, %edi
	leaq highlight_def_group_name(%rip), %rax
	jz .Lbb2476
	cmpl $17, %edi
	leaq _stmt_group_name(%rip), %rax
	jz .Lbb2475
	cmpl $18, %edi
	leaq _root_group_name(%rip), %rax
	jz .Lbb2474
	cmpl $19, %edi
	leaq root_group_name(%rip), %rax
	jz .Lbb2473
	leaq err_group_name(%rip), %rax
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb2493
.Lbb2473:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb2493
.Lbb2474:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb2493
.Lbb2475:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb2493
.Lbb2476:
	movq %rax, %rdx
	movl $13, %eax
	jmp .Lbb2493
.Lbb2477:
	movq %rax, %rdx
	movl $14, %eax
	jmp .Lbb2493
.Lbb2478:
	movq %rax, %rdx
	movl $11, %eax
	jmp .Lbb2493
.Lbb2479:
	movq %rax, %rdx
	movl $11, %eax
	jmp .Lbb2493
.Lbb2480:
	movq %rax, %rdx
	movl $6, %eax
	jmp .Lbb2493
.Lbb2481:
	movq %rax, %rdx
	movl $10, %eax
	jmp .Lbb2493
.Lbb2482:
	movq %rax, %rdx
	movl $9, %eax
	jmp .Lbb2493
.Lbb2483:
	movq %rax, %rdx
	movl $9, %eax
	jmp .Lbb2493
.Lbb2484:
	movq %rax, %rdx
	movl $6, %eax
	jmp .Lbb2493
.Lbb2485:
	movq %rax, %rdx
	movl $6, %eax
	jmp .Lbb2493
.Lbb2486:
	movq %rax, %rdx
	movl $3, %eax
	jmp .Lbb2493
.Lbb2487:
	movq %rax, %rdx
	movl $11, %eax
	jmp .Lbb2493
.Lbb2488:
	movq %rax, %rdx
	movl $4, %eax
	jmp .Lbb2493
.Lbb2489:
	movq %rax, %rdx
	movl $9, %eax
	jmp .Lbb2493
.Lbb2490:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb2493
.Lbb2491:
	movq %rax, %rdx
	movl $5, %eax
	jmp .Lbb2493
.Lbb2492:
	movq %rax, %rdx
	movl $5, %eax
.Lbb2493:
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
