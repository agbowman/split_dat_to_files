CREATE PROGRAM cds_batch_content:dba
 SET last_mod = "714189"
 SET last_mod = "cds_batch_vars.inc:539853"
 IF (validate(cdsbatchvarsrun) != 0)
  GO TO exit_cds_batch_vars
 ENDIF
 DECLARE cdsbatchvarsrun = i2 WITH public, noconstant(1)
 DECLARE cds_inprogress = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",254591,"INPROCESS"))
 DECLARE cds_complete = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",254591,"COMPLETE"))
 DECLARE ce_slice_type = f8 WITH public, noconstant(uar_get_code_by("MEANING",401571,"CONSULT_EP"))
 DECLARE nhs_trust_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",278,"NHSTRUST"))
 DECLARE nhs_trust_child_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",369,"NHSTRUSTCHLD"
   ))
 DECLARE trust_rel_code = f8 WITH public, noconstant(uar_get_code_by("MEANING",369,"NHSTRUSTCHLD"))
 DECLARE maternity_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"MATERNITY"))
 DECLARE newborn_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"NEWBORN"))
 DECLARE psych_ip_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "PSYCHIATRICINPATIENT"))
 DECLARE reg_day_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "REGULARDAYADMISSION"))
 DECLARE reg_night_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "REGULARNIGHTADMISSION"))
 DECLARE mortuary_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"MORTUARY"))
 DECLARE daycare_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"DAYCARE"))
 DECLARE direct_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"DIRECTREFERRAL"))
 DECLARE ed_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCYDEPARTMENT"))
 DECLARE ip_preadmit_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "INPATIENTPREADMISSION"))
 DECLARE op_prereg_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "OUTPATIENTPREREGISTRATION"))
 DECLARE daycase_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"DAYCASE"))
 DECLARE daycase_wl_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "DAYCASEWAITINGLIST"))
 DECLARE ip_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE ip_wl_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "INPATIENTWAITINGLIST"))
 DECLARE op_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"OUTPATIENT"))
 DECLARE op_referral_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "OUTPATIENTREFERRAL"))
 DECLARE community_ahp_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "COMMUNITYAHP"))
 DECLARE mentalhealth_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "MENTALHEALTH"))
 DECLARE psych_op_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "PSYCHIATRICOUTPATIENT"))
 DECLARE mhinpatient_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"MHINPATIENT")
  )
 DECLARE community_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"COMMUNITY"))
 DECLARE community_ref_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "COMMUNITYREFERRAL"))
 DECLARE waitlist_pwl_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",254636,
   "WAITINGLIST"))
 DECLARE booked_pwl_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",254636,"BOOKED"))
 DECLARE planned_pwl_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",254636,"PLANNED"))
 DECLARE offer_date = q8 WITH public, noconstant(uar_get_code_by("MEANING",356,"OFFERMADEDAT"))
 DECLARE suspend_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",14778,"SUSPEND"))
 DECLARE mgmt_overnight = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",30382,
   "PLANNEDADMISSIONATLEASTONENIGHT"))
 DECLARE mgmt_day = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",30382,
   "NOOVERNIGHTSTAYREQUIRED"))
 DECLARE appt_confirmed = f8 WITH public, noconstant(uar_get_code_by("MEANING",14233,"CONFIRMED"))
 DECLARE appt_hold = f8 WITH public, noconstant(uar_get_code_by("MEANING",14233,"HOLD"))
 DECLARE appt_resched = f8 WITH public, noconstant(uar_get_code_by("MEANING",14233,"RESCHEDULED"))
 DECLARE appt_cancelled = f8 WITH public, noconstant(uar_get_code_by("MEANING",14233,"CANCELLED"))
 IF (appt_cancelled < 1)
  SET appt_cancelled = uar_get_code_by("MEANING",14233,"CANCELED")
 ENDIF
 DECLARE nhs_trace = f8 WITH public, noconstant(uar_get_code_by("MEANING",30700,"NHS_TRACE"))
 DECLARE patient = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",14250,"PATIENT"))
 DECLARE home_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE gp_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE cds_010 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"010"))
 DECLARE cds_011 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"011"))
 DECLARE cds_020 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"020"))
 DECLARE cds_021 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"021"))
 DECLARE cds_030 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"030"))
 DECLARE cds_040 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"040"))
 DECLARE cds_050 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"050"))
 DECLARE cds_060 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"060"))
 DECLARE cds_070 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"070"))
 DECLARE cds_080 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"080"))
 DECLARE cds_090 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"090"))
 DECLARE cds_100 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"100"))
 DECLARE cds_110 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"110"))
 DECLARE cds_120 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"120"))
 DECLARE cds_130 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"130"))
 DECLARE cds_140 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"140"))
 DECLARE cds_150 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"150"))
 DECLARE cds_160 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"160"))
 DECLARE cds_170 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"170"))
 DECLARE cds_180 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"180"))
 DECLARE cds_190 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"190"))
 DECLARE cds_200 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"200"))
 DECLARE cds_210 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"210"))
 DECLARE cds_0201 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"0201"))
 DECLARE cds_310 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"310"))
 DECLARE cds_311 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"311"))
 DECLARE cds_312 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"312"))
 DECLARE cds_313 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"313"))
 DECLARE cds_314 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"314"))
 DECLARE cdspaediatricint_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"CC02A"))
 DECLARE cdspaediatricext_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"CC02B"))
 DECLARE cdsadultint_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"CC03A"))
 DECLARE cdsadultext_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"CC03B"))
 DECLARE cdsneonatalint_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"CC01A"))
 DECLARE cdsneonatalext_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"CC01B"))
 DECLARE cdstype_ae = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001896,"AE"))
 DECLARE cdstype_ecds = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001896,"ECDS"))
 DECLARE cdstype_apc = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001896,"APC"))
 DECLARE cdstype_eal = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001896,"EAL"))
 DECLARE cdstype_opa = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001896,"OPA"))
 DECLARE cdstype_opf = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001896,"OPF"))
 DECLARE cdstype_adc = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001896,"ADC"))
 DECLARE cdstype_csr = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001896,"CSR"))
 DECLARE cdstype_ccc = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001896,"CCC"))
 DECLARE cdstype_cac = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001896,"CAC"))
 DECLARE cdstype_cgs = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001896,"CGS"))
 DECLARE cdstype_cip = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001896,"CIP"))
 DECLARE cbc_cc_alias_type_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001894,"CCMDS")
  )
 DECLARE cbc_cui_alias_type_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001894,"CUI"))
 DECLARE sensitive_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",87,"SENSITIVE"))
 DECLARE trust = f8 WITH public, noconstant(0.0)
 DECLARE resetdate = q8
 DECLARE reset_enddate = q8
 DECLARE outdev = vc
 DECLARE updatestatus = i2 WITH public, noconstant(0)
#exit_cds_batch_vars
 SET last_mod = "202259"
 IF (validate(ukr_common_subroutines) != 0)
  GO TO ukr_common_subroutines_exit
 ENDIF
 DECLARE ukr_common_subroutines = i2 WITH public, constant(1)
 DECLARE columnexists(stable=vc,scolumn=vc) = i4
 DECLARE pm_get_cvo_alias() = c40
 SUBROUTINE (checkdate(s_date_prompt=vc,use_time_ind=i2,end_time_ind=i2) =q8)
   DECLARE d_return_date = q8 WITH private, noconstant(0.0)
   DECLARE i_time = i4 WITH private, noconstant(0)
   SET s_date_prompt = cnvtupper(trim(s_date_prompt,3))
   IF (use_time_ind > 0)
    SET i_time = cnvttime(cnvtdatetime(s_date_prompt))
   ELSE
    IF (end_time_ind > 0)
     SET i_time = 235959
    ENDIF
   ENDIF
   IF (textlen(trim(s_date_prompt,3))=0)
    SET s_date_prompt = "CURDATE"
   ELSEIF (s_date_prompt="*SYSDATE*")
    SET s_date_prompt = replace(s_date_prompt,"SYSDATE","CURDATE",0)
   ENDIF
   IF (s_date_prompt="*CURDATE*")
    SET d_return_date = parser(s_date_prompt)
    SET d_return_date = cnvtdatetime(d_return_date,i_time)
   ELSE
    SET d_return_date = cnvtdatetime(cnvtdate2(s_date_prompt,"DD-MMM-YYYY"),i_time)
   ENDIF
   RETURN(d_return_date)
 END ;Subroutine
 SUBROUTINE (getpromptid(i_prompt_num=i4,i_item_num=i4) =f8)
   DECLARE s_prompt_item = vc WITH private, noconstant("")
   DECLARE d_prompt_id = f8 WITH private, noconstant(0.0)
   DECLARE i_pos = i4 WITH private, noconstant(0)
   SET s_prompt_item = getpromptitem(i_prompt_num,i_item_num)
   IF (textlen(trim(s_prompt_item,3)) > 0)
    SET i_pos = findstring("|",s_prompt_item,1,0)
    IF (i_pos > 0)
     SET d_prompt_id = cnvtreal(substring(1,(i_pos - 1),s_prompt_item))
    ELSE
     SET d_prompt_id = cnvtreal(s_prompt_item)
    ENDIF
   ENDIF
   RETURN(d_prompt_id)
 END ;Subroutine
 SUBROUTINE (getpromptdisp(i_prompt_num=i4,i_item_num=i4) =vc)
   DECLARE s_prompt_item = vc WITH private, noconstant("")
   DECLARE s_prompt_disp = vc WITH private, noconstant("")
   DECLARE i_pos = i4 WITH private, noconstant(0)
   SET s_prompt_item = getpromptitem(i_prompt_num,i_item_num)
   IF (textlen(trim(s_prompt_item,3)) > 0)
    SET i_pos = findstring("|",s_prompt_item,1,0)
    IF (i_pos > 0)
     SET s_prompt_disp = trim(substring((i_pos+ 1),(textlen(s_prompt_item) - i_pos),s_prompt_item),3)
    ENDIF
   ENDIF
   RETURN(s_prompt_disp)
 END ;Subroutine
 SUBROUTINE (getpromptitem(i_prompt_num=i4,i_item_num=i4) =vc)
   DECLARE s_data_type = vc WITH private, noconstant("")
   DECLARE s_prompt_item = vc WITH private, noconstant("")
   IF (i_prompt_num > 0
    AND i_item_num > 0)
    SET s_data_type = reflect(parameter(i_prompt_num,0))
    IF (textlen(trim(s_data_type,3)) > 0)
     IF (substring(1,1,s_data_type)="L")
      SET s_data_type = reflect(parameter(i_prompt_num,i_item_num))
      IF (textlen(trim(s_data_type,3)) > 0)
       SET s_prompt_item = build(parameter(i_prompt_num,i_item_num))
      ENDIF
     ELSE
      IF (i_item_num=1)
       SET s_prompt_item = build(parameter(i_prompt_num,i_item_num))
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(s_prompt_item)
 END ;Subroutine
 SUBROUTINE (checkmrn(s_mrn_num=vc) =vc)
   DECLARE s_mrnstr = vc WITH private, noconstant("")
   DECLARE i_mrnlen = i4 WITH private, noconstant(0)
   DECLARE s_trim_mrn = vc WITH private, noconstant("")
   SET s_mrnstr = trim(s_mrn_num,3)
   SET i_mrnlen = textlen(s_mrnstr)
   SET while_flag = 1
   SET i = 1
   WHILE (i <= i_mrnlen
    AND while_flag=1)
     IF (substring(i,1,s_mrnstr)="0")
      SET s_trim_mrn = replace(s_mrnstr,"0"," ",1)
      SET s_mrnstr = s_trim_mrn
      SET i += 1
     ELSE
      SET while_flag = 0
     ENDIF
   ENDWHILE
   SET s_mrnstr = trim(s_mrnstr,3)
   RETURN(s_mrnstr)
 END ;Subroutine
 SUBROUTINE column_exists(stable,scolumn)
   DECLARE ce_flag = i4
   SET ce_flag = 0
   DECLARE ce_temp = vc WITH noconstant("")
   SET stable = cnvtupper(stable)
   SET scolumn = cnvtupper(scolumn)
   IF (((currev=8
    AND currevminor=2
    AND currevminor2 >= 4) OR (((currev=8
    AND currevminor > 2) OR (currev > 8)) )) )
    SET ce_temp = build('"',stable,".",scolumn,'"')
    SET stat = checkdic(parser(ce_temp),"A",0)
    IF (stat > 0)
     SET ce_flag = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     l.attr_name
     FROM dtableattr a,
      dtableattrl l
     WHERE a.table_name=stable
      AND l.attr_name=scolumn
      AND l.structtype="F"
      AND btest(l.stat,11)=0
     DETAIL
      ce_flag = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(ce_flag)
 END ;Subroutine
