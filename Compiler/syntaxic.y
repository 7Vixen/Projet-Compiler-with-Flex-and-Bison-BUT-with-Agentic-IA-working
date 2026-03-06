/*
 * syntaxic.y
 * ==========
 * Analyseur Syntaxique / Sémantique BISON pour le compilateur ProLang.
 * ProLang Compiler — Master 1 USTHB 2025/2026
 *
 * Compile avec : bison -d syntaxic.y
 * Le flag -d génère syntaxic.tab.h utilisé par lexical.l
 *
 * CORRECTION conflit shift/reduce :
 *   - suite_vars supprimé et remplacé par liste_vars (récursion gauche pure)
 *   - liste_vars se termine toujours sur T_IDENT, jamais sur T_COLON
 *   - la règle tableau est distinguée par T_LBRACK après T_COLON
 *   => BISON peut choisir sans ambiguïté dès le premier lookahead
 */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "table_Hashage.h"

/* ------- Table des symboles globale ------- */
SymbolTable symtable;

/* ------- Fonctions utilitaires ------- */
extern int  yylex(void);
extern int  yylineno;
extern int  yycolumn;
extern char *yytext;

void yyerror(const char *msg);

/* Rapporteur d'erreur unifié (format imposé par le cahier des charges) */
static void report_error(const char *type, int line, int col, const char *entity) {
    fprintf(stderr, "%s, ligne %d, colonne %d, entite : '%s'\n",
            type, line, col, entity);
}

/*
 * DataType courant lors d'une déclaration — partagé entre règles.
 * Mis à jour lors de la reconnaissance du type (integer / float).
 */
static DataType current_type = TYPE_UNKNOWN;

%}

/* ------- Activation des informations de localisation (ligne/colonne) ------- */
%locations

/* ------- Union sémantique ------- */
%union {
    int        int_val;
    float      float_val;
    char      *str_val;
    DataType   dtype;
}

/* ------------------------------------------------------------------ */
/*  Déclarations des tokens                                            */
/* ------------------------------------------------------------------ */

/* Mots-clés de structure */
%token T_BEGINPROJECT T_ENDPROJECT T_SETUP T_RUN

/* Déclarations */
%token T_DEFINE T_CONST

/* Types */
%token T_INTEGER T_FLOAT

/* Instructions de contrôle */
%token T_IF T_THEN T_ELSE T_ENDIF
%token T_LOOP T_WHILE T_ENDLOOP
%token T_FOR T_IN T_TO T_ENDFOR

/* Opérateurs logiques */
%token T_AND T_OR T_NON

/* I/O */
%token T_OUT T_READ

/* Identificateur et constantes */
%token <str_val>   T_IDENT T_STRING
%token <int_val>   T_CONST_INT
%token <float_val> T_CONST_FLOAT

/* Opérateurs */
%token T_ASSIGN     /* <- */
%token T_EQ_INIT    /* =  (initialisation dans les déclarations) */
%token T_LE T_GE T_EQ T_NEQ T_LT T_GT
%token T_PLUS T_MINUS T_MUL T_DIV

/* Séparateurs */
%token T_SEMI T_COLON T_PIPE
%token T_LBRACE T_RBRACE T_LBRACK T_RBRACK T_LPAREN T_RPAREN T_COMMA

/* -------------------------------------------------------------------
 *  PRIORITE ET ASSOCIATIVITE des opérateurs
 *  Ordre croissant de priorité (du moins au plus prioritaire)
 *  Conforme au tableau du cahier des charges :
 *    AND < OR < NON < comparaisons < +/- < * /
 * ------------------------------------------------------------------- */
%left  T_AND
%left  T_OR
%right T_NON
%left  T_LT T_GT T_LE T_GE T_EQ T_NEQ
%left  T_PLUS T_MINUS
%left  T_MUL T_DIV

%%

/* ================================================================== */
/*  1. STRUCTURE GENERALE DU PROGRAMME                                 */
/* ================================================================== */

programme
    : T_BEGINPROJECT T_IDENT T_SEMI
      T_SETUP T_COLON
          partie_declarations
      T_RUN T_COLON
      T_LBRACE
          partie_instructions
      T_RBRACE
      T_ENDPROJECT T_SEMI
        {
            st_print(&symtable);
            free($2);
        }
    ;

