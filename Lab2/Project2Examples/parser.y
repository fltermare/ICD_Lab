%{
#include <stdio.h>
#include <stdlib.h>

extern int linenum;             /* declared in lex.l */
extern FILE *yyin;              /* declared by lex */
extern char *yytext;            /* declared by lex */
extern char buf[256];           /* declared in lex.l */
%}

%token ',' ';' ':' '(' ')' '[' ']' ADD SUB MUL DIV MOD ASSIGN GT GE NE LE LT EQ AND OR NOT ARRAY BEG BOOLEAN DEF DO ELSE END FALSE FOR INTEGER IF OF PRINT READ REAL THEN TO TRUE VAR WHILE OCT ID INT FLOAT SCI RETURN BS BSS BSSS STRING

%%

program		: ID ';' programbody END ID
            ;


programbody	: var_d function compound_state
            ;


var_d		: VAR id_list ':' scalar_type ';' var_d
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
            | ARRAY INT TO INT OF scalar_type
            ;

literal_constant    : INT
                    | OCT
                    | SCI
                    | FLOAT
                    | str
                    | FALSE
                    | TRUE
                    ;
function    : func_d function
            | func_p function
            |
            ;

func_d      : ID '(' func ')' ':' scalar_type ';' compound_state END ID
            ;

func_p      : ID '(' func ')' ';' compound_state END ID
            | ID '(' func ')' ';'
            ;

state   : compound_state state 
        | simple_state state
        | conditional_state state
        | while_state state
        | for_state state
        | return_state state
        | func_invocation state
        | 
        ;

func_invocation     : ID '(' func ')' ';' 
                    ;

compound_state      : BEG var_d state END
                    ;

simple_state        : ID ASSIGN boolean_expr ';'
                    | expr ASSIGN boolean_expr ';' 
                    | PRINT ID ';'
                    | PRINT expr ';'
                    | PRINT str ';'
                    | READ ID ';'
                    | READ expr ';'
                    | READ str ';'
                    ;

conditional_state   : IF boolean_expr THEN state END IF 
                    | IF boolean_expr THEN state ELSE state END IF
                    ;
 
while_state         : WHILE boolean_expr DO state END DO
                    ;
                    
for_state           : FOR ID ASSIGN INT TO INT DO state END DO
                    ;

return_state        : RETURN boolean_expr ';'
                    ;


func    : id_list ':' scalar_type ';' func
        | id_list ':' scalar_type
        | expr 
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
        | SUB expr
        | NOT expr
        | expr control expr
//        | '(' expr ')' control '(' expr ')'
//        | '(' expr ')' control num
//        | expr control '(' expr ')'
        | '(' expr ')'
        | num
        | ID
        | ID '(' expr_f ')'
        | ID bracket
        | TRUE
        | FALSE
        ;

bracket : '[' expr ']' bracket;
        |
        ;

expr_f  : expr ',' expr_f
        | expr
        ;

boolean_expr	: '(' boolean_expr ')'
                | expr GT expr boolean_expr2
                | expr LT expr boolean_expr2
                | expr EQ expr boolean_expr2
                | expr GE expr boolean_expr2
                | expr LE expr boolean_expr2
                | expr NE expr boolean_expr2  
                | expr AND expr boolean_expr2
                | expr OR expr boolean_expr2
                | expr
                ;

boolean_expr2   : GT expr boolean_expr2
                | LT expr boolean_expr2
                | EQ expr boolean_expr2
                | GE expr boolean_expr2
                | LE expr boolean_expr2 
                | NE expr boolean_expr2 
                | AND expr boolean_expr2 
                | OR expr boolean_expr2
                |
                ;

str	    : BS str_c BSSS
        ;

str_c   : BSS str_c
        | BSS
        ;
/*
str     : BS BSS BSSS str
        |
        ;
*/
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

