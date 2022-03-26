tokens: tokens.l
	flex -o tokens.cpp tokens.l
parser: parser.y
	bison -d -o parser.cpp parser.y
toy: tokens.cpp parser.cpp codegen.cpp main.cpp
	clang++ -o toy tokens.cpp parser.cpp codegen.cpp main.cpp `llvm-config --cxxflags --ldflags --system-libs --libs core`
compile:
	./toy < example.c
assembly: example.ll
	llc example.ll
target: example.s
	clang example.s
