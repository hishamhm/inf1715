.data
   .comm glob, 4
   .comm hlob, 4
   .comm jlob, 4
.text
id:
   .string "bla"
zz:
   .string "blo"
.globl f
.type f, @function
f:
   pushl %ebp
   movl %esp, %ebp
   subl $20, %esp /* 8 locais, 3 args (IrOpLocal "a",8)(IrOpLocal "b",12)(IrOpLocal "c",16)(IrOpLocal "blabla",-4)(IrOpLocal "vovo",-8)(IrOpLocal "x",-12)(IrOpLocal "y",-16)(IrOpLocal "zoo",-20) **/
   push %ebp
   push %esi
   push %edi
   /* 1 */
   movl $9, %eax
   /* 2 */
   movl $0, %ebx
   /* 3 */
   movl $0, %ecx
   /* 4 */
   movl $12, %edx
   /* 5 */
   movl $15, %edi
   /* 6 */
   movl %edi, -8(%ebp) /* spill de IrOpLocal "vovo" de volta para a memoria */
   movl $16, %edi
   /* 7 */
   movl %eax, -12(%ebp) /* spill de IrOpLocal "x" de volta para a memoria */
   movl -8(%ebp), %eax /* carrega IrOpLocal "vovo" em eax */
/* weee, score 0! */
   movl %eax, %eax
   popl %edi
   popl %esi
   popl %ebx
   leave
   ret

.globl bytops
.type bytops, @function
bytops:
   pushl %ebp
   movl %esp, %ebp
   subl $16, %esp /* 4 locais, 0 args (IrOpLocal "i",-4)(IrOpLocal "v",-8)(IrOpLocal "x",-12)(IrOpLocal "y",-16) **/
   push %ebp
   push %esi
   push %edi
   /* 1 */
   movl $0, %eax
   /* 2 */
   movl %eax, -4(%ebp) /* spill de IrOpLocal "i" de volta para a memoria */
   pushl $10
   call malloc
   addl $4, %esp
   movl %eax, %ebx
   /* 3 */
   movl -16(%ebp), %ecx /* carrega IrOpLocal "y" em ecx */
   movl %ecx, %esi
   addl %ebx, %esi
   movsbl (%esi), %eax
   /* 4 */
   movl -12(%ebp), %edx /* carrega IrOpLocal "x" em edx */
   movl %edx, %esi
   addl %ebx, %esi
   movb %eax, (%esi)
   /* 5 */
   popl %edi
   popl %esi
   popl %ebx
   leave
   ret

.globl g
.type g, @function
g:
   pushl %ebp
   movl %esp, %ebp
   subl $52, %esp /* 13 locais, 0 args (IrOpLocal "g",-4)(IrOpLocal "i",-8)(IrOpLocal "id",-12)(IrOpLocal "v",-16)(IrOpLocal "x",-20)(IrOpLocal "y",-24)(IrOpLocal "z",-28)(IrOpTemp "$t0",-32)(IrOpTemp "$t1",-36)(IrOpTemp "$t2",-40)(IrOpTemp "$t3",-44)(IrOpTemp "$t4",-48)(IrOpTemp "$t9",-52) **/
   push %ebp
   push %esi
   push %edi
   /* 1 */
   movl $0, %eax
   /* 2 */
   movl $0, %ebx
   /* 1 */
.L1:
   /* 2 */
   movl -20(%ebp), %eax /* carrega IrOpLocal "x" em eax */
   cmpl $10, %eax
   jl .Lg_2_1
   movl $0, %ebx
   jmp .Lg_2_2
.Lg_2_1:
   movl $1, %ebx
.Lg_2_2:
   /* 3 */
   /* crazy spill time! */
   movl %eax, -20(%ebp) /* spill de IrOpLocal "x" de volta para a memoria */
   movl %ebx, -52(%ebp) /* spill de IrOpTemp "$t9" de volta para a memoria */
   /* done */
   cmpl $0, %ebx
   je .L2
   /* 1 */
   movl $200, %eax
   /* 2 */
   pushl $123
   /* 3 */
   movl %eax, -48(%ebp) /* spill de IrOpTemp "$t4" de volta para a memoria */
   call m
   addl $4, %esp
   /* 4 */
   movl %eax, %ebx /* carrega IrOpTemp "$ret" em ebx */
   movl %ebx, %ecx
   /* 5 */
   movl -20(%ebp), %edx /* carrega IrOpLocal "x" em edx */
   movl %eax, %edi
   addl %edx, %edi
   /* 6 */
/* weee, score 0! */
   movl %edi, %edx
   addl %edx, %edx
   /* 7 */
