#include <stdio.h>

// maximum size of each dimension
#define MAX_DIM_SIZE 32
// maximum number of words in dictionary file
#define MAX_DICTIONARY_WORDS 1000
// maximum size of each word in the dictionary
#define MAX_WORD_SIZE 10

int read_char() { return getchar(); }
int read_int()
{
  int i;
  scanf("%i", &i);
  return i;
}
void read_string(char* s, int size) { fgets(s, size, stdin); }
void print_char(int c)     { putchar(c); }
void print_int(int i)      { printf("%i", i); }
void print_string(char* s) { printf("%s", s); }
void output(char *string)  { print_string(string); }

// dictionary file name
const char dictionary_file_name[] = "dictionary.txt";
// grid file name
const char grid_file_name[] = "2dgrid.txt";
// content of grid file
char grid[(MAX_DIM_SIZE + 1 /* for \n */ ) * MAX_DIM_SIZE + 1 /* for \0 */ ];
// content of dictionary file 
char dictionary[MAX_DICTIONARY_WORDS * (MAX_WORD_SIZE + 1 /* for \n */ ) + 1 /* for \0 */ ];
///////////////////////////////////////////////////////////////////////////////
/////////////// Do not modify anything above
///////////////Put your global variables/functions here///////////////////////


int nr_cols = 0;
int nr_rows = 0;
int found = 0;

// starting index of each word in the dictionary
int dictionary_idx[MAX_DICTIONARY_WORDS];
// number of words in the dictionary
int dict_num_words = 0;



// function to print found word
void print_word(char *word)
{
  while(*word != '\n' && *word != '\0') {
    print_char(*word);
    word++;
  }
}

// function to see if the string contains the (\n terminated) word
int contain_h(char *string, char *word)
{
  while (1) {
    if (*string != *word || *string == '\n'){
      return (*word == '\n');
    }
    string++;
    word++;
  }
  return 0;
}

int contain_v(char *string, char *word){

   while(1){  
     if (*string != *word || *string == '\n'){
        return (*word == '\n');
     }
     if (string - grid + nr_cols +1 < (nr_cols + 1)*nr_rows){
     string+=nr_cols+1;
     word++;
     }
     else{
       word++;
       return (*word == '\n');
     }
   }
    return 0;
   }

int contain_d(char *string, char *word){

   while(1){  
     if (*string != *word || *string == '\n') {    
        return (*word == '\n');
     }
     if ((string - grid + nr_cols + 2 < ((nr_cols + 1)*nr_rows))){ //&& *string != '\n'
      string+=nr_cols+2;
      word++;
     }
     else{
       word++;
       return (*word == '\n');
     }
   }
    return 0;
   
}

void print(int row, int col, char *word, char direction){
      print_int(row);
      print_char(',');
      print_int(col);
      print_char(' ');
      print_char(direction);
      print_char(' ');
      print_word(word);
      print_char('\n');
}

void strfind(int grid_idx, int row)
{
  int offset = grid_idx;
  int idx = 0;
  char *word;
  int col = 0;
  while (grid[grid_idx] != '\n') {
    for(idx = 0; idx < dict_num_words; idx ++) {
      word = dictionary + dictionary_idx[idx]; 
      if (contain_h(grid + grid_idx, word)) {
        col = grid_idx-offset;
        print(row, col, word, 'H');
        found = 1;
      }
      if (contain_v(grid + grid_idx, word)){
        col = grid_idx-offset;
        print(row, col, word, 'V');
        found = 1;
      }
      if (contain_d(grid + grid_idx, word)){
        col = grid_idx-offset;
        print(row, col, word, 'D');
        found = 1;
      }
    }
    grid_idx++;
  }
}

void length(){
     int idx = 0;
     while (grid[idx]!='\0'){
       if (grid[idx]=='\n'){
         if (nr_cols == 0)
            nr_cols=idx;
         nr_rows++;
       }
       idx++;
     }
}



//---------------------------------------------------------------------------
// MAIN function
//---------------------------------------------------------------------------

int main (void)
{

  /////////////Reading dictionary and grid files//////////////
  ///////////////Please DO NOT touch this part/////////////////
  int c_input;
  int idx = 0;


  // open grid file
  FILE *grid_file = fopen(grid_file_name, "r");
  // open dictionary file
  FILE *dictionary_file = fopen(dictionary_file_name, "r");

  // if opening the grid file failed
  if(grid_file == NULL){
    print_string("Error in opening grid file.\n");
    return -1;
  }

  // if opening the dictionary file failed
  if(dictionary_file == NULL){
    print_string("Error in opening dictionary file.\n");
    return -1;
  }
  // reading the grid file
  do {
    c_input = fgetc(grid_file);
    // indicates the the of file
    if(feof(grid_file)) {
      grid[idx] = '\0';
      break;
    }
    grid[idx] = c_input;
    idx += 1;

  } while (1);

  // closing the grid file
  fclose(grid_file);
  idx = 0;
   
  // reading the dictionary file
  do {
    c_input = fgetc(dictionary_file);
    // indicates the end of file
    if(feof(dictionary_file)) {
      dictionary[idx] = '\0';
      break;
    }
    dictionary[idx] = c_input;
    idx += 1;
  } while (1);


  // closing the dictionary file
  fclose(dictionary_file);
  //////////////////////////End of reading////////////////////////
  ///////////////You can add your code here!//////////////////////
  int start_idx = 0;
  int dict_idx = 0;
  idx = 0;
  do {
    c_input = dictionary[idx];
    if(c_input == '\0') {
      break;
    }
    if(c_input == '\n') {
      dictionary_idx[dict_idx ++] = start_idx;
      start_idx = idx + 1;
    }
    idx += 1;
  } while (1);

  dict_num_words = dict_idx;

  length();
  
  int row =0;
  int idx_2=0;

  while (row<nr_rows){
      strfind(idx_2, row);
      idx_2+=nr_cols+1;
      row++;
  }
  
  if (found == 0)
     print_string("-1\n");

  return 0;
}
