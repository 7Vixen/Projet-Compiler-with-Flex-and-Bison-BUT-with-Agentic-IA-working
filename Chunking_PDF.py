"""
Chunking_PDF.py
===============
Lit le fichier PDF du projet ProLang et le découpe en chunks sémantiques.
Chaque chunk est ensuite sauvegardé en tant que fichier Markdown dans ./Context/

Usage:
    python Chunking_PDF.py [chemin_vers_pdf]

    Si aucun chemin n'est fourni, le script cherche "Projet M1_compil 25-26.pdf"
    dans le dossier courant.

Chunks générés (correspondant aux fichiers .md du dossier Context/):
    1.  Global_context.md          → Vue d'ensemble & structure générale du programme
    2.  lexical_structure.md       → Identificateurs, types, constantes, commentaires
    3.  syntaxic_structure.md      → Grammaire : déclarations, instructions, boucles, conditions
    4.  semantics.md               → Règles sémantiques (types, portée, compatibilité)
    5.  Table_Hashage_context.md   → Table des symboles (hash table)
    6.  traitement_erreur.md       → Gestion et format des messages d'erreur
    7.  Code_INT_context.md        → Génération du code intermédiaire (quadruplets)
    8.  OPT_Code.md                → Optimisation du code intermédiaire
    9.  Code_Asssembleur8086.md    → Génération du code assembleur 8086
"""

import os
import sys
import re
import json
from pathlib import Path

# ---------------------------------------------------------------------------
# Dépendances  (pip install pdfplumber --break-system-packages)
# ---------------------------------------------------------------------------
try:
    import pdfplumber
except ImportError:
    print("[ERREUR] pdfplumber n'est pas installé.")
    print("  → pip install pdfplumber --break-system-packages")
    sys.exit(1)


# ===========================================================================
# CONFIGURATION DES CHUNKS
# Chaque entrée décrit un chunk sémantique à produire.
# "sections" est la liste des titres/mots-clés présents dans le PDF qui
# appartiennent à ce chunk.
# ===========================================================================
CHUNK_CONFIG = [
    {
        "filename": "Global_context.md",
        "title": "Contexte Global du Projet ProLang",
        "description": "Vue d'ensemble du compilateur, structure générale du programme source.",
        "sections": [
            "Introduction",
            "Description du mini langage",
            "Structure générale",
            "BeginProject",
            "Setup",
            "Run",
            "EndProject",
        ],
    },
    {
        "filename": "lexical_structure.md",
        "title": "Structure Lexicale — Analyse Lexicale (FLEX)",
        "description": "Tokens, identificateurs, types, constantes, opérateurs, commentaires.",
        "sections": [
            "Analyse lexicale",
            "Identificateur",
            "Types",
            "integer",
            "float",
            "Commentaires",
            "Opérateurs arithmétiques",
            "Opérateurs logiques",
            "Opérateurs de comparaison",
            "Associativité",
            "Priorité",
        ],
    },
    {
        "filename": "syntaxic_structure.md",
        "title": "Structure Syntaxique — Grammaire BNF (BISON)",
        "description": "Règles grammaticales : déclarations, affectation, conditions, boucles, E/S.",
        "sections": [
            "Analyse syntaxico-sémantique",
            "Partie déclaration",
            "Déclaration de variables",
            "Déclaration d'un tableau",
            "Déclaration d'une constante",
            "Partie Instruction",
            "Affectation",
            "Condition",
            "Boucle",
            "Lecture et écriture",
            "define",
            "const",
            "if",
            "loop while",
            "for",
            "in(",
            "out(",
        ],
    },
    {
        "filename": "semantics.md",
        "title": "Analyse Sémantique",
        "description": "Vérifications sémantiques : compatibilité de types, variables déclarées, constantes.",
        "sections": [
            "sémantique",
            "types incompatibles",
            "identificateurs non déclarés",
            "constante",
            "Valeur est une constante",
            "taille du tableau",
        ],
    },
    {
        "filename": "Table_Hashage_context.md",
        "title": "Table des Symboles — Table de Hachage",
        "description": "Structure et gestion de la table des symboles implémentée en table de hachage.",
        "sections": [
            "table de symboles",
            "table des symboles",
            "table de hachage",
            "Gestion de la table",
            "rechercher",
            "insérer",
            "variables structurées",
        ],
    },
    {
        "filename": "traitement_erreur.md",
        "title": "Traitement des Erreurs",
        "description": "Format et types des messages d'erreur (lexicaux, syntaxiques, sémantiques).",
        "sections": [
            "Traitement des erreurs",
            "messages d'erreur",
            "Type_ de_ l'erreur",
            "ligne",
            "colonne",
            "entité qui a générée",
        ],
    },
    {
        "filename": "Code_INT_context.md",
        "title": "Génération du Code Intermédiaire (Quadruplets)",
        "description": "Génération du code intermédiaire sous forme de quadruplets (op, arg1, arg2, résultat).",
        "sections": [
            "Génération du code intermédiaire",
            "quadruplets",
            "code intermédiaire",
        ],
    },
    {
        "filename": "OPT_Code.md",
        "title": "Optimisation du Code Intermédiaire",
        "description": "Techniques d'optimisation appliquées au code intermédiaire (élimination de code mort, propagation de constantes, etc.).",
        "sections": [
            "Optimisation du code intermédiaire",
            "Optimisation",
        ],
    },
    {
        "filename": "Code_Asssembleur8086.md",
        "title": "Génération du Code Assembleur 8086",
        "description": "Traduction du code intermédiaire en assembleur Intel 8086.",
        "sections": [
            "Génération du code machine",
            "assembleur 8086",
            "code machine",
            "code objet",
        ],
    },
]


