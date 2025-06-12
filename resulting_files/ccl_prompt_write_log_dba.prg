CREATE PROGRAM ccl_prompt_write_log:dba
 PROMPT
  "log msg" = ""
  WITH msg
 IF (_debugflag=1)
  SELECT INTO value(_logfilename)
   d.*
   FROM (dummyt d  WITH seq = 1)
   DETAIL
    FOR (i = 1 TO size( $MSG) BY 100)
      txt = substring(i,100, $MSG), col 0, txt,
      " <", row + 1
    ENDFOR
    row + 1
   WITH nocounter, maxcol = 500, append
  ;end select
 ENDIF
END GO
