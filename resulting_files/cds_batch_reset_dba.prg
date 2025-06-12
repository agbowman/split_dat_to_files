CREATE PROGRAM cds_batch_reset:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Choose a trust to reset:" = "",
  "Reset all activity from date:" = "CURDATE",
  "Reset all activity up to date:" = "CURDATE",
  "CDS Type:" = "",
  "File Version" = "6.1          ",
  "mars report id" = 0
  WITH outdev, trust, startdate,
  enddate, cdstype, version,
  mars_report_id
 SET last_mod = "817537"
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
 IF (validate(ukr_expand_utils) != 0)
  GO TO ukr_expand_utils_exit
 ENDIF
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
 SUBROUTINE (setexpandsize(i_exp_size=i4) =null)
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
 SUBROUTINE (expandinit(i_orig_size=i4) =null)
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
 SUBROUTINE (padstruct(s_exp_list=vc,s_exp_item1=vc,s_exp_item2=vc,s_exp_item3=vc) =null)
   IF (textlen(trim(s_exp_list,3)) > 0
    AND textlen(trim(s_exp_item1,3)) > 0)
    EXECUTE ukr_expand_utils value(pad_struct), value(trim(s_exp_list,3)), value(trim(s_exp_item1,3)),
    value(trim(s_exp_item2,3)), value(trim(s_exp_item3,3))
    CALL expandinit(ml_orig_size)
   ENDIF
 END ;Subroutine
