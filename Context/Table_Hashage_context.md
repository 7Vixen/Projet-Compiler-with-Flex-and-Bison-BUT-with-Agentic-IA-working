# Table des Symboles — Table de Hachage

Cette section décrit la structure clé du compilateur permettant de stocker et gérer les informations sur chaque entité déclarée.

## 1. Structure de la Table de Hashage
La **table de symboles** est créée par l'analyseur lexical et regroupe l'ensemble des informations concernant toutes les variables, constantes et structures du programme (identificateurs, types de données, valeurs, tailles de tableaux).
L'implémentation de la table des symboles doit obligatoirement reposer sur une **table de hachage**.

## 2. Logique d'Insertion et de Recherche
Des procédures spécifiques doivent exister pour gérer cette table :
- **Rechercher (`rechercher`)** : Chaque fois que le compilateur rencontre un identificateur, il doit d'abord interroger la table de hachage. 
  - Lors d'une déclaration (`define`), il s'assure qu'aucun identificateur avec un même nom n'existe déjà. 
  - Lorsqu'il est utilisé (partie instruction `Run:`), il cherche l'identificateur pour en vérifier l’existence sémantique et en manipuler le type.
- **Insérer (`insérer`)** : La table ajoute les nouveaux symboles capturés pendant la déclaration avec toutes leurs informations.

## 3. Variables Structurées
La table de hachage doit inclure et gérer correctement l'insertion et la structure des informations liées aux **variables structurées**, comme les éléments de type tableau avec leur taille (qui doit être une constante stockée en mémoire de table de hachage lors de son initialisation).
