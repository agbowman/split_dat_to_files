CREATE PROGRAM ccllibsearch:dba
 PROMPT
  "Enter shared library name    : " = " ",
  "Enter routine name to search : " = "*"
 IF (( $1=" "))
  CASE (cursys)
   OF "AXP":
    SET libname = "cer_exe:shrccluar.exe"
   OF "WIN":
    SET libname = "cer_exe:libshrccluar"
   OF "AIX":
    SET libname = "cer_exe:libshrccluar"
  ENDCASE
 ENDIF
 DEFINE rtl trim(libname)
 SELECT
  *
  FROM rtlt
  WHERE (cnvtupper(line)= $2)
  WITH check
 ;end select
 FREE DEFINE rtl
END GO
