%{ 
    //by hamzaoui thameur & omari hamza  
    #include <stdio.h>
    #include <stdlib.h>  
    #include <stdbool.h>
    #include <string.h>

    void initialisation();
    void afficher();
    void print_nodes();
    void print_tabs();
    void afficher_qdr();
    void sauvegarder_qdr();
    void copy_propagation();
    void generate_code();
    void optimiser_qdr();
    void propagateExpression();
    void propagateCopy();
    void eliminateRedundancy();
    void simplifyAlgebra();
    void eliminateDeadCode();



    bool doubleDeclaration(char name[]);
    bool nonDeclare(char entite[]);
    bool outOfRange(char name[], int index);
    bool typeCompatibilite(char type1[], char type2[]);
    bool divisionParZero(float num);
    void inserer(char entite[], char code[], char type[], int taille, float val, int y);
    void update_type(char name[], char type[]);
    void update_val(char name[], float val);
    char *get_type(char name[]);
    float get_val(char name[]);
    char *get_code(char name[]);
    void set_tab_val(char name[], int index, float val);
    float get_tab_val(char *name, int index);
    bool index_check(char *name, int index);
    void quadr(char opr[],char op1[],char op2[],char res[]);
    void ajour_quad(int num_quad, int colon_quad, char val []);

    int yylex();
    int yyerror(char* s);

    int nb_ligne=1, Col=1;
    int current_line_indent = 0;
    int indent_level = 0; 
    int state = 0;
    int isNewline = 0;

    char variables_LIST_IDF[100][20], variables_LIST_IDF2[100][20], Types[100][20];;
    int variables_counter = 0, variables_counter2 = 0;
    char sauvType[25], sauvType2[25];
    float savedVal;

    int Fin_if = 0, deb_else = 0, Fin, BorneSup, counter = 1, counter2 = 1;
    int qc = 0;
    char tmp[20], tmp2[20], tmp3[20], tmp4[20], tabName[20];
    int tmp_int;

    int isempty();
    int isfull();
    char* peek();
    char* pop();
    char push(char *data); 

    int isempty2();
    int isfull2();
    int peek2();
    int pop2();
    char push2(int data); 
    
    extern FILE* yyin;
%}
%union {
    int INT;
    float FLOAT;
    char CHAR;
    char *STR;
    int BOOL;
}

%start PROG

%token mc_int mc_float mc_char mc_bool mc_if mc_else mc_for mc_in mc_range mc_while mc_import mc_np mc_png mc_jpg mc_matplotlib mc_as mc_numpy mc_cv2 mc_imwrite mc_imread
add sub mul divv aff vrg point tf lb rb lp rp dd and or not g l ge le eq dif <STR>idf 
<INT>v_int <FLOAT>v_float <CHAR>v_char <BOOL>v_bool indent dedent newline err


%left or and not
%left g l ge le eq dif
%left add sub
%left mul divv
%left indent dedent

%type<FLOAT> EXP1 EXP2 EXP3;
%type<INT> EXP_B COND COND1 COND2 COND3;

%%
PROG: LIST_INS { printf("The program is correct syntactically\n"); YYACCEPT; }
;


INS_DECTYPE: TYPE LIST_IDF {
                for (variables_counter = variables_counter-1; variables_counter >= 0; variables_counter--){
                    update_type(variables_LIST_IDF[variables_counter], sauvType);
                }
                variables_counter = 0;
                strcpy(sauvType, "NULL");
           }
           | IMPORT_LIB
;

IMPORT_LIB: mc_import LIB mc_as mcf 
          
;
LIB: mc_matplotlib
     |mc_numpy
     |mc_cv2
;

mcf : idf {
            inserer($1, "IDF", "", 0, 0, 0);
            strcpy(variables_LIST_IDF[variables_counter], $1);
            variables_counter++;
            
}

;

FonctionA: mcf point mc_imread lp tf idf point IM tf rp 
;
FonctionB: mcf point mc_imwrite lp tf idf point IM tf vrg idf rp {
                if (nonDeclare($11)){
                printf("Semantic Error, line %d, column %d : [ %s ] Not Declared\n", nb_ligne, Col, $11);
            }}
                     
