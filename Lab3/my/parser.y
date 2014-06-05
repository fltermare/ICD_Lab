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
extern int Opt_D;
int level_flag = 0;     // indicate which level
int global_flag = 0;
char* id_flag;
char* id_current;       // record current array varialbe parameter id [used in array]
int func_type = 0;      // in func_del  0 no : 1 yes
int func_para = 0;      // in func_del  0 no : 1 yes
int func_comp = 0;      // in func_del  0 no : 1 yes
int decl_type = 0;      // in decl ?    0 no : 1~3 yes
int para_num = 0;       // number of parameters
int is_array = 0;       // is array or not
int array_order = 0;    // which array element
int a_f = 0;            // first array int_const
int a_s = 0;            // second array int_const
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

int newsymtable(int level_f)
{
    symtable *ptr;
    ptr = (symtable*) malloc(sizeof(symtable));
    ptr->entry = (symrec*) malloc(sizeof(symrec));
    ptr->symtable_level = level_f;
    ptr->next_table = sym_table;
    
    /*init entry*/
    ptr->entry = (symrec*) 0;

    /*assing sym_table to new postion*/
    sym_table = ptr;
    return 0;
}

int delsymtable(int level_f)
{
    printf("[level_f] : %d\n", level_f);
    printf("[sym level] : %d\n", sym_table->symtable_level);
    
    while(sym_table != (symtable*)0 && sym_table->symtable_level == level_f) {
        // free entry
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
    
        printf("[delsymtable - test]\n");

        // free table 
        symtable *tmp1;
        tmp1 = sym_table;
        sym_table = sym_table->next_table;
        free(tmp1->entry);
        free(tmp1);
    
    }
    
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
    ptr->attribute = (char*) malloc(strlen(sym_attribute)+100);
   
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
symrec* searchsym( char* sym_name, int sym_level)
{
    //printf("[searchsym]\n");
    
    symrec *ptr;
    symtable *ptrr;

    //get current level
    
    // go through this table and entry
    
    ptrr = sym_table;
    while(ptrr != (symtable*)0 && ptrr->symtable_level == sym_level) {
        for(ptr = ptrr->entry; ptr != (symrec*) 0; ptr = ptr->next) {
            if(strcmp(ptr->name, sym_name) == 0) {
                return ptr;
            }
        }
        ptrr = ptrr->next_table;
    }
   /* 
    for(ptrr = sym_table; ptrr->symtable_level == tmp; ptrr = ptrr->next_table) {
        for(ptr = ptrr->entry; ptr != (symrec*) 0; ptr = ptr->next) {
            if(strcmp(ptr->name, sym_name) == 0) {
                return ptr;
            }
        }
    }
    
    
    for(ptr = sym_table->entry; ptr != (symrec*) 0; ptr = ptr->next)
        if(strcmp(ptr->name, sym_name) == 0)
            return ptr;
    */

    // not found
    return 0;
}
///////

///////**API
install( char* sym_name, int sym_level, char* sym_kind, char* sym_type, char* sym_attribute)
{
    //printf("[install]\n");
    
    symrec* s;
    s = searchsym(sym_name, sym_level);
    if(s == 0)
        s = pushsym(sym_name, sym_level, sym_kind, sym_type, sym_attribute);
    else {
        yyerror("variable 'sym_name' redeclared");        
    }
    //printf("[install] finish\n");
}

update_type( char* sym_name, int sym_level, char* sym_type)
{
    //printf("[update]\n");

    symrec* s;
    s = getsym(sym_name);
    if(s == 0)
        printf("!!!ERROR - UPDATE_TYPE!!!\n");
    else
        printf("name: %s, level: %d\n", s->name, s->level);
        strcpy(s->type, sym_type);
}
update_array_type_func_1( char* sym_name, int sym_level, int elements)  //update func_type (for array) part1
{
    //printf("[update]\n");
    symrec* s;
    s = getsym(sym_name);
    
    char attr[10] = {0};
    attr[0] = '[';
    sprintf(attr+1, "%d]", elements);
    
    if(s == 0) {
        printf("!!!ERROR - UPDATE_ARRAY_TYPE_0!!!\n");
    } else {
        printf("name: %s, level: %d\n", s->name, s->level);
        strcpy(s->type, attr);
        printf("[update] %s to %s\n", s->name, s->type);
    }
}

update_array_type_func_2( char* sym_name, int sym_level, char* sym_type)  //udpate func_type (for array) part2
{
    //printf("[update]\n");
    symrec* s;
    s = getsym(sym_name);

    char tmp [100];
    
    if(s == 0) {
        printf("!!!ERROR - UPDATE_ARRAY_TYPE_0!!!\n");
    } else {
        printf("name: %s, level: %d\n", s->name, s->level);
        strcpy(tmp, sym_type);
        strcpy(tmp+strlen(tmp), s->type); 
        strcpy(s->type, tmp);
    }
}
update_array_type_p1( char* sym_name, int sym_level, int elements)      //update type(array) part1
{
    //printf("[update]\n");

    symrec* s;
    s = sym_table->entry;
    char attr[10] = {0};
    attr[0] = '[';
    sprintf(attr+1, "%d]", elements);
    char* emp = "___empty___";
    while(s != (symrec*) 0) {
        if(strcmp(emp, s->type) == 0) {
            strcpy(s->type, attr);
            printf("[update] %s to %s\n", s->name, s->type);
        }
        s = s->next;
    }
}

update_array_type_p2( char* sym_name, int sym_level, char* sym_type)    //update type(array) part2
{
    //printf("[update]\n");
    symrec* s;
    s = sym_table->entry;
    char tmp[100];
    
    
    while(s != (symrec*) 0) {
        if((s->type)[0] == '[') {
            strcpy(tmp, sym_type);
            strcpy(tmp+strlen(tmp), s->type);
            strcpy(s->type, tmp);
            printf("[update] %s to %s\n", s->name, s->type);
        }
        s = s->next;
    }
}

update_attr( char* sym_name, int sym_level, char* sym_attribute, int paranum)
{
    printf("[update_attribute]\n");

    symrec* s;
    s = getsym(sym_name);
    char* emp = "___empty___";
    int i, j;
    for(j = 0; j < paranum; ++j) {
        i = strlen(s->attribute);
    
        printf("%s\n", s->attribute);
        printf("sizeof attribute: %d\n", i); 
        if(s == 0) {
            printf("!!!ERROR - UPDATE_ATTR!!!\n");
        } else {
            printf("name: %s, level: %d\n", s->name, s->level);
            if (strcmp(s->attribute, emp) == 0) {
                strcpy(s->attribute, sym_attribute);
            } else {
                strcpy((s->attribute)+i, sym_attribute);
            }
        }
    }
}

update_attr_array( char* sym_func_name, char* sym_array_name, int sym_level, int paranum)
{
    printf("[update_attribute array version]\n");

    symrec* s;
    symrec* a;
    s = getsym(sym_func_name);
    a = getsym(sym_array_name);
    char* emp = "___empty___";
    int i, j;
     
    for(j = 0; j < paranum; ++j) {
        i = strlen(s->attribute);
    
        printf("%s\n", s->attribute);
        printf("sizeof attribute: %d\n", i); 
        
        if(s == 0) {
            printf("!!!ERROR - UPDATE_ATTR!!!\n");
        } else {
            printf("name: %s, level: %d\n", s->name, s->level);
            if (strcmp(s->attribute, emp) == 0) {
                strcpy(s->attribute, a->type);
            } else {
                strcpy((s->attribute)+i, a->type);
            }
        }
    }
}

update_decl(int sym_level, char* sym_type)
{
    symrec* s;
    s = sym_table->entry;
    char* emp = "___empty___";
    while(s != (symrec*) 0) {
        if(strcmp(s->type, emp) == 0) {
            strcpy(s->type, sym_type);
        }
        s = s->next;
    }
}

update_decl_const_number(int sym_level, char* sym_kind, char* sym_type, int number)
{
    
    symrec* s;
    s = sym_table->entry;
    char* emp = "___empty___";
    char attr[10];
    sprintf(attr, "%d", number);
    while(s != (symrec*) 0) {
        if(strcmp(s->type, emp) == 0) {
            strcpy(s->type, sym_type);
            strcpy(s->kind, sym_kind);
            strcpy(s->attribute, attr);
        }
        s = s->next;
    }
}

update_decl_const_str(int sym_level, char* sym_kind, char* sym_type, char* string)
{
    
    symrec* s;
    s = sym_table->entry;
    char* emp = "___empty___";
    while(s != (symrec*) 0) {
        if(strcmp(s->type, emp) == 0) {
            strcpy(s->type, sym_type);
            strcpy(s->kind, sym_kind);
            strcpy(s->attribute, string);
        }
        s = s->next;
    }
}
context_check( char* sym_name)
{
    if(getsym( sym_name) == 0)
        printf("%s is an undeclared identifier\n", sym_name);
}

void dumpsymbol(int level_f)
{
   // printf("[dumpsymbol]\n");
    if(Opt_D) { 
    int i;
    printf("%-32s\t%-11s\t%-11s\t%-17s\t%-11s\t\n","Name","Kind","Level","Type","Attribute");
    for(i = 0; i < 110; i++)
        printf("-");
    printf("\n");
    
    char* emp = "___empty___";
    symtable* sym_current_table;
    sym_current_table = sym_table;
    while (sym_current_table->symtable_level == level_f) {
        symrec *ptr;
        for(ptr = sym_current_table->entry; ptr != (symrec*) 0; ptr = ptr->next) {
            printf("%-32s\t", ptr->name);
            printf("%-11s\t", ptr->kind);
            if(ptr->level > 0) 
                printf("%d%-10s\t", ptr->level, "(local)");
            else
                printf("%d%-10s\t", ptr->level, "(global)");
            if(strcmp(ptr->type, emp) == 0)
                printf("%-17s\t", "");
            else
                printf("%-17s\t", ptr->type);
            if(strcmp(ptr->attribute, emp) == 0)
                printf("%-11s\t", "");
            else    
                printf("%-11s\t", ptr->attribute);
            printf("\n");
        }
        if(sym_current_table->next_table != (symtable*) 0)
            sym_current_table = sym_current_table->next_table;
        else 
            break;
    }
    
    for(i = 0; i < 110; i++)
        printf("-");
    printf("\n");
    }
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
%token <intValue> OCTAL_CONST
%token SCIENTIFIC
%token <stringValue> STR_CONST

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
                    newsymtable(level_flag);
                    install($1, level_flag, "program", "void", "");
                    //printf("[name]: %s\n", sym_table->entry->name);
                    printf("level : %d\n", level_flag);
                }
			  program_body
			  END ID
                {
                    dumpsymbol(level_flag);
                    delsymtable(level_flag);
                    printf("level : %d\n", level_flag);
                }
			;

program_body    : opt_decl_list 
                  opt_func_decl_list 
                  compound_stmt 
			    ;

opt_decl_list   : {decl_type = 1; }decl_list 
                  {decl_type = 0; }
                | /* epsilon */ 
                ;

decl_list   : decl_list decl 
            | decl 
            ;

decl		: VAR id_list MK_COLON scalar_type MK_SEMICOLON      /* scalar type declaration */
			| VAR id_list MK_COLON array_type  MK_SEMICOLON      /* array type declaration */
			| VAR id_list MK_COLON literal_const MK_SEMICOLON    /* const declaration */
			;

int_const   : INT_CONST
                { 
                    if(is_array) {
                        if(array_order == 1) 
                            a_f = $1;
                        else 
                            a_s = $1;
                    } else {
                        update_decl_const_number(level_flag, "constant", "integer", $1);
                    }
                }
            | OCTAL_CONST
                { 
                    if(is_array) {
                        if(array_order == 1)
                            a_f = $1;
                        else
                            a_s = $1;
                    } else {
                       update_decl_const_number(level_flag, "constant", "octal", $1);
                    }
                }
			;

literal_const		: int_const
                    | OP_SUB int_const
                    | FLOAT_CONST
                    | OP_SUB FLOAT_CONST
                    | SCIENTIFIC
                    | OP_SUB SCIENTIFIC
                    | STR_CONST 
                        {
                            update_decl_const_str(level_flag, "constant", "string", $1);
                        }
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
                    install($1, level_flag, "function", "___empty___", "___empty___");
                    //dumpsymbol(level_flag);
                    printf("[name]: %s\n", sym_table->entry->name);
                    newsymtable(level_flag+1);
                    printf("level : %d\n", level_flag);
                    func_para = 1;
                    decl_type = 1;
                    func_comp = 1;
                }
              opt_param_list
                {
                    decl_type = 1;
                    func_type = 1;
                    func_para = 0;
                }
              MK_RPAREN opt_type MK_SEMICOLON
                {
                    func_type = 0;
                }
			  compound_stmt
			  END ID
                {
                    if(func_comp == 1) {
                       dumpsymbol(level_flag);
                       delsymtable(level_flag);
                       printf("level : %d\n", level_flag);
                       level_flag--;
                       func_comp = 0;
                    } else {
                        printf("!!ERROR-func_comp!!\n");
                    }
                    printf("level : %d\n", level_flag);
                }
			;

