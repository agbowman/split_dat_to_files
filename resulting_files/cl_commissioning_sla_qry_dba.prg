CREATE PROGRAM cl_commissioning_sla_qry:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Trust:" = ""
  WITH outdev, trust
 SET last_mod = "108948"
 IF (validate(ukr_common_rpt) != 0)
  GO TO ukr_common_rpt_exit
 ENDIF
 DECLARE ukr_common_rpt = i2 WITH public, constant(1)
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
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 IF (validate(ukr_common_declares) != 0)
  GO TO ukr_common_declares_exit
 ENDIF
 DECLARE ukr_common_declares = i2 WITH public, noconstant(1)
 DECLARE contrib_src_nhsreport_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",73,
   "NHS_REPORT"))
 DECLARE auth_status_inerror_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE auth_status_inerrornoview_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",8,
   "INERRNOVIEW"))
 DECLARE auth_status_inerrornomut_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",8,
   "INERRNOMUT"))
 DECLARE enc_inpatient_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE enc_ip_preadmit_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "INPATIENTPREADMISSION"))
 DECLARE enc_ip_waitlist_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "INPATIENTWAITINGLIST"))
 DECLARE enc_ip_psych_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "PSYCHIATRICINPATIENT"))
 DECLARE enc_mh_ip_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"MHINPATIENT"))
 DECLARE enc_comm_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"COMMUNITY"))
 DECLARE enc_comm_ref_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "COMMUNITYREFERRAL"))
 DECLARE enc_outpatient_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"OUTPATIENT")
  )
 DECLARE enc_op_prereg_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "OUTPATIENTPREREGISTRATION"))
 DECLARE enc_op_referral_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "OUTPATIENTREFERRAL"))
 DECLARE enc_op_psych_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "PSYCHIATRICOUTPATIENT"))
 DECLARE enc_comm_ahp_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"COMMUNITYAHP")
  )
 DECLARE enc_daycare_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"DAYCARE"))
 DECLARE enc_daycase_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"DAYCASE"))
 DECLARE enc_daycase_wl_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "DAYCASEWAITINGLIST"))
 DECLARE enc_direct_ref_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "DIRECTREFERRAL"))
 DECLARE enc_emergency_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "EMERGENCYDEPARTMENT"))
 DECLARE enc_maternity_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"MATERNITY"))
 DECLARE enc_newborn_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"NEWBORN"))
 DECLARE enc_mentalhealth_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "MENTALHEALTH"))
 DECLARE enc_mortuary_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"MORTUARY"))
 DECLARE enc_reg_day_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "REGULARDAYADMISSION"))
 DECLARE enc_reg_night_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "REGULARNIGHTADMISSION"))
 DECLARE addr_home_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE pa_mrn_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE pa_ssn_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE ea_mrn_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE ea_finnbr_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE ea_visitid_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",319,"VISITID"))
 DECLARE ppr_primary_phys_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE epr_attend_doc_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE epr_refer_doc_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",333,"REFERDOC"))
 DECLARE pra_externalid_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",320,"EXTERNALID"))
 DECLARE pra_comm_dr_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",320,"DOCCNBR"))
 DECLARE pra_non_gp_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",320,"NONGP"))
 DECLARE pra_gdp_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",320,"GDP"))
 DECLARE eor_commissioner_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",352,
   "COMMISSIONER"))
 DECLARE oor_maincommiss_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",369,"MAINCOMMISS")
  )
 DECLARE oor_trust_child_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",369,"NHSTRUSTCHLD"
   ))
 DECLARE oa_nhs_alias_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",334,"NHSORGALIAS"))
 DECLARE urgency_imm_life_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",103003,
   "1IMMEDIATELIFESAVING"))
 DECLARE urgency_imm_save_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",103003,
   "1IMMEDIATELIMBORORGANSAVING"))
 DECLARE urgency_urgent_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",103003,"2URGENT"
   ))
 DECLARE urgency_expedited_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",103003,
   "3EXPEDITED"))
 DECLARE urgency_elective_cd = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",103003,
   "4ELECTIVE"))
 DECLARE nhs_trust_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",278,"NHSTRUST"))
 DECLARE overseascd = f8 WITH public, noconstant(uar_get_code_by("MEANING",356,"PASOVERSEAS"))
 DECLARE patient = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",14250,"PATIENT"))
 DECLARE pla_treatment_site_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",17649,
   "TREATSITECD"))
 DECLARE no_fixed_abode_cd = c8 WITH public, noconstant("ZZ99 3VZ")
