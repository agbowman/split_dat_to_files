CREATE PROGRAM bhs_pco_metrics_rpt_v2:dba
 FREE RECORD t_record
 RECORD t_record(
   1 action_dt_tm = dq8
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
   1 loc_cnt = i4
   1 loc_qual[*]
     2 phys_id = f8
     2 loc = vc
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 DECLARE endorse_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"ENDORSE"))
 DECLARE perform_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"PERFORM"))
 DECLARE sign_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"SIGN"))
 DECLARE review_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"REVIEW"))
 DECLARE blob_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",25,"BLOB"))
 DECLARE doc_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"DOC"))
 DECLARE mdoc_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"MDOC"))
 DECLARE powerchart_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",89,"POWERCHART"))
 DECLARE completed_cd = f8 WITH constant(uar_get_code_by("MEANING",103,"COMPLETED"))
 DECLARE pharmacy_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"PHARMACY"))
 DECLARE home_meds_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "HOMEMEDSUPDATEDINMEDICATIONPROFILE"))
 DECLARE order_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE ordered_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE signed_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",15750,"SIGNED"))
 DECLARE mock_org_id = f8
 DECLARE phys_exists = i2
 DECLARE t_line = vc
 DECLARE location = vc
 DECLARE indx = i4
 DECLARE nsize = i4
 DECLARE nbucketsize = i4
 DECLARE ntotal = i4
 DECLARE nstart = i4
 DECLARE nbuckets = i4
 IF (validate(request->batch_selection))
  SET t_record->action_dt_tm = cnvtdatetime(request->ops_date)
  IF ((t_record->action_dt_tm <= 0))
   SET t_record->action_dt_tm = cnvtdatetime(curdate,curtime3)
  ENDIF
  SET t_record->action_dt_tm = datetimeadd(t_record->action_dt_tm,- (30))
  SET t_record->beg_date = datetimefind(t_record->action_dt_tm,"M","B","B")
  SET t_record->end_date = datetimefind(t_record->action_dt_tm,"M","E","E")
  SET email_list =  $1
 ENDIF
 SET t_record->beg_date = cnvtdatetime("01-oct-2007 00:00:00")
 SET t_record->end_date = cnvtdatetime("14-oct-2007 23:59:59")
 SET email_list = "naser.sanjar2@bhs.org"
 SELECT INTO "nl:"
  o.organization_id
  FROM organization o
  PLAN (o
   WHERE o.org_name_key="MOCKBAYSTATEHEALTHSYSTEM")
  DETAIL
   mock_org_id = o.organization_id
 ;end select
 SELECT DISTINCT INTO TABLE pco_temp
  encntr_id = p.encounter_id, person_id = p.person_id, phys_id = p.phys_id
  FROM bhs_pco_daily_statistics p
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
 SELECT INTO TABLE phys_temp
  phys_id = t_record->phys_qual[d.seq].phys_id
  FROM (dummyt d  WITH seq = t_record->phys_cnt)
  PLAN (d)
 ;end select
 SELECT INTO "nl:"
  FROM phys_temp pt,
   sch_appt sa,
   sch_appt sa1
  PLAN (pt)
   JOIN (sa
   WHERE sa.person_id=pt.phys_id
    AND sa.beg_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND sa.beg_dt_tm <= cnvtdatetime(t_record->end_date)
    AND sa.state_meaning="CHECKED IN"
    AND sa.role_meaning="RESOURCE")
   JOIN (sa1
   WHERE sa1.schedule_id=sa.schedule_id
    AND sa1.state_meaning="CHECKED IN"
    AND sa1.role_meaning="PATIENT")
  ORDER BY sa.person_id, sa.schedule_id
  HEAD sa.person_id
   idx = locateval(indx,1,t_record->phys_cnt,sa.person_id,t_record->phys_qual[indx].phys_id)
  HEAD sa.schedule_id
   t_record->phys_qual[idx].sch_appt_cnt = (t_record->phys_qual[idx].sch_appt_cnt+ 1), t_record->
   encntr_appt_cnt = (t_record->encntr_appt_cnt+ 1), stat = alterlist(t_record->encntr_appt_qual,
    t_record->encntr_appt_cnt),
   t_record->encntr_appt_qual[t_record->encntr_appt_cnt].encntr_id = sa1.encntr_id, t_record->
   encntr_appt_qual[t_record->encntr_appt_cnt].phys_id = sa.person_id
  WITH orahint("index(sa XIE97SCH_APPT)")
 ;end select
 SELECT INTO "nl:"
  FROM phys_temp pt,
   ce_event_prsnl cep,
   scd_story s,
   person p,
   encounter e
  PLAN (pt)
   JOIN (cep
   WHERE cep.action_prsnl_id=pt.phys_id
    AND cep.action_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND cep.action_dt_tm <= cnvtdatetime(t_record->end_date)
    AND cep.action_status_cd=completed_cd
    AND cep.action_type_cd=sign_cd)
   JOIN (s
   WHERE s.event_id=cep.event_id
    AND s.story_completion_status_cd=signed_cd)
   JOIN (p
   WHERE p.person_id=cep.person_id)
   JOIN (e
   WHERE e.person_id=cep.person_id)
  ORDER BY pt.phys_id, cep.event_id
  HEAD pt.phys_id
   idx = locateval(indx,1,t_record->phys_cnt,pt.phys_id,t_record->phys_qual[indx].phys_id)
  HEAD cep.event_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].signed_pn_cnt = (t_record->phys_qual[idx].signed_pn_cnt+ 1)
   ENDIF
  WITH orahint("index(cep XIE3CE_EVENT_PRSNL)")
 ;end select
 SELECT INTO "nl:"
  FROM phys_temp pt,
   ce_event_prsnl cep,
   clinical_event ce,
   clinical_event ce1,
   ce_blob_result ceb,
   person p,
   encounter e
  PLAN (pt)
   JOIN (cep
   WHERE cep.action_prsnl_id=pt.phys_id
    AND cep.action_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND cep.action_dt_tm <= cnvtdatetime(t_record->end_date)
    AND cep.action_status_cd=completed_cd
    AND cep.action_type_cd=sign_cd)
   JOIN (ce
   WHERE ce.event_id=cep.event_id
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
   JOIN (p
   WHERE p.person_id=cep.person_id)
   JOIN (e
   WHERE e.person_id=cep.person_id)
  ORDER BY pt.phys_id, cep.event_id
  HEAD pt.phys_id
   idx = locateval(indx,1,t_record->phys_cnt,pt.phys_id,t_record->phys_qual[indx].phys_id)
  HEAD cep.event_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].signed_cn_cnt = (t_record->phys_qual[idx].signed_cn_cnt+ 1)
   ENDIF
  WITH orahint("index(cep XIE3CE_EVENT_PRSNL)")
 ;end select
 SELECT INTO "nl:"
  FROM phys_temp pt,
   ce_event_prsnl cep,
   person p,
   encounter e
  PLAN (pt)
   JOIN (cep
   WHERE cep.action_prsnl_id=pt.phys_id
    AND cep.action_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND cep.action_dt_tm <= cnvtdatetime(t_record->end_date)
    AND cep.action_type_cd=endorse_cd
    AND cep.action_status_cd=completed_cd)
   JOIN (p
   WHERE p.person_id=cep.person_id)
   JOIN (e
   WHERE e.person_id=cep.person_id)
  ORDER BY pt.phys_id, cep.event_id
  HEAD pt.phys_id
   idx = locateval(indx,1,t_record->phys_cnt,pt.phys_id,t_record->phys_qual[indx].phys_id)
  HEAD cep.event_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    CASE (cep.action_type_cd)
     OF endorse_cd:
      t_record->phys_qual[idx].endorse_cnt = (t_record->phys_qual[idx].endorse_cnt+ 1)
     OF perform_cd:
      t_record->phys_qual[idx].perform_cnt = (t_record->phys_qual[idx].perform_cnt+ 1)
    ENDCASE
   ENDIF
  WITH orahint("index(cep XIE3CE_EVENT_PRSNL)")
 ;end select
 SELECT INTO "nl:"
  FROM phys_temp pt,
   ce_event_prsnl cep,
   clinical_event ce,
   person p,
   encounter e
  PLAN (pt)
   JOIN (cep
   WHERE cep.action_prsnl_id=pt.phys_id
    AND cep.action_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND cep.action_dt_tm <= cnvtdatetime(t_record->end_date)
    AND cep.action_status_cd=completed_cd
    AND cep.action_type_cd IN (sign_cd, review_cd)
    AND ((cep.event_prsnl_id+ 0) != pt.phys_id))
   JOIN (ce
   WHERE ce.event_id=cep.event_id)
   JOIN (p
   WHERE p.person_id=cep.person_id)
   JOIN (e
   WHERE e.person_id=cep.person_id)
  ORDER BY pt.phys_id, cep.event_id
  HEAD pt.phys_id
   idx = locateval(indx,1,t_record->phys_cnt,pt.phys_id,t_record->phys_qual[indx].phys_id)
  HEAD cep.event_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    CASE (cep.action_type_cd)
     OF sign_cd:
      t_record->phys_qual[idx].fwd_doc_sign_cnt = (t_record->phys_qual[idx].fwd_doc_sign_cnt+ 1),idx2
       = 0,idx2 = locateval(indx,1,t_record->encntr_appt_cnt,ce.encntr_id,t_record->encntr_appt_qual[
       indx].encntr_id),
      IF (idx2 > 0)
       t_record->encntr_appt_qual[idx2].doc_ind = 1
      ENDIF
     OF review_cd:
      t_record->phys_qual[idx].fwd_doc_rev_cnt = (t_record->phys_qual[idx].fwd_doc_rev_cnt+ 1)
    ENDCASE
   ENDIF
  WITH maxcol = 1000
 ;end select
 SET nsize = t_record->encntr_appt_cnt
 SET nbucketsize = 200
 SET ntotal = (ceil((cnvtreal(nsize)/ nbucketsize)) * nbucketsize)
 SET nstart = 1
 SET nbuckets = value((1+ ((ntotal - 1)/ nbucketsize)))
 SET stat = alterlist(t_record->encntr_appt_qual,ntotal)
 FOR (j = (nsize+ 1) TO ntotal)
   SET t_record->encntr_appt_qual[j].encntr_id = t_record->encntr_appt_qual[nsize].encntr_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   scd_story s,
   ce_event_prsnl cep
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (s
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),s.encounter_id,t_record->encntr_appt_qual[
    indx].encntr_id)
    AND s.story_completion_status_cd=signed_cd)
   JOIN (cep
   WHERE cep.event_id=s.event_id
    AND expand(indx,nstart,(nstart+ (nbucketsize - 1)),(cep.action_prsnl_id+ 0),t_record->
    encntr_appt_qual[indx].phys_id)
    AND cep.action_status_cd=completed_cd
    AND cep.action_type_cd=sign_cd)
  ORDER BY s.encounter_id
  HEAD s.encounter_id
   idx = 0, idx = locateval(indx,1,t_record->encntr_appt_cnt,s.encounter_id,t_record->
    encntr_appt_qual[indx].encntr_id)
   IF (idx > 0)
    t_record->encntr_appt_qual[idx].doc_ind = 1
   ENDIF
  WITH orahint("index(cep XIE1CE_EVENT_PRSNL)")
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   clinical_event ce,
   ce_event_prsnl cep,
   clinical_event ce1,
   ce_blob_result ceb
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (ce
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),ce.encntr_id,t_record->encntr_appt_qual[indx]
    .encntr_id)
    AND ce.event_class_cd=mdoc_cd
    AND ce.contributor_system_cd=powerchart_cd
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.accession_nbr=" "
    AND  NOT ( EXISTS (
   (SELECT
    s.scd_story_id
    FROM scd_story s
    WHERE s.event_id=ce.event_id))))
   JOIN (cep
   WHERE cep.event_id=ce.event_id
    AND expand(indx,nstart,(nstart+ (nbucketsize - 1)),(cep.action_prsnl_id+ 0),t_record->
    encntr_appt_qual[indx].phys_id)
    AND cep.action_status_cd=completed_cd
    AND cep.action_type_cd=sign_cd)
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
  ORDER BY ce.encntr_id
  HEAD ce.encntr_id
   idx = 0, idx = locateval(indx,1,t_record->encntr_appt_cnt,ce.encntr_id,t_record->encntr_appt_qual[
    indx].encntr_id)
   IF (idx > 0)
    t_record->encntr_appt_qual[idx].doc_ind = 1
   ENDIF
  WITH orahint("index(cep XIE1CE_EVENT_PRSNL)")
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   clinical_event ce,
   ce_event_prsnl cep,
   ce_event_prsnl cep1
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (ce
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),ce.encntr_id,t_record->encntr_appt_qual[indx]
    .encntr_id))
   JOIN (cep
   WHERE cep.event_id=ce.event_id
    AND expand(indx,nstart,(nstart+ (nbucketsize - 1)),(cep.action_prsnl_id+ 0),t_record->
    encntr_appt_qual[indx].phys_id)
    AND cep.action_status_cd=completed_cd
    AND cep.action_type_cd=sign_cd)
   JOIN (cep1
   WHERE cep1.ce_event_prsnl_id=cep.ce_event_prsnl_id
    AND ((cep1.event_prsnl_id+ 0) != cep.action_prsnl_id))
  ORDER BY ce.encntr_id
  HEAD ce.encntr_id
   idx = 0, idx = locateval(indx,1,t_record->encntr_appt_cnt,ce.encntr_id,t_record->encntr_appt_qual[
    indx].encntr_id)
   IF (idx > 0)
    t_record->encntr_appt_qual[idx].doc_ind = 1
   ENDIF
  WITH orahint("index(cep XIE1CE_EVENT_PRSNL)")
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->encntr_appt_cnt),
   phys_temp pt
  PLAN (d)
   JOIN (pt
   WHERE (pt.phys_id=t_record->encntr_appt_qual[d.seq].phys_id))
  DETAIL
   idx = locateval(indx,1,t_record->phys_cnt,pt.phys_id,t_record->phys_qual[indx].phys_id), t_record
   ->phys_qual[idx].encntr_appt_cnt = (t_record->phys_qual[idx].encntr_appt_cnt+ 1)
   IF ((t_record->encntr_appt_qual[d.seq].doc_ind=1))
    t_record->phys_qual[idx].encntr_appt_doc_cnt = (t_record->phys_qual[idx].encntr_appt_doc_cnt+ 1)
   ENDIF
  WITH nocounter
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
  FROM pco_temp pt,
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
   WHERE e.person_id=pt.person_id
    AND e.encntr_id=pt.encntr_id)
  ORDER BY pt.phys_id, hm.expect_mod_id
  HEAD pt.phys_id
   idx = locateval(indx,1,t_record->phys_cnt,pt.phys_id,t_record->phys_qual[indx].phys_id)
  HEAD hm.expect_mod_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].man_sat_hm_cnt = (t_record->phys_qual[idx].man_sat_hm_cnt+ 1)
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
    AND o.orig_order_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND o.orig_order_dt_tm <= cnvtdatetime(t_record->end_date))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.order_provider_id=pt.phys_id
    AND oa.action_type_cd=order_cd)
   JOIN (p
   WHERE p.person_id=pt.person_id)
   JOIN (e
   WHERE e.person_id=pt.person_id
    AND e.encntr_id=pt.encntr_id)
  ORDER BY pt.phys_id, o.order_id
  HEAD pt.phys_id
   idx = locateval(indx,1,t_record->phys_cnt,pt.phys_id,t_record->phys_qual[indx].phys_id)
  HEAD o.order_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].orders_cnt = (t_record->phys_qual[idx].orders_cnt+ 1)
   ENDIF
  WITH orahint("index(o XIE11ORDERS), index(oa XPKORDER_ACTION)")
 ;end select
 SELECT INTO "nl:"
  FROM pco_temp pt,
   charge c,
   person p,
   encounter e
  PLAN (pt)
   JOIN (c
   WHERE c.encntr_id=pt.encntr_id
    AND c.process_flg IN (0, 999))
   JOIN (p
   WHERE p.person_id=pt.person_id)
   JOIN (e
   WHERE e.person_id=pt.person_id
    AND e.encntr_id=pt.encntr_id)
  ORDER BY pt.phys_id, c.charge_item_id
  HEAD pt.phys_id
   idx = locateval(indx,1,t_record->phys_cnt,pt.phys_id,t_record->phys_qual[indx].phys_id)
  HEAD c.charge_item_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].charges_cnt = (t_record->phys_qual[idx].charges_cnt+ 1)
   ENDIF
 ;end select
 FREE DEFINE rtl2
 DEFINE rtl2 "ellyn_users.dat"
 SELECT INTO "nl:"
  FROM rtl2t m
  HEAD REPORT
   line_count = 0
  DETAIL
   t_len = size(m.line), line_count = (line_count+ 1), t_record->loc_cnt = (t_record->loc_cnt+ 1),
   idx = t_record->loc_cnt, stat = alterlist(t_record->loc_qual,idx), curpos = 0,
   curpos = (curpos+ 1), curpos = findstring("|",m.line,curpos,0), t_record->loc_qual[idx].phys_id =
   cnvtint(substring(1,(curpos - 1),m.line)),
   nextpos = findstring("|",m.line,(curpos+ 1),0), curpos = (nextpos+ 1), t_record->loc_qual[idx].loc
    = substring(curpos,(t_len - curpos),m.line)
  WITH nocounter
 ;end select
 SELECT INTO "pco_metrics.xls"
  total_docs = ((t_record->phys_qual[d.seq].signed_pn_cnt+ t_record->phys_qual[d.seq].signed_cn_cnt)
  + t_record->phys_qual[d.seq].fwd_doc_sign_cnt), percent_signed_docs = cnvtint((100 * (cnvtreal(
    t_record->phys_qual[d.seq].encntr_appt_doc_cnt)/ t_record->phys_qual[d.seq].encntr_appt_cnt))),
  phys_id = t_record->phys_qual[d.seq].phys_id
  FROM (dummyt d  WITH seq = t_record->phys_cnt),
   person pr
  PLAN (d)
   JOIN (pr
   WHERE (pr.person_id=t_record->phys_qual[d.seq].phys_id)
    AND pr.active_ind=1)
  ORDER BY pr.name_full_formatted, phys_id
  HEAD REPORT
   t_line = "PCO Metrics Report", col 0, t_line,
   row + 1, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
     end_date,"DD-MMM-YYYY;;Q"),char(9)), col 0,
   t_line, row + 1, t_line = concat("Physcian Name",char(9),"Location",char(9),"Charts Opened",
    char(9),"Signed Prescriptions",char(9),"Allergy Additions/Updates",char(9),
    "Problem Additions/Updates",char(9),"Diagnosis Additions/Updates",char(9),
    "Procedure Additions/Updates",
    char(9),"Signed PowerNotes",char(9),"Signed Clinical Notes",char(9),
    "Forwarded Documents Signed",char(9),"Total Documents Signed",char(9),
    "Forwarded Documents Reviewed",
    char(9),"Results Endorsed",char(9),"Manual Satisfiers into HM",char(9),
    "Orders",char(9),"Charges",char(9),"Scheduled Appointments",
    char(9),"% Appointments with Signed Documents",char(9)),
   col 0, t_line, row + 1
  HEAD pr.name_full_formatted
   null
  HEAD phys_id
   idx = locateval(indx,1,t_record->loc_cnt,t_record->phys_qual[d.seq].phys_id,t_record->loc_qual[
    indx].phys_id)
   IF (idx=0)
    location = "Location not on file"
   ELSE
    location = trim(t_record->loc_qual[idx].loc)
   ENDIF
   t_line = concat(trim(pr.name_full_formatted),char(9),trim(location),char(9),trim(cnvtstring(
      t_record->phys_qual[d.seq].charts)),
    char(9),trim(cnvtstring(t_record->phys_qual[d.seq].signed_med_cnt)),char(9),trim(cnvtstring(
      t_record->phys_qual[d.seq].allergy_cnt)),char(9),
    trim(cnvtstring(t_record->phys_qual[d.seq].problem_cnt)),char(9),trim(cnvtstring(t_record->
      phys_qual[d.seq].diagnosis_cnt)),char(9),trim(cnvtstring(t_record->phys_qual[d.seq].
      procedure_cnt)),
    char(9),trim(cnvtstring(t_record->phys_qual[d.seq].signed_pn_cnt)),char(9),trim(cnvtstring(
      t_record->phys_qual[d.seq].signed_cn_cnt)),char(9),
    trim(cnvtstring(t_record->phys_qual[d.seq].fwd_doc_sign_cnt)),char(9),trim(cnvtstring(total_docs)
     ),char(9),trim(cnvtstring(t_record->phys_qual[d.seq].fwd_doc_rev_cnt)),
    char(9),trim(cnvtstring(t_record->phys_qual[d.seq].endorse_cnt)),char(9),trim(cnvtstring(t_record
      ->phys_qual[d.seq].man_sat_hm_cnt)),char(9),
    trim(cnvtstring(t_record->phys_qual[d.seq].orders_cnt)),char(9),trim(cnvtstring(t_record->
      phys_qual[d.seq].charges_cnt)),char(9),trim(cnvtstring(t_record->phys_qual[d.seq].sch_appt_cnt)
     ),
    char(9),trim(cnvtstring(percent_signed_docs)),char(9)), col 0, t_line,
   row + 1
  WITH nocounter, maxcol = 1000, formfeed = none
 ;end select
 IF (findfile("pco_metrics.xls")=1)
  SET subject_line = concat("PCO Metrics Report ",format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",
   format(t_record->end_date,"DD-MMM-YYYY;;Q"))
  SET dclcom = concat("(uuencode pco_metrics.xls pco_metrics.xls;) "," | mailx -s ",'"',subject_line,
   '" ',
   email_list)
  SET len = size(trim(dclcom))
  SET status = 0
  SET stat = dcl(dclcom,len,status)
  SET stat = remove("pco_metrics.xls")
 ENDIF
 SET stat = remove("pco_temp.dat*")
 SET stat = remove("phys_temp*")
#exit_script
 SET reply->status_data[1].status = "S"
END GO
