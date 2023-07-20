%{   
    //PROLOGUE - CODE IN C
    #include <stdio.h>
    #include <string.h>
    #include "cgen.h"
    #include "kappalib.h"

    extern int yylex(void);
    extern int line_num;
%}

//BISON DECLARATIONS

//colection of data types
%union
{
  char* str;
}

%define parse.error verbose

//declarations of terminal types-types that lexer returns:
/* indetifier */
%token <str> KW_IDENTIFIER
/* variables */
%token <str> KW_INTEGER
%token <str> KW_REAL
%token <str> KW_BOOLEAN
%token <str> KW_STRING
%token <str> KW_CONSTANT
/* operators */
//**IMPORTANT **:the lower you get, the higher the operator PRIORITY
%right <str> KW_ASSIGNMENT KW_EQUAL
%left <str> KW_OR
%left <str> KW_AND
%right <str> KW_NOT
%left <str> KW_EQ_NEQ
%left <str> KW_RELATIONAL
%left <str> KW_ADD_SUB
%left <str> KW_MUL_DIV_MOD
%right <str> KW_POWER
%left <str> KW_LEFT_BRACKET KW_RIGHT_BRACKET KW_LEFT_ARRAY KW_RIGHT_ARRAY KW_DOT
/* delimeters */
%token <str> KW_DOUBLE_DOT
%token <str> KW_COMMA
%token <str> KW_SEMICOLON
/* if statement */
%token <str> KW_IF
%token <str> KW_ENDIF
%token <str> KW_ELSE
/* for statment */
%token <str> KW_FOR
%token <str> KW_IN
%token <str> KW_ENDFOR
/* while statment */
%token <str> KW_WHILE
%token <str> KW_ENDWHILE 
/* functions */
%token <str> KW_FUNCTION_START
%token <str> KW_FUNCTION_END
%token <str> KW_FUNCTION_RETURN_TYPE 
%token <str> KW_IMPLEMENTED_FUNCTION
/* other keywords needed */
%token <str> KW_BREAK
%token <str> KW_CONTINUE
%token <str> KW_MAIN
%token <str> KW_RETURN
%token <str> KW_COMMENT
%token <str> KW_COMMENT_VALUE

//declarations of NON-terminal types-types that lexer dosent return:
/* functions */
%type <str> functions_begin
%type <str> functions_end
%type <str> function
/* comments */
%type <str> comments
%type <str> comment_value
/* variables */
%type <str> input_variables
%type <str> data_type
%type <str> kw_identifiers
%type <str> first_function_input
%type <str> function_inputs 
%type <str> kw_arrays
/* constants */
%type <str> constants
/* expresions */
%type <str> expression
%type <str> final_expression
/* statements */
%type <str> statements
/* other keywords needed */
%type <str> break
%type <str> continue
%type <str> return
/* while stament*/
%type <str> while_statement
%type <str> while_statement_beginning
%type <str> while_statement_ending
/* for statement */
%type <str> for_statement
%type <str> for_statement_beginning
%type <str> for_statement_ending
/* if statement */
%type <str> if_statement
%type <str> if_begining
%type <str> else
%type <str> end_if
/* functions body -it is used in every line */
%type <str> function_body 
/* implemented functions */
%type <str> implemented_function
/* main */
%type <str> main
/* programs input - starting the program*/
%start input
/* programs body */
%type <str> programs_body


%% 

// GRAMMAR RULES 

input:  
  %empty 
  | input programs_body  
{ 
  if (yyerror_count == 0) {
     printf("%s\n", $2);
  }
};

/*==================== Variable Data Types ====================*/ 
data_type:
  KW_INTEGER        { $$ = template("int"); }
  | KW_BOOLEAN  { $$ = template("int"); }
  | KW_REAL    { $$ = template("float"); }
  | KW_STRING   { $$ = template("char*"); }
  
/*==================== Programs body i anything that can be writen in the kappa script ==================== */
programs_body:
  function
  | function_body
  