;
IM:mc_jpg
   |mc_png
   
;


TYPE: mc_int { strcpy(sauvType, "Int");}
    | mc_float { strcpy(sauvType, "Float"); }
    | mc_char { strcpy(sauvType, "Char"); }
    | mc_bool { strcpy(sauvType, "Bool"); }
;

LIST_IDF: idf {
            if (doubleDeclaration($1)){
                printf("Semantic Error, line %d, column %d, [ %s ] Already declared\n", nb_ligne, Col, $1);
            }
            else{
                inserer($1, "IDF", "", 0, 0, 0);
                strcpy(variables_LIST_IDF[variables_counter], $1);
                variables_counter++;
            }
        }
        | idf lb v_int rb {
            if (doubleDeclaration($1)){
                printf("Semantic Error, line %d, column %d, [ %s ] Already declared\n", nb_ligne, Col, $1);
            }
            else{
                inserer($1, "IDF Tab", "", $3, 0, 0);
                strcpy(variables_LIST_IDF[variables_counter], $1);
                variables_counter++;
            }
        }    
        | idf vrg LIST_IDF {
            if (doubleDeclaration($1)){
                printf("Semantic Error, line %d, column %d, [ %s ] Already declared\n", nb_ligne, Col, $1);
            }
            else{
                inserer($1, "IDF", "", 0, 0, 0);
                strcpy(variables_LIST_IDF[variables_counter], $1);
                variables_counter++;
            }
        }
        | idf lb v_int rb vrg LIST_IDF {
            if (doubleDeclaration($1)){
                printf("Semantic Error, line %d, column %d, [ %s ] Already declared\n", nb_ligne, Col, $1);
            }
            else{
                inserer($1, "IDF Tab", "", $3, 0, 0);
                strcpy(variables_LIST_IDF[variables_counter], $1);
                variables_counter++;
            }
        }
        | idf aff v_int {
            if (doubleDeclaration($1)){
                printf("Semantic Error, line %d, column %d, [ %s ] Already declared\n", nb_ligne, Col, $1);
            }
            else{
                if (strcmp(sauvType, "Int") != 0){
                    printf("Semantic Error, line %d, column %d, Value isn't of the type [ %s ]\n", nb_ligne, Col, sauvType);
                }
                else{
                    inserer($1, "IDF", "Int", 0, (float) $3, 0);
                    sprintf(tmp3, "%d", $3);
                    quadr("=", tmp3, "Empty", $1);
                }
            }    
        }
        | idf aff v_float {
            if (doubleDeclaration($1)){
                printf("Semantic Error, line %d, column %d, [ %s ] Already declared\n", nb_ligne, Col, $1);
            }
            else{
                if (strcmp(sauvType, "Float") != 0){
                    printf("Semantic Error, line %d, column %d, Value isn't of the type [ %s ]\n", nb_ligne, Col, sauvType);
                }
                else{
                    inserer($1, "IDF", "Float", 0, $3, 0);
                    sprintf(tmp3, "%f", $3);
                    quadr("=", tmp3, "Empty", $1);
                }
            }    
        }
        | idf aff v_char {
            if (doubleDeclaration($1)){
                printf("Semantic Error, line %d, column %d, [ %s ] Already declared\n", nb_ligne, Col, $1);
            }
            else{
                if (strcmp(sauvType, "Char") != 0){
                    printf("Semantic Error, line %d, column %d, Value isn't of the type [ %s ]\n", nb_ligne, Col, sauvType);
                }
                else{
                    inserer($1, "IDF", "Char", 0, (float) $3, 0);
                    sprintf(tmp3, "'%c'", $3);
                    quadr("=", tmp3, "Empty", $1);
                }
            }    
        }
        | idf aff v_bool {
            if (doubleDeclaration($1)){
                printf("Semantic Error, line %d, column %d, [ %s ] Already declared\n", nb_ligne, Col, $1);
            }
            else{
                if (strcmp(sauvType, "Bool") != 0){
                    printf("Semantic Error, line %d, column %d, Value isn't of the type [ %s ]\n", nb_ligne, Col, sauvType);
                }
                else{
                    inserer($1, "IDF", "Int", 0, (float) $3, 0);
                    if ($3 == 1){
                        strcpy(tmp3, "true");
                    }
                    else{
                        strcpy(tmp3, "false");
                    }
                    quadr("=", tmp3, "Empty", $1);
                }
            }    
        }
        | idf aff v_int vrg LIST_IDF {
            if (doubleDeclaration($1)){
                printf("Semantic Error, line %d, column %d, [ %s ] Already declared\n", nb_ligne, Col, $1);
            }
            else{
                if (strcmp(sauvType, "Int") != 0){
                    printf("Semantic Error, line %d, column %d, Value isn't of the type [ %s ]\n", nb_ligne, Col, sauvType);
                }
                else{
                    inserer($1, "IDF", "Int", 0, (float) $3, 0);
                    sprintf(tmp3, "%d", $3);
                    quadr("=", tmp3, "Empty", $1);
                }
            }    
        } 
        | idf aff v_float vrg LIST_IDF {
            if (doubleDeclaration($1)){
                printf("Semantic Error, line %d, column %d, [ %s ] Already declared\n", nb_ligne, Col, $1);
            }
            else{
                if (strcmp(sauvType, "Float") != 0){
                    printf("Semantic Error, line %d, column %d, Value isn't of the type [ %s ]\n", nb_ligne, Col, sauvType);
                }
                else{
                    inserer($1, "IDF", "Float", 0, $3, 0);
                    sprintf(tmp3, "%f", $3);
                    quadr("=", tmp3, "Empty", $1);
                }
            }    
        } 
        | idf aff v_char vrg LIST_IDF {
            if (doubleDeclaration($1)){
                printf("Semantic Error, line %d, column %d, [ %s ] Already declared\n", nb_ligne, Col, $1);
            }
            else{
                if (strcmp(sauvType, "Char") != 0){
                    printf("Semantic Error, line %d, column %d, Value isn't of the type [ %s ]\n", nb_ligne, Col, sauvType);
                }
                else{
                    inserer($1, "IDF", "Char", 0, (float) $3, 0);
                    sprintf(tmp3, "'%c'", $3);
                    quadr("=", tmp3, "Empty", $1);
                }
            }    
        } 
        | idf aff v_bool vrg LIST_IDF {
            if (doubleDeclaration($1)){
                printf("Semantic Error, line %d, column %d, [ %s ] Already declared\n", nb_ligne, Col, $1);
            }
            else{
                if (strcmp(sauvType, "Bool") != 0){
                    printf("Semantic Error, line %d, column %d, Value isn't of the type [ %s ]\n", nb_ligne, Col, sauvType);
                }
                else{
                    inserer($1, "IDF", "Int", 0, (float) $3, 0);
                    if ($3 == 1){
                        strcpy(tmp3, "true");
                    }
                    else{
                        strcpy(tmp3, "false");
                    }
                    quadr("=", tmp3, "Empty", $1);
                }
            }
        }
         
