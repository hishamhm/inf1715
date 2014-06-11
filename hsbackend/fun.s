f:
   pushl %ebp
   movl %esp, %ebp
   subl $20, %esp /* 8 locais, 3 args (IrOpLocal "a",8)(IrOpLocal "b",12)(IrOpLocal "c",16)(IrOpLocal "blabla",-4)(IrOpLocal "vovo",-8)(IrOpLocal "x",-12)(IrOpLocal "y",-16)(IrOpLocal "zoo",-20) **/
   push %ebp
   push %esi
   push %edi
   movl $9, %eax
   movl $0, %ebx
   movl $0, %ecx
   movl $12, %edx
   movl $15, %edi
   movl %edi, -8(%ebp) /* spill de IrOpLocal "vovo" de volta para a memoria */
   movl $16, %edi
   /* crazy spill time! */
   movl %eax, -12(%ebp) /* spill de IrOpLocal "x" de volta para a memoria */
   movl %ebx, -16(%ebp) /* spill de IrOpLocal "y" de volta para a memoria */
   movl %ecx, -20(%ebp) /* spill de IrOpLocal "zoo" de volta para a memoria */
   movl %edx, 8(%ebp) /* spill de IrOpLocal "a" de volta para a memoria */
   movl %edi, -4(%ebp) /* spill de IrOpLocal "blabla" de volta para a memoria */
   /* done */
   popl %edi
   popl %esi
   popl %ebx
   movl %ebp, %esp
   popl %ebp
   ret

g:
   pushl %ebp
   movl %esp, %ebp
   subl $52, %esp /* 13 locais, 0 args (IrOpLocal "g",-4)(IrOpLocal "i",-8)(IrOpLocal "id",-12)(IrOpLocal "v",-16)(IrOpLocal "x",-20)(IrOpLocal "y",-24)(IrOpLocal "z",-28)(IrOpTemp "$t0",-32)(IrOpTemp "$t1",-36)(IrOpTemp "$t2",-40)(IrOpTemp "$t3",-44)(IrOpTemp "$t4",-48)(IrOpTemp "$t9",-52) **/
   push %ebp
   push %esi
   push %edi
   movl $0, %eax
   movl $0, %ebx
.L1:
   movl -20(%ebp), %eax /* carrega IrOpLocal "x" em eax */
   cmpl %eax, $10
   jl .Lg_2_1
   movl $0, %ebx
   jmp .Lg_2_2
.Lg_2_1:
   movl $1, %ebx
.Lg_2_2:
   /* crazy spill time! */
   movl %eax, -20(%ebp) /* spill de IrOpLocal "x" de volta para a memoria */
   movl %ebx, -52(%ebp) /* spill de IrOpTemp "$t9" de volta para a memoria */
   /* done */
   cmp %ebx, $0
   je .L2
   movl $1, %eax
   addl $1, %eax
   movl %eax, -48(%ebp) /* spill de IrOpTemp "$t4" de volta para a memoria */
   call m
   movl %eax, %eax /* carrega IrOpTemp "$ret" em eax */
   movl %eax, %ebx
   movl -48(%ebp), %ecx /* carrega IrOpTemp "$t4" em ecx */
   movl -20(%ebp), %edx /* carrega IrOpLocal "x" em edx */
   movl %ecx, %edi
   addl %edx, %edi
/* weee, score 0! */
   movl %edi, %edx
   addl %edx, %edx
   movl %edi, -44(%ebp) /* spill de IrOpTemp "$t3" de volta para a memoria */
   movl %edx, %edi
   addl $3, %edi
   movl %edi, -36(%ebp) /* spill de IrOpTemp "$t1" de volta para a memoria */
   movl %edi, %edi
   addl $9, %edi
   movl %edi, -32(%ebp) /* spill de IrOpTemp "$t0" de volta para a memoria */
   movsbl $0, %edi
   movl %eax, %eax /* spill de IrOpTemp "$ret" de volta para a memoria */
   movl %ecx, -48(%ebp) /* spill de IrOpTemp "$t4" de volta para a memoria */
   movl %edx, -40(%ebp) /* spill de IrOpTemp "$t2" de volta para a memoria */
/* weee, score 0! */
   pushl $10
   call malloc
   movl %eax, %edi
   movl -24(%ebp), %eax /* carrega IrOpLocal "y" em eax */
   movl %eax, %esi
   addl %edi, %esi
   movsbl (%esi), %ecx
   movl %_, %esi
   addl %edi, %esi
   movb %_, (%esi)
   movl -32(%ebp), %edx /* carrega IrOpTemp "$t0" em edx */
/* weee, score 0! */
   movl %edx, %eax
   movl $9, %eax
   movl -4(%ebp), %eax /* carrega IrOpLocal "g" em eax */
/* weee, score 0! */
   movl %eax, %eax
   movl %edi, -16(%ebp) /* spill de IrOpLocal "v" de volta para a memoria */
   movl -24(%ebp), %edi /* carrega IrOpLocal "y" em edi */
   movl %edi, %edi
   addl $1, %edi
   /* crazy spill time! */
   movl %eax, -4(%ebp) /* spill de IrOpLocal "g" de volta para a memoria */
   movl %eax, -20(%ebp) /* spill de IrOpLocal "x" de volta para a memoria */
   movl %ebx, -28(%ebp) /* spill de IrOpLocal "z" de volta para a memoria */
   movl %ecx, -8(%ebp) /* spill de IrOpLocal "i" de volta para a memoria */
   movl %edx, -32(%ebp) /* spill de IrOpTemp "$t0" de volta para a memoria */
   movl %edi, -24(%ebp) /* spill de IrOpLocal "y" de volta para a memoria */
   /* done */
   jmp .L1