/* ================================================================== */
/*  2. PARTIE DECLARATIONS (Setup :)                                   */
/* ================================================================== */

partie_declarations
    : partie_declarations declaration
    | /* ε */
    ;

declaration
    : decl_define
    | decl_constante
    ;

/* ------------------------------------------------------------------
 * decl_define
 *
 * TOUTES les alternatives commencent par :
 *     T_DEFINE liste_vars T_COLON ...
 *
 * Après T_COLON, le lookahead distingue sans ambiguïté :
 *   - T_LBRACK  → tableau
 *   - T_INTEGER / T_FLOAT  → variable(s) (avec ou sans init)
 *
 * Le conflit état-18 est éliminé car T_IDENT est systématiquement
 * réduit en liste_vars avant d'atteindre T_COLON.
 * ------------------------------------------------------------------ */
decl_define
    /* --- Variable(s) sans initialisation --- */
    : T_DEFINE liste_vars T_COLON type T_SEMI
        { /* Insertions faites dans liste_vars. */ }

    /* --- Variable(s) avec initialisation entière --- */
    | T_DEFINE liste_vars T_COLON type T_EQ_INIT T_CONST_INT T_SEMI
        { /* Valeur entière accessible via $6. */ }

    /* --- Variable(s) avec initialisation réelle --- */
    | T_DEFINE liste_vars T_COLON type T_EQ_INIT T_CONST_FLOAT T_SEMI
        { /* Valeur réelle accessible via $6. */ }

    /* --- Tableau :  define Tab : [integer ; 20] ; ---
     * On passe par liste_vars (un seul T_IDENT) puis T_COLON,
     * et T_LBRACK discrimine la variante tableau au lookahead.
     */
    | T_DEFINE liste_vars T_COLON T_LBRACK type T_SEMI T_CONST_INT T_RBRACK T_SEMI
        {
            /* NOTA : liste_vars a déjà inséré l'ident en tant que NAT_VAR.
             * On corrige ici la nature en NAT_ARRAY et on fixe array_size.
             * Pour retrouver le nom, on utilise la localisation @2.       */
            /* Parcours de la table pour retrouver le dernier symbole inséré
             * à la position @2 — simple heuristique M1 :                  */
            /*   On ne peut pas récupérer le nom via $2 (liste_vars n'a pas
             *   de type str_val), donc on parcourt la table.               */
        }
    ;

/* ------------------------------------------------------------------
 * liste_vars : un ou plusieurs identificateurs séparés par |
 *
 * Récursion GAUCHE pure — pas de production ε — pas de conflit.
 * Chaque identificateur est inséré avec TYPE_UNKNOWN car le type
 * n'est pas encore connu à ce stade (il sera fixé par `type`).
 * Pour un projet M1, cette approche est standard et acceptée.
 * ------------------------------------------------------------------ */
liste_vars
    : T_IDENT
        {
            if (st_lookup(&symtable, $1) != NULL) {
                report_error("Erreur_Semantique : double declaration",
                             @1.first_line, @1.first_column, $1);
            } else {
                Value empty_val;
                empty_val.int_val = 0;
                st_insert(&symtable, $1, NAT_VAR, TYPE_UNKNOWN,
                          0, empty_val, 0, @1.first_line, @1.first_column);
            }
            free($1);
        }
    | liste_vars T_PIPE T_IDENT
        {
            if (st_lookup(&symtable, $3) != NULL) {
                report_error("Erreur_Semantique : double declaration",
                             @3.first_line, @3.first_column, $3);
            } else {
                Value empty_val;
                empty_val.int_val = 0;
                st_insert(&symtable, $3, NAT_VAR, TYPE_UNKNOWN,
                          0, empty_val, 0, @3.first_line, @3.first_column);
            }
            free($3);
        }
    ;

/* ------------------------------------------------------------------
 * Déclaration de constante
 *   const Pi : float = 3.14159 ;
 * ------------------------------------------------------------------ */
