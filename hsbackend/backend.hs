
import IrDados
import IrLexico
import IrSintatico

import Text.ParserCombinators.Parsec

import Data.List

import Data.Set (Set)
import qualified Data.Set as Set

----------------------------------------------------------------------------------------------------

main =
   do 
      file <- readFile "fun.m0.ir"
      case (analiseLexica file) of
         Left err     -> do putStr "Erro lexico em "
                            print err
         Right tokens -> geraIr tokens

----------------------------------------------------------------------------------------------------

geraIr tokens =
   do case (analiseSintatica tokens) of
         Left err  -> do putStr "Erro de sintaxe em "
                         print err
         Right ir ->  exibirSaida ir

----------------------------------------------------------------------------------------------------

processaGlobais :: [IrGlobal] -> [String]
processaGlobais glos =
   map (\ (IrGlobal nome) -> "   .comm "++nome++", 4") glos

----------------------------------------------------------------------------------------------------

processaStrings :: [IrString] -> [String]
processaStrings strs =
   concatMap (\ (IrString id valor) -> [id++":", "   .string \""++valor++"\""] ) strs

----------------------------------------------------------------------------------------------------

processaFuncao (IrFuncao nome args cmds) =
   codigo
   where
      blocos = quebraBlocosBasicos cmds
      locais = variaveisLocais cmds args
      numLocais = (((length locais) - (length args)) * 4)
      codigo = [ (".globl " ++ nome)
               , (".type " ++ nome ++ ", @function")
               , (nome ++ ":")
               , "   pushl %ebp"
               , "   movl %esp, %ebp"
               , "   subl $" ++ (show numLocais) ++ ", %esp /* " ++ (show (length locais)) ++ " locais, " ++ (show (length args)) ++ " args "++(concatMap show locais)++" **/"
               , "   push %ebp"
               , "   push %esi"
               , "   push %edi"
               ] ++ concat (map processaBloco blocos)

      processaBloco bloco = 
         selecionaOperacoes (verificaProximoUso bloco) locais nome

----------------------------------------------------------------------------------------------------

exibirSaida (strs, glos, funs) =
   let
      globais = processaGlobais glos
      strings = processaStrings strs
      funcoes = map processaFuncao funs
   in do print funcoes
         writeFile "fun.s" (unlines ([ ".data" ] ++
                                     globais ++
                                     [ ".text" ] ++
                                     strings ++ 
                                     (map unlines funcoes)))

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
--- 1. Repartir as instruções de cada função em blocos básicos (Algoritmo 8.5, Seção 8.4.1)
----------------------------------------------------------------------------------------------------

quebraBlocosBasicos :: [IrInstr] -> [[IrInstr]]
quebraBlocosBasicos cmds =
   quebra [] [] cmds 
   where 
      quebra :: [[IrInstr]] -> [IrInstr] -> [IrInstr] -> [[IrInstr]]
      -- É label, começa um bloco novo com ele
      quebra blocos atual (c@(IrX IrLabel x):cs)      = quebra (blocos ++ [ atual ] ) [c] cs
      -- Se deve ser o último do bloco
      quebra blocos atual (c@(IrX IrGoto x):cs)       = quebra (blocos ++ [ atual++[c] ] ) [] cs
      quebra blocos atual (c@(IrXY IrIf x y):cs)      = quebra (blocos ++ [ atual++[c] ] ) [] cs
      quebra blocos atual (c@(IrXY IrIfFalse x y):cs) = quebra (blocos ++ [ atual++[c] ] ) [] cs
      quebra blocos atual (c@(IrR IrRet):cs)          = quebra (blocos ++ [ atual++[c] ] ) [] cs
      quebra blocos atual (c@(IrX IrRetVal x):cs)     = quebra (blocos ++ [ atual++[c] ] ) [] cs
      -- Senão, adiciona ao bloco atual
      quebra blocos atual (c:cs)                 = quebra blocos (atual++[c]) cs
      -- Se acabou
      quebra blocos atual []                     = blocos ++ [atual]

----------------------------------------------------------------------------------------------------
--- 2.1. Fazer o levantamento de variáveis "vivas" e "próximo uso" (Algoritmo 8.7, Seção 8.4.2 - "Next-Use Information")
----------------------------------------------------------------------------------------------------

