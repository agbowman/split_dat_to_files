CREATE PROGRAM al_bhs_eks_diag_to_hl7:dba
 DECLARE ml_mod_option = vc WITH protect, constant(trim( $1))
 DECLARE ms_cr_str = vc WITH protect, constant(char(013))
 DECLARE ms_bm_str = vc WITH protect, constant(char(011))
 DECLARE ms_eom_str = vc WITH protect, constant(concat(char(28),char(13)))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE mf_ssn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,"SSN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_current_name_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",213,"CURRENT"))
 DECLARE mf_male_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"MALE"))
 DECLARE mf_female_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"FEMALE"))
 DECLARE mf_phone_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE mf_addr_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE mf_icd9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",400,"ICD9CM"))
 DECLARE mf_icd10_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"ICD10-CM"))
 DECLARE mf_orgdoc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",320,
   "ORGANIZATIONDOCTOR"))
 DECLARE mf_primary_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",12034,"PRIMARY"))
 DECLARE mf_secondary_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",12034,"SECONDARY"))
 DECLARE mf_tertiary_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",12034,"TERTIARY"))
 DECLARE mf_adtegate_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",73,"ADTEGATE"))
 DECLARE mf_sch_patient_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14250,"PATIENT"))
 DECLARE mf_powerchart_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",89,"POWERCHART"))
 DECLARE ms_tmp_message = vc WITH protect, noconstant("")
 DECLARE ml_tmp_retval = i4 WITH protect, noconstant(0)
 DECLARE ml_text = vc WITH protect, noconstant("")
 DECLARE ml_t_size = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_p_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_err_ind = i4 WITH protect, noconstant(0)
 DECLARE ml_err_msg = vc WITH protect, noconstant("")
 DECLARE ms_trans_name = vc WITH protect, noconstant("")
 DECLARE ms_file_name = vc WITH protect, noconstant("")
 DECLARE ms_email = vc WITH protect, noconstant("")
 DECLARE ms_file_path = vc WITH protect, noconstant(concat(trim(logical("bhscust"),3),"/diaghl7/"))
 DECLARE ml_dmc_ret = i4 WITH protect, noconstant(0)
 DECLARE ms_cmd_str = vc WITH protect, noconstant("")
 DECLARE ms_final_hl7_msg = vc WITH protect, noconstant("")
 DECLARE ml_output_size = i4 WITH protect, noconstant(10000)
 FREE RECORD prsn_info
 RECORD prsn_info(
   1 cnt = i4
   1 cmrn = vc
   1 mrn = vc
   1 fin_nbr = vc
   1 mrn_fac = vc
   1 name_first = vc
   1 name_middle = vc
   1 name_last = vc
   1 dob = vc
   1 gender = vc
   1 addr_line1 = vc
   1 addr_line2 = vc
   1 city = vc
   1 state = vc
   1 zip_code = vc
   1 home_phone_num = vc
   1 ssn = vc
   1 msh_hl7_slice = vc
   1 pid_hl7_slice = vc
   1 pv1_hl7_slice = vc
   1 encntr_class_cd = f8
   1 encntr_class_value = vc
   1 med_service_cd = f8
   1 med_service__value = vc
   1 encntr_type_cd = f8
   1 encntr_type_value = vc
   1 sch_cnt = i4
   1 sch[*]
     2 alias = vc
   1 diag[*]
     2 diag_id = f8
     2 icd_code = vc
     2 icd_type = vc
     2 description = vc
     2 diag_date = vc
     2 diag_type = vc
     2 diag_priority = vc
     2 diag_prsnl_id = f8
     2 diag_prsnl_alias = vc
     2 diag_hl7_slice = vc
 ) WITH protect
 SET ml_tmp_retval = - (1)
 SET retval = ml_tmp_retval
 SET ms_tmp_message = build("Starting script person_id = ",trigger_personid)
 SET ms_tmp_message = build(ms_tmp_message," encounter_id = ",trigger_encntrid)
 SET ms_trans_name = concat(trim(cnvtstring(trigger_personid,20),3),"_",trim(cnvtstring(
    trigger_encntrid,20),3),"_",format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;q"))
 IF (ml_mod_option="A")
  SET ml_pos = 1
  SET ms_tmp_message = build(ms_tmp_message," misc1 = ",eksdata->tqual[3].qual[ml_pos].data[1].misc,
   " misc2 = ",eksdata->tqual[3].qual[ml_pos].data[2].misc)
 ELSEIF (ml_mod_option="U")
  SET ml_pos = 2
  SET ms_tmp_message = build(ms_tmp_message," misc1 = ",eksdata->tqual[3].qual[ml_pos].data[1].misc,
   " misc2 = ",eksdata->tqual[3].qual[ml_pos].data[2].misc)
 ELSEIF (ml_mod_option="D")
  SET ml_pos = 3
  SET ms_tmp_message = build(ms_tmp_message," misc1 = ",eksdata->tqual[3].qual[ml_pos].data[1].misc,
   " misc2 = ",eksdata->tqual[3].qual[ml_pos].data[2].misc)
 ENDIF
 SET ms_file_name = concat("diag_hl7_",trim(cnvtstring(cnvtreal(eksdata->tqual[3].qual[ml_pos].data[2
     ].misc),20),3),"_",ms_trans_name,".txt")
 SELECT INTO "nl:"
  FROM diagnosis d,
   nomenclature n
  WHERE d.diagnosis_id=cnvtreal(eksdata->tqual[3].qual[ml_pos].data[2].misc)
   AND n.nomenclature_id=d.nomenclature_id
   AND n.source_vocabulary_cd IN (mf_icd9_cd, mf_icd10_cd)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ml_err_ind = 1
  SET ms_tmp_message = build(ms_tmp_message," Diagnosis is not associated with ICD9 or ICD10")
  GO TO exit_program
 ENDIF
 SET prsn_info->msh_hl7_slice = build("MSH|^~\&","|CERNER","|CERNER","|ADT DIAG","|PATIENTKEEPER",
  "|",format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;q"),"|","|ADT^A08","|",
  replace(ms_trans_name,"_","",0),"|","|2.3 ")
 SELECT INTO "nl:"
  FROM person_alias pa
  WHERE pa.person_id=trigger_personid
   AND pa.active_ind=1
   AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   AND pa.person_alias_type_cd IN (mf_cmrn_cd, mf_ssn_cd)
  ORDER BY pa.updt_dt_tm
  DETAIL
   IF (pa.person_alias_type_cd=mf_cmrn_cd)
    prsn_info->cmrn = trim(pa.alias,3)
   ENDIF
   IF (pa.person_alias_type_cd=mf_ssn_cd)
    prsn_info->ssn = trim(pa.alias,3)
   ENDIF
  FOOT REPORT
   ml_t_size = size(prsn_info->cmrn)
   IF (ml_t_size=0)
    ml_err_ind = 1, ms_tmp_message = build(ms_tmp_message,
     " CMRN size is 0. Check why CMRN was not found")
   ENDIF
   IF (ml_t_size < 7)
    FOR (ml_cnt = 1 TO (7 - ml_t_size))
      prsn_info->cmrn = concat("0",prsn_info->cmrn)
    ENDFOR
   ENDIF
  WITH nocounter
 ;end select
 IF (ml_err_ind=1)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM encntr_alias ea
  WHERE ea.encntr_id=trigger_encntrid
   AND ea.active_ind=1
   AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   AND ea.encntr_alias_type_cd IN (mf_mrn_cd, mf_fin_cd)
  ORDER BY ea.updt_dt_tm
  DETAIL
   IF (ea.encntr_alias_type_cd=mf_mrn_cd)
    prsn_info->mrn = trim(ea.alias,3), prsn_info->mrn_fac = substring(1,3,uar_get_code_display(ea
      .alias_pool_cd))
   ENDIF
   IF (ea.encntr_alias_type_cd=mf_fin_cd)
    prsn_info->fin_nbr = trim(ea.alias,3)
   ENDIF
  FOOT REPORT
   ml_t_size = size(prsn_info->mrn)
   IF (ml_t_size=0)
    ml_err_ind = 1, ms_tmp_message = build(ms_tmp_message,
     " MRN size is 0. Check why MRN was not found")
   ENDIF
   IF (ml_t_size < 7)
    FOR (ml_cnt = 1 TO (7 - ml_t_size))
      prsn_info->mrn = concat("0",prsn_info->mrn)
    ENDFOR
   ENDIF
   ml_t_size = size(prsn_info->fin_nbr)
   IF (ml_t_size=0)
    ml_err_ind = 1, ms_tmp_message = build(ms_tmp_message,
     " FIN size is 0. Check why FIN was not found")
   ENDIF
   IF (ml_t_size < 10)
    FOR (ml_cnt = 1 TO (10 - ml_t_size))
      prsn_info->fin_nbr = concat("0",prsn_info->fin_nbr)
    ENDFOR
   ENDIF
  WITH nocounter
 ;end select
 IF (ml_err_ind=1)
  GO TO exit_program
 ENDIF
 IF (size(trim(prsn_info->fin_nbr,3))=0)
  SET ml_err_ind = 1
  SET ms_tmp_message = build(ms_tmp_message," No rows found on encntr_alias table. Skip message.")
  SET ms_email = concat("Found an encounter without data on encntr_alias.",char(13),"Dt/Tm: ",trim(
    format(sysdate,"mm/dd/yy hh:mm;;d")),char(13),
   char(13),"Person ID: ",trim(cnvtstring(trigger_personid,20)),char(13),"Encounter ID: ",
   trim(cnvtstring(trigger_encntrid,20)),char(13),"Node: ",curnode,char(13),
   "Domain: ",curdomain)
  CALL uar_send_mail(nullterm("angelce.lazovski@bhs.org"),nullterm(concat(
     "Blank account encountered (PK) ",trim(format(sysdate,"mm/dd/yy hh:mm;;d")))),nullterm(ms_email),
   nullterm("PK Diagnosis Rule"),1,
   nullterm("IPM.NOTE"))
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM person_name pn
  WHERE pn.person_id=trigger_personid
   AND pn.active_ind=1
   AND pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   AND pn.name_type_cd=mf_current_name_cd
  ORDER BY pn.name_type_seq
  DETAIL
   prsn_info->name_first = trim(pn.name_first), prsn_info->name_last = trim(pn.name_last), prsn_info
   ->name_middle = trim(pn.name_middle)
  FOOT REPORT
   ml_t_size = size(prsn_info->name_first)
   IF (ml_t_size=0)
    ml_err_ind = 1, ms_tmp_message = build(ms_tmp_message,
     " First_Name size is 0. Check why FIRST_NAME was not found")
   ENDIF
   ml_t_size = size(prsn_info->name_last)
   IF (ml_t_size=0)
    ml_err_ind = 1, ms_tmp_message = build(ms_tmp_message,
     " Last_Name size is 0. Check why LAST_NAME was not found")
   ENDIF
  WITH nocounter
 ;end select
 IF (ml_err_ind=1)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM person p
  WHERE p.person_id=trigger_personid
  DETAIL
   prsn_info->dob = format(p.birth_dt_tm,"YYYYMMDD;;q")
   IF (p.sex_cd=mf_female_cd)
    prsn_info->gender = "F"
   ELSEIF (p.sex_cd=mf_male_cd)
    prsn_info->gender = "M"
   ELSE
    prsn_info->gender = "U"
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM address ad
  WHERE ad.parent_entity_name="PERSON"
   AND ad.parent_entity_id=trigger_personid
   AND ad.address_type_cd=mf_addr_home_cd
   AND ad.active_ind=1
   AND ad.end_effective_dt_tm > sysdate
   AND ad.address_type_seq=1
  DETAIL
   prsn_info->addr_line1 = trim(ad.street_addr), prsn_info->addr_line2 = trim(ad.street_addr2),
   prsn_info->city = trim(ad.city),
   prsn_info->zip_code = trim(ad.zipcode), prsn_info->state = uar_get_code_display(ad.state_cd)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM phone ph
  WHERE ph.parent_entity_name="PERSON"
   AND ph.parent_entity_id=trigger_personid
   AND ph.phone_type_cd IN (mf_phone_home_cd)
   AND ph.phone_type_seq=1
  DETAIL
   prsn_info->home_phone_num = trim(ph.phone_num,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e
  WHERE e.encntr_id=trigger_encntrid
  DETAIL
   prsn_info->med_service_cd = e.med_service_cd, prsn_info->encntr_class_cd = e.encntr_class_cd,
   prsn_info->encntr_type_cd = e.encntr_type_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value_alias cva
  WHERE cva.code_value IN (prsn_info->med_service_cd, prsn_info->encntr_class_cd, prsn_info->
  encntr_type_cd)
   AND cva.contributor_source_cd=mf_adtegate_cd
  ORDER BY cva.alias DESC
  DETAIL
   IF ((cva.code_value=prsn_info->med_service_cd))
    prsn_info->med_service__value = trim(cva.alias,3)
   ENDIF
   IF ((cva.code_value=prsn_info->encntr_class_cd))
    prsn_info->encntr_class_value = trim(cva.alias,3)
   ENDIF
   IF ((cva.code_value=prsn_info->encntr_type_cd))
    prsn_info->encntr_type_value = trim(cva.alias,3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM sch_appt sa,
   sch_event_alias sea
  WHERE sa.encntr_id=trigger_encntrid
   AND sa.sch_role_cd=mf_sch_patient_cd
   AND sea.sch_event_id=sa.sch_event_id
  ORDER BY sea.alias
  HEAD REPORT
   prsn_info->sch_cnt = 0
  HEAD sea.alias
   IF (size(trim(sea.alias,3)) > 0)
    prsn_info->sch_cnt = (prsn_info->sch_cnt+ 1), stat = alterlist(prsn_info->sch,prsn_info->sch_cnt),
    prsn_info->sch[prsn_info->sch_cnt].alias = sea.alias
   ENDIF
  WITH nocounter
 ;end select
 SET prsn_info->pv1_hl7_slice = build("PV1|1","|",prsn_info->encntr_class_value,"|","|",
  "|","|","|","|","|",
  "|",prsn_info->med_service__value,"|","|","|",
  "|","|","|","|","|",
  prsn_info->encntr_type_value,"|")
 SET prsn_info->pid_hl7_slice = build("PID|1","|",prsn_info->cmrn,"|",prsn_info->mrn,
  "^^^",prsn_info->mrn_fac,"|","|",prsn_info->name_last,
  "^",prsn_info->name_first,"^",prsn_info->name_middle,"|",
  "|",prsn_info->dob,"|",prsn_info->gender,"|",
  "|","|",prsn_info->addr_line1,"^",prsn_info->addr_line2,
  "^",prsn_info->city,"^",prsn_info->state,"^",
  prsn_info->zip_code,"|","|",prsn_info->home_phone_num,"|",
  "|","|","|","|",prsn_info->fin_nbr,
  "|","|")
 IF ((prsn_info->sch_cnt > 0))
  FOR (ml_loop = 1 TO prsn_info->sch_cnt)
    IF (ml_loop=1)
     SET prsn_info->pid_hl7_slice = build(prsn_info->pid_hl7_slice,"|",prsn_info->sch[ml_loop].alias)
    ELSE
     SET prsn_info->pid_hl7_slice = build(prsn_info->pid_hl7_slice,"~",prsn_info->sch[ml_loop].alias)
    ENDIF
  ENDFOR
  SET prsn_info->pid_hl7_slice = build(prsn_info->pid_hl7_slice,"||")
 ELSE
  SET prsn_info->pid_hl7_slice = build(prsn_info->pid_hl7_slice,"|||")
 ENDIF
 SELECT INTO "nl:"
  FROM diagnosis d,
   nomenclature n
  WHERE d.encntr_id=trigger_encntrid
   AND d.person_id=trigger_personid
   AND d.active_ind=1
   AND d.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   AND d.contributor_system_cd=mf_powerchart_cd
   AND n.nomenclature_id=d.nomenclature_id
   AND n.source_vocabulary_cd IN (mf_icd9_cd, mf_icd10_cd)
  HEAD REPORT
   prsn_info->cnt = 0
  DETAIL
   prsn_info->cnt = (prsn_info->cnt+ 1), stat = alterlist(prsn_info->diag,prsn_info->cnt), prsn_info
   ->diag[prsn_info->cnt].diag_id = d.diagnosis_id,
   prsn_info->diag[prsn_info->cnt].diag_date = format(d.diag_dt_tm,"YYYYMMDDHHMMSS;;q"), prsn_info->
   diag[prsn_info->cnt].description = trim(n.source_string), prsn_info->diag[prsn_info->cnt].icd_code
    = trim(n.source_identifier)
   IF (n.source_vocabulary_cd=mf_icd10_cd)
    prsn_info->diag[prsn_info->cnt].icd_type = "I10"
   ELSEIF (n.source_vocabulary_cd=mf_icd9_cd)
    prsn_info->diag[prsn_info->cnt].icd_type = "I9"
   ENDIF
   prsn_info->diag[prsn_info->cnt].diag_type = trim(uar_get_code_display(d.diag_type_cd))
   IF (d.ranking_cd=mf_primary_cd)
    prsn_info->diag[prsn_info->cnt].diag_priority = "1"
   ELSEIF (d.ranking_cd=mf_secondary_cd)
    prsn_info->diag[prsn_info->cnt].diag_priority = "2"
   ELSEIF (d.ranking_cd=mf_tertiary_cd)
    prsn_info->diag[prsn_info->cnt].diag_priority = "3"
   ELSE
    prsn_info->diag[prsn_info->cnt].diag_priority = "99"
   ENDIF
  WITH nocounter
 ;end select
 IF ((prsn_info->cnt > 0))
  FOR (ml_loop = 1 TO prsn_info->cnt)
    SET prsn_info->diag[ml_loop].diag_hl7_slice = build("DG1","|",ml_loop,"|",prsn_info->diag[ml_loop
     ].icd_type,
     "|",prsn_info->diag[ml_loop].icd_code,"^",prsn_info->diag[ml_loop].description,"^",
     prsn_info->diag[ml_loop].icd_type,"|",prsn_info->diag[ml_loop].description,"|",prsn_info->diag[
     ml_loop].diag_date,
     "|",prsn_info->diag[ml_loop].diag_type,"|","|","|",
     "|","|","|","|","|",
     "|",prsn_info->diag[ml_loop].diag_priority,"|","|","|",
     "|","|","|","|","|",
     "|","|","| ")
  ENDFOR
 ENDIF
 SET ms_final_hl7_msg = concat(ms_bm_str,prsn_info->msh_hl7_slice,ms_cr_str,prsn_info->pid_hl7_slice,
  ms_cr_str,
  prsn_info->pv1_hl7_slice)
 IF ((prsn_info->cnt > 0))
  FOR (ml_loop = 1 TO prsn_info->cnt)
    SET ms_final_hl7_msg = concat(ms_final_hl7_msg,ms_cr_str,prsn_info->diag[ml_loop].diag_hl7_slice)
  ENDFOR
 ENDIF
 SET ms_final_hl7_msg = concat(ms_final_hl7_msg,ms_eom_str)
 SET ml_tmp_retval = 100
 SET ml_output_size = (size(ms_final_hl7_msg)+ 100)
#exit_program
 SET retval = ml_tmp_retval
 SET log_message = ms_tmp_message
 IF (ml_err_ind=0)
  CALL echo("WRITING TO FILE")
  CALL echo(ms_file_path)
  SELECT INTO value(concat(ms_file_path,"suc/",ms_file_name))
   FROM (dummyt d  WITH seq = 1)
   DETAIL
    CALL print(ms_final_hl7_msg)
   WITH nocounter, maxcol = value(ml_output_size)
  ;end select
  SET ms_cmd_str = concat("mv ",ms_file_path,"suc/",ms_file_name," ",
   ms_file_path,"fin/",ms_file_name)
  IF (ml_err_ind=0)
   CALL dcl(ms_cmd_str,size(ms_cmd_str),ml_dmc_ret)
  ENDIF
 ENDIF
 CALL echo(retval)
 CALL echo(log_message)
END GO
