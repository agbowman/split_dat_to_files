CREATE PROGRAM bhs_rpt_trauma_teach:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SET patlist = "177357"
 FREE RECORD m_rec
 RECORD m_rec(
   1 pat[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_encntr_type = vc
     2 s_pat_name = vc
     2 s_dob = vc
     2 s_fin = vc
     2 s_mrn = vc
     2 s_attending_md = vc
     2 s_admit_dt = vc
     2 s_referring_md = vc
     2 dx[*]
       3 s_dx = vc
       3 s_icd9 = vc
 ) WITH protect
 SET reqinfo->updt_id = 751187
 FREE RECORD dgapl_request
 RECORD dgapl_request(
   1 prsnl_id = f8
 )
 SET dgapl_request->prsnl_id = reqinfo->updt_id
 RECORD dgapl_reply(
   1 patient_lists[*]
     2 patient_list_id = f8
     2 name = vc
     2 description = vc
     2 patient_list_type_cd = f8
     2 owner_id = f8
     2 list_access_cd = f8
     2 arguments[*]
       3 argument_name = vc
       3 argument_value = vc
       3 parent_entity_name = vc
       3 parent_entity_id = f8
     2 encntr_type_filters[*]
       3 encntr_type_cd = f8
       3 encntr_class_cd = f8
     2 proxies[*]
       3 prsnl_id = f8
       3 prsnl_group_id = f8
       3 list_access_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE dcp_get_available_pat_lists  WITH replace(request,dgapl_request), replace(reply,dgapl_reply)
 RECORD dgp_reply(
   1 patient_list_id = f8
   1 name = vc
   1 description = vc
   1 patient_list_type_cd = f8
   1 owner_id = f8
   1 prsnl_access_cd = f8
   1 execution_dt_tm = dq8
   1 execution_status_cd = f8
   1 execution_status_disp = vc
   1 arguments[*]
     2 argument_name = vc
     2 argument_value = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
   1 encntr_type_filters[*]
     2 encntr_type_cd = f8
   1 patients[*]
     2 person_id = f8
     2 person_name = vc
     2 encntr_id = f8
     2 priority = i4
     2 active_ind = i2
     2 filter_ind = i2
     2 responsible_prsnl_id = f8
     2 responsible_prsnl_name = vc
     2 responsible_reltn_cd = f8
     2 responsible_reltn_disp = vc
     2 responsible_reltn_id = f8
     2 responsible_reltn_flag = i2
     2 organization_id = f8
     2 confid_level_cd = f8
     2 confid_level = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD request
 RECORD request(
   1 patient_list_id = f8
   1 patient_list_type_cd = f8
   1 best_encntr_flag = i4
   1 arguments[*]
     2 argument_name = vc
     2 argument_value = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
   1 encntr_type_filters[*]
     2 encntr_type_cd = f8
     2 encntr_class_cd = f8
 )
 DECLARE selection = i4
 FOR (i = 1 TO size(dgapl_reply->patient_lists,5))
   IF ((dgapl_reply->patient_lists[i].patient_list_id=cnvtreal(patlist)))
    SET selection = i
    SET i = (size(dgapl_reply->patient_lists,5)+ 1)
   ENDIF
 ENDFOR
 SET request->patient_list_id = dgapl_reply->patient_lists[selection].patient_list_id
 SET request->patient_list_type_cd = dgapl_reply->patient_lists[selection].patient_list_type_cd
 SET num_arguments = size(dgapl_reply->patient_lists[selection].arguments,5)
 SET stat = alterlist(request->arguments,num_arguments)
 FOR (i = 1 TO num_arguments)
   SET request->arguments[i].argument_name = dgapl_reply->patient_lists[selection].arguments[i].
   argument_name
   SET request->arguments[i].argument_value = dgapl_reply->patient_lists[selection].arguments[i].
   argument_value
   SET request->arguments[i].parent_entity_name = dgapl_reply->patient_lists[selection].arguments[i].
   parent_entity_name
   SET request->arguments[i].parent_entity_id = dgapl_reply->patient_lists[selection].arguments[i].
   parent_entity_id
 ENDFOR
 SET num_filters = size(dgapl_reply->patient_lists[selection].encntr_type_filters,5)
 SET stat = alterlist(request->encntr_type_filters,num_filters)
 FOR (i = 1 TO num_filters)
  SET request->encntr_type_filters[i].encntr_type_cd = dgapl_reply->patient_lists[selection].
  encntr_type_filters[i].encntr_type_cd
  SET request->encntr_type_filters[i].encntr_class_cd = dgapl_reply->patient_lists[selection].
  encntr_type_filters[i].encntr_class_cd
 ENDFOR
 SET dgp_reply->status_data.status = "F"
 DECLARE listtype = vc WITH constant(uar_get_code_meaning(request->patient_list_type_cd))
 DECLARE encntr_org_sec_ind = i2 WITH noconstant(0)
 DECLARE confid_ind = i2 WITH noconstant(0)
 DECLARE logstatistics(seconds=f8) = null
 DECLARE begin_time = f8 WITH noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE finish_time = f8 WITH noconstant(cnvtdatetime(curdate,curtime3))
 EXECUTE bhs_dcp_get_pl_careteam2
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 SET stat = alterlist(m_rec->pat,size(dgp_reply->patients,5))
 FOR (ml_cnt = 1 TO size(dgp_reply->patients,5))
   SET m_rec->pat[ml_cnt].f_encntr_id = dgp_reply->patients[ml_cnt].encntr_id
   SET m_rec->pat[ml_cnt].f_person_id = dgp_reply->patients[ml_cnt].person_id
   SET m_rec->pat[ml_cnt].s_pat_name = dgp_reply->patients[ml_cnt].person_name
   SET m_rec->pat[ml_cnt].s_admit_dt = dgp_reply->patients[ml_cnt].responsible_reltn_disp
 ENDFOR
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_attendmd_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,
   "ATTENDINGPHYSICIAN"))
 DECLARE mf_refermd_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,
   "REFERRINGPHYSICIAN"))
 DECLARE mf_icd9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",400,"ICD9CM"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->pat,5))),
   encounter e,
   prsnl pr,
   encntr_prsnl_reltn epr2,
   person p,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=m_rec->pat[d.seq].f_encntr_id)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > sysdate)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm > sysdate)
   JOIN (epr2
   WHERE epr2.encntr_id=e.encntr_id
    AND epr2.encntr_prsnl_r_cd IN (mf_attendmd_cd, mf_refermd_cd)
    AND epr2.end_effective_dt_tm > sysdate
    AND epr2.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=epr2.prsnl_person_id
    AND pr.active_ind=1
    AND pr.end_effective_dt_tm > sysdate)
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
  ORDER BY p.name_full_formatted
  HEAD p.person_id
   m_rec->pat[d.seq].f_person_id = p.person_id, m_rec->pat[d.seq].s_pat_name = trim(p
    .name_full_formatted), m_rec->pat[d.seq].s_dob = trim(format(p.birth_dt_tm,"mm/dd/yyyy;;d")),
   m_rec->pat[d.seq].s_admit_dt = trim(format(e.reg_dt_tm,"mm/dd/yyyy;;d")), m_rec->pat[d.seq].
   s_encntr_type = trim(uar_get_code_display(e.encntr_type_cd)), m_rec->pat[d.seq].s_fin = trim(ea1
    .alias),
   m_rec->pat[d.seq].s_mrn = trim(ea2.alias)
  DETAIL
   IF (epr2.encntr_prsnl_r_cd=mf_attendmd_cd)
    m_rec->pat[d.seq].s_attending_md = trim(pr.name_full_formatted)
   ELSEIF (epr2.encntr_prsnl_r_cd=mf_refermd_cd)
    m_rec->pat[d.seq].s_referring_md = trim(pr.name_full_formatted)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->pat,5))),
   diagnosis dx,
   nomenclature n
  PLAN (d)
   JOIN (dx
   WHERE (dx.person_id=m_rec->pat[d.seq].f_person_id)
    AND dx.active_ind=1
    AND dx.end_effective_dt_tm > sysdate)
   JOIN (n
   WHERE n.nomenclature_id=dx.nomenclature_id
    AND n.source_vocabulary_cd=mf_icd9_cd
    AND n.active_ind=1)
  ORDER BY dx.end_effective_dt_tm
  HEAD REPORT
   pl_cnt = 0
  HEAD dx.encntr_id
   pl_cnt = 0
  DETAIL
   pl_cnt = (pl_cnt+ 1)
   IF (pl_cnt > size(m_rec->pat[d.seq].dx,5))
    stat = alterlist(m_rec->pat[d.seq].dx,(pl_cnt+ 5))
   ENDIF
   m_rec->pat[d.seq].dx[pl_cnt].s_dx = trim(n.source_string), m_rec->pat[d.seq].dx[pl_cnt].s_icd9 =
   trim(n.source_identifier)
  FOOT  dx.encntr_id
   stat = alterlist(m_rec->pat[d.seq].dx,pl_cnt)
  WITH nocounter
 ;end select
 SELECT INTO value( $OUTDEV)
  ps_pat_name = trim(m_rec->pat[d.seq].s_pat_name)
  FROM (dummyt d  WITH seq = value(size(m_rec->pat,5)))
  PLAN (d)
  ORDER BY ps_pat_name
  HEAD REPORT
   pl_col = 0, pl_dx = 0, col pl_col,
   "Visit_#", pl_col = (pl_col+ 50), col pl_col,
   "Pt_Type", pl_col = (pl_col+ 50), col pl_col,
   "Patient_Name", pl_col = (pl_col+ 100), col pl_col,
   "Level_of_Service", pl_col = (pl_col+ 100), col pl_col,
   "Diagnosis", pl_col = (pl_col+ 100), col pl_col,
   "ICD-9", pl_col = (pl_col+ 50), col pl_col,
   "DOB", pl_col = (pl_col+ 50), col pl_col,
   "MRN#", pl_col = (pl_col+ 50), col pl_col,
   "Provider_Name", pl_col = (pl_col+ 100), col pl_col,
   "Admit_dt", pl_col = (pl_col+ 50), col pl_col,
   "Referring_MD", pl_col = (pl_col+ 100)
  HEAD ps_pat_name
   IF (size(m_rec->pat[d.seq].dx,5) > 0)
    FOR (pl_dx = 1 TO size(m_rec->pat[d.seq].dx,5))
      row + 1, pl_col = 0, col pl_col,
      m_rec->pat[d.seq].s_fin, pl_col = (pl_col+ 50), col pl_col,
      m_rec->pat[d.seq].s_encntr_type, pl_col = (pl_col+ 50), col pl_col,
      m_rec->pat[d.seq].s_pat_name, pl_col = (pl_col+ 100), col pl_col,
      "", pl_col = (pl_col+ 100), col pl_col,
      m_rec->pat[d.seq].dx[pl_dx].s_dx, pl_col = (pl_col+ 100), col pl_col,
      m_rec->pat[d.seq].dx[pl_dx].s_icd9, pl_col = (pl_col+ 50), col pl_col,
      m_rec->pat[d.seq].s_dob, pl_col = (pl_col+ 50), col pl_col,
      m_rec->pat[d.seq].s_mrn, pl_col = (pl_col+ 50), col pl_col,
      m_rec->pat[d.seq].s_attending_md, pl_col = (pl_col+ 100), col pl_col,
      m_rec->pat[d.seq].s_admit_dt, pl_col = (pl_col+ 50), col pl_col,
      m_rec->pat[d.seq].s_referring_md, pl_col = (pl_col+ 100)
    ENDFOR
   ELSE
    row + 1, pl_col = 0, col pl_col,
    m_rec->pat[d.seq].s_fin, pl_col = (pl_col+ 50), col pl_col,
    m_rec->pat[d.seq].s_encntr_type, pl_col = (pl_col+ 50), col pl_col,
    m_rec->pat[d.seq].s_pat_name, pl_col = (pl_col+ 100), col pl_col,
    "", pl_col = (pl_col+ 100), col pl_col,
    "", pl_col = (pl_col+ 100), col pl_col,
    "", pl_col = (pl_col+ 50), col pl_col,
    m_rec->pat[d.seq].s_dob, pl_col = (pl_col+ 50), col pl_col,
    m_rec->pat[d.seq].s_mrn, pl_col = (pl_col+ 50), col pl_col,
    m_rec->pat[d.seq].s_attending_md, pl_col = (pl_col+ 100), col pl_col,
    m_rec->pat[d.seq].s_admit_dt, pl_col = (pl_col+ 50), col pl_col,
    m_rec->pat[d.seq].s_referring_md, pl_col = (pl_col+ 100)
   ENDIF
  WITH nocounter, maxcol = 20000, format,
   separator = " "
 ;end select
 SELECT INTO "nl:"
  DETAIL
   row + 0
  WITH skipreport = value(1)
 ;end select
 CALL echorecord(m_rec)
#error
END GO