escreve1le2 IrEq = True
escreve1le2 IrNe = True
escreve1le2 IrLe = True
escreve1le2 IrGe = True
escreve1le2 IrGt = True
escreve1le2 IrLt = True
escreve1le2 IrAdd = True
escreve1le2 IrSub = True
escreve1le2 IrDiv = True
escreve1le2 IrMul = True
escreve1le2 IrSetIdx = True
escreve1le2 IrSetIdxByte = True
escreve1le2 _ = False

escreve0le3 IrIdxSet = True
escreve0le3 IrIdxSetByte = True
escreve0le3 _ = False

escreve1le1 IrSet = True
escreve1le1 IrSetByte = True
escreve1le1 IrNeg = True
escreve1le1 IrNew = True
escreve1le1 IrNewByte = True
escreve1le1 _ = False

escreve0le1 IrParam = True
escreve0le1 IrRetVal = True
escreve0le1 IrIf = True
escreve0le1 IrIfFalse = True
escreve0le1 _ = False

escreve0le0 IrLabel = True
escreve0le0 IrCall = True
escreve0le0 IrGoto = True
escreve0le0 IrRet = True
escreve0le0 _ = False

----------------------------------------------------------------------------------------------------

-- A "tabela" de próximo uso é na verdade uma função
-- (imagine-a sendo a função de lookup na tabela)
type FuncProxUso = IrOp -> (Bool, Int)

morreu x tabela   = (\var -> if var == x then (False, -1) else tabela var)
vivo   v i tabela = (\var -> if var == v then (True, i)   else tabela var)

----------------------------------------------------------------------------------------------------

verificaProximoUso :: [IrInstr] -> [(IrInstr, FuncProxUso)]
verificaProximoUso bloco =
   resultado 
   where
      nrInstrucoes = length bloco
      todosVivosNoFinal = (\var -> (True, nrInstrucoes) )
      -- reverse 2x para processar a lista de trás pra frente e depois restaurar a ordem
      resultado = reverse (verifica (reverse bloco) nrInstrucoes todosVivosNoFinal)

      verifica :: [IrInstr] -> Int -> FuncProxUso -> [(IrInstr, FuncProxUso)]
      -- Para cada comando c, vamos gerar um par (c, tabela)
      verifica (c:cs) nrInstrucao tabela =
         (c, tabela) : (verifica cs (nrInstrucao - 1) novaTabela)
         where
            novaTabela =
               case c of
               IrXYZ op x y z -> if escreve1le2 op
                                 then (vivo z nrInstrucao (vivo y nrInstrucao (morreu x tabela)))
                                 else (vivo z nrInstrucao (vivo y nrInstrucao (vivo x nrInstrucao tabela)))
               IrXY op x y    -> if escreve1le1 op
                                 then (vivo y nrInstrucao (morreu x tabela))
                                 else if escreve0le1 op
                                      then (vivo x nrInstrucao tabela)
                                      else tabela
               IrX op x       -> if escreve0le1 op
                                 then (vivo x nrInstrucao tabela)
                                 else tabela
               IrR op         -> tabela
   
      -- Fim da recursão
      verifica [] _ _ = []

----------------------------------------------------------------------------------------------------
--- 2.2. Fazer a seleção de operações, usando uma função de seleção de registradores (Seção 8.6.2 - "The Code-Generation Algorithm")
----------------------------------------------------------------------------------------------------

data Descritor = Registrador String
               | Memoria IrOp
                  deriving (Eq, Ord, Show)

-- O estado atual da alocação de registradores se dá
-- pela tabela de descritores.
-- A "tabela" de descritores é implementada com uma função
-- (novamente, imagine como sendo a função de lookup na tabela)
type Estado = Descritor -> Set Descritor

-- No estado inicial, os registradores estão vazios, as locais estão nos seus lugares, e temps vazios.
estadoInicial :: Estado
estadoInicial (Registrador r) = Set.empty
estadoInicial v@(Memoria (IrOpLocal l)) = Set.singleton v
estadoInicial (Memoria (IrOpTemp t)) = Set.empty
estadoInicial x = error ("Não sei o que fazer com " ++ (show x))

----------------------------------------------------------------------------------------------------

