/*Jamie Grasley #1164621 on MacOS*/
%{
#include "y.tab.h"
#include <stdio.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yyparse(void);
char str[1024];
%}
%%/*Tab and comment handling*/
[ \t]+               {}
"//".*               {}
("+")                {return ADD;}/*Token handling*/
("-")                {return SUB;}
("*")                {return MULT;}
("/")                {return DIV;}
("<")                {return LES;}
(">")                {return GRE;}
("<=")               {return LEQ;}
(">=")               {return GEQ;}
("==")               {return COMP;}
("=")                {return ASSIGN;}
("!=")               {return NEQ;}
("(")                {return LBR;}
(")")                {return RBR;}
(";")                {return SEMICOLON;}
("if")               {return IF;}
("then")             {return THEN;}
("else")             {return ELSE;}
("print")            {return PRINT;}
("newline")          {return NEWLINE;}
("stop")             {return STOP;}
("endif")            {return ENDIF;}
[0-9]+               {yylval.intval = atoi(yytext); return INT;}
\"[^\"]*\" { 
    strncpy(str, &(yytext[1]), strlen(yytext)-2);
    str[strlen(yytext)-2] = (char) 0;
    yylval.strval = strdup(str);
    return STR;
}/*String Handling*/
[a-zA-Z][a-zA-Z0-9]* {
     strncpy(str, &(yytext[1]), strlen(yytext));
     yylval.strval = strdup(str);
     return IDENT;}/*Identifier handling*/
\n
. {}/*Unrecognized input*/                   
%%



int main()
{
     yyparse();
     return 0;
}

int yywrap(void)
{
     return 1;
}
