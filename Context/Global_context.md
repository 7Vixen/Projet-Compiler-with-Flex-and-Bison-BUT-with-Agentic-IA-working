# Contexte Global du Projet ProLang

> **Fichier :** `Global_context.md`  
> **Description :** Vue d'ensemble du compilateur, structure générale du programme source.  
> **Source :** Projet M1 Compilation 2025-2026 — USTHB

---

## Contenu extrait du PDF

### Page 1

d’Informatique
I- Introduction
Ce projet a pour but de concevoir un mini-compilateur pour un langage nommé
«ProLang», en intégrant les différentes étapes de la compilation : l'analyse lexicale,
syntaxique, sémantique, la génération de code intermédiaire, optimisation du code
intermédiaire, ainsi que la génération du code objet.
De plus, la gestion parallèle de la table des symboles et le traitement des différentes erreurs
devront être pris en charge lors des phases d’analyse du processus de compilation.
II- Description du mini langage « ProLang»
II.1. Structure générale
La structure générale du programme est la suivante :
BeginProject M1_IV_2526;
Setup :
%% Partie déclarations
Run :
{
//* Partie
instruction *//
}
EndProject ;
II.2. Partie déclaration
Cette section est dédiée à la déclaration des variables simples et constantes nécessaires au bon
fonctionnement du programme.
1. Déclaration de variables
La syntaxe de déclaration d’une variable simple est la suivante :
define <nom_var> : <type> ;

---

## Notes pour l'agent

Ce fichier est un chunk sémantique destiné à un agent de compilation.
Il couvre les aspects suivants du compilateur ProLang :

- Introduction
- Description du mini langage
- Structure générale
- BeginProject
- Setup
- Run
- EndProject

## Notes:
le fichier global context est simplement un apuis pour comprendre l'idée générale ensuite tu suivra les étape avec les autre chunk (les autre fichier.md) suivant :
 



