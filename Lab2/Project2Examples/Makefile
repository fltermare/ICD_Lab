all: 
	yacc -d -v parser.y
	lex scanner.l
	gcc lex.yy.c y.tab.c -ly -lfl -o parser
clean:
	rm -f lex.yy.c y.tab.h y.tab.c y.output parser
