# Structure Lexicale — Analyse Lexicale (FLEX)

Cette section définit les tokens (expressions régulières) et les contraintes lexicales du langage « ProLang ».

## 1. Identificateurs
Un identificateur est une entité lexicale qui représente le nom d'un programme, d'une variable ou d'une constante.
**Contraintes :**
- Doit obligatoirement commencer par une lettre alphabétique (minuscule).
- Composé de lettres minuscules, de chiffres et/ou de tirets bas (`_`).
- **Longueur maximale** : 14 caractères.
- Ne doit **pas** se terminer par un tiret bas (`_`).
- Ne doit **pas** contenir de tirets bas consécutifs.

**Expression Régulière (Indicative) :**
```regex
[a-z]([a-z0-9]|_[a-z0-9]){0,13}
```

## 2. Types et Mots-clés de déclaration
| Entité Lexicale | Description | Exemples |
|---|---|---|
| `integer` | Constante entière signée ou non signée, valeur entre -32768 et 32767. Si signée, elle doit être entre parenthèses. | `5`, `(-5)`, `(+5)` |
| `float` | Constante réelle avec un point décimal, signée ou non signée. Si signée, elle doit être entre parenthèses. | `5.5`, `(-5.76)`, `(+568.77)` |

## 3. Opérateurs
| Catégorie | Opérateurs |
|---|---|
| **Arithmétiques** | `+`, `-`, `*`, `/` |
| **Logiques** | `AND`, `OR`, `NON` |
| **Comparaison** | `<`, `>`, `<=`, `>=`, `==`, `!=` |
| **Affectation** | `` (ou syntaxe équivalente définie) |
| **Initialisation** | `$=` (selon les termes exacts du cahier des charges / requêtes) |

## 4. Symboles Spéciaux et Séparateurs
- Séparateur de déclarations : `|` (sépare les variables sur une même ligne)
- Fin d'instruction : `;`
- Bloc d'instructions : `{`, `}`
- Déclaration de type : `:`

## 5. Commentaires
Les commentaires sont ignorés par l'analyseur lexical.
- **Sur une seule ligne** : Tout texte commençant par `%%` jusqu'à la fin de la ligne.
- **Sur plusieurs lignes** : Tout texte compris entre `//*` et `*//`.
