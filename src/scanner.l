
/* definitions */

%{
#include <stdio.h>
#include <stdlib.h>
#include "tokendef.h"

 /* integers to track line and column numbers */
int scancol = 1;
int yycol = 1;
int scanlineno = 1;

 /* char pointer to pass error messages to driver.c */
char *yyerror;

 /* TODO: functions to update line and column numbers */
void updateCol();
void countLines();

 /* TODO: function to process a string literal */
int processString();

%}

newline       [\r]?[\n] //TODO
whitespace    [\t ]+  //TODO
integer       0|[1-9][0-9]* //TODO
character     \'([^\\\n]|\\[nt\"\\])\' //TODO

 /* String can contain any characters between the double quotes */
 /* other than a newline or unescaped doublequotes */
*/
string      \"([^\\\n]|\\[nt\"\\])*\" //TODO


 /* If the end quote is not found in the same line the string is unterminated */
untermstring //TODO

comment        "/*"([^*]|\*+[^*/])*\*+"/" //TODO
multlncomment   "/*"([^*]|\*+[^*/])*\n //TODO
untermcomment   "/*"([^*]|\*+[^*/])* //TODO

identifier      [A-Za-z][A-Za-z0-9]* //TODO
illidentifier   [0-9]+[A-Za-z]+ //TODO: regular expression for an illegal identifier

yylineno = 1;

%%

 /* rules */

 /* Keywords */
 /* TODO: Support all keywords in mC */

 /* Operators */
 /* TODO: Support all operators in mC */

"++"    { updateCol(); return OPER_INC; }
"--"    { updateCol(); return OPER_DEC; }
"&&"    { updateCol(); return OPER_AND; }
"||"    { updateCol(); return OPER_OR; }
"<="    { updateCol(); return OPER_LTE; }
">="    { updateCol(); return OPER_GTE; }
"=="    { updateCol(); return OPER_EQ; }
"!="    { updateCol(); return OPER_NEQ; }

"+"     { updateCol(); return OPER_ADD; }
"-"     { updateCol(); return OPER_SUB; }
"*"     { updateCol(); return OPER_MUL; }
"/"     { updateCol(); return OPER_DIV; }
"%"     { updateCol(); return OPER_MOD; }
"<"     { updateCol(); return OPER_LT; }
">"     { updateCol(); return OPER_GT; }
"="     { updateCol(); return OPER_ASGN; }
"@"     { updateCol(); return OPER_AT; }
"!"     { updateCol(); return OPER_NOT; }

 /* Identifiers */;
{identifier}    //TODO
{illidentifier} //TODO

 /* Constants */;
{integer}     { updateCol(); return INTCONST; }  //TODO
{integerlead0} {
    updateCol();
    yyerror = "Illegal token";
    return ERROR;
}  //TODO: "Integers may not have leading zeros"
{character}  { updateCol(); return CHARCONST; }   //TODO
{string}        {updateCol(); return processString();}
{untermstring}  {updateCol(); yyerror = "Unterminated string"; return ERROR;}

 /* Comments */
{comment}  { updateCol(); }     //TODO
{untermcomment} {
    yyerror = "Unterminated comment";
    return ERROR;
} //TODO
{multlncomment} { countLines(); } //TODO

 /* Other */
{newline}   { countLines(); }    //TODO
{whitespace}  { updateCol(); }  //TODO
.        {
    updateCol();
{return ILLEGAL_TOK;}
}

%%

/* user routines */

/* TODO:
Implement this function to keep track of column numbers
*/
void updateCol(){
    yycol += yyleng;
}

/* TODO:
Implement this function to keep track of line numbers
*/
void countLines(){
    // TODO(human): Implement this function.
    // It must handle BOTH single newlines and multi-line comments.
    // Walk through yytext (length yyleng), and for each character:
    //   - if it's '\n': increment scanlineno, reset scancol to 1
    //   - otherwise: increment scancol
    // After the loop, sync yylineno = scanlineno
}


/* TODO:
Implement this function to
check for illegal escape sequences in string literals
and
convert valid escape sequences into escaped characters
(string[0] == '\\' and string[1] == 'n', then string[0] should be '\n')
*/
int processString(){
    char buffer[4096];
    int j = 0;

    for(int i = 1; i < yyleng-1; i++){

        if(yytext[i] == '\\'){
            i++;

            switch(yytext[i]){
                case 'n': buffer[j++] = '\n'; break;
                case 't': buffer[j++] = '\t'; break;
                case '"': buffer[j++] = '"'; break;
                case '\\': buffer[j++] = '\\'; break;

                default:
                    yyerror =
                    "Unrecognized escape character in String";
                    return ERROR;
            }
        }
        else{
            buffer[j++] = yytext[i];
        }
    }

    buffer[j] = '\0';
    strcpy(yytext, buffer);

    return STRCONST;
}
