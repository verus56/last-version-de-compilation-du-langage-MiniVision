#include <stdio.h>
#include <string.h>    

char stack[500][100];
int top = -1;  

int isempty() {
   if(top == -1)
      return 1;
   else
      return 0;
}
   
int isfull() {
   if(top == 500)
      return 1;
   else
      return 0;
}

char* peek() {
   return stack[top];
}

char* pop() {
   char* data;
	
   if(!isempty()) {
      data = stack[top];
      top = top - 1;   
      return data;
   }
}

char push(char *data) {
   if(!isfull()) {
      top = top + 1;
      strcpy(stack[top], data);
   }
}