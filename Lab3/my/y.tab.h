#ifndef YYERRCODE
#define YYERRCODE 256
#endif

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
typedef union
{
    char* stringValue;
    int intValue;
    float floatValue;
} YYSTYPE;
extern YYSTYPE yylval;
