CREATE PROGRAM bhs_mp_get_pat_info:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encounter ID:" = 0
  WITH outdev, f_encntr_id
 FREE RECORD m_info
 RECORD m_info(
   1 s_name = vc
   1 s_sex = vc
   1 s_dob = vc
   1 s_age = vc
   1 s_mrn = vc
   1 s_fin = vc
   1 s_admit_dt_tm = vc
   1 s_loc = vc
   1 s_encntr_type = vc
 )
 DECLARE mf_encntr_id = f8 WITH protect, constant(cnvtreal( $F_ENCNTR_ID))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE mf_person_id = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_alias ea1,
   encntr_alias ea2,
   person p
  PLAN (e
   WHERE e.encntr_id=mf_encntr_id
    AND e.active_ind=1
    AND e.end_effective_dt_tm > sysdate)
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > sysdate
    AND ea1.encntr_alias_type_cd=mf_fin_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > sysdate
    AND ea2.encntr_alias_type_cd=mf_mrn_cd)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm > sysdate)
  HEAD e.encntr_id
   mf_person_id = e.person_id, m_info->s_name = trim(p.name_full_formatted), m_info->s_dob = trim(
    format(p.birth_dt_tm,"mm/dd/yyyy;;d")),
   m_info->s_age = trim(cnvtage(p.birth_dt_tm),3), m_info->s_sex = trim(uar_get_code_display(p.sex_cd
     )), m_info->s_encntr_type = trim(uar_get_code_display(e.encntr_type_cd)),
   m_info->s_admit_dt_tm = trim(format(e.reg_dt_tm,"mm/dd/yyyy hh:mm;;d")), m_info->s_fin = trim(ea1
    .alias), m_info->s_mrn = trim(ea2.alias),
   ms_tmp = trim(uar_get_code_display(e.loc_nurse_unit_cd)), ms_tmp = concat(ms_tmp,"; ",trim(
     uar_get_code_display(e.loc_room_cd)),"; ",trim(uar_get_code_display(e.loc_bed_cd))), m_info->
   s_loc = ms_tmp
  WITH nocounter
 ;end select
 IF (((curqual < 1) OR (mf_person_id <= 0)) )
  GO TO exit_script
 ENDIF
#exit_script
 CALL echo("rectojson")
 CALL echo(cnvtrectojson(m_info))
 CALL echo("echojson")
 CALL echojson(m_info, $OUTDEV)
 CALL echorecord(m_info)
 FREE RECORD m_info
END GO