;

LIST_INS: INS LIST_INS
        | INS
        
;

INS: INS_AFF newline
   | INS_DECTYPE newline
   | INS_IF {pop2();}
   | INS_IF2 {
        pop2();
        tmp_int = pop2();
        qc--;
        sprintf(tmp,"%d", qc); 
        ajour_quad(tmp_int, 1, tmp);
   }
   | INS_FOR_RANGE
   | INS_FOR_TAB
   | INS_WHILE
   | FonctionB

   
;



         
;

INS_AFF: idf aff EXP1 {
            if (nonDeclare($1)){
                inserer($1, "IDF", sauvType, 0, $3, 0);
            }
            if (typeCompatibilite(get_type($1), sauvType)){
                printf("Semantic Error, line %d, column %d, Type Incompatibility [ %s (%s) = (%s) ]\n", nb_ligne, Col, $1, get_type($1), sauvType);
            }
            else{
                if ((strcmp(get_type($1), sauvType) != 0) && (strcmp(get_type($1), "Float") != 0)){
                    update_type($1, sauvType);
                }
                update_val($1, $3);
                quadr("=", pop(), "Empty", $1);
            }
            strcpy(sauvType, "NULL");
       }
       | idf lb v_int rb aff EXP1 {
            if(nonDeclare($1)){
                printf("Semantic Error, line %d, column %d : [ %s ] Not Declared\n", nb_ligne, Col, $1);
            }
            else{
                if (strcmp(get_code($1), "IDF Tab") != 0){
                    printf("Semantic Error, line %d, column %d, [ %s ] Has to be a table\n", nb_ligne, Col, $1);
                }
                else{
                    if (outOfRange($1, $3)) {
                        printf("Semantic Error, line %d, column %d : Index [ %d ] Out of range\n", nb_ligne, Col, $3);
                    }
                    else{
                        if (typeCompatibilite(get_type($1), sauvType)){
                            printf("Semantic Error, line %d, column %d, Type Incompatibility [ %s[%d] (%s) = (%s) ]\n", nb_ligne, Col, $1, $3, get_type($1), sauvType);
                        }
                        else {
                            set_tab_val($1, $3, $6);
                            sprintf(tabName, "%s[%d]", $1, $3);
                            quadr("=", pop(), "Empty", tabName);
                        }
                    }                      
                }
 
            }
            strcpy(sauvType, "NULL");
       }
    |idf aff FonctionA {
            if (doubleDeclaration($1)){
                printf("Semantic Error, line %d, column %d, [ %s ] Already declared\n", nb_ligne, Col, $1);
            }
            else if (nonDeclare($1)){
                inserer($1, "IDF", "Int", 0, 0, 0);
            }
        } 

      
