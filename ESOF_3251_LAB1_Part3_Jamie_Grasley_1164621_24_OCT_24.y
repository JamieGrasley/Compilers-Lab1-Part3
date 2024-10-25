/*Jamie Grasley #1164621 on MacOS*/
%{

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

extern int yylex();  
extern int yyparse(); 
extern void yyerror(const char *s);
//Stack size is arbitrary
#define SIZE 5
int count = 0;//Conter for the stack
int stack[SIZE]={1}; //Set the top value in the stack to 1 so top() works correctly

//Push onto the stack
void push(int value){
if(count<SIZE){
        count++;
        stack[count]=value;
        
}
else{
        printf("Stack full");
}
}
//Pop off the stack, return -1 if empty because otherwise it would always return true or false
int pop(){
if(count>=0){

        return stack[count--];
}
else{
        printf("Stack empty");
        return -1;
}
}
//Check the top of the stack, return -1 if empty because otherwise it would always return true or false
int top(){
if(count>=0){
        return stack[count];
}
else{
        printf("Stack empty");
        return -1;
}   
}

typedef struct idTable idTable;
struct idTable {
        char key[1024];
        int val;
};

idTable valTable[50];
int tabCount=0;

int checkTable(char *id){
        if(tabCount==0){return -1;}
        for(int i=0;i<tabCount;i++){
                if(strcmp(id,valTable[i].key)==0){
                return i;
                }
        }
        return -1;
}
void tableAdd(char *id, int value){
        if (tabCount<50){
        strncpy(valTable[tabCount].key,id,sizeof(valTable[tabCount].key)-1);
        valTable[tabCount].val=value;
        tabCount++;
        }
        else{printf("Assignment table full");}
}
void tableAssign(int value, int index){
        valTable[index].val=value;
}
int getValue(char *id){
        for(int i=0;i<tabCount;i++){
                if(strcmp(id,valTable[i].key)==0){
                return valTable[i].val;
                }
        }
        return -1;
}


%}

%union {
    int intval; //Store int values
    char* strval; //Store string values
}
//Define all tokens
%token IF THEN ELSE ENDIF PRINT NEWLINE SEMICOLON STOP ADD SUB MULT DIV LES GRE LEQ GEQ COMP NEQ LBR RBR ASSIGN
//Associate to correct return types and storage types
%token <strval> STR
%token <strval> IDENT
%type <intval> expr
%token <intval> INT
// Define operator precedence
%left ADD SUB   
%left MULT DIV
%nonassoc LES GRE LEQ GEQ COMP NEQ 


%%
//Rules for the interpreter
program:
        stmt_list
        ;

stmt_list:
        stmt stmt_list
        |
        ;
stmt:
        assign_stmt
        |if_stmt
        |print_stmt
        |newline
        |end_stmt
        |expr
        ;
if_stmt:
    IF expr THEN {top()==1 ? push($2!=0) : push(0);} stmt_list {pop();} //If top is 1 then its true and executes the if statement
    ELSE {top()==1 ? push($2==0) : push(0);} stmt_list {pop();} ENDIF  //If top is 0 then its true and executes the else statement
    ;
    



print_stmt:
        PRINT STR SEMICOLON {if (top() == 1){printf("%s\n", $2);}} //Print a string
        |PRINT expr SEMICOLON {if (top() == 1){printf("%d\n", $2);}} //Print an evaluated expression
;
newline:
        PRINT NEWLINE SEMICOLON {if (top() == 1){printf("\n");}}//Print a newline
        ;
assign_stmt:
        IDENT ASSIGN expr SEMICOLON{
                int index=checkTable($1);
                if(index>-1){
                        tableAssign($3,index);
                }
                else if (index==-1){
                        tableAdd($1,$3);

                }
        }
        ;

expr://The expressions operations
        expr ADD expr           {$$ = $1 + $3;}
        |expr SUB expr          {$$ = $1 - $3;}
        |expr MULT expr         {$$ = $1 * $3;}
        |expr DIV expr          {$$ = $1 / $3;}
        |expr LES expr          {$$ = ($1 < $3) ? 1 : 0;}
        |expr GRE expr          {$$ = ($1 > $3) ? 1 : 0;}
        |expr LEQ expr          {$$ = ($1 <= $3) ? 1 : 0;}
        |expr GEQ expr          {$$ = ($1 >= $3) ? 1 : 0;}
        |expr COMP expr         {$$ = ($1 == $3) ? 1 : 0;}
        |expr NEQ expr          {$$ = ($1 != $3) ? 1 : 0;}
        |LBR expr RBR           {$$ = $2;}
        |INT                    {$$=$1;}
        |IDENT                  {$$=getValue($1);}
        ;

//Allows for exiting the process
end_stmt:    
        STOP SEMICOLON { printf("Ending process\n"); exit(0); }
         ;

%%
//For error handling
 void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}