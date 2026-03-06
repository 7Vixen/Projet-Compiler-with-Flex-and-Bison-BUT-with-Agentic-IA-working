# Structure Syntaxique — Grammaire BNF (BISON)

Cette section détaille les règles grammaticales du compilateur BISON pour valider la structure du programme ProLang.

## 1. Structure Générale du Programme
Le langage impose une structure stricte divisée en une partie Setup et une partie Run.
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

## 2. Poids et Priorité des Opérateurs
La résolution des ambiguïtés se fait grâce à l'associativité et la priorité des opérateurs ("Opérateurs Arithmétiques", "Opérateurs Logiques", "Opérateurs de comparaison").

**Associativité** : Gauche pour tous les opérateurs.

| Ordre de Priorité (Croissant) | Opérateurs |
| :---: | :--- |
| **1 (Plus faible)** | Opérateurs Logiques : `AND`, `OR` |
| **2** | Opérateurs Logiques : `NON` |
| **3** | Opérateurs de Comparaison : `<`, `>`, `>=`, `<=`, `==`, `!=` |
| **4** | Opérateurs Arithmétiques : `+`, `-` |
| **5 (Plus forte)** | Opérateurs Arithmétiques : `*`, `/` |

## 3. Partie Déclarations (`Setup :`)
- **Déclaration de variables simples** :
  `define <nom_var> : <type> ;`
  Plusieurs variables peuvent être déclarées ensemble en utilisant `|` :
  `define a | b | c : integer ;`
  Déclaration avec initialisation (ex: en utilisant `$=` selon les cas / `=` tel qu'illustré) :
  `define b : integer = 10 ;`

- **Déclaration d'un tableau** :
  `define <nom_tab> : [ <type> ; <Taille> ] ;`
  *(La taille doit être une constante entière positive)*

- **Déclaration d'une constante** :
  `const <nom_const> : <type> = Valeur ;`

## 4. Partie Instructions (`Run :`)
> Toute instruction doit se terminer par un point-virgule `;`.

- **Affectation** : 
  `<idf>  <Expression> ;`
  `<idf>[<indice>]  <Expression> ;`

- **Condition (`if`)** :
```bnf
if ( <Condition> ) then:
{
    <Instructions>
} else {
    <Instructions>
} endIf ;
```

- **Boucle `loop while`** :
```bnf
loop while ( <Condition> ) {
    <Instructions>
} endloop ;
```

- **Boucle `for`** :
```bnf
for <idf> in <val_init> to <val_limit> {
    <Instructions>
} endfor ;
```

- **Lecture et Écriture (`in`, `out`)** :
  `in(<UserName>) ;`
  `out("Texte", <UserName>) ;`