/*==================== Functions ====================*/
//fisrt function input
first_function_input:
  KW_IDENTIFIER KW_DOUBLE_DOT data_type  //x: type
  { $$=template("%s %s", $4, $1); }            //typeC x
  | kw_arrays KW_DOUBLE_DOT data_type    //array[num]: type
  { $$=template("%s %s",$4, $1); }             //typeC array[num]
//function input variables
function_inputs:       
  first_function_input
  | first_function_input KW_COMMA function_inputs//x: type,...
  { $$ = template("%s, %s",$1, $4);} 		       //typeC x,...
//function begining-declaration
functions_begin:  
  KW_FUNCTION_START KW_IDENTIFIER KW_LEFT_BRACKET function_inputs KW_RIGHT_BRACKET KW_FUNCTION_RETURN_TYPE data_type KW_DOUBLE_DOT //def foo(inputs)->return type:
    { $$ = template("%s %s(%s){", $8, $3, $5); }											 //return type foo(inputs){
  | KW_FUNCTION_START KW_IDENTIFIER KW_LEFT_BRACKET function_inputs KW_RIGHT_BRACKET KW_DOUBLE_DOT                                 //def foo(inputs):
    { $$ = template("void %s(%s){", $3, $5);}												 //void foo(inputs){
  | KW_FUNCTION_START KW_IDENTIFIER KW_LEFT_BRACKET  KW_RIGHT_BRACKET KW_DOUBLE_DOT						 //def foo():
    { $$ = template("void %s(){", $3);}													 //void foo(){
  | KW_FUNCTION_START KW_IDENTIFIER KW_LEFT_BRACKET  KW_RIGHT_BRACKET KW_FUNCTION_RETURN_TYPE data_type KW_DOUBLE_DOT              //def foo()->return:
    { $$ = template("%s %s(){",$7, $3);}												 //return type foo(){
//functions ending
functions_end:
  KW_FUNCTION_END KW_SEMICOLON //enddef 
  { $$ = template("}");}       //}
//functions body-anything i can have in a function
function_body:
  { $$ = template("%s", $1);}
  | function_body function_body {$$=template("%s%s", $1,$2);}
  | final_expression
  | statements  
  | comments        
  | constants       
  | input_variables 
//function completed -begin+body+end
function:
  functions_begin function_body functions_end
  { $$ = template("%s\n%s\n%s", $1, $2, $3);}
  | main function_body functions_end
  { $$ = template("%s\n%s\n%s", $1, $2, $3);} 
//implemented function by user or in kappalib.h
implemented_function: 
  KW_IMPLEMENTED_FUNCTION KW_LEFT_BRACKET kw_identifiers KW_RIGHT_BRACKET // ex. write(x...)                                                                            
  { $$ = template("%s(%s)",$1,$3);}					  
  | KW_IMPLEMENTED_FUNCTION KW_LEFT_BRACKET  KW_RIGHT_BRACKET		  //ex. read()
  { $$ = template("%s()",$1);}
  | KW_IDENTIFIER KW_LEFT_BRACKET kw_identifiers KW_RIGHT_BRACKET         //ex. users_function(x...)
  { $$ = template("%s(%s)",$1,$3);}
  | KW_IDENTIFIER KW_LEFT_BRACKET  KW_RIGHT_BRACKET                       //ex.users_function()
  { $$ = template("%s()",$1);}

/*==================== Variables ====================*/
//identifiers
kw_identifiers:
  kw_identifiers KW_COMMA  kw_identifiers { $$ = template("%s, %s", $1, $4); } //x,.. y
  | KW_IDENTIFIER  {$$ = template("%s", $1); }                                       //x
//arrays
kw_arrays:
  KW_IDENTIFIER KW_LEFT_ARRAY KW_INTEGER KW_RIGHT_ARRAY {$$ = template("%s[%s]", $1,$3);}                                     //array[num]
  | kw_arrays KW_COMMA  KW_IDENTIFIER KW_LEFT_ARRAY KW_INTEGER KW_RIGHT_ARRAY {$$ = template("%s, %s[%s]", $1, $4,$6);} //array[num], ..., arraySecond[num2] 
