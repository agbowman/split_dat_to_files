CREATE PROGRAM ccltimeload:dba
 PROMPT
  "Enter program in uppercase to time load: " = " ",
  "Enter number of times to load: " = 1
 FOR (cnt = 1 TO  $2)
   TRANSLATE   $1  WITH load
 ENDFOR
END GO