escreve (Registrador r) = "%" ++ r
escreve (Memoria (IrOpNumero n)) = "$" ++ (show n)
escreve x = error ("Não sei escrever " ++ (show x))

----------------------------------------------------------------------------------------------------

endereco :: Descritor -> [(IrOp, Int)] -> String
endereco (Memoria var) locais = 
   case (find (\(v, _) -> v == var) locais) of
   Just ((IrOpLocal l), i) -> (show i) ++ "(%ebp)"
   Just ((IrOpTemp l), i) -> (show i) ++ "(%ebp)"
   Nothing -> case var of 
              (IrOpNumero n) -> "$" ++ (show n)
              (IrOpTemp "$ret") -> "%eax"
              _ -> error ("Don't know how to represent "++(show var)++"!")

----------------------------------------------------------------------------------------------------

type Locais = [(IrOp, Int)]

type Contexto = (FuncProxUso, Estado, Locais, String, Int)

selecionaOperacoes :: [(IrInstr, FuncProxUso)] -> Locais -> String -> [String]
selecionaOperacoes bloco locais nome =
   resultado
   where
      resultado = seleciona bloco estadoInicial 1

      seleciona :: [(IrInstr, FuncProxUso)] -> Estado -> Int -> [String]
      seleciona (c:cs) estado i =
         ("   /* "++(show i)++" */") : saida ++ seleciona cs novoEstado (i+1)
         where
            (instrucao, proxUso) = c
            contexto = (proxUso, estado, locais, nome, i)
            (saida, novoEstado) = geraCodigo instrucao contexto
      
      -- Fim da recursão
      seleciona [] estado _ = []

----------------------------------------------------------------------------------------------------
--- 2.3. Implementar a função de seleção de registradores (Seção 8.6.3 - "Design of the function getReg")
----------------------------------------------------------------------------------------------------

regs = [ Registrador "eax", Registrador "ebx", Registrador "ecx", Registrador "edx", Registrador "edi"]

-- Registrador dummy para quando o valor de retorno é ignorado
r_ = Registrador "_"

emAlgumReg :: Descritor -> [Descritor] -> Estado -> Maybe Descritor
emAlgumReg var regs estado =
   find (achou var) regs
   where
      achou var reg =
         Set.member var (estado reg)

algumRegVazio :: [Descritor] -> Estado -> Maybe Descritor
algumRegVazio regs estado =
   find (\reg -> Set.null (estado reg)) regs

ehLocal (IrOpLocal l) = True
ehLocal _ = False

----------------------------------------------------------------------------------------------------

-- Funções de atualização de estado da tabela de descritores
type FuncAtualizaEstado = Descritor -> Estado -> Descritor -> Estado

-- Faz a variavel var ocupar o registrador reg exclusivamente.
ocupaReg :: Descritor -> Estado -> Descritor -> Estado
ocupaReg var estado reg =
   novoEstado
   where
      novoEstado r2@(Registrador r) = if reg == r2 then (Set.singleton var) else (estado r2)
      novoEstado v2@(Memoria m)     = if var == v2 then Set.insert reg (estado v2)
                                                   else Set.delete reg (estado v2)

-- Adiciona a variavel var ao registrador reg, mantendo quem já estava lá.
compartilha :: Descritor -> Estado -> Descritor -> Estado
compartilha var estado reg =
   novoEstado
   where
      novoEstado r2@(Registrador r) = if reg == r2 then Set.insert var (estado r2) else estado r2
      novoEstado v2@(Memoria m)     = if var == v2 then (Set.singleton reg) else estado v2

-- Variável agora está apenas no registrador.
saiDaMemoria :: Descritor -> Estado -> Descritor -> Estado
saiDaMemoria var estado reg =
   novoEstado
   where
      novoEstado r2@(Registrador r) = if reg == r2 then (Set.singleton var) else (estado r2)
      novoEstado v2@(Memoria m)     = if var == v2 then (Set.singleton reg)
                                                   else Set.delete reg (estado v2)

-- Spill: variável volta para a memória.
voltaPraMemoria :: Descritor -> Estado -> Descritor -> Estado
voltaPraMemoria var estado reg =
   novoEstado
   where
      novoEstado r2@(Registrador r) = estado r2
      novoEstado v2@(Memoria m)     = if var == v2 then Set.insert var (estado v2) else (estado v2)

