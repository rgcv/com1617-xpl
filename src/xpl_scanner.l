%option c++ yyclass="xpl_scanner" outfile="xpl_scanner.cpp"
%option stack noyywrap yylineno 8bit debug
%{
/* $Id: xpl_scanner.l,v 1.6 2017/04/14 12:19:09 ist181045 Exp $ */
// make relevant includes before including the parser's tab file
#include <string>
#include <cdk/ast/sequence_node.h>
#include <cdk/ast/expression_node.h>
#include "xpl_scanner.h"
#include "xpl_parser.tab.h"

#include <climits>
#include <cmath>

// don't change this
#define yyerror LexerError
%}

    /* Literal rules */
INTEGER    [1-9][0-9]*|"0"
HEX        "0x"[0-9A-Fa-f]+
REAL       [0-9]+"."[0-9]*|"."[0-9]+
EXP        [Ee][-+]?[0-9]+

    /* Other rules */
SINGLES    [-()[\]<>=+*/%;!@?|~&{}.]

%x X_STRING X_COMMENT

%%
    { set_debug(1); }

    /* Comments */
    /* Multi-line nested comments */
"/*"                   yy_push_state(X_COMMENT);
<X_COMMENT>"/*"        yy_push_state(X_COMMENT);
<X_COMMENT>"*/"        yy_pop_state();
<X_COMMENT>.|\n        ;


    /* Single-line comments */
"//".*$                ;



    /* Operators */
    /* Relational operators */
">="                   return tGE;
"<="                   return tLE;
"=="                   return tEQ;
"!="                   return tNE;

    /* I/O operators */
"!!"                   return tPRINTLN;



    /* Keywords */
    /* Literal identifier keywords */
"int"                  return tTYPEINTEGER;
"real"                 return tTYPEREAL;
"string"               return tTYPESTRING;
    
    /* Literals */
"null"                 return tNULL;


    /* Scope keywords */
"public"               return tPUBLIC;
"use"                  return tUSE;


    /* Conditional statement keywords */
"if"                   return tIF;
"else"                 return tELSE;
"elsif"                return tELSIF;


    /* Control statement keywords */
"stop"                 return tSTOP;
"next"                 return tNEXT;
"return"               return tRETURN;


    /* Iteration statement keywords */
"while"                return tWHILE;
"sweep"                return tSWEEP;


    /* Others */
"procedure"            return tPROCEDURE;


    /* Identifiers */
[A-Za-z_][A-Za-z0-9_]* yylval.s = new std::string(yytext); return tIDENTIFIER;



    /* Literals */
    /* Strings */
\"                     yy_push_state(X_STRING); yylval.s = new std::string("");
<X_STRING>\"           yy_pop_state(); return tSTRING;
<X_STRING>\\\"         *yylval.s += yytext + 1;
<X_STRING>.            *yylval.s += yytext;
<X_STRING>\n           yyerror("Newline in string");


    /* Integers */
"0"+{INTEGER}          yyerror("Integers mustn\'t have a single leading 0");
{INTEGER}|{HEX}        {
    short b = yytext[1] && yytext[1] == 'x' ? 16 : 10;
    long l = strtol(yytext, nullptr, b);

    if (l > INT_MAX) yyerror("Integer overflow");
    else if (l < INT_MIN) yyerror("Integer underflow");
    else {
      yylval.i = (int)l;
      return tINTEGER;
    }
}


    /* Reals (safe, flex will match rules above first) */
({REAL}|{INTEGER}){EXP}? yylval.d = strtod(yytext, nullptr); return tREAL;


    /* Others */
    /* Single characters */
{SINGLES}              return *yytext;


    /* Whitespace */
[ \t\n\r]+             ; /* ignore whitespace */


    /* Aliens */
.                      yyerror("Unknown character");

%%
// Very, very dirty hack: flex is a mess generating C++ scanners.
int xpl_scanner::yywrap() { return 1; }