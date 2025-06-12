CREATE PROGRAM cdocview:dba
 PROMPT
  "Enter MINE/CRT/printer/file: " = mine,
  "Enter C MODULE NAME:         " = "*"
 DEFINE rtl  $2
 SELECT INTO  $1
  doc = substring(5,100,rtlt.line)
  FROM rtlt
  WHERE rtlt.line="\*\* *"
  HEAD REPORT
   found = 0
  DETAIL
   IF (found=1)
    IF (doc="DESCRIPTION:*")
     BREAK
    ENDIF
    doc, row + 1
   ELSEIF (doc="*MOD*")
    found = 1
   ENDIF
  WITH maxcol = 101
 ;end select
 FREE DEFINE rtl
END GO