----------------------------------------------------------------------------------------------------

-- Funções de carga de variáveis da memória para registradores (implementadas dentro da getReg)
type FuncCarga = Descritor -> Descritor -> [String]

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------

-- Força o spill dos registradores selecionados.
forcarSpill :: Locais -> Estado -> [Descritor] -> ([String], Estado)
forcarSpill locais estado (r:rs) =
   (sp ++ sps, novoEstado)
   where
      sp = geraSpills r estado
      proxEstado = Set.foldr (\var estado2 -> (voltaPraMemoria var estado2 r)) estado (estado r)
      (sps, novoEstado) = forcarSpill locais proxEstado rs

      -- Gera código de spill das variáveis presentes em reg
      geraSpills :: Descritor -> Estado -> [String]
      geraSpills reg estado =
         Set.foldr (\var cs -> (spill reg var) : cs) [] (estado reg)
      
      spill reg@(Registrador r) var@(Memoria l) =
         "   movl " ++ (escreve reg) ++ ", " ++ (endereco var locais) ++ " /* spill de "++(show l)++" de volta para a memoria */"

forcarSpill _ estado [] =
   ([], estado)

-- Força o spill de todos os registradores.
forcarSpillLocais :: Locais -> Estado -> ([String], Estado)
forcarSpillLocais locais estado =
   ("   /* crazy spill time! */" : spills ++ ["   /* done */"], novoEstado)
   where
      (spills, novoEstado) = forcarSpill locais estado regs

----------------------------------------------------------------------------------------------------

