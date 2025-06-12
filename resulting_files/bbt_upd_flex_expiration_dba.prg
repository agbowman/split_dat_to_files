CREATE PROGRAM bbt_upd_flex_expiration:dba
 RECORD reply(
   1 persons[*]
     2 person_id = f8
     2 specimens[*]
       3 specimen_id = f8
       3 drawn_dt_tm = dq8
       3 testing_facility_cd = f8
       3 encntr_id = f8
       3 facility_cd = f8
       3 accession = c20
       3 old_expire_dt_tm = dq8
       3 new_expire_dt_tm = dq8
       3 update_status_flag = i2
       3 new_override_id = f8
       3 orders[*]
         4 order_id = f8
         4 products[*]
           5 product_id = f8
           5 old_product_event_id = f8
           5 new_product_event_id = f8
           5 product_type_cd = f8
           5 product_type_disp = vc
           5 xm_status_flag = i2
           5 new_xm_expire_dt_tm = dq8
           5 old_xm_expire_dt_tm = dq8
       3 exception_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
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
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
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
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
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
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lglbslsubeventcnt = size(reply->status_data.subeventstatus,5)
    IF (lglbslsubeventcnt > 0)
     SET lglbslsubeventsize = size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationstatus))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectvalue))
    ELSE
     SET lglbslsubeventsize = 1
    ENDIF
    IF (lglbslsubeventsize > 0)
     SET lglbslsubeventcnt += 1
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
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((glbsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
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
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
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
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
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
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lglbslsubeventcnt = size(reply->status_data.subeventstatus,5)
    IF (lglbslsubeventcnt > 0)
     SET lglbslsubeventsize = size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationstatus))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectvalue))
    ELSE
     SET lglbslsubeventsize = 1
    ENDIF
    IF (lglbslsubeventsize > 0)
     SET lglbslsubeventcnt += 1
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
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((glbsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 IF (validate(bbt_get_pref_def,999)=999)
  DECLARE bbt_get_pref_def = i2 WITH protect, constant(1)
  RECORD prefvalues(
    1 prefs[*]
      2 value = vc
  )
  RECORD flexspectransparams(
    1 params[*]
      2 index = i4
      2 transfusionstartrange = i4
      2 transfusionendrange = i4
      2 specimenexpiration = i4
  )
  RECORD encounterlocations(
    1 locs[*]
      2 encfacilitycd = f8
  )
  DECLARE pref_level_bb = i2 WITH public, constant(1)
  DECLARE pref_level_flex = i2 WITH public, constant(2)
  DECLARE flex_spec_group = vc WITH protect, constant("flexible specimen")
  DECLARE pref_flex_spec_yes = vc WITH protect, constant("YES")
  DECLARE pref_flex_spec_no = vc WITH protect, constant("NO")
  DECLARE prefentryexists = i2 WITH protect, noconstant(0)
  DECLARE statbbpref = i2 WITH protect, noconstant(0)
 ENDIF
 SUBROUTINE (bbtgetencounterlocations(facility_code=f8(value),level_flag=i2(value)) =i2)
   DECLARE index = i2 WITH protect, noconstant(0)
   DECLARE loccnt = i2 WITH protect, noconstant(0)
   DECLARE prefcount = i2 WITH protect, noconstant(0)
   DECLARE flexprefentry = vc WITH protect, constant("patient encounter locations")
   SET statbbpref = initrec(encounterlocations)
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    flexprefentry)
   IF ((statbbpref=- (1)))
    IF (prefentryexists=1)
     RETURN(1)
    ELSE
     RETURN(- (1))
    ENDIF
   ENDIF
   SET prefcount = size(prefvalues->prefs,5)
   IF (prefcount=0)
    RETURN(1)
   ENDIF
   FOR (index = 1 TO prefcount)
     IF (cnvtreal(prefvalues->prefs[index].value) > 0.0)
      SET loccnt += 1
      IF (size(encounterlocations->locs,5) < loccnt)
       SET stat = alterlist(encounterlocations->locs,(loccnt+ 9))
      ENDIF
      SET encounterlocations->locs[loccnt].encfacilitycd = cnvtreal(prefvalues->prefs[index].value)
     ENDIF
   ENDFOR
   SET stat = alterlist(encounterlocations->locs,loccnt)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (bbtgethistoricinfopreference(facility_code=f8(value)) =i2)
   DECLARE historical_demog_ind = i2 WITH protect, noconstant(0)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE prefentry = vc WITH protect, constant("print historical demographics")
   DECLARE code_set = i4 WITH protect, constant(20790)
   DECLARE historycd = f8 WITH protect, constant(uar_get_code_by("MEANING",code_set,"HISTORY"))
   IF ((historycd=- (1)))
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM code_value_extension cve
    WHERE cve.code_value=historycd
     AND cve.field_name="OPTION"
     AND cve.code_set=code_set
    DETAIL
     IF (trim(cve.field_value,3)="1")
      historical_demog_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (historical_demog_ind=0)
    RETURN(0)
   ENDIF
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="Yes"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetcustompacklistpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("custom packing list program name")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetrequiredcourierdispenseassignpreference(facility_code=f8(value)) =i2)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("require dispense courier")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetrequiredcourierreturnproductspreference(facility_code=f8(value)) =i2)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("require return courier")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetinterfaceddevicespreference(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("uses interfaced devices")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(0)
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetbbtestingfacility(facility_code=f8(value)) =f8)
   RETURN(bbtgetflexspectestingfacility(facility_code))
 END ;Subroutine
 SUBROUTINE (bbtgetflexspectestingfacility(facility_code=f8(value)) =f8)
   DECLARE prefentry = vc WITH protect, constant("transfusion service facility")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF ((((statbbpref=- (1))) OR (size(prefvalues->prefs,5) > 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(prefvalues->prefs,5)=1)
    IF (size(trim(prefvalues->prefs[1].value)) > 0)
     SET strlogmessage = build("PrefEntry- ",prefentry,":",prefvalues->prefs[1].value,
      ",Facility Code:",
      facility_code)
     CALL log_message(strlogmessage,log_level_debug)
     RETURN(cnvtreal(trim(prefvalues->prefs[1].value,3)))
    ELSE
     RETURN(0.0)
    ENDIF
   ELSE
    RETURN(0.0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecenableflexexpiration(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("enable flex expiration")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF ((((statbbpref=- (1))) OR (size(prefvalues->prefs,5) > 1)) )
    SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
    CALL log_message(strlogmessage,log_level_error)
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(prefvalues->prefs,5)=1)
    IF ((prefvalues->prefs[1].value="1"))
     RETURN(1)
    ELSE
     RETURN(0)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecdefclinsigantibodyparams(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("def clin sig antibody params")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecxmalloexpunits(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("xm allogeneic expire units")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecxmautoexpunits(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("xm autologous expire units")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecmaxspecexpunits(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("max specimen expire units")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecclinsigantibodiesexpunits(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("clin sig antibodies exp units")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecextendtransfoverride(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("extend transf override")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ELSEIF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_no))
     RETURN(0)
    ELSE
     RETURN(1)
    ENDIF
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspeccalcposttransfspecsfromdawndt(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("calc post transf specs from drawn dt")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ELSEIF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_no))
     RETURN(0)
    ELSE
     RETURN(0)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecexpunittypemean(facility_code=f8(value)) =c12)
   DECLARE prefentry = vc WITH protect, constant("flex spec expiration unit type")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(trim(prefvalues->prefs[1].value,3))
   ELSE
    RETURN("")
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecxmtagsprinter(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("xm tags printer")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   RETURN(trim(prefvalues->prefs[1].value))
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecexceptionrptprinter(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("exception rpt printer")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   RETURN(trim(prefvalues->prefs[1].value))
 END ;Subroutine
 SUBROUTINE (bbtgetflexspectransfusionparameters(facility_code=f8(value)) =i2)
   DECLARE index = i2 WITH protect, noconstant(0)
   DECLARE prefcount = i2 WITH protect, noconstant(0)
   DECLARE strposhold = i2 WITH protect, noconstant(0)
   DECLARE strprevposhold = i2 WITH protect, noconstant(0)
   DECLARE strsize = i2 WITH protect, noconstant(0)
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE maxparamitems = i2 WITH protect, constant(4)
   DECLARE prefentry = vc WITH protect, constant("transfusion parameters")
   SET statbbpref = initrec(flexspectransparams)
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   SET prefcount = size(prefvalues->prefs,5)
   IF (((statbbpref != 1) OR (prefcount < 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET statbbpref = alterlist(flexspectransparams->params,prefcount)
   FOR (index = 1 TO prefcount)
     SET strsize = 0
     SET strsize = size(prefvalues->prefs[index].value)
     SET strposhold = findstring(",",prefvalues->prefs[index].value)
     SET flexspectransparams->params[index].index = cnvtint(substring(1,(strposhold - 1),prefvalues->
       prefs[index].value))
     SET strprevposhold = strposhold
     SET strposhold = findstring(",",prefvalues->prefs[index].value,(strprevposhold+ 1))
     SET flexspectransparams->params[index].transfusionstartrange = cnvtint(substring((strprevposhold
       + 1),((strposhold - strprevposhold) - 1),prefvalues->prefs[index].value))
     SET strprevposhold = strposhold
     SET strposhold = findstring(",",prefvalues->prefs[index].value,(strprevposhold+ 1))
     SET flexspectransparams->params[index].transfusionendrange = cnvtint(substring((strprevposhold+
       1),((strposhold - strprevposhold) - 1),prefvalues->prefs[index].value))
     SET flexspectransparams->params[index].specimenexpiration = cnvtint(substring((strposhold+ 1),(
       strsize - strposhold),prefvalues->prefs[index].value))
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (getbbpreference(sfacilityctx=vc,spositionctx=vc,suserctx=vc,ssubgroup=vc,sprefentry=vc
  ) =i2)
   DECLARE success_ind = i2 WITH protect, noconstant(0)
   DECLARE hpref = i4 WITH protect, noconstant(0)
   DECLARE hgroup = i4 WITH protect, noconstant(0)
   DECLARE hsection = i4 WITH protect, noconstant(0)
   DECLARE hgroup2 = i4 WITH protect, noconstant(0)
   DECLARE hsubgroup = i4 WITH protect, noconstant(0)
   DECLARE hsubgroup2 = i4 WITH protect, noconstant(0)
   DECLARE hval = i4 WITH protect, noconstant(0)
   DECLARE hattr = i4 WITH protect, noconstant(0)
   DECLARE hentry = i4 WITH protect, noconstant(0)
   DECLARE idxentry = i4 WITH protect, noconstant(0)
   DECLARE idxattr = i4 WITH protect, noconstant(0)
   DECLARE idxval = i4 WITH protect, noconstant(0)
   DECLARE subgroupcount = i4 WITH protect, noconstant(0)
   DECLARE namelen = i4 WITH protect, noconstant(255)
   DECLARE entryname = c255 WITH protect, noconstant(fillstring(255," "))
   DECLARE entrycount = i4 WITH protect, noconstant(0)
   DECLARE attrcount = i4 WITH protect, noconstant(0)
   DECLARE valcount = i4 WITH protect, noconstant(0)
   DECLARE valname = c255 WITH protect, noconstant(fillstring(255," "))
   DECLARE subgroupexists = i2 WITH protect, noconstant(0)
   EXECUTE prefrtl
   SET statbbpref = initrec(prefvalues)
   SET prefentryexists = 0
   SET hpref = uar_prefcreateinstance(0)
   IF (hpref=0)
    CALL log_message("Bad hPref, try logging in",log_level_error)
    RETURN(- (1))
   ENDIF
   SET statbbpref = uar_prefaddcontext(hpref,"default","system")
   IF (statbbpref != 1)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Bad default context",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (size(nullterm(sfacilityctx)) > 0)
    SET statbbpref = uar_prefaddcontext(hpref,"facility",nullterm(sfacilityctx))
    IF (statbbpref != 1)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Bad facility context",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (size(nullterm(spositionctx)) > 0)
    SET statbbpref = uar_prefaddcontext(hpref,"position",nullterm(spositionctx))
    IF (statbbpref != 1)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Bad position context",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (size(nullterm(suserctx)) > 0)
    SET statbbpref = uar_prefaddcontext(hpref,"user",nullterm(suserctx))
    IF (statbbpref != 1)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Bad user context",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET statbbpref = uar_prefsetsection(hpref,"module")
   IF (statbbpref != 1)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Bad section",log_level_error)
    RETURN(- (1))
   ENDIF
   SET hgroup = uar_prefcreategroup()
   SET statbbpref = uar_prefsetgroupname(hgroup,"blood bank")
   IF (statbbpref != 1)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Bad group name",log_level_error)
    RETURN(- (1))
   ENDIF
   SET statbbpref = uar_prefaddgroup(hpref,hgroup)
   IF (statbbpref != 1)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Error adding group",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (size(nullterm(ssubgroup)) > 0)
    SET subgroupexists = 1
    SET hsubgroup = uar_prefaddsubgroup(hgroup,nullterm(ssubgroup))
    IF (hsubgroup <= 0)
     CALL uar_prefdestroygroup(hgroup)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Error adding sub group",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET statbbpref = uar_prefperform(hpref)
   IF (statbbpref != 1)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Error performing preference query",log_level_error)
    RETURN(- (1))
   ENDIF
   SET hsection = uar_prefgetsectionbyname(hpref,"module")
   SET hgroup2 = uar_prefgetgroupbyname(hsection,"blood bank")
   IF (subgroupexists=1)
    SET hsubgroup2 = uar_prefgetsubgroup(hgroup2,0)
    IF (hsubgroup2 <= 0)
     CALL uar_prefdestroysection(hsection)
     CALL uar_prefdestroygroup(hgroup2)
     CALL uar_prefdestroygroup(hgroup)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Error obtaining sub group",log_level_error)
     RETURN(- (1))
    ENDIF
    SET hgroup2 = hsubgroup2
   ENDIF
   SET entrycount = 0
   SET statbbpref = uar_prefgetgroupentrycount(hgroup2,entrycount)
   IF (statbbpref != 1)
    CALL uar_prefdestroysection(hsection)
    CALL uar_prefdestroygroup(hgroup2)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Error getting group entry count",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (entrycount <= 0)
    CALL uar_prefdestroysection(hsection)
    CALL uar_prefdestroygroup(hgroup2)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Preferences not found",log_level_error)
    RETURN(0)
   ENDIF
   FOR (idxentry = 0 TO (entrycount - 1))
     SET hentry = uar_prefgetgroupentry(hgroup2,idxentry)
     SET namelen = 255
     SET entryname = fillstring(255," ")
     SET statbbpref = uar_prefgetentryname(hentry,entryname,namelen)
     IF (statbbpref != 1)
      CALL uar_prefdestroyentry(hentry)
      CALL uar_prefdestroysection(hsection)
      CALL uar_prefdestroygroup(hgroup2)
      CALL uar_prefdestroygroup(hgroup)
      CALL uar_prefdestroyinstance(hpref)
      CALL log_message("Error getting entry name",log_level_error)
      RETURN(- (1))
     ENDIF
     IF (nullterm(entryname)=nullterm(sprefentry))
      SET prefentryexists = 1
      SET attrcount = 0
      SET statbbpref = uar_prefgetentryattrcount(hentry,attrcount)
      IF (((statbbpref != 1) OR (attrcount=0)) )
       CALL uar_prefdestroyentry(hentry)
       CALL uar_prefdestroysection(hsection)
       CALL uar_prefdestroygroup(hgroup2)
       CALL uar_prefdestroygroup(hgroup)
       CALL uar_prefdestroyinstance(hpref)
       CALL log_message("Bad entryAttrCount",log_level_error)
       RETURN(- (1))
      ENDIF
      FOR (idxattr = 0 TO (attrcount - 1))
        SET hattr = uar_prefgetentryattr(hentry,idxattr)
        DECLARE attrname = c255
        SET namelen = 255
        SET statbbpref = uar_prefgetattrname(hattr,attrname,namelen)
        IF (nullterm(attrname)="prefvalue")
         SET valcount = 0
         SET statbbpref = uar_prefgetattrvalcount(hattr,valcount)
         SET idxval = 0
         SET statbbpref = alterlist(prefvalues->prefs,valcount)
         FOR (idxval = 0 TO (valcount - 1))
           SET valname = fillstring(255," ")
           SET namelen = 255
           SET hval = uar_prefgetattrval(hattr,valname,namelen,idxval)
           SET prefvalues->prefs[(idxval+ 1)].value = nullterm(valname)
         ENDFOR
         IF (hattr > 0)
          CALL uar_prefdestroyattr(hattr)
         ENDIF
         IF (hentry > 0)
          CALL uar_prefdestroyentry(hentry)
         ENDIF
         IF (hsection > 0)
          CALL uar_prefdestroysection(hsection)
         ENDIF
         IF (hgroup2 > 0)
          CALL uar_prefdestroygroup(hgroup2)
         ENDIF
         IF (hgroup > 0)
          CALL uar_prefdestroygroup(hgroup)
         ENDIF
         IF (hpref > 0)
          CALL uar_prefdestroyinstance(hpref)
         ENDIF
         RETURN(1)
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (hattr > 0)
    CALL uar_prefdestroyattr(hattr)
   ENDIF
   IF (hentry > 0)
    CALL uar_prefdestroyentry(hentry)
   ENDIF
   IF (hsection > 0)
    CALL uar_prefdestroysection(hsection)
   ENDIF
   IF (hgroup2 > 0)
    CALL uar_prefdestroygroup(hgroup2)
   ENDIF
   IF (hgroup > 0)
    CALL uar_prefdestroygroup(hgroup)
   ENDIF
   IF (hpref > 0)
    CALL uar_prefdestroyinstance(hpref)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtgetxmtagpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE prefentry = vc WITH protect, constant("crossmatch tag program name")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetcomponenttagpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("component tag program name")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetemergencytagpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE prefentry = vc WITH protect, constant("emergency tag program name")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexfilterbyfacility(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("filter specimens by facility")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE flex_on_ind = i2 WITH protect, noconstant(0)
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtdispgetproductorderassocpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("associate to prod orders on dispense")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN("")
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    IF (trim(prefvalues->prefs[1].value)="1")
     RETURN("Yes")
    ELSE
     RETURN("No")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecahgxmatch(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("ahg crossmatch")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    IF (trim(prefvalues->prefs[1].value)="1")
     RETURN("Yes")
    ELSE
     RETURN("No")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetaborhdiscrepancy(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("abo discrepancy")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    IF (trim(prefvalues->prefs[1].value)="1")
     RETURN("Yes")
    ELSE
     RETURN("No")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecneonatedaysdefined(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("neonate day spec override")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexexpiredspecimenexpirationovrd(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("extend expired specimen expiration")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtgetdisponcurrentaborh(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("dispense based on current aborh")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE flex_on_ind = i2 WITH protect, noconstant(0)
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtgetdisponsecondaborh(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("dispense based on two aborh")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE flex_on_ind = i2 WITH protect, noconstant(0)
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtgetflexexpiredspecimenneonatedischarge(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("extend neonate specimen discharge")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_debug)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtcorrectcommentpromptpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("result comment prompt")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN("")
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    IF (trim(prefvalues->prefs[1].value)="1")
     RETURN("Yes")
    ELSE
     RETURN("No")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE bbtprintdispenseencounteridentifier(facility_code)
   DECLARE prefentry = vc WITH protect, constant("print dispense encounter identifier")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_debug)
    ENDIF
    RETURN(0)
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetsamplevalidityorderspreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("sample validity qualifying orders")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE strpref = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) < 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   FOR (index = 1 TO size(prefvalues->prefs,5))
     IF (strpref="")
      SET strpref = concat(strpref,prefvalues->prefs[index].value)
     ELSE
      SET strpref = concat(strpref,",",prefvalues->prefs[index].value)
     ENDIF
   ENDFOR
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",strpref,",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   RETURN(strpref)
 END ;Subroutine
 SUBROUTINE bbtgetbbidtagpreference(facility_code)
   DECLARE prefentry = vc WITH protect, constant("disp bbid 2d tags")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_debug)
    ENDIF
    RETURN(0)
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetprodtagverifypreference(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("product tag verification")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_debug)
    ENDIF
    RETURN(0)
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 RECORD flex_param_out(
   1 testing_facility_cd = f8
   1 flex_on_ind = i2
   1 flex_param = i4
   1 allo_param = i4
   1 auto_param = i4
   1 anti_flex_ind = i2
   1 anti_param = i4
   1 max_spec_validity = i4
   1 expiration_unit_type_mean = c12
   1 max_transfusion_end_range = i4
   1 transfusion_flex_params[*]
     2 index = i4
     2 start_range = i4
     2 end_range = i4
     2 flex_param = i4
   1 extend_trans_ovrd_ind = i2
   1 calc_trans_drawn_dt_ind = i2
   1 neonate_age = i4
 )
 RECORD flex_patient_out(
   1 person_id = f8
   1 encntr_id = f8
   1 anti_exist_ind = i2
   1 transfusion[*]
     2 transfusion_dt_tm = dq8
     2 critical_dt_tm = dq8
 )
 RECORD flex_codes(
   1 codes_loaded_ind = i2
   1 transfused_state_cd = f8
   1 blood_product_cd = f8
 )
 RECORD flex_max_out(
   1 max_expire_dt_tm = dq8
   1 max_expire_flag = i2
 )
 FREE SET facilityinfo
 RECORD facilityinfo(
   1 facilities[*]
     2 testing_facility_cd = f8
     2 flex_on_ind = i2
     2 flex_param = i4
     2 allo_param = i4
     2 auto_param = i4
     2 anti_flex_ind = i2
     2 anti_param = i4
     2 max_spec_validity = i4
     2 expiration_unit_type_mean = c12
     2 max_transfusion_end_range = i4
     2 transfusion_flex_params[*]
       3 index = i4
       3 start_range = i4
       3 end_range = i4
       3 flex_param = i4
     2 extend_trans_ovrd_ind = i2
     2 calc_trans_drawn_dt_ind = i2
     2 extend_expired_specimen = i2
     2 neonate_age = i4
     2 load_flex_params = i2
     2 extend_neonate_disch_spec = i2
 )
 DECLARE getcriticaldtstms() = i2
 DECLARE getflexcodesbycdfmeaning() = i2
 DECLARE statbbcalcflex = i2 WITH protect, noconstant(0)
 DECLARE ntrans_flag = i2 WITH protect, constant(1)
 DECLARE nanti_flag = i2 WITH protect, constant(2)
 DECLARE nneonate_flag = i2 WITH protect, constant(3)
 DECLARE nmax_param_flag = i2 WITH protect, constant(4)
 SET flex_param_out->testing_facility_cd = - (1)
 SUBROUTINE (loadflexparams(encntrfacilitycd=f8(value)) =i2)
   DECLARE prefcount = i2 WITH protect, noconstant(0)
   DECLARE prefindex = i2 WITH protect, noconstant(0)
   DECLARE testingfacilitycd = f8 WITH protect, noconstant(0.0)
   SET testingfacilitycd = bbtgetflexspectestingfacility(encntrfacilitycd)
   IF ((testingfacilitycd=- (1)))
    CALL log_message("Error getting transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF ((flex_param_out->testing_facility_cd=testingfacilitycd))
    RETURN(1)
   ENDIF
   SET statbbcalcflex = initrec(flex_param_out)
   SET statbbcalcflex = initrec(flex_patient_out)
   SET flex_param_out->flex_on_ind = bbtgetflexspecenableflexexpiration(testingfacilitycd)
   CASE (flex_param_out->flex_on_ind)
    OF 0:
     RETURN(0)
    OF - (1):
     CALL log_message("Error getting flex on preference.",log_level_error)
     RETURN(- (1))
   ENDCASE
   SET flex_param_out->allo_param = bbtgetflexspecxmalloexpunits(testingfacilitycd)
   IF ((flex_param_out->allo_param=- (1)))
    CALL log_message("Error getting flex param preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->auto_param = bbtgetflexspecxmautoexpunits(testingfacilitycd)
   IF ((flex_param_out->auto_param=- (1)))
    CALL log_message("Error getting auto param pref.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->anti_flex_ind = bbtgetflexspecdefclinsigantibodyparams(testingfacilitycd)
   IF ((flex_param_out->anti_flex_ind=- (1)))
    CALL log_message("Error getting anti_flex_ind.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->anti_param = bbtgetflexspecclinsigantibodiesexpunits(testingfacilitycd)
   IF ((flex_param_out->anti_param=- (1)))
    CALL log_message("Error getting anti_param.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->max_spec_validity = bbtgetflexspecmaxspecexpunits(testingfacilitycd)
   IF ((flex_param_out->max_spec_validity=- (1)))
    CALL log_message("Error getting max spec validity preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->expiration_unit_type_mean = bbtgetflexspecexpunittypemean(testingfacilitycd)
   IF (size(flex_param_out->expiration_unit_type_mean,1) <= 0)
    CALL log_message("Error getting expiration unit type preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (bbtgetflexspectransfusionparameters(testingfacilitycd)=1)
    SET prefcount = size(flexspectransparams->params,5)
    SET statbbcalcflex = alterlist(flex_param_out->transfusion_flex_params,prefcount)
    FOR (prefindex = 1 TO prefcount)
      SET flex_param_out->transfusion_flex_params[prefindex].index = flexspectransparams->params[
      prefindex].index
      SET flex_param_out->transfusion_flex_params[prefindex].start_range = flexspectransparams->
      params[prefindex].transfusionstartrange
      SET flex_param_out->transfusion_flex_params[prefindex].end_range = flexspectransparams->params[
      prefindex].transfusionendrange
      SET flex_param_out->transfusion_flex_params[prefindex].flex_param = flexspectransparams->
      params[prefindex].specimenexpiration
      IF ((flexspectransparams->params[prefindex].transfusionendrange > flex_param_out->
      max_transfusion_end_range))
       SET flex_param_out->max_transfusion_end_range = flexspectransparams->params[prefindex].
       transfusionendrange
      ENDIF
    ENDFOR
   ELSE
    CALL log_message("Error getting transfusion flex params.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->extend_trans_ovrd_ind = bbtgetflexspecextendtransfoverride(testingfacilitycd)
   IF ((flex_param_out->extend_trans_ovrd_ind=- (1)))
    CALL log_message("Error getting extend_trans_ovrd_ind.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->calc_trans_drawn_dt_ind = bbtgetflexspeccalcposttransfspecsfromdawndt(
    testingfacilitycd)
   IF ((flex_param_out->calc_trans_drawn_dt_ind=- (1)))
    CALL log_message("Error getting calc_trans_drawn_dt_ind.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->neonate_age = bbtgetflexspecneonatedaysdefined(testingfacilitycd)
   IF ((flex_param_out->neonate_age=- (1)))
    CALL log_message("Error getting neonate days defined.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->testing_facility_cd = testingfacilitycd
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (loadflexpatient(personid=f8(value),encntrid=f8(value)) =i2)
   DECLARE current_dt_tm = dq8 WITH protect, constant(cnvtdatetime(curdate,0))
   DECLARE transfusioncount = i4 WITH protect, noconstant(0)
   DECLARE earliesttransfusionenddttm = dq8 WITH protect, noconstant(0.0)
   SET statbbcalcflex = initrec(flex_patient_out)
   IF ((flex_param_out->anti_flex_ind=1))
    SELECT
     IF (encntrid > 0.0)
      FROM person_antibody pa,
       transfusion_requirements tr
      PLAN (pa
       WHERE pa.encntr_id=encntrid
        AND pa.active_ind=1)
       JOIN (tr
       WHERE tr.requirement_cd=pa.antibody_cd
        AND tr.significance_ind=1)
     ELSE
      FROM person_antibody pa,
       transfusion_requirements tr
      PLAN (pa
       WHERE pa.person_id=personid
        AND pa.active_ind=1)
       JOIN (tr
       WHERE tr.requirement_cd=pa.antibody_cd
        AND tr.significance_ind=1)
     ENDIF
     INTO "nl:"
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET flex_patient_out->anti_exist_ind = 1
    ENDIF
   ENDIF
   IF ((flex_codes->codes_loaded_ind != 1))
    IF (getflexcodesbycdfmeaning(null) != 1)
     CALL log_message("Error calling GetFlexCodesByCDFMeaning.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (((2 * flex_param_out->max_transfusion_end_range) < flex_param_out->max_spec_validity))
    SET earliesttransfusionenddttm = datetimeadd(current_dt_tm,- ((flex_param_out->
     max_transfusion_end_range+ flex_param_out->max_spec_validity)))
   ELSE
    SET earliesttransfusionenddttm = datetimeadd(current_dt_tm,- ((2 * flex_param_out->
     max_transfusion_end_range)))
   ENDIF
   SELECT INTO "nl:"
    FROM transfusion t,
     product p,
     product_index pi,
     product_category pc,
     product_event pe
    PLAN (t
     WHERE t.person_id=personid
      AND t.active_ind=1)
     JOIN (p
     WHERE p.product_id=t.product_id
      AND (p.product_class_cd=flex_codes->blood_product_cd)
      AND p.active_ind=1)
     JOIN (pi
     WHERE pi.product_cd=p.product_cd
      AND pi.active_ind=1)
     JOIN (pc
     WHERE pc.product_cat_cd=pi.product_cat_cd
      AND pc.active_ind=1)
     JOIN (pe
     WHERE pe.product_id=p.product_id
      AND (pe.event_type_cd=flex_codes->transfused_state_cd)
      AND pe.event_dt_tm >= cnvtdatetime(earliesttransfusionenddttm)
      AND ((encntrid > 0.0
      AND pe.encntr_id=encntrid) OR (encntrid=0.0))
      AND pe.active_ind=1)
    ORDER BY pe.event_dt_tm DESC
    HEAD REPORT
     transfusioncount = 0
    HEAD pe.event_dt_tm
     row + 0
    DETAIL
     IF (pi.autologous_ind=0)
      IF (pc.xmatch_required_ind=1)
       transfusioncount += 1
       IF (transfusioncount > size(flex_patient_out->transfusion,5))
        statbbcalcflex = alterlist(flex_patient_out->transfusion,(transfusioncount+ 9))
       ENDIF
       flex_patient_out->transfusion[transfusioncount].transfusion_dt_tm = pe.event_dt_tm
      ENDIF
     ENDIF
    FOOT  pe.event_dt_tm
     row + 0
    FOOT REPORT
     statbbcalcflex = alterlist(flex_patient_out->transfusion,transfusioncount)
    WITH nocounter
   ;end select
   SET flex_patient_out->person_id = personid
   SET flex_patient_out->encntr_id = encntrid
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getcriticaldtstms(null)
   DECLARE criticalrange = i4 WITH protect, noconstant(0)
   DECLARE transfusionflexparamscount = i4 WITH protect, noconstant(0)
   DECLARE transfusionflexparamsindex = i4 WITH protect, noconstant(0)
   DECLARE transcount = i4 WITH protect, noconstant(0)
   DECLARE transindex = i4 WITH protect, noconstant(0)
   IF ((flex_codes->codes_loaded_ind != 1))
    IF (getflexcodesbycdfmeaning(null) != 1)
     CALL log_message("Error calling GetFlexCodesByCDFMeaning.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET transfusionflexparamscount = size(flex_param_out->transfusion_flex_params,5)
   FOR (transfusionflexparamsindex = 1 TO transfusionflexparamscount)
     IF ((flex_param_out->transfusion_flex_params[transfusionflexparamsindex].index=1))
      SET criticalrange = flex_param_out->transfusion_flex_params[transfusionflexparamsindex].
      end_range
      SET transfusionflexparamsindex = transfusionflexparamscount
     ENDIF
   ENDFOR
   SET transcount = size(flex_patient_out->transfusion,5)
   FOR (transindex = 1 TO transcount)
     IF (trim(flex_param_out->expiration_unit_type_mean)="D")
      SET flex_patient_out->transfusion[transindex].critical_dt_tm = datetimeadd(cnvtdatetime(
        cnvtdate(flex_patient_out->transfusion[transindex].transfusion_dt_tm),235959),criticalrange)
     ELSE
      SET flex_patient_out->transfusion[transindex].critical_dt_tm = datetimeadd(flex_patient_out->
       transfusion[transindex].transfusion_dt_tm,criticalrange)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getflexcodesbycdfmeaning(null)
   DECLARE bb_inventory_states_cs = i4 WITH protect, constant(1610)
   DECLARE transfused_state_mean = c12 WITH protect, constant("7")
   DECLARE product_class_cs = i4 WITH protect, constant(1606)
   DECLARE blood_product_mean = c12 WITH protect, constant("BLOOD")
   SET statbbcalcflex = initrec(flex_codes)
   SET flex_codes->codes_loaded_ind = 0
   SET flex_codes->transfused_state_cd = uar_get_code_by("MEANING",bb_inventory_states_cs,nullterm(
     transfused_state_mean))
   IF ((flex_codes->transfused_state_cd <= 0.0))
    CALL log_message("Error getting transfused state cd.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_codes->blood_product_cd = uar_get_code_by("MEANING",product_class_cs,nullterm(
     blood_product_mean))
   IF ((flex_codes->blood_product_cd <= 0.0))
    CALL log_message("Error getting blood product cd.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_codes->codes_loaded_ind = 1
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (getflexexpiration(personid=f8(value),encntrid=f8(value),drawndttm=dq8(value),
  encntrfacilitycd=f8(value),disregarddefaultind=i2(value)) =dq8)
   DECLARE expiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE paramdttm = dq8 WITH protect, noconstant(0.0)
   DECLARE transcount = i4 WITH protect, noconstant(0)
   DECLARE transindex = i4 WITH protect, noconstant(0)
   DECLARE transdttmdrawndttmdiff = i4 WITH protect, noconstant(0)
   DECLARE transflexparamscount = i2 WITH protect, noconstant(0)
   DECLARE transflexparamsindex = i2 WITH protect, noconstant(0)
   DECLARE recalccriticaldttmind = i2 WITH protect, noconstant(0)
   DECLARE prevtestingfaccdhold = f8 WITH protect, noconstant(0.0)
   DECLARE usecritind = i2 WITH protect, noconstant(0)
   IF ((flex_codes->codes_loaded_ind != 1))
    IF (getflexcodesbycdfmeaning(null) != 1)
     CALL log_message("Error calling GetFlexCodesByCDFMeaning.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET prevtestingfaccdhold = flex_param_out->testing_facility_cd
   IF (loadflexparams(encntrfacilitycd) != 1)
    CALL log_message("Error loading flex params.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF ((prevtestingfaccdhold != flex_param_out->testing_facility_cd))
    SET recalccriticaldttmind = 1
   ENDIF
   IF ((((flex_patient_out->person_id != personid)) OR ((flex_patient_out->encntr_id != encntrid))) )
    IF (loadflexpatient(personid,encntrid) != 1)
     CALL log_message("Error loading patient info.",log_level_error)
     RETURN(- (1))
    ENDIF
    SET recalccriticaldttmind = 1
   ENDIF
   IF (recalccriticaldttmind=1)
    IF (getcriticaldtstms(null) != 1)
     CALL log_message("Error loading critical dates/times.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (disregarddefaultind=1)
    IF ((flex_patient_out->anti_exist_ind=1))
     SET flex_param_out->flex_param = flex_param_out->anti_param
    ELSE
     SET flex_param_out->flex_param = - (1)
    ENDIF
   ELSE
    SET flex_param_out->flex_param = flex_param_out->allo_param
    IF ((flex_patient_out->anti_exist_ind=1))
     IF ((flex_param_out->anti_param < flex_param_out->flex_param))
      SET flex_param_out->flex_param = flex_param_out->anti_param
     ENDIF
    ENDIF
   ENDIF
   IF ((flex_param_out->flex_param != - (1)))
    IF (trim(flex_param_out->expiration_unit_type_mean)="D")
     SET expiredttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),flex_param_out->flex_param
      )
    ELSE
     SET expiredttm = datetimeadd(drawndttm,flex_param_out->flex_param)
    ENDIF
   ENDIF
   SET transcount = size(flex_patient_out->transfusion,5)
   SET transflexparamscount = size(flex_param_out->transfusion_flex_params,5)
   FOR (transindex = 1 TO transcount)
     SET usecritind = 0
     IF ((drawndttm < flex_patient_out->transfusion[transindex].transfusion_dt_tm))
      SET usecritind = 1
     ELSEIF ((drawndttm < flex_patient_out->transfusion[transindex].critical_dt_tm))
      IF ((flex_param_out->calc_trans_drawn_dt_ind=0))
       SET usecritind = 1
      ENDIF
     ENDIF
     IF (usecritind=1)
      IF ((((expiredttm > flex_patient_out->transfusion[transindex].critical_dt_tm)) OR (expiredttm=
      0.0)) )
       SET expiredttm = flex_patient_out->transfusion[transindex].critical_dt_tm
      ENDIF
     ELSE
      SET transdttmdrawndttmdiff = ceil(datetimediff(drawndttm,flex_patient_out->transfusion[
        transindex].transfusion_dt_tm))
      FOR (transflexparamsindex = 1 TO transflexparamscount)
        IF ((transdttmdrawndttmdiff >= flex_param_out->transfusion_flex_params[transflexparamsindex].
        start_range)
         AND (transdttmdrawndttmdiff <= flex_param_out->transfusion_flex_params[transflexparamsindex]
        .end_range))
         IF (trim(flex_param_out->expiration_unit_type_mean)="D")
          SET paramdttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),flex_param_out->
           transfusion_flex_params[transflexparamsindex].flex_param)
         ELSE
          SET paramdttm = datetimeadd(drawndttm,flex_param_out->transfusion_flex_params[
           transflexparamsindex].flex_param)
         ENDIF
         IF (((expiredttm > paramdttm) OR (expiredttm=0.0)) )
          SET expiredttm = paramdttm
         ENDIF
         SET transflexparamsindex = transflexparamscount
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   RETURN(expiredttm)
 END ;Subroutine
 SUBROUTINE (getflexmaxexpiration(personid=f8(value),encntrid=f8(value),drawndttm=dq8(value),
  encntrfacilitycd=f8(value)) =i2)
   DECLARE expiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE paramdttm = dq8 WITH protect, noconstant(0.0)
   DECLARE transcount = i4 WITH protect, noconstant(0)
   DECLARE transindex = i4 WITH protect, noconstant(0)
   DECLARE transdttmdrawndttmdiff = i4 WITH protect, noconstant(0)
   DECLARE transflexparamscount = i2 WITH protect, noconstant(0)
   DECLARE transflexparamsindex = i2 WITH protect, noconstant(0)
   DECLARE recalccriticaldttmind = i2 WITH protect, noconstant(0)
   DECLARE prevtestingfaccdhold = f8 WITH protect, noconstant(0.0)
   DECLARE usecritind = i2 WITH protect, noconstant(0)
   DECLARE maxparamexpiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE transexpiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE nantiparamind = i2 WITH protect, noconstant(0)
   DECLARE ntransparamind = i2 WITH protect, noconstant(0)
   DECLARE calcflexparam = i4 WITH protect, noconstant(0)
   IF ((flex_codes->codes_loaded_ind != 1))
    IF (getflexcodesbycdfmeaning(null) != 1)
     CALL log_message("Error calling GetFlexCodesByCDFMeaning.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET statbbcalcflex = initrec(flex_max_out)
   SET prevtestingfaccdhold = flex_param_out->testing_facility_cd
   IF (loadflexparams(encntrfacilitycd) != 1)
    CALL log_message("Error loading flex params.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF ((prevtestingfaccdhold != flex_param_out->testing_facility_cd))
    SET recalccriticaldttmind = 1
   ENDIF
   IF ((((flex_patient_out->person_id != personid)) OR ((flex_patient_out->encntr_id != encntrid))) )
    IF (loadflexpatient(personid,encntrid) != 1)
     CALL log_message("Error loading patient info.",log_level_error)
     RETURN(- (1))
    ENDIF
    SET recalccriticaldttmind = 1
   ENDIF
   IF (recalccriticaldttmind=1)
    IF (getcriticaldtstms(null) != 1)
     CALL log_message("Error loading critical dates/times.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET calcflexparam = flex_param_out->max_spec_validity
   IF ((flex_patient_out->anti_exist_ind=1))
    IF ((flex_param_out->anti_param < calcflexparam))
     SET calcflexparam = flex_param_out->anti_param
     SET nantiparamind = 1
    ENDIF
   ENDIF
   IF (trim(flex_param_out->expiration_unit_type_mean)="D")
    SET maxparamexpiredttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),calcflexparam)
   ELSE
    SET maxparamexpiredttm = datetimeadd(drawndttm,calcflexparam)
   ENDIF
   SET transcount = size(flex_patient_out->transfusion,5)
   SET transflexparamscount = size(flex_param_out->transfusion_flex_params,5)
   SET transexpiredttm = maxparamexpiredttm
   FOR (transindex = 1 TO transcount)
     SET usecritind = 0
     IF ((drawndttm < flex_patient_out->transfusion[transindex].transfusion_dt_tm))
      SET usecritind = 1
     ELSEIF ((drawndttm < flex_patient_out->transfusion[transindex].critical_dt_tm))
      IF ((flex_param_out->calc_trans_drawn_dt_ind=0))
       SET usecritind = 1
      ENDIF
     ENDIF
     IF (usecritind=1)
      IF ((transexpiredttm > flex_patient_out->transfusion[transindex].critical_dt_tm))
       SET transexpiredttm = flex_patient_out->transfusion[transindex].critical_dt_tm
       SET ntransparamind = 1
      ENDIF
     ELSE
      SET transdttmdrawndttmdiff = ceil(datetimediff(drawndttm,flex_patient_out->transfusion[
        transindex].transfusion_dt_tm))
      FOR (transflexparamsindex = 1 TO transflexparamscount)
        IF ((transdttmdrawndttmdiff >= flex_param_out->transfusion_flex_params[transflexparamsindex].
        start_range)
         AND (transdttmdrawndttmdiff <= flex_param_out->transfusion_flex_params[transflexparamsindex]
        .end_range))
         IF (trim(flex_param_out->expiration_unit_type_mean)="D")
          SET paramdttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),flex_param_out->
           transfusion_flex_params[transflexparamsindex].flex_param)
         ELSE
          SET paramdttm = datetimeadd(drawndttm,flex_param_out->transfusion_flex_params[
           transflexparamsindex].flex_param)
         ENDIF
         IF (transexpiredttm > paramdttm)
          SET transexpiredttm = paramdttm
          SET ntransparamind = 1
         ENDIF
         SET transflexparamsindex = transflexparamscount
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (ntransparamind=1)
    IF ((flex_param_out->extend_trans_ovrd_ind=0))
     SET flex_max_out->max_expire_dt_tm = cnvtdatetime(transexpiredttm)
     SET flex_max_out->max_expire_flag = ntrans_flag
    ELSE
     SET flex_max_out->max_expire_dt_tm = cnvtdatetime(maxparamexpiredttm)
     IF (nantiparamind=0)
      SET flex_max_out->max_expire_flag = nmax_param_flag
     ELSE
      SET flex_max_out->max_expire_flag = nanti_flag
     ENDIF
    ENDIF
   ELSEIF (nantiparamind=1)
    SET flex_max_out->max_expire_dt_tm = cnvtdatetime(maxparamexpiredttm)
    SET flex_max_out->max_expire_flag = nanti_flag
   ELSE
    SET flex_max_out->max_expire_dt_tm = cnvtdatetime(maxparamexpiredttm)
    SET flex_max_out->max_expire_flag = nmax_param_flag
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (getflexexpirationforperson(personid=f8(value),encntrid=f8(value),drawndttm=dq8(value),
  encntrfacilitycd=f8(value),disregarddefaultind=i2(value)) =dq8)
   DECLARE expiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE paramdttm = dq8 WITH protect, noconstant(0.0)
   DECLARE transcount = i4 WITH protect, noconstant(0)
   DECLARE transindex = i4 WITH protect, noconstant(0)
   DECLARE transdttmdrawndttmdiff = i4 WITH protect, noconstant(0)
   DECLARE transflexparamscount = i2 WITH protect, noconstant(0)
   DECLARE transflexparamsindex = i2 WITH protect, noconstant(0)
   DECLARE recalccriticaldttmind = i2 WITH protect, noconstant(0)
   DECLARE prevtestingfaccdhold = f8 WITH protect, noconstant(0.0)
   DECLARE usecritind = i2 WITH protect, noconstant(0)
   IF ((flex_codes->codes_loaded_ind != 1))
    IF (getflexcodesbycdfmeaning(null) != 1)
     CALL log_message("Error calling GetFlexCodesByCDFMeaning.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET prevtestingfaccdhold = flex_param_out->testing_facility_cd
   IF ((prevtestingfaccdhold != flex_param_out->testing_facility_cd))
    SET recalccriticaldttmind = 1
   ENDIF
   IF ((((flex_patient_out->person_id != personid)) OR ((flex_patient_out->encntr_id != encntrid))) )
    IF (loadflexpatient(personid,encntrid) != 1)
     CALL log_message("Error loading patient info.",log_level_error)
     RETURN(- (1))
    ENDIF
    SET recalccriticaldttmind = 1
   ENDIF
   IF (recalccriticaldttmind=1)
    IF (getcriticaldtstms(null) != 1)
     CALL log_message("Error loading critical dates/times.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (disregarddefaultind=1)
    IF ((flex_patient_out->anti_exist_ind=1))
     SET flex_param_out->flex_param = flex_param_out->anti_param
    ELSE
     SET flex_param_out->flex_param = - (1)
    ENDIF
   ELSE
    SET flex_param_out->flex_param = flex_param_out->allo_param
    IF ((flex_patient_out->anti_exist_ind=1))
     IF ((flex_param_out->anti_param < flex_param_out->flex_param))
      SET flex_param_out->flex_param = flex_param_out->anti_param
     ENDIF
    ENDIF
   ENDIF
   IF ((flex_param_out->flex_param != - (1)))
    IF (trim(flex_param_out->expiration_unit_type_mean)="D")
     SET expiredttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),flex_param_out->flex_param
      )
    ELSE
     SET expiredttm = datetimeadd(drawndttm,flex_param_out->flex_param)
    ENDIF
   ENDIF
   SET transcount = size(flex_patient_out->transfusion,5)
   SET transflexparamscount = size(flex_param_out->transfusion_flex_params,5)
   FOR (transindex = 1 TO transcount)
     SET usecritind = 0
     IF ((drawndttm < flex_patient_out->transfusion[transindex].transfusion_dt_tm))
      SET usecritind = 1
     ELSEIF ((drawndttm < flex_patient_out->transfusion[transindex].critical_dt_tm))
      IF ((flex_param_out->calc_trans_drawn_dt_ind=0))
       SET usecritind = 1
      ENDIF
     ENDIF
     IF (usecritind=1)
      IF ((((expiredttm > flex_patient_out->transfusion[transindex].critical_dt_tm)) OR (expiredttm=
      0.0)) )
       SET expiredttm = flex_patient_out->transfusion[transindex].critical_dt_tm
      ENDIF
     ELSE
      SET transdttmdrawndttmdiff = ceil(datetimediff(drawndttm,flex_patient_out->transfusion[
        transindex].transfusion_dt_tm))
      FOR (transflexparamsindex = 1 TO transflexparamscount)
        IF ((transdttmdrawndttmdiff >= flex_param_out->transfusion_flex_params[transflexparamsindex].
        start_range)
         AND (transdttmdrawndttmdiff <= flex_param_out->transfusion_flex_params[transflexparamsindex]
        .end_range))
         IF (trim(flex_param_out->expiration_unit_type_mean)="D")
          SET paramdttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),flex_param_out->
           transfusion_flex_params[transflexparamsindex].flex_param)
         ELSE
          SET paramdttm = datetimeadd(drawndttm,flex_param_out->transfusion_flex_params[
           transflexparamsindex].flex_param)
         ENDIF
         IF (((expiredttm > paramdttm) OR (expiredttm=0.0)) )
          SET expiredttm = paramdttm
         ENDIF
         SET transflexparamsindex = transflexparamscount
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   RETURN(expiredttm)
 END ;Subroutine
 SUBROUTINE (getflexmaxexpirationforperson(personid=f8(value),encntrid=f8(value),drawndttm=dq8(value),
  encntrfacilitycd=f8(value)) =i2)
   DECLARE expiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE paramdttm = dq8 WITH protect, noconstant(0.0)
   DECLARE transcount = i4 WITH protect, noconstant(0)
   DECLARE transindex = i4 WITH protect, noconstant(0)
   DECLARE transdttmdrawndttmdiff = i4 WITH protect, noconstant(0)
   DECLARE transflexparamscount = i2 WITH protect, noconstant(0)
   DECLARE transflexparamsindex = i2 WITH protect, noconstant(0)
   DECLARE recalccriticaldttmind = i2 WITH protect, noconstant(0)
   DECLARE prevtestingfaccdhold = f8 WITH protect, noconstant(0.0)
   DECLARE usecritind = i2 WITH protect, noconstant(0)
   DECLARE maxparamexpiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE transexpiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE nantiparamind = i2 WITH protect, noconstant(0)
   DECLARE ntransparamind = i2 WITH protect, noconstant(0)
   DECLARE calcflexparam = i4 WITH protect, noconstant(0)
   IF ((flex_codes->codes_loaded_ind != 1))
    IF (getflexcodesbycdfmeaning(null) != 1)
     CALL log_message("Error calling GetFlexCodesByCDFMeaning.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET statbbcalcflex = initrec(flex_max_out)
   SET prevtestingfaccdhold = flex_param_out->testing_facility_cd
   IF ((prevtestingfaccdhold != flex_param_out->testing_facility_cd))
    SET recalccriticaldttmind = 1
   ENDIF
   IF ((((flex_patient_out->person_id != personid)) OR ((flex_patient_out->encntr_id != encntrid))) )
    IF (loadflexpatient(personid,encntrid) != 1)
     CALL log_message("Error loading patient info.",log_level_error)
     RETURN(- (1))
    ENDIF
    SET recalccriticaldttmind = 1
   ENDIF
   IF (recalccriticaldttmind=1)
    IF (getcriticaldtstms(null) != 1)
     CALL log_message("Error loading critical dates/times.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET calcflexparam = flex_param_out->max_spec_validity
   IF ((flex_patient_out->anti_exist_ind=1))
    IF ((flex_param_out->anti_param < calcflexparam))
     SET calcflexparam = flex_param_out->anti_param
     SET nantiparamind = 1
    ENDIF
   ENDIF
   IF (trim(flex_param_out->expiration_unit_type_mean)="D")
    SET maxparamexpiredttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),calcflexparam)
   ELSE
    SET maxparamexpiredttm = datetimeadd(drawndttm,calcflexparam)
   ENDIF
   SET transcount = size(flex_patient_out->transfusion,5)
   SET transflexparamscount = size(flex_param_out->transfusion_flex_params,5)
   SET transexpiredttm = maxparamexpiredttm
   FOR (transindex = 1 TO transcount)
     SET usecritind = 0
     IF ((drawndttm < flex_patient_out->transfusion[transindex].transfusion_dt_tm))
      SET usecritind = 1
     ELSEIF ((drawndttm < flex_patient_out->transfusion[transindex].critical_dt_tm))
      IF ((flex_param_out->calc_trans_drawn_dt_ind=0))
       SET usecritind = 1
      ENDIF
     ENDIF
     IF (usecritind=1)
      IF ((transexpiredttm > flex_patient_out->transfusion[transindex].critical_dt_tm))
       SET transexpiredttm = flex_patient_out->transfusion[transindex].critical_dt_tm
       SET ntransparamind = 1
      ENDIF
     ELSE
      SET transdttmdrawndttmdiff = ceil(datetimediff(drawndttm,flex_patient_out->transfusion[
        transindex].transfusion_dt_tm))
      FOR (transflexparamsindex = 1 TO transflexparamscount)
        IF ((transdttmdrawndttmdiff >= flex_param_out->transfusion_flex_params[transflexparamsindex].
        start_range)
         AND (transdttmdrawndttmdiff <= flex_param_out->transfusion_flex_params[transflexparamsindex]
        .end_range))
         IF (trim(flex_param_out->expiration_unit_type_mean)="D")
          SET paramdttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),flex_param_out->
           transfusion_flex_params[transflexparamsindex].flex_param)
         ELSE
          SET paramdttm = datetimeadd(drawndttm,flex_param_out->transfusion_flex_params[
           transflexparamsindex].flex_param)
         ENDIF
         IF (transexpiredttm > paramdttm)
          SET transexpiredttm = paramdttm
          SET ntransparamind = 1
         ENDIF
         SET transflexparamsindex = transflexparamscount
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (ntransparamind=1)
    IF ((flex_param_out->extend_trans_ovrd_ind=0))
     SET flex_max_out->max_expire_dt_tm = cnvtdatetime(transexpiredttm)
     SET flex_max_out->max_expire_flag = ntrans_flag
    ELSE
     SET flex_max_out->max_expire_dt_tm = cnvtdatetime(maxparamexpiredttm)
     IF (nantiparamind=0)
      SET flex_max_out->max_expire_flag = nmax_param_flag
     ELSE
      SET flex_max_out->max_expire_flag = nanti_flag
     ENDIF
    ENDIF
   ELSEIF (nantiparamind=1)
    SET flex_max_out->max_expire_dt_tm = cnvtdatetime(maxparamexpiredttm)
    SET flex_max_out->max_expire_flag = nanti_flag
   ELSE
    SET flex_max_out->max_expire_dt_tm = cnvtdatetime(maxparamexpiredttm)
    SET flex_max_out->max_expire_flag = nmax_param_flag
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (getflexspecimenparams(facilityindex=i4(value),enc_facility_cd=f8(value),addreadind=i2(
   value),appkey=c10(value)) =null)
   DECLARE transparamscount = i4 WITH protect, noconstant(0)
   SET facilityinfo->facilities[facilityindex].load_flex_params = 1
   IF (addreadind=1)
    IF ((loadflexparams(enc_facility_cd)=- (1)))
     SET facilityinfo->facilities[facilityindex].load_flex_params = - (1)
     CALL log_message("Error loading flex params.",log_level_error)
    ENDIF
    SET facilityinfo->facilities[facilityindex].testing_facility_cd = flex_param_out->
    testing_facility_cd
    SET facilityinfo->facilities[facilityindex].flex_on_ind = flex_param_out->flex_on_ind
    SET facilityinfo->facilities[facilityindex].flex_param = flex_param_out->flex_param
    SET facilityinfo->facilities[facilityindex].allo_param = flex_param_out->allo_param
    SET facilityinfo->facilities[facilityindex].auto_param = flex_param_out->auto_param
    SET facilityinfo->facilities[facilityindex].anti_flex_ind = flex_param_out->anti_flex_ind
    SET facilityinfo->facilities[facilityindex].anti_param = flex_param_out->anti_param
    SET facilityinfo->facilities[facilityindex].max_spec_validity = flex_param_out->max_spec_validity
    SET facilityinfo->facilities[facilityindex].expiration_unit_type_mean = flex_param_out->
    expiration_unit_type_mean
    SET facilityinfo->facilities[facilityindex].max_transfusion_end_range = flex_param_out->
    max_transfusion_end_range
    SET facilityinfo->facilities[facilityindex].extend_trans_ovrd_ind = flex_param_out->
    extend_trans_ovrd_ind
    SET facilityinfo->facilities[facilityindex].calc_trans_drawn_dt_ind = flex_param_out->
    calc_trans_drawn_dt_ind
    SET facilityinfo->facilities[facilityindex].neonate_age = flex_param_out->neonate_age
    SET transparamscount = size(flex_param_out->transfusion_flex_params,5)
    SET stat = alterlist(facilityinfo->facilities[facilityindex].transfusion_flex_params,
     transparamscount)
    FOR (x_idx = 1 TO transparamscount)
      SET facilityinfo->facilities[facilityindex].transfusion_flex_params[x_idx].index =
      flex_param_out->transfusion_flex_params[x_idx].index
      SET facilityinfo->facilities[facilityindex].transfusion_flex_params[x_idx].start_range =
      flex_param_out->transfusion_flex_params[x_idx].start_range
      SET facilityinfo->facilities[facilityindex].transfusion_flex_params[x_idx].end_range =
      flex_param_out->transfusion_flex_params[x_idx].end_range
      SET facilityinfo->facilities[facilityindex].transfusion_flex_params[x_idx].flex_param =
      flex_param_out->transfusion_flex_params[x_idx].flex_param
    ENDFOR
    IF (trim(appkey)="AVAILSPECS")
     SET facilityinfo->facilities[facilityindex].extend_expired_specimen =
     bbtgetflexexpiredspecimenexpirationovrd(facilityinfo->facilities[facilityindex].
      testing_facility_cd)
     SET facilityinfo->facilities[facilityindex].extend_neonate_disch_spec =
     bbtgetflexexpiredspecimenneonatedischarge(facilityinfo->facilities[facilityindex].
      testing_facility_cd)
    ENDIF
   ELSE
    SET flex_param_out->testing_facility_cd = facilityinfo->facilities[facilityindex].
    testing_facility_cd
    SET flex_param_out->flex_on_ind = facilityinfo->facilities[facilityindex].flex_on_ind
    SET flex_param_out->flex_param = facilityinfo->facilities[facilityindex].flex_param
    SET flex_param_out->allo_param = facilityinfo->facilities[facilityindex].allo_param
    SET flex_param_out->auto_param = facilityinfo->facilities[facilityindex].auto_param
    SET flex_param_out->anti_flex_ind = facilityinfo->facilities[facilityindex].anti_flex_ind
    SET flex_param_out->anti_param = facilityinfo->facilities[facilityindex].anti_param
    SET flex_param_out->max_spec_validity = facilityinfo->facilities[facilityindex].max_spec_validity
    SET flex_param_out->expiration_unit_type_mean = facilityinfo->facilities[facilityindex].
    expiration_unit_type_mean
    SET flex_param_out->max_transfusion_end_range = facilityinfo->facilities[facilityindex].
    max_transfusion_end_range
    SET flex_param_out->extend_trans_ovrd_ind = facilityinfo->facilities[facilityindex].
    extend_trans_ovrd_ind
    SET flex_param_out->calc_trans_drawn_dt_ind = facilityinfo->facilities[facilityindex].
    calc_trans_drawn_dt_ind
    SET flex_param_out->neonate_age = facilityinfo->facilities[facilityindex].neonate_age
    SET transparamscount = size(facilityinfo->facilities[facilityindex].transfusion_flex_params,5)
    SET stat = alterlist(flex_param_out->transfusion_flex_params,transparamscount)
    FOR (x_idx = 1 TO transparamscount)
      SET flex_param_out->transfusion_flex_params[x_idx].index = facilityinfo->facilities[
      facilityindex].transfusion_flex_params[x_idx].index
      SET flex_param_out->transfusion_flex_params[x_idx].start_range = facilityinfo->facilities[
      facilityindex].transfusion_flex_params[x_idx].start_range
      SET flex_param_out->transfusion_flex_params[x_idx].end_range = facilityinfo->facilities[
      facilityindex].transfusion_flex_params[x_idx].end_range
      SET flex_param_out->transfusion_flex_params[x_idx].flex_param = facilityinfo->facilities[
      facilityindex].transfusion_flex_params[x_idx].flex_param
    ENDFOR
   ENDIF
 END ;Subroutine
 RECORD modxm_request(
   1 productlist[*]
     2 product_id = f8
     2 product_event_id = f8
     2 xm_exp_dt_tm = dq8
     2 pe_xm_updt_cnt = i4
     2 xm_updt_cnt = i4
     2 p_updt_cnt = i4
     2 reinstate_reason_cd = f8
   1 more_processing_ind = i2
 )
 RECORD modxm_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 results[1]
     2 product_event_id = f8
     2 new_product_event_id = f8
     2 status = c1
     2 err_process = vc
     2 err_message = vc
 )
 RECORD unique_prods(
   1 products[*]
     2 product_id = f8
 )
 DECLARE nmodxmprodcnt = i2 WITH protect, noconstant(0)
 DECLARE unlockxmproducts() = i2
 SUBROUTINE (addmodxmproduct(product_id=f8(value),product_event_id=f8(value),xm_exp_dt_tm=dq8(value),
  reason_cd=f8(value)) =null)
   DECLARE lstat = i4 WITH protect, noconstant(0)
   SET nmodxmprodcnt += 1
   IF (nmodxmprodcnt > size(modxm_request->productlist,5))
    SET lstat = alterlist(modxm_request->productlist,(nmodxmprodcnt+ 9))
   ENDIF
   SET modxm_request->productlist[nmodxmprodcnt].product_id = product_id
   SET modxm_request->productlist[nmodxmprodcnt].product_event_id = product_event_id
   SET modxm_request->productlist[nmodxmprodcnt].xm_exp_dt_tm = xm_exp_dt_tm
   SET modxm_request->productlist[nmodxmprodcnt].reinstate_reason_cd = reason_cd
 END ;Subroutine
 SUBROUTINE (modxmproducts(lock_prods_ind=i2(value)) =i2)
   DECLARE lstat = i4 WITH protect, noconstant(0)
   DECLARE nprodcnt = i2 WITH protect, noconstant(0)
   DECLARE nerrorind = i2 WITH protect, noconstant(0)
   DECLARE nfoundcnt = i2 WITH protect, noconstant(0)
   IF (nmodxmprodcnt > 0)
    SET lstat = alterlist(modxm_request->productlist,nmodxmprodcnt)
    SELECT INTO "nl:"
     pe.updt_cnt, xm.updt_cnt, p.product_id
     FROM (dummyt d1  WITH seq = value(nmodxmprodcnt)),
      product p,
      product_event pe,
      crossmatch xm
     PLAN (d1)
      JOIN (pe
      WHERE (pe.product_event_id=modxm_request->productlist[d1.seq].product_event_id))
      JOIN (xm
      WHERE xm.product_event_id=pe.product_event_id)
      JOIN (p
      WHERE p.product_id=pe.product_id)
     ORDER BY p.product_id
     HEAD p.product_id
      nprodcnt += 1
      IF (nprodcnt > size(unique_prods->products,5))
       lstat = alterlist(unique_prods->products,(nprodcnt+ 9))
      ENDIF
      unique_prods->products[nprodcnt].product_id = p.product_id
     DETAIL
      nfoundcnt += 1, modxm_request->productlist[d1.seq].pe_xm_updt_cnt = pe.updt_cnt, modxm_request
      ->productlist[d1.seq].xm_updt_cnt = xm.updt_cnt
      IF (lock_prods_ind=1)
       modxm_request->productlist[d1.seq].p_updt_cnt = (p.updt_cnt+ 1)
      ELSE
       modxm_request->productlist[d1.seq].p_updt_cnt = p.updt_cnt
      ENDIF
     WITH counter
    ;end select
    IF (nfoundcnt != nmodxmprodcnt)
     SET nerrorind = 1
     CALL log_message("XM Not found",log_level_audit)
    ELSE
     SET nerrorind = error_message(1)
     IF (nerrorind=0)
      SET modxm_request->more_processing_ind = 1
      SET lstat = alterlist(unique_prods->products,nprodcnt)
      IF (lock_prods_ind=1)
       CALL log_message("Locking XM Products",log_level_debug)
       SELECT INTO "nl:"
        p.product_id
        FROM (dummyt d1  WITH seq = value(nprodcnt)),
         product p
        PLAN (d1)
         JOIN (p
         WHERE (p.product_id=unique_prods->products[d1.seq].product_id)
          AND p.locked_ind=1
          AND p.product_id > 0)
        WITH forupdate(p)
       ;end select
       SET nerrorind = error_message(1)
       IF (nerrorind=0)
        UPDATE  FROM product p,
          (dummyt d1  WITH seq = value(nprodcnt))
         SET p.locked_ind = 1, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(sysdate),
          p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
          updt_applctx
         PLAN (d1)
          JOIN (p
          WHERE (p.product_id=unique_prods->products[d1.seq].product_id))
         WITH nocounter
        ;end update
        SET nerrorind = error_message(1)
        IF (nerrorind=0)
         COMMIT
        ENDIF
       ENDIF
      ENDIF
      IF (nerrorind=0)
       CALL log_message("Calling bbt_chg_event_reinstate",log_level_debug)
       SET modify = nopredeclare
       EXECUTE bbt_chg_event_reinstate  WITH replace("REQUEST","MODXM_REQUEST"), replace("REPLY",
        "MODXM_REPLY")
       SET modify = predeclare
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (nerrorind=0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE unlockxmproducts(null)
   DECLARE nprodcnt = i2 WITH protect, noconstant(0)
   DECLARE nerrorind = i2 WITH protect, noconstant(0)
   SET nprodcnt = size(unique_prods->products,5)
   IF (nprodcnt > 0)
    SELECT INTO "nl:"
     p.product_id
     FROM (dummyt d1  WITH seq = value(nprodcnt)),
      product p
     PLAN (d1)
      JOIN (p
      WHERE (p.product_id=unique_prods->products[d1.seq].product_id)
       AND p.locked_ind=1
       AND p.product_id > 0)
     WITH forupdate(p)
    ;end select
    SET nerrorind = error_message(1)
    IF (nerrorind=0)
     UPDATE  FROM product p,
       (dummyt d1  WITH seq = value(nprodcnt))
      SET p.locked_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(sysdate),
       p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
       updt_applctx
      PLAN (d1)
       JOIN (p
       WHERE (p.product_id=unique_prods->products[d1.seq].product_id))
      WITH nocounter
     ;end update
     SET nerrorind = error_message(1)
    ENDIF
   ENDIF
   IF (nerrorind=0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_bb_exception(sub_person_id=f8,sub_order_id=f8,sub_exception_prsnl_id=f8,
  exception_dt_tm=dq8,prod_event_id=f8,exception_type_mean=vc,sub_override_reason_cd=f8,
  sub_event_type_cd=f8,sub_result_id=f8,sub_perform_result_id=f8,sub_from_abo_cd=f8,sub_from_rh_cd=f8,
  sub_to_abo_cd=f8,sub_to_rh_cd=f8,sub_default_expiration_dt_tm=dq8) =null)
   SET exception_status = "I"
   SET sub_exception_type_cd = 0.0
   DECLARE sub_bb_exception_id = f8 WITH protect, noconstant(0.0)
   DECLARE except_type_mean = c12
   SET except_type_mean = fillstring(12," ")
   SET except_type_mean = exception_type_mean
   SET stat = uar_get_meaning_by_codeset(14072,nullterm(except_type_mean),1,sub_exception_type_cd)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   SET sub_bb_exception_id = new_pathnet_seq
   INSERT  FROM bb_exception b
    SET b.exception_id = sub_bb_exception_id, b.product_event_id = prod_event_id, b.exception_type_cd
      = sub_exception_type_cd,
     b.event_type_cd = sub_event_type_cd, b.from_abo_cd = sub_from_abo_cd, b.from_rh_cd =
     sub_from_rh_cd,
     b.to_abo_cd = sub_to_abo_cd, b.to_rh_cd = sub_to_rh_cd, b.override_reason_cd =
     sub_override_reason_cd,
     b.result_id = sub_result_id, b.perform_result_id = sub_perform_result_id, b.updt_cnt = 0,
     b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->
     updt_task,
     b.updt_applctx = reqinfo->updt_applctx, b.active_ind = 1, b.active_status_cd = reqdata->
     active_status_cd,
     b.active_status_dt_tm = cnvtdatetime(sysdate), b.active_status_prsnl_id = reqinfo->updt_id, b
     .donor_contact_id = 0.0,
     b.donor_contact_type_cd = 0.0, b.order_id = sub_order_id, b.exception_prsnl_id =
     sub_exception_prsnl_id,
     b.exception_dt_tm = cnvtdatetime(exception_dt_tm), b.person_id = sub_person_id, b
     .default_expire_dt_tm = cnvtdatetime(sub_default_expiration_dt_tm)
    WITH counter
   ;end insert
   SET bb_exception_id = sub_bb_exception_id
   IF (curqual=0)
    SET exception_status = "F"
   ELSE
    SET exception_status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_tag_mismatch_exception(tag_product_nbr=vc,tag_div_chars=vc,tag_product_type_cd=f8) =
  null)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   DECLARE sub_bb_exception_id = f8 WITH protect, noconstant(0.0)
   SET sub_bb_exception_id = bb_exception_id
   INSERT  FROM bb_tag_verify_excpn tv
    SET tv.bb_tag_verify_excpn_id = new_pathnet_seq, tv.exception_id = sub_bb_exception_id, tv
     .tag_product_sub_nbr_txt = tag_div_chars,
     tv.tag_product_nbr_txt = tag_product_nbr, tv.tag_product_type_cd = tag_product_type_cd, tv
     .updt_id = reqinfo->updt_id,
     tv.updt_task = reqinfo->updt_task, tv.updt_applctx = reqinfo->updt_applctx, tv.updt_cnt = 0
    WITH counter
   ;end insert
   IF (curqual=0)
    SET exception_status = "F"
   ELSE
    SET exception_status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_invd_prod_ord_exception(product_order_id=f8) =null)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   DECLARE sub_bb_exception_id = f8 WITH protect, noconstant(0.0)
   SET sub_bb_exception_id = bb_exception_id
   INSERT  FROM bb_invld_prod_ord_exceptn b
    SET b.bb_invld_prod_ord_exceptn_id = new_pathnet_seq, b.exception_id = sub_bb_exception_id, b
     .product_order_id = product_order_id,
     b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
    WITH counter
   ;end insert
   IF (curqual=0)
    SET exception_status = "F"
   ELSE
    SET exception_status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE add_reqs_exception(sub_special_testing_cd,sub_requirement_cd)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   DECLARE sub_bb_exception_id = f8 WITH protect, noconstant(0.0)
   SET sub_bb_exception_id = bb_exception_id
   INSERT  FROM bb_reqs_exception b
    SET b.reqs_exception_id = new_pathnet_seq, b.exception_id = sub_bb_exception_id, b
     .special_testing_cd = sub_special_testing_cd,
     b.requirement_cd = sub_requirement_cd, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(sysdate),
     b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
     updt_applctx,
     b.active_ind = 1, b.active_status_cd = reqdata->active_status_cd, b.active_status_dt_tm =
     cnvtdatetime(sysdate),
     b.active_status_prsnl_id = reqinfo->updt_id
    WITH counter
   ;end insert
   IF (curqual=0)
    SET exception_status = "F"
   ELSE
    SET exception_status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE add_autodir_reqs_exception(sub_product_id)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   DECLARE sub_bb_exception_id = f8 WITH protect, noconstant(0.0)
   SET sub_bb_exception_id = bb_exception_id
   INSERT  FROM bb_autodir_exception b
    SET b.bb_autodir_exc_id = new_pathnet_seq, b.bb_exception_id = sub_bb_exception_id, b.product_id
      = sub_product_id,
     b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.active_ind = 1,
     b.active_status_cd = reqdata->active_status_cd, b.active_status_dt_tm = cnvtdatetime(sysdate), b
     .active_status_prsnl_id = reqinfo->updt_id
    WITH counter
   ;end insert
   IF (curqual=0)
    SET exception_status = "F"
   ELSE
    SET exception_status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_bb_inactive_exception(sub_person_id=f8,sub_order_id=f8,sub_exception_prsnl_id=f8,
  exception_dt_tm=dq8,prod_event_id=f8,exception_type_mean=vc,sub_override_reason_cd=f8,
  sub_event_type_cd=f8,sub_result_id=f8,sub_perform_result_id=f8,sub_from_abo_cd=f8,sub_from_rh_cd=f8,
  sub_to_abo_cd=f8,sub_to_rh_cd=f8,sub_default_expiration_dt_tm=dq8) =null)
   SET exception_status = "I"
   DECLARE sub_exception_type_cd = f8 WITH protect, noconstant(0.0)
   DECLARE sub_bb_exception_id = f8 WITH protect, noconstant(0.0)
   DECLARE except_type_mean = c12
   SET except_type_mean = fillstring(12," ")
   SET except_type_mean = exception_type_mean
   SET stat = uar_get_meaning_by_codeset(14072,nullterm(except_type_mean),1,sub_exception_type_cd)
   IF (sub_exception_type_cd=0.0)
    SET exception_status = "FU"
   ELSE
    DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
    SET new_pathnet_seq = 0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_pathnet_seq = seqn
     WITH format, nocounter
    ;end select
    SET sub_bb_exception_id = new_pathnet_seq
    INSERT  FROM bb_exception b
     SET b.exception_id = sub_bb_exception_id, b.product_event_id = prod_event_id, b
      .exception_type_cd = sub_exception_type_cd,
      b.event_type_cd = sub_event_type_cd, b.from_abo_cd = sub_from_abo_cd, b.from_rh_cd =
      sub_from_rh_cd,
      b.to_abo_cd = sub_to_abo_cd, b.to_rh_cd = sub_to_rh_cd, b.override_reason_cd =
      sub_override_reason_cd,
      b.result_id = sub_result_id, b.perform_result_id = sub_perform_result_id, b.updt_cnt = 0,
      b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->
      updt_task,
      b.updt_applctx = reqinfo->updt_applctx, b.active_ind = 0, b.active_status_cd = reqdata->
      inactive_status_cd,
      b.active_status_dt_tm = cnvtdatetime(sysdate), b.active_status_prsnl_id = reqinfo->updt_id, b
      .donor_contact_id = 0.0,
      b.donor_contact_type_cd = 0.0, b.order_id = sub_order_id, b.exception_prsnl_id =
      sub_exception_prsnl_id,
      b.exception_dt_tm = cnvtdatetime(exception_dt_tm), b.person_id = sub_person_id, b
      .default_expire_dt_tm = cnvtdatetime(sub_default_expiration_dt_tm)
     WITH counter
    ;end insert
    SET bb_exception_id = sub_bb_exception_id
    IF (curqual=0)
     SET exception_status = "F"
    ELSE
     SET exception_status = "S"
    ENDIF
   ENDIF
 END ;Subroutine
 DECLARE add_inactive_reqs_exception(sub_special_testing_cd,sub_requirement_cd) = null
 SUBROUTINE add_inactive_reqs_exception(sub_special_testing_cd,sub_requirement_cd)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   DECLARE sub_bb_exception_id = f8 WITH protect, noconstant(0.0)
   SET sub_bb_exception_id = bb_exception_id
   INSERT  FROM bb_reqs_exception b
    SET b.reqs_exception_id = new_pathnet_seq, b.exception_id = sub_bb_exception_id, b
     .special_testing_cd = sub_special_testing_cd,
     b.requirement_cd = sub_requirement_cd, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(sysdate),
     b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
     updt_applctx,
     b.active_ind = 0, b.active_status_cd = reqdata->inactive_status_cd, b.active_status_dt_tm =
     cnvtdatetime(sysdate),
     b.active_status_prsnl_id = reqinfo->updt_id
    WITH counter
   ;end insert
   IF (curqual=0)
    SET exception_status = "F"
   ELSE
    SET exception_status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE (activate_bb_exception(sub_exception_id=f8,updt_cnt=i4) =null)
   SET exception_status = "I"
   SELECT INTO "nl:"
    b.exception_id
    FROM bb_exception b
    WHERE b.exception_id=sub_exception_id
     AND b.active_ind=0
     AND b.updt_cnt=updt_cnt
    WITH nocounter, forupdate(b)
   ;end select
   IF (curqual=0)
    SET exception_status = "FL"
   ENDIF
   IF (curqual=1)
    UPDATE  FROM bb_exception b
     SET b.active_ind = 1, b.active_status_cd = reqdata->active_status_cd, b.updt_cnt = (b.updt_cnt+
      1),
      b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->
      updt_task,
      b.updt_applctx = reqinfo->updt_applctx
     WHERE b.exception_id=sub_exception_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET exception_status = "F"
    ELSE
     SET exception_status = "S"
    ENDIF
   ENDIF
 END ;Subroutine
 SET modify = predeclare
 DECLARE script_name = c24 WITH constant("bbt_upd_flex_expiration")
 DECLARE exception_status = c1 WITH protect, noconstant(" ")
 DECLARE sub_exception_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE uar_error = vc WITH protect, noconstant("")
 DECLARE buildmsg = c40 WITH protect, noconstant(fillstring(40," "))
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE bb_exception_id = f8 WITH protect, noconstant(0.0)
 DECLARE bb_spec_expire_ovrd_id = f8 WITH protect, noconstant(0.0)
 DECLARE bb_ovrd_prod_id = f8 WITH protect, noconstant(0.0)
 DECLARE spec_ovrd_except_mean = c12 WITH protect, constant("FLEXSPEC")
 DECLARE ovrd_neonate_mean = c12 WITH protect, constant("NEONATE")
 DECLARE syscheckstr = c4 WITH protect, noconstant("    ")
 DECLARE sysoverrideind = i2 WITH protect, noconstant(0)
 DECLARE sys_mean = c4 WITH protect, constant("SYS_")
 DECLARE sys_trans_mean = c12 WITH protect, constant("SYS_TRANS")
 DECLARE sys_anti_mean = c12 WITH protect, constant("SYS_ANTI")
 DECLARE sys_combine_mean = c12 WITH protect, constant("SYS_COMBINE")
 DECLARE sys_dischrg_mean = c12 WITH protect, constant("SYS_DISCHRG")
 DECLARE modify_xm_reason_cs = i4 WITH protect, constant(14073)
 DECLARE modify_xm_reason_cd = f8 WITH protect, noconstant(0.0)
 DECLARE modify_xm_reason_mean = c12 WITH protect, noconstant("            ")
 DECLARE sys_userflex_mean = c12 WITH protect, constant("SYS_USERFLEX")
 DECLARE upd_stat_no_upd = i2 WITH protect, constant(0)
 DECLARE upd_stat_shortened = i2 WITH protect, constant(1)
 DECLARE upd_stat_lengthened = i2 WITH protect, constant(2)
 DECLARE upd_stat_expired = i2 WITH protect, constant(3)
 DECLARE upd_stat_undo_flex = i2 WITH protect, constant(4)
 DECLARE current_dt_tm = q8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE expired_dt_tm = q8 WITH protect, constant(cnvtdatetime(curdate,(curtime2 - 1)))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE personidx = i4 WITH protect, noconstant(0)
 DECLARE personcnt = i4 WITH protect, noconstant(0)
 DECLARE specimenidx = i4 WITH protect, noconstant(0)
 DECLARE specimencnt = i4 WITH protect, noconstant(0)
 DECLARE orderidx = i4 WITH protect, noconstant(0)
 DECLARE ordercnt = i4 WITH protect, noconstant(0)
 DECLARE productidx = i4 WITH protect, noconstant(0)
 DECLARE productcnt = i4 WITH protect, noconstant(0)
 DECLARE dttmchange = f8 WITH protect, noconstant(0.0)
 DECLARE xmdttmchange = f8 WITH protect, noconstant(0.0)
 DECLARE modxmrepindex = i4 WITH protect, noconstant(0)
 DECLARE modxmnum = i4 WITH protect, noconstant(0)
 DECLARE newexpiredttm = dq8 WITH protect, noconstant(0.0)
 SET log_program_name = "bbt_upd_flex_expiration"
 SET syscheckstr = substring(1,4,trim(request->override_reason_mean))
 IF (syscheckstr=sys_mean)
  SET sysoverrideind = 1
 ENDIF
 IF (sysoverrideind=1)
  SET modify_xm_reason_mean = trim(request->override_reason_mean)
 ELSE
  SET modify_xm_reason_mean = sys_userflex_mean
 ENDIF
 SET modify_xm_reason_cd = uar_get_code_by("MEANING",modify_xm_reason_cs,nullterm(
   modify_xm_reason_mean))
 IF (modify_xm_reason_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve modify XM reason with meaning of ",trim(request->
    override_reason_mean),".")
  CALL populate_subeventstatus_msg(log_program_name,"F","uar_failed",uar_error,log_level_audit)
  GO TO exit_script
 ENDIF
 SET stat = initrec(modxm_request)
 SET stat = initrec(modxm_reply)
 SET curalias inspec request->persons[personidx].specimens[specimenidx]
 SET curalias inorder request->persons[personidx].specimens[specimenidx].orders[orderidx]
 SET curalias inprod request->persons[personidx].specimens[specimenidx].orders[orderidx].products[
 productidx]
 SET curalias outspec reply->persons[personidx].specimens[specimenidx]
 SET curalias outorder reply->persons[personidx].specimens[specimenidx].orders[orderidx]
 SET curalias outprod reply->persons[personidx].specimens[specimenidx].orders[orderidx].products[
 productidx]
 SET personcnt = cnvtint(size(request->persons,5))
 SET stat = alterlist(reply->persons,personcnt)
 FOR (personidx = 1 TO personcnt)
   SET reply->persons[personidx].person_id = request->persons[personidx].person_id
   SET specimencnt = cnvtint(size(request->persons[personidx].specimens,5))
   SET stat = alterlist(reply->persons[personidx].specimens,specimencnt)
   FOR (specimenidx = 1 TO specimencnt)
     SET outspec->specimen_id = inspec->specimen_id
     SET outspec->drawn_dt_tm = inspec->drawn_dt_tm
     SET outspec->accession = inspec->accession
     SET outspec->testing_facility_cd = inspec->testing_facility_cd
     SET outspec->encntr_id = inspec->encntr_id
     SET outspec->facility_cd = inspec->facility_cd
     SET outspec->old_expire_dt_tm = inspec->old_expire_dt_tm
     IF (cnvtdatetime(inspec->new_expire_dt_tm) > 0)
      SET outspec->new_expire_dt_tm = inspec->new_expire_dt_tm
     ELSE
      IF (trim(request->override_reason_mean)=sys_combine_mean)
       SET outspec->new_expire_dt_tm = expired_dt_tm
       SET outspec->update_status_flag = upd_stat_undo_flex
      ELSEIF (trim(inspec->override_mean)=ovrd_neonate_mean)
       SET outspec->new_expire_dt_tm = inspec->old_expire_dt_tm
      ELSE
       SET newexpiredttm = null
       SET newexpiredttm = getflexexpiration(request->persons[personidx].person_id,0.0,inspec->
        drawn_dt_tm,inspec->facility_cd,1)
       IF ((newexpiredttm=- (1)))
        CALL populate_subeventstatus_msg(log_program_name,"F","GetFlexExpiration Failed",
         "GetFlexExpiration returned a failure.",log_level_audit)
        GO TO exit_script
       ENDIF
       SET outspec->new_expire_dt_tm = newexpiredttm
       IF (cnvtdatetime(outspec->new_expire_dt_tm)=0)
        SET outspec->new_expire_dt_tm = inspec->old_expire_dt_tm
       ENDIF
      ENDIF
     ENDIF
     IF ((outspec->update_status_flag != upd_stat_undo_flex))
      SET dttmchange = datetimediff(outspec->new_expire_dt_tm,outspec->old_expire_dt_tm,5)
      IF (dttmchange=0)
       SET outspec->update_status_flag = upd_stat_no_upd
      ELSEIF (dttmchange < 0)
       SET outspec->update_status_flag = upd_stat_shortened
      ELSE
       IF (sysoverrideind=1)
        SET outspec->update_status_flag = upd_stat_no_upd
       ELSE
        SET outspec->update_status_flag = upd_stat_lengthened
       ENDIF
      ENDIF
     ENDIF
     SET ordercnt = cnvtint(size(inspec->orders,5))
     SET stat = alterlist(outspec->orders,ordercnt)
     FOR (orderidx = 1 TO ordercnt)
       SET outorder->order_id = inorder->order_id
       SET productcnt = cnvtint(size(inorder->products,5))
       SET stat = alterlist(outorder->products,productcnt)
       FOR (productidx = 1 TO productcnt)
         SET outprod->product_id = inprod->product_id
         SET outprod->old_product_event_id = inprod->product_event_id
         SET outprod->old_xm_expire_dt_tm = inprod->old_xm_expire_dt_tm
         SET outprod->product_type_cd = inprod->product_type_cd
         SET outprod->xm_status_flag = upd_stat_no_upd
         SET outprod->new_xm_expire_dt_tm = inprod->old_xm_expire_dt_tm
         IF ((outspec->update_status_flag=upd_stat_shortened))
          SET xmdttmchange = datetimediff(outspec->new_expire_dt_tm,inprod->old_xm_expire_dt_tm,5)
          IF (xmdttmchange < 0)
           SET outprod->new_xm_expire_dt_tm = outspec->new_expire_dt_tm
           SET outprod->xm_status_flag = upd_stat_shortened
           CALL addmodxmproduct(inprod->product_id,inprod->product_event_id,outprod->
            new_xm_expire_dt_tm,modify_xm_reason_cd)
           SET xmdttmchange = datetimediff(outprod->new_xm_expire_dt_tm,current_dt_tm,5)
           IF (xmdttmchange <= 0)
            SET outprod->xm_status_flag = upd_stat_expired
           ENDIF
          ENDIF
         ELSEIF ((outspec->update_status_flag=upd_stat_undo_flex))
          SET outprod->new_xm_expire_dt_tm = outspec->new_expire_dt_tm
          CALL addmodxmproduct(inprod->product_id,inprod->product_event_id,outspec->new_expire_dt_tm,
           modify_xm_reason_cd)
          SET outprod->xm_status_flag = upd_stat_expired
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
 IF (nmodxmprodcnt > 0)
  IF (modxmproducts(request->lock_prods_ind)=0)
   CALL populate_subeventstatus_msg(log_program_name,"F","Script Call","ModXMProducts failed",
    log_level_audit)
   GO TO exit_script
  ENDIF
  IF ((modxm_reply->status_data.status != "S"))
   CALL populate_subeventstatus_msg(log_program_name,"F","Script Call","bbt_chg_event_rein failed",
    log_level_audit)
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (personidx = 1 TO personcnt)
  SET specimencnt = cnvtint(size(reply->persons[personidx].specimens,5))
  FOR (specimenidx = 1 TO specimencnt)
    IF ((outspec->update_status_flag=upd_stat_undo_flex))
     IF ((inspec->override_id > 0))
      IF (inactivateoverride(inspec->override_id)=0)
       SET buildmsg = build("Inactivate ovrd: ",inspec->override_id)
       GO TO exit_script
      ENDIF
     ENDIF
    ELSEIF ((outspec->update_status_flag != upd_stat_no_upd))
     IF ((inspec->override_id > 0))
      IF (inactivateoverride(inspec->override_id)=0)
       SET buildmsg = build("Inactivate ovrd: ",inspec->override_id)
       GO TO exit_script
      ENDIF
     ENDIF
     SET bb_exception_id = 0.0
     CALL log_message("Insert bb_Exception",log_level_debug)
     CALL add_bb_exception(reply->persons[personidx].person_id,0.0,reqinfo->updt_id,current_dt_tm,0.0,
      spec_ovrd_except_mean,request->override_reason_cd,0.0,0.0,0.0,
      0.0,0.0,0.0,0.0,cnvtdatetime(""))
     IF (exception_status="F")
      IF (error_message(1)=1)
       GO TO exit_script
      ENDIF
     ELSE
      SET outspec->exception_id = bb_exception_id
     ENDIF
     SET buildmsg = build("Insert ovrd: Spec_id ",outspec->specimen_id)
     CALL log_message(buildmsg,log_level_debug)
     SET bb_spec_expire_ovrd_id = 0.0
     IF (addspecoverride(bb_exception_id,outspec->specimen_id,outspec->new_expire_dt_tm,outspec->
      old_expire_dt_tm,current_dt_tm,
      request->override_reason_cd,reply->persons[personidx].person_id,outspec->encntr_id)=0)
      CALL log_message("Insert bb_spec_ovrd failed",log_level_debug)
      GO TO exit_script
     ELSE
      SET outspec->new_override_id = bb_spec_expire_ovrd_id
     ENDIF
     IF (nmodxmprodcnt > 0)
      SET ordercnt = cnvtint(size(inspec->orders,5))
      FOR (orderidx = 1 TO ordercnt)
       SET productcnt = cnvtint(size(inorder->products,5))
       FOR (productidx = 1 TO productcnt)
        SET modxmrepindex = 0
        IF ((outprod->xm_status_flag != upd_stat_no_upd))
         SET modxmrepindex = locateval(modxmnum,1,size(modxm_reply->results,5),value(outprod->
           old_product_event_id),modxm_reply->results[modxmnum].product_event_id)
         IF (modxmrepindex=0)
          SET buildmsg = build("XM Not updated: Product Id ",outprod->product_id)
          CALL populate_subeventstatus_msg(log_program_name,"F","XM Not Updated",buildmsg,
           log_level_audit)
          GO TO exit_script
         ELSE
          SET outprod->new_product_event_id = modxm_reply->results[modxmrepindex].
          new_product_event_id
         ENDIF
         SET buildmsg = build("Insert ovrd: Product Id ",outprod->product_id)
         CALL log_message(buildmsg,log_level_debug)
         SET bb_ovrd_prod_id = 0.0
         IF (addspecoverrideprod(bb_spec_expire_ovrd_id,outprod->product_id,outprod->
          new_xm_expire_dt_tm,outprod->old_xm_expire_dt_tm,outprod->old_product_event_id)=0)
          SET buildmsg = build("Insert ovrd product failed:",outprod->product_id)
          CALL log_message(buildmsg,log_level_debug)
          GO TO exit_script
         ENDIF
        ENDIF
       ENDFOR
      ENDFOR
     ENDIF
    ENDIF
  ENDFOR
 ENDFOR
 SET curalias inspec off
 SET curalias inorder off
 SET curalias inprod off
 SET curalias outspec off
 SET curalias outorder off
 SET curalias outprod off
 SUBROUTINE (addspecoverride(bb_except_id=f8(value),specimen_id=f8(value),new_spec_expire_dt_tm=dq8(
   value),prev_spec_expire_dt_tm=dq8(value),override_dt_tm=dq8(value),override_reason_cd=f8(value),
  person_id=f8(value),encntr_id=f8(value)) =i2)
   DECLARE sub_override_id = f8 WITH protect, noconstant(0.0)
   DECLARE nerrorind = i2 WITH protect, noconstant(0)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   SET bb_spec_expire_ovrd_id = 0.0
   SET sub_override_id = new_pathnet_seq
   IF (sub_override_id > 0)
    INSERT  FROM bb_spec_expire_ovrd bso
     SET bso.bb_spec_expire_ovrd_id = sub_override_id, bso.person_id = person_id, bso.encntr_id =
      encntr_id,
      bso.exception_id = bb_except_id, bso.new_spec_expire_dt_tm =
      IF (new_spec_expire_dt_tm != null) cnvtdatetime(new_spec_expire_dt_tm)
      ELSE null
      ENDIF
      , bso.prev_spec_expire_dt_tm = cnvtdatetime(prev_spec_expire_dt_tm),
      bso.override_dt_tm = cnvtdatetime(override_dt_tm), bso.override_reason_cd = override_reason_cd,
      bso.specimen_id = specimen_id,
      bso.updt_cnt = 0, bso.updt_dt_tm = cnvtdatetime(sysdate), bso.updt_id = reqinfo->updt_id,
      bso.updt_task = reqinfo->updt_task, bso.updt_applctx = reqinfo->updt_applctx, bso.active_ind =
      1,
      bso.active_status_cd = reqdata->active_status_cd, bso.active_status_dt_tm = cnvtdatetime(
       sysdate), bso.active_status_prsnl_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    SET nerrorind = error_message(1)
    IF (nerrorind=0)
     SET bb_spec_expire_ovrd_id = sub_override_id
    ENDIF
   ELSE
    CALL populate_subeventstatus_msg(log_program_name,"F","New Override Failed","getNewSeq failed",
     log_level_audit)
    SET nerrorind = 1
   ENDIF
   IF (nerrorind=0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (addspecoverrideprod(override_id=f8(value),product_id=f8(value),new_xm_expire_dt_tm=dq8(
   value),prev_xm_expire_dt_tm=dq8(value),product_event_id=f8(value)) =i2)
   DECLARE sub_prod_override_id = f8 WITH protect, noconstant(0.0)
   DECLARE nerrorind = i2 WITH protect, noconstant(0)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   SET sub_prod_override_id = new_pathnet_seq
   IF (sub_prod_override_id > 0)
    INSERT  FROM bb_spec_exp_ovrd_prod bsp
     SET bsp.bb_spec_exp_ovrd_prod_id = sub_prod_override_id, bsp.bb_spec_expire_ovrd_id =
      override_id, bsp.product_id = product_id,
      bsp.new_xm_expire_dt_tm =
      IF (new_xm_expire_dt_tm != null) cnvtdatetime(new_xm_expire_dt_tm)
      ELSE null
      ENDIF
      , bsp.prev_xm_expire_dt_tm = cnvtdatetime(prev_xm_expire_dt_tm), bsp.product_event_id =
      product_event_id,
      bsp.updt_cnt = 0, bsp.updt_dt_tm = cnvtdatetime(sysdate), bsp.updt_id = reqinfo->updt_id,
      bsp.updt_task = reqinfo->updt_task, bsp.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    SET nerrorind = error_message(1)
    IF (nerrorind=0)
     SET bb_ovrd_prod_id = sub_prod_override_id
    ENDIF
   ELSE
    CALL populate_subeventstatus_msg(log_program_name,"F","New Override Prod Failed",
     "getNewSeq failed",log_level_audit)
    SET nerrorind = 1
   ENDIF
   IF (nerrorind=0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (inactivateoverride(old_override_id=f8(value)) =i2)
   DECLARE nerrorind = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    bso.bb_spec_expire_ovrd_id
    FROM bb_spec_expire_ovrd bso
    WHERE bso.bb_spec_expire_ovrd_id=old_override_id
    WITH forupdate(bso)
   ;end select
   IF (curqual=0)
    SET nerrorind = 1
    CALL populate_subeventstatus_msg(log_program_name,"F","Inactivate ovrd failed",
     "Failed to find ovrd",log_level_audit)
   ELSE
    SET nerrorind = error_message(1)
    IF (nerrorind=0)
     UPDATE  FROM bb_spec_expire_ovrd bso
      SET bso.updt_cnt = (bso.updt_cnt+ 1), bso.updt_dt_tm = cnvtdatetime(sysdate), bso.updt_id =
       reqinfo->updt_id,
       bso.updt_task = reqinfo->updt_task, bso.updt_applctx = reqinfo->updt_applctx, bso.active_ind
        = 0,
       bso.active_status_cd = reqdata->inactive_status_cd, bso.active_status_dt_tm = cnvtdatetime(
        sysdate), bso.active_status_prsnl_id = reqinfo->updt_id
      WHERE bso.bb_spec_expire_ovrd_id=old_override_id
      WITH nocounter
     ;end update
     SET nerrorind = error_message(1)
    ENDIF
   ENDIF
   IF (nerrorind=0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
#set_status
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status="F"))
  SET reqinfo->commit_ind = 0
  IF ((request->lock_prods_ind=1))
   ROLLBACK
  ENDIF
 ENDIF
 IF ((request->lock_prods_ind=1))
  IF (unlockxmproducts(null)=0)
   SET reply->status_data.status = "F"
   SET reqinfo->commit_ind = 0
  ENDIF
 ENDIF
 SET stat = initrec(modxm_request)
 SET stat = initrec(modxm_reply)
 SET stat = initrec(unique_prods)
 SET modify = nopredeclare
END GO