;

EXP1: EXP1 add EXP2 {
        $$ = $1 + $3;
        strcpy(tmp2, pop());
        strcpy(tmp, pop());
        sprintf(tmp4, "temp_var%d", counter);
        counter++;
        quadr("+", tmp, tmp2, tmp4);
        push(tmp4); 
    }
    | EXP1 sub EXP2 {
        $$ = $1 - $3;
        strcpy(tmp2, pop());
        strcpy(tmp, pop());
        sprintf(tmp4, "temp_var%d", counter);
        counter++;
        quadr("-", tmp, tmp2, tmp4);
        push(tmp4); 
    }
    | EXP2
;
EXP2: EXP2 mul EXP3 {
        $$ = $1 * $3;
        strcpy(tmp2, pop());
        strcpy(tmp, pop());
        sprintf(tmp4, "temp_var%d", counter);
        counter++;
        quadr("*", tmp, tmp2, tmp4);
        push(tmp4); 
    }
    | EXP2 divv EXP3 {
        if (divisionParZero($3)){
            printf("Semantic Error, line %d, column %d, Division By Zero [ %f / %f ]\n", nb_ligne, Col, $1, $3);
        }
        else{
            $$ = $1 / $3;
            strcpy(tmp2, pop());
            strcpy(tmp, pop());
            sprintf(tmp4, "temp_var%d", counter);
            counter++;
            quadr("/", tmp, tmp2, tmp4);
            push(tmp4);
        }
    }
    | EXP3    
