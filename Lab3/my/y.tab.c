#include <stdlib.h>
#include <string.h>
#ifndef lint
#ifdef __unused
__unused
#endif
static char const 
yyrcsid[] = "$FreeBSD: release/9.2.0/usr.bin/yacc/skeleton.c 216370 2010-12-11 08:32:16Z joel $";
#endif
#define YYBYACC 1
#define YYMAJOR 1
#define YYMINOR 9
#define YYLEX yylex()
#define YYEMPTY -1
#define yyclearin (yychar=(YYEMPTY))
#define yyerrok (yyerrflag=0)
#define YYRECOVERING() (yyerrflag!=0)
#if defined(__cplusplus) || __STDC__
static int yygrowstack(void);
#else
static int yygrowstack();
#endif
#define YYPREFIX "yy"
#line 2 "parser.y"
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


/*/////**flag*/
extern int Opt_D;
int level_flag = 0;     /* indicate which level*/
int global_flag = 0;
char* id_flag;
char* id_current;       /* record current array varialbe parameter id [used in array]*/
int func_type = 0;      /* in func_del  0 no : 1 yes*/
int func_para = 0;      /* in func_del  0 no : 1 yes*/
int func_comp = 0;      /* in func_del  0 no : 1 yes*/
int decl_type = 0;      /* in decl ?    0 no : 1~3 yes*/
int para_num = 0;       /* number of parameters*/
int is_array = 0;       /* is array or not*/
int array_order = 0;    /* which array element*/
int a_f = 0;            /* first array int_const*/
int a_s = 0;            /* second array int_const*/
/*/////*/
/*/////**symbol table*/
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

/*symrec *sym_entry = (symrec*) 0;*/
/*symtable *sym_current_table;*/
/*sym_current_table = sym_table;*/

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
        /* free entry*/
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

        /* free table */
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
    /*printf("[pushsym]\n");*/

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
     
    /*printf("[pushsym] finished\n");*/
    return ptr;
}

symrec *getsym( char* sym_name)
{
    /*printf("[getsym]\n");*/
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
    /*printf("[searchsym]\n");*/
    
    symrec *ptr;
    symtable *ptrr;

    /*get current level*/
    
    /* go through this table and entry*/
    
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

    /* not found*/
    return 0;
}
/*/////*/

/*/////**API*/
install( char* sym_name, int sym_level, char* sym_kind, char* sym_type, char* sym_attribute)
{
    /*printf("[install]\n");*/
    
    symrec* s;
    s = searchsym(sym_name, sym_level);
    if(s == 0)
        s = pushsym(sym_name, sym_level, sym_kind, sym_type, sym_attribute);
    else {
        yyerror("variable 'sym_name' redeclared");        
    }
    /*printf("[install] finish\n");*/
}

