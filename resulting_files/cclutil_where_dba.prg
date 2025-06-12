CREATE PROGRAM cclutil_where:dba
 PROMPT
  "OutputFile                        : " = "MINE",
  "Enter Name of Objects to Search   : " = "CCL*",
  "Select Object Type (E,P)          : " = "P",
  "Select Sort Mode for Output (0-3) : " = 0,
  "Select Type of Search to Perform  : " = "",
  "Enter String to Search For        : " = "*"
  WITH outdev, objectname, objecttype,
  sortmode, wheretype, wherename
 CALL echo(
  ">>>WhereSort: 0(none) 1(PrgName,WhereType,WhereName) 2(WhereType,WhereName,PrgName) 3(WhereName,WhereType,PrgName)"
  )
 CALL echo(">>>WhereType: TABLE, PROGRAM, DECLARESUB, DECLAREUAR, CALLUAR, CUSTOM, CUSTOM2")
 DECLARE where_type_var = vc WITH protect, noconstant(cnvtupper( $5))
 RECORD rec1(
   1 qual[*]
     2 objectname = vc
     2 objecttype = c1
     2 objectgroup = i1
 )
 SET message = noinformation
 SET modify = recordalter
 DECLARE tmpfilename = vc WITH noconstant(build(cnvtlower(curprcname),"__.tmp"))
 SET cnt = 0
 SELECT INTO nl
  d.object, d.object_name
  FROM dprotect d
  WHERE d.object_name=patstring(cnvtupper( $2))
   AND d.object=cnvtupper( $3)
   AND d.group=0
  DETAIL
   cnt += 1, rec1->qual[cnt].objectname = d.object_name, rec1->qual[cnt].objecttype = d.object
  WITH counter
 ;end select
 CALL echo(build("PrgCnt=",cnt))
 IF (cnt=0)
  SELECT INTO  $1
   o_type_se = evaluate(cnvtupper( $3),"E","EKModules","Programs"), prog_name_se = concat('"',
    cnvtupper(trim( $2,7)),'"')
   FROM dummyt
   DETAIL
    col 0, "No Group0/DBA", col + 1,
    o_type_se, col + 1, "with names that match",
    col + 1, prog_name_se, col + 1,
    "were found.", row + 1
   WITH nocounter
  ;end select
  RETURN
 ENDIF
 FOR (num = 1 TO cnt)
  IF (mod(num,100)=0)
   CALL echo(build(num,":",cnt))
  ENDIF
  EXECUTE cclutil_where1:dba value(tmpfilename), rec1->qual[num].objectname, rec1->qual[num].
  objecttype,
  num, where_type_var,  $6
 ENDFOR
 IF (findfile(value(tmpfilename)) != 1)
  SELECT INTO  $1
   o_type_se = evaluate(cnvtupper( $3),"E","EKModules","Programs"), prog_name_se = concat('"',
    cnvtupper(trim( $2,7)),'"'), where_name_se = concat('"',trim( $6,7),'"')
   FROM dummyt
   DETAIL
    col 0, "No", col + 1,
    where_type_var, col + 1, "usage of",
    col + 1, where_name_se, col + 1,
    "found in", col + 1, o_type_se,
    col + 1, "with names that match", col + 1,
    prog_name_se, row + 1
  ;end select
 ELSE
  DEFINE rtl value(tmpfilename)
  SELECT
   IF (( $4=1))
    ORDER BY prgname, wheretype, wherename
   ELSEIF (( $4=2))
    ORDER BY wheretype, wherename, prgname
   ELSEIF (( $4=3))
    ORDER BY wherename, wheretype, prgname
   ELSE
   ENDIF
   INTO  $1
   prgname = substring(1,40,r.line), wheretype = substring(41,15,r.line), wherename = substring(56,70,
    r.line)
   FROM rtlt r
   WHERE substring(41,15,r.line)=where_type_var
    AND (substring(56,70,r.line)= $6)
   HEAD REPORT
    detail_cnt = 0, col 0, "PrgName",
    col 41, "WhereType", col 56,
    "WhereName", row + 1
   DETAIL
    detail_cnt += 1, col 0, prgname,
    col 41, wheretype, col 56,
    wherename, row + 1
   FOOT REPORT
    IF (detail_cnt=0)
     row + 1, col 0, "No matches found",
     row + 1
    ENDIF
   WITH format, separator = " ", nullreport
  ;end select
 ENDIF
 FREE DEFINE rtl
 SET stat = remove(value(tmpfilename))
 SET message = information
END GO
