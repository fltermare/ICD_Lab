/* A Bison parser, made by GNU Bison 3.0.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2013 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    ADD = 258,
    SUB = 259,
    MUL = 260,
    DIV = 261,
    MOD = 262,
    ASSIGN = 263,
    GT = 264,
    GE = 265,
    NE = 266,
    LE = 267,
    LT = 268,
    EQ = 269,
    AND = 270,
    OR = 271,
    NOT = 272,
    ARRAY = 273,
    BEG = 274,
    BOOLEAN = 275,
    DEF = 276,
    DO = 277,
    ELSE = 278,
    END = 279,
    FALSE = 280,
    FOR = 281,
    INTEGER = 282,
    IF = 283,
    OF = 284,
    PRINT = 285,
    READ = 286,
    REAL = 287,
    THEN = 288,
    TO = 289,
    TRUE = 290,
    VAR = 291,
    WHILE = 292,
    OCT = 293,
    ID = 294,
    INT = 295,
    FLOAT = 296,
    SCI = 297,
    RETURN = 298,
    BS = 299,
    BSS = 300,
    BSSS = 301,
    STRING = 302
  };
#endif
/* Tokens.  */
#define ADD 258
#define SUB 259
#define MUL 260
#define DIV 261
#define MOD 262
#define ASSIGN 263
#define GT 264
#define GE 265
#define NE 266
#define LE 267
#define LT 268
#define EQ 269
#define AND 270
#define OR 271
#define NOT 272
#define ARRAY 273
#define BEG 274
#define BOOLEAN 275
#define DEF 276
#define DO 277
#define ELSE 278
#define END 279
#define FALSE 280
#define FOR 281
#define INTEGER 282
#define IF 283
#define OF 284
#define PRINT 285
#define READ 286
#define REAL 287
#define THEN 288
#define TO 289
#define TRUE 290
#define VAR 291
#define WHILE 292
#define OCT 293
#define ID 294
#define INT 295
#define FLOAT 296
#define SCI 297
#define RETURN 298
#define BS 299
#define BSS 300
#define BSSS 301
#define STRING 302

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
