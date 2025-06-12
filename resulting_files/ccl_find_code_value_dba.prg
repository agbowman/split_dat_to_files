CREATE PROGRAM ccl_find_code_value:dba
 PROMPT
  "Enter program prefix to search or * : " = "*",
  "Echo out program names for progress N/Y: " = "N"
 SET search_name = cnvtupper( $1)
 SET echo_progress = cnvtupper( $2)
 RECORD rec(
   1 cnt = i4
   1 qual[*]
     2 name = c31
 )
 SET stat = remove("ccl_find_code_value.ccl")
 SET rec->cnt = 0
 SELECT INTO "nl:"
  d.object_name, d.object
  FROM dprotect d
  WHERE d.object="P"
   AND d.object_name=patstring(search_name)
   AND d.group=0
  DETAIL
   rec->cnt += 1, stat = alterlist(rec->qual,rec->cnt), rec->qual[rec->cnt].name = d.object_name
  WITH counter
 ;end select
 FOR (num = 1 TO rec->cnt)
  IF (mod(num,2000)=0)
   CALL echo(num)
   IF (echo_progress="Y")
    CALL echo(rec->qual[num].name)
   ENDIF
  ENDIF
  IF (num > 15000)
   EXECUTE ccl_find_code_value2 value(rec->qual[num].name)
  ELSE
   TRANSLATE INTO ccl_find_code_value value(rec->qual[num].name)  WITH check, append
  ENDIF
 ENDFOR
 FREE DEFINE rtl
 DEFINE rtl "ccl_find_code_value.ccl"
 SELECT
  prog = substring(1,30,r.line)
  FROM rtlt r
  WHERE substring(31,30,r.line)=":CODE_VALUE"
  HEAD REPORT
   "Report showing programs which reference CODE_VALUE table in query", row + 1, "Program Name",
   row + 1, "==============================", row + 1
  HEAD prog
   prog, row + 1
  WITH nocounter, maxrow = 1, maxcol = 80,
   noformfeed
 ;end select
 FREE DEFINE rtl
END GO