;
EXP3: lp EXP1 rp {
        $$ = $2;
    }
    | v_int {
        if (strcmp(sauvType, "Float") != 0){
            strcpy(sauvType, "Int");
        }
        sprintf(tmp3, "%d", $1);
        push(tmp3);
        $$ = (float) $1;
    }
    | v_float {
        strcpy(sauvType, "Float");
        sprintf(tmp3, "%f", $1);
        push(tmp3);
        $$ = $1;
    }
    | v_char {
        if ((strcmp(sauvType, "Float") != 0) && (strcmp(sauvType, "Int") != 0)){
            strcpy(sauvType, "Char");
        }
        sprintf(tmp3, "'%c'", $1);
        push(tmp3);
        $$ = (float) $1;
    }
    | v_bool { 
        if ((strcmp(sauvType, "Float") != 0) && (strcmp(sauvType, "Int") != 0) && (strcmp(sauvType, "Char") != 0)){
            strcpy(sauvType, "Bool");
        }
        if ($1 == 1){
            strcpy(tmp3, "true");
        }
        else{
            strcpy(tmp3, "false");
        }
        push(tmp3);
        $$ = (float) $1;
    }
    | idf {
        if(!nonDeclare($1)){
            $$ = get_val($1);
            strcpy(sauvType, get_type($1));
            push($1);
        }
        else{
            printf("Semantic Error, line %d, column %d : [ %s ] Not Declared\n", nb_ligne, Col, $1);
        }
    }
    | idf lb v_int rb {
        if(nonDeclare($1)){
            printf("Semantic Error, line %d, column %d, [ %s ] Not Declared\n", nb_ligne, Col, $1);
        }
        else{
            if (outOfRange($1, $3)) {
                printf("Semantic Error, line %d, column %d, Index [ %d ] Out of range\n", nb_ligne, Col, $3);
            }
            else{
                if (index_check($1, $3)){
                    $$ = get_tab_val($1, $3);
                    strcpy(sauvType, get_type($1));
                    sprintf(tmp3, "%s[%d]", $1, $3);
                    push(tmp3);
                }
                else{
                    printf("Semantic Error, line %d, column %d, %s[%d] Has to be initialized\n", nb_ligne, Col, $1, $3);
                    $$ = 0;
                    strcpy(sauvType, get_type($1));
                    sprintf(tmp3, "%d", 0);
                    push(tmp3);
                }
            }   
        }
    }
;
INS_IF: INS_IF2 mc_else dd newline indent LIST_INS dedent {
            tmp_int = pop2();
            pop2();
            sprintf(tmp, "%d", qc);  
            ajour_quad(tmp_int, 1, strdup(tmp));
      }
;
INS_IF2: INS_IF1 newline indent LIST_INS dedent {
            tmp_int = pop2();
            push2(qc);
            quadr("BR", "", "Empty", "Empty"); 
            sprintf(tmp,"%d", qc); 
            ajour_quad(tmp_int, 1, strdup(tmp));
       }
;
INS_IF1: mc_if lp COND rp dd {
            pop();
            push2(qc);
            push2(qc);
            sprintf(tmp3, "temp_cond%d", counter2);
            counter2++;
            quadr("BZ", "", tmp3, "Empty");
       }
;

INS_FOR_RANGE: INS_FOR_RANGE2 newline indent LIST_INS dedent {
                strcpy(tmp2, pop());
                tmp_int = pop2();
                if (!typeCompatibilite(get_type(tmp2), "Int")){
                    sprintf(tmp4, "temp_var%d", counter);
                    counter++;
                    quadr("+", tmp2, "1", tmp4);
                    quadr("=", tmp4, "Empty", tmp2); 
                    sprintf(tmp, "%d", tmp_int);
                    quadr("BR", tmp, "Empty", "Empty"); 
                    sprintf(tmp, "%d", qc); 
                    ajour_quad(tmp_int, 1, strdup(tmp));
                }
             }
;

INS_FOR_RANGE2: mc_for idf mc_in mc_range lp EXP1 vrg EXP1 rp dd {
                    pop();
                    pop();
                    if (nonDeclare($2)){
                        inserer($2, "IDF", "Int", 0, 0, 0);
                    }
                    if (typeCompatibilite(get_type($2), "Int")){
                        printf("Semantic Error, line %d, column %d, [ %s ] Must be an Integer\n", nb_ligne, Col, $2);
                    }
                    else{
                        push($2);
                        sprintf(tmp, "%d", (int) $6);
                        quadr("=", tmp, "Empty", $2);
                        push2(qc);
                        sprintf(tmp3, "temp_cond%d", counter2);
                        counter2++;
                        quadr("BZ", "", tmp3, "Empty"); 
                    }
              }