-- A função getReg! (página 547)
getReg :: Contexto -> IrOpcode -> IrOp -> IrOp -> IrOp -> (Descritor, Descritor, Descritor, [String], Estado)
getReg contexto op x y z =
   -- escolhe a estratégia de acordo com o tipo de operação:
   if (op == IrSet || op == IrSetByte) && ehLocal y then getRegSet
   else if escreve0le3 op then getRegXYZ
   else if escreve1le2 op then getRegYZX
   else if escreve1le1 op then getRegYX
   else getRegX
   where
      (proxUso, estado, locais, _, _) = contexto

      -- três registradores (escreve 1, le 2)
      getRegYZX =
         (rx, ry, rz, spillsY ++ spillsZ ++ spillsX, estadoX)
         where
            (ry, estadoY, spillsY) = escolhe y estado   ocupaReg      carrega
            (rz, estadoZ, spillsZ) = escolhe z estadoY  ocupaReg      carrega  
            (rx, estadoX, spillsX) = escolhe x estadoZ  saiDaMemoria  ignora   

      -- três registradores (escreve 0, le 3)
      getRegXYZ =
         (rx, ry, rz, spillsY ++ spillsZ ++ spillsX, estadoX)
         where
            (rx, estadoX, spillsX) = escolhe x estado   ocupaReg  carrega
            (ry, estadoY, spillsY) = escolhe y estadoX  ocupaReg  carrega
            (rz, estadoZ, spillsZ) = escolhe z estadoY  ocupaReg  carrega

      -- dois registradores (escreve 1, le 1)
      getRegYX =
         (rx, ry, r_, spillsY ++ spillsX, estadoX)
         where
            (ry, estadoY, spillsY) = escolhe y estado   ocupaReg      carrega
            (rx, estadoX, spillsX) = escolhe x estadoY  saiDaMemoria  ignora

      -- um registrador (escreve 0, le 1)
      getRegX =
         (rx, r_, r_, spillsX, estadoX)
         where
            (rx, estadoX, spillsX) = escolhe x estado   ocupaReg  carrega

      escolhe :: IrOp -> Estado -> FuncAtualizaEstado -> FuncCarga -> (Descritor, Estado, [String])

      escolhe i@(IrOpNumero n) estado _ _ = ((Memoria i), estado, [])
      escolhe y estado atualizaEstado carregaVariavel =
         let
            novoEstado = atualizaEstado  (Memoria y) estado
            carga      = carregaVariavel (Memoria y)
         in
            -- 1. if y is currently in a register, pick a register already containing y as Ry.
            -- Do not issue a machine instruction to load this register, as none is needed.
            case (emAlgumReg (Memoria y) regs estado) of
            Just reg -> (reg, estado, [])
            Nothing ->
               -- 2. If y is not in a register, but there is a register that is currently empty,
               -- pick one such register as Ry.
               case (algumRegVazio regs estado) of
               Just reg -> (reg, novoEstado reg, carga reg)
               Nothing ->
                  -- 3. The difficult case occurs when y is not in a register, and there is no register
                  -- that is currently empty. We need to pick one of the allowable registers
                  -- anyway, and we need to make it safe to reuse. Let R be a candidate
                  -- register, and suppose v is one of the variables that the register descriptor
                  -- for R says is in R. We need to make sure that v's value either is not really needed,
                  -- or that there is somewhere else we can go to get the value of R.
                  -- The possibilites are:
                     let
                        testaVar :: Descritor -> Int
                        testaVar v@(Memoria mv) =
                           -- (a) If the address descriptor for v says that v is somewhere besides R,
                           -- then we are OK.
                           if Set.size (estado v) > 1
                           then 0
                           -- (b) if v is x, the value being computed by instruction I, and x is not
                           -- also one of the other operands of instruction I (z in this example),
                           -- then we are OK. The reason is that in this case, we know this value
                           -- of x is never again going to be used, so we are free to ignore it.
                           else if mv == x && x /= z
                           then 0
                           -- (c) Otherwise, if v is not used later (that is, after then instruction I,
                           -- there are no further uses of v, and if v is live on exit from the block,
                           -- then v is recomputed within the block), then we are OK.
                           else if (fst (proxUso mv) == False) && ehLocal mv
                           then 0
                           -- (d) If we are not OK by one of the previous cases, then we need to
                           -- generate the store instruction to place a copy of v in its own
                           -- memory location. This operation is called a spill.
                           else 1
                        
                        -- Since R may hold several variables at the moment, we repeat the above
                        -- steps for each such variable v. At the end, R's "score" is the number
                        -- of store instructions we needed to generate.
                        testaScore :: Descritor -> Int
                        testaScore r = Set.foldl (\score v -> score + (testaVar v) ) 0 (estado r)
   
                        --  Pick one of the registers with the lowest score.
                        menorScore :: [Descritor] -> (Descritor, Int)
                        menorScore (r:rs@(rx:rxs)) =
                           let 
                              score = testaScore r
                              (minRs, scoreRs) = menorScore rs
                           in if score < scoreRs
                              then (r, score)
                              else (minRs, scoreRs)
                        menorScore (r:[]) = (r, testaScore r)
                        
                        (reg, score) = menorScore regs
                     in if score == 0
                        then (reg, novoEstado reg, carga reg ++ ["/* weee, score 0! */"])
                        else let (spills, estadoSpill) = forcarSpill locais estado [reg]
                             in  (reg, (atualizaEstado (Memoria y) estadoSpill) reg, spills ++ (carga reg))

      -- The last matter to consider specially is the case when I is a copy instruction
      -- x = y. We pick the register Ry as above. Then we always choose Rx = Ry.
      getRegSet =
         (rx, ry, r_, spillsY, estadoX)
         where
            (ry, estadoY, spillsY) = escolhe y estado ocupaReg carrega
            (rx, estadoX, _) = (ry, compartilha (Memoria x) estadoY ry, [])
      
      -- Funções de carga da memória para registrador:

      ignora _ _ = []

      carrega var@(Memoria l) reg@(Registrador r) =
         ["   movl " ++ (endereco var locais) ++ ", " ++ (escreve reg) ++ " /* carrega "++(show l)++" em "++r++" */" ]

----------------------------------------------------------------------------------------------------

geraCodigo :: IrInstr -> Contexto -> ([String], Estado)

geraCodigo (IrX IrLabel (IrOpLabel l) ) contexto =
   ([ l ++ ":" ], estado)
   where
      (_, estado, _, _, _) = contexto

geraCodigo (IrX IrGoto (IrOpLabel l)) contexto =
   (saida, novoEstado)
   where
      (_, estado, locais, _, _) = contexto
      -- fim de bloco básico: forçar o spill das locais
      (spillLocais, novoEstado) = forcarSpillLocais locais estado
      operacao = [ "   jmp " ++ l ]
      saida = spillLocais ++ operacao

