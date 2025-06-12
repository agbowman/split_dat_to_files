CREATE PROGRAM bbd_rpt_deferral:dba
 RECORD reply(
   1 report_name_list[*]
     2 report_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 DECLARE log_program_name = vc WITH protect, noconstant(curprog)
 IF (validate(glbsl_def,999)=999)
  CALL echo("Declaring GLBSL_DEF")
  DECLARE glbsl_def = i2 WITH protect, constant(1)
  DECLARE log_override_ind = i2 WITH protect, noconstant(0)
  SET log_override_ind = 0
  DECLARE log_level_error = i2 WITH protect, noconstant(0)
  DECLARE log_level_warning = i2 WITH protect, noconstant(1)
  DECLARE log_level_audit = i2 WITH protect, noconstant(2)
  DECLARE log_level_info = i2 WITH protect, noconstant(3)
  DECLARE log_level_debug = i2 WITH protect, noconstant(4)
  DECLARE hsys = h WITH protect, noconstant(0)
  DECLARE sysstat = i4 WITH protect, noconstant(0)
  DECLARE serrmsg = c132 WITH protect, noconstant(" ")
  DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
  DECLARE glbsl_msg_default = i4 WITH protect, noconstant(0)
  DECLARE glbsl_msg_level = i4 WITH protect, noconstant(0)
  EXECUTE msgrtl
  SET glbsl_msg_default = uar_msgdefhandle()
  SET glbsl_msg_level = uar_msggetlevel(glbsl_msg_default)
  CALL uar_syscreatehandle(hsys,sysstat)
  DECLARE lglbslsubeventcnt = i4 WITH protect, noconstant(0)
  DECLARE iglbslloggingstat = i2 WITH protect, noconstant(0)
  DECLARE lglbslsubeventsize = i4 WITH protect, noconstant(0)
  DECLARE iglbslloglvloverrideind = i2 WITH protect, noconstant(0)
  DECLARE sglbsllogtext = vc WITH protect, noconstant("")
  DECLARE sglbsllogevent = vc WITH protect, noconstant("")
  DECLARE iglbslholdloglevel = i2 WITH protect, noconstant(0)
  DECLARE iglbslerroroccured = i2 WITH protect, noconstant(0)
  DECLARE lglbsluarmsgwritestat = i4 WITH protect, noconstant(0)
  DECLARE glbsl_info_domain = vc WITH protect, constant("PATHNET SCRIPT LOGGING")
  DECLARE glbsl_logging_on = c1 WITH protect, constant("L")
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=glbsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=glbsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 DECLARE log_message(logmsg=vc,loglvl=i4) = null
 SUBROUTINE log_message(logmsg,loglvl)
   SET iglbslloglvloverrideind = 0
   SET sglbsllogtext = ""
   SET sglbsllogevent = ""
   SET sglbsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET iglbslholdloglevel = loglvl
   ELSE
    IF (glbsl_msg_level < loglvl)
     SET iglbslholdloglevel = glbsl_msg_level
     SET iglbslloglvloverrideind = 1
    ELSE
     SET iglbslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (iglbslloglvloverrideind=1)
    SET sglbsllogevent = "ScriptOverride"
   ELSE
    CASE (iglbslholdloglevel)
     OF log_level_error:
      SET sglbsllogevent = "ScriptError"
     OF log_level_warning:
      SET sglbsllogevent = "ScriptWarning"
     OF log_level_audit:
      SET sglbsllogevent = "ScriptAudit"
     OF log_level_info:
      SET sglbsllogevent = "ScriptInfo"
     OF log_level_debug:
      SET sglbsllogevent = "ScriptDebug"
    ENDCASE
   ENDIF
   SET lglbsluarmsgwritestat = uar_msgwrite(glbsl_msg_default,0,nullterm(sglbsllogevent),
    iglbslholdloglevel,nullterm(sglbsllogtext))
 END ;Subroutine
 DECLARE error_message(logstatusblockind=i2) = i2
 SUBROUTINE error_message(logstatusblockind)
   SET iglbslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET iglbslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(iglbslerroroccured)
 END ;Subroutine
 DECLARE populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),targetobjectname=
  vc(value),targetobjectvalue=vc(value)) = i2
 SUBROUTINE populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lglbslsubeventcnt = size(reply->status_data.subeventstatus,5)
    IF (lglbslsubeventcnt > 0)
     SET lglbslsubeventsize = size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationname))
     SET lglbslsubeventsize = (lglbslsubeventsize+ size(trim(reply->status_data.subeventstatus[
       lglbslsubeventcnt].operationstatus)))
     SET lglbslsubeventsize = (lglbslsubeventsize+ size(trim(reply->status_data.subeventstatus[
       lglbslsubeventcnt].targetobjectname)))
     SET lglbslsubeventsize = (lglbslsubeventsize+ size(trim(reply->status_data.subeventstatus[
       lglbslsubeventcnt].targetobjectvalue)))
    ELSE
     SET lglbslsubeventsize = 1
    ENDIF
    IF (lglbslsubeventsize > 0)
     SET lglbslsubeventcnt = (lglbslsubeventcnt+ 1)
     SET iglbslloggingstat = alter(reply->status_data.subeventstatus,lglbslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 DECLARE populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) = i2
 SUBROUTINE populate_subeventstatus_msg(operationname,operationstatus,targetobjectname,
  targetobjectvalue,loglevel)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 DECLARE check_log_level(arg_log_level=i4) = i2
 SUBROUTINE check_log_level(arg_log_level)
   IF (((glbsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 rpt_title = vc
   1 rpt_time = vc
   1 rpt_as_of_date = vc
   1 rpt_from = vc
   1 rpt_to = vc
   1 person = vc
   1 date_of_birth = vc
   1 sex = vc
   1 donor_number = vc
   1 last_donated = vc
   1 deferred = vc
   1 dfrl_reason = vc
   1 rpt_id = vc
   1 rpt_page = vc
   1 printed = vc
   1 printed_by = vc
   1 end_of_report = vc
 )
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "D O N O R   D E F E R R A L   R E P O R T")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->rpt_from = uar_i18ngetmessage(i18nhandle,"rpt_from","From:")
 SET captions->rpt_to = uar_i18ngetmessage(i18nhandle,"rpt_to","To:")
 SET captions->person = uar_i18ngetmessage(i18nhandle,"person","Person")
 SET captions->date_of_birth = uar_i18ngetmessage(i18nhandle,"date_of_birth","Date of Birth")
 SET captions->sex = uar_i18ngetmessage(i18nhandle,"sex","Sex")
 SET captions->donor_number = uar_i18ngetmessage(i18nhandle,"donor_number","Donor Number")
 SET captions->last_donated = uar_i18ngetmessage(i18nhandle,"last_donated","Last Donated")
 SET captions->deferred = uar_i18ngetmessage(i18nhandle,"deferred","Deferred Until")
 SET captions->dfrl_reason = uar_i18ngetmessage(i18nhandle,"dfrl_reason","Deferral Reasons")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id","Report ID: BBD_RPT_DEFERRAL")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->printed_by = uar_i18ngetmessage(i18nhandle,"printed_by","By:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 DECLARE temp_cd = f8 WITH noconstant(0.0)
 DECLARE perm_cd = f8 WITH noconstant(0.0)
 DECLARE donor_nbr_format_cd = f8 WITH noconstant(0.0)
 DECLARE line = c125 WITH noconstant(fillstring(125,"_"))
 DECLARE sfilename = vc WITH noconstant(build("cer_temp:bbddfr_",format(curdate,"mmdd;;d"),format(
    curtime3,"hhmmss;;m"),".txt"))
 DECLARE stat = i4 WITH noconstant(0)
 SET stat = uar_get_meaning_by_codeset(14237,"PERMNENT",1,perm_cd)
 SET stat = uar_get_meaning_by_codeset(14237,"TEMP",1,temp_cd)
 SET stat = uar_get_meaning_by_codeset(4,"DONORID",1,donor_nbr_format_cd)
 SELECT INTO value(sfilename)
  pd.person_id, p.name_full_formatted, p.name_last_key,
  p.name_first_key, sex = uar_get_code_display(p.sex_cd), alias = cnvtalias(pa.alias,pa.alias_pool_cd
   ),
  elig_type = uar_get_code_display(bde.eligibility_type_cd), elig_dt_tm = cnvtdatetime(bde
   .eligible_dt_tm), reason = uar_get_code_display(bdr.reason_cd)
  FROM bbd_donor_contact bdc,
   bbd_donor_eligibility bde,
   bbd_deferral_reason bdr,
   person_donor pd,
   person p,
   person_alias pa
  PLAN (bdc
   WHERE bdc.contact_dt_tm BETWEEN cnvtdatetime(request->begin_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND bdc.active_ind=1)
   JOIN (bde
   WHERE bde.contact_id=bdc.contact_id
    AND bde.active_ind=1
    AND ((bde.eligibility_type_cd=perm_cd
    AND (request->perm_deferred_ind=1)) OR (bde.eligibility_type_cd=temp_cd
    AND (request->temp_deferred_ind=1))) )
   JOIN (bdr
   WHERE bdr.eligibility_id=bde.eligibility_id
    AND bdr.active_ind=1)
   JOIN (pd
   WHERE pd.person_id=bdc.person_id
    AND pd.active_ind=1)
   JOIN (p
   WHERE p.person_id=pd.person_id
    AND p.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.person_alias_type_cd=outerjoin(donor_nbr_format_cd)
    AND pa.active_ind=outerjoin(1))
  ORDER BY elig_type, p.name_full_formatted, p.person_id,
   elig_dt_tm DESC, reason
  HEAD REPORT
   first_elig_type = 0
  HEAD PAGE
   CALL center(captions->rpt_title,1,125), col 104, captions->rpt_time,
   col 118, curtime"@TIMENOSECONDS;;M", row + 1,
   col 35, captions->rpt_from, col 45,
   request->begin_dt_tm"@DATECONDENSED;;d", col 58, captions->rpt_to,
   col 68, request->end_dt_tm"@DATECONDENSED;;d", col 104,
   captions->rpt_as_of_date, col 118, curdate"@DATECONDENSED;;d",
   row + 1,
   CALL center(trim(elig_type),1,125), row + 3,
   col 5, captions->person, col 35,
   captions->date_of_birth, col 50, captions->sex,
   col 58, captions->donor_number, col 74,
   captions->last_donated, col 89, captions->deferred,
   col 104, captions->dfrl_reason, row + 1,
   col 5, "----------------------------", col 35,
   "-------------", col 50, "------",
   col 58, "--------------", col 74,
   "-------------", col 89, "--------------",
   col 104, "---------------", row + 1
  HEAD elig_type
   IF (first_elig_type=0)
    first_elig_type = 1
   ELSE
    BREAK
   ENDIF
  HEAD p.name_full_formatted
   row + 0
  HEAD p.person_id
   store_date = fillstring(14," ")
   IF (row > 50)
    BREAK
   ENDIF
   col 5, p.name_full_formatted"##############################"
   IF (curutc=1)
    store_date = format(datetimezone(p.birth_dt_tm,p.birth_tz),"@DATECONDENSED;4;q")
   ELSE
    store_date = format(p.birth_dt_tm,"@DATECONDENSED;;d")
   ENDIF
   col 35, store_date, col 50,
   sex"########", col 58, alias"#############",
   col 74, pd.last_donation_dt_tm"@DATECONDENSED;;d"
   IF (bde.eligibility_type_cd=temp_cd)
    col 89, elig_dt_tm"@DATECONDENSED;;d"
   ENDIF
  HEAD elig_dt_tm
   row + 0
  HEAD reason
   col 104, reason"###################", row + 1
   IF (row > 55)
    BREAK
   ENDIF
  FOOT  reason
   row + 0
  FOOT  elig_dt_tm
   row + 0
  FOOT  p.person_id
   row + 0
  FOOT  p.name_full_formatted
   row + 0
  FOOT  elig_type
   row + 0
  FOOT PAGE
   row 57, col 1, line,
   row + 1, col 1, captions->rpt_id,
   col 58, captions->rpt_page, col 64,
   curpage"###", col 100, captions->printed,
   col 110, curdate"@DATECONDENSED;;d", col 120,
   curtime"@TIMENOSECONDS;;M", row + 1, col 100,
   captions->printed_by, col 110, curuser
  FOOT REPORT
   row 60, col 51, captions->end_of_report
  WITH nullreport, nocounter, maxrow = 61,
   compress
 ;end select
 IF (error_message(1)=0)
  SET stat = alterlist(reply->report_name_list,1)
  SET reply->report_name_list[1].report_name = sfilename
  SET reply->status_data.status = "S"
  CALL populate_subeventstatus("Report Complete","S","bbd_rpt_deferral",
   "Report completed successfully")
 ELSE
  SET stat = alterlist(reply->report_name_list,1)
  SET reply->report_name_list[1].report_name = sfilename
  SET reply->status_data.status = "F"
  CALL populate_subeventstatus_msg("Abnormal End","F","bbd_rpt_deferral","Report ended abnormally",
   log_level_audit)
 ENDIF
#exit_script
 CALL uar_sysdestroyhandle(hsys)
END GO
