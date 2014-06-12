
module IrSintatico where

import IrDados 
import Text.ParserCombinators.Parsec
import Text.ParserCombinators.Parsec.Pos

type MeuParser a = GenParser IrToken () a

--- converte tokens para parser -----------------------------------------------------------------------

ignoraPos s x xs = s

ehIgual t x = if t == x then Just x else Nothing

eh :: IrToken -> GenParser IrToken st IrToken
eh t = tokenPrim show ignoraPos (ehIgual t)

umID :: GenParser IrToken st String
umID = tokenPrim show ignoraPos testa
   where testa (IrID id) = Just id
         testa _         = Nothing

showC (IrC c) = ['\'', c, '\'']
showC x = show x

umC :: Char -> GenParser IrToken st Char
umC c = tokenPrim showC ignoraPos testa
   where testa (IrC x) = if x == c then Just x else Nothing
         testa _       = Nothing

umLITSTRING :: GenParser IrToken st String
umLITSTRING = tokenPrim (\(IrLITSTRING s) -> "\"" ++ s ++ "\"") ignoraPos testa
   where testa (IrLITSTRING s) = Just s
         testa _               = Nothing

umLABEL :: GenParser IrToken st String
umLABEL = tokenPrim show ignoraPos testa
   where testa (IrLABEL s) = Just s
         testa _           = Nothing

umLITNUM :: GenParser IrToken st Int
umLITNUM = tokenPrim (\(IrLITNUM n) -> show n) ignoraPos testa
   where testa (IrLITNUM n) = Just n
         testa _            = Nothing

umNL :: GenParser IrToken st IrToken
umNL = tokenPrim (\_ -> "\"\\n\"") pulaLinha (ehIgual IrNL)
   where pulaLinha pos x xs = updatePosChar pos '\n'

--- analise sintatica -----------------------------------------------------------------------

programa :: MeuParser Ir
programa =
   do many umNL
      str <- asStrings
      glo <- asGlobais
      fun <- asFuncoes
      return (str, glo, fun)

asStrings :: MeuParser [IrString]
asStrings = many umaString

umaString :: MeuParser IrString
umaString =
   do eh IrSTRING
      id <- umID
      umC '='
      st <- umLITSTRING
      umNL
      return (IrString id st)

asGlobais :: MeuParser [IrGlobal]
asGlobais = many umaGlobal

umaGlobal :: MeuParser IrGlobal
umaGlobal =
   do eh IrGLOBAL
      id <- umID
      umNL
      return (IrGlobal id)

asFuncoes :: MeuParser [IrFuncao]
asFuncoes = many umaFuncao

argumentos :: MeuParser [String]
argumentos = between (umC '(') (umC ')') (umID `sepBy` (umC ','))

umaFuncao :: MeuParser IrFuncao
umaFuncao =
   do eh IrFUN
      nome <- umID
      args <- argumentos
      umNL
      cmds <- osComandos
      return (IrFuncao nome args (concat cmds))

osComandos :: MeuParser [[IrInstr]]
osComandos = many (do { ls <- many umLabel; cmd <- umComando; umNL; return (ls ++ [cmd]) })

umLabel :: MeuParser IrInstr
umLabel =
   do l <- umLABEL
      umC ':'
      many umNL
      return (IrX IrLabel (IrOpLabel l))

geraOpId :: String -> IrOp
geraOpId i@('$':xs) = (IrOpTemp i)
geraOpId i = (IrOpLocal i)

umRval :: MeuParser IrOp
umRval =
   do { n <- umLITNUM; return (IrOpNumero n) }
   <|> do { i <- umID; return (geraOpId i) }

algumC cs = choice (map (\c -> do { k <- try (umC c); return (IrC k) }) cs)

ehBinOp :: MeuParser IrToken
ehBinOp = (eh IrEQ) <|> (eh IrNE) <|> (eh IrLE) <|> (eh IrGE) <|> algumC "+-*/<>"

geraBinOp :: IrToken -> String -> IrOp -> IrOp -> IrInstr
geraBinOp op x' y z =
   let x = geraOpId x'
       opcode = case op of
                IrEQ -> IrEq
                IrNE -> IrNe
                IrLE -> IrLe
                IrGE -> IrGe
                IrC '<' -> IrLt
                IrC '>' -> IrGt
                IrC '+' -> IrAdd
                IrC '-' -> IrSub
                IrC '*' -> IrDiv
                IrC '/' -> IrMul
   in (IrXYZ opcode x y z)

umComando :: MeuParser IrInstr
umComando =
   try     (do { x <- umID; umC '='; y <- umRval; op <- ehBinOp; z <- umRval;                   return (geraBinOp op x y z) })
   <|> try (do { x <- umID; umC '='; umC '-'; y <- umRval;                                      return (IrXY IrNeg (geraOpId x) y) })
   <|> try (do { x <- umID; umC '='; eh IrNEW; eh IrBYTE; y <- umRval;                          return (IrXY IrNewByte (geraOpId x) y) })
   <|> try (do { x <- umID; umC '='; eh IrNEW; y <- umRval;                                     return (IrXY IrNew (geraOpId x) y) })
   <|> try (do { x <- umID; umC '='; y <- umRval; umC '['; z <- umRval; umC ']';                return (IrXYZ IrSetIdx (geraOpId x) y z) })
   <|> try (do { x <- umID; umC '['; y <- umRval; umC ']'; umC '='; z <- umRval;                return (IrXYZ IrIdxSet (geraOpId x) y z) })
   <|> try (do { x <- umID; umC '='; eh IrBYTE; y <- umRval; umC '['; z <- umRval; umC ']';     return (IrXYZ IrSetIdxByte (geraOpId x) y z) })
   <|> try (do { x <- umID; umC '['; y <- umRval; umC ']'; umC '='; eh IrBYTE; z <- umRval;     return (IrXYZ IrIdxSetByte (geraOpId x) y z) })
   <|> try (do { x <- umID; umC '='; eh IrBYTE; y <- umRval;                                    return (IrXY IrSetByte (geraOpId x) y) })
   <|> try (do { x <- umID; umC '='; y <- umRval;                                               return (IrXY IrSet (geraOpId x) y) })
   <|> try (do { eh IrIF; x <- umRval; eh IrGOTO; y <- umLABEL;                                 return (IrXY IrIf x (IrOpLabel y)) })
   <|> try (do { eh IrIFFALSE; x <- umRval; eh IrGOTO; y <- umLABEL;                            return (IrXY IrIfFalse x (IrOpLabel y)) })
   <|> try (do { eh IrGOTO; x <- umLABEL;                                                       return (IrX IrGoto (IrOpLabel x)) })
   <|> try (do { eh IrPARAM; x <- umRval;                                                       return (IrX IrParam x) })
   <|> try (do { eh IrCALL; x <- umID;                                                          return (IrX IrCall (IrOpFuncao x)) })
   <|> try (do { eh IrRET; x <- umRval;                                                         return (IrX IrRetVal x) })
   <|> try (do { eh IrRET;                                                                      return (IrR IrRet) })

analiseSintatica :: [IrToken] -> Either ParseError Ir
analiseSintatica tokens = parse programa "" tokens
