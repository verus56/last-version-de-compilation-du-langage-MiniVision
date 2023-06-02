#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
typedef struct node1 *list_idf_cst;
typedef struct node2 *list_mc_sep;
typedef struct tableau *vals;
typedef struct node1{
    char name[20];
    char code[20];
    char type[20];
    int taille;
    float val;
    vals tab_vals;
    list_idf_cst next;
} node1;

typedef struct node2{
    char name[20];
    char type[20];
    list_mc_sep next;
} node2;

typedef struct tableau{
    int index;
    float val;
    vals next;
} tableau;

list_idf_cst tab[1000];
list_mc_sep tabs[40], tabm[40];

char temp[50];
extern int nb_ligne, Col;

list_idf_cst create_node1(){
    list_idf_cst L;
    L = (list_idf_cst)malloc(sizeof(node1));
    L->next = NULL;
    if (L == NULL){ 
        exit(-1);
    }
    return(L);
}
list_mc_sep create_node2(){
    list_mc_sep L;
    L = (list_mc_sep)malloc(sizeof(node2));
    L->next = NULL;
    if (L == NULL){ 
        exit(-1);
    }
    return(L);
}
vals create_val(){
    vals L;
    L = (vals)malloc(sizeof(tableau));
    L->next = NULL;
    if (L == NULL){ 
        exit(-1);
    }
    return(L);
}

void initialisation(){
    for (int i = 0; i < 1000; i++){
        tab[i] = NULL;
    }
    for (int i = 0; i < 40; i++){
        tabm[i] = NULL;
        tabs[i] = NULL;
    }
}

int hash(char *name, int size){
    int length =  strnlen(name, 128);
    unsigned int hash_value =0;
    for (int i = 0; i < length; i++){
        hash_value += name[i];
        hash_value *= name[i];
    } 
    
    return hash_value % size;
}

void update_tab(int size, char entite[], char code[], char type[], int taille, float val){
    int state = 1;
    int n = hash(entite, size);
    list_idf_cst L = tab[n], L2;
    if (L == NULL){
        L = create_node1();
        strcpy(L->name, entite);
        strcpy(L->code, code);
        strcpy(L->type, type);
        L->taille = taille;
        L->val = val;
        tab[n] = L;
        L->tab_vals = NULL;
    }
    else{
        if (L->next == NULL){
            if ((strcmp(entite, L->name) == 0) && (state == 1)){
                state = 0;
            }
        }
        else{
            while (L->next != NULL){
                if ((strcmp(entite, L->name) == 0) && (state == 1)){
                    state = 0;
                    break;
                }
                L = L->next;
            }
            if ((strcmp(entite, L->name) == 0) && (state == 1)){
                state = 0;
            }
        }
        if (state == 1){
            L2 = create_node1();
            strcpy(L2->name, entite);
            strcpy(L2->code, code);
            strcpy(L2->type, type);
            L2->taille = taille;
            L2->val = val;
            L2->tab_vals = NULL;
            L->next = L2;
        }
    }
}

void update_tabm(int size, char entite[], char code[]){
    int state = 1;
    int n = hash(entite, size);
    list_mc_sep L = tabm[n], L2;
    if (L == NULL){
        L = create_node2();
        strcpy(L->name, entite);
        strcpy(L->type, code);
        tabm[n] = L;
    }
    else{
        if (L->next == NULL){
            if ((strcmp(entite, L->name) == 0) && (state == 1)){
                state = 0;
            }
        }
        else{
            while (L->next != NULL){
                if ((strcmp(entite, L->name) == 0) && (state == 1)){
                    state = 0;
                    break;
                }
                L = L->next;
            }
            if ((strcmp(entite, L->name) == 0) && (state == 1)){
                state = 0;
            }
        }
        if (state == 1){
            L2 = create_node2();
            strcpy(L2->name, entite);
            strcpy(L2->type, code);
            L->next = L2;
        }
    }
}

void update_tabs(int size, char entite[], char code[]){
    int state = 1;
    int n = hash(entite, size);
    list_mc_sep L = tabs[n], L2, Ls;
    if (tabs[n] == NULL){
        L2 = create_node2();
        strcpy(L2->name, entite);
        strcpy(L2->type, code);
        tabs[n] = L2;
    }
    else{
        if (L->next == NULL){
            if ((strcmp(entite, L->name) == 0) && (state == 1)){
                state = 0;
            }
        }
        else{
            while (L->next != NULL){
                if ((strcmp(entite, L->name) == 0) && (state == 1)){
                    state = 0;
                    break;
                }
                L = L->next;
            }
            if ((strcmp(entite, L->name) == 0) && (state == 1)){
                state = 0;
            }
        }
        if (state == 1){
            L2 = create_node2();
            strcpy(L2->name, entite);
            strcpy(L2->type, code);
            L->next = L2;
        }
    }
}

