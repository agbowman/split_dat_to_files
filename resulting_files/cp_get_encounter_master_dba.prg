CREATE PROGRAM cp_get_encounter_master:dba
 RECORD reply(
   1 encntr_type_cd = f8
   1 encntr_type_disp = c40
   1 encntr_type_mean = c12
   1 encntr_status_cd = f8
   1 encntr_status_disp = c40
   1 encntr_status_mean = c12
   1 reg_dt_tm = dq8
   1 isolation_cd = f8
   1 isolation_disp = c40
   1 isolation_mean = c12
   1 med_service_cd = f8
   1 med_service_disp = c40
   1 med_service_mean = c12
   1 location_cd = f8
   1 location_disp = c40
   1 location_mean = c12
   1 loc_facility_cd = f8
   1 loc_facility_disp = c40
   1 loc_facility_desc = c60
   1 loc_facility_mean = c12
   1 loc_building_cd = f8
   1 loc_building_disp = c40
   1 loc_building_desc = vc
   1 loc_building_mean = c12
   1 loc_nurse_unit_cd = f8
   1 loc_nurse_unit_disp = c40
   1 loc_nurse_unit_desc = vc
   1 loc_nurse_unit_mean = c12
   1 loc_room_cd = f8
   1 loc_room_disp = c40
   1 loc_room_mean = c12
   1 loc_bed_cd = f8
   1 loc_bed_disp = c40
   1 loc_bed_mean = c12
   1 disch_dt_tm = dq8
   1 organization_id = f8
   1 reason_for_visit = vc
   1 person_id = f8
   1 financial_class_cd = f8
   1 financial_class_disp = c40
   1 financial_class_mean = c12
   1 encntr_alias[*]
     2 encntr_alias_id = f8
     2 alias_pool_cd = f8
     2 alias_pool_disp = c40
     2 alias_pool_mean = c12
     2 encntr_alias_type_cd = f8
     2 encntr_alias_type_disp = c40
     2 encntr_alias_type_mean = c12
     2 alias = c200
   1 encntr_info[*]
     2 encntr_info_id = f8
     2 info_type_cd = f8
     2 info_type_disp = c40
     2 info_type_mean = c12
     2 long_text_id = f8
     2 long_text = vc
     2 value_numeric = i4
     2 chartable_ind = i2
   1 encntr_domain[*]
     2 encntr_domain_id = f8
     2 person_id = f8
     2 encntr_domain_type_cd = f8
     2 encntr_domain_type_disp = c40
     2 encntr_domain_type_mean = c12
     2 loc_facility_cd = f8
     2 loc_facility_disp = c40
     2 loc_facility_mean = c12
     2 loc_building_cd = f8
     2 loc_building_disp = c40
     2 loc_building_mean = c12
     2 loc_nurse_unit_cd = f8
     2 loc_nurse_unit_disp = c40
     2 loc_nurse_unit_mean = c12
     2 loc_room_cd = f8
     2 loc_room_disp = c40
     2 loc_room_mean = c12
     2 loc_bed_cd = f8
     2 loc_bed_disp = c40
     2 loc_bed_mean = c12
     2 med_service_cd = f8
     2 med_service_disp = c40
     2 med_service_mean = c12
   1 encntr_loc_hist[*]
     2 encntr_loc_hist_id = f8
     2 location_cd = f8
     2 location_disp = c40
     2 location_mean = c12
     2 location_status_cd = f8
     2 location_status_disp = c40
     2 location_status_mean = c12
     2 arrive_dt_tm = dq8
     2 arrive_prsnl_id = f8
     2 depart_dt_tm = dq8
     2 depart_prsnl_id = f8
     2 transfer_reason_cd = f8
     2 transfer_reason_disp = c40
     2 transfer_reason_mean = c12
     2 location_temp_ind = i2
     2 chart_comment_ind = i2
     2 comment_text = c200
     2 loc_facility_cd = f8
     2 loc_facility_disp = c40
     2 loc_facility_mean = c12
     2 loc_building_cd = f8
     2 loc_building_disp = c40
     2 loc_building_mean = c12
     2 loc_nurse_unit_cd = f8
     2 loc_nurse_unit_disp = c40
     2 loc_nurse_unit_mean = c12
     2 loc_room_cd = f8
     2 loc_room_disp = c40
     2 loc_room_mean = c12
     2 loc_bed_cd = f8
     2 loc_bed_disp = c40
     2 loc_bed_mean = c12
   1 encntr_prsnl_reltn[*]
     2 encntr_prsnl_reltn_id = f8
     2 prsnl_person_id = f8
     2 encntr_prsnl_r_cd = f8
     2 encntr_prsnl_r_disp = c40
     2 encntr_prsnl_r_mean = c12
     2 beg_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 SET log_program_name = "CP_GET_ENCOUNTER_MASTER"
 DECLARE retrieveencounter(null) = null WITH protect
 DECLARE retrieveencounteralias(null) = null WITH protect
 DECLARE retrieveencountercomment(null) = null WITH protect
 DECLARE retrieveencounterdomain(null) = null WITH protect
 DECLARE retrieveencounterlocationhistory(null) = null WITH protect
 DECLARE retrieveencounterpersonnelrelation(null) = null WITH protect
 DECLARE count = i4 WITH protect
 DECLARE info_type_cd = f8 WITH noconstant(0.0), protect
 SET stat = uar_get_meaning_by_codeset(355,"COMMENT",1,info_type_cd)
 SET reply->status_data.status = "F"
 CALL log_message("Starting script: cp_get_encounter_master",log_level_debug)
 IF ((request->encntr_id=0))
  CALL populate_subeventstatus("DataValidation","Z","request->encntr_id","0")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 CALL retrieveencounter(null)
 CALL retrieveencounteralias(null)
 CALL retrieveencountercomment(null)
 CALL retrieveencounterdomain(null)
 CALL retrieveencounterlocationhistory(null)
 CALL retrieveencounterpersonnelrelation(null)
 SUBROUTINE retrieveencounter(null)
   CALL log_message("Select 1 -  Retrieve encounter row ",log_level_debug)
   SELECT INTO "nl"
    e.encntr_type_cd, e.encntr_status_cd, e.reg_dt_tm,
    e.isolation_cd, e.med_service_cd, e.location_cd,
    e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd,
    e.loc_room_cd, e.loc_bed_cd, e.disch_dt_tm,
    e.organization_id, e.reason_for_visit, e.person_id,
    e.financial_class_cd
    FROM encounter e
    WHERE (e.encntr_id=request->encntr_id)
     AND e.active_ind=1
     AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND e.end_effective_dt_tm >= cnvtdatetime(sysdate)
    DETAIL
     reply->encntr_type_cd = e.encntr_type_cd, reply->encntr_status_cd = e.encntr_status_cd, reply->
     reg_dt_tm = e.reg_dt_tm,
     reply->isolation_cd = e.isolation_cd, reply->med_service_cd = e.med_service_cd, reply->
     location_cd = e.location_cd,
     reply->loc_facility_cd = e.loc_facility_cd, reply->loc_building_cd = e.loc_building_cd, reply->
     loc_nurse_unit_cd = e.loc_nurse_unit_cd,
     reply->loc_room_cd = e.loc_room_cd, reply->loc_bed_cd = e.loc_bed_cd, reply->disch_dt_tm = e
     .disch_dt_tm,
     reply->organization_id = e.organization_id, reply->reason_for_visit = e.reason_for_visit, reply
     ->person_id = e.person_id,
     reply->financial_class_cd = e.financial_class_cd
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"ENCOUNTER","TABLE",1,1)
   SET reply->status_data.status = "S"
 END ;Subroutine
 SUBROUTINE retrieveencounteralias(null)
   CALL log_message("Select 2 - Retrieve encounter alias rows",log_level_debug)
   SET count = 0
   SELECT INTO "nl:"
    e.encntr_alias_id, e.alias_pool_cd, e.encntr_alias_type_cd,
    e.alias
    FROM encntr_alias e
    WHERE (e.encntr_id=request->encntr_id)
     AND e.active_ind=1
     AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND e.end_effective_dt_tm >= cnvtdatetime(sysdate)
    DETAIL
     count += 1, stat = alterlist(reply->encntr_alias,count), reply->encntr_alias[count].
     encntr_alias_id = e.encntr_alias_id,
     reply->encntr_alias[count].alias_pool_cd = e.alias_pool_cd, reply->encntr_alias[count].
     encntr_alias_type_cd = e.encntr_alias_type_cd, reply->encntr_alias[count].alias = cnvtalias(e
      .alias,e.alias_pool_cd)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"ENCNTR_ALIAS","TABLE",1,0)
 END ;Subroutine
 SUBROUTINE retrieveencountercomment(null)
   CALL log_message(
    "Select 3 - Retrieve encounter info(now just retrieve ENCOUNTER COMMENT info) rows",
    log_level_debug)
   SELECT INTO "nl:"
    e.encntr_info_id, e.info_type_cd, info_type_mean = uar_get_code_meaning(e.info_type_cd),
    e.long_text_id, e.value_numeric, e.chartable_ind
    FROM encntr_info e
    WHERE (e.encntr_id=request->encntr_id)
     AND e.info_type_cd=info_type_cd
     AND e.chartable_ind=1
     AND e.active_ind=1
     AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND e.end_effective_dt_tm >= cnvtdatetime(sysdate)
    DETAIL
     count += 1, stat = alterlist(reply->encntr_info,count), reply->encntr_info[count].encntr_info_id
      = e.encntr_info_id,
     reply->encntr_info[count].info_type_cd = e.info_type_cd, reply->encntr_info[count].long_text_id
      = e.long_text_id, reply->encntr_info[count].value_numeric = e.value_numeric,
     reply->encntr_info[count].chartable_ind = e.chartable_ind
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"ENCNTR_INFO","TABLE",1,0)
   SET count = 0
   SET total = size(reply->encntr_info,5)
   IF (total > 0)
    CALL log_message("Select 4 - Retrieve long_text rows ",log_level_debug)
    SELECT INTO "nl:"
     l.long_text
     FROM long_text l,
      (dummyt d  WITH seq = value(total))
     PLAN (d)
      JOIN (l
      WHERE (l.long_text_id=reply->encntr_info[d.seq].long_text_id)
       AND (reply->encntr_info[d.seq].long_text_id > 0))
     DETAIL
      reply->encntr_info[d.seq].long_text = l.long_text
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"LONG_TEXT","TABLE",1,0)
   ENDIF
 END ;Subroutine
 SUBROUTINE retrieveencounterdomain(null)
   CALL log_message("Select 5 - Retrieve encounter domain rows ",log_level_debug)
   SET count = 0
   SELECT INTO "nl:"
    e.encntr_domain_id, e.person_id, e.encntr_domain_type_cd,
    e.loc_facility_cd, e.loc_building_cd, e.loc_nurse_unit_cd,
    e.loc_room_cd, e.loc_bed_cd, e.med_service_cd
    FROM encntr_domain e
    WHERE (e.encntr_id=request->encntr_id)
     AND e.active_ind=1
     AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND e.end_effective_dt_tm >= cnvtdatetime(sysdate)
    DETAIL
     count += 1, stat = alterlist(reply->encntr_domain,count), reply->encntr_domain[count].
     encntr_domain_id = e.encntr_domain_id,
     reply->encntr_domain[count].person_id = e.person_id, reply->encntr_domain[count].
     encntr_domain_type_cd = e.encntr_domain_type_cd, reply->encntr_domain[count].loc_facility_cd = e
     .loc_facility_cd,
     reply->encntr_domain[count].loc_building_cd = e.loc_building_cd, reply->encntr_domain[count].
     loc_nurse_unit_cd = e.loc_nurse_unit_cd, reply->encntr_domain[count].loc_room_cd = e.loc_room_cd,
     reply->encntr_domain[count].loc_bed_cd = e.loc_bed_cd, reply->encntr_domain[count].
     med_service_cd = e.med_service_cd
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"ENCNTR_DOMAIN","TABLE",1,0)
 END ;Subroutine
 SUBROUTINE retrieveencounterlocationhistory(null)
   CALL log_message("Select 6 - Retrieve encounter location history rows",log_level_debug)
   SET count = 0
   SELECT INTO "nl:"
    e.encntr_loc_hist_id, e.location_cd, e.location_status_cd,
    e.arrive_dt_tm, e.arrive_prsnl_id, e.depart_dt_tm,
    e.depart_prsnl_id, e.transfer_reason_cd, e.location_temp_ind,
    e.chart_comment_ind, e.comment_text, e.loc_facility_cd,
    e.loc_building_cd, e.loc_nurse_unit_cd, e.loc_room_cd,
    e.loc_bed_cd
    FROM encntr_loc_hist e
    WHERE (e.encntr_id=request->encntr_id)
     AND e.active_ind=1
     AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND e.end_effective_dt_tm >= cnvtdatetime(sysdate)
    DETAIL
     count += 1, stat = alterlist(reply->encntr_loc_hist,count), reply->encntr_loc_hist[count].
     encntr_loc_hist_id = e.encntr_loc_hist_id,
     reply->encntr_loc_hist[count].location_cd = e.location_cd, reply->encntr_loc_hist[count].
     location_status_cd = e.location_status_cd, reply->encntr_loc_hist[count].arrive_dt_tm = e
     .arrive_dt_tm,
     reply->encntr_loc_hist[count].arrive_prsnl_id = e.arrive_prsnl_id, reply->encntr_loc_hist[count]
     .depart_dt_tm = e.depart_dt_tm, reply->encntr_loc_hist[count].depart_prsnl_id = e
     .depart_prsnl_id,
     reply->encntr_loc_hist[count].transfer_reason_cd = e.transfer_reason_cd, reply->encntr_loc_hist[
     count].location_temp_ind = e.location_temp_ind, reply->encntr_loc_hist[count].chart_comment_ind
      = e.chart_comment_ind,
     reply->encntr_loc_hist[count].comment_text = e.comment_text, reply->encntr_loc_hist[count].
     loc_facility_cd = e.loc_facility_cd, reply->encntr_loc_hist[count].loc_building_cd = e
     .loc_building_cd,
     reply->encntr_loc_hist[count].loc_nurse_unit_cd = e.loc_nurse_unit_cd, reply->encntr_loc_hist[
     count].loc_room_cd = e.loc_room_cd, reply->encntr_loc_hist[count].loc_bed_cd = e.loc_bed_cd
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"ENCNTR_LOC_HIST","TABLE",1,0)
 END ;Subroutine
 SUBROUTINE retrieveencounterpersonnelrelation(null)
   CALL log_message("Select 7 - Retrieve encounter personnel relation rows",log_level_debug)
   SET count = 0
   SELECT INTO "nl:"
    e.encntr_prsnl_reltn_id, e.prsnl_person_id, e.encntr_prsnl_r_cd,
    encntr_prsnl_r_mean = uar_get_code_meaning(e.encntr_prsnl_r_cd)
    FROM encntr_prsnl_reltn e
    WHERE (e.encntr_id=request->encntr_id)
     AND e.active_ind=1
     AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND e.end_effective_dt_tm >= cnvtdatetime(sysdate)
    DETAIL
     count += 1, stat = alterlist(reply->encntr_prsnl_reltn,count), reply->encntr_prsnl_reltn[count].
     encntr_prsnl_reltn_id = e.encntr_prsnl_reltn_id,
     reply->encntr_prsnl_reltn[count].prsnl_person_id = e.prsnl_person_id, reply->encntr_prsnl_reltn[
     count].encntr_prsnl_r_cd = e.encntr_prsnl_r_cd, reply->encntr_prsnl_reltn[count].
     beg_effective_dt_tm = e.beg_effective_dt_tm
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"ENCNTR_PRSNL_RELTN","TABLE",1,0)
 END ;Subroutine
#exit_script
 CALL log_message("End of script: cp_get_encounter_master",log_level_debug)
END GO
