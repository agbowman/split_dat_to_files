CREATE PROGRAM bhs_sys_rad_expedite_audit
 DECLARE filename = vc
 DECLARE cpline = vc
 DECLARE dclcom = vc
 DECLARE pname = vc
 DECLARE ms_path = vc WITH protect, noconstant("")
 FREE RECORD temp
 RECORD temp(
   1 cnt = i4
   1 qual[*]
     2 line = vc
     2 pid = vc
     2 name = vc
 )
 SET filename = build("expedites",format(month((curdate - 1)),"##;p0"),format(day((curdate - 1)),
   "##;p0"),".log")
 CALL echo(filename)
 SET ms_path = replace(trim(logical("ccluserdir"),3),"ccluserdir","temp/",0)
 SET cpline = concat("cp ",ms_path,filename," ",trim(logical("ccluserdir"),3),
  "/",filename)
 CALL echo(cpline)
 SET dclcom = cpline
 SET len = size(trim(dclcom))
 SET status = 0
 CALL dcl(dclcom,len,status)
 IF (status > 0)
  CALL echo("file copied")
 ELSE
  CALL echo("Copy failed")
 ENDIF
 IF (findfile(filename) > 0)
  CALL echo("Found the file")
 ELSE
  CALL echo("Did not find the file")
 ENDIF
 CALL parser(concat('set logical mylogical "ccluserdir:',filename,'" go'))
 FREE DEFINE rtl2
 DEFINE rtl2 "mylogical"
 SELECT INTO "nl:"
  FROM rtl2t t
  HEAD REPORT
   pid = 0, loc = 0
  DETAIL
   loc = 0, pid = 0
   IF (trim(t.line,3) IN ("RadNet Order/Consult (copy to) for provider*", "Reason - physician*"))
    IF (trim(t.line,3)="RadNet Order/Consult (copy to) for provider*")
     loc = 0, pid = 0, loc = textlen("RadNet Order/Consult (copy to) for provider"),
     personid = substring(45,100,t.line)
    ENDIF
    IF (trim(t.line,3)="Reason - physician*")
     temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].line
      = trim(t.line,3),
     temp->qual[temp->cnt].pid = personid
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(temp->cnt)),
   prsnl p
  PLAN (d)
   JOIN (p
   WHERE p.person_id=cnvtint(temp->qual[d.seq].pid))
  DETAIL
   temp->qual[d.seq].name = p.name_full_formatted
  WITH nocounter
 ;end select
 CALL echorecord(temp)
 DECLARE fexp = vc
 SET fexp = build(curnode,"_failedexp.log")
 SELECT INTO value(fexp)
  line = build(temp->qual[d.seq].line,":",temp->qual[d.seq].name)
  FROM (dummyt d  WITH seq = value(temp->cnt))
  PLAN (d
   WHERE d.seq > 0)
  WITH nocounter
 ;end select
 EXECUTE bhs_ma_email_file
 CALL emailfile(filename,filename,"naser.sanjar@bhs.org","Radiology Expedites",1)
 CALL emailfile(fexp,fexp,"naser.sanjar@bhs.org","Radiology Failed Expedites",1)
END GO
