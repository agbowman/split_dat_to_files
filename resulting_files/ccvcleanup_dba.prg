CREATE PROGRAM ccvcleanup:dba
 PROMPT
  "ENTER COPYBOOK NAME: " = " ",
  "ENTER OUTPUT NAME: " = "MINE"
 FREE DEFINE rtl
 DEFINE rtl  $1
 SELECT INTO  $2
  dline = r.line
  FROM rtlt r
  HEAD REPORT
   cnt = 1
  DETAIL
   IF (dline=";*&*SOURCE:*")
    dline, row + 1, cnt = 0
   ELSEIF (cnt=0)
    IF (substring(1,1,dline) != ";")
     cnt = 1
    ENDIF
   ELSEIF (cnt=1)
    dline, row + 1
   ENDIF
  WITH maxcol = 133, format = variable
 ;end select
 FREE DEFINE rtl
END GO