geraCodigo (IrX IrParam x) contexto =
   (saida, novoEstado)
   where
      (rx, _, _, prepara, novoEstado) = getReg contexto IrParam x x x
      operacao = [ "   pushl " ++ (escreve rx) ]
      saida = prepara ++ operacao

geraCodigo (IrX IrCall x@(IrOpFuncao f)) contexto =
   (saida, novoEstado)
   where
      (_, estado, locais, _, _) = contexto
--      (_, _, _, prepara, estado1) = getReg contexto IrCall x x x
      -- liberar registradores pela convenção de chamada
      (spill, novoEstado) = forcarSpill locais estado [Registrador "eax", Registrador "ecx", Registrador "edx"]
      operacao = [ "   call " ++ f ]
      saida = spill ++ operacao

geraCodigo (IrX IrRetVal x) contexto =
   (saida, novoEstado)
   where
      (proxUso, estado, locais, nome, i) = contexto
      -- valor de retorno fica em %eax
      (spill, estado1) = forcarSpill locais estado [Registrador "eax"]
      contexto2 = (proxUso, estado1, locais, nome, i)
      (rx, _, _, prepara, novoEstado) = getReg contexto2 IrRetVal x x x
      operacao = [ "   movl " ++ (escreve rx) ++ ", %eax"
                 , "   popl %edi"
                 , "   popl %esi"
                 , "   popl %ebx"
                 , "   leave"
                 , "   ret"
                 ]
      saida = spill ++ prepara ++ operacao

geraCodigo (IrXY IrIf x (IrOpLabel l)) contexto =
   (operacao, novoEstado)
   where
      (_, _, locais, _, _) = contexto
      -- fim de bloco básico: forçar o spill das locais
      (spillLocais, novoEstado) = forcarSpillLocais locais estado1
      (rx, _, _, prepara, estado1) = getReg contexto IrIf x x x
      operacao = [ "   cmp " ++ (escreve rx) ++ ", $0"
                 , "   jne " ++ l
                 ]
      saida = spillLocais ++ prepara ++ operacao

geraCodigo (IrXY IrIfFalse x (IrOpLabel l)) contexto =
   (saida, novoEstado)
   where
      (_, _, locais, _, _) = contexto
      (spillLocais, estado1) = forcarSpillLocais locais estado
      (rx, _, _, prepara, novoEstado) = getReg contexto IrIf x x x
      -- fim de bloco básico: forçar o spill das locais
      operacao = [ "   cmp " ++ (escreve rx) ++ ", $0"
                 , "   je " ++ l
                 ]
      saida = spillLocais ++ prepara ++ operacao

geraCodigo (IrXY IrSet x y) contexto =
   (saida, novoEstado)
   where
      (rx, ry, _, prepara, novoEstado) = getReg contexto IrSet x y y
      operacao = [ "   movl " ++ (escreve ry) ++ ", " ++ (escreve rx) ]
      saida = prepara ++ operacao

geraCodigo (IrXY IrSetByte x y) contexto =
   (saida, novoEstado)
   where
      (rx, ry, _, prepara, novoEstado) = getReg contexto IrSetByte x y y
      operacao = [ "   movsbl " ++ (escreve ry) ++ ", " ++ (escreve rx) ]
      saida = prepara ++ operacao

geraCodigo (IrXY IrNeg x y) contexto =
   (saida, novoEstado)
   where
      (rx, ry, _, prepara, novoEstado) = getReg contexto IrNeg x y y
      operacao = [ "   negl " ++ (escreve ry) ++ ", " ++ (escreve rx) ]
      saida = prepara ++ operacao

geraCodigo (IrXY IrNew x y) contexto =
   (saida, novoEstado)
   where
      (_, _, locais, _, _) = contexto
      (rx, ry, _, prepara, estado1) = getReg contexto IrNew x y y
      -- liberar registradores pela convenção de chamada
      (spill, novoEstado) = forcarSpill locais estado1 [Registrador "eax", Registrador "ecx", Registrador "edx"]
      operacao = [ "   movl " ++ (escreve ry) ++ ", %esi"
                 , "   imul $4, %esi"
                 , "   pushl %esi"
                 , "   call malloc"
                 , "   movl %eax, " ++ (escreve rx)
                 ]
      saida = spill ++ prepara ++ operacao

