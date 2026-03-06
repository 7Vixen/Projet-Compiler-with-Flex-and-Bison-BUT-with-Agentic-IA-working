/*
 * table_Hashage.h
 * ===============
 * Table des symboles du compilateur ProLang — déclarations de types et prototypes.
 * Implémentée sous forme de table de hachage (djb2 + chaînage externe).
 *
 * ProLang Compiler — Master 1 USTHB 2025/2026
 */

#ifndef TABLE_HASHAGE_H
#define TABLE_HASHAGE_H

#define TABLE_SIZE    211  /* taille première pour limiter les collisions  */
#define MAX_NAME_LEN   15  /* 14 caractères + '\0'                         */

/* ------------------------------------------------------------------ */
/*  Nature de l'entité déclarée                                         */
/* ------------------------------------------------------------------ */
typedef enum {
    NAT_VAR,        /* variable simple    */
    NAT_CONST,      /* constante          */
    NAT_ARRAY       /* tableau            */
} Nature;

/* ------------------------------------------------------------------ */
/*  Type de la donnée                                                   */
/* ------------------------------------------------------------------ */
typedef enum {
    TYPE_INTEGER,
    TYPE_FLOAT,
    TYPE_UNKNOWN    /* avant complétion sémantique */
} DataType;

/* ------------------------------------------------------------------ */
/*  Valeur stockée — union pour économiser la mémoire                  */
/* ------------------------------------------------------------------ */
typedef union {
    int   int_val;
    float float_val;
} Value;

/* ------------------------------------------------------------------ */
/*  Entrée de la table des symboles                                     */
/* ------------------------------------------------------------------ */
typedef struct Symbol {
    char         name[MAX_NAME_LEN]; /* nom de l'identificateur              */
    Nature       nature;             /* VAR / CONST / ARRAY                  */
    DataType     type;               /* integer / float                      */
    Value        value;              /* valeur initiale (si initialisée)     */
    int          is_initialized;     /* 1 si une valeur initiale est connue  */
    int          array_size;         /* taille du tableau (NAT_ARRAY seult.) */
    int          line;               /* ligne de déclaration (pour erreurs)  */
    int          column;             /* colonne de déclaration               */
    struct Symbol *next;             /* chaînage pour gestion des collisions */
} Symbol;

/* ------------------------------------------------------------------ */
/*  La table elle-même                                                  */
/* ------------------------------------------------------------------ */
typedef struct {
    Symbol *buckets[TABLE_SIZE];
    int     count;                   /* nombre total de symboles insérés     */
} SymbolTable;

/* ------------------------------------------------------------------ */
/*  Fonctions publiques                                                 */
/* ------------------------------------------------------------------ */

/** Initialise la table (met tous les buckets à NULL). */
void         st_init   (SymbolTable *st);

/** Fonction de hachage djb2 sur le nom. */
unsigned int st_hash   (const char *name);

/**
 * Insère un nouveau symbole.
 * Retourne  0 : succès
 *          -1 : identificateur déjà déclaré (double déclaration — erreur sémantique)
 */
int          st_insert (SymbolTable *st, const char *name,
                         Nature nature, DataType type,
                         int is_init, Value value,
                         int array_size, int line, int col);

/**
 * Recherche un symbole par son nom.
 * Retourne un pointeur vers l'entrée, ou NULL si introuvable.
 */
Symbol      *st_lookup (SymbolTable *st, const char *name);

/**
 * Met à jour la valeur d'un symbole existant (lors d'une affectation).
 * Retourne  0 : succès
 *          -1 : symbole introuvable
 *          -2 : tentative de modification d'une constante (erreur sémantique)
 */
int          st_update (SymbolTable *st, const char *name, Value value);

/**
 * Supprime un symbole de la table.
 * Retourne  0 : succès
 *          -1 : symbole introuvable
 */
int          st_delete (SymbolTable *st, const char *name);

/** Affiche le contenu complet de la table (debug / rapport). */
void         st_print  (const SymbolTable *st);

/** Libère toute la mémoire allouée par la table. */
void         st_free   (SymbolTable *st);

#endif /* TABLE_HASHAGE_H */
