CREATE PROGRAM bhs_rpt_apheresis_pn_test:dba
 PROMPT
  "Begin Date" = "SYSDATE",
  "Stop Date" = "SYSDATE"
  WITH begin_date, stop_date
 DECLARE ms_outfile = vc WITH protect, constant(concat("apheresis_medicine_service_data_",format(
    curdate,"YYYYMMDD;;D"),".csv"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_verify_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTHVERIFIED"))
 DECLARE mf_auth_modify_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_form_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",15750,"SIGNED"))
 DECLARE mf_acd_anti_coag_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",72,
   "ACDAANTICOAGULANT"))
 DECLARE mf_normal_saline_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",72,"NORMALSALINE")
  )
 DECLARE mf_5_albumin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",72,"5ALBUMIN"))
 DECLARE mf_fresh_frozen_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",72,
   "FRESHFROZENPLASMA"))
 DECLARE mf_other_fluid_vol_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",72,
   "OTHERFLUIDVOLUMEAPHERESIS"))
 DECLARE mf_othre_fluid_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",72,
   "OTHERFLUIDAPHERESIS"))
 DECLARE mf_total_vol_rep_fluid_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",72,
   "TOTALVOLUMEREPLACEMENTFLUIDS"))
 DECLARE ms_treatment_num = vc WITH protect, noconstant(" ")
 DECLARE ml_trtmnt_ret_len2 = i4 WITH protect, noconstant(0)
 DECLARE ms_inseries_of = vc WITH protect, noconstant(" ")
 DECLARE ml_inseries_ret_len2 = i4 WITH protect, noconstant(0)
 DECLARE start_date = dq8 WITH protect
 DECLARE end_date = dq8 WITH protect
 DECLARE ms_phy = vc WITH protect, noconstant(" ")
 DECLARE ms_date = vc WITH protect, noconstant(" ")
 DECLARE ms_diag_txt = vc WITH protect, noconstant(" ")
 DECLARE ms_comp_txt = vc WITH protect, noconstant(" ")
 DECLARE ms_procedure_date = vc WITH protect, noconstant(" ")
 DECLARE ms_apheresis_start_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE cnt1 = i4 WITH protect, noconstant(0)
 DECLARE cnt2 = i4 WITH protect, noconstant(0)
 FREE RECORD m_rec
 RECORD m_rec(
   1 pt[*]
     2 f_person_id = f8
     2 s_patient_name = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 story[*]
       3 s_treatment_nbr = vc
       3 f_scd_story_id = f8
       3 s_diagnosis = vc
       3 s_complications = vc
       3 d_date_procedure = vc
       3 s_aph_proc_cumlative = vc
       3 s_aph_proc_year_to_dt = vc
       3 s_in_series_of = vc
       3 s_acd_a_anticoag = vc
       3 s_normal_saline = vc
       3 s_5_albumin = vc
       3 s_fresh_froz_plasma = vc
       3 s_othr_fld_vol = vc
       3 s_other_fluid = vc
       3 s_total_vol_rep_fluid = vc
       3 s_pulse_pressure = vc
       3 s_aph_proc_start_time = vc
 )
 IF (validate(request->batch_selection))
  SET start_date = cnvtlookbehind("1M",cnvtdatetime(((curdate - day(curdate))+ 1),0))
  SET end_date = cnvtlookahead("1M",cnvtlookbehind("1M",cnvtdatetime(((curdate - day(curdate))+ 1),
     235959)))
 ELSE
  SET start_date = cnvtdatetime( $BEGIN_DATE)
  SET end_date = cnvtdatetime( $STOP_DATE)
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encntr_alias mrn,
   encntr_alias fin,
   person p,
   scr_pattern sp,
   scd_story sst,
   scd_story_pattern ssp
  PLAN (sst
   WHERE sst.story_completion_status_cd=mf_form_status_cd
    AND sst.person_id=18756772
    AND sst.active_ind=1)
   JOIN (ssp
   WHERE ssp.scd_story_id=sst.scd_story_id)
   JOIN (sp
   WHERE sp.scr_pattern_id=ssp.scr_pattern_id
    AND sp.display_key="AMSTHERAPEUTICPLASMAEXCHANGENOTE")
   JOIN (mrn
   WHERE mrn.encntr_id=sst.encounter_id
    AND mrn.encntr_alias_type_cd=mf_mrn_cd
    AND mrn.active_ind=1)
   JOIN (fin
   WHERE fin.encntr_id=sst.encounter_id
    AND fin.active_ind=1
    AND fin.encntr_alias_type_cd=mf_fin_cd)
   JOIN (p
   WHERE p.person_id=sst.person_id)
   JOIN (ce
   WHERE ce.event_id=sst.event_id
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.result_status_cd IN (25, 34, 35))
  ORDER BY p.person_id, sst.active_status_dt_tm DESC, sst.scd_story_id
  HEAD REPORT
   cnt = 0
  HEAD p.person_id
   cnt1 = 0, cnt = (cnt+ 1), stat = alterlist(m_rec->pt,cnt),
   m_rec->pt[cnt].f_person_id = p.person_id, stat = alterlist(m_rec->pt,cnt), m_rec->pt[cnt].
   f_person_id = p.person_id,
   m_rec->pt[cnt].s_fin = fin.alias, m_rec->pt[cnt].s_mrn = mrn.alias, m_rec->pt[cnt].s_patient_name
    = p.name_full_formatted
  DETAIL
   cnt1 = (cnt1+ 1), stat = alterlist(m_rec->pt[cnt].story,cnt1), m_rec->pt[cnt].story[cnt1].
   f_scd_story_id = sst.scd_story_id
  FOOT  p.person_id
   cnt1 = 0
  FOOT REPORT
   null
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  spt_display = spt.display, table1 = "1", stt1.definition,
  stt1.display, stt1.text_representation, st1.scd_term_data_id,
  st1.scd_term_id, std1.fkey_entity_name, std1.fkey_id,
  std1.scd_term_data_id, std1.scd_term_data_key, std1_type = uar_get_code_display(std1
   .scd_term_data_type_cd),
  std1.value_text, table2 = "2", stt2.definition,
  stt2.display, stt2.text_representation, st2.scd_term_id,
  st2.scd_term_data_id, std2.fkey_entity_name, std2.fkey_id,
  std2.scd_term_data_id, std2.scd_term_data_key, std2_type = uar_get_code_display(std2
   .scd_term_data_type_cd),
  std2.value_text, table3 = "3", stt3.definition,
  stt3.display, stt3.text_representation, st3.scd_term_id,
  st3.scd_term_data_id, std3.fkey_entity_name, std3.fkey_id,
  std3.scd_term_data_id, std3.scd_term_data_key, std3_type = uar_get_code_display(std3
   .scd_term_data_type_cd),
  std3.value_text, updt = trim(format(st1.updt_dt_tm,"dd-mm-yyyy hh:mm:ss;;d")), active = trim(format
   (st1.active_status_dt_tm,"dd-mm-yyyy hh:mm:ss;;d")),
  ce.result_val, units_val = uar_get_code_display(ce.result_units_cd), event_code = ce.event_cd,
  dta_type = uar_get_code_display(ce.event_cd), finalvalue = concat(trim(ce.result_val,3),trim(
    uar_get_code_display(ce.result_units_cd),3))
  FROM (dummyt d1  WITH seq = value(size(m_rec->pt,5))),
   dummyt d2,
   scd_paragraph sp,
   scr_paragraph_type spt,
   scd_sentence ss,
   scd_term st1,
   scr_term_text stt1,
   scd_term_data std1,
   scd_term st2,
   scr_term_text stt2,
   scd_term_data std2,
   scd_term st3,
   scr_term_text stt3,
   scd_term_data std3,
   clinical_event ce
  PLAN (d1
   WHERE maxrec(d2,size(m_rec->pt[d1.seq].story,5)))
   JOIN (d2)
   JOIN (sp
   WHERE (sp.scd_story_id=m_rec->pt[d1.seq].story[d2.seq].f_scd_story_id))
   JOIN (spt
   WHERE spt.scr_paragraph_type_id=sp.scr_paragraph_type_id)
   JOIN (ss
   WHERE ss.scd_story_id=sp.scd_story_id
    AND ss.scd_paragraph_id=sp.scd_paragraph_id
    AND ss.active_ind=1)
   JOIN (st1
   WHERE st1.scd_story_id=sp.scd_story_id
    AND st1.scd_sentence_id=ss.scd_sentence_id
    AND ((((st1.parent_scd_term_id+ 0)=0.00)) OR (((st1.parent_scd_term_id+ 0)=(st1.scd_term_id+ 0))
   )) )
   JOIN (stt1
   WHERE st1.scr_term_id=stt1.scr_term_id
    AND stt1.display IN ("Date/Time Started", "Referring Physician",
   "Diagnosis associated to treatment", "Complications", "Apheresis Procedures: cumulative",
   "Treatment Fluids and Replacement", "VITAL SIGNS", "Apheresis Procedures: year to date",
   "Treatment number", "In series of",
   "Apheresis Procedure Start Date/Time"))
   JOIN (std1
   WHERE std1.scd_term_data_id=outerjoin(st1.scd_term_data_id))
   JOIN (st2
   WHERE st2.parent_scd_term_id=outerjoin(st1.scd_term_id))
   JOIN (stt2
   WHERE stt2.scr_term_id=outerjoin(st2.scr_term_id))
   JOIN (std2
   WHERE std2.scd_term_data_id=outerjoin(st2.scd_term_data_id))
   JOIN (st3
   WHERE st3.parent_scd_term_id=outerjoin(st2.scd_term_id))
   JOIN (stt3
   WHERE stt3.scr_term_id=outerjoin(st3.scr_term_id))
   JOIN (std3
   WHERE std3.scd_term_data_id=outerjoin(st3.scd_term_data_id))
   JOIN (ce
   WHERE ce.event_id=outerjoin(std1.fkey_id)
    AND ce.valid_until_dt_tm > outerjoin(sysdate))
  ORDER BY sp.scd_story_id, sp.sequence_number, ss.sequence_number,
   st1.sequence_number, st2.sequence_number, st3.sequence_number
  HEAD REPORT
   ms_trtmnt_comp_trimmed = fillstring(64000," "), ms_trtmnt_uncomp = fillstring(64000," "),
   ms_trtmnt_rtf = fillstring(64000," "),
   ms_trtmnt_value = fillstring(64000," "), ms_inseries_comp_trimmed = fillstring(64000," "),
   ms_inseries_uncomp = fillstring(64000," "),
   ms_inseries_rtf = fillstring(64000," "), ms_inseries_value = fillstring(64000," ")
  HEAD sp.scd_story_id
   ms_diag_txt = "", ms_comp_txt = "", diag_cnt = 0,
   comp_cnt = 0
  HEAD stt1.display
   diag_cnt = 0, comp_cnt = 0
  HEAD stt2.display
   diag_cnt = 0, comp_cnt = 0
   IF (stt1.display="Diagnosis associated to treatment")
    IF (trim(ms_diag_txt)="")
     ms_diag_txt = concat(trim(stt2.display,3),":")
    ELSE
     ms_diag_txt = concat(trim(ms_diag_txt),". ",trim(stt2.display,3),":")
    ENDIF
   ENDIF
   IF (stt1.display="Complications")
    IF (trim(ms_comp_txt)="")
     ms_comp_txt = concat(trim(stt2.display,3),":")
    ELSE
     ms_comp_txt = concat(trim(ms_comp_txt),". ",trim(stt2.display,3),":")
    ENDIF
   ENDIF
  DETAIL
   IF (stt1.display="Diagnosis associated to treatment"
    AND std3.fkey_entity_name="DIAGNOSIS")
    diag_cnt = (diag_cnt+ 1)
    IF (diag_cnt=1)
     ms_diag_txt = concat(trim(ms_diag_txt)," ",trim(stt3.display,3))
    ELSE
     ms_diag_txt = concat(trim(ms_diag_txt),", ",trim(stt3.display,3))
    ENDIF
    CALL echo(ms_diag_txt), m_rec->pt[d1.seq].story[d2.seq].s_diagnosis = trim(ms_diag_txt,3)
   ENDIF
   IF (stt1.display="Complications")
    comp_cnt = (comp_cnt+ 1)
    IF (comp_cnt=1)
     ms_comp_txt = concat(trim(ms_comp_txt)," ",trim(stt3.display,3))
    ELSE
     ms_comp_txt = concat(trim(ms_comp_txt),", ",trim(stt3.display,3))
    ENDIF
    CALL echo(ms_comp_txt), m_rec->pt[d1.seq].story[d2.seq].s_complications = trim(ms_comp_txt,3),
    CALL echo(concat("s_complications: ",m_rec->pt[d1.seq].story[d2.seq].s_complications))
   ENDIF
   IF (stt1.display="Date/Time Started")
    m_rec->pt[d1.seq].story[d2.seq].d_date_procedure = trim(std2.value_text,3)
   ENDIF
   IF (stt1.display="Treatment number"
    AND std2.scd_term_data_key="BlockedTextData1")
    ms_treatment_num = std2.value_text, ms_treatment_num = replace(ms_treatment_num,
     "__{ScdBlockedTextDataTag}__",""),
    CALL echo(concat("ms_treatment_num1: ",ms_treatment_num)),
    ms_trtmnt_comp_trimmed = trim(ms_treatment_num)
    IF (findstring("rtf",ms_treatment_num) > 0)
     ms_trtmnt_value = ms_treatment_num,
     CALL echo(concat("ms_trtmnt_value1: ",ms_trtmnt_value)),
     CALL uar_rtf2(ms_trtmnt_value,textlen(ms_trtmnt_value),ms_trtmnt_rtf,size(ms_trtmnt_rtf),
     ml_trtmnt_ret_len2,1),
     ms_trtmnt_value = trim(ms_trtmnt_rtf,3)
    ENDIF
    m_rec->pt[d1.seq].story[d2.seq].s_treatment_nbr = trim(ms_trtmnt_value,3),
    CALL echo(concat("ms_trtmnt_value2: ",ms_trtmnt_value))
   ENDIF
   IF (stt1.display="In series of"
    AND std2.scd_term_data_key="BlockedTextData1")
    ms_inseries_of = std2.value_text, ms_inseries_of = replace(ms_inseries_of,
     "__{ScdBlockedTextDataTag}__",""),
    CALL echo(concat("ms_inseries_of1: ",ms_inseries_of)),
    ms_inseries_comp_trimmed = trim(ms_inseries_of)
    IF (findstring("rtf",ms_inseries_of) > 0)
     ms_inseries_value = ms_inseries_of,
     CALL echo(concat("ms_inseries_value1: ",ms_inseries_value)),
     CALL uar_rtf2(ms_inseries_value,textlen(ms_inseries_value),ms_inseries_rtf,size(ms_inseries_rtf),
     ml_inseries_ret_len2,1),
     ms_inseries_value = trim(ms_inseries_rtf,3)
    ENDIF
    m_rec->pt[d1.seq].story[d2.seq].s_in_series_of = trim(ms_inseries_value,3),
    CALL echo(concat("ms_inseries_value2: ",ms_inseries_value))
   ENDIF
   IF (stt1.display="Apheresis Procedures: cumulative")
    m_rec->pt[d1.seq].story[d2.seq].s_aph_proc_cumlative = trim(std2.value_text,3)
   ENDIF
   IF (stt1.display="Apheresis Procedures: year to date")
    m_rec->pt[d1.seq].story[d2.seq].s_aph_proc_year_to_dt = trim(std2.value_text,3)
   ENDIF
   IF (stt1.display="Treatment Fluids and Replacement"
    AND std1.fkey_entity_name="CLINICAL_EVENT"
    AND ce.event_cd=243975307)
    m_rec->pt[d1.seq].story[d2.seq].s_acd_a_anticoag = trim(finalvalue,3)
   ENDIF
   IF (stt1.display="Treatment Fluids and Replacement"
    AND std1.fkey_entity_name="CLINICAL_EVENT"
    AND ce.event_cd=243181942)
    m_rec->pt[d1.seq].story[d2.seq].s_normal_saline = trim(finalvalue,3)
   ENDIF
   IF (stt1.display="Treatment Fluids and Replacement"
    AND std1.fkey_entity_name="CLINICAL_EVENT"
    AND ce.event_cd=243182122)
    m_rec->pt[d1.seq].story[d2.seq].s_5_albumin = trim(finalvalue,3)
   ENDIF
   IF (stt1.display="Treatment Fluids and Replacement"
    AND std1.fkey_entity_name="CLINICAL_EVENT"
    AND ce.event_cd=243182321.00)
    m_rec->pt[d1.seq].story[d2.seq].s_fresh_froz_plasma = trim(finalvalue,3)
   ENDIF
   IF (stt1.display="Treatment Fluids and Replacement"
    AND std1.fkey_entity_name="CLINICAL_EVENT"
    AND ce.event_cd=243182533.00)
    m_rec->pt[d1.seq].story[d2.seq].s_othr_fld_vol = trim(finalvalue,3)
   ENDIF
   IF (stt1.display="Treatment Fluids and Replacement"
    AND std1.fkey_entity_name="CLINICAL_EVENT"
    AND ce.event_cd=243182723.00)
    m_rec->pt[d1.seq].story[d2.seq].s_other_fluid = trim(finalvalue,3)
   ENDIF
   IF (stt1.display="Treatment Fluids and Replacement"
    AND std1.fkey_entity_name="CLINICAL_EVENT"
    AND ce.event_cd=243975375.00)
    m_rec->pt[d1.seq].story[d2.seq].s_total_vol_rep_fluid = trim(finalvalue,3)
   ENDIF
   IF (stt1.display="VITAL SIGNS"
    AND std1.fkey_entity_name="CLINICAL_EVENT"
    AND ce.event_cd=367077424.00)
    m_rec->pt[d1.seq].story[d2.seq].s_pulse_pressure = trim(finalvalue,3)
   ENDIF
   IF (stt1.display="Apheresis Procedure Start Date/Time"
    AND std1.fkey_entity_name="CLINICAL_EVENT"
    AND ce.event_cd=272650786)
    ms_apheresis_start_tm = format(cnvtdatetime(cnvtdate2(substring(3,8,ce.result_val),"yyyymmdd"),
      cnvttime2(substring(11,6,ce.result_val),"HHMMSS")),"mm/dd/yy hh:mm;;d"), m_rec->pt[d1.seq].
    story[d2.seq].s_aph_proc_start_time = ms_apheresis_start_tm
   ENDIF
   CALL echo(ms_apheresis_start_tm)
  WITH nocounter, maxcol = 3000
 ;end select
 SELECT INTO value(concat("apheresis_medicine_service_data_",format(curdate,"YYYYMMDD;;D"),".csv"))
  patient_id = m_rec->pt[d1.seq].f_person_id, patient_name = substring(1,30,m_rec->pt[d1.seq].
   s_patient_name), apheresis_proc_start_time = m_rec->pt[d1.seq].story[d2.seq].s_aph_proc_start_time,
  mrn = substring(1,30,m_rec->pt[d1.seq].s_mrn), fin = substring(1,30,m_rec->pt[d1.seq].s_fin),
  treatment_number = m_rec->pt[d1.seq].story[d2.seq].s_treatment_nbr,
  in_series_of = m_rec->pt[d1.seq].story[d2.seq].s_in_series_of, date_of_procedure = m_rec->pt[d1.seq
  ].story[d2.seq].d_date_procedure, apheresis_procedure_cumulative = m_rec->pt[d1.seq].story[d2.seq].
  s_aph_proc_cumlative,
  apheresis_procedure_year_to_date = m_rec->pt[d1.seq].story[d2.seq].s_aph_proc_year_to_dt,
  acd_a_anticoagulant = m_rec->pt[d1.seq].story[d2.seq].s_acd_a_anticoag, normal_saline = m_rec->pt[
  d1.seq].story[d2.seq].s_normal_saline,
  5_albumin = m_rec->pt[d1.seq].story[d2.seq].s_5_albumin, fresh_frozen_plasma = m_rec->pt[d1.seq].
  story[d2.seq].s_fresh_froz_plasma, other_fluid_volume = m_rec->pt[d1.seq].story[d2.seq].
  s_othr_fld_vol,
  other_fluid = m_rec->pt[d1.seq].story[d2.seq].s_other_fluid, total_vol_replacement_fluid = m_rec->
  pt[d1.seq].story[d2.seq].s_total_vol_rep_fluid, pulse_pressure_data = m_rec->pt[d1.seq].story[d2
  .seq].s_pulse_pressure,
  diagnosis = substring(1,10000,m_rec->pt[d1.seq].story[d2.seq].s_diagnosis), complications =
  substring(1,10000,m_rec->pt[d1.seq].story[d2.seq].s_complications)
  FROM (dummyt d1  WITH seq = value(size(m_rec->pt,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(m_rec->pt[d1.seq].story,5)))
   JOIN (d2)
  WITH nocounter, format, pcformat(value('"'),value(",")),
   time = 300000
 ;end select
 CALL echo(concat("apheresis_medicine_service_data_",format(curdate,"YYYYMMDD;;D"),".csv"))
 SET dclcom = concat("$cust_script/bhs_ftp_file.ksh ",concat("apheresis_medicine_service_data_",
   format(curdate,"YYYYMMDD;;D"),".csv"),
  " 172.17.10.5 'bhs\cisftp' C!sftp01 Biovigilance2/Apheresis_Medicine_Service_Data")
 SET status = 0
 SET len = size(trim(dclcom))
 CALL dcl(dclcom,len,status)
 CALL echorecord(m_rec)
END GO