#ukr_common_subroutines_exit
 IF (validate(ukr_error_subroutines) != 0)
  GO TO ukr_error_subroutines_exit
 ENDIF
 DECLARE ukr_error_subroutines = i2 WITH public, constant(1)
 DECLARE max_errors = i4 WITH public, constant(25)
 DECLARE failure = c1 WITH public, constant("F")
 DECLARE no_data = c1 WITH public, constant("Z")
 DECLARE warning = c1 WITH public, constant("W")
 DECLARE success = c1 WITH public, constant("S")
 DECLARE partial = c1 WITH public, constant("P")
 DECLARE error_mode = c1 WITH public, constant("E")
 DECLARE reply_mode = c1 WITH public, constant("R")
 DECLARE error_storage_mode = c1 WITH public, noconstant(error_mode)
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE clearerrorstructure() = null
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE msg_default = i4 WITH protect, noconstant(0)
 DECLARE msg_level = i4 WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET msg_default = uar_msgopen("UKDISCERNREPORTING")
 SET msg_level = uar_msggetlevel(msg_default)
 DECLARE iloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE slogtext = vc WITH protect, noconstant("")
 DECLARE slogevent = vc WITH protect, noconstant("")
 DECLARE iholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE info_domain = vc WITH protect, constant("UKDISCERNREPORTING SCRIPT LOGGING")
 DECLARE logging_on = c1 WITH protect, constant("L")
 DECLARE debug_ind = i2 WITH public, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE subeventcnt = i4 WITH protect, noconstant(0)
 DECLARE iloggingstat = i2 WITH protect, noconstant(0)
 DECLARE subeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 FREE RECORD errors
 RECORD errors(
   1 error_ind = i2
   1 error_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ms_err_msg = vc WITH private, noconstant("")
 SET stat = error(ms_err_msg,1)
 FREE SET ms_err_msg
 SUBROUTINE (checkerror(s_status=c1,s_op_name=vc,s_op_status=c1,s_target_obj_name=vc) =i2)
   DECLARE s_err_msg = vc WITH private, noconstant("")
   DECLARE l_err_code = i4 WITH private, noconstant(0)
   DECLARE l_err_cnt = i4 WITH private, noconstant(0)
   SET l_err_code = error(s_err_msg,0)
   WHILE (l_err_code > 0
    AND l_err_cnt < max_errors)
     SET errors->error_ind = 1
     SET l_err_cnt += 1
     CALL adderrormsg(s_status,s_op_name,s_op_status,s_target_obj_name,s_err_msg)
     CALL log_message(s_err_msg,log_level_audit)
     SET l_err_code = error(s_err_msg,0)
   ENDWHILE
   RETURN(errors->error_ind)
 END ;Subroutine
 SUBROUTINE (seterrorstoragemode(s_error_storage_mode=c1) =i2)
  IF (s_error_storage_mode=error_mode)
   SET error_storage_mode = s_error_storage_mode
  ELSEIF (s_error_storage_mode=reply_mode
   AND validate(reply)=1)
   SET error_storage_mode = s_error_storage_mode
   SET reply->status_data.status = failure
  ELSE
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE (adderrormsg(s_status=c1,s_op_name=vc,s_op_status=c1,s_target_obj_name=vc,
  s_target_obj_value=vc) =null)
   SET errors->error_cnt += 1
   SET s_status = cnvtupper(trim(substring(1,1,s_status),3))
   SET s_op_status = cnvtupper(trim(substring(1,1,s_op_status),3))
   IF (error_storage_mode=reply_mode)
    IF ((reply->status_data.status=failure))
     SET errors->error_ind = 1
    ENDIF
    IF (((s_status=failure) OR (s_op_status=failure)) )
     SET msg = concat("SCRIPT FAILURE - ",trim(s_target_obj_value,3))
     CALL echo(msg)
     CALL log_message(msg,log_level_audit)
    ENDIF
    IF (size(reply->status_data.subeventstatus,5) < max_errors)
     SET stat = alter(reply->status_data.subeventstatus,max_errors)
    ENDIF
    IF ((errors->error_cnt <= max_errors))
     SET reply->status_data.subeventstatus[errors->error_cnt].operationname = trim(substring(1,25,
       s_op_name),3)
     SET reply->status_data.subeventstatus[errors->error_cnt].operationstatus = s_op_status
     SET reply->status_data.subeventstatus[errors->error_cnt].targetobjectname = trim(substring(1,25,
       s_target_obj_name),3)
     SET reply->status_data.subeventstatus[errors->error_cnt].targetobjectvalue = trim(
      s_target_obj_value,3)
    ENDIF
   ELSE
    IF (textlen(s_status) > 0
     AND (errors->status_data.status != failure))
     SET errors->status_data.status = s_status
    ENDIF
    IF ((errors->status_data.status=failure))
     SET errors->error_ind = 1
    ENDIF
    IF (((s_status=failure) OR (s_op_status=failure)) )
     SET msg = concat("SCRIPT FAILURE - ",trim(s_target_obj_value,3))
     CALL echo(msg)
     CALL log_message(msg,log_level_audit)
    ENDIF
    IF (size(errors->status_data.subeventstatus,5) < max_errors)
     SET stat = alter(errors->status_data.subeventstatus,max_errors)
    ENDIF
    IF ((errors->error_cnt <= max_errors))
     SET errors->status_data.subeventstatus[errors->error_cnt].operationname = trim(substring(1,25,
       s_op_name),3)
     SET errors->status_data.subeventstatus[errors->error_cnt].operationstatus = s_op_status
     SET errors->status_data.subeventstatus[errors->error_cnt].targetobjectname = trim(substring(1,25,
       s_target_obj_name),3)
     SET errors->status_data.subeventstatus[errors->error_cnt].targetobjectvalue = trim(
      s_target_obj_value,3)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (showerrors(s_output=vc) =null)
  DECLARE s_output_dest = vc WITH protect, noconstant(cnvtupper(trim(s_output,3)))
  IF ((errors->error_cnt > 0))
   IF (error_storage_mode=reply_mode)
    SET stat = alter(reply->status_data.subeventstatus,errors->error_cnt)
    IF (((textlen(s_output_dest)=0) OR (s_output_dest="MINE")) )
     SET s_output_dest = "NOFORMS"
    ENDIF
    IF (s_output_dest="NOFORMS")
     CALL echo("")
    ENDIF
    SELECT INTO value(s_output_dest)
     operation_name = evaluate(d.seq,1,"ERROR LOG",reply->status_data.subeventstatus[(d.seq - 1)].
      operationname), target_object_name = evaluate(d.seq,1,"ERROR LOG",reply->status_data.
      subeventstatus[(d.seq - 1)].targetobjectname), status = evaluate(d.seq,1,reply->status_data.
      status,reply->status_data.subeventstatus[(d.seq - 1)].operationstatus),
     error_message = trim(substring(1,100,evaluate(d.seq,1,concat("SCRIPT ERROR LOG FOR: ",trim(
          curprog,3)),reply->status_data.subeventstatus[(d.seq - 1)].targetobjectvalue)))
     FROM (dummyt d  WITH seq = value((errors->error_cnt+ 1)))
     PLAN (d)
     WITH nocounter, format, separator = " "
    ;end select
   ELSE
    SET stat = alter(errors->status_data.subeventstatus,errors->error_cnt)
    IF (((textlen(s_output_dest)=0) OR (s_output_dest="MINE")) )
     SET s_output_dest = "NOFORMS"
    ENDIF
    IF (s_output_dest="NOFORMS")
     CALL echo("")
    ENDIF
    SELECT INTO value(s_output_dest)
     operation_name = evaluate(d.seq,1,"ERROR LOG",errors->status_data.subeventstatus[(d.seq - 1)].
      operationname), target_object_name = evaluate(d.seq,1,"ERROR LOG",errors->status_data.
      subeventstatus[(d.seq - 1)].targetobjectname), status = evaluate(d.seq,1,errors->status_data.
      status,errors->status_data.subeventstatus[(d.seq - 1)].operationstatus),
     error_message = trim(substring(1,100,evaluate(d.seq,1,concat("SCRIPT ERROR LOG FOR: ",trim(
          curprog,3)),errors->status_data.subeventstatus[(d.seq - 1)].targetobjectvalue)))
     FROM (dummyt d  WITH seq = value((errors->error_cnt+ 1)))
     PLAN (d)
     WITH nocounter, format, separator = " "
    ;end select
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE checkstatusblock(i_expected_cnt,i_results_cnt)
  IF ((errors->error_ind=1))
   CALL checkerror(failure,"CCL_ERROR",failure,"FINAL ERROR CHECK")
  ENDIF
  IF ((errors->error_ind=1))
   SET reply->status_data.status = failure
  ELSE
   CASE (i_results_cnt)
    OF i_expected_cnt:
     SET reply->status_data.status = success
    OF 0:
     SET reply->status_data.status = no_data
    ELSE
     SET reply->status_data.status = partial
   ENDCASE
  ENDIF
 END ;Subroutine
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET iloglvloverrideind = 0
   SET slogtext = ""
   SET slogevent = ""
   SET slogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET iholdloglevel = loglvl
   ELSE
    IF (msg_level < loglvl)
     SET iholdloglevel = msg_level
     SET iloglvloverrideind = 1
    ELSE
     SET iholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (iloglvloverrideind=1)
    SET slogevent = "Script_Override"
   ELSE
    CASE (iholdloglevel)
     OF log_level_error:
      SET slogevent = "Script_Error"
     OF log_level_warning:
      SET slogevent = "Script_Warning"
     OF log_level_audit:
      SET slogevent = "Script_Audit"
     OF log_level_info:
      SET slogevent = "Script_Info"
     OF log_level_debug:
      SET slogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(msg_default,0,nullterm(slogevent),iholdloglevel,nullterm(
     slogtext))
   IF (debug_ind=1)
    CALL echo(logmsg)
   ENDIF
 END ;Subroutine
 SUBROUTINE clearerrorstructure(null)
   SET errors->error_ind = 0
   SET errors->error_cnt = 0
   SET errors->status_data.status = ""
   SET errors->status_data.subeventstatus[1].operationname = ""
   SET errors->status_data.subeventstatus[1].operationstatus = ""
   SET errors->status_data.subeventstatus[1].targetobjectname = ""
   SET errors->status_data.subeventstatus[1].targetobjectvalue = ""
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logname=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL adderrormsg(failure,opname,failure,"CCL ERROR",serrmsg)
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
    CALL populate_subeventstatus(opname,"Z","No records qualified",logname)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET subeventcnt = size(reply->status_data.subeventstatus,5)
    SET subeventsize = size(trim(reply->status_data.subeventstatus[subeventcnt].operationname))
    SET subeventsize += size(trim(reply->status_data.subeventstatus[subeventcnt].operationstatus))
    SET subeventsize += size(trim(reply->status_data.subeventstatus[subeventcnt].targetobjectname))
    SET subeventsize += size(trim(reply->status_data.subeventstatus[subeventcnt].targetobjectvalue))
    IF (subeventsize > 0)
     SET subeventcnt += 1
     SET iloggingstat = alter(reply->status_data.subeventstatus,subeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[subeventcnt].operationname = substring(1,25,operationname)
    SET reply->status_data.subeventstatus[subeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[subeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[subeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (validationfailuremsg(s_output=vc,logmsg=vc,loglvl=vc) =null)
   CALL log_message(logmsg,loglvl)
   DECLARE s_output_dest = vc WITH protect, noconstant(cnvtupper(trim(s_output,3)))
   IF (((textlen(s_output_dest)=0) OR (s_output_dest="MINE")) )
    SET s_output_dest = "NOFORMS"
   ENDIF
   SELECT INTO value(s_output_dest)
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    DETAIL
     row + 1, logmsg
    WITH nocounter, format, separator = " ",
     maxcol = 200
   ;end select
   GO TO exit_script
 END ;Subroutine
#ukr_error_subroutines_exit
 SET last_mod = "ukr_pref_access_sub:645195"
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
 DECLARE i18n_handle = i4 WITH noconstant(0), protected
 SET stat = uar_i18nlocalizationinit(i18n_handle,curprog,"",curcclrev)
 EXECUTE prefrtl
 DECLARE c_pai_err_1_operation = vc WITH constant(uar_i18ngetmessage(i18n_handle,
   "c_pai_err_1_operation","PrefAcc_Initialise()")), protected
 DECLARE c_pai_err_1_target = vc WITH constant(uar_i18ngetmessage(i18n_handle,"c_pai_err_1_target",
   "Initialisation_Failure")), protected
 DECLARE c_pai_err_1_message = vc WITH constant(uar_i18ngetmessage(i18n_handle,"c_pai_err_1_message",
   build2("Unable to complete Initialisation due to failure in","uar_PrefPerform() API"))), protected
 DECLARE c_paar_err_1_operation = vc WITH constant(uar_i18ngetmessage(i18n_handle,
   "c_paar_err_1_operation","PrefAcc_AddReport()")), protected
 DECLARE c_paar_err_1_target = vc WITH constant(uar_i18ngetmessage(i18n_handle,"c_paar_err_1_target",
   "Invalid_State")), protected
 DECLARE c_paar_err_1_message = vc WITH constant(uar_i18ngetmessage(i18n_handle,
   "c_paar_err_1_message",build2("This function cannot be called without a successfull",
    "call to PrefAcc_Initialise()"))), protected
 DECLARE c_paar_err_2_operation = vc WITH constant(uar_i18ngetmessage(i18n_handle,
   "c_paar_err_2_operation","PrefAcc_AddReport()")), protected
 DECLARE c_paar_err_2_target = vc WITH constant(uar_i18ngetmessage(i18n_handle,"c_paar_err_2_target",
   "Report_Not_Found")), protected
 DECLARE c_paar_err_2_message = vc WITH constant(uar_i18ngetmessage(i18n_handle,
   "c_paar_err_2_message","The specified report could not be found")), protected
 DECLARE c_paar_err_3_operation = vc WITH constant(uar_i18ngetmessage(i18n_handle,
   "c_paar_err_3_operation","PrefAcc_AddReport()")), protected
 DECLARE c_paar_err_3_target = vc WITH constant(uar_i18ngetmessage(i18n_handle,"c_paar_err_3_target",
   "No_Data")), protected
 DECLARE c_paar_err_3_message = vc WITH constant(uar_i18ngetmessage(i18n_handle,
   "c_paar_err_3_message","No prefrences were found for the specified report")), protected
 DECLARE c_pagv_err_1_operation = vc WITH constant(uar_i18ngetmessage(i18n_handle,
   "c_pagv_err_1_operation","PrefAcc_GetValue()")), protected
 DECLARE c_pagv_err_1_target = vc WITH constant(uar_i18ngetmessage(i18n_handle,"c_pagv_err_1_target",
   "Invalid_State")), protected
 DECLARE c_pagv_err_1_message = vc WITH constant(uar_i18ngetmessage(i18n_handle,
   "c_pagv_err_1_message","The specified report could not be found")), protected
 DECLARE c_pagv_err_2_operation = vc WITH constant(uar_i18ngetmessage(i18n_handle,
   "c_pagv_err_2_operation","PrefAcc_GetValue()")), protected
 DECLARE c_pagv_err_2_target = vc WITH constant(uar_i18ngetmessage(i18n_handle,"c_pagv_err_2_target",
   "Report_Not_Found")), protected
 DECLARE c_pagv_err_2_message = vc WITH constant(uar_i18ngetmessage(i18n_handle,
   "c_pagv_err_2_message","The specified report could not be found")), protected
 DECLARE c_pagv_err_3_operation = vc WITH constant(uar_i18ngetmessage(i18n_handle,
   "c_pagv_err_3_operation","PrefAcc_GetValue()")), protected
 DECLARE c_pagv_err_3_target = vc WITH constant(uar_i18ngetmessage(i18n_handle,"c_pagv_err_3_target",
   "No_Data")), protected
 DECLARE c_pagv_err_3_message = vc WITH constant(uar_i18ngetmessage(i18n_handle,
   "c_pagv_err_3_message","Specified prefrence was not found")), protected
 DECLARE c_function_fail = i4 WITH constant(0), protected
 DECLARE c_function_success = i4 WITH constant(1), protected
 DECLARE g_rps_initialised = i4 WITH noconstant(0), protected
 DECLARE g_handle_pref = i4 WITH noconstant(0), protected
 DECLARE g_handle_pgroup = i4 WITH noconstant(0), protected
 DECLARE g_handle_section = i4 WITH noconstant(0), protected
 DECLARE g_subgroup_cnt = i4 WITH noconstant(0), protected
 FREE RECORD rec_prefstore
 RECORD rec_prefstore(
   1 counters
     2 report_list_cnt = i4
     2 max_report_pref_list_cnt = i4
   1 report_list[*]
     2 report_name = vc
     2 report_pref_list_cnt = i4
     2 report_pref_list[*]
       3 pref_name = vc
       3 pref_value = vc
 )
 DECLARE prefacc_initialise(null) = i4
 DECLARE prefacc_destroy() = i4
 SUBROUTINE (extractpreferences(handle_group=i4) =i4)
   DECLARE entry_cnt = i4 WITH noconstant(0)
   DECLARE rpt_count = i4 WITH noconstant(1)
   DECLARE name = c255 WITH noconstant("")
   DECLARE entry_name = c255 WITH noconstant("")
   DECLARE pref_value = c255 WITH noconstant("")
   SET stat = uar_prefgetgroupentrycount(handle_group,entry_cnt)
   IF ((rec_prefstore->counters.report_list_cnt=0))
    SET rec_prefstore->counters.report_list_cnt = 1
    SET stat = alterlist(rec_prefstore->report_list,1)
    SET rec_prefstore->report_list[rpt_count].report_name = "global"
    IF (entry_cnt=0)
     RETURN(0)
    ENDIF
   ELSE
    IF (entry_cnt=0)
     RETURN(0)
    ENDIF
    SET rec_prefstore->counters.report_list_cnt += 1
    SET rpt_count = rec_prefstore->counters.report_list_cnt
    SET stat = alterlist(rec_prefstore->report_list,rpt_count)
    SET str_len = 255
    SET stat = uar_prefgetgroupname(handle_group,name,str_len)
    SET rec_prefstore->report_list[rpt_count].report_name = cnvtlower(trim(name,3))
   ENDIF
   SET rec_prefstore->report_list[rpt_count].report_pref_list_cnt = entry_cnt
   SET stat = alterlist(rec_prefstore->report_list[rpt_count].report_pref_list,entry_cnt)
   IF ((entry_cnt > rec_prefstore->counters.max_report_pref_list_cnt))
    SET rec_prefstore->counters.max_report_pref_list_cnt = entry_cnt
   ENDIF
   FOR (entry_index = 0 TO (entry_cnt - 1))
     SET entry_name = ""
     SET str_len = 255
     SET attrib_cnt = 0
     SET handle_entry = uar_prefgetgroupentry(handle_group,entry_index)
     SET stat = uar_prefgetentryname(handle_entry,entry_name,str_len)
     SET stat = uar_prefgetentryattrcount(handle_entry,attrib_cnt)
     FOR (attrib_index = 0 TO (attrib_cnt - 1))
       SET name = ""
       SET str_len = 255
       SET handle_attrib = uar_prefgetentryattr(handle_entry,attrib_index)
       SET stat = uar_prefgetattrname(handle_attrib,name,str_len)
       IF (cnvtlower(trim(name,3))="prefvalue")
        SET pref_value = ""
        SET str_len = 255
        SET stat = uar_prefgetattrval(handle_attrib,pref_value,str_len,0)
        SET rec_prefstore->report_list[rpt_count].report_pref_list[(entry_index+ 1)].pref_name =
        cnvtlower(trim(entry_name,3))
        SET rec_prefstore->report_list[rpt_count].report_pref_list[(entry_index+ 1)].pref_value =
        pref_value
       ENDIF
       CALL uar_prefdestroyattr(handle_attrib)
     ENDFOR
     CALL uar_prefdestroyentry(handle_entry)
   ENDFOR
   RETURN(entry_cnt)
 END ;Subroutine
 SUBROUTINE prefacc_initialise(null)
  IF (g_rps_initialised=0)
   SET g_handle_pref = uar_prefcreateinstance(0)
   SET stat = uar_prefaddcontext(g_handle_pref,"default","system")
   SET stat = uar_prefsetsection(g_handle_pref,"application")
   SET g_handle_pgroup = uar_prefcreategroup()
   SET stat = uar_prefsetgroupname(g_handle_pgroup,"discern reporting")
   SET stat = uar_prefaddgroup(g_handle_pref,g_handle_pgroup)
   CALL uar_prefdestroygroup(g_handle_pgroup)
   SET stat = uar_prefperform(g_handle_pref)
   IF (stat != 0)
    SET g_handle_section = uar_prefgetsectionbyname(g_handle_pref,"application")
    SET g_handle_pgroup = uar_prefgetgroupbyname(g_handle_section,"discern reporting")
    SET stat = uar_prefgetsubgroupcount(g_handle_pgroup,g_subgroup_cnt)
    SET stat = extractpreferences(g_handle_pgroup)
    SET g_rps_initialised = 1
   ELSE
    CALL uar_prefdestroyinstance(g_handle_pref)
    CALL adderrormsg(failure,c_pai_err_1_operation,failure,c_pai_err_1_target,c_pai_err_1_message)
    RETURN(c_function_fail)
   ENDIF
  ENDIF
  RETURN(c_function_success)
 END ;Subroutine
 SUBROUTINE prefacc_destroy(null)
  IF (g_rps_initialised=1)
   FOR (rpt_index = 1 TO rec_prefstore->counters.report_list_cnt)
     SET stat = alterlist(rec_prefstore->report_list[rpt_index].report_pref_list,0)
   ENDFOR
   SET stat = alterlist(rec_prefstore->report_list,0)
   SET rec_prefstore->counters.report_list_cnt = 0
   SET rec_prefstore->counters.max_report_pref_list_cnt = 0
   CALL uar_prefdestroygroup(g_handle_pgroup)
   CALL uar_prefdestroysection(g_handle_section)
   CALL uar_prefdestroyinstance(g_handle_pref)
   SET g_rps_initialised = 0
   SET g_subgroup_cnt = 0
  ENDIF
  RETURN(c_function_success)
 END ;Subroutine
 SUBROUTINE (prefacc_addreport(report_name=vc,report_index=i4(ref)) =i4)
   SET report_index = 0
   IF (g_rps_initialised=1)
    DECLARE sgroup_name = c255 WITH noconstant("")
    SET sgroup_index = 0
    SET sgroup_found = 0
    SET handle_sgroup = 0
    SET report_name = cnvtlower(trim(report_name,3))
    WHILE (sgroup_index < g_subgroup_cnt
     AND sgroup_found=0)
      SET handle_sgroup = uar_prefgetsubgroup(g_handle_pgroup,sgroup_index)
      SET sgroup_name = ""
      SET str_len = 255
      SET stat = uar_prefgetgroupname(handle_sgroup,sgroup_name,str_len)
      IF (cnvtlower(trim(sgroup_name,3))=report_name)
       SET sgroup_found = 1
      ELSE
       CALL uar_prefdestroygroup(handle_sgroup)
       SET sgroup_index += 1
      ENDIF
    ENDWHILE
    IF (sgroup_found=1)
     SET stat = extractpreferences(handle_sgroup)
     CALL uar_prefdestroygroup(handle_sgroup)
     IF (stat > 0)
      SET report_index = rec_prefstore->counters.report_list_cnt
      RETURN(c_function_success)
     ELSE
      CALL adderrormsg(failure,c_paar_err_3_operation,failure,c_paar_err_3_target,
       c_paar_err_3_message)
     ENDIF
    ELSE
     CALL adderrormsg(failure,c_paar_err_2_operation,failure,c_paar_err_2_target,c_paar_err_2_message
      )
    ENDIF
   ELSE
    CALL adderrormsg(failure,c_paar_err_1_operation,failure,c_paar_err_1_target,c_paar_err_1_message)
   ENDIF
   RETURN(c_function_fail)
 END ;Subroutine
 SUBROUTINE (prefacc_getvalue(report_index=i4,pref_name=vc,pref_value=vc(ref),opt=i2(value,0)) =i4)
   SET pref_value = ""
   IF (g_rps_initialised=1)
    IF (report_index >= 1
     AND (report_index <= rec_prefstore->counters.report_list_cnt))
     SET pref_index = 1
     SET pref_found = 0
     SET pref_name = cnvtlower(trim(pref_name,3))
     WHILE ((pref_index <= rec_prefstore->report_list[report_index].report_pref_list_cnt)
      AND pref_found=0)
       IF ((rec_prefstore->report_list[report_index].report_pref_list[pref_index].pref_name=pref_name
       ))
        SET pref_found = 1
       ELSE
        SET pref_index += 1
       ENDIF
     ENDWHILE
     IF (pref_found=1)
      SET pref_value = rec_prefstore->report_list[report_index].report_pref_list[pref_index].
      pref_value
      RETURN(c_function_success)
     ELSE
      IF (opt=0)
       CALL adderrormsg(failure,c_pagv_err_3_operation,failure,c_pagv_err_3_target,
        c_pagv_err_3_message)
      ENDIF
     ENDIF
    ELSE
     CALL adderrormsg(failure,c_pagv_err_2_operation,failure,c_pagv_err_2_target,c_pagv_err_2_message
      )
    ENDIF
   ELSE
    CALL adderrormsg(failure,c_pagv_err_1_operation,failure,c_pagv_err_1_target,c_pagv_err_1_message)
   ENDIF
   RETURN(c_function_fail)
 END ;Subroutine
 SET last_mod = "472263"
 IF (validate(ukr_4001902_sub_ind) != 1)
  DECLARE ukr_4001902_sub_ind = i2 WITH public, constant(1)
  SUBROUTINE (getoption1fieldvalue(cdf_meaning=vc) =vc)
    DECLARE option1_value = vc WITH noconstant("")
    SELECT INTO "nl:"
     FROM code_value cv,
      code_value_extension cve
     PLAN (cv
      WHERE cv.code_set=4001902
       AND cv.cdf_meaning=cdf_meaning
       AND cv.active_ind=1)
      JOIN (cve
      WHERE (cve.code_value= Outerjoin(cv.code_value))
       AND (cve.field_name= Outerjoin("OPTION1"))
       AND (cve.code_set= Outerjoin(4001902)) )
     HEAD REPORT
      option1_value = cve.field_value
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM code_value cv,
       code_value_extension cve
      PLAN (cv
       WHERE cv.code_set=104400
        AND cv.cdf_meaning=cdf_meaning
        AND cv.active_ind=1)
       JOIN (cve
       WHERE cve.code_value=cv.code_value
        AND cve.field_name="OPTION1"
        AND cve.code_set=104400)
      HEAD REPORT
       option1_value = cve.field_value
      WITH nocounter
     ;end select
    ENDIF
    RETURN(option1_value)
  END ;Subroutine
  SUBROUTINE (getreportingconfigcv(cdf_meaning=vc) =f8)
    DECLARE return_cv = f8 WITH noconstant(uar_get_code_by("MEANING",4001902,nullterm(cdf_meaning)))
    IF (return_cv <= 0)
     SET return_cv = uar_get_code_by("MEANING",104400,nullterm(cdf_meaning))
    ENDIF
    RETURN(return_cv)
  END ;Subroutine
 ENDIF
 IF (validate(inprogress_ind)=0)
  DECLARE inprogress_ind = i4 WITH public, noconstant(0)
 ENDIF
 SELECT INTO "nl:"
  FROM cds_batch cb
  WHERE cb.cds_batch_id=0
   AND cb.cds_batch_status_cd=cds_inprogress
   AND cb.updt_dt_tm > cnvtdatetime((curdate - 3),curtime3)
  DETAIL
   inprogress_ind = 1
  WITH nocounter
 ;end select
 DECLARE update_dt_tm = dq8 WITH public, constant(cnvtdatetime(sysdate))
 DECLARE stemp = vc WITH protect, noconstant("")
 IF (inprogress_ind=1)
  GO TO exit_script
 ELSE
  CALL updatezerorowbatchstatus(cds_inprogress)
 ENDIF
 DECLARE create_dt_tm = dq8 WITH public, constant(cnvtdatetime(sysdate))
 DECLARE null_dt_tm = dq8 WITH public, constant(cnvtdatetime("31-DEC-2100"))
 DECLARE start = i4 WITH protect, noconstant(1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE latestencntrselect = vc WITH protect, noconstant("")
 DECLARE testpatientexcclause = vc WITH protect, noconstant("")
 DECLARE eorgclause = vc WITH protect, noconstant("")
 DECLARE cbcorgclauseojoin = vc WITH protect, noconstant("")
 DECLARE cbcorgclauseojoin2 = vc WITH protect, noconstant("")
 DECLARE cbcorgclause = vc WITH protect, noconstant("")
 DECLARE begdateclause = vc WITH protect, noconstant("")
 DECLARE temp_parser = vc WITH protect, noconstant("")
 DECLARE tmp_activity_dt_tm = dq8 WITH protect, noconstant(0.0)
 DECLARE encntrslicestring = c12 WITH protect, constant("ENCNTR_SLICE")
 DECLARE schschedulestring = c12 WITH protect, constant("SCH_SCHEDULE")
 DECLARE patientstring = c7 WITH protect, constant("PATIENT")
 DECLARE pmwaitliststring = c12 WITH protect, constant("PM_WAIT_LIST")
 DECLARE clineventstring = c14 WITH protect, constant("CLINICAL_EVENT")
 DECLARE episodeactivitystring = c16 WITH protect, constant("EPISODE_ACTIVITY")
 DECLARE encountercrstring = c12 WITH protect, constant("ENCOUNTER_CR")
 DECLARE d_appt_dt_tm = dq8 WITH public, constant(cnvtdatetime("31-DEC-2999"))
 DECLARE tmp_batch_content_id = f8 WITH protect, noconstant(0.0)
 DECLARE tmp_batch_id = f8 WITH protect, noconstant(0.0)
 DECLARE tmp_error_ind = i2 WITH protect, noconstant(0)
 DECLARE tmp_perm_del_ind = i2 WITH protect, noconstant(0)
 DECLARE tmp_fs_ident = vc WITH protect, noconstant("")
 DECLARE tmp_fs_name = vc WITH protect, noconstant("")
 DECLARE tmp_suppress_ind = i2 WITH protect, noconstant(0)
 DECLARE undocancel = c12 WITH public, constant("UNDOCANCEL")
 DECLARE undonoshow = c12 WITH public, constant("UNDONOSHOW")
 DECLARE undocheckin = c12 WITH public, constant("UNDOCHECKIN")
 DECLARE shuffle = c12 WITH public, constant("SHUFFLE")
 DECLARE cancel = c12 WITH public, constant("CANCEL")
 DECLARE reschedule = c12 WITH public, constant("RESCHEDULE")
 DECLARE systemcancel = c12 WITH public, constant("SYSTEMCANCEL")
 DECLARE automodify = c12 WITH public, constant("AUTOMODIFY")
 DECLARE modifyorder = c12 WITH public, constant("MODIFYORDER")
 DECLARE adminerror = c12 WITH public, constant("ADMINERROR")
 DECLARE modify = c12 WITH public, constant("MODIFY")
 DECLARE admin_error = c12 WITH public, constant("ADMIN_ERROR")
 DECLARE swapres = c12 WITH public, constant("SWAPRES")
 DECLARE pmwaitliststatusstring = vc WITH protect, constant("PM_WAIT_LIST_STATUS")
 DECLARE activeindstring = vc WITH protect, constant("ACTIVE_IND")
 DECLARE encounterstring = c9 WITH protect, constant("ENCOUNTER")
 DECLARE p_cnt = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, noconstant(0)
 DECLARE new_batch_size = i4 WITH protect, noconstant(0)
 DECLARE iidx = i4 WITH protect, noconstant(0)
 DECLARE iprogcbc_flag = i4 WITH public, noconstant(1)
 DECLARE initial_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",14230,
   "INITIALREGULARADMISSION"))
 DECLARE subsequent_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",14230,
   "SUBSEQUENTREGULARADMISSION"))
 DECLARE com_field_value_s = vc WITH public, noconstant("")
 SET com_field_value_s = getoption1fieldvalue("COMCDSOPTION")
 DECLARE com_field_value = i4 WITH public, constant(cnvtint(com_field_value_s))
 DECLARE comn_cont_type_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "COMMUNITYCONTACTTYPE"))
 DECLARE comn_cont_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"COMMUNITYCONTACT"))
 DECLARE comn_indrct_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "INDIRECTPATIENTACTIVITYCODE"))
 DECLARE group_pat_nonp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",16127,
   "GROUPSESSIONNONPATIENT"))
 DECLARE contact_st_dt_tm_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "COMMUNITYADHOCCONTACTSTARTDATETIME"))
 DECLARE app_beg_dt_tm_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "APPOINTMENTBEGDATECOMM"))
 DECLARE auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE inerror_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE dfa_rtt_form_desc = vc WITH public, constant("Referral to Treatment Status")
 DECLARE rtt_status_form_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "REFERRALTOTREATMENTSTATUS"))
 DECLARE dcp_gen_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"DCPGENERICCODE"))
 DECLARE rtt_activity_dt_ce_code = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "RTTSTATUSACTIVITYDATE"))
 DECLARE abs_valid_until_dt_tm = vc WITH public, noconstant("31-DEC-2100")
 DECLARE ep_act_admin_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,
   "ADMINEVENT"))
 DECLARE ep_act_pm_admin_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,
   "ADMINEVENTPM"))
 DECLARE deceased_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,"DECEASED"))
 DECLARE stop_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002289,"STOP"))
 DECLARE inp_wl_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,"ADDIWL"))
 DECLARE cnc_appt_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,"CANCELOP"))
 DECLARE cnc_tci_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,"CANCELIP"))
 DECLARE chk_out_appt_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,
   "CHECKOUTOP"))
 DECLARE cab_op_appt_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,
   "CONFIRMOPCAB"))
 DECLARE cnf_op_appt_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,"CONFIRMOP"
   ))
 DECLARE cnf_tci_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,"CONFIRMIP"))
 DECLARE dna_op_appt_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,"NOSHOWOP")
  )
 DECLARE dna_tci_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,"NOSHOWIP"))
 DECLARE disch_in_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,"DISCHARGEIP")
  )
 DECLARE rsch_op_appt_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,
   "RESCHEDULEOP"))
 DECLARE ip_addm_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,"IPADM"))
 DECLARE op_ref_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,"OPREFERRAL"))
 DECLARE rsch_in_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,"RESCHEDULEIP")
  )
 DECLARE comm_rf_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,"COMMREFERRAL"))
 DECLARE rej_comm_rf_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,"REJCOMMRF"))
 DECLARE cancel_comm_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,"CANCELCOMM"))
 DECLARE chk_out_comm_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,"CHECKOUTCOMM")
  )
 DECLARE confirm_comm_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,"CONFIRMCOMM"))
 DECLARE no_show_comm_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,"NOSHOWCOMM"))
 DECLARE rsch_comm_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,"RESCHDCOMM"))
 DECLARE wl_remove_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4002189,"WLREMOVE"))
 DECLARE offer_auto_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002343,"AUTO"))
 DECLARE act_type_size = i4 WITH public, constant(24)
 DECLARE discernruleorder_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,
   "DISCERNRULEORDER"))
 DECLARE laboratory_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"LABORATORY"))
 DECLARE radiology_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"RADIOLOGY"))
 DECLARE surgery_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"SURGERY"))
 DECLARE cdsretrig_cd = f8 WITH public, constant(uar_get_code_by("MEANING",207902,"CDSRETRIG"))
 DECLARE view_cd = f8 WITH public, constant(uar_get_code_by("MEANING",14232,"VIEW"))
 DECLARE request_cd = f8 WITH public, constant(uar_get_code_by("MEANING",14232,"REQUEST"))
 DECLARE diagapptexcl_cd = f8 WITH public, noconstant(0.0)
 SET diagapptexcl_cd = getreportingconfigcv("DIAGAPPTEXCL")
 DECLARE ae_attend_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJAEA"))
 DECLARE ae_track_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJAET"))
 DECLARE f_ge_sl_ch_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJFGESC"))
 DECLARE f_ge_sl_act_ch_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJFGESAC"
   ))
 DECLARE f_ge_encntr_ch_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJFGEEC")
  )
 DECLARE f_ge_coding_updt_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,
   "CBCOJFGECC"))
 DECLARE f_ge_ccc_updt_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJFGECCC")
  )
 DECLARE f_ge_ae_undo_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJFGEDAE"))
 DECLARE cons_op_f_appt_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJOPFA"))
 DECLARE res_missing_op_ref1_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,
   "CBCOJRESOR1"))
 DECLARE res_missing_op_ref2_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,
   "CBCOJRESOR2"))
 DECLARE cons_op_a_appt_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJOPAA"))
 DECLARE cons_op_ref_only_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,
   "CBCOJOPREF"))
 DECLARE eal_add_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJEALA"))
 DECLARE eal_add_rem_same_day_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,
   "CBCOJEALAR"))
 DECLARE eal_rem_adm_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJEALRDTA"))
 DECLARE eal_rem_cancel_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,
   "CBCOJEALRDTC"))
 DECLARE eal_reinst_del_rem_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,
   "CBCOJEALRDR"))
 DECLARE eal_offer_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJEALO"))
 DECLARE eal_susp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJEALS"))
 DECLARE eal_retrig_act_aoo_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,
   "CBCOJEALAOO"))
 DECLARE eal_retrig_act_offer_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,
   "CBCOJEALOF"))
 DECLARE eal_retrig_act_erod_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,
   "CBCOJEALEROD"))
 DECLARE eal_retrig_tci_pass_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,
   "CBCOJEALTCIP"))
 DECLARE admin_ce_epa_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJAECEEPA")
  )
 DECLARE admin_gen_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJAEG"))
 DECLARE admin_dec_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJAERUD"))
 DECLARE admin_ce_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJAECER"))
 DECLARE retrig_rtt_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJPASRTT"))
 DECLARE comm_serv_ref_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJCSRA"))
 DECLARE comm_care_cont_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJCCRA"))
 DECLARE comm_adhoc_care_cont_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,
   "CBCOJACCA"))
 DECLARE comm_group_ses_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJGSA"))
 DECLARE comm_ind_acc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJIPAA"))
 DECLARE comm_sch_perm_rem_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,
   "CBCOJCSPR"))
 DECLARE ip_sch_perm_rem_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJISPR")
  )
 DECLARE op_sch_perm_rem_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJOSPR")
  )
 DECLARE rem_zzz_pat_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJRZZZ"))
 DECLARE g_enc_updt_retr_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJGUE"))
 DECLARE g_cod_updt_retr_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJGUC"))
 DECLARE g_wl_updt_retr = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJGUWL"))
 DECLARE g_epi_enc_reltn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJGUEP")
  )
 DECLARE g_ord_retr_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJGUO"))
 DECLARE g_diag_retr_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJGUD"))
 DECLARE g_proc_retr_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,"CBCOJGUP"))
 DECLARE g_proc_retr_updt_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001895,
   "CBCOJEALPUP"))
 DECLARE dis_rd_att_fv = vc WITH public, noconstant("")
 SET dis_rd_att_fv = getoption1fieldvalue("CDSDISREGDAY")
 SET dis_rd_att_fv = trim(cnvtupper(dis_rd_att_fv),3)
 DECLARE cdsdiagoverride_flag = vc WITH public, noconstant("")
 SET cdsdiagoverride_flag = getoption1fieldvalue("CDSOPDIAGIND")
 SET cdsdiagoverride_flag = trim(cnvtupper(cdsdiagoverride_flag),3)
 DECLARE rttretswitch_s = vc WITH public, noconstant("")
 SET rttretswitch_s = getoption1fieldvalue("CDSRTTRETOF")
 SET rttretswitch_s = trim(cnvtupper(rttretswitch_s),3)
 IF (validate(ecds_switch)=0)
  DECLARE ecds_switch = i2 WITH public, noconstant(0)
  SET ecds_switch = cnvtint(getoption1fieldvalue("ECDSSWITCH"))
  IF ( NOT (ecds_switch IN (0, 1, 2)))
   SET ecds_switch = 0
  ENDIF
 ENDIF
 DECLARE cds_xml = i2 WITH public, noconstant(0)
 IF (validate(cdsbatch))
  IF ((cdsbatch->version.major=6)
   AND (cdsbatch->version.minor=1))
   SET ecds_switch = 0
  ENDIF
  IF ((cdsbatch->version.major=6)
   AND (cdsbatch->version.minor=2)
   AND ecds_switch=0
   AND locateval(prompt_num,1,cds_prompt_type->type_cnt,uar_get_code_by("MEANING",4001896,"ECDS"),
   cds_prompt_type->type[prompt_num].value_cd)
   AND  NOT (locateval(prompt_num,1,cds_prompt_type->type_cnt,uar_get_code_by("MEANING",4001896,"AE"),
   cds_prompt_type->type[prompt_num].value_cd)))
   SET ecds_switch = 1
  ENDIF
  IF ((cdsbatch->version.major=6)
   AND (cdsbatch->version.minor >= 3))
   SET cds_xml = 1
  ENDIF
 ENDIF
 DECLARE rtt_parser = vc WITH public, noconstant("")
 DECLARE rtt_switch_start = dq8 WITH public, noconstant(0.0)
 DECLARE rtt_switch_end = dq8 WITH public, noconstant(0.0)
 SET idx = findstring("TO",cnvtupper(rttretswitch_s))
 IF (idx > 0)
  SET rtt_switch_start = cnvtdatetime(cnvtdate2(trim(substring(1,(idx - 2),rttretswitch_s),3),
    "DD-MMM-YYYY"),0)
  SET rtt_switch_end = cnvtdatetime(cnvtdate2(trim(substring((idx+ 3),textlen(rttretswitch_s),
      rttretswitch_s),3),"DD-MMM-YYYY"),235959)
  IF (rtt_switch_start > 0.0
   AND rtt_switch_end > 0.0
   AND rtt_switch_start < rtt_switch_end)
   SET rtt_parser = build2(
    "(epa.updt_dt_tm between cnvtdatetime(resetDate) and cnvtdatetime(reset_endDate)) ",
    "and (epa.updt_dt_tm not between cnvtdatetime(rtt_switch_start) and cnvtdatetime(rtt_switch_end))"
    )
  ELSE
   CALL adderrormsg(failure,"VALIDATE",failure,"PREFERENCE",
    "RTT retrigger Switch not configured properly")
   GO TO exit_script
  ENDIF
 ELSEIF (cnvtdatetime(rttretswitch_s) > 0.0)
  SET rtt_switch_start = cnvtdatetime(cnvtdate2(trim(rttretswitch_s,3),"DD-MMM-YYYY"),0)
  SET rtt_parser = "epa.updt_dt_tm >= cnvtdatetime(resetDate) "
  SET rtt_parser = build2(rtt_parser,
   " and epa.updt_dt_tm < cnvtdatetime(minval(rtt_switch_start,reset_endDate))")
 ELSEIF (textlen(trim(rttretswitch_s,3)) > 0)
  CALL adderrormsg(failure,"VALIDATE",failure,"PREFERENCE",
   "RTT retrigger Switch not configured properly")
  GO TO exit_script
 ELSE
  SET rtt_parser =
  "epa.updt_dt_tm >= cnvtdatetime(resetDate) and epa.updt_dt_tm < cnvtdatetime(reset_endDate) "
 ENDIF
 SET idx = 0
 DECLARE dis_rd_att_parser = vc WITH protect, noconstant(" ")
 IF (dis_rd_att_fv IN ("1", "Y", "YES", "ON"))
  SET dis_rd_att_parser = " se.sch_event_id = sa.sch_event_id"
 ELSE
  SET dis_rd_att_parser = build2(" se.sch_event_id = sa.sch_event_id",
   " and se.appt_type_cd != subsequent_cd")
 ENDIF
 IF (validate(pref_18ww)=0)
  DECLARE pref_index = i4 WITH noconstant(1)
  DECLARE pref_18ww = vc WITH noconstant("OFF")
  SET stat = prefacc_initialise(0)
  IF (stat=c_function_success)
   SET stat = prefacc_getvalue(pref_index,"18ww",pref_18ww)
   SET pref_18ww = cnvtupper(pref_18ww)
  ELSE
   CALL adderrormsg(failure,"VALIDATE",failure,"PREFERENCE","Preference not intialised")
   GO TO exit_script
  ENDIF
  SET stat = prefacc_destroy(0)
 ENDIF
 FREE RECORD cds
 RECORD cds(
   1 activity[*]
     2 update_type = i2
     2 cds_batch_content_id = f8
     2 cds_batch_id = f8
     2 parent_entity_id = f8
     2 parent_entity_name = c30
     2 encntr_id = f8
     2 cds_type_cd = f8
     2 cds_row_error_ind = i2
     2 provider_org_id = f8
     2 encntr_org_id = f8
     2 update_del_flag = i2
     2 activity_dt_tm = dq8
     2 opa_sch_event_id = f8
     2 delete_row_ind = i2
     2 fs_parent_entity_ident = vc
     2 fs_parent_entity_name = vc
     2 suppress_ind = i2
     2 permanent_del_ind = i2
     2 transaction_type_cd = f8
 )
 FREE RECORD request
 RECORD request(
   1 retrigger_type_flag = i2
   1 prg_mode_flag = f8
   1 current_dt_tm = dq8
   1 entity_cnt = i4
   1 entity[*]
     2 entity_id = f8
     2 entity_name = c30
     2 status_flag = i2
     2 status_details = vc
     2 xml_fail_ind = i2
 )
 FREE RECORD reply
 RECORD reply(
   1 cds_batch_content[*]
     2 cds_batch_content_id = f8
     2 status = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (validate(trust_id)=null)
  SET trust_id = 0.0
 ENDIF
 IF (trust_id=0.0)
  SET resetdate = cnvtdatetime((curdate - 1),0)
  SET reset_enddate = cnvtdatetime(curdate,cnvttime((cnvtmin(curtime)+ 60)))
  RECORD cds_prompt_type(
    1 type_cnt = i4
    1 ae_flag = i1
    1 apc_flag = i1
    1 eal_flag = i1
    1 opa_flag = i1
    1 adc_flag = i1
    1 csr_flag = i1
    1 ccc_flag = i1
    1 cac_flag = i1
    1 cgs_flag = i1
    1 cip_flag = i1
  )
  SET cds_prompt_type->ae_flag = 1
  SET cds_prompt_type->apc_flag = 1
  SET cds_prompt_type->eal_flag = 1
  SET cds_prompt_type->opa_flag = 1
  SET cds_prompt_type->adc_flag = 1
  SET cds_prompt_type->csr_flag = 1
  SET cds_prompt_type->ccc_flag = 1
  SET cds_prompt_type->cac_flag = 1
  SET cds_prompt_type->cgs_flag = 1
  SET cds_prompt_type->cip_flag = 1
  SET stemp = concat("***** Running cds_batch_content. Start:",format(update_dt_tm,"@MEDIUMDATETIME"),
   "*****")
  CALL log_message(stemp,log_level_debug)
 ELSE
  SET stemp = concat("***** Running cds_batch_content from cds_batch_reset. trust_id = ",cnvtstring(
    trust_id),"*****")
  CALL log_message(stemp,log_level_debug)
  SET stemp = concat("***** Reset Date = ",format(cnvtdate(resetdate),"@MEDIUMDATE")," *****")
  CALL log_message(stemp,log_level_debug)
  SET stemp = concat("***** Start:",format(update_dt_tm,"@MEDIUMDATETIME"),"*****")
  CALL log_message(stemp,log_level_debug)
 ENDIF
 SET last_mod = "414021"
 FREE RECORD encntr_types
 RECORD encntr_types(
   1 ae_cnt = i4
   1 ae[*]
     2 episode_type_cd = f8
   1 apc_cnt = i4
   1 apc[*]
     2 episode_type_cd = f8
   1 eal_cnt = i4
   1 eal[*]
     2 episode_type_cd = f8
   1 opa_cnt = i4
   1 opa[*]
     2 episode_type_cd = f8
   1 apc_eal_cnt = i4
   1 apc_eal[*]
     2 episode_type_cd = f8
   1 csr_cnt = i4
   1 csr[*]
     2 episode_type_cd = f8
   1 ccc_cnt = i4
   1 ccc[*]
     2 episode_type_cd = f8
   1 cac_cnt = i4
   1 cac[*]
     2 episode_type_cd = f8
   1 cgs_cnt = i4
   1 cgs[*]
     2 episode_type_cd = f8
   1 cip_cnt = i4
   1 cip[*]
     2 episode_type_cd = f8
   1 ae_apc_cnt = i4
   1 ae_apc[*]
     2 episode_type_cd = f8
   1 ae_eal_cnt = i4
   1 ae_eal[*]
     2 episode_type_cd = f8
 )
 SELECT INTO "nl:"
  FROM code_value_group cvg
  PLAN (cvg
   WHERE cvg.parent_code_value IN (cdstype_ae, cdstype_apc, cdstype_eal, cdstype_opa, cdstype_csr,
   cdstype_cac, cdstype_ccc, cdstype_cgs, cdstype_cip)
    AND ((cvg.code_set+ 0)=71))
  HEAD REPORT
   ae_cnt = 0, apc_cnt = 0, eal_cnt = 0,
   opa_cnt = 0, csr_cnt = 0, ccc_cnt = 0,
   cac_cnt = 0, cgs_cnt = 0, cip_cnt = 0,
   stat = alterlist(encntr_types->ae,10), stat = alterlist(encntr_types->apc,10), stat = alterlist(
    encntr_types->eal,10),
   stat = alterlist(encntr_types->opa,10), stat = alterlist(encntr_types->csr,10), stat = alterlist(
    encntr_types->ccc,10),
   stat = alterlist(encntr_types->cac,10), stat = alterlist(encntr_types->cgs,10), stat = alterlist(
    encntr_types->cip,10)
  DETAIL
   IF (cvg.parent_code_value=cdstype_ae)
    ae_cnt += 1
    IF (mod(ae_cnt,10)=1)
     stat = alterlist(encntr_types->ae,(ae_cnt+ 10))
    ENDIF
    encntr_types->ae[ae_cnt].episode_type_cd = cvg.child_code_value
   ELSEIF (cvg.parent_code_value=cdstype_apc)
    apc_cnt += 1
    IF (mod(apc_cnt,10)=1)
     stat = alterlist(encntr_types->apc,(apc_cnt+ 10))
    ENDIF
    encntr_types->apc[apc_cnt].episode_type_cd = cvg.child_code_value
   ELSEIF (cvg.parent_code_value=cdstype_eal)
    eal_cnt += 1
    IF (mod(eal_cnt,10)=1)
     stat = alterlist(encntr_types->eal,(eal_cnt+ 10))
    ENDIF
    encntr_types->eal[eal_cnt].episode_type_cd = cvg.child_code_value
   ELSEIF (cvg.parent_code_value=cdstype_opa)
    opa_cnt += 1
    IF (mod(opa_cnt,10)=1)
     stat = alterlist(encntr_types->opa,(opa_cnt+ 10))
    ENDIF
    encntr_types->opa[opa_cnt].episode_type_cd = cvg.child_code_value
   ELSEIF (cvg.parent_code_value=cdstype_csr)
    csr_cnt += 1
    IF (mod(csr_cnt,10)=1)
     stat = alterlist(encntr_types->csr,(csr_cnt+ 10))
    ENDIF
    encntr_types->csr[csr_cnt].episode_type_cd = cvg.child_code_value
   ELSEIF (cvg.parent_code_value=cdstype_ccc)
    ccc_cnt += 1
    IF (mod(ccc_cnt,10)=1)
     stat = alterlist(encntr_types->ccc,(ccc_cnt+ 10))
    ENDIF
    encntr_types->ccc[ccc_cnt].episode_type_cd = cvg.child_code_value
   ELSEIF (cvg.parent_code_value=cdstype_cac)
    cac_cnt += 1
    IF (mod(cac_cnt,10)=1)
     stat = alterlist(encntr_types->cac,(cac_cnt+ 10))
    ENDIF
    encntr_types->cac[cac_cnt].episode_type_cd = cvg.child_code_value
   ELSEIF (cvg.parent_code_value=cdstype_cgs)
    cgs_cnt += 1
    IF (mod(cgs_cnt,10)=1)
     stat = alterlist(encntr_types->cgs,(cgs_cnt+ 10))
    ENDIF
    encntr_types->cgs[cgs_cnt].episode_type_cd = cvg.child_code_value
   ELSEIF (cvg.parent_code_value=cdstype_cip)
    cip_cnt += 1
    IF (mod(cip_cnt,10)=1)
     stat = alterlist(encntr_types->cip,(cip_cnt+ 10))
    ENDIF
    encntr_types->cip[cip_cnt].episode_type_cd = cvg.child_code_value
   ENDIF
  FOOT REPORT
   stat = alterlist(encntr_types->ae,ae_cnt), stat = alterlist(encntr_types->apc,apc_cnt), stat =
   alterlist(encntr_types->eal,eal_cnt),
   stat = alterlist(encntr_types->opa,opa_cnt), stat = alterlist(encntr_types->csr,csr_cnt), stat =
   alterlist(encntr_types->ccc,ccc_cnt),
   stat = alterlist(encntr_types->cac,cac_cnt), stat = alterlist(encntr_types->cgs,cgs_cnt), stat =
   alterlist(encntr_types->cip,cip_cnt),
   encntr_types->ae_cnt = ae_cnt, encntr_types->apc_cnt = apc_cnt, encntr_types->eal_cnt = eal_cnt,
   encntr_types->opa_cnt = opa_cnt, encntr_types->csr_cnt = csr_cnt, encntr_types->ccc_cnt = ccc_cnt,
   encntr_types->cac_cnt = cac_cnt, encntr_types->cgs_cnt = cgs_cnt, encntr_types->cip_cnt = cip_cnt
  WITH nocounter
 ;end select
 IF ((((((((((encntr_types->ae_cnt+ encntr_types->apc_cnt)+ encntr_types->eal_cnt)+ encntr_types->
 opa_cnt)+ encntr_types->csr_cnt)+ encntr_types->ccc_cnt)+ encntr_types->cac_cnt)+ encntr_types->
 cgs_cnt)+ encntr_types->cip_cnt)=0))
  CALL echo(concat(
    "Warning: Encounter types have not been mapped in Code Groupings. Hard coding encounter types"))
  SET stat = alterlist(encntr_types->ae,1)
  SET encntr_types->ae[1].episode_type_cd = ed_type
  SET stat = alterlist(encntr_types->apc,8)
  SET encntr_types->apc[1].episode_type_cd = maternity_type
  SET encntr_types->apc[2].episode_type_cd = newborn_type
  SET encntr_types->apc[3].episode_type_cd = psych_ip_type
  SET encntr_types->apc[4].episode_type_cd = reg_day_type
  SET encntr_types->apc[5].episode_type_cd = reg_night_type
  SET encntr_types->apc[6].episode_type_cd = daycase_type
  SET encntr_types->apc[7].episode_type_cd = ip_type
  SET encntr_types->apc[8].episode_type_cd = mhinpatient_type
  SET stat = alterlist(encntr_types->eal,4)
  SET encntr_types->eal[1].episode_type_cd = ip_wl_type
  SET encntr_types->eal[2].episode_type_cd = daycase_wl_type
  SET encntr_types->eal[3].episode_type_cd = daycase_type
  SET encntr_types->eal[4].episode_type_cd = ip_type
  SET stat = alterlist(encntr_types->opa,3)
  SET encntr_types->opa[1].episode_type_cd = op_type
  SET encntr_types->opa[2].episode_type_cd = op_referral_type
  SET encntr_types->opa[3].episode_type_cd = op_prereg_type
  SET stat = alterlist(encntr_types->csr,2)
  SET encntr_types->csr[1].episode_type_cd = community_cd
  SET encntr_types->csr[2].episode_type_cd = community_ref_cd
  SET stat = alterlist(encntr_types->ccc,2)
  SET encntr_types->ccc[1].episode_type_cd = community_cd
  SET encntr_types->ccc[2].episode_type_cd = community_ref_cd
  SET stat = alterlist(encntr_types->cac,2)
  SET encntr_types->cac[1].episode_type_cd = community_cd
  SET encntr_types->cac[2].episode_type_cd = community_ref_cd
  SET stat = alterlist(encntr_types->cgs,2)
  SET encntr_types->cgs[1].episode_type_cd = community_cd
  SET encntr_types->cgs[2].episode_type_cd = community_ref_cd
  SET stat = alterlist(encntr_types->cip,2)
  SET encntr_types->cip[1].episode_type_cd = community_cd
  SET encntr_types->cip[2].episode_type_cd = community_ref_cd
  SET encntr_types->ae_cnt = size(encntr_types->ae,5)
  SET encntr_types->apc_cnt = size(encntr_types->apc,5)
  SET encntr_types->eal_cnt = size(encntr_types->eal,5)
  SET encntr_types->opa_cnt = size(encntr_types->opa,5)
  SET encntr_types->csr_cnt = size(encntr_types->csr,5)
  SET encntr_types->ccc_cnt = size(encntr_types->ccc,5)
  SET encntr_types->cac_cnt = size(encntr_types->cac,5)
  SET encntr_types->cgs_cnt = size(encntr_types->cgs,5)
  SET encntr_types->cip_cnt = size(encntr_types->cip,5)
 ENDIF
 SET encntr_types->apc_eal_cnt = (encntr_types->apc_cnt+ encntr_types->eal_cnt)
 SET stat = alterlist(encntr_types->apc_eal,encntr_types->apc_eal_cnt)
 FOR (c = 1 TO encntr_types->apc_cnt)
   SET encntr_types->apc_eal[c].episode_type_cd = encntr_types->apc[c].episode_type_cd
 ENDFOR
 FOR (c = 1 TO encntr_types->eal_cnt)
   SET encntr_types->apc_eal[(c+ encntr_types->apc_cnt)].episode_type_cd = encntr_types->eal[c].
   episode_type_cd
 ENDFOR
 SET encntr_types->ae_apc_cnt = (encntr_types->apc_cnt+ encntr_types->ae_cnt)
 SET stat = alterlist(encntr_types->ae_apc,encntr_types->ae_apc_cnt)
 FOR (c = 1 TO encntr_types->apc_cnt)
   SET encntr_types->ae_apc[c].episode_type_cd = encntr_types->apc[c].episode_type_cd
 ENDFOR
 FOR (c = 1 TO encntr_types->ae_cnt)
   SET encntr_types->ae_apc[(c+ encntr_types->apc_cnt)].episode_type_cd = encntr_types->ae[c].
   episode_type_cd
 ENDFOR
 SET encntr_types->ae_eal_cnt = (encntr_types->eal_cnt+ encntr_types->ae_cnt)
 SET stat = alterlist(encntr_types->ae_eal,encntr_types->ae_eal_cnt)
 FOR (c = 1 TO encntr_types->eal_cnt)
   SET encntr_types->ae_eal[c].episode_type_cd = encntr_types->eal[c].episode_type_cd
 ENDFOR
 FOR (c = 1 TO encntr_types->ae_cnt)
   SET encntr_types->ae_eal[(c+ encntr_types->eal_cnt)].episode_type_cd = encntr_types->ae[c].
   episode_type_cd
 ENDFOR
 FREE RECORD cds_activity_types
 RECORD cds_activity_types(
   1 type_cnt = i4
   1 type[*]
     2 activity_cd = f8
 )
 FREE RECORD cds_activity_types_temp
 RECORD cds_activity_types_temp(
   1 type_cnt = i4
   1 type[*]
     2 activity_cd = f8
 )
 SET stat = alterlist(cds_activity_types->type,act_type_size)
 IF (com_field_value != 0)
  IF ((cds_prompt_type->csr_flag=1))
   SET cds_activity_types->type[(cds_activity_types->type_cnt+ 1)].activity_cd = cds_310
   SET cds_activity_types->type_cnt += 1
  ENDIF
  IF ((cds_prompt_type->ccc_flag=1))
   SET cds_activity_types->type[(cds_activity_types->type_cnt+ 1)].activity_cd = cds_311
   SET cds_activity_types->type_cnt += 1
  ENDIF
  IF ((cds_prompt_type->cac_flag=1))
   SET cds_activity_types->type[(cds_activity_types->type_cnt+ 1)].activity_cd = cds_312
   SET cds_activity_types->type_cnt += 1
  ENDIF
  IF ((cds_prompt_type->cgs_flag=1))
   SET cds_activity_types->type[(cds_activity_types->type_cnt+ 1)].activity_cd = cds_313
   SET cds_activity_types->type_cnt += 1
  ENDIF
  IF ((cds_prompt_type->cip_flag=1))
   SET cds_activity_types->type[(cds_activity_types->type_cnt+ 1)].activity_cd = cds_314
   SET cds_activity_types->type_cnt += 1
  ENDIF
 ENDIF
 IF ((cds_prompt_type->ae_flag=1))
  SET cds_activity_types->type[(cds_activity_types->type_cnt+ 1)].activity_cd = cds_010
  SET cds_activity_types->type[(cds_activity_types->type_cnt+ 2)].activity_cd = cds_011
  SET cds_activity_types->type_cnt += 2
 ENDIF
 IF ((cds_prompt_type->apc_flag=1))
  SET cds_activity_types->type[(cds_activity_types->type_cnt+ 1)].activity_cd = cds_120
  SET cds_activity_types->type[(cds_activity_types->type_cnt+ 2)].activity_cd = cds_130
  SET cds_activity_types->type[(cds_activity_types->type_cnt+ 3)].activity_cd = cds_140
  SET cds_activity_types->type[(cds_activity_types->type_cnt+ 4)].activity_cd = cds_150
  SET cds_activity_types->type[(cds_activity_types->type_cnt+ 5)].activity_cd = cds_160
  SET cds_activity_types->type[(cds_activity_types->type_cnt+ 6)].activity_cd = cds_170
  SET cds_activity_types->type[(cds_activity_types->type_cnt+ 7)].activity_cd = cds_180
  SET cds_activity_types->type[(cds_activity_types->type_cnt+ 8)].activity_cd = cds_190
  SET cds_activity_types->type[(cds_activity_types->type_cnt+ 9)].activity_cd = cds_200
  SET cds_activity_types->type_cnt += 9
 ENDIF
 IF ((cds_prompt_type->eal_flag=1))
  SET cds_activity_types->type[(cds_activity_types->type_cnt+ 1)].activity_cd = cds_030
  SET cds_activity_types->type[(cds_activity_types->type_cnt+ 2)].activity_cd = cds_060
  SET cds_activity_types->type[(cds_activity_types->type_cnt+ 3)].activity_cd = cds_070
  SET cds_activity_types->type[(cds_activity_types->type_cnt+ 4)].activity_cd = cds_080
  SET cds_activity_types->type[(cds_activity_types->type_cnt+ 5)].activity_cd = cds_090
  SET cds_activity_types->type_cnt += 5
 ENDIF
 IF ((cds_prompt_type->opa_flag=1))
  SET cds_activity_types->type[(cds_activity_types->type_cnt+ 1)].activity_cd = cds_020
  SET cds_activity_types->type[(cds_activity_types->type_cnt+ 2)].activity_cd = cds_021
  SET cds_activity_types->type_cnt += 2
 ENDIF
 IF ((cds_prompt_type->adc_flag=1))
  SET cds_activity_types->type[(cds_activity_types->type_cnt+ 1)].activity_cd = cds_0201
  SET cds_activity_types->type_cnt += 1
 ENDIF
 SET stat = alterlist(cds_activity_types->type,cds_activity_types->type_cnt)
 IF (trust_id > 0)
  SET eorgclause = "(e.organization_id+0 = trust_id or e.organization_id+0 in "
  SET eorgclause = concat(eorgclause," (select oor.related_org_id from org_org_reltn oor ")
  SET eorgclause = concat(eorgclause," where oor.organization_id = trust_id ")
  SET eorgclause = concat(eorgclause," and oor.org_org_reltn_cd+0 = trust_rel_code ")
  SET eorgclause = concat(eorgclause," and oor.active_ind = 1 ")
  SET eorgclause = concat(eorgclause," and oor.beg_effective_dt_tm <= cnvtdatetime(update_dt_tm) ")
  SET eorgclause = concat(eorgclause," and oor.end_effective_dt_tm > cnvtdatetime(update_dt_tm))) ")
  SET cbcorgclauseojoin = "cbc.organization_id = outerjoin(trust_id)"
  SET cbcorgclauseojoin2 = "cbc2.organization_id = outerjoin(trust_id)"
  SET cbcorgclause = "cbc.organization_id = trust_id"
  SET begdateclause = "sa.beg_dt_tm+0 < cnvtdatetime(curdate, 235959)"
 ELSE
  SET eorgclause = "e.organization_id+0 > 0"
  SET cbcorgclauseojoin = "cbc.organization_id > outerjoin(0)"
  SET cbcorgclauseojoin2 = "cbc2.organization_id > outerjoin(0)"
  SET cbcorgclause = "cbc.organization_id > 0"
  SET begdateclause = "sa.beg_dt_tm+0 < cnvtdatetime(curdate, 0000)"
 ENDIF
 SET latestencntrselect =
 "not exists (select e1.encntr_id from encounter e1 where e1.encntr_id = e.encntr_id "
 SET latestencntrselect = concat(latestencntrselect," and e1.disch_dt_tm+0 <= e.create_dt_tm ")
 SET latestencntrselect = concat(latestencntrselect," and e1.reg_dt_tm+0 <= e.create_dt_tm ")
 SET latestencntrselect = concat(latestencntrselect," and e1.contributor_system_cd+0 > 0)")
 SET testpatientexcclause =
 "p.person_id = e.person_id and (p.name_last_key != 'ZZZ*' OR p.name_last_key IS NULL)"
 IF (com_field_value=0)
  GO TO non_community_cds
 ENDIF
 CALL echo("--------START OF COMMUNITY QUERIES--------")
 IF ((cds_prompt_type->csr_flag=1))
  SELECT INTO "nl:"
   FROM encounter e,
    cds_batch_content cbc,
    person p
   PLAN (e
    WHERE e.updt_dt_tm >= cnvtdatetime(resetdate)
     AND e.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND expand(idx,1,encntr_types->csr_cnt,(e.encntr_type_cd+ 0),encntr_types->csr[idx].
     episode_type_cd)
     AND parser(latestencntrselect)
     AND parser(eorgclause))
    JOIN (p
    WHERE parser(testpatientexcclause))
    JOIN (cbc
    WHERE (cbc.parent_entity_id= Outerjoin(e.encntr_id))
     AND (cbc.cds_type_cd= Outerjoin(cds_310))
     AND parser(cbcorgclauseojoin))
   ORDER BY e.encntr_id
   HEAD REPORT
    cnt = size(cds->activity,5)
   HEAD e.encntr_id
    cnt += 1
    IF (cnt > size(cds->activity,5))
     stat = alterlist(cds->activity,(cnt+ 499))
    ENDIF
    cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_batch_content_id = cbc
    .cds_batch_content_id, cds->activity[cnt].activity_dt_tm = cnvtdatetime(e.referral_rcvd_dt_tm),
    cds->activity[cnt].parent_entity_id = e.encntr_id, cds->activity[cnt].parent_entity_name =
    encounterstring, cds->activity[cnt].cds_type_cd = cds_310,
    cds->activity[cnt].encntr_org_id = e.organization_id, cds->activity[cnt].encntr_id = e.encntr_id,
    cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind,
    cds->activity[cnt].suppress_ind = cbc.suppress_ind, cds->activity[cnt].transaction_type_cd =
    comm_serv_ref_cd
    IF (e.active_ind=1
     AND cbc.update_del_flag != 1)
     cds->activity[cnt].update_del_flag = 9
    ELSE
     cds->activity[cnt].update_del_flag = 1
    ENDIF
   FOOT  e.encntr_id
    null
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((cds_prompt_type->cac_flag=1))
  SELECT INTO "nl:"
   FROM clinical_event ce,
    clinical_event ce2,
    clinical_event ce3,
    clinical_event ce4,
    ce_date_result cdr,
    encounter e,
    person p,
    cds_batch_content cbc,
    ce_coded_result ccr,
    nomenclature n
   PLAN (ce
    WHERE ce.updt_dt_tm >= cnvtdatetime(resetdate)
     AND ce.updt_dt_tm < cnvtdatetime(reset_enddate)
     AND ((ce.event_cd+ 0)=comn_cont_cd)
     AND ce.valid_until_dt_tm=cnvtdatetime(abs_valid_until_dt_tm))
    JOIN (e
    WHERE e.encntr_id=ce.encntr_id
     AND parser(eorgclause)
     AND expand(idx,1,encntr_types->cac_cnt,(e.encntr_type_cd+ 0),encntr_types->cac[idx].
     episode_type_cd))
    JOIN (p
    WHERE parser(testpatientexcclause))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce.event_id
     AND ((ce2.event_cd+ 0)=dcp_gen_cd)
     AND ce2.valid_until_dt_tm=cnvtdatetime(abs_valid_until_dt_tm))
    JOIN (ce3
    WHERE ce3.parent_event_id=ce2.event_id
     AND ((ce3.event_cd+ 0)=comn_cont_type_cd)
     AND ce3.valid_until_dt_tm=cnvtdatetime(abs_valid_until_dt_tm))
    JOIN (ce4
    WHERE ce4.parent_event_id=ce2.event_id
     AND ((ce4.event_cd+ 0)=contact_st_dt_tm_cd)
     AND ce4.valid_until_dt_tm=cnvtdatetime(abs_valid_until_dt_tm))
    JOIN (cdr
    WHERE cdr.event_id=ce4.event_id
     AND cdr.valid_until_dt_tm=cnvtdatetime(abs_valid_until_dt_tm))
    JOIN (ccr
    WHERE ccr.event_id=ce3.event_id
     AND ccr.valid_until_dt_tm=cnvtdatetime(abs_valid_until_dt_tm))
    JOIN (n
    WHERE n.nomenclature_id=ccr.nomenclature_id
     AND n.active_ind=1)
    JOIN (cbc
    WHERE (cbc.parent_entity_id= Outerjoin(ce.event_id))
     AND (cbc.parent_entity_name= Outerjoin(clineventstring))
     AND parser(cbcorgclauseojoin))
   ORDER BY ce.event_id
   HEAD REPORT
    cnt = size(cds->activity,5)
   HEAD ce.event_id
    num = 0, rowfound = locateval(num,1,size(cds->activity,5),ce.event_id,cds->activity[num].
     parent_entity_id,
     clineventstring,cds->activity[num].parent_entity_name)
    IF (rowfound=0)
     cnt += 1
     IF (cnt > size(cds->activity,5))
      stat = alterlist(cds->activity,(cnt+ 499))
     ENDIF
     cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_batch_content_id =
     cbc.cds_batch_content_id, cds->activity[cnt].activity_dt_tm = cnvtdatetime(cdr.result_dt_tm),
     cds->activity[cnt].parent_entity_id = ce.event_id, cds->activity[cnt].parent_entity_name =
     clineventstring, cds->activity[cnt].cds_type_cd = cds_312,
     cds->activity[cnt].encntr_org_id = e.organization_id, cds->activity[cnt].encntr_id = e.encntr_id,
     cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind,
     cds->activity[cnt].suppress_ind = cbc.suppress_ind, cds->activity[cnt].transaction_type_cd =
     comm_adhoc_care_cont_cd
     IF (e.active_ind=1
      AND ce.result_status_cd IN (auth_cd, modified_cd)
      AND n.source_string_keycap="UNSCHEDULED"
      AND cbc.update_del_flag != 1)
      cds->activity[cnt].update_del_flag = 9
     ELSE
      cds->activity[cnt].update_del_flag = 1
     ENDIF
    ENDIF
   FOOT  ce.event_id
    null
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((cds_prompt_type->cip_flag=1))
  SELECT INTO "nl:"
   FROM clinical_event ce,
    clinical_event ce2,
    clinical_event ce3,
    ce_date_result cdr,
    encounter e,
    person p,
    cds_batch_content cbc
   PLAN (ce
    WHERE ce.updt_dt_tm >= cnvtdatetime(resetdate)
     AND ce.updt_dt_tm < cnvtdatetime(reset_enddate)
     AND ((ce.event_cd+ 0)=comn_indrct_cd)
     AND ce.valid_until_dt_tm=cnvtdatetime(abs_valid_until_dt_tm))
    JOIN (e
    WHERE e.encntr_id=ce.encntr_id
     AND parser(eorgclause)
     AND expand(idx,1,encntr_types->cip_cnt,(e.encntr_type_cd+ 0),encntr_types->cip[idx].
     episode_type_cd))
    JOIN (p
    WHERE parser(testpatientexcclause))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce.event_id
     AND ((ce2.event_cd+ 0)=dcp_gen_cd)
     AND ce2.valid_until_dt_tm=cnvtdatetime(abs_valid_until_dt_tm))
    JOIN (ce3
    WHERE ce3.parent_event_id=ce2.event_id
     AND ((ce3.event_cd+ 0)=app_beg_dt_tm_cd)
     AND ce.valid_until_dt_tm=cnvtdatetime(abs_valid_until_dt_tm))
    JOIN (cdr
    WHERE cdr.event_id=ce3.event_id
     AND cdr.valid_until_dt_tm=cnvtdatetime(abs_valid_until_dt_tm))
    JOIN (cbc
    WHERE (cbc.parent_entity_id= Outerjoin(ce3.event_id))
     AND (cbc.parent_entity_name= Outerjoin(clineventstring))
     AND parser(cbcorgclauseojoin))
   ORDER BY ce3.event_id
   HEAD REPORT
    cnt = size(cds->activity,5)
   HEAD ce3.event_id
    num = 0, rowfound = locateval(num,1,size(cds->activity,5),ce.event_id,cds->activity[num].
     parent_entity_id,
     clineventstring,cds->activity[num].parent_entity_name)
    IF (rowfound=0)
     cnt += 1
     IF (cnt > size(cds->activity,5))
      stat = alterlist(cds->activity,(cnt+ 499))
     ENDIF
     cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_batch_content_id =
     cbc.cds_batch_content_id, cds->activity[cnt].activity_dt_tm = cnvtdatetime(cdr.result_dt_tm),
     cds->activity[cnt].parent_entity_id = ce3.event_id, cds->activity[cnt].parent_entity_name =
     clineventstring, cds->activity[cnt].cds_type_cd = cds_314,
     cds->activity[cnt].encntr_org_id = e.organization_id, cds->activity[cnt].encntr_id = e.encntr_id,
     cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind,
     cds->activity[cnt].suppress_ind = cbc.suppress_ind, cds->activity[cnt].transaction_type_cd =
     comm_ind_acc_cd
     IF (e.active_ind=1
      AND ce3.result_status_cd IN (auth_cd, modified_cd)
      AND cbc.update_del_flag != 1)
      cds->activity[cnt].update_del_flag = 9
     ELSE
      cds->activity[cnt].update_del_flag = 1
     ENDIF
    ENDIF
   FOOT  ce3.event_id
    null
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((((cds_prompt_type->ccc_flag=1)) OR ((cds_prompt_type->cgs_flag=1))) )
  IF ((cds_prompt_type->ccc_flag=1))
   SELECT INTO "nl:"
    FROM encounter e,
     sch_appt sa,
     sch_event_action sea,
     person p,
     cds_batch_content cbc
    PLAN (sa
     WHERE sa.updt_dt_tm >= cnvtdatetime(resetdate)
      AND sa.updt_dt_tm <= cnvtdatetime(reset_enddate)
      AND ((sa.sch_role_cd+ 0)=patient)
      AND trim(sa.role_meaning)=patientstring)
     JOIN (sea
     WHERE sea.sch_event_id=sa.sch_event_id
      AND sea.schedule_id=sa.schedule_id
      AND sea.action_dt_tm >= cnvtdatetime(resetdate)
      AND sea.action_dt_tm <= cnvtdatetime(reset_enddate))
     JOIN (e
     WHERE e.encntr_id=sa.encntr_id
      AND expand(idx,1,encntr_types->ccc_cnt,(e.encntr_type_cd+ 0),encntr_types->ccc[idx].
      episode_type_cd)
      AND parser(latestencntrselect)
      AND parser(eorgclause))
     JOIN (p
     WHERE parser(testpatientexcclause))
     JOIN (cbc
     WHERE (cbc.parent_entity_id= Outerjoin(sa.schedule_id))
      AND (cbc.parent_entity_name= Outerjoin(schschedulestring))
      AND (cbc.cds_type_cd= Outerjoin(cds_311))
      AND (cbc.permanent_del_ind= Outerjoin(0))
      AND parser(cbcorgclauseojoin))
    ORDER BY sa.schedule_id
    HEAD REPORT
     cnt = size(cds->activity,5)
    HEAD sa.schedule_id
     num = 0, rowfound = locateval(num,1,size(cds->activity,5),sa.schedule_id,cds->activity[num].
      parent_entity_id)
     IF (rowfound=0)
      cnt += 1
      IF (cnt > size(cds->activity,5))
       stat = alterlist(cds->activity,(cnt+ 499))
      ENDIF
      cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_batch_content_id =
      cbc.cds_batch_content_id, cds->activity[cnt].activity_dt_tm = sa.beg_dt_tm,
      cds->activity[cnt].parent_entity_name = schschedulestring, cds->activity[cnt].parent_entity_id
       = sa.schedule_id, cds->activity[cnt].encntr_id = e.encntr_id,
      cds->activity[cnt].cds_type_cd = cds_311, cds->activity[cnt].encntr_org_id = e.organization_id,
      cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind,
      cds->activity[cnt].suppress_ind = cbc.suppress_ind, cds->activity[cnt].transaction_type_cd =
      comm_care_cont_cd
      IF (e.active_ind=1
       AND cbc.update_del_flag != 1)
       cds->activity[cnt].update_del_flag = 9
      ELSE
       cds->activity[cnt].update_del_flag = 1
      ENDIF
     ENDIF
    FOOT  sa.schedule_id
     null
    FOOT REPORT
     stat = alterlist(cds->activity,cnt)
    WITH nocounter
   ;end select
  ENDIF
  IF ((cds_prompt_type->cgs_flag=1))
   SELECT INTO "nl:"
    FROM sch_event se,
     sch_event_action sea,
     sch_appt sa,
     cds_batch_content cbc,
     sch_appt_option sao,
     location l
    PLAN (sa
     WHERE sa.updt_dt_tm >= cnvtdatetime(resetdate)
      AND sa.updt_dt_tm <= cnvtdatetime(reset_enddate))
     JOIN (sea
     WHERE sea.sch_event_id=sa.sch_event_id
      AND sea.schedule_id=sa.schedule_id
      AND sea.action_dt_tm >= cnvtdatetime(resetdate)
      AND sea.action_dt_tm <= cnvtdatetime(reset_enddate))
     JOIN (se
     WHERE se.sch_event_id=sa.sch_event_id
      AND se.version_dt_tm=cnvtdatetime(abs_valid_until_dt_tm))
     JOIN (l
     WHERE l.location_cd=sa.appt_location_cd)
     JOIN (sao
     WHERE sao.appt_type_cd=se.appt_type_cd
      AND sao.beg_effective_dt_tm <= cnvtdatetime(update_dt_tm)
      AND sao.end_effective_dt_tm > cnvtdatetime(update_dt_tm)
      AND sao.sch_option_cd=group_pat_nonp_cd
      AND sao.active_ind=1)
     JOIN (cbc
     WHERE (cbc.parent_entity_id= Outerjoin(sa.schedule_id))
      AND (cbc.parent_entity_name= Outerjoin(schschedulestring))
      AND (cbc.cds_type_cd= Outerjoin(cds_313))
      AND parser(cbcorgclauseojoin))
    ORDER BY sa.schedule_id
    HEAD REPORT
     cnt = size(cds->activity,5)
    HEAD sa.schedule_id
     num = 0, rowfound = locateval(num,1,size(cds->activity,5),sa.schedule_id,cds->activity[num].
      parent_entity_id)
     IF (rowfound=0)
      cnt += 1
      IF (cnt > size(cds->activity,5))
       stat = alterlist(cds->activity,(cnt+ 499))
      ENDIF
      cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_batch_content_id =
      cbc.cds_batch_content_id, cds->activity[cnt].activity_dt_tm = sa.beg_dt_tm,
      cds->activity[cnt].parent_entity_name = schschedulestring, cds->activity[cnt].parent_entity_id
       = sa.schedule_id, cds->activity[cnt].encntr_id = 0.0,
      cds->activity[cnt].cds_type_cd = cds_313, cds->activity[cnt].encntr_org_id = l.organization_id,
      cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind,
      cds->activity[cnt].suppress_ind = cbc.suppress_ind, cds->activity[cnt].transaction_type_cd =
      comm_group_ses_cd
      IF (cbc.update_del_flag != 1)
       cds->activity[cnt].update_del_flag = 9
      ELSE
       cds->activity[cnt].update_del_flag = 1
      ENDIF
     ENDIF
    FOOT  sa.schedule_id
     null
    FOOT REPORT
     stat = alterlist(cds->activity,cnt)
    WITH nocounter
   ;end select
  ENDIF
  IF (size(cds->activity,5)=0)
   CALL echo("No CDS Activity. Skipping CCC CGS Exception logic Queries ...")
  ELSE
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
     sch_appt sa,
     sch_event_action sea
    PLAN (d
     WHERE (cds->activity[d.seq].parent_entity_name=schschedulestring)
      AND (cds->activity[d.seq].cds_type_cd IN (cds_311, cds_313)))
     JOIN (sa
     WHERE (sa.schedule_id=cds->activity[d.seq].parent_entity_id)
      AND trim(sa.role_meaning)=patientstring)
     JOIN (sea
     WHERE sea.sch_event_id=sa.sch_event_id
      AND ((sea.schedule_id+ 0)=sa.schedule_id)
      AND ((sea.action_meaning IN (undocancel, undonoshow, undocheckin, shuffle, swapres)) OR (((sea
     .action_meaning IN (cancel, reschedule)
      AND sea.reason_meaning IN (systemcancel, automodify, modifyorder)) OR (sea.reason_meaning IN (
     adminerror, admin_error)
      AND sea.action_meaning != modify)) )) )
    ORDER BY d.seq
    HEAD d.seq
     IF ((cds->activity[d.seq].cds_batch_content_id > 0))
      cds->activity[d.seq].update_del_flag = 1, cds->activity[d.seq].delete_row_ind = 0, cds->
      activity[d.seq].permanent_del_ind = 1,
      cds->activity[d.seq].transaction_type_cd = comm_sch_perm_rem_cd
     ELSE
      cds->activity[d.seq].delete_row_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
     sch_appt sa,
     sch_event se,
     sch_appt_option sao,
     code_value_group cvg
    PLAN (d
     WHERE (cds->activity[d.seq].parent_entity_name=schschedulestring)
      AND (cds->activity[d.seq].cds_type_cd IN (cds_311, cds_313)))
     JOIN (sa
     WHERE (sa.schedule_id=cds->activity[d.seq].parent_entity_id)
      AND trim(sa.role_meaning)=patientstring)
     JOIN (se
     WHERE se.sch_event_id=sa.sch_event_id)
     JOIN (sao
     WHERE sao.appt_type_cd=se.appt_type_cd
      AND sao.beg_effective_dt_tm <= cnvtdatetime(update_dt_tm)
      AND sao.end_effective_dt_tm > cnvtdatetime(update_dt_tm)
      AND sao.active_ind=1)
     JOIN (cvg
     WHERE cvg.child_code_value=sao.sch_option_cd
      AND cvg.parent_code_value=diagapptexcl_cd)
    ORDER BY d.seq
    HEAD d.seq
     IF ((cds->activity[d.seq].cds_batch_content_id > 0))
      cds->activity[d.seq].update_del_flag = 1, cds->activity[d.seq].delete_row_ind = 0, cds->
      activity[d.seq].permanent_del_ind = 1,
      cds->activity[d.seq].transaction_type_cd = comm_sch_perm_rem_cd
     ELSE
      cds->activity[d.seq].delete_row_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   SET cds_cnt = size(cds->activity,5)
   SET loc = 1
   WHILE (loc <= cds_cnt)
     IF ((cds->activity[loc].delete_row_ind=1))
      SET cds_cnt -= 1
      SET stat = alterlist(cds->activity,cds_cnt,(loc - 1))
     ELSE
      SET loc += 1
     ENDIF
   ENDWHILE
  ENDIF
 ENDIF
 CALL echo("--------END OF COMMUNITY CDS---------")
