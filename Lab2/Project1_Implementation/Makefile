TARGET = scanner
OBJECT = lex.yy.c 
CC = gcc -g
LEX = flex
LIBS = -lfl

all: lex.yy.c
	$(CC) lex.yy.c -o $(TARGET) $(LIBS)

lex.yy.c: lex.l
	$(LEX) lex.l

clean:
	rm -f $(TARGET) $(OBJECT)

