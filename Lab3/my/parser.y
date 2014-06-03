%{
/**
 * Introduction to Compiler Design by Prof. Yi Ping You
 * Project 2 YACC sample
 */
#include <stdio.h>
#include <stdlib.h>

extern int linenum;		/* declared in lex.l */
extern FILE *yyin;		/* declared by lex */
extern char *yytext;	/* declared by lex */
extern char buf[256];	/* declared in lex.l */


///////**flag
int level_flag = 0;     /* indicate which level */
int global_flag = 0;
char* id_flag;
int func_type = 0;      /* in func_del  0 no : 1 yes*/
int func_para = 0;      /* in func_del  0 no : 1 yes*/
int func_comp = 0;      /* in func_del  0 no : 1 yes*/
///////
///////**symbol table
struct symrec
{
    char *name;
    int level;
    char *kind;
    char *type;
    char *attribute;
    struct symrec *next;

};

struct symtable
{
    struct symrec *entry;
    int symtable_level;
    struct symtable *next_table;
};

typedef struct symrec symrec;
typedef struct symtable symtable;
symtable* sym_table = (symtable*) 0;

//symrec *sym_entry = (symrec*) 0;
//symtable *sym_current_table;
//sym_current_table = sym_table;

int newsymtable()
{
    symtable *ptr;
    ptr = (symtable*) malloc(sizeof(symtable));
    ptr->entry = (symrec*) malloc(sizeof(symrec));
    ptr->symtable_level = level_flag;
    ptr->next_table = sym_table;
    
    /*init entry*/
    ptr->entry = (symrec*) 0;

    /*assing sym_table to new postion*/
    sym_table = ptr;
    return 0;
}

int delsymtable()
{
    /*free entry*/
    symrec *ptr;
    for(ptr = sym_table->entry; ptr != (symrec*) 0; ptr = ptr->next) {
       symrec *tmp;
       tmp = ptr;
       
       free(tmp->name);
       free(tmp->kind);
       free(tmp->type);
       free(tmp->attribute);
       free(tmp);
    }

    /* free table */
    symtable *tmp;
    tmp = sym_table;
    sym_table = sym_table->next_table;
    free(tmp->entry);
    free(tmp);
    return 0;
}

symrec *pushsym( char* sym_name, int sym_level, char* sym_kind, char* sym_type, char* sym_attribute)
{
    //printf("[pushsym]\n");

    symrec *ptr;
    /*malloc*/ 
    ptr = (symrec*) malloc(sizeof(symrec));
    ptr->name = (char*) malloc(strlen(sym_name)+1);
    ptr->kind = (char*) malloc(strlen(sym_kind)+1);
    ptr->type = (char*) malloc(strlen(sym_type)+1);
    ptr->attribute = (char*) malloc(strlen(sym_attribute)+1);
   
    /*assign*/
    strcpy(ptr->name, sym_name);
    strcpy(ptr->kind, sym_kind);
    strcpy(ptr->type, sym_type);
    strcpy(ptr->attribute, sym_attribute);
    ptr->level = sym_level;

    symrec *tmp;
    tmp = sym_table->entry;
    sym_table->entry = ptr;
    ptr->next = tmp;
     
    //printf("[pushsym] finished\n");
    return ptr;
}

symrec *getsym( char* sym_name)
{
    //printf("[getsym]\n");
    symtable *ptr_t;
    symrec *ptr;
    
    /* go through every table and entry */
    for(ptr_t = sym_table; ptr_t != (symtable*) 0; ptr_t = ptr_t->next_table)
        for(ptr = ptr_t->entry; ptr != (symrec*) 0; ptr = ptr->next)
            if(strcmp(ptr->name, sym_name) == 0)
                return ptr;
    /* not found */
    return 0;
}
///////

///////**API
install( char* sym_name, int sym_level, char* sym_kind, char* sym_type, char* sym_attribute)
{
    //printf("[install]\n");
    
    symrec* s;
    s = getsym(sym_name);
    if(s == 0)
        s = pushsym(sym_name, sym_level, sym_kind, sym_type, sym_attribute);
    else {
        yyerror("variable 'blabla' redeclared");        
    }
    //printf("[install] finish\n");
}

update_type( char* sym_name, char* sym_type)
{
    //printf("[update]\n");

    symrec* s;
    s = getsym(sym_name);
    if(s == 0)
        printf("!!!ERROR - UPDATE_TYPE!!!\n");
    else
        strcpy(s->type, sym_type);
}
context_check( char* sym_name)
{
    if(getsym( sym_name) == 0)
        printf("%s is an undeclared identifier\n", sym_name);
}

void dumpsymbol()
{
   // printf("[dumpsymbol]\n");
    
    int i;
    printf("%-32s\t%-11s\t%-11s\t%-17s\t%-11s\t\n","Name","Kind","Level","Type","Attribute");
    for(i = 0; i < 110; i++)
        printf("-");
    printf("\n");
    
    symrec *ptr;
    for(ptr = sym_table->entry; ptr != (symrec*) 0; ptr = ptr->next) {
        printf("%-32s\t", ptr->name);
        printf("%-11s\t", ptr->kind);
        if(ptr->level > 0) 
            printf("%d%-10s\t", ptr->level, "(local)");
        else
            printf("%d%-10s\t", ptr->level, "(global)");
        printf("%-17s\t", ptr->type);
        printf("%-11s\t", ptr->attribute);
        printf("\n");
    }
    
    for(i = 0; i < 110; i++)
        printf("-");
    printf("\n");
}
///////

%}

