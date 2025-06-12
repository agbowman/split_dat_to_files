CREATE PROGRAM codecache_getallactive:dba
 RECORD reply(
   1 codesetlist[*]
     2 codeset = i4
     2 codevaluelist[*]
       3 codevalue = f8
       3 display = vc
 )
 DECLARE totalvalues = i4 WITH noconstant(0)
 DECLARE valuecap = i4 WITH noconstant(0)
 DECLARE valuesize = i4 WITH noconstant(0)
 DECLARE setcap = i4 WITH noconstant(0)
 DECLARE setsize = i4 WITH noconstant(0)
 DECLARE max_list = i4 WITH constant(65535)
 SELECT INTO "nl:"
  FROM code_value cv,
   code_value_set cvs
  PLAN (cv
   WHERE cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (cvs
   WHERE cvs.code_set=cv.code_set)
  ORDER BY cv.code_set
  HEAD cv.code_set
   valuecap = 0, valuesize = 0
   IF (setcap=setsize)
    IF (setcap=0)
     setcap = 16
    ELSE
     setcap = (setcap * 2)
    ENDIF
    stat = alterlist(reply->codesetlist,setcap)
   ENDIF
   setsize = (setsize+ 1), reply->codesetlist[setsize].codeset = cv.code_set
  DETAIL
   IF (valuesize=valuecap)
    IF (valuecap=0)
     valuecap = 16
    ELSE
     valuecap = (valuecap * 2)
    ENDIF
    stat = alterlist(reply->codesetlist[setsize].codevaluelist,valuecap)
   ENDIF
   valuesize = (valuesize+ 1)
   IF (valuesize <= max_list)
    reply->codesetlist[setsize].codevaluelist[valuesize].codevalue = cv.code_value, reply->
    codesetlist[setsize].codevaluelist[valuesize].display = cv.display
   ENDIF
  FOOT  cv.code_set
   IF (valuesize > max_list)
    stat = alterlist(reply->codesetlist[setsize].codevaluelist,0)
   ELSE
    IF (valuesize < valuecap)
     stat = alterlist(reply->codesetlist[setsize].codevaluelist,valuesize)
    ENDIF
    totalvalues = (totalvalues+ valuesize)
   ENDIF
  WITH nocounter
 ;end select
 IF (setsize < setcap)
  SET stat = alterlist(reply->codesetlist,setsize)
 ENDIF
 CALL echo(build("total values returned:",totalvalues))
END GO