geraCodigo (IrXY IrNewByte x y) contexto =
   (saida, novoEstado)
   where
      (_, _, locais, _, _) = contexto
      (rx, ry, _, prepara, estado1) = getReg contexto IrNew x y y
      -- liberar registradores pela convenção de chamada
      (spill, novoEstado) = forcarSpill locais estado1 [Registrador "eax", Registrador "ecx", Registrador "edx"]
      operacao = [ "   pushl " ++ (escreve ry)
                 , "   call malloc"
                 , "   movl %eax, " ++ (escreve rx)
                 ]
      saida = spill ++ prepara ++ operacao

geraCodigo (IrXYZ IrSetIdx x y z) contexto =
   (saida, novoEstado)
   where
      (rx, ry, rz, prepara, novoEstado) = getReg contexto IrSetIdx x y z
      operacao = [ "   movl " ++ (escreve rz) ++ ", %esi"
                 , "   imul $4, %esi"
                 , "   addl " ++ (escreve ry) ++ ", %esi"
                 , "   movl (%esi), " ++ (escreve rx)
                 ]
      saida = prepara ++ operacao

geraCodigo (IrXYZ IrSetIdxByte x y z) contexto =
   (saida, novoEstado)
   where
      (rx, ry, rz, prepara, novoEstado) = getReg contexto IrSetIdxByte x y z
      operacao = [ "   movl " ++ (escreve rz) ++ ", %esi"
                 , "   addl " ++ (escreve ry) ++ ", %esi"
                 , "   movsbl (%esi), " ++ (escreve rx)
                 ]
      saida = prepara ++ operacao

geraCodigo (IrXYZ IrIdxSet x y z) contexto =
   (saida, novoEstado)
   where
      (rx, ry, rz, prepara, novoEstado) = getReg contexto IrIdxSet x y z
      operacao = [ "   movl " ++ (escreve ry) ++ ", %esi"
                 , "   imul $4, %esi"
                 , "   addl " ++ (escreve rx) ++ ", %esi"
                 , "   movl " ++ (escreve rz) ++ ", (%esi)"
                 ]
      saida = prepara ++ operacao

geraCodigo (IrXYZ IrIdxSetByte x y z) contexto =
   (saida, novoEstado)
   where
      (rx, ry, rz, prepara, novoEstado) = getReg contexto IrIdxSetByte x y z
      operacao = [ "   movl " ++ (escreve ry) ++ ", %esi"
                 , "   addl " ++ (escreve rx) ++ ", %esi"
                 , "   movb " ++ (escreve rz) ++ ", (%esi)"
                 ]
      saida = prepara ++ operacao

geraCodigo op@(IrXYZ IrNe x y z) contexto = geraComparacao op contexto "jne"

geraCodigo op@(IrXYZ IrEq x y z) contexto = geraComparacao op contexto "je"

geraCodigo op@(IrXYZ IrLe x y z) contexto = geraComparacao op contexto "jle"

geraCodigo op@(IrXYZ IrGe x y z) contexto = geraComparacao op contexto "jge"

geraCodigo op@(IrXYZ IrLt x y z) contexto = geraComparacao op contexto "jl"

geraCodigo op@(IrXYZ IrGt x y z) contexto = geraComparacao op contexto "jg"

geraCodigo op@(IrXYZ IrAdd x y z) contexto = geraAritmetica op contexto "addl"

geraCodigo op@(IrXYZ IrSub x y z) contexto = geraAritmetica op contexto "subl"

geraCodigo op@(IrXYZ IrMul x y z) contexto = geraAritmetica op contexto "imul"

geraCodigo (IrXYZ IrDiv x y z) contexto =
   (saida, novoEstado)
   where
      (_, _, locais, _, _) = contexto
      (rx, ry, rz, prepara, estado1) = getReg contexto IrDiv x y z
      -- idiv usa %eax e %edx
      (spill, novoEstado) = forcarSpill locais estado1 [Registrador "eax", Registrador "edx"]
      operacao = [ "   movl " ++ (escreve ry) ++ ", %eax"
                 , "   cltd"
                 , "   idiv " ++ (escreve rz)
                 , "   mov %eax, " ++ (escreve rx)
                 ]
      saida = spill ++ prepara ++ operacao

