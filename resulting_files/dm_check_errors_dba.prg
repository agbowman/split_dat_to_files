CREATE PROGRAM dm_check_errors:dba
 IF (msg != fillstring(255," ")
  AND error_reported=0)
  SET error_reported = 1
  IF (rstring > "")
   CALL parser(rstring,1)
  ENDIF
  IF (rstring1 > "")
   CALL parser(rstring1,1)
  ENDIF
  SELECT INTO value(filename3)
   *
   FROM dual
   DETAIL
    "Error = ", error_msg, row + 1,
    msg, row + 1, row + 1
   WITH format = stream, noheading, formfeed = none,
    maxcol = 512, maxrow = 1, append
  ;end select
 ENDIF
END GO
