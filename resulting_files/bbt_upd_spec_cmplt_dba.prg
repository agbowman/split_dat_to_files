CREATE PROGRAM bbt_upd_spec_cmplt:dba
 RECORD reply(
   1 orders[*]
     2 order_id = f8
     2 updt_cnt = i4
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 complete_ind = i2
     2 cancel_ind = i2
     2 oe_format_id = f8
     2 detaillist[*]
       3 oe_field_id = f8
       3 group_seq = i4
       3 field_seq = i4
       3 value_req_ind = i4
       3 field_meaning_id = f8
       3 field_meaning = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 facility[*]
     2 loc_facility_cd = f8
     2 orders[*]
       3 order_id = f8
       3 updt_cnt = i4
       3 catalog_cd = f8
       3 catalog_type_cd = f8
       3 person_id = f8
       3 drawn_dt_tm = dq8
       3 encntr_id = f8
       3 loc_facility_cd = f8
       3 result_id = f8
       3 oe_format_id = f8
       3 bb_processing_cd = f8
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
 SET cmplt_code = 0.0
 SET cancel_code = 0.0
 SET dept_cmplt_cd = 0.0
 SET days_hrs = " "
 SET days = 0
 SET hrs = 0
 SET order_cnt = 0
 SET idx = 0
 DECLARE temp_order_cnt = i4 WITH protect, noconstant(0)
 DECLARE temp_order_index = i4 WITH protect, noconstant(0)
 DECLARE facility_count = i4 WITH protect, noconstant(0)
 DECLARE temp_facility_index = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE calc_expire_dt_tm = q8 WITH protect, noconstant(0.0)
 DECLARE current_dt_tm_hold = q8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE off_idx = i4 WITH noconstant(0)
 DECLARE encloc_idx = i4 WITH noconstant(0)
 DECLARE field_cnt = i4 WITH protect, noconstant(0)
 DECLARE get_flex_params = i4 WITH protect, noconstant(1)
 DECLARE transf_flex_param_count = i4 WITH protect, noconstant(0)
 DECLARE temp_transf_index = i4 WITH protect, noconstant(0)
 DECLARE flex_enabled = i4 WITH protect, noconstant(0)
 DECLARE cancel_enabled = i4 WITH protect, noconstant(0)
 DECLARE facility_code = f8 WITH protect, noconstant(0.0)
 DECLARE encounter_location_found = i4 WITH protect, noconstant(0.0)
 DECLARE dtexpiredate = q8 WITH protect
 DECLARE sexpiredttmstring = vc WITH protect
 DECLARE loadflexparamsforfacility(encntrfacilitycd=f8(value)) = i2
 DECLARE get_code_value(sub_code_set,sub_cdf_meaning) = f8
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SET gsub_code_value = 0.0
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = sub_cdf_meaning
   SET stat = uar_get_meaning_by_codeset(sub_code_set,cdf_meaning,1,gsub_code_value)
   RETURN(gsub_code_value)
 END ;Subroutine
 SUBROUTINE check_opt_date_passed(script_name)
   SET ddmmyy_flag = 0
   SET dd_flag = 0
   SET mm_flag = 0
   SET yy_flag = 0
   SET dayentered = 0
   SET monthentered = 0
   SET yearentered = 0
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("DAY[",temp_string)))
   IF (temp_pos > 0)
    SET day_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET day_pos = cnvtint(value(findstring("]",day_string)))
    IF (day_pos > 0)
     SET day_nbr = substring(1,(day_pos - 1),day_string)
     IF (trim(day_nbr) > " ")
      SET ddmmyy_flag += 1
      SET dd_flag = 1
      SET dayentered = cnvtreal(day_nbr)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse DAY value"
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse DAY value"
    ENDIF
   ENDIF
   IF ((reply->status_data.status != "F"))
    SET temp_pos = 0
    SET temp_pos = cnvtint(value(findstring("MONTH[",temp_string)))
    IF (temp_pos > 0)
     SET month_string = substring((temp_pos+ 6),size(temp_string),temp_string)
     SET month_pos = cnvtint(value(findstring("]",month_string)))
     IF (month_pos > 0)
      SET month_nbr = substring(1,(month_pos - 1),month_string)
      IF (trim(month_nbr) > " ")
       SET ddmmyy_flag += 1
       SET mm_flag = 1
       SET monthentered = cnvtreal(month_nbr)
      ELSE
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "parse MONTH value"
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse MONTH value"
     ENDIF
    ENDIF
   ENDIF
   IF ((reply->status_data.status != "F"))
    SET temp_pos = 0
    SET temp_pos = cnvtint(value(findstring("YEAR[",temp_string)))
    IF (temp_pos > 0)
     SET year_string = substring((temp_pos+ 5),size(temp_string),temp_string)
     SET year_pos = cnvtint(value(findstring("]",year_string)))
     IF (year_pos > 0)
      SET year_nbr = substring(1,(year_pos - 1),year_string)
      IF (trim(year_nbr) > " ")
       SET ddmmyy_flag += 1
       SET yy_flag = 1
       SET yearentered = cnvtreal(year_nbr)
      ELSE
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "parse YEAR value"
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse YEAR value"
     ENDIF
    ENDIF
   ENDIF
   IF (ddmmyy_flag > 1)
    SET reply->status_data.subeventstatus[1].operationname = script_name
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "parse DAY or MONTH or YEAR value"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "multi date selection"
    GO TO exit_script
   ENDIF
   IF ((reply->status_data.status="F"))
    SET reply->status_data.subeventstatus[1].operationname = script_name
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
    GO TO exit_script
   ENDIF
   IF (dd_flag=1)
    IF (dayentered > 0)
     SET interval = build(abs(dayentered),"d")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET begday = cnvtlookahead(interval,request->ops_date)
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),235959)
     SET endday = cnvtlookahead(interval,request->ops_date)
    ELSE
     SET interval = build(abs(dayentered),"d")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET begday = cnvtlookbehind(interval,request->ops_date)
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),235959)
     SET endday = cnvtlookbehind(interval,request->ops_date)
    ENDIF
   ELSEIF (mm_flag=1)
    IF (monthentered > 0)
     SET interval = build(abs(monthentered),"m")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET smonth = cnvtstring(month(request->ops_date))
     SET sday = "01"
     SET syear = cnvtstring(year(request->ops_date))
     SET sdateall = concat(smonth,sday,syear)
     SET begday = cnvtlookahead(interval,cnvtdatetime(cnvtdate(sdateall),0))
     SET endday = cnvtlookahead("1m",cnvtdatetime(cnvtdate(begday),235959))
     SET endday = cnvtlookbehind("1d",endday)
    ELSE
     SET interval = build(abs(monthentered),"m")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET smonth = cnvtstring(month(request->ops_date))
     SET sday = "01"
     SET syear = cnvtstring(year(request->ops_date))
     SET sdateall = concat(smonth,sday,syear)
     SET begday = cnvtlookbehind(interval,cnvtdatetime(cnvtdate(sdateall),0))
     SET endday = cnvtlookahead("1m",cnvtdatetime(cnvtdate(begday),235959))
     SET endday = cnvtlookbehind("1d",endday)
    ENDIF
   ELSEIF (yy_flag=1)
    IF (yearentered > 0)
     SET interval = build(abs(yearentered),"y")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET smonth = "01"
     SET sday = "01"
     SET syear = cnvtstring(year(request->ops_date))
     SET sdateall = concat(smonth,sday,syear)
     SET begday = cnvtlookahead(interval,cnvtdatetime(cnvtdate(sdateall),0))
     SET endday = cnvtlookahead("1y",cnvtdatetime(cnvtdate(begday),235959))
     SET endday = cnvtlookbehind("1d",endday)
    ELSE
     SET interval = build(abs(yearentered),"y")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET smonth = "01"
     SET sday = "01"
     SET syear = cnvtstring(year(request->ops_date))
     SET sdateall = concat(smonth,sday,syear)
     SET begday = cnvtlookbehind(interval,cnvtdatetime(cnvtdate(sdateall),0))
     SET endday = cnvtlookahead("1y",cnvtdatetime(cnvtdate(begday),235959))
     SET endday = cnvtlookbehind("1d",endday)
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = script_name
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "parse DAY or MONTH or YEAR value"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "NO date selection"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE check_bb_organization(script_name)
   DECLARE norgpos = i2 WITH protect, noconstant(0)
   DECLARE ntemppos = i2 WITH protect, noconstant(0)
   DECLARE ncodeset = i4 WITH protect, constant(278)
   DECLARE sorgname = vc WITH protect, noconstant(fillstring(132,""))
   DECLARE sorgstring = vc WITH protect, noconstant(fillstring(132,""))
   DECLARE dbbmanufcd = f8 WITH protect, noconstant(0.0)
   DECLARE dbbsupplcd = f8 WITH protect, noconstant(0.0)
   DECLARE dbbclientcd = f8 WITH protect, noconstant(0.0)
   SET stat = uar_get_meaning_by_codeset(ncodeset,"BBMANUF",1,dbbmanufcd)
   SET stat = uar_get_meaning_by_codeset(ncodeset,"BBSUPPL",1,dbbsupplcd)
   SET stat = uar_get_meaning_by_codeset(ncodeset,"BBCLIENT",1,dbbclientcd)
   SET ntemppos = cnvtint(value(findstring("ORG[",temp_string)))
   IF (ntemppos > 0)
    SET sorgstring = substring((ntemppos+ 4),size(temp_string),temp_string)
    SET norgpos = cnvtint(value(findstring("]",sorgstring)))
    IF (norgpos > 0)
     SET sorgname = substring(1,(norgpos - 1),sorgstring)
     IF (trim(sorgname) > " ")
      SELECT INTO "nl:"
       FROM org_type_reltn ot,
        organization o
       PLAN (ot
        WHERE ot.org_type_cd IN (dbbmanufcd, dbbsupplcd, dbbclientcd)
         AND ot.active_ind=1)
        JOIN (o
        WHERE o.org_name_key=trim(cnvtupper(sorgname))
         AND o.active_ind=1)
       DETAIL
        request->organization_id = o.organization_id
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
   ELSE
    SET request->organization_id = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_owner_cd(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("OWN[",temp_string)))
   IF (temp_pos > 0)
    SET own_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET own_pos = cnvtint(value(findstring("]",own_string)))
    IF (own_pos > 0)
     SET own_area = substring(1,(own_pos - 1),own_string)
     IF (trim(own_area) > " ")
      SET request->cur_owner_area_cd = cnvtreal(own_area)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse owner area code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse owner area code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->cur_owner_area_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_inventory_cd(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("INV[",temp_string)))
   IF (temp_pos > 0)
    SET inv_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET inv_pos = cnvtint(value(findstring("]",inv_string)))
    IF (inv_pos > 0)
     SET inv_area = substring(1,(inv_pos - 1),inv_string)
     IF (trim(inv_area) > " ")
      SET request->cur_inv_area_cd = cnvtreal(inv_area)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse inventory area code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse inventory area code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->cur_inv_area_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_location_cd(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("LOC[",temp_string)))
   IF (temp_pos > 0)
    SET loc_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",loc_string)))
    IF (loc_pos > 0)
     SET location_cd = substring(1,(loc_pos - 1),loc_string)
     IF (trim(location_cd) > " ")
      SET request->address_location_cd = cnvtreal(location_cd)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse location code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse location code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->address_location_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_sort_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("SORT[",temp_string)))
   IF (temp_pos > 0)
    SET sort_string = substring((temp_pos+ 5),size(temp_string),temp_string)
    SET sort_pos = cnvtint(value(findstring("]",sort_string)))
    IF (sort_pos > 0)
     SET sort_selection = substring(1,(sort_pos - 1),sort_string)
    ELSE
     SET sort_selection = " "
    ENDIF
   ELSE
    SET sort_selection = " "
   ENDIF
 END ;Subroutine
 SUBROUTINE check_mode_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("MODE[",temp_string)))
   IF (temp_pos > 0)
    SET mode_string = substring((temp_pos+ 5),size(temp_string),temp_string)
    SET mode_pos = cnvtint(value(findstring("]",mode_string)))
    IF (mode_pos > 0)
     SET mode_selection = substring(1,(mode_pos - 1),mode_string)
    ELSE
     SET mode_selection = " "
    ENDIF
   ELSE
    SET mode_selection = " "
   ENDIF
 END ;Subroutine
 SUBROUTINE check_rangeofdays_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("RANGEOFDAYS[",temp_string)))
   IF (temp_pos > 0)
    SET next_string = substring((temp_pos+ 12),size(temp_string),temp_string)
    SET next_pos = cnvtint(value(findstring("]",next_string)))
    SET days_look_ahead = cnvtint(trim(substring(1,(next_pos - 1),next_string)))
    IF (days_look_ahead > 0)
     SET days_look_ahead = days_look_ahead
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse look ahead days"
     GO TO exit_script
    ENDIF
   ELSE
    SET days_look_ahead = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_hrs_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("HRS[",temp_string)))
   IF (temp_pos > 0)
    SET hrs_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET hrs_pos = cnvtint(value(findstring("]",hrs_string)))
    IF (hrs_pos > 0)
     SET num_hrs = substring(1,(hrs_pos - 1),hrs_string)
     IF (trim(num_hrs) > " ")
      IF (cnvtint(trim(num_hrs)) > 0)
       SET hoursentered = cnvtreal(num_hrs)
      ELSE
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].operationname = script_name
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
       SET reply->status_data.subeventstatus[1].targetobjectname = "parse number of hours"
       GO TO exit_script
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse number of hours"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse number of hours"
     GO TO exit_script
    ENDIF
   ELSE
    SET hoursentered = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_svc_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("SVC[",temp_string)))
   IF (temp_pos > 0)
    SET svc_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET svc_pos = cnvtint(value(findstring("]",svc_string)))
    SET parm_string = fillstring(100," ")
    SET parm_string = substring(1,(svc_pos - 1),svc_string)
    SET ptr = 1
    SET back_ptr = 1
    SET param_idx = 1
    SET nbr_of_services = size(trim(parm_string))
    SET flag_exit_loop = 0
    FOR (param_idx = 1 TO nbr_of_services)
      SET ptr = findstring(",",parm_string,back_ptr)
      IF (ptr=0)
       SET ptr = (nbr_of_services+ 1)
       SET flag_exit_loop = 1
      ENDIF
      SET parm_len = (ptr - back_ptr)
      SET stat = alterlist(ops_params->qual,param_idx)
      SET ops_params->qual[param_idx].param = trim(substring(back_ptr,value(parm_len),parm_string),3)
      SET back_ptr = (ptr+ 1)
      SET stat = alterlist(request->qual,param_idx)
      SET request->qual[param_idx].service_resource_cd = cnvtreal(ops_params->qual[param_idx].param)
      IF (flag_exit_loop=1)
       SET param_idx = nbr_of_services
      ENDIF
    ENDFOR
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = script_name
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
    SET reply->status_data.subeventstatus[1].targetobjectname = "parse service resource"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE check_donation_location(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("DLOC[",temp_string)))
   IF (temp_pos > 0)
    SET loc_string = substring((temp_pos+ 5),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",loc_string)))
    IF (loc_pos > 0)
     SET location_cd = substring(1,(loc_pos - 1),loc_string)
     IF (trim(location_cd) > " ")
      SET request->donation_location_cd = cnvtreal(trim(location_cd))
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse donation location"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse donation location"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->donation_location_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_null_report(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("NULLRPT[",temp_string)))
   IF (temp_pos > 0)
    SET null_string = substring((temp_pos+ 8),size(temp_string),temp_string)
    SET null_pos = cnvtint(value(findstring("]",null_string)))
    IF (null_pos > 0)
     SET null_selection = substring(1,(null_pos - 1),null_string)
     IF (trim(null_selection)="Y")
      SET request->null_ind = 1
     ELSE
      SET request->null_ind = 0
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse null report indicator"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE check_outcome_cd(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("OUTCOME[",temp_string)))
   IF (temp_pos > 0)
    SET outcome_string = substring((temp_pos+ 8),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",outcome_string)))
    IF (loc_pos > 0)
     SET outcome_cd = substring(1,(loc_pos - 1),outcome_string)
     IF (trim(outcome_cd) > " ")
      SET request->outcome_cd = cnvtreal(outcome_cd)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse outcome code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse outcome code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->outcome_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE (check_facility_cd(script_name=vc) =null)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("FACILITY[",temp_string)))
   IF (temp_pos > 0)
    SET loc_string = substring((temp_pos+ 9),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",loc_string)))
    IF (loc_pos > 0)
     SET facility_cd = substring(1,(loc_pos - 1),loc_string)
     IF (trim(facility_cd) > " ")
      SET request->facility_cd = cnvtreal(facility_cd)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no facility code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse facility code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no facility code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse facility code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->facility_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE (check_exception_type_cd(script_name=vc) =null)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("EXCEPT[",temp_string)))
   IF (temp_pos > 0)
    SET loc_string = substring((temp_pos+ 7),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",loc_string)))
    IF (loc_pos > 0)
     SET exception_type_cd = substring(1,(loc_pos - 1),loc_string)
     IF (trim(exception_type_cd) > " ")
      IF (trim(exception_type_cd)="ALL")
       SET request->exception_type_cd = 0.0
      ELSE
       SET request->exception_type_cd = cnvtreal(exception_type_cd)
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "no exception type code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse exception type code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "no exception type code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse exception type code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->exception_type_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_misc_functionality(param_name)
   SET temp_pos = 0
   SET status_param = ""
   SET temp_str = concat(param_name,"[")
   SET temp_pos = cnvtint(value(findstring(temp_str,temp_string)))
   IF (temp_pos > 0)
    SET status_string = substring((temp_pos+ textlen(temp_str)),size(temp_string),temp_string)
    SET status_pos = cnvtint(value(findstring("]",status_string)))
    IF (status_pos > 0)
     SET status_param = substring(1,(status_pos - 1),status_string)
     IF (trim(status_param) > " ")
      SET ops_param_status = cnvtint(status_param)
     ENDIF
    ENDIF
   ENDIF
   RETURN
 END ;Subroutine
 SET cmplt_code = get_code_value(6004,"COMPLETED")
 SET cancel_code = get_code_value(6004,"CANCELED")
 SET dept_cmplt_cd = get_code_value(14281,"COMPLETED")
 SET xm_exp_code = get_code_value(1661,"XM EXP CALC")
 DECLARE activity_type_cs = i4 WITH protect, constant(106)
 DECLARE bb_activity_type_mean = c12 WITH protect, constant("BB")
 DECLARE bb_activity_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE order_action_codeset = i4 WITH constant(6003)
 DECLARE dept_order_status_cs = i4 WITH protect, constant(14281)
 DECLARE action_cancel_cdf = c12 WITH constant("CANCEL")
 DECLARE action_cancel_cd = f8 WITH noconstant(0.0)
 DECLARE labinprocess_dept_status_mean = c12 WITH protect, constant("LABINPROCESS")
 DECLARE labinprocess_dept_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE inlab_dept_status_mean = c12 WITH protect, constant("LABINLAB")
 DECLARE inlab_dept_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE collected_dept_status_mean = c12 WITH protect, constant("LABCOLLECTED")
 DECLARE collected_dept_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cancel_dttm_meaning = f8 WITH constant(51.0)
 DECLARE canceldttm = c12
 DECLARE canceldttmdesc = c30
 DECLARE cancel_date_and_time = c20 WITH protect, constant("Cancel Date and Time")
 DECLARE catalog_type_cs = i4 WITH constant(6000)
 DECLARE gen_lab_meaning = c12 WITH protect, constant("GENERAL LAB")
 DECLARE genlab_cd = f8 WITH constant(uar_get_code_by("MEANING",catalog_type_cs,nullterm(
    gen_lab_meaning))), protect
 DECLARE cancel_reason_meaning = f8 WITH constant(1105.0)
 DECLARE cancelreason = c12
 DECLARE cancelreasondesc = c30
 DECLARE ops_param_status = i4 WITH noconstant(- (1))
 SET bb_activity_type_cd = uar_get_code_by("MEANING",activity_type_cs,nullterm(bb_activity_type_mean)
  )
 IF (bb_activity_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve activity type code with meaning of ",trim(
    bb_activity_type_mean),".")
  GO TO exit_script
 ENDIF
 SET inlab_dept_status_cd = uar_get_code_by("MEANING",dept_order_status_cs,nullterm(
   labinprocess_dept_status_mean))
 IF (inlab_dept_status_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve department order status code with meaning of ",trim(
    labinprocess_dept_status_mean),".")
  GO TO exit_script
 ENDIF
 SET labinprocess_dept_status_cd = uar_get_code_by("MEANING",dept_order_status_cs,nullterm(
   inlab_dept_status_mean))
 IF (labinprocess_dept_status_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve department order status code with meaning of ",trim(
    inlab_dept_status_mean),".")
  GO TO exit_script
 ENDIF
 SET collected_dept_status_cd = uar_get_code_by("MEANING",dept_order_status_cs,nullterm(
   collected_dept_status_mean))
 IF (collected_dept_status_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve department order status code with meaning of ",trim(
    collected_dept_status_mean),".")
  GO TO exit_script
 ENDIF
 SET action_cancel_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(order_action_codeset,action_cancel_cdf,1,action_cancel_cd)
 SELECT INTO "nl:"
  an.answer
  FROM answer an
  PLAN (an
   WHERE an.active_ind=1
    AND xm_exp_code=an.question_cd)
  DETAIL
   days_hrs = trim(uar_get_code_meaning(cnvtreal(an.answer)))
  WITH nocounter
 ;end select
 IF (days_hrs="D")
  SET xm_comp_code = get_code_value(1661,"XM COMP DYS")
  SELECT INTO "nl:"
   an.answer
   FROM answer an
   PLAN (an
    WHERE an.active_ind=1
     AND xm_comp_code=an.question_cd)
   DETAIL
    days = cnvtint(an.answer)
  ;end select
 ENDIF
 IF (days_hrs="H")
  SET xm_comp_code = get_code_value(1661,"XM COMP HRS")
  SELECT INTO "nl:"
   an.answer
   FROM answer an
   PLAN (an
    WHERE an.active_ind=1
     AND xm_comp_code=an.question_cd)
   DETAIL
    hrs = cnvtint(an.answer)
  ;end select
 ENDIF
 IF (trim(request->batch_selection) > " ")
  SET temp_string = trim(request->batch_selection)
  CALL check_misc_functionality("CANCEL")
  CALL check_facility_cd("bbt_upd_spec_cmplt")
 ENDIF
 IF ((request->facility_cd > 0.0))
  IF ((getencounterlocations(request->facility_cd)=- (1)))
   GO TO exit_script
  ENDIF
 ENDIF
 SET abid_cd = get_code_value(1635,"ANTIBODY ID")
 SET antigen_cd = get_code_value(1635,"ANTIGEN")
 SET xm_cd = get_code_value(1635,"XM")
 INSERT  FROM shared_value_gttd
  (source_entity_name, source_entity_value)(SELECT
   cnvtstring(od.order_id), od.order_id
   FROM orders od
   WHERE od.activity_type_cd=bb_activity_type_cd
    AND od.catalog_type_cd=genlab_cd
    AND od.dept_status_cd IN (labinprocess_dept_status_cd, inlab_dept_status_cd,
   collected_dept_status_cd))
 ;end insert
 SELECT INTO "nl:"
  od.order_id, os.order_id, od.catalog_cd,
  co.drawn_dt_tm, os.container_id, co.container_id,
  sd.bb_processing_cd
  FROM orders od,
   shared_value_gttd g,
   encounter e,
   order_serv_res_container os,
   container co,
   result r,
   bb_spec_expire_ovrd bseo,
   service_directory sd
  PLAN (g
   WHERE g.source_entity_value != 0.0)
   JOIN (od
   WHERE od.order_id=g.source_entity_value)
   JOIN (sd
   WHERE od.catalog_cd=sd.catalog_cd)
   JOIN (e
   WHERE e.encntr_id=od.encntr_id)
   JOIN (os
   WHERE od.order_id=os.order_id)
   JOIN (co
   WHERE os.container_id=co.container_id)
   JOIN (r
   WHERE (r.order_id= Outerjoin(od.order_id)) )
   JOIN (bseo
   WHERE (bseo.specimen_id= Outerjoin(co.specimen_id))
    AND (bseo.active_ind= Outerjoin(value(1))) )
  ORDER BY e.loc_facility_cd, od.person_id, od.encntr_id,
   od.order_id
  HEAD REPORT
   row + 0
  HEAD e.loc_facility_cd
   facility_count += 1, temp_order_cnt = 0
   IF (size(temp->facility,5) <= facility_count)
    stat = alterlist(temp->facility,facility_count)
   ENDIF
   temp->facility[facility_count].loc_facility_cd = e.loc_facility_cd, encounter_location_found =
   locateval(encloc_idx,1,size(encounterlocations->locs,5),e.loc_facility_cd,encounterlocations->
    locs[encloc_idx].encfacilitycd)
  HEAD od.order_id
   row + 0
  DETAIL
   row + 0
  FOOT  od.order_id
   IF (co.drawn_dt_tm != null)
    IF (bseo.bb_spec_expire_ovrd_id > 0.0)
     override_exp_dt_tm = bseo.new_spec_expire_dt_tm,
     CALL populatereply(od.order_id,od.catalog_cd,od.updt_cnt,od.catalog_type_cd,od.oe_format_id,sd
     .bb_processing_cd,r.result_id,override_exp_dt_tm)
    ELSE
     temp_order_cnt += 1
     IF (size(temp->facility[facility_count].orders,5) <= temp_order_cnt)
      stat = alterlist(temp->facility[facility_count].orders,(temp_order_cnt+ 10))
     ENDIF
     temp->facility[facility_count].orders[temp_order_cnt].order_id = od.order_id, temp->facility[
     facility_count].orders[temp_order_cnt].catalog_cd = od.catalog_cd, temp->facility[facility_count
     ].orders[temp_order_cnt].updt_cnt = od.updt_cnt,
     temp->facility[facility_count].orders[temp_order_cnt].catalog_type_cd = od.catalog_type_cd, temp
     ->facility[facility_count].orders[temp_order_cnt].person_id = od.person_id, temp->facility[
     facility_count].orders[temp_order_cnt].drawn_dt_tm = co.drawn_dt_tm,
     temp->facility[facility_count].orders[temp_order_cnt].encntr_id = e.encntr_id, temp->facility[
     facility_count].orders[temp_order_cnt].loc_facility_cd = e.loc_facility_cd, temp->facility[
     facility_count].orders[temp_order_cnt].oe_format_id = od.oe_format_id,
     temp->facility[facility_count].orders[temp_order_cnt].updt_cnt = od.updt_cnt, temp->facility[
     facility_count].orders[temp_order_cnt].result_id = r.result_id, temp->facility[facility_count].
     orders[temp_order_cnt].bb_processing_cd = sd.bb_processing_cd
    ENDIF
   ENDIF
  FOOT  e.loc_facility_cd
   stat = alterlist(temp->facility[facility_count].orders,temp_order_cnt)
  FOOT REPORT
   stat = alterlist(reply->orders,order_cnt), stat = alterlist(temp->facility,facility_count)
  WITH counter, maxqual(r,1)
 ;end select
 FOR (temp_facility_index = 1 TO facility_count)
   SET flex_enabled = bbtgetflexspecenableflexexpiration(temp->facility[temp_facility_index].
    loc_facility_cd)
   SET encounter_location_found = locateval(encloc_idx,1,size(encounterlocations->locs,5),temp->
    facility[temp_facility_index].loc_facility_cd,encounterlocations->locs[encloc_idx].encfacilitycd)
   IF (flex_enabled=1)
    CALL loadflexparams(temp->facility[temp_facility_index].loc_facility_cd)
    SET temp_order_cnt = size(temp->facility[temp_facility_index].orders,5)
    FOR (temp_order_index = 1 TO temp_order_cnt)
     SET calc_expire_dt_tm = getflexexpirationforperson(temp->facility[temp_facility_index].orders[
      temp_order_index].person_id,0.0,temp->facility[temp_facility_index].orders[temp_order_index].
      drawn_dt_tm,temp->facility[temp_facility_index].loc_facility_cd,0)
     CALL populatereply(temp->facility[temp_facility_index].orders[temp_order_index].order_id,temp->
      facility[temp_facility_index].orders[temp_order_index].catalog_cd,temp->facility[
      temp_facility_index].orders[temp_order_index].updt_cnt,temp->facility[temp_facility_index].
      orders[temp_order_index].catalog_type_cd,temp->facility[temp_facility_index].orders[
      temp_order_index].oe_format_id,
      temp->facility[temp_facility_index].orders[temp_order_index].bb_processing_cd,temp->facility[
      temp_facility_index].orders[temp_order_index].result_id,calc_expire_dt_tm)
    ENDFOR
   ELSE
    SET temp_order_cnt = size(temp->facility[temp_facility_index].orders,5)
    FOR (temp_order_index = 1 TO temp_order_cnt)
      IF (days_hrs="D")
       SET sexpiredttmstring = ""
       SET dtexpiredate = datetimeadd(temp->facility[temp_facility_index].orders[temp_order_index].
        drawn_dt_tm,days)
       SET sexpiredttmstring = format(cnvtdate(dtexpiredate),"DD-MMM-YYYY 23:59:59.99;;D")
       SET calc_expire_dt_tm = cnvtdatetime(sexpiredttmstring)
      ENDIF
      IF (days_hrs="H")
       SET calc_expire_dt_tm = datetimeadd(temp->facility[temp_facility_index].orders[
        temp_order_index].drawn_dt_tm,(hrs/ 24.0))
      ENDIF
      CALL populatereply(temp->facility[temp_facility_index].orders[temp_order_index].order_id,temp->
       facility[temp_facility_index].orders[temp_order_index].catalog_cd,temp->facility[
       temp_facility_index].orders[temp_order_index].updt_cnt,temp->facility[temp_facility_index].
       orders[temp_order_index].catalog_type_cd,temp->facility[temp_facility_index].orders[
       temp_order_index].oe_format_id,
       temp->facility[temp_facility_index].orders[temp_order_index].bb_processing_cd,temp->facility[
       temp_facility_index].orders[temp_order_index].result_id,calc_expire_dt_tm)
    ENDFOR
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->orders,order_cnt)
 IF (ops_param_status=1)
  SELECT INTO "nl:"
   ofm.oe_field_meaning, ofm.description
   FROM oe_field_meaning ofm
   WHERE ofm.oe_field_meaning_id IN (51.0, 1105.0)
   DETAIL
    IF (ofm.oe_field_meaning_id=cancel_dttm_meaning)
     canceldttm = cnvtupper(ofm.oe_field_meaning), canceldttmdesc = cnvtupper(ofm.description)
    ENDIF
    IF (ofm.oe_field_meaning_id=cancel_reason_meaning)
     cancelreason = cnvtupper(ofm.oe_field_meaning), cancelreasondesc = cnvtupper(ofm.description)
    ENDIF
   WITH counter
  ;end select
  SELECT
   off.group_seq, off.field_seq, off.oe_field_id,
   off.oe_format_id, off.value_required_ind, off.label_text
   FROM oe_format_fields off
   WHERE expand(off_idx,1,size(reply->orders,5),off.oe_format_id,reply->orders[off_idx].oe_format_id)
    AND off.accept_flag IN (0, 1)
    AND off.action_type_cd=value(action_cancel_cd)
   ORDER BY off.oe_format_id, off.label_text
   HEAD off.oe_format_id
    row + 0
   HEAD off.label_text
    row + 0
   DETAIL
    FOR (ord_indx = 1 TO size(reply->orders,5))
      IF ((reply->orders[ord_indx].cancel_ind=1)
       AND (reply->orders[ord_indx].oe_format_id=off.oe_format_id))
       IF (cnvtupper(off.label_text)=cancelreasondesc)
        field_cnt = size(reply->orders[ord_indx].detaillist,5), stat = alterlist(reply->orders[
         ord_indx].detaillist,(field_cnt+ 1)), reply->orders[ord_indx].detaillist[(field_cnt+ 1)].
        oe_field_id = off.oe_field_id,
        reply->orders[ord_indx].detaillist[(field_cnt+ 1)].field_seq = off.field_seq, reply->orders[
        ord_indx].detaillist[(field_cnt+ 1)].group_seq = off.group_seq, reply->orders[ord_indx].
        detaillist[(field_cnt+ 1)].value_req_ind = off.value_required_ind,
        reply->orders[ord_indx].detaillist[(field_cnt+ 1)].field_meaning = cancelreason, reply->
        orders[ord_indx].detaillist[(field_cnt+ 1)].field_meaning_id = cancel_reason_meaning
       ENDIF
       IF (((cnvtupper(off.label_text)=canceldttmdesc) OR (cnvtupper(off.label_text)=cnvtupper(
        cancel_date_and_time))) )
        field_cnt = size(reply->orders[ord_indx].detaillist,5), stat = alterlist(reply->orders[
         ord_indx].detaillist,(field_cnt+ 1)), reply->orders[ord_indx].detaillist[(field_cnt+ 1)].
        oe_field_id = off.oe_field_id,
        reply->orders[ord_indx].detaillist[(field_cnt+ 1)].field_seq = off.field_seq, reply->orders[
        ord_indx].detaillist[(field_cnt+ 1)].group_seq = off.group_seq, reply->orders[ord_indx].
        detaillist[(field_cnt+ 1)].value_req_ind = off.value_required_ind,
        reply->orders[ord_indx].detaillist[(field_cnt+ 1)].field_meaning = canceldttm, reply->orders[
        ord_indx].detaillist[(field_cnt+ 1)].field_meaning_id = cancel_dttm_meaning
       ENDIF
      ENDIF
    ENDFOR
   FOOT  off.label_text
    row + 0
   FOOT  off.oe_format_id
    row + 0
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 IF (order_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
#exit_script
 SUBROUTINE (getencounterlocations(facility_cd=f8(value)) =i2)
   DECLARE exp_size = i4 WITH protect, noconstant(0)
   DECLARE x_idx = i4 WITH protect, noconstant(0)
   SET stat = bbtgetencounterlocations(facility_cd,pref_level_bb)
   IF ((stat=- (1)))
    CALL log_message("Error getting encounter facilities for transfusion facility.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET exp_size = size(encounterlocations->locs,5)
   SET validatefacility = locateval(x_idx,1,exp_size,facility_cd,encounterlocations->locs[x_idx].
    encfacilitycd)
   IF (validatefacility=0)
    SET exp_size += 1
    SET stat = alterlist(encounterlocations->locs,exp_size)
    SET encounterlocations->locs[exp_size].encfacilitycd = facility_cd
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (populatereply(order_id=f8(value),catalog_cd=f8(value),updt_cnt=i4(value),catalog_type_cd
  =f8(value),oe_format_id=f8(value),bb_processing_cd=f8(value),result_id=f8(value),expire_dt_tm=dq8(
   value)) =null)
   IF (cnvtdatetime(current_dt_tm_hold) > cnvtdatetime(expire_dt_tm)
    AND (((request->facility_cd=0.0)) OR ((request->facility_cd > 0.0)
    AND encounter_location_found > 0)) )
    IF (result_id > 0.0)
     IF (((bb_processing_cd=abid_cd) OR (((bb_processing_cd=antigen_cd) OR (bb_processing_cd=xm_cd))
     )) )
      SET order_cnt += 1
      IF (size(reply->orders,5) <= order_cnt)
       SET stat = alterlist(reply->orders,(order_cnt+ 10))
      ENDIF
      SET reply->orders[order_cnt].order_id = order_id
      SET reply->orders[order_cnt].catalog_cd = catalog_cd
      SET reply->orders[order_cnt].updt_cnt = updt_cnt
      SET reply->orders[order_cnt].catalog_type_cd = catalog_type_cd
      SET reply->orders[order_cnt].oe_format_id = oe_format_id
      SET reply->orders[order_cnt].updt_cnt = updt_cnt
      SET reply->orders[order_cnt].complete_ind = 1
     ENDIF
    ELSEIF (ops_param_status=1)
     SET order_cnt += 1
     IF (size(reply->orders,5) <= order_cnt)
      SET stat = alterlist(reply->orders,(order_cnt+ 10))
     ENDIF
     SET reply->orders[order_cnt].order_id = order_id
     SET reply->orders[order_cnt].catalog_cd = catalog_cd
     SET reply->orders[order_cnt].updt_cnt = updt_cnt
     SET reply->orders[order_cnt].catalog_type_cd = catalog_type_cd
     SET reply->orders[order_cnt].oe_format_id = oe_format_id
     SET reply->orders[order_cnt].updt_cnt = updt_cnt
     SET reply->orders[order_cnt].cancel_ind = 1
    ENDIF
   ENDIF
 END ;Subroutine
END GO