#non_community_cds
 IF ((cds_prompt_type->apc_flag=1))
  CALL log_message("--- Starting APC ---",log_level_debug)
  SELECT INTO "nl:"
   FROM encntr_slice es,
    encounter e,
    cds_batch_content cbc,
    person p
   PLAN (es
    WHERE es.updt_dt_tm >= cnvtdatetime(resetdate)
     AND es.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND ((es.encntr_slice_type_cd+ 0)=ce_slice_type))
    JOIN (e
    WHERE e.encntr_id=es.encntr_id
     AND expand(idx,1,encntr_types->apc_cnt,(e.encntr_type_cd+ 0),encntr_types->apc[idx].
     episode_type_cd)
     AND parser(latestencntrselect)
     AND parser(eorgclause))
    JOIN (p
    WHERE parser(testpatientexcclause))
    JOIN (cbc
    WHERE (cbc.parent_entity_id= Outerjoin(es.encntr_slice_id))
     AND (cbc.parent_entity_name= Outerjoin(encntrslicestring))
     AND parser(cbcorgclauseojoin)
     AND (cbc.permanent_del_ind= Outerjoin(0)) )
   ORDER BY es.encntr_slice_id, 0
   HEAD REPORT
    cnt = size(cds->activity,5)
   HEAD es.encntr_slice_id
    IF (((cbc.cds_batch_content_id > 0.0
     AND es.active_ind=0) OR (es.active_ind=1)) )
     cnt += 1
     IF (cnt > size(cds->activity,5))
      stat = alterlist(cds->activity,(cnt+ 499))
     ENDIF
     cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_batch_content_id =
     cbc.cds_batch_content_id, cds->activity[cnt].parent_entity_id = es.encntr_slice_id,
     cds->activity[cnt].parent_entity_name = encntrslicestring, cds->activity[cnt].encntr_org_id = e
     .organization_id, cds->activity[cnt].cds_type_cd = cds_130,
     cds->activity[cnt].transaction_type_cd = f_ge_sl_ch_cd, cds->activity[cnt].suppress_ind = cbc
     .suppress_ind
     IF (cbc.encntr_id > 0.0)
      cds->activity[cnt].encntr_id = cbc.encntr_id
     ELSE
      cds->activity[cnt].encntr_id = e.encntr_id
     ENDIF
     cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind
     IF (es.active_ind=1)
      cds->activity[cnt].update_del_flag = 9
     ELSE
      cds->activity[cnt].update_del_flag = 1
     ENDIF
     IF (datetimecmp(es.end_effective_dt_tm,null_dt_tm)=0)
      cds->activity[cnt].activity_dt_tm = es.beg_effective_dt_tm
     ELSE
      cds->activity[cnt].activity_dt_tm = es.end_effective_dt_tm
     ENDIF
    ENDIF
   FOOT  es.encntr_slice_id
    null
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
  SET stemp = concat("APC 1 complete. Qual = ",cnvtstring(curqual))
  CALL log_message(stemp,log_level_debug)
  SELECT INTO "nl:"
   FROM encntr_slice es,
    encounter e,
    cds_batch_content cbc
   PLAN (es
    WHERE es.updt_dt_tm >= cnvtdatetime(resetdate)
     AND es.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND es.active_ind=0
     AND ((es.encntr_slice_type_cd+ 0)=ce_slice_type))
    JOIN (e
    WHERE e.encntr_id=es.encntr_id
     AND expand(idx,1,encntr_types->ae_eal_cnt,(e.encntr_type_cd+ 0),encntr_types->ae_eal[idx].
     episode_type_cd)
     AND parser(latestencntrselect)
     AND parser(eorgclause))
    JOIN (cbc
    WHERE cbc.parent_entity_id=es.encntr_slice_id
     AND cbc.parent_entity_name=encntrslicestring
     AND parser(cbcorgclause))
   ORDER BY es.encntr_slice_id
   HEAD REPORT
    cnt = size(cds->activity,5)
   HEAD es.encntr_slice_id
    rowfound = 0, start = 1, rowfound = locateval(idx,start,size(cds->activity,5),es.encntr_slice_id,
     cds->activity[idx].parent_entity_id)
    IF (rowfound=0)
     cnt += 1
     IF (cnt > size(cds->activity,5))
      stat = alterlist(cds->activity,(cnt+ 499))
     ENDIF
     cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_batch_content_id =
     cbc.cds_batch_content_id, cds->activity[cnt].parent_entity_id = es.encntr_slice_id,
     cds->activity[cnt].parent_entity_name = encntrslicestring, cds->activity[cnt].encntr_org_id = e
     .organization_id, cds->activity[cnt].encntr_id = e.encntr_id,
     cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].update_del_flag
      = 1, cds->activity[cnt].cds_type_cd = cds_130,
     cds->activity[cnt].transaction_type_cd = f_ge_ae_undo_cd, cds->activity[cnt].suppress_ind = cbc
     .suppress_ind
     IF (datetimecmp(es.end_effective_dt_tm,null_dt_tm)=0)
      cds->activity[cnt].activity_dt_tm = es.beg_effective_dt_tm
     ELSE
      cds->activity[cnt].activity_dt_tm = es.end_effective_dt_tm
     ENDIF
    ENDIF
   FOOT  es.encntr_slice_id
    null
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
  SET encntr_types->apc_cnt += 1
  SET stat = alterlist(encntr_types->apc,encntr_types->apc_cnt)
  SET encntr_types->apc[encntr_types->apc_cnt].episode_type_cd = ip_preadmit_type
  SELECT INTO "nl:"
   FROM encounter e,
    encntr_slice es,
    cds_batch_content cbc,
    person p
   PLAN (e
    WHERE e.updt_dt_tm >= cnvtdatetime(resetdate)
     AND e.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND expand(idx,1,encntr_types->apc_cnt,(e.encntr_type_cd+ 0),encntr_types->apc[idx].
     episode_type_cd)
     AND parser(latestencntrselect)
     AND parser(eorgclause))
    JOIN (p
    WHERE parser(testpatientexcclause))
    JOIN (es
    WHERE es.encntr_id=e.encntr_id
     AND ((es.encntr_slice_type_cd+ 0)=ce_slice_type))
    JOIN (cbc
    WHERE (cbc.parent_entity_id= Outerjoin(es.encntr_slice_id))
     AND (cbc.parent_entity_name= Outerjoin(encntrslicestring))
     AND parser(cbcorgclauseojoin))
   HEAD REPORT
    cnt = size(cds->activity,5)
   DETAIL
    IF (((cbc.cds_batch_content_id > 0.0
     AND es.active_ind=0) OR (es.active_ind=1)) )
     start = 1, rowfound = 0, rowfound = locateval(idx,start,size(cds->activity,5),es.encntr_slice_id,
      cds->activity[idx].parent_entity_id)
     IF (rowfound=0)
      cnt += 1
      IF (cnt > size(cds->activity,5))
       stat = alterlist(cds->activity,(cnt+ 499))
      ENDIF
      cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_batch_content_id =
      cbc.cds_batch_content_id, cds->activity[cnt].parent_entity_id = es.encntr_slice_id,
      cds->activity[cnt].parent_entity_name = encntrslicestring, cds->activity[cnt].encntr_org_id = e
      .organization_id, cds->activity[cnt].cds_type_cd = cds_130,
      cds->activity[cnt].transaction_type_cd = f_ge_encntr_ch_cd
      IF (cbc.encntr_id > 0.0)
       cds->activity[cnt].encntr_id = cbc.encntr_id
      ELSE
       cds->activity[cnt].encntr_id = e.encntr_id
      ENDIF
      cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].suppress_ind
       = cbc.suppress_ind
      IF (es.active_ind=1)
       cds->activity[cnt].update_del_flag = 9
      ELSE
       cds->activity[cnt].update_del_flag = 1
      ENDIF
      IF (datetimecmp(es.end_effective_dt_tm,null_dt_tm)=0)
       cds->activity[cnt].activity_dt_tm = es.beg_effective_dt_tm
      ELSE
       cds->activity[cnt].activity_dt_tm = es.end_effective_dt_tm
      ENDIF
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
  SET encntr_types->apc_cnt -= 1
  SET stat = alterlist(encntr_types->apc,encntr_types->apc_cnt)
  SET stemp = concat("APC 2 complete. Qual = ",cnvtstring(curqual))
  CALL log_message(stemp,log_level_debug)
  SELECT INTO "nl:"
   FROM coding cod,
    encntr_slice es,
    encounter e,
    cds_batch_content cbc,
    person p
   PLAN (cod
    WHERE cod.updt_dt_tm >= cnvtdatetime(resetdate)
     AND cod.updt_dt_tm <= cnvtdatetime(reset_enddate))
    JOIN (es
    WHERE es.encntr_slice_id=cod.encntr_slice_id
     AND es.encntr_slice_type_cd=ce_slice_type)
    JOIN (e
    WHERE e.encntr_id=es.encntr_id
     AND expand(idx,1,encntr_types->apc_cnt,e.encntr_type_cd,encntr_types->apc[idx].episode_type_cd)
     AND parser(latestencntrselect)
     AND parser(eorgclause))
    JOIN (p
    WHERE parser(testpatientexcclause))
    JOIN (cbc
    WHERE (cbc.parent_entity_id= Outerjoin(es.encntr_slice_id))
     AND (cbc.parent_entity_name= Outerjoin(encntrslicestring))
     AND parser(cbcorgclauseojoin))
   ORDER BY es.encntr_slice_id, 0
   HEAD REPORT
    cnt = size(cds->activity,5)
   HEAD es.encntr_slice_id
    IF (((cbc.cds_batch_content_id > 0.0
     AND es.active_ind=0) OR (es.active_ind=1)) )
     start = 1, rowfound = 0, rowfound = locateval(idx,start,size(cds->activity,5),es.encntr_slice_id,
      cds->activity[idx].parent_entity_id)
     IF (rowfound=0)
      cnt += 1
      IF (cnt > size(cds->activity,5))
       stat = alterlist(cds->activity,(cnt+ 499))
      ENDIF
      cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_batch_content_id =
      cbc.cds_batch_content_id, cds->activity[cnt].parent_entity_id = es.encntr_slice_id,
      cds->activity[cnt].parent_entity_name = encntrslicestring, cds->activity[cnt].encntr_org_id = e
      .organization_id, cds->activity[cnt].encntr_id = e.encntr_id,
      cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].suppress_ind
       = cbc.suppress_ind, cds->activity[cnt].cds_type_cd = cds_130,
      cds->activity[cnt].transaction_type_cd = f_ge_coding_updt_cd
      IF (cbc.encntr_id > 0.0)
       cds->activity[cnt].encntr_id = cbc.encntr_id
      ELSE
       cds->activity[cnt].encntr_id = e.encntr_id
      ENDIF
      IF (es.active_ind=1)
       cds->activity[cnt].update_del_flag = 9
      ELSE
       cds->activity[cnt].update_del_flag = 1
      ENDIF
      IF (datetimecmp(es.end_effective_dt_tm,null_dt_tm)=0)
       cds->activity[cnt].activity_dt_tm = es.beg_effective_dt_tm
      ELSE
       cds->activity[cnt].activity_dt_tm = es.end_effective_dt_tm
      ENDIF
     ENDIF
    ENDIF
   FOOT  es.encntr_slice_id
    null
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
  SET stemp = concat("APC 3 complete. Qual = ",cnvtstring(curqual))
  CALL log_message(stemp,log_level_debug)
  SET last_mod = "ukr_pref_get_ccmds:645195"
  IF (validate(ukr_pref_get_ccmds_ind)=0)
   DECLARE ukr_pref_get_ccmds_ind = i2 WITH public, constant(1)
   DECLARE pref_ccmds_idx = i4 WITH protect, noconstant(1)
   DECLARE pref_ccmds_value = vc WITH noconstant("OFF")
   DECLARE pref_ccmds_key = vc WITH constant("CCMDS")
   SET stat = prefacc_initialise(0)
   IF (stat=c_function_success)
    SET stat = prefacc_getvalue(pref_ccmds_idx,pref_ccmds_key,pref_ccmds_value,1)
    SET pref_ccmds_value = cnvtupper(pref_ccmds_value)
   ELSE
    GO TO exit_script
   ENDIF
   SET stat = prefacc_destroy(0)
  ENDIF
  IF (pref_ccmds_value="ON")
   DECLARE resulttext_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",14709,"RESULTTEXT"
     ))
   DECLARE cc_startdatetime_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",72,
     "CRITICALCARESTARTDATETIME"))
   DECLARE ce_inerror_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",8,"INERROR"))
   DECLARE ce_inerror_noview_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",8,
     "INERRNOVIEW"))
   DECLARE ce_inerror_nomut_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",8,"INERRNOMUT")
    )
   DECLARE ce_cancelled_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",8,"CANCELLED"))
   SELECT INTO "nl:"
    FROM clinical_event ce,
     scd_story ss,
     scd_story_pattern scp,
     scr_pattern sp,
     encounter e,
     encntr_slice es,
     person p,
     cds_batch_content cbc,
     cds_batch_content cbc2,
     cds_batch_content cbc3,
     cds_batch_content cbc4,
     cds_batch_content cbc5
    PLAN (ce
     WHERE ce.updt_dt_tm >= cnvtdatetime(resetdate)
      AND ce.updt_dt_tm <= cnvtdatetime(reset_enddate)
      AND ce.valid_until_dt_tm=cnvtdatetime(abs_valid_until_dt_tm))
     JOIN (ss
     WHERE ss.event_id=ce.event_id
      AND ss.active_ind=1)
     JOIN (scp
     WHERE scp.scd_story_id=ss.scd_story_id)
     JOIN (sp
     WHERE sp.scr_pattern_id=scp.scr_pattern_id
      AND sp.display_key IN ("ADULTCCMDSAUDIT", "ICNARCCMPADULTAUDIT", "PCCMDSWARD", "PICANETPCCMDS")
      AND sp.active_ind=1)
     JOIN (e
     WHERE e.encntr_id=ce.encntr_id
      AND parser(latestencntrselect)
      AND expand(idx,1,encntr_types->apc_cnt,(e.encntr_type_cd+ 0),encntr_types->apc[idx].
      episode_type_cd)
      AND parser(eorgclause)
      AND e.active_ind=1)
     JOIN (es
     WHERE es.encntr_id=e.encntr_id
      AND ((es.encntr_slice_type_cd+ 0)=ce_slice_type)
      AND es.active_ind=1)
     JOIN (p
     WHERE parser(testpatientexcclause)
      AND p.active_ind=1)
     JOIN (cbc
     WHERE (cbc.parent_entity_id= Outerjoin(es.encntr_slice_id))
      AND (cbc.parent_entity_name= Outerjoin(encntrslicestring))
      AND parser(cbcorgclauseojoin))
     JOIN (cbc2
     WHERE (cbc2.parent_entity_id= Outerjoin(ce.event_id))
      AND (cbc2.parent_entity_name= Outerjoin(clineventstring))
      AND (cbc2.cds_type_cd= Outerjoin(cdspaediatricint_cd))
      AND parser(cbcorgclauseojoin2))
     JOIN (cbc3
     WHERE (cbc3.parent_entity_id= Outerjoin(ce.event_id))
      AND (cbc3.parent_entity_name= Outerjoin(clineventstring))
      AND (cbc3.cds_type_cd= Outerjoin(cdspaediatricext_cd))
      AND parser(replace(cbcorgclauseojoin,"cbc","cbc3",0)))
     JOIN (cbc4
     WHERE (cbc4.parent_entity_id= Outerjoin(ce.event_id))
      AND (cbc4.parent_entity_name= Outerjoin(clineventstring))
      AND (cbc4.cds_type_cd= Outerjoin(cdsadultint_cd))
      AND parser(replace(cbcorgclauseojoin,"cbc","cbc4",0)))
     JOIN (cbc5
     WHERE (cbc5.parent_entity_id= Outerjoin(ce.event_id))
      AND (cbc5.parent_entity_name= Outerjoin(clineventstring))
      AND (cbc5.cds_type_cd= Outerjoin(cdsadultext_cd))
      AND parser(replace(cbcorgclauseojoin,"cbc","cbc5",0)))
    ORDER BY ce.event_id, ce.valid_from_dt_tm DESC
    HEAD REPORT
     cnt = size(cds->activity,5)
    HEAD ce.event_id
     CASE (sp.display_key)
      OF "PICANETPCCMDS":
       IF ( NOT (ce.result_status_cd=inerror_cd
        AND cbc2.cds_batch_content_id=0))
        cnt += 1
        IF (cnt > size(cds->activity,5))
         stat = alterlist(cds->activity,(cnt+ 499))
        ENDIF
        cds->activity[cnt].cds_batch_id = 0.0, cds->activity[cnt].cds_batch_content_id = cbc2
        .cds_batch_content_id, cds->activity[cnt].parent_entity_id = ce.event_id,
        cds->activity[cnt].parent_entity_name = clineventstring, cds->activity[cnt].encntr_org_id = e
        .organization_id, cds->activity[cnt].cds_type_cd = cdspaediatricint_cd,
        cds->activity[cnt].encntr_id = e.encntr_id, cds->activity[cnt].cds_row_error_ind = cbc2
        .cds_row_error_ind
        IF (ce.result_status_cd=inerror_cd)
         cds->activity[cnt].update_del_flag = 1
        ELSE
         cds->activity[cnt].update_del_flag = 9
        ENDIF
       ENDIF
      OF "PCCMDSWARD":
       IF ( NOT (ce.result_status_cd=inerror_cd
        AND cbc3.cds_batch_content_id=0))
        cnt += 1
        IF (cnt > size(cds->activity,5))
         stat = alterlist(cds->activity,(cnt+ 499))
        ENDIF
        cds->activity[cnt].cds_batch_id = 0.0, cds->activity[cnt].cds_batch_content_id = cbc3
        .cds_batch_content_id, cds->activity[cnt].parent_entity_id = ce.event_id,
        cds->activity[cnt].parent_entity_name = clineventstring, cds->activity[cnt].encntr_org_id = e
        .organization_id, cds->activity[cnt].cds_type_cd = cdspaediatricext_cd,
        cds->activity[cnt].encntr_id = e.encntr_id, cds->activity[cnt].cds_row_error_ind = cbc3
        .cds_row_error_ind
        IF (ce.result_status_cd=inerror_cd)
         cds->activity[cnt].update_del_flag = 1
        ELSE
         cds->activity[cnt].update_del_flag = 9
        ENDIF
       ENDIF
      OF "ICNARCCMPADULTAUDIT":
       IF ( NOT (ce.result_status_cd=inerror_cd
        AND cbc4.cds_batch_content_id=0))
        cnt += 1
        IF (cnt > size(cds->activity,5))
         stat = alterlist(cds->activity,(cnt+ 499))
        ENDIF
        cds->activity[cnt].cds_batch_id = 0.0, cds->activity[cnt].cds_batch_content_id = cbc4
        .cds_batch_content_id, cds->activity[cnt].parent_entity_id = ce.event_id,
        cds->activity[cnt].parent_entity_name = clineventstring, cds->activity[cnt].encntr_org_id = e
        .organization_id, cds->activity[cnt].cds_type_cd = cdsadultint_cd,
        cds->activity[cnt].encntr_id = e.encntr_id, cds->activity[cnt].cds_row_error_ind = cbc4
        .cds_row_error_ind
        IF (ce.result_status_cd=inerror_cd)
         cds->activity[cnt].update_del_flag = 1
        ELSE
         cds->activity[cnt].update_del_flag = 9
        ENDIF
       ENDIF
      OF "ADULTCCMDSAUDIT":
       IF ( NOT (ce.result_status_cd=inerror_cd
        AND cbc5.cds_batch_content_id=0))
        cnt += 1
        IF (cnt > size(cds->activity,5))
         stat = alterlist(cds->activity,(cnt+ 499))
        ENDIF
        cds->activity[cnt].cds_batch_id = 0.0, cds->activity[cnt].cds_batch_content_id = cbc5
        .cds_batch_content_id, cds->activity[cnt].parent_entity_id = ce.event_id,
        cds->activity[cnt].parent_entity_name = clineventstring, cds->activity[cnt].encntr_org_id = e
        .organization_id, cds->activity[cnt].cds_type_cd = cdsadultext_cd,
        cds->activity[cnt].encntr_id = e.encntr_id, cds->activity[cnt].cds_row_error_ind = cbc5
        .cds_row_error_ind
        IF (ce.result_status_cd=inerror_cd)
         cds->activity[cnt].update_del_flag = 1
        ELSE
         cds->activity[cnt].update_del_flag = 9
        ENDIF
       ENDIF
     ENDCASE
    DETAIL
     start = 1, idx = 0, rowfound = locateval(idx,start,size(cds->activity,5),es.encntr_slice_id,cds
      ->activity[idx].parent_entity_id)
     IF (rowfound=0)
      cnt += 1
      IF (cnt > size(cds->activity,5))
       stat = alterlist(cds->activity,(cnt+ 499))
      ENDIF
      cds->activity[cnt].cds_batch_content_id = cbc.cds_batch_content_id, cds->activity[cnt].
      cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].parent_entity_id = es.encntr_slice_id,
      cds->activity[cnt].parent_entity_name = encntrslicestring, cds->activity[cnt].encntr_id = cbc
      .encntr_id, cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind,
      cds->activity[cnt].encntr_org_id = e.organization_id, cds->activity[cnt].cds_type_cd = cbc
      .cds_type_cd, cds->activity[cnt].activity_dt_tm = cbc.activity_dt_tm,
      cds->activity[cnt].transaction_type_cd = f_ge_ccc_updt_cd, cds->activity[cnt].suppress_ind =
      cbc.suppress_ind
      IF (es.active_ind=1)
       cds->activity[cnt].update_del_flag = 9
      ELSE
       cds->activity[cnt].update_del_flag = 1
      ENDIF
     ENDIF
    FOOT  ce.event_id
     null
    FOOT REPORT
     stat = alterlist(cds->activity,cnt)
    WITH nocounter
   ;end select
   IF (size(cds->activity,5)=0)
    CALL echo("No CDS Activity. Skipping CCMDS Queries ...")
   ELSE
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
      scd_story ss,
      scd_term st,
      scd_term_data std,
      scr_term_definition stdef
     PLAN (d
      WHERE (cds->activity[d.seq].parent_entity_name=clineventstring)
       AND (cds->activity[d.seq].cds_type_cd IN (cdspaediatricint_cd, cdspaediatricext_cd,
      cdsadultint_cd, cdsadultext_cd, cdsneonatalint_cd,
      cdsneonatalext_cd)))
      JOIN (ss
      WHERE (ss.event_id=cds->activity[d.seq].parent_entity_id)
       AND ss.active_ind=1)
      JOIN (st
      WHERE st.scd_story_id=ss.scd_story_id
       AND st.end_effective_dt_tm=cnvtdatetime(null_dt_tm)
       AND st.active_ind=1)
      JOIN (std
      WHERE std.scd_term_data_id=st.scd_term_data_id)
      JOIN (stdef
      WHERE stdef.scr_term_def_id=st.scr_term_id
       AND stdef.scr_term_def_type_cd=resulttext_cd
       AND stdef.scr_term_def_key="UKR"
       AND stdef.def_text IN ("PICANET!0005", "CCMDS!0194"))
     ORDER BY d.seq
     HEAD d.seq
      cds->activity[d.seq].activity_dt_tm = std.value_dt_tm
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
      scd_story ss,
      scd_term st,
      scd_term_data std,
      clinical_event ce,
      ce_date_result cdr
     PLAN (d
      WHERE (cds->activity[d.seq].parent_entity_name=clineventstring)
       AND (cds->activity[d.seq].cds_type_cd IN (cdspaediatricint_cd, cdspaediatricext_cd,
      cdsadultint_cd, cdsadultext_cd, cdsneonatalint_cd,
      cdsneonatalext_cd))
       AND (cds->activity[d.seq].activity_dt_tm=0))
      JOIN (ss
      WHERE (ss.event_id=cds->activity[d.seq].parent_entity_id)
       AND ss.active_ind=1)
      JOIN (st
      WHERE st.scd_story_id=ss.scd_story_id
       AND st.end_effective_dt_tm=cnvtdatetime(null_dt_tm)
       AND st.active_ind=1)
      JOIN (std
      WHERE std.scd_term_data_id=st.scd_term_data_id)
      JOIN (ce
      WHERE ce.event_id=std.fkey_id
       AND ce.event_cd=cc_startdatetime_cd
       AND  NOT (ce.result_status_cd IN (ce_inerror_cd, ce_inerror_noview_cd, ce_inerror_nomut_cd,
      ce_cancelled_cd))
       AND ce.valid_until_dt_tm=cnvtdatetime(null_dt_tm))
      JOIN (cdr
      WHERE cdr.event_id=ce.event_id
       AND cdr.valid_until_dt_tm=cnvtdatetime(null_dt_tm))
     ORDER BY d.seq
     HEAD d.seq
      cds->activity[d.seq].activity_dt_tm = cdr.result_dt_tm
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(cds->activity,5)))
     PLAN (d
      WHERE (cds->activity[d.seq].parent_entity_name=clineventstring)
       AND (cds->activity[d.seq].cds_type_cd IN (cdspaediatricint_cd, cdspaediatricext_cd,
      cdsadultint_cd, cdsadultext_cd, cdsneonatalint_cd,
      cdsneonatalext_cd))
       AND (cds->activity[d.seq].activity_dt_tm=0))
     ORDER BY d.seq
     HEAD d.seq
      cds->activity[d.seq].delete_row_ind = 1
     WITH nocounter
    ;end select
    SET cds_cnt = size(cds->activity,5)
    SET loc = 1
    WHILE (loc <= cds_cnt)
      IF ((cds->activity[loc].delete_row_ind=1))
       SET cds_cnt -= 1
       SET stat = alterlist(cds->activity,cds_cnt,(loc - 1))
      ELSE
       SET loc += 1
      ENDIF
    ENDWHILE
   ENDIF
   SET stemp = concat("APC 4 complete. Qual = ",cnvtstring(curqual))
   CALL log_message(stemp,log_level_debug)
  ENDIF
  DECLARE consepattr_flag = vc WITH public, noconstant("")
  SET consepattr_flag = getoption1fieldvalue("CDSCEATTROPT")
  SET consepattr_flag = trim(cnvtupper(consepattr_flag),3)
  IF (consepattr_flag IN ("1", "Y", "YES", "ON"))
   SELECT INTO "nl:"
    FROM encntr_slice_act esa,
     encntr_slice es,
     encounter e,
     cds_batch_content cbc,
     person p
    PLAN (esa
     WHERE esa.updt_dt_tm >= cnvtdatetime(resetdate)
      AND esa.updt_dt_tm <= cnvtdatetime(reset_enddate))
     JOIN (es
     WHERE es.encntr_slice_id=esa.encntr_slice_id
      AND es.encntr_slice_type_cd=ce_slice_type
      AND es.active_ind=1)
     JOIN (e
     WHERE e.encntr_id=es.encntr_id
      AND expand(idx,1,encntr_types->apc_cnt,e.encntr_type_cd,encntr_types->apc[idx].episode_type_cd)
      AND parser(latestencntrselect)
      AND parser(eorgclause)
      AND e.active_ind=1)
     JOIN (p
     WHERE parser(testpatientexcclause))
     JOIN (cbc
     WHERE cbc.parent_entity_id=es.encntr_slice_id
      AND cbc.parent_entity_name=encntrslicestring
      AND cbc.update_del_flag=9
      AND parser(cbcorgclauseojoin))
    ORDER BY es.encntr_slice_id
    HEAD REPORT
     cnt = size(cds->activity,5)
    HEAD es.encntr_slice_id
     start = 1, rowfound = 0, rowfound = locateval(idx,start,size(cds->activity,5),es.encntr_slice_id,
      cds->activity[idx].parent_entity_id)
     IF (rowfound=0)
      cnt += 1
      IF (cnt > size(cds->activity,5))
       stat = alterlist(cds->activity,(cnt+ 499))
      ENDIF
      cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_batch_content_id =
      cbc.cds_batch_content_id, cds->activity[cnt].parent_entity_id = es.encntr_slice_id,
      cds->activity[cnt].parent_entity_name = encntrslicestring, cds->activity[cnt].encntr_org_id =
      cbc.organization_id, cds->activity[cnt].encntr_id = cbc.encntr_id,
      cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].
      update_del_flag = 9, cds->activity[cnt].activity_dt_tm = cbc.activity_dt_tm,
      cds->activity[cnt].cds_type_cd = cbc.cds_type_cd, cds->activity[cnt].suppress_ind = cbc
      .suppress_ind, cds->activity[cnt].transaction_type_cd = f_ge_sl_act_ch_cd
     ENDIF
    FOOT  es.encntr_slice_id
     null
    FOOT REPORT
     stat = alterlist(cds->activity,cnt)
    WITH nocounter
   ;end select
   SET stemp = concat("APC 5 complete. Qual = ",cnvtstring(curqual))
   CALL log_message(stemp,log_level_debug)
  ENDIF
  CALL log_message("--- APC Complete ---",log_level_debug)
 ENDIF
 IF ((cds_prompt_type->opa_flag=1))
  CALL log_message("--- Starting OPF ---",log_level_debug)
  SELECT INTO "nl:"
   FROM encounter e,
    sch_appt sa,
    sch_event_action sea,
    sch_event_patient sep,
    pm_wait_list pwl,
    person p,
    cds_batch_content cbc1,
    cds_batch_content cbc2
   PLAN (sa
    WHERE sa.updt_dt_tm >= cnvtdatetime(resetdate)
     AND sa.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND ((sa.sch_role_cd+ 0)=patient)
     AND trim(sa.role_meaning)=patientstring)
    JOIN (sea
    WHERE sea.sch_event_id=sa.sch_event_id
     AND sea.schedule_id=sa.schedule_id
     AND sea.action_dt_tm >= cnvtdatetime(resetdate)
     AND sea.action_dt_tm <= cnvtdatetime(reset_enddate))
    JOIN (sep
    WHERE sep.sch_event_id=sa.sch_event_id
     AND sep.version_dt_tm=cnvtdatetime(null_dt_tm)
     AND sep.active_ind=1)
    JOIN (e
    WHERE e.encntr_id=sep.encntr_id
     AND expand(idx,1,encntr_types->opa_cnt,(e.encntr_type_cd+ 0),encntr_types->opa[idx].
     episode_type_cd)
     AND e.active_ind=1
     AND parser(latestencntrselect)
     AND parser(eorgclause))
    JOIN (pwl
    WHERE (pwl.encntr_id= Outerjoin(e.encntr_id)) )
    JOIN (p
    WHERE parser(testpatientexcclause))
    JOIN (cbc1
    WHERE (cbc1.parent_entity_id= Outerjoin(pwl.pm_wait_list_id))
     AND (cbc1.parent_entity_name= Outerjoin(pmwaitliststring))
     AND (cbc1.cds_type_cd= Outerjoin(cds_021))
     AND parser(replace(cbcorgclauseojoin,"cbc","cbc1",0)))
    JOIN (cbc2
    WHERE (cbc2.parent_entity_id= Outerjoin(sa.schedule_id))
     AND (cbc2.parent_entity_name= Outerjoin(schschedulestring))
     AND (cbc2.cds_type_cd!= Outerjoin(cds_080))
     AND parser(replace(cbcorgclauseojoin,"cbc","cbc2",0)))
   ORDER BY sa.schedule_id
   HEAD REPORT
    cnt = size(cds->activity,5)
   HEAD sa.schedule_id
    num = 0, tmp_batch_content_id = 0.0, tmp_batch_id = 0.0,
    tmp_error_ind = 0, tmp_perm_del_ind = 0, tmp_fs_ident = "",
    tmp_fs_name = "", tmp_suppress_ind = 0
    IF (cbc1.cds_batch_content_id > 0)
     rowfound = locateval(num,1,size(cds->activity,5),cbc1.cds_batch_content_id,cds->activity[num].
      cds_batch_content_id)
     IF (rowfound > 0)
      rowfound = 0
     ELSE
      tmp_batch_content_id = cbc1.cds_batch_content_id, tmp_batch_id = cbc1.cds_batch_id,
      tmp_error_ind = cbc1.cds_row_error_ind,
      tmp_suppress_ind = cbc1.suppress_ind, tmp_fs_ident = cbc1.fs_parent_entity_ident, tmp_fs_name
       = cbc1.fs_parent_entity_name
     ENDIF
    ELSE
     IF (cbc2.cds_batch_content_id > 0)
      rowfound = locateval(num,1,size(cds->activity,5),sa.schedule_id,cds->activity[num].
       parent_entity_id,
       schschedulestring,cds->activity[num].parent_entity_name), tmp_batch_content_id = cbc2
      .cds_batch_content_id, tmp_batch_id = cbc2.cds_batch_id,
      tmp_error_ind = cbc2.cds_row_error_ind, tmp_suppress_ind = cbc2.suppress_ind, tmp_perm_del_ind
       = cbc2.permanent_del_ind,
      tmp_fs_ident = cbc2.fs_parent_entity_ident, tmp_fs_name = cbc2.fs_parent_entity_name
     ELSE
      rowfound = 0
     ENDIF
    ENDIF
    IF (tmp_perm_del_ind=0)
     IF (rowfound=0)
      cnt += 1
      IF (cnt > size(cds->activity,5))
       stat = alterlist(cds->activity,(cnt+ 499))
      ENDIF
      cds->activity[cnt].cds_batch_content_id = tmp_batch_content_id, cds->activity[cnt].cds_batch_id
       = tmp_batch_id, cds->activity[cnt].activity_dt_tm = sa.beg_dt_tm,
      cds->activity[cnt].parent_entity_id = sa.schedule_id, cds->activity[cnt].parent_entity_name =
      schschedulestring, cds->activity[cnt].encntr_id = e.encntr_id,
      cds->activity[cnt].update_del_flag = 9, cds->activity[cnt].encntr_org_id = e.organization_id,
      cds->activity[cnt].cds_row_error_ind = tmp_error_ind,
      cds->activity[cnt].suppress_ind = tmp_suppress_ind, cds->activity[cnt].transaction_type_cd =
      cons_op_f_appt_cd, cds->activity[cnt].fs_parent_entity_ident = tmp_fs_ident,
      cds->activity[cnt].fs_parent_entity_name = tmp_fs_name
      IF (sa.beg_dt_tm <= cnvtdatetime(create_dt_tm))
       cds->activity[cnt].cds_type_cd = cds_020
      ELSE
       cds->activity[cnt].cds_type_cd = cds_021
      ENDIF
     ENDIF
    ENDIF
   FOOT  sa.schedule_id
    null
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encounter e,
    sch_appt sa,
    sch_event_patient sep,
    cds_batch_content cbc
   PLAN (sa
    WHERE sa.beg_dt_tm >= cnvtdatetime(resetdate)
     AND sa.beg_dt_tm <= cnvtdatetime(reset_enddate)
     AND  NOT ( EXISTS (
    (SELECT
     sea.sch_event_id
     FROM sch_event_action sea
     WHERE sea.sch_event_id=sa.sch_event_id
      AND sea.schedule_id=sa.schedule_id
      AND  NOT (sea.sch_action_cd IN (view_cd, request_cd))
      AND sea.action_dt_tm >= cnvtdatetime(resetdate)
      AND sea.action_dt_tm <= cnvtdatetime(reset_enddate))))
     AND ((sa.sch_role_cd+ 0)=patient)
     AND trim(sa.role_meaning)=patientstring)
    JOIN (sep
    WHERE sep.sch_event_id=sa.sch_event_id
     AND sep.version_dt_tm=cnvtdatetime(null_dt_tm)
     AND sep.active_ind=1)
    JOIN (e
    WHERE e.encntr_id=sep.encntr_id
     AND e.active_ind=1
     AND parser(latestencntrselect)
     AND parser(eorgclause))
    JOIN (cbc
    WHERE cbc.parent_entity_id=sa.schedule_id
     AND cbc.parent_entity_name=schschedulestring
     AND cbc.permanent_del_ind=0
     AND cbc.cds_type_cd=cds_021)
   ORDER BY sa.schedule_id
   HEAD REPORT
    cnt = size(cds->activity,5)
   HEAD sa.schedule_id
    num = 0, rowfound = locateval(num,1,size(cds->activity,5),cbc.cds_batch_content_id,cds->activity[
     num].cds_batch_content_id)
    IF (rowfound=0)
     cnt += 1
     IF (cnt > size(cds->activity,5))
      stat = alterlist(cds->activity,(cnt+ 499))
     ENDIF
     cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_batch_content_id =
     cbc.cds_batch_content_id, cds->activity[cnt].activity_dt_tm = sa.beg_dt_tm,
     cds->activity[cnt].parent_entity_name = schschedulestring, cds->activity[cnt].parent_entity_id
      = sa.schedule_id, cds->activity[cnt].encntr_id = e.encntr_id,
     cds->activity[cnt].cds_type_cd = cds_020, cds->activity[cnt].encntr_org_id = cbc.organization_id,
     cds->activity[cnt].update_del_flag = 9,
     cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].suppress_ind =
     cbc.suppress_ind, cds->activity[cnt].transaction_type_cd = cons_op_a_appt_cd,
     cds->activity[cnt].fs_parent_entity_ident = cbc.fs_parent_entity_ident, cds->activity[cnt].
     fs_parent_entity_name = cbc.fs_parent_entity_name
    ENDIF
   FOOT  sa.schedule_id
    null
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
  IF (size(cds->activity,5)=0)
   CALL echo("No CDS Activity. Skipping OPA/OPF Queries ...")
  ELSE
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
     sch_appt sa,
     sch_event_action sea
    PLAN (d
     WHERE (cds->activity[d.seq].parent_entity_name=schschedulestring)
      AND (cds->activity[d.seq].cds_type_cd IN (cds_020, cds_021)))
     JOIN (sa
     WHERE (sa.schedule_id=cds->activity[d.seq].parent_entity_id)
      AND trim(sa.role_meaning)=patientstring)
     JOIN (sea
     WHERE sea.sch_event_id=sa.sch_event_id
      AND ((sea.schedule_id+ 0)=sa.schedule_id)
      AND ((sea.action_meaning IN (undocancel, undonoshow, undocheckin, shuffle, swapres)) OR (((sea
     .action_meaning IN (cancel, reschedule)
      AND sea.reason_meaning IN (systemcancel, automodify, modifyorder)) OR (sea.reason_meaning IN (
     adminerror, admin_error)
      AND sea.action_meaning != modify)) )) )
    ORDER BY d.seq
    HEAD d.seq
     IF ((cds->activity[d.seq].cds_batch_content_id > 0))
      cds->activity[d.seq].update_del_flag = 1, cds->activity[d.seq].delete_row_ind = 0, cds->
      activity[d.seq].permanent_del_ind = 1,
      cds->activity[d.seq].transaction_type_cd = op_sch_perm_rem_cd
     ELSE
      cds->activity[d.seq].delete_row_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF ( NOT (cdsdiagoverride_flag IN ("1", "Y", "YES", "ON")))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
      sch_appt sa,
      sch_event se,
      sch_appt_option sao,
      code_value_group cvg
     PLAN (d
      WHERE (cds->activity[d.seq].parent_entity_name=schschedulestring)
       AND (cds->activity[d.seq].cds_type_cd IN (cds_020, cds_021)))
      JOIN (sa
      WHERE (sa.schedule_id=cds->activity[d.seq].parent_entity_id)
       AND trim(sa.role_meaning)=patientstring)
      JOIN (se
      WHERE se.sch_event_id=sa.sch_event_id)
      JOIN (sao
      WHERE sao.appt_type_cd=se.appt_type_cd
       AND sao.beg_effective_dt_tm <= cnvtdatetime(update_dt_tm)
       AND sao.end_effective_dt_tm > cnvtdatetime(update_dt_tm)
       AND sao.active_ind=1)
      JOIN (cvg
      WHERE cvg.child_code_value=sao.sch_option_cd
       AND cvg.parent_code_value=diagapptexcl_cd)
     ORDER BY d.seq
     HEAD d.seq
      IF ((cds->activity[d.seq].cds_batch_content_id > 0))
       cds->activity[d.seq].update_del_flag = 1, cds->activity[d.seq].delete_row_ind = 0, cds->
       activity[d.seq].permanent_del_ind = 1,
       cds->activity[d.seq].transaction_type_cd = op_sch_perm_rem_cd
      ELSE
       cds->activity[d.seq].delete_row_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
     cds_batch_content cbc
    PLAN (d
     WHERE (cds->activity[d.seq].parent_entity_name=schschedulestring)
      AND (cds->activity[d.seq].cds_batch_content_id > 0.0)
      AND (cds->activity[d.seq].cds_type_cd IN (cds_020, cds_021))
      AND (cds->activity[d.seq].update_del_flag=1)
      AND (cds->activity[d.seq].delete_row_ind=0))
     JOIN (cbc
     WHERE (cbc.cds_batch_content_id=cds->activity[d.seq].cds_batch_content_id)
      AND cbc.parent_entity_name=pmwaitliststring
      AND cbc.update_del_flag=9)
    ORDER BY d.seq
    HEAD d.seq
     num = 0, row_found = locateval(num,1,size(cds->activity,5),cbc.encntr_id,cds->activity[num].
      encntr_id,
      1,evaluate2(
       IF ((cds->activity[num].cds_type_cd IN (cds_020, cds_021))) 1
       ELSE 0
       ENDIF
       ),1,evaluate2(
       IF ((cds->activity[num].update_del_flag=9)
        AND (cds->activity[num].delete_row_ind=0)) 1
       ELSE 0
       ENDIF
       ))
     IF (row_found <= 0)
      cds->activity[d.seq].activity_dt_tm = cnvtdatetime(d_appt_dt_tm), cds->activity[d.seq].
      cds_type_cd = cds_021, cds->activity[d.seq].update_del_flag = cbc.update_del_flag,
      cds->activity[d.seq].encntr_id = cbc.encntr_id, cds->activity[d.seq].encntr_org_id = cbc
      .organization_id, cds->activity[d.seq].parent_entity_name = cbc.parent_entity_name,
      cds->activity[d.seq].parent_entity_id = cbc.parent_entity_id, cds->activity[d.seq].
      cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[d.seq].delete_row_ind = 0,
      cds->activity[d.seq].suppress_ind = cbc.suppress_ind, cds->activity[d.seq].transaction_type_cd
       = res_missing_op_ref1_cd
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
     encounter e,
     encntr_loc_hist elh,
     pm_wait_list pwl
    PLAN (d
     WHERE (cds->activity[d.seq].parent_entity_name=schschedulestring)
      AND (cds->activity[d.seq].cds_type_cd IN (cds_020, cds_021))
      AND (((cds->activity[d.seq].update_del_flag=1)) OR ((cds->activity[d.seq].delete_row_ind=1)))
      AND textlen(trim(cds->activity[d.seq].fs_parent_entity_ident,3))=0)
     JOIN (e
     WHERE (e.encntr_id=cds->activity[d.seq].encntr_id)
      AND e.active_ind=1)
     JOIN (elh
     WHERE elh.encntr_id=e.encntr_id
      AND ((elh.encntr_type_cd+ 0)=op_referral_type)
      AND elh.active_ind=1)
     JOIN (pwl
     WHERE pwl.encntr_id=elh.encntr_id
      AND ((pwl.waiting_end_dt_tm = null) OR (pwl.waiting_end_dt_tm >= cnvtdatetime(resetdate)))
      AND  NOT ( EXISTS (
     (SELECT
      1
      FROM cds_batch_content cbc
      WHERE cbc.encntr_id=pwl.encntr_id
       AND (cbc.cds_batch_content_id != cds->activity[d.seq].cds_batch_content_id)
       AND cbc.cds_type_cd IN (cds_020, cds_021)
       AND cbc.update_del_flag=9))))
    ORDER BY pwl.pm_wait_list_id
    HEAD REPORT
     cnt = size(cds->activity,5)
    HEAD pwl.pm_wait_list_id
     num = 0, row_found = locateval(num,1,size(cds->activity,5),e.encntr_id,cds->activity[num].
      encntr_id,
      1,evaluate2(
       IF ((cds->activity[num].cds_type_cd IN (cds_020, cds_021))) 1
       ELSE 0
       ENDIF
       ),1,evaluate2(
       IF ((cds->activity[num].update_del_flag=9)
        AND (cds->activity[num].delete_row_ind=0)) 1
       ELSE 0
       ENDIF
       ))
     IF (row_found <= 0)
      cnt += 1
      IF (cnt > size(cds->activity,5))
       stat = alterlist(cds->activity,(cnt+ 499))
      ENDIF
      cds->activity[cnt].cds_batch_id = 0.0, cds->activity[cnt].cds_batch_content_id = 0.0, cds->
      activity[cnt].activity_dt_tm = cnvtdatetime(d_appt_dt_tm),
      cds->activity[cnt].cds_type_cd = cds_021, cds->activity[cnt].update_del_flag = 9, cds->
      activity[cnt].encntr_id = elh.encntr_id,
      cds->activity[cnt].encntr_org_id = elh.organization_id, cds->activity[cnt].parent_entity_name
       = pmwaitliststring, cds->activity[cnt].parent_entity_id = pwl.pm_wait_list_id,
      cds->activity[cnt].cds_row_error_ind = 0, cds->activity[cnt].suppress_ind = 0, cds->activity[
      cnt].transaction_type_cd = res_missing_op_ref2_cd
     ENDIF
    FOOT  pwl.pm_wait_list_id
     null
    FOOT REPORT
     stat = alterlist(cds->activity,cnt)
    WITH nocounter
   ;end select
   SET cds_cnt = size(cds->activity,5)
   SET loc = 1
   WHILE (loc <= cds_cnt)
     IF ((cds->activity[loc].delete_row_ind=1))
      SET cds_cnt -= 1
      SET stat = alterlist(cds->activity,cds_cnt,(loc - 1))
     ELSE
      SET loc += 1
     ENDIF
   ENDWHILE
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
     cds_batch_content cbc
    PLAN (d
     WHERE textlen(trim(cds->activity[d.seq].fs_parent_entity_ident,3))=0)
     JOIN (cbc
     WHERE (cbc.encntr_id=cds->activity[d.seq].encntr_id)
      AND textlen(trim(cbc.fs_parent_entity_ident,3)) > 0)
    DETAIL
     cds->activity[d.seq].fs_parent_entity_ident = cbc.fs_parent_entity_ident, cds->activity[d.seq].
     fs_parent_entity_name = cbc.fs_parent_entity_name
    WITH nocounter
   ;end select
  ENDIF
  SELECT INTO "nl:"
   FROM pm_wait_list pwl,
    encounter e,
    person p,
    cds_batch_content cbc,
    cds_batch_content cbc2
   PLAN (e
    WHERE e.updt_dt_tm >= cnvtdatetime(resetdate)
     AND e.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND ((e.encntr_type_cd+ 0)=op_referral_type)
     AND e.active_ind=1
     AND parser(latestencntrselect)
     AND parser(eorgclause)
     AND  NOT ( EXISTS (
    (SELECT
     1
     FROM sch_appt sa
     WHERE sa.encntr_id=e.encntr_id))))
    JOIN (pwl
    WHERE pwl.encntr_id=e.encntr_id
     AND ((pwl.waiting_end_dt_tm = null) OR (pwl.waiting_end_dt_tm >= cnvtdatetime(resetdate))) )
    JOIN (p
    WHERE parser(testpatientexcclause))
    JOIN (cbc
    WHERE (cbc.encntr_id= Outerjoin(e.encntr_id))
     AND (cbc.parent_entity_name= Outerjoin(pmwaitliststring))
     AND (cbc.cds_type_cd= Outerjoin(cds_021))
     AND parser(cbcorgclauseojoin))
    JOIN (cbc2
    WHERE (cbc2.parent_entity_id= Outerjoin(e.encntr_id))
     AND (cbc2.parent_entity_name= Outerjoin(encountercrstring))
     AND (cbc2.cds_type_cd= Outerjoin(cds_021))
     AND parser(cbcorgclauseojoin2))
   ORDER BY pwl.pm_wait_list_id
   HEAD REPORT
    cnt = size(cds->activity,5)
   HEAD pwl.pm_wait_list_id
    cnt += 1
    IF (cnt > size(cds->activity,5))
     stat = alterlist(cds->activity,(cnt+ 499))
    ENDIF
    IF (cbc2.cds_batch_content_id > 0.0)
     cds->activity[cnt].cds_batch_id = cbc2.cds_batch_id, cds->activity[cnt].cds_batch_content_id =
     cbc2.cds_batch_content_id, cds->activity[cnt].suppress_ind = cbc2.suppress_ind,
     cds->activity[cnt].cds_row_error_ind = cbc2.cds_row_error_ind, cds->activity[cnt].
     parent_entity_name = cbc2.parent_entity_name, cds->activity[cnt].parent_entity_id = cbc2
     .parent_entity_id,
     cds->activity[cnt].fs_parent_entity_ident = cbc2.fs_parent_entity_ident, cds->activity[cnt].
     fs_parent_entity_name = cbc2.fs_parent_entity_name
    ELSE
     cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_batch_content_id =
     cbc.cds_batch_content_id, cds->activity[cnt].suppress_ind = cbc.suppress_ind,
     cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].
     parent_entity_name = pmwaitliststring, cds->activity[cnt].parent_entity_id = pwl.pm_wait_list_id
    ENDIF
    cds->activity[cnt].activity_dt_tm = cnvtdatetime(d_appt_dt_tm), cds->activity[cnt].cds_type_cd =
    cds_021, cds->activity[cnt].update_del_flag = 9,
    cds->activity[cnt].encntr_id = e.encntr_id, cds->activity[cnt].encntr_org_id = e.organization_id,
    cds->activity[cnt].transaction_type_cd = cons_op_ref_only_cd
   FOOT  pwl.pm_wait_list_id
    null
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
  CALL log_message("--- OPF Complete ---",log_level_debug)
 ENDIF
 IF ((cds_prompt_type->ae_flag=1))
  DECLARE ecds_swon_date_opt = vc WITH public, noconstant("")
  DECLARE ecds_valid_dt = dq8 WITH public, noconstant(0.0)
  SET ecds_swon_date_opt = getoption1fieldvalue("CDSECDSSWON")
  IF (textlen(trim(ecds_swon_date_opt,3)) > 0)
   SET ecds_valid_dt = cnvtdatetime(cnvtdate2(trim(ecds_swon_date_opt,3),"DD-MMM-YYYY"),0)
  ENDIF
  CALL log_message("--- Starting AE ---",log_level_debug)
  DECLARE ae_apc_clause = vc WITH protect, noconstant(
   "expand(idx,1,encntr_types->AE_cnt,e.encntr_type_cd+0 ,encntr_types->AE[idx].episode_type_cd)")
  IF (checkdic("PM_WAIT_LIST.FROM_ED_IND","A",0) > 0)
   SET ae_apc_clause = build2(ae_apc_clause," or exists (select 1")
   SET ae_apc_clause = build2(ae_apc_clause," from pm_wait_list pwl")
   SET ae_apc_clause = build2(ae_apc_clause," where pwl.encntr_id = e.encntr_id")
   SET ae_apc_clause = build2(ae_apc_clause," and pwl.from_ed_ind = 1 )")
  ENDIF
  SELECT INTO "nl:"
   FROM encounter e,
    person p,
    cds_batch_content cbc,
    cds_batch_content cbc2
   PLAN (e
    WHERE e.updt_dt_tm >= cnvtdatetime(resetdate)
     AND e.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND parser(ae_apc_clause)
     AND parser(latestencntrselect)
     AND parser(eorgclause))
    JOIN (p
    WHERE parser(testpatientexcclause))
    JOIN (cbc
    WHERE (cbc.parent_entity_id= Outerjoin(e.encntr_id))
     AND (cbc.parent_entity_name= Outerjoin(encounterstring))
     AND (cbc.cds_type_cd= Outerjoin(cds_010))
     AND parser(cbcorgclauseojoin))
    JOIN (cbc2
    WHERE (cbc2.parent_entity_id= Outerjoin(e.encntr_id))
     AND (cbc2.parent_entity_name= Outerjoin(encounterstring))
     AND (cbc2.cds_type_cd= Outerjoin(cds_011))
     AND parser(cbcorgclauseojoin2))
   ORDER BY e.encntr_id
   HEAD REPORT
    cnt = size(cds->activity,5), stat = alterlist(cds->activity,(cnt+ 1999))
   HEAD e.encntr_id
    tmp_activity_dt_tm = evaluate(e.arrive_dt_tm,0.0,e.reg_dt_tm,e.arrive_dt_tm)
    IF (ecds_switch IN (0, 2))
     cnt += 1
     IF (cnt > size(cds->activity,5))
      stat = alterlist(cds->activity,(cnt+ 499))
     ENDIF
     cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_batch_content_id =
     cbc.cds_batch_content_id, cds->activity[cnt].parent_entity_id = e.encntr_id,
     cds->activity[cnt].parent_entity_name = encounterstring, cds->activity[cnt].encntr_org_id = e
     .organization_id, cds->activity[cnt].encntr_id = e.encntr_id,
     cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].suppress_ind =
     cbc.suppress_ind, cds->activity[cnt].activity_dt_tm = tmp_activity_dt_tm,
     cds->activity[cnt].cds_type_cd = cds_010, cds->activity[cnt].transaction_type_cd = ae_attend_cd
     IF (e.active_ind=1)
      cds->activity[cnt].update_del_flag = 9
     ELSE
      cds->activity[cnt].update_del_flag = 1
     ENDIF
    ENDIF
    IF (ecds_switch IN (1, 2))
     IF (tmp_activity_dt_tm >= ecds_valid_dt)
      cnt += 1
      IF (cnt > size(cds->activity,5))
       stat = alterlist(cds->activity,(cnt+ 499))
      ENDIF
      cds->activity[cnt].cds_batch_id = cbc2.cds_batch_id, cds->activity[cnt].cds_batch_content_id =
      cbc2.cds_batch_content_id, cds->activity[cnt].parent_entity_id = e.encntr_id,
      cds->activity[cnt].parent_entity_name = encounterstring, cds->activity[cnt].encntr_org_id = e
      .organization_id, cds->activity[cnt].encntr_id = e.encntr_id,
      cds->activity[cnt].cds_row_error_ind = cbc2.cds_row_error_ind, cds->activity[cnt].suppress_ind
       = cbc2.suppress_ind, cds->activity[cnt].activity_dt_tm = tmp_activity_dt_tm,
      cds->activity[cnt].cds_type_cd = cds_011, cds->activity[cnt].transaction_type_cd = ae_attend_cd
      IF (e.active_ind=1)
       cds->activity[cnt].update_del_flag = 9
      ELSE
       cds->activity[cnt].update_del_flag = 1
      ENDIF
     ENDIF
    ENDIF
   FOOT  e.encntr_id
    null
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
  SET stemp = concat("AE 1 complete. Qual = ",cnvtstring(curqual))
  CALL log_message(stemp,log_level_debug)
  SELECT INTO "nl:"
   FROM tracking_checkin tc,
    tracking_item ti,
    encounter e,
    person p,
    cds_batch_content cbc,
    code_value cv
   PLAN (tc
    WHERE tc.updt_dt_tm >= cnvtdatetime(resetdate)
     AND tc.updt_dt_tm <= cnvtdatetime(reset_enddate))
    JOIN (ti
    WHERE ti.tracking_id=tc.tracking_id)
    JOIN (e
    WHERE e.encntr_id=ti.encntr_id
     AND expand(idx,1,encntr_types->ae_apc_cnt,(e.encntr_type_cd+ 0),encntr_types->ae_apc[idx].
     episode_type_cd)
     AND parser(latestencntrselect)
     AND parser(eorgclause))
    JOIN (p
    WHERE parser(testpatientexcclause))
    JOIN (cbc
    WHERE cbc.parent_entity_id=e.encntr_id
     AND cbc.parent_entity_name=encounterstring
     AND parser(cbcorgclause))
    JOIN (cv
    WHERE cv.code_value=tc.tracking_group_cd
     AND cv.cdf_meaning="ER")
   ORDER BY e.encntr_id, cbc.cds_type_cd
   HEAD REPORT
    cnt = size(cds->activity,5), stat = alterlist(cds->activity,(cnt+ 1999))
   HEAD e.encntr_id
    null
   HEAD cbc.cds_type_cd
    IF (((cbc.cds_type_cd=cds_010
     AND ecds_switch IN (0, 2)) OR (cbc.cds_type_cd=cds_011
     AND ecds_switch IN (1, 2))) )
     start = 1, rowfound = 0, rowfound = locateval(idx,start,size(cds->activity,5),cbc
      .cds_batch_content_id,cds->activity[idx].cds_batch_content_id)
     IF (rowfound=0)
      cnt += 1
      IF (cnt > size(cds->activity,5))
       stat = alterlist(cds->activity,(cnt+ 499))
      ENDIF
      cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_batch_content_id =
      cbc.cds_batch_content_id, cds->activity[cnt].parent_entity_id = cbc.parent_entity_id,
      cds->activity[cnt].parent_entity_name = encounterstring, cds->activity[cnt].encntr_org_id = cbc
      .organization_id, cds->activity[cnt].encntr_id = cbc.encntr_id,
      cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].suppress_ind
       = cbc.suppress_ind, cds->activity[cnt].activity_dt_tm = cbc.activity_dt_tm,
      cds->activity[cnt].cds_type_cd = cbc.cds_type_cd, cds->activity[cnt].transaction_type_cd =
      ae_track_cd
      IF (e.active_ind=1)
       cds->activity[cnt].update_del_flag = 9
      ELSE
       cds->activity[cnt].update_del_flag = 1
      ENDIF
     ENDIF
    ENDIF
   FOOT  cbc.cds_type_cd
    null
   FOOT  e.encntr_id
    null
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
  SET stemp = concat("AE 2 complete. Qual = ",cnvtstring(curqual))
  CALL log_message(stemp,log_level_debug)
  CALL log_message("--- AE Complete ---",log_level_debug)
 ENDIF
 IF ((cds_prompt_type->eal_flag=1))
  CALL log_message("--- Starting EAL ---",log_level_debug)
  SELECT INTO "nl:"
   FROM pm_wait_list pwl,
    encounter e,
    person p,
    cds_batch_content cbc
   PLAN (e
    WHERE e.updt_dt_tm >= cnvtdatetime(resetdate)
     AND e.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND expand(idx,1,encntr_types->eal_cnt,(e.encntr_type_cd+ 0),encntr_types->eal[idx].
     episode_type_cd)
     AND parser(latestencntrselect)
     AND parser(eorgclause))
    JOIN (pwl
    WHERE pwl.encntr_id=e.encntr_id
     AND pwl.updt_dt_tm >= cnvtdatetime(resetdate)
     AND pwl.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND pwl.admit_type_cd > 0
     AND pwl.admit_type_cd IN (waitlist_pwl_cd, booked_pwl_cd, planned_pwl_cd))
    JOIN (p
    WHERE parser(testpatientexcclause))
    JOIN (cbc
    WHERE (cbc.parent_entity_id= Outerjoin(pwl.pm_wait_list_id))
     AND (cbc.cds_type_cd= Outerjoin(cds_060))
     AND parser(cbcorgclauseojoin))
   ORDER BY pwl.pm_wait_list_id, 0
   HEAD REPORT
    cnt = size(cds->activity,5), stat = alterlist(cds->activity,(cnt+ 1999))
   HEAD pwl.pm_wait_list_id
    cnt += 1
    IF (cnt > size(cds->activity,5))
     stat = alterlist(cds->activity,(cnt+ 499))
    ENDIF
    cds->activity[cnt].cds_type_cd = cds_060, cds->activity[cnt].cds_batch_content_id = cbc
    .cds_batch_content_id, cds->activity[cnt].cds_batch_id = cbc.cds_batch_id,
    cds->activity[cnt].parent_entity_id = pwl.pm_wait_list_id, cds->activity[cnt].parent_entity_name
     = pmwaitliststring, cds->activity[cnt].encntr_org_id = e.organization_id,
    cds->activity[cnt].encntr_id = e.encntr_id, cds->activity[cnt].cds_row_error_ind = cbc
    .cds_row_error_ind, cds->activity[cnt].suppress_ind = cbc.suppress_ind,
    cds->activity[cnt].transaction_type_cd = eal_add_cd
    IF (e.active_ind=0)
     cds->activity[cnt].update_del_flag = 1
    ELSE
     cds->activity[cnt].update_del_flag = 9
    ENDIF
    IF (pwl.admit_decision_dt_tm IS NOT null)
     cds->activity[cnt].activity_dt_tm = pwl.admit_decision_dt_tm
    ELSE
     cds->activity[cnt].activity_dt_tm = pwl.active_status_dt_tm
    ENDIF
   FOOT  pwl.pm_wait_list_id
    null
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
  SET stemp = concat("EAL 1 complete. Qual = ",cnvtstring(curqual))
  CALL log_message(stemp,log_level_debug)
  SELECT INTO "nl:"
   FROM encounter e,
    cds_batch_content cbc,
    person p,
    pm_wait_list pwl,
    encntr_loc_hist elh
   PLAN (e
    WHERE e.updt_dt_tm >= cnvtdatetime(resetdate)
     AND e.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND expand(idx,1,encntr_types->apc_eal_cnt,(e.encntr_type_cd+ 0),encntr_types->apc_eal[idx].
     episode_type_cd)
     AND parser(latestencntrselect)
     AND parser(eorgclause))
    JOIN (elh
    WHERE elh.encntr_id=e.encntr_id
     AND elh.encntr_type_cd IN (ip_wl_type, daycase_wl_type)
     AND elh.active_ind=1)
    JOIN (pwl
    WHERE pwl.encntr_id=elh.encntr_id
     AND pwl.admit_decision_dt_tm IS NOT null)
    JOIN (p
    WHERE parser(testpatientexcclause))
    JOIN (cbc
    WHERE (cbc.parent_entity_id= Outerjoin(pwl.pm_wait_list_id))
     AND (cbc.cds_type_cd= Outerjoin(cds_060))
     AND parser(cbcorgclauseojoin)
     AND cbc.cds_batch_content_id = null)
   ORDER BY pwl.pm_wait_list_id
   HEAD REPORT
    cnt = size(cds->activity,5), stat = alterlist(cds->activity,(cnt+ 1999))
   HEAD pwl.pm_wait_list_id
    rowfound = locateval(idx,start,size(cds->activity,5),pwl.pm_wait_list_id,cds->activity[idx].
     parent_entity_id,
     cds_060,cds->activity[idx].cds_type_cd)
    IF (rowfound=0
     AND ((pwl.admit_type_cd IN (waitlist_pwl_cd, booked_pwl_cd, planned_pwl_cd)) OR (e.admit_type_cd
     IN (waitlist_pwl_cd, booked_pwl_cd, planned_pwl_cd))) )
     cnt += 1
     IF (cnt > size(cds->activity,5))
      stat = alterlist(cds->activity,(cnt+ 499))
     ENDIF
     cds->activity[cnt].cds_type_cd = cds_060, cds->activity[cnt].cds_batch_content_id = cbc
     .cds_batch_content_id, cds->activity[cnt].cds_batch_id = cbc.cds_batch_id,
     cds->activity[cnt].parent_entity_id = pwl.pm_wait_list_id, cds->activity[cnt].parent_entity_name
      = pmwaitliststring, cds->activity[cnt].encntr_org_id = e.organization_id,
     cds->activity[cnt].encntr_id = e.encntr_id, cds->activity[cnt].cds_row_error_ind = cbc
     .cds_row_error_ind, cds->activity[cnt].suppress_ind = cbc.suppress_ind,
     cds->activity[cnt].transaction_type_cd = eal_add_rem_same_day_cd, cds->activity[cnt].
     activity_dt_tm = pwl.admit_decision_dt_tm
     IF (e.active_ind=0)
      cds->activity[cnt].update_del_flag = 1
     ELSE
      cds->activity[cnt].update_del_flag = 9
     ENDIF
    ENDIF
   FOOT  pwl.pm_wait_list_id
    null
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
  SET stemp = concat("EAL 1.2 complete. Qual = ",cnvtstring(curqual))
  CALL log_message(stemp,log_level_debug)
  SELECT INTO "nl:"
   FROM sch_appt sa,
    sch_event se,
    sch_event_action sea,
    pm_wait_list pwl,
    encounter e,
    person p,
    cds_batch_content cbc
   PLAN (sa
    WHERE sa.updt_dt_tm >= cnvtdatetime(resetdate)
     AND sa.updt_dt_tm <= cnvtdatetime(reset_enddate))
    JOIN (se
    WHERE se.sch_event_id=sa.sch_event_id)
    JOIN (sea
    WHERE sea.sch_event_id=sa.sch_event_id
     AND sea.schedule_id=sa.schedule_id
     AND sea.action_dt_tm >= cnvtdatetime(resetdate)
     AND sea.action_dt_tm <= cnvtdatetime(reset_enddate))
    JOIN (pwl
    WHERE pwl.encntr_id=sa.encntr_id
     AND pwl.admit_type_cd IN (waitlist_pwl_cd, booked_pwl_cd, planned_pwl_cd)
     AND pwl.admit_type_cd > 0)
    JOIN (e
    WHERE e.encntr_id=pwl.encntr_id
     AND expand(idx,1,encntr_types->apc_eal_cnt,e.encntr_type_cd,encntr_types->apc_eal[idx].
     episode_type_cd)
     AND parser(latestencntrselect)
     AND parser(eorgclause))
    JOIN (p
    WHERE parser(testpatientexcclause))
    JOIN (cbc
    WHERE (cbc.parent_entity_id= Outerjoin(sa.schedule_id))
     AND (cbc.parent_entity_name= Outerjoin(schschedulestring))
     AND (cbc.permanent_del_ind= Outerjoin(0))
     AND parser(cbcorgclauseojoin))
   ORDER BY sa.encntr_id, sa.schedule_id, 0
   HEAD REPORT
    cnt = size(cds->activity,5), stat = alterlist(cds->activity,(cnt+ 1999))
   HEAD sa.encntr_id
    initial_admission_ind = 0
   HEAD sa.schedule_id
    null
   FOOT  sa.schedule_id
    IF (((dis_rd_att_fv IN ("1", "Y", "YES", "ON")) OR (((se.appt_type_cd=initial_cd) OR (se
    .appt_type_cd != subsequent_cd
     AND initial_admission_ind=0)) )) )
     IF (se.appt_type_cd=initial_cd)
      initial_admission_ind = 1
     ENDIF
     cnt += 1
     IF (cnt > size(cds->activity,5))
      stat = alterlist(cds->activity,(cnt+ 499))
     ENDIF
     cds->activity[cnt].cds_type_cd = cds_080, cds->activity[cnt].parent_entity_id = sa.schedule_id,
     cds->activity[cnt].parent_entity_name = schschedulestring,
     cds->activity[cnt].cds_batch_content_id = cbc.cds_batch_content_id, cds->activity[cnt].
     cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].encntr_org_id = e.organization_id,
     cds->activity[cnt].encntr_id = e.encntr_id, cds->activity[cnt].cds_row_error_ind = cbc
     .cds_row_error_ind, cds->activity[cnt].suppress_ind = cbc.suppress_ind,
     cds->activity[cnt].transaction_type_cd = eal_offer_cd, cds->activity[cnt].activity_dt_tm = pwl
     .provisional_admit_dt_tm
     IF (e.active_ind=0)
      cds->activity[cnt].update_del_flag = 1
     ELSE
      cds->activity[cnt].update_del_flag = 9
     ENDIF
    ENDIF
   FOOT  sa.encntr_id
    null
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encounter e,
    sch_appt sa,
    cds_batch_content cbc,
    cds_batch_content cbc2
   PLAN (sa
    WHERE sa.beg_dt_tm >= cnvtdatetime(resetdate)
     AND sa.beg_dt_tm <= cnvtdatetime(reset_enddate)
     AND  NOT ( EXISTS (
    (SELECT
     sea.sch_event_id
     FROM sch_event_action sea
     WHERE sea.sch_event_id=sa.sch_event_id
      AND sea.schedule_id=sa.schedule_id
      AND  NOT (sea.sch_action_cd IN (view_cd, request_cd))
      AND sea.action_dt_tm >= cnvtdatetime(resetdate)
      AND sea.action_dt_tm <= cnvtdatetime(reset_enddate))))
     AND ((sa.sch_role_cd+ 0)=patient)
     AND trim(sa.role_meaning)=patientstring)
    JOIN (e
    WHERE e.encntr_id=sa.encntr_id
     AND e.active_ind=1
     AND parser(latestencntrselect)
     AND parser(eorgclause))
    JOIN (cbc
    WHERE cbc.parent_entity_id=sa.schedule_id
     AND cbc.parent_entity_name=schschedulestring
     AND cbc.cds_type_cd=cds_080
     AND cbc.permanent_del_ind=0)
    JOIN (cbc2
    WHERE cbc2.encntr_id=e.encntr_id
     AND cbc2.parent_entity_name=pmwaitliststring
     AND cbc2.cds_type_cd=cds_060)
   ORDER BY sa.schedule_id
   HEAD REPORT
    cnt = size(cds->activity,5)
   HEAD sa.schedule_id
    num = 0, rowfound = locateval(num,1,size(cds->activity,5),cbc.cds_batch_content_id,cds->activity[
     num].cds_batch_content_id)
    IF (rowfound=0)
     cnt += 1
     IF (cnt > size(cds->activity,5))
      stat = alterlist(cds->activity,(cnt+ 499))
     ENDIF
     cds->activity[cnt].cds_batch_id = 0.0, cds->activity[cnt].cds_batch_content_id = cbc
     .cds_batch_content_id, cds->activity[cnt].activity_dt_tm = cbc.activity_dt_tm,
     cds->activity[cnt].parent_entity_name = cbc.parent_entity_name, cds->activity[cnt].
     parent_entity_id = cbc.parent_entity_id, cds->activity[cnt].encntr_id = cbc.encntr_id,
     cds->activity[cnt].cds_type_cd = cbc.cds_type_cd, cds->activity[cnt].encntr_org_id = cbc
     .organization_id, cds->activity[cnt].update_del_flag = cbc.update_del_flag,
     cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].suppress_ind =
     cbc.suppress_ind, cds->activity[cnt].transaction_type_cd = eal_retrig_tci_pass_cd
    ENDIF
    rowfound = locateval(num,1,size(cds->activity,5),cbc2.cds_batch_content_id,cds->activity[num].
     cds_batch_content_id)
    IF (rowfound=0)
     cnt += 1
     IF (cnt > size(cds->activity,5))
      stat = alterlist(cds->activity,(cnt+ 499))
     ENDIF
     cds->activity[cnt].cds_batch_id = 0.0, cds->activity[cnt].cds_batch_content_id = cbc2
     .cds_batch_content_id, cds->activity[cnt].activity_dt_tm = cbc2.activity_dt_tm,
     cds->activity[cnt].parent_entity_name = cbc2.parent_entity_name, cds->activity[cnt].
     parent_entity_id = cbc2.parent_entity_id, cds->activity[cnt].encntr_id = cbc2.encntr_id,
     cds->activity[cnt].cds_type_cd = cbc2.cds_type_cd, cds->activity[cnt].encntr_org_id = cbc2
     .organization_id, cds->activity[cnt].update_del_flag = cbc2.update_del_flag,
     cds->activity[cnt].cds_row_error_ind = cbc2.cds_row_error_ind, cds->activity[cnt].suppress_ind
      = cbc2.suppress_ind, cds->activity[cnt].transaction_type_cd = eal_retrig_tci_pass_cd
    ENDIF
   FOOT  sa.schedule_id
    null
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
  SET stemp = concat("EAL 2 complete. Qual = ",cnvtstring(curqual))
  CALL log_message(stemp,log_level_debug)
  IF (size(cds->activity,5)=0)
   CALL echo("No CDS Activity. Skipping EAL 080 Queries ...")
  ELSE
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
     sch_appt sa,
     sch_event_action sea
    PLAN (d
     WHERE (cds->activity[d.seq].parent_entity_name=schschedulestring)
      AND (cds->activity[d.seq].cds_type_cd=cds_080))
     JOIN (sa
     WHERE (sa.schedule_id=cds->activity[d.seq].parent_entity_id)
      AND trim(sa.role_meaning)=patientstring)
     JOIN (sea
     WHERE sea.sch_event_id=sa.sch_event_id
      AND ((sea.schedule_id+ 0)=sa.schedule_id)
      AND ((sea.action_meaning IN (shuffle, swapres)) OR (((sea.action_meaning IN (cancel, reschedule
     )
      AND sea.reason_meaning IN (systemcancel, automodify, modifyorder)) OR (sea.reason_meaning IN (
     adminerror, admin_error)
      AND sea.action_meaning != modify)) )) )
    ORDER BY d.seq
    HEAD d.seq
     IF ((cds->activity[d.seq].cds_batch_content_id > 0))
      cds->activity[d.seq].update_del_flag = 1, cds->activity[d.seq].delete_row_ind = 0, cds->
      activity[d.seq].permanent_del_ind = 1,
      cds->activity[d.seq].transaction_type_cd = ip_sch_perm_rem_cd
     ELSE
      cds->activity[d.seq].delete_row_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
     sch_appt sa,
     sch_event se,
     sch_appt_option sao,
     code_value_group cvg
    PLAN (d
     WHERE (cds->activity[d.seq].parent_entity_name=schschedulestring)
      AND (cds->activity[d.seq].cds_type_cd=cds_080))
     JOIN (sa
     WHERE (sa.schedule_id=cds->activity[d.seq].parent_entity_id)
      AND trim(sa.role_meaning)=patientstring)
     JOIN (se
     WHERE se.sch_event_id=sa.sch_event_id)
     JOIN (sao
     WHERE sao.appt_type_cd=se.appt_type_cd
      AND sao.beg_effective_dt_tm <= cnvtdatetime(update_dt_tm)
      AND sao.end_effective_dt_tm > cnvtdatetime(update_dt_tm)
      AND sao.active_ind=1)
     JOIN (cvg
     WHERE cvg.child_code_value=sao.sch_option_cd
      AND cvg.parent_code_value=diagapptexcl_cd)
    ORDER BY d.seq
    HEAD d.seq
     IF ((cds->activity[d.seq].cds_batch_content_id > 0))
      cds->activity[d.seq].update_del_flag = 1, cds->activity[d.seq].delete_row_ind = 0, cds->
      activity[d.seq].permanent_del_ind = 1,
      cds->activity[d.seq].transaction_type_cd = ip_sch_perm_rem_cd
     ELSE
      cds->activity[d.seq].delete_row_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   SET cds_cnt = size(cds->activity,5)
   SET loc = 1
   WHILE (loc <= cds_cnt)
     IF ((cds->activity[loc].delete_row_ind=1))
      SET cds_cnt -= 1
      SET stat = alterlist(cds->activity,cds_cnt,(loc - 1))
     ELSE
      SET loc += 1
     ENDIF
   ENDWHILE
  ENDIF
  SELECT INTO "nl:"
   FROM pm_wait_list_status pwls,
    pm_wait_list pwl,
    encounter e,
    person p,
    cds_batch_content cbc
   PLAN (pwls
    WHERE pwls.updt_dt_tm >= cnvtdatetime(resetdate)
     AND pwls.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND pwls.status_cd=suspend_cd
     AND pwls.active_ind=1)
    JOIN (pwl
    WHERE pwl.pm_wait_list_id=pwls.pm_wait_list_id
     AND pwl.admit_type_cd > 0)
    JOIN (e
    WHERE e.encntr_id=pwl.encntr_id
     AND parser(latestencntrselect)
     AND parser(eorgclause))
    JOIN (p
    WHERE parser(testpatientexcclause))
    JOIN (cbc
    WHERE (cbc.parent_entity_id= Outerjoin(pwls.pm_wait_list_status_id))
     AND parser(cbcorgclauseojoin)
     AND (cbc.cds_type_cd= Outerjoin(cds_090)) )
   ORDER BY pwls.pm_wait_list_status_id, 0
   HEAD REPORT
    cnt = size(cds->activity,5), stat = alterlist(cds->activity,(cnt+ 1999))
   DETAIL
    cnt += 1
    IF (cnt > size(cds->activity,5))
     stat = alterlist(cds->activity,(cnt+ 499))
    ENDIF
    cds->activity[cnt].cds_type_cd = cds_090, cds->activity[cnt].parent_entity_id = pwls
    .pm_wait_list_status_id, cds->activity[cnt].parent_entity_name = pmwaitliststatusstring,
    cds->activity[cnt].cds_batch_content_id = cbc.cds_batch_content_id, cds->activity[cnt].
    cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].encntr_org_id = e.organization_id,
    cds->activity[cnt].encntr_id = e.encntr_id, cds->activity[cnt].cds_row_error_ind = cbc
    .cds_row_error_ind, cds->activity[cnt].suppress_ind = cbc.suppress_ind,
    cds->activity[cnt].transaction_type_cd = eal_susp_cd, cds->activity[cnt].activity_dt_tm = pwls
    .status_dt_tm
    IF (e.active_ind=0)
     cds->activity[cnt].update_del_flag = 1
    ELSE
     cds->activity[cnt].update_del_flag = 9
    ENDIF
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
  SET stemp = concat("EAL 3 complete. Qual = ",cnvtstring(curqual))
  CALL log_message(stemp,log_level_debug)
  SET stemp = concat("EAL 4a complete. Qual = ",cnvtstring(curqual))
  CALL log_message(stemp,log_level_debug)
  IF (column_exists(pmwaitliststatusstring,activeindstring))
   SELECT INTO "nl:"
    FROM pm_wait_list pwl,
     pm_wait_list_status pwls,
     cds_batch_content cbc
    PLAN (pwl
     WHERE pwl.updt_dt_tm >= cnvtdatetime(resetdate)
      AND pwl.updt_dt_tm <= cnvtdatetime(reset_enddate))
     JOIN (cbc
     WHERE cbc.encntr_id=pwl.encntr_id
      AND cbc.parent_entity_name=pmwaitliststatusstring
      AND parser(cbcorgclause)
      AND cbc.cds_type_cd=cds_090
      AND cbc.update_del_flag=9)
     JOIN (pwls
     WHERE pwls.pm_wait_list_status_id=cbc.parent_entity_id
      AND pwls.active_ind=0)
    HEAD REPORT
     cnt = size(cds->activity,5), stat = alterlist(cds->activity,(cnt+ 1999))
    DETAIL
     cnt += 1
     IF (cnt > size(cds->activity,5))
      stat = alterlist(cds->activity,(cnt+ 499))
     ENDIF
     cds->activity[cnt].cds_type_cd = cds_090, cds->activity[cnt].parent_entity_id = cbc
     .parent_entity_id, cds->activity[cnt].parent_entity_name = cbc.parent_entity_name,
     cds->activity[cnt].cds_batch_content_id = cbc.cds_batch_content_id, cds->activity[cnt].
     cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].encntr_org_id = cbc.organization_id,
     cds->activity[cnt].encntr_id = cbc.encntr_id, cds->activity[cnt].update_del_flag = 1, cds->
     activity[cnt].activity_dt_tm = pwl.updt_dt_tm,
     cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].suppress_ind =
     cbc.suppress_ind, cds->activity[cnt].transaction_type_cd = eal_susp_cd
    FOOT REPORT
     stat = alterlist(cds->activity,cnt)
    WITH nocounter
   ;end select
   SET stemp = concat("EAL 4b complete. Qual = ",cnvtstring(curqual))
   CALL log_message(stemp,log_level_debug)
  ENDIF
  SELECT INTO "nl:"
   FROM pm_wait_list pwl,
    encounter e,
    person p,
    cds_batch_content cbc,
    cds_batch_content cbc2,
    pm_transaction pmt
   PLAN (e
    WHERE e.updt_dt_tm >= cnvtdatetime(resetdate)
     AND e.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND expand(idx,1,encntr_types->apc_eal_cnt,(e.encntr_type_cd+ 0),encntr_types->apc_eal[idx].
     episode_type_cd)
     AND e.reg_dt_tm IS NOT null
     AND parser(latestencntrselect)
     AND parser(eorgclause))
    JOIN (pwl
    WHERE pwl.encntr_id=e.encntr_id
     AND pwl.waiting_end_dt_tm IS NOT null
     AND ((pwl.admit_type_cd+ 0) > 0))
    JOIN (p
    WHERE parser(testpatientexcclause))
    JOIN (cbc
    WHERE (cbc.parent_entity_id= Outerjoin(pwl.pm_wait_list_id))
     AND parser(cbcorgclauseojoin)
     AND (cbc.cds_type_cd= Outerjoin(cds_070)) )
    JOIN (cbc2
    WHERE (cbc2.parent_entity_id= Outerjoin(pwl.pm_wait_list_id))
     AND parser(cbcorgclauseojoin2)
     AND (cbc2.cds_type_cd= Outerjoin(cds_060)) )
    JOIN (pmt
    WHERE pmt.n_encntr_id=e.encntr_id
     AND pmt.activity_dt_tm >= cnvtdatetime(resetdate)
     AND pmt.activity_dt_tm <= cnvtdatetime(reset_enddate)
     AND ((pmt.o_reg_dt_tm != pmt.n_reg_dt_tm) OR (pmt.o_reg_dt_tm = null
     AND pmt.n_reg_dt_tm IS NOT null)) )
   ORDER BY pwl.pm_wait_list_id
   HEAD REPORT
    cnt = size(cds->activity,5)
   HEAD pwl.pm_wait_list_id
    start = 1, rowfound = 0
    IF (cbc2.cds_batch_content_id > 0)
     cnt += 1
     IF (cnt > size(cds->activity,5))
      stat = alterlist(cds->activity,(cnt+ 499))
     ENDIF
     cds->activity[cnt].cds_batch_content_id = cbc.cds_batch_content_id, cds->activity[cnt].
     cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_type_cd = cds_070,
     cds->activity[cnt].encntr_id = e.encntr_id, cds->activity[cnt].parent_entity_id = pwl
     .pm_wait_list_id, cds->activity[cnt].parent_entity_name = pmwaitliststring
     IF (e.active_ind=0)
      cds->activity[cnt].update_del_flag = 1
     ELSE
      cds->activity[cnt].update_del_flag = 9
     ENDIF
     cds->activity[cnt].activity_dt_tm = pwl.waiting_end_dt_tm, cds->activity[cnt].encntr_org_id = e
     .organization_id, cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind,
     cds->activity[cnt].suppress_ind = cbc.suppress_ind, cds->activity[cnt].transaction_type_cd =
     eal_rem_adm_cd
    ELSE
     rowfound = locateval(rowfound,start,size(cds->activity,5),cds_060,cds->activity[rowfound].
      cds_type_cd,
      pwl.pm_wait_list_id,cds->activity[rowfound].parent_entity_id)
     IF (rowfound > 0)
      cnt += 1
      IF (cnt > size(cds->activity,5))
       stat = alterlist(cds->activity,(cnt+ 499))
      ENDIF
      cds->activity[cnt].cds_batch_content_id = cbc.cds_batch_content_id, cds->activity[cnt].
      cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_type_cd = cds_070,
      cds->activity[cnt].encntr_id = e.encntr_id, cds->activity[cnt].parent_entity_id = pwl
      .pm_wait_list_id, cds->activity[cnt].parent_entity_name = pmwaitliststring
      IF (e.active_ind=0)
       cds->activity[cnt].update_del_flag = 1
      ELSE
       cds->activity[cnt].update_del_flag = 9
      ENDIF
      cds->activity[cnt].activity_dt_tm = pwl.waiting_end_dt_tm, cds->activity[cnt].encntr_org_id = e
      .organization_id, cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind,
      cds->activity[cnt].suppress_ind = cbc.suppress_ind, cds->activity[cnt].transaction_type_cd =
      eal_rem_adm_cd
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
  SET stemp = concat("EAL 5.1 complete. Qual = ",cnvtstring(curqual))
  CALL log_message(stemp,log_level_debug)
  SELECT INTO "nl:"
   FROM pm_wait_list pwl,
    encounter e,
    person p,
    cds_batch_content cbc
   PLAN (pwl
    WHERE pwl.updt_dt_tm >= cnvtdatetime(resetdate)
     AND pwl.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND pwl.removal_dt_tm IS NOT null
     AND pwl.waiting_end_dt_tm IS NOT null)
    JOIN (e
    WHERE (e.encntr_id=(pwl.encntr_id+ 0))
     AND expand(idx,1,encntr_types->eal_cnt,e.encntr_type_cd,encntr_types->eal[idx].episode_type_cd)
     AND e.active_ind=1
     AND e.reg_dt_tm = null)
    JOIN (p
    WHERE parser(testpatientexcclause))
    JOIN (cbc
    WHERE (cbc.parent_entity_id= Outerjoin(pwl.pm_wait_list_id))
     AND parser(cbcorgclauseojoin)
     AND (cbc.cds_type_cd= Outerjoin(cds_070)) )
   ORDER BY pwl.pm_wait_list_id
   HEAD REPORT
    cnt = size(cds->activity,5)
   HEAD pwl.pm_wait_list_id
    cnt += 1
    IF (cnt > size(cds->activity,5))
     stat = alterlist(cds->activity,(cnt+ 499))
    ENDIF
    cds->activity[cnt].cds_batch_content_id = cbc.cds_batch_content_id, cds->activity[cnt].
    cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_type_cd = cds_070,
    cds->activity[cnt].encntr_id = e.encntr_id, cds->activity[cnt].parent_entity_id = pwl
    .pm_wait_list_id, cds->activity[cnt].parent_entity_name = pmwaitliststring,
    cds->activity[cnt].update_del_flag = 9, cds->activity[cnt].activity_dt_tm = pwl.waiting_end_dt_tm,
    cds->activity[cnt].encntr_org_id = e.organization_id,
    cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].suppress_ind =
    cbc.suppress_ind, cds->activity[cnt].transaction_type_cd = eal_rem_cancel_cd
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
  SET stemp = concat("EAL 5.2 complete. Qual = ",cnvtstring(curqual))
  CALL log_message(stemp,log_level_debug)
  SELECT INTO "nl:"
   FROM pm_wait_list pwl,
    encounter e,
    person p,
    cds_batch_content cbc
   PLAN (pwl
    WHERE pwl.updt_dt_tm >= cnvtdatetime(resetdate)
     AND pwl.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND pwl.removal_dt_tm = null
     AND pwl.waiting_end_dt_tm = null)
    JOIN (e
    WHERE e.encntr_id=pwl.encntr_id
     AND e.active_ind=1
     AND e.reg_dt_tm = null)
    JOIN (p
    WHERE parser(testpatientexcclause))
    JOIN (cbc
    WHERE cbc.parent_entity_id=pwl.pm_wait_list_id
     AND parser(cbcorgclause)
     AND cbc.cds_type_cd=cds_070
     AND cbc.update_del_flag=9)
   ORDER BY pwl.pm_wait_list_id
   HEAD REPORT
    cnt = size(cds->activity,5)
   HEAD pwl.pm_wait_list_id
    cnt += 1
    IF (cnt > size(cds->activity,5))
     stat = alterlist(cds->activity,(cnt+ 499))
    ENDIF
    cds->activity[cnt].cds_batch_content_id = cbc.cds_batch_content_id, cds->activity[cnt].
    cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_type_cd = cds_070,
    cds->activity[cnt].encntr_id = e.encntr_id, cds->activity[cnt].parent_entity_id = pwl
    .pm_wait_list_id, cds->activity[cnt].parent_entity_name = pmwaitliststring,
    cds->activity[cnt].update_del_flag = 1, cds->activity[cnt].activity_dt_tm = cbc.activity_dt_tm,
    cds->activity[cnt].encntr_org_id = e.organization_id,
    cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].suppress_ind =
    cbc.suppress_ind, cds->activity[cnt].transaction_type_cd = eal_reinst_del_rem_cd
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
  SET stemp = concat("EAL 5.3 complete. Qual = ",cnvtstring(curqual))
  CALL log_message(stemp,log_level_debug)
  SELECT INTO "nl:"
   FROM pm_wait_list pwl,
    encounter e,
    person p,
    cds_batch_content cbc1,
    sch_appt sa,
    sch_event se,
    sch_event_action sea,
    cds_batch_content cbc2
   PLAN (e
    WHERE e.updt_dt_tm >= cnvtdatetime(resetdate)
     AND e.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND expand(idx,1,encntr_types->apc_eal_cnt,(e.encntr_type_cd+ 0),encntr_types->apc_eal[idx].
     episode_type_cd)
     AND e.disch_dt_tm IS NOT null
     AND parser(latestencntrselect)
     AND parser(eorgclause)
     AND e.active_ind=1)
    JOIN (pwl
    WHERE pwl.encntr_id=e.encntr_id
     AND pwl.updt_dt_tm >= cnvtdatetime(resetdate)
     AND pwl.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND pwl.admit_type_cd IN (waitlist_pwl_cd, booked_pwl_cd, planned_pwl_cd)
     AND pwl.admit_offer_outcome_cd > 0)
    JOIN (p
    WHERE parser(testpatientexcclause))
    JOIN (cbc1
    WHERE cbc1.parent_entity_id=pwl.pm_wait_list_id
     AND cbc1.cds_type_cd=cds_060
     AND parser(replace(cbcorgclause,"cbc","cbc1",0)))
    JOIN (sa
    WHERE sa.encntr_id=e.encntr_id
     AND sa.role_meaning="PATIENT"
     AND sa.active_ind=1)
    JOIN (se
    WHERE parser(dis_rd_att_parser))
    JOIN (sea
    WHERE sea.sch_event_id=sa.sch_event_id
     AND sea.schedule_id=sa.schedule_id
     AND sea.action_meaning="CONFIRM")
    JOIN (cbc2
    WHERE cbc2.parent_entity_id=sa.schedule_id
     AND cbc2.cds_type_cd=cds_080
     AND parser(replace(cbcorgclause,"cbc","cbc2",0))
     AND cbc2.permanent_del_ind=0)
   ORDER BY sa.encntr_id, sea.action_dt_tm DESC
   HEAD REPORT
    cnt = size(cds->activity,5)
   DETAIL
    start = 1, rowfound = 0, idx = 0,
    rowfound = locateval(idx,start,size(cds->activity,5),cbc1.cds_batch_content_id,cds->activity[idx]
     .cds_batch_content_id)
    IF (rowfound=0)
     cnt += 1
     IF (cnt > size(cds->activity,5))
      stat = alterlist(cds->activity,(cnt+ 499))
     ENDIF
     cds->activity[cnt].cds_batch_content_id = cbc1.cds_batch_content_id, cds->activity[cnt].
     activity_dt_tm = cbc1.activity_dt_tm, cds->activity[cnt].parent_entity_name = cbc1
     .parent_entity_name,
     cds->activity[cnt].parent_entity_id = cbc1.parent_entity_id, cds->activity[cnt].encntr_id = cbc1
     .encntr_id, cds->activity[cnt].cds_type_cd = cbc1.cds_type_cd,
     cds->activity[cnt].cds_batch_id = cbc1.cds_batch_id, cds->activity[cnt].encntr_org_id = cbc1
     .organization_id, cds->activity[cnt].update_del_flag = cbc1.update_del_flag,
     cds->activity[cnt].cds_row_error_ind = cbc1.cds_row_error_ind, cds->activity[cnt].suppress_ind
      = cbc1.suppress_ind, cds->activity[cnt].transaction_type_cd = eal_retrig_act_aoo_cd,
     start = 1, rowfound = 0, idx = 0,
     rowfound = locateval(idx,start,size(cds->activity,5),cbc2.cds_batch_content_id,cds->activity[idx
      ].cds_batch_content_id)
     IF (rowfound=0)
      cnt += 1
      IF (cnt > size(cds->activity,5))
       stat = alterlist(cds->activity,(cnt+ 499))
      ENDIF
      cds->activity[cnt].cds_batch_content_id = cbc2.cds_batch_content_id, cds->activity[cnt].
      activity_dt_tm = cbc2.activity_dt_tm, cds->activity[cnt].parent_entity_name = cbc2
      .parent_entity_name,
      cds->activity[cnt].parent_entity_id = cbc2.parent_entity_id, cds->activity[cnt].encntr_id =
      cbc2.encntr_id, cds->activity[cnt].cds_type_cd = cbc2.cds_type_cd,
      cds->activity[cnt].cds_batch_id = cbc2.cds_batch_id, cds->activity[cnt].encntr_org_id = cbc2
      .organization_id, cds->activity[cnt].update_del_flag = cbc2.update_del_flag,
      cds->activity[cnt].cds_row_error_ind = cbc2.cds_row_error_ind, cds->activity[cnt].suppress_ind
       = cbc2.suppress_ind, cds->activity[cnt].transaction_type_cd = eal_retrig_act_aoo_cd
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
  IF (checkdic("PM_OFFER","T",0) > 0)
   SELECT INTO "nl:"
    FROM pm_offer po,
     encounter e,
     person p,
     cds_batch_content cbc
    PLAN (po
     WHERE po.updt_dt_tm >= cnvtdatetime(resetdate)
      AND po.updt_dt_tm <= cnvtdatetime(reset_enddate)
      AND po.active_ind=1
      AND ((po.schedule_id+ 0) != 0))
     JOIN (e
     WHERE e.encntr_id=po.encntr_id
      AND expand(idx,1,encntr_types->apc_eal_cnt,(e.encntr_type_cd+ 0),encntr_types->apc_eal[idx].
      episode_type_cd)
      AND parser(latestencntrselect)
      AND parser(eorgclause)
      AND e.active_ind=1)
     JOIN (p
     WHERE parser(testpatientexcclause))
     JOIN (cbc
     WHERE cbc.parent_entity_id=po.schedule_id
      AND cbc.parent_entity_name="SCH_SCHEDULE"
      AND cbc.cds_type_cd=cds_080
      AND cbc.update_del_flag=9)
    HEAD REPORT
     cnt = size(cds->activity,5)
    DETAIL
     start = 1, rowfound = 0, idx = 0,
     rowfound = locateval(idx,start,size(cds->activity,5),cbc.cds_batch_content_id,cds->activity[idx]
      .cds_batch_content_id)
     IF (rowfound=0)
      cnt += 1
      IF (cnt > size(cds->activity,5))
       stat = alterlist(cds->activity,(cnt+ 499))
      ENDIF
      cds->activity[cnt].cds_batch_content_id = cbc.cds_batch_content_id, cds->activity[cnt].
      activity_dt_tm = cbc.activity_dt_tm, cds->activity[cnt].parent_entity_name = cbc
      .parent_entity_name,
      cds->activity[cnt].parent_entity_id = cbc.parent_entity_id, cds->activity[cnt].encntr_id = cbc
      .encntr_id, cds->activity[cnt].cds_type_cd = cbc.cds_type_cd,
      cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].encntr_org_id = cbc
      .organization_id, cds->activity[cnt].update_del_flag = cbc.update_del_flag,
      cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].suppress_ind
       = cbc.suppress_ind, cds->activity[cnt].transaction_type_cd = eal_retrig_act_offer_cd
     ENDIF
    FOOT REPORT
     stat = alterlist(cds->activity,cnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM pm_offer po,
     encounter e,
     person p,
     cds_batch_content cbc
    PLAN (po
     WHERE po.updt_dt_tm >= cnvtdatetime(resetdate)
      AND po.updt_dt_tm <= cnvtdatetime(reset_enddate)
      AND ((po.schedule_id+ 0)=0)
      AND po.offer_type_cd=offer_auto_cd)
     JOIN (e
     WHERE e.encntr_id=po.encntr_id
      AND expand(idx,1,encntr_types->apc_eal_cnt,(e.encntr_type_cd+ 0),encntr_types->apc_eal[idx].
      episode_type_cd)
      AND parser(latestencntrselect)
      AND parser(eorgclause)
      AND e.active_ind=1)
     JOIN (p
     WHERE parser(testpatientexcclause))
     JOIN (cbc
     WHERE cbc.encntr_id=e.encntr_id
      AND cbc.cds_type_cd IN (cds_060, cds_080)
      AND cbc.update_del_flag=9)
    HEAD REPORT
     cnt = size(cds->activity,5)
    DETAIL
     start = 1, rowfound = 0, idx = 0,
     rowfound = locateval(idx,start,size(cds->activity,5),cbc.cds_batch_content_id,cds->activity[idx]
      .cds_batch_content_id)
     IF (rowfound=0)
      cnt += 1
      IF (cnt > size(cds->activity,5))
       stat = alterlist(cds->activity,(cnt+ 499))
      ENDIF
      cds->activity[cnt].cds_batch_content_id = cbc.cds_batch_content_id, cds->activity[cnt].
      activity_dt_tm = cbc.activity_dt_tm, cds->activity[cnt].parent_entity_name = cbc
      .parent_entity_name,
      cds->activity[cnt].parent_entity_id = cbc.parent_entity_id, cds->activity[cnt].encntr_id = cbc
      .encntr_id, cds->activity[cnt].cds_type_cd = cbc.cds_type_cd,
      cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].encntr_org_id = cbc
      .organization_id, cds->activity[cnt].update_del_flag = cbc.update_del_flag,
      cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].suppress_ind
       = cbc.suppress_ind, cds->activity[cnt].transaction_type_cd = eal_retrig_act_erod_cd
     ENDIF
    FOOT REPORT
     stat = alterlist(cds->activity,cnt)
    WITH nocounter
   ;end select
  ENDIF
  SELECT INTO "nl:"
   FROM orders o,
    sch_event_attach sett,
    sch_event_patient sep,
    cds_batch_content cbc
   PLAN (o
    WHERE o.updt_dt_tm >= cnvtdatetime(resetdate)
     AND o.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND o.updt_cnt > 0
     AND o.active_ind=1)
    JOIN (sett
    WHERE sett.order_id=o.order_id
     AND sett.active_ind=1
     AND sett.beg_effective_dt_tm <= cnvtdatetime(update_dt_tm)
     AND sett.end_effective_dt_tm > cnvtdatetime(update_dt_tm))
    JOIN (sep
    WHERE sep.sch_event_id=sett.sch_event_id
     AND ((sep.encntr_id+ 0) > 0.0)
     AND sep.active_ind=1
     AND sep.beg_effective_dt_tm <= cnvtdatetime(update_dt_tm)
     AND sep.end_effective_dt_tm > cnvtdatetime(update_dt_tm))
    JOIN (cbc
    WHERE cbc.encntr_id=sep.encntr_id
     AND cbc.cds_type_cd=cds_060
     AND cbc.update_del_flag=9)
   ORDER BY cbc.cds_batch_content_id
   HEAD REPORT
    cnt = size(cds->activity,5)
   HEAD cbc.cds_batch_content_id
    start = 1, rowfound = 0, idx = 0,
    rowfound = locateval(idx,start,size(cds->activity,5),cbc.cds_batch_content_id,cds->activity[idx].
     cds_batch_content_id)
    IF (rowfound=0)
     cnt += 1
     IF (cnt > size(cds->activity,5))
      stat = alterlist(cds->activity,(cnt+ 499))
     ENDIF
     cds->activity[cnt].cds_batch_content_id = cbc.cds_batch_content_id, cds->activity[cnt].
     activity_dt_tm = cbc.activity_dt_tm, cds->activity[cnt].parent_entity_name = cbc
     .parent_entity_name,
     cds->activity[cnt].parent_entity_id = cbc.parent_entity_id, cds->activity[cnt].encntr_id = cbc
     .encntr_id, cds->activity[cnt].cds_type_cd = cbc.cds_type_cd,
     cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].encntr_org_id = cbc
     .organization_id, cds->activity[cnt].update_del_flag = cbc.update_del_flag,
     cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].suppress_ind =
     cbc.suppress_ind, cds->activity[cnt].transaction_type_cd = g_proc_retr_updt_cd
    ENDIF
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((cds_prompt_type->adc_flag=1))
  FREE RECORD temp_ce
  RECORD temp_ce(
    1 qual_cnt = i4
    1 qual[*]
      2 ce_id = f8
  )
  IF (checkdic("EPISODE_ACTIVITY","T",0) > 0)
   SELECT INTO "nl:"
    FROM episode_activity epa,
     encounter e,
     person p,
     cds_batch_content cbc
    PLAN (epa
     WHERE parser(rtt_parser)
      AND epa.activity_cd=ep_act_admin_type_cd
      AND epa.created_by_ce_event_id > 0)
     JOIN (e
     WHERE e.encntr_id=epa.created_by_encntr_id
      AND parser(eorgclause)
      AND e.active_ind=1)
     JOIN (p
     WHERE parser(testpatientexcclause))
     JOIN (cbc
     WHERE cbc.parent_entity_id=epa.created_by_ce_event_id
      AND cbc.parent_entity_name=clineventstring
      AND parser(cbcorgclause))
    HEAD REPORT
     cnt = size(cds->activity,5), stat = alterlist(cds->activity,(cnt+ 499)), temp_ce->qual_cnt = 0
    HEAD epa.episode_activity_id
     cnt += 1
     IF (cnt > size(cds->activity,5))
      stat = alterlist(cds->activity,(cnt+ 499))
     ENDIF
     IF ( NOT (e.encntr_type_cd IN (community_cd, community_ref_cd)))
      cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_batch_content_id =
      cbc.cds_batch_content_id, cds->activity[cnt].parent_entity_id = epa.episode_activity_id,
      cds->activity[cnt].parent_entity_name = episodeactivitystring, cds->activity[cnt].encntr_org_id
       = e.organization_id, cds->activity[cnt].encntr_id = e.encntr_id,
      cds->activity[cnt].cds_type_cd = cds_0201, cds->activity[cnt].activity_dt_tm = epa
      .activity_dt_tm, cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind,
      cds->activity[cnt].suppress_ind = cbc.suppress_ind, cds->activity[cnt].transaction_type_cd =
      admin_ce_epa_cd
      IF (epa.active_ind=0)
       cds->activity[cnt].update_del_flag = 1
      ELSE
       cds->activity[cnt].update_del_flag = 9
      ENDIF
      temp_ce->qual_cnt += 1
      IF ((temp_ce->qual_cnt > size(temp_ce->qual,5)))
       stat = alterlist(temp_ce->qual,(temp_ce->qual_cnt+ 499))
      ENDIF
      temp_ce->qual[temp_ce->qual_cnt].ce_id = epa.created_by_ce_event_id
     ENDIF
    FOOT  epa.episode_activity_id
     null
    FOOT REPORT
     stat = alterlist(cds->activity,cnt), stat = alterlist(temp_ce->qual,temp_ce->qual_cnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM episode_activity epa,
     encounter e,
     person p,
     cds_batch_content cbc
    PLAN (epa
     WHERE parser(rtt_parser)
      AND epa.activity_cd IN (ep_act_admin_type_cd, ep_act_pm_admin_type_cd)
      AND epa.created_by_encntr_id > 0)
     JOIN (e
     WHERE e.encntr_id=epa.created_by_encntr_id
      AND parser(eorgclause)
      AND e.active_ind=1)
     JOIN (p
     WHERE parser(testpatientexcclause))
     JOIN (cbc
     WHERE (cbc.parent_entity_id= Outerjoin(epa.episode_activity_id))
      AND (cbc.parent_entity_name= Outerjoin(episodeactivitystring))
      AND parser(cbcorgclauseojoin))
    HEAD REPORT
     cnt = size(cds->activity,5), stat = alterlist(cds->activity,(cnt+ 499))
    HEAD epa.episode_activity_id
     IF (((locateval(idx,1,temp_ce->qual_cnt,epa.created_by_ce_event_id,temp_ce->qual[idx].ce_id)=0)
      OR (epa.created_by_ce_event_id=0)) )
      IF ( NOT (e.encntr_type_cd IN (community_cd, community_ref_cd)))
       cnt += 1
       IF (cnt > size(cds->activity,5))
        stat = alterlist(cds->activity,(cnt+ 499))
       ENDIF
       cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_batch_content_id =
       cbc.cds_batch_content_id, cds->activity[cnt].parent_entity_id = epa.episode_activity_id,
       cds->activity[cnt].parent_entity_name = episodeactivitystring, cds->activity[cnt].
       encntr_org_id = e.organization_id, cds->activity[cnt].encntr_id = e.encntr_id,
       cds->activity[cnt].cds_type_cd = cds_0201, cds->activity[cnt].activity_dt_tm = epa
       .activity_dt_tm, cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind,
       cds->activity[cnt].suppress_ind = cbc.suppress_ind, cds->activity[cnt].transaction_type_cd =
       admin_gen_cd
       IF (epa.active_ind=0)
        cds->activity[cnt].update_del_flag = 1
       ELSE
        cds->activity[cnt].update_del_flag = 9
       ENDIF
       IF (epa.created_by_ce_event_id > 0)
        temp_ce->qual_cnt += 1
        IF ((temp_ce->qual_cnt > size(temp_ce->qual,5)))
         stat = alterlist(temp_ce->qual,(temp_ce->qual_cnt+ 499))
        ENDIF
        temp_ce->qual[temp_ce->qual_cnt].ce_id = epa.created_by_ce_event_id
       ENDIF
      ENDIF
     ENDIF
    FOOT  epa.episode_activity_id
     null
    FOOT REPORT
     stat = alterlist(cds->activity,cnt), stat = alterlist(temp_ce->qual,temp_ce->qual_cnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM episode_activity epa,
     encounter e,
     person p,
     cds_batch_content cbc,
     episode_encntr_reltn eer
    PLAN (epa
     WHERE parser(rtt_parser)
      AND epa.activity_cd=deceased_type_cd
      AND epa.activity_type_cd=stop_type_cd)
     JOIN (eer
     WHERE eer.episode_id=epa.episode_id
      AND eer.beg_effective_dt_tm <= cnvtdatetime(update_dt_tm)
      AND eer.end_effective_dt_tm > cnvtdatetime(update_dt_tm)
      AND eer.active_ind=1)
     JOIN (e
     WHERE e.encntr_id=eer.encntr_id
      AND parser(eorgclause)
      AND e.active_ind=1)
     JOIN (p
     WHERE parser(testpatientexcclause))
     JOIN (cbc
     WHERE (cbc.parent_entity_id= Outerjoin(epa.episode_activity_id))
      AND (cbc.parent_entity_name= Outerjoin(episodeactivitystring))
      AND parser(cbcorgclauseojoin))
    ORDER BY epa.episode_activity_id, e.create_dt_tm DESC
    HEAD REPORT
     cnt = size(cds->activity,5), stat = alterlist(cds->activity,(cnt+ 499))
    HEAD epa.episode_activity_id
     cnt += 1
     IF (cnt > size(cds->activity,5))
      stat = alterlist(cds->activity,(cnt+ 499))
     ENDIF
     IF ( NOT (e.encntr_type_cd IN (community_cd, community_ref_cd)))
      cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_batch_content_id =
      cbc.cds_batch_content_id, cds->activity[cnt].parent_entity_id = epa.episode_activity_id,
      cds->activity[cnt].parent_entity_name = episodeactivitystring, cds->activity[cnt].encntr_org_id
       = e.organization_id, cds->activity[cnt].encntr_id = e.encntr_id,
      cds->activity[cnt].cds_type_cd = cds_0201, cds->activity[cnt].activity_dt_tm = epa
      .activity_dt_tm, cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind,
      cds->activity[cnt].suppress_ind = cbc.suppress_ind, cds->activity[cnt].transaction_type_cd =
      admin_dec_cd
      IF (epa.active_ind=0)
       cds->activity[cnt].update_del_flag = 1
      ELSE
       cds->activity[cnt].update_del_flag = 9
      ENDIF
     ENDIF
    FOOT  epa.episode_activity_id
     null
    FOOT REPORT
     stat = alterlist(cds->activity,cnt), stat = alterlist(temp_ce->qual,temp_ce->qual_cnt)
    WITH nocounter
   ;end select
  ENDIF
  SELECT INTO "nl:"
   FROM clinical_event ce,
    encounter e,
    person p,
    dcp_forms_activity_comp dfac,
    dcp_forms_activity dfa,
    clinical_event ce2,
    clinical_event ce3,
    ce_date_result cdr,
    cds_batch_content cbc
   PLAN (ce
    WHERE ce.updt_dt_tm >= cnvtdatetime(resetdate)
     AND ce.updt_dt_tm < cnvtdatetime(reset_enddate)
     AND ((ce.event_cd+ 0)=rtt_status_form_cd)
     AND ce.valid_until_dt_tm=cnvtdatetime(abs_valid_until_dt_tm))
    JOIN (e
    WHERE e.encntr_id=ce.encntr_id
     AND parser(eorgclause)
     AND e.active_ind=1)
    JOIN (p
    WHERE parser(testpatientexcclause))
    JOIN (dfac
    WHERE dfac.parent_entity_id=ce.event_id
     AND dfac.parent_entity_name="CLINICAL_EVENT")
    JOIN (dfa
    WHERE dfa.dcp_forms_activity_id=dfac.dcp_forms_activity_id
     AND dfa.description=dfa_rtt_form_desc
     AND dfa.form_status_cd IN (auth_cd, modified_cd, inerror_cd))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce.event_id
     AND ((ce2.event_cd+ 0)=dcp_gen_cd)
     AND ce2.valid_until_dt_tm=cnvtdatetime(abs_valid_until_dt_tm))
    JOIN (ce3
    WHERE ce3.parent_event_id=ce2.event_id
     AND ce3.event_cd=rtt_activity_dt_ce_code
     AND ce3.valid_until_dt_tm=cnvtdatetime(abs_valid_until_dt_tm))
    JOIN (cdr
    WHERE cdr.event_id=ce3.event_id
     AND cdr.valid_until_dt_tm=cnvtdatetime(abs_valid_until_dt_tm))
    JOIN (cbc
    WHERE (cbc.parent_entity_id= Outerjoin(ce.event_id))
     AND (cbc.parent_entity_name= Outerjoin(clineventstring))
     AND parser(cbcorgclauseojoin))
   ORDER BY ce.event_id
   HEAD REPORT
    cnt = size(cds->activity,5), stat = alterlist(cds->activity,(cnt+ 499))
   HEAD ce.event_id
    IF (locateval(idx,1,temp_ce->qual_cnt,ce.event_id,temp_ce->qual[idx].ce_id)=0)
     cnt += 1
     IF (cnt > size(cds->activity,5))
      stat = alterlist(cds->activity,(cnt+ 499))
     ENDIF
     IF ( NOT (e.encntr_type_cd IN (community_cd, community_ref_cd)))
      cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_batch_content_id =
      cbc.cds_batch_content_id, cds->activity[cnt].parent_entity_id = ce.event_id,
      cds->activity[cnt].parent_entity_name = clineventstring, cds->activity[cnt].encntr_org_id = e
      .organization_id, cds->activity[cnt].encntr_id = e.encntr_id,
      cds->activity[cnt].cds_type_cd = cds_0201, cds->activity[cnt].activity_dt_tm = cdr.result_dt_tm,
      cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind,
      cds->activity[cnt].suppress_ind = cbc.suppress_ind, cds->activity[cnt].transaction_type_cd =
      admin_ce_cd
      IF (((e.active_ind=0) OR (dfa.form_status_cd=inerror_cd)) )
       cds->activity[cnt].update_del_flag = 1
      ELSE
       cds->activity[cnt].update_del_flag = 9
      ENDIF
     ENDIF
    ENDIF
   FOOT  ce.event_id
    null
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
  FREE RECORD ce_temp
 ENDIF
 SELECT INTO "nl:"
  FROM episode_activity epa,
   encounter e,
   person p,
   cds_batch_content cbc
  PLAN (epa
   WHERE parser(rtt_parser)
    AND epa.activity_cd IN (inp_wl_type_cd, cnc_appt_type_cd, cnc_tci_type_cd, chk_out_appt_type_cd,
   cab_op_appt_type_cd,
   cnf_op_appt_type_cd, cnf_tci_type_cd, dna_op_appt_type_cd, dna_tci_type_cd, disch_in_type_cd,
   rsch_op_appt_type_cd, ip_addm_type_cd, op_ref_type_cd, rsch_in_type_cd, comm_rf_cd,
   rej_comm_rf_cd, cancel_comm_cd, chk_out_comm_cd, confirm_comm_cd, no_show_comm_cd,
   rsch_comm_cd, wl_remove_type_cd)
    AND epa.created_by_encntr_id > 0
    AND epa.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=epa.created_by_encntr_id
    AND parser(eorgclause)
    AND e.active_ind=1)
   JOIN (p
   WHERE parser(testpatientexcclause))
   JOIN (cbc
   WHERE cbc.encntr_id=epa.created_by_encntr_id
    AND  NOT (cbc.cds_type_cd IN (cds_010, cds_011, cds_0201, cds_090))
    AND cbc.update_del_flag=9
    AND cbc.permanent_del_ind=0
    AND parser(cbcorgclause))
  ORDER BY epa.episode_activity_id, cbc.cds_batch_content_id
  HEAD REPORT
   cnt = size(cds->activity,5), stat = alterlist(cds->activity,(cnt+ 499))
  HEAD epa.episode_activity_id
   null
  DETAIL
   mark_for_retrigger = 0
   CASE (epa.activity_cd)
    OF inp_wl_type_cd:
     IF ((cds_prompt_type->eal_flag=1))
      IF (cbc.cds_type_cd IN (cds_060, cds_070, cds_080))
       mark_for_retrigger = 1
      ENDIF
     ENDIF
    OF wl_remove_type_cd:
     IF ((((cds_prompt_type->eal_flag=1)
      AND cbc.cds_type_cd=cds_060) OR ((cds_prompt_type->opa_flag=1)
      AND cbc.cds_type_cd IN (cds_020, cds_021))) )
      mark_for_retrigger = 1
     ENDIF
    OF disch_in_type_cd:
    OF ip_addm_type_cd:
     IF ((cds_prompt_type->apc_flag=1))
      IF (cbc.cds_type_cd IN (cds_120, cds_130, cds_140, cds_150, cds_160,
      cds_180, cds_190, cds_200))
       mark_for_retrigger = 1
      ENDIF
     ENDIF
    OF op_ref_type_cd:
     IF ((cds_prompt_type->opa_flag=1))
      IF (cbc.cds_type_cd IN (cds_020, cds_021))
       mark_for_retrigger = 1
      ENDIF
     ENDIF
    OF comm_rf_cd:
     IF ((cds_prompt_type->csr_flag=1))
      IF (cbc.cds_type_cd=cds_310)
       mark_for_retrigger = 1
      ENDIF
     ENDIF
    OF rej_comm_rf_cd:
    OF cancel_comm_cd:
    OF chk_out_comm_cd:
    OF confirm_comm_cd:
    OF no_show_comm_cd:
    OF rsch_comm_cd:
     IF ((cds_prompt_type->ccc_flag=1))
      IF (cbc.cds_type_cd=cds_311)
       IF (cbc.parent_entity_id=epa.created_by_schedule_id)
        mark_for_retrigger = 1
       ENDIF
      ENDIF
     ENDIF
     ,
     IF ((cds_prompt_type->cgs_flag=1))
      IF (cbc.cds_type_cd=cds_313)
       IF (cbc.parent_entity_id=epa.created_by_schedule_id)
        mark_for_retrigger = 1
       ENDIF
      ENDIF
     ENDIF
    OF cnc_tci_type_cd:
    OF cnf_tci_type_cd:
    OF dna_tci_type_cd:
    OF rsch_in_type_cd:
     IF ((cds_prompt_type->eal_flag=1))
      IF (cbc.cds_type_cd=cds_080)
       IF (cbc.parent_entity_id=epa.created_by_schedule_id)
        mark_for_retrigger = 1
       ENDIF
      ENDIF
     ENDIF
    OF cnc_appt_type_cd:
    OF chk_out_appt_type_cd:
    OF cab_op_appt_type_cd:
    OF cnf_op_appt_type_cd:
    OF dna_op_appt_type_cd:
    OF rsch_op_appt_type_cd:
     IF ((cds_prompt_type->opa_flag=1))
      IF (cbc.cds_type_cd IN (cds_020, cds_021))
       IF (cbc.parent_entity_id=epa.created_by_schedule_id)
        mark_for_retrigger = 1
       ENDIF
      ENDIF
     ENDIF
   ENDCASE
   IF (mark_for_retrigger=1)
    IF (locateval(idx,1,size(cds->activity,5),cbc.cds_batch_content_id,cds->activity[idx].
     cds_batch_content_id)=0)
     cnt += 1
     IF (cnt > size(cds->activity,5))
      stat = alterlist(cds->activity,(cnt+ 499))
     ENDIF
     cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_batch_content_id =
     cbc.cds_batch_content_id, cds->activity[cnt].parent_entity_id = cbc.parent_entity_id,
     cds->activity[cnt].parent_entity_name = cbc.parent_entity_name, cds->activity[cnt].encntr_org_id
      = cbc.organization_id, cds->activity[cnt].encntr_id = cbc.encntr_id,
     cds->activity[cnt].cds_type_cd = cbc.cds_type_cd, cds->activity[cnt].activity_dt_tm = cbc
     .activity_dt_tm, cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind,
     cds->activity[cnt].update_del_flag = cbc.update_del_flag, cds->activity[cnt].suppress_ind = cbc
     .suppress_ind, cds->activity[cnt].transaction_type_cd = retrig_rtt_cd,
     cds->activity[cnt].fs_parent_entity_ident = cbc.fs_parent_entity_ident, cds->activity[cnt].
     fs_parent_entity_name = cbc.fs_parent_entity_name
    ENDIF
   ENDIF
  FOOT  epa.episode_activity_id
   null
  FOOT REPORT
   stat = alterlist(cds->activity,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM cds_batch_content cbc,
   encounter e,
   person p
  PLAN (p
   WHERE p.name_last_key="ZZZ*"
    AND ((p.updt_dt_tm+ 0) >= cnvtdatetime(resetdate))
    AND ((p.updt_dt_tm+ 0) <= cnvtdatetime(reset_enddate)))
   JOIN (e
   WHERE e.person_id=p.person_id)
   JOIN (cbc
   WHERE cbc.encntr_id=e.encntr_id
    AND parser(cbcorgclause)
    AND ((cbc.update_del_flag+ 0)=9)
    AND expand(idx,start,cds_activity_types->type_cnt,cbc.cds_type_cd,cds_activity_types->type[idx].
    activity_cd))
  ORDER BY cbc.cds_batch_content_id
  HEAD REPORT
   cnt = size(cds->activity,5)
  HEAD cbc.cds_batch_content_id
   cnt += 1
   IF (cnt > size(cds->activity,5))
    stat = alterlist(cds->activity,(cnt+ 499))
   ENDIF
   cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_batch_content_id = cbc
   .cds_batch_content_id, cds->activity[cnt].activity_dt_tm = cnvtdatetime(cbc.activity_dt_tm),
   cds->activity[cnt].parent_entity_id = cbc.parent_entity_id, cds->activity[cnt].parent_entity_name
    = cbc.parent_entity_name, cds->activity[cnt].cds_type_cd = cbc.cds_type_cd,
   cds->activity[cnt].encntr_org_id = cbc.organization_id, cds->activity[cnt].encntr_id = cbc
   .encntr_id, cds->activity[cnt].update_del_flag = 1,
   cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].suppress_ind =
   cbc.suppress_ind, cds->activity[cnt].transaction_type_cd = rem_zzz_pat_cd,
   cds->activity[cnt].fs_parent_entity_ident = cbc.fs_parent_entity_ident, cds->activity[cnt].
   fs_parent_entity_name = cbc.fs_parent_entity_name
  FOOT  cbc.cds_batch_content_id
   null
  FOOT REPORT
   stat = alterlist(cds->activity,cnt)
  WITH nocounter
 ;end select
 IF ((((cds_prompt_type->eal_flag=1)) OR ((((cds_prompt_type->opa_flag=1)) OR ((((cds_prompt_type->
 adc_flag=1)) OR ((((cds_prompt_type->csr_flag=1)) OR ((((cds_prompt_type->ccc_flag=1)) OR ((((
 cds_prompt_type->cac_flag=1)) OR ((cds_prompt_type->cip_flag=1))) )) )) )) )) )) )
  DECLARE temp_cnt = i4 WITH protect, noconstant(0)
  FOR (var_cnt = 1 TO cds_activity_types->type_cnt)
   IF (mod(var_cnt,3)=1)
    SET stat = alterlist(cds_activity_types_temp->type,(var_cnt+ 3))
   ENDIF
   IF ((cds_activity_types->type[var_cnt].activity_cd IN (cds_060, cds_070, cds_080, cds_090,
   cds_0201,
   cds_310, cds_311, cds_312, cds_314)))
    SET temp_cnt += 1
    SET cds_activity_types_temp->type[temp_cnt].activity_cd = cds_activity_types->type[var_cnt].
    activity_cd
    SET cds_activity_types_temp->type_cnt = temp_cnt
   ENDIF
  ENDFOR
  SET stat = alterlist(cds_activity_types_temp->type,temp_cnt)
  SET new_batch_size = size(cds_activity_types_temp->type,5)
  SELECT INTO "nl:"
   FROM encounter e,
    cds_batch_content cbc
   PLAN (e
    WHERE e.updt_dt_tm >= cnvtdatetime(resetdate)
     AND e.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND parser(latestencntrselect)
     AND parser(eorgclause))
    JOIN (cbc
    WHERE cbc.encntr_id=e.encntr_id
     AND parser(cbcorgclause)
     AND cbc.permanent_del_ind=0
     AND expand(idx,start,new_batch_size,cbc.cds_type_cd,cds_activity_types_temp->type[idx].
     activity_cd))
   ORDER BY cbc.cds_batch_content_id
   HEAD REPORT
    cnt = size(cds->activity,5)
   HEAD cbc.cds_batch_content_id
    start = 1, rowfound = 0, idx = 0
    IF ((( NOT (cbc.cds_type_cd IN (cds_070, cds_080, cds_090))) OR (cbc.cds_type_cd IN (cds_070,
    cds_080, cds_090)
     AND e.active_ind=0
     AND cbc.update_del_flag=9)) )
     rowfound = locateval(idx,start,size(cds->activity,5),cbc.cds_batch_content_id,cds->activity[idx]
      .cds_batch_content_id)
     IF (rowfound=0)
      cnt += 1
      IF (cnt > size(cds->activity,5))
       stat = alterlist(cds->activity,(cnt+ 499))
      ENDIF
      cds->activity[cnt].cds_batch_content_id = cbc.cds_batch_content_id, cds->activity[cnt].
      cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].activity_dt_tm = cbc.activity_dt_tm,
      cds->activity[cnt].parent_entity_id = cbc.parent_entity_id, cds->activity[cnt].
      parent_entity_name = cbc.parent_entity_name, cds->activity[cnt].cds_type_cd = cbc.cds_type_cd,
      cds->activity[cnt].encntr_id = e.encntr_id, cds->activity[cnt].encntr_org_id = e
      .organization_id, cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind,
      cds->activity[cnt].suppress_ind = cbc.suppress_ind, cds->activity[cnt].transaction_type_cd =
      g_enc_updt_retr_cd, cds->activity[cnt].fs_parent_entity_ident = cbc.fs_parent_entity_ident,
      cds->activity[cnt].fs_parent_entity_name = cbc.fs_parent_entity_name
      IF (cbc.update_del_flag=9)
       IF (e.active_ind=0)
        cds->activity[cnt].update_del_flag = 1
       ELSE
        cds->activity[cnt].update_del_flag = 9
       ENDIF
      ELSE
       cds->activity[cnt].update_del_flag = 1
      ENDIF
     ENDIF
    ENDIF
   FOOT  cbc.cds_batch_content_id
    null
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
  SET temp_cnt = 0
  SET stat = alterlist(cds_activity_types_temp->type,0)
  FOR (var_cnt = 1 TO cds_activity_types->type_cnt)
   IF (mod(var_cnt,3)=1)
    SET stat = alterlist(cds_activity_types_temp->type,(var_cnt+ 3))
   ENDIF
   IF ((cds_activity_types->type[var_cnt].activity_cd IN (cds_060, cds_020, cds_021, cds_310, cds_311,
   cds_312, cds_314)))
    SET temp_cnt += 1
    SET cds_activity_types_temp->type[temp_cnt].activity_cd = cds_activity_types->type[var_cnt].
    activity_cd
    SET cds_activity_types_temp->type_cnt = temp_cnt
   ENDIF
  ENDFOR
  SET stat = alterlist(cds_activity_types_temp->type,temp_cnt)
  SET new_batch_size = size(cds_activity_types_temp->type,5)
  SELECT INTO "nl:"
   FROM pm_wait_list pwl,
    encounter e,
    cds_batch_content cbc
   PLAN (pwl
    WHERE pwl.updt_dt_tm >= cnvtdatetime(resetdate)
     AND pwl.updt_dt_tm <= cnvtdatetime(reset_enddate))
    JOIN (e
    WHERE e.encntr_id=pwl.encntr_id
     AND parser(replace(latestencntrselect,"e1","e3",0))
     AND parser(eorgclause)
     AND ((e.updt_dt_tm < cnvtdatetime(resetdate)) OR (e.updt_dt_tm > cnvtdatetime(reset_enddate))) )
    JOIN (cbc
    WHERE cbc.encntr_id=pwl.encntr_id
     AND parser(cbcorgclause)
     AND cbc.permanent_del_ind=0
     AND expand(idx,start,new_batch_size,cbc.cds_type_cd,cds_activity_types_temp->type[idx].
     activity_cd)
     AND  NOT (cbc.cds_type_cd=cds_020
     AND cbc.parent_entity_name=pmwaitliststring))
   ORDER BY cbc.cds_batch_content_id
   HEAD REPORT
    cnt = size(cds->activity,5)
   HEAD cbc.cds_batch_content_id
    start = 1, rowfound = 0, idx = 0,
    rowfound = locateval(idx,start,size(cds->activity,5),cbc.cds_batch_content_id,cds->activity[idx].
     cds_batch_content_id)
    IF (rowfound=0)
     cnt += 1
     IF (cnt > size(cds->activity,5))
      stat = alterlist(cds->activity,(cnt+ 499))
     ENDIF
     cds->activity[cnt].cds_batch_content_id = cbc.cds_batch_content_id, cds->activity[cnt].
     activity_dt_tm = cbc.activity_dt_tm, cds->activity[cnt].parent_entity_name = cbc
     .parent_entity_name,
     cds->activity[cnt].parent_entity_id = cbc.parent_entity_id, cds->activity[cnt].encntr_id = cbc
     .encntr_id, cds->activity[cnt].cds_type_cd = cbc.cds_type_cd,
     cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].encntr_org_id = cbc
     .organization_id, cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind,
     cds->activity[cnt].suppress_ind = cbc.suppress_ind, cds->activity[cnt].transaction_type_cd =
     g_wl_updt_retr, cds->activity[cnt].fs_parent_entity_ident = cbc.fs_parent_entity_ident,
     cds->activity[cnt].fs_parent_entity_name = cbc.fs_parent_entity_name
     IF (cbc.update_del_flag=9)
      IF (e.active_ind=0)
       cds->activity[cnt].update_del_flag = 1
      ELSE
       cds->activity[cnt].update_del_flag = 9
      ENDIF
     ELSE
      cds->activity[cnt].update_del_flag = 1
     ENDIF
    ENDIF
   FOOT  cbc.cds_batch_content_id
    null
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
 ENDIF
 SET temp_cnt = 0
 SET stat = alterlist(cds_activity_types_temp->type,0)
 SET cds_activity_types_temp->type_cnt = 0
 FOR (var_cnt = 1 TO cds_activity_types->type_cnt)
  IF (mod(var_cnt,10)=1)
   SET stat = alterlist(cds_activity_types_temp->type,(var_cnt+ 10))
  ENDIF
  IF ( NOT ((cds_activity_types->type[var_cnt].activity_cd IN (cds_030, cds_060, cds_070, cds_080,
  cds_090,
  cds_0201, cds_310, cds_311, cds_312, cds_313,
  cds_314))))
   SET temp_cnt += 1
   SET cds_activity_types_temp->type[temp_cnt].activity_cd = cds_activity_types->type[var_cnt].
   activity_cd
   SET cds_activity_types_temp->type_cnt = temp_cnt
  ENDIF
 ENDFOR
 SET stat = alterlist(cds_activity_types_temp->type,temp_cnt)
 SET new_batch_size = size(cds_activity_types_temp->type,5)
 SELECT INTO "nl:"
  cbc.cds_batch_content_id, cbc.cds_batch_id, cbc.activity_dt_tm,
  cbc.parent_entity_name, cbc.parent_entity_id, cbc.cds_type_cd,
  cbc.organization_id, cbc.encntr_id, cbc.update_del_flag,
  cbc.suppress_ind, cbc.fs_parent_entity_ident, cbc.fs_parent_entity_name
  FROM coding c,
   encounter e,
   cds_batch_content cbc
  PLAN (c
   WHERE c.updt_dt_tm >= cnvtdatetime(resetdate)
    AND c.updt_dt_tm <= cnvtdatetime(reset_enddate))
   JOIN (e
   WHERE e.encntr_id=c.encntr_id
    AND parser(eorgclause))
   JOIN (cbc
   WHERE cbc.parent_entity_id=c.encntr_slice_id
    AND cbc.parent_entity_name=encntrslicestring
    AND ((cbc.update_del_flag+ 0)=9)
    AND cbc.permanent_del_ind=0
    AND expand(idx,start,cds_activity_types->type_cnt,cbc.cds_type_cd,cds_activity_types->type[idx].
    activity_cd)
    AND (( NOT (cbc.cds_type_cd=cds_020
    AND cbc.parent_entity_name=pmwaitliststring)) UNION (
   (SELECT INTO "nl:"
    cbc.cds_batch_content_id, cbc.cds_batch_id, cbc.activity_dt_tm,
    cbc.parent_entity_name, cbc.parent_entity_id, cbc.cds_type_cd,
    cbc.organization_id, cbc.encntr_id, cbc.update_del_flag,
    cbc.suppress_ind, cbc.fs_parent_entity_ident, cbc.fs_parent_entity_name
    FROM coding c,
     encounter e,
     cds_batch_content cbc
    WHERE c.updt_dt_tm >= cnvtdatetime(resetdate)
     AND c.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND e.encntr_id=c.encntr_id
     AND parser(eorgclause)
     AND cbc.encntr_id=c.encntr_id
     AND cbc.parent_entity_name != encntrslicestring
     AND expand(idx,start,new_batch_size,cbc.cds_type_cd,cds_activity_types_temp->type[idx].
     activity_cd)
     AND  NOT (cbc.cds_type_cd=cds_020
     AND cbc.parent_entity_name=pmwaitliststring)
     AND cbc.permanent_del_ind=0
     AND ((cbc.update_del_flag+ 0)=9)))) )
  ORDER BY 1
  HEAD REPORT
   cnt = size(cds->activity,5)
  HEAD cbc.cds_batch_content_id
   start = 1, rowfound = 0, rowfound = locateval(rowfound,start,cnt,cbc.cds_batch_content_id,cds->
    activity[rowfound].cds_batch_content_id)
   IF (rowfound=0)
    cnt += 1
    IF (cnt > size(cds->activity,5))
     stat = alterlist(cds->activity,(cnt+ 499))
    ENDIF
    cds->activity[cnt].cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].cds_batch_content_id = cbc
    .cds_batch_content_id, cds->activity[cnt].activity_dt_tm = cnvtdatetime(cbc.activity_dt_tm),
    cds->activity[cnt].parent_entity_id = cbc.parent_entity_id, cds->activity[cnt].parent_entity_name
     = cbc.parent_entity_name, cds->activity[cnt].cds_type_cd = cbc.cds_type_cd,
    cds->activity[cnt].encntr_org_id = cbc.organization_id, cds->activity[cnt].encntr_id = cbc
    .encntr_id, cds->activity[cnt].update_del_flag = cbc.update_del_flag,
    cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].suppress_ind =
    cbc.suppress_ind, cds->activity[cnt].transaction_type_cd = g_cod_updt_retr_cd,
    cds->activity[cnt].fs_parent_entity_ident = cbc.fs_parent_entity_ident, cds->activity[cnt].
    fs_parent_entity_name = cbc.fs_parent_entity_name
   ENDIF
  FOOT  cbc.cds_batch_content_id
   null
  FOOT REPORT
   stat = alterlist(cds->activity,cnt)
  WITH nocounter, rdbunion
 ;end select
 SET temp_cnt = 0
 SET stat = alterlist(cds_activity_types_temp->type,0)
 FOR (var_cnt = 1 TO cds_activity_types->type_cnt)
  IF (mod(var_cnt,3)=1)
   SET stat = alterlist(cds_activity_types_temp->type,(var_cnt+ 3))
  ENDIF
  IF ( NOT ((cds_activity_types->type[var_cnt].activity_cd IN (cds_090, cds_010, cds_011, cds_313))))
   SET temp_cnt += 1
   SET cds_activity_types_temp->type[temp_cnt].activity_cd = cds_activity_types->type[var_cnt].
   activity_cd
   SET cds_activity_types_temp->type_cnt = temp_cnt
  ENDIF
 ENDFOR
 SET stat = alterlist(cds_activity_types_temp->type,temp_cnt)
 SET new_batch_size = size(cds_activity_types_temp->type,5)
 SELECT INTO "nl:"
  cbc.cds_batch_content_id, cbc.cds_batch_id, cbc.activity_dt_tm,
  cbc.parent_entity_name, cbc.parent_entity_id, cbc.cds_type_cd,
  cbc.organization_id, cbc.encntr_id, cbc.update_del_flag
  FROM episode_encntr_reltn eer,
   cds_batch_content cbc
  PLAN (eer
   WHERE eer.updt_dt_tm >= cnvtdatetime(resetdate)
    AND eer.updt_dt_tm <= cnvtdatetime(reset_enddate)
    AND eer.beg_effective_dt_tm <= cnvtdatetime(update_dt_tm)
    AND eer.end_effective_dt_tm > cnvtdatetime(update_dt_tm))
   JOIN (cbc
   WHERE cbc.encntr_id=eer.encntr_id
    AND ((cbc.update_del_flag+ 0)=9)
    AND cbc.permanent_del_ind=0
    AND expand(idx,start,cds_activity_types->type_cnt,cbc.cds_type_cd,cds_activity_types->type[idx].
    activity_cd)
    AND  NOT (cbc.cds_type_cd=cds_020
    AND cbc.parent_entity_name=pmwaitliststring))
  ORDER BY 1
  HEAD REPORT
   cnt = size(cds->activity,5)
  DETAIL
   start = 1, cdsfound = 0, cdsfound = locateval(cdsfound,start,size(cds->activity,5),cbc
    .cds_batch_content_id,cds->activity[cdsfound].cds_batch_content_id)
   IF (cdsfound=0)
    cnt += 1
    IF (cnt > size(cds->activity,5))
     stat = alterlist(cds->activity,(cnt+ 499))
    ENDIF
    cds->activity[cnt].cds_batch_content_id = cbc.cds_batch_content_id, cds->activity[cnt].
    cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].activity_dt_tm = cnvtdatetime(cbc
     .activity_dt_tm),
    cds->activity[cnt].parent_entity_name = cbc.parent_entity_name, cds->activity[cnt].
    parent_entity_id = cbc.parent_entity_id, cds->activity[cnt].cds_type_cd = cbc.cds_type_cd,
    cds->activity[cnt].encntr_org_id = cbc.organization_id, cds->activity[cnt].encntr_id = cbc
    .encntr_id, cds->activity[cnt].update_del_flag = cbc.update_del_flag,
    cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].suppress_ind =
    cbc.suppress_ind, cds->activity[cnt].transaction_type_cd = g_epi_enc_reltn_cd,
    cds->activity[cnt].fs_parent_entity_ident = cbc.fs_parent_entity_ident, cds->activity[cnt].
    fs_parent_entity_name = cbc.fs_parent_entity_name
   ENDIF
  FOOT REPORT
   stat = alterlist(cds->activity,cnt)
  WITH nocounter
 ;end select
 IF ((((cds_prompt_type->eal_flag=1)) OR ((cds_prompt_type->ae_flag=1))) )
  DECLARE ae_in_list = vc WITH public, noconstant("")
  CASE (ecds_switch)
   OF 0:
    SET ae_in_list = "CDS_010"
   OF 1:
    SET ae_in_list = "CDS_011"
   OF 2:
    SET ae_in_list = "CDS_010, CDS_011"
  ENDCASE
  IF ((cds_prompt_type->eal_flag=1)
   AND (cds_prompt_type->ae_flag=1))
   SET temp_parser = build2("cbc.cds_type_cd in (CDS_060,",ae_in_list,")")
  ELSEIF ((cds_prompt_type->eal_flag=1))
   SET temp_parser = "cbc.cds_type_cd = CDS_060"
  ELSEIF ((cds_prompt_type->ae_flag=1))
   SET temp_parser = build2("cbc.cds_type_cd in (",ae_in_list,")")
  ENDIF
  SELECT INTO "nl:"
   FROM orders o,
    encounter e,
    cds_batch_content cbc
   PLAN (o
    WHERE o.updt_dt_tm >= cnvtdatetime(resetdate)
     AND o.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND o.catalog_type_cd IN (discernruleorder_cd, laboratory_cd, radiology_cd, surgery_cd))
    JOIN (e
    WHERE e.encntr_id=o.encntr_id
     AND parser(eorgclause))
    JOIN (cbc
    WHERE cbc.encntr_id=e.encntr_id
     AND ((cbc.update_del_flag+ 0)=9)
     AND cbc.permanent_del_ind=0
     AND cbc.cds_batch_id != 0.0
     AND parser(temp_parser))
   ORDER BY cbc.cds_batch_content_id
   HEAD REPORT
    cnt = size(cds->activity,5)
   HEAD cbc.cds_batch_content_id
    start = 1, rowfound = 0, rowfound = locateval(rowfound,start,cnt,cbc.cds_batch_content_id,cds->
     activity[rowfound].cds_batch_content_id)
    IF (rowfound=0)
     IF (((o.catalog_type_cd=surgery_cd
      AND cbc.cds_type_cd=cds_060) OR (cbc.cds_type_cd IN (cds_010, cds_011))) )
      cnt += 1
      IF (cnt > size(cds->activity,5))
       stat = alterlist(cds->activity,(cnt+ 499))
      ENDIF
      cds->activity[cnt].cds_batch_content_id = cbc.cds_batch_content_id, cds->activity[cnt].
      cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].activity_dt_tm = cnvtdatetime(cbc
       .activity_dt_tm),
      cds->activity[cnt].parent_entity_name = cbc.parent_entity_name, cds->activity[cnt].
      parent_entity_id = cbc.parent_entity_id, cds->activity[cnt].cds_type_cd = cbc.cds_type_cd,
      cds->activity[cnt].encntr_org_id = cbc.organization_id, cds->activity[cnt].encntr_id = cbc
      .encntr_id, cds->activity[cnt].update_del_flag = cbc.update_del_flag,
      cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].suppress_ind
       = cbc.suppress_ind, cds->activity[cnt].transaction_type_cd = g_ord_retr_cd
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist(cds->activity,cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((((cds_prompt_type->ae_flag=1)) OR ((cds_prompt_type->opa_flag=1))) )
  DECLARE ae_in_list = vc WITH public, noconstant("")
  CASE (ecds_switch)
   OF 0:
    SET ae_in_list = "CDS_010"
   OF 1:
    SET ae_in_list = "CDS_011"
   OF 2:
    SET ae_in_list = "CDS_010, CDS_011"
  ENDCASE
  IF ((cds_prompt_type->opa_flag=1)
   AND (cds_prompt_type->ae_flag=1))
   SET temp_parser = build2("cbc.cds_type_cd in (CDS_020,",ae_in_list,")")
  ELSEIF ((cds_prompt_type->opa_flag=1))
   SET temp_parser = "cbc.cds_type_cd = CDS_020"
  ELSEIF ((cds_prompt_type->ae_flag=1))
   SET temp_parser = build2("cbc.cds_type_cd in (",ae_in_list,")")
  ENDIF
  DECLARE cds_retrig_opt_cd = f8 WITH protect, noconstant(0.0)
  DECLARE proc_diag_retrig_opt = vc WITH public, noconstant("")
  SET cds_retrig_opt_cd = getreportingconfigcv("CDSRTRGOPT01")
  SET proc_diag_retrig_opt = getoption1fieldvalue("CDSRTRGOPT01")
  SET proc_diag_retrig_opt = trim(cnvtupper(proc_diag_retrig_opt),3)
  IF (cds_retrig_opt_cd < 0.00)
   CALL log_message("Error: code value for CDF meaning CDS_RETRIG_OPT_CD not set in code set 4001902",
    log_level_warning)
  ENDIF
  IF (proc_diag_retrig_opt IN ("Y", "YES", "ON", "1"))
   DECLARE diag_src_voc_icd_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"ICD10"))
   DECLARE diag_src_voc_icd_cd1 = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"ICD10WHO")
    )
   DECLARE diag_src_voc_sct_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"SNMCT"))
   DECLARE diag_src_voc_smded_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",400,
     "SNMUKEMED"))
   DECLARE diag_prin_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",401,"DIAG"))
   DECLARE morph_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",15849,"I10-MORPH"))
   SELECT INTO "nl:"
    FROM diagnosis d,
     nomenclature n,
     encounter e,
     cds_batch_content cbc
    PLAN (d
     WHERE d.updt_dt_tm >= cnvtdatetime(resetdate)
      AND d.updt_dt_tm <= cnvtdatetime(reset_enddate))
     JOIN (n
     WHERE n.nomenclature_id=d.nomenclature_id
      AND ((n.principle_type_cd=diag_prin_type_cd
      AND n.source_vocabulary_cd IN (diag_src_voc_icd_cd, diag_src_voc_icd_cd1)
      AND n.vocab_axis_cd != morph_cd) OR (n.source_vocabulary_cd IN (diag_src_voc_sct_cd,
     diag_src_voc_smded_cd)))
      AND n.active_ind=1)
     JOIN (e
     WHERE e.encntr_id=d.encntr_id
      AND parser(eorgclause))
     JOIN (cbc
     WHERE cbc.encntr_id=e.encntr_id
      AND ((cbc.update_del_flag+ 0)=9)
      AND cbc.permanent_del_ind=0
      AND cbc.cds_batch_id != 0.0
      AND parser(temp_parser))
    ORDER BY cbc.cds_batch_content_id
    HEAD REPORT
     cnt = size(cds->activity,5)
    HEAD cbc.cds_batch_content_id
     updt_flag = 0
    DETAIL
     IF (cbc.cds_type_cd=cds_020)
      CASE (cds_xml)
       OF 0:
        IF ( NOT (n.source_vocabulary_cd IN (diag_src_voc_sct_cd, diag_src_voc_smded_cd)))
         updt_flag = 1
        ENDIF
       OF 1:
        IF (n.source_vocabulary_cd != diag_src_voc_smded_cd)
         updt_flag = 1
        ENDIF
      ENDCASE
     ELSEIF (cbc.cds_type_cd=cds_011)
      IF (n.source_vocabulary_cd IN (diag_src_voc_sct_cd, diag_src_voc_smded_cd))
       updt_flag = 1
      ENDIF
     ELSE
      IF (n.source_vocabulary_cd != diag_src_voc_smded_cd)
       updt_flag = 1
      ENDIF
     ENDIF
    FOOT  cbc.cds_batch_content_id
     IF (updt_flag=1)
      start = 1, rowfound = 0, rowfound = locateval(rowfound,start,cnt,cbc.cds_batch_content_id,cds->
       activity[rowfound].cds_batch_content_id)
      IF (rowfound=0)
       cnt += 1
       IF (cnt > size(cds->activity,5))
        stat = alterlist(cds->activity,(cnt+ 499))
       ENDIF
       cds->activity[cnt].cds_batch_content_id = cbc.cds_batch_content_id, cds->activity[cnt].
       cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].activity_dt_tm = cnvtdatetime(cbc
        .activity_dt_tm),
       cds->activity[cnt].parent_entity_name = cbc.parent_entity_name, cds->activity[cnt].
       parent_entity_id = cbc.parent_entity_id, cds->activity[cnt].cds_type_cd = cbc.cds_type_cd,
       cds->activity[cnt].encntr_org_id = cbc.organization_id, cds->activity[cnt].encntr_id = cbc
       .encntr_id, cds->activity[cnt].update_del_flag = cbc.update_del_flag,
       cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].suppress_ind
        = cbc.suppress_ind, cds->activity[cnt].transaction_type_cd = g_diag_retr_cd,
       cds->activity[cnt].fs_parent_entity_ident = cbc.fs_parent_entity_ident, cds->activity[cnt].
       fs_parent_entity_name = cbc.fs_parent_entity_name
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(cds->activity,cnt)
    WITH nocounter
   ;end select
   DECLARE opcs4_src_voc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"OPCS4"))
   DECLARE proc_prin_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",401,"PROCEDURE"))
   DECLARE pm_offer_proc_reltn_exists = i2 WITH protect, constant(checkdic("PM_OFFER_PROC_RELTN","T",
     0))
   DECLARE sing_op_enc_date_opt = vc WITH public, noconstant("")
   DECLARE valid_dt = dq8 WITH public, noconstant(0.0)
   SET sing_op_enc_date_opt = getoption1fieldvalue("CDSOPSESWON")
   SET valid_dt = cnvtdatetime(cnvtdate2(trim(sing_op_enc_date_opt,3),"DD-MMM-YYYY"),0)
   FREE RECORD tmp_encntr
   RECORD tmp_encntr(
     1 qual[*]
       2 encntr_id = f8
   )
   IF (valid_dt > 0.0
    AND pm_offer_proc_reltn_exists > 0
    AND (cds_prompt_type->opa_flag=1))
    SELECT INTO "nl:"
     FROM procedure p,
      pm_offer_proc_reltn popr,
      nomenclature n,
      pm_offer po,
      cds_batch_content cbc
     PLAN (p
      WHERE p.updt_dt_tm >= cnvtdatetime(resetdate)
       AND p.updt_dt_tm <= cnvtdatetime(reset_enddate))
      JOIN (popr
      WHERE popr.procedure_id=p.procedure_id)
      JOIN (n
      WHERE n.nomenclature_id=p.nomenclature_id
       AND ((n.principle_type_cd=proc_prin_type_cd
       AND n.source_vocabulary_cd=opcs4_src_voc_cd) OR (n.source_vocabulary_cd=diag_src_voc_sct_cd))
       AND n.active_ind=1)
      JOIN (po
      WHERE po.pm_offer_id=popr.pm_offer_id)
      JOIN (cbc
      WHERE cbc.parent_entity_id=po.schedule_id
       AND cbc.parent_entity_name=schschedulestring
       AND ((cbc.update_del_flag+ 0)=9)
       AND cbc.permanent_del_ind=0
       AND cbc.cds_batch_id != 0.0
       AND cbc.cds_type_cd=cds_020)
     ORDER BY cbc.cds_batch_content_id
     HEAD REPORT
      cnt = size(cds->activity,5), tmp_cnt = 0
     HEAD cbc.cds_batch_content_id
      updt_flag = 0
     DETAIL
      CASE (cds_xml)
       OF 0:
        IF (n.source_vocabulary_cd != diag_src_voc_sct_cd)
         updt_flag = 1
        ENDIF
       OF 1:
        updt_flag = 1
      ENDCASE
     FOOT  cbc.cds_batch_content_id
      IF (updt_flag=1)
       start = 1, rowfound = 0, rowfound = locateval(rowfound,start,cnt,cbc.cds_batch_content_id,cds
        ->activity[rowfound].cds_batch_content_id)
       IF (rowfound=0)
        cnt += 1
        IF (cnt > size(cds->activity,5))
         stat = alterlist(cds->activity,(cnt+ 499))
        ENDIF
        cds->activity[cnt].cds_batch_content_id = cbc.cds_batch_content_id, cds->activity[cnt].
        cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].activity_dt_tm = cnvtdatetime(cbc
         .activity_dt_tm),
        cds->activity[cnt].parent_entity_name = cbc.parent_entity_name, cds->activity[cnt].
        parent_entity_id = cbc.parent_entity_id, cds->activity[cnt].cds_type_cd = cbc.cds_type_cd,
        cds->activity[cnt].encntr_org_id = cbc.organization_id, cds->activity[cnt].encntr_id = cbc
        .encntr_id, cds->activity[cnt].update_del_flag = cbc.update_del_flag,
        cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].suppress_ind
         = cbc.suppress_ind, cds->activity[cnt].transaction_type_cd = g_proc_retr_cd,
        cds->activity[cnt].fs_parent_entity_ident = cbc.fs_parent_entity_ident, cds->activity[cnt].
        fs_parent_entity_name = cbc.fs_parent_entity_name
       ENDIF
       rowfound2 = 0, rowfound2 = locateval(rowfound2,start,size(tmp_encntr->qual,5),cbc.encntr_id,
        tmp_encntr->qual[rowfound2].encntr_id)
       IF (rowfound2=0)
        tmp_cnt += 1
        IF (tmp_cnt > size(tmp_encntr->qual,5))
         stat = alterlist(tmp_encntr->qual,(tmp_cnt+ 499))
        ENDIF
        tmp_encntr->qual[tmp_cnt].encntr_id = cbc.encntr_id
       ENDIF
      ENDIF
     FOOT REPORT
      stat = alterlist(cds->activity,cnt), stat = alterlist(tmp_encntr->qual,tmp_cnt)
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    FROM procedure p,
     nomenclature n,
     encounter e,
     cds_batch_content cbc
    PLAN (p
     WHERE p.updt_dt_tm >= cnvtdatetime(resetdate)
      AND p.updt_dt_tm <= cnvtdatetime(reset_enddate))
     JOIN (n
     WHERE n.nomenclature_id=p.nomenclature_id
      AND ((n.principle_type_cd=proc_prin_type_cd
      AND n.source_vocabulary_cd=opcs4_src_voc_cd) OR (n.source_vocabulary_cd=diag_src_voc_sct_cd))
      AND n.active_ind=1)
     JOIN (e
     WHERE e.encntr_id=p.encntr_id
      AND parser(eorgclause))
     JOIN (cbc
     WHERE cbc.encntr_id=e.encntr_id
      AND ((cbc.update_del_flag+ 0)=9)
      AND cbc.permanent_del_ind=0
      AND cbc.cds_batch_id != 0.0
      AND parser(temp_parser))
    ORDER BY cbc.cds_batch_content_id
    HEAD REPORT
     cnt = size(cds->activity,5), tmp_cnt = size(tmp_encntr->qual,5)
    HEAD cbc.cds_batch_content_id
     updt_flag = 0
    DETAIL
     IF (cbc.cds_type_cd=cds_020)
      CASE (cds_xml)
       OF 0:
        IF (n.source_vocabulary_cd != diag_src_voc_sct_cd)
         updt_flag = 1
        ENDIF
       OF 1:
        updt_flag = 1
      ENDCASE
     ELSE
      IF (n.source_vocabulary_cd=opcs4_src_voc_cd)
       updt_flag = 1
      ENDIF
     ENDIF
    FOOT  cbc.cds_batch_content_id
     IF (updt_flag=1)
      start = 1, rowfound = 0, rowfound = locateval(rowfound,start,cnt,cbc.cds_batch_content_id,cds->
       activity[rowfound].cds_batch_content_id),
      tmprowfound = 0, tmprowfound = locateval(tmprowfound,start,tmp_cnt,cbc.encntr_id,tmp_encntr->
       qual[tmprowfound].encntr_id)
      IF (rowfound=0
       AND tmprowfound=0)
       cnt += 1
       IF (cnt > size(cds->activity,5))
        stat = alterlist(cds->activity,(cnt+ 499))
       ENDIF
       cds->activity[cnt].cds_batch_content_id = cbc.cds_batch_content_id, cds->activity[cnt].
       cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].activity_dt_tm = cnvtdatetime(cbc
        .activity_dt_tm),
       cds->activity[cnt].parent_entity_name = cbc.parent_entity_name, cds->activity[cnt].
       parent_entity_id = cbc.parent_entity_id, cds->activity[cnt].cds_type_cd = cbc.cds_type_cd,
       cds->activity[cnt].encntr_org_id = cbc.organization_id, cds->activity[cnt].encntr_id = cbc
       .encntr_id, cds->activity[cnt].update_del_flag = cbc.update_del_flag,
       cds->activity[cnt].cds_row_error_ind = cbc.cds_row_error_ind, cds->activity[cnt].suppress_ind
        = cbc.suppress_ind, cds->activity[cnt].transaction_type_cd = g_proc_retr_cd,
       cds->activity[cnt].fs_parent_entity_ident = cbc.fs_parent_entity_ident, cds->activity[cnt].
       fs_parent_entity_name = cbc.fs_parent_entity_name
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(cds->activity,cnt)
    WITH nocounter
   ;end select
   FREE RECORD tmp_encntr
  ENDIF
 ENDIF
 IF (size(cds->activity,5)=0)
  CALL log_message("No CDS Activity",log_level_debug)
  GO TO retrigger_cds_activity
 ELSE
  SET updatestatus = 1
 ENDIF
 SELECT INTO "nl:"
  decode_table = decode(otr.seq,"otr",oor.seq,"oor","zzz")
  FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
   dummyt d1,
   dummyt d2,
   org_type_reltn otr,
   org_type_reltn otr2,
   org_org_reltn oor
  PLAN (d)
   JOIN (((d1)
   JOIN (otr
   WHERE (otr.organization_id=cds->activity[d.seq].encntr_org_id)
    AND otr.org_type_cd=nhs_trust_cd
    AND otr.active_ind=1
    AND otr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND otr.end_effective_dt_tm >= cnvtdatetime(sysdate))
   ) ORJOIN ((d2)
   JOIN (oor
   WHERE (oor.related_org_id=cds->activity[d.seq].encntr_org_id)
    AND oor.org_org_reltn_cd=nhs_trust_child_cd
    AND oor.active_ind=1
    AND oor.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND oor.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (otr2
   WHERE otr2.organization_id=oor.organization_id
    AND otr2.org_type_cd=nhs_trust_cd
    AND otr2.active_ind=1
    AND otr2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND otr2.end_effective_dt_tm >= cnvtdatetime(sysdate))
   ))
  DETAIL
   IF (decode_table="otr")
    cds->activity[d.seq].provider_org_id = otr.organization_id
   ELSEIF (decode_table="oor")
    cds->activity[d.seq].provider_org_id = otr2.organization_id
   ENDIF
  WITH nocounter
 ;end select
 DECLARE cds_size = i4 WITH protect, noconstant(size(cds->activity,5))
 DECLARE updt_type1_cnt = i4 WITH protect, noconstant(0)
 DECLARE loc_idx = i4 WITH protect, noconstant(0)
 DECLARE bcds = i4 WITH protect, noconstant(0)
 DECLARE alcds = i4 WITH protect, noconstant(0)
 DECLARE alcnt = i4 WITH protect, noconstant(0)
 SET bcds = locateval(loc_idx,1,cds_size,0.0,cds->activity[loc_idx].provider_org_id)
 WHILE (bcds > 0)
   SET cds->activity[bcds].provider_org_id = cds->activity[bcds].encntr_org_id
   SET cds->activity[bcds].cds_row_error_ind = 1
   SET cds->activity[bcds].suppress_ind = 1
   SET bcds = locateval(loc_idx,(bcds+ 1),cds_size,0.0,cds->activity[loc_idx].provider_org_id)
 ENDWHILE
 FREE RECORD ukr_mod_request
 RECORD ukr_mod_request(
   1 execute_dt_tm = dq8
   1 transaction_flag = i2
   1 cds_batch_content[*]
     2 activity_dt_tm = dq8
     2 cds_batch_content_id = f8
     2 cds_batch_cnt_hist_id = f8
     2 cds_batch_id = f8
     2 cds_type_cd = f8
     2 cds_row_error_ind = i4
     2 encntr_id = f8
     2 encntr_org_id = f8
     2 opa_sch_event_id = f8
     2 parent_entity_id = f8
     2 parent_entity_name = c30
     2 provider_org_id = f8
     2 update_del_flag = i2
     2 suppress_ind = i2
     2 fs_parent_entity_ident = c36
     2 fs_parent_entity_name = c30
     2 transaction_type_cd = f8
     2 permanent_del_ind = i2
     2 action_flag = i2
     2 cds_batch_content_alias_cnt = i2
     2 cds_batch_content_alias[*]
       3 alias = c35
       3 end_effective_dt_tm = dq8
       3 cds_bat_cont_alias_type_cd = f8
       3 cds_batch_content_alias_id = f8
 )
 SET stat = alterlist(ukr_mod_request->cds_batch_content,cds_size)
 FOR (bcds = 1 TO cds_size)
   IF ((cds->activity[bcds].cds_batch_content_id=0))
    SET cds->activity[bcds].update_type = 1
    SET updt_type1_cnt += 1
   ELSE
    SET cds->activity[bcds].update_type = 3
    SET cds->activity[bcds].cds_batch_id = 0
   ENDIF
   SET ukr_mod_request->cds_batch_content[bcds].action_flag = cds->activity[bcds].update_type
   SET ukr_mod_request->cds_batch_content[bcds].cds_batch_content_id = cds->activity[bcds].
   cds_batch_content_id
   SET ukr_mod_request->cds_batch_content[bcds].cds_batch_id = cds->activity[bcds].cds_batch_id
   SET ukr_mod_request->cds_batch_content[bcds].parent_entity_id = cds->activity[bcds].
   parent_entity_id
   SET ukr_mod_request->cds_batch_content[bcds].parent_entity_name = cds->activity[bcds].
   parent_entity_name
   SET ukr_mod_request->cds_batch_content[bcds].cds_type_cd = cds->activity[bcds].cds_type_cd
   SET ukr_mod_request->cds_batch_content[bcds].cds_row_error_ind = cds->activity[bcds].
   cds_row_error_ind
   SET ukr_mod_request->cds_batch_content[bcds].provider_org_id = cds->activity[bcds].provider_org_id
   SET ukr_mod_request->cds_batch_content[bcds].update_del_flag = cds->activity[bcds].update_del_flag
   SET ukr_mod_request->cds_batch_content[bcds].encntr_id = cds->activity[bcds].encntr_id
   SET ukr_mod_request->cds_batch_content[bcds].activity_dt_tm = cds->activity[bcds].activity_dt_tm
   SET ukr_mod_request->cds_batch_content[bcds].fs_parent_entity_ident = cds->activity[bcds].
   fs_parent_entity_ident
   SET ukr_mod_request->cds_batch_content[bcds].fs_parent_entity_name = cds->activity[bcds].
   fs_parent_entity_name
   SET ukr_mod_request->cds_batch_content[bcds].permanent_del_ind = cds->activity[bcds].
   permanent_del_ind
   SET ukr_mod_request->cds_batch_content[bcds].suppress_ind = cds->activity[bcds].suppress_ind
   SET ukr_mod_request->cds_batch_content[bcds].transaction_type_cd = cds->activity[bcds].
   transaction_type_cd
   SET alcnt = 0
   IF ((cds->activity[bcds].cds_batch_content_id=0))
    SET alcnt += 1
    SET stat = alterlist(ukr_mod_request->cds_batch_content[bcds].cds_batch_content_alias,alcnt)
    SET ukr_mod_request->cds_batch_content[bcds].cds_batch_content_alias_cnt = alcnt
    SET ukr_mod_request->cds_batch_content[bcds].cds_batch_content_alias[alcnt].end_effective_dt_tm
     = cnvtdatetime(null_dt_tm)
    IF ((cds->activity[bcds].cds_type_cd IN (cdspaediatricint_cd, cdspaediatricext_cd, cdsadultint_cd,
    cdsadultext_cd, cdsneonatalint_cd,
    cdsneonatalext_cd)))
     SET ukr_mod_request->cds_batch_content[bcds].cds_batch_content_alias[alcnt].
     cds_bat_cont_alias_type_cd = cbc_cc_alias_type_cd
    ELSE
     SET ukr_mod_request->cds_batch_content[bcds].cds_batch_content_alias[alcnt].
     cds_bat_cont_alias_type_cd = cbc_cui_alias_type_cd
    ENDIF
   ENDIF
 ENDFOR
 SET ukr_mod_request->transaction_flag = 2
 EXECUTE ukr_cds_transaction
 IF ((reply->status_data.status="F"))
  CALL adderrormsg(failure,"SCRIPT",failure,"CDS_BATCH_CONTENT",
   "CDS activity identification process failed")
  GO TO exit_script
 ENDIF
#retrigger_cds_activity
 IF (cdsretrig_cd < 0.0)
  FREE RECORD ukr_mod_request
  FREE RECORD cds
  SELECT INTO "nl:"
   FROM person_prsnl_reltn ppr,
    encounter e
   PLAN (ppr
    WHERE ppr.updt_dt_tm >= cnvtdatetime(resetdate)
     AND ppr.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND ppr.person_prsnl_r_cd=gp_cd
     AND ppr.active_ind=1
     AND ppr.manual_create_ind=0)
    JOIN (e
    WHERE e.person_id=ppr.person_id
     AND parser(eorgclause))
   ORDER BY e.encntr_id
   HEAD REPORT
    cnt = 0
   HEAD e.encntr_id
    cnt += 1
    IF (cnt > size(request->entity,5))
     stat = alterlist(request->entity,(cnt+ 499))
    ENDIF
    request->entity[cnt].entity_id = e.encntr_id
   FOOT  e.encntr_id
    null
   FOOT REPORT
    stat = alterlist(request->entity,cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM pm_hist_tracking pht,
    address addr,
    address_hist ah,
    encounter e
   PLAN (pht
    WHERE pht.updt_dt_tm >= cnvtdatetime(resetdate)
     AND pht.updt_dt_tm <= cnvtdatetime(reset_enddate))
    JOIN (ah
    WHERE ah.pm_hist_tracking_id=pht.pm_hist_tracking_id)
    JOIN (addr
    WHERE addr.address_id=ah.address_id
     AND addr.address_type_cd=home_cd
     AND addr.parent_entity_name="PERSON")
    JOIN (e
    WHERE e.person_id=addr.parent_entity_id
     AND parser(eorgclause))
   ORDER BY e.encntr_id
   HEAD REPORT
    cnt = size(request->entity,5)
   HEAD e.encntr_id
    rowfound = 0, rowfound = locateval(rowfound,start,size(request->entity,5),e.encntr_id,request->
     entity[rowfound].entity_id)
    IF (rowfound=0)
     cnt += 1
     IF (cnt > size(request->entity,5))
      stat = alterlist(request->entity,(cnt+ 499))
     ENDIF
     request->entity[cnt].entity_id = e.encntr_id
    ENDIF
   FOOT  e.encntr_id
    null
   FOOT REPORT
    stat = alterlist(request->entity,cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM episode e,
    episode_encntr_reltn eer
   PLAN (e
    WHERE e.updt_dt_tm >= cnvtdatetime(resetdate)
     AND e.updt_dt_tm <= cnvtdatetime(reset_enddate)
     AND e.beg_effective_dt_tm <= cnvtdatetime(update_dt_tm)
     AND e.end_effective_dt_tm > cnvtdatetime(update_dt_tm))
    JOIN (eer
    WHERE eer.episode_id=e.episode_id
     AND eer.beg_effective_dt_tm <= cnvtdatetime(update_dt_tm)
     AND eer.end_effective_dt_tm > cnvtdatetime(update_dt_tm))
   ORDER BY eer.encntr_id
   HEAD REPORT
    cnt = size(request->entity,5)
   HEAD eer.encntr_id
    rowfound = 0, rowfound = locateval(rowfound,start,size(request->entity,5),eer.encntr_id,request->
     entity[rowfound].entity_id)
    IF (rowfound=0)
     cnt += 1
     IF (cnt > size(request->entity,5))
      stat = alterlist(request->entity,(cnt+ 499))
     ENDIF
     request->entity[cnt].entity_id = eer.encntr_id
    ENDIF
   FOOT  eer.encntr_id
    null
   FOOT REPORT
    stat = alterlist(request->entity,cnt)
   WITH nocounter
  ;end select
  IF (size(request->entity,5)=0)
   CALL log_message("No records to retrigger",log_level_debug)
   GO TO exit_script
  ELSE
   SET updatestatus = 1
  ENDIF
  SET request->retrigger_type_flag = 2
  EXECUTE ukr_cds_retrigger_activity
 ENDIF
#exit_script
 IF (updatestatus=0)
  CALL log_message("No Records to process",log_level_debug)
 ELSE
  SET stemp = concat("CDS Content Reset from ",format(cnvtdate(resetdate),"@MEDIUMDATE"))
  CALL log_message(stemp,log_level_debug)
 ENDIF
 FREE RECORD encntr_types
 FREE RECORD request
 FREE RECORD ukr_mod_request
 FREE RECORD cds_activity_types_temp
 IF (inprogress_ind=1
  AND validate(util_seed_ind) != 1)
  SET stemp = build2(curprog,
   " Another instance of cds_batch_content is currently executing please try again later")
  CALL log_message(stemp,log_level_audit)
  CALL adderrormsg(failure,"SCRIPT",failure,"CDS_BATCH_CONTENT",
   "CDS Batch Content Error: another instance of cds_batch_content is currently executing please try again later"
   )
 ENDIF
 CALL updatezerorowbatchstatus(cds_complete)
 SET stemp = concat("***** Complete cds_batch_content. Finish:",format(update_dt_tm,"@MEDIUMDATETIME"
   ),"*****")
 CALL log_message(stemp,log_level_debug)
 SET iprogcbc_flag = 0
 SUBROUTINE (updatezerorowbatchstatus(dbatchstatus=f8) =null)
  UPDATE  FROM cds_batch cb
   SET cb.cds_batch_status_cd = dbatchstatus, cb.updt_dt_tm = cnvtdatetime(sysdate), cb
    .cds_batch_end_dt_tm =
    IF (dbatchstatus=cds_complete) cnvtdatetime(reset_enddate)
    ELSE cnvtdatetime(sysdate)
    ENDIF
   WHERE cb.cds_batch_id=0
  ;end update
  COMMIT
 END ;Subroutine
END GO
