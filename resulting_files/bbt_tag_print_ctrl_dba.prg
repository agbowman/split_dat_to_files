CREATE PROGRAM bbt_tag_print_ctrl:dba
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
 DECLARE susername = c50 WITH protect, noconstant("")
 DECLARE nstatus = i4 WITH protect, noconstant(0)
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE sunknownstring = vc WITH protect, noconstant("")
 DECLARE sstillbornstring = vc WITH protect, noconstant("")
 SET nstatus = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET sunknownstring = uar_i18ngetmessage(i18nhandle,"UNKNOWN_AGE","Unknown")
 SET sstillbornstring = uar_i18ngetmessage(i18nhandle,"STILLBORN_AGE","Stillborn")
 SELECT INTO "nl:"
  FROM prsnl pl
  WHERE (person_id=reqinfo->updt_id)
  DETAIL
   susername = pl.username
  WITH nocounter
 ;end select
 SUBROUTINE (formatage(birth_dt_tm=f8,deceased_dt_tm=f8,policy=vc) =vc WITH protect)
   DECLARE eff_end_dt_tm = f8 WITH private, noconstant(0.0)
   SET eff_end_dt_tm = deceased_dt_tm
   IF (((eff_end_dt_tm=null) OR (eff_end_dt_tm=0.00)) )
    SET eff_end_dt_tm = cnvtdatetime(sysdate)
   ENDIF
   IF (((birth_dt_tm > eff_end_dt_tm) OR (birth_dt_tm=null)) )
    RETURN(sunknownstring)
   ELSEIF (birth_dt_tm=deceased_dt_tm)
    RETURN(sstillbornstring)
   ELSE
    RETURN(cnvtage2(birth_dt_tm,eff_end_dt_tm,0,concat(policy,"/",trim(susername),"/",trim(cnvtstring
       (reqinfo->position_cd,32,2)))))
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
 RECORD tag_request(
   1 debug_ind = i2
   1 tag_type = c20
   1 sub_tag_type = c20
   1 taglist[*]
     2 product_event_id = f8
     2 event_type_cd = f8
     2 event_type_mean = c12
     2 product_id = f8
     2 derivative_ind = i2
     2 person_id = f8
     2 encntr_id = f8
     2 order_id = f8
     2 tech_id = f8
     2 tech_name = c15
     2 pe_event_dt_tm = dq8
     2 name_full_formatted = c50
     2 alias_mrn = c20
     2 alias_fin = c20
     2 alias_ssn = c20
     2 birth_dt_tm = dq8
     2 age = vc
     2 sex_cd = f8
     2 sex_disp = c6
     2 patient_location = c30
     2 prvdr_name_full_formatted = c50
     2 product_cd = f8
     2 product_disp = c40
     2 product_desc = c60
     2 product_nbr = c20
     2 serial_nbr = c22
     2 product_type_barcode = vc
     2 product_sub_nbr = c5
     2 alternate_nbr = c20
     2 cur_abo_cd = f8
     2 cur_abo_disp = c20
     2 cur_rh_cd = f8
     2 cur_rh_disp = c20
     2 supplier_prefix = c5
     2 segment_nbr = c20
     2 cur_volume = i4
     2 cur_unit_meas_cd = f8
     2 cur_unit_meas_disp = c15
     2 quantity = i4
     2 item_volume = i4
     2 item_unit_per_vial = i4
     2 item_unit_meas_cd = f8
     2 item_unit_meas_disp = c15
     2 bb_id_nbr = c20
     2 product_expire_dt_tm = dq8
     2 accession = c20
     2 xm_result_value_alpha = c15
     2 xm_result_event_prsnl_username = c15
     2 xm_result_event_dt_tm = dq8
     2 xm_expire_dt_tm = dq8
     2 reason_cd = f8
     2 reason_disp = c15
     2 person_abo_cd = f8
     2 person_abo_disp = c20
     2 person_rh_cd = f8
     2 person_rh_disp = c20
     2 antibody_cnt = i4
     2 antibodylist[*]
       3 antibody_cd = f8
       3 antibody_disp = c15
       3 trans_req_ind = i2
     2 antigen_cnt = i4
     2 antigenlist[*]
       3 antigen_cd = f8
       3 antigen_disp = c15
     2 cmpnt_cnt = i4
     2 cmpntlist[*]
       3 product_id = f8
       3 product_cd = f8
       3 product_disp = c40
       3 product_nbr = c20
       3 serial_nbr = c22
       3 product_sub_nbr = c5
       3 cur_abo_cd = f8
       3 cur_abo_disp = c20
       3 cur_rh_cd = f8
       3 supplier_prefix = c5
       3 cur_rh_disp = c20
     2 unknown_patient_ind = i2
     2 unknown_patient_text = c50
     2 dispense_tech_id = f8
     2 dispense_tech_username = c15
     2 dispense_dt_tm = dq8
     2 dispense_courier_id = f8
     2 dispense_courier = c50
     2 dispense_prvdr_id = f8
     2 dispense_prvdr_name = c50
     2 pooled_product_ind = i2
     2 admit_prvdr_id = f8
     2 admit_prvdr_name = c50
     2 anchor_dt_tm = dq8
     2 person_aborh_barcode = vc
     2 product_barcode_nbr = c20
     2 cur_supplier_id = f8
     2 pooled_product_ind = i2
     2 alpha_translation_ind = i2
     2 alias_mrn_formatted = c25
     2 alias_fin_formatted = c25
     2 alias_ssn_formatted = c25
     2 flag_chars = c2
     2 owner_area = f8
     2 inventory_area = f8
     2 address[*]
       3 enc_loc_facility_cd = f8
       3 enc_facility_address1 = vc
       3 enc_facility_address2 = vc
       3 enc_facility_address3 = vc
       3 enc_facility_address4 = vc
       3 enc_facility_citystatezip = vc
       3 enc_facility_country = vc
   1 bbid_preference_ind = i2
 )
 RECORD alpha_translations(
   1 alpha_trans_list[*]
     2 alpha_barcode = vc
     2 alpha_trans = vc
 )
 RECORD reply(
   1 rpt_filename = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET crossmatch_tag = "CROSSMATCH"
 SET component_tag = "COMPONENT"
 SET emergency_tag = "EMERGENCY"
 SET pilot_lbl = "PILOT"
 SET blank_formatted_sub_tag = "BLANK/FORMATTED"
 SET blank_sub_tag = "BLANK"
 SET reprint_sub_tag = "REPRINT"
 SET bb_processing_code_set = 1636
 SET xm_interp_cdf_meaning = "HISTRY & UPD"
 SET result_stat_code_set = 1901
 SET verified_status_cdf_meaning = "VERIFIED"
 SET corrected_status_cdf_meaning = "CORRECTED"
 SET person_alias_type_code_set = 4
 SET encntr_alias_type_code_set = 319
 SET mrn_alias_cdf_meaning = "MRN"
 SET fin_alias_cdf_meaning = "FIN NBR"
 SET ssn_alias_cdf_meaning = "SSN"
 SET encntr_prsnl_code_set = 333
 SET admit_dr_cdf_meaning = "ADMITDOC"
 SET temp_str = "            "
 DECLARE current_name_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",213,"CURRENT"))
 DECLARE mrn_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE ssn_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE active_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE business_address_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,
   "BUSINESS"))
 DECLARE current_time = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE current_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE current_encntr_id = f8 WITH protect, noconstant(0.0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE dorder_id = f8 WITH protect, noconstant(0.0)
 DECLARE dproduct_event_id = f8 WITH protect, noconstant(0.0)
 DECLARE dmrn_populated = i2 WITH protect, noconstant(0)
 DECLARE dssn_populated = i2 WITH protect, noconstant(0)
 DECLARE combine_add_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",327,"ADD"))
 DECLARE dminute = f8 WITH protect, constant((1/ 1440.0))
 SET tag_type = fillstring(20," ")
 SET sub_tag_type = fillstring(20," ")
 SET tot_tag_cnt = 0
 SET rpt_filename = fillstring(45," ")
 SET xm_interp_cd = 0.0
 SET verified_status_cd = 0.0
 SET corrected_status_cd = 0.0
 SET reply->status_data.status = " "
 SET count1 = 0
 SET antibody_cnt = 0
 SET antigen_cnt = 0
 SET cmpnt_cnt = 0
 SET max_antibody_cnt = 10
 SET max_antigen_cnt = 10
 SET max_cmpnt_cnt = 10
 SET hhmm_hd = 0
 SET person_mrn_alias_type_cd = 0.0
 SET person_ssn_alias_type_cd = 0.0
 SET encntr_mrn_alias_type_cd = 0.0
 SET encntr_fin_alias_type_cd = 0.0
 SET admit_dr_cd = 0.0
 DECLARE historical_demog_ind = i2 WITH public, noconstant(0)
 DECLARE get_next = i2 WITH protect, noconstant(0)
 DECLARE print_disp_encntr = i2 WITH public, noconstant(0)
 DECLARE encntr_id = f8 WITH protect, noconstant(0.0)
 DECLARE nloadsupplier = i2 WITH protect, noconstant(0)
 DECLARE nloadalphatrans = i2 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE scrossmatchtagname = vc WITH protect, noconstant(" ")
 DECLARE scomponenttagname = vc WITH protect, noconstant(" ")
 DECLARE semergencytagname = vc WITH protect, noconstant(" ")
 DECLARE findpersonaborhbarcode() = i2 WITH protect
 DECLARE populatealphatrans() = i2 WITH protect
 DECLARE untranslateproductnbr() = i2 WITH protect
 SET tag_request->bbid_preference_ind = bbtgetbbidtagpreference(request->facility_cd)
 SET scrossmatchtagname = trim(bbtgetxmtagpreference(request->facility_cd))
 IF (textlen(trim(scrossmatchtagname)) > 0)
  IF (checkprg(cnvtupper(scrossmatchtagname)) != 0)
   CALL log_message("we are executing the crossmatch tag object",log_level_debug)
  ELSE
   CALL log_message("the crossmatch tag object could not be found",log_level_error)
  ENDIF
 ENDIF
 SET scomponenttagname = trim(bbtgetcomponenttagpreference(request->facility_cd))
 IF (textlen(trim(scomponenttagname)) > 0)
  IF (checkprg(cnvtupper(scomponenttagname)) != 0)
   CALL log_message("we are executing the component tag object",log_level_debug)
  ELSE
   CALL log_message("the component tag object could not be found",log_level_error)
  ENDIF
 ENDIF
 SET semergencytagname = trim(bbtgetemergencytagpreference(request->facility_cd))
 IF (textlen(trim(semergencytagname)) > 0)
  IF (checkprg(cnvtupper(semergencytagname)) != 0)
   CALL log_message("we are executing the emergency tag object",log_level_debug)
  ELSE
   CALL log_message("the emergency tag object could not be found",log_level_error)
  ENDIF
 ENDIF
 DECLARE assigned_cdf_meaning = c12
 DECLARE quarantined_cdf_meaning = c12
 DECLARE crossmatched_cdf_meaning = c12
 DECLARE issued_cdf_meaning = c12
 DECLARE disposed_cdf_meaning = c12
 DECLARE transferred_cdf_meaning = c12
 DECLARE transfused_cdf_meaning = c12
 DECLARE modified_cdf_meaning = c12
 DECLARE unconfirmed_cdf_meaning = c12
 DECLARE autologous_cdf_meaning = c12
 DECLARE directed_cdf_meaning = c12
 DECLARE available_cdf_meaning = c12
 DECLARE received_cdf_meaning = c12
 DECLARE destroyed_cdf_meaning = c12
 DECLARE shipped_cdf_meaning = c12
 DECLARE in_progress_cdf_meaning = c12
 DECLARE pooled_cdf_meaning = c12
 DECLARE pooled_product_cdf_meaning = c12
 DECLARE confirmed_cdf_meaning = c12
 DECLARE drawn_cdf_meaning = c12
 DECLARE tested_cdf_meaning = c12
 DECLARE intransit_cdf_meaning = c12
 DECLARE transferred_from_cdf_meaning = c12
 SET product_state_code_set = 1610
 SET product_state_expected_cnt = 19
 SET assigned_cdf_meaning = "1"
 SET quarantined_cdf_meaning = "2"
 SET crossmatched_cdf_meaning = "3"
 SET issued_cdf_meaning = "4"
 SET disposed_cdf_meaning = "5"
 SET transferred_cdf_meaning = "6"
 SET transfused_cdf_meaning = "7"
 SET modified_cdf_meaning = "8"
 SET unconfirmed_cdf_meaning = "9"
 SET autologous_cdf_meaning = "10"
 SET directed_cdf_meaning = "11"
 SET available_cdf_meaning = "12"
 SET received_cdf_meaning = "13"
 SET destroyed_cdf_meaning = "14"
 SET shipped_cdf_meaning = "15"
 SET in_progress_cdf_meaning = "16"
 SET pooled_cdf_meaning = "17"
 SET pooled_product_cdf_meaning = "18"
 SET confirmed_cdf_meaning = "19"
 SET drawn_cdf_meaning = "20"
 SET tested_cdf_meaning = "21"
 SET intransit_cdf_meaning = "25"
 SET modified_product_cdf_meaning = "24"
 SET transferred_from_cdf_meaning = "26"
 SET assigned_event_type_cd = 0.0
 SET quarantined_event_type_cd = 0.0
 SET crossmatched_event_type_cd = 0.0
 SET issued_event_type_cd = 0.0
 SET disposed_event_type_cd = 0.0
 SET transferred_event_type_cd = 0.0
 SET transfused_event_type_cd = 0.0
 SET modified_event_type_cd = 0.0
 SET unconfirmed_event_type_cd = 0.0
 SET autologous_event_type_cd = 0.0
 SET directed_event_type_cd = 0.0
 SET available_event_type_cd = 0.0
 SET received_event_type_cd = 0.0
 SET destroyed_event_type_cd = 0.0
 SET shipped_event_type_cd = 0.0
 SET in_progress_event_type_cd = 0.0
 SET pooled_event_type_cd = 0.0
 SET pooled_product_event_type_cd = 0.0
 SET confirmed_event_type_cd = 0.0
 SET drawn_event_type_cd = 0.0
 SET tested_event_type_cd = 0.0
 SET in_transit_event_type_cd = 0.0
 SET modified_product_event_type_cd = 0.0
 SET transferred_from_event_type_cd = 0.0
 SET get_event_type_cds_status = " "
 IF (get_event_type_cds_ctrl(0)=0)
  GO TO exit_script
 ENDIF
 SET gsub_code_value = 0.0
 SET tag_type = cnvtupper(request->tag_type)
 SET sub_tag_type = cnvtupper(request->sub_tag_type)
 SET tot_tag_cnt = size(request->taglist,5)
 SET tag_request->debug_ind = request->debug_ind
 SET tag_request->tag_type = request->tag_type
 SET tag_request->sub_tag_type = request->sub_tag_type
 SET stat = alterlist(tag_request->taglist,tot_tag_cnt)
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(tot_tag_cnt))
  DETAIL
   tag_request->taglist[d.seq].product_event_id = request->taglist[d.seq].product_event_id
  WITH nocounter
 ;end select
 SET historical_demog_ind = bbtgethistoricinfopreference(request->facility_cd)
 IF (tag_type=crossmatch_tag)
  SET print_disp_encntr = bbtprintdispenseencounteridentifier(request->facility_cd)
 ENDIF
 SET encntr_mrn_alias_type_cd = 0.0
 SET temp_str = mrn_alias_cdf_meaning
 CALL get_code_value(encntr_alias_type_code_set,temp_str)
 IF (gsub_code_value=0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname =
  "get encounter encntr_mrn_alias_type_cd"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_tag_print_ctrl"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get encounter mrn alias type code_value"
  GO TO exit_script
 ELSE
  SET encntr_mrn_alias_type_cd = gsub_code_value
 ENDIF
 SET encntr_fin_alias_type_cd = 0.0
 SET temp_str = fin_alias_cdf_meaning
 CALL get_code_value(encntr_alias_type_code_set,temp_str)
 IF (gsub_code_value=0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get encntr_fin_alias_type_cd"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_tag_print_ctrl"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get fin nbr encntr alias type code_value"
  GO TO exit_script
 ELSE
  SET encntr_fin_alias_type_cd = gsub_code_value
 ENDIF
 SET person_ssn_alias_type_cd = 0.0
 SET temp_str = ssn_alias_cdf_meaning
 CALL get_code_value(person_alias_type_code_set,temp_str)
 IF (gsub_code_value=0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get person person_ssn_alias_type_cd"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_tag_print_ctrl"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get person ssn alias type code_value"
  GO TO exit_script
 ELSE
  SET person_ssn_alias_type_cd = gsub_code_value
 ENDIF
 SET temp_str = admit_dr_cdf_meaning
 CALL get_code_value(encntr_prsnl_code_set,temp_str)
 IF (gsub_code_value=0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get admit_dr_cd"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_tag_print_ctrl"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get admit doctor type code_value"
  GO TO exit_script
 ELSE
  SET admit_dr_cd = gsub_code_value
 ENDIF
 IF (tag_type=crossmatch_tag
  AND sub_tag_type=reprint_sub_tag)
  SET xm_interp_cd = 0.0
  SET temp_str = xm_interp_cdf_meaning
  CALL get_code_value(bb_processing_code_set,temp_str)
  IF (gsub_code_value=0)
   SET count1 += 1
   IF (count1 > 1)
    SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[count1].operationname = "get xm_interp code_value"
   SET reply->status_data.subeventstatus[count1].operationstatus = "F"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_tag_print_ctrl"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get xm_interp code_value"
   GO TO exit_script
  ELSE
   SET xm_interp_cd = gsub_code_value
  ENDIF
  SET verified_status_cd = 0.0
  SET temp_str = verified_status_cdf_meaning
  CALL get_code_value(result_stat_code_set,temp_str)
  IF (gsub_code_value=0)
   SET count1 += 1
   IF (count1 > 1)
    SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[count1].operationname = "get verified status code_value"
   SET reply->status_data.subeventstatus[count1].operationstatus = "F"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_tag_print_ctrl"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get verified status code_value"
   GO TO exit_script
  ELSE
   SET verified_status_cd = gsub_code_value
  ENDIF
  SET corrected_status_cd = 0.0
  SET temp_str = corrected_status_cdf_meaning
  CALL get_code_value(result_stat_code_set,temp_str)
  IF (gsub_code_value=0)
   SET count1 += 1
   IF (count1 > 1)
    SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[count1].operationname = "get corrected status code_value"
   SET reply->status_data.subeventstatus[count1].operationstatus = "F"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_tag_print_ctrl"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get corrected status code_value"
   GO TO exit_script
  ELSE
   SET corrected_status_cd = gsub_code_value
  ENDIF
 ENDIF
 SET person_mrn_alias_type_cd = 0.0
 SET temp_str = mrn_alias_cdf_meaning
 CALL get_code_value(person_alias_type_code_set,temp_str)
 IF (gsub_code_value=0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get person person_mrn_alias_type_cd"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_tag_print_ctrl"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get person mrn alias type code_value"
  GO TO exit_script
 ELSE
  SET person_mrn_alias_type_cd = gsub_code_value
 ENDIF
 IF (sub_tag_type=blank_formatted_sub_tag)
  SELECT INTO "nl:"
   d.seq
   FROM (dummyt d  WITH seq = value(tot_tag_cnt))
   DETAIL
    tag_request->taglist[d.seq].tech_name = fillstring(15,"X"), tag_request->taglist[d.seq].
    pe_event_dt_tm = cnvtdatetime(sysdate), tag_request->taglist[d.seq].name_full_formatted =
    fillstring(40,"X"),
    tag_request->taglist[d.seq].alias_mrn = fillstring(20,"X"), tag_request->taglist[d.seq].alias_fin
     = fillstring(20,"X"), tag_request->taglist[d.seq].alias_ssn = fillstring(20,"X"),
    tag_request->taglist[d.seq].age = fillstring(12,"X"), tag_request->taglist[d.seq].sex_disp =
    "XXXXXX", tag_request->taglist[d.seq].patient_location = fillstring(30,"X"),
    tag_request->taglist[d.seq].prvdr_name_full_formatted = fillstring(40,"X"), tag_request->taglist[
    d.seq].product_disp = fillstring(20,"X"), tag_request->taglist[d.seq].product_desc = fillstring(
     60,"X"),
    tag_request->taglist[d.seq].product_nbr = fillstring(20,"X"), tag_request->taglist[d.seq].
    serial_nbr = fillstring(22,"X"), tag_request->taglist[d.seq].product_type_barcode = fillstring(22,
     "X"),
    tag_request->taglist[d.seq].product_sub_nbr = fillstring(5,"X"), tag_request->taglist[d.seq].
    alternate_nbr = fillstring(20,"X"), tag_request->taglist[d.seq].segment_nbr = fillstring(20,"X"),
    tag_request->taglist[d.seq].cur_volume = 9999, tag_request->taglist[d.seq].cur_unit_meas_disp =
    fillstring(15,"X"), tag_request->taglist[d.seq].item_unit_meas_disp = fillstring(15,"X"),
    tag_request->taglist[d.seq].bb_id_nbr = fillstring(20,"X"), tag_request->taglist[d.seq].
    product_expire_dt_tm = cnvtdatetime(sysdate), tag_request->taglist[d.seq].accession = fillstring(
     20,"X"),
    tag_request->taglist[d.seq].xm_result_value_alpha = fillstring(10,"X"), tag_request->taglist[d
    .seq].xm_result_event_prsnl_username = fillstring(15,"X"), tag_request->taglist[d.seq].
    xm_result_event_dt_tm = cnvtdatetime(sysdate),
    tag_request->taglist[d.seq].xm_expire_dt_tm = cnvtdatetime(sysdate), tag_request->taglist[d.seq].
    reason_disp = fillstring(15,"X"), tag_request->taglist[d.seq].person_abo_disp = fillstring(13,"X"
     ),
    tag_request->taglist[d.seq].person_rh_disp = fillstring(10,"X"), tag_request->taglist[d.seq].
    cur_abo_disp = fillstring(13,"X"), tag_request->taglist[d.seq].supplier_prefix = fillstring(5,"X"
     ),
    tag_request->taglist[d.seq].cur_rh_disp = fillstring(10,"X"), max_antibody_cnt = 27, tag_request
    ->taglist[d.seq].antibody_cnt = 27,
    stat = alterlist(tag_request->taglist[d.seq].antibodylist,27)
    FOR (antbdy = 1 TO 27)
     tag_request->taglist[d.seq].antibodylist[antbdy].antibody_disp = "XXXXXXXXXX",
     IF (antbdy < 14)
      tag_request->taglist[d.seq].antibodylist[antbdy].trans_req_ind = 0
     ELSE
      tag_request->taglist[d.seq].antibodylist[antbdy].trans_req_ind = 1
     ENDIF
    ENDFOR
    max_antigen_cnt = 27, tag_request->taglist[d.seq].antigen_cnt = 27, stat = alterlist(tag_request
     ->taglist[d.seq].antigenlist,27)
    FOR (antgen = 1 TO 27)
      tag_request->taglist[d.seq].antigenlist[antgen].antigen_disp = "XXXXXXXXXX"
    ENDFOR
    max_cmpnt_cnt = 40, tag_request->taglist[d.seq].cmpnt_cnt = 40, stat = alterlist(tag_request->
     taglist[d.seq].cmpntlist,40)
    FOR (cmpnt = 1 TO 40)
      tag_request->taglist[d.seq].cmpntlist[cmpnt].product_id = 0.0, tag_request->taglist[d.seq].
      cmpntlist[cmpnt].product_cd = 0.0, tag_request->taglist[d.seq].cmpntlist[cmpnt].product_disp =
      fillstring(20,"X"),
      tag_request->taglist[d.seq].cmpntlist[cmpnt].product_nbr = fillstring(20,"X"), tag_request->
      taglist[d.seq].cmpntlist[cmpnt].serial_nbr = fillstring(22,"X"), tag_request->taglist[d.seq].
      cmpntlist[cmpnt].product_sub_nbr = fillstring(5,"X"),
      tag_request->taglist[d.seq].cmpntlist[cmpnt].cur_abo_cd = 0.0, tag_request->taglist[d.seq].
      cmpntlist[cmpnt].cur_abo_disp = fillstring(13,"X"), tag_request->taglist[d.seq].cmpntlist[cmpnt
      ].supplier_prefix = "XXXXX",
      tag_request->taglist[d.seq].cmpntlist[cmpnt].cur_rh_cd = 0.0, tag_request->taglist[d.seq].
      cmpntlist[cmpnt].cur_rh_disp = fillstring(10,"X")
    ENDFOR
    tag_request->taglist[d.seq].unknown_patient_text = fillstring(50,"X"), tag_request->taglist[d.seq
    ].dispense_tech_username = fillstring(15,"X"), tag_request->taglist[d.seq].dispense_courier =
    fillstring(50,"X"),
    tag_request->taglist[d.seq].dispense_prvdr_name = fillstring(50,"X"), tag_request->taglist[d.seq]
    .admit_prvdr_name = fillstring(50,"X"), tag_request->taglist[d.seq].alias_mrn_formatted =
    fillstring(20,"X"),
    tag_request->taglist[d.seq].alias_fin_formatted = fillstring(20,"X"), tag_request->taglist[d.seq]
    .alias_ssn_formatted = fillstring(20,"X")
   WITH nocounter
  ;end select
 ELSEIF (sub_tag_type=reprint_sub_tag)
  IF (print_disp_encntr > 0)
   SELECT
    *
    FROM (dummyt d  WITH seq = value(tag_request->taglist)),
     product_event pe
    PLAN (d
     WHERE (tag_request->taglist[d.seq].product_event_id > 0.0))
     JOIN (pe
     WHERE (pe.related_product_event_id=tag_request->taglist[d.seq].product_event_id)
      AND pe.event_type_cd=issued_event_type_cd
      AND pe.active_ind=1)
    DETAIL
     encntr_id = pe.encntr_id
    WITH nocounter
   ;end select
  ENDIF
  SELECT INTO "nl:"
   pe.product_id, pe.person_id, pe.encntr_id,
   pe.order_id, event_type_mean = decode(pe.seq,uar_get_code_meaning(pe.event_type_cd),"            "
    ), o.last_update_provider_id,
   o_pnl.name_full_formatted, aor.accession, loc_building_disp = uar_get_code_display(e
    .loc_building_cd),
   loc_nurse_unit_disp = uar_get_code_display(e.loc_nurse_unit_cd), loc_room_disp =
   uar_get_code_display(e.loc_room_cd), loc_bed_disp = uar_get_code_display(e.loc_bed_cd)
   FROM (dummyt d  WITH seq = value(tot_tag_cnt)),
    product_event pe,
    prsnl pnl,
    encounter e,
    orders o,
    prsnl o_pnl,
    (dummyt d_aor  WITH seq = 1),
    accession_order_r aor
   PLAN (d
    WHERE (tag_request->taglist[d.seq].product_event_id > 0.0)
     AND tag_request->taglist[d.seq].product_event_id)
    JOIN (pe
    WHERE (pe.product_event_id=tag_request->taglist[d.seq].product_event_id))
    JOIN (pnl
    WHERE pnl.person_id=pe.event_prsnl_id
     AND pe.event_prsnl_id != null
     AND pe.event_prsnl_id > 0)
    JOIN (e
    WHERE e.encntr_id=pe.encntr_id
     AND pe.encntr_id != null)
    JOIN (o
    WHERE o.order_id=pe.order_id
     AND pe.order_id != null)
    JOIN (o_pnl
    WHERE o_pnl.person_id=o.last_update_provider_id
     AND o_pnl.person_id != null)
    JOIN (d_aor
    WHERE d_aor.seq=1)
    JOIN (aor
    WHERE aor.order_id=pe.order_id
     AND aor.primary_flag=0
     AND pe.order_id != null)
   ORDER BY d.seq
   HEAD d.seq
    tag_request->taglist[d.seq].event_type_cd = pe.event_type_cd, tag_request->taglist[d.seq].
    event_type_mean = event_type_mean, tag_request->taglist[d.seq].product_id = pe.product_id,
    tag_request->taglist[d.seq].person_id = pe.person_id, tag_request->taglist[d.seq].encntr_id =
    IF (encntr_id=0) pe.encntr_id
    ELSE encntr_id
    ENDIF
    , tag_request->taglist[d.seq].order_id = pe.order_id,
    tag_request->taglist[d.seq].pe_event_dt_tm = pe.event_dt_tm, tag_request->taglist[d.seq].tech_id
     = pe.event_prsnl_id, tag_request->taglist[d.seq].tech_name = pnl.username
    IF (pe.order_id > 0.0)
     tag_request->taglist[d.seq].anchor_dt_tm = o.current_start_dt_tm
    ELSE
     tag_request->taglist[d.seq].anchor_dt_tm = pe.event_dt_tm
    ENDIF
   DETAIL
    IF (o.order_id > 0)
     tag_request->taglist[d.seq].prvdr_name_full_formatted = o_pnl.name_full_formatted
    ENDIF
    IF (aor.accession_id > 0)
     tag_request->taglist[d.seq].accession = uar_fmt_accession(aor.accession,size(aor.accession,1))
    ENDIF
    tag_request->taglist[d.seq].patient_location = trim(loc_building_disp)
    IF (size(trim(loc_nurse_unit_disp)) > 0)
     tag_request->taglist[d.seq].patient_location = concat(trim(tag_request->taglist[d.seq].
       patient_location)," ",trim(loc_nurse_unit_disp))
    ENDIF
    IF (size(trim(loc_room_disp)) > 0)
     tag_request->taglist[d.seq].patient_location = concat(trim(tag_request->taglist[d.seq].
       patient_location)," ",trim(loc_room_disp))
    ENDIF
    IF (size(trim(loc_bed_disp)) > 0)
     tag_request->taglist[d.seq].patient_location = concat(trim(tag_request->taglist[d.seq].
       patient_location)," ",trim(loc_bed_disp))
    ENDIF
   FOOT  d.seq
    row + 0
   WITH nocounter, outerjoin(d_aor)
  ;end select
  IF (curqual > 0)
   SELECT INTO "nl:"
    p.product_nbr, p.serial_number_txt, p.product_cd,
    p.product_type_barcode, p.cur_unit_meas_cd, p.cur_expire_dt_tm,
    product_disp = uar_get_code_display(p.product_cd), product_desc = uar_get_code_description(p
     .product_cd), unit_meas_disp = uar_get_code_display(p.cur_unit_meas_cd),
    sproductnbr = p.product_nbr
    FROM (dummyt d  WITH seq = value(tot_tag_cnt)),
     product p
    PLAN (d)
     JOIN (p
     WHERE (p.product_id=tag_request->taglist[d.seq].product_id)
      AND p.product_id != null
      AND p.product_id > 0)
    DETAIL
     tag_request->taglist[d.seq].product_nbr = p.product_nbr, tag_request->taglist[d.seq].serial_nbr
      = p.serial_number_txt, tag_request->taglist[d.seq].product_sub_nbr = p.product_sub_nbr,
     tag_request->taglist[d.seq].flag_chars = p.flag_chars, tag_request->taglist[d.seq].product_cd =
     p.product_cd, tag_request->taglist[d.seq].product_type_barcode = p.product_type_barcode,
     tag_request->taglist[d.seq].cur_unit_meas_cd = p.cur_unit_meas_cd, tag_request->taglist[d.seq].
     product_expire_dt_tm = p.cur_expire_dt_tm, tag_request->taglist[d.seq].alternate_nbr = p
     .alternate_nbr,
     tag_request->taglist[d.seq].product_disp = product_disp, tag_request->taglist[d.seq].
     product_desc = product_desc, tag_request->taglist[d.seq].cur_unit_meas_disp = unit_meas_disp,
     tag_request->taglist[d.seq].pooled_product_ind = p.pooled_product_ind, tag_request->taglist[d
     .seq].cur_supplier_id = p.cur_supplier_id, tag_request->taglist[d.seq].pooled_product_ind = p
     .pooled_product_ind
     IF (textlen(trim(p.barcode_nbr)) > 0)
      tag_request->taglist[d.seq].product_barcode_nbr = p.barcode_nbr
     ELSE
      IF (findstring("!",trim(sproductnbr),1,0)=1
       AND textlen(trim(sproductnbr)) >= 13
       AND textlen(trim(sproductnbr)) <= 19)
       tag_request->taglist[d.seq].product_barcode_nbr = sproductnbr
      ELSEIF (textlen(trim(sproductnbr))=13)
       tag_request->taglist[d.seq].product_barcode_nbr = sproductnbr
      ELSE
       IF (p.pooled_product_ind=0)
        nloadsupplier = 1
       ENDIF
      ENDIF
     ENDIF
     tag_request->taglist[d.seq].owner_area = p.cur_owner_area_cd, tag_request->taglist[d.seq].
     inventory_area = p.cur_inv_area_cd
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    table_ind = decode(bp.seq,"bp ",drv.seq,"drv","xxx"), bp.cur_abo_cd, bp_abo_disp =
    uar_get_code_display(bp.cur_abo_cd),
    bp.cur_rh_cd, bp_rh_disp = uar_get_code_display(bp.cur_rh_cd), bp.cur_volume,
    drv.item_volume, drv.item_unit_meas_cd, drv_unit_meas_disp = uar_get_code_display(drv
     .item_unit_meas_cd),
    drv.cur_intl_units
    FROM (dummyt d  WITH seq = value(tot_tag_cnt)),
     blood_product bp,
     derivative drv
    PLAN (d)
     JOIN (((bp
     WHERE (bp.product_id=tag_request->taglist[d.seq].product_id)
      AND bp.product_id != null
      AND bp.product_id > 0)
     ) ORJOIN ((drv
     WHERE (drv.product_id=tag_request->taglist[d.seq].product_id))
     ))
    DETAIL
     IF (table_ind="bp ")
      tag_request->taglist[d.seq].derivative_ind = 0, tag_request->taglist[d.seq].cur_abo_cd = bp
      .cur_abo_cd, tag_request->taglist[d.seq].cur_abo_disp = bp_abo_disp,
      tag_request->taglist[d.seq].cur_rh_cd = bp.cur_rh_cd, tag_request->taglist[d.seq].cur_rh_disp
       = bp_rh_disp, tag_request->taglist[d.seq].cur_volume = bp.cur_volume,
      tag_request->taglist[d.seq].item_volume = 0, tag_request->taglist[d.seq].item_unit_meas_cd = 0,
      tag_request->taglist[d.seq].segment_nbr = bp.segment_nbr,
      tag_request->taglist[d.seq].supplier_prefix = bp.supplier_prefix
     ELSEIF (table_ind="drv")
      tag_request->taglist[d.seq].derivative_ind = 1, tag_request->taglist[d.seq].cur_abo_cd = 0,
      tag_request->taglist[d.seq].cur_rh_cd = 0,
      tag_request->taglist[d.seq].cur_volume = 0, tag_request->taglist[d.seq].item_unit_meas_cd = drv
      .item_unit_meas_cd, tag_request->taglist[d.seq].item_unit_meas_disp = drv_unit_meas_disp
      IF (drv.units_per_vial > 0)
       tag_request->taglist[d.seq].item_volume = 0, tag_request->taglist[d.seq].item_unit_per_vial =
       drv.units_per_vial
      ELSE
       tag_request->taglist[d.seq].item_volume = drv.item_volume, tag_request->taglist[d.seq].
       item_unit_per_vial = 0
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    qty = decode(rec.seq,rec.orig_rcvd_qty,tfn.seq,tfn.orig_transfused_qty,pd.seq,
     pd.orig_dispense_qty,a.seq,a.orig_assign_qty), cur_ius = decode(rec.seq,rec.orig_intl_units,tfn
     .seq,tfn.transfused_intl_units,pd.seq,
     pd.orig_dispense_intl_units,a.seq,a.orig_assign_intl_units)
    FROM (dummyt d  WITH seq = value(tot_tag_cnt)),
     assign a,
     patient_dispense pd,
     transfusion tfn,
     receipt rec
    PLAN (d
     WHERE (tag_request->taglist[d.seq].derivative_ind=1))
     JOIN (((a
     WHERE (a.product_event_id=tag_request->taglist[d.seq].product_event_id))
     ) ORJOIN ((((pd
     WHERE (pd.product_event_id=tag_request->taglist[d.seq].product_event_id))
     ) ORJOIN ((((tfn
     WHERE (tfn.product_event_id=tag_request->taglist[d.seq].product_event_id))
     ) ORJOIN ((rec
     WHERE (rec.product_event_id=tag_request->taglist[d.seq].product_event_id))
     )) )) ))
    DETAIL
     tag_request->taglist[d.seq].quantity = qty
     IF ((tag_request->taglist[d.seq].item_unit_per_vial > 0))
      tag_request->taglist[d.seq].item_volume = cur_ius
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    table_ind = decode(epr.seq,"epr",pabo.seq,"abo",ea.seq,
     "ea ",pa.seq,"pa ","xxx"), per.name_full_formatted, per.birth_dt_tm,
    per.sex_cd, sex_disp = uar_get_code_display(per.sex_cd), pa.seq,
    pa.alias, ea.seq, ea.alias,
    pabo.seq, pabo.abo_cd, abo_disp = uar_get_code_display(pabo.abo_cd),
    pabo.rh_cd, rh_disp = uar_get_code_display(pabo.rh_cd), epr.seq,
    epr.prsnl_person_id
    FROM (dummyt d  WITH seq = value(tot_tag_cnt)),
     person per,
     (dummyt d2  WITH seq = 1),
     person_alias pa,
     encounter e,
     encntr_alias ea,
     person_aborh pabo,
     encntr_prsnl_reltn epr,
     prsnl pnl
    PLAN (d)
     JOIN (per
     WHERE (per.person_id=tag_request->taglist[d.seq].person_id)
      AND per.person_id != null
      AND per.person_id > 0)
     JOIN (d2
     WHERE d2.seq=1)
     JOIN (((pa
     WHERE pa.person_id=per.person_id
      AND pa.person_alias_type_cd IN (person_ssn_alias_type_cd, person_mrn_alias_type_cd)
      AND pa.active_ind=1
      AND pa.alias_pool_cd > 0
      AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND pa.end_effective_dt_tm >= cnvtdatetime(sysdate))
     ) ORJOIN ((((e
     WHERE e.person_id=per.person_id
      AND (e.encntr_id=tag_request->taglist[d.seq].encntr_id)
      AND (tag_request->taglist[d.seq].encntr_id != null)
      AND (tag_request->taglist[d.seq].encntr_id > 0))
     JOIN (ea
     WHERE ea.encntr_id=e.encntr_id
      AND ((ea.encntr_alias_type_cd=encntr_fin_alias_type_cd) OR (ea.encntr_alias_type_cd=
     encntr_mrn_alias_type_cd))
      AND ea.active_ind=1
      AND ea.alias_pool_cd > 0
      AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
     ) ORJOIN ((((pabo
     WHERE pabo.person_id=per.person_id
      AND pabo.active_ind=1)
     ) ORJOIN ((epr
     WHERE (epr.encntr_id=tag_request->taglist[d.seq].encntr_id)
      AND epr.encntr_prsnl_r_cd=admit_dr_cd)
     JOIN (pnl
     WHERE pnl.person_id=epr.prsnl_person_id)
     )) )) ))
    ORDER BY d.seq
    HEAD d.seq
     tag_request->taglist[d.seq].name_full_formatted = per.name_full_formatted
     IF (curutc=1)
      tag_request->taglist[d.seq].birth_dt_tm = datetimezoneutc(per.birth_dt_tm,per.birth_tz)
     ELSE
      tag_request->taglist[d.seq].birth_dt_tm = datetimezone(per.birth_dt_tm,per.birth_tz)
     ENDIF
     tag_request->taglist[d.seq].age = formatage(per.birth_dt_tm,per.deceased_dt_tm,"LABRPTAGE"),
     tag_request->taglist[d.seq].sex_cd = per.sex_cd, tag_request->taglist[d.seq].sex_disp = sex_disp
    DETAIL
     IF (table_ind="pa ")
      IF (pa.person_alias_type_cd=person_ssn_alias_type_cd)
       tag_request->taglist[d.seq].alias_ssn = pa.alias, tag_request->taglist[d.seq].
       alias_ssn_formatted = cnvtalias(pa.alias,pa.alias_pool_cd)
      ENDIF
      IF (pa.person_alias_type_cd=person_mrn_alias_type_cd)
       tag_request->taglist[d.seq].alias_mrn = pa.alias, tag_request->taglist[d.seq].
       alias_mrn_formatted = cnvtalias(pa.alias,pa.alias_pool_cd)
      ENDIF
     ELSEIF (table_ind="ea ")
      IF (ea.encntr_alias_type_cd=encntr_fin_alias_type_cd)
       tag_request->taglist[d.seq].alias_fin = ea.alias, tag_request->taglist[d.seq].
       alias_fin_formatted = cnvtalias(ea.alias,ea.alias_pool_cd)
      ELSEIF (ea.encntr_alias_type_cd=encntr_mrn_alias_type_cd
       AND ea.encntr_id > 0)
       tag_request->taglist[d.seq].alias_mrn = ea.alias, tag_request->taglist[d.seq].
       alias_mrn_formatted = cnvtalias(ea.alias,ea.alias_pool_cd)
      ENDIF
     ELSEIF (table_ind="abo")
      tag_request->taglist[d.seq].person_abo_cd = pabo.abo_cd, tag_request->taglist[d.seq].
      person_abo_disp = abo_disp, tag_request->taglist[d.seq].person_rh_cd = pabo.rh_cd,
      tag_request->taglist[d.seq].person_rh_disp = rh_disp
     ELSEIF (table_ind="epr")
      tag_request->taglist[d.seq].admit_prvdr_id = epr.prsnl_person_id, tag_request->taglist[d.seq].
      admit_prvdr_name = pnl.name_full_formatted
     ENDIF
    FOOT  d.seq
     row + 0
    WITH nocounter, outerjoin(d2)
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tot_tag_cnt)),
     encounter e,
     address ad
    PLAN (d)
     JOIN (e
     WHERE (e.encntr_id=tag_request->taglist[d.seq].encntr_id)
      AND e.encntr_id > 0)
     JOIN (ad
     WHERE e.loc_facility_cd=ad.parent_entity_id
      AND ad.active_ind=1
      AND ad.address_type_cd=business_address_type_cd
      AND ad.parent_entity_name="LOCATION")
    ORDER BY d.seq
    HEAD d.seq
     add_cnt = 0, stat = alterlist(tag_request->taglist[d.seq].address,3)
    DETAIL
     add_cnt += 1
     IF (add_cnt > size(tag_request->taglist[d.seq].address,5))
      stat = alterlist(tag_request->taglist[d.seq].address,(add_cnt+ 1))
     ENDIF
     tag_request->taglist[d.seq].address[add_cnt].enc_loc_facility_cd = e.loc_facility_cd,
     tag_request->taglist[d.seq].address[add_cnt].enc_facility_address1 = ad.street_addr, tag_request
     ->taglist[d.seq].address[add_cnt].enc_facility_address2 = ad.street_addr2,
     tag_request->taglist[d.seq].address[add_cnt].enc_facility_address3 = ad.street_addr3,
     tag_request->taglist[d.seq].address[add_cnt].enc_facility_address4 = ad.street_addr4,
     tag_request->taglist[d.seq].address[add_cnt].enc_facility_citystatezip = concat(trim(ad.city),
      ", ",trim(ad.state),"-",trim(ad.zipcode)),
     tag_request->taglist[d.seq].address[add_cnt].enc_facility_country = ad.country
    FOOT  d.seq
     stat = alterlist(tag_request->taglist[d.seq].address,add_cnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    d.seq, pa.person_id, pa.antibody_cd,
    ptr.requirement_cd, pa_ptr_ind = decode(ptr.seq,"1ptr",pa.seq,"0pa ","xxx"), pa_ptr_cd = decode(
     ptr.seq,ptr.requirement_cd,pa.seq,pa.antibody_cd,0.0),
    pa_ptr_disp = decode(ptr.seq,uar_get_code_display(ptr.requirement_cd),pa.seq,uar_get_code_display
     (pa.antibody_cd))
    FROM (dummyt d  WITH seq = value(tot_tag_cnt)),
     person_antibody pa,
     person_trans_req ptr
    PLAN (d)
     JOIN (((pa
     WHERE (pa.person_id=tag_request->taglist[d.seq].person_id)
      AND pa.person_id != null
      AND pa.person_id > 0
      AND pa.active_ind=1
      AND pa.antibody_cd != null
      AND pa.antibody_cd > 0)
     ) ORJOIN ((ptr
     WHERE (ptr.person_id=tag_request->taglist[d.seq].person_id)
      AND ptr.person_id != null
      AND ptr.person_id > 0
      AND ptr.active_ind=1
      AND ptr.requirement_cd != null
      AND ptr.requirement_cd > 0)
     ))
    ORDER BY d.seq, pa.person_id, pa_ptr_ind,
     pa_ptr_disp, pa_ptr_cd
    HEAD d.seq
     antibody_cnt = 0, tag_request->taglist[d.seq].antibody_cnt = 0, max_antibody_cnt = 10,
     stat = alterlist(tag_request->taglist[d.seq].antibodylist,10)
    HEAD pa_ptr_cd
     antibody_cnt += 1
     IF (antibody_cnt > max_antibody_cnt)
      max_antibody_cnt += 10, stat = alterlist(tag_request->taglist[d.seq].antibodylist,
       max_antibody_cnt)
     ENDIF
     tag_request->taglist[d.seq].antibodylist[antibody_cnt].antibody_cd = pa_ptr_cd, tag_request->
     taglist[d.seq].antibodylist[antibody_cnt].antibody_disp = pa_ptr_disp
     IF (pa_ptr_ind="1ptr")
      tag_request->taglist[d.seq].antibodylist[antibody_cnt].trans_req_ind = 1
     ELSE
      tag_request->taglist[d.seq].antibodylist[antibody_cnt].trans_req_ind = 0
     ENDIF
    FOOT  pa_ptr_cd
     row + 0
    FOOT  d.seq
     tag_request->taglist[d.seq].antibody_cnt = antibody_cnt, stat = alterlist(tag_request->taglist[d
      .seq].antibodylist,antibody_cnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    d.seq, st.product_id, st.special_testing_cd,
    special_testing_disp = uar_get_code_display(st.special_testing_cd)
    FROM (dummyt d  WITH seq = value(tot_tag_cnt)),
     special_testing st
    PLAN (d)
     JOIN (st
     WHERE (st.product_id=tag_request->taglist[d.seq].product_id)
      AND st.product_id != null
      AND st.product_id > 0
      AND st.active_ind=1
      AND st.special_testing_cd != null
      AND st.special_testing_cd > 0)
    ORDER BY d.seq, st.special_testing_cd
    HEAD d.seq
     antigen_cnt = 0, max_antigen_cnt = 10, tag_request->taglist[d.seq].antigen_cnt = 0,
     stat = alterlist(tag_request->taglist[d.seq].antigenlist,10)
    HEAD st.special_testing_cd
     antigen_cnt += 1
     IF (antigen_cnt > max_antigen_cnt)
      max_antigen_cnt += 10, stat = alterlist(tag_request->taglist[d.seq].antigenlist,max_antigen_cnt
       )
     ENDIF
     tag_request->taglist[d.seq].antigenlist[antigen_cnt].antigen_cd = st.special_testing_cd,
     tag_request->taglist[d.seq].antigenlist[antigen_cnt].antigen_disp = special_testing_disp
    FOOT  st.special_testing_cd
     row + 0
    FOOT  d.seq
     tag_request->taglist[d.seq].antigen_cnt = antigen_cnt, stat = alterlist(tag_request->taglist[d
      .seq].antigenlist,antigen_cnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    d.seq, p.product_id, p.pooled_product_id,
    p.product_cd, p.product_nbr, p.serial_number_txt,
    p.product_cd, product_disp = uar_get_code_display(p.product_cd), bp.cur_abo_cd,
    abo_disp = uar_get_code_display(bp.cur_abo_cd), bp.cur_rh_cd, rh_disp = uar_get_code_display(bp
     .cur_rh_cd)
    FROM (dummyt d  WITH seq = value(tot_tag_cnt)),
     product p,
     blood_product bp
    PLAN (d
     WHERE (tag_request->taglist[d.seq].pooled_product_ind=1))
     JOIN (p
     WHERE (p.pooled_product_id=tag_request->taglist[d.seq].product_id))
     JOIN (bp
     WHERE bp.product_id=p.product_id)
    ORDER BY d.seq, p.product_id
    HEAD d.seq
     cmpnt_cnt = 0, tag_request->taglist[d.seq].cmpnt_cnt = 0, max_cmpnt_cnt = 10,
     stat = alterlist(tag_request->taglist[d.seq].cmpntlist,10)
    DETAIL
     cmpnt_cnt += 1
     IF (cmpnt_cnt > max_cmpnt_cnt)
      max_cmpnt_cnt += 10, stat = alterlist(tag_request->taglist[d.seq].cmpntlist,max_cmpnt_cnt)
     ENDIF
     tag_request->taglist[d.seq].cmpntlist[cmpnt_cnt].product_id = p.product_id, tag_request->
     taglist[d.seq].cmpntlist[cmpnt_cnt].product_cd = p.product_cd, tag_request->taglist[d.seq].
     cmpntlist[cmpnt_cnt].product_disp = product_disp,
     tag_request->taglist[d.seq].cmpntlist[cmpnt_cnt].product_nbr = p.product_nbr, tag_request->
     taglist[d.seq].cmpntlist[cmpnt_cnt].serial_nbr = p.serial_number_txt, tag_request->taglist[d.seq
     ].cmpntlist[cmpnt_cnt].product_sub_nbr = p.product_sub_nbr,
     tag_request->taglist[d.seq].cmpntlist[cmpnt_cnt].cur_abo_cd = bp.cur_abo_cd, tag_request->
     taglist[d.seq].cmpntlist[cmpnt_cnt].cur_abo_disp = abo_disp, tag_request->taglist[d.seq].
     cmpntlist[cmpnt_cnt].cur_rh_cd = bp.cur_rh_cd,
     tag_request->taglist[d.seq].cmpntlist[cmpnt_cnt].cur_rh_disp = rh_disp, tag_request->taglist[d
     .seq].cmpntlist[cmpnt_cnt].supplier_prefix = bp.supplier_prefix
    FOOT  d.seq
     tag_request->taglist[d.seq].cmpnt_cnt = cmpnt_cnt, stat = alterlist(tag_request->taglist[d.seq].
      cmpntlist,cmpnt_cnt)
    WITH nocounter
   ;end select
   IF (((tag_type=crossmatch_tag
    AND textlen(trim(scrossmatchtagname)) > 0) OR (((tag_type=component_tag
    AND textlen(trim(scomponenttagname)) > 0) OR (tag_type=emergency_tag
    AND textlen(trim(semergencytagname)) > 0)) )) )
    IF (findpersonaborhbarcode(null)=0)
     GO TO exit_script
    ENDIF
    IF (nloadsupplier=1)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(tot_tag_cnt)),
       bb_supplier bbs
      PLAN (d
       WHERE textlen(trim(tag_request->taglist[d.seq].product_barcode_nbr))=0)
       JOIN (bbs
       WHERE (bbs.organization_id=tag_request->taglist[d.seq].cur_supplier_id)
        AND bbs.active_ind=1)
      DETAIL
       IF (bbs.alpha_translation_ind=1)
        nloadalphatrans = 1
       ENDIF
       tag_request->taglist[d.seq].alpha_translation_ind = bbs.alpha_translation_ind
      WITH nocounter
     ;end select
     IF (nloadalphatrans=1)
      IF (populatealphatrans(null)=0)
       GO TO exit_script
      ENDIF
     ENDIF
     IF (untranslateproductnbr(null)=0)
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   IF (print_disp_encntr=0
    AND historical_demog_ind=1)
    FOR (lidx = 1 TO tot_tag_cnt)
      SET current_person_id = tag_request->taglist[lidx].person_id
      SET current_encntr_id = tag_request->taglist[lidx].encntr_id
      SET dorder_id = 0.0
      SET dproduct_event_id = 0.0
      IF ((tag_request->taglist[lidx].order_id > 0.0))
       SET dorder_id = tag_request->taglist[lidx].order_id
       SET dproduct_event_id = - (1)
      ELSEIF ((tag_request->taglist[lidx].product_event_id > 0.0))
       SET dproduct_event_id = tag_request->taglist[lidx].product_event_id
       SET dorder_id = - (1)
      ENDIF
      SELECT INTO "nl:"
       pc.from_person_id
       FROM person_combine_det pcd,
        person_combine pc
       PLAN (pcd
        WHERE ((pcd.entity_id=dorder_id
         AND pcd.entity_name="ORDERS") OR (pcd.entity_id=dproduct_event_id
         AND pcd.entity_name IN ("ASSIGN", "PATIENT_DISPENSE"))) )
        JOIN (pc
        WHERE pc.person_combine_id=pcd.person_combine_id
         AND pc.active_status_cd=active_status_cd
         AND pc.active_status_dt_tm >= cnvtdatetime(tag_request->taglist[lidx].anchor_dt_tm)
         AND pc.active_ind=1)
       ORDER BY pc.active_status_dt_tm
       HEAD REPORT
        current_person_id = pc.from_person_id
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       ec.from_encntr_id
       FROM encntr_combine_det ecd,
        encntr_combine ec
       PLAN (ecd
        WHERE ((ecd.entity_id=dorder_id
         AND ecd.entity_name="ORDERS") OR (ecd.entity_id=dproduct_event_id
         AND ecd.entity_name IN ("ASSIGN", "PATIENT_DISPENSE"))) )
        JOIN (ec
        WHERE ec.encntr_combine_id=ecd.encntr_combine_id
         AND ec.active_status_cd=active_status_cd
         AND ec.active_status_dt_tm >= cnvtdatetime(tag_request->taglist[lidx].anchor_dt_tm)
         AND ec.active_ind=1)
       ORDER BY ec.active_status_dt_tm
       HEAD REPORT
        current_encntr_id = ec.from_encntr_id
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       pnh.name_full
       FROM person_name_hist pnh
       PLAN (pnh
        WHERE pnh.person_id=current_person_id
         AND pnh.name_type_cd=current_name_type_cd
         AND pnh.transaction_dt_tm <= cnvtdatetime(datetimeadd(tag_request->taglist[lidx].
          anchor_dt_tm,dminute))
         AND  NOT ( EXISTS (
        (SELECT
         pcd.entity_id
         FROM person_combine_det pcd
         WHERE pcd.entity_id=pnh.person_name_hist_id
          AND pcd.entity_name="PERSON_NAME_HIST"
          AND pcd.combine_action_cd=combine_add_cd))))
       ORDER BY pnh.transaction_dt_tm DESC
       HEAD REPORT
        tag_request->taglist[lidx].name_full_formatted = pnh.name_full
       WITH nocounter
      ;end select
      SET bmrn_populated = 0
      SET bssn_populated = 0
      SELECT INTO "nl:"
       pah.alias
       FROM person_alias_hist pah,
        person_alias pa
       PLAN (pah
        WHERE pah.person_id=current_person_id
         AND pah.transaction_dt_tm <= cnvtdatetime(datetimeadd(tag_request->taglist[lidx].
          anchor_dt_tm,dminute))
         AND  NOT ( EXISTS (
        (SELECT
         pcd.entity_id
         FROM person_combine_det pcd
         WHERE pcd.entity_id=pah.person_alias_hist_id
          AND pcd.entity_name="PERSON_ALIAS_HIST"
          AND pcd.combine_action_cd=combine_add_cd))))
        JOIN (pa
        WHERE pa.person_alias_id=pah.person_alias_id
         AND pa.end_effective_dt_tm > cnvtdatetime(tag_request->taglist[lidx].anchor_dt_tm))
       ORDER BY pa.person_alias_type_cd, pah.transaction_dt_tm DESC
       HEAD pa.person_alias_type_cd
        CASE (pa.person_alias_type_cd)
         OF mrn_type_cd:
          IF (bmrn_populated=0)
           tag_request->taglist[lidx].alias_mrn = substring(1,20,pah.alias), tag_request->taglist[
           lidx].alias_mrn_formatted = cnvtalias(pah.alias,pa.alias_pool_cd), bmrn_populated = 1
          ENDIF
         OF ssn_type_cd:
          IF (bssn_populated=0)
           tag_request->taglist[lidx].alias_ssn = substring(1,20,pah.alias), tag_request->taglist[
           lidx].alias_ssn_formatted = cnvtalias(pah.alias,pa.alias_pool_cd), bssn_populated = 1
          ENDIF
        ENDCASE
       WITH nocounter
      ;end select
      IF ((tag_request->taglist[lidx].encntr_id > 0))
       SELECT INTO "nl:"
        eah.encntr_id
        FROM encntr_alias_hist eah,
         encntr_alias ea
        PLAN (eah
         WHERE eah.encntr_id=current_encntr_id
          AND eah.transaction_dt_tm <= cnvtdatetime(datetimeadd(tag_request->taglist[lidx].
           anchor_dt_tm,dminute))
          AND  NOT ( EXISTS (
         (SELECT
          ecd.entity_id, ecd.entity_name
          FROM encntr_combine_det ecd
          WHERE ecd.entity_id=eah.encntr_alias_hist_id
           AND ecd.entity_name="ENCNTR_ALIAS_HIST"
           AND ecd.combine_action_cd=combine_add_cd))))
         JOIN (ea
         WHERE ea.encntr_alias_id=eah.encntr_alias_id
          AND ea.encntr_alias_type_cd=encntr_mrn_alias_type_cd
          AND ea.end_effective_dt_tm > cnvtdatetime(tag_request->taglist[lidx].anchor_dt_tm))
        ORDER BY eah.transaction_dt_tm DESC
        HEAD REPORT
         tag_request->taglist[lidx].alias_mrn = substring(1,20,eah.alias), tag_request->taglist[lidx]
         .alias_mrn_formatted = cnvtalias(eah.alias,ea.alias_pool_cd)
        WITH nocounter
       ;end select
      ENDIF
    ENDFOR
   ENDIF
   IF (((tag_type=component_tag) OR (tag_type=emergency_tag)) )
    SELECT INTO "nl:"
     pd.seq, pd.unknown_patient_ind, pd.unknown_patient_text,
     pd.courier_id, pd.courier_text, pnl_ind =
     IF (pnl.person_id > 0
      AND pnl.person_id != null)
      IF (pnl.person_id=pd.dispense_courier_id) 1
      ELSEIF (pnl.person_id=pd.dispense_prov_id) 2
      ELSE 0
      ENDIF
     ELSE 0
     ENDIF
     ,
     pd.dispense_prov_id, pnl.name_full_formatted
     FROM (dummyt d  WITH seq = value(tot_tag_cnt)),
      patient_dispense pd,
      (dummyt d_pnl  WITH seq = 1),
      prsnl pnl
     PLAN (d
      WHERE (tag_request->taglist[d.seq].event_type_mean=issued_cdf_meaning))
      JOIN (pd
      WHERE (pd.product_event_id=tag_request->taglist[d.seq].product_event_id))
      JOIN (d_pnl
      WHERE d_pnl.seq=1)
      JOIN (pnl
      WHERE ((pnl.person_id=pd.dispense_courier_id) OR (pnl.person_id=pd.dispense_prov_id))
       AND pnl.person_id != null
       AND pnl.person_id > 0)
     ORDER BY d.seq
     HEAD d.seq
      IF (pd.unknown_patient_ind=1)
       tag_request->taglist[d.seq].unknown_patient_ind = pd.unknown_patient_ind, tag_request->
       taglist[d.seq].unknown_patient_text = pd.unknown_patient_text
      ENDIF
      tag_request->taglist[d.seq].dispense_tech_id = tag_request->taglist[d.seq].tech_id, tag_request
      ->taglist[d.seq].dispense_tech_username = tag_request->taglist[d.seq].tech_name, tag_request->
      taglist[d.seq].bb_id_nbr = pd.bb_id_nbr,
      tag_request->taglist[d.seq].dispense_dt_tm = cnvtdatetime(tag_request->taglist[d.seq].
       pe_event_dt_tm)
      IF (((pd.dispense_courier_id=0) OR (pd.dispense_courier_id=null)) )
       tag_request->taglist[d.seq].dispense_courier = pd.dispense_courier_text
      ENDIF
     DETAIL
      IF (pnl_ind=1)
       tag_request->taglist[d.seq].dispense_courier_id = pd.dispense_courier_id, tag_request->
       taglist[d.seq].dispense_courier = pnl.username
      ELSEIF (pnl_ind=2)
       tag_request->taglist[d.seq].dispense_prvdr_id = pd.dispense_prov_id, tag_request->taglist[d
       .seq].dispense_prvdr_name = pnl.name_full_formatted
      ENDIF
     FOOT  d.seq
      row + 0
     WITH nocounter, outerjoin(d_pnl)
    ;end select
    SELECT INTO "nl:"
     a.seq
     FROM (dummyt d  WITH seq = value(tot_tag_cnt)),
      assign a
     PLAN (d
      WHERE (tag_request->taglist[d.seq].event_type_mean=assigned_cdf_meaning))
      JOIN (a
      WHERE (a.product_event_id=tag_request->taglist[d.seq].product_event_id))
     ORDER BY d.seq
     HEAD d.seq
      tag_request->taglist[d.seq].bb_id_nbr = a.bb_id_nbr
     FOOT  d.seq
      row + 0
     WITH nocounter
    ;end select
   ELSEIF (tag_type=crossmatch_tag)
    SELECT INTO "nl:"
     rpe.product_event_id, pd.seq, pd.unknown_patient_ind,
     pd.unknown_patient_text, rpe.event_prsnl_id, pd.dispense_courier_id,
     pd.dispense_prov_id, pnl.username, pnl.name_full_formatted,
     pnl_ind =
     IF (pnl.person_id != null
      AND pnl.person_id > 0)
      IF (pnl.person_id=pd.dispense_courier_id) 1
      ELSEIF (pnl.person_id=pd.dispense_prov_id) 2
      ELSEIF (pnl.person_id=rpe.event_prsnl_id) 3
      ELSE 0
      ENDIF
     ELSE 0
     ENDIF
     FROM (dummyt d  WITH seq = value(tot_tag_cnt)),
      product_event rpe,
      patient_dispense pd,
      (dummyt d_pnl  WITH seq = 1),
      prsnl pnl
     PLAN (d
      WHERE (tag_request->taglist[d.seq].event_type_mean=crossmatched_cdf_meaning))
      JOIN (rpe
      WHERE (rpe.related_product_event_id=tag_request->taglist[d.seq].product_event_id)
       AND rpe.event_type_cd=issued_event_type_cd
       AND rpe.active_ind=1)
      JOIN (pd
      WHERE pd.product_event_id=rpe.product_event_id)
      JOIN (d_pnl
      WHERE d_pnl.seq=1)
      JOIN (pnl
      WHERE ((pnl.person_id=rpe.event_prsnl_id) OR (((pnl.person_id=pd.dispense_courier_id) OR (pnl
      .person_id=pd.dispense_prov_id)) ))
       AND pnl.person_id != null
       AND pnl.person_id > 0)
     ORDER BY d.seq
     HEAD d.seq
      IF (rpe.seq > 0)
       IF (pd.unknown_patient_ind=1)
        tag_request->taglist[d.seq].unknown_patient_ind = pd.unknown_patient_ind, tag_request->
        taglist[d.seq].unknown_patient_text = pd.unknown_patient_text
       ENDIF
       tag_request->taglist[d.seq].bb_id_nbr = pd.bb_id_nbr, tag_request->taglist[d.seq].
       dispense_dt_tm = cnvtdatetime(rpe.event_dt_tm)
       IF (((pd.dispense_courier_id=0) OR (pd.dispense_courier_id=null)) )
        tag_request->taglist[d.seq].dispense_courier = pd.dispense_courier_text
       ENDIF
      ENDIF
     DETAIL
      IF (pnl_ind=1)
       tag_request->taglist[d.seq].dispense_courier_id = pd.dispense_courier_id, tag_request->
       taglist[d.seq].dispense_courier = pnl.username
      ELSEIF (pnl_ind=2)
       tag_request->taglist[d.seq].dispense_prvdr_id = pd.dispense_prov_id, tag_request->taglist[d
       .seq].dispense_prvdr_name = pnl.name_full_formatted
      ELSEIF (pnl_ind=3)
       tag_request->taglist[d.seq].dispense_tech_id = rpe.event_prsnl_id, tag_request->taglist[d.seq]
       .dispense_tech_username = pnl.username
      ENDIF
     FOOT  d.seq
      row + 0
     WITH nocounter, outerjoin(d_pnl)
    ;end select
    SELECT INTO "nl:"
     pe.order_id, pe.bb_result_id, xm.crossmatch_exp_dt_tm,
     xm.bb_id_nbr, r.result_id, r.task_assay_cd,
     dta.bb_result_processing_cd, pr.result_value_alpha, re.event_dt_tm,
     re.event_personnel_id, pnl.username
     FROM (dummyt d  WITH seq = value(tot_tag_cnt)),
      product_event pe,
      crossmatch xm,
      result r,
      discrete_task_assay dta,
      perform_result pr,
      result_event re,
      prsnl pnl
     PLAN (d)
      JOIN (pe
      WHERE (pe.product_event_id=tag_request->taglist[d.seq].product_event_id)
       AND pe.product_event_id != null
       AND pe.product_event_id > 0
       AND pe.bb_result_id != null
       AND pe.bb_result_id > 0
       AND pe.order_id != null
       AND pe.order_id > 0)
      JOIN (xm
      WHERE xm.product_event_id=pe.product_event_id)
      JOIN (r
      WHERE r.bb_result_id=pe.bb_result_id
       AND r.order_id=pe.order_id
       AND r.result_id != null
       AND r.result_id > 0
       AND r.task_assay_cd != null
       AND r.task_assay_cd > 0)
      JOIN (dta
      WHERE dta.task_assay_cd=r.task_assay_cd
       AND dta.bb_result_processing_cd=xm_interp_cd)
      JOIN (pr
      WHERE pr.result_id=r.result_id
       AND ((pr.result_status_cd=verified_status_cd) OR (pr.result_status_cd=corrected_status_cd))
       AND pr.perform_result_id != null
       AND pr.perform_result_id > 0)
      JOIN (re
      WHERE re.result_id=r.result_id
       AND re.perform_result_id=pr.perform_result_id
       AND re.event_type_cd=pr.result_status_cd)
      JOIN (pnl
      WHERE pnl.person_id=re.event_personnel_id
       AND re.event_personnel_id != null
       AND re.event_personnel_id > 0)
     DETAIL
      tag_request->taglist[d.seq].xm_result_value_alpha = pr.result_value_alpha, tag_request->
      taglist[d.seq].xm_result_event_prsnl_username = pnl.username, tag_request->taglist[d.seq].
      xm_result_event_dt_tm = re.event_dt_tm,
      tag_request->taglist[d.seq].xm_expire_dt_tm = xm.crossmatch_exp_dt_tm
      IF (size(trim(tag_request->taglist[d.seq].bb_id_nbr),1)=0)
       tag_request->taglist[d.seq].bb_id_nbr = xm.bb_id_nbr
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ELSEIF (sub_tag_type != blank_sub_tag)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "print tags/lagels"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_tag_print_ctrl"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "invalid sub_tag_type"
  GO TO exit_script
 ENDIF
 IF (tag_type=crossmatch_tag)
  IF (textlen(trim(scrossmatchtagname))=0)
   EXECUTE bbt_tag_crossmatch
  ELSE
   EXECUTE value(cnvtupper(scrossmatchtagname))
  ENDIF
 ELSEIF (tag_type=component_tag)
  IF (textlen(trim(scomponenttagname))=0)
   EXECUTE bbt_tag_component
  ELSE
   EXECUTE value(cnvtupper(scomponenttagname))
  ENDIF
 ELSEIF (tag_type=emergency_tag)
  IF (textlen(trim(semergencytagname))=0)
   EXECUTE bbt_tag_emergency
  ELSE
   EXECUTE value(cnvtupper(semergencytagname))
  ENDIF
 ELSEIF (tag_type=pilot_lbl)
  EXECUTE bbt_tag_pilot_lbl
 ELSE
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "print tags/lagels"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_tag_print_ctrl"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "invalid tag_type"
  GO TO exit_script
 ENDIF
 SET reply->rpt_filename = rpt_filename
 GO TO exit_script
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
  SET gsub_code_value = 0.0
  SET stat = uar_get_meaning_by_codeset(sub_code_set,sub_cdf_meaning,1,gsub_code_value)
 END ;Subroutine
 DECLARE get_event_type_cds_ctrl(sub_var) = i2
 SUBROUTINE get_event_type_cds_ctrl(sub_success_ind)
   SET sub_success_ind = 0
   SET get_event_type_cds_status = " "
   SET get_event_type_cds_status = get_event_type_cds(" ")
   IF (get_event_type_cds_status="F")
    SET sub_success_ind = 0
    SET reply->status_data.status = "F"
    SET count1 += 1
    IF (count1 > 1)
     SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[count1].operationname = "get event_type code_values"
    SET reply->status_data.subeventstatus[count1].operationstatus = "F"
    SET reply->status_data.subeventstatus[count1].targetobjectname = "code_value"
    IF (assigned_event_type_cd=0)
     SET reply->status_data.subeventstatus[count1].targetobjectvalue =
     "could not get assigned event_type_cd"
    ELSEIF (crossmatched_event_type_cd=0)
     SET reply->status_data.subeventstatus[count1].targetobjectvalue =
     "could not get crossmatched event_type_cd"
    ELSEIF (issued_event_type_cd=0)
     SET reply->status_data.subeventstatus[count1].targetobjectvalue =
     "could not get issued event_type_cd"
    ELSEIF (autologous_event_type_cd=0)
     SET reply->status_data.subeventstatus[count1].targetobjectvalue =
     "could not get autologous event_type_cd"
    ELSEIF (directed_event_type_cd=0)
     SET reply->status_data.subeventstatus[count1].targetobjectvalue =
     "could not get directed event_type_cd"
    ELSEIF (in_progress_event_type_cd=0)
     SET reply->status_data.subeventstatus[count1].targetobjectvalue =
     "could not get in progress event_type_cd"
    ELSE
     SET reply->status_data.subeventstatus[count1].targetobjectvalue =
     "error retrieving event_type_cd's"
    ENDIF
   ELSE
    SET sub_success_ind = 1
   ENDIF
   RETURN(sub_success_ind)
 END ;Subroutine
 DECLARE get_event_type_cds(event_type_status) = c1
 SUBROUTINE get_event_type_cds(event_type_cd_dummy)
   SET event_type_status = "F"
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,assigned_cdf_meaning,1,
    assigned_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,quarantined_cdf_meaning,1,
    quarantined_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,crossmatched_cdf_meaning,1,
    crossmatched_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,issued_cdf_meaning,1,
    issued_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,disposed_cdf_meaning,1,
    disposed_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,transferred_cdf_meaning,1,
    transferred_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,transfused_cdf_meaning,1,
    transfused_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,modified_cdf_meaning,1,
    modified_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,unconfirmed_cdf_meaning,1,
    unconfirmed_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,autologous_cdf_meaning,1,
    autologous_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,directed_cdf_meaning,1,
    directed_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,available_cdf_meaning,1,
    available_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,received_cdf_meaning,1,
    received_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,destroyed_cdf_meaning,1,
    destroyed_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,shipped_cdf_meaning,1,
    shipped_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,in_progress_cdf_meaning,1,
    in_progress_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,pooled_cdf_meaning,1,
    pooled_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,pooled_product_cdf_meaning,1,
    pooled_product_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,confirmed_cdf_meaning,1,
    confirmed_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,drawn_cdf_meaning,1,
    drawn_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,tested_cdf_meaning,1,
    tested_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,intransit_cdf_meaning,1,
    in_transit_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,modified_product_cdf_meaning,1,
    modified_product_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,transferred_from_cdf_meaning,1,
    transferred_from_event_type_cd)
   SET event_type_status = "S"
   RETURN(event_type_status)
 END ;Subroutine
 SUBROUTINE findpersonaborhbarcode(null)
   DECLARE lstandard_aborh_cs = i4 WITH protect, constant(1640)
   DECLARE saboonly_cd = c32 WITH protect, constant("ABOOnly_cd")
   DECLARE srhonly_cd = c32 WITH protect, constant("RhOnly_cd")
   DECLARE sbarcode = c32 WITH protect, constant("Barcode")
   DECLARE nidx1 = i2 WITH protect, noconstant(0)
   DECLARE nidx2 = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tot_tag_cnt)),
     code_value_extension cve1,
     code_value_extension cve2,
     code_value_extension cve3,
     code_value cv
    PLAN (d)
     JOIN (cve1
     WHERE cve1.code_set=lstandard_aborh_cs
      AND cve1.field_name=saboonly_cd
      AND (cnvtreal(cve1.field_value)=tag_request->taglist[d.seq].person_abo_cd))
     JOIN (cve2
     WHERE cve2.code_set=lstandard_aborh_cs
      AND cve2.field_name=srhonly_cd
      AND (cnvtreal(cve2.field_value)=tag_request->taglist[d.seq].person_rh_cd)
      AND cve2.code_value=cve1.code_value)
     JOIN (cve3
     WHERE cve3.code_set=lstandard_aborh_cs
      AND cve3.field_name=sbarcode
      AND cve3.code_value=cve1.code_value)
     JOIN (cv
     WHERE cv.active_ind=1
      AND cv.code_value=cve3.code_value)
    HEAD REPORT
     num1 = 0
    DETAIL
     tag_request->taglist[d.seq].person_aborh_barcode = cve3.field_value
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[count1].operationname = "get person ABORh barcode"
    SET reply->status_data.subeventstatus[count1].operationstatus = "F"
    SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_tag_print_ctrl"
    SET reply->status_data.subeventstatus[count1].targetobjectvalue =
    "could not get person ABORh barcode."
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE populatealphatrans(null)
   DECLARE ntranscnt = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    bat.alpha_barcode_value, bat.alpha_translation_value
    FROM bb_alpha_translation bat
    PLAN (bat
     WHERE bat.alpha_translation_id > 0
      AND bat.active_ind=1)
    HEAD REPORT
     ntranscnt = 0, nstat = alterlist(alpha_translations->alpha_trans_list,(ntranscnt+ 10))
    DETAIL
     ntranscnt += 1
     IF (ntranscnt > size(alpha_translations->alpha_trans_list,5))
      nstat = alterlist(alpha_translations->alpha_trans_list,(ntranscnt+ 10))
     ENDIF
     alpha_translations->alpha_trans_list[ntranscnt].alpha_barcode = bat.alpha_barcode_value,
     alpha_translations->alpha_trans_list[ntranscnt].alpha_trans = cnvtupper(trim(bat
       .alpha_translation_value))
    FOOT REPORT
     nstat = alterlist(alpha_translations->alpha_trans_list,ntranscnt)
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[count1].operationname = "get alpha translation"
    SET reply->status_data.subeventstatus[count1].operationstatus = "F"
    SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_tag_print_ctrl"
    SET reply->status_data.subeventstatus[count1].targetobjectvalue =
    "could not get supplier alpha translation."
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE untranslateproductnbr(null)
   DECLARE nidx = i2 WITH protect, noconstant(0)
   DECLARE nfound = i2 WITH protect, noconstant(0)
   DECLARE i = i2 WITH protect, noconstant(0)
   DECLARE nalphacnt = i2 WITH protect, noconstant(0)
   DECLARE ntranslationsize = i2 WITH protect, noconstant(0)
   DECLARE nproductnbrsize = i2 WITH protect, noconstant(0)
   DECLARE stranslation = vc WITH protect, noconstant("")
   DECLARE salphabarcode = vc WITH protect, noconstant("")
   SET nalphacnt = size(alpha_translations->alpha_trans_list,5)
   FOR (nidx = 1 TO tot_tag_cnt)
     IF (textlen(trim(tag_request->taglist[nidx].product_barcode_nbr))=0)
      IF ((tag_request->taglist[nidx].pooled_product_ind=0))
       IF ((tag_request->taglist[nidx].alpha_translation_ind=1))
        SET i = 1
        WHILE (nfound=0
         AND i <= nalphacnt)
          SET stranslation = alpha_translations->alpha_trans_list[i].alpha_trans
          SET salphabarcode = alpha_translations->alpha_trans_list[i].alpha_barcode
          IF (findstring(stranslation,tag_request->taglist[nidx].product_nbr,1,0)=1)
           SET nfound = 1
           SET ntranslationsize = size(stranslation)
           SET nproductnbrsize = size(tag_request->taglist[nidx].product_nbr)
           SET tag_request->taglist[nidx].product_barcode_nbr = build(salphabarcode,substring((
             ntranslationsize+ 1),(nproductnbrsize - ntranslationsize),tag_request->taglist[nidx].
             product_nbr))
          ENDIF
          SET i += 1
        ENDWHILE
        IF (textlen(trim(tag_request->taglist[nidx].product_barcode_nbr))=0)
         SET tag_request->taglist[nidx].product_barcode_nbr = tag_request->taglist[nidx].product_nbr
        ENDIF
       ELSE
        SET tag_request->taglist[nidx].product_barcode_nbr = tag_request->taglist[nidx].product_nbr
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status != "F"))
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(tag_request)
 FREE RECORD alpha_translations
END GO
