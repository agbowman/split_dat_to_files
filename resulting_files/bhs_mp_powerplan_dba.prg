CREATE PROGRAM bhs_mp_powerplan:dba
 PROMPT
  "Enter Person ID:" = 0
  WITH f_person_id
 DECLARE ml_phase_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ord_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_pp_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_cs319_fin = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_person_id = f8 WITH protect, constant(cnvtreal( $F_PERSON_ID))
 DECLARE mf_cs16769_planned = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"PLANNED"))
 DECLARE mf_cs16769_initiated = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"INITIATED"
   ))
 DECLARE mf_cs14281_discontinued = f8 WITH protect, constant(uar_get_code_by("MEANING",14281,
   "DISCONTINUED"))
 DECLARE mf_cs14281_completed = f8 WITH protect, constant(uar_get_code_by("MEANING",14281,"COMPLETED"
   ))
 DECLARE mf_cs14281_canceled = f8 WITH protect, constant(uar_get_code_by("MEANING",14281,"CANCELED"))
 FREE RECORD m_powerplans
 RECORD m_powerplans(
   1 powerplans[*]
     2 s_powerplan_name = vc
     2 s_patient_name = vc
     2 s_fin_number = vc
     2 f_pp_cat_group_id = f8
     2 phase[*]
       3 s_status = vc
       3 s_facility = vc
       3 s_phase_name = vc
       3 s_provider_name = vc
       3 s_entered_by = vc
       3 s_order_date = vc
       3 s_order_type = vc
       3 f_phase_id = f8
       3 f_pcg_id = f8
       3 l_disc_comp_order_cnt = i4
       3 l_total_order_cnt = i4
       3 s_phase_type = vc
       3 f_group_num = f8
       3 s_parent_phase_desc = vc
       3 f_cat_group_id = f8
       3 orders[*]
         4 s_order_mnemonic = vc
         4 s_order_status = vc
         4 f_order_synonym_id = f8
         4 l_order_cnt = i4
 ) WITH protect
 SELECT DISTINCT INTO "nl:"
  FROM pathway pw,
   act_pw_comp a,
   pw_comp_action pca,
   orders o,
   person p,
   encntr_alias ea,
   prsnl pr,
   prsnl pr1,
   encounter e,
   pathway_action pa
  PLAN (p
   WHERE p.person_id=mf_person_id)
   JOIN (pw
   WHERE pw.pw_status_cd IN (mf_cs16769_planned, mf_cs16769_initiated)
    AND pw.active_ind=1
    AND pw.person_id=p.person_id
    AND pw.type_mean IN ("CAREPLAN", "PHASE", "SUBPHASE"))
   JOIN (a
   WHERE (a.pathway_id= Outerjoin(pw.pathway_id))
    AND (a.parent_entity_name= Outerjoin("ORDERS")) )
   JOIN (pca
   WHERE (pca.act_pw_comp_id= Outerjoin(a.act_pw_comp_id))
    AND (pca.parent_entity_id= Outerjoin(a.parent_entity_id))
    AND (pca.parent_entity_name= Outerjoin("ORDERS")) )
   JOIN (o
   WHERE (o.order_id= Outerjoin(a.parent_entity_id))
    AND (o.originating_encntr_id= Outerjoin(a.originating_encntr_id))
    AND (o.synonym_id!= Outerjoin(0)) )
   JOIN (pa
   WHERE pa.pathway_id=pw.pathway_id
    AND pa.pw_status_cd != 0
    AND (pa.updt_dt_tm=
   (SELECT
    max(pac.updt_dt_tm)
    FROM pathway_action pac
    WHERE pac.pathway_id=pa.pathway_id)))
   JOIN (pr
   WHERE pr.person_id=pa.action_prsnl_id)
   JOIN (pr1
   WHERE pr1.person_id=pa.provider_id)
   JOIN (ea
   WHERE ea.encntr_id=pw.encntr_id
    AND ea.encntr_alias_type_cd=mf_cs319_fin
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id)
  ORDER BY pw.pathway_id, pw.pw_status_cd, o.order_id,
   pw.pw_group_desc, pw.description, 0
  HEAD REPORT
   ml_pp_cnt = 0
  HEAD pw.pw_cat_group_id
   CALL echo(pw.pathway_id), ml_pp_cnt += 1
   IF (((mod(ml_pp_cnt,50)=1) OR (ml_pp_cnt=1)) )
    CALL alterlist(m_powerplans->powerplans,(ml_pp_cnt+ 49))
   ENDIF
   m_powerplans->powerplans[ml_pp_cnt].s_powerplan_name = trim(pw.pw_group_desc,3), m_powerplans->
   powerplans[ml_pp_cnt].s_patient_name = trim(p.name_full_formatted,3), m_powerplans->powerplans[
   ml_pp_cnt].s_fin_number = trim(cnvtalias(ea.alias,ea.alias_pool_cd),3),
   m_powerplans->powerplans[ml_pp_cnt].f_pp_cat_group_id = pw.pw_cat_group_id, ml_phase_cnt = 0
  HEAD pw.pathway_id
   ml_phase_cnt += 1
   IF (((mod(ml_phase_cnt,20)=1) OR (ml_phase_cnt=1)) )
    CALL alterlist(m_powerplans->powerplans[ml_pp_cnt].phase,(ml_phase_cnt+ 19))
   ENDIF
   IF ( NOT (pw.parent_phase_desc IN ("", null)))
    ms_parent_phase_disp = trim(pw.parent_phase_desc,3)
   ELSE
    ms_parent_phase_disp = ""
   ENDIF
   m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].s_entered_by = trim(pr.name_full_formatted,
    3), m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].s_phase_name = trim(pw.description,3),
   m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].f_phase_id = pw.pathway_id,
   m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].f_pcg_id = pw.pathway_catalog_id,
   m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].s_provider_name = trim(pr1
    .name_full_formatted,3), m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].s_order_date =
   trim(format(pa.updt_dt_tm,"MM/DD/YYYY hh:mm;;D"),3),
   m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].s_order_type = concat(trim(
     uar_get_code_display(pa.communication_type_cd),3)," order by"), m_powerplans->powerplans[
   ml_pp_cnt].phase[ml_phase_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd),3),
   m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].s_status = trim(uar_get_code_display(pw
     .pw_status_cd),3),
   m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].s_phase_type = pw.type_mean, m_powerplans
   ->powerplans[ml_pp_cnt].phase[ml_phase_cnt].f_cat_group_id = pw.pw_cat_group_id, m_powerplans->
   powerplans[ml_pp_cnt].phase[ml_phase_cnt].f_group_num = pw.pw_group_nbr,
   m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].s_parent_phase_desc = ms_parent_phase_disp,
   ml_ord_cnt = 0
  HEAD o.order_id
   IF (o.synonym_id != 0)
    ml_ord_cnt += 1
    IF (((mod(ml_ord_cnt,20)=1) OR (ml_ord_cnt=1)) )
     CALL alterlist(m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].orders,(ml_ord_cnt+ 19))
    ENDIF
    IF (ml_phase_cnt > 0
     AND ml_ord_cnt > 0)
     m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].orders[ml_ord_cnt].s_order_mnemonic =
     trim(o.order_mnemonic,3), m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].orders[
     ml_ord_cnt].f_order_synonym_id = o.synonym_id, m_powerplans->powerplans[ml_pp_cnt].phase[
     ml_phase_cnt].orders[ml_ord_cnt].s_order_status = trim(uar_get_code_display(o.dept_status_cd),3),
     m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].orders[ml_ord_cnt].l_order_cnt =
     ml_ord_cnt, m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].l_total_order_cnt += 1
     IF (o.dept_status_cd IN (mf_cs14281_completed, mf_cs14281_discontinued, mf_cs14281_canceled))
      m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].l_disc_comp_order_cnt += 1
     ENDIF
    ENDIF
   ENDIF
  FOOT  pw.pw_cat_group_id
   CALL alterlist(m_powerplans->powerplans[ml_pp_cnt].phase,ml_phase_cnt)
  FOOT  pw.pathway_id
   CALL alterlist(m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].orders,ml_ord_cnt)
  FOOT REPORT
   CALL alterlist(m_powerplans->powerplans,ml_pp_cnt)
  WITH nocounter
 ;end select
 SET _memory_reply_string = cnvtrectojson(m_powerplans)
 FREE RECORD m_powerplans
END GO
