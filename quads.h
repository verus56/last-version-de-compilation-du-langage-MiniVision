#include <ctype.h>

typedef struct qdr {
    char oper[100]; 
    char op1[100];   
    char op2[100];   
    char res[100];  
} qdr;

qdr quad[1000];
extern int qc;

void quadr(char opr[],char op1[],char op2[],char res[]){
	strcpy(quad[qc].oper, opr);
	strcpy(quad[qc].op1, op1);
	strcpy(quad[qc].op2, op2);
	strcpy(quad[qc].res, res);
    qc++;
}


// Function to check if two quadruplets are identical
bool isRedundant(qdr q1, qdr q2) {
    return strcmp(q1.oper, q2.oper) == 0 && strcmp(q1.op1, q2.op1) == 0 && strcmp(q1.op2, q2.op2) == 0;
}

// Function to perform redundant expression elimination
void eliminateRedundancy() {
    int i, j;
    for (i = 0; i < qc; i++) {
        for (j = i + 1; j < qc; j++) {
            if (isRedundant(quad[i], quad[j])) {
                strcpy(quad[j].oper, "="); // Clear redundant quadruplet
                strcpy(quad[j].op1,quad[i].res );
                strcpy(quad[j].op2, "Empty");
                // strcpy(quad[j].res, "");

                
                
            }
        }
    }
}


void propagateExpression() {
    int i;
    for (i = 0; i < qc; i++) {
        if (strcmp(quad[i].oper, "=") == 0) {
            char temp[100];
            strcpy(temp, quad[i].res);

            for (int j = i + 1; j < qc; j++) {
                if (strcmp(quad[j].op1, temp) == 0)
                    strcpy(quad[j].op1, quad[i].op1);

                if (strcmp(quad[j].op2, temp) == 0)
                    strcpy(quad[j].op2, quad[i].op1);
            }
        }
    }
}

void propagateCopy() {
    int i;
    for (i = 0; i < qc; i++) {
        if (strcmp(quad[i].oper, "=") == 0) {
            char op1[100];
            strcpy(op1, quad[i].op1);

            for (int j = i + 1; j < qc; j++) {
                if (strcmp(quad[j].op1, op1) == 0)
                    strcpy(quad[j].op1, quad[i].res);

                if (strcmp(quad[j].op2, op1) == 0)
                    strcpy(quad[j].op2, quad[i].res);
            }
        }
    }
}

// Function to perform algebraic simplification
void simplifyAlgebra() {
    int i;
    for (i = 0; i < qc; i++) {
        if (strcmp(quad[i].oper, "=") == 0) {
            // Check for specific algebraic simplification rules
            if (strcmp(quad[i].oper, "*") == 0 && strcmp(quad[i].op2, "1") == 0) {
                // Replace multiplication by 1 with the original operand
                strcpy(quad[i].oper, "=");
                strcpy(quad[i].op2, "Empty");
            }
            else if (strcmp(quad[i].oper, "*") == 0 && strcmp(quad[i].op2, "0") == 0) {
                // Replace multiplication by 0 with 0
                strcpy(quad[i].oper, "=");
                strcpy(quad[i].op1, "0");
                strcpy(quad[i].op2, "Empty");
            }
            // Add more simplification rules as needed
            
        }
    }
}


void eliminateDeadCode() {
    int i;
    for (i = 0; i < qc; i++) {
        if (strcmp(quad[i].oper, "=") == 0) {
            // Check if the assignment result is never used
            bool isUnused = true;
            for (int j = i + 1; j < qc; j++) {
                if (strcmp(quad[j].op1, quad[i].res) == 0 || strcmp(quad[j].op2, quad[i].res) == 0) {
                    isUnused = false;
                    break;
                }
            }

            if (isUnused) {
                // Remove the dead code assignment
                strcpy(quad[i].oper, "Empty");
                strcpy(quad[i].op1, "Empty");
                strcpy(quad[i].op2, "Empty");
                strcpy(quad[i].res, "Empty");
            }
        }
    }
}





void ajour_quad(int num_quad, int colon_quad, char val []){
    switch (colon_quad){
        case 0:
            strcpy(quad[num_quad].oper, val);
            break;
        case 1: 
            strcpy(quad[num_quad].op1, val);
            break;
        case 2:
            strcpy(quad[num_quad].op2, val);
            break;
        case 3: 
            strcpy(quad[num_quad].res, val);
            break;
    }
}

void afficher_qdr(){
    int i;
    printf("\n |- (4) LISTING QUADRUPLETS\n");
    printf(" |\t--------------------------------------------------------\n |");
    for (i = 0; i < qc; i++){
        printf("\n |\t %d - ( %s  ,  %s  ,  %s  ,  %s )",i, quad[i].oper, quad[i].op1, quad[i].op2, quad[i].res); 
        printf("\n |\t--------------------------------------------------------\n |");
    }
    printf("-\n");
}

void sauvegarder_qdr(const char* filename) {
    int i;
    FILE* fp = fopen(filename, "w");
    if (fp == NULL) {
        perror("Error opening file");
        return;
    }
    fprintf(fp, "\n |- (4) LISTING QUADRUPLETS\n");
    fprintf(fp, " |\t--------------------------------------------------------\n |");
    for (i = 0; i < qc; i++){
        fprintf(fp, "\n |\t %d - ( %s  ,  %s  ,  %s  ,  %s )",i, quad[i].oper, quad[i].op1, quad[i].op2, quad[i].res); 
        fprintf(fp, "\n |\t--------------------------------------------------------\n |");
    }
    fprintf(fp, "-\n");
    fclose(fp);
}


void generate_code() {
    int i;
    printf("\n |- (5) Generated Code\n");
    printf( " |\t--------------------------------------------------------\n |");
    for (i = 0; i < qc; i++) {
        printf("%d:\t", i);
        if (strcmp(quad[i].oper, "+") == 0) {
            printf("\n |\t MOV AX, %s\n", quad[i].op1);
            printf("\n |\tADD AX, %s\n", quad[i].op2);
            printf("\n |\tMOV %s, AX\n", quad[i].res);
        } else if (strcmp(quad[i].oper, "-") == 0) {
            printf("\n |\t MOV AX, %s\n", quad[i].op1);
            printf("\n |\t SUB AX, %s\n", quad[i].op2);
            printf("\n |\t MOV %s, AX\n", quad[i].res);
        } else if (strcmp(quad[i].oper, "*") == 0) {
            printf("\n |\t MOV AX, %s\n", quad[i].op1);
            printf("\n |\t MUL %s\n", quad[i].op2);
            printf("\n |\t MOV %s, AX\n", quad[i].res);
        } else if (strcmp(quad[i].oper, "/") == 0) {
            printf("\n |\t MOV AX, %s\n", quad[i].op1);
            printf("\n |\t MOV BX, %s\n", quad[i].op2);
            printf("\n |\t DIV BX\n");
            printf("\n |\t MOV %s, AX\n", quad[i].res);
        } else if (strcmp(quad[i].oper, "=") == 0) {
            printf("\n |\t MOV AX, %s\n", quad[i].op1);
            printf("\n |\t MOV %s, AX\n", quad[i].res);
        } else if (strcmp(quad[i].oper, "goto") == 0) {
            printf("\n |\t JMP %s\n", quad[i].res);
        } else if (strcmp(quad[i].oper, "if") == 0) {
            printf("\n |\t MOV AX, %s\n", quad[i].op1);
            printf("\n |\t CMP AX, %s\n", quad[i].op2);
            printf("\n |\t JNE %s\n", quad[i].res);
        }
    }
}


