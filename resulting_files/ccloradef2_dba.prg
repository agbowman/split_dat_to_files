CREATE PROGRAM ccloradef2:dba
 PROMPT
  "(S)ystem, (U)ser : " = " "
 CASE (cnvtupper( $1))
  OF "S":
   EXECUTE ccloradef "FDORACLESYSTEM.DEF", "Y", 8000,
   "V500", "*", "*",
   "SYS*"
  OF "U":
   EXECUTE ccloradef "FDORACLEUSER.DEF", "N", 55000,
   "V500", "*", "*",
   "V500"
  OF "A":
   EXECUTE ccloradef "FDORACLEALL.DEF", "N", 55000,
   "V500", "*", "*",
   "*"
 ENDCASE
END GO
