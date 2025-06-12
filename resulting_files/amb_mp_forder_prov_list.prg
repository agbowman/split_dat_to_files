CREATE PROGRAM amb_mp_forder_prov_list
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Personnel Id:" = "0.0",
  "Personname_ind" = 0,
  "Person Id:" = "0.0"
  WITH outdev, prov_id, person_ind,
  person_id
 FREE RECORD record_data
 RECORD record_data(
   1 person_name = vc
   1 person_name_full = vc
   1 build_provlist[*]
     2 order_provider_id = vc
     2 order_provider_name = vc
     2 selected_ind = i2
     2 selected = i2
   1 location_cds[*]
     2 location_cd = f8
   1 ftorderprov_pref_found_rs = vc
   1 forderloc_pref_found_rs = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD temp_rec_lcds
 RECORD temp_rec_lcds(
   1 cnt = i4
   1 qual[*]
     2 value = f8
 )
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
 DECLARE crsl_msg_default = i4 WITH protect, noconstant(0)
 DECLARE crsl_msg_level = i4 WITH protect, noconstant(0)
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
 DECLARE crsl_info_domain = vc WITH protect, constant("DISCERNABU SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 IF (((logical("MP_LOGGING_ALL") > " ") OR (logical(concat("MP_LOGGING_",log_program_name)) > " ")) )
  SET log_override_ind = 1
 ENDIF
 DECLARE log_message(logmsg=vc,loglvl=i4) = null
 SUBROUTINE log_message(logmsg,loglvl)
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
 DECLARE error_message(logstatusblockind=i2) = i2
 SUBROUTINE error_message(logstatusblockind)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     IF (validate(reply))
      SET reply->status_data.status = "F"
     ENDIF
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      IF (validate(reply))
       CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
      ENDIF
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 DECLARE error_and_zero_check_rec(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2,
  recorddata=vc(ref)) = i2
 SUBROUTINE error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,recorddata)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus_rec(opname,"F",serrmsg,logmsg,recorddata)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET recorddata->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET recorddata->status_data.status = "Z"
    CALL populate_subeventstatus_rec(opname,"Z","No records qualified",logmsg,recorddata)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 DECLARE error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2) = i2
 SUBROUTINE error_and_zero_check(qualnum,opname,logmsg,errorforceexit,zeroforceexit)
   RETURN(error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,
    reply))
 END ;Subroutine
 DECLARE populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) = i2
 SUBROUTINE populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,
  targetobjectvalue,recorddata)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(recorddata->status_data.subeventstatus[
      lcrslsubeventcnt].operationstatus)))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(recorddata->status_data.subeventstatus[
      lcrslsubeventcnt].targetobjectname)))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(recorddata->status_data.subeventstatus[
      lcrslsubeventcnt].targetobjectvalue)))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt = (lcrslsubeventcnt+ 1)
     SET icrslloggingstat = alter(recorddata->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue =
    targetobjectvalue
   ENDIF
 END ;Subroutine
 DECLARE populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),targetobjectname=
  vc(value),targetobjectvalue=vc(value)) = i2
 SUBROUTINE populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
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
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET log_program_name = "AMB_MP_FORDER_PROV_LIST"
 DECLARE gatherorderingprovider(null) = vc WITH protect
 DECLARE gatheruserlocationprefs(prsnl_id=f8,pref_id=vc) = null WITH protect, copy
 DECLARE gatherpersoname(null) = vc WITH protect
 DECLARE gatheruserprefs(prsnl_id=f8,pref_id=vc) = null WITH protect, copy
 DECLARE current_date_time_ftorder_prov = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), protect
 DECLARE pcnt = i2 WITH noconstant(0)
 DECLARE forderloc_pref_found_rs = vc
 DECLARE user_loc_pref_string = vc
 DECLARE person_name_string = vc
 DECLARE person_name_string_full = vc
 DECLARE user_prov_pref_string = vc
 DECLARE ftorderprov_pref_found = vc
 DECLARE logging = i4 WITH protect, noconstant(0)
 CALL log_message(concat("Begin script: ",log_program_name),log_level_debug)
 SET record_data->status_data.status = "F"
 IF (( $PERSON_IND != 1))
  CALL gatheruserlocationprefs( $PROV_ID,"AMB_FTORDER_LOCATION_FAV")
  IF (forderloc_pref_found_rs="1")
   SET record_data->forderloc_pref_found_rs = "1"
  ENDIF
  DECLARE start_commal = i4 WITH protect, noconstant(1)
  DECLARE end_commal = i4 WITH protect, noconstant(findstring("|",user_loc_pref_string,start_commal))
  DECLARE ftorderloc_pref = vc
  WHILE (start_commal > 0)
    IF ( NOT (end_commal))
     SET ftorderloc_pref = substring((start_commal+ 1),(textlen(user_loc_pref_string) - start_commal),
      user_loc_pref_string)
    ELSE
     SET ftorderloc_pref = substring((start_commal+ 1),((end_commal - start_commal) - 1),
      user_loc_pref_string)
    ENDIF
    CALL echo(start_commal)
    SET start_commal = end_commal
    IF (start_commal)
     SET end_commal = findstring("|",user_loc_pref_string,(start_commal+ 1))
    ENDIF
  ENDWHILE
  DECLARE loc_parser = vc WITH public, noconstant("0")
  IF (ftorderloc_pref != "")
   SET loc_parser = build2("l.location_cd IN (",ftorderloc_pref,")")
   CALL gatherorderingprovider(null)
  ENDIF
  CALL gatheruserprefs( $PROV_ID,"AMB_FTORDER_PROV_FAV")
  DECLARE start_comma = i4 WITH protect, noconstant(1)
  DECLARE pos = i4
  DECLARE avisitprovcnt = i4 WITH protect, noconstant(1)
  DECLARE end_comma = i4 WITH protect, noconstant(findstring("|",user_prov_pref_string,start_comma))
  DECLARE ftorderprov_pref = vc
  IF (ftorderprov_pref_found="1")
   SET record_data->ftorderprov_pref_found_rs = "1"
  ENDIF
  WHILE (start_comma > 0)
    IF ( NOT (end_comma))
     SET ftorderprov_pref = substring((start_comma+ 1),(textlen(user_prov_pref_string) - start_comma),
      user_prov_pref_string)
    ELSE
     SET ftorderprov_pref = substring((start_comma+ 1),((end_comma - start_comma) - 1),
      user_prov_pref_string)
    ENDIF
    FOR (fseq = 1 TO size(record_data->build_provlist,5))
     SET pos = findstring(record_data->build_provlist[fseq].order_provider_id,ftorderprov_pref,
      start_comma)
     IF (pos != 0)
      SET record_data->build_provlist[fseq].selected = 1
     ELSE
      SET record_data->build_provlist[fseq].selected = 0
      SET avisitprovcnt = (avisitprovcnt+ 1)
     ENDIF
    ENDFOR
    SET start_comma = end_comma
    IF (start_comma)
     SET end_comma = findstring("|",user_prov_pref_string,(start_comma+ 1))
    ENDIF
  ENDWHILE
 ELSE
  CALL gatherpersoname(null)
  SET record_data->person_name = person_name_string
  SET record_data->person_name_full = person_name_string_full
 ENDIF
 SET record_data->status_data.status = "S"
 CALL echorecord(record_data)
 SET modify maxvarlen 20000000
 SET _memory_reply_string = cnvtrectojson(record_data)
 SUBROUTINE gatherorderingprovider(dummy)
   CALL log_message("In gatherOrderingProvider()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE dba_check = f8
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=88
     AND cdf_meaning="DBA"
    DETAIL
     dba_check = cv.code_value
    WITH nocounter
   ;end select
   DECLARE num2 = i2
   SELECT DISTINCT
    p.person_id, por.organization_id, p.name_full_formatted
    FROM location l,
     prsnl_org_reltn por,
     prsnl p
    PLAN (l
     WHERE parser(loc_parser))
     JOIN (por
     WHERE por.organization_id=l.organization_id
      AND por.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND por.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND por.active_ind=1)
     JOIN (p
     WHERE p.person_id=por.person_id
      AND  NOT (p.position_cd=dba_check)
      AND p.username > " "
      AND p.active_ind=1
      AND p.physician_ind=1
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    ORDER BY p.name_full_formatted, p.person_id
    HEAD REPORT
     pcnt = 0
    HEAD p.person_id
     pcnt = (pcnt+ 1)
     IF (mod(pcnt,100)=1)
      stat = alterlist(record_data->build_provlist,(pcnt+ 99))
     ENDIF
     record_data->build_provlist[pcnt].order_provider_name = trim(replace(p.name_full_formatted,
       concat(char(13),char(10)),"; ",0)), record_data->build_provlist[pcnt].order_provider_id =
     cnvtstring(p.person_id), record_data->build_provlist[pcnt].selected = 0
    FOOT REPORT
     stat = alterlist(record_data->build_provlist,pcnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check_rec(curqual,"AMB_MP_FORDER_PROV_LIST","gatherOrderingProvider",1,0,
    record_data)
   CALL log_message(build("Exit gatherOrderingProvider(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE gatheruserprefs(prsnl_id,pref_id)
   CALL log_message("In GatherUserPrefs()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   SET user_prov_pref_string = ""
   SET ftorderprov_pref_found = ""
   SELECT INTO "nl:"
    FROM app_prefs a,
     name_value_prefs n
    PLAN (a
     WHERE (a.prsnl_id= $PROV_ID))
     JOIN (n
     WHERE n.parent_entity_id=a.app_prefs_id
      AND n.parent_entity_name="APP_PREFS"
      AND n.pvc_name=pref_id)
    ORDER BY n.sequence
    HEAD n.pvc_name
     fav_cnt = 0
    DETAIL
     user_prov_pref_string = concat(user_prov_pref_string,trim(n.pvc_value)), ftorderprov_pref_found
      = "1"
    WITH nocounter
   ;end select
   CALL error_and_zero_check_rec(curqual,"AMB_MP_FORDER_PROV_LIST","GatherUserPrefs",1,0,
    record_data)
   CALL log_message(build("Exit GatherUserPrefs(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE gatheruserlocationprefs(prsnl_id,pref_id)
   CALL log_message("In GatherUserLocationPrefs()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   SET user_loc_pref_string = ""
   SET forderloc_pref_found_rs = ""
   SELECT INTO "nl:"
    FROM app_prefs a,
     name_value_prefs n
    PLAN (a
     WHERE (a.prsnl_id= $PROV_ID))
     JOIN (n
     WHERE n.parent_entity_id=a.app_prefs_id
      AND n.parent_entity_name="APP_PREFS"
      AND n.pvc_name=pref_id)
    ORDER BY n.sequence
    HEAD n.pvc_name
     fav_cnt = 0
    DETAIL
     user_loc_pref_string = concat(user_loc_pref_string,trim(n.pvc_value)), forderloc_pref_found_rs
      = "1"
    WITH nocounter
   ;end select
   CALL error_and_zero_check_rec(curqual,"AMB_MP_FORDER_PROV_LIST","GatherUserLocationPrefs",1,0,
    record_data)
   CALL log_message(build("Exit GatherUserLocationPrefs(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE gatherpersoname(null)
   CALL log_message("In GatherPersoName()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   SET person_name_string = ""
   SET person_name_string_full = ""
   SELECT
    p.name_last, p.name_first
    FROM person p
    WHERE (p.person_id= $PERSON_ID)
    DETAIL
     person_name_string_full = trim(replace(p.name_full_formatted,concat(char(13),char(10)),"; ",0)),
     person_name_string = trim(substring(1,50,replace(p.name_full_formatted,concat(char(13),char(10)),
        "; ",0)))
    WITH nocounter
   ;end select
   CALL error_and_zero_check_rec(curqual,"AMB_MP_FORDER_PROV_LIST","GatherPersoName",1,0,
    record_data)
   CALL log_message(build("Exit GatherPersoName(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
#exit_script
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",datetimediff(cnvtdatetime(curdate,curtime3),
    current_date_time_ftorder_prov,5)),log_level_debug)
 FREE RECORD record_data
END GO
