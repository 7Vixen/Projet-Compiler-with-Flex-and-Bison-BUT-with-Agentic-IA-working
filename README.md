# Documentation Technique : Projet Compilateur ProLang

Ce document détaille la conception et l'implémentation du compilateur pour le langage **ProLang**, en mettant l'accent sur les choix techniques effectués pour respecter les spécifications du projet (PDF).

---

## I. Analyseur Lexical (FLEX)

L'analyseur lexical est la première étape du processus. Son rôle est de transformer le code source (flux de caractères) en une suite de **tokens** (unités lexicales).

### 1. Gestion Précise de la Localisation : La Macro `YY_USER_ACTION`

L'un des points les plus critiques pour un compilateur est la clarté des messages d'erreur. Le PDF exige d'afficher la **ligne** et la **colonne** de chaque entité. 

Pour automatiser cela, nous avons utilisé la macro `YY_USER_ACTION`. Voici son fonctionnement détaillé :

```c
#define YY_USER_ACTION \
    yylloc.first_line   = yylineno; \
    yylloc.first_column = yycolumn; \
    yylloc.last_line    = yylineno; \
    yylloc.last_column  = yycolumn + (int)yyleng - 1; \
    yycolumn           += (int)yyleng;
```

**Pourquoi avoir fait ce choix ?**
*   **Synchronisation** : Cette macro est exécutée par FLEX juste avant l'action associée à chaque token reconnu. 
*   **Lien avec Bison** : Elle remplit la structure `yylloc`. Ainsi, l'analyseur syntaxique (Bison) sait exactement où se trouve chaque symbole dans le fichier.
*   **Calcul de la colonne** : `yycolumn` est notre compteur manuel. `yyleng` représente la longueur du texte du token (`yytext`). En additionnant `yyleng` à `yycolumn`, nous préparons la position du prochain token.

---

### 2. Logique et Conception des Expressions Régulières

Chaque règle a été pensée pour traduire les contraintes métier du PDF en logique formelle.

#### A. Les Identificateurs (`IDENT_BASE`)
**La règle :** `{LETTRE}({LETTRE}|{CHIFFRE}|"_"({LETTRE}|{CHIFFRE}))*`

**L'idée derrière la conception :**
Le PDF impose trois contraintes complexes :
1. Commencer par une lettre.
2. Pas d'underscores consécutifs (`__`).
3. Pas d'underscore à la fin.

**Comment la règle résout-elle cela ?**
*   Le début `{LETTRE}` assure la règle 1.
*   Le groupe `("_"({LETTRE}|{CHIFFRE}))` est la clé. En forçant chaque `_` à être immédiatement suivi par une lettre ou un chiffre, on rend impossible l'existence de `__` ou d'un `_` final, car la répétition `*` ne peut se terminer que par un caractère alphanumérique ou le groupe complet (qui finit par un alphanumérique).
*   **Contrôle supplémentaire** : Une vérification de longueur (`strlen > 14`) et de caractère final est effectuée dans l'action C pour garantir une robustesse totale face aux spécifications.

#### B. Nombres Signés entre parenthèses
**La règle :** `"("[+-]{ENTIER}")"` et `"("[+-]{REEL}")"`

**L'idée :** 
Pour éviter les conflits d'ambiguïté (est-ce un signe de soustraction ou un signe de nombre ?), le langage impose que toute constante signée soit encapsulée. 
*   **Traitement** : Dans l'action, nous utilisons `atoi(yytext + 1)` ou `atof(yytext + 1)`. Le `+1` permet de sauter la parenthèse ouvrante lors de la conversion numérique.
*   **Bornes** : Une vérification est faite pour s'assurer que les entiers restent dans l'intervalle 16-bit `[-32768, 32767]`.

#### C. Commentaires Multi-lignes "Machine à états"
**La règle :** `"//*"` (déclenche un bloc de code C)

**L'idée :** 
Les expressions régulières FLEX peuvent être complexes à gérer pour les commentaires multi-lignes (problèmes de récursivité ou de gloutonnerie). Nous avons opté pour une approche impérative :
*   On utilise une boucle `while` avec `input()`.
*   On suit manuellement `prev1` et `prev2` pour détecter la séquence de fin `*//`.
*   **Mise à jour de position** : On incrémente `yylineno` et on réinitialise `yycolumn` à chaque `\n` rencontré à l'intérieur du commentaire.

#### D. Manipulation des Chaînes de Caractères
**La règle :** `\"[^\"]*\"`

**L'idée :** 
Reconnaître tout texte entre guillemets. Le compilateur doit extraire la *valeur* sémantique sans les délimiteurs.
*   **L'astuce** : Nous allouons une nouvelle chaîne et utilisons `strncpy` pour copier uniquement le contenu situé entre le premier et le dernier guillemet.

---

### 3. Configuration de l'environnement (Options)

*   `%option yylineno` : Gestion automatique des lignes par FLEX.
*   `%option noyywrap` : Analyse d'un seul fichier source sans chaînage.

---

## II. Analyseur Syntaxique (BISON)

*(Cette section sera complétée après l'implémentation finale de la grammaire et des actions sémantiques.)*