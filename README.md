# PuzzleSolver
\
The
first input is a dictionary file, which consists of English words in lowercase alphabetic
characters (
a-z
) delimited by a newline (
\\
n
) and terminated by End-Of-File (EOF). 
\
\
A
valid dictionary does not include any other characters.  The second input is the puzzle
grid, which in this task is just a single-line string of alphabetic characters (
a-z
) in any
order and combination.  The grid file is terminated by a newline (
\\
n
) followed by End-
Of-File (EOF). 
A valid grid file does not include any other characters. 
\
\
 The output of 1dstrfind
is the index of an occurrence of a dictionary word in the
grid
string followed by the
matching word on each line of the output or
-1
if no word in
dictionary
matches.
\
\
The 2dstrfind files read the
2dgrid.txt
and store its content into a null-
terminated string named
grid
.  They also read a dictionary file named
dictionary.txt
and store its content into a null-terminated string named
dictionary
. 
The programme looks for horizontal. vertical and diagonal matches in the 2dgrid.
\
\
A word is said to be horizontally matched if all characters match inside a row without
wrap-around.  The direction of a horizontal match must be from
left
to
right
. 
\
\
A word is said to be vertically matched if all characters match
within a column in the
downward
direction and without wrap-around.
\
\
 A word is said to be diagonally matched
if  all  characters  match  along  a  diagonal.   A  valid  diagonal  match  extends  from  left
to  right  in  the  downward  direction.
\
\
The program will
output x,y coordinates of the first letter of an occurrence of a dictionary word in
the
grid
followed by letter ‘H’, ‘V’or ‘D’(for horizontal, vertical and diagonal matches,
respectively)  and  followed  by  the  matching  word  per  line  of  the  output  or
-1
if  no
dictionary word is present in
grid
.
\
\
Similarly, for wrap-around, the programme will
find all matching words, including
matches that wrap around the grid horizontally, vertically or diagonally.  Your program
must output x,y coordinates of the first letter of an occurrence of a dictionary word in
the
grid
followed by letter ‘H’, ‘V’or ‘D’(for horizontal, vertical and diagonal matches,
respectively)  and  followed  by  the  matching  word  per  line  of  the  output  or
-1
if  no
dictionary word is present in
grid
.
\
\
Specifications:
\
•
A dictionary file may contain a maximum of 1000 words.
\
•
A  single  word  in  the  dictionary  file  may  contain  a  maximum  of  10  alphabetic
characters.  All characters are lowercase.
\
•
All grid coordinates start at 0.  The maximum grid coordinate in any dimension
(x, y) is 31.
\
•
A grid file may contain only lower-case alphabetic characters (
a-z
).