void inserer(char entite[], char code[], char type[], int taille, float val, int y){
    switch (y){ 
        case 0:/* insertion in IDF Table*/
            update_tab(1000, entite, code, type, taille, val);            
            break;

        case 1:/* insertion in KeyWords Table */
            update_tabm(40, entite, code);
            break; 

        case 2:/* insertion in Separators Table*/
            update_tabs(40, entite, code);
            break;
    }

}

void afficher(){
    int i;
    list_idf_cst L;
    list_mc_sep Lm, Ls;
    printf(" |- (1) LISTING THE TS TABLE\n |\n");
    printf(" |\t/*************** IDF Table *************/\n");
    printf(" |\t_______________________________________________________________________\n");
    printf(" |\t| Entity_Name | Entity_Code | Entity_Type | Entity_Val | Entity_Size  |\n");
    printf(" |\t_______________________________________________________________________\n");

    for (i = 0; i < 1000; i++){
        L = tab[i];
        while(L != NULL){
            printf(" |\t|%12s |%12s | %11s | %10f | %12d |\n",L->name, L->code, L->type, L->val, L->taille); 
            L = L->next;
        }
    } 

    printf(" |\t______________________________________________________________________\n"); 
    printf(" |\n |\t/*************** MC Table *************/\n");
    printf(" |\t_____________________________\n");
    printf(" |\t| Entity_Name |  Entity_Code | \n");
    printf(" |\t_____________________________\n");

    for (i = 0; i < 40; i++){
        Lm = tabm[i];
        while(Lm != NULL){
            printf(" |\t|%12s |%12s | \n", Lm->name, Lm->type); 
            Lm = Lm->next;
        }
    }

    printf(" |\t_____________________________\n");
    printf(" |\n |\t/*************** Separators Table *************/\n");
    printf(" |\t_____________________________\n");
    printf(" |\t| Entity_Name |  Entity_Code | \n");
    printf(" |\t_____________________________\n");
    for (i = 0; i < 40; i++){
        Ls = tabs[i];
        while(Ls != NULL){
            printf(" |\t|%12s |%12s | \n", Ls->name, Ls->type); 
            Ls = Ls->next;
        }
    }
    printf(" |-\t_____________________________\n\n");
}

void print_nodes(){
    int i;
    list_idf_cst L;
    list_mc_sep Lm, Ls;
    printf(" |- (2) LISTING THE NODES AS A HASHMAP\n |\n");
    printf(" |\t/*************** IDF Table *************/\n");
    for (i = 0; i < 1000; i++){
        L = tab[i];
        if (L == NULL){
            continue;
        }
        printf(" |\t[%d] ", i);
        while(L != NULL){
            printf("\"%s\" -> ", L->name); 
            L = L->next;
        }
        printf("NULL\n");
    } 
    printf(" |\n |\t/*************** KeyWords Table *************/\n");
    for (i = 0; i < 40; i++){
        Lm = tabm[i];
        if (Lm == NULL){
            continue;
        }
        printf(" |\t[%d] ", i);
        while(Lm != NULL){
            printf("\"%s\" -> ", Lm->name); 
            Lm = Lm->next;
        }
        printf("NULL\n");
    }  

    printf(" |\n |\t/*************** Separators Table *************/\n");
    for (i = 0; i < 40; i++){
        Ls = tabs[i];
        if (Ls == NULL){
            continue;
        }
        printf(" |\t[%d] ", i);
        while(Ls != NULL){
            printf("\"%s\" -> ", Ls->name); 
            Ls = Ls->next;
        }
        printf("NULL\n");
    }    
    printf(" |-\t\n");
}

/***  FUNCTIONS For hlep ***/

char* split_string(char* s, int start, int end){
    if ((start >= 0) && (end <= strlen(s)-1) && (start<end)){
        char* temp = (char*)calloc((end - start), sizeof(char));
        for (size_t i = start; i <= end; i++){
            temp[i-start] = s[i];
        }
        return temp;
        free(temp);
    }
}

list_idf_cst exist(char name[], int size){
    int n = hash(name, size);
    list_idf_cst L = tab[n];
    
    while(L != NULL){
        if (strcmp(name, L->name) == 0){
            return L;
        }
        L = L->next;
    }
    return NULL;
}

bool doubleDeclaration(char name[]){
    if (exist(name, 1000) != NULL){
        return true;
    }
    else{
        return false;
    }
}