opt_param_list	: param_list 
			    | /* epsilon */
    			;

param_list	: param_list MK_SEMICOLON param
			| param
			;

param		: {para_num = 0;} id_list MK_COLON type {para_num = 0;}
			;

id_list		: id_list MK_COMMA ID 
                {
                    printf("[func_para]: %d\n", func_para);
                    printf("[id_decl_type] = %d\n", decl_type);
                     
                    if(decl_type == 1) {

                        id_current = $3;
                        
                        if(func_para == 1) {
                            para_num++;
                            install($3, level_flag+1, "parameter", "___empty___", "___empty___");
                            printf("[para]: %s\n", sym_table->entry->name);
                           // dumpsymbol(level_flag+1);
                        } else {
                            install($3, level_flag, "variable", "___empty___", "___empty___");
                            printf("[vari]: %s\n", sym_table->entry->name);
                           // dumpsymbol(level_flag);
                        }
                    }
                    
                }
			| ID 
                {
                    printf("[func_para]: %d\n", func_para);
                    printf("[id_decl_type] = %d\n", decl_type);
                    
                    if(decl_type == 1) {
                        
                        id_current = $1;
                       
                        if(func_para == 1) {
                            para_num++;
                            install($1, level_flag+1, "parameter", "___empty___", "___empty___");
                            printf("[para]: %s\n", sym_table->entry->name);
                           // dumpsymbol(level_flag+1);
                        } else {
                            install($1, level_flag, "variable", "___empty___", "___empty___");
                            printf("[vari]: %s\n", sym_table->entry->name);
                           // dumpsymbol(level_flag);
                        }
                    }
                }
            ;