;
INS_FOR_TAB : INS_FOR_TAB2 indent LIST_INS dedent {
                strcpy(tmp2, pop());
                strcpy(tmp, pop());
                if ((!nonDeclare(tmp2)) && (strcmp(get_code(tmp2), "IDF Tab") == 0) && (!typeCompatibilite(get_type(tmp), get_type(tmp2)))){
                    tmp_int = pop2();
                    sprintf(tabName, "%s[Next Index]", tmp2);
                    quadr("=", tabName, "Empty", tmp);
                    sprintf(tmp, "%d", tmp_int);
                    quadr("BR", tmp, "Empty", "Empty"); 
                    sprintf(tmp, "%d", qc);
                    ajour_quad(tmp_int, 1, strdup(tmp));
                }
            }
;
INS_FOR_TAB2: mc_for idf mc_in idf dd newline {
                if(nonDeclare($4)){
                    printf("Semantic Error, line %d, column %d, [ %s ] Not Declared\n", nb_ligne, Col, $4);
                }
                else{
                    if (strcmp(get_code($4), "IDF Tab") != 0){
                        printf("Semantic Error, line %d, column %d, [ %s ] Has to be a table\n", nb_ligne, Col, $4);
                    }
                    else{
                        if (nonDeclare($2)){
                            inserer($2, "IDF", get_type($4), 0, 0, 0);
                        }
                        if (typeCompatibilite(get_type($2), get_type($4))){
                            printf("Semantic Error, line %d, column %d, Type Incompatibility [ %s (%s) - %s (%s) ]\n", nb_ligne, Col, $2, get_type($2), $4, get_type($4));
                        }
                        else{
                            sprintf(tabName, "%s[First Index]", $4);
                            quadr("=", tabName, "Empty", $2);
                            push2(qc);
                            sprintf(tmp3, "temp_cond%d", counter2);
                            counter2++;
                            quadr("BZ", "", tmp3, "Empty"); 
                        } 
                    }
                }
                push($2);
                push($4);
            }
;
INS_WHILE: INS_WHILE2 indent LIST_INS dedent {
            tmp_int = pop2();
            sprintf(tmp, "%d", tmp_int);
            quadr("BR", tmp, "Empty", "Empty"); 
            sprintf(tmp, "%d", qc); 
            ajour_quad(tmp_int, 1, strdup(tmp));
        }
;
INS_WHILE2: mc_while lp COND rp dd newline {
            pop();
            push2(qc);
            sprintf(tmp3, "temp_cond%d", counter2);
            counter2++;
            quadr("BZ", "", tmp3, "Empty"); 
        }
;


