
#=========================================================================
# 2D String Finder 
#=========================================================================
# Finds the matching words from dictionary in the 2D grid
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

grid_file_name:         .asciiz  "2dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 1057     # Maximun size of 2D grid_file + NULL (((32 + 1) * 32) + 1)
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
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP 
END_LOOP:
        sb   $0,  grid($t0)            # grid[idx] = '\0'

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
       li $v0, 0
       li $s5, 0                       # ok = 0
        
DO:     
        lb   $t1,dictionary($t4)       # c_input=dictionary[idx]
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
      jal LENGTH                       # compute the number of rows/columns in grid
      li $s6, 0                        # row = 0
      li $t5, 0                        # idx_2 = 0

MAIN_WHILE_LOOP:      
      slt $t4, $s6, $s4               # while (row < nr_rows)
      beq $t4, $0, TESTPRINT          # when exiting the while loop, test if any word was found
      move $s7, $t5                   # $s7 is the strfind's function parameter aka idx_2
      j STRFIND                       # call strfind(idx_2, row)     
      
RETURN_FROM_STRFIND:
      addi, $t5, $t5, 1               # idx_2 += nr_cols+1
      add $t5, $t5, $s3
      addi $s6, $s6, 1                # row++
      j MAIN_WHILE_LOOP     
      
      
#------------------------------------------------------------------
#                         STRFIND FUNCTION
#------------------------------------------------------------------  
 
       
STRFIND:                              # strfind($s7, $s6)        
       move $k1, $s7                  # offset = grid_idx
       li $k0, 0                      # col=0
       
WHILE_LOOP:       
       li $t4, 0                             # idx = 0
       lb $t7, grid($s7)                     # get grid[grid_idx]
       addi $v1, $0, 10                      # get newline char
       beq $t7, $v1, RETURN_FROM_STRFIND     # while (grid[grid_idx] != '\n')
        
FOR_LOOP:      
       slt $t8, $t4, $s1               # (idx<dict_num_words) ? 1 : 0         
       beq $t8, $0, END_FOR_LOOP       # if idx>=dict_num_words end_for_loop
       la $s0, dictionary
       la $s2, grid
       lw $t2, dictionary_idx($t4) 
       add $t9, $s0, $t2               # word = dictionary+dictionary_idx[idx]          
       add $s2, $s2, $s7               # string = grid[grid_idx]    
       
HORIZONTAL:              
       la $t6, ($t9)
       move $a3, $t6
       move $a1, $s2                   # make copies of the parameters
       move $a2, $t9
       jal CONTAIN_H
       
VERTICAL: 
       move $a3, $t6
       move $a1, $s2                   # make copies of the parameters
       move $a2, $t9
       jal CONTAIN_V
       
DIAGONAL:       
       move $a3, $t6
       move $a1, $s2                   # make copies of the parameters
       move $a2, $t9
       jal CONTAIN_D
       
INC:       
       addi $t4, $t4, 4                # idx++
       j FOR_LOOP  

END_FOR_LOOP:
       addi $s7, $s7, 1                # grid_idx++
       j WHILE_LOOP
      
#------------------------------------------------------------------
#                        CONTAIN_H FUNCTION
#------------------------------------------------------------------            
       
CONTAIN_H:
       lb $t3, 0($a1)                  # a1 is *string   -> get first character
       lb $t1, 0($a2)                  # a2 is *word   -> get first character
       addi $a2, $a2, 1                # increase pointer word
       addi $a1, $a1, 1                # increase pointer of string
       bne $t3, $t1, END_CONTAIN_H     # if (*string != *word) go to label
       addi $v1, $0, 10                
       beq $t3, $v1, END_CONTAIN_H     #if (*string == '\n') go to label
       j CONTAIN_H
       
END_CONTAIN_H:    
       addi $v1, $0, 10                # newline \n
       beq  $t1, $v1, PRINT_H          # if (*word=='\n') print it
       jr $ra                          # else return to for 
       
#------------------------------------------------------------------
#                        CONTAIN_V FUNCTION
#------------------------------------------------------------------           
       
