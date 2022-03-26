%{
#include <cstdio>
#include <cstdlib>
#include <string>
#include "ast.h"
extern int yylex();
FunctionAST* FnAST;
void yyerror (const char *s) { fprintf(stderr, "%s\n", s); }
%}

%union {
    NumberExprAST* expr;
    PrototypeAST* prot;
    FunctionAST* func;
    int token;
    std::string *str;
}

%token TINT TRETURN
%token TLPAREN TRPAREN TLBRACE TRBRACE TSEMICOLON

%token <str> TIDENTIFIER
%token <str> TINTEGER

%type <str> ident
%type <expr> value ret_expr
%type <func> func_decl

%start program

%%
program: func_decl { FnAST = $1; }

func_decl: TINT ident TLPAREN TRPAREN TLBRACE ret_expr TRBRACE {
    $$ = new FunctionAST(new PrototypeAST(*$2, {}), $6);
}

ret_expr: TRETURN value TSEMICOLON { $$ = $2; }

ident: TIDENTIFIER { $$ = new std::string(*$1); }

value: TINTEGER { $$ = new NumberExprAST(atoi($1->c_str())); }
%%
