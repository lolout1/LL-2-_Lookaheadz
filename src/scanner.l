
/* definitions */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tokendef.h"

/* scancol tracks where we currently are in the line.
   yycol gets set to where the current token STARTS before we advance. */
int scancol = 1;
int yycol = 1;
int scanlineno = 1;

/* saved position for where a comment begins (for unterminated errors) */
int comment_start_line;
int comment_start_col;

/* error message string passed to driver.c */
char *yyerror;

void updateCol();
void countLines();
int processString();
%}

 /* exclusive start condition for block comments */
%x COMMENT

 /* pattern definitions */
newline       \r?\n
whitespace    [\t ]+
integer       0|[1-9][0-9]*
integerlead0  0[0-9]+
character     \'([^\\\n\']|\\[nt\"\\])\'
string        \"([^\\\n\"]|\\.)*\"
untermstring  \"([^\\\n\"]|\\.)*\n
identifier    [A-Za-z][A-Za-z0-9]*
illidentifier [0-9]+[A-Za-z]+[A-Za-z0-9]*

%%

 /* keywords must appear before the identifier rule so that flex
    picks these first when both match the same length */
"if"        { updateCol(); return KWD_IF; }
"else"      { updateCol(); return KWD_ELSE; }
"while"     { updateCol(); return KWD_WHILE; }
"int"       { updateCol(); return KWD_INT; }
"string"    { updateCol(); return KWD_STRING; }
"char"      { updateCol(); return KWD_CHAR; }
"return"    { updateCol(); return KWD_RETURN; }
"void"      { updateCol(); return KWD_VOID; }

 /* multi-character operators (checked before single-char versions) */
"++"    { updateCol(); return OPER_INC; }
"--"    { updateCol(); return OPER_DEC; }
"&&"    { updateCol(); return OPER_AND; }
"||"    { updateCol(); return OPER_OR; }
"<="    { updateCol(); return OPER_LTE; }
">="    { updateCol(); return OPER_GTE; }
"=="    { updateCol(); return OPER_EQ; }
"!="    { updateCol(); return OPER_NEQ; }

 /* single-character operators */
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

 /* punctuation */
"["     { updateCol(); return LSQ_BRKT; }
"]"     { updateCol(); return RSQ_BRKT; }
"{"     { updateCol(); return LCRLY_BRKT; }
"}"     { updateCol(); return RCRLY_BRKT; }
"("     { updateCol(); return LPAREN; }
")"     { updateCol(); return RPAREN; }
","     { updateCol(); return COMMA; }
";"     { updateCol(); return SEMICLN; }

 /* identifiers and illegal identifiers */
{identifier}    { updateCol(); return ID; }
{illidentifier} { updateCol(); yyerror = "Illegal token"; return ERROR; }

 /* integer constants and leading-zero errors */
{integer}       { updateCol(); return INTCONST; }
{integerlead0}  { updateCol(); yyerror = "Illegal token"; return ERROR; }

 /* character constants */
{character}     { updateCol(); return CHARCONST; }

 /* string constants: valid strings go through processString() which
    checks escape sequences and converts them. unterminated strings
    hit a newline before the closing quote. */
{string}        { updateCol(); return processString(); }
{untermstring}  {
    yycol = scancol;
    yylineno = scanlineno;
    /* walk through the text to properly handle the newline at the end */
    for(int i = 0; i < yyleng; i++){
        if(yytext[i] == '\n'){
            scanlineno++;
            scancol = 1;
        } else {
            scancol++;
        }
    }
    yyerror = "Unterminated string";
    return ERROR;
}

 /* block comments: enter the COMMENT state on "/*", exit on "*\/" */
"/*"    {
    comment_start_line = scanlineno;
    comment_start_col = scancol;
    scancol += yyleng;
    BEGIN(COMMENT);
}
<COMMENT>"*/"   { scancol += yyleng; BEGIN(INITIAL); }
<COMMENT>\n     { scanlineno++; scancol = 1; }
<COMMENT>.      { scancol++; }
<COMMENT><<EOF>> {
    /* switch back to INITIAL so the next yylex() call returns 0 (EOF) cleanly
       instead of re-triggering this handler in an infinite loop */
    BEGIN(INITIAL);
    yycol = comment_start_col;
    yylineno = comment_start_line;
    yyerror = "Unterminated comment";
    return ERROR;
}

 /* whitespace and newlines: consume without returning a token */
{newline}       { countLines(); }
{whitespace}    { scancol += yyleng; }

 /* anything else is illegal */
.   { updateCol(); return ILLEGAL_TOK; }

%%

/* user routines */

/* save the start column of the current token, then advance the
   scanner position past it. this way yycol always holds the column
   where the token begins, which is what the driver prints. */
void updateCol(){
    yycol = scancol;
    yylineno = scanlineno;
    scancol += yyleng;
}

/* walk through yytext character by character, incrementing the
   line number on each newline and resetting the column. used
   for newlines and any multi-line matched text. */
void countLines(){
    for(int i = 0; i < yyleng; i++){
        if(yytext[i] == '\n'){
            scanlineno++;
            scancol = 1;
        } else {
            scancol++;
        }
    }
    yylineno = scanlineno;
}

/* process a string literal: strip the surrounding quotes, convert
   valid escape sequences into their actual characters, and flag
   any unrecognized escapes as errors. */
int processString(){
    char buffer[4096];
    int j = 0;

    /* iterate from 1 to yyleng-2 to skip the opening and closing quotes */
    for(int i = 1; i < yyleng - 1; i++){
        if(yytext[i] == '\\'){
            i++;
            switch(yytext[i]){
                case 'n':  buffer[j++] = '\n'; break;
                case 't':  buffer[j++] = '\t'; break;
                case '"':  buffer[j++] = '"';  break;
                case '\\': buffer[j++] = '\\'; break;
                default:
                    /* adjust yycol to point at the bad escape character */
                    yycol += i;
                    yyerror = "Unrecognized escape character in String";
                    return ERROR;
            }
        } else {
            buffer[j++] = yytext[i];
        }
    }

    buffer[j] = '\0';
    strcpy(yytext, buffer);
    return STRCONST;
}
