# Table des Symboles — Table de Hachage

Cette section décrit la structure et les fonctions de gestion de la table des symboles du compilateur ProLang, implémentée sous forme de **table de hachage**.

---

## 1. Quand est-elle remplie ?

| Phase | Action sur la table |
|---|---|
| **Analyse lexicale (FLEX)** | Détection des identificateurs — première insertion brute (nom uniquement) |
| **Analyse sémantique (BISON)** | Complétion de l'entrée : type, nature, valeur initiale, taille (tableaux) |
| **Partie instruction** | Recherche pour vérifier existence et compatibilité de type |

---

## 2. Structure d'une entrée (`Symbol`)

Chaque entrée dans la table représente une entité déclarée dans la section `Setup :`.

```c
/* symbol_table.h */

#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#define TABLE_SIZE   211   /* taille première pour limiter les collisions  */
#define MAX_NAME_LEN  15   /* 14 caractères + '\0'                         */

/* Nature de l'entité */
typedef enum {
    NAT_VAR,        /* variable simple    */
    NAT_CONST,      /* constante          */
    NAT_ARRAY       /* tableau            */
} Nature;

/* Type de la valeur */
typedef enum {
    TYPE_INTEGER,
    TYPE_FLOAT,
    TYPE_UNKNOWN    /* avant complétion sémantique */
} DataType;

/* Valeur stockée (union pour éviter le gaspillage mémoire) */
typedef union {
    int   int_val;
    float float_val;
} Value;

/* Entrée de la table */
typedef struct Symbol {
    char        name[MAX_NAME_LEN]; /* nom de l'identificateur              */
    Nature      nature;             /* VAR / CONST / ARRAY                  */
    DataType    type;               /* integer / float                      */
    Value       value;              /* valeur initiale (si initialisée)     */
    int         is_initialized;     /* 1 si une valeur initiale est connue  */
    int         array_size;         /* taille du tableau (NAT_ARRAY seult.) */
    int         line;               /* ligne de déclaration (pour erreurs)  */
    int         column;             /* colonne de déclaration               */
    struct Symbol *next;            /* chaînage pour gestion des collisions */
} Symbol;

/* La table elle-même */
typedef struct {
    Symbol *buckets[TABLE_SIZE];
    int     count;                  /* nombre total de symboles insérés     */
} SymbolTable;

/* ------------------------------------------------------------------ */
/*  Fonctions publiques                                                 */
/* ------------------------------------------------------------------ */

/** Initialise la table (met tous les buckets à NULL). */
void        st_init       (SymbolTable *st);

/** Fonction de hachage (djb2 sur le nom). */
unsigned int st_hash      (const char *name);

/**
 * Insère un nouveau symbole.
 * Retourne  0 : succès
 *          -1 : identificateur déjà déclaré (erreur sémantique)
 */
int         st_insert     (SymbolTable *st, const char *name,
                            Nature nature, DataType type,
                            int is_init, Value value,
                            int array_size, int line, int col);

/**
 * Recherche un symbole par son nom.
 * Retourne un pointeur vers l'entrée, ou NULL si introuvable.
 */
Symbol     *st_lookup     (SymbolTable *st, const char *name);

/**
 * Met à jour la valeur d'un symbole existant (affectation).
 * Retourne  0 : succès
 *          -1 : symbole introuvable
 *          -2 : tentative de modification d'une constante
 */
int         st_update     (SymbolTable *st, const char *name, Value value);

/**
 * Supprime un symbole (non requis en compilation simple,
 * utile si on étend à la gestion de portées).
 * Retourne  0 : succès
 *          -1 : symbole introuvable
 */
int         st_delete     (SymbolTable *st, const char *name);

/** Affiche le contenu complet de la table (debug / rapport). */
void        st_print      (const SymbolTable *st);

/** Libère toute la mémoire allouée. */
void        st_free       (SymbolTable *st);

#endif /* SYMBOL_TABLE_H */
```

---

## 3. Fonction de hachage retenue : djb2

```c
unsigned int st_hash(const char *name) {
    unsigned int hash = 5381;
    int c;
    while ((c = *name++))
        hash = ((hash << 5) + hash) + c;  /* hash * 33 + c */
    return hash % TABLE_SIZE;
}
```

- Simple, rapide, distribution uniforme sur des noms courts.
- `TABLE_SIZE = 211` (nombre premier) minimise les collisions.

---

## 4. Gestion des collisions — Chaînage externe

Les collisions sont résolues par **liste chaînée** sur chaque bucket :

```
buckets[42] → [x | int | var] → [x2 | float | var] → NULL
buckets[87] → [Pi | float | const | 3.14159] → NULL
...
```

---

## 5. Informations stockées par nature

| Nature | name | type | value | is_init | array_size | line | col |
|---|---|---|---|---|---|---|---|
| `NAT_VAR` | ✓ | ✓ | ✓ (si init) | ✓ | — | ✓ | ✓ |
| `NAT_CONST` | ✓ | ✓ | ✓ (obligatoire) | 1 | — | ✓ | ✓ |
| `NAT_ARRAY` | ✓ | ✓ | — | 0 | ✓ (≥1) | ✓ | ✓ |

---

## 6. Vérifications sémantiques assurées par la table

- **Double déclaration** : `st_lookup` avant `st_insert` — erreur si déjà présent.
- **Identificateur non déclaré** : `st_lookup` dans la partie `Run:` — erreur si NULL.
- **Modification d'une constante** : `st_update` vérifie `nature != NAT_CONST`.
- **Compatibilité de type** : le type stocké est comparé lors d'une affectation ou expression.
- **Taille de tableau** : `array_size > 0` vérifié à l'insertion.

---

## 7. Fichiers générés

| Fichier | Contenu |
|---|---|
| `symbol_table.h` | Déclarations des types et prototypes (ce fichier) |
| `symbol_table.c` | Implémentation de toutes les fonctions |

---

## 8. Exemple d'état de la table après analyse de :

```prolang
define a | b | c : integer;
define moyenne : float = 0.0;
define Tab : [integer ; 20];
const Pi : float = 3.14159;
```

| # | Nom | Nature | Type | Valeur | Init | Taille |
|---|---|---|---|---|---|---|
| 1 | `a` | VAR | INTEGER | — | non | — |
| 2 | `b` | VAR | INTEGER | — | non | — |
| 3 | `c` | VAR | INTEGER | — | non | — |
| 4 | `moyenne` | VAR | FLOAT | 0.0 | oui | — |
| 5 | `Tab` | ARRAY | INTEGER | — | non | 20 |
| 6 | `Pi` | CONST | FLOAT | 3.14159 | oui | — |