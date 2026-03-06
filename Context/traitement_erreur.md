# Traitement des Erreurs

L'affichage et le traitement des erreurs de compilation sont primordiaux pour le compilateur ProLang et doivent respecter un formalisme extrêmement strict.

## Format Strict d'Affichage
Tout message d'erreur rapporté par les phases du compilateur doit respecter le format d'affichage exigé lors de la détection :

```text
Type_ de_ l’erreur, ligne <Ligne>, colonne <Colonne>, entité qui a générée l’erreur
```
Exemple officiel : `Type_ de_ l’erreur, ligne 12, colonne 5, entité qui a générée l’erreur`

**Contenu de Configuration Obligatoire :**
1. **Type_ de_ l’erreur** : La catégorie globale de l'erreur interceptée.
   - *Erreur Lexicale* (ex: entité illégale).
   - *Erreur Syntaxique* (ex: manque d'un `;` selon BISON).
   - *Erreur Sémantique* (ex: "identificateurs non déclarés", "types incompatibles", tentative d'affectation sur une "constante").
2. **Ligne** : Le numéro de la ligne extraite via le parser FLEX/BISON au moment du plantage ou de l'analyse (`yylineno`).
3. **Colonne** : La valeur de comptage horizontale (position du mot bloquant) générée via un compteur dans FLEX.
4. **Entité qui a généré l'erreur** : L'unité lexicale capturée ou le symbole responsable de l'arrêt (ex: une variable `X1`, une valeur `5.5`).
