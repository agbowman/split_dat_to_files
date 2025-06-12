CREATE PROGRAM bbt_get_avail_flex_specs:dba
 RECORD reply(
   1 historical_demog_ind = i2
   1 personlist[*]
     2 alert_flag = c1
     2 person_id = f8
     2 new_sample_dt_tm = dq8
     2 name_full_formatted = c40
     2 specimen[*]
       3 specimen_id = f8
       3 encntr_id = f8
       3 override_id = f8
       3 override_cd = f8
       3 override_disp = vc
       3 override_mean = c12
       3 drawn_dt_tm = dq8
       3 unformatted_accession = c20
       3 accession = c20
       3 expire_dt_tm = dq8
       3 flex_on_ind = i2
       3 flex_max = i4
       3 flex_days_hrs_mean = c12
       3 historical_name = c40
       3 encntr_facility_cd = f8
       3 testing_facility_cd = f8
       3 orders[*]
         4 order_id = f8
         4 order_mnemonic = vc
         4 status = c40
         4 products[*]
           5 product_nbr_display = vc
           5 product_id = f8
           5 product_event_id = f8
           5 product_type_cd = f8
           5 product_type_disp = vc
           5 locked_ind = i2
           5 crossmatch_expire_dt_tm = dq8
           5 updt_applctx = f8
         4 order_status_cd = f8
         4 order_status_disp = vc
         4 order_status_mean = c12
         4 catalog_cd = f8
         4 catalog_disp = vc
         4 catalog_mean = c12
         4 phase_group_cd = f8
         4 phase_group_disp = vc
         4 phase_group_mean = c12
         4 encntr_id = f8
       3 max_expire_dt_tm = dq8
       3 max_expire_flag = i2
       3 is_expired_flag = i2
       3 assoc_neo_disch_encntr = i2
     2 active_specimen_exists = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 FREE SET temp
 RECORD temp(
   1 personlist[*]
     2 person_id = f8
     2 name_full_formatted = c40
     2 birth_dt_tm = dq8
     2 orders[*]
       3 order_id = f8
       3 encntr_id = f8
       3 encntr_fac_cd = f8
       3 encntr_discharged = i2
       3 order_mnemonic = vc
       3 status = c40
       3 order_status_cd = f8
       3 catalog_cd = f8
       3 phase_group_cd = f8
       3 accession = c20
       3 productevents[*]
         4 product_event_id = f8
         4 product
           5 product_id = f8
           5 product_number_disp = vc
           5 product_type_cd = f8
           5 locked_ind = i2
           5 crossmatch_expire_dt_tm = dq8
           5 updt_applctx = f8
       3 containers[*]
         4 container_id = f8
         4 specimen_id = f8
         4 new_spec_expire_dt_tm = f8
         4 override_id = f8
         4 override_cd = f8
         4 drawn_dt_tm = dq8
 )
 SET modify = predeclare
 DECLARE script_name = c24 WITH constant("bbt_get_avail_flex_specs")
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE uar_error = vc WITH protect, noconstant("")
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE temp_person_count = i4 WITH protect, noconstant(0)
 DECLARE temp_order_count = i4 WITH protect, noconstant(0)
 DECLARE temp_prod_event_count = i4 WITH protect, noconstant(0)
 DECLARE temp_container_count = i4 WITH protect, noconstant(0)
 DECLARE person_count = i4 WITH protect, noconstant(0)
 DECLARE specimen_count = i4 WITH protect, noconstant(0)
 DECLARE orders_count = i4 WITH protect, noconstant(0)
 DECLARE products_count = i4 WITH protect, noconstant(0)
 DECLARE facility_count = i4 WITH protect, noconstant(0)
 DECLARE i_idx = i4 WITH protect, noconstant(0)
 DECLARE j_idx = i4 WITH protect, noconstant(0)
 DECLARE k_idx = i4 WITH protect, noconstant(0)
 DECLARE l_idx = i4 WITH protect, noconstant(0)
 DECLARE x_idx = i4 WITH protect, noconstant(0)
 DECLARE y_idx = i4 WITH protect, noconstant(0)
 DECLARE actualsize = i4 WITH protect, noconstant(0)
 DECLARE expandsize = i4 WITH protect, noconstant(0)
 DECLARE expandtotal = i4 WITH protect, noconstant(0)
 DECLARE expandstart = i4 WITH protect, noconstant(1)
 DECLARE lidx1 = i4 WITH protect, noconstant(0)
 DECLARE lidx2 = i4 WITH protect, noconstant(0)
 DECLARE dcurrent_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE lidx3 = i4 WITH protect, noconstant(0)
 DECLARE dminute = f8 WITH protect, constant((1/ 1440.0))
 DECLARE personindexhold = i4 WITH protect, noconstant(0)
 DECLARE specindexhold = i4 WITH protect, noconstant(0)
 DECLARE ordindexhold = i4 WITH protect, noconstant(0)
 DECLARE temppersonidxhold = i4 WITH protect, noconstant(0)
 DECLARE facilityidxhold = i4 WITH protect, noconstant(0)
 DECLARE current_dt_tm_hold = q8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE expdttm = q8 WITH protect, noconstant(0.0)
 DECLARE maxexpdttmhold = q8 WITH protect, noconstant(0.0)
 DECLARE flexmaxhold = i4 WITH protect, noconstant(0)
 DECLARE flexdayshrsmeanhold = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE flextestingfaccdhold = f8 WITH protect, noconstant(0.0)
 DECLARE encntrfacilitycdhold = f8 WITH protect, noconstant(0.0)
 DECLARE maxexpdttm = q8 WITH protect, noconstant(0.0)
 DECLARE maxorderdrawndttm = q8 WITH protect, noconstant(0.0)
 DECLARE sup_grp_ord_type = i2 WITH protect, constant(2)
 DECLARE ord_set_ord_type = i2 WITH protect, constant(6)
 DECLARE sys_anti_ovrd_cdf_meaning = c12 WITH protect, constant("SYS_ANTI")
 DECLARE neonate_ovrd_cdf_meaning = c12 WITH protect, constant("NEONATE")
 DECLARE override_meaning = c12 WITH protect, noconstant
 DECLARE old_expire_mean = c1 WITH protect, noconstant(fillstring(1," "))
 DECLARE old_expire_time = f8 WITH protect, noconstant(0.0)
 DECLARE old_time_cd = f8 WITH protect, noconstant(0.0)
 DECLARE activity_type_cs = i4 WITH protect, constant(106)
 DECLARE bb_activity_type_mean = c12 WITH protect, constant("BB")
 DECLARE bb_activity_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE questions_cs = i4 WITH protect, constant(1661)
 DECLARE xm_exp_calc_ques_mean = c12 WITH protect, constant("XM EXP CALC")
 DECLARE xm_exp_calc_ques_cd = f8 WITH protect, noconstant(0.0)
 DECLARE xm_warn_dys_ques_mean = c12 WITH protect, constant("XM WARN DYS")
 DECLARE xm_warn_dys_ques_cd = f8 WITH protect, noconstant(0.0)
 DECLARE xm_warn_hrs_ques_mean = c12 WITH protect, constant("XM WARN HRS")
 DECLARE xm_warn_hrs_ques_cd = f8 WITH protect, noconstant(0.0)
 DECLARE valid_responses_cs = i4 WITH protect, constant(1659)
 DECLARE hours_valid_resp_mean = c12 WITH protect, constant("H")
 DECLARE hours_valid_resp_cd = f8 WITH protect, noconstant(0.0)
 DECLARE days_valid_resp_mean = c12 WITH protect, constant("D")
 DECLARE days_valid_resp_cd = f8 WITH protect, noconstant(0.0)
 DECLARE catalog_type_cs = i4 WITH protect, constant(6000)
 DECLARE gen_lab_cat_type_mean = c12 WITH protect, constant("GENERAL LAB")
 DECLARE gen_lab_cat_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE order_status_cs = i4 WITH protect, constant(6004)
 DECLARE ordered_status_mean = c12 WITH protect, constant("ORDERED")
 DECLARE ordered_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE inprocess_status_mean = c12 WITH protect, constant("INPROCESS")
 DECLARE inprocess_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE completed_status_mean = c12 WITH protect, constant("COMPLETED")
 DECLARE completed_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE future_status_mean = c12 WITH protect, constant("FUTURE")
 DECLARE future_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE unscheduled_status_mean = c12 WITH protect, constant("UNSCHEDULED")
 DECLARE unscheduled_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pending_rev_status_mean = c12 WITH protect, constant("PENDING REV")
 DECLARE pending_rev_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE suspended_status_mean = c12 WITH protect, constant("SUSPENDED")
 DECLARE suspended_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dept_order_status_cs = i4 WITH protect, constant(14281)
 DECLARE inlab_dept_status_mean = c12 WITH protect, constant("LABINLAB")
 DECLARE inlab_dept_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE collected_dept_status_mean = c12 WITH protect, constant("LABCOLLECTED")
 DECLARE collected_dept_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE labscheduled_dept_status_mean = c12 WITH protect, constant("LABSCHEDULED")
 DECLARE labscheduled_dept_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE labdispatch_dept_status_mean = c12 WITH protect, constant("LABDISPATCH")
 DECLARE labdispatch_dept_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE name_type_cs = i4 WITH protect, constant(213)
 DECLARE current_name_type_mean = c12 WITH protect, constant("CURRENT")
 DECLARE current_name_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE combine_action_cs = i4 WITH protect, constant(327)
 DECLARE combine_action_add_mean = c12 WITH protect, constant("ADD")
 DECLARE dcombine_add_cd = f8 WITH protect, noconstant(0.0)
 DECLARE rec_sts_cs = i4 WITH protect, constant(48)
 DECLARE rec_sts_active_mean = c12 WITH protect, constant("ACTIVE")
 DECLARE dactive_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE event_type_cs = i4 WITH protect, constant(1610)
 DECLARE bb_orderable_proc_cs = i4 WITH protect, constant(1635)
 DECLARE prod_req_order_mean = vc WITH protect, constant("PRODUCT ORDR")
 DECLARE prod_req_order_cd = f8 WITH protect, noconstant(0.0)
 DECLARE crossmatched_event_type_mean = c12 WITH protect, constant("3")
 DECLARE crossmatched_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE facility_cd = f8 WITH protect, noconstant(0.0)
 DECLARE filterspecimenbyfacility = i2 WITH protect, noconstant(0)
 DECLARE test_facility_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pc_facility_cd = f8 WITH protect, noconstant(0.0)
 DECLARE spec_in_facility = i2 WITH protect, noconstant(0)
 DECLARE retrieve_specimen = i2 WITH protect, noconstant(0)
 DECLARE trans_facility_cd = f8 WITH protect, noconstant(0.0)
 DECLARE appkeyvalue = c10 WITH protect, noconstant(fillstring(10," "))
 DECLARE extend_expired_specimens = i2 WITH protect, noconstant(0)
 DECLARE assoc_neo_disch_encntr = i2 WITH protect, noconstant(0)
 SUBROUTINE (determineexpandtotal(lactualsize=i4,lexpandsize=i4) =i4 WITH protect, noconstant(0))
   RETURN((ceil((cnvtreal(lactualsize)/ lexpandsize)) * lexpandsize))
 END ;Subroutine
 SUBROUTINE (determineexpandsize(lrecordsize=i4,lmaximumsize=i4) =i4 WITH protect, noconstant(0))
   DECLARE lreturn = i4 WITH protect, noconstant(0)
   IF (lrecordsize <= 1)
    SET lreturn = 1
   ELSEIF (lrecordsize <= 10)
    SET lreturn = 10
   ELSEIF (lrecordsize <= 500)
    SET lreturn = 50
   ELSE
    SET lreturn = 100
   ENDIF
   IF (lmaximumsize < lreturn)
    SET lreturn = lmaximumsize
   ENDIF
   RETURN(lreturn)
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
 SUBROUTINE (bbtcheckspecimeninfacility(spec_facility_cd=f8(value),spec_testing_facility_cd=f8(value),
  pc_facility_code=f8(value),filter_by_facility=i2(value)) =i2)
  IF (filter_by_facility=1)
   IF (pc_facility_code=0)
    RETURN(0)
   ENDIF
   IF (((pc_facility_code=spec_testing_facility_cd) OR (pc_facility_code=spec_facility_cd)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SELECT INTO "nl:"
  dm.info_char
  FROM dm_info dm
  WHERE dm.info_domain="PATHNET SCRIPT LOGGING"
   AND dm.info_name="bbt_get_avail_flex_specs"
  DETAIL
   IF (dm.info_char="L")
    log_override_ind = 1
   ELSE
    log_override_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (log_override_ind=1)
  CALL echo("Starting bbt_get_avail_flex_specs script")
  CALL log_message("Starting bbt_get_avail_flex_specs script",log_level_debug)
  CALL echorecord(request)
 ENDIF
 IF (size(request->personlist,5)=0)
  CALL errorhandler("F","PersonList","PersonList is empty")
 ENDIF
 FOR (lidx3 = 1 TO size(request->personlist,5))
   IF ((request->personlist[lidx3].person_id=0.0)
    AND (request->personlist[lidx3].filter_encntr_id=0.0))
    CALL errorhandler("F","PersonList",
     "At least one PersonList record has both person_id and encntr_id as 0.")
   ENDIF
 ENDFOR
 SET bb_activity_type_cd = uar_get_code_by("MEANING",activity_type_cs,nullterm(bb_activity_type_mean)
  )
 IF (bb_activity_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve activity type code with meaning of ",trim(
    bb_activity_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET xm_exp_calc_ques_cd = uar_get_code_by("MEANING",questions_cs,nullterm(xm_exp_calc_ques_mean))
 IF (xm_exp_calc_ques_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve question code with meaning of ",trim(
    xm_exp_calc_ques_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET xm_warn_dys_ques_cd = uar_get_code_by("MEANING",questions_cs,nullterm(xm_warn_dys_ques_mean))
 IF (xm_warn_dys_ques_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve question code with meaning of ",trim(
    xm_warn_dys_ques_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET xm_warn_hrs_ques_cd = uar_get_code_by("MEANING",questions_cs,nullterm(xm_warn_hrs_ques_mean))
 IF (xm_warn_hrs_ques_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve question code with meaning of ",trim(
    xm_warn_hrs_ques_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET hours_valid_resp_cd = uar_get_code_by("MEANING",valid_responses_cs,nullterm(
   hours_valid_resp_mean))
 IF (hours_valid_resp_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve valid response with meaning of ",trim(
    hours_valid_resp_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET days_valid_resp_cd = uar_get_code_by("MEANING",valid_responses_cs,nullterm(days_valid_resp_mean)
  )
 IF (days_valid_resp_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve valid response with meaning of ",trim(
    days_valid_resp_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET gen_lab_cat_type_cd = uar_get_code_by("MEANING",catalog_type_cs,nullterm(gen_lab_cat_type_mean))
 IF (gen_lab_cat_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve catalog type code with meaning of ",trim(
    gen_lab_cat_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET ordered_status_cd = uar_get_code_by("MEANING",order_status_cs,nullterm(ordered_status_mean))
 IF (ordered_status_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve order status code with meaning of ",trim(
    ordered_status_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET inprocess_status_cd = uar_get_code_by("MEANING",order_status_cs,nullterm(inprocess_status_mean))
 IF (inprocess_status_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve order status code with meaning of ",trim(
    inprocess_status_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET completed_status_cd = uar_get_code_by("MEANING",order_status_cs,nullterm(completed_status_mean))
 IF (completed_status_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve order status code with meaning of ",trim(
    completed_status_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET future_status_cd = uar_get_code_by("MEANING",order_status_cs,nullterm(future_status_mean))
 IF (future_status_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve order status code with meaning of ",trim(
    future_status_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET unscheduled_status_cd = uar_get_code_by("MEANING",order_status_cs,nullterm(
   unscheduled_status_mean))
 IF (unscheduled_status_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve order status code with meaning of ",trim(
    unscheduled_status_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET pending_rev_status_cd = uar_get_code_by("MEANING",order_status_cs,nullterm(
   pending_rev_status_mean))
 IF (pending_rev_status_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve order status code with meaning of ",trim(
    pending_rev_status_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET suspended_status_cd = uar_get_code_by("MEANING",order_status_cs,nullterm(suspended_status_mean))
 IF (suspended_status_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve order status code with meaning of ",trim(
    suspended_status_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET inlab_dept_status_cd = uar_get_code_by("MEANING",dept_order_status_cs,nullterm(
   inlab_dept_status_mean))
 IF (inlab_dept_status_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve department order status code with meaning of ",trim(
    inlab_dept_status_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET collected_dept_status_cd = uar_get_code_by("MEANING",dept_order_status_cs,nullterm(
   collected_dept_status_mean))
 IF (collected_dept_status_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve department order status code with meaning of ",trim(
    collected_dept_status_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET labscheduled_dept_status_cd = uar_get_code_by("MEANING",dept_order_status_cs,nullterm(
   labscheduled_dept_status_mean))
 IF (labscheduled_dept_status_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve department order status code with meaning of ",trim(
    labscheduled_dept_status_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET labdispatch_dept_status_cd = uar_get_code_by("MEANING",dept_order_status_cs,nullterm(
   labdispatch_dept_status_mean))
 IF (labdispatch_dept_status_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve department order status code with meaning of ",trim(
    labdispatch_dept_status_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET current_name_type_cd = uar_get_code_by("MEANING",name_type_cs,nullterm(current_name_type_mean))
 IF (current_name_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve person mgmt config code with meaning of ",trim(
    current_name_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET crossmatched_event_type_cd = uar_get_code_by("MEANING",event_type_cs,nullterm(
   crossmatched_event_type_mean))
 IF (crossmatched_event_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve event type code with meaning of ",trim(
    crossmatched_event_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET dcombine_add_cd = uar_get_code_by("MEANING",combine_action_cs,nullterm(combine_action_add_mean))
 IF (dcombine_add_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve combine action code with meaning of ",trim(
    combine_action_add_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET dactive_status_cd = uar_get_code_by("MEANING",rec_sts_cs,nullterm(rec_sts_active_mean))
 IF (dactive_status_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve rec_sts active code with meaning of ",trim(
    rec_sts_active_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET prod_req_order_cd = uar_get_code_by("MEANING",bb_orderable_proc_cs,nullterm(prod_req_order_mean)
  )
 IF (prod_req_order_cd <= 0.0)
  SET uar_error = concat(
   "Failed to retrieve blood bank orderable processing type code with meaning of ",trim(
    prod_req_order_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET reply->historical_demog_ind = bbtgethistoricinfopreference(request->facility_cd)
 SET pc_facility_cd = request->facility_cd
 SET test_facility_cd = bbtgetflexspectestingfacility(request->facility_cd)
 IF ((test_facility_cd=- (1)))
  CALL errorhandler("F","GetFlexSpecimenParams Failed","Get test facility cd failed.")
 ENDIF
 IF (test_facility_cd > 0)
  SET pc_facility_cd = test_facility_cd
 ENDIF
 SET filterspecimenbyfacility = bbtgetflexfilterbyfacility(pc_facility_cd)
 IF (validate(request->app_key))
  SET appkeyvalue = trim(cnvtupper(request->app_key))
 ENDIF
 SELECT INTO "nl:"
  expire = uar_get_code_meaning(cnvtreal(trim(a.answer)))
  FROM answer a
  WHERE a.question_cd=xm_exp_calc_ques_cd
   AND a.active_ind=1
  HEAD REPORT
   old_expire_mean = expire
  WITH nocounter
 ;end select
 IF (old_expire_mean=days_valid_resp_mean)
  SET old_time_cd = xm_warn_dys_ques_cd
 ELSE
  SET old_time_cd = xm_warn_hrs_ques_cd
 ENDIF
 SELECT INTO "nl:"
  time = cnvtreal(trim(a.answer))
  FROM answer a
  WHERE a.question_cd=old_time_cd
   AND a.active_ind=1
  HEAD REPORT
   IF (old_expire_mean=days_valid_resp_mean)
    old_expire_time = time
   ELSE
    old_expire_time = (time/ 24.0)
   ENDIF
  WITH nocounter
 ;end select
 SET expandstart = 1
 SET actualsize = size(request->personlist,5)
 IF (actualsize <= 1)
  SET expandsize = 1
 ELSEIF (actualsize <= 5)
  SET expandsize = 5
 ELSE
  SET expandsize = 20
 ENDIF
 SET expandtotal = (ceil((cnvtreal(actualsize)/ expandsize)) * expandsize)
 IF (log_override_ind=1)
  CALL echo(build("actualSize: ",actualsize))
  CALL echo(build("expandSize: ",expandsize))
  CALL echo(build("expandTotal: ",expandtotal))
 ENDIF
 SET stat = alterlist(request->personlist,expandtotal)
 FOR (i_idx = (actualsize+ 1) TO expandtotal)
  SET request->personlist[i_idx].person_id = request->personlist[actualsize].person_id
  SET request->personlist[i_idx].filter_encntr_id = request->personlist[actualsize].filter_encntr_id
 ENDFOR
 IF (log_override_ind=1)
  CALL echo("Before select orders")
  CALL log_message("Before select orders",log_level_debug)
  CALL echorecord(request)
 ENDIF
 SET maxorderdrawndttm = datetimeadd(current_dt_tm_hold,- (180))
 SET facility_count = 0
 SELECT
  IF ((request->personlist[1].filter_encntr_id > 0.0))
   PLAN (d
    WHERE assign(expandstart,evaluate(d.seq,1,1,(expandstart+ expandsize))))
    JOIN (p
    WHERE (p.person_id=request->personlist[1].person_id))
    JOIN (e
    WHERE expand(x_idx,expandstart,((expandstart+ expandsize) - 1),e.encntr_id,request->personlist[
     x_idx].filter_encntr_id))
    JOIN (o
    WHERE o.encntr_id=e.encntr_id
     AND o.current_start_dt_tm >= cnvtdatetime(maxorderdrawndttm)
     AND ((o.catalog_type_cd+ 0.0)=gen_lab_cat_type_cd)
     AND ((o.activity_type_cd+ 0.0)=bb_activity_type_cd)
     AND o.orderable_type_flag != sup_grp_ord_type
     AND o.orderable_type_flag != ord_set_ord_type)
    JOIN (aor
    WHERE aor.order_id=o.order_id
     AND aor.primary_flag=0)
    JOIN (sd
    WHERE sd.catalog_cd=o.catalog_cd
     AND sd.bb_processing_cd != prod_req_order_cd)
    JOIN (d_bop)
    JOIN (bop
    WHERE bop.order_id=o.order_id)
  ELSE
   PLAN (d
    WHERE assign(expandstart,evaluate(d.seq,1,1,(expandstart+ expandsize))))
    JOIN (p
    WHERE expand(i_idx,expandstart,((expandstart+ expandsize) - 1),p.person_id,request->personlist[
     i_idx].person_id))
    JOIN (e
    WHERE e.person_id=p.person_id)
    JOIN (o
    WHERE o.person_id=p.person_id
     AND o.current_start_dt_tm >= cnvtdatetime(maxorderdrawndttm)
     AND o.catalog_type_cd=gen_lab_cat_type_cd
     AND ((o.encntr_id+ 0.0)=e.encntr_id)
     AND ((o.activity_type_cd+ 0.0)=bb_activity_type_cd)
     AND o.orderable_type_flag != sup_grp_ord_type
     AND o.orderable_type_flag != ord_set_ord_type)
    JOIN (aor
    WHERE aor.order_id=o.order_id
     AND aor.primary_flag=0)
    JOIN (sd
    WHERE sd.catalog_cd=o.catalog_cd
     AND sd.bb_processing_cd != prod_req_order_cd)
    JOIN (d_bop)
    JOIN (bop
    WHERE bop.order_id=o.order_id)
  ENDIF
  INTO "nl:"
  p.*, e.*, o.*,
  aor.*, sd.*, bop.*,
  locatestart = expandstart
  FROM (dummyt d  WITH seq = value((expandtotal/ expandsize))),
   person p,
   encounter e,
   orders o,
   accession_order_r aor,
   service_directory sd,
   dummyt d_bop,
   bb_order_phase bop
  ORDER BY p.person_id, e.encntr_id, aor.order_id
  HEAD REPORT
   temp_person_count = 0, person_count = 0
  HEAD p.person_id
   temp_order_count = 0, specimen_count = 0
  HEAD e.encntr_id
   personlistindexhold = locateval(i_idx,locatestart,((locatestart+ expandsize) - 1),p.person_id,
    request->personlist[i_idx].person_id)
   IF ((request->personlist[personlistindexhold].encntr_facility_cd > 0.0))
    encntrfacilitycdhold = request->personlist[personlistindexhold].encntr_facility_cd
   ELSE
    encntrfacilitycdhold = e.loc_facility_cd
   ENDIF
   trans_facility_cd = bbtgetflexspectestingfacility(encntrfacilitycdhold), facilityidxhold =
   locateval(x_idx,1,size(facilityinfo->facilities,5),trans_facility_cd,facilityinfo->facilities[
    x_idx].testing_facility_cd)
   IF (facilityidxhold <= 0)
    facility_count += 1
    IF (facility_count > size(facilityinfo->facilities,5))
     stat = alterlist(facilityinfo->facilities,facility_count)
    ENDIF
    facilityinfo->facilities[facility_count].testing_facility_cd = trans_facility_cd,
    CALL getflexspecimenparams(facility_count,encntrfacilitycdhold,1,appkeyvalue), facilityidxhold =
    facility_count
   ENDIF
   retrieve_specimen = 1
   IF ((facilityinfo->facilities[facilityidxhold].flex_on_ind=1))
    IF (evaluate(nullind(p.birth_dt_tm),0,1,0)=1
     AND (datetimediff(current_dt_tm_hold,cnvtdatetime(cnvtdate(p.birth_dt_tm),235959)) <=
    facilityinfo->facilities[facilityidxhold].neonate_age))
     flexspecmax = facilityinfo->facilities[facilityidxhold].neonate_age, flexspecmax += 1
     IF (evaluate(nullind(e.disch_dt_tm),0,1,0)=1
      AND appkeyvalue="AVAILSPECS"
      AND (facilityinfo->facilities[facilityidxhold].extend_neonate_disch_spec != 1))
      retrieve_specimen = 0
     ENDIF
    ELSE
     flexspecmax = facilityinfo->facilities[facilityidxhold].max_spec_validity, flexspecmax += 1
    ENDIF
   ENDIF
   IF ((request->personlist[personlistindexhold].filter_encntr_id > 0.0))
    filterbyencounterind = 1
   ELSE
    filterbyencounterind = 0
   ENDIF
  HEAD aor.order_id
   IF ((facilityinfo->facilities[facilityidxhold].flex_on_ind=1))
    IF (((o.order_status_cd IN (inprocess_status_cd, completed_status_cd)) OR (o.order_status_cd=
    ordered_status_cd
     AND o.dept_status_cd IN (inlab_dept_status_cd, collected_dept_status_cd)))
     AND datetimediff(current_dt_tm_hold,o.current_start_dt_tm) <= flexspecmax)
     IF (retrieve_specimen=1)
      temppersonidxhold = locateval(x_idx,1,temp_person_count,p.person_id,temp->personlist[x_idx].
       person_id)
      IF (temppersonidxhold <= 0)
       temp_person_count += 1
       IF (temp_person_count > size(temp->personlist,5))
        stat = alterlist(temp->personlist,(temp_person_count+ 9))
       ENDIF
       temp->personlist[temp_person_count].name_full_formatted = p.name_full_formatted, temp->
       personlist[temp_person_count].person_id = p.person_id, temp->personlist[temp_person_count].
       birth_dt_tm = p.birth_dt_tm,
       temppersonidxhold = temp_person_count
      ENDIF
      temp_order_count += 1
      IF (temp_order_count > size(temp->personlist[temppersonidxhold].orders,5))
       stat = alterlist(temp->personlist[temppersonidxhold].orders,(temp_order_count+ 9))
      ENDIF
      temp->personlist[temppersonidxhold].orders[temp_order_count].order_id = o.order_id, temp->
      personlist[temppersonidxhold].orders[temp_order_count].order_mnemonic = o.order_mnemonic, temp
      ->personlist[temppersonidxhold].orders[temp_order_count].encntr_id = e.encntr_id,
      temp->personlist[temppersonidxhold].orders[temp_order_count].encntr_fac_cd =
      encntrfacilitycdhold, temp->personlist[temppersonidxhold].orders[temp_order_count].
      encntr_discharged = evaluate(nullind(e.disch_dt_tm),0,1,0), temp->personlist[temppersonidxhold]
      .orders[temp_order_count].status = uar_get_code_display(o.dept_status_cd),
      temp->personlist[temppersonidxhold].orders[temp_order_count].order_status_cd = o
      .order_status_cd, temp->personlist[temppersonidxhold].orders[temp_order_count].catalog_cd = sd
      .catalog_cd, temp->personlist[temppersonidxhold].orders[temp_order_count].phase_group_cd = bop
      .phase_grp_cd,
      temp->personlist[temppersonidxhold].orders[temp_order_count].accession = aor.accession
     ENDIF
    ENDIF
   ELSE
    IF (o.order_status_cd IN (ordered_status_cd, inprocess_status_cd, completed_status_cd,
    future_status_cd, unscheduled_status_cd,
    pending_rev_status_cd, suspended_status_cd))
     IF (old_expire_mean=days_valid_resp_mean)
      expiredttm = datetimeadd(cnvtdatetime(cnvtdate(o.current_start_dt_tm),235959),old_expire_time)
     ELSE
      expiredttm = datetimeadd(o.current_start_dt_tm,old_expire_time)
     ENDIF
     IF (expiredttm > current_dt_tm_hold)
      personindexhold = locateval(x_idx,1,person_count,p.person_id,reply->personlist[x_idx].person_id
       )
      IF (personindexhold <= 0)
       person_count += 1
       IF (person_count > size(reply->personlist,5))
        stat = alterlist(reply->personlist,(person_count+ 9))
       ENDIF
       reply->personlist[person_count].name_full_formatted = p.name_full_formatted, reply->
       personlist[person_count].person_id = p.person_id, personindexhold = person_count
      ENDIF
      IF ((request->alert_ind="Y"))
       IF (filterspecimenbyfacility=1)
        spec_in_facility = bbtcheckspecimeninfacility(encntrfacilitycdhold,trans_facility_cd,
         pc_facility_cd,filterspecimenbyfacility)
        IF (spec_in_facility=1)
         reply->personlist[personindexhold].alert_flag = "Y", reply->personlist[personindexhold].
         active_specimen_exists = 1
        ENDIF
       ELSE
        reply->personlist[personindexhold].alert_flag = "Y", reply->personlist[personindexhold].
        active_specimen_exists = 1
       ENDIF
      ELSE
       specimen_count += 1
       IF (specimen_count > size(reply->personlist[personindexhold].specimen,5))
        stat = alterlist(reply->personlist[personindexhold].specimen,(specimen_count+ 9))
       ENDIF
       reply->personlist[personindexhold].specimen[specimen_count].drawn_dt_tm = o
       .current_start_dt_tm, reply->personlist[personindexhold].specimen[specimen_count].accession =
       o.order_mnemonic
       IF (o.dept_status_cd IN (labscheduled_dept_status_cd, labdispatch_dept_status_cd))
        reply->personlist[personindexhold].specimen[specimen_count].expire_dt_tm = cnvtdatetime("")
       ELSE
        reply->personlist[personindexhold].specimen[specimen_count].expire_dt_tm = expiredttm
       ENDIF
       reply->personlist[personindexhold].specimen[specimen_count].unformatted_accession = aor
       .accession, reply->personlist[personindexhold].specimen[specimen_count].accession =
       uar_fmt_accession(aor.accession,size(aor.accession,1)), stat = alterlist(reply->personlist[
        personindexhold].specimen[specimen_count].orders,1),
       reply->personlist[personindexhold].specimen[specimen_count].orders[1].order_id = o.order_id,
       reply->personlist[personindexhold].specimen[specimen_count].orders[1].encntr_id = o.encntr_id,
       reply->personlist[personindexhold].specimen[specimen_count].orders[1].order_mnemonic = o
       .order_mnemonic,
       reply->personlist[personindexhold].specimen[specimen_count].orders[1].status =
       uar_get_code_display(o.dept_status_cd), reply->personlist[personindexhold].specimen[
       specimen_count].orders[1].order_status_cd = o.order_status_cd, reply->personlist[
       personindexhold].specimen[specimen_count].orders[1].catalog_cd = sd.catalog_cd,
       reply->personlist[personindexhold].specimen[specimen_count].orders[1].phase_group_cd = bop
       .phase_grp_cd
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  DETAIL
   row + 0
  FOOT  aor.order_id
   row + 0
  FOOT  e.encntr_id
   row + 0
  FOOT  p.person_id
   IF (temp_person_count > 0)
    stat = alterlist(temp->personlist[temp_person_count].orders,temp_order_count)
   ENDIF
   personindexhold = locateval(x_idx,1,person_count,p.person_id,reply->personlist[x_idx].person_id)
   IF (personindexhold > 0)
    stat = alterlist(reply->personlist[personindexhold].specimen,specimen_count)
    IF ((request->alert_ind="Y"))
     IF (personindexhold > 0)
      IF ((reply->personlist[personindexhold].alert_flag != "Y"))
       reply->personlist[personindexhold].alert_flag = "N"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(temp->personlist,temp_person_count), stat = alterlist(reply->personlist,
    person_count)
   IF (facility_count > 0)
    stat = alterlist(facilityinfo->facilities,facility_count)
   ENDIF
  WITH nocounter, expand = 1, outerjoin = d_bop
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Select person",errmsg)
 ENDIF
 SET stat = alterlist(request->personlist,actualsize)
 IF (temp_person_count=0)
  GO TO get_historic_name
 ENDIF
 IF (log_override_ind=1)
  CALL echo("Starting product event")
  CALL log_message("Starting product event",log_level_debug)
  CALL echorecord(temp)
 ENDIF
 SELECT INTO "nl:"
  pe.*, prd.*, bp.*,
  pi.*, c.*
  FROM (dummyt d1  WITH seq = value(size(temp->personlist,5))),
   (dummyt d2  WITH seq = 1),
   product_event pe,
   product prd,
   blood_product bp,
   product_index pi,
   crossmatch c
  PLAN (d1
   WHERE maxrec(d2,size(temp->personlist[d1.seq].orders,5)))
   JOIN (d2)
   JOIN (pe
   WHERE (pe.order_id=temp->personlist[d1.seq].orders[d2.seq].order_id)
    AND ((pe.event_type_cd+ 0.0)=crossmatched_event_type_cd)
    AND pe.active_ind=1)
   JOIN (prd
   WHERE prd.product_id=pe.product_id
    AND prd.active_ind=1)
   JOIN (bp
   WHERE bp.product_id=prd.product_id
    AND bp.active_ind=1)
   JOIN (pi
   WHERE pi.product_cd=bp.product_cd
    AND pi.active_ind=1)
   JOIN (c
   WHERE c.product_event_id=pe.product_event_id
    AND c.active_ind=1)
  ORDER BY d1.seq, d2.seq, bp.product_id
  HEAD d1.seq
   row + 0
  HEAD d2.seq
   temp_prod_event_count = 0
  HEAD bp.product_id
   IF (pi.product_cd > 0.0
    AND pi.autologous_ind=0)
    temp_prod_event_count += 1
    IF (temp_prod_event_count > size(temp->personlist[d1.seq].orders[d2.seq].productevents,5))
     stat = alterlist(temp->personlist[d1.seq].orders[d2.seq].productevents,(temp_prod_event_count+ 9
      ))
    ENDIF
    temp->personlist[d1.seq].orders[d2.seq].productevents[temp_prod_event_count].product_event_id =
    pe.product_event_id, temp->personlist[d1.seq].orders[d2.seq].productevents[temp_prod_event_count]
    .product.locked_ind = prd.locked_ind, temp->personlist[d1.seq].orders[d2.seq].productevents[
    temp_prod_event_count].product.product_id = prd.product_id,
    temp->personlist[d1.seq].orders[d2.seq].productevents[temp_prod_event_count].product.
    product_number_disp = concat(trim(bp.supplier_prefix),trim(prd.product_nbr)," ",trim(prd
      .product_sub_nbr)), temp->personlist[d1.seq].orders[d2.seq].productevents[temp_prod_event_count
    ].product.product_type_cd = prd.product_cd, temp->personlist[d1.seq].orders[d2.seq].
    productevents[temp_prod_event_count].product.updt_applctx = prd.updt_applctx,
    temp->personlist[d1.seq].orders[d2.seq].productevents[temp_prod_event_count].product.
    crossmatch_expire_dt_tm = c.crossmatch_exp_dt_tm
   ENDIF
  DETAIL
   row + 0
  FOOT  bp.product_id
   row + 0
  FOOT  d2.seq
   stat = alterlist(temp->personlist[d1.seq].orders[d2.seq].productevents,temp_prod_event_count)
  FOOT  d1.seq
   row + 0
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Select product event",errmsg)
 ENDIF
 IF (log_override_ind=1)
  CALL echo("Starting result/perform result")
  CALL log_message("Starting result/perform result",log_level_debug)
  CALL echorecord(temp)
 ENDIF
 SELECT INTO "nl:"
  r.*, pr.*
  FROM (dummyt d1  WITH seq = value(size(temp->personlist,5))),
   (dummyt d2  WITH seq = 1),
   result r,
   perform_result pr
  PLAN (d1
   WHERE maxrec(d2,size(temp->personlist[d1.seq].orders,5)))
   JOIN (d2)
   JOIN (r
   WHERE (r.order_id=temp->personlist[d1.seq].orders[d2.seq].order_id))
   JOIN (pr
   WHERE pr.result_id=r.result_id
    AND ((pr.container_id+ 0) > 0.0))
  ORDER BY d1.seq, d2.seq, pr.container_id
  HEAD d1.seq
   row + 0
  HEAD d2.seq
   temp_container_count = 0
  HEAD pr.container_id
   temp_container_count += 1
   IF (temp_container_count > size(temp->personlist[d1.seq].orders[d2.seq].containers,5))
    stat = alterlist(temp->personlist[d1.seq].orders[d2.seq].containers,(temp_container_count+ 9))
   ENDIF
   temp->personlist[d1.seq].orders[d2.seq].containers[temp_container_count].container_id = pr
   .container_id
  DETAIL
   row + 0
  FOOT  pr.container_id
   row + 0
  FOOT  d2.seq
   stat = alterlist(temp->personlist[d1.seq].orders[d2.seq].containers,temp_container_count)
  FOOT  d1.seq
   row + 0
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Select result",errmsg)
 ENDIF
 IF (log_override_ind=1)
  CALL echo("Starting container")
  CALL log_message("Starting containert",log_level_debug)
  CALL echorecord(temp)
 ENDIF
 SELECT INTO "nl:"
  osrc.*
  FROM (dummyt d1  WITH seq = value(size(temp->personlist,5))),
   (dummyt d2  WITH seq = 1),
   order_serv_res_container osrc
  PLAN (d1
   WHERE maxrec(d2,size(temp->personlist[d1.seq].orders,5)))
   JOIN (d2)
   JOIN (osrc
   WHERE (osrc.order_id=temp->personlist[d1.seq].orders[d2.seq].order_id))
  ORDER BY d1.seq, d2.seq, osrc.container_id
  HEAD d1.seq
   row + 0
  HEAD d2.seq
   temp_container_count = 0
  HEAD osrc.container_id
   IF (((size(temp->personlist[d1.seq].orders[d2.seq].containers,5)=0) OR (temp_container_count > 0
   )) )
    temp_container_count += 1
    IF (temp_container_count > size(temp->personlist[d1.seq].orders[d2.seq].containers,5))
     stat = alterlist(temp->personlist[d1.seq].orders[d2.seq].containers,(temp_container_count+ 9))
    ENDIF
    temp->personlist[d1.seq].orders[d2.seq].containers[temp_container_count].container_id = osrc
    .container_id
   ENDIF
  DETAIL
   row + 0
  FOOT  osrc.container_id
   row + 0
  FOOT  d2.seq
   IF (temp_container_count > 0)
    stat = alterlist(temp->personlist[d1.seq].orders[d2.seq].containers,temp_container_count)
   ENDIF
  FOOT  d1.seq
   row + 0
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Select order_serv_res_container",errmsg)
 ENDIF
 IF (log_override_ind=1)
  CALL echo("Starting specimen override")
  CALL log_message("Starting specimen override",log_level_debug)
  CALL echorecord(temp)
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(temp->personlist,5))),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   container c,
   bb_spec_expire_ovrd bseo
  PLAN (d1
   WHERE maxrec(d2,size(temp->personlist[d1.seq].orders,5)))
   JOIN (d2
   WHERE maxrec(d3,size(temp->personlist[d1.seq].orders[d2.seq].containers,5)))
   JOIN (d3)
   JOIN (c
   WHERE (c.container_id=temp->personlist[d1.seq].orders[d2.seq].containers[d3.seq].container_id))
   JOIN (bseo
   WHERE (bseo.specimen_id= Outerjoin(c.specimen_id))
    AND (bseo.active_ind= Outerjoin(1)) )
  ORDER BY d1.seq, d2.seq, d3.seq,
   c.container_id
  DETAIL
   temp->personlist[d1.seq].orders[d2.seq].containers[d3.seq].specimen_id = c.specimen_id, temp->
   personlist[d1.seq].orders[d2.seq].containers[d3.seq].drawn_dt_tm = c.drawn_dt_tm
   IF (bseo.specimen_id > 0.0)
    temp->personlist[d1.seq].orders[d2.seq].containers[d3.seq].new_spec_expire_dt_tm = bseo
    .new_spec_expire_dt_tm, temp->personlist[d1.seq].orders[d2.seq].containers[d3.seq].override_id =
    bseo.bb_spec_expire_ovrd_id, temp->personlist[d1.seq].orders[d2.seq].containers[d3.seq].
    override_cd = bseo.override_reason_cd
   ENDIF
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Select container",errmsg)
 ENDIF
 IF (log_override_ind=1)
  CALL echo("Starting populate reply")
  CALL log_message("Starting populate reply",log_level_debug)
  CALL echorecord(temp)
 ENDIF
 SET person_count = size(reply->personlist,5)
 SET flex_param_out->testing_facility_cd = - (1)
 FOR (i_idx = 1 TO size(temp->personlist,5))
   SET personindexhold = locateval(x_idx,1,size(reply->personlist,5),temp->personlist[i_idx].
    person_id,reply->personlist[x_idx].person_id)
   IF (personindexhold <= 0)
    SET person_count += 1
    IF (person_count > size(reply->personlist,5))
     SET stat = alterlist(reply->personlist,(person_count+ 9))
    ENDIF
    SET reply->personlist[person_count].name_full_formatted = temp->personlist[i_idx].
    name_full_formatted
    SET reply->personlist[person_count].person_id = temp->personlist[i_idx].person_id
    SET personindexhold = person_count
   ENDIF
   SET specimen_count = size(reply->personlist[personindexhold].specimen,5)
   FOR (j_idx = 1 TO size(temp->personlist[i_idx].orders,5))
     SET spec_in_facility = 0
     SET trans_facility_cd = bbtgetflexspectestingfacility(temp->personlist[i_idx].orders[j_idx].
      encntr_fac_cd)
     SET facilityidxhold = locateval(x_idx,1,size(facilityinfo->facilities,5),trans_facility_cd,
      facilityinfo->facilities[x_idx].testing_facility_cd)
     IF (facilityidxhold > 0)
      CALL getflexspecimenparams(facilityidxhold,temp->personlist[i_idx].orders[j_idx].encntr_fac_cd,
       0,appkeyvalue)
      IF ((facilityinfo->facilities[facilityidxhold].load_flex_params=- (1)))
       CALL errorhandler("F","GetFlexSpecimenParams Failed",
        "GetFlexSpecimenParams returned a failure.")
      ENDIF
     ENDIF
     FOR (k_idx = 1 TO size(temp->personlist[i_idx].orders[j_idx].containers,5))
       IF ((temp->personlist[i_idx].orders[j_idx].containers[k_idx].override_id > 0.0))
        SET override_meaning = trim(uar_get_code_meaning(temp->personlist[i_idx].orders[j_idx].
          containers[k_idx].override_cd))
        SET expdttm = temp->personlist[i_idx].orders[j_idx].containers[k_idx].new_spec_expire_dt_tm
        IF (override_meaning IN (sys_anti_ovrd_cdf_meaning, neonate_ovrd_cdf_meaning))
         SET flex_max_out->max_expire_dt_tm = expdttm
         IF (override_meaning=sys_anti_ovrd_cdf_meaning)
          SET flex_max_out->max_expire_flag = nanti_flag
         ELSEIF (override_meaning=neonate_ovrd_cdf_meaning)
          SET flex_max_out->max_expire_flag = nneonate_flag
         ENDIF
        ELSE
         SET stat = getflexmaxexpirationforperson(temp->personlist[i_idx].person_id,0.0,temp->
          personlist[i_idx].orders[j_idx].containers[k_idx].drawn_dt_tm,temp->personlist[i_idx].
          orders[j_idx].encntr_fac_cd)
         IF ((stat=- (1)))
          CALL errorhandler("F","GetFlexMaxExpirationForPerson Failed",
           "GetFlexMaxExpirationForPerson returned a failure.")
         ENDIF
        ENDIF
       ELSE
        SET expdttm = null
        SET expdttm = getflexexpirationforperson(temp->personlist[i_idx].person_id,0.0,temp->
         personlist[i_idx].orders[j_idx].containers[k_idx].drawn_dt_tm,temp->personlist[i_idx].
         orders[j_idx].encntr_fac_cd,0)
        IF ((expdttm=- (1)))
         CALL errorhandler("F","GetFlexExpirationForPerson Failed",
          "GetFlexExpirationForPerson returned a failure.")
        ENDIF
        SET stat = getflexmaxexpirationforperson(temp->personlist[i_idx].person_id,0.0,temp->
         personlist[i_idx].orders[j_idx].containers[k_idx].drawn_dt_tm,temp->personlist[i_idx].
         orders[j_idx].encntr_fac_cd)
        IF ((stat=- (1)))
         CALL errorhandler("F","GetFlexMaxExpirationForPerson Failed",
          "GetFlexMaxExpirationForPerson returned a failure.")
        ENDIF
       ENDIF
       SET flextestingfaccdhold = flex_param_out->testing_facility_cd
       SET flexmaxhold = flex_param_out->max_spec_validity
       SET flexdayshrsmeanhold = flex_param_out->expiration_unit_type_mean
       SET extend_expired_specimens = 0
       SET assoc_neo_disch_encntr = 0
       IF ((temp->personlist[i_idx].birth_dt_tm != null)
        AND (datetimediff(cnvtdatetime(current_dt_tm_hold),cnvtdatetime(cnvtdate(temp->personlist[
          i_idx].birth_dt_tm),235959)) <= flex_param_out->neonate_age))
        IF ((flex_max_out->max_expire_flag=nmax_param_flag))
         SET maxexpdttm = datetimeadd(cnvtdatetime(cnvtdate(temp->personlist[i_idx].birth_dt_tm),
           235959),flex_param_out->neonate_age)
        ELSE
         SET maxexpdttm = flex_max_out->max_expire_dt_tm
        ENDIF
        IF ((temp->personlist[i_idx].orders[j_idx].encntr_discharged=1))
         SET extend_expired_specimens = facilityinfo->facilities[facilityidxhold].
         extend_neonate_disch_spec
         SET assoc_neo_disch_encntr = 1
        ELSE
         SET extend_expired_specimens = facilityinfo->facilities[facilityidxhold].
         extend_expired_specimen
        ENDIF
       ELSE
        SET maxexpdttm = flex_max_out->max_expire_dt_tm
        SET extend_expired_specimens = facilityinfo->facilities[facilityidxhold].
        extend_expired_specimen
       ENDIF
       IF (((expdttm > cnvtdatetime(current_dt_tm_hold)) OR (extend_expired_specimens=1
        AND cnvtdatetime(current_dt_tm_hold) < maxexpdttm)) )
        IF ((request->alert_ind="Y"))
         IF (filterspecimenbyfacility=1)
          IF ((reply->personlist[personindexhold].active_specimen_exists=0))
           SET spec_in_facility = bbtcheckspecimeninfacility(temp->personlist[i_idx].orders[j_idx].
            encntr_fac_cd,flextestingfaccdhold,pc_facility_cd,filterspecimenbyfacility)
           IF (spec_in_facility=1)
            SET reply->personlist[personindexhold].alert_flag = "Y"
            IF (expdttm > cnvtdatetime(current_dt_tm_hold))
             SET reply->personlist[personindexhold].active_specimen_exists = 1
            ENDIF
           ENDIF
          ENDIF
         ELSE
          SET reply->personlist[personindexhold].alert_flag = "Y"
          IF (expdttm > cnvtdatetime(current_dt_tm_hold))
           SET reply->personlist[personindexhold].active_specimen_exists = 1
          ENDIF
         ENDIF
        ELSE
         SET specindexhold = locateval(x_idx,1,size(reply->personlist[personindexhold].specimen,5),
          temp->personlist[i_idx].orders[j_idx].containers[k_idx].specimen_id,reply->personlist[
          personindexhold].specimen[x_idx].specimen_id)
         IF (specindexhold <= 0)
          SET specimen_count += 1
          IF (specimen_count > size(reply->personlist[personindexhold].specimen,5))
           SET stat = alterlist(reply->personlist[personindexhold].specimen,(specimen_count+ 9))
          ENDIF
          SET reply->personlist[personindexhold].specimen[specimen_count].flex_on_ind = 1
          SET reply->personlist[personindexhold].specimen[specimen_count].flex_days_hrs_mean =
          flexdayshrsmeanhold
          SET reply->personlist[personindexhold].specimen[specimen_count].flex_max = flexmaxhold
          SET reply->personlist[personindexhold].specimen[specimen_count].encntr_id = temp->
          personlist[i_idx].orders[j_idx].encntr_id
          SET reply->personlist[personindexhold].specimen[specimen_count].unformatted_accession =
          temp->personlist[i_idx].orders[j_idx].accession
          SET reply->personlist[personindexhold].specimen[specimen_count].accession =
          uar_fmt_accession(temp->personlist[i_idx].orders[j_idx].accession,size(temp->personlist[
            i_idx].orders[j_idx].accession,1))
          SET reply->personlist[personindexhold].specimen[specimen_count].drawn_dt_tm = temp->
          personlist[i_idx].orders[j_idx].containers[k_idx].drawn_dt_tm
          SET reply->personlist[personindexhold].specimen[specimen_count].expire_dt_tm = expdttm
          SET reply->personlist[personindexhold].specimen[specimen_count].max_expire_dt_tm =
          flex_max_out->max_expire_dt_tm
          SET reply->personlist[personindexhold].specimen[specimen_count].max_expire_flag =
          flex_max_out->max_expire_flag
          SET reply->personlist[personindexhold].specimen[specimen_count].override_id = temp->
          personlist[i_idx].orders[j_idx].containers[k_idx].override_id
          SET reply->personlist[personindexhold].specimen[specimen_count].override_cd = temp->
          personlist[i_idx].orders[j_idx].containers[k_idx].override_cd
          SET reply->personlist[personindexhold].specimen[specimen_count].override_disp =
          uar_get_code_display(temp->personlist[i_idx].orders[j_idx].containers[k_idx].override_cd)
          SET reply->personlist[personindexhold].specimen[specimen_count].override_mean =
          uar_get_code_meaning(temp->personlist[i_idx].orders[j_idx].containers[k_idx].override_cd)
          SET reply->personlist[personindexhold].specimen[specimen_count].specimen_id = temp->
          personlist[i_idx].orders[j_idx].containers[k_idx].specimen_id
          SET reply->personlist[personindexhold].specimen[specimen_count].encntr_facility_cd = temp->
          personlist[i_idx].orders[j_idx].encntr_fac_cd
          SET reply->personlist[personindexhold].specimen[specimen_count].testing_facility_cd =
          flextestingfaccdhold
          IF (validate(reply->personlist[personindexhold].specimen[specimen_count].is_expired_flag)
           AND expdttm < cnvtdatetime(current_dt_tm_hold))
           SET reply->personlist[personindexhold].specimen[specimen_count].is_expired_flag = 1
          ENDIF
          SET reply->personlist[personindexhold].specimen[specimen_count].assoc_neo_disch_encntr =
          assoc_neo_disch_encntr
          SET specindexhold = specimen_count
         ENDIF
         SET orders_count = size(reply->personlist[personindexhold].specimen[specindexhold].orders,5)
         SET ordindexhold = locateval(x_idx,1,orders_count,temp->personlist[i_idx].orders[j_idx].
          order_id,reply->personlist[personindexhold].specimen[specindexhold].orders[x_idx].order_id)
         IF (ordindexhold <= 0)
          SET orders_count += 1
          SET stat = alterlist(reply->personlist[personindexhold].specimen[specindexhold].orders,
           orders_count)
          SET reply->personlist[personindexhold].specimen[specindexhold].orders[orders_count].
          order_id = temp->personlist[i_idx].orders[j_idx].order_id
          SET reply->personlist[personindexhold].specimen[specindexhold].orders[orders_count].
          encntr_id = temp->personlist[i_idx].orders[j_idx].encntr_id
          SET reply->personlist[personindexhold].specimen[specindexhold].orders[orders_count].
          order_mnemonic = temp->personlist[i_idx].orders[j_idx].order_mnemonic
          SET reply->personlist[personindexhold].specimen[specindexhold].orders[orders_count].status
           = temp->personlist[i_idx].orders[j_idx].status
          SET reply->personlist[personindexhold].specimen[specindexhold].orders[orders_count].
          order_status_cd = temp->personlist[i_idx].orders[j_idx].order_status_cd
          SET reply->personlist[personindexhold].specimen[specindexhold].orders[orders_count].
          catalog_cd = temp->personlist[i_idx].orders[j_idx].catalog_cd
          SET reply->personlist[personindexhold].specimen[specindexhold].orders[orders_count].
          phase_group_cd = temp->personlist[i_idx].orders[j_idx].phase_group_cd
          SET ordindexhold = orders_count
         ENDIF
         SET products_count = size(reply->personlist[personindexhold].specimen[specindexhold].orders[
          ordindexhold].products,5)
         FOR (l_idx = 1 TO size(temp->personlist[i_idx].orders[j_idx].productevents,5))
           SET products_count += 1
           IF (products_count > size(reply->personlist[personindexhold].specimen[specindexhold].
            orders[ordindexhold].products,5))
            SET stat = alterlist(reply->personlist[personindexhold].specimen[specindexhold].orders[
             ordindexhold].products,(products_count+ 9))
           ENDIF
           SET reply->personlist[personindexhold].specimen[specindexhold].orders[ordindexhold].
           products[products_count].crossmatch_expire_dt_tm = temp->personlist[i_idx].orders[j_idx].
           productevents[l_idx].product.crossmatch_expire_dt_tm
           SET reply->personlist[personindexhold].specimen[specindexhold].orders[ordindexhold].
           products[products_count].locked_ind = temp->personlist[i_idx].orders[j_idx].productevents[
           l_idx].product.locked_ind
           SET reply->personlist[personindexhold].specimen[specindexhold].orders[ordindexhold].
           products[products_count].product_event_id = temp->personlist[i_idx].orders[j_idx].
           productevents[l_idx].product_event_id
           SET reply->personlist[personindexhold].specimen[specindexhold].orders[ordindexhold].
           products[products_count].product_id = temp->personlist[i_idx].orders[j_idx].productevents[
           l_idx].product.product_id
           SET reply->personlist[personindexhold].specimen[specindexhold].orders[ordindexhold].
           products[products_count].product_nbr_display = temp->personlist[i_idx].orders[j_idx].
           productevents[l_idx].product.product_number_disp
           SET reply->personlist[personindexhold].specimen[specindexhold].orders[ordindexhold].
           products[products_count].product_type_cd = temp->personlist[i_idx].orders[j_idx].
           productevents[l_idx].product.product_type_cd
           SET reply->personlist[personindexhold].specimen[specindexhold].orders[ordindexhold].
           products[products_count].product_type_disp = uar_get_code_display(temp->personlist[i_idx].
            orders[j_idx].productevents[l_idx].product.product_type_cd)
           SET reply->personlist[personindexhold].specimen[specindexhold].orders[ordindexhold].
           products[products_count].updt_applctx = temp->personlist[i_idx].orders[j_idx].
           productevents[l_idx].product.updt_applctx
         ENDFOR
         SET stat = alterlist(reply->personlist[personindexhold].specimen[specindexhold].orders[
          ordindexhold].products,products_count)
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   SET stat = alterlist(reply->personlist[personindexhold].specimen,specimen_count)
   IF ((request->alert_ind="Y"))
    IF ((reply->personlist[personindexhold].alert_flag != "Y"))
     SET reply->personlist[personindexhold].alert_flag = "N"
    ENDIF
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->personlist,person_count)
 IF ((request->alert_ind != "Y"))
  SET person_count = size(reply->personlist,5)
  FOR (i_idx = 1 TO person_count)
    SET maxexpdttmhold = 0.0
    SET specimen_count = size(reply->personlist[i_idx].specimen,5)
    FOR (j_idx = 1 TO specimen_count)
      IF ((reply->personlist[i_idx].specimen[j_idx].expire_dt_tm > maxexpdttmhold))
       SET maxexpdttmhold = reply->personlist[i_idx].specimen[j_idx].expire_dt_tm
      ENDIF
    ENDFOR
    IF (maxexpdttmhold > 0.0)
     SET reply->personlist[i_idx].new_sample_dt_tm = cnvtlookahead("1,S",maxexpdttmhold)
    ELSE
     SET reply->personlist[i_idx].new_sample_dt_tm = current_dt_tm_hold
    ENDIF
  ENDFOR
 ENDIF
#get_historic_name
 IF (log_override_ind=1)
  CALL echo("Starting popluate historical name")
  CALL log_message("Starting popluate historical name",log_level_debug)
  CALL echo(build("historical_demog_ind: ",reply->historical_demog_ind))
 ENDIF
 IF ((reply->historical_demog_ind=1)
  AND (request->alert_ind != "Y"))
  FOR (y_idx = 1 TO size(reply->personlist,5))
    FOR (lidx1 = 1 TO size(reply->personlist[y_idx].specimen,5))
      FOR (lidx2 = 1 TO size(reply->personlist[y_idx].specimen[lidx1].orders,5))
        SET dcurrent_person_id = reply->personlist[y_idx].person_id
        SELECT INTO "nl:"
         pc.from_person_id
         FROM person_combine_det pcd,
          person_combine pc
         PLAN (pcd
          WHERE (pcd.entity_id=reply->personlist[y_idx].specimen[lidx1].orders[lidx2].order_id)
           AND pcd.entity_name="ORDERS")
          JOIN (pc
          WHERE pc.person_combine_id=pcd.person_combine_id
           AND pc.active_status_cd=dactive_status_cd
           AND pc.active_status_dt_tm >= cnvtdatetime(reply->personlist[y_idx].specimen[lidx1].
           drawn_dt_tm)
           AND pc.active_ind=1)
         ORDER BY pc.active_status_dt_tm
         HEAD REPORT
          dcurrent_person_id = pc.from_person_id
         WITH nocounter
        ;end select
        SELECT INTO "nl:"
         pnh.name_full
         FROM person_name_hist pnh
         PLAN (pnh
          WHERE pnh.person_id=dcurrent_person_id
           AND pnh.name_type_cd=current_name_type_cd
           AND pnh.transaction_dt_tm <= cnvtdatetime(datetimeadd(reply->personlist[y_idx].specimen[
            lidx1].drawn_dt_tm,dminute))
           AND  NOT ( EXISTS (
          (SELECT
           pcd.entity_id
           FROM person_combine_det pcd
           WHERE pcd.entity_id=pnh.person_name_hist_id
            AND pcd.entity_name="PERSON_NAME_HIST"
            AND pcd.combine_action_cd=dcombine_add_cd))))
         ORDER BY pnh.transaction_dt_tm DESC
         HEAD REPORT
          reply->personlist[y_idx].specimen[lidx1].historical_name = pnh.name_full
         WITH nocounter
        ;end select
      ENDFOR
    ENDFOR
  ENDFOR
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("F","Select person_name_hist",errmsg)
  ENDIF
 ENDIF
 GO TO set_status
 SUBROUTINE (errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = script_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
#set_status
 IF (person_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 FREE SET temp
 IF (log_override_ind=1)
  CALL echo("End bbt_get_avail_flex_specs script")
  CALL log_message("End bbt_get_avail_flex_specs script",log_level_debug)
  CALL echorecord(request)
 ENDIF
END GO