%union
{
    char* stringValue;
    int intValue;
    float floatValue;
}
%token <stringValue> ID
%token <intValue> INT_CONST
%token <floatValue> FLOAT_CONST

/* tokens */
%token ARRAY
%token BEG
%token <stringValue> BOOLEAN
%token DEF
%token DO
%token ELSE
%token END
%token FALSE
%token FOR
%token <stringValue> INTEGER
%token IF
%token OF
%token PRINT
%token READ
%token REAL
%token RETURN
%token STRING
%token THEN
%token TO
%token TRUE
%token VAR
%token WHILE

/*
%token ID 
%token INT_CONST
%token FLOAT_CONST
*/
%token OCTAL_CONST
%token SCIENTIFIC
%token STR_CONST

%token OP_ADD
%token OP_SUB
%token OP_MUL
%token OP_DIV
%token OP_MOD
%token OP_ASSIGN
%token OP_EQ
%token OP_NE
%token OP_GT
%token OP_LT
%token OP_GE
%token OP_LE
%token OP_AND
%token OP_OR
%token OP_NOT

%token MK_COMMA
%token MK_COLON
%token MK_SEMICOLON
%token MK_LPAREN
%token MK_RPAREN
%token MK_LB
%token MK_RB

/* start symbol */
%start program
%%

program     : ID MK_SEMICOLON 
                {
                    newsymtable();
                    install($1, level_flag, "program", "void", "");
                    //printf("[name]: %s\n", sym_table->entry->name);
                    printf("level : %d\n", level_flag);
                }
			  program_body
			  END ID
                {
                    dumpsymbol();
                    delsymtable();
                    printf("level : %d\n", level_flag);
                }
			;

program_body    : opt_decl_list 
                  opt_func_decl_list 
                  compound_stmt 
			    ;

opt_decl_list   : decl_list
                | /* epsilon */
                ;

decl_list   : decl_list decl
            | decl
            ;

decl		: VAR id_list MK_COLON scalar_type MK_SEMICOLON       /* scalar type declaration */
			| VAR id_list MK_COLON array_type MK_SEMICOLON        /* array type declaration */
			| VAR id_list MK_COLON literal_const MK_SEMICOLON     /* const declaration */
			;

int_const	:	INT_CONST
			|	OCTAL_CONST
			;

literal_const		: int_const
                    | OP_SUB int_const
                    | FLOAT_CONST
                    | OP_SUB FLOAT_CONST
                    | SCIENTIFIC
                    | OP_SUB SCIENTIFIC
                    | STR_CONST
                    | TRUE
                    | FALSE
                    ;

opt_func_decl_list	: func_decl_list
			        | /* epsilon */
        			;

func_decl_list		: func_decl_list func_decl
	        		| func_decl
        			;

