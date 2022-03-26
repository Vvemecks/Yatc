# Yatc
Yet Another Toy Compiler

## 概述
抽象语法树是联系语法制导翻译与中间代码生成的关键，需要先定义抽象语法树结构才能在 `bison` 中编写语义规则，之后对抽象语法树每个节点实现 `codegen()` 方法，就可以输出 `LLVM IR`

## 抽象语法树
对于抽象语法树，以函数原型为例，其节点定义如下
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
