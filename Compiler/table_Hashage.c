/*
 * table_Hashage.c
 * ===============
 * Implémentation de la table des symboles du compilateur ProLang.
 * Algorithme de hachage : djb2  |  Gestion des collisions : chaînage externe.
 *
 * ProLang Compiler — Master 1 USTHB 2025/2026
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "table_Hashage.h"

/* ------------------------------------------------------------------ */
/*  st_init — Initialisation                                            */
/* ------------------------------------------------------------------ */
void st_init(SymbolTable *st) {
    int i;
    for (i = 0; i < TABLE_SIZE; i++)
        st->buckets[i] = NULL;
    st->count = 0;
}

/* ------------------------------------------------------------------ */
/*  st_hash — Fonction de hachage djb2                                 */
/* ------------------------------------------------------------------ */
unsigned int st_hash(const char *name) {
    unsigned int hash = 5381;
    int c;
    while ((c = (unsigned char)*name++))
        hash = ((hash << 5) + hash) + c;  /* hash * 33 + c */
    return hash % TABLE_SIZE;
}

/* ------------------------------------------------------------------ */
/*  st_insert — Insertion d'un nouveau symbole                         */
/* ------------------------------------------------------------------ */
int st_insert(SymbolTable *st, const char *name,
               Nature nature, DataType type,
               int is_init, Value value,
               int array_size, int line, int col)
{
    /* Vérification de double déclaration */
    if (st_lookup(st, name) != NULL)
        return -1;  /* identificateur déjà déclaré */

    /* Allocation du nouveau nœud */
    Symbol *sym = (Symbol *)malloc(sizeof(Symbol));
    if (!sym) {
        fprintf(stderr, "Erreur_Interne, ligne %d, colonne %d, entite : '%s' — malloc échoué\n",
                line, col, name);
        exit(EXIT_FAILURE);
    }

    strncpy(sym->name, name, MAX_NAME_LEN - 1);
    sym->name[MAX_NAME_LEN - 1] = '\0';
    sym->nature         = nature;
    sym->type           = type;
    sym->value          = value;
    sym->is_initialized = is_init;
    sym->array_size     = array_size;
    sym->line           = line;
    sym->column         = col;

    /* Insertion en tête du bucket (plus rapide) */
    unsigned int idx = st_hash(name);
    sym->next          = st->buckets[idx];
    st->buckets[idx]   = sym;
    st->count++;

    return 0;
}

/* ------------------------------------------------------------------ */
/*  st_lookup — Recherche par nom                                       */
/* ------------------------------------------------------------------ */
Symbol *st_lookup(SymbolTable *st, const char *name) {
    unsigned int idx = st_hash(name);
    Symbol *cur = st->buckets[idx];
    while (cur) {
        if (strcmp(cur->name, name) == 0)
            return cur;
        cur = cur->next;
    }
    return NULL;
}

/* ------------------------------------------------------------------ */
/*  st_update — Mise à jour de la valeur (affectation)                 */
/* ------------------------------------------------------------------ */
int st_update(SymbolTable *st, const char *name, Value value) {
    Symbol *sym = st_lookup(st, name);
    if (!sym)
        return -1;  /* symbole introuvable */
    if (sym->nature == NAT_CONST)
        return -2;  /* tentative de modification d'une constante */

    sym->value          = value;
    sym->is_initialized = 1;
    return 0;
}

/* ------------------------------------------------------------------ */
/*  st_delete — Suppression d'un symbole                               */
/* ------------------------------------------------------------------ */
int st_delete(SymbolTable *st, const char *name) {
    unsigned int idx = st_hash(name);
    Symbol *cur  = st->buckets[idx];
    Symbol *prev = NULL;

    while (cur) {
        if (strcmp(cur->name, name) == 0) {
            if (prev)
                prev->next = cur->next;
            else
                st->buckets[idx] = cur->next;
            free(cur);
            st->count--;
            return 0;
        }
        prev = cur;
        cur  = cur->next;
    }
    return -1;  /* symbole introuvable */
}

/* ------------------------------------------------------------------ */
/*  st_print — Affichage complet (debug / rapport)                     */
/* ------------------------------------------------------------------ */
static const char *nature_str(Nature n) {
    switch (n) {
        case NAT_VAR:   return "VAR";
        case NAT_CONST: return "CONST";
        case NAT_ARRAY: return "ARRAY";
        default:        return "?";
    }
}

static const char *type_str(DataType t) {
    switch (t) {
        case TYPE_INTEGER: return "INTEGER";
        case TYPE_FLOAT:   return "FLOAT";
        default:           return "UNKNOWN";
    }
}

void st_print(const SymbolTable *st) {
    int i;
    printf("\n========================================\n");
    printf("  TABLE DES SYMBOLES — ProLang\n");
    printf("  Total : %d entrée(s)\n", st->count);
    printf("========================================\n");
    printf("%-16s %-7s %-8s %-10s %-5s %-6s %-5s %-5s\n",
           "Nom", "Nature", "Type", "Valeur", "Init", "Taille", "Ligne", "Col");
    printf("------------------------------------------------------------------\n");

    for (i = 0; i < TABLE_SIZE; i++) {
        Symbol *cur = st->buckets[i];
        while (cur) {
            char val_buf[32] = "-";
            if (cur->is_initialized) {
                if (cur->type == TYPE_INTEGER)
                    snprintf(val_buf, sizeof(val_buf), "%d", cur->value.int_val);
                else
                    snprintf(val_buf, sizeof(val_buf), "%.6g", (double)cur->value.float_val);
            }
            char size_buf[16] = "-";
            if (cur->nature == NAT_ARRAY)
                snprintf(size_buf, sizeof(size_buf), "%d", cur->array_size);

            printf("%-16s %-7s %-8s %-10s %-5s %-6s %-5d %-5d\n",
                   cur->name,
                   nature_str(cur->nature),
                   type_str(cur->type),
                   val_buf,
                   cur->is_initialized ? "oui" : "non",
                   size_buf,
                   cur->line,
                   cur->column);
            cur = cur->next;
        }
    }
    printf("========================================\n\n");
}

/* ------------------------------------------------------------------ */
/*  st_free — Libération de toute la mémoire                          */
/* ------------------------------------------------------------------ */
void st_free(SymbolTable *st) {
    int i;
    for (i = 0; i < TABLE_SIZE; i++) {
        Symbol *cur = st->buckets[i];
        while (cur) {
            Symbol *next = cur->next;
            free(cur);
            cur = next;
        }
        st->buckets[i] = NULL;
    }
    st->count = 0;
}
