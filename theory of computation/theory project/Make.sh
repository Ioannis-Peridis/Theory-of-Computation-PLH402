#!/bin/bash

bison -d --debug -v -r all  myparser.y 
flex lexer.l
gcc -o compiler.out lex.yy.c myparser.tab.c cgen.c -lfl 
if  [ $1 -eq '1' ]
then
    echo "#include \"kappalib.h\"" > test_comp_second.c
    ./compiler.out<test_comp_second.th >> test_comp_second.c
else
    echo "#include \"kappalib.h\"" > test_comp.c
    ./compiler.out<test_comp.th >> test_comp.c
fi
rm ./compiler.out
rm lex.yy.c myparser.tab.c myparser.tab.h myparser.output