geraCodigo (IrR IrRet) contexto =
   (operacao, estado)
   where
      (_, estado, locais, _, _) = contexto
      operacao = [ "   popl %edi"
                 , "   popl %esi"
                 , "   popl %ebx"
                 , "   movl %ebp, %esp"
                 , "   popl %ebp"
                 , "   ret"
                 ]

--------------------------------------------------------------------------------------------

geraTempLabels :: Contexto -> (String, String)
geraTempLabels contexto =
   ( ".L" ++ nome ++ "_" ++ (show i) ++ "_1", ".L" ++ nome ++ "_" ++ (show i) ++ "_2" )
   where
      (_, _, _, nome, i) = contexto

geraComparacao :: IrInstr -> Contexto -> String -> ([String], Estado)

geraComparacao (IrXYZ op x y z) contexto opcode =
   (saida, novoEstado)
   where
      (rx, ry, rz, prepara, novoEstado) = getReg contexto op x y z
      (l1, l2) = geraTempLabels contexto
      operacao = [ "   cmpl " ++ (escreve ry) ++ ", " ++ (escreve rz)
                 , "   "++opcode++" " ++ l1
                 , "   movl $0, " ++ (escreve rx)
                 , "   jmp " ++ l2
                 , l1 ++ ":" 
                 , "   movl $1, " ++ (escreve rx)
                 , l2 ++ ":" 
                 ]
      saida = prepara ++ operacao

--------------------------------------------------------------------------------------------

geraAritmetica (IrXYZ op x y z) contexto opcode =
   (saida, novoEstado)
   where
      (rx, ry, rz, prepara, novoEstado) = getReg contexto op x y z
      operacao = [ "   movl " ++ (escreve ry) ++ ", " ++ (escreve rx)
                 , "   "++opcode++" " ++ (escreve rz) ++ ", " ++ (escreve rx)
                 ]
      saida = prepara ++ operacao

--------------------------------------------------------------------------------------------

--- Obter conjunto de variaveis locais da função

variaveisLocais :: [IrInstr] -> [String] -> [(IrOp, Int)]
variaveisLocais bloco args =
   (paresArgs args 8) ++ (paresLocais semArgs (-4))
   
   where
      encontradas = Set.toList (foldl insereLocais Set.empty bloco)

      -- Remove argumentos e $ret da lista das locais que terão offsets negativos na pilha.
      semArgs = tiraArgs ("$ret" : args) encontradas
         where 
            tiraArgs :: [String] -> [IrOp] -> [IrOp]
            
            tiraArgs (ar:ars) lista = tiraArgs ars (filter (tiraArg ar) lista)
            tiraArgs [] lista = lista
            
            tiraArg :: String -> IrOp -> Bool
            tiraArg ar (IrOpLocal l) = (ar /= l)
            tiraArg ar (IrOpTemp l) = (ar /= l)
            tiraArg _ _ = True

      -- Gera os pares indicando os offsets positivos dos argumentos
      paresArgs :: [String] -> Int -> [(IrOp, Int)]
      paresArgs (ar:ars) n = (IrOpLocal ar, n) : paresArgs ars (n+4)
      paresArgs [] _ = []
      
      -- Gera os pares indicando os offsets negativos das locais
      paresLocais :: [IrOp] -> Int -> [(IrOp, Int)]
      paresLocais (l:ls) n = (l, n) : paresLocais ls (n-4)
      paresLocais [] _ = []
      
      insereLocais conjunto ins =
            -- Tenta inserir todos os parâmetros
            case ins of
               IrXYZ op x y z -> (insere x (insere y (insere z conjunto)))
               IrXY  op x y   -> (insere x (insere y conjunto))
               IrX   op x     -> (insere x conjunto)
               IrR   op       -> conjunto

      -- Se for local ou temp, insere no conjunto
      insere v@(IrOpLocal var) conjunto = Set.insert v conjunto
      insere v@(IrOpTemp  var) conjunto = Set.insert v conjunto
      -- Senão, não insere
      insere _                 conjunto = conjunto

--------------------------------------------------------------------------------------------
