
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
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


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     T_BEGINPROJECT = 258,
     T_ENDPROJECT = 259,
     T_SETUP = 260,
     T_RUN = 261,
     T_DEFINE = 262,
     T_CONST = 263,
     T_INTEGER = 264,
     T_FLOAT = 265,
     T_IF = 266,
     T_THEN = 267,
     T_ELSE = 268,
     T_ENDIF = 269,
     T_LOOP = 270,
     T_WHILE = 271,
     T_ENDLOOP = 272,
     T_FOR = 273,
     T_IN = 274,
     T_TO = 275,
     T_ENDFOR = 276,
     T_AND = 277,
     T_OR = 278,
     T_NON = 279,
     T_OUT = 280,
     T_IDENT = 281,
     T_STRING = 282,
     T_CONST_INT = 283,
     T_CONST_FLOAT = 284,
     T_ASSIGN = 285,
     T_EQ_INIT = 286,
     T_LE = 287,
     T_GE = 288,
     T_EQ = 289,
     T_NEQ = 290,
     T_LT = 291,
     T_GT = 292,
     T_PLUS = 293,
     T_MINUS = 294,
     T_MUL = 295,
     T_DIV = 296,
     T_SEMI = 297,
     T_COLON = 298,
     T_PIPE = 299,
     T_LBRACE = 300,
     T_RBRACE = 301,
     T_LBRACK = 302,
     T_RBRACK = 303,
     T_LPAREN = 304,
     T_RPAREN = 305,
     T_COMMA = 306
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 52 "syntaxic.y"

    int        int_val;
    float      float_val;
    char      *str_val;
    DataType   dtype;



/* Line 1676 of yacc.c  */
#line 112 "syntaxic.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;

#if ! defined YYLTYPE && ! defined YYLTYPE_IS_DECLARED
typedef struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
} YYLTYPE;
# define yyltype YYLTYPE /* obsolescent; will be withdrawn */
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif

extern YYLTYPE yylloc;