CONTAIN_V:
       lb $t3, 0($a1)                  # a1 is *string   -> get first character
       lb $t1, 0($a2)                  # a2 is *word   -> get first character
       bne $t3, $t1, END_CONTAIN_V     # if (*string != *word) go to label
       addi $v1, $0, 10                
       beq $t3, $v1, END_CONTAIN_V     # if (*string == '\n') go to label
       la $v1, grid                    #
       sub $v0, $a1, $v1               #             
       add $v0, $v0, $s3               # string - grid + nr_cols +1
       addi $v0, $v0, 1                #
       addi $v1, $s3, 1
       mul $v1, $v1, $s4               # (nr_cols + 1)*nr_rows
       bge $v0, $v1, ELSE_BRANCH_V     # if (string - grid + nr_cols +1 < (nr_cols + 1)*nr_rows)
       add $a1, $a1, $s3
       addi $a1, $a1, 1                # string+=nr_cols+1
       addi $a2, $a2, 1                # increase pointer word
       j CONTAIN_V
       
END_CONTAIN_V:    
       addi $v1, $0, 10                # newline \n
       beq  $t1, $v1, PRINT_V          # if (*word=='\n') print it
       jr $ra                          # else return to for

ELSE_BRANCH_V:
      addi $a2, $a2, 1                # increase pointer word
      lb $t1, 0($a2)                  # a2 is *word   -> get first character
      j END_CONTAIN_V

#------------------------------------------------------------------
#                        CONTAIN_D FUNCTION
#------------------------------------------------------------------          
       
CONTAIN_D:
       lb $t3, 0($a1)                  # a1 is *string   -> get first character
       lb $t1, 0($a2)                  # a2 is *word   -> get first character
       bne $t3, $t1, END_CONTAIN_D     # if (*string != *word) go to label
       addi $v1, $0, 10                
       beq $t3, $v1, END_CONTAIN_D     # if (*string == '\n') go to label
       la $v1, grid                    #
       sub $v0, $a1, $v1               #             
       add $v0, $v0, $s3               # string - grid + nr_cols + 2
       addi $v0, $v0, 2                #
       addi $v1, $s3, 1
       mul $v1, $v1, $s4               # (nr_cols + 1)*nr_rows
       bge $v0, $v1, ELSE_BRANCH_D     # if (string - grid + nr_cols +1 < (nr_cols + 1)*nr_rows)
       add $a1, $a1, $s3
       addi $a1, $a1, 2                # string+=nr_cols+2
       addi $a2, $a2, 1                # increase pointer word
       j CONTAIN_D
       
END_CONTAIN_D:    
       addi $v1, $0, 10                # newline \n
       beq  $t1, $v1, PRINT_D          # if (*word=='\n') print it
       jr $ra                          # else return to for
       
ELSE_BRANCH_D:
      addi $a2, $a2, 1                # increase pointer word
      lb $t1, 0($a2)                  # a2 is *word   -> get first character
      j END_CONTAIN_D


#------------------------------------------------------------------
#                       PRINT_V FUNCTION
#------------------------------------------------------------------ 

PRINT_V:
     sub $k0, $s7, $k1               # col = grid_idx-offset
     li $v0, 1       
     move $a0, $s6                   #print_int  --- row
     syscall
     li $a0, ','
     li $v0, 11                      #print_char(',')
     syscall
     li $v0, 1       
     move $a0, $k0                   #print_int  --- col
     syscall
     li $a0, ' '
     li $v0, 11                      #print_char(' ')
     syscall
     li $a0, 'V'
     li $v0, 11                      #print_char('H')
     syscall
     li $a0, ' '
     li $v0, 11                      #print_char(' ')
     syscall
     
PRINT_WORD_LOOP_V:
     lb $t1, 0($a3)                    #get the first char of the word that needs to be printed
     li $v1, 0 
     addi $v1, $0, 10                  # newline \n
     beq  $t1, $v1, PRINT_NEWLINE_V    # if (*word=='\n') 
     move $a0, $t1
     li $v0, 11                        #print char
     syscall
     addi $a3, $a3, 1
     j PRINT_WORD_LOOP_V

PRINT_NEWLINE_V:          
      li $a0, '\n'
      li $v0, 11                     #print_char('\n')
      syscall
      
      li $s5, 1                      # at least one word was found in the string
      j DIAGONAL