//variables declarations
input_variables:
   kw_identifiers KW_DOUBLE_DOT data_type KW_SEMICOLON { $$ = template("%s %s;\n", $4, $1);} //x, y, z: type
  | kw_arrays KW_DOUBLE_DOT data_type KW_SEMICOLON { $$ = template("%s %s;\n", $4, $1);}     //array[num], array[num2]: type

/*==================== Constants ====================*/
constants:
   KW_CONSTANT KW_IDENTIFIER KW_EQUAL KW_INTEGER KW_DOUBLE_DOT data_type KW_SEMICOLON //const identifier_type = value :data_type;
  { $$ = template("const %s %s = %s;\n", $10, $3, $7);			              //const data_type identifier_type = value;
  | KW_CONSTANT KW_IDENTIFIER KW_EQUAL KW_STRING KW_DOUBLE_DOT data_type KW_SEMICOLON
  { $$ = template("const %s %s = %s;\n", $10, $3, $7); }
  | KW_CONSTANT KW_IDENTIFIER KW_EQUAL KW_BOOLEAN KW_DOUBLE_DOT data_type KW_SEMICOLON
  { $$ = template("const %s %s = %s;\n", $10, $3, $7); }
  | KW_CONSTANT KW_IDENTIFIER KW_EQUAL KW_REAL KW_DOUBLE_DOT data_type KW_SEMICOLON
  { $$ = template("const %s %s = %s;\n", $10, $3, $7); }

/*==================== Expressions ====================*/
//all expresions list
expression:
  KW_IDENTIFIER {$$= template("%s", $1);}
  | kw_arrays {$$=template("%s", $1);}
  | KW_INTEGER {$$= template("%s", $1);}
  | KW_REAL {$$= template("%s", $1);}
  | expression KW_POWER KW_INTEGER { $$= template("%s**%s", $1, $2);}
  | KW_ADD_SUB expression {$$= template("%s%s", $1, $2);}
  | expression KW_MUL_DIV_MOD expression{$$= template("%s%s%s", $1, $2, $3);}
  | expression KW_ADD_SUB expression{$$= template("%s%s%s", $1, $2, $3);}
  | expression KW_RELATIONAL expression {$$= template("%s%s%s", $1, $2, $3);}
  | expression KW_EQ_NEQ expression {$$= template("%s%s%s", $1, $2, $3);}
  | KW_NOT expression {$$=template("!%s", $2);}
  | expression KW_AND expression {$$= template("%s && %s", $1, $3);}
  | expression KW_OR expression {$$= template("%s || %s", $1, $3);}
  | expression KW_ASSIGNMENT expression {$$= template("%s %s %s", $1, $2, $3);}
  | expression KW_EQUAL expression {$$= template("%s %s %s", $1, $2, $3);}
  | KW_LEFT_BRACKET expression KW_RIGHT_BRACKET { $$ = template("(%s)", $2);}
  | expression KW_ASSIGNMENT implemented_function {$$= template("%s %s %s", $1, $2, $3);}
  | expression KW_EQUAL implemented_function {$$= template("%s %s %s", $1, $2, $3);}
//final expression+;
final_expression:
  expression KW_SEMICOLON {$$=template("%s;\n", $1);}
 
/*==================== IF Statements ====================*/
//beggining of if statment
if_begining:
  KW_IF KW_LEFT_BRACKET expression KW_RIGHT_BRACKET  KW_DOUBLE_DOT //if (expression):
  {$$ = template("if(%s){\n", $4);}					 //if(expression){
//else case
else:
  KW_ELSE KW_DOUBLE_DOT 	 //else:
  { $$ = template("}else{\n");}  //}else{
//ending of if statment
end_if:
  KW_ENDIF KW_SEMICOLON	   //endif;
  {$$ = template("}\n");}  //};
//if statment completed  
if_statement:
  if_begining function_body else function_body end_if {$$=template("%s%s%s%s%s", $1, $2, $3, $4, $5);}
  | if_begining function_body end_if {$$=template("%s%s%s", $1, $2, $3);} 
  
/*==================== FOR statement ====================*/
for_statement_beginning:
  KW_FOR KW_IDENTIFIER KW_IN KW_LEFT_ARRAY KW_INTEGER 
    KW_DOUBLE_DOT KW_ADD_SUB KW_INTEGER KW_DOUBLE_DOT KW_INTEGER KW_RIGHT_ARRAY KW_DOUBLE_DOT
  { $$ = template("for (%s=%s; %s<=%s; %s=%s%s%s){\n", $3, $8, $3, $13,  $3, $3, $10, $11);}
  |KW_FOR KW_IDENTIFIER KW_IN KW_LEFT_ARRAY KW_INTEGER 
    KW_DOUBLE_DOT  KW_INTEGER KW_DOUBLE_DOT KW_INTEGER KW_RIGHT_ARRAY KW_DOUBLE_DOT
  { $$ = template("for (%s=%s; %s<=%s; %s=%s+%s){\n", $3, $8, $3, $12,  $3, $3, $10);}
  |KW_FOR KW_IDENTIFIER KW_IN KW_LEFT_ARRAY KW_INTEGER 
    KW_DOUBLE_DOT  KW_INTEGER KW_RIGHT_ARRAY KW_DOUBLE_DOT
  { $$ = template("for (%s=%s; %s<=%s; %s++){\n", $3, $8, $3, $10,  $3);}

for_statement_ending:
  KW_ENDFOR KW_SEMICOLON {$$ = template("}\n");} 

for_statement:
  for_statement_beginning function_body for_statement_ending
  {$$ = template("%s%s%s", $1, $2, $3);}

/*==================== WHILE statement ====================*/
//beggining of while statment 
while_statement_beginning:
  KW_WHILE KW_LEFT_BRACKET expression KW_RIGHT_BRACKET KW_DOUBLE_DOT //while (expression):
  { $$ = template("while(%s){\n", $4);}					   //while(expression){
//ending of while statment
while_statement_ending:
  KW_ENDWHILE KW_SEMICOLON		//endwhile;
  { $$ = template ("}//endwhile\n"); }  //}
//completed while statment
while_statement:
  while_statement_beginning function_body while_statement_ending
  {$$ = template("%s%s%s", $1, $2, $3);}

/*==================== other statements and total====================*/
//break
break:
 KW_BREAK KW_SEMICOLON { $$ = template("break;\n");}
//continue
continue:
  KW_CONTINUE KW_SEMICOLON {$$=template("continue;\n");}
//return
return:
  KW_RETURN KW_SEMICOLON {$$=template("return;\n");}  				//return;
  | KW_RETURN expression KW_SEMICOLON {$$=template("return %s;\n", $3);}	//return expression;
// total list of all statments possible
statements:
  if_statement
  | for_statement
  | while_statement
  | break
  | continue
  | return

/*==================== Comments ====================*/
//comments value
comment_value:
  comment_value KW_COMMENT_VALUE {$$ = template("%s%s", $1, $2);}
  | KW_COMMENT_VALUE {$$ = template("//%s", $1);}
//comment
comments:
  KW_COMMENT {printf(" ");} //Do nothing
  | comments  comment_value { $$ = template("%s\n", $2); }

/*==================== Main() ====================*/
main: 
  KW_FUNCTION_START KW_MAIN KW_LEFT_BRACKET KW_RIGHT_BRACKET KW_DOUBLE_DOT //def main():
  {$$ = template("int main(){");}						 //itn main(){


%%

//EPILOGUE

int main(){
  puts(c_prologue);
  if(yyparse()==0) printf("//Accepted !\n");
  else {
    printf("//Rejected ! \n");
  }
}


