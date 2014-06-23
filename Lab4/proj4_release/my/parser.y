%{
/**
 * Introduction to Compiler Design by Prof. Yi Ping You
 * Project 3 YACC sample
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "header.h"
#include "symtab.h"
#include "semcheck.h"

//#include "test.h"

int yydebug;

extern int linenum;		/* declared in lex.l */
extern FILE *yyin;		/* declared by lex */
extern char *yytext;		/* declared by lex */
extern char buf[256];		/* declared in lex.l */

int scope = 0;

int Opt_D = 1;			/* symbol table dump option */
char fileName[256];


struct SymTable *symbolTable;	// main symbol table

__BOOLEAN paramError;			// indicate is parameter have any error?

struct PType *funcReturn;		// record function's return type, used at 'return statement' production rule
//Lab4 variables
FILE*   pFile;                  // output file
char*   pro_name;               // Program name
char*   fun_name;               // function name
int     localnumber = 0;        // local variable's number
char    tab[4];                 // how many tabs
char*   VariType;               // Variable Type

//Lab4 flags
int is_main = 0;
int is_globalVari = 0;
int is_simple = 0;              // is in simple_stmt
int is_assign = 0;              // is in assignment
int is_const = 0;
int is_print = 0;               // is in Print stmt
//Lab4 functions
struct Vnode
{
    char* vname;
    char* vtype;
    int   vlocalnumber;
    struct Vnode *vnext;
};
typedef struct Vnode Vnode;
Vnode* VariHead = (Vnode*) 0;

/*
void AddVariList(char* name) 
{
    Vnode* ptr;
    ptr = (Vnode*) malloc(sizeof(Vnode));
    ptr->vname = (char*) malloc(strlen(name)+1);

    strcpy(ptr->vname, name);
    if(is_globalVari == 1)
        ptr->vlocalnumber = 0;
    else
        ptr->vlocalnumber = ++localnumber;
    ptr->vnext = VariHead;
    VariHead = ptr;
}

void OutVariList(char* type)
{
    Vnode* ptr;
    while(VariHead != (Vnode*) 0) {
       ptr = VariHead;
       if(is_globalVari == 1)
           fprintf(pFile, ".field public static %s %s\n", VariHead->vname, type);
       else
           fprintf(pFile, "%s %s %d\n", VariHead->vname, type, VariHead->vlocalnumber);
       VariHead = VariHead->vnext;
       //free
       free(ptr->vname);
       free(ptr);
    }
}
*/
%}

%union {
	int intVal;
	float realVal;
	//__BOOLEAN booleanVal;
	char *lexeme;
	struct idNode_sem *id;
	//SEMTYPE type;
	struct ConstAttr *constVal;
	struct PType *ptype;
	struct param_sem *par;
	struct expr_sem *exprs;
	/*struct var_ref_sem *varRef; */
	struct expr_sem_node *exprNode;
};

/* tokens */
%token ARRAY BEG BOOLEAN DEF DO ELSE END FALSE FOR INTEGER IF OF PRINT READ REAL RETURN STRING THEN TO TRUE VAR WHILE
%token OP_ADD OP_SUB OP_MUL OP_DIV OP_MOD OP_ASSIGN OP_EQ OP_NE OP_GT OP_LT OP_GE OP_LE OP_AND OP_OR OP_NOT
%token MK_COMMA MK_COLON MK_SEMICOLON MK_LPAREN MK_RPAREN MK_LB MK_RB

%token <lexeme>ID
%token <intVal>INT_CONST 
%token <realVal>FLOAT_CONST
%token <realVal>SCIENTIFIC
%token <lexeme>STR_CONST

%type<id> id_list
%type<constVal> literal_const
%type<ptype> type scalar_type array_type opt_type
%type<par> param param_list opt_param_list
%type<exprs> var_ref boolean_expr boolean_term boolean_factor relop_expr expr term factor boolean_expr_list opt_boolean_expr_list
%type<intVal> dim mul_op add_op rel_op array_index loop_param

/* start symbol */
%start program
%%

