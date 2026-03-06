import pdfplumber

with pdfplumber.open(r'c:\Users\rog wephyrus\Desktop\Projet TP Compile WITH IA Agents\Projet M1_compil 25-26.pdf') as pdf:
    with open(r'c:\Users\rog wephyrus\Desktop\Projet TP Compile WITH IA Agents\Context\all_text.txt', 'w', encoding='utf-8') as f:
        for i, page in enumerate(pdf.pages):
            f.write(f"--- PAGE {i+1} ---\n")
            f.write(page.extract_text() or "")
            f.write("\n")
            
            tables = page.extract_tables()
            for table in tables:
                for row in table:
                    clean_row = [str(cell) if cell else "" for cell in row]
                    f.write(" | ".join(clean_row) + "\n")
            f.write("\n")