bool nonDeclare(char name[]){   
    if (exist(name, 1000) == NULL)
        return true;
    else{
        return false;
    }
}

bool outOfRange(char name[], int index){
    list_idf_cst L = exist(name, 1000);
    if ((index >= 0) && (index < L->taille)){
        return false;
    }
    return true;
}


bool typeCompatibilite(char type1[], char type2[]){
    if ((strcmp(type1, "Int") == 0) && ((strcmp(type2, "Int") == 0) || (strcmp(type2, "Float") == 0))){
        return false; 
    }
    else if ((strcmp(type1, "Float") == 0) && ((strcmp(type2, "Int") == 0) || (strcmp(type2, "Float") == 0))){
        return false;  
    }
    else if ((strcmp(type1, "Bool") == 0) && (strcmp(type2, "Bool") == 0)){
        return false;
    }
    else if ((strcmp(type1, "Char") == 0) && (strcmp(type2, "Char") == 0)){
        return false;
    }
    return true;
}
bool divisionParZero(float num){
    if (num == 0){
        return true;
    }
    return false;
}
void get_string_of_val(char* type, float val){
    if (strcmp(type, "Int") == 0){
        sprintf(temp, "%d", (int) val);
    }
    if (strcmp(type, "Float") == 0){
        sprintf(temp, "%f", val);
    }
    if (strcmp(type, "Char") == 0){
        sprintf(temp, "'%c'", (char) val);
    }
    if (strcmp(type, "Bool") == 0){
        if (val == 1){
            strcpy(temp, "true");
        }
        else{
            strcpy(temp, "false");
        }
    }    
}

void update_type(char name[], char type[]){
    list_idf_cst L = exist(name, 1000);
    strcpy(L->type, type);
}

void update_val(char name[], float val){
    list_idf_cst L = exist(name, 1000);
    L->val = val;
}

char *get_type(char name[]){
    list_idf_cst L = exist(name, 1000);
    if (L != NULL){
        return L->type;
    }
    return NULL;
}

char *get_code(char name[]){
    list_idf_cst L = exist(name, 1000);
    if (L != NULL){
        return L->code;
    }
    return NULL;
}

float get_val(char name[]){
    list_idf_cst L = exist(name, 1000);
    if (L != NULL){
        return L->val;
    }
}

void set_tab_val(char name[], int index, float val){
    int state = 1;
    list_idf_cst L = exist(name, 1000);
    vals L2 = L->tab_vals, L3;
    if (L2 == NULL){
        L2 = create_val();
        L2->index = index;
        L2->val = val;
        L->tab_vals = L2;
    }
    else{
        if (L2->next == NULL){
            if (L2->index == index){
                L2->val = val;
                state = 0;
            }
        }
        else{
            while (L2->next != NULL){
                if ((L2->index == index) && (state == 1)){
                    L2->val = val;
                    state = 0;
                    break;
                }
                L2 = L2->next;
            }
            if ((L2->index == index) && (state == 1)){
                L2->val = val;
                state = 0;
            }
        }
        if (state == 1){
            L3 = create_val();
            L3->index = index;
            L3->val = val;
            L2->next = L3;
        }
    }
}
float get_tab_val(char *name, int index){
    list_idf_cst L = exist(name, 1000);
    vals L2 = L->tab_vals;
    while (L2 != NULL){
        if (L2->index == index){
            return L2->val;
        }
        L2 = L2->next;
    }
}
bool index_check(char *name, int index){
    list_idf_cst L = exist(name, 1000);
    vals L2 = L->tab_vals;

    while (L2 != NULL){
        if (L2->index == index){
            return true;
        }
        L2 = L2->next;
    }
    return false;
}
void print_tabs(){
    int i;
    list_idf_cst L;
    printf("\n |- (3) LISTING THE TAB VALUES INSIDE THE CODE\n");
    for (i = 0; i < 1000; i++){
        L = tab[i];
        if (L == NULL){
            continue;
        }
        if (strcmp(L->code, "IDF Tab") != 0){
            continue;
        }
        while(L != NULL){
            printf(" |\t%s[%d] :", L->name, L->taille);
            if (L->tab_vals != NULL){
                while(L->tab_vals != NULL){
                    get_string_of_val(L->type, (L->tab_vals)->val);
                    printf("\n |\t\t%s[%d] = %s", L->name, (L->tab_vals)->index, temp);
                    L->tab_vals = (L->tab_vals)->next;
                }
                printf("\n");
            }
            else{
                printf(" Empty\n");
            }
            L = L->next;
        }
    }
    printf(" |-\t\n");
}   