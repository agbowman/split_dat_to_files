CREATE PROGRAM bhs_eks_dta_to_hl7:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Target System:" = "",
  "Clinical Event ID:" = ""
  WITH outdev, s_target_sys, f_clin_event_id
 FREE RECORD m_rec
 RECORD m_rec(
   1 s_name_full = vc
   1 f_person_id = f8
   1 f_encntr_id = f8
   1 s_cmrn = vc
   1 s_fin = vc
   1 s_mrn = vc
   1 s_mrn_fac = vc
   1 s_name_first = vc
   1 s_name_middle = vc
   1 s_name_last = vc
   1 s_dob = vc
   1 s_sex = vc
   1 s_addr_line1 = vc
   1 s_addr_line2 = vc
   1 s_city = vc
   1 s_state = vc
   1 s_zip = vc
   1 s_home_phone = vc
   1 s_ssn = vc
   1 s_dta_disp = vc
   1 s_dta_res_val = vc
   1 s_dta_res_unit = vc
   1 s_msh_seg = vc
   1 s_pid_seg = vc
   1 s_obx_seg = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_name = vc
   1 file_buf = vc
   1 file_dir = i4
   1 file_offset = i4
 )
 DECLARE ms_target_sys = vc WITH protect, constant(trim(cnvtupper( $S_TARGET_SYS)))
 DECLARE mf_clin_event_id = f8 WITH protect, constant(cnvtreal( $F_CLIN_EVENT_ID))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE mf_ssn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,"SSN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_cur_name_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",213,"CURRENT"))
 DECLARE mf_male_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"MALE"))
 DECLARE mf_female_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"FEMALE"))
 DECLARE mf_home_phone_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE mf_home_addr_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE mf_adtegate_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",73,"ADTEGATE"))
 DECLARE ms_bm_str = vc WITH protect, constant(char(011))
 DECLARE ms_cr_str = vc WITH protect, constant(char(013))
 DECLARE ms_eom_str = vc WITH protect, constant(concat(char(28),char(13)))
 DECLARE mf_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_encntr_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_target_name = vc WITH protect, noconstant(" ")
 DECLARE ms_target_fac = vc WITH protect, noconstant(" ")
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ml_tmp = i4 WITH protect, noconstant(0)
 DECLARE mn_err_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_trans_name = vc WITH protect, noconstant(" ")
 DECLARE ms_file_name = vc WITH protect, noconstant(" ")
 DECLARE ms_file_path = vc WITH protect, noconstant(concat(trim(logical("bhscust"),3),"/diaghl7/"))
 DECLARE ms_dcl_str = vc WITH protect, noconstant(" ")
 DECLARE ml_dcl_stat = i4 WITH protect, noconstant(0)
 DECLARE ms_final_hl7_msg = vc WITH protect, noconstant(" ")
 SET retval = - (1)
 SELECT INTO "nl:"
  FROM clinical_event ce
  WHERE ce.clinical_event_id=mf_clin_event_id
  HEAD ce.clinical_event_id
   mf_person_id = ce.person_id, m_rec->f_person_id = ce.person_id, mf_encntr_id = ce.encntr_id,
   m_rec->f_encntr_id = ce.encntr_id, m_rec->s_dta_disp = trim(cnvtupper(uar_get_code_display(ce
      .event_cd))), m_rec->s_dta_res_val = trim(ce.result_val),
   m_rec->s_dta_res_unit = trim(uar_get_code_display(ce.result_units_cd))
  WITH nocounter
 ;end select
 IF (((curqual < 1) OR (((mf_person_id=0.0) OR (textlen(m_rec->s_dta_res_val)=0)) )) )
  IF (mf_person_id=0.0)
   SET ms_log = concat("Person ID not found for this CLINICAL EVENT_ID: ",trim(cnvtstring(
      mf_clin_event_id)))
  ENDIF
  IF (textlen(m_rec->s_dta_res_val)
   AND mf_person_id > 0.0)
   SET ms_log = concat(ms_log," DTA result is blank or not found.")
  ENDIF
  GO TO exit_script
 ENDIF
 SET ms_trans_name = concat(trim(cnvtstring(mf_encntr_id,20),3),"_",trim(cnvtstring(mf_clin_event_id)
   ),trim(format(sysdate,"YYYYMMDDHHMMSS;;q")))
 SET ms_file_name = concat("diag_hl7_",ms_trans_name,".txt")
 CASE (ms_target_sys)
  OF "PREMIERE":
   SET ms_target_name = "CLIN"
   SET ms_target_fac = "BHS"
 ENDCASE
 SET m_rec->s_msh_seg = concat("MSH|^~\&","|CERNER","|CERNER","|",ms_target_name,
  "|",ms_target_fac,"|",format(sysdate,"YYYYMMDDHHMMSS;;q"),"|",
  "|ADT^A08","|",replace(ms_trans_name,"_","",0),"|","|2.3 ")
 CALL echo("get cmrn, ssn")
 SELECT INTO "nl:"
  FROM person_alias pa
  WHERE pa.person_id=mf_person_id
   AND pa.active_ind=1
   AND pa.end_effective_dt_tm > sysdate
   AND pa.person_alias_type_cd IN (mf_cmrn_cd, mf_ssn_cd)
  ORDER BY pa.updt_dt_tm
  DETAIL
   IF (pa.person_alias_type_cd=mf_cmrn_cd)
    m_rec->s_cmrn = trim(pa.alias,3)
   ELSEIF (pa.person_alias_type_cd=mf_ssn_cd)
    m_rec->s_ssn = trim(pa.alias,3)
   ENDIF
  FOOT REPORT
   ml_tmp = textlen(m_rec->s_cmrn)
   IF (ml_tmp=0)
    mn_err_ind = 1, ms_log = concat(ms_log," CMRN size is 0. Check why CMRN was not found")
   ENDIF
   IF (ml_tmp < 7)
    FOR (ml_cnt = 1 TO (7 - ml_tmp))
      m_rec->s_cmrn = concat("0",m_rec->s_cmrn)
    ENDFOR
   ENDIF
  WITH nocounter
 ;end select
 IF (mn_err_ind=1)
  GO TO exit_script
 ENDIF
 CALL echo("get fin, mrn")
 SELECT INTO "nl:"
  FROM encntr_alias ea
  WHERE ea.encntr_id=mf_encntr_id
   AND ea.active_ind=1
   AND ea.end_effective_dt_tm > sysdate
   AND ea.encntr_alias_type_cd IN (mf_mrn_cd, mf_fin_cd)
  ORDER BY ea.updt_dt_tm
  DETAIL
   IF (ea.encntr_alias_type_cd=mf_mrn_cd)
    m_rec->s_mrn = trim(ea.alias,3), m_rec->s_mrn_fac = substring(1,3,uar_get_code_display(ea
      .alias_pool_cd))
   ELSEIF (ea.encntr_alias_type_cd=mf_fin_cd)
    m_rec->s_fin = trim(ea.alias,3)
   ENDIF
  FOOT REPORT
   ml_tmp = textlen(m_rec->s_mrn)
   IF (ml_tmp=0)
    mn_err_ind = 1, ms_log = concat(ms_log," MRN size is 0. Check why MRN was not found")
   ENDIF
   IF (ml_tmp < 7)
    FOR (ml_cnt = 1 TO (7 - ml_tmp))
      m_rec->s_mrn = concat("0",m_rec->s_mrn)
    ENDFOR
   ENDIF
   ml_tmp = 0, ml_tmp = size(m_rec->s_fin)
   IF (ml_tmp=0)
    mn_err_ind = 1, ms_log = concat(ms_log," FIN size is 0. Check why FIN was not found")
   ENDIF
   IF (ml_tmp < 10)
    FOR (ml_cnt = 1 TO (10 - ml_tmp))
      m_rec->s_fin = concat("0",m_rec->s_fin)
    ENDFOR
   ENDIF
  WITH nocounter
 ;end select
 IF (mn_err_ind=1)
  GO TO exit_script
 ENDIF
 CALL echo("get name")
 SELECT INTO "nl:"
  FROM person_name pn
  WHERE pn.person_id=mf_person_id
   AND pn.active_ind=1
   AND pn.end_effective_dt_tm > sysdate
   AND pn.name_type_cd=mf_cur_name_cd
  ORDER BY pn.name_type_seq
  DETAIL
   m_rec->s_name_first = trim(pn.name_first), m_rec->s_name_last = trim(pn.name_last), m_rec->
   s_name_middle = trim(pn.name_middle),
   m_rec->s_name_full = trim(pn.name_full)
  FOOT REPORT
   ml_tmp = size(m_rec->s_name_first)
   IF (ml_tmp=0)
    mn_err_ind = 1, ms_log = concat(ms_log,
     " First_Name size is 0. Check why FIRST_NAME was not found")
   ENDIF
   ml_tmp = 0, ml_tmp = size(m_rec->s_name_last)
   IF (ml_tmp=0)
    mn_err_ind = 1, ms_log = concat(ms_log," Last_Name size is 0. Check why LAST_NAME was not found")
   ENDIF
  WITH nocounter
 ;end select
 IF (mn_err_ind=1)
  GO TO exit_script
 ENDIF
 CALL echo("get sex")
 SELECT INTO "nl:"
  FROM person p
  WHERE p.person_id=mf_person_id
  DETAIL
   m_rec->s_dob = trim(format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),"YYYYMMDD;;q"
     ))
   IF (p.sex_cd=mf_female_cd)
    m_rec->s_sex = "F"
   ELSEIF (p.sex_cd=mf_male_cd)
    m_rec->s_sex = "M"
   ELSE
    m_rec->s_sex = "U"
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("get address")
 SELECT INTO "nl:"
  FROM address ad
  WHERE ad.parent_entity_name="PERSON"
   AND ad.parent_entity_id=mf_person_id
   AND ad.address_type_cd=mf_home_addr_cd
   AND ad.active_ind=1
   AND ad.end_effective_dt_tm > sysdate
   AND ad.address_type_seq=1
  DETAIL
   m_rec->s_addr_line1 = trim(ad.street_addr), m_rec->s_addr_line2 = trim(ad.street_addr2), m_rec->
   s_city = trim(ad.city),
   m_rec->s_zip = trim(ad.zipcode), m_rec->s_state = uar_get_code_display(ad.state_cd)
  WITH nocounter
 ;end select
 CALL echo("get phone")
 SELECT INTO "nl:"
  FROM phone ph
  WHERE ph.parent_entity_name="PERSON"
   AND ph.parent_entity_id=mf_person_id
   AND ph.phone_type_cd IN (mf_home_phone_cd)
   AND ph.phone_type_seq=1
   AND ph.active_ind=1
  DETAIL
   m_rec->s_home_phone = trim(ph.phone_num,3)
  WITH nocounter
 ;end select
 SET m_rec->s_pid_seg = concat("PID|1","|",m_rec->s_cmrn,"|",m_rec->s_mrn,
  "^^^",m_rec->s_mrn_fac,"|","|",m_rec->s_name_last,
  "^",m_rec->s_name_first,"^",m_rec->s_name_middle,"|",
  "|",m_rec->s_dob,"|",m_rec->s_sex,"|",
  "|","|",m_rec->s_addr_line1,"^",m_rec->s_addr_line2,
  "^",m_rec->s_city,"^",m_rec->s_state,"^",
  m_rec->s_zip,"|","|",m_rec->s_home_phone,"|",
  "|","|","|","|",m_rec->s_fin,
  "| ")
 SET m_rec->s_obx_seg = concat("OBX|1|ST","|",m_rec->s_dta_disp,"^",m_rec->s_dta_disp,
  "^","||",m_rec->s_dta_res_val,"|",m_rec->s_dta_res_unit,
  "|||||F")
 SET ms_final_hl7_msg = concat(ms_bm_str,m_rec->s_msh_seg,ms_cr_str,m_rec->s_pid_seg,ms_cr_str,
  m_rec->s_obx_seg,ms_eom_str)
 CALL echo(ms_final_hl7_msg)
 SET ms_log = concat("HL7 created for CLIN_EVENT_ID:",trim(cnvtstring(mf_clin_event_id))," DTA:",
  m_rec->s_dta_disp," ",
  m_rec->s_dta_res_val," ",m_rec->s_dta_res_unit," FileName:",ms_file_name)
 CALL echo("write file to disk")
 IF (mn_err_ind=0)
  SET frec->file_name = concat(ms_file_path,"suc/",ms_file_name)
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = ms_final_hl7_msg
  SET stat = cclio("WRITE",frec)
  SET stat = cclio("CLOSE",frec)
  SET ms_dcl_str = concat("mv ",ms_file_path,"suc/",ms_file_name," ",
   ms_file_path,"fin/",ms_file_name)
  CALL echo(ms_dcl_str)
  CALL dcl(ms_dcl_str,size(ms_dcl_str),ml_dcl_stat)
 ENDIF
 SET retval = 100
#exit_script
 IF (mn_err_ind=1)
  CALL echo("No file created")
 ENDIF
 CALL echo(ms_log)
 SET log_message = ms_log
 CALL echo(ml_dcl_stat)
 CALL echo(retval)
 CALL echo(log_message)
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
