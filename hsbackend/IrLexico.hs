
module IrLexico where

import IrDados
import Text.ParserCombinators.Parsec

stringEscape = 
   do char '\\'
      (char 't' >>= return (char '\t'))
      <|> (char 'n' >>= return (char '\n'))
      <|> (char '\\' >>= return (char '\\'))

stringLetra = satisfy (\c -> (c /= '"') && (c /= '\\') && (c > '\026'))

stringLiteral :: Parser String
stringLiteral = 
   do s <- between (char '"') (char '"') (many (stringLetra <|> stringEscape))
      return (foldr (:) "" s)

identificador :: Parser String
identificador = 
   do c <- ( letter <|> char '_' <|> char '$' )
      cs <- many ( alphaNum <|> char '_' )
      return (c:cs)

palavrasChaves = [
   ("fun", IrFUN),
   ("global", IrGLOBAL),
   ("string", IrSTRING),
   ("new", IrNEW),
   ("ifFalse", IrIFFALSE),
   ("if", IrIF),
   ("goto", IrGOTO),
   ("param", IrPARAM),
   ("call", IrCALL),
   ("ret", IrRET),
   ("byte", IrBYTE),
   ("==", IrEQ),
   ("!=", IrNE),
   ("<=", IrLE),
   (">=", IrGE)
   ]

palavraChave :: Parser IrToken
palavraChave = foldl1 (<|>) (map (\(kw, tk) -> do { try (string kw); return tk }) palavrasChaves)

umLabel :: Parser String
umLabel =
   do c <- char '.'
      cs <- many (alphaNum <|> char '_') 
      return (c:cs)

lexico :: Parser [IrToken]
lexico =
   many ( many (oneOf " \t") >> (
      palavraChave
      <|> do { c <- oneOf "(,):=[]<>+-*/"; return (IrC c) }
      <|> do { n <- many1 digit;           return (IrLITNUM (read n :: Int)) }
      <|> do { s <- stringLiteral;         return (IrLITSTRING s) }
      <|> do { s <- identificador;         return (IrID s) }
      <|> do { l <- umLabel;               return (IrLABEL l) }
      <|> do { many1 (char '\n' >> many (oneOf " \t")); return IrNL }
   ))

analiseLexica :: String -> Either ParseError [IrToken]
analiseLexica entrada = parse lexico "" entrada
