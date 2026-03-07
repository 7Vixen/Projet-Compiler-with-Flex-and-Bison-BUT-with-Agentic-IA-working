%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "table_Hashage.h"
#include "syntaxic.tab.h"

/* ------- Compteurs de position pour les messages d'erreur ------- */
int yycolumn = 1;

/* Mise à jour de la colonne à chaque token reconnu */
#define YY_USER_ACTION \
    yylloc.first_line   = yylineno;        \
    yylloc.first_column = yycolumn;        \
    yylloc.last_line    = yylineno;        \
    yylloc.last_column  = yycolumn + (int)yyleng - 1; \
    yycolumn           += (int)yyleng;

%}

/* Options FLEX */
%option noyywrap
%option yylineno

LETTRE      [a-z]
CHIFFRE     [0-9]
IDENT_BASE  {LETTRE}({LETTRE}|{CHIFFRE}|"_"({LETTRE}|{CHIFFRE}))*

ENTIER      {CHIFFRE}+
REEL        {CHIFFRE}+"."{CHIFFRE}+
CHAINE      \"[^\"]*\"

%%

"%%"[^\n]*              { /* commentaire ligne : ignorer */ }

"//*"                   {
                            /* commentaire multi-ligne : consommer jusqu a la fermeture */
                            int c;
                            int prev1 = 0, prev2 = 0;
                            while ((c = input()) != EOF) {
                                if (c == '\n') { yylineno++; yycolumn = 1; }
                                else yycolumn++;
                                if (prev2 == '*' && prev1 == '/' && c == '/') break;
                                prev2 = prev1;
                                prev1 = c;
                            }
                        }

"BeginProject"          { return T_BEGINPROJECT; }
"EndProject"            { return T_ENDPROJECT;   }
"Setup"                 { return T_SETUP;        }
"Run"                   { return T_RUN;          }
"define"                { return T_DEFINE;       }
"const"                 { return T_CONST;        }
"integer"               { return T_INTEGER;      }
"float"                 { return T_FLOAT;        }
"if"                    { return T_IF;           }
"then"                  { return T_THEN;         }
"else"                  { return T_ELSE;         }
"endIf"                 { return T_ENDIF;        }
"loop"                  { return T_LOOP;         }
"while"                 { return T_WHILE;        }
"endloop"               { return T_ENDLOOP;      }
"for"                   { return T_FOR;          }
"in"                    { return T_IN;           }
"to"                    { return T_TO;           }
"endfor"                { return T_ENDFOR;       }
"AND"                   { return T_AND;          }
"OR"                    { return T_OR;           }
"NON"                   { return T_NON;          }
"out"                   { return T_OUT;          }


 /*  3. IDENTIFICATEURS                                           */
 /*  La regex autorise les patterns valides (commence par lettre,*/
 /*  pas de __ ni de _ final), mais la longueur max (14) est     */
 /*  vérifiée dans l'action.                                      */

{IDENT_BASE}            {
                            /* Vérification longueur maximale : 14 caractères */
                            if ((int)strlen(yytext) > 14) {
                                fprintf(stderr,
                                    "Erreur_Lexicale, ligne %d, colonne %d, entite : '%s' — identificateur trop long (max 14 caracteres)\n",
                                    yylineno, yycolumn - (int)yyleng, yytext);
                            }
                            /* Vérification : ne doit pas se terminer par _ */
                            if (yytext[yyleng - 1] == '_') {
                                fprintf(stderr,
                                    "Erreur_Lexicale, ligne %d, colonne %d, entite : '%s' — identificateur ne peut pas se terminer par '_'\n",
                                    yylineno, yycolumn - (int)yyleng, yytext);
                            }
                            yylval.str_val = strdup(yytext);
                            return T_IDENT;
                        }


 /* Réel signé entre parenthèses : (+5.76) ou (-5.76) */
"("[+-]{REEL}")"        {
                            yylval.float_val = (float)atof(yytext + 1); /* skip '(' */
                            return T_CONST_FLOAT;
                        }

"("[+-]{ENTIER}")"      {
                            yylval.int_val = atoi(yytext + 1); /* skip '(' */
                            return T_CONST_INT;
                        }
{REEL}                  {
                            yylval.float_val = (float)atof(yytext);
                            return T_CONST_FLOAT;
                        }
{ENTIER}                {
                            yylval.int_val = atoi(yytext);
                            return T_CONST_INT;
                        }
{CHAINE}                {
                            /* Stocker sans les guillemets */
                            int len = (int)strlen(yytext) - 2;
                            char *s = (char *)malloc(len + 1);
                            strncpy(s, yytext + 1, len);
                            s[len] = '\0';
                            yylval.str_val = s;
                            return T_STRING;
                        }

"<-"                    { return T_ASSIGN;  }
"<="                    { return T_LE;      }
">="                    { return T_GE;      }
"=="                    { return T_EQ;      }
"!="                    { return T_NEQ;     }
"<"                     { return T_LT;      }
">"                     { return T_GT;      }
"+"                     { return T_PLUS;    }
"-"                     { return T_MINUS;   }
"*"                     { return T_MUL;     }
"/"                     { return T_DIV;     }
"="                     { return T_EQ_INIT; }
";"                     { return T_SEMI;    }
":"                     { return T_COLON;   }
"|"                     { return T_PIPE;    }
"{"                     { return T_LBRACE; }
"}"                     { return T_RBRACE; }
"["                     { return T_LBRACK; }
"]"                     { return T_RBRACK; }
"("                     { return T_LPAREN; }
")"                     { return T_RPAREN; }
","                     { return T_COMMA;  }
[ \t\r]+                { /* ignorer les espaces / tabulations */ }
\n                      { yycolumn = 1; /* yylineno incrémenté par l'option */ }

.                       {
                            fprintf(stderr,
                                "Erreur_Lexicale, ligne %d, colonne %d, entite : '%s'\n",
                                yylineno, yycolumn - (int)yyleng, yytext);
                        }

%%