program     : ID
			{
              pFile = fopen("atest.y", "w");
              fprintf(pFile, "%s.j;\n", $1);
              pro_name = (char*) malloc(sizeof($1)+1);
              strcpy(pro_name, $1);
              fprintf(pFile, ".class public %s\n", pro_name);
              fprintf(pFile, ".super java/lang/Object\n");
              VariType = (char*) malloc(20);
              
              struct PType *pType = createPType( VOID_t );
			  struct SymNode *newNode = createProgramNode( $1, scope, pType );
			  insertTab( symbolTable, newNode );

			  if( strcmp(fileName,$1) ) {
				fprintf( stdout, "########## Error at Line#%d: program beginning ID inconsist with file name ########## \n", linenum );
			  }
			}
			  MK_SEMICOLON 
			  program_body
			  END ID
			{
			  if( strcmp($1, $6) ) { fprintf( stdout, "########## Error at Line #%d: %s", linenum,"Program end ID inconsist with the beginning ID ########## \n"); }
			  if( strcmp(fileName,$6) ) {
				 fprintf( stdout, "########## Error at Line#%d: program end ID inconsist with file name ########## \n", linenum );
			  }
			  // dump symbol table
			  if( Opt_D == 1 )
				printSymTable( symbolTable, scope );
              
              fprintf(pFile, ".end method\n");
              free(VariType);
              fclose(pFile);
			}
			;

program_body: {is_globalVari = 1;} opt_decl_list {is_globalVari = 0;} opt_func_decl_list {is_main = 1;} compound_stmt 
			;

opt_decl_list   : decl_list
			    | /* epsilon */
    			;

decl_list   : decl_list decl
			| decl
			;

decl		: VAR id_list MK_COLON scalar_type MK_SEMICOLON       /* scalar type declaration */
			{
			  // insert into symbol table
			  struct idNode_sem *ptr;
			  struct SymNode *newNode;
			  for( ptr=$2 ; ptr!=0 ; ptr=(ptr->next) ) {
			  	if( verifyRedeclaration( symbolTable, ptr->value, scope ) ==__FALSE ) { }
				else {
					newNode = createVarNode( ptr->value, scope, $4 );
                    if(scope == 0) {
                        newNode->symLocalNum = 0;
                    } else {
                        newNode->symLocalNum = ++localnumber;
                        
                    }
					insertTab( symbolTable, newNode );
				}
			  }

              //OutVariList(VariType);
			  deleteIdList( $2 );
			}
			| VAR id_list MK_COLON array_type MK_SEMICOLON        /* array type declaration */
			{
			  verifyArrayType( $2, $4 );
			  // insert into symbol table
			  struct idNode_sem *ptr;
			  struct SymNode *newNode;
			  for( ptr=$2 ; ptr!=0 ; ptr=(ptr->next) ) {
			  	if( $4->isError == __TRUE ) { }
				else if( verifyRedeclaration( symbolTable, ptr->value, scope ) ==__FALSE ) { }
				else {
					newNode = createVarNode( ptr->value, scope, $4 );
					insertTab( symbolTable, newNode );
				}
			  }
			  
			  deleteIdList( $2 );
			}
			| VAR id_list MK_COLON literal_const MK_SEMICOLON     /* const declaration */
			{
			  struct PType *pType = createPType( $4->category );
			  // insert constants into symbol table
			  struct idNode_sem *ptr;
			  struct SymNode *newNode;
			  for( ptr=$2 ; ptr!=0 ; ptr=(ptr->next) ) {
			  	if( verifyRedeclaration( symbolTable, ptr->value, scope ) ==__FALSE ) { }
				else {
					newNode = createConstNode( ptr->value, scope, pType, $4 );
					insertTab( symbolTable, newNode );
				}
			  }
			  
			  deleteIdList( $2 );
			}
			;

