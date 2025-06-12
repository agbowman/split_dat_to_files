CREATE PROGRAM bhs_pco_metrics_tj3:dba
 FREE RECORD t_record
 RECORD t_record(
   1 beg_date = dq8
   1 end_date = dq8
   1 phys_cnt = i4
   1 phys_qual[*]
     2 phys_id = f8
     2 charts = i4
     2 signed_med_cnt = i4
     2 problem_cnt = i4
     2 allergy_cnt = i4
     2 endorse_cnt = i4
     2 perform_cnt = i4
     2 diagnosis_cnt = i4
     2 procedure_cnt = i4
     2 sch_appt_cnt = i4
     2 man_sat_hm_cnt = i4
     2 signed_pn_cnt = i4
     2 signed_cn_cnt = i4
     2 fwd_doc_sign_cnt = i4
     2 fwd_doc_rev_cnt = i4
     2 orders_cnt = i4
     2 charges_cnt = i4
     2 encntr_appt_cnt = i4
     2 encntr_appt_doc_cnt = i4
   1 encntr_appt_cnt = i4
   1 encntr_appt_qual[*]
     2 phys_id = f8
     2 encntr_id = f8
     2 doc_ind = i2
 )
 SET t_record->beg_date = cnvtdatetime("12-SEP-2007 00:00:00")
 SET t_record->end_date = cnvtdatetime("12-SEP-2007 23:59:00")
 DECLARE pharmacy_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"PHARMACY"))
 DECLARE home_meds_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "HOMEMEDSUPDATEDINMEDICATIONPROFILE"))
 DECLARE order_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE ordered_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE endorse_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"ENDORSE"))
 DECLARE perform_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"PERFORM"))
 DECLARE sign_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"SIGN"))
 DECLARE review_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"REVIEW"))
 DECLARE completed_cd = f8 WITH constant(uar_get_code_by("MEANING",103,"COMPLETED"))
 DECLARE signed_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",15750,"SIGNED"))
 DECLARE doc_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"DOC"))
 DECLARE mdoc_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"MDOC"))
 DECLARE blob_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",25,"BLOB"))
 DECLARE powerchart_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",89,"POWERCHART"))
 DECLARE mock_org_id = f8
 DECLARE indx = i4
 DECLARE phys_exists = i2
 SELECT INTO "nl:"
  o.organization_id
  FROM organization o
  PLAN (o
   WHERE o.org_name_key="MOCKBAYSTATEHEALTHSYSTEM")
  DETAIL
   mock_org_id = o.organization_id
 ;end select
 SELECT INTO TABLE pco_temp
  encntr_id = p.encounter_id, person_id = p.person_id, phys_id = p.phys_id
  FROM pco_daily_statistics p
  PLAN (p
   WHERE p.create_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND p.create_dt_tm <= cnvtdatetime(t_record->end_date))
 ;end select
 SELECT INTO "nl:"
  FROM pco_temp pt
  PLAN (pt)
  ORDER BY pt.phys_id, pt.encntr_id
  HEAD pt.phys_id
   t_record->phys_cnt = (t_record->phys_cnt+ 1), stat = alterlist(t_record->phys_qual,t_record->
    phys_cnt), idx = t_record->phys_cnt,
   t_record->phys_qual[idx].phys_id = pt.phys_id
  HEAD pt.encntr_id
   t_record->phys_qual[idx].charts = (t_record->phys_qual[idx].charts+ 1)
 ;end select
 SELECT INTO "nl:"
  FROM pco_temp pt,
   allergy a,
   person p,
   encounter e
  PLAN (pt)
   JOIN (a
   WHERE a.encntr_id=pt.encntr_id
    AND a.created_prsnl_id=pt.person_id
    AND a.updt_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND a.updt_dt_tm <= cnvtdatetime(t_record->end_date))
   JOIN (p
   WHERE p.person_id=a.person_id)
   JOIN (e
   WHERE e.person_id=a.person_id)
  ORDER BY a.created_prsnl_id, a.allergy_id, a.allergy_instance_id
  HEAD a.created_prsnl_id
   idx = locateval(indx,1,t_record->phys_cnt,a.created_prsnl_id,t_record->phys_qual[indx].phys_id)
  HEAD a.allergy_instance_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].allergy_cnt = (t_record->phys_qual[idx].allergy_cnt+ 1)
   ENDIF
 ;end select
 SELECT INTO "nl:"
  FROM pco_temp pt,
   problem pr,
   person p,
   encounter e
  PLAN (pt)
   JOIN (pr
   WHERE pr.person_id=pt.person_id
    AND ((pr.updt_dt_tm+ 0) >= cnvtdatetime(t_record->beg_date))
    AND ((pr.updt_dt_tm+ 0) <= cnvtdatetime(t_record->end_date))
    AND pr.active_status_prsnl_id=pt.phys_id)
   JOIN (p
   WHERE p.person_id=pr.person_id)
   JOIN (e
   WHERE e.person_id=pr.person_id)
  ORDER BY pr.active_status_prsnl_id, pr.problem_id
  HEAD pr.active_status_prsnl_id
   idx = locateval(indx,1,t_record->phys_cnt,pr.active_status_prsnl_id,t_record->phys_qual[indx].
    phys_id)
  HEAD pr.problem_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].problem_cnt = (t_record->phys_qual[idx].problem_cnt+ 1)
   ENDIF
 ;end select
 SELECT INTO "nl:"
  FROM pco_temp pt,
   diagnosis d,
   person p,
   encounter e
  PLAN (pt)
   JOIN (d
   WHERE d.encntr_id=pt.encntr_id
    AND d.updt_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND d.updt_dt_tm <= cnvtdatetime(t_record->end_date)
    AND d.active_status_prsnl_id=pt.phys_id)
   JOIN (p
   WHERE p.person_id=d.person_id)
   JOIN (e
   WHERE e.person_id=d.person_id)
  ORDER BY d.active_status_prsnl_id, d.diagnosis_id
  HEAD d.active_status_prsnl_id
   idx = locateval(indx,1,t_record->phys_cnt,d.active_status_prsnl_id,t_record->phys_qual[indx].
    phys_id)
  HEAD d.diagnosis_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].diagnosis_cnt = (t_record->phys_qual[idx].diagnosis_cnt+ 1)
   ENDIF
 ;end select
 SELECT INTO "nl:"
  FROM pco_temp pt,
   procedure pr,
   person p,
   encounter e
  PLAN (pt)
   JOIN (pr
   WHERE pr.encntr_id=pt.encntr_id
    AND pr.updt_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND pr.updt_dt_tm <= cnvtdatetime(t_record->end_date)
    AND pr.active_status_prsnl_id=pt.phys_id)
   JOIN (p
   WHERE p.person_id=pt.person_id)
   JOIN (e
   WHERE e.person_id=pt.person_id)
  ORDER BY pr.active_status_prsnl_id, pr.procedure_id
  HEAD pr.active_status_prsnl_id
   idx = locateval(indx,1,t_record->phys_cnt,pr.active_status_prsnl_id,t_record->phys_qual[indx].
    phys_id)
  HEAD pr.procedure_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].procedure_cnt = (t_record->phys_qual[idx].procedure_cnt+ 1)
   ENDIF
 ;end select
 SELECT INTO "nl:"
  FROM pco_temp pt,
   sch_resource sr,
   sch_appt sa
  PLAN (pt)
   JOIN (sr
   WHERE sr.person_id=pt.phys_id
    AND sr.active_ind=1)
   JOIN (sa
   WHERE sa.resource_cd=sr.resource_cd
    AND sa.beg_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND sa.beg_dt_tm <= cnvtdatetime(t_record->end_date)
    AND sa.state_meaning="CHECKED IN")
  ORDER BY sr.resource_cd, sa.sch_appt_id
  HEAD sr.resource_cd
   idx = locateval(indx,1,t_record->phys_cnt,sr.person_id,t_record->phys_qual[indx].phys_id)
  HEAD sa.sch_appt_id
   t_record->phys_qual[idx].sch_appt_cnt = (t_record->phys_qual[idx].sch_appt_cnt+ 1)
  WITH orahint("index(sa XIE98SCH_APPT)")
 ;end select
 SELECT INTO "nl:"
  FROM pco_temp pt,
   sch_appt sa
  PLAN (pt)
   JOIN (sa
   WHERE sa.encntr_id=pt.encntr_id
    AND sa.state_meaning="CHECKED IN")
  ORDER BY sa.encntr_id
  HEAD sa.encntr_id
   t_record->encntr_appt_cnt = (t_record->encntr_appt_cnt+ 1), stat = alterlist(t_record->
    encntr_appt_qual,t_record->encntr_appt_cnt), t_record->encntr_appt_qual[t_record->encntr_appt_cnt
   ].encntr_id = sa.encntr_id,
   t_record->encntr_appt_qual[t_record->encntr_appt_cnt].phys_id = pt.phys_id
  WITH orahint("index(sa XIE7SCH_APPT)")
 ;end select
 SELECT INTO "nl:"
  FROM pco_temp pt,
   ce_event_prsnl cep,
   person p,
   encounter e
  PLAN (pt)
   JOIN (cep
   WHERE cep.person_id=pt.person_id
    AND ((cep.action_prsnl_id+ 0)=pt.phys_id)
    AND cep.action_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND cep.action_dt_tm <= cnvtdatetime(t_record->end_date)
    AND cep.action_type_cd IN (endorse_cd, perform_cd)
    AND cep.action_status_cd=completed_cd)
   JOIN (p
   WHERE p.person_id=cep.person_id)
   JOIN (e
   WHERE e.person_id=cep.person_id)
  ORDER BY cep.action_prsnl_id, cep.event_id
  HEAD cep.action_prsnl_id
   idx = locateval(indx,1,t_record->phys_cnt,cep.action_prsnl_id,t_record->phys_qual[indx].phys_id)
  HEAD cep.event_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    CASE (cep.action_type_cd)
     OF endorse_cd:
      t_record->phys_qual[idx].endorse_cnt = (t_record->phys_qual[idx].endorse_cnt+ 1)
     OF perform_cd:
      t_record->phys_qual[idx].perform_cnt = (t_record->phys_qual[idx].perform_cnt+ 1)
    ENDCASE
   ENDIF
 ;end select
 SELECT INTO "nl:"
  FROM pco_temp pt,
   orders o,
   order_review ordr,
   person p,
   encounter e
  PLAN (pt)
   JOIN (o
   WHERE o.person_id=pt.person_id
    AND o.encntr_id=pt.encntr_id
    AND o.activity_type_cd=pharmacy_cd)
   JOIN (ordr
   WHERE ordr.order_id=o.order_id
    AND ((ordr.review_personnel_id+ 0)=pt.phys_id)
    AND ordr.review_type_flag=2
    AND ordr.reviewed_status_flag > 0
    AND ordr.review_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND ordr.review_dt_tm <= cnvtdatetime(t_record->end_date))
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (e
   WHERE e.person_id=o.person_id)
  HEAD ordr.review_personnel_id
   idx = locateval(indx,1,t_record->phys_cnt,ordr.review_personnel_id,t_record->phys_qual[indx].
    phys_id)
  HEAD ordr.order_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].signed_med_cnt = (t_record->phys_qual[idx].signed_med_cnt+ 1)
   ENDIF
 ;end select
 SELECT INTO "nl:"
  FROM pco_temp pt,
   orders o,
   order_action oa,
   person p,
   encounter e
  PLAN (pt)
   JOIN (o
   WHERE o.person_id=pt.person_id
    AND o.encntr_id=pt.encntr_id
    AND o.activity_type_cd=pharmacy_cd)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND ((oa.order_provider_id+ 0)=pt.phys_id)
    AND ((oa.action_dt_tm+ 0) >= cnvtdatetime(t_record->beg_date))
    AND ((oa.action_dt_tm+ 0) <= cnvtdatetime(t_record->end_date))
    AND oa.inactive_flag=0
    AND oa.template_order_flag=0.00
    AND oa.order_status_cd=ordered_cd)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (e
   WHERE e.person_id=o.person_id)
  HEAD oa.order_provider_id
   idx = locateval(indx,1,t_record->phys_cnt,oa.order_provider_id,t_record->phys_qual[indx].phys_id)
  HEAD oa.order_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].signed_med_cnt = (t_record->phys_qual[idx].signed_med_cnt+ 1)
   ENDIF
 ;end select
 SELECT INTO "nl:"
  FROM pco_table pt,
   hm_expect_mod_hist hm,
   person p,
   encounter e
  PLAN (pt)
   JOIN (hm
   WHERE hm.person_id=pt.person_id
    AND ((hm.updt_id=pt.phys_id) OR (hm.active_status_prsnl_id=pt.phys_id))
    AND hm.updt_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND hm.updt_dt_tm <= cnvtdatetime(t_record->end_date)
    AND hm.active_ind=1)
   JOIN (p
   WHERE p.person_id=pt.person_id)
   JOIN (e
   WHERE e.person_id=pt.person_id)
  ORDER BY pt.phys_id, hm.expect_mod_id
  HEAD pt.phys_id
   idx = locateval(indx,1,t_record->phys_cnt,pt.phys_id,t_record->phys_qual[indx].phys_id)
  HEAD hm.expect_mod_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].man_sat_hm_cnt = (t_record->phys_qual[idx].man_sat_hm_cnt+ 1)
   ENDIF
 ;end select
 SELECT INTO "nl:"
  c_null = nullind(c.charge_item_id)
  FROM pco_temp pt,
   orders o,
   order_action oa,
   charge c,
   person p,
   encounter e
  PLAN (pt)
   JOIN (o
   WHERE o.person_id=pt.person_id
    AND o.encntr_id=pt.encntr_id
    AND o.orig_order_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND o.orig_order_dt_tm <= cnvtdatetime(t_record->end_date))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.order_provider_id=pt.phys_id
    AND oa.action_type_cd=order_cd)
   JOIN (c
   WHERE c.order_id=outerjoin(o.order_id))
   JOIN (p
   WHERE p.person_id=pt.person_id)
   JOIN (e
   WHERE e.person_id=pt.person_id)
  ORDER BY pt.phys_id, o.order_id
  HEAD pt.phys_id
   idx = locateval(indx,1,t_record->phys_cnt,pt.phys_id,t_record->phys_qual[indx].phys_id)
  HEAD o.order_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].orders_cnt = (t_record->phys_qual[idx].orders_cnt+ 1)
    IF (c_null=0)
     t_record->phys_qual[idx].charges_cnt = (t_record->phys_qual[idx].charges_cnt+ 1)
    ENDIF
   ENDIF
  WITH orahint("index(o XIE11ORDERS), index(oa XPKORDER_ACTION)")
 ;end select
 SELECT INTO "nl:"
  FROM pco_temp pt,
   ce_event_prsnl cep,
   person p,
   encounter e
  PLAN (pt)
   JOIN (cep
   WHERE cep.person_id=pt.person_id
    AND cep.action_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND cep.action_dt_tm <= cnvtdatetime(t_record->end_date)
    AND cep.action_status_cd=completed_cd
    AND cep.action_type_cd IN (sign_cd, review_cd)
    AND ((cep.event_prsnl_id+ 0) != pt.phys_id)
    AND ((cep.action_prsnl_id+ 0)=pt.phys_id))
   JOIN (p
   WHERE p.person_id=cep.person_id)
   JOIN (e
   WHERE e.person_id=cep.person_id)
  ORDER BY cep.action_prsnl_id, cep.event_id
  HEAD cep.action_prsnl_id
   idx = locateval(indx,1,t_record->phys_cnt,cep.action_prsnl_id,t_record->phys_qual[indx].phys_id)
  HEAD cep.event_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    CASE (cep.action_type_cd)
     OF sign_cd:
      t_record->phys_qual[idx].fwd_doc_sign_cnt = (t_record->phys_qual[idx].fwd_doc_sign_cnt+ 1),idx2
       = 0,idx2 = locateval(indx,1,t_record->encntr_appt_cnt,e.encntr_id,t_record->encntr_appt_qual[
       indx].encntr_id),
      IF (idx2 > 0)
       t_record->encntr_appt_qual[idx2].doc_ind = 1
      ENDIF
     OF review_cd:
      t_record->phys_qual[idx].fwd_doc_rev_cnt = (t_record->phys_qual[idx].fwd_doc_rev_cnt+ 1)
    ENDCASE
   ENDIF
 ;end select
 SELECT INTO "nl:"
  FROM pco_temp pt,
   scd_story s,
   ce_event_prsnl cep,
   person p,
   encounter e
  PLAN (pt)
   JOIN (s
   WHERE s.person_id=pt.person_id
    AND s.encounter_id=pt.encntr_id
    AND s.story_completion_status_cd=signed_cd)
   JOIN (cep
   WHERE cep.event_id=s.event_id
    AND cep.action_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND cep.action_dt_tm <= cnvtdatetime(t_record->end_date)
    AND cep.action_status_cd=completed_cd
    AND cep.action_type_cd=sign_cd
    AND cep.action_prsnl_id=pt.phys_id)
   JOIN (p
   WHERE p.person_id=cep.person_id)
   JOIN (e
   WHERE e.person_id=cep.person_id)
  ORDER BY cep.action_prsnl_id, cep.event_id
  HEAD cep.action_prsnl_id
   idx = locateval(indx,1,t_record->phys_cnt,cep.action_prsnl_id,t_record->phys_qual[indx].phys_id)
  HEAD cep.event_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].signed_pn_cnt = (t_record->phys_qual[idx].signed_pn_cnt+ 1), idx2 = 0,
    idx2 = locateval(indx,1,t_record->encntr_appt_cnt,e.encntr_id,t_record->encntr_appt_qual[indx].
     encntr_id)
    IF (idx2 > 0)
     t_record->encntr_appt_qual[idx2].doc_ind = 1
    ENDIF
   ENDIF
  WITH orahint("index(cep XIE1CE_EVENT_PRSNL)")
 ;end select
 SELECT INTO "nl:"
  FROM pco_temp pt,
   clinical_event ce,
   clinical_event ce1,
   ce_blob_result ceb,
   ce_event_prsnl cep,
   person p,
   encounter e
  PLAN (pt)
   JOIN (ce
   WHERE ce.encntr_id=pt.encntr_id
    AND ce.event_class_cd=mdoc_cd
    AND ce.contributor_system_cd=powerchart_cd
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.accession_nbr=" "
    AND  NOT ( EXISTS (
   (SELECT
    s.scd_story_id
    FROM scd_story s
    WHERE s.event_id=ce.event_id))))
   JOIN (ce1
   WHERE ce1.parent_event_id=ce.event_id
    AND ce1.event_class_cd=doc_cd
    AND  NOT ( EXISTS (
   (SELECT
    s.scd_story_id
    FROM scd_story s
    WHERE s.event_id=ce1.event_id))))
   JOIN (ceb
   WHERE ceb.event_id=ce1.event_id
    AND ceb.storage_cd=blob_cd)
   JOIN (cep
   WHERE cep.event_id=ce.event_id
    AND cep.action_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND cep.action_dt_tm <= cnvtdatetime(t_record->end_date)
    AND cep.action_status_cd=completed_cd
    AND cep.action_type_cd=sign_cd
    AND cep.action_prsnl_id=pt.phys_id)
   JOIN (p
   WHERE p.person_id=cep.person_id)
   JOIN (e
   WHERE e.person_id=cep.person_id)
  ORDER BY cep.action_prsnl_id, cep.event_id
  HEAD cep.action_prsnl_id
   idx = locateval(indx,1,t_record->phys_cnt,cep.action_prsnl_id,t_record->phys_qual[indx].phys_id)
  HEAD cep.event_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].signed_cn_cnt = (t_record->phys_qual[idx].signed_cn_cnt+ 1), idx2 = 0,
    idx2 = locateval(indx,1,t_record->encntr_appt_cnt,e.encntr_id,t_record->encntr_appt_qual[indx].
     encntr_id)
    IF (idx2 > 0)
     t_record->encntr_appt_qual[idx2].doc_ind = 1
    ENDIF
   ENDIF
  WITH orahint("index(cep XIE1CE_EVENT_PRSNL)")
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->encntr_appt_cnt)
  PLAN (d)
  DETAIL
   idx = locateval(indx,1,t_record->phys_cnt,t_record->encntr_appt_qual[d.seq].phys_id,t_record->
    phys_qual[indx].phys_id), t_record->phys_qual[idx].encntr_appt_cnt = (t_record->phys_qual[idx].
   encntr_appt_cnt+ 1)
   IF ((t_record->encntr_appt_qual[d.seq].doc_ind=1))
    t_record->phys_qual[idx].encntr_appt_doc_cnt = (t_record->phys_qual[idx].encntr_appt_doc_cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 SET t_month = month(cnvtdatetime(t_record->beg_date))
 SET t_year = year(cnvtdatetime(t_record->beg_date))
 FOR (i = 1 TO t_record->phys_cnt)
  SET phys_exists = 0
  SELECT INTO "nl:"
   FROM pco_summary p
   PLAN (p
    WHERE (p.phys_id=t_record->phys_qual[i].phys_id)
     AND t_month=p.month
     AND t_year=p.year)
   DETAIL
    t_record->phys_qual[i].allergy_cnt = (t_record->phys_qual[i].allergy_cnt+ p.allergy_cnt),
    t_record->phys_qual[i].charges_cnt = (t_record->phys_qual[i].charges_cnt+ p.charges_cnt),
    t_record->phys_qual[i].charts = (t_record->phys_qual[i].charts+ p.charts),
    t_record->phys_qual[i].diagnosis_cnt = (t_record->phys_qual[i].diagnosis_cnt+ p.diagnosis_cnt),
    t_record->phys_qual[i].encntr_appt_cnt = (t_record->phys_qual[i].encntr_appt_cnt+ p
    .encntr_appt_cnt), t_record->phys_qual[i].encntr_appt_doc_cnt = (t_record->phys_qual[i].
    encntr_appt_doc_cnt+ p.encntr_appt_doc_cnt),
    t_record->phys_qual[i].endorse_cnt = (t_record->phys_qual[i].endorse_cnt+ p.endorse_cnt),
    t_record->phys_qual[i].fwd_doc_rev_cnt = (t_record->phys_qual[i].fwd_doc_rev_cnt+ p
    .fwd_doc_rev_cnt), t_record->phys_qual[i].fwd_doc_sign_cnt = (t_record->phys_qual[i].
    fwd_doc_sign_cnt+ p.fwd_doc_sign_cnt),
    t_record->phys_qual[i].man_sat_hm_cnt = (t_record->phys_qual[i].man_sat_hm_cnt+ p.man_sat_hm_cnt),
    t_record->phys_qual[i].orders_cnt = (t_record->phys_qual[i].orders_cnt+ p.orders_cnt), t_record->
    phys_qual[i].perform_cnt = (t_record->phys_qual[i].perform_cnt+ p.perform_cnt),
    t_record->phys_qual[i].problem_cnt = (t_record->phys_qual[i].problem_cnt+ p.problem_cnt),
    t_record->phys_qual[i].procedure_cnt = (t_record->phys_qual[i].procedure_cnt+ p.procedure_cnt),
    t_record->phys_qual[i].sch_appt_cnt = (t_record->phys_qual[i].sch_appt_cnt+ p.sch_appt_cnt),
    t_record->phys_qual[i].signed_cn_cnt = (t_record->phys_qual[i].signed_cn_cnt+ p.signed_cn_cnt),
    t_record->phys_qual[i].signed_med_cnt = (t_record->phys_qual[i].signed_med_cnt+ p.signed_med_cnt),
    t_record->phys_qual[i].signed_pn_cnt = (t_record->phys_qual[i].signed_pn_cnt+ p.signed_pn_cnt),
    phys_exists = 1
   WITH nocounter
  ;end select
 ENDFOR
END GO