opt_type	: MK_COLON type
			| /* epsilon */
			;

type        : scalar_type
            | array_type
            ;

scalar_type	: INTEGER 
                { 
                    if(func_type) {
                        if(is_array) {
                            update_array_type_func_2(id_flag, level_flag, "integer");    
                        } else {
                            update_type(id_flag, level_flag, "integer");
                        }
                    } else {
                        if(func_para) {
                            if(is_array) {
                                update_array_type_p2(id_current, level_flag, "integer");
                                update_attr_array(id_flag, id_current, level_flag, para_num);
                            } else {
                                update_attr(id_flag, level_flag, " integer", para_num);
                            }
                        } else {
                            if(is_array) {
                                update_array_type_p2(id_current, level_flag, "integer");
                            }
                        }
                        update_decl(level_flag, "integer");
                    }
                }
			| REAL
                { 
                    if(func_type) {
                        if(is_array) {
                            update_array_type_func_2(id_flag, level_flag, "real");    
                        } else {
                            update_type(id_flag, level_flag, "real");
                        }
                    } else {
                        if(func_para) {
                            if(is_array) {
                                update_array_type_p2(id_current, level_flag, "real");
                                update_attr_array(id_flag, id_current, level_flag, para_num);
                            } else {
                                update_attr(id_flag, level_flag, " real", para_num);
                            }
                        } else {
                            if(is_array) {
                                update_array_type_p2(id_current, level_flag, "real");
                            }
                        }
                        update_decl(level_flag, "real");
                    }
                }
			| BOOLEAN
                { 
                    if(func_type) {
                        if(is_array) {
                            update_array_type_func_2(id_flag, level_flag, "boolean");    
                        } else {
                            update_type(id_flag, level_flag, "boolean");
                        }
                    } else {
                        if(func_para) {
                            if(is_array) {
                                update_array_type_p2(id_current, level_flag, "boolean");
                                update_attr_array(id_flag, id_current, level_flag, para_num);
                            } else {
                                update_attr(id_flag, level_flag, " boolean", para_num);
                            }
                        } else {
                            if(is_array) {
                                update_array_type_p2(id_current, level_flag, "boolean");
                            }
                        }
                        update_decl(level_flag, "boolean");
                    }
                }
			| STRING
                { 
                    if(func_type) {
                        if(is_array) {
                            update_array_type_func_2(id_flag, level_flag, "string");    
                        } else {
                            update_type(id_flag, level_flag, "string");
                        }
                    } else {
                        if(func_para) {
                            if(is_array) {
                                update_array_type_p2(id_current, level_flag, "string");
                                update_attr_array(id_flag, id_current, level_flag, para_num);
                            } else {
                                update_attr(id_flag, level_flag, " string", para_num);
                            }
                        } else {
                            if(is_array) {
                                update_array_type_p2(id_current, level_flag, "string");
                            }
                        }
                        update_decl(level_flag, "string");
                    }
                }
			;

array_type	:   {
                    is_array = 1;
                    array_order = 1;
                } 
              ARRAY int_const 
                {
                    array_order = 2;
                }
              TO int_const OF
                {
                    array_order = 0;
                    if(a_f > a_s)
                        yyerror("array int_constant error\n");
                    if(func_type) {
                        update_array_type_func_1(id_flag, level_flag, a_s-a_f+1);
                    } else {
                        update_array_type_p1(id_current, level_flag, a_s-a_f+1);
                    }
                }
              type
                {
                    is_array = 0;
                }
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
                        func_comp++;
                        level_flag++;
                        newsymtable(level_flag);    
                    }
                  opt_decl_list
    			  opt_stmt_list
                  END
                    {
                        func_comp--;
                        if(func_comp != 1) {
                            dumpsymbol(level_flag);
                            delsymtable(level_flag);
                            level_flag--;
                        }
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

