%{

//CODE IN C

	#include <stdio.h>
	#include <string.h>
	#include "cgen.h"
	#include "myparser2.tab.h"
	int line_num = 1;
%}

%x comment 

IDENTIFIER 	[a-zA-Z][0-9a-zA-Z_]*
INTEGER  	([0])|([1-9][0-9]*)
REAL	        {INTEGER}"."[0-9]+([eE][-+]?[0-9]+)?
STRING  	[\"]([\\n\\t\\r\\\"\.\, a-zA-Z0-9\-+*/:_$%!#@&~^()]+)[\"]
SPACE		[ \r\t\n]
LINE_COM	"--"

%%

 //RULES:PATERN-ACTION

{LINE_COM}    { BEGIN(comment); // enter the exclusive condition if you find a line comment
                return KW_COMMENT; }
<comment>.    { yylval.str=strdup(yytext); 
                return KW_COMMENT_VALUE; }
<comment>"\n" BEGIN(INITIAL); // get out of the exclusive condition when you change line

"integer"  { return KW_INTEGER; }
"scalar"   { return KW_REAL; }
"str"	   { return KW_STRING; }
"boolean"  { return KW_BOOLEAN; }
"const"    { return KW_CONSTANT; }
"True"|"False" { yylval.str=strdup(yytext);
                 return KW_BOOLEAN; }
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

"+"|"-"    { yylval.str=strdup(yytext);
              return KW_ADD_SUB; }            
"*"|"/"|"%" { yylval.str=strdup(yytext);
              return KW_MUL_DIV_MOD; }			
"**"        { return KW_POWER; }
"=="|"!="   { yylval.str=strdup(yytext);
              return KW_EQ_NEQ;}
"<"|"<="|">"|">=" { yylval.str=strdup(yytext);
                    return KW_RELATIONAL; }                 				
"+="|"-="|"*="|"/="|"%=" { yylval.str=strdup(yytext);
                           return KW_ASSIGNMENT;}	
"."  { return KW_DOT; }							
":"  { return KW_DOUBLE_DOT; }
"="  { yylval.str=strdup(yytext);
       return KW_EQUAL; }
";"  { return KW_SEMICOLON; }
","  { return KW_COMMA; }
"("  { return KW_LEFT_BRACKET; }
")"  { return KW_RIGHT_BRACKET; }
"["  { return KW_LEFT_ARRAY; }
"]"  { return KW_RIGHT_ARRAY; }


"readStr"|"readInteger"|"readScalar"|"writeStr"|"writeInteger"|"writeScalar"|"write"  { yylval.str = strdup(yytext); 
											return KW_IMPLEMENTED_FUNCTION; } 
 
{STRING}      { yylval.str = strdup(yytext); 
                return KW_STRING; }
{IDENTIFIER}  { yylval.str = strdup(yytext); 
                return KW_IDENTIFIER; }
{INTEGER}     { yylval.str = strdup(yytext); 
                return KW_INTEGER; }
{REAL}        { yylval.str = strdup(yytext); 
                return KW_REAL; }

\n      { line_num ++; } //increase line number wehn you find new line
{SPACE} { yylval.str = strdup(yytext);  
          return KW_SPACE;}
"\\*" 	//when you find comment do nothing
<<EOF>>  return 0; //end of file return 0
.        { yyerror("Lectical Error Occured: Literal Not Recognised '%s'\n", yytext); } //for any other character-error

%%
//USER CODE (empty no needed because we conect to bison)

 
