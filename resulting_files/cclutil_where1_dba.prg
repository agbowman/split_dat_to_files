CREATE PROGRAM cclutil_where1:dba
 PROMPT
  "OutputFile:" = "jcm",
  "ObjectName:" = "JCM",
  "ObjectType:" = "P",
  "AppendMode:" = 1,
  "WhereType: " = "*",
  "Wherename: " = "*"
 DECLARE pname = vc WITH protect, noconstant(cnvtupper( $2))
 DECLARE oname1 = vc WITH protect, noconstant(build(cnvtlower(curprcname),"__1.out"))
 DECLARE oname2 = vc WITH protect, noconstant(build(cnvtlower(curprcname),"__2.out"))
 DECLARE errmsg = c255 WITH protect
 DECLARE estat = i4 WITH protect
 IF (( $5="CUSTOM2"))
  CASE (cnvtupper( $3))
   OF "E":
    TRANSLATE INTO value(oname1) EKMODULE value(pname):dba
   OF "P":
    TRANSLATE INTO value(oname1) PROGRAM value(pname):dba
  ENDCASE
 ELSE
  CASE (cnvtupper( $3))
   OF "E":
    TRANSLATE INTO value(oname1) EKMODULE value(pname):dba  WITH xml
   OF "P":
    TRANSLATE INTO value(oname1) PROGRAM value(pname):dba  WITH xml
  ENDCASE
 ENDIF
 SET estat = error(errmsg,1)
 IF (estat != 0)
  RETURN
 ENDIF
 FREE DEFINE rtl
 DEFINE rtl value(oname1)
 DECLARE state_name = vc
 DECLARE object_name = vc
 DECLARE result_qual = i4 WITH noconstant(0)
 SELECT INTO value(oname2)
  r.line
  FROM rtlt r
  HEAD REPORT
   state = 1, state2 = 0, posend = 0,
   pos = 0, pos2 = 0, skip = 0
  DETAIL
   CASE (state)
    OF 1:
     IF (state=1)
      pos = findstring("<TABLE.",r.line)
      IF (pos > 0)
       state = 2, state_name = "TABLE"
      ENDIF
     ENDIF
     ,
     IF (state=1)
      pos = findstring("<Z_EXECUTE.",r.line)
      IF (pos > 0)
       state = 3, state_name = "PROGRAM"
      ENDIF
     ENDIF
     ,
     IF (state=1)
      pos = findstring("<CALL.",r.line)
      IF (pos > 0)
       state = 4, state_name = "CALL"
      ENDIF
     ENDIF
     ,
     IF (state=1)
      pos = findstring("<Z_DECLARE.",r.line)
      IF (pos > 0)
       state = 5, state_name = "DECLARE"
      ENDIF
     ENDIF
     ,
     IF (state=1
      AND ( $5="CUSTOM*"))
      IF ((r.line= $6))
       state = 999, state_name =  $5
      ENDIF
     ENDIF
    OF 2:
     pos = findstring("</TABLE.",r.line),
     IF (pos > 0)
      state = 1
     ENDIF
    OF 3:
     pos = findstring("</Z_EXECUTE.",r.line),
     IF (pos > 0)
      state = 1
     ENDIF
    OF 4:
     pos = findstring("</Z_CALL.",r.line),
     IF (pos > 0)
      state = 1
     ENDIF
    OF 5:
     pos = findstring("<CALL.",r.line),
     IF (pos > 0)
      state = 6
     ELSE
      state = 7
     ENDIF
    OF 6:
     pos = findstring("</Z_DECLARE.",r.line),
     IF (pos > 0)
      state = 1
     ENDIF
    OF 7:
     pos = findstring("</Z_DECLARE.",r.line),
     IF (pos > 0)
      state = 1
     ENDIF
   ENDCASE
   IF (state=999)
    object_name = trim(substring(1,70,r.line),2), col 0, pname,
    col 40, state_name, col 55,
    object_name, row + 1, result_qual = 1,
    state = 1
   ELSEIF (state IN (2, 3, 4, 6))
    pos = findstring("<NAMESPACE.",r.line)
    IF (pos > 0)
     skip = 1, pos = 0
    ELSE
     pos = findstring("<NAME",r.line)
    ENDIF
    IF (skip=1
     AND pos > 0)
     skip = 0, pos = 0
    ENDIF
    IF (pos > 0)
     pos = findstring("text=",r.line,1), state2 = 0
     IF (pos > 0)
      pos2 = findstring(substring((pos+ 5),1,r.line),r.line,(pos+ 7)), object_name = substring((pos+
       6),(pos2 - (pos+ 6)),r.line)
      CASE (state)
       OF 4:
        IF (object_name="UAR_*")
         state_name = "CALLUAR", state2 = state
        ENDIF
       OF 6:
        IF (object_name="UAR_*")
         state_name = "DECLAREUAR"
        ELSE
         state_name = "DECLARESUB"
        ENDIF
        ,state2 = state
       ELSE
        state2 = state
      ENDCASE
      IF (state2 > 1)
       col 0, pname, col 40,
       state_name, col 55, object_name,
       row + 1, result_qual = 1
      ENDIF
      state = 1
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter, noformfeed, maxrow = 1,
   noheading
 ;end select
 FREE DEFINE rtl
 IF (result_qual=1)
  DEFINE rtl value(oname2)
  SELECT
   IF (( $4=1))
    WITH noheading, nocounter
   ELSE
   ENDIF
   DISTINCT INTO  $1
   result = substring(1,130,r.line)
   FROM rtlt r
   WHERE r.line != " "
   ORDER BY r.line
   WITH noheading, append, nocounter
  ;end select
  FREE DEFINE rtl
 ENDIF
 SET stat = remove(value(oname1))
 SET stat = remove(value(oname2))
END GO