EXP_B: EXP1 g EXP1 {
        pop(); pop();
        if ($1 > $3){
            $$ = 1;
            strcpy(tmp, "true");
        }
        else{
            $$ = 0;
            strcpy(tmp, "false");
        }
        push(tmp);

        
     }
     | EXP1 l EXP1 {
        pop(); pop();
        if ($1 < $3){
            $$ = 1;
            strcpy(tmp, "true");
        }
        else{
            $$ = 0;
            strcpy(tmp, "false");
        }
        push(tmp);
     }
     | EXP1 ge EXP1 {
        pop(); pop();
        if ($1 >= $3){
            $$ = 1;
            strcpy(tmp, "true");
        }
        else{
            $$ = 0;
            strcpy(tmp, "false");
        }
        push(tmp);
     }
     | EXP1 le EXP1 {
        pop(); pop();
        if ($1 <= $3){
            $$ = 1;
            strcpy(tmp, "true");
        }
        else{
            $$ = 0;
            strcpy(tmp, "false");
        }
        push(tmp);
     }
     | EXP1 eq EXP1 {
        pop(); pop();
        if ($1 == $3){
            $$ = 1;
            strcpy(tmp, "true");
        }
        else{
            $$ = 0;
            strcpy(tmp, "false");
        }
        push(tmp);
     }
     | EXP1 dif EXP1 {
        pop(); pop();
        if ($1 != $3){
            $$ = 1;
            strcpy(tmp, "true");
        }
        else{
            $$ = 0;
            strcpy(tmp, "false");
        }
        push(tmp);
     }
     | v_int {
        if ($1 != 0){
            $$ = 1;
            strcpy(tmp, "true");
        }
        else{
            $$ = 0;
            strcpy(tmp, "false");
        }
        push(tmp);
     }
     | v_float {
        if ($1 != 0){
            $$ = 1;
            strcpy(tmp, "true");
        }
        else{
            $$ = 0;
            strcpy(tmp, "false");
        }
        push(tmp);
     }
     | v_char {
        if ((float) $1 != 0){
            $$ = 1;
            strcpy(tmp, "true");
        }
        else{
            $$ = 0;
            strcpy(tmp, "false");
        }
        push(tmp);
     }
     | v_bool { 
        $$ = $1;
        if ($1 == 1){
            strcpy(tmp, "true");
        }
        else{
            strcpy(tmp, "false");
        }
        push(tmp);
     }
     | idf {
         if (!nonDeclare($1)){
            if (get_val($1) != 0){
                $$ = 1;
                strcpy(tmp, "true");
            }
            else{
                $$ = 0;
                strcpy(tmp, "false");
            }
            push(tmp);
         }
         else {
             printf("Semantic Error, line %d, column %d, entite '%s' Not Declared\n", nb_ligne, Col, $1);
         }
     }
     | idf lb v_int rb {
         if(nonDeclare($1)){
             printf("Semantic Error, line %d, column %d, entite '%s' Not Declared\n", nb_ligne, Col, $1);
         }
         else{
             if (outOfRange($1, $3)) {
                 printf("Semantic Error, line %d, column %d, Index [ %d ] Out of range\n", nb_ligne, Col, $3);
             }
             else{
                 if (index_check($1, $3)){
                     if (get_tab_val($1, $3) != 0){
                         $$ = 1;
                         strcpy(tmp, "true");
                     }
                     else{
                         $$ = 0;
                         strcpy(tmp, "false");
                     }
                     push(tmp);
                 }
                 else{
                     printf("Semantic Error, line %d, column %d, %s[%d] Has to be initialized\n", nb_ligne, Col, $1, $3);
                     $$ = 0;
                     strcpy(tmp, "false");
                     push(tmp);
                 }
             }   
         }
     }
;

COND: COND or COND1 {
        pop(); pop();
        if (($1 == 1) || ($3 == 1)){
            $$ = 1;
            strcpy(tmp, "true");
        }
        else{
            $$ = 0;
            strcpy(tmp, "false");
        }
        push(tmp);
    }
    | COND1
;
COND1: COND1 and COND2 {
        pop(); pop();
        if (($1 == 1) && ($3 == 1)){
            $$ = 1;
            strcpy(tmp, "true");
        }
        else{
            $$ = 0;
            strcpy(tmp, "false");
        }
        push(tmp);
     }
     | COND2
;

COND2: not COND3 {
        pop();
        if ($2 == 1){
            $$ = 0;
            strcpy(tmp, "false");
        }
        else{
            $$ = 1;
            strcpy(tmp, "true");
        }
        push(tmp);
     }
     | COND3     
;

COND3: EXP_B { strcpy(sauvType, "NULL"); }
;

%%
int main(){

    initialisation();   // INITIALIZE THE TABLES

    yyin = fopen( "Input/file.mpy", "r" );
    yyparse(); 
    
    afficher();         //  LISTING THE TS TABLE
    print_nodes();      //  LISTING THE NODES AS A HASHMAP
    print_tabs();       //  LISTING THE TAB VALUES INSIDE THE CODE
    afficher_qdr();    //  LISTING QUADRUPLETS
    sauvegarder_qdr("quadruplets.txt");
    generate_code();  // gneration code machin
    propagateExpression(); // propagateExpression
    eliminateDeadCode(); // eliminateDeadCode
    eliminateRedundancy(); // eliminateRedundancy
    simplifyAlgebra();
    //propagateCopy();
    printf(" |\t--------------------------------------------------------\n |");
    printf("\n |- (FIN) Quadruplets after Optimisation\n");
    afficher_qdr();
    sauvegarder_qdr("quadruplets optimse.txt");
    printf(" |\t--------------------------------------------------------\n |");
    printf("\n |- Generated Code after Optimisation:\n");
    generate_code();
    
    
    return 0;
}
int yywrap(){}
int yyerror(char* msg){
    printf ("Syntactic Error, line %d, column %d\n", nb_ligne, Col);
}