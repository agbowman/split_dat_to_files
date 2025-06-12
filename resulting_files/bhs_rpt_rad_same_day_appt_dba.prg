CREATE PROGRAM bhs_rpt_rad_same_day_appt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Appt Start Date:" = "CURDATE",
  "Appt End Date:" = "CURDATE",
  "Resource Group:" = 0
  WITH outdev, ms_start_date, ms_end_date,
  mf_res_grp
 DECLARE mf_begin_dt_tm = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_START_DATE,
    "DD-MMM-YYYY"),0))
 DECLARE mf_end_dt_tm = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_END_DATE,"DD-MMM-YYYY"),
   235959))
 DECLARE mf_ea_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_ea_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_patient_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14250,"PATIENT"))
 DECLARE mf_action_schedule_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14232,"SCHEDULE"
   ))
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 FREE RECORD s_loc
 RECORD s_loc(
   1 l_cnt = i4
   1 qual[*]
     2 f_code_value = f8
     2 s_code_display = vc
 )
 FREE RECORD s_data
 RECORD s_data(
   1 l_cnt = i4
   1 qual[*]
     2 f_sch_event_id = f8
     2 f_appt_id = f8
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 f_appt_date = f8
     2 f_pat_dob = f8
     2 s_appt_status = vc
     2 s_pat_name = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_appt_type = vc
     2 s_appt_loc = vc
     2 s_user = vc
     2 f_action_date = f8
     2 s_res_grp = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.active_ind=1
   AND cv.cdf_meaning="AMBULATORY"
   AND cv.display_key IN ("BRIEASTLONG", "BRIENFIELD", "BRINORTHAMPTON", "BRISOUTHHAD", "BMCRAD",
  "3300RAD", "BBWCRAD", "BFMCRAD", "BMLHRAD", "BWHRADIOLOGY")
  HEAD REPORT
   s_loc->l_cnt = 0
  DETAIL
   s_loc->l_cnt = (s_loc->l_cnt+ 1), stat = alterlist(s_loc->qual,s_loc->l_cnt), s_loc->qual[s_loc->
   l_cnt].f_code_value = cv.code_value,
   s_loc->qual[s_loc->l_cnt].s_code_display = trim(cv.display,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM sch_appt sa,
   sch_event se,
   sch_appt sa2,
   sch_resource sr,
   sch_res_list srl,
   sch_res_group srg,
   sch_event_action sea,
   prsnl pr,
   encntr_alias ea1,
   encntr_alias ea2,
   person p
  PLAN (sea
   WHERE sea.action_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND sea.sch_action_cd=mf_action_schedule_cd
    AND sea.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND sea.action_prsnl_id != 12437405.0)
   JOIN (se
   WHERE se.sch_event_id=sea.sch_event_id
    AND se.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (sa
   WHERE sa.sch_event_id=se.sch_event_id
    AND sa.sch_role_cd=mf_patient_cd
    AND expand(ml_idx,1,s_loc->l_cnt,sa.appt_location_cd,s_loc->qual[ml_idx].f_code_value)
    AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND sa.active_ind=1)
   JOIN (sa2
   WHERE sa2.sch_event_id=se.sch_event_id
    AND sa2.sch_role_cd != mf_patient_cd
    AND sa2.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND sa2.active_ind=1)
   JOIN (sr
   WHERE sr.person_id=sa2.person_id
    AND sr.resource_cd=sa2.resource_cd
    AND sr.active_ind=1
    AND sr.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (srl
   WHERE srl.resource_cd=sr.resource_cd
    AND srl.active_ind=1
    AND srl.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND (srl.res_group_id= $MF_RES_GRP))
   JOIN (srg
   WHERE srg.res_group_id=srl.res_group_id)
   JOIN (pr
   WHERE pr.person_id=sea.action_prsnl_id)
   JOIN (ea1
   WHERE ea1.encntr_id=outerjoin(sa.encntr_id)
    AND ea1.encntr_alias_type_cd=outerjoin(mf_ea_mrn_cd)
    AND ea1.active_ind=outerjoin(1)
    AND ea1.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (ea2
   WHERE ea2.encntr_id=outerjoin(sa.encntr_id)
    AND ea2.encntr_alias_type_cd=outerjoin(mf_ea_fin_cd)
    AND ea2.active_ind=outerjoin(1)
    AND ea2.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (p
   WHERE p.person_id=sa.person_id)
  ORDER BY srg.mnemonic_key, sa.beg_dt_tm, sa.sch_event_id
  HEAD REPORT
   s_data->l_cnt = 0
  HEAD sa.sch_event_id
   IF (cnvtdate(sa.beg_dt_tm)=cnvtdate(sea.action_dt_tm))
    s_data->l_cnt = (s_data->l_cnt+ 1), stat = alterlist(s_data->qual,s_data->l_cnt), s_data->qual[
    s_data->l_cnt].f_appt_id = sa.sch_appt_id,
    s_data->qual[s_data->l_cnt].f_encntr_id = sa.encntr_id, s_data->qual[s_data->l_cnt].f_person_id
     = sa.person_id, s_data->qual[s_data->l_cnt].f_pat_dob = p.birth_dt_tm,
    s_data->qual[s_data->l_cnt].f_sch_event_id = sa.sch_event_id, s_data->qual[s_data->l_cnt].
    s_appt_loc = uar_get_code_display(sa.appt_location_cd), s_data->qual[s_data->l_cnt].s_appt_type
     = uar_get_code_display(se.appt_type_cd),
    s_data->qual[s_data->l_cnt].s_fin = trim(ea2.alias,3), s_data->qual[s_data->l_cnt].s_mrn = trim(
     ea1.alias,3), s_data->qual[s_data->l_cnt].s_appt_status = uar_get_code_display(se.sch_state_cd),
    s_data->qual[s_data->l_cnt].s_pat_name = p.name_full_formatted, s_data->qual[s_data->l_cnt].
    f_appt_date = sa.beg_dt_tm, s_data->qual[s_data->l_cnt].s_user = pr.username,
    s_data->qual[s_data->l_cnt].f_action_date = sea.action_dt_tm, s_data->qual[s_data->l_cnt].
    s_res_grp = srg.mnemonic
   ENDIF
  WITH nocounter
 ;end select
 IF ((s_data->l_cnt > 0))
  SELECT INTO  $OUTDEV
   patient_name = trim(substring(1,100,s_data->qual[d.seq].s_pat_name)), mrn = trim(substring(1,100,
     s_data->qual[d.seq].s_mrn)), fin = trim(substring(1,100,s_data->qual[d.seq].s_fin)),
   appt_loc = trim(substring(1,100,s_data->qual[d.seq].s_appt_loc)), appt_date = format(cnvtdatetime(
     s_data->qual[d.seq].f_appt_date),"MM/DD/YYYY hh:mm:ss;;d"), appt_type = trim(substring(1,100,
     s_data->qual[d.seq].s_appt_type)),
   appt_status = trim(substring(1,100,s_data->qual[d.seq].s_appt_status)), user = trim(substring(1,25,
     s_data->qual[d.seq].s_user)), resource_group = trim(substring(1,25,s_data->qual[d.seq].s_res_grp
     ),3)
   FROM (dummyt d  WITH seq = s_data->l_cnt)
   PLAN (d
    WHERE d.seq > 0)
   WITH nocounter, maxcol = 20000, format,
    separator = " ", memsort
  ;end select
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Report finished successfully. No appointments qualified.", col 0,
    "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08
  ;end select
 ENDIF
#exit_script
END GO
