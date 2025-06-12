CREATE PROGRAM bbt_get_avail_specimens:dba
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
 RECORD reply(
   1 alert_flag = c1
   1 name_full_formatted = c40
   1 historical_demog_ind = i2
   1 specimen[*]
     2 drawn_dt_tm = di8
     2 unformatted_accession = c20
     2 accession = c20
     2 order_mnemonic = vc
     2 status = c40
     2 expire_dt_tm = di8
     2 historical_name = c40
     2 order_id = f8
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
 DECLARE lspeccnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET expire_cd = 0.0
 SET time_cd = 0.0
 SET expire_time = 0.0
 SET catalog_type_cd = 0.0
 SET activity_type_cd = 0.0
 SET future_cd = 0.0
 SET unscheduled_cd = 0.0
 SET inprocess_cd = 0.0
 SET ordered_cd = 0.0
 SET pending_rev_cd = 0.0
 SET suspended_cd = 0.0
 SET completed_cd = 0.0
 SET dept_scheduled_cd = 0.0
 SET dept_dispatched_cd = 0.0
 DECLARE cdf_meaning = c12
 DECLARE expire_mean = c1 WITH noconstant(fillstring(1," "))
 DECLARE expire_dt_tm = dq8 WITH noconstant(cnvtdatetime(0,0))
 SET code_set = 0
 SET code_cnt = 1
 DECLARE sup_grp_ord_type = i2 WITH constant(2)
 DECLARE ord_set_ord_type = i2 WITH constant(6)
 DECLARE dcurrentnametypecd = f8 WITH protect, noconstant(0.0)
 DECLARE dcombineaddcd = f8 WITH protect, noconstant(0.0)
 DECLARE dactivestatuscd = f8 WITH protect, noconstant(0.0)
 DECLARE dcurrentpersonid = f8 WITH protect, noconstant(0.0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE dminute = f8 WITH protect, constant((1/ 1440.0))
 SET code_set = 1661
 SET cdf_meaning = "XM EXP CALC"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,expire_cd)
 SELECT INTO "nl:"
  expire = uar_get_code_meaning(cnvtreal(trim(a.answer)))
  FROM answer a
  WHERE a.question_cd=expire_cd
   AND a.active_ind=1
  HEAD REPORT
   expire_mean = expire
  WITH nocounter
 ;end select
 IF (expire_mean="D")
  SET cdf_meaning = "XM WARN DYS"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,time_cd)
 ELSE
  SET cdf_meaning = "XM WARN HRS"
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,time_cd)
 ENDIF
 SELECT INTO "nl:"
  time = cnvtint(trim(a.answer))
  FROM answer a
  WHERE a.question_cd=time_cd
   AND a.active_ind=1
  HEAD REPORT
   IF (expire_mean="D")
    expire_time = time
   ELSE
    expire_time = (time/ 24.0)
   ENDIF
  WITH nocounter
 ;end select
 SET code_set = 6000
 SET cdf_meaning = "GENERAL LAB"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,catalog_type_cd)
 SET code_set = 106
 SET cdf_meaning = "BB"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,activity_type_cd)
 SET code_set = 6004
 SET cdf_meaning = "FUTURE"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,future_cd)
 SET cdf_meaning = "UNSCHEDULED"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,unscheduled_cd)
 SET cdf_meaning = "INPROCESS"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,inprocess_cd)
 SET cdf_meaning = "ORDERED"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,ordered_cd)
 SET cdf_meaning = "PENDING REV"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,pending_rev_cd)
 SET cdf_meaning = "SUSPENDED"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,suspended_cd)
 SET cdf_meaning = "COMPLETED"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,completed_cd)
 SET code_set = 14281
 SET cdf_meaning = "LABSCHEDULED"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,dept_scheduled_cd)
 SET cdf_meaning = "LABDISPATCH"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,dept_dispatched_cd)
 SET stat = uar_get_meaning_by_codeset(213,"CURRENT",1,dcurrentnametypecd)
 SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",1,dactivestatuscd)
 SET stat = uar_get_meaning_by_codeset(327,"ADD",1,dcombineaddcd)
 IF (((expire_cd=0.0) OR (((catalog_type_cd=0.0) OR (((activity_type_cd=0.0) OR (((time_cd=0.0) OR (
 ((future_cd=0.0) OR (((unscheduled_cd=0.0) OR (((inprocess_cd=0.0) OR (((ordered_cd=0.0) OR (((
 pending_rev_cd=0.0) OR (((suspended_cd=0.0) OR (((completed_cd=0.0) OR (((dept_scheduled_cd=0.0) OR
 (((dept_dispatched_cd=0.0) OR (((dcurrentnametypecd=0.0) OR (((dcombineaddcd=0.0) OR (
 dactivestatuscd=0.0)) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbt_get_avail_specimens.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  IF (expire_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read the expiration type code value"
  ELSEIF (catalog_type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read the Laboratory Catalog Type code value"
  ELSEIF (activity_type_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read the Blood Bank activity type code value"
  ELSEIF (time_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read the expiration time code value"
  ELSEIF (future_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read the future order status code value"
  ELSEIF (unscheduled_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read the unscheduled order status code value"
  ELSEIF (inprocess_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read the in process order status code value"
  ELSEIF (ordered_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read the ordered order status code value"
  ELSEIF (pending_rev_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read the pending review order status code value"
  ELSEIF (suspended_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read the suspended order status code value"
  ELSEIF (completed_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read the completed order status code value"
  ELSEIF (dept_scheduled_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read the scheduled department status code value"
  ELSEIF (dept_dispatched_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read the dispatched department status code value"
  ELSEIF (dcurrentnametypecd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read the curernt name type code value"
  ELSEIF (dactivestatuscd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read the active status code value"
  ELSEIF (dcombineaddcd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read the combine action add code value"
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to read required code value"
  ENDIF
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 SET reply->historical_demog_ind = bbtgethistoricinfopreference(request->facility_cd)
 SELECT INTO "nl:"
  o.seq, o.current_start_dt_tm, o.person_id,
  o.catalog_type_cd, o.activity_type_cd, o.order_id,
  o.order_mnemonic, dept_status = uar_get_code_display(o.dept_status_cd), aor.accession
  "####################",
  accession = uar_fmt_accession(aor.accession,size(aor.accession,1)), aor.seq, aor.accession_id
  FROM orders o,
   (dummyt d_aor  WITH seq = 1),
   accession_order_r aor
  PLAN (o
   WHERE (o.person_id=request->person_id)
    AND o.catalog_type_cd=catalog_type_cd
    AND o.activity_type_cd=activity_type_cd
    AND o.orderable_type_flag != sup_grp_ord_type
    AND o.orderable_type_flag != ord_set_ord_type)
   JOIN (d_aor
   WHERE d_aor.seq=1)
   JOIN (aor
   WHERE aor.order_id=o.order_id
    AND aor.primary_flag=0)
  ORDER BY o.order_id
  HEAD REPORT
   lspeccnt = 0
  HEAD o.order_id
   IF (o.order_status_cd IN (future_cd, unscheduled_cd, ordered_cd, pending_rev_cd, suspended_cd,
   completed_cd, inprocess_cd))
    IF (expire_mean="D")
     expire_dt_tm = datetimeadd(cnvtdatetime(cnvtdate(o.current_start_dt_tm),235959),expire_time)
    ELSE
     expire_dt_tm = datetimeadd(o.current_start_dt_tm,expire_time)
    ENDIF
    IF (expire_dt_tm > cnvtdatetime(sysdate))
     IF ((request->alert_ind != "Y"))
      lspeccnt += 1, stat = alterlist(reply->specimen,lspeccnt), reply->specimen[lspeccnt].
      drawn_dt_tm = o.current_start_dt_tm
      IF (o.dept_status_cd IN (dept_scheduled_cd, dept_dispatched_cd))
       reply->specimen[lspeccnt].expire_dt_tm = cnvtdatetime("")
      ELSE
       reply->specimen[lspeccnt].expire_dt_tm = expire_dt_tm
      ENDIF
      reply->specimen[lspeccnt].unformatted_accession = aor.accession, reply->specimen[lspeccnt].
      accession = accession, reply->specimen[lspeccnt].order_mnemonic = o.order_mnemonic,
      reply->specimen[lspeccnt].order_id = o.order_id, reply->specimen[lspeccnt].status = dept_status
     ELSE
      reply->alert_flag = "Y"
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter, outerjoin(d_aor)
 ;end select
 IF ((request->alert_ind="Y"))
  IF ((reply->alert_flag != "Y"))
   SET reply->alert_flag = "N"
  ENDIF
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM person p
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.active_ind=1)
  HEAD REPORT
   reply->name_full_formatted = trim(p.name_full_formatted)
  WITH nocounter
 ;end select
 IF ((reply->historical_demog_ind=1))
  FOR (lidx = 1 TO lspeccnt)
    SET dcurrentpersonid = request->person_id
    SELECT INTO "nl:"
     pc.from_person_id
     FROM person_combine_det pcd,
      person_combine pc
     PLAN (pcd
      WHERE (pcd.entity_id=reply->specimen[lidx].order_id)
       AND pcd.entity_name="ORDERS")
      JOIN (pc
      WHERE pc.person_combine_id=pcd.person_combine_id
       AND pc.active_status_cd=dactivestatuscd
       AND pc.active_status_dt_tm >= cnvtdatetime(reply->specimen[lidx].drawn_dt_tm)
       AND pc.active_ind=1)
     ORDER BY pc.active_status_dt_tm
     HEAD REPORT
      dcurrentpersonid = pc.from_person_id
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     pnh.name_full
     FROM person_name_hist pnh
     PLAN (pnh
      WHERE pnh.person_id=dcurrentpersonid
       AND pnh.name_type_cd=dcurrentnametypecd
       AND pnh.transaction_dt_tm <= cnvtdatetime(datetimeadd(reply->specimen[lidx].drawn_dt_tm,
        dminute))
       AND  NOT ( EXISTS (
      (SELECT
       pcd.entity_id
       FROM person_combine_det pcd
       WHERE pcd.entity_id=pnh.person_name_hist_id
        AND pcd.entity_name="PERSON_NAME_HIST"
        AND pcd.combine_action_cd=dcombineaddcd))))
     ORDER BY pnh.transaction_dt_tm DESC
     HEAD REPORT
      reply->specimen[lidx].historical_name = pnh.name_full
     WITH nocounter
    ;end select
  ENDFOR
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
