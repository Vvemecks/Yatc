%{
#include <cstdlib>
#include <string>
#include "ast.h"
#include "parser.hpp"

#define KEYWORD_TOKEN(t)    yylval.token = t
#define STRING_TOKEN        yylval.str = new std::string(yytext, yyleng)
%}

%option noyywrap

%%

[ \t\n]                                         ;
"int"                                           KEYWORD_TOKEN(TINT); return TINT;
"return"                                        KEYWORD_TOKEN(TRETURN); return TRETURN;

[a-zA-Z_][a-zA-Z0-9_]*                          STRING_TOKEN; return TIDENTIFIER;
[0-9]+                                          STRING_TOKEN; return TINTEGER;

"("                                             return TLPAREN;
")"                                             return TRPAREN;
"{"                                             return TLBRACE;
"}"                                             return TRBRACE;
";"                                             return TSEMICOLON;

%%