# ===========================================================================
# EXTRACTION DU TEXTE PAR PAGE
# ===========================================================================

def extract_pages(pdf_path: str) -> list[dict]:
    """Retourne une liste de dicts {page_num, text} pour chaque page du PDF."""
    pages = []
    with pdfplumber.open(pdf_path) as pdf:
        for i, page in enumerate(pdf.pages, start=1):
            text = page.extract_text() or ""
            # Extraire aussi les tableaux sous forme textuelle
            tables = page.extract_tables()
            table_texts = []
            for table in tables:
                for row in table:
                    clean_row = [cell if cell else "" for cell in row]
                    table_texts.append(" | ".join(clean_row))
            if table_texts:
                text += "\n\n[TABLEAU]\n" + "\n".join(table_texts)
            pages.append({"page_num": i, "text": text})
    return pages


# ===========================================================================
# SCORE DE PERTINENCE : mesure combien un texte correspond à un chunk
# ===========================================================================

def relevance_score(text: str, keywords: list[str]) -> int:
    """Compte combien de mots-clés (insensible à la casse) apparaissent dans text."""
    text_lower = text.lower()
    return sum(1 for kw in keywords if kw.lower() in text_lower)


# ===========================================================================
# AFFECTATION DES PAGES AUX CHUNKS
# ===========================================================================

def assign_pages_to_chunks(pages: list[dict], chunks: list[dict]) -> dict[str, list[dict]]:
    """
    Pour chaque page, trouve le(s) chunk(s) le(s) plus pertinent(s) et
    les lui assigne.  Une page peut appartenir à plusieurs chunks si le
    score est identique pour les deux premiers.
    """
    assignments: dict[str, list[dict]] = {c["filename"]: [] for c in chunks}

    for page in pages:
        scores = []
        for chunk in chunks:
            score = relevance_score(page["text"], chunk["sections"])
            scores.append((score, chunk["filename"]))

        scores.sort(key=lambda x: x[0], reverse=True)

        if scores[0][0] == 0:
            # Page non classée → on l'ajoute au Global_context par défaut
            assignments["Global_context.md"].append(page)
        else:
            best_score = scores[0][0]
            # Ajouter à tous les chunks ayant le score maximal (ex-æquo)
            for score, filename in scores:
                if score == best_score:
                    assignments[filename].append(page)
                else:
                    break

    return assignments


# ===========================================================================
# NETTOYAGE DU TEXTE EXTRAIT
# ===========================================================================