literal_const   : INT_CONST
			{
			  int tmp = $1;
			  $$ = createConstAttr( INTEGER_t, &tmp );
              if(is_assign) {
                  fprintf(pFile, "ldc %d\n", tmp);
              }
			}
			| OP_SUB INT_CONST
			{
			  int tmp = -$2;
			  $$ = createConstAttr( INTEGER_t, &tmp );
              
              if(is_assign) {
                  fprintf(pFile, "ldc %d\n", $2);
              }

			}
			| FLOAT_CONST
			{
			  float tmp = $1;
			  $$ = createConstAttr( REAL_t, &tmp ); 
              if(is_assign) {
                  fprintf(pFile, "ldc %f\n", tmp);

              }

			}
			| OP_SUB FLOAT_CONST
			{
			  float tmp = -$2;
			  $$ = createConstAttr( REAL_t, &tmp ); 
              if(is_assign) {
                  fprintf(pFile, "ldc %f\n", tmp);
              }

			}
			| SCIENTIFIC 
			{
			  float tmp = $1;
			  $$ = createConstAttr( REAL_t, &tmp );
              
              if(is_assign) {
                  fprintf(pFile, "ldc %d\n", $1);
              }
			}
			| OP_SUB SCIENTIFIC
			{
			  float tmp = -$2;
			  $$ = createConstAttr( REAL_t, &tmp ); 
              if(is_assign) {
                  fprintf(pFile, "ldc -%d\n", $2);
              }

			}
			| STR_CONST
			{
			  $$ = createConstAttr( STRING_t, $1 ); 
              if(is_assign) {
                  fprintf(pFile, "ldc %s\n", $1);
              }
              if(is_print)
                  fprintf(pFile, "\tldc \"%s\"\n", $1);

			}
			| TRUE
			{
			  SEMTYPE tmp = __TRUE;
			  $$ = createConstAttr( BOOLEAN_t, &tmp ); 
              if(is_assign) {
                  fprintf(pFile, "iconst_1\n");
              }

			}
			| FALSE
			{
			  SEMTYPE tmp = __FALSE;
			  $$ = createConstAttr( BOOLEAN_t, &tmp );
              if(is_assign) {
                  fprintf(pFile, "iconst_0\n");
              }

			}
			;

opt_func_decl_list	: func_decl_list
			| /* epsilon */
			;

func_decl_list		: func_decl_list func_decl
			| func_decl
			;

func_decl		: ID MK_LPAREN opt_param_list
			{
			  // check and insert parameters into symbol table
			  paramError = insertParamIntoSymTable( symbolTable, $3, scope+1 );
			}
			  MK_RPAREN opt_type 
			{
			  // check and insert function into symbol table
			  if( paramError == __TRUE ) {
			  	printf("--- param(s) with several fault!! ---\n");
			  } else {
				insertFuncIntoSymTable( symbolTable, $1, $3, $6, scope );
			  }
			  funcReturn = $6;
			}
			  MK_SEMICOLON
			  compound_stmt
			  END ID
			{
			  if( strcmp($1,$11) ) {
				fprintf( stdout, "########## Error at Line #%d: the end of the functionName mismatch ########## \n", linenum );
			  }
			  funcReturn = 0;
			}
			;

opt_param_list		: param_list { $$ = $1; }
			| /* epsilon */ { $$ = 0; }
			;

param_list  : param_list MK_SEMICOLON param
			{
			  param_sem_addParam( $1, $3 );
			  $$ = $1;
			}
			| param { $$ = $1; }
			;

param       : id_list MK_COLON type { $$ = createParam( $1, $3 ); }
			;

id_list	    : id_list MK_COMMA ID
			{
			  idlist_addNode( $1, $3 );
			  $$ = $1;
              
              //AddVariList($3);
			}
			| ID 
            { 
              $$ = createIdList($1); 
              
              //AddVariList($1);
            }
			;

opt_type    : MK_COLON type { $$ = $2; }
			| /* epsilon */ { $$ = createPType( VOID_t ); }
			;

type        : scalar_type { $$ = $1; }
			| array_type { $$ = $1; }
			;

scalar_type : INTEGER { $$ = createPType( INTEGER_t ); strcpy(VariType, "I"); }
			| REAL { $$ = createPType( REAL_t ); strcpy(VariType, "F"); }
			| BOOLEAN { $$ = createPType( BOOLEAN_t ); strcpy(VariType, "Z"); }
			| STRING { $$ = createPType( STRING_t ); strcpy(VariType, "string"); }
			;

array_type		: ARRAY array_index TO array_index OF type
			{
				verifyArrayDim( $6, $2, $4 );
				increaseArrayDim( $6, $2, $4 );
				$$ = $6;
			}
			;

array_index : INT_CONST { $$ = $1; }
			| OP_SUB INT_CONST { $$ = -$2; }
			;

stmt        : compound_stmt
			| simple_stmt
			| cond_stmt
			| while_stmt
			| for_stmt
			| return_stmt
			| proc_call_stmt
			;

