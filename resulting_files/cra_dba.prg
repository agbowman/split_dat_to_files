CREATE PROGRAM cra:dba
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE hsys = i4 WITH protect, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE crsl_msg_default = h WITH protect, noconstant(0)
 DECLARE crsl_msg_level = h WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SET crsl_msg_level = uar_msggetlevel(crsl_msg_default)
 DECLARE lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 DECLARE scrsllogevent = vc WITH protect, noconstant("")
 DECLARE icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE crsl_info_domain = vc WITH protect, constant("CLINRPT SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=crsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=crsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET icrslloglvloverrideind = 0
   SET scrsllogtext = ""
   SET scrsllogevent = ""
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET icrslholdloglevel = loglvl
   ELSE
    IF (crsl_msg_level < loglvl)
     SET icrslholdloglevel = crsl_msg_level
     SET icrslloglvloverrideind = 1
    ELSE
     SET icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (icrslloglvloverrideind=1)
    SET scrsllogevent = "Script_Override"
   ELSE
    CASE (icrslholdloglevel)
     OF log_level_error:
      SET scrsllogevent = "Script_Error"
     OF log_level_warning:
      SET scrsllogevent = "Script_Warning"
     OF log_level_audit:
      SET scrsllogevent = "Script_Audit"
     OF log_level_info:
      SET scrsllogevent = "Script_Info"
     OF log_level_debug:
      SET scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(crsl_msg_default,0,nullterm(scrsllogevent),
    icrslholdloglevel,nullterm(scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     SET reply->status_data.status = "F"
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus(opname,"F",serrmsg,logmsg)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET reply->status_data.status = "Z"
    CALL populate_subeventstatus(opname,"Z","No records qualified",logmsg)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(reply->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(reply->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE xml_version_encoding = vc WITH constant("<?xml version='1.0' encoding='ISO-8859-1'?>"),
 protect
 DECLARE export_successful = i4 WITH constant(1), protect
 DECLARE export_failed = i4 WITH constant(- (1)), protect
 DECLARE double_quote_char = c1 WITH constant('"'), protect
 DECLARE sencodedstr = vc WITH noconstant(""), protect
 SUBROUTINE (createelementstring(stag=vc(val),scontent=vc(val)) =vc)
   RETURN(build(createstartelementstring(stag),scontent,createendelementstring(stag)))
 END ;Subroutine
 SUBROUTINE (createstartelementstring(stag=vc(val)) =vc)
   RETURN(build("<",stag,">"))
 END ;Subroutine
 SUBROUTINE (createendelementstring(stag=vc(val)) =vc)
   RETURN(build("</",stag,">"))
 END ;Subroutine
 SUBROUTINE (createattributestring(stag=vc(val),scontent=vc(val)) =vc)
   RETURN(build2(" ",stag,"=",double_quote_char,scontent,
    double_quote_char))
 END ;Subroutine
 SUBROUTINE (createattributestringbystring(stag=vc(val),scontent=vc(val)) =vc)
   RETURN(build2(" ",stag,"=",double_quote_char,findandreplacespecialcharacters(scontent),
    double_quote_char))
 END ;Subroutine
 SUBROUTINE (createcommentstring(scomment=vc(val)) =vc)
   RETURN(build2("<!--",scomment,"-->"))
 END ;Subroutine
 SUBROUTINE (findandreplacespecialcharacters(str=vc(val)) =vc)
   SET sencodedstr = replace(str,"&","&amp;",0)
   SET sencodedstr = replace(sencodedstr,"<","&lt;",0)
   SET sencodedstr = replace(sencodedstr,">","&gt;",0)
   SET sencodedstr = replace(sencodedstr,char(34),"&quot;",0)
   SET sencodedstr = replace(sencodedstr,char(39),"&apos;",0)
   RETURN(sencodedstr)
 END ;Subroutine
 SUBROUTINE (exportfilebyblobid(longblobid=f8(val),tosourcdir=vc(val),filename=vc(val)) =i4)
   CALL log_message("In ExportFileByBlobId()",log_level_debug)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(sysdate)), private
   SET modify maxvarlen 99999999
   DECLARE blob_string = vc WITH noconstant(" "), protect
   DECLARE blob_size = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    moreblob = textlen(lb.long_blob)
    FROM long_blob lb
    PLAN (lb
     WHERE lb.long_blob_id=longblobid)
    HEAD REPORT
     outbuf = fillstring(32767," ")
    DETAIL
     offset = 0, retlen = 1
     WHILE (retlen > 0)
       retlen = blobget(outbuf,offset,lb.long_blob), blob_size += retlen, offset += retlen,
       blob_string = notrim(concat(notrim(blob_string),notrim(outbuf)))
     ENDWHILE
     IF (blob_size > lb.blob_length)
      CALL echo(build("adjusted size from",blob_size," to: ",lb.blob_length)), blob_size = lb
      .blob_length
     ENDIF
    WITH nocounter, rdbarrayfetch = 1
   ;end select
   CALL error_and_zero_check(curqual,"LONG_BLOB","EXPORTFILEBYBLOBID",1,1)
   FREE RECORD temp_request
   RECORD temp_request(
     1 source_dir = vc
     1 source_filename = vc
     1 nbrlines = i4
     1 line[*]
       2 linedata = vc
     1 overflowpage[*]
       2 ofr_qual[*]
         3 ofr_line = vc
     1 isblob = c1
     1 document_size = i4
     1 document = gvc
   )
   SET temp_request->source_dir = tosourcdir
   SET temp_request->source_filename = filename
   SET temp_request->isblob = "1"
   SET temp_request->document_size = blob_size
   SET temp_request->document = blob_string
   FREE RECORD temp_reply
   RECORD temp_reply(
     1 info_line[*]
       2 new_line = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   EXECUTE eks_put_source  WITH replace("REQUEST","TEMP_REQUEST"), replace("REPLY","TEMP_REPLY")
   CALL log_message(build("Exit ExportFileByBlobId(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
   IF ((temp_reply->status_data.status != "S"))
    RETURN(export_failed)
   ELSE
    RETURN(export_successful)
   ENDIF
 END ;Subroutine
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE return_status = i4 WITH noconstant(0), protect
 DECLARE blob_id = f8 WITH constant(cnvtreal( $1)), protect
 DECLARE file_location = vc WITH constant( $2), protect
 DECLARE file_name = vc WITH constant( $3), protect
 DECLARE error_text = vc WITH noconstant(""), protect
 DECLARE error_loc = vc WITH noconstant("VALIDATION"), protect
 DECLARE example_text1 = vc WITH constant(concat("cra 12345, ",char(34),"cer_temp:",char(34),", ",
   char(34),"myFile.zip",char(34)))
 DECLARE example_text2 = vc WITH constant(concat("cra 12345, ",char(34),"$cer_temp/:",char(34),", ",
   char(34),"myFile.zip",char(34)))
 DECLARE example_text3 = vc WITH constant(concat("cra 12345, ",char(34),"/home/user/",char(34),", ",
   char(34),"myFile.zip",char(34)))
 DECLARE example_text4 = vc WITH constant(concat("cra 12345, ",char(34),"user01:[user.userId]",char(
    34),", ",
   char(34),"myFile.zip",char(34)))
 DECLARE i18nhandle = i4 WITH noconstant(0), protect
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog," ",curcclrev)
 DECLARE invalidblob = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ERR1",
   "Invalid long_blob_id entered."))
 DECLARE invalidfileloc = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ERR2",
   "Invalid file location entered."))
 DECLARE invalidfilename = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ERR3",
   "Invalid file name entered."))
 DECLARE exportfailed = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ERR4",
   "Exporting of file by long_blob_id failed."))
 DECLARE exampletext = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ERR4","Examples:"))
 SET reply->status_data.status = "F"
 IF (blob_id < 1)
  CALL adderrortext(invalidblob)
 ENDIF
 IF (trim(file_location)="")
  CALL adderrortext(invalidfileloc)
 ENDIF
 IF (trim(file_name)="")
  CALL adderrortext(invalidfilename)
 ENDIF
 IF (size(trim(error_text)) > 0)
  GO TO exit_script
 ENDIF
 SET return_status = exportfilebyblobid(blob_id,file_location,file_name)
 IF (return_status != export_successful)
  SET reply->status_data.status = "F"
  CALL adderrortext(exportfailed)
  SET error_loc = "ExportFileByBlobId"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE (adderrortext(serrortext=vc(val)) =null)
   IF (size(trim(error_text)) > 0)
    SET error_text = concat(error_text,", ",serrortext)
   ELSE
    SET error_text = serrortext
   ENDIF
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "cra"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = error_loc
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_text
  CALL echorecord(reply)
  CALL echo(exampletext)
  CALL echo(example_text1)
  CALL echo(example_text2)
  CALL echo(example_text3)
  CALL echo(example_text4)
 ENDIF
END GO
