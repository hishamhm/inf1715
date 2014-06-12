
module IrDados where

import Data.Typeable

data IrToken = IrFUN
             | IrGLOBAL
             | IrSTRING
             | IrBYTE
             | IrLABEL String
             | IrID String
             | IrNEW
             | IrIF
             | IrIFFALSE
             | IrGOTO
             | IrPARAM
             | IrCALL
             | IrRET
             | IrNL
             | IrLITSTRING String
             | IrLITNUM Int
             | IrEQ
             | IrNE
             | IrLE
             | IrGE
             | IrC Char
   deriving (Show, Eq)

data IrString = IrString String String
   deriving Show

data IrGlobal = IrGlobal String
   deriving Show

data IrOp = IrOpGlobal String
          | IrOpLocal String
          | IrOpTemp String
          | IrOpLabel String
          | IrOpNumero Int
          | IrOpString String
          | IrOpFuncao String
   deriving (Show, Eq, Ord, Typeable)

data IrInstr = IrX   IrOpcode IrOp
             | IrXY  IrOpcode IrOp IrOp
             | IrXYZ IrOpcode IrOp IrOp IrOp
             | IrR   IrOpcode
   deriving Show

data IrOpcode = IrLabel
              | IrGoto
              | IrParam
              | IrCall
              | IrRetVal
              | IrIf
              | IrIfFalse
              | IrSet
              | IrSetByte
              | IrNeg
              | IrNew
              | IrNewByte
              | IrSetIdx
              | IrSetIdxByte
              | IrIdxSet
              | IrIdxSetByte
              | IrNe
              | IrEq
              | IrLe
              | IrGe
              | IrLt
              | IrGt
              | IrAdd
              | IrSub
              | IrDiv
              | IrMul
              | IrRet
   deriving (Show, Eq)

data IrFuncao = IrFuncao String [String] [IrInstr]
   deriving Show

type Ir = ([IrString], [IrGlobal], [IrFuncao])