/* weee, score 0! */
   movl %edx, %eax
   addl $3, %eax
   /* 8 */
   movl %edi, -44(%ebp) /* spill de IrOpTemp "$t3" de volta para a memoria */
   movl %eax, %edi
   addl $9, %edi
   /* 9 */
   movl %edi, -32(%ebp) /* spill de IrOpTemp "$t0" de volta para a memoria */
   movl $0, %edi
   /* 10 */
   movl %eax, -36(%ebp) /* spill de IrOpTemp "$t1" de volta para a memoria */
   movl %ecx, -28(%ebp) /* spill de IrOpLocal "z" de volta para a memoria */
   movl %edx, -40(%ebp) /* spill de IrOpTemp "$t2" de volta para a memoria */
/* weee, score 0! */
   pushl $10
   call malloc
   addl $4, %esp
   movl %eax, %edi
   /* 11 */
   movl -24(%ebp), %edx /* carrega IrOpLocal "y" em edx */
/* weee, score 0! */
/* weee, score 0! */
   movl %edx, %esi
   addl %edi, %esi
   movsbl (%esi), %edx
   /* 12 */
   movl -20(%ebp), %edi /* carrega IrOpLocal "x" em edi */
/* weee, score 0! */
   movl %edi, %esi
   addl %edi, %esi
   movb %edx, (%esi)
   /* 13 */
   movl -32(%ebp), %ecx /* carrega IrOpTemp "$t0" em ecx */
/* weee, score 0! */
/* weee, score 0! */
   movl %ecx, %ecx
   /* 14 */
   movl $9, %ecx
   /* 15 */
   movl -4(%ebp), %ecx /* carrega IrOpLocal "g" em ecx */
/* weee, score 0! */
   movl %ecx, %ecx
   /* 16 */
   movl -24(%ebp), %eax /* carrega IrOpLocal "y" em eax */
/* weee, score 0! */
   movl %eax, %eax
   addl $1, %eax
   /* 17 */
   /* crazy spill time! */
   movl %eax, -24(%ebp) /* spill de IrOpLocal "y" de volta para a memoria */
   movl %ebx, %eax /* spill de IrOpTemp "$ret" de volta para a memoria */
   movl %ecx, -4(%ebp) /* spill de IrOpLocal "g" de volta para a memoria */
   movl %ecx, -20(%ebp) /* spill de IrOpLocal "x" de volta para a memoria */
   movl %edx, -8(%ebp) /* spill de IrOpLocal "i" de volta para a memoria */
   movl %edi, -16(%ebp) /* spill de IrOpLocal "v" de volta para a memoria */
   /* done */
   jmp .L1
   /* 1 */
.L2:
   /* 2 */
   movl -12(%ebp), %eax /* carrega IrOpLocal "id" em eax */
   movl %eax, %eax
   /* 3 */
   popl %edi
   popl %esi
   popl %ebx
   leave
   ret

.globl h
.type h, @function
h:
   pushl %ebp
   movl %esp, %ebp
   subl $16, %esp /* 4 locais, 0 args (IrOpLocal "i",-4)(IrOpLocal "v",-8)(IrOpLocal "x",-12)(IrOpLocal "y",-16) **/
   push %ebp
   push %esi
   push %edi
   /* 1 */
   movl $0, %eax
   /* 2 */
   movl $0, %ebx
   /* 3 */
   /* 1 */
   movl $0, %eax
   /* 2 */
   movl %eax, -4(%ebp) /* spill de IrOpLocal "i" de volta para a memoria */
   movl $10, %esi
   imul $4, %esi
   pushl %esi
   call malloc
   addl $4, %esp
   movl %eax, %ebx
   /* 3 */
   movl -16(%ebp), %ecx /* carrega IrOpLocal "y" em ecx */
   movl %ecx, %esi
   imul $4, %esi
   addl %ebx, %esi
   movl (%esi), %eax
   /* 4 */
   movl -12(%ebp), %edx /* carrega IrOpLocal "x" em edx */
   movl %edx, %esi
   imul $4, %esi
   addl %ebx, %esi
   movl %eax, (%esi)
   /* 5 */
   movl -12(%ebp), %edx /* carrega IrOpLocal "x" em edx */
   pushl %edx
   /* 6 */
   movl %eax, -4(%ebp) /* spill de IrOpLocal "i" de volta para a memoria */
   movl %ecx, -16(%ebp) /* spill de IrOpLocal "y" de volta para a memoria */
   movl %edx, -12(%ebp) /* spill de IrOpLocal "x" de volta para a memoria */
   call f
   addl $4, %esp
   /* 1 */
