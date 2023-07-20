%{

//CODE IN C

	#include <stdio.h>
	#include <string.h>
	#include "cgen.h"
	int line_num = 1;
	#define KW_ADD_SUB 1
	#define KW_AND 2
	#define KW_ASSIGNMENT 3
	#define KW_BOOLEAN 4
	#define KW_BREAK 5
	#define KW_COMMA 6
	#define KW_COMMENT 7
	#define KW_COMMENT_VALUE 8
	#define KW_CONSTANT 9
	#define KW_CONTINUE 10
	#define KW_DOT 11
	#define KW_DOUBLE_DOT 12
	#define KW_ELSE 13
	#define KW_ENDFOR 14
	#define KW_ENDIF 15
	#define KW_ENDWHILE 16
	#define KW_EQUAL 17
	#define KW_EQ_NEQ 18
	#define KW_FOR 19
	#define KW_FUNCTION_END 20
	#define KW_FUNCTION_RETURN_TYPE 21
	#define KW_FUNCTION_START 22
	#define KW_IDENTIFIER 23
	#define KW_IF 24
	#define KW_IMPLEMENTED_FUNCTION 25
	#define KW_IN 26
	#define KW_INTEGER 27
	#define KW_LEFT_ARRAY 28
	#define KW_LEFT_BRACKET 29
	#define KW_MAIN 30
	#define KW_MUL_DIV_MOD 31
	#define KW_NOT 32
	#define KW_OR 33
	#define KW_POWER 34
	#define KW_REAL 35
	#define KW_RELATIONAL 36
	#define KW_RETURN 37
	#define KW_RIGHT_ARRAY 38
	#define KW_RIGHT_BRACKET 39
	#define KW_SEMICOLON 40
	#define KW_SPACE 41
	#define KW_STRING 42
	#define KW_WHILE 43
	
	
%}

%x comment 

IDENTIFIER 	[a-zA-Z][0-9a-zA-Z_]*
INTEGER  	([0])|([1-9][0-9]*)
REAL	        {INTEGER}"."[0-9]+([eE][-+]?[0-9]+)?
STRING  	[\"]([\\n\\t\\r\\\"\.\, a-zA-Z0-9\-+*/:_%!#@&~^()]+)[\"]
SPACE		[ \r\t\n]

%%

 //RULES:PATERN-ACTION
 
"/*"       { BEGIN(comment);      // enter the exclusive condition if you find opening
 	     return KW_COMMENT; }
<comment>.                        //do nothing   
<comment>"*/" BEGIN(INITIAL);     // get out of the exclusive condition when you find closing

"--"       { BEGIN(comment);      // enter the exclusive condition if you find a line 
             return KW_COMMENT; }
<comment>.                        //do nothing  
<comment>"\n" BEGIN(INITIAL);     // get out of the exclusive condition when you change line

"integer"  { return KW_INTEGER; }
"scalar"   { return KW_REAL; }
"str"	   { return KW_STRING; }
"boolean"  { return KW_BOOLEAN; }
"const"    { return KW_CONSTANT; }
"True"|"False" { return KW_BOOLEAN; }
"if"       { return KW_IF; }
"else"     { return KW_ELSE; }
"endif"    { return KW_ENDIF; }
"for"      { return KW_FOR; }
"in"	   { return KW_IN; }
"endfor"   { return KW_ENDFOR; }
"while"    { return KW_WHILE; }
"endwhile" { return KW_ENDWHILE; }
"break"    { return KW_BREAK; }
"continue" { return KW_CONTINUE; }
"not"      { return KW_NOT; }
"and"      { return KW_AND; }
"or"       { return KW_OR; }
"def"      { return KW_FUNCTION_START; }
"enddef"   { return KW_FUNCTION_END; }
"->"       { return KW_FUNCTION_RETURN_TYPE; }
"main"     { return KW_MAIN; }
"return"   { return KW_RETURN; }

"+"|"-"     { return KW_ADD_SUB; }            
"*"|"/"|"%" { return KW_MUL_DIV_MOD; }			
"**"        { return KW_POWER; }
"=="|"!="   { return KW_EQ_NEQ;}
"<"|"<="|">"|">=" { return KW_RELATIONAL; }                 				
"+="|"-="|"*="|"/="|"%=" { return KW_ASSIGNMENT;}	
"."  { return KW_DOT; }							
":"  { return KW_DOUBLE_DOT; }
"="  { return KW_EQUAL; }
";"  { return KW_SEMICOLON; }
","  { return KW_COMMA; }
"("  { return KW_LEFT_BRACKET; }
")"  { return KW_RIGHT_BRACKET; }
"["  { return KW_LEFT_ARRAY; }
"]"  { return KW_RIGHT_ARRAY; }
 
{STRING}      { return KW_STRING; }
{IDENTIFIER}  { return KW_IDENTIFIER; }
{INTEGER}     { return KW_INTEGER; }
{REAL}        { return KW_REAL; }

\n      { line_num ++; } //increase line number wehn you find new line
{SPACE} { return KW_SPACE;}
"\\*" 	
<<EOF>>  return 0; //end of file return 0
.        printf("Error  in line: %d\n", line_num); //for any other character-error


%%
 //USER CODE 
 
int main(){

    int token;
    while((token=yylex()) !=0 ){
        printf("Line %3d Token %2d: %s \n", line_num, token, yytext);  
    }
    return 0;
}




 