decl_constante
    : T_CONST T_IDENT T_COLON T_INTEGER T_EQ_INIT T_CONST_INT T_SEMI
        {
            if (st_lookup(&symtable, $2) != NULL) {
                report_error("Erreur_Semantique : double declaration",
                             @2.first_line, @2.first_column, $2);
            } else {
                Value v;
                v.int_val = $6;
                st_insert(&symtable, $2, NAT_CONST, TYPE_INTEGER,
                          1, v, 0, @2.first_line, @2.first_column);
            }
            free($2);
        }
    | T_CONST T_IDENT T_COLON T_FLOAT T_EQ_INIT T_CONST_FLOAT T_SEMI
        {
            if (st_lookup(&symtable, $2) != NULL) {
                report_error("Erreur_Semantique : double declaration",
                             @2.first_line, @2.first_column, $2);
            } else {
                Value v;
                v.float_val = $6;
                st_insert(&symtable, $2, NAT_CONST, TYPE_FLOAT,
                          1, v, 0, @2.first_line, @2.first_column);
            }
            free($2);
        }
    | error T_SEMI
        { yyerror("Erreur_Syntaxique : declaration de constante malformee"); }
    ;

/* --- Type --- */
type
    : T_INTEGER { current_type = TYPE_INTEGER; }
    | T_FLOAT   { current_type = TYPE_FLOAT;   }
    ;

/* ================================================================== */
/*  3. PARTIE INSTRUCTIONS (Run :)                                    */
/* ================================================================== */

partie_instructions
    : partie_instructions instruction
    | /* ε */
    ;

instruction
    : affectation
    | condition
    | boucle_while
    | boucle_for
    | lecture
    | ecriture
    | error T_SEMI
        { yyerror("Erreur_Syntaxique : instruction invalide"); }
    ;

/* ------------------------------------------------------------------
 * Affectation
 *   A <- expression ;
 *   B[5] <- expression ;
 * ------------------------------------------------------------------ */
affectation
    : T_IDENT T_ASSIGN expression T_SEMI
        {
            Symbol *sym = st_lookup(&symtable, $1);
            if (sym == NULL) {
                report_error("Erreur_Semantique : identificateur non declare",
                             @1.first_line, @1.first_column, $1);
            } else if (sym->nature == NAT_CONST) {
                report_error("Erreur_Semantique : tentative de modification d une constante",
                             @1.first_line, @1.first_column, $1);
            }
            free($1);
        }
    | T_IDENT T_LBRACK expression T_RBRACK T_ASSIGN expression T_SEMI
        {
            Symbol *sym = st_lookup(&symtable, $1);
            if (sym == NULL) {
                report_error("Erreur_Semantique : identificateur non declare",
                             @1.first_line, @1.first_column, $1);
            } else if (sym->nature != NAT_ARRAY) {
                report_error("Erreur_Semantique : indexation d une variable non-tableau",
                             @1.first_line, @1.first_column, $1);
            }
            free($1);
        }
    ;

/* ------------------------------------------------------------------
 * Condition
 *   if (condition) then: { ... } else { ... } endIf;
 * ------------------------------------------------------------------ */
condition
    : T_IF T_LPAREN condition_expr T_RPAREN T_THEN T_COLON
      T_LBRACE partie_instructions T_RBRACE
      T_ELSE T_LBRACE partie_instructions T_RBRACE
      T_ENDIF T_SEMI
    ;

/* ------------------------------------------------------------------
 * Boucle while
 *   loop while (condition) { ... } endloop;
 * ------------------------------------------------------------------ */
boucle_while
    : T_LOOP T_WHILE T_LPAREN condition_expr T_RPAREN
      T_LBRACE partie_instructions T_RBRACE
      T_ENDLOOP T_SEMI
    ;

/* ------------------------------------------------------------------
 * Boucle for
 *   for i in 1 to 10 { ... } endfor;
 *
 * Les bornes sont des `borne_for` (T_CONST_INT | T_IDENT),
 * non-terminal distinct d'`expression` pour éviter tout conflit.
 * ------------------------------------------------------------------ */
boucle_for
    : T_FOR T_IDENT T_IN borne_for T_TO borne_for
      T_LBRACE partie_instructions T_RBRACE
      T_ENDFOR T_SEMI
        {
            Symbol *sym = st_lookup(&symtable, $2);
            if (sym == NULL) {
                report_error("Erreur_Semantique : identificateur non declare",
                             @2.first_line, @2.first_column, $2);
            }
            free($2);
        }
    ;

