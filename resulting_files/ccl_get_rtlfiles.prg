CREATE PROGRAM ccl_get_rtlfiles
 PROMPT
  "Output to File/Printer/MINE:" = "MINE"
  WITH outdev
 RECORD reply(
   1 data[*]
     2 buffer = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE p_server = i2 WITH constant(request->servernum), public
 DECLARE p_type = vc WITH constant(request->logtype), public
 DECLARE p_host = vc WITH constant(request->hostname), public
 DECLARE com = vc
 DECLARE _fname = vc WITH constant(cnvtlower(build(curuser,p_type,".out")))
 DECLARE count = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 CASE (p_type)
  OF "RTL":
   IF (cursys="AIX")
    SET com = concat("cd $CCLUSERDIR|rm ",_fname,".out")
    CALL dcl(com,size(trim(com)),0)
    SET com = concat("cd $CCLUSERDIR|ls rtlsrv*.log >> ",_fname)
   ELSE
    SET com = concat("$dir ccluserdir:rtlsrv*",build(p_server),"*.log /date/versions=2 /output=",
     _fname," /col=1")
   ENDIF
   CALL dcl(com,size(trim(com)),0)
   FREE DEFINE rtl
   DEFINE rtl _fname
   CALL echo(com)
   CALL echo(_fname)
   IF (p_server > 0)
    SELECT INTO "nl:"
     log = substring(1,30,r.line)
     FROM rtlt r
     WHERE r.line IN ("RTLSRV*", "rtlsrv*")
      AND p_server=cnvtint(substring(7,4,r.line))
     DETAIL
      count += 1, stat = alterlist(reply->data,count), reply->data[count].buffer = log
     WITH maxrow = 1, reporthelp, check
    ;end select
   ELSE
    SELECT INTO "nl:"
     log = substring(1,30,r.line)
     FROM rtlt r
     WHERE ((r.line="RTLSRV*") OR (r.line="rtlsrv*"))
     DETAIL
      count += 1, stat = alterlist(reply->data,count), reply->data[count].buffer = log
     WITH maxrow = 1, reporthelp, check
    ;end select
   ENDIF
   IF (cursys="AIX")
    SET _stat = remove(_fname)
   ELSE
    SET _stat = remove(build(_fname,";*"))
   ENDIF
 ENDCASE
 FREE DEFINE rtl
 SET reply->status_data.status = "S"
END GO