#ukr_expand_utils_exit
#ukr_common_rpt_exit
 DECLARE trust_id = f8 WITH constant(cnvtreal(getpromptid(2,1))), protect
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
 DECLARE trust_nacs = vc WITH public, noconstant
 DECLARE trust_name = vc WITH public, noconstant
 DECLARE cdsoutdir_dcl = vc WITH public
 DECLARE a_count = i4 WITH public, noconstant(0)
 DECLARE alias_error_flag = i4 WITH public, noconstant(0)
 DECLARE current_dt_tm = q8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE idx = i4 WITH public, noconstant(0)
 DECLARE inprogress_ind = i4 WITH public, noconstant(0)
 IF (validate(parent_prog)=0)
  DECLARE parent_prog = vc WITH public, constant("CDS_BATCH_RESET")
 ENDIF
 SET debug_ind = nullcheck(parameter(7,1),parameter(7,1),0)
 FREE RECORD cdsbatch
 RECORD cdsbatch(
   1 batch[*]
     2 cds_batch_id = f8
     2 cds_batch_hist_id = f8
     2 cds_batch_type_cd = f8
     2 opwl_batch_ind = i2
     2 cds_batch_size = i4
     2 program_name = c30
     2 cds_batch_start_dt = dq8
     2 cds_batch_end_dt = dq8
     2 filename = c200
     2 parameter = c10
     2 content[*]
       3 cds_batch_content_id = f8
       3 cds_batch_cnt_hist_id = f8
       3 cds_type_cd = f8
       3 parent_entity_id = f8
       3 parent_entity_name = c30
       3 update_del_flag = i2
       3 encntr_id = f8
       3 cds_row_error_ind = i2
       3 activity_dt_tm = dq8
       3 cds_type_cd = f8
       3 cbc_alias_cnt = i4
       3 alias[*]
         4 cbc_alias_type_cd = f8
         4 cbc_alias = vc
       3 suppress_ind = i2
       3 transaction_type_cd = f8
       3 fs_parent_entity_name = vc
       3 fs_parent_entity_ident = vc
   1 request_dt_tm = dq8
   1 organization_id = f8
   1 org_code = c3
   1 rerun_flag = i2
   1 batch_type_request = f8
   1 testmode = i2
   1 anonymous = i2
   1 sensitive_ind = i2
   1 version
     2 major = i2
     2 minor = i2
     2 display = vc
 )
 SET resetdate = cnvtdatetime(cnvtdate2( $STARTDATE,"DD-MMM-YYYY"),0)
 SET reset_enddate = cnvtdatetime(cnvtdate2( $ENDDATE,"DD-MMM-YYYY"),0)
 CALL validateinputdata(resetdate,reset_enddate)
 SET cdsbatch->version.display = format(cnvtreal( $VERSION),"#.#;;F")
 SET cdsbatch->version.major = cnvtint(substring(1,1,cdsbatch->version.display))
 SET cdsbatch->version.minor = cnvtint(substring(3,1,cdsbatch->version.display))
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
 DECLARE ecds_switch = i2 WITH protect, noconstant(0)
 SET ecds_switch = cnvtint(getoption1fieldvalue("ECDSSWITCH"))
 IF ( NOT (ecds_switch IN (1, 2)))
  SET ecds_switch = 0
 ENDIF
 SET last_mod = "ukr_cds_prompt_batch_handler.inc:762426"
 IF (validate(cds_prompt_type)=0)
  RECORD cds_prompt_type(
    1 type_cnt = i1
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
    1 type[*]
      2 value_cd = f8
  )
  DECLARE curprog_upcase = vc WITH constant(cnvtupper(curprog)), protect
  SET idx = 1
  DECLARE prompt_idx = i1 WITH protect, noconstant(0)
  DECLARE prompt_num = i1 WITH protect, noconstant(0)
  IF (curprog_upcase="CDS_BATCH_RESET")
   SET prompt_idx = 5
  ELSEIF (curprog_upcase="UKR_CDS_CREATE_EXTRACTS")
   SET prompt_idx = 4
  ENDIF
  DECLARE cds_type_id = f8 WITH protect, noconstant(getpromptid(prompt_idx,idx))
  WHILE (cds_type_id > 0.0)
    SET cds_prompt_type->type_cnt += 1
    SET stat = alterlist(cds_prompt_type->type,cds_prompt_type->type_cnt)
    SET cds_prompt_type->type[cds_prompt_type->type_cnt].value_cd = cds_type_id
    SET idx += 1
    IF (trim(uar_get_code_meaning(cds_type_id),3)="OPA"
     AND (cdsbatch->version.major <= 6)
     AND (cdsbatch->version.minor <= 2))
     SET cds_prompt_type->type_cnt += 1
     SET stat = alterlist(cds_prompt_type->type,cds_prompt_type->type_cnt)
     SET cds_prompt_type->type[cds_prompt_type->type_cnt].value_cd = uar_get_code_by("MEANING",
      4001896,"OPF")
    ELSEIF (trim(uar_get_code_meaning(cds_type_id),3)="AE"
     AND (cdsbatch->version.major=6)
     AND (cdsbatch->version.minor=2))
     CALL echo(build2("ECDS SWITCH************** = ",ecds_switch))
     CASE (ecds_switch)
      OF 1:
       SET cds_prompt_type->type[cds_prompt_type->type_cnt].value_cd = uar_get_code_by("MEANING",
        4001896,"ECDS")
      OF 2:
       SET cds_prompt_type->type_cnt += 1
       SET stat = alterlist(cds_prompt_type->type,cds_prompt_type->type_cnt)
       SET cds_prompt_type->type[cds_prompt_type->type_cnt].value_cd = uar_get_code_by("MEANING",
        4001896,"ECDS")
     ENDCASE
    ENDIF
    SET cds_type_id = getpromptid(prompt_idx,idx)
  ENDWHILE
  IF ((cdsbatch->version.major=6)
   AND (cdsbatch->version.minor=1)
   AND locateval(prompt_num,1,cds_prompt_type->type_cnt,uar_get_code_by("MEANING",4001896,"ECDS"),
   cds_prompt_type->type[prompt_num].value_cd))
   CALL validationfailuremsg(value( $OUTDEV),build2(curprog,
     " Error: CDS could not generate ECDS for version 6.1"),log_level_info)
  ENDIF
 ENDIF
 IF ((cds_prompt_type->type_cnt=0))
  CALL validationfailuremsg(value( $OUTDEV),build2(curprog,
    " Error: User did not select a CDS Type from the prompt."),log_level_info)
 ENDIF
 FOR (idx = 1 TO cds_prompt_type->type_cnt)
   IF ((cds_prompt_type->type[idx].value_cd IN (cdstype_ae, cdstype_ecds)))
    SET cds_prompt_type->ae_flag = 1
   ENDIF
   IF ((cds_prompt_type->type[idx].value_cd=cdstype_apc))
    SET cds_prompt_type->apc_flag = 1
   ENDIF
   IF ((cds_prompt_type->type[idx].value_cd=cdstype_eal))
    SET cds_prompt_type->eal_flag = 1
   ENDIF
   IF ((cds_prompt_type->type[idx].value_cd=cdstype_opa))
    SET cds_prompt_type->opa_flag = 1
   ENDIF
   IF ((cds_prompt_type->type[idx].value_cd=cdstype_adc))
    SET cds_prompt_type->adc_flag = 1
   ENDIF
   IF ((cds_prompt_type->type[idx].value_cd=cdstype_csr))
    SET cds_prompt_type->csr_flag = 1
   ENDIF
   IF ((cds_prompt_type->type[idx].value_cd=cdstype_ccc))
    SET cds_prompt_type->ccc_flag = 1
   ENDIF
   IF ((cds_prompt_type->type[idx].value_cd=cdstype_cac))
    SET cds_prompt_type->cac_flag = 1
   ENDIF
   IF ((cds_prompt_type->type[idx].value_cd=cdstype_cgs))
    SET cds_prompt_type->cgs_flag = 1
   ENDIF
   IF ((cds_prompt_type->type[idx].value_cd=cdstype_cip))
    SET cds_prompt_type->cip_flag = 1
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM organization o,
   organization_alias oa
  PLAN (o
   WHERE o.organization_id=trust_id
    AND o.active_ind=1
    AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND o.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (oa
   WHERE oa.organization_id=o.organization_id
    AND oa.org_alias_type_cd=oa_nhs_alias_cd
    AND oa.active_ind=1
    AND oa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND oa.end_effective_dt_tm > cnvtdatetime(sysdate))
  HEAD REPORT
   a_count = 0
  HEAD oa.organization_id
   a_count += 1
  DETAIL
   trust_nacs = oa.alias, trust_name = o.org_name
  FOOT  oa.organization_id
   null
  FOOT REPORT
   null
  WITH nocounter
 ;end select
 IF (a_count > 1)
  SET alias_error_flag = 1
  GO TO exit_error
 ENDIF
 EXECUTE cds_batch_content
 IF (inprogress_ind=1)
  GO TO exit_error
 ENDIF
 EXECUTE cds_batch_create "MINE", trust_nacs, "",
  $VERSION,  $MARS_REPORT_ID
 IF (validate(util_seed_ind) != 1)
  IF (size(cdsbatch->batch,5) > 0)
   SELECT INTO  $OUTDEV
    b_id = cdsbatch->batch[d.seq].cds_batch_id, fn = cdsbatch->batch[d.seq].filename
    FROM (dummyt d  WITH seq = value(size(cdsbatch->batch,5)))
    ORDER BY b_id
    HEAD REPORT
     col 5, "CDS Content Reset from ", col + 2,
     CALL print(format(cnvtdatetime(resetdate),"@MEDIUMDATE")), row + 1, col 5,
     "CDS Batch Create Successfully Run", row + 1, col 5,
     "Date:", col + 2,
     CALL print(format(curdate,"DD-MMM-YYYY;;D")),
     row + 1, col 5, "Time:",
     col + 2, curtime, row + 1,
     col 5, "Trust:", col + 2,
     trust_name, row + 1, col 5,
     "File Version: ", col + 2,
     CALL print(format(cnvtreal( $VERSION),"#.#;;F")),
     row + 2, col 5, "The following files have been extracted to :",
     col + 2, cdsoutdir_dcl, row + 2,
     col 5, "Batch ID", col 35,
     "Filename", row + 1, col 5,
     "--------", col 35, "--------",
     row + 1
    HEAD b_id
     col 5,
     CALL print(format(cnvtint(b_id),";L")), col 35,
     CALL print(substring(1,80,fn)), row + 1
    FOOT  b_id
     row + 0
    FOOT REPORT
     row + 0
    WITH nocounter
   ;end select
  ELSE
   CALL echo("Nothing to process")
   SELECT INTO  $OUTDEV
    FROM dummyt d
    DETAIL
     col 10, "Nothing to process"
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (validate(util_seed_ind)=1
  AND size(cdsbatch->batch,5) > 0)
  SELECT INTO "nl:"
   b_id = cdsbatch->batch[d.seq].cds_batch_id, fn = cdsbatch->batch[d.seq].filename
   FROM (dummyt d  WITH seq = value(size(cdsbatch->batch,5)))
   ORDER BY b_id
   HEAD b_id
    opf_seed_disp = build(opf_seed_disp,char(13),char(10),cdsbatch->batch[d.seq].filename)
   WITH nocounter
  ;end select
 ELSEIF (validate(util_seed_ind)=1
  AND size(cdsbatch->batch,5)=0)
  SET opf_seed_disp = "No Activity to Process for this time period"
 ENDIF
#exit_error
 IF (parent_prog="CDS_BATCH_RESET")
  IF (checkerror(failure,"CCL ERROR",failure,"FINAL ERROR CHECK") > 0)
   CALL showerrors(value( $OUTDEV))
  ENDIF
  FREE RECORD reply
 ENDIF
 IF (alias_error_flag=1)
  IF (validate(util_seed_ind) != 1)
   SELECT INTO  $OUTDEV
    FROM dummyt d
    DETAIL
     col 10, "More than one organisation matches the NACS code entered - please ensure", row + 1,
     col 10,
     "there is only one organisation per active and effective NACS code built in the database"
    WITH nocounter
   ;end select
  ELSE
   SET opf_seed_disp = build2("NACS code for this trust matches more than one organization",char(13),
    char(10),"Please ensure there is only one organisation per active and effective NACS code built")
  ENDIF
 ENDIF
 IF (inprogress_ind=1)
  IF (validate(util_seed_ind) != 1)
   CALL validationfailuremsg(value( $OUTDEV),
    "CDS Batch Content Error: Another instance of cds_batch_content is currently executing please try again later.",
    log_level_info)
  ELSE
   SET opf_seed_disp = build2(
    "Another instance of cds_batch_content is currently executing. Batches not created for this period"
    )
  ENDIF
 ENDIF
 SUBROUTINE (validateinputdata(initcheckdate=q8,endcheckdate=q8) =null)
   IF (trust_id=0.0)
    CALL validationfailuremsg(value( $OUTDEV),
     "CDS Batch Content Error: User did not select a trust from the prompt.",log_level_info)
   ENDIF
   IF (((initcheckdate=0.0) OR (endcheckdate=0.0)) )
    CALL validationfailuremsg(value( $OUTDEV),
     "CDS Batch Content Error: User did not set Reset FROM date or Reset TO date.",log_level_info)
   ENDIF
   SET idx = 1
   DECLARE cds_type_id = f8 WITH protect, noconstant(getpromptid(5,idx))
   DECLARE compcheckdate = i4 WITH protect, noconstant(datetimecmp(endcheckdate,initcheckdate))
   IF (compcheckdate < 0)
    CALL validationfailuremsg(value( $OUTDEV),
     "CDS Batch Content Error: Entered Reset FROM date is after the Reset TO date",log_level_info)
   ELSEIF (compcheckdate > 35)
    CALL validationfailuremsg(value( $OUTDEV),
     "CDS Batch Content Error: Start and end dates cannot be greater than 35 days apart",
     log_level_info)
   ELSEIF (((initcheckdate > current_dt_tm) OR (endcheckdate > current_dt_tm)) )
    CALL validationfailuremsg(value( $OUTDEV),
     "CDS Batch Content Error: Start or end dates are after the current date",log_level_info)
   ENDIF
   SET reset_enddate = cnvtdatetime(cnvtdate2( $ENDDATE,"DD-MMM-YYYY"),235959)
 END ;Subroutine
#exit_script
END GO