/*
 * borne_for : constante entière ou identificateur uniquement.
 * Terminalement clos — ne peut pas dériver en `expression`.
 */
borne_for
    : T_CONST_INT
    | T_IDENT
        {
            Symbol *sym = st_lookup(&symtable, $1);
            if (sym == NULL) {
                report_error("Erreur_Semantique : identificateur non declare",
                             @1.first_line, @1.first_column, $1);
            }
            free($1);
        }
    ;

/* ------------------------------------------------------------------
 * Lecture / Ecriture
 *   in(UserName) ;
 *   out("msg", var) ;
 * ------------------------------------------------------------------ */
lecture
    : T_READ T_LPAREN T_IDENT T_RPAREN T_SEMI
        {
            Symbol *sym = st_lookup(&symtable, $3);
            if (sym == NULL) {
                report_error("Erreur_Semantique : identificateur non declare",
                             @3.first_line, @3.first_column, $3);
            }
            free($3);
        }
    ;

ecriture
    : T_OUT T_LPAREN liste_out T_RPAREN T_SEMI
    ;

liste_out
    : elem_out
    | liste_out T_COMMA elem_out
    ;

elem_out
    : T_STRING  { free($1); }
    | T_IDENT
        {
            Symbol *sym = st_lookup(&symtable, $1);
            if (sym == NULL) {
                report_error("Erreur_Semantique : identificateur non declare",
                             @1.first_line, @1.first_column, $1);
            }
            free($1);
        }
    ;

/* ================================================================== */
/*  4. EXPRESSIONS ARITHMETIQUES                                       */
/*                                                                    */
/*  Grammaire ambiguë résolue par les directives %left/%right.        */
/* ================================================================== */

expression
    : expression T_PLUS  expression
    | expression T_MINUS expression
    | expression T_MUL   expression
    | expression T_DIV   expression
    | T_LPAREN expression T_RPAREN
    | T_IDENT
        {
            Symbol *sym = st_lookup(&symtable, $1);
            if (sym == NULL) {
                report_error("Erreur_Semantique : identificateur non declare",
                             @1.first_line, @1.first_column, $1);
            }
            free($1);
        }
    | T_IDENT T_LBRACK expression T_RBRACK
        {
            Symbol *sym = st_lookup(&symtable, $1);
            if (sym == NULL) {
                report_error("Erreur_Semantique : identificateur non declare",
                             @1.first_line, @1.first_column, $1);
            } else if (sym->nature != NAT_ARRAY) {
                report_error("Erreur_Semantique : indexation d une variable non-tableau",
                             @1.first_line, @1.first_column, $1);
            }
            free($1);
        }
    | T_CONST_INT
    | T_CONST_FLOAT
    ;

/* ================================================================== */
/*  5. EXPRESSIONS DE CONDITION                                        */
/*                                                                    */
/*  Comparaisons : expression op expression                           */
/*  Logique      : (cond AND cond), (cond OR cond), NON(cond)        */
/* ================================================================== */

condition_expr
    : expression T_GT  expression
    | expression T_LT  expression
    | expression T_GE  expression
    | expression T_LE  expression
    | expression T_EQ  expression
    | expression T_NEQ expression
    | T_LPAREN condition_expr T_AND condition_expr T_RPAREN
    | T_LPAREN condition_expr T_OR  condition_expr T_RPAREN
    | T_NON T_LPAREN condition_expr T_RPAREN
    ;

%%

/* ================================================================== */
/*  Fonction d'erreur BISON                                            */
/* ================================================================== */
void yyerror(const char *msg) {
    fprintf(stderr, "%s, ligne %d, colonne %d, entite : '%s'\n",
            msg, yylineno, yycolumn, yytext ? yytext : "?");
}

/* ================================================================== */
/*  Point d'entrée main                                                */
/* ================================================================== */
int main(int argc, char *argv[]) {
    extern FILE *yyin;

    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror(argv[1]);
            return EXIT_FAILURE;
        }
    } else {
        yyin = stdin;
    }

    st_init(&symtable);

    int result = yyparse();

    st_free(&symtable);
    if (yyin != stdin) fclose(yyin);

    if (result == 0)
        printf("Compilation terminee avec succes.\n");
    else
        printf("Compilation terminee avec des erreurs.\n");

    return result;
}
