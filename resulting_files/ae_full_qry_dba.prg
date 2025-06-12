CREATE PROGRAM ae_full_qry:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start of reporting period:" = "CURDATE",
  "End of reporting period:" = "CURDATE",
  "Trust:" = "",
  "Facility" = "",
  "AE Department" = ""
  WITH outdev, startdate, enddate,
  trust, facility, aeloc
 SET last_mod = "385946"
 IF (textlen(trim( $TRUST))=0)
  GO TO exit_program
 ENDIF
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
 DECLARE fac_pos = i2 WITH protect, constant(5)
 DECLARE amb_pos = i2 WITH protect, constant(6)
 DECLARE pref_report_index = i4 WITH noconstant(0)
 DECLARE pref_dbr_value = vc WITH noconstant("no")
 SET stat = prefacc_initialise(0)
 IF (stat=c_function_success)
  SET stat = prefacc_addreport("ae_full_qry",pref_report_index)
  SET stat = prefacc_getvalue(pref_report_index,"display breach reason",pref_dbr_value)
 ENDIF
 SET stat = prefacc_destroy(0)
 SUBROUTINE getweeknumber(test_dt_tm,countoption)
   IF (countoption=0)
    SET c_dt_string = concat("01-JAN-",cnvtstring(year(test_dt_tm))," 00:00")
   ELSEIF (month(test_dt_tm) < 4)
    SET c_dt_string = concat("01-APR-",cnvtstring((year(test_dt_tm) - 1)))
   ELSE
    SET c_dt_string = concat("01-APR-",cnvtstring(year(test_dt_tm)))
   ENDIF
   SET c_dt_tm = cnvtdatetime(concat(c_dt_string," 00:00"))
   SET c_dt_tm = datetimeadd(c_dt_tm,(- (mod((weekday(c_dt_tm) - 2),7)) - 1))
   SET weeknumber = cnvtint(datetimediff(test_dt_tm,c_dt_tm,2))
   RETURN(weeknumber)
 END ;Subroutine
 SET last_mod = "ae_full.inc:577415"
 DECLARE trust_id = f8
 DECLARE ae_cd = f8
 DECLARE stream_cd = f8
 DECLARE trust_rel_code = f8
 DECLARE mrn_cd = f8
 DECLARE att_cd = f8
 DECLARE fin_cd = f8
 DECLARE trust_name = vc
 DECLARE trust_ods = vc
 DECLARE start_date = vc
 DECLARE end_date = vc
 SET trust_id = cnvtreal(getpromptid(4,1))
 DECLARE c_nhs_org_alias_cd = f8 WITH constant(uar_get_code_by("MEANING",334,"NHSORGALIAS")), public
 SET ae_cd = uar_get_code_by("DISPLAYKEY",71,"EMERGENCYDEPARTMENT")
 SET stream_cd = uar_get_code_by("DISPLAYKEY",356,"STREAM")
 SET trust_rel_code = uar_get_code_by("MEANING",369,"NHSTRUSTCHLD")
 SET mrn_cd = uar_get_code_by("MEANING",4,"MRN")
 SET att_cd = uar_get_code_by("DISPLAYKEY",319,"VISITID")
 SET fin_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 DECLARE treatsitecd = f8 WITH protect, constant(uar_get_code_by("MEANING",17649,"TREATSITECD"))
 SET form_status_auth = uar_get_code_by("MEANING",8,"AUTH")
 SET form_status_modified = uar_get_code_by("MEANING",8,"MODIFIED")
 SET form_status_inprog = uar_get_code_by("MEANING",8,"IN PROGRESS")
 SET event_type_edbreachrsn = uar_get_code_by("DISPLAYKEY",72,"EDBREACHREASON")
 DECLARE current_time = q8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE end_dt_tm = q8 WITH public, constant(cnvtdatetime("31-DEC-2100"))
 DECLARE pos = i4 WITH public, noconstant(0)
 DECLARE counter = i4 WITH public, noconstant(0)
 DECLARE aetype_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",17649,"AEDEPTTYPE"))
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
 DECLARE ae_stream_opt_s = vc WITH public, noconstant("")
 DECLARE stream_opt_dt = dq8 WITH protect, noconstant(0.0)
 DECLARE stream_priority = c1 WITH protect, noconstant("")
 DECLARE option_date = vc WITH protect, noconstant("")
 DECLARE clinical_stream_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"CLINICALSTREAMING")),
 public
 DECLARE in_error_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE in_error_noview_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",8,"INERRNOVIEW"))
 DECLARE in_error_nomut_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",8,"INERRNOMUT"))
 DECLARE cancelled_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",8,"CANCELLED"))
 DECLARE not_done_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",8,"NOTDONE"))
 IF (not_done_cd <= 0.0)
  SET not_done_cd = uar_get_code_by("MEANING",8,"NOT DONE")
 ENDIF
 DECLARE ed_init_assess_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "EDINITIALASSESSMENT"))
 DECLARE disch_dept_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGEDEPARTMENT"))
 DECLARE idx = i4 WITH public, noconstant(0)
 DECLARE cancelled_track_event_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",16369,
   "CANCEL"))
 DECLARE encntr_type_where = vc WITH protect, noconstant("e.encntr_type_cd = ae_cd")
 IF (checkdic("PM_WAIT_LIST.FROM_ED_IND","A",0) > 0)
  SET encntr_type_where = build2("(",encntr_type_where," OR ",
   " (exists(select 1 from pm_wait_list pwl ","where pwl.encntr_id = e.encntr_id ",
   " and pwl.from_ed_ind = 1 "," and pwl.active_ind = 1)))")
 ENDIF
 IF (validate(fac_pos)
  AND validate(amb_pos))
  DECLARE idx = i2 WITH protect, noconstant(1)
  DECLARE loc_parser = vc WITH protect, noconstant("")
  DECLARE tmp_id = f8 WITH protect, noconstant(cnvtreal(getpromptid(amb_pos,idx)))
  DECLARE fac_disp = vc WITH protect, noconstant("")
  DECLARE aeloc_disp = vc WITH protect, noconstant("")
  SET tmp_id = getpromptid(fac_pos,idx)
  WHILE (tmp_id > 0.0)
    IF (idx=1)
     SET loc_parser = build2("loc_facility_cd in(",tmp_id)
     SET fac_disp = build2("Facility: ",getpromptdisp(fac_pos,idx))
    ELSE
     SET loc_parser = build2(loc_parser,", ",tmp_id)
     SET fac_disp = build2(fac_disp,", ",getpromptdisp(fac_pos,idx))
    ENDIF
    SET idx += 1
    SET tmp_id = getpromptid(fac_pos,idx)
  ENDWHILE
  SET idx = 1
  SET tmp_id = getpromptid(amb_pos,idx)
  WHILE (tmp_id > 0.0)
    IF (idx=1)
     SET loc_parser = build2("loc_nurse_unit_cd in(",tmp_id)
     SET aeloc_disp = build2("A&E department: ",getpromptdisp(amb_pos,idx))
    ELSE
     SET loc_parser = build2(loc_parser,", ",tmp_id)
     SET aeloc_disp = build2(aeloc_disp,", ",getpromptdisp(amb_pos,idx))
    ENDIF
    SET idx += 1
    SET tmp_id = getpromptid(amb_pos,idx)
  ENDWHILE
  IF (textlen(trim(loc_parser,3)) > 0)
   SET loc_parser = build2(loc_parser," )")
   SET encntr_type_where = build2("e.encntr_type_cd = ae_cd and e.",loc_parser)
   IF (checkdic("PM_WAIT_LIST.FROM_ED_IND","A",0) > 0)
    SET encntr_type_where = build2("((",encntr_type_where,") OR ",
     " (exists(select 1 from pm_wait_list pwl,encntr_loc_hist elh ",
     "where pwl.encntr_id = e.encntr_id ",
     " and pwl.from_ed_ind = 1 "," and pwl.active_ind = 1 "," and elh.encntr_id = pwl.encntr_id ",
     " and elh.",loc_parser,
     " and elh.active_ind = 1)))")
   ENDIF
  ENDIF
 ENDIF
 IF (( $STARTDATE="CURDATE"))
  SET start_date = format((curdate - 1),"DD-MMM-YYYY;;d")
 ELSE
  SET start_date =  $STARTDATE
 ENDIF
 IF (( $ENDDATE="CURDATE"))
  SET end_date = format(curdate,"DD-MMM-YYYY;;d")
 ELSE
  SET end_date =  $ENDDATE
 ENDIF
 DECLARE field_value1 = vc WITH public, constant(getoption1fieldvalue("AETREATDTOPT"))
 DECLARE treat_dt_opt_dt = dq8 WITH protect, noconstant(cnvtdate2(field_value1,"dd-mmm-yyyy"))
 IF (cnvtupper(format(treat_dt_opt_dt,"dd-mmm-yyyy;;d")) != cnvtupper(field_value1))
  CALL log_message(
   "Error: treatment date derivation option(UK Reporting configuration Code Set) in a wrong format.",
   log_level_warning)
  SET treat_dt_opt_dt = 0.0
 ENDIF
 SELECT INTO "nl:"
  FROM organization o,
   organization_alias oa
  PLAN (o
   WHERE o.organization_id=trust_id
    AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND o.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND o.active_ind=1)
   JOIN (oa
   WHERE oa.organization_id=o.organization_id
    AND oa.org_alias_type_cd=c_nhs_org_alias_cd
    AND oa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND oa.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND oa.active_ind=1)
  DETAIL
   trust_name = trim(o.org_name,3), trust_ods = trim(cnvtupper(oa.alias),3)
  WITH nocounter
 ;end select
 FREE SET aedata
 RECORD aedata(
   1 qual[*]
     2 encntr_id = f8
     2 ae_apc_ind = i2
     2 person_id = i4
     2 tracking_id = f8
     2 mrn_list[*]
       3 mrn = vc
     2 nhs_no = vc
     2 nhs_no_status = c2
     2 fullname = c50
     2 sex = c1
     2 dob = dq8
     2 fin = vc
     2 attendance = i4
     2 referralsource = c100
     2 stream = c50
     2 arrivaltime = dq8
     2 treatmentstarttime = dq8
     2 assessmenttime = dq8
     2 dtatime = dq8
     2 majorstime = dq8
     2 injuriestime = dq8
     2 pucctime = dq8
     2 paedstime = dq8
     2 bedrequesttime = dq8
     2 checkouttime = dq8
     2 disposition = c80
     2 timeinradiology = i4
     2 visitreason = c255
     2 attendancetype = c50
     2 checkoutpersonnel = vc
     2 diagnosis_code = c20
     2 diagnosis_language = c9
     2 diagnosis_text = c100
     2 clinician = c100
     2 dept_type = c2
     2 treatment_site_code = c5
     2 cliniciantype = c20
     2 cliniciantime = dq8
     2 ethnicity = c50
     2 breach_reason = vc
     2 treatmentstarttimeevent = dq8
     2 clinicalassigntimeevent = dq8
     2 point_dt_tm = dq8
     2 pm_stream = c50
     2 pf_stream = c50
 )
 SET ae_stream_opt_s = getoption1fieldvalue("AESTREAMOPT")
 IF (textlen(trim(ae_stream_opt_s,3)) > 0)
  SET stream_priority = trim(substring(1,1,ae_stream_opt_s),3)
  SET option_date = substring((findstring(":",ae_stream_opt_s,0)+ 1),textlen(ae_stream_opt_s),
   ae_stream_opt_s)
  SET stream_opt_dt = cnvtdatetime(cnvtdate2(option_date,"DD-MMM-YYYY"),0)
  IF ( NOT (stream_priority IN ("P", "C")))
   CALL log_message("Error: stream precedence option is not valid.",log_level_warning)
  ENDIF
  IF (cnvtupper(format(stream_opt_dt,"DD-MMM-YYYY;;d")) != cnvtupper(option_date))
   CALL log_message(
    "Error: stream date derivation option(UK Reporting configuration Code Set) in a wrong format.",
    log_level_warning)
   SET stream_opt_dt = 0.0
  ENDIF
 ENDIF
 FREE RECORD trusts
 RECORD trusts(
   1 trust_cnt = i4
   1 trust_list[*]
     2 trust_id = f8
 )
 SET stat = alterlist(trusts->trust_list,20)
 SET trusts->trust_list[1].trust_id = trust_id
 SET trusts->trust_cnt = 1
 SELECT INTO "nl:"
  FROM org_org_reltn oor
  WHERE oor.organization_id=trust_id
   AND oor.org_org_reltn_cd=trust_rel_code
   AND oor.active_ind=1
   AND oor.beg_effective_dt_tm < cnvtdatetime(sysdate)
   AND oor.end_effective_dt_tm > cnvtdatetime(sysdate)
  HEAD REPORT
   t_cnt = 1
  DETAIL
   t_cnt += 1
   IF (t_cnt > size(trusts->trust_list,5))
    stat = alterlist(trusts->trust_list,(t_cnt+ 20))
   ENDIF
   trusts->trust_list[t_cnt].trust_id = oor.related_org_id
  FOOT REPORT
   trusts->trust_cnt = t_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(trusts->trust_list,trusts->trust_cnt)
 SET stat = 0
 SET listcount = 0
 SELECT DISTINCT INTO "nl:"
  FROM encounter e,
   tracking_item ti,
   person p,
   encntr_alias ea
  PLAN (e
   WHERE e.arrive_dt_tm >= cnvtdatetime(cnvtdate2(start_date,"DD-MMM-YYYY"),0)
    AND e.arrive_dt_tm < cnvtdatetime(cnvtdate2(end_date,"DD-MMM-YYYY"),235959)
    AND expand(idx,1,trusts->trust_cnt,e.organization_id,trusts->trust_list[idx].trust_id)
    AND parser(encntr_type_where)
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (ti
   WHERE ti.encntr_id=e.encntr_id
    AND ti.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.name_last_key != "ZZZ*"
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND p.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd IN (fin_cd, att_cd)
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  ORDER BY e.arrive_dt_tm, e.encntr_id
  HEAD e.encntr_id
   listcount += 1, stat = alterlist(aedata->qual,listcount), aedata->qual[listcount].encntr_id = e
   .encntr_id,
   aedata->qual[listcount].person_id = e.person_id, aedata->qual[listcount].tracking_id = ti
   .tracking_id, aedata->qual[listcount].fullname = p.name_full_formatted,
   aedata->qual[listcount].sex = substring(1,1,uar_get_code_display(p.sex_cd)), aedata->qual[
   listcount].dob = p.birth_dt_tm, aedata->qual[listcount].referralsource = uar_get_code_display(e
    .admit_mode_cd),
   aedata->qual[listcount].arrivaltime = e.arrive_dt_tm, aedata->qual[listcount].visitreason = trim(e
    .reason_for_visit), aedata->qual[listcount].attendancetype = uar_get_code_display(e.readmit_cd),
   aedata->qual[listcount].ethnicity = uar_get_code_display(p.ethnic_grp_cd)
   IF (e.encntr_type_cd=ae_cd)
    aedata->qual[listcount].ae_apc_ind = 0, aedata->qual[listcount].disposition =
    uar_get_code_display(e.disch_disposition_cd)
   ELSE
    aedata->qual[listcount].disposition = "Admitted as Inpatient", aedata->qual[listcount].ae_apc_ind
     = 1
   ENDIF
  DETAIL
   IF (ea.encntr_alias_type_cd=fin_cd)
    aedata->qual[listcount].fin = cnvtalias(ea.alias,ea.alias_pool_cd)
   ELSEIF (ea.encntr_alias_type_cd=att_cd)
    aedata->qual[listcount].attendance = cnvtint(cnvtalias(ea.alias,ea.alias_pool_cd))
   ENDIF
  FOOT  e.encntr_id
   null
  WITH nocounter, expand = 1
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM encntr_info ei
  PLAN (ei
   WHERE expand(idx,1,listcount,ei.encntr_id,aedata->qual[idx].encntr_id)
    AND ei.info_sub_type_cd=stream_cd
    AND ei.active_ind=1)
  HEAD ei.encntr_id
   loc1 = locateval(idx,1,listcount,ei.encntr_id,aedata->qual[idx].encntr_id), aedata->qual[loc1].
   pm_stream = uar_get_code_display(ei.value_cd)
  FOOT  ei.encntr_id
   null
  WITH nocounter
 ;end select
 IF (listcount=0)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = listcount),
   tracking_checkin tc,
   code_value cv,
   prsnl p
  PLAN (d)
   JOIN (tc
   WHERE (tc.tracking_id=aedata->qual[d.seq].tracking_id)
    AND tc.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=tc.tracking_group_cd
    AND cv.cdf_meaning="ER"
    AND cv.active_ind=1)
   JOIN (p
   WHERE p.person_id=tc.checkout_id)
  ORDER BY tc.checkout_dt_tm
  DETAIL
   IF (tc.checkout_dt_tm=cnvtdatetime("31-DEC-2100 00:00"))
    aedata->qual[d.seq].checkouttime = 0, aedata->qual[d.seq].point_dt_tm = cnvtdatetime(sysdate)
   ELSE
    aedata->qual[d.seq].checkouttime = tc.checkout_dt_tm, aedata->qual[d.seq].checkoutpersonnel =
    trim(p.name_full_formatted), aedata->qual[d.seq].point_dt_tm = tc.checkout_dt_tm
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   clinical_event ce
  PLAN (e
   WHERE expand(idx,1,listcount,e.encntr_id,aedata->qual[idx].encntr_id))
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.event_cd=clinical_stream_cd
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
    AND  NOT (((ce.result_status_cd+ 0) IN (in_error_cd, in_error_noview_cd, in_error_nomut_cd,
   cancelled_cd))))
  ORDER BY e.encntr_id, ce.performed_dt_tm DESC
  HEAD e.encntr_id
   loc1 = locateval(idx,1,listcount,e.encntr_id,aedata->qual[idx].encntr_id), aedata->qual[loc1].
   pf_stream = trim(ce.result_val,3)
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = listcount)
  DETAIL
   IF (textlen(trim(aedata->qual[d1.seq].pm_stream,3)) > 0
    AND textlen(trim(aedata->qual[d1.seq].pf_stream,3))=0)
    aedata->qual[d1.seq].stream = aedata->qual[d1.seq].pm_stream
   ELSEIF (textlen(trim(aedata->qual[d1.seq].pf_stream,3)) > 0
    AND textlen(trim(aedata->qual[d1.seq].pm_stream,3))=0)
    aedata->qual[d1.seq].stream = aedata->qual[d1.seq].pf_stream
   ENDIF
   IF (textlen(trim(aedata->qual[d1.seq].pm_stream,3)) > 0
    AND textlen(trim(aedata->qual[d1.seq].pf_stream,3)) > 0)
    CASE (stream_priority)
     OF "C":
      IF ((aedata->qual[d1.seq].point_dt_tm <= stream_opt_dt))
       aedata->qual[d1.seq].stream = aedata->qual[d1.seq].pf_stream
      ELSEIF ((aedata->qual[d1.seq].point_dt_tm > stream_opt_dt))
       aedata->qual[d1.seq].stream = aedata->qual[d1.seq].pm_stream
      ENDIF
     OF "P":
      IF ((aedata->qual[d1.seq].point_dt_tm <= stream_opt_dt))
       aedata->qual[d1.seq].stream = aedata->qual[d1.seq].pm_stream
      ELSEIF ((aedata->qual[d1.seq].point_dt_tm > stream_opt_dt))
       aedata->qual[d1.seq].stream = aedata->qual[d1.seq].pf_stream
      ENDIF
     ELSE
      aedata->qual[d1.seq].stream = aedata->qual[d1.seq].pm_stream
    ENDCASE
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = listcount),
   tracking_prv_reln tpr,
   tracking_prsnl tp,
   track_reference tr,
   prsnl p,
   code_value cv
  PLAN (d)
   JOIN (tpr
   WHERE (tpr.tracking_id=aedata->qual[d.seq].tracking_id))
   JOIN (tp
   WHERE tp.person_id=tpr.tracking_provider_id)
   JOIN (cv
   WHERE cv.code_value=tp.tracking_group_cd
    AND cv.cdf_meaning="ER"
    AND cv.active_ind=1)
   JOIN (tr
   WHERE tr.tracking_ref_id=tp.tracking_prsnl_task_id)
   JOIN (p
   WHERE p.person_id=tp.person_id)
  ORDER BY tpr.assign_dt_tm DESC
  DETAIL
   aedata->qual[d.seq].clinician = p.name_full_formatted, aedata->qual[d.seq].cliniciantype = tr
   .display, aedata->qual[d.seq].cliniciantime = tpr.assign_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.seq, eventtype = tev.display_key
  FROM (dummyt d  WITH seq = listcount),
   tracking_event te,
   code_value cv,
   track_event tev
  PLAN (d)
   JOIN (te
   WHERE (te.tracking_id=aedata->qual[d.seq].tracking_id)
    AND te.event_status_cd != cancelled_track_event_cd
    AND te.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=te.tracking_group_cd
    AND cv.cdf_meaning="ER"
    AND cv.active_ind=1)
   JOIN (tev
   WHERE tev.track_event_id=te.track_event_id)
  ORDER BY d.seq, te.requested_dt_tm DESC
  DETAIL
   CASE (eventtype)
    OF "TREATMENTSTART":
     aedata->qual[d.seq].treatmentstarttimeevent = te.onset_dt_tm
    OF "ASSESSMENT":
    OF "PAEDASSESSMENT":
     aedata->qual[d.seq].assessmenttime = te.complete_dt_tm
    OF "ADMISSION":
    OF "ADMISSIONTOOBS":
     aedata->qual[d.seq].dtatime = te.requested_dt_tm
    OF "BEDREQUEST":
     aedata->qual[d.seq].bedrequesttime = te.requested_dt_tm
   ENDCASE
  WITH nocounter
 ;end select
 IF (checkdic("PM_WAIT_LIST.FROM_ED_IND","A",0) > 0)
  SELECT INTO "nl:"
   FROM pm_wait_list pwl
   PLAN (pwl
    WHERE expand(idx,1,listcount,pwl.encntr_id,aedata->qual[idx].encntr_id)
     AND pwl.from_ed_ind=1
     AND pwl.active_ind=1)
   HEAD pwl.encntr_id
    loc1 = locateval(idx,1,listcount,pwl.encntr_id,aedata->qual[idx].encntr_id)
    IF (trust_ods IN ("R1H", "RNJ"))
     IF ((aedata->qual[loc1].dtatime=0))
      aedata->qual[loc1].dtatime = pwl.admit_decision_dt_tm
     ENDIF
    ELSE
     aedata->qual[loc1].dtatime = pwl.admit_decision_dt_tm
    ENDIF
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = listcount),
   tracking_checkin tc,
   code_value cv,
   tracking_prv_reln tpr,
   tracking_prv_reln tpr2
  PLAN (d)
   JOIN (tc
   WHERE (tc.tracking_id=aedata->qual[d.seq].tracking_id)
    AND tc.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=tc.tracking_group_cd
    AND cv.cdf_meaning="ER"
    AND cv.active_ind=1)
   JOIN (tpr
   WHERE (tpr.tracking_provider_id= Outerjoin(tc.primary_doc_id))
    AND (tpr.tracking_id= Outerjoin(tc.tracking_id)) )
   JOIN (tpr2
   WHERE (tpr2.tracking_provider_id= Outerjoin(tc.primary_nurse_id))
    AND (tpr2.tracking_id= Outerjoin(tc.tracking_id)) )
  ORDER BY d.seq, tpr.assign_dt_tm, tpr2.assign_dt_tm
  HEAD d.seq
   doc_ind = 0, nurse_ind = 0
  DETAIL
   IF (tc.primary_doc_id > 0
    AND doc_ind=0
    AND tpr.tracking_provider_id=tc.primary_doc_id)
    aedata->qual[d.seq].clinicalassigntimeevent = tpr.assign_dt_tm, doc_ind = 1
   ENDIF
   IF (doc_ind=0
    AND nurse_ind=0
    AND tc.primary_doc_id <= 0
    AND tc.primary_nurse_id > 0
    AND tpr2.tracking_provider_id=tc.primary_nurse_id)
    aedata->qual[d.seq].clinicalassigntimeevent = tpr2.assign_dt_tm, nurse_ind = 1
   ENDIF
  FOOT  d.seq
   IF (((treat_dt_opt_dt >= curdate) OR (treat_dt_opt_dt=0.0)) )
    IF ((aedata->qual[d.seq].treatmentstarttimeevent > 0)
     AND (((aedata->qual[d.seq].treatmentstarttimeevent <= aedata->qual[d.seq].
    clinicalassigntimeevent)) OR ((aedata->qual[d.seq].clinicalassigntimeevent=0))) )
     aedata->qual[d.seq].treatmentstarttime = aedata->qual[d.seq].treatmentstarttimeevent
    ELSEIF ((aedata->qual[d.seq].clinicalassigntimeevent > 0)
     AND (((aedata->qual[d.seq].clinicalassigntimeevent < aedata->qual[d.seq].treatmentstarttimeevent
    )) OR ((aedata->qual[d.seq].treatmentstarttimeevent=0))) )
     aedata->qual[d.seq].treatmentstarttime = aedata->qual[d.seq].clinicalassigntimeevent
    ENDIF
   ELSE
    aedata->qual[d.seq].treatmentstarttime = aedata->qual[d.seq].treatmentstarttimeevent
   ENDIF
  WITH nocounter
 ;end select
 SET mrn_count = 0
 SELECT INTO "nl:"
  d.seq, mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
  FROM (dummyt d  WITH seq = listcount),
   org_alias_pool_reltn oa,
   person_alias pa
  PLAN (d)
   JOIN (oa
   WHERE ((oa.organization_id=trust_id) OR (oa.organization_id IN (
   (SELECT
    oor.related_org_id
    FROM org_org_reltn oor
    WHERE oor.organization_id=trust_id
     AND oor.org_org_reltn_cd=trust_rel_code))))
    AND oa.alias_entity_alias_type_cd=mrn_cd
    AND oa.active_ind=1
    AND oa.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND oa.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pa
   WHERE (pa.person_id=aedata->qual[d.seq].person_id)
    AND pa.alias_pool_cd=oa.alias_pool_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
  DETAIL
   mrn_count = (size(aedata->qual[d.seq].mrn_list,5)+ 1), stat = alterlist(aedata->qual[d.seq].
    mrn_list,mrn_count), aedata->qual[d.seq].mrn_list[mrn_count].mrn = mrn
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  nhs_sts = pm_get_cvo_alias(pa.person_alias_status_cd,contrib_src_nhsreport_cd)
  FROM (dummyt d  WITH seq = value(size(aedata->qual,5))),
   person_alias pa
  PLAN (d)
   JOIN (pa
   WHERE (pa.person_id=aedata->qual[d.seq].person_id)
    AND pa.person_alias_type_cd=pa_ssn_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
  DETAIL
   aedata->qual[d.seq].nhs_no = trim(cnvtalias(pa.alias,pa.alias_pool_cd),3), aedata->qual[d.seq].
   nhs_no_status = nhs_sts
  WITH nocounter
 ;end select
 SET code2 = fillstring(20," ")
 SELECT INTO "nl:"
  code = n.source_identifier, lang = uar_get_code_display(n.source_vocabulary_cd), text = n
  .source_string
  FROM (dummyt d  WITH seq = listcount),
   diagnosis di,
   nomenclature n
  PLAN (d)
   JOIN (di
   WHERE (di.encntr_id=aedata->qual[d.seq].encntr_id)
    AND di.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=di.nomenclature_id)
  ORDER BY di.diag_dt_tm
  DETAIL
   IF (trim(lang)="ICD-10")
    code2 = replace(code,".","",0)
    IF (textlen(trim(code2))=3)
     code2 = concat(trim(code2),"X")
    ENDIF
   ELSE
    code2 = code
   ENDIF
   aedata->qual[d.seq].diagnosis_code = code2, aedata->qual[d.seq].diagnosis_language = substring(1,9,
    lang), aedata->qual[d.seq].diagnosis_text = text
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pla_value = pm_get_cvo_alias(pla.value_cd,contrib_src_nhsreport_cd), nurse_unit =
  uar_get_code_display(tl.loc_nurse_unit_cd), room = uar_get_code_display(tl.loc_room_cd),
  arrive_time = tl.arrive_dt_tm, priority =
  IF (pla.location_cd=tl.loc_nurse_unit_cd) 1
  ELSEIF (pla.location_cd=tl.loc_room_cd) 2
  ELSE 3
  ENDIF
  FROM tracking_locator tl,
   pm_loc_attrib plaed,
   pm_loc_attrib pla
  PLAN (tl
   WHERE expand(counter,1,listcount,1,evaluate2(
     IF (tl.arrive_dt_tm < cnvtdatetime(aedata->qual[counter].point_dt_tm)) 1
     ELSE 0
     ENDIF
     ),
    tl.tracking_id,aedata->qual[counter].tracking_id))
   JOIN (plaed
   WHERE plaed.location_cd=tl.loc_nurse_unit_cd
    AND plaed.active_ind=1
    AND plaed.attrib_type_cd=aetype_cd)
   JOIN (pla
   WHERE pla.location_cd IN (tl.loc_nurse_unit_cd, tl.loc_room_cd, tl.loc_bed_cd)
    AND pla.attrib_type_cd IN (aetype_cd, treatsitecd)
    AND pla.active_ind=1)
  ORDER BY tl.tracking_id, tl.arrive_dt_tm DESC, priority
  HEAD tl.tracking_id
   idx = locateval(counter,1,listcount,tl.tracking_id,aedata->qual[counter].tracking_id), counter = 0
  HEAD tl.arrive_dt_tm
   counter += 1
  DETAIL
   IF (counter=1)
    CASE (pla.attrib_type_cd)
     OF aetype_cd:
      aedata->qual[idx].dept_type = pla_value
     OF treatsitecd:
      IF (priority=1)
       aedata->qual[idx].treatment_site_code = pla.value_string
      ENDIF
    ENDCASE
    IF (cnvtupper(nurse_unit)="*PAED*")
     aedata->qual[idx].paedstime = arrive_time
    ELSE
     CASE (cnvtupper(room))
      OF "*MAJOR*":
       aedata->qual[idx].majorstime = arrive_time
      OF "*MINOR*":
       aedata->qual[idx].injuriestime = arrive_time
      OF "*INJUR*":
       aedata->qual[idx].injuriestime = arrive_time
      OF "*PUCC*":
       aedata->qual[idx].pucctime = arrive_time
     ENDCASE
    ENDIF
   ENDIF
  FOOT  tl.arrive_dt_tm
   null
  FOOT  tl.tracking_id
   null
  WITH nocounter, expand = 1
 ;end select
 IF (disch_dept_cd >= 1.0)
  SELECT INTO "nl:"
   ce_value = pm_get_cvo_alias(ccr.result_cd,contrib_src_nhsreport_cd)
   FROM clinical_event ce,
    ce_coded_result ccr
   PLAN (ce
    WHERE expand(counter,1,listcount,ce.encntr_id,aedata->qual[counter].encntr_id)
     AND ce.event_cd=disch_dept_cd
     AND ce.valid_until_dt_tm=cnvtdatetime(end_dt_tm)
     AND  NOT (ce.result_status_cd IN (in_error_cd, in_error_noview_cd, in_error_nomut_cd,
    cancelled_cd)))
    JOIN (ccr
    WHERE ccr.event_id=ce.event_id
     AND ccr.valid_until_dt_tm=cnvtdatetime(end_dt_tm))
   ORDER BY ce.encntr_id, ce.performed_dt_tm DESC
   HEAD ce.encntr_id
    idx = locateval(counter,1,listcount,ce.encntr_id,aedata->qual[counter].encntr_id), aedata->qual[
    idx].dept_type = ce_value
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 IF (pref_dbr_value="yes")
  SELECT INTO "nl:"
   FROM dcp_forms_activity dfa,
    dcp_forms_activity_comp dfac,
    clinical_event ce1,
    clinical_event ce2,
    (dummyt d  WITH seq = listcount)
   PLAN (d)
    JOIN (dfa
    WHERE (dfa.encntr_id=aedata->qual[d.seq].encntr_id)
     AND dfa.form_status_cd IN (form_status_auth, form_status_modified, form_status_inprog)
     AND dfa.description="ED Breach Reason"
     AND dfa.active_ind=1)
    JOIN (dfac
    WHERE dfac.dcp_forms_activity_id=dfa.dcp_forms_activity_id
     AND dfac.parent_entity_name="CLINICAL_EVENT")
    JOIN (ce1
    WHERE ce1.parent_event_id=dfac.parent_entity_id
     AND ce1.valid_from_dt_tm < cnvtdatetime(current_time)
     AND ce1.valid_until_dt_tm > cnvtdatetime(current_time))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce1.event_id
     AND ce2.event_cd=event_type_edbreachrsn
     AND ce2.valid_from_dt_tm < cnvtdatetime(current_time)
     AND ce2.valid_until_dt_tm > cnvtdatetime(current_time))
   ORDER BY d.seq, ce2.clinical_event_id
   HEAD d.seq
    row + 0
   HEAD ce2.clinical_event_id
    aedata->qual[d.seq].breach_reason = ce2.result_val
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_date_result cdr
  PLAN (ce
   WHERE expand(counter,1,size(aedata->qual,5),ce.encntr_id,aedata->qual[counter].encntr_id)
    AND ce.valid_until_dt_tm=cnvtdatetime(end_dt_tm)
    AND ce.event_cd=ed_init_assess_cd
    AND  NOT (((ce.result_status_cd+ 0) IN (in_error_cd, in_error_noview_cd, in_error_nomut_cd,
   cancelled_cd, not_done_cd))))
   JOIN (cdr
   WHERE cdr.event_id=ce.event_id
    AND cdr.valid_until_dt_tm=cnvtdatetime(end_dt_tm))
  ORDER BY ce.encntr_id, cdr.result_dt_tm
  HEAD ce.encntr_id
   pos = locateval(counter,1,size(aedata->qual,5),ce.encntr_id,aedata->qual[counter].encntr_id),
   aedata->qual[pos].assessmenttime = cdr.result_dt_tm
  FOOT  ce.encntr_id
   null
  WITH nocounter, expand = 1
 ;end select
 SUBROUTINE (formattohhmm(arrival_time=q8,checkout_time=q8) =q8)
   SET diffnumber = datetimediff(checkout_time,arrival_time,4)
   SET hours = floor((diffnumber/ 60))
   SET mins = mod(diffnumber,60)
   RETURN(build(hours,":",format(mins,"##;P0")))
 END ;Subroutine
 SELECT
  IF (pref_dbr_value="yes")
   day_of_month = cnvtint(day(aedata->qual[d.seq].arrivaltime)), month_of_year = cnvtint(month(aedata
     ->qual[d.seq].arrivaltime)), year = cnvtint(year(aedata->qual[d.seq].arrivaltime)),
   week_no = getweeknumber(aedata->qual[d.seq].arrivaltime,0), day_of_week = cnvtint(weekday(aedata->
     qual[d.seq].arrivaltime)), mrn = substring(1,15,trim(aedata->qual[d.seq].mrn_list[1].mrn,3)),
   nhs_no = substring(1,30,trim(aedata->qual[d.seq].nhs_no,3)), nhs_no_status = trim(aedata->qual[d
    .seq].nhs_no_status,3), full_name = substring(1,50,trim(aedata->qual[d.seq].fullname,3)),
   sex = aedata->qual[d.seq].sex, dob = format(aedata->qual[d.seq].dob,"dd-mmm-yyyy;;d"), age =
   cnvtage(aedata->qual[d.seq].dob,aedata->qual[d.seq].arrivaltime,0),
   ethnic_group = substring(1,40,trim(aedata->qual[d.seq].ethnicity,3)), fin_no = substring(1,25,trim
    (aedata->qual[d.seq].fin,3)), att_no = aedata->qual[d.seq].attendance,
   attendance_type = substring(1,40,trim(aedata->qual[d.seq].attendancetype,3)), referral_source =
   substring(1,40,trim(aedata->qual[d.seq].referralsource,3)), stream = substring(1,40,trim(aedata->
     qual[d.seq].stream,3)),
   reason_for_visit = substring(1,255,trim(aedata->qual[d.seq].visitreason,3)), arrival_time = format
   (aedata->qual[d.seq].arrivaltime,"dd-mmm-yyyy hh:mm;;d"), arrival_hour = cnvtint(hour(aedata->
     qual[d.seq].arrivaltime)),
   assessment_time = format(aedata->qual[d.seq].assessmenttime,"dd-mmm-yyyy hh:mm;;d"),
   arrival_to_assessment =
   IF (datetimediff(aedata->qual[d.seq].assessmenttime,aedata->qual[d.seq].arrivaltime,1) >= 1)
    IF (datetimediff(aedata->qual[d.seq].assessmenttime,aedata->qual[d.seq].arrivaltime,1) >= 2)
     format(datetimediff(aedata->qual[d.seq].assessmenttime,aedata->qual[d.seq].arrivaltime),
      "DD Days HH:MM;;Z")
    ELSE format(datetimediff(aedata->qual[d.seq].assessmenttime,aedata->qual[d.seq].arrivaltime),
      "DD Day HH:MM;;Z")
    ENDIF
   ELSE format(cnvttime(datetimediff(aedata->qual[d.seq].assessmenttime,aedata->qual[d.seq].
       arrivaltime,4)),"HH:MM;;M")
   ENDIF
   , treatment_start_time = format(aedata->qual[d.seq].treatmentstarttime,"dd-mmm-yyyy hh:mm;;d"),
   arrival_to_treatment =
   IF (datetimediff(aedata->qual[d.seq].treatmentstarttime,aedata->qual[d.seq].arrivaltime,1) >= 1)
    IF (datetimediff(aedata->qual[d.seq].treatmentstarttime,aedata->qual[d.seq].arrivaltime,1) >= 2)
     format(datetimediff(aedata->qual[d.seq].treatmentstarttime,aedata->qual[d.seq].arrivaltime),
      "DD Days HH:MM;;Z")
    ELSE format(datetimediff(aedata->qual[d.seq].treatmentstarttime,aedata->qual[d.seq].arrivaltime),
      "DD Day HH:MM;;Z")
    ENDIF
   ELSE format(cnvttime(datetimediff(aedata->qual[d.seq].treatmentstarttime,aedata->qual[d.seq].
       arrivaltime,4)),"HH:MM;;M")
   ENDIF
   , clinician = substring(1,50,concat(trim(aedata->qual[d.seq].clinician)," ")),
   clinician_assign_time = format(aedata->qual[d.seq].cliniciantime,"DD-MMM-YYYY HH:MM;;D"),
   dta_time = format(aedata->qual[d.seq].dtatime,"dd-mmm-yyyy hh:mm;;d"), dta_to_disposal =
   IF (datetimediff(aedata->qual[d.seq].checkouttime,aedata->qual[d.seq].dtatime,1) >= 1)
    IF (datetimediff(aedata->qual[d.seq].checkouttime,aedata->qual[d.seq].dtatime,1) >= 2) format(
      datetimediff(aedata->qual[d.seq].checkouttime,aedata->qual[d.seq].dtatime),"DD Days HH:MM;;Z")
    ELSE format(datetimediff(aedata->qual[d.seq].checkouttime,aedata->qual[d.seq].dtatime),
      "DD Day HH:MM;;Z")
    ENDIF
   ELSE format(cnvttime(datetimediff(aedata->qual[d.seq].checkouttime,aedata->qual[d.seq].dtatime,4)),
     "HH:MM;;M")
   ENDIF
   , checkout_time = format(aedata->qual[d.seq].checkouttime,"dd-mmm-yyyy hh:mm;;d"),
   checkout_personnel = substring(1,50,trim(aedata->qual[d.seq].checkoutpersonnel,3)), los =
   formattohhmm(aedata->qual[d.seq].arrivaltime,aedata->qual[d.seq].checkouttime), breach_reason =
   substring(1,255,aedata->qual[d.seq].breach_reason),
   majors_time = format(aedata->qual[d.seq].majorstime,"dd-mmm-yyyy hh:mm;;d"), injuries_time =
   format(aedata->qual[d.seq].injuriestime,"dd-mmm-yyyy hh:mm;;d"), pucc_time = format(aedata->qual[d
    .seq].pucctime,"dd-mmm-yyyy hh:mm;;d"),
   paeds_time = format(aedata->qual[d.seq].paedstime,"dd-mmm-yyyy hh:mm;;d"), disposition = substring
   (1,40,trim(aedata->qual[d.seq].disposition,3)), diagnosis_code = substring(1,20,trim(aedata->qual[
     d.seq].diagnosis_code,3)),
   diagnosis_language = substring(1,9,trim(aedata->qual[d.seq].diagnosis_language,3)), diagnosis_text
    = substring(1,100,trim(aedata->qual[d.seq].diagnosis_text,3)), dept_type = aedata->qual[d.seq].
   dept_type,
   site_code = substring(1,5,trim(aedata->qual[d.seq].treatment_site_code,3))
  ELSE
   day_of_month = cnvtint(day(aedata->qual[d.seq].arrivaltime)), month_of_year = cnvtint(month(aedata
     ->qual[d.seq].arrivaltime)), year = cnvtint(year(aedata->qual[d.seq].arrivaltime)),
   week_no = getweeknumber(aedata->qual[d.seq].arrivaltime,0), day_of_week = cnvtint(weekday(aedata->
     qual[d.seq].arrivaltime)), mrn = substring(1,15,trim(aedata->qual[d.seq].mrn_list[1].mrn,3)),
   nhs_no = substring(1,30,trim(aedata->qual[d.seq].nhs_no,3)), nhs_no_status = trim(aedata->qual[d
    .seq].nhs_no_status,3), full_name = substring(1,50,trim(aedata->qual[d.seq].fullname,3)),
   sex = aedata->qual[d.seq].sex, dob = format(aedata->qual[d.seq].dob,"dd-mmm-yyyy;;d"), age =
   cnvtage(aedata->qual[d.seq].dob,aedata->qual[d.seq].arrivaltime,0),
   ethnic_group = substring(1,40,trim(aedata->qual[d.seq].ethnicity,3)), fin_no = substring(1,25,trim
    (aedata->qual[d.seq].fin,3)), att_no = aedata->qual[d.seq].attendance,
   attendance_type = substring(1,40,trim(aedata->qual[d.seq].attendancetype,3)), referral_source =
   substring(1,40,trim(aedata->qual[d.seq].referralsource,3)), stream = substring(1,40,trim(aedata->
     qual[d.seq].stream,3)),
   reason_for_visit = substring(1,255,trim(aedata->qual[d.seq].visitreason,3)), arrival_time = format
   (aedata->qual[d.seq].arrivaltime,"dd-mmm-yyyy hh:mm;;d"), arrival_hour = cnvtint(hour(aedata->
     qual[d.seq].arrivaltime)),
   assessment_time = format(aedata->qual[d.seq].assessmenttime,"dd-mmm-yyyy hh:mm;;d"),
   arrival_to_assessment =
   IF (datetimediff(aedata->qual[d.seq].assessmenttime,aedata->qual[d.seq].arrivaltime,1) >= 1)
    IF (datetimediff(aedata->qual[d.seq].assessmenttime,aedata->qual[d.seq].arrivaltime,1) >= 2)
     format(datetimediff(aedata->qual[d.seq].assessmenttime,aedata->qual[d.seq].arrivaltime),
      "DD Days HH:MM;;Z")
    ELSE format(datetimediff(aedata->qual[d.seq].assessmenttime,aedata->qual[d.seq].arrivaltime),
      "DD Day HH:MM;;Z")
    ENDIF
   ELSE format(cnvttime(datetimediff(aedata->qual[d.seq].assessmenttime,aedata->qual[d.seq].
       arrivaltime,4)),"HH:MM;;M")
   ENDIF
   , treatment_start_time = format(aedata->qual[d.seq].treatmentstarttime,"dd-mmm-yyyy hh:mm;;d"),
   arrival_to_treatment =
   IF (datetimediff(aedata->qual[d.seq].treatmentstarttime,aedata->qual[d.seq].arrivaltime,1) >= 1)
    IF (datetimediff(aedata->qual[d.seq].treatmentstarttime,aedata->qual[d.seq].arrivaltime,1) >= 2)
     format(datetimediff(aedata->qual[d.seq].treatmentstarttime,aedata->qual[d.seq].arrivaltime),
      "DD Days HH:MM;;Z")
    ELSE format(datetimediff(aedata->qual[d.seq].treatmentstarttime,aedata->qual[d.seq].arrivaltime),
      "DD Day HH:MM;;Z")
    ENDIF
   ELSE format(cnvttime(datetimediff(aedata->qual[d.seq].treatmentstarttime,aedata->qual[d.seq].
       arrivaltime,4)),"HH:MM;;M")
   ENDIF
   , clinician = substring(1,50,concat(trim(aedata->qual[d.seq].clinician)," ")),
   clinician_assign_time = format(aedata->qual[d.seq].cliniciantime,"DD-MMM-YYYY HH:MM;;D"),
   dta_time = format(aedata->qual[d.seq].dtatime,"dd-mmm-yyyy hh:mm;;d"), dta_to_disposal =
   IF (datetimediff(aedata->qual[d.seq].checkouttime,aedata->qual[d.seq].dtatime,1) >= 1)
    IF (datetimediff(aedata->qual[d.seq].checkouttime,aedata->qual[d.seq].dtatime,1) >= 2) format(
      datetimediff(aedata->qual[d.seq].checkouttime,aedata->qual[d.seq].dtatime),"DD Days HH:MM;;Z")
    ELSE format(datetimediff(aedata->qual[d.seq].checkouttime,aedata->qual[d.seq].dtatime),
      "DD Day HH:MM;;Z")
    ENDIF
   ELSE format(cnvttime(datetimediff(aedata->qual[d.seq].checkouttime,aedata->qual[d.seq].dtatime,4)),
     "HH:MM;;M")
   ENDIF
   , checkout_time = format(aedata->qual[d.seq].checkouttime,"dd-mmm-yyyy hh:mm;;d"),
   checkout_personnel = substring(1,50,trim(aedata->qual[d.seq].checkoutpersonnel,3)), los =
   formattohhmm(aedata->qual[d.seq].arrivaltime,aedata->qual[d.seq].checkouttime), majors_time =
   format(aedata->qual[d.seq].majorstime,"dd-mmm-yyyy hh:mm;;d"),
   injuries_time = format(aedata->qual[d.seq].injuriestime,"dd-mmm-yyyy hh:mm;;d"), pucc_time =
   format(aedata->qual[d.seq].pucctime,"dd-mmm-yyyy hh:mm;;d"), paeds_time = format(aedata->qual[d
    .seq].paedstime,"dd-mmm-yyyy hh:mm;;d"),
   disposition = substring(1,40,trim(aedata->qual[d.seq].disposition,3)), diagnosis_code = substring(
    1,20,trim(aedata->qual[d.seq].diagnosis_code,3)), diagnosis_language = substring(1,9,trim(aedata
     ->qual[d.seq].diagnosis_language,3)),
   diagnosis_text = substring(1,100,trim(aedata->qual[d.seq].diagnosis_text,3)), dept_type = aedata->
   qual[d.seq].dept_type, site_code = substring(1,5,trim(aedata->qual[d.seq].treatment_site_code,3))
  ENDIF
  INTO  $OUTDEV
  FROM (dummyt d  WITH seq = listcount)
  WITH nocounter, format, separator = " "
 ;end select
#exit_program
END GO
