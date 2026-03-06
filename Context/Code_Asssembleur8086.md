# Génération du Code Assembleur 8086

Cette étape traduit la séquence de code intermédiaire en code exécutable spécifique à l'architecture 8086 de la machine cible.

## 1. Mapping des Quadruplets vers le 8086
La base de la génération du code reposera sur le format de **quadruplets** (Opérateur, Opérande 1, Opérande 2, Résultat) utilisé dans le code intermédiaire généré et optimisé au préalable.

L'implémentation doit permettre de faire correspondre (mapper) la structure d'un code de quadruplet au **jeu d'instructions de l'assembleur 8086** :

- **Opérations d'affectation** (`<-`): Le passage de données d'une opérande ou valeur constante vers un bloc mémoire doit générer du code assembleur en utilisant généralement les registres (`AX`, `BX`...) et l'instruction `MOV`.
- **Expressions Arithmétiques** : Les opérations primitives listées dans le contexte (addition `+`, soustraction `-`, etc.) doivent correspondre aux instructions arithmétiques comme `ADD`, `SUB`, `MUL`, `DIV`.
- **Sauts et Boucles (`if`, `loop while`, `for`)** : La génération de quadruplets pour le contrôle de flux (qui intègre couramment des branchements) se traduit en instructions de sauts au niveau du code machine (`JMP`, `JE`, `JNE`, `JG`) associées à l'évaluation d'un saut selon le flag d'instruction `CMP`.

## 2. Code Objet
L'objectif est d'exporter le résultat sous un format fonctionnel et valide contenant le code machine / source d'assembly 8086 lisible par un traducteur/émulateur standard de la plate-forme intel.