#------------------------------------------------------------------
#                       PRINT_H FUNCTION
#------------------------------------------------------------------ 

PRINT_H:
     sub $k0, $s7, $k1               # col = grid_idx-offset
     li $v0, 1       
     move $a0, $s6                   #print_int  --- row
     syscall
     li $a0, ','
     li $v0, 11                      #print_char(',')
     syscall
     li $v0, 1       
     move $a0, $k0                   #print_int  --- col
     syscall
     li $a0, ' '
     li $v0, 11                      #print_char(' ')
     syscall
     li $a0, 'H'
     li $v0, 11                      #print_char('H')
     syscall
     li $a0, ' '
     li $v0, 11                      #print_char(' ')
     syscall
     
PRINT_WORD_LOOP_H:
     lb $t1, 0($a3)                    #get the first char of the word that needs to be printed
     li $v1, 0 
     addi $v1, $0, 10                  # newline \n
     beq  $t1, $v1, PRINT_NEWLINE_H    # if (*word=='\n') 
     move $a0, $t1
     li $v0, 11                        #print char
     syscall
     addi $a3, $a3, 1
     j PRINT_WORD_LOOP_H

PRINT_NEWLINE_H:          
      li $a0, '\n'
      li $v0, 11                     #print_char('\n')
      syscall
      
     li $s5, 1                       # at least one word was found in the string
     j VERTICAL
    
      
#------------------------------------------------------------------
#                       PRINT_D FUNCTION
#------------------------------------------------------------------ 
     
PRINT_D:
     sub $k0, $s7, $k1               # col = grid_idx-offset
     li $v0, 1       
     move $a0, $s6                   #print_int  --- row
     syscall
     li $a0, ','
     li $v0, 11                      #print_char(',')
     syscall
     li $v0, 1       
     move $a0, $k0                   #print_int  --- col
     syscall
     li $a0, ' '
     li $v0, 11                      #print_char(' ')
     syscall
     li $a0, 'D'
     li $v0, 11                      #print_char('D')
     syscall
     li $a0, ' '
     li $v0, 11                      #print_char(' ')
     syscall
         
PRINT_WORD_LOOP_D:
     lb $t1, 0($a3)                   #get the first char of the word that needs to be printed
     li $v1, 0 
     addi $v1, $0, 10                  # newline \n
     beq  $t1, $v1, PRINT_NEWLINE_D      # if (*word=='\n') 
     move $a0, $t1
     li $v0, 11                        #print char
     syscall
     addi $a3, $a3, 1
     j PRINT_WORD_LOOP_D

PRINT_NEWLINE_D:          
      li $a0, '\n'
      li $v0, 11                     #print_char('\n')
      syscall
      
     li $s5, 1                       # at least one word was found in the string
     j INC

TESTPRINT:
     bne $s5, $0, MAIN_END               # go back to the next row in the grid  
     li $v0, 1                           # print_string("-1\n") if no word was found
     li $a0, -1
     syscall
     li $a0, '\n'
     li $v0, 11                          #print_char('\n')
     syscall
     j MAIN_END

#------------------------------------------------------------------
#                         LENGTH FUNCTION
#------------------------------------------------------------------     


LENGTH:
       li $t4, 0                       # idx = 0
       li $s3, 0                       # num_cols
       li $s4, 0                       # num_rows
          
LENGTH_WHILE_LOOP:
        lb $t7, grid($t4)              # grid[idx]
        beq $t7, $0, END_LENGTH_WHILE_LOOP     # while grid[idx] != '\0'
        addi $v1, $0, 10    
        bne $t7, $v1, GO_TO_NEXT_COL   # if (grid[idx]=='\n')
        beq $s3, $0, SET_NUM_COLS     # if (num_cols == 0) 

INC_NUM_ROWS:
        addi $s4, $s4, 1               # increase the num_rows
        j GO_TO_NEXT_COL

SET_NUM_COLS:
        move $s3, $t4                  # set num_cols to idx  
        j INC_NUM_ROWS
         
GO_TO_NEXT_COL:
        addi $t4, $t4, 1
        j LENGTH_WHILE_LOOP
                          
END_LENGTH_WHILE_LOOP:  
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