#ukr_common_declares_exit
 SET last_mod = "202259"
 IF (validate(ukr_common_subroutines) != 0)
  GO TO ukr_common_subroutines_exit
 ENDIF
 DECLARE ukr_common_subroutines = i2 WITH public, constant(1)
 DECLARE checkdate(s_date_prompt=vc,use_time_ind=i2,end_time_ind=i2) = q8
 DECLARE getpromptid(i_prompt_num=i4,i_item_num=i4) = f8
 DECLARE getpromptdisp(i_prompt_num=i4,i_item_num=i4) = vc
 DECLARE getpromptitem(i_prompt_num=i4,i_item_num=i4) = vc
 DECLARE checkmrn(s_mrn_num=vc) = vc
 DECLARE columnexists(stable=vc,scolumn=vc) = i4
 DECLARE pm_get_cvo_alias() = c40
 SUBROUTINE checkdate(s_date_prompt,use_time_ind,end_time_ind)
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
 SUBROUTINE getpromptid(i_prompt_num,i_item_num)
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
 SUBROUTINE getpromptdisp(i_prompt_num,i_item_num)
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
 SUBROUTINE getpromptitem(i_prompt_num,i_item_num)
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
 SUBROUTINE checkmrn(s_mrn_num)
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
      SET i = (i+ 1)
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
 DECLARE log_message(logmsg=vc,loglvl=i4) = null
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
 DECLARE checkerror(s_status=c1,s_op_name=vc,s_op_status=c1,s_target_obj_name=vc) = i2
 DECLARE adderrormsg(s_status=c1,s_op_name=vc,s_op_status=c1,s_target_obj_name=vc,s_target_obj_value=
  vc) = null
 DECLARE showerrors(s_output=vc) = null
 DECLARE seterrorstoragemode(s_error_storage_mode=c1) = i2
 DECLARE ms_err_msg = vc WITH private, noconstant("")
 SET stat = error(ms_err_msg,1)
 FREE SET ms_err_msg
 SUBROUTINE checkerror(s_status,s_op_name,s_op_status,s_target_obj_name)
   DECLARE s_err_msg = vc WITH private, noconstant("")
   DECLARE l_err_code = i4 WITH private, noconstant(0)
   DECLARE l_err_cnt = i4 WITH private, noconstant(0)
   SET l_err_code = error(s_err_msg,0)
   WHILE (l_err_code > 0
    AND l_err_cnt < max_errors)
     SET errors->error_ind = 1
     SET l_err_cnt = (l_err_cnt+ 1)
     CALL adderrormsg(s_status,s_op_name,s_op_status,s_target_obj_name,s_err_msg)
     CALL log_message(s_err_msg,log_level_audit)
     SET l_err_code = error(s_err_msg,0)
   ENDWHILE
   RETURN(errors->error_ind)
 END ;Subroutine
 SUBROUTINE seterrorstoragemode(s_error_storage_mode)
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
 SUBROUTINE adderrormsg(s_status,s_op_name,s_op_status,s_target_obj_name,s_target_obj_value)
   SET errors->error_cnt = (errors->error_cnt+ 1)
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
 SUBROUTINE showerrors(s_output)
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
 SUBROUTINE log_message(logmsg,loglvl)
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
 DECLARE error_and_zero_check(qualnum=i4,opname=vc,logname=vc,errorforceexit=i2,zeroforceexit=i2) =
 i2
 SUBROUTINE error_and_zero_check(qualnum,opname,logname,errorforceexit,zeroforceexit)
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
 DECLARE populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),targetobjectname=
  vc(value),targetobjectvalue=vc(value)) = i2
 SUBROUTINE populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET subeventcnt = size(reply->status_data.subeventstatus,5)
    SET subeventsize = size(trim(reply->status_data.subeventstatus[subeventcnt].operationname))
    SET subeventsize = (subeventsize+ size(trim(reply->status_data.subeventstatus[subeventcnt].
      operationstatus)))
    SET subeventsize = (subeventsize+ size(trim(reply->status_data.subeventstatus[subeventcnt].
      targetobjectname)))
    SET subeventsize = (subeventsize+ size(trim(reply->status_data.subeventstatus[subeventcnt].
      targetobjectvalue)))
    IF (subeventsize > 0)
     SET subeventcnt = (subeventcnt+ 1)
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
 DECLARE populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) = i2
 SUBROUTINE populate_subeventstatus_msg(operationname,operationstatus,targetobjectname,
  targetobjectvalue,loglevel)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 DECLARE validationfailuremsg(s_output=vc,logmsg=vc,loglvl=vc) = null
 SUBROUTINE validationfailuremsg(s_output,logmsg,loglvl)
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
 IF (validate(ukr_expand_utils) != 0)
  GO TO ukr_expand_utils_exit
 ENDIF
 DECLARE setexpandsize(i_exp_size=i4) = null
 DECLARE padstruct(s_exp_list=vc,s_exp_item1=vc,s_exp_item2=vc,s_exp_item3=vc) = null
 DECLARE expandinit(i_orig_size=i4) = null
 DECLARE ukr_expand_utils = i2 WITH public, constant(1)
 DECLARE ms_dummyt_where = vc WITH public, constant(
  "initarray(ml_exp_start, evaluate(d.seq, 1, 1, ml_exp_start + ml_exp_size))")
 DECLARE ms_exp_base = vc WITH public, constant(
  "expand(ml_exp_idx, ml_exp_start, ml_exp_start + (ml_exp_size - 1),")
 DECLARE ml_exp_size_def = i4 WITH public, constant(25)
 DECLARE pad_struct = i2 WITH public, constant(0)
 DECLARE loadtemp = i2 WITH public, constant(1)
 DECLARE ml_exp_idx = i4 WITH public, noconstant(0)
 DECLARE ml_exp_size = i4 WITH public, noconstant(ml_exp_size_def)
 DECLARE ml_exp_start = i4 WITH public, noconstant(1)
 DECLARE ml_exp_list_size = i4 WITH public, noconstant(0)
 DECLARE ml_orig_size = i4 WITH public, noconstant(0)
 DECLARE ml_dummyt_seq = i4 WITH public, noconstant(0)
 SUBROUTINE setexpandsize(i_exp_size)
   IF (i_exp_size <= 0)
    SET ml_exp_size = ml_exp_size_def
    CALL echo(concat("ERROR - Invalid expand size, using default size of ",trim(cnvtstring(
        ml_exp_size_def),3)," ..."))
   ELSEIF (i_exp_size > 200)
    SET ml_exp_size = 200
    CALL echo("ERROR - Maximum expand size reached, using size of 200...")
   ELSE
    SET ml_exp_size = i_exp_size
   ENDIF
 END ;Subroutine
 SUBROUTINE expandinit(i_orig_size)
   IF (i_orig_size > 0)
    SET ml_exp_start = 1
    SET ml_exp_list_size = (ceil((cnvtreal(i_orig_size)/ ml_exp_size)) * ml_exp_size)
    SET ml_orig_size = i_orig_size
    SET ml_dummyt_seq = (1+ ((ml_exp_list_size - 1)/ ml_exp_size))
   ELSE
    SET ml_exp_start = 0
    SET ml_exp_list_size = 0
    SET ml_orig_size = 0
    SET ml_dummyt_seq = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE padstruct(s_exp_list,s_exp_item1,s_exp_item2,s_exp_item3)
   IF (textlen(trim(s_exp_list,3)) > 0
    AND textlen(trim(s_exp_item1,3)) > 0)
    EXECUTE ukr_expand_utils value(pad_struct), value(trim(s_exp_list,3)), value(trim(s_exp_item1,3)),
    value(trim(s_exp_item2,3)), value(trim(s_exp_item3,3))
    CALL expandinit(ml_orig_size)
   ENDIF
 END ;Subroutine
