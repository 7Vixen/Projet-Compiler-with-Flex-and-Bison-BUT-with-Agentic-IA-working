# Structure Syntaxique — Grammaire BNF (BISON)

Cette section détaille les règles grammaticales complètes du compilateur BISON pour valider la structure du programme ProLang.

---

## 1. Structure Générale du Programme

```bnf
<Programme> ::= BeginProject <Identificateur> ;
                Setup :
                    <Partie_Declarations>
                Run :
                {
                    <Partie_Instructions>
                }
                EndProject ;
```

---

## 2. Partie Déclarations (`Setup :`)

```bnf
<Partie_Declarations> ::= <Partie_Declarations> <Declaration>
                        | <Declaration>
                        | ε

<Declaration> ::= <Decl_Variable>
                | <Decl_Tableau>
                | <Decl_Constante>

/* Déclaration de variable simple — avec ou sans initialisation */
<Decl_Variable> ::= define <Liste_Vars> : <Type> ;
                  | define <Liste_Vars> : <Type> = <Constante> ;

/* Plusieurs variables séparées par | */
<Liste_Vars> ::= <Identificateur>
               | <Liste_Vars> | <Identificateur>

/* Déclaration de tableau */
<Decl_Tableau> ::= define <Identificateur> : [ <Type> ; <Entier_Positif> ] ;

/* Déclaration de constante */
<Decl_Constante> ::= const <Identificateur> : <Type> = <Constante> ;

<Type> ::= integer
         | float
```

---

## 3. Partie Instructions (`Run :`)

> Toute instruction doit se terminer par un point-virgule `;`.

```bnf
<Partie_Instructions> ::= <Partie_Instructions> <Instruction>
                        | <Instruction>
                        | ε

<Instruction> ::= <Affectation>
                | <Condition>
                | <Boucle_While>
                | <Boucle_For>
                | <Lecture>
                | <Ecriture>

/* Affectation — variable simple */
<Affectation> ::= <Identificateur> <- <Expression> ;

/* Affectation — élément de tableau */
<Affectation> ::= <Identificateur> [ <Expression> ] <- <Expression> ;

/* Condition if / else */
<Condition> ::= if ( <Expr_Condition> ) then: { <Partie_Instructions> }
                else { <Partie_Instructions> } endIf ;

/* Boucle while */
<Boucle_While> ::= loop while ( <Expr_Condition> ) { <Partie_Instructions> } endloop ;

/* Boucle for */
<Boucle_For> ::= for <Identificateur> in <Valeur> to <Valeur> { <Partie_Instructions> } endfor ;

/* Lecture */
<Lecture> ::= in ( <Identificateur> ) ;

/* Écriture — peut contenir un texte littéral et/ou des identificateurs */
<Ecriture> ::= out ( <Liste_Out> ) ;

<Liste_Out> ::= <Elem_Out>
              | <Liste_Out> , <Elem_Out>

<Elem_Out> ::= <Chaine>
             | <Identificateur>
```

---

## 4. Expressions

```bnf
<Expression> ::= <Expression> + <Expression>
               | <Expression> - <Expression>
               | <Expression> * <Expression>
               | <Expression> / <Expression>
               | ( <Expression> )
               | <Identificateur>
               | <Identificateur> [ <Expression> ]
               | <Constante>

<Expr_Condition> ::= <Expression> > <Expression>
                   | <Expression> < <Expression>
                   | <Expression> >= <Expression>
                   | <Expression> <= <Expression>
                   | <Expression> == <Expression>
                   | <Expression> != <Expression>
                   | ( <Expr_Condition> AND <Expr_Condition> )
                   | ( <Expr_Condition> OR  <Expr_Condition> )
                   | NON ( <Expr_Condition> )
```

---

## 5. Constantes et Valeurs terminales

```bnf
<Constante> ::= <Entier>
              | <Reel>
              | ( + <Entier> )
              | ( - <Entier> )
              | ( + <Reel> )
              | ( - <Reel> )

<Valeur> ::= <Entier>
           | <Identificateur>

<Entier_Positif> ::= [0-9]+          /* constante entière > 0, taille de tableau */
<Entier>         ::= [0-9]+
<Reel>           ::= [0-9]+ . [0-9]+
<Chaine>         ::= " [^"]* "
<Identificateur> ::= /* défini dans l'analyseur lexical */
```

---

## 6. Priorité et Associativité des Opérateurs (directive BISON)

Les directives suivantes doivent être déclarées dans le fichier `.y` pour lever toute ambiguïté.  
L'ordre de déclaration va du **moins prioritaire** au **plus prioritaire** :

| Priorité (croissante ↓) | Associativité | Opérateurs |
|---|---|---|
| 1 — la plus faible | gauche | `AND` |
| 2 | gauche | `OR` |
| 3 | **droite (unaire)** | `NON` |
| 4 | gauche | `<` `>` `<=` `>=` `==` `!=` |
| 5 | gauche | `+` `-` |
| 6 — la plus forte | gauche | `*` `/` |

> **Note sur `NON`** : C'est un opérateur **unaire** (préfixe). Il doit être déclaré avec `%right` ou via `%precedence` dans BISON, séparément des opérateurs binaires.

---

## 7. Erreurs Syntaxiques Attendues

Le compilateur doit détecter et signaler les erreurs suivantes avec ligne, colonne et entité :

| Erreur | Exemple déclencheur |
|---|---|
| Mot-clé manquant (`EndProject`, `endIf`, etc.) | Bloc non fermé |
| Point-virgule manquant | Instruction sans `;` |
| Type inconnu dans `define` / `const` | `define x : boolean ;` |
| Taille de tableau invalide (≤ 0) | `define T : [integer ; 0] ;` |
| Accolade non fermée | `if (...) then: { ... ` sans `}` |
| Expression malformée | `a <- + ;` |