# Yatc
Yet Another Toy Compiler

## 概述
抽象语法树是联系语法制导翻译与中间代码生成的关键，需要先定义抽象语法树结构才能在 `bison` 中编写语义规则，之后对抽象语法树每个节点实现 `codegen()` 方法，就可以输出 `LLVM IR`

当定义好抽象语法树之后，可以直接手动 `new` 一些节点，便于在没有语法分析的情况下检查生成的 `LLVM IR` 是否正确

## 抽象语法树
对于抽象语法树，其每个节点定义本身非常简单，但是需要明白各种继承关系，以函数原型为例，其节点定义如下
```C++
class PrototypeAST {
  std::string Name;
  std::vector<std::string> Args;

public:
  PrototypeAST(const std::string &Name, std::vector<std::string> Args)
      : Name(Name), Args(std::move(Args)) {}

  Function *codegen();
  const std::string &getName() const { return Name; }
};
```
使用 `bison` 进行语法制导翻译时，在 `parser.y` 中对 `YYSTYPE` 使用 `union` 重定义，包含各语法树节点类的指针，如下
```C++
%union {
    NumberExprAST* expr;
    PrototypeAST* prot;
    FunctionAST* func;
    int token;
    std::string *str;
}
```
翻译中的每一步对应的语义规则为创建节点，即对指针初始化、拷贝、删除等操作，对于本程序，翻译的最终结果为指向 `FunctionAST` 对象的指针

## LLVM IR
注意到上述 `PrototypeAST` 中有 `codegen()` 成员，除虚基类节点均有该成员，负责实现 `LLVM IR` 的生成，例如对于整数常量，只需要一行代码
```C++
Value *NumberExprAST::codegen() {
  return ConstantInt::get(*TheContext, APInt(32, Val, true));
}
```
另外，顶层还需要定义如下变量，用于代码生成，其详细含义可以参考 `LLVM` 官方教程
```C++
std::unique_ptr<LLVMContext> TheContext;
std::unique_ptr<Module> TheModule;
std::unique_ptr<IRBuilder<>> Builder;
std::map<std::string, Value *> NamedValues;
```
主函数有四行，分别为初始化上述变量、语法分析、生成 `LLVM IR`、打印输出
```C++
InitializeModule();
yyparse();
auto FnIR = FnAST->codegen();
FnIR->print(errs());
```

## 问题记录
代码编译时需要加上配置选项 `llvm-config --cxxflags --ldflags --system-libs --libs core`，例如
```shell
clang++ -o toy tokens.cpp parser.cpp codegen.cpp main.cpp `llvm-config --cxxflags --ldflags --system-libs --libs core`
```
`bison` 中需要使用 `union` 定义 `YYSTYPE`，早期 `C++` 规定 `union` 中只允许基本类型，`C++ 11` 去除了该限定，但是如果包含的类型有非默认构造函数，例如 `std::string`、`std::unique_ptr` 等，该 `union` 的默认构造函数会被编译器删除，会导致对象构造失败，解决方法是使用指针

## 参考
[My First Language Frontend with LLVM Tutorial](https://llvm.org/docs/tutorial/MyFirstLanguageFrontend/index.html)
