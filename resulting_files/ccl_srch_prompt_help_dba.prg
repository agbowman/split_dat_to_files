CREATE PROGRAM ccl_srch_prompt_help:dba
 FREE RECORD reply
 RECORD reply(
   1 fieldname = vc
   1 fieldsize = i4
   1 fieldlist[*]
     2 columnname = vc
     2 columnsize = i4
   1 errid = i4
   1 errmsg = vc
   1 qual[*]
     2 display_element = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET cnt = 0
 DECLARE stat = i4
 DECLARE promptcnt = i4
 DECLARE help_lookup = c1000
 DECLARE start_val = c30
 DECLARE nqual = i4
 DECLARE maxopt = c30
 DECLARE fieldsize = i4
 SET maxval = 100
 FREE RECORD promptrec
 RECORD promptrec(
   1 buf = vc
   1 fieldnames = vc
 )
 SET prgname = request->program_name
 SET testing = 1
 SET message = noinformation
 SET trace = nocost
 DECLARE errmsg = c255
 SET stat = error(errmsg,1)
 SET readreq = validate(request->help_lookup,"N")
 IF (readreq != "N")
  SET templookup = trim(request->help_lookup,3)
  IF (textlen(templookup) > 1)
   SET readreq = "Y"
   SET help_lookup = templookup
  ELSE
   SET readreq = "N"
  ENDIF
 ENDIF
 CALL echo(concat("ReadReq= ",readreq))
 IF (readreq="N")
  SELECT INTO "nl:"
   c.help_lookup, c.context_startval
   FROM ccl_prompt_help c
   WHERE c.program_name IN (cnvtlower(prgname), cnvtupper(prgname))
    AND (c.prompt_num=request->prompt_num)
    AND c.control_ind=3
    AND c.active_ind=1
   DETAIL
    help_lookup = cnvtupper(c.help_lookup), start_val = c.context_startval
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[0].operationname = "ccl_srch_prompt_help"
   SET reply->status_data.subeventstatus[0].operationstatus = "F"
   SET reply->status_data.subeventstatus[0].targetobjectname = curprog
   SET errmsg = build(concat("Record does not exist for Program= ",prgname,", prompt= "),request->
    prompt_num)
   GO TO exit_script
  ENDIF
 ENDIF
 SET cnt = 0
 IF (findstring("SELECT",cnvtupper(trim(help_lookup))))
  SET start_val = request->start_val
  SET maxopt = " "
  SET pos = findstring("WITH",help_lookup)
  IF (pos)
   SET withlen = (textlen(help_lookup) - pos)
   SET withopt = concat(" ",trim(substring(pos,withlen,help_lookup)),", maxrow= 1, reporthelp, check",
    trim(maxopt))
   SET help_lookup = substring(1,(pos - 1),help_lookup)
  ELSE
   SET withopt = concat(" WITH maxrow= 1, reporthelp, check ",trim(maxopt))
  ENDIF
  SET promptrec->buf = concat(check(trim(help_lookup))," head report"," stat = 0",
   " reply->fieldName = concat(reportinfo(1))"," reply->fieldSize = size(reply->fieldName)",
   " detail"," if (mod( cnt, 50 ) = 0)","  stat = alterlist(reply->qual,cnt + 50)"," endif",
   " cnt = cnt + 1",
   " reply->qual[cnt].display_element = reportinfo(2)"," foot report",
   " stat = alterlist(reply->qual,cnt)",withopt," go")
  IF (testing)
   CALL echo(concat("BUF= ",promptrec->buf))
  ENDIF
  CALL parser(promptrec->buf)
  SET stat = error(errmsg,0)
  IF (stat != 0)
   SET failed = "T"
   SET reply->errid = stat
   GO TO exit_script
  ENDIF
 ELSE
  SET start_val = request->start_val
  SET datetime = concat(format(curdate,"MMDD;;D"),"_",format(curtime,"HHMMSS;;M"))
  SET outfile = trim(concat("cer_temp:cclhlp",datetime,".dat"))
  SET isodbc = true
  SET helpbuf = fillstring(100," ")
  IF (textlen(trim(start_val)) > 0)
   SET helpbuf = concat("EXECUTE ",trim(help_lookup)," '",outfile,"', '",
    start_val,"'")
  ELSE
   SET helpbuf = concat("EXECUTE ",trim(help_lookup)," '",outfile,"'")
  ENDIF
  SET cmdbuf = concat(trim(helpbuf)," GO")
  IF (validate(testing,0))
   CALL echo(concat("OUTFILE= ",outfile))
   CALL echo(concat("COMMAND= ",cmdbuf))
  ENDIF
  CALL parser(cmdbuf)
  SET stat = error(errmsg,0)
  IF (stat != 0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
  FREE DEFINE rtl2
  SET logical file_loc value(outfile)
  DEFINE rtl2 "file_loc"
  SELECT INTO "nl:"
   r.*
   FROM rtl2t r
   HEAD REPORT
    cnt = 0, headerinit = 1
   DETAIL
    stat = alterlist(reply->qual,(cnt+ 50))
    IF (mod(cnt,50)=0)
     stat = alterlist(reply->qual,(cnt+ 50))
    ENDIF
    IF (headerinit=1)
     findpos = findstring("_",r.line)
     IF (findpos > 0)
      reply->fieldname = r.line
     ELSE
      reply->fieldname = "RESULTS", cnt += 1, reply->qual[cnt].display_element = r.line
     ENDIF
     headerinit = 0
    ELSE
     cnt += 1, reply->qual[cnt].display_element = r.line
    ENDIF
   FOOT REPORT
    reply->fieldsize = size(reply->fieldname), stat = alterlist(reply->qual,cnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET errmsg = " No records qualified for query!"
   SET failed = "T"
   SET reply->errid = stat
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->fieldlist,10)
 SET fieldnum = 1
 SET foundfield = 1
 SET fieldlen = 0
 SET i = 1
 WHILE ((i <= reply->fieldsize))
   SET nextchar = substring(i,1,reply->fieldname)
   IF (foundfield)
    SET fieldlen += 1
    IF (nextchar=" ")
     SET foundfield = 0
     SET reply->fieldlist[fieldnum].columnname = substring((i - fieldlen),fieldlen,reply->fieldname)
     CALL echo(concat(" Setting columnName= ",reply->fieldlist[fieldnum].columnname))
    ENDIF
   ELSE
    IF (nextchar=" ")
     SET fieldlen += 1
    ELSE
     SET reply->fieldlist[fieldnum].columnsize = fieldlen
     SET fieldnum += 1
     SET fieldlen = 0
     SET foundfield = 1
    ENDIF
   ENDIF
   SET i += 1
 ENDWHILE
 IF (foundfield)
  SET i -= 1
  SET reply->fieldlist[fieldnum].columnname = substring((i - fieldlen),(fieldlen+ 1),reply->fieldname
   )
  SET reply->fieldlist[fieldnum].columnsize = fieldlen
  CALL echo(concat(" foundField TRUE: Setting columnName= ",reply->fieldlist[fieldnum].columnname))
 ELSE
  SET fieldnum -= 1
 ENDIF
 SET stat = alterlist(reply->fieldlist,fieldnum)
 IF (testing)
  CALL echo(build(concat(" Run help for Progam= ",prgname,", prompt_num= "),request->prompt_num))
  CALL echo(concat(" Fieldname  : ",substring(1,100,reply->fieldname)),1,0)
  CALL echo(concat(" Fieldsize  : ",build(reply->fieldsize)),1,0)
  CALL echo("",1,0)
  FOR (x = 1 TO fieldnum)
    CALL echo(build("Field# ",x,concat(", = ",reply->fieldlist[x].columnname),", Size= ",reply->
      fieldlist[x].columnsize))
  ENDFOR
  CALL echo(concat(" Number values returned for prompt: ",build(cnt)),1,0)
  IF (cnt > 0)
   SET nqual = size(reply->qual,5)
   IF (nqual > 10)
    SET nqual = 10
    CALL echo("First 10: ")
   ENDIF
   FOR (x = 1 TO nqual)
     CALL echo(concat(" Reply->qual[",build(x),"].display_element:",reply->qual[x].display_element),1,
      0)
   ENDFOR
   SET nqual = size(reply->qual,5)
   IF (nqual >= 20)
    CALL echo("Last 10: ")
    FOR (x = (nqual - 9) TO nqual)
      CALL echo(concat(" Reply->qual[",build(x),"].display_element:",reply->qual[x].display_element),
       1,0)
    ENDFOR
   ENDIF
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->errmsg = errmsg
  SET reply->status_data.subeventstatus[0].operationname = "srch prompt help"
  SET reply->status_data.subeventstatus[0].operationstatus = "F"
  SET reply->status_data.subeventstatus[0].targetobjectname = curprog
  SET reply->status_data.subeventstatus[0].targetobjectvalue = errmsg
  CALL echo(concat("Status= Failed  ",errmsg))
 ELSE
  SET reply->status_data.status = "S"
  CALL echo("Status= S")
 ENDIF
#endit
 IF ((reply->errid != 0))
  CALL echo(concat(" Errid      : ",build(reply->errid)),1,0)
  CALL echo(concat(" Errmsg     : ",substring(1,100,reply->errmsg)),1,0)
 ENDIF
END GO
