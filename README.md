# last-version-de-compilation-du-langage-MiniVision

compiler for a mini language similar to Python written with Flex & Bison.

## - Compiling

Compile usingthe following commands

    $ flex lexical.l
    $ bison -d synt.y -v
    $ gcc lex.yy.c synt.tab.c -lfl -ly -o prog.exe

To test the script write it first in **`Input/file.mpy`** then execute it using

    $ ./prog

---
## 2- MiniPy 
Dans cette partie on veut générer des codes en python pour gérer des images. La 
bibliothèque la plus utiliser est numpy. Chaque instruction dans MiniVision doit être sur une 
seule ligne. 
Les blocs sont identifiés par l'indentation, (quatre espaces) au lieu d'accolades comme en C. 
Une augmentation de l'indentation marque le début d'un bloc, et une réduction de l'indentation 
marque la fin du bloc courant. 



## 7 Optimisation 
On considère quatre types de transformations successives appliquées au code intermédiaire : 
*   **Propagation de copie**
*    (e.g. remplacer t1=t2 ; t3=4*t1 par t1=t2 ; t3=4*t2). 
*   **Propagation d’expression**
*    (e.g. remplacer t1=expr; t3=4*t1 par t1=expr; t3=4*expr). 
*   **Élimination d’expressions redondantes (communes)** 
*   (e.g. remplacer t6=4*j ; t12=4*j par 
        t6=4*j ; t12=t6 ). 
*   **Simplification algébrique**
*    (e.g. remplacer t1+1-1 par t1). 
*   **Élimination de code inutile (code mort)**

## 8 Génération du code machine 
Le code machine génére en assembleur 8086.
