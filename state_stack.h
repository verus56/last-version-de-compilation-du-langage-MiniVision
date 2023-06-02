#include <stdio.h>
#include <string.h>    

int stack2[500];     
int top2 = -1;  

int isempty2() {
   if(top2 == -1)
      return 1;
   else
      return 0;
}
   
int isfull2() {
   if(top2 == 500)
      return 1;
   else
      return 0;
}

int peek2() {
   return stack2[top2];
}

int pop2() {
   int data;
	
   if(!isempty2()) {
      data = stack2[top2];
      top2 = top2 - 1;   
      return data;
   }
}

char push2(int data) {
   if(!isfull2()) {
      top2 = top2 + 1;
      stack2[top2] = data;
   }
}