# Analyse Sémantique

Cette phase vérifie la cohérence du code d'un point de vue sens. Les règles de typage, de déclaration et de compatibilité doivent être rigoureusement appliquées.

## 1. Vérification des Déclarations
- **Identificateurs non déclarés** : Toute variable ou constante (scalaire ou tableau) utilisée dans la partie `Run :` **doit** avoir été préalablement déclarée dans la partie `Setup :`.
- **Double déclaration** : Un identificateur ne peut pas être déclaré plus d'une fois dans le même scope (programme).
- **Taille de tableau** : Lors de la déclaration d'un tableau, l'entité `<Taille>` doit obligatoirement être évaluée comme une **constante entière positive**.

## 2. Règles de Typage (`integer`, `float`)
- **Compatibilité des types lors des affectations** : 
  - Lors d'une affectation de la forme `<idf>  <Expression> ;`, le type du résultat de l'évaluation de `<Expression>` doit être parfaitement **compatible** avec le type de `<idf>`.
  - Si `<idf>` est de type `integer`, l'expression doit être de type `integer`.
  - Si `<idf>` est de type `float`, l'expression doit évaluer à `float`. L'affectation entre types incompatibles doit lever une erreur sémantique.

## 3. Modification des Constantes
- **Valeur est une constante** : Toute tentative d'affectation ou de modification sur un identificateur préalablement déclaré avec le mot-clé `const` est **strictement interdite**. Un message d'erreur sémantique doit être levé (ex: *tentative de modification d'une constante*).

## 4. Cohérence Sémantique des Types de Base
- Les valeurs littérales utilisées dans le code doivent respecter les domaines de chaque type :
  - **`integer`** : Entre `-32768` et `32767`.
  - Un entier/réel signé doit être mis entre parenthèses pour être valablement analysé comme valeur signée et vérifié sémantiquement.