compound_stmt		: 
			{ 
			  scope++;
			}
			  BEG
            {
              /*
              int i;
              for(i = scope; i > 0; --i) {
                tab = '\t';
              };
              
              fprintf("%s'\n" tab);
              */
              if(is_main == 1) {
                  fprintf(pFile, ".method public static main([Ljava/lang/String;)V\n");
                  fprintf(pFile, "\t.limit stack 100\n");
                  fprintf(pFile, "\t.limit local 100\n");
                  is_main = 0;
              }

            }
			  opt_decl_list
			  opt_stmt_list
			  END 
			{ 
			  // print contents of current scope
			  if( Opt_D == 1 )
			  	printSymTable( symbolTable, scope );
			  deleteScope( symbolTable, scope );	// leave this scope, delete...
              
              fprintf(pFile, "\treturn\n");
			  
              scope--;
			}
			;

opt_stmt_list   : stmt_list
    			| /* epsilon */
			    ;

stmt_list   : stmt_list stmt
			| stmt
			;

simple_stmt : var_ref 
            { 
              is_simple = 1;
              is_assign = 1;
            } 
              OP_ASSIGN boolean_expr MK_SEMICOLON
			{
			  // check if LHS exists
			  __BOOLEAN flagLHS = verifyExistence( symbolTable, $1, scope, __TRUE );
			  // id RHS is not dereferenced, check and deference
			  __BOOLEAN flagRHS = __TRUE;
			  if( $4->isDeref == __FALSE ) {
				flagRHS = verifyExistence( symbolTable, $4, scope, __FALSE );
			  }
			  // if both LHS and RHS are exists, verify their type
			  if( flagLHS==__TRUE && flagRHS==__TRUE )
				verifyAssignmentTypeMatch( $1, $4 );
              
              is_assign = 0;            
              is_simple = 0;
			}
			| PRINT 
            {
              is_print = 1;
              fprintf(pFile, "getstatic java/lang/System/out Ljava/io/PrintStream;\n");
            } 
            boolean_expr MK_SEMICOLON 
            { 
              verifyScalarExpr( $3, "print" ); is_print = 0;
              fprintf(pFile, "invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n");
            }
 			| READ boolean_expr MK_SEMICOLON { verifyScalarExpr( $2, "read" ); }
			;

proc_call_stmt  : ID MK_LPAREN opt_boolean_expr_list MK_RPAREN MK_SEMICOLON
			{
			  verifyFuncInvoke( $1, $3, symbolTable, scope );
			}
			;

cond_stmt   : IF condition THEN
			  opt_stmt_list
			  ELSE
			  opt_stmt_list
			  END IF
			| IF condition THEN opt_stmt_list END IF
			;

condition   : boolean_expr { verifyBooleanExpr( $1, "if" ); } 
			;

while_stmt  : WHILE condition_while DO
			  opt_stmt_list
			  END DO
			;

condition_while		: boolean_expr { verifyBooleanExpr( $1, "while" ); } 
			;

for_stmt    : FOR ID 
			{
			  insertLoopVarIntoTable( symbolTable, $2 );
			}
			  OP_ASSIGN loop_param TO loop_param
			{
			  verifyLoopParam( $5, $7 );
			}
			  DO
			  opt_stmt_list
			  END DO
			{
              popLoopVar( symbolTable );
			}
			;

loop_param  : INT_CONST { $$ = $1; }
			| OP_SUB INT_CONST { $$ = -$2; }
			;

return_stmt : RETURN boolean_expr MK_SEMICOLON
			{
			  verifyReturnStatement( $2, funcReturn );
			}
			;

opt_boolean_expr_list	: boolean_expr_list { $$ = $1; }
			| /* epsilon */ { $$ = 0; }	// null
			;

boolean_expr_list	: boolean_expr_list MK_COMMA boolean_expr
			{
			  struct expr_sem *exprPtr;
			  for( exprPtr=$1 ; (exprPtr->next)!=0 ; exprPtr=(exprPtr->next) );
			  exprPtr->next = $3;
			  $$ = $1;
			}
			| boolean_expr
			{
			  $$ = $1;
			}
			;

boolean_expr: boolean_expr OP_OR boolean_term
			{
			  verifyAndOrOp( $1, OR_t, $3 );
			  $$ = $1;
			}
			| boolean_term { $$ = $1; }
			;

boolean_term: boolean_term OP_AND boolean_factor
			{
			  verifyAndOrOp( $1, AND_t, $3 );
			  $$ = $1;
			}
			| boolean_factor { $$ = $1; }
			;

