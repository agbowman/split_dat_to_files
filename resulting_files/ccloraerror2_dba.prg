CREATE PROGRAM ccloraerror2:dba
 PROMPT
  "Enter Rdbms error number : " = 0,
  "Output Name : " = "MINE"
 FREE DEFINE rtl
 IF (cursys="AXP")
  SET logical "ORAERRDIR" value("ora_root:[rdbms]")
  SET logical "ORAERRDIR2" value("ora_root:[rdbms.mesg]")
  IF (findfile("oraerrdir:oraus.msg"))
   DEFINE rtl "oraerrdir:oraus.msg"
  ELSEIF (findfile("oraerrdir2:oraus.msg"))
   DEFINE rtl "oraerrdir2:oraus.msg"
  ELSEIF (findfile("oraerrdir2:eror.msg"))
   DEFINE rtl "oraerrdir:error.msg"
  ELSE
   RETURN
  ENDIF
 ELSE
  SET logical "ORAERRDIR" value(build(logical("ORACLE_HOME"),"/rdbms/mesg"))
  IF (findfile("oraerrdir:oraus.msg"))
   DEFINE rtl "oraerrdir:oraus.msg"
  ELSEIF (findfile("oraerrdir:error.msg"))
   DEFINE rtl "oraerrdir:error.msg"
  ELSE
   RETURN
  ENDIF
 ENDIF
 IF (( $1=0))
  SELECT INTO  $2
   ora_error = r.line
   FROM rtlt r
   WHERE ((r.line="//*") OR (r.line="?????, *"))
   WITH counter, format
  ;end select
 ELSE
  SET errnum = format( $1,"#####;rp0")
  SELECT INTO  $2
   r.line
   FROM rtlt r
   WHERE ((r.line="//*") OR (r.line="?????, *"))
   HEAD REPORT
    fnd = 0
   DETAIL
    CASE (fnd)
     OF 0:
      IF (r.line=patstring(concat(errnum,", *")))
       r.line, row + 1, fnd = 1
      ENDIF
     OF 1:
      IF (r.line="//*")
       r.line, row + 1
      ELSE
       fnd = 2
      ENDIF
     OF 2:
      fnd = 2
    ENDCASE
   WITH counter, maxcol = 135
  ;end select
 ENDIF
 FREE DEFINE rtl
END GO
