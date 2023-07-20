flex lexer_temp.l
gcc -o lex.out lex.yy.c -lfl
./lex.out<test.in
rm ./lex.out
rm lex.yy.c 