def clean_text(raw: str) -> str:
    """Supprime les en-têtes répétitifs du document universitaire."""
    lines = raw.splitlines()
    cleaned = []
    skip_patterns = [
        "Université des Sciences",
        "Faculté d'Informatique",
        "Master 1-IV",
        "Projet de réalisation",
        "avec les Outils FLEX",
    ]
    for line in lines:
        if any(p in line for p in skip_patterns):
            continue
        cleaned.append(line)
    return "\n".join(cleaned).strip()


# ===========================================================================
# GÉNÉRATION DES FICHIERS MARKDOWN
# ===========================================================================

MARKDOWN_TEMPLATE = """\
# {title}

> **Fichier :** `{filename}`  
> **Description :** {description}  
> **Source :** Projet M1 Compilation 2025-2026 — USTHB

---

## Contenu extrait du PDF

{content}

---

## Notes pour l'agent

Ce fichier est un chunk sémantique destiné à un agent de compilation.
Il couvre les aspects suivants du compilateur ProLang :

{bullet_sections}

> *Généré automatiquement par `Chunking_PDF.py`*
"""


def pages_to_markdown_content(pages: list[dict]) -> str:
    """Convertit une liste de pages en contenu Markdown structuré."""
    parts = []
    for p in sorted(pages, key=lambda x: x["page_num"]):
        text = clean_text(p["text"])
        if text:
            parts.append(f"### Page {p['page_num']}\n\n{text}")
    return "\n\n---\n\n".join(parts) if parts else "_Aucun contenu extrait._"


def bullet_list(items: list[str]) -> str:
    return "\n".join(f"- {item}" for item in items)


def generate_markdown(chunk: dict, pages: list[dict]) -> str:
    content = pages_to_markdown_content(pages)
    return MARKDOWN_TEMPLATE.format(
        title=chunk["title"],
        filename=chunk["filename"],
        description=chunk["description"],
        content=content,
        bullet_sections=bullet_list(chunk["sections"]),
    )


# ===========================================================================
# POINT D'ENTRÉE PRINCIPAL
# ===========================================================================

def main():
    # --- Résolution du chemin PDF ---
    if len(sys.argv) > 1:
        pdf_path = sys.argv[1]
    else:
        # Chercher dans le dossier courant
        candidates = list(Path(".").glob("*.pdf"))
        if not candidates:
            print("[ERREUR] Aucun fichier PDF trouvé dans le dossier courant.")
            print("  Usage : python Chunking_PDF.py <chemin_vers_pdf>")
            sys.exit(1)
        pdf_path = str(candidates[0])
        print(f"[INFO] PDF détecté automatiquement : {pdf_path}")

    if not os.path.exists(pdf_path):
        print(f"[ERREUR] Fichier introuvable : {pdf_path}")
        sys.exit(1)

    # --- Dossier de sortie ---
    output_dir = Path("Context")
    output_dir.mkdir(exist_ok=True)
    print(f"[INFO] Dossier de sortie : {output_dir.resolve()}")

    # --- Extraction des pages ---
    print(f"[INFO] Extraction du texte depuis : {pdf_path}")
    pages = extract_pages(pdf_path)
    print(f"[INFO] {len(pages)} page(s) extraite(s).")

    # --- Affectation pages → chunks ---
    assignments = assign_pages_to_chunks(pages, CHUNK_CONFIG)

    # --- Génération des fichiers Markdown ---
    print("\n[INFO] Génération des fichiers Markdown...\n")
    report = []
    for chunk in CHUNK_CONFIG:
        filename = chunk["filename"]
        assigned_pages = assignments[filename]
        md_content = generate_markdown(chunk, assigned_pages)

        out_path = output_dir / filename
        out_path.write_text(md_content, encoding="utf-8")

        page_nums = sorted(set(p["page_num"] for p in assigned_pages))
        status = f"  ✅  {filename:<35} ← pages {page_nums}" if page_nums else f"  ⚠️   {filename:<35} ← (aucune page assignée — squelette créé)"
        print(status)
        report.append({"file": filename, "pages": page_nums})

    # --- Résumé JSON ---
    summary_path = output_dir / "_chunking_report.json"
    summary_path.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")

    print(f"\n[OK] {len(CHUNK_CONFIG)} fichiers Markdown générés dans '{output_dir}/'")
    print(f"[OK] Rapport de découpage : {summary_path}")


if __name__ == "__main__":
    main()