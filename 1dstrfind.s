
#=========================================================================
# 1D String Finder 
#=========================================================================
# Finds the [first] matching word from dictionary in the grid
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2019
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

grid_file_name:         .asciiz  "1dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
                
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 33       # Maximun size of 1D grid_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 11001    # Maximum number of words in dictionary *
                                        # ( maximum size of each word + \n) + NULL
# You can add your data here!
.align 4
dictionary_idx: .space 4000

#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, grid_file_name        # grid file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # grid[idx] = c_input
        la   $a1, grid($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(grid_file);
        blez $v0, END_LOOP              # if(feof(grid_file)) { break }
        lb   $t1, grid($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP 
        
END_LOOP:
        sb   $0,  grid($t0)             # grid[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(grid_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from  file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)                             
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------


# You can add your code here!

       li $t4, 0                       #idx = 0
       li $t3, 0                       #start_idx = 0
       li $t0, 0                       #dict_idx = 0
       li $s1, 0                       #dict_num_words = 0
       li $t6, 0                       #grid_idx = 0
        
DO:     
        lb   $t1, dictionary($t4)      # c_input=dictionary[idx]
        beq $t1, $0, BREAK             # if (c_input=='\0') break
        addi $v0, $0, 10               # newline \n
        bne  $t1, $v0, END             # if(c_input != '\n') idx++
                                       # else
        sw  $t3, dictionary_idx($t0)   # dictionary_idx[dict_idx] = start_idx
        addi $t0, $t0, 4               # dict_idx++
        addi $t3, $t4, 1               # start_idx = idx + 1 
        
END:        
       addi $t4, $t4, 1                # idx = idx + 1
       j DO

BREAK: 
      move $s1, $t0
      j STRFIND                        # call strfind() 
               
#------------------------------------------------------------------
#                         STRFIND FUNCTION
#------------------------------------------------------------------  
     
STRFIND:
       li $t6, 0                       # grid_idx = 0
       li $s5, 0                       # variable checking if any word from the dictionary was found in the string
       
WHILE_LOOP:       
       lb $t7, grid($t6)     
       beq $t7, $0, END_WHILE_LOOP     # if grid[grid_idx] != '\0'
       li $t4, 0                       # idx = 0
        
FOR_LOOP:      
       bge $t4, $s1, END_FOR_LOOP      # if idx >= dict_num_words end_for_loop
       lw $t2, dictionary_idx($t4) 
       la $t9, dictionary($t2)         # word = dictionary + dictionary_idx[idx]
       la $t5, grid($t6)               # grid[grid_idx]
       move $a1, $t5                   # string
       move $a2, $t9                   # word
       la $a3, ($a2)                   # make a copy of the address
       jal CONTAIN 
       beq $v1, 1, PRINT_INT
       addi $t4, $t4, 4                # idx++
       j FOR_LOOP   

END_FOR_LOOP:
       addi $t6, $t6, 1                # grid_idx++
       j WHILE_LOOP
   
END_WHILE_LOOP:  
     bne $s5, $0, MAIN_END  
     li $v0, 1                         # print_string("-1\n");
     li $a0, -1
     syscall
     li $a0, '\n'
     li $v0, 11                        #print_char('\n')
     syscall
     j MAIN_END                        #exit
     
CONTAIN:
      lb $t3, 0($a1)                   # a1 is *string   -> get first character
      lb $t1, 0($a2)                   # a2 is *word   -> get first character
      bne $t3, $t1, END_CONTAIN        # if (*string != *word) go to label
      addi $a2, $a2, 1                 # increase pointer word
      addi $a1, $a1, 1                 # increase pointer of string
      j CONTAIN
       
END_CONTAIN:   
      addi $v1, $0, 10                 # newline \n
      seq $v1, $t1, $v1                # if (*word=='\n') 
      jr  $ra                          # return to for

PRINT_INT:
     li $v0, 1       
     move $a0, $t6                     #print_int ( grid_idx )
     syscall
     li $a0, ' '
     li $v0, 11                        #print_char(' ')
     syscall
     j PRINT_WORD_LOOP
     
PRINT_WORD_LOOP:
     lb $t1, 0($a3)                    # get the first char of the word that needs to be printed
     li $v1, 0 
     addi $v1, $0, 10                  # newline \n
     beq  $t1, $v1, PRINT_NEWLINE      # if (*word=='\n') 
     move $a0, $t1
     li $v0, 11                        # print char
     syscall
     addi $a3, $a3, 1
     j PRINT_WORD_LOOP

PRINT_NEWLINE:          
      li $a0, '\n'
      li $v0, 11                       #print_char('\n')
      syscall
      li $s5, 1                        # found = 1
      jr $ra

#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
MAIN_END:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