update_type( char* sym_name, int sym_level, char* sym_type)
{
    /*printf("[update]\n");*/

    symrec* s;
    s = getsym(sym_name);
    if(s == 0)
        printf("!!!ERROR - UPDATE_TYPE!!!\n");
    else
        printf("name: %s, level: %d\n", s->name, s->level);
        strcpy(s->type, sym_type);
}
update_array_type_func_1( char* sym_name, int sym_level, int elements)  /*update func_type (for array) part1*/
{
    /*printf("[update]\n");*/
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

update_array_type_func_2( char* sym_name, int sym_level, char* sym_type)  /*udpate func_type (for array) part2*/
{
    /*printf("[update]\n");*/
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
update_array_type_p1( char* sym_name, int sym_level, int elements)      /*update type(array) part1*/
{
    /*printf("[update]\n");*/

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

update_array_type_p2( char* sym_name, int sym_level, char* sym_type)    /*update type(array) part2*/
{
    /*printf("[update]\n");*/
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
   /* printf("[dumpsymbol]\n");*/
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
/*/////*/

#line 445 "parser.y"
typedef union
{
    char* stringValue;
    int intValue;
    float floatValue;
} YYSTYPE;
#line 474 "y.tab.c"
#define YYERRCODE 256
#define ID 257
#define INT_CONST 258
#define FLOAT_CONST 259
#define ARRAY 260
#define BEG 261
#define BOOLEAN 262
#define DEF 263
#define DO 264
#define ELSE 265
#define END 266
#define FALSE 267
#define FOR 268
#define INTEGER 269
#define IF 270
#define OF 271
#define PRINT 272
#define READ 273
#define REAL 274
#define RETURN 275
#define STRING 276
#define THEN 277
#define TO 278
#define TRUE 279
#define VAR 280
#define WHILE 281
#define OCTAL_CONST 282
#define SCIENTIFIC 283
#define STR_CONST 284
#define OP_ADD 285
#define OP_SUB 286
#define OP_MUL 287
#define OP_DIV 288
#define OP_MOD 289
#define OP_ASSIGN 290
#define OP_EQ 291
#define OP_NE 292
#define OP_GT 293
#define OP_LT 294
#define OP_GE 295
#define OP_LE 296
#define OP_AND 297
#define OP_OR 298
#define OP_NOT 299
#define MK_COMMA 300
#define MK_COLON 301
#define MK_SEMICOLON 302
#define MK_LPAREN 303
#define MK_RPAREN 304
#define MK_LB 305
#define MK_RB 306
const short yylhs[] = {                                        -1,
    2,    0,    1,    7,    3,    3,    6,    6,    8,    8,
    8,   13,   13,   12,   12,   12,   12,   12,   12,   12,
   12,   12,    4,    4,   14,   14,   17,   18,   20,   15,
   16,   16,   21,   21,   23,   22,    9,    9,   19,   19,
   24,   24,   10,   10,   10,   10,   25,   26,   27,   11,
   28,   28,   28,   28,   28,   28,   28,   35,    5,   36,
   36,   37,   37,   29,   29,   29,   34,   30,   30,   31,
   32,   33,   40,   40,   41,   41,   39,   39,   42,   42,
   43,   43,   44,   44,   46,   46,   46,   46,   46,   46,
   45,   45,   47,   47,   48,   48,   49,   49,   49,   50,
   50,   50,   50,   50,   50,   50,   38,   38,   51,
};
const short yylen[] = {                                         2,
    0,    6,    3,    0,    2,    0,    2,    1,    5,    5,
    5,    1,    1,    1,    2,    1,    2,    1,    2,    1,
    1,    1,    1,    0,    2,    1,    0,    0,    0,   12,
    1,    0,    3,    1,    0,    4,    3,    1,    2,    0,
    1,    1,    1,    1,    1,    1,    0,    0,    0,    9,
    1,    1,    1,    1,    1,    1,    1,    0,    5,    1,
    0,    2,    1,    4,    3,    3,    5,    8,    6,    6,
   10,    3,    1,    0,    3,    1,    3,    1,    3,    1,
    2,    1,    3,    1,    1,    1,    1,    1,    1,    1,
    3,    1,    1,    1,    3,    1,    1,    1,    1,    1,
    2,    3,    4,    4,    5,    1,    1,    2,    3,
};
const short yydefred[] = {                                      0,
    0,    0,    1,    0,    0,    0,    0,    0,    0,    0,
    0,   26,    0,    0,    8,    2,   27,   58,    3,   25,
   38,    0,    7,    0,    0,    0,    0,   28,    0,   34,
    0,    0,   37,   12,   16,   45,   22,   43,   44,   46,
   21,   13,   18,   20,    0,    0,    0,    0,   14,    0,
    0,   35,    0,    0,    0,    0,    0,    0,    0,    0,
   51,   63,   52,   53,   54,   55,   56,   57,    0,    0,
    0,   17,   19,   15,    9,   10,   11,    0,    0,   33,
    0,    0,    0,    0,    0,    0,    0,  106,    0,    0,
    0,   80,   82,    0,    0,   96,    0,    0,    0,    0,
   59,   62,    0,    0,  108,   48,    0,    0,   41,   42,
   36,    0,    0,    0,    0,    0,    0,    0,    0,   81,
    0,    0,    0,    0,   93,   94,   87,   90,   89,   85,
   88,   86,    0,    0,   97,   98,   99,    0,   65,   66,
   72,    0,    0,    0,    0,   39,   29,    0,    0,    0,
    0,    0,    0,  102,    0,    0,   79,    0,    0,   95,
    0,   64,  109,    0,    0,   67,    0,    0,  104,    0,
  103,    0,    0,    0,    0,    0,    0,  105,    0,   69,
   70,   49,    0,    0,    0,    0,   30,    0,   68,   50,
    0,   71,
};
const short yydgoto[] = {                                       2,
    5,    4,    6,   10,   61,   14,    7,   15,   22,  109,
  110,   88,   49,   11,   12,   28,   24,   51,  108,  165,
   29,   30,   31,  111,   50,  145,  186,   62,   63,   64,
   65,   66,   67,   68,   25,   69,   70,   89,  112,  113,
  114,   91,   92,   93,   94,  133,  134,   95,  138,   96,
  105,
};
const short yysindex[] = {                                   -233,
 -249,    0,    0,    0, -210, -194, -191, -165, -201, -157,
 -194,    0, -147, -191,    0,    0,    0,    0,    0,    0,
    0, -188,    0,    0,    0, -131,   41,    0, -170,    0,
 -147,   82,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0, -184, -148, -139, -124,    0, -115,
 -120,    0, -177, -123,  -71, -239, -239, -239, -239, -239,
    0,    0,    0,    0,    0,    0,    0,    0,  -77,   82,
 -257,    0,    0,    0,    0,    0,    0, -241,  -97,    0,
 -154, -239,  -84,  -93, -245, -239, -239,    0,  -90, -262,
  -85,    0,    0, -134, -171,    0, -236, -225, -219, -243,
    0,    0, -239, -239,    0,    0, -154,  -82,    0,    0,
    0,  -80,  -83,  -66, -241, -239,  -67, -239,  -90,    0,
 -273,   82, -239, -239,    0,    0,    0,    0,    0,    0,
    0,    0, -189, -189,    0,    0,    0, -189,    0,    0,
    0,   82, -217, -276,  -36,    0,    0,  -58, -239,  -24,
  -44, -239, -272,    0, -116,  -85,    0,  -98, -171,    0,
   -4,    0,    0, -241, -157,    0,  -80, -241,    0,  -39,
    0,   82,   -3,    7,    3,    9,   12,    0,   14,    0,
    0,    0,   21,   82,   23, -154,    0,   29,    0,    0,
   37,    0,
};
const short yyrindex[] = {                                      0,
    0,    0,    0, -234,    0,   43,    0,    0,    0,    0,
   44,    0,    0,   16,    0,    0,    0,    0,    0,    0,
    0,    0,    0, -247,   65,    0,   42,    0,    2,    0,
    0,   45,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0, -229,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,  -52,
    0,    0,    0,    0,    0,    0,    0,    0,    5,    0,
   42,    8,    0, -158,    0,    0,    0,    0, -121,    0,
  -19,    0,    0, -197,  -69,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,   42,    0,    0,    0,
    0, -218,    0,   10,    0,    8, -158,    0,  -95,    0,
    0,  -27,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,   45,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    8,    0,    0,    0,   -8,    0,  -34,  -45,    0,
    0,    0,    0,    0,    0,    0, -216,    0,    0,    0,
    0,   45,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,   45,    0,   42,    0,    0,    0,    0,
    0,    0,
};
const short yygindex[] = {                                      0,
    0,    0,  284,    0,  -10,    0,    0,  299,  285,  291,
  292,  294,  -43,    0,  317,    0,    0,    0,    0,    0,
    0,  277,    0,  -99,    0,    0,    0,  260,    0,    0,
    0,    0,    0,    0,    0, -113,    0,  -31,  -53, -100,
    0,  209,  -75,    0,  201,    0,    0,  202,    0,  203,
    0,
};
#define YYTABLESIZE 363
const short yytable[] = {                                      19,
   71,   74,   90,   97,   98,   99,  100,  146,  155,   35,
  120,  117,   34,   72,  122,  151,   34,   84,   34,   35,
  142,  123,    6,    1,  123,  123,    6,   37,  161,  163,
  154,  171,  103,  121,  106,  123,   42,   73,   71,   41,
   42,   74,   42,   43,   44,    4,   85,  104,  157,  143,
  144,  170,    3,  119,  123,    8,   32,  118,  179,   86,
  107,  123,    9,   87,  153,  139,   84,   84,   34,   35,
  188,  150,  123,   34,   72,  107,  140,   37,  123,   84,
  123,   76,  141,   75,  162,   76,  190,   75,   13,   41,
   71,   16,   42,   43,   44,  167,   85,   42,   73,   84,
   84,   17,   84,   18,   84,  107,   84,   36,   84,   21,
   71,   26,   27,   87,   38,  135,  136,  137,  107,   39,
  175,   40,   26,   81,  177,   33,  107,  107,  107,  107,
  107,   52,  107,  107,  107,  107,  107,  107,  107,  107,
   71,  107,  100,  107,   78,  107,  107,  107,  172,  173,
  125,  126,   71,   75,  176,  100,  127,  128,  129,  130,
  131,  132,   76,  100,  100,  100,  100,  100,  101,  100,
  100,  100,  100,  100,  100,  100,  100,   77,  100,   82,
  100,  101,  100,   79,  100,   83,  125,  126,  101,  101,
  101,  101,  101,  101,   92,  101,  101,  101,  101,  101,
  101,  101,  101,  107,  101,  115,  101,   92,  101,  116,
  101,  124,   60,   60,  104,   92,   92,  123,   91,  147,
  148,   92,   92,   92,   92,   92,   92,   92,   92,   83,
   92,   91,   92,  149,   92,  152,   92,   61,   61,   91,
   91,  164,   83,  166,   78,   91,   91,   91,   91,   91,
   91,   91,   91,  168,   91,   77,   91,   78,   91,  169,
   91,  174,   83,   83,  178,   83,  180,   83,   77,   83,
  181,   83,    5,  182,  183,  184,    5,  187,   78,  185,
   78,    5,   78,    5,   78,    5,   78,    5,    5,   77,
    5,   77,  189,   77,  191,   77,    5,   77,   34,   35,
  192,   47,   36,   24,   23,   31,   40,   37,   32,   38,
   61,   74,   23,   73,   39,   53,   40,   46,   47,   41,
   48,    6,   42,   43,   44,    6,   45,   20,   80,  102,
    6,  156,    6,  158,    6,  159,    6,    6,   54,    6,
  160,    0,   18,    0,    4,    6,    0,    0,    0,   55,
    0,   56,    0,   57,   58,    0,   59,    0,    0,    0,
    0,    0,   60,
};
const short yycheck[] = {                                      10,
   32,   45,   56,   57,   58,   59,   60,  107,  122,  257,
   86,  257,  258,  259,  277,  116,  258,  257,  258,  259,
  264,  298,  257,  257,  298,  298,  261,  267,  142,  306,
  304,  304,  290,   87,   78,  298,  282,  283,   70,  279,
  282,   85,  282,  283,  284,  280,  286,  305,  124,  103,
  104,  152,  302,   85,  298,  266,  304,  303,  172,  299,
  290,  298,  257,  303,  118,  302,  264,  257,  258,  259,
  184,  115,  298,  258,  259,  305,  302,  267,  298,  277,
  298,  300,  302,  300,  302,  304,  186,  304,  280,  279,
  122,  257,  282,  283,  284,  149,  286,  282,  283,  297,
  298,  303,  300,  261,  302,  264,  304,  262,  306,  257,
  142,  300,  301,  303,  269,  287,  288,  289,  277,  274,
  164,  276,  300,  301,  168,  257,  285,  286,  287,  288,
  289,  302,  291,  292,  293,  294,  295,  296,  297,  298,
  172,  300,  264,  302,  260,  304,  305,  306,  265,  266,
  285,  286,  184,  302,  165,  277,  291,  292,  293,  294,
  295,  296,  302,  285,  286,  287,  288,  289,  264,  291,
  292,  293,  294,  295,  296,  297,  298,  302,  300,  303,
  302,  277,  304,  304,  306,  257,  285,  286,  266,  285,
  286,  287,  288,  289,  264,  291,  292,  293,  294,  295,
  296,  297,  298,  301,  300,  290,  302,  277,  304,  303,
  306,  297,  265,  266,  305,  285,  286,  298,  264,  302,
  304,  291,  292,  293,  294,  295,  296,  297,  298,  264,
  300,  277,  302,  300,  304,  303,  306,  265,  266,  285,
  286,  278,  277,  302,  264,  291,  292,  293,  294,  295,
  296,  297,  298,  278,  300,  264,  302,  277,  304,  304,
  306,  266,  297,  298,  304,  300,  270,  302,  277,  304,
  264,  306,  257,  271,  266,  264,  261,  257,  298,  266,
  300,  266,  302,  268,  304,  270,  306,  272,  273,  298,
  275,  300,  270,  302,  266,  304,  281,  306,  258,  259,
  264,  260,  262,  261,  261,  304,  302,  267,   25,  269,
  266,  304,   14,  304,  274,   31,  276,   27,   27,  279,
   27,  257,  282,  283,  284,  261,  286,   11,   52,   70,
  266,  123,  268,  133,  270,  134,  272,  273,  257,  275,
  138,   -1,  261,   -1,  280,  281,   -1,   -1,   -1,  268,
   -1,  270,   -1,  272,  273,   -1,  275,   -1,   -1,   -1,
   -1,   -1,  281,
};
#define YYFINAL 2
#ifndef YYDEBUG
#define YYDEBUG 1
#endif
#define YYMAXTOKEN 306
#if YYDEBUG
const char * const yyname[] = {
"end-of-file",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"ID","INT_CONST","FLOAT_CONST",
"ARRAY","BEG","BOOLEAN","DEF","DO","ELSE","END","FALSE","FOR","INTEGER","IF",
"OF","PRINT","READ","REAL","RETURN","STRING","THEN","TO","TRUE","VAR","WHILE",
"OCTAL_CONST","SCIENTIFIC","STR_CONST","OP_ADD","OP_SUB","OP_MUL","OP_DIV",
"OP_MOD","OP_ASSIGN","OP_EQ","OP_NE","OP_GT","OP_LT","OP_GE","OP_LE","OP_AND",
"OP_OR","OP_NOT","MK_COMMA","MK_COLON","MK_SEMICOLON","MK_LPAREN","MK_RPAREN",
"MK_LB","MK_RB",
};
const char * const yyrule[] = {
"$accept : program",
"$$1 :",
"program : ID MK_SEMICOLON $$1 program_body END ID",
"program_body : opt_decl_list opt_func_decl_list compound_stmt",
"$$2 :",
"opt_decl_list : $$2 decl_list",
"opt_decl_list :",
"decl_list : decl_list decl",
"decl_list : decl",
"decl : VAR id_list MK_COLON scalar_type MK_SEMICOLON",
"decl : VAR id_list MK_COLON array_type MK_SEMICOLON",
"decl : VAR id_list MK_COLON literal_const MK_SEMICOLON",
"int_const : INT_CONST",
"int_const : OCTAL_CONST",
"literal_const : int_const",
"literal_const : OP_SUB int_const",
"literal_const : FLOAT_CONST",
"literal_const : OP_SUB FLOAT_CONST",
"literal_const : SCIENTIFIC",
"literal_const : OP_SUB SCIENTIFIC",
"literal_const : STR_CONST",
"literal_const : TRUE",
"literal_const : FALSE",
"opt_func_decl_list : func_decl_list",
"opt_func_decl_list :",
"func_decl_list : func_decl_list func_decl",
"func_decl_list : func_decl",
"$$3 :",
"$$4 :",
"$$5 :",
"func_decl : ID MK_LPAREN $$3 opt_param_list $$4 MK_RPAREN opt_type MK_SEMICOLON $$5 compound_stmt END ID",
"opt_param_list : param_list",
"opt_param_list :",
"param_list : param_list MK_SEMICOLON param",
"param_list : param",
"$$6 :",
"param : $$6 id_list MK_COLON type",
"id_list : id_list MK_COMMA ID",
"id_list : ID",
"opt_type : MK_COLON type",
"opt_type :",
"type : scalar_type",
"type : array_type",
"scalar_type : INTEGER",
"scalar_type : REAL",
"scalar_type : BOOLEAN",
"scalar_type : STRING",
"$$7 :",
"$$8 :",
"$$9 :",
"array_type : $$7 ARRAY int_const $$8 TO int_const OF $$9 type",
"stmt : compound_stmt",
"stmt : simple_stmt",
"stmt : cond_stmt",
"stmt : while_stmt",
"stmt : for_stmt",
"stmt : return_stmt",
"stmt : proc_call_stmt",
"$$10 :",
"compound_stmt : BEG $$10 opt_decl_list opt_stmt_list END",
"opt_stmt_list : stmt_list",
"opt_stmt_list :",
"stmt_list : stmt_list stmt",
"stmt_list : stmt",
"simple_stmt : var_ref OP_ASSIGN boolean_expr MK_SEMICOLON",
"simple_stmt : PRINT boolean_expr MK_SEMICOLON",
"simple_stmt : READ boolean_expr MK_SEMICOLON",
"proc_call_stmt : ID MK_LPAREN opt_boolean_expr_list MK_RPAREN MK_SEMICOLON",
"cond_stmt : IF boolean_expr THEN opt_stmt_list ELSE opt_stmt_list END IF",
"cond_stmt : IF boolean_expr THEN opt_stmt_list END IF",
"while_stmt : WHILE boolean_expr DO opt_stmt_list END DO",
"for_stmt : FOR ID OP_ASSIGN int_const TO int_const DO opt_stmt_list END DO",
"return_stmt : RETURN boolean_expr MK_SEMICOLON",
"opt_boolean_expr_list : boolean_expr_list",
"opt_boolean_expr_list :",
"boolean_expr_list : boolean_expr_list MK_COMMA boolean_expr",
"boolean_expr_list : boolean_expr",
"boolean_expr : boolean_expr OP_OR boolean_term",
"boolean_expr : boolean_term",
"boolean_term : boolean_term OP_AND boolean_factor",
"boolean_term : boolean_factor",
"boolean_factor : OP_NOT boolean_factor",
"boolean_factor : relop_expr",
"relop_expr : expr rel_op expr",
"relop_expr : expr",
"rel_op : OP_LT",
"rel_op : OP_LE",
"rel_op : OP_EQ",
"rel_op : OP_GE",
"rel_op : OP_GT",
"rel_op : OP_NE",
"expr : expr add_op term",
"expr : term",
"add_op : OP_ADD",
"add_op : OP_SUB",
"term : term mul_op factor",
"term : factor",
"mul_op : OP_MUL",
"mul_op : OP_DIV",
"mul_op : OP_MOD",
"factor : var_ref",
"factor : OP_SUB var_ref",
"factor : MK_LPAREN boolean_expr MK_RPAREN",
"factor : OP_SUB MK_LPAREN boolean_expr MK_RPAREN",
"factor : ID MK_LPAREN opt_boolean_expr_list MK_RPAREN",
"factor : OP_SUB ID MK_LPAREN opt_boolean_expr_list MK_RPAREN",
"factor : literal_const",
"var_ref : ID",
"var_ref : var_ref dim",
"dim : MK_LB boolean_expr MK_RB",
};
#endif
#if YYDEBUG
#include <stdio.h>
#endif
#ifdef YYSTACKSIZE
#undef YYMAXDEPTH
#define YYMAXDEPTH YYSTACKSIZE
#else
#ifdef YYMAXDEPTH
#define YYSTACKSIZE YYMAXDEPTH
#else
#define YYSTACKSIZE 10000
#define YYMAXDEPTH 10000
#endif
#endif
#define YYINITSTACKSIZE 200
int yydebug;
int yynerrs;
int yyerrflag;
int yychar;
short *yyssp;
YYSTYPE *yyvsp;
YYSTYPE yyval;
YYSTYPE yylval;
short *yyss;
short *yysslim;
YYSTYPE *yyvs;
int yystacksize;
#line 928 "parser.y"

int yyerror( char *msg )
{
	fprintf( stderr, "\n|--------------------------------------------------------------------------\n" );
	fprintf( stderr, "| Error found in Line #%d: %s\n", linenum, buf );
	fprintf( stderr, "|\n" );
	fprintf( stderr, "| Unmatched token: %s\n", yytext );
	fprintf( stderr, "|--------------------------------------------------------------------------\n" );
	exit(-1);
}

#line 886 "y.tab.c"
/* allocate initial stack or double stack size, up to YYMAXDEPTH */
#if defined(__cplusplus) || __STDC__
static int yygrowstack(void)
#else
static int yygrowstack()
#endif
{
    int newsize, i;
    short *newss;
    YYSTYPE *newvs;

    if ((newsize = yystacksize) == 0)
        newsize = YYINITSTACKSIZE;
    else if (newsize >= YYMAXDEPTH)
        return -1;
    else if ((newsize *= 2) > YYMAXDEPTH)
        newsize = YYMAXDEPTH;
    i = yyssp - yyss;
    newss = yyss ? (short *)realloc(yyss, newsize * sizeof *newss) :
      (short *)malloc(newsize * sizeof *newss);
    if (newss == NULL)
        return -1;
    yyss = newss;
    yyssp = newss + i;
    newvs = yyvs ? (YYSTYPE *)realloc(yyvs, newsize * sizeof *newvs) :
      (YYSTYPE *)malloc(newsize * sizeof *newvs);
    if (newvs == NULL)
        return -1;
    yyvs = newvs;
    yyvsp = newvs + i;
    yystacksize = newsize;
    yysslim = yyss + newsize - 1;
    return 0;
}

#define YYABORT goto yyabort
#define YYREJECT goto yyabort
#define YYACCEPT goto yyaccept
#define YYERROR goto yyerrlab

#ifndef YYPARSE_PARAM
#if defined(__cplusplus) || __STDC__
#define YYPARSE_PARAM_ARG void
#define YYPARSE_PARAM_DECL
#else	/* ! ANSI-C/C++ */
#define YYPARSE_PARAM_ARG
#define YYPARSE_PARAM_DECL
#endif	/* ANSI-C/C++ */
#else	/* YYPARSE_PARAM */
#ifndef YYPARSE_PARAM_TYPE
#define YYPARSE_PARAM_TYPE void *
#endif
#if defined(__cplusplus) || __STDC__
#define YYPARSE_PARAM_ARG YYPARSE_PARAM_TYPE YYPARSE_PARAM
#define YYPARSE_PARAM_DECL
#else	/* ! ANSI-C/C++ */
#define YYPARSE_PARAM_ARG YYPARSE_PARAM
#define YYPARSE_PARAM_DECL YYPARSE_PARAM_TYPE YYPARSE_PARAM;
#endif	/* ANSI-C/C++ */
#endif	/* ! YYPARSE_PARAM */

int
yyparse (YYPARSE_PARAM_ARG)
    YYPARSE_PARAM_DECL
{
    int yym, yyn, yystate;
#if YYDEBUG
    const char *yys;

    if ((yys = getenv("YYDEBUG")))
    {
        yyn = *yys;
        if (yyn >= '0' && yyn <= '9')
            yydebug = yyn - '0';
    }
#endif

    yynerrs = 0;
    yyerrflag = 0;
    yychar = (-1);

    if (yyss == NULL && yygrowstack()) goto yyoverflow;
    yyssp = yyss;
    yyvsp = yyvs;
    *yyssp = yystate = 0;

yyloop:
    if ((yyn = yydefred[yystate])) goto yyreduce;
    if (yychar < 0)
    {
        if ((yychar = yylex()) < 0) yychar = 0;
#if YYDEBUG
        if (yydebug)
        {
            yys = 0;
            if (yychar <= YYMAXTOKEN) yys = yyname[yychar];
            if (!yys) yys = "illegal-symbol";
            printf("%sdebug: state %d, reading %d (%s)\n",
                    YYPREFIX, yystate, yychar, yys);
        }
#endif
    }
    if ((yyn = yysindex[yystate]) && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yychar)
    {
#if YYDEBUG
        if (yydebug)
            printf("%sdebug: state %d, shifting to state %d\n",
                    YYPREFIX, yystate, yytable[yyn]);
#endif
        if (yyssp >= yysslim && yygrowstack())
        {
            goto yyoverflow;
        }
        *++yyssp = yystate = yytable[yyn];
        *++yyvsp = yylval;
        yychar = (-1);
        if (yyerrflag > 0)  --yyerrflag;
        goto yyloop;
    }
    if ((yyn = yyrindex[yystate]) && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yychar)
    {
        yyn = yytable[yyn];
        goto yyreduce;
    }
    if (yyerrflag) goto yyinrecovery;
#if defined(lint) || defined(__GNUC__)
    goto yynewerror;
#endif
yynewerror:
    yyerror("syntax error");
#if defined(lint) || defined(__GNUC__)
    goto yyerrlab;
#endif
yyerrlab:
    ++yynerrs;
yyinrecovery:
    if (yyerrflag < 3)
    {
        yyerrflag = 3;
        for (;;)
        {
            if ((yyn = yysindex[*yyssp]) && (yyn += YYERRCODE) >= 0 &&
                    yyn <= YYTABLESIZE && yycheck[yyn] == YYERRCODE)
            {
#if YYDEBUG
                if (yydebug)
                    printf("%sdebug: state %d, error recovery shifting\
 to state %d\n", YYPREFIX, *yyssp, yytable[yyn]);
#endif
                if (yyssp >= yysslim && yygrowstack())
                {
                    goto yyoverflow;
                }
                *++yyssp = yystate = yytable[yyn];
                *++yyvsp = yylval;
                goto yyloop;
            }
            else
            {
#if YYDEBUG
                if (yydebug)
                    printf("%sdebug: error recovery discarding state %d\n",
                            YYPREFIX, *yyssp);
#endif
                if (yyssp <= yyss) goto yyabort;
                --yyssp;
                --yyvsp;
            }
        }
    }
    else
    {
        if (yychar == 0) goto yyabort;
#if YYDEBUG
        if (yydebug)
        {
            yys = 0;
            if (yychar <= YYMAXTOKEN) yys = yyname[yychar];
            if (!yys) yys = "illegal-symbol";
            printf("%sdebug: state %d, error recovery discards token %d (%s)\n",
                    YYPREFIX, yystate, yychar, yys);
        }
#endif
        yychar = (-1);
        goto yyloop;
    }
yyreduce:
#if YYDEBUG
    if (yydebug)
        printf("%sdebug: state %d, reducing by rule %d (%s)\n",
                YYPREFIX, yystate, yyn, yyrule[yyn]);
#endif
    yym = yylen[yyn];
    if (yym)
        yyval = yyvsp[1-yym];
    else
        memset(&yyval, 0, sizeof yyval);
    switch (yyn)
    {
case 1:
#line 517 "parser.y"
{
                    newsymtable(level_flag);
                    install(yyvsp[-1].stringValue, level_flag, "program", "void", "");
                    /*printf("[name]: %s\n", sym_table->entry->name);*/
                    printf("level : %d\n", level_flag);
                }
break;
case 2:
#line 525 "parser.y"
{
                    dumpsymbol(level_flag);
                    delsymtable(level_flag);
                    printf("level : %d\n", level_flag);
                }
break;
case 4:
#line 537 "parser.y"
{decl_type = 1; }
break;
case 5:
#line 538 "parser.y"
{decl_type = 0; }
break;
case 12:
#line 552 "parser.y"
{ 
                    if(is_array) {
                        if(array_order == 1) 
                            a_f = yyvsp[0].intValue;
                        else 
                            a_s = yyvsp[0].intValue;
                    } else {
                        update_decl_const_number(level_flag, "constant", "integer", yyvsp[0].intValue);
                    }
                }
break;
case 13:
#line 563 "parser.y"
{ 
                    if(is_array) {
                        if(array_order == 1)
                            a_f = yyvsp[0].intValue;
                        else
                            a_s = yyvsp[0].intValue;
                    } else {
                       update_decl_const_number(level_flag, "constant", "octal", yyvsp[0].intValue);
                    }
                }
break;
case 20:
#line 582 "parser.y"
{
                            update_decl_const_str(level_flag, "constant", "string", yyvsp[0].stringValue);
                        }
break;
case 27:
#line 598 "parser.y"
{
                    id_flag = yyvsp[-1].stringValue;
                    install(yyvsp[-1].stringValue, level_flag, "function", "___empty___", "___empty___");
                    /*dumpsymbol(level_flag);*/
                    printf("[name]: %s\n", sym_table->entry->name);
                    newsymtable(level_flag+1);
                    printf("level : %d\n", level_flag);
                    func_para = 1;
                    decl_type = 1;
                    func_comp = 1;
                }
break;
case 28:
#line 610 "parser.y"
{
                    decl_type = 1;
                    func_type = 1;
                    func_para = 0;
                }
break;
case 29:
#line 616 "parser.y"
{
                    func_type = 0;
                }
break;
case 30:
#line 621 "parser.y"
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
break;
case 35:
#line 643 "parser.y"
{para_num = 0;}
break;
case 36:
#line 643 "parser.y"
{para_num = 0;}
break;
case 37:
#line 647 "parser.y"
{
                    printf("[func_para]: %d\n", func_para);
                    printf("[id_decl_type] = %d\n", decl_type);
                     
                    if(decl_type == 1) {

                        id_current = yyvsp[0].stringValue;
                        
                        if(func_para == 1) {
                            para_num++;
                            install(yyvsp[0].stringValue, level_flag+1, "parameter", "___empty___", "___empty___");
                            printf("[para]: %s\n", sym_table->entry->name);
                           /* dumpsymbol(level_flag+1);*/
                        } else {
                            install(yyvsp[0].stringValue, level_flag, "variable", "___empty___", "___empty___");
                            printf("[vari]: %s\n", sym_table->entry->name);
                           /* dumpsymbol(level_flag);*/
                        }
                    }
                    
                }
break;
case 38:
#line 669 "parser.y"
{
                    printf("[func_para]: %d\n", func_para);
                    printf("[id_decl_type] = %d\n", decl_type);
                    
                    if(decl_type == 1) {
                        
                        id_current = yyvsp[0].stringValue;
                       
                        if(func_para == 1) {
                            para_num++;
                            install(yyvsp[0].stringValue, level_flag+1, "parameter", "___empty___", "___empty___");
                            printf("[para]: %s\n", sym_table->entry->name);
                           /* dumpsymbol(level_flag+1);*/
                        } else {
                            install(yyvsp[0].stringValue, level_flag, "variable", "___empty___", "___empty___");
                            printf("[vari]: %s\n", sym_table->entry->name);
                           /* dumpsymbol(level_flag);*/
                        }
                    }
                }
break;
case 43:
#line 700 "parser.y"
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
break;
case 44:
#line 724 "parser.y"
{ 
                    if(func_type) {
                        update_type(id_flag, level_flag, "real");
                        /*update_decl(level_flag, "real");*/
                    } else {
                        if(is_array) {
                        
                        } else {
                            if(func_para) {
                                update_attr(id_flag, level_flag, " real", para_num);
                            }
                            update_decl(level_flag, "real");
                        }
                    }
                }
break;
case 45:
#line 740 "parser.y"
{ 
                    if(func_type) {
                        update_type(id_flag, level_flag, "boolean");
                        /*update_decl(level_flag, "boolean");*/
                    } else {
                        if(is_array) {
                        
                        } else {
                            if(func_para) {
                               update_attr(id_flag, level_flag, " boolean", para_num);
                            }
                            update_decl(level_flag, "boolean");
                        }
                    }
                }
break;
case 46:
#line 756 "parser.y"
{
                    if(func_type) {
                        update_type(id_flag, level_flag, "string");
                    } else {
                        if(is_array) {
                        
                        } else {
                            if(func_para) {
                                update_attr(id_flag, level_flag, " string", para_num);
                            }
                            update_decl(level_flag, "string");
                        }
                    }
                }
break;
case 47:
#line 772 "parser.y"
{
                    is_array = 1;
                    array_order = 1;
                }
break;
case 48:
#line 777 "parser.y"
{
                    array_order = 2;
                }
break;
case 49:
#line 781 "parser.y"
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
break;
case 50:
#line 792 "parser.y"
{
                    is_array = 0;
                }
break;
case 58:
#line 807 "parser.y"
{
                        func_comp++;
                        level_flag++;
                        newsymtable(level_flag);    
                    }
break;
case 59:
#line 815 "parser.y"
{
                        func_comp--;
                        if(func_comp != 1) {
                            dumpsymbol(level_flag);
                            delsymtable(level_flag);
                            level_flag--;
                        }
                    }
break;
#line 1373 "y.tab.c"
    }
    yyssp -= yym;
    yystate = *yyssp;
    yyvsp -= yym;
    yym = yylhs[yyn];
    if (yystate == 0 && yym == 0)
    {
#if YYDEBUG
        if (yydebug)
            printf("%sdebug: after reduction, shifting from state 0 to\
 state %d\n", YYPREFIX, YYFINAL);
#endif
        yystate = YYFINAL;
        *++yyssp = YYFINAL;
        *++yyvsp = yyval;
        if (yychar < 0)
        {
            if ((yychar = yylex()) < 0) yychar = 0;
#if YYDEBUG
            if (yydebug)
            {
                yys = 0;
                if (yychar <= YYMAXTOKEN) yys = yyname[yychar];
                if (!yys) yys = "illegal-symbol";
                printf("%sdebug: state %d, reading %d (%s)\n",
                        YYPREFIX, YYFINAL, yychar, yys);
            }
#endif
        }
        if (yychar == 0) goto yyaccept;
        goto yyloop;
    }
    if ((yyn = yygindex[yym]) && (yyn += yystate) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yystate)
        yystate = yytable[yyn];
    else
        yystate = yydgoto[yym];
#if YYDEBUG
    if (yydebug)
        printf("%sdebug: after reduction, shifting from state %d \
to state %d\n", YYPREFIX, *yyssp, yystate);
#endif
    if (yyssp >= yysslim && yygrowstack())
    {
        goto yyoverflow;
    }
    *++yyssp = yystate;
    *++yyvsp = yyval;
    goto yyloop;
yyoverflow:
    yyerror("yacc stack overflow");
yyabort:
    return (1);
yyaccept:
    return (0);
}
