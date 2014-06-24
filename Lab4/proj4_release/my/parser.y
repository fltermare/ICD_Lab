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
int     param_num = 0;          // number of function's parameter
int     label_num = 0;          // number of label
int     labelLoopNum= 0;        // number of Loop's label 
//Lab4 flags
int is_main = 0;
int is_globalVari = 0;
int is_simple = 0;              // is in simple_stmt
int is_assign = 0;              // is in assignment
int is_const = 0;
int is_print = 0;               // is in Print stmt
int is_read = 0;                // is in Read stmt
int is_param = 0;               // in decl function parameters
int is_condition = 0;           // in condition stmt
int is_return = 0;
int is_for = 0;                 // in for stmt
int is_while = 0;               // in while stmt
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
              pFile = fopen("atest.j", "w");
              fprintf(pFile, "; %s.j\n", $1);
              pro_name = (char*) malloc(sizeof($1)+1);
              strcpy(pro_name, $1);
              fprintf(pFile, ".class public %s\n", pro_name);
              fprintf(pFile, ".super java/lang/Object\n");
              fprintf(pFile, ".field public static _sc Ljava/util/Scanner;\n");
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
                        fprintf(pFile, ".field public static %s ", newNode->name);
                        switch(newNode->type->type) {
                        case INTEGER_t:
                            fprintf(pFile, "I\n") ;
                            break;
                        case BOOLEAN_t:
                            fprintf(pFile, "Z\n") ;
                            break;
                        case STRING_t:
                            fprintf(pFile, "C\n") ;
                            break;
                        case REAL_t:
                            fprintf(pFile, "F\n") ;
                            break;
                        default:
                            fprintf(pFile, "[decl type] fucking error\n");
                        break;
                        }
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
              if(is_assign || is_print || is_return || is_condition || is_for || is_while) {
                  fprintf(pFile, "\tsipush %d\n", tmp);
              }
			}
			| OP_SUB INT_CONST
			{
			  int tmp = -$2;
			  $$ = createConstAttr( INTEGER_t, &tmp );
              
              if(is_assign || is_print || is_return || is_condition || is_for || is_while) {
                  fprintf(pFile, "\tldc %d\n", $2);
              }

			}
			| FLOAT_CONST
			{
			  float tmp = $1;
			  $$ = createConstAttr( REAL_t, &tmp ); 
              if(is_assign || is_print || is_return || is_condition || is_for || is_while) {
                  fprintf(pFile, "\tldc %f\n", tmp);
              }
			}
			| OP_SUB FLOAT_CONST
			{
			  float tmp = -$2;
			  $$ = createConstAttr( REAL_t, &tmp ); 
              if(is_assign || is_print || is_return || is_condition || is_for || is_while) {
                  fprintf(pFile, "\tldc %f\n", tmp);
              }

			}
			| SCIENTIFIC 
			{
			  float tmp = $1;
			  $$ = createConstAttr( REAL_t, &tmp );
              
              if(is_assign || is_print || is_return || is_condition || is_for || is_while) {
                  fprintf(pFile, "\tldc %d\n", $1);
              }
			}
			| OP_SUB SCIENTIFIC
			{
			  float tmp = -$2;
			  $$ = createConstAttr( REAL_t, &tmp ); 
              if(is_assign || is_print || is_return || is_condition || is_for || is_while) {
                  fprintf(pFile, "\tldc -%d\n", $2);
              }

			}
			| STR_CONST
			{
			  $$ = createConstAttr( STRING_t, $1 ); 
              if(is_assign) {
                  fprintf(pFile, "\tldc %s\n", $1);
              }
              if(is_print) {
                  fprintf(pFile, "\tldc \"%s\"\n", $1);
                  //fprintf(pFile, "\tinvokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n");
              }

			}
			| TRUE
			{
			  SEMTYPE tmp = __TRUE;
			  $$ = createConstAttr( BOOLEAN_t, &tmp ); 
              if(is_assign || is_print || is_return || is_condition || is_for || is_while) {
                  fprintf(pFile, "\ticonst_1\n");
              }

			}
			| FALSE
			{
			  SEMTYPE tmp = __FALSE;
			  $$ = createConstAttr( BOOLEAN_t, &tmp );
              if(is_assign || is_print || is_return || is_condition || is_for || is_while) {
                  fprintf(pFile, "\ticonst_0\n");
              }

			}
			;