.L3:
   /* 2 */
   popl %edi
   popl %esi
   popl %ebx
   leave
   ret

.globl i
.type i, @function
i:
   pushl %ebp
   movl %esp, %ebp
   subl $12, %esp /* 3 locais, 0 args (IrOpLocal "x",-4)(IrOpLocal "y",-8)(IrOpTemp "$t5",-12) **/
   push %ebp
   push %esi
   push %edi
   /* 1 */
   movl $0, %eax
   /* 2 */
   movl $0, %ebx
   /* 3 */
   movl %eax, %ecx
   addl %ebx, %ecx
   /* 4 */
   movl %ecx, %eax
   /* 5 */
   movl %eax, -4(%ebp) /* spill de IrOpLocal "x" de volta para a memoria */
   movl %ecx, -12(%ebp) /* spill de IrOpTemp "$t5" de volta para a memoria */
   call g
   addl $0, %esp
   /* 6 */
   movl %eax, %edx /* carrega IrOpTemp "$ret" em edx */
   pushl %edx
   /* 7 */
   movl %eax, -4(%ebp) /* spill de IrOpLocal "x" de volta para a memoria */
   movl %ecx, -12(%ebp) /* spill de IrOpTemp "$t5" de volta para a memoria */
   movl %edx, %eax /* spill de IrOpTemp "$ret" de volta para a memoria */
   call h
   addl $4, %esp
   /* 8 */
   movl %eax, -4(%ebp) /* spill de IrOpLocal "x" de volta para a memoria */
   movl $12, %eax
   popl %edi
   popl %esi
   popl %ebx
   leave
   ret

.globl j
.type j, @function
j:
   pushl %ebp
   movl %esp, %ebp
   subl $12, %esp /* 3 locais, 0 args (IrOpLocal "a",-4)(IrOpLocal "b",-8)(IrOpLocal "c",-12) **/
   push %ebp
   push %esi
   push %edi
   /* 1 */
   movl $0, %eax
   /* 2 */
   movl $0, %ebx
   /* 3 */
   movl $0, %ecx
   /* 4 */
   cmpl %ecx, %ebx
   je .Lj_4_1
   movl $0, %eax
   jmp .Lj_4_2
.Lj_4_1:
   movl $1, %eax
.Lj_4_2:
   /* 5 */
   cmpl %ecx, %ebx
   jne .Lj_5_1
   movl $0, %eax
   jmp .Lj_5_2
.Lj_5_1:
   movl $1, %eax
.Lj_5_2:
   /* 6 */
   cmpl %ecx, %ebx
   jg .Lj_6_1
   movl $0, %eax
   jmp .Lj_6_2
.Lj_6_1:
   movl $1, %eax
.Lj_6_2:
   /* 7 */
   cmpl %ecx, %ebx
   jl .Lj_7_1
   movl $0, %eax
   jmp .Lj_7_2
.Lj_7_1:
   movl $1, %eax
.Lj_7_2:
   /* 8 */
   cmpl %ecx, %ebx
   jge .Lj_8_1
   movl $0, %eax
   jmp .Lj_8_2
.Lj_8_1:
   movl $1, %eax
.Lj_8_2:
   /* 9 */
   cmpl %ecx, %ebx
   jle .Lj_9_1
   movl $0, %eax
   jmp .Lj_9_2
.Lj_9_1:
   movl $1, %eax
.Lj_9_2:
   /* 10 */
   movl %ebx, %ecx
   imul %eax, %ecx
   /* 11 */
   movl %ebx, %eax
   addl %ecx, %eax
   /* 12 */
   movl %ebx, %eax
   subl %ecx, %eax
   /* 13 */
   movl %eax, -4(%ebp) /* spill de IrOpLocal "a" de volta para a memoria */
   movl %ebx, %eax
   cltd
   idiv %ecx
   mov %eax, %eax
   /* 14 */
   movl %ebx, %eax
   negl %eax
   /* 15 */
   movl %eax, -4(%ebp) /* spill de IrOpLocal "a" de volta para a memoria */
   movl %ecx, -12(%ebp) /* spill de IrOpLocal "c" de volta para a memoria */
   call g
   addl $0, %esp
   /* 16 */
   movl %eax, -4(%ebp) /* spill de IrOpLocal "a" de volta para a memoria */
   movl %ecx, -12(%ebp) /* spill de IrOpLocal "c" de volta para a memoria */
   call i
   addl $0, %esp
   /* 17 */
   popl %edi
   popl %esi
   popl %ebx
   leave
   ret

