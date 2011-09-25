all:
	flex -o cpp.lex.cc decaflex.lex
	g++ -o decaflex cpp.lex.cc -lfl
clean:
	rm cpp.lex.cc
	rm decaflex