opt_func_decl_list	: func_decl_list
			| /* epsilon */
			;

func_decl_list		: func_decl_list func_decl
			| func_decl
			;

func_decl   : ID MK_LPAREN
            {
                fprintf(pFile, ".method public static %s(", $1);
                is_param = 1; 
            }
              opt_param_list
			{
                is_param = 0; 
			    // check and insert parameters into symbol table
			    paramError = insertParamIntoSymTable( symbolTable, $4, scope+1 );
			}
			  MK_RPAREN opt_type 
			{
                switch($7->type) {
                case INTEGER_t:
                    fprintf(pFile, ")I\n");
                    break;
                case BOOLEAN_t:
                    fprintf(pFile, ")I\n");
                    break;
                case STRING_t:
                    //fprintf(pFile, "\tslocal %d ; local variable number %d\n",node->name, node->symLocalNum);
                    break;
                case REAL_t:
                    fprintf(pFile, ")F\n");
                    break;
                default:
                    fprintf(pFile, ")V\n");
                    break;
                }
                
                // check and insert function into symbol table
			    if( paramError == __TRUE ) {
			  	    printf("--- param(s) with several fault!! ---\n");
			    } else {
				    insertFuncIntoSymTable( symbolTable, $1, $4, $7, scope );
			    }
			    funcReturn = $7;
			}
			  MK_SEMICOLON
			  compound_stmt
			  END ID
			{
			    if( strcmp($1,$12) ) {
				    fprintf( stdout, "######### Error at Line #%d: the end of the functionName mismatch ######### \n", linenum );
			    }
                switch($7->type) {
                case INTEGER_t:
                    fprintf(pFile, "\tireturn\n");
                    break;
                case BOOLEAN_t:
                    fprintf(pFile, "I\n");
                    break;
                case STRING_t:
                    //fprintf(pFile, "\tslocal %d ; local variable number %d\n",node->name, node->symLocalNum);
                    break;
                case REAL_t:
                    fprintf(pFile, "\tfreturn\n");
                    break;
                default:
                    fprintf(pFile, "\treturn\n");
                    break;
                }
                fprintf(pFile, ".end method\n\n");
                localnumber = 0;
			    funcReturn = 0;
			}
			;

opt_param_list		: param_list 
            { 
                $$ = $1; 
            }
			| /* epsilon */ { $$ = 0; }
			;

param_list  : param_list MK_SEMICOLON param
			{
			  param_sem_addParam( $1, $3 );
			  $$ = $1;
			}
			| param { $$ = $1; }
			;

param       :{param_num = 0;} id_list MK_COLON type 
            { 
                $$ = createParam( $2, $4 ); 
                struct param_sem *ptr;
                ptr = $$;
                struct idNode_sem *ptrIdList;
                for(ptrIdList = ptr->idlist; ptrIdList != 0; ptrIdList = ptrIdList->next) {
                    switch($$->pType->type) {
                    case INTEGER_t:
                        fprintf(pFile, "I");
                        break;
                    case BOOLEAN_t:
                        fprintf(pFile, "B");
                        break;
                    case STRING_t:
                        //fprintf(pFile, "\tslocal %d ; local variable number %d\n",node->name, node->symLocalNum);
                        break;
                    case REAL_t:
                        fprintf(pFile, "F");
                        break;
                    default:
                        fprintf(pFile, "[param type] fucking error\n");
                        break;
                    }
                }
                param_num = 0;
            }
			;