.L2:
   movl -12(%ebp), %eax /* carrega IrOpLocal "id" em eax */
   movl %eax, %eax
   /* crazy spill time! */
   movl %eax, -12(%ebp) /* spill de IrOpLocal "id" de volta para a memoria */
   movl %eax, -28(%ebp) /* spill de IrOpLocal "z" de volta para a memoria */
   /* done */
   popl %edi
   popl %esi
   popl %ebx
   movl %ebp, %esp
   popl %ebp
   ret

h:
   pushl %ebp
   movl %esp, %ebp
   subl $16, %esp /* 4 locais, 0 args (IrOpLocal "i",-4)(IrOpLocal "v",-8)(IrOpLocal "x",-12)(IrOpLocal "y",-16) **/
   push %ebp
   push %esi
   push %edi
   movl $0, %eax
   movl $0, %ebx
   cmp $0, $0
   jne .L3
   movl $0, %eax
   movl %eax, -4(%ebp) /* spill de IrOpLocal "i" de volta para a memoria */
   movl $10, %esi
   imul $4, %esi
   pushl %esi
   call malloc
   movl %eax, %ebx
   movl -16(%ebp), %eax /* carrega IrOpLocal "y" em eax */
   movl %eax, %esi
   imul $4, %esi
   addl %ebx, %esi
   movl (%esi), %ecx
   movl %_, %esi
   imul $4, %esi
   addl %ebx, %esi
   movl %_, (%esi)
   movl -12(%ebp), %edx /* carrega IrOpLocal "x" em edx */
   pushl %edx
   movl %eax, -16(%ebp) /* spill de IrOpLocal "y" de volta para a memoria */
   movl %ecx, -4(%ebp) /* spill de IrOpLocal "i" de volta para a memoria */
   movl %edx, -12(%ebp) /* spill de IrOpLocal "x" de volta para a memoria */
   call f
.L3:
   /* crazy spill time! */
   /* done */
   popl %edi
   popl %esi
   popl %ebx
   movl %ebp, %esp
   popl %ebp
   ret

i:
   pushl %ebp
   movl %esp, %ebp
   subl $12, %esp /* 3 locais, 0 args (IrOpLocal "x",-4)(IrOpLocal "y",-8)(IrOpTemp "$t5",-12) **/
   push %ebp
   push %esi
   push %edi
   movl $0, %eax
   movl $0, %ebx
   movl %eax, %ecx
   addl %ebx, %ecx
   movl %ecx, %eax
   movl %eax, -4(%ebp) /* spill de IrOpLocal "x" de volta para a memoria */
   movl %ecx, -12(%ebp) /* spill de IrOpTemp "$t5" de volta para a memoria */
   call g
   call h
   /* crazy spill time! */
   movl %ebx, -8(%ebp) /* spill de IrOpLocal "y" de volta para a memoria */
   /* done */
   movl $12, %eax
   popl %edi
   popl %esi
   popl %ebx
   movl %ebp, %esp
   popl %ebp
   ret

j:
   pushl %ebp
   movl %esp, %ebp
   subl $12, %esp /* 3 locais, 0 args (IrOpLocal "a",-4)(IrOpLocal "b",-8)(IrOpLocal "c",-12) **/
   push %ebp
   push %esi
   push %edi
   movl $0, %eax
   movl $0, %ebx
   movl $0, %ecx
   cmpl %ebx, %ecx
   je .Lj_4_1
   movl $0, %eax
   jmp .Lj_4_2
.Lj_4_1:
   movl $1, %eax
.Lj_4_2:
   cmpl %ebx, %ecx
   jne .Lj_5_1
   movl $0, %eax
   jmp .Lj_5_2
.Lj_5_1:
   movl $1, %eax
.Lj_5_2:
   cmpl %ebx, %ecx
   jg .Lj_6_1
   movl $0, %eax
   jmp .Lj_6_2
.Lj_6_1:
   movl $1, %eax
.Lj_6_2:
   cmpl %ebx, %ecx
   jl .Lj_7_1
   movl $0, %eax
   jmp .Lj_7_2
.Lj_7_1:
   movl $1, %eax
.Lj_7_2:
   cmpl %ebx, %ecx
   jge .Lj_8_1
   movl $0, %eax
   jmp .Lj_8_2
.Lj_8_1:
   movl $1, %eax
.Lj_8_2:
   cmpl %ebx, %ecx
   jle .Lj_9_1
   movl $0, %eax
   jmp .Lj_9_2
.Lj_9_1:
   movl $1, %eax
.Lj_9_2:
   movl %ebx, %ecx
   imul %eax, %ecx
   movl %ebx, %eax
   addl %ecx, %eax
   movl %ebx, %eax
   subl %ecx, %eax
   movl %eax, -4(%ebp) /* spill de IrOpLocal "a" de volta para a memoria */
   movl %ebx, %eax
   cltd
   idiv %ecx
   mov %eax, %eax
   negl %ebx, %eax
   movl %eax, -4(%ebp) /* spill de IrOpLocal "a" de volta para a memoria */
   movl %ecx, -12(%ebp) /* spill de IrOpLocal "c" de volta para a memoria */
   call g
   call i
   /* crazy spill time! */
   movl %ebx, -8(%ebp) /* spill de IrOpLocal "b" de volta para a memoria */
   /* done */
   popl %edi
   popl %esi
   popl %ebx
   movl %ebp, %esp
   popl %ebp
   ret

