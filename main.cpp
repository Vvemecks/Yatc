#include <memory>
#include <iostream>
#include "ast.h"

extern int yyparse();
extern FunctionAST* FnAST;

int main(int argc, char* argv[])
{
    InitializeModule();
    yyparse();

    auto FnIR = FnAST->codegen();
    FnIR->print(errs());
    return 0;
}