boolean_factor		: OP_NOT boolean_factor 
			{
			  verifyUnaryNOT( $2 );
			  $$ = $2;
			}
			| relop_expr { $$ = $1; }
			;

relop_expr  : expr rel_op expr
			{
			  verifyRelOp( $1, $2, $3 );
			  $$ = $1;
			}
			| expr { $$ = $1; }
			;

rel_op      : OP_LT { $$ = LT_t; }
			| OP_LE { $$ = LE_t; }
			| OP_EQ { $$ = EQ_t; }
			| OP_GE { $$ = GE_t; }
			| OP_GT { $$ = GT_t; }
			| OP_NE { $$ = NE_t; }
			;

expr        : expr add_op term
			{
			  verifyArithmeticOp( $1, $2, $3 );
			  $$ = $1;
			}
			| term { $$ = $1; }
			;

add_op      : OP_ADD { $$ = ADD_t; }
			| OP_SUB { $$ = SUB_t; }
			;

term        : term mul_op factor
			{
			  if( $2 == MOD_t ) {
				verifyModOp( $1, $3 );
			  }
			  else {
				verifyArithmeticOp( $1, $2, $3 );
			  }
			  $$ = $1;
			}
			| factor { $$ = $1; }
			;

mul_op			: OP_MUL { $$ = MUL_t; }
			| OP_DIV { $$ = DIV_t; }
			| OP_MOD { $$ = MOD_t; }
			;

factor      : var_ref
			{
			  verifyExistence( symbolTable, $1, scope, __FALSE );
			  $$ = $1;
			  $$->beginningOp = NONE_t;
			}
			| OP_SUB var_ref
			{
			  if( verifyExistence( symbolTable, $2, scope, __FALSE ) == __TRUE )
				verifyUnaryMinus( $2 );
			  $$ = $2;
			  $$->beginningOp = SUB_t;
			}
			| MK_LPAREN boolean_expr MK_RPAREN 
			{
			  $2->beginningOp = NONE_t;
			  $$ = $2; 
			}
			| OP_SUB MK_LPAREN boolean_expr MK_RPAREN
			{
			  verifyUnaryMinus( $3 );
			  $$ = $3;
			  $$->beginningOp = SUB_t;
			}
			| ID MK_LPAREN opt_boolean_expr_list MK_RPAREN
			{
			  $$ = verifyFuncInvoke( $1, $3, symbolTable, scope );
			  $$->beginningOp = NONE_t;
			}
			| OP_SUB ID MK_LPAREN opt_boolean_expr_list MK_RPAREN
			{
			  $$ = verifyFuncInvoke( $2, $4, symbolTable, scope );
			  $$->beginningOp = SUB_t;
			}
            | literal_const
			{
			  $$ = (struct expr_sem *)malloc(sizeof(struct expr_sem));
			  $$->isDeref = __TRUE;
			  $$->varRef = 0;
			  $$->pType = createPType( $1->category );
			  $$->next = 0;
			  if( $1->hasMinus == __TRUE ) {
			  	$$->beginningOp = SUB_t;
			  }
			  else {
				$$->beginningOp = NONE_t;
			  }
			}
			;

var_ref     : ID
			{
			  $$ = createExprSem( $1 );
              
              struct SymNode *node = 0;               
              node = lookupSymbol( symbolTable, $1, scope, __TRUE);
              if(is_print) {
                  if(node == 0) {
                      printf("fucking error\n");
                  } else {
                      switch(node->type->type) {
                      case INTEGER_t:
                        fprintf(pFile, "\tiload %d ; local variable number %s\n", node->symLocalNum, node->name);
                        break;
                      case BOOLEAN_t:
                        fprintf(pFile, "\tiload %d ; local variable number %s\n", node->symLocalNum, node->name) ;
                        break;
                      case STRING_t:
                        fprintf(pFile, "\tldc \"%s\" ; local variable number %s\n",
                        node->attribute->constVal->value.stringVal, node->name);
                        break;
                      case REAL_t:
                        fprintf(pFile, "\tfload %d ; local variable number %s\n", node->symLocalNum, node->name);
                        break;
                      default:
                        fprintf(pFile, "fucking error\n");
                        break;
                      }
                  }
              }
			}
			| var_ref dim
			{
			  increaseDim( $1, $2 );
			  $$ = $1;
			}
			;

dim			: MK_LB boolean_expr MK_RB
			{
			  $$ = verifyArrayIndex( $2 );
			}
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

