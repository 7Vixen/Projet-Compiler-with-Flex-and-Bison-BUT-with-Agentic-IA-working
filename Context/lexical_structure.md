# Structure Lexicale — Analyse Lexicale (FLEX)

Cette section définit les tokens (expressions régulières) et les contraintes lexicales du langage « ProLang ».

---

## 1. Identificateurs

Un identificateur représente le nom d'un programme, d'une variable ou d'une constante.

**Contraintes (extraites du PDF) :**
- Doit obligatoirement commencer par une lettre alphabétique minuscule.
- Composé uniquement de lettres minuscules, de chiffres et/ou de tirets bas (`_`).
- **Longueur maximale : 14 caractères.**
- Ne doit **pas** se terminer par un tiret bas (`_`).
- Ne doit **pas** contenir de tirets bas consécutifs (`__`).

**Expression Régulière (Indicative) :**
```regex
[a-z]([a-z0-9](_[a-z0-9])?)*
```
> Remarque : la contrainte des 14 caractères max doit être vérifiée dans l'action FLEX (via `strlen(yytext) <= 14`), car les regex POSIX ne gèrent pas facilement les bornes de longueur avec des groupes alternatifs.

**Exemples valides :** `isil_program`, `myprogram`, `testprog`

---

## 2. Mots-clés Réservés

Les mots-clés suivants sont réservés et doivent être reconnus **avant** les identificateurs dans FLEX :

| Mot-clé | Rôle |
|---|---|
| `BeginProject` | Début du programme |
| `EndProject` | Fin du programme |
| `Setup` | Début de la section déclarations |
| `Run` | Début de la section instructions |
| `define` | Déclaration de variable ou tableau |
| `const` | Déclaration de constante |
| `integer` | Type entier |
| `float` | Type réel |
| `if` | Début condition |
| `then` | Suite de la condition |
| `else` | Branche alternative |
| `endIf` | Fin de la condition |
| `loop` | Début de boucle |
| `while` | Condition de boucle while |
| `endloop` | Fin de boucle while |
| `for` | Début de boucle for |
| `in` | Mot-clé de la boucle for |
| `to` | Borne limite de la boucle for |
| `endfor` | Fin de boucle for |
| `AND` | Opérateur logique ET |
| `OR` | Opérateur logique OU |
| `NON` | Opérateur logique négation |
| `in(...)` | Instruction de lecture |
| `out(...)` | Instruction d'écriture |

---

## 3. Constantes (Tokens de valeur)

### 3.1 Constantes entières (`integer`)
- Suite de chiffres, valeur entre **-32768** et **32767**.
- Si signée (+ ou -), elle doit être **entre parenthèses**.

**Exemples :** `5`, `(-5)`, `(+5)`

```regex
[0-9]+
\([+-][0-9]+\)
```

### 3.2 Constantes réelles (`float`)
- Suite de chiffres contenant un **point décimal**.
- Si signée (+ ou -), elle doit être **entre parenthèses**.

**Exemples :** `5.5`, `(-5.76)`, `(+568.77)`

```regex
[0-9]+\.[0-9]+
\([+-][0-9]+\.[0-9]+\)
```

### 3.3 Chaînes de caractères
Utilisées dans les instructions `out(...)` pour afficher du texte littéral.

```regex
\"[^\"]*\"
```

---

## 4. Opérateurs

| Catégorie | Opérateurs |
|---|---|
| **Arithmétiques** | `+`, `-`, `*`, `/` |
| **Logiques** | `AND`, `OR`, `NON` |
| **Comparaison** | `<`, `>`, `<=`, `>=`, `==`, `!=` |
| **Affectation** | `←` (flèche gauche, telle que définie dans le PDF) |
| **Initialisation (déclaration)** | `=` (utilisé dans `define` et `const` pour l'initialisation) |

> **Note :** L'opérateur d'affectation dans la partie instruction est représenté par `←` dans le PDF. Dans l'implémentation FLEX/BISON, on pourra le représenter par un token dédié (ex: `ASSIGN`).

---

## 5. Symboles Spéciaux et Séparateurs

| Symbole | Rôle |
|---|---|
| `;` | Fin d'instruction (obligatoire pour toute instruction) |
| `:` | Séparateur type dans les déclarations |
| `\|` | Séparateur entre plusieurs noms de variables dans `define` |
| `{` `}` | Délimiteurs de bloc d'instructions |
| `[` `]` | Délimiteurs pour la déclaration et l'accès aux tableaux |
| `(` `)` | Parenthèses (expressions, constantes signées) |
| `,` | Séparateur d'arguments dans `out(...)` |

---

## 6. Commentaires

Les commentaires sont **ignorés** par l'analyseur lexical (aucun token produit).

- **Sur une seule ligne** : Tout texte commençant par `%%` jusqu'à la fin de la ligne.
- **Sur plusieurs lignes** : Tout texte compris entre `//*` et `*//`.

**Exemples :**
```
%% ceci est un commentaire sur une seule ligne

//* Ceci est un commentaire sur
   plusieurs lignes
*//
```

## 7.Lien avec la table des symboles

tu a maintenant lu le fichier lexical_structure.md , et vu que la table des symboles commence à se remplir dès l'analyse lexicale (reconnaissance des identificateurs), et se complète/vérifie pendant l'analyse syntaxico-sémantique (types, valeurs, etc.).  tu va aussi implémanté la table de Hashage pour cela suit les instruction du fichier suivant : Table_Hashage_context.md qui est toujours dans le docier /context 
