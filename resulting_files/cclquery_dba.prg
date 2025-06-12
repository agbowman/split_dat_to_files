CREATE PROGRAM cclquery:dba
 PROMPT
  "Enter output name for report  (MINE): " = "MINE",
  "Enter program name                (): " = "X",
  "Show index columns for plan(Y/N) (N): " = "N"
 DECLARE progname = c31
 DECLARE groupname = c12
 DECLARE rptname = c80
 DECLARE _tmpfile = vc
 DECLARE err_msg[5] = c130
 DECLARE err_stat = i4
 DECLARE err_cnt = i4
 DECLARE cclquery_stat = i4
 DECLARE gpos = i2
 DELETE  FROM plan_table p
  WHERE p.statement_id=patstring(concat(trim(curuser),":*"))
  WITH nocounter
 ;end delete
 COMMIT
 SET gpos = findstring(":", $2)
 IF (gpos > 0)
  SET progname = substring(1,(gpos - 1),cnvtupper( $2))
  SET groupname = substring((gpos+ 1),31,cnvtupper( $2))
 ELSE
  SET progname = cnvtupper( $2)
  SET groupname = " "
 ENDIF
 SET _wildcard = findstring("*",progname)
 IF (size(trim(progname)) > 25)
  SET rptname = concat("cclquery",curuser)
 ELSEIF (_wildcard > 0)
  SET rptname = concat(substring(1,(_wildcard - 1),trim(cnvtlower(progname))),"xxx")
 ELSE
  SET rptname = trim(cnvtlower(progname))
 ENDIF
 SET cclquery_stat = 0
 SET begin_load_time = cnvtdatetime(sysdate)
 EXECUTE cclquery2 value(progname)
 SET err_cnt = 0
 SET err_stat = 1
 WHILE (err_stat != 0
  AND err_cnt < 5)
  SET err_cnt += 1
  SET err_stat = error(err_msg[err_cnt],0)
 ENDWHILE
 SET err_cnt -= 1
 FREE DEFINE rtl
 EXECUTE cclsize3 build(rptname,".tmp2"), trim(progname)
 FREE DEFINE rtl
 DEFINE rtl build(rptname,".tmp2")
 SELECT INTO build(rptname,".out")
  FROM rtlt r
  HEAD REPORT
   "CCLQUERY reports (1:Ccl size) (2:Oracle plan) (3:Sql area) (4:Translate with query source)", row
    + 1, ">>>PARSER or VALIDATE functions will not be evaluated by cclquery",
   row + 1, ">>>Avoid using variable of same name as column name for single table query", row + 1,
   row + 1
  DETAIL
   r.line, row + 1
  WITH format = variable, maxrow = 1, maxcol = 140,
   noformfeed, nocounter
 ;end select
 FREE DEFINE rtl
 IF (cclquery_stat=1)
  SET message = window
  IF (curbatch=0)
   CALL text(1,1,"Wait while fetching from ccloraplan...                                          ")
  ENDIF
  IF (cnvtupper( $3)="Y")
   EXECUTE ccloraplan build(rptname,".tmp2"), "S", patstring(concat(trim(curuser),"*"))
  ELSE
   EXECUTE ccloraplan build(rptname,".tmp2"), "Z", patstring(concat(trim(curuser),"*"))
  ENDIF
  IF (curqual)
   SET _tmpfile = build(rptname,".tmp2")
   IF (findfile(_tmpfile))
    FREE DEFINE rtl
    DEFINE rtl build(rptname,".tmp2")
    SELECT INTO build(rptname,".out")
     r.line
     FROM rtlt r
     WHERE r.line != " "
     HEAD REPORT
      "CCLQUERY errors=", err_cnt"#", row + 1
      WHILE (err_cnt > 0)
        err_msg[err_cnt], row + 1, err_cnt -= 1
      ENDWHILE
     DETAIL
      r.line, row + 1
     FOOT REPORT
      CALL print(char(12))
     WITH format = variable, maxrow = 1, maxcol = 140,
      noformfeed, append, nocounter
    ;end select
    FREE DEFINE rtl
   ENDIF
  ELSE
   SELECT INTO build(rptname,".out")
    FROM dummyt
    HEAD REPORT
     "CCLQUERY errors=", err_cnt"#", row + 1
     WHILE (err_cnt > 0)
       err_msg[err_cnt], row + 1, err_cnt -= 1
     ENDWHILE
    FOOT REPORT
     CALL print(char(12))
    WITH format = variable, maxrow = 1, maxcol = 140,
     noformfeed, append, nocounter
   ;end select
  ENDIF
  IF (curqual
   AND cnvtupper( $3)="Y")
   IF (curbatch=0)
    CALL text(1,1,"Wait while fetching from cclsqlarea...                                          ")
   ENDIF
   EXECUTE cclsqlarea2 build(rptname,".tmp2"), value(concat("_",trim(progname))), 0,
   "T", format(begin_load_time,"yyyy-mm-dd/hh:mm:ss;3;q")
   SET _tmpfile = build(rptname,".tmp2")
   IF (curqual
    AND findfile(_tmpfile))
    FREE DEFINE rtl
    DEFINE rtl build(rptname,".tmp2")
    SELECT INTO build(rptname,".out")
     r.line
     FROM rtlt r
     WHERE r.line != " "
     DETAIL
      r.line, row + 1
     FOOT REPORT
      CALL print(char(12))
     WITH format = variable, maxrow = 1, maxcol = 140,
      noformfeed, append, nocounter
    ;end select
    FREE DEFINE rtl
   ENDIF
  ENDIF
  ROLLBACK
 ENDIF
 SET _tmpfile = build(rptname,".tmp")
 IF (findfile(_tmpfile))
  FREE DEFINE rtl
  DEFINE rtl _tmpfile
  SELECT INTO build(rptname,".out")
   r.line
   FROM rtlt r
   HEAD REPORT
    rcnt = 0
   DETAIL
    rcnt += 1, rcnt"#####", ")",
    r.line, row + 1
   WITH format = variable, maxrow = 1, maxcol = 140,
    noformfeed, append, nocounter
  ;end select
  FREE DEFINE rtl
 ELSE
  CALL echo(concat("Findfile failed for: ",_tmpfile))
 ENDIF
 SET message = nowindow
 DEFINE rtl build(rptname,".out")
 SELECT INTO trim( $1)
  cclquery = r.line
  FROM rtlt r
  DETAIL
   cclquery, row + 1
  WITH nocounter, noformfeed, maxrow = 1,
   maxcol = 133
 ;end select
 FREE DEFINE rtl
 SET stat = 1
 WHILE (stat)
   SET stat = remove(build(rptname,".out"))
   SET stat = remove(build(rptname,".tmp"))
   SET stat = remove(build(rptname,".tmp2"))
 ENDWHILE
END GO
