#!/bin/bash

dir="$HOME/ac/puc-rio/comp/trab4/testes"

[ -d "$dir" ] || {
   echo "Edite o script e altere a variavel dir para o seu diretorio de testes!"
   exit 1
}

output=/dev/stdout
redir=

for((;;))
do
   if [ "$1" == "--summary" ]
   then
      summary=yes
      output=/dev/null
      shift
   elif [ "$1" == "--assign" ]
   then
      dir="$dir/assignments"
      shift
   elif [ "$1" == "--redir" ]
   then
      redir=yes
      shift
   else
      break
   fi
done

[ -x "$1" ] || {
   echo "Argumento faltando!"
   echo "Uso: $0 [--redir] [--assign] [--summary] <programa>"
   echo "--assign   testa o subdiretorio assignments/"
   echo "--summary  roda tudo em lote e gera o resumo"
   echo "--redir    roda os programas dos alunos que nao aceitam parametro >:("
   exit 1
}

oks=0
fails=0

for i in $dir/*.m0
do
   [ "$summary" ] || {
      echo
      echo
      echo
      echo "--------------------------------------------------------------------------"
      echo $i
      echo "--------------------------------------------------------------------------"
      cat -n $i
      echo "--------------------------------------------------------------------------"
   }

   if [ "$redir" ]
   then
      $1 < $i &> $output
      ret=$?
   else
      $1 $i &> $output
      ret=$?
   fi
   echo "------------------------------------------------------------------------" &> output
   echo -en "$i\t\t"

   if echo $i | grep -q fail
   then
      if [ $ret = 0 ]
      then
         echo "FAIL"
         fails=$[fails+1]
      else
         echo "ok"
         oks=$[oks+1]
      fi
   else
      if [ $ret = 0 ]
      then
         echo "ok"
         oks=$[oks+1]
      else
         echo "FAIL"
         fails=$[fails+1]
      fi
   fi
   [ "$summary" ] || {
      read
   }
done

[ "$summary" ] && {
   echo -e "OK's:\t$oks"
   echo -e "Fails:\t$fails"
}