func_decl	: ID MK_LPAREN 
                {
                    id_flag = $1;
                    install($1, level_flag, "function", "        ", "       ");
                    printf("[name]: %s\n", sym_table->entry->name);
                    newsymtable();
                    printf("level : %d\n", level_flag);
                    level_flag++;
                    func_type = 1;
                    func_para = 1;
                    func_comp = 1;
                }
              opt_param_list
                {
                    func_para = 0;
                }
              MK_RPAREN opt_type MK_SEMICOLON
                {
                    func_type = 0;
                }
			  compound_stmt
			  END ID
                {
                    printf("END ID: %s\n", $12);
                    dumpsymbol();
                    delsymtable();
                    level_flag--;
                    printf("level : %d\n", level_flag);
                }
			;

opt_param_list	: param_list
			    | /* epsilon */
    			;

param_list	: param_list MK_SEMICOLON param
			| param
			;

param		: id_list MK_COLON type
			;

id_list		: id_list MK_COMMA ID 
                {
                    if(func_para) {
                        install($3, level_flag, "parameter", "        ", "        ");
                        printf("[para]: %s\n", sym_table->entry->name);
                    }
                }
			| ID 
                {
                    if(func_para) {
                        install($1, level_flag, "parameter", "        ", "        ");
                        printf("[para]: %s\n", sym_table->entry->name);
                    }
                }
            ;

opt_type	: MK_COLON type
			| /* epsilon */
			;

type		: scalar_type
			| array_type
			;

scalar_type	: INTEGER 
                { 
                    if(func_type) {
                        //printf("\n[%s]\n\n", id_flag);
                        update_type(id_flag, "integer");
                    }
                }
			| REAL
			| BOOLEAN
			| STRING
			;

array_type	: ARRAY int_const TO int_const OF type
			;

stmt		: compound_stmt 
			| simple_stmt 
			| cond_stmt 
			| while_stmt 
			| for_stmt 
			| return_stmt 
			| proc_call_stmt 
			;

compound_stmt   : BEG 
                    {
                        level_flag++;
                        newsymtable();    
                    }
                  opt_decl_list
    			  opt_stmt_list
                  END
                    {
                        dumpsymbol();
                        delsymtable();
                        level_flag--;
                    }
                ;

opt_stmt_list   : stmt_list
    			| /* epsilon */
	    		;

stmt_list	: stmt_list stmt
			| stmt
			;

simple_stmt	: var_ref OP_ASSIGN boolean_expr MK_SEMICOLON
			| PRINT boolean_expr MK_SEMICOLON
			| READ boolean_expr MK_SEMICOLON
			;

proc_call_stmt	: ID MK_LPAREN opt_boolean_expr_list MK_RPAREN MK_SEMICOLON
                ;

cond_stmt   : IF boolean_expr THEN
              opt_stmt_list
              ELSE
              opt_stmt_list
              END IF
            | IF boolean_expr THEN opt_stmt_list END IF
            ;

while_stmt  : WHILE boolean_expr DO
              opt_stmt_list
              END DO
			;

for_stmt    : FOR ID OP_ASSIGN int_const TO int_const DO
              opt_stmt_list
              END DO
            ;

return_stmt : RETURN boolean_expr MK_SEMICOLON
			;

opt_boolean_expr_list   : boolean_expr_list
                        | /* epsilon */
                        ;

boolean_expr_list   : boolean_expr_list MK_COMMA boolean_expr
                    | boolean_expr
                    ;

boolean_expr        : boolean_expr OP_OR boolean_term
                    | boolean_term
                    ;

boolean_term        : boolean_term OP_AND boolean_factor
                    | boolean_factor
                    ;

boolean_factor      : OP_NOT boolean_factor 
                    | relop_expr
                    ;

relop_expr  : expr rel_op expr
            | expr
            ;

rel_op      : OP_LT
            | OP_LE
            | OP_EQ
            | OP_GE
            | OP_GT
            | OP_NE
			;

expr        : expr add_op term
            | term
            ;

add_op      : OP_ADD
            | OP_SUB
            ;

term        : term mul_op factor
			| factor
			;

mul_op      : OP_MUL
			| OP_DIV
			| OP_MOD
			;

factor      : var_ref
			| OP_SUB var_ref
			| MK_LPAREN boolean_expr MK_RPAREN
			| OP_SUB MK_LPAREN boolean_expr MK_RPAREN
			| ID MK_LPAREN opt_boolean_expr_list MK_RPAREN
			| OP_SUB ID MK_LPAREN opt_boolean_expr_list MK_RPAREN
            | literal_const
			;

var_ref		: ID 
			| var_ref dim
			;

dim			: MK_LB boolean_expr MK_RB
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

