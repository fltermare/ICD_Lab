%{
#include <stdio.h>
#include <stdlib.h>

extern int linenum;             /* declared in lex.l */
extern FILE *yyin;              /* declared by lex */
extern char *yytext;            /* declared by lex */
extern char buf[256];           /* declared in lex.l */
%}

%token ',' ';' ':' '(' ')' '[' ']' ADD SUB MUL DIV MOD ASSIGN GT GE GL LE LT EQ AND OR NOT ARRAY BEG BOOLEAN DEF
DO ELSE END FALSE FOR INTEGER IF OF PRINT READ REAL STRING THEN TO TRUE RETURE VAR WHILE
BS BSS BSSS DEF

%%

program		: ID ';' programbody END ID
            ;


programbody	: var_d func_d compound_state
            ;


var_d		: VAR id_list ':' scalar_type ';' var_d
            | VAR id_list ':' ARRAY INT TO INT OF scalar_type ';' var_d
            | VAR id_list ':' literal_constant ';' var_d
            |
            ;

id_list		: ID ',' id_list
            | ID
            ;

scalar_type	: INTEGER
            | REAL
            | STRING
            | BOOLEAN
            ;

literal_constant    : INT
                    | OCT
                    | SCI
                    | FLOAT
                    | STRING
                    | FALSE
                    | TRUE
                    ;

func_d      : ID '(' func ')' ':' scalar_type ';' compound_state END ID func_d
            | 
            ;
        
compound_state  : BEGI var_d state EN
                |
                ;

state   : ID ASSIGN expr ';' state
        | ID ';' state BEGI state EN EN ID
    //  | IF boolean_expr THEN state ELSE state EN IF state
        | IF boolean_expr THEN state EN IF state
        | WHILE boolean_expr DO state EN DO state
        | FOR ID ASSIGN INT TO INT DO state EN DO state
        | RETURN expr ';'
        | ID '(' func ')' scalar_type ';' state
        | ID '(' func ')' ';' state
        | compound_state
        | PRINT str ';'  state
        | PRINT expr ';' state
        | PRINT ID ';' state
        | READ str ';' state
        | READ expr ';' state
        | READ ID ';' state
        | var_d state state
        |
        ;

func    : ID_list ':' scalar_type ';' func
        | ID_list ':' scalar_type
        |
        ;

num     : INT
        | OCT
        | SCI
        | FLOAT
        ;

control : ADD
        | SUB
        | MUL
        | DIV
        | MOD
        ;

expr    : SUB num
        | expr control expr
        | '(' expr ')' control '(' expr ')'
        | '(' expr ')' control num
        | expr control '(' expr ')'
        | num
        | ID
        | ID '(' expr_f ')' 
        ;

expr_f  : expr ',' expr_f
        | expr
        ;

boolean_expr	: expr GT expr
                | expr LT expr
                | expr EQ expr
                | expr GE expr
                | expr LE expr
                | expr GL expr
                | expr AND expr
                | expr OR expr
                | NOT expr
                ;

str	    : BS str_c BSSS
        ;

str_c   : BSS str_c
        | BSS
        ;

%%

int yyerror( char *msg )
{
    fprintf( stderr, "\n|--------------------------------------------------------------------------\n" );
    fprintf( stderr, "| Error found in Line #%d: %s\n", linenum, buf );
    fprintf( stderr, "|\n" );
    fprintf( stderr, "| Unmatched token: %s\n", yytext );
    fprintf( stderr, "|--------------------------------------------------------------------------\n" );
    exit(-1);
}

int  main( int argc, char **argv )
{
    if( argc != 2 ) {
        fprintf(  stdout,  "Usage:  ./parser  [filename]\n"  );
        exit(0);
    }

    FILE *fp = fopen( argv[1], "r" );
	
    if( fp == NULL )  {
        fprintf( stdout, "Open  file  error\n" );
        exit(-1);
    }

    yyin = fp;
    yyparse();
	
    fprintf( stdout, "\n" );
    fprintf( stdout, "|--------------------------------|\n" );
    fprintf( stdout, "|  There is no syntactic error!  |\n" );
    fprintf( stdout, "|--------------------------------|\n" );
    exit(0);
}