id_list	    : id_list MK_COMMA ID
			{
			  idlist_addNode( $1, $3 );
			  $$ = $1;
              param_num++;
              
			}
			| ID 
            { 
              param_num++;
              $$ = createIdList($1); 
              
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

compound_stmt: 
			{ 
			  scope++;
			}
			  BEG
            {
              if(is_main == 1) {
                  fprintf(pFile, "\n.method public static main([Ljava/lang/String;)V\n");
                  fprintf(pFile, "\t.limit stack 100\n");
                  fprintf(pFile, "\t.limit locals 100\n");
                  fprintf(pFile, "\tnew java/util/Scanner\n");
                  fprintf(pFile, "\tdup\n");
                  fprintf(pFile, "\tgetstatic java/lang/System/in Ljava/io/InputStream;\n");
                  fprintf(pFile, "\tinvokespecial java/util/Scanner/<init>(Ljava/io/InputStream;)V\n");
                  fprintf(pFile, "\tputstatic %s/_sc Ljava/util/Scanner;\n", pro_name);
              } else {
                  fprintf(pFile, ".limit stack 100\n");
                  fprintf(pFile, ".limit locals 100\n");
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
              if(is_main) {
                  fprintf(pFile, "\treturn\n");
                  fprintf(pFile, ".end method\n");
                  is_main = 0;
              }
			  
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
                /*
                if($1->pType->type == REAL_t && $4->pType->type == INTEGER_t) {
                    fprintf(pFile, "i2f\n");
                }
			    */
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
                
                
                //Lab4
                struct SymNode *node = 0;
                node = lookupLoopVar(symbolTable, $1->varRef->id);
                if(node == 0) {
                    node = lookupSymbol(symbolTable, $1->varRef->id, scope, __FALSE);
                }
                
                if($1->pType->type == REAL_t && $4->pType->type == INTEGER_t) {
                    fprintf(pFile, "\ti2f\n");
                }
                
                if(is_simple && node->category != CONSTANT_t) {
                    if (node->scope > 0) {
                        switch(node->type->type) {
                        case INTEGER_t:
                            fprintf(pFile, "\tistore %d\n", node->symLocalNum);
                            break;
                        case BOOLEAN_t:
                            fprintf(pFile, "\tistore %d\n", node->symLocalNum);
                            break;
                        case STRING_t:
                            //fprintf(pFile, "\tslocal %d ; local variable number %d\n",node->name, node->symLocalNum);
                            break;
                        case REAL_t:
                            fprintf(pFile, "\tfstore %d\n", node->symLocalNum);
                            break;
                        default:
                            fprintf(pFile, "[simple_stmt type !const] fucking error\n");
                            break;
                        }
                    }
                } else if (is_simple && node->category == CONSTANT_t) {
                    switch(node->type->type) {
                        case INTEGER_t:
                            fprintf(pFile, "sipush %d\n", node->attribute->constVal->value.integerVal);
                            break;
                        case BOOLEAN_t:
                            fprintf(pFile, "iconst_%d\n", node->attribute->constVal->value.booleanVal);
                            break;
                        case STRING_t:
                            fprintf(pFile, "ldc %s\n", node->attribute->constVal->value.stringVal);
                            break;
                        case REAL_t:
                            fprintf(pFile, "ldc %s\n", node->attribute->constVal->value.realVal);
                            break;
                        default:
                            fprintf(pFile, "[simple_stmt type const] fucking error\n");
                            break;
                        }
                } 
                
                is_assign = 0;            
                is_simple = 0;
			}
			| PRINT 
            {
                is_print = 1;
                fprintf(pFile, "\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
            } 
            boolean_expr MK_SEMICOLON 
            {
                    switch($3->pType->type) {
                    case INTEGER_t:
                        fprintf(pFile, "\tinvokevirtual java/io/PrintStream/print(I)V\n");
                        break;
                    case BOOLEAN_t:
                        fprintf(pFile, "\tinvokevirtual java/io/PrintStream/print(Z)V\n");
                        break;
                    case STRING_t:
                        fprintf(pFile, "\tinvokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n");
                        break;
                    case REAL_t:
                        fprintf(pFile, "\tinvokevirtual java/io/PrintStream/print(F)V\n");
                        break;
                    default:
                        fprintf(pFile, "[print] fucking error\n");
                        break;
                    }
                
                verifyScalarExpr( $3, "print" ); is_print = 0;
            }
 			| READ
            {
                fprintf(pFile, "\t;invoke java.util.Scanner.nextXXX();\n");
                fprintf(pFile, "\tgetstatic %s/_sc Ljava/util/Scanner;\n", pro_name);
                is_read = 1;    
            }
            boolean_expr MK_SEMICOLON 
            { 
                
                is_read = 0;
                verifyScalarExpr( $3, "read" ); 
            }
			;

proc_call_stmt  : ID MK_LPAREN opt_boolean_expr_list MK_RPAREN MK_SEMICOLON
			{
			    fprintf(pFile, "");
                verifyFuncInvoke( $1, $3, symbolTable, scope );
			}
			;

cond_stmt   : IF condition THEN
			  opt_stmt_list
            {
                fprintf(pFile, "\tgoto Lexit_%d\n", label_num);
            }
			  ELSE
            {
                fprintf(pFile, "Lelse_%d:\n", label_num++);
            }
              opt_stmt_list
			  END IF
            {
                fprintf(pFile, "Lexit_%d:\n", --label_num);
                label_num--;
            }
			| IF condition THEN opt_stmt_list
            {
                fprintf(pFile, "\tgoto Lexit_%d\n", label_num);
            }
              END IF
            {
                fprintf(pFile, "Lelse_%d:\n", label_num++);
                fprintf(pFile, "Lexit_%d:\n", --label_num);
                label_num--;
            }
			;

condition   :
            {
                is_condition = 1;
            } 
              boolean_expr
            { 
                verifyBooleanExpr( $2, "if" ); 
                is_condition = 0;
            }
			;

while_stmt  : WHILE
            {
                is_while = 1;
                fprintf(pFile, "Lbegin_%d:\n", labelLoopNum++);
            }
              condition_while
              DO
			  opt_stmt_list
            {
                is_while = 0;
                labelLoopNum -= 2;
                fprintf(pFile, "\tgoto Lbegin_%d\n", labelLoopNum);
                fprintf(pFile, "Lexit_%d:\n", labelLoopNum);
            }
			  END DO
			;

condition_while		: boolean_expr { verifyBooleanExpr( $1, "while" ); } 
			;

for_stmt    : FOR
            {
                is_for = 1;
            }
              ID 
			{
			    insertLoopVarIntoTable( symbolTable, $3 );
                
			}
			  OP_ASSIGN loop_param TO loop_param
			{
                verifyLoopParam( $6, $8 );
                
                struct SymNode *node = 0;
                node = lookupLoopVar( symbolTable, $3 ); 
                if(node != 0)  
                    node->symLocalNum = ++localnumber;
                else
                    printf("[for_stmt_id] fucking error\n");

                fprintf(pFile, "\tldc %d\n", $6);
                fprintf(pFile, "\tistore %d\n", node->symLocalNum);
                
                fprintf(pFile, "Lbegin_%d:\n", labelLoopNum++);
                fprintf(pFile, "\tiload %d\n", node->symLocalNum);
                fprintf(pFile, "\tsipush %d\n", $8);
                fprintf(pFile, "\tisub\n");
                
                fprintf(pFile, "\tiflt Ltrue_%d\n", labelLoopNum);
                fprintf(pFile, "\ticonst_0\n");
                fprintf(pFile, "\tgoto Lfalse_%d\n", labelLoopNum);
               
               
                fprintf(pFile, "Ltrue_%d:\n", labelLoopNum);
                fprintf(pFile, "\ticonst_1\n");
                fprintf(pFile, "Lfalse_%d:\n", labelLoopNum++);
                fprintf(pFile, "\tifeq Lexit_%d\n", labelLoopNum-2);
			}
			  DO
			  opt_stmt_list
			  END DO
			{
			    struct SymNode *node = 0;
                node = lookupLoopVar( symbolTable, $3 ); 
                if(node == 0)  
                    printf("[for_stmt_id_end] fucking error\n");
                
                fprintf(pFile, "\tiload %d\n", node->symLocalNum);
                fprintf(pFile, "\tsipush 1\n");
                fprintf(pFile, "\tiadd\n");
                fprintf(pFile, "\tistore %d\n", node->symLocalNum);
                labelLoopNum -= 2;
                fprintf(pFile, "\tgoto Lbegin_%d\n", labelLoopNum);
                fprintf(pFile, "Lexit_%d:\n", labelLoopNum);
                
                is_for = 0;
                popLoopVar( symbolTable );
			}
			;

loop_param  : INT_CONST { $$ = $1; }
			| OP_SUB INT_CONST { $$ = -$2; }
			;

return_stmt : RETURN
            {
                is_return = 1;
            }
              boolean_expr MK_SEMICOLON
			{
                is_return = 0;
			    verifyReturnStatement( $3, funcReturn );
                switch($3->pType->type) {
                case INTEGER_t:
                    fprintf(pFile, "\tireturn\n");
                    break;
                case BOOLEAN_t:
                    fprintf(pFile, "\tbreturn\n");
                    break;
                case STRING_t:
                    //fprintf(pFile, "\tslocal %d ; local variable number %d\n",node->name, node->symLocalNum);
                    break;
                case REAL_t:
                    fprintf(pFile, "\tfreturn\n");
                    break;
                default:
                    printf("[return] fucking error\n");
                    break;
                }
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
              printf("[%d]\n", $2->pType->type);
              fprintf(pFile, "neg\n");
			}
			| relop_expr { $$ = $1; }
			;

relop_expr  : expr rel_op expr
			{
			    verifyRelOp( $1, $2, $3 );
			    $$ = $1;
                
                if($3->pType->type == INTEGER_t)
                    fprintf(pFile, "\tisub\n\t");
                else if($3->pType->type == REAL_t)
                    fprintf(pFile, "\tfcmpl\n\t");
//aaabbb
                switch($2) {
                case LT_t: 
                    fprintf(pFile, "iflt Ltrue_%d\n", label_num);
                    fprintf(pFile, "\ticonst_0\n");
                    fprintf(pFile, "\tgoto Lfalse_%d\n", label_num);
                    fprintf(pFile, "Ltrue_%d:\n", label_num);
                    fprintf(pFile, "\ticonst_1\n");
                    fprintf(pFile, "Lfalse_%d:\n", label_num++);
                    fprintf(pFile, "\tifeq Lelse_%d\n", label_num);
                    break;
                case LE_t: 
                    fprintf(pFile, "ifle Ltrue_%d\n", label_num);
                    fprintf(pFile, "\ticonst_0\n");
                    fprintf(pFile, "\tgoto Lfalse_%d\n", label_num);
                    fprintf(pFile, "Ltrue_%d:\n", label_num);
                    fprintf(pFile, "\ticonst_1\n");
                    fprintf(pFile, "Lfalse_%d:\n", label_num++);
                    fprintf(pFile, "\tifeq Lelse_%d\n", label_num);
                    break;
                case EQ_t: 
                    fprintf(pFile, "ifeq\n");
                    fprintf(pFile, "\ticonst_0\n");
                    fprintf(pFile, "\tgoto Lfalse_%d\n", label_num);
                    fprintf(pFile, "Ltrue_%d:\n", label_num);
                    fprintf(pFile, "\ticonst_1\n");
                    fprintf(pFile, "Lfalse_%d:\n", label_num++);
                    fprintf(pFile, "\tifeq Lelse_%d\n", label_num);
                    break;
                case GE_t: 
                    fprintf(pFile, "ifge\n");
                    fprintf(pFile, "\ticonst_0\n");
                    fprintf(pFile, "\tgoto Lfalse_%d\n", label_num);
                    fprintf(pFile, "Ltrue_%d:\n", label_num);
                    fprintf(pFile, "\ticonst_1\n");
                    fprintf(pFile, "Lfalse_%d:\n", label_num++);
                    fprintf(pFile, "\tifeq Lelse_%d\n", label_num);
                    break;
                case GT_t: 
                    fprintf(pFile, "ifgt Ltrue_%d\n", label_num);
                    fprintf(pFile, "\ticonst_0\n");
                    fprintf(pFile, "\tgoto Lfalse_%d\n", label_num);
                    fprintf(pFile, "Ltrue_%d:\n", label_num);
                    fprintf(pFile, "\ticonst_1\n");
                    fprintf(pFile, "Lfalse_%d:\n", label_num++);
                    fprintf(pFile, "\tifeq Lelse_%d\n", label_num);
                    break;
                case NE_t: 
                    fprintf(pFile, "ifne\n");
                    fprintf(pFile, "\ticonst_0\n");
                    fprintf(pFile, "\tgoto Lfalse_%d\n", label_num);
                    fprintf(pFile, "Ltrue_%d:\n", label_num);
                    fprintf(pFile, "\ticonst_1\n");
                    fprintf(pFile, "Lfalse_%d:\n", label_num++);
                    fprintf(pFile, "\tifeq Lelse_%d\n", label_num);
                   break;
                default:
                    fprintf(pFile, "[relop] fucking error;");
                    break;
                }
                
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
                
                switch($2) {
                case ADD_t: 
                    fprintf(pFile, "add\n");
                    break;
                case SUB_t: 
                    fprintf(pFile, "sub\n");
                    break;
                default:
                    fprintf(pFile, "[add_op] fucking error;");
                    break;
                }
			}
			| term { $$ = $1; }
			;

add_op      : OP_ADD 
            { 
                $$ = ADD_t;
            }
			| OP_SUB 
            { 
                $$ = SUB_t;
            }
			;

term        : term mul_op factor
			{
			    if( $2 == MOD_t ) {
				    verifyModOp( $1, $3 );
			    }
			    else {
		            verifyArithmeticOp( $1, $2, $3 );
			    }
                
                switch($2) {
                case MUL_t: 
                    fprintf(pFile, "mul\n");
                    break;
                case DIV_t: 
                    fprintf(pFile, "div\n");
                    break;
                case MOD_t: 
                    fprintf(pFile, "irem\n");
                    break;
                default:
                    fprintf(pFile, "[mul_op] fucking error;");
                    break;
                }
			    
                $$ = $1;
			}
			| factor { $$ = $1; }
			;

mul_op      : OP_MUL { $$ = MUL_t; }
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
                struct SymNode *node = 0;
                node = lookupSymbol( symbolTable, $2, 0, __FALSE );

                              
                switch(node->type->type) {
                case INTEGER_t:
                    fprintf(pFile, "\ti") ;
                    break;
                case BOOLEAN_t:
                    fprintf(pFile, "\tb") ;
                    break;
                case STRING_t:
                    fprintf(pFile, "\tc") ;
                    break;
                case REAL_t:
                    fprintf(pFile, "\tf") ;
                    break;
                default:
                    fprintf(pFile, "[OP_SUB procedure] fucking error\n");
                    break;
                }
                fprintf(pFile, "neg\n");

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
                
                if(is_for) {
                    node = lookupLoopVar( symbolTable, $1);
                }
                if(node == 0)
                    node = lookupSymbol( symbolTable, $1, scope, __TRUE);
                
                if(is_print || is_assign || is_return || is_condition || is_for || is_while) {
                    
                    if(node == 0) {
                        printf("[var_ref id] fucking error\n");
                    } else {
                        switch(node->type->type) {
                        case INTEGER_t:
                            fprintf(pFile, "\tiload %d ; local variable number %s\n", node->symLocalNum, node->name);
                            //fprintf(pFile, "\tinvokevirtual java/io/PrintStream/print(I)V\n");
                            break;
                        case BOOLEAN_t:
                            fprintf(pFile, "\tiload %d ; local variable number %s\n", node->symLocalNum, node->name) ;
                            //fprintf(pFile, "\tinvokevirtual java/io/PrintStream/print(Z)V\n");
                            break;
                        case STRING_t:
                            fprintf(pFile, "\tldc \"%s\" ; local variable number %s\n", \
                            node->attribute->constVal->value.stringVal, node->name);
                        
                            //fprintf(pFile, "\tinvokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n");
                            break;
                        case REAL_t:
                            fprintf(pFile, "\tfload %d ; local variable number %s\n", node->symLocalNum, node->name);
                            //fprintf(pFile, "\tinvokevirtual java/io/PrintStream/print(F)V\n");
                            break;
                        default:
                            fprintf(pFile, "[var_ref type1] fucking error\n");
                            break;
                        }
                    }
                }
                if(is_read) {
                    switch(node->type->type) {
                    case INTEGER_t:
                        fprintf(pFile, "\tinvokevirtual java/util/Scanner/nextInt()I\n");
                        fprintf(pFile, "\tistore %d\n", node->symLocalNum);
                        break;
                    case BOOLEAN_t:
                        fprintf(pFile, "\tinvokevirtual java/util/Scanner/nextBoolean()Z\n");
                        fprintf(pFile, "\tistore %d\n", node->symLocalNum);
                        break;
                    case STRING_t:
                        fprintf(pFile, "\tinvokevirtual java/util/Scanner/nextString()S\n");
                        fprintf(pFile, "\tiload %d ; local variable number %s\n", node->symLocalNum, node->name);
                        break;
                    case REAL_t:
                        fprintf(pFile, "\tinvokevirtual java/util/Scanner/nextFloat()F\n");
                        fprintf(pFile, "\tfstore %d\n", node->symLocalNum);
                        break;
                    default:
                        fprintf(pFile, "[var_ref type2] fucking error\n");
                        break;
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

