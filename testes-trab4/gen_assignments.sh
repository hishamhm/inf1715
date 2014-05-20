#!/bin/bash

types=("int" "char" "bool" "string" "[]int" "[]char" "[]bool" "[][]int")

seq=100

dir="assignments"

rm -f $dir/*
for to in ${types[@]}
do
   for from in ${types[@]}
   do
      if [ "$to" = "$from" -o "$to$from" = "intchar" -o "$to$from" = "charint" -o "$to$from" = "string[]char" -o "$to$from" = "[]charstring" ]
      then
         fail=""
      else
         fail="fail-"
      fi

      namepattern="$fail$to-$from"
      namepattern="${namepattern//\[\]/v_}"

      file="$dir/$seq-$namepattern.m0"
      echo "fun foo()" >> $file
      echo "   a: $to" >> $file
      echo "   b: $from" >> $file
      echo "   a = b" >> $file
      echo "end" >> $file
      seq=$[seq+1]

      file="$dir/$seq-$namepattern-ret.m0"
      echo "fun foo(v:$from):$to" >> $file
      echo "   return v" >> $file
      echo "end" >> $file
      seq=$[seq+1]

      file="$dir/$seq-$namepattern-retglob.m0"
      echo "glob:$from" >> $file
      echo "fun foo():$to" >> $file
      echo "   return glob" >> $file
      echo "end" >> $file
      seq=$[seq+1]

      file="$dir/$seq-$namepattern-retidx.m0"
      echo "fun foo(v:[]$from):$to" >> $file
      echo "   return v[0]" >> $file
      echo "end" >> $file
      seq=$[seq+1]

   done
done
