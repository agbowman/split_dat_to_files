CREATE PROGRAM ccloradef3:dba
 PROMPT
  "(S)ystem, (U)ser : " = " ",
  "Table_name       : " = " "
 CASE (cnvtupper( $1))
  OF "S":
   EXECUTE ccloradef "MINE", "Y", 55000,
   "V500", "*",  $2,
   "SYS*"
  OF "U":
   EXECUTE ccloradef "MINE", "N", 55000,
   "V500", "*",  $2,
   "V500"
 ENDCASE
END GO