#ukr_expand_utils_exit
#ukr_common_rpt_exit
 DECLARE trust_id = f8
 DECLARE trust_rel_code = f8
 DECLARE fin_cd = f8
 DECLARE mrn_cd = f8
 SET trust_id = cnvtreal(getpromptid(2,1))
 SET trust_rel_code = uar_get_code_by("MEANING",369,"NHSTRUSTCHLD")
 SET mrn_cd = uar_get_code_by("DISPLAYKEY",319,"MRN")
 SET fin_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 SELECT INTO  $1
  patient = cnvtcap(p.name_full_formatted), cnn = cnvtalias(ea2.alias,ea2.alias_pool_cd), fin =
  cnvtalias(ea.alias,ea.alias_pool_cd),
  e.encntr_id, es.encntr_slice_flag, main_speciality = uar_get_code_display(s.service_category_cd),
  treatment_function_cd = uar_get_code_display(s.med_service_cd), facility = uar_get_code_display(e
   .loc_facility_cd), eb.man_alloc_req_ind,
  coding_state = uar_get_code_display(eb.state_cd), encounter_type = uar_get_code_display(e
   .encntr_type_cd), reg_date = e.reg_dt_tm"dd-mmm-yyyy;;d",
  discharge_dt = e.disch_dt_tm"dd-mmm-yyyy;;d"
  FROM encntr_alias ea,
   encntr_alias ea2,
   encounter e,
   person p,
   eem_benefit_alloc eb,
   encntr_slice es,
   service_category_hist s
  PLAN (e
   WHERE ((e.organization_id=trust_id) OR (e.organization_id IN (
   (SELECT
    oor.related_org_id
    FROM org_org_reltn oor
    WHERE oor.organization_id=trust_id
     AND oor.org_org_reltn_cd=trust_rel_code))))
    AND e.active_ind=1)
   JOIN (ea
   WHERE e.encntr_id=ea.encntr_id
    AND ea.encntr_alias_type_cd=fin_cd
    AND ea.active_ind=1)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.encntr_alias_type_cd=mrn_cd
    AND ea2.active_ind=1)
   JOIN (eb
   WHERE ea2.encntr_id=eb.encntr_id
    AND eb.active_ind=1
    AND eb.man_alloc_req_ind > 0
    AND eb.eem_benefit_id=0)
   JOIN (es
   WHERE es.encntr_slice_id=eb.encntr_slice_id
    AND es.active_ind=1)
   JOIN (s
   WHERE s.encntr_id=es.encntr_id
    AND es.beg_effective_dt_tm BETWEEN s.beg_effective_dt_tm AND s.end_effective_dt_tm)
   JOIN (p
   WHERE p.active_ind=1
    AND e.person_id=p.person_id)
  WITH nocounter, format, pcformat,
   separator = " "
 ;end select
END GO
