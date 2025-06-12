CREATE PROGRAM aps_prt_db_kc61_params:dba
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
 SET log_program_name = "APS_PRT_DB_KC61_PARAMS"
 RECORD reply(
   1 print_file_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE sthick_line = vc WITH public, constant(fillstring(96,"="))
 DECLARE sthin_line = vc WITH public, constant(fillstring(96,"-"))
 DECLARE svertical_line = c1 WITH public, constant(fillstring(1,"|"))
 DECLARE lcodesetcnt = i4 WITH protect, noconstant(0)
 DECLARE shead = vc WITH protect, noconstant("")
 DECLARE ssubhead = vc WITH protect, noconstant("")
 DECLARE spage = vc WITH protect, noconstant("")
 DECLARE sname = vc WITH protect, noconstant("")
 DECLARE sdomain = vc WITH protect, noconstant("")
 DECLARE sdate = vc WITH protect, noconstant("")
 DECLARE stime = vc WITH protect, noconstant("")
 DECLARE scodeset = vc WITH protect, noconstant("")
 DECLARE skc61code = vc WITH protect, noconstant("")
 DECLARE sapcode = vc WITH protect, noconstant("")
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
 DECLARE l18nhandle = i4 WITH public, noconstant(0)
 DECLARE h = i4 WITH public, noconstant(0)
 SET h = uar_i18nlocalizationinit(l18nhandle,curprog,"",curcclrev)
 SET reply->status_data.status = "F"
 CALL log_message("Starting script: aps_prt_db_kc61_params",log_level_debug)
 IF ((request->debug_ind=1))
  CALL echorecord(request)
 ENDIF
 SET lcodesetcnt = size(request->code_sets,5)
 SET shead = uar_i18ngetmessage(l18nhandle,"HEAD",
  "PathNet Anatomic Pathology: Cytology KC61 Report Parameters")
 SET ssubhead = uar_i18ngetmessage(l18nhandle,"SUBHEAD","Audit Report")
 SET sname = uar_i18ngetmessage(l18nhandle,"NAME","Name:")
 SET sdomain = uar_i18ngetmessage(l18nhandle,"DOMAIN","Domain:")
 SET sdate = uar_i18ngetmessage(l18nhandle,"DATE","Date:")
 SET stime = uar_i18ngetmessage(l18nhandle,"TIME","Time:")
 SET scodeset = uar_i18ngetmessage(l18nhandle,"CODESET","Codeset:")
 SET skc61code = uar_i18ngetmessage(l18nhandle,"KC61CODE","KC61 Code Value")
 SET sapcode = uar_i18ngetmessage(l18nhandle,"APCODE","AP Code Value")
 EXECUTE cpm_create_file_name_logical "ApsDbKC61", "dat", "APS"
 SET reply->print_file_name = cpm_cfn_info->file_name
 IF (lcodesetcnt > 0)
  SELECT INTO cpm_cfn_info->file_name_logical
   child_disp_key = cnvtupper(cnvtalphanum(uar_get_code_display(cvg.child_code_value)))
   FROM (dummyt d  WITH seq = value(lcodesetcnt)),
    code_value cv,
    code_value_group cvg,
    code_value_set cvs
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_set=request->code_sets[d.seq].code_set)
     AND cv.code_value > 0)
    JOIN (cvg
    WHERE cvg.parent_code_value=cv.code_value)
    JOIN (cvs
    WHERE cvs.code_set=cv.code_set)
   ORDER BY cvs.display_key, cv.display_key, child_disp_key
   HEAD REPORT
    CALL center(shead,1,96), row + 1,
    CALL center(ssubhead,1,96),
    row + 1, col 1, sname,
    col 9, request->user_name"##############", col 83,
    sdate, sdate = format(curdate,"mm/dd/yy;;d"), col 89,
    sdate, row + 1, col 1,
    sdomain, col 9, request->domain,
    col 83, stime, stime = format(curtime3,"hh:mm:ss;3;m"),
    col 89, stime
   HEAD PAGE
    IF (curpage > 1)
     CALL center(ssubhead,1,96), sdate = format(curdate,"mm/dd/yy;;d"), col 88,
     sdate, row + 1, stime = format(curtime3,"hh:mm:ss;3;m"),
     col 88, stime
    ELSE
     row + 1
    ENDIF
    row + 1, col 1, skc61code,
    col 42, sapcode, row + 1,
    col 1, sthick_line
   HEAD cvs.display_key
    row + 1, col 1, scodeset,
    col + 1, cvs.display_key, row + 1,
    col 1, sthick_line
   HEAD cv.display_key
    row + 1, sdisp = trim(substring(1,38,cv.display)), col 1,
    sdisp, col 40, svertical_line,
    row + 1, col 1, sthin_line
   HEAD child_disp_key
    row + 1, col 40, svertical_line,
    sdisp = trim(substring(1,53,uar_get_code_display(cvg.child_code_value))), col 42, sdisp,
    row + 1, col 1, sthin_line
   FOOT REPORT
    row + 1, col 1, sthick_line,
    row + 1
   WITH nocounter
  ;end select
  IF (error_message(1) > 0)
   GO TO exit_script
  ENDIF
  CALL log_message("KC61 parameters report successfully created.",log_level_debug)
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL log_message("End of script: aps_prt_db_kc61_params",log_level_debug)
 IF ((request->debug_ind=1))
  CALL echorecord(reply)
 ENDIF
 CALL uar_sysdestroyhandle(hsys)
END GO
