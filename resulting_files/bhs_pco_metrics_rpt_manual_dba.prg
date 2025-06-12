CREATE PROGRAM bhs_pco_metrics_rpt_manual:dba
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
     2 fwd_doc_cnt = i4
     2 fwd_doc_sign_cnt = i4
     2 fwd_doc_rev_cnt = i4
     2 fwd_doc_not_sign_cnt = i4
     2 fwd_ord_not_sign_cnt = i4
     2 unread_msgs = i4
     2 orders_cnt = i4
     2 charges_cnt = i4
     2 encntr_appt_cnt = i4
     2 encntr_appt_doc_cnt = i4
     2 location = vc
     2 position = vc
   1 encntr_appt_cnt = i4
   1 encntr_appt_qual[*]
     2 phys_id = f8
     2 encntr_id = f8
     2 doc_ind = i2
   1 pn_cnt = i4
   1 pn_qual[*]
     2 event_id = f8
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 DECLARE endorse_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"ENDORSE"))
 DECLARE perform_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"PERFORM"))
 DECLARE modify_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"MODIFY"))
 DECLARE sign_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"SIGN"))
 DECLARE review_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"REVIEW"))
 DECLARE blob_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",25,"BLOB"))
 DECLARE doc_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"DOC"))
 DECLARE mdoc_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"MDOC"))
 DECLARE appt1_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION"))
 DECLARE appt2_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHOBV"))
 DECLARE appt3_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDOBV"))
 DECLARE appt4_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE appt5_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP"))
 DECLARE appt6_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDIP"))
 DECLARE appt7_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE appt8_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"PREADMITDAYSTAY"))
 DECLARE appt9_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHDAYSTAY"))
 DECLARE appt10_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDDAYSTAY"))
 DECLARE pending_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",79,"PENDING"))
 DECLARE powerchart_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",89,"POWERCHART"))
 DECLARE completed_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",103,"COMPLETED"))
 DECLARE requested_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",103,"REQUESTED"))
 DECLARE pharmacy_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"PHARMACY"))
 DECLARE home_meds_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "HOMEMEDSUPDATEDINMEDICATIONPROFILE"))
 DECLARE order_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE ordered_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE phone_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6026,"PHONEMSG"))
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
 SET t_record->beg_date = cnvtdatetime("12-sep-2007 00:00:00")
 SET t_record->end_date = cnvtdatetime("04-dec-2007 23:59:59")
 SET email_list = "anthony.jacobson@bhs.org"
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
   t_record->phys_cnt = (t_record->phys_cnt+ 1)
   IF (mod(t_record->phys_cnt,1000)=1)
    stat = alterlist(t_record->phys_qual,(t_record->phys_cnt+ 999))
   ENDIF
   idx = t_record->phys_cnt, t_record->phys_qual[idx].phys_id = pt.phys_id
  HEAD pt.encntr_id
   t_record->phys_qual[idx].charts = (t_record->phys_qual[idx].charts+ 1)
  FOOT REPORT
   stat = alterlist(t_record->phys_qual,t_record->phys_cnt)
 ;end select
 SELECT INTO TABLE phys_temp
  phys_id = t_record->phys_qual[d.seq].phys_id
  FROM (dummyt d  WITH seq = t_record->phys_cnt)
  PLAN (d)
 ;end select
 SELECT INTO "nl:"
  FROM phys_temp pt,
   prsnl p
  PLAN (pt)
   JOIN (p
   WHERE p.person_id=pt.phys_id)
  ORDER BY p.person_id
  HEAD p.person_id
   idx = locateval(indx,1,t_record->phys_cnt,p.person_id,t_record->phys_qual[indx].phys_id), t_record
   ->phys_qual[idx].position = uar_get_code_display(p.position_cd)
 ;end select
 SELECT INTO "nl:"
  FROM phys_temp pt,
   bhs_physician_location bp,
   bhs_practice_location bpl
  PLAN (pt)
   JOIN (bp
   WHERE bp.person_id=pt.phys_id)
   JOIN (bpl
   WHERE bpl.location_id=bp.location_id)
  ORDER BY pt.phys_id
  HEAD pt.phys_id
   idx = locateval(indx,1,t_record->phys_cnt,pt.phys_id,t_record->phys_qual[indx].phys_id), t_record
   ->phys_qual[idx].location = bpl.location_description
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
   encntr_appt_cnt = (t_record->encntr_appt_cnt+ 1)
   IF (mod(t_record->encntr_appt_cnt,10000)=1)
    stat = alterlist(t_record->encntr_appt_qual,(t_record->encntr_appt_cnt+ 9999))
   ENDIF
   t_record->encntr_appt_qual[t_record->encntr_appt_cnt].encntr_id = sa1.encntr_id, t_record->
   encntr_appt_qual[t_record->encntr_appt_cnt].phys_id = sa.person_id
  FOOT REPORT
   stat = alterlist(t_record->encntr_appt_qual,t_record->encntr_appt_cnt)
  WITH orahint("index(sa XIE97SCH_APPT)")
 ;end select
 SELECT INTO "nl:"
  FROM phys_temp pt,
   ce_event_prsnl cep,
   scd_story s,
   clinical_event ce,
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
   JOIN (ce
   WHERE ce.event_id=cep.event_id
    AND ((ce.performed_prsnl_id+ 0)=cep.action_prsnl_id))
   JOIN (p
   WHERE p.person_id=cep.person_id)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND  NOT (e.encntr_type_cd IN (appt1_cd, appt2_cd, appt3_cd, appt4_cd, appt5_cd,
   appt6_cd, appt7_cd, appt8_cd, appt9_cd, appt10_cd)))
  ORDER BY pt.phys_id, cep.event_id
  HEAD pt.phys_id
   idx = locateval(indx,1,t_record->phys_cnt,pt.phys_id,t_record->phys_qual[indx].phys_id)
  HEAD cep.event_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].signed_pn_cnt = (t_record->phys_qual[idx].signed_pn_cnt+ 1)
   ENDIF
   t_record->pn_cnt = (t_record->pn_cnt+ 1), stat = alterlist(t_record->pn_qual,t_record->pn_cnt),
   t_record->pn_qual[t_record->pn_cnt].event_id = s.event_id
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
    AND ((ce.performed_prsnl_id+ 0)=cep.action_prsnl_id)
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
   WHERE e.encntr_id=ce.encntr_id
    AND  NOT (e.encntr_type_cd IN (appt1_cd, appt2_cd, appt3_cd, appt4_cd, appt5_cd,
   appt6_cd, appt7_cd, appt8_cd, appt9_cd, appt10_cd)))
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
   clinical_event ce,
   person p,
   encounter e
  PLAN (pt)
   JOIN (cep
   WHERE cep.action_prsnl_id=pt.phys_id
    AND cep.action_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND cep.action_dt_tm <= cnvtdatetime(t_record->end_date)
    AND cep.action_type_cd=endorse_cd
    AND cep.action_status_cd=completed_cd)
   JOIN (ce
   WHERE ce.event_id=cep.event_id
    AND ce.event_id=ce.parent_event_id)
   JOIN (p
   WHERE p.person_id=cep.person_id)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND  NOT (e.encntr_type_cd IN (appt1_cd, appt2_cd, appt3_cd, appt4_cd, appt5_cd,
   appt6_cd, appt7_cd, appt8_cd, appt9_cd, appt10_cd)))
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
   ce_event_prsnl cep1,
   clinical_event ce,
   person p,
   encounter e
  PLAN (pt)
   JOIN (cep
   WHERE cep.action_prsnl_id=pt.phys_id
    AND cep.action_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND cep.action_dt_tm <= cnvtdatetime(t_record->end_date)
    AND cep.action_status_cd=completed_cd
    AND cep.action_type_cd=sign_cd
    AND cep.request_prsnl_id != cep.action_prsnl_id)
   JOIN (cep1
   WHERE cep1.event_id=cep.event_id
    AND cep1.action_prsnl_id=cep.action_prsnl_id
    AND cep1.action_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND cep1.action_dt_tm <= cnvtdatetime(t_record->end_date)
    AND cep1.action_status_cd=completed_cd
    AND cep1.action_type_cd=modify_cd
    AND cep1.request_prsnl_id != cep1.action_prsnl_id)
   JOIN (ce
   WHERE ce.event_id=cep.event_id)
   JOIN (p
   WHERE p.person_id=cep.person_id)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND  NOT (e.encntr_type_cd IN (appt1_cd, appt2_cd, appt3_cd, appt4_cd, appt5_cd,
   appt6_cd, appt7_cd, appt8_cd, appt9_cd, appt10_cd)))
  ORDER BY pt.phys_id, cep.event_id
  HEAD pt.phys_id
   idx = locateval(indx,1,t_record->phys_cnt,pt.phys_id,t_record->phys_qual[indx].phys_id)
  HEAD cep.event_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].fwd_doc_cnt = (t_record->phys_qual[idx].fwd_doc_cnt+ 1)
   ENDIF
  WITH orahint("index(cep XIE3CE_EVENT_PRSNL), index(cep1 XIE1CE_EVENT_PRSNL)")
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
    AND cep.request_prsnl_id != cep.action_prsnl_id)
   JOIN (ce
   WHERE ce.event_id=cep.event_id)
   JOIN (p
   WHERE p.person_id=cep.person_id)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND  NOT (e.encntr_type_cd IN (appt1_cd, appt2_cd, appt3_cd, appt4_cd, appt5_cd,
   appt6_cd, appt7_cd, appt8_cd, appt9_cd, appt10_cd)))
  ORDER BY pt.phys_id, cep.event_id, cep.ce_event_prsnl_id
  HEAD pt.phys_id
   idx = locateval(indx,1,t_record->phys_cnt,pt.phys_id,t_record->phys_qual[indx].phys_id)
  HEAD cep.ce_event_prsnl_id
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
    AND cep.action_status_cd=requested_cd
    AND cep.action_type_cd IN (sign_cd, review_cd)
    AND cep.request_dt_tm <= cnvtdatetime(t_record->end_date)
    AND cep.request_dt_tm >= cnvtdatetime(datetimeadd(t_record->beg_date,- (365)))
    AND cep.request_prsnl_id != cep.action_prsnl_id
    AND  NOT ( EXISTS (
   (SELECT
    cep2.event_id
    FROM ce_event_prsnl cep2
    WHERE cep2.event_id=cep.event_id
     AND ((cep2.action_prsnl_id+ 0)=cep.action_prsnl_id)
     AND ((cep2.action_status_cd+ 0) != requested_cd)))))
   JOIN (ce
   WHERE ce.event_id=cep.event_id)
   JOIN (p
   WHERE p.person_id=cep.person_id)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND  NOT (e.encntr_type_cd IN (appt1_cd, appt2_cd, appt3_cd, appt4_cd, appt5_cd,
   appt6_cd, appt7_cd, appt8_cd, appt9_cd, appt10_cd)))
  ORDER BY pt.phys_id, cep.ce_event_prsnl_id
  HEAD pt.phys_id
   idx = locateval(indx,1,t_record->phys_cnt,pt.phys_id,t_record->phys_qual[indx].phys_id)
  HEAD cep.ce_event_prsnl_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].fwd_doc_not_sign_cnt = (t_record->phys_qual[idx].fwd_doc_not_sign_cnt+ 1
    )
   ENDIF
  WITH orahint("index(cep XIE3CE_EVENT_PRSNL)")
 ;end select
 SELECT INTO "nl:"
  FROM phys_temp pt,
   order_notification ono,
   orders o,
   person p,
   encounter e
  PLAN (pt)
   JOIN (ono
   WHERE ono.to_prsnl_id=pt.phys_id
    AND ono.notification_dt_tm <= cnvtdatetime(t_record->end_date)
    AND ono.notification_status_flag=1)
   JOIN (o
   WHERE o.order_id=ono.order_id)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND  NOT (e.encntr_type_cd IN (appt1_cd, appt2_cd, appt3_cd, appt4_cd, appt5_cd,
   appt6_cd, appt7_cd, appt8_cd, appt9_cd, appt10_cd)))
  ORDER BY pt.phys_id, ono.order_notification_id
  HEAD pt.phys_id
   idx = locateval(indx,1,t_record->phys_cnt,pt.phys_id,t_record->phys_qual[indx].phys_id)
  HEAD ono.order_notification_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].fwd_ord_not_sign_cnt = (t_record->phys_qual[idx].fwd_ord_not_sign_cnt+ 1
    )
   ENDIF
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM phys_temp pt,
   task_activity_assignment taa,
   task_activity ta,
   person p,
   encounter e
  PLAN (pt)
   JOIN (taa
   WHERE taa.assign_prsnl_id=pt.phys_id
    AND taa.task_status_cd=pending_cd
    AND taa.beg_eff_dt_tm >= cnvtdatetime(datetimeadd(t_record->beg_date,- (365))))
   JOIN (ta
   WHERE ta.task_id=taa.task_id
    AND ((ta.task_type_cd+ 0)=phone_cd))
   JOIN (p
   WHERE p.person_id=ta.person_id)
   JOIN (e
   WHERE e.encntr_id=ta.encntr_id)
  ORDER BY pt.phys_id, taa.task_activity_assign_id
  HEAD pt.phys_id
   idx = locateval(indx,1,t_record->phys_cnt,pt.phys_id,t_record->phys_qual[indx].phys_id)
  HEAD taa.task_activity_assign_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].unread_msgs = (t_record->phys_qual[idx].unread_msgs+ 1)
   ENDIF
  WITH maxcol = 1000
 ;end select
 SET nsize = t_record->encntr_appt_cnt
 SET nbucketsize = 20
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
   ce_event_prsnl cep,
   clinical_event ce
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
   JOIN (ce
   WHERE ce.event_id=cep.event_id
    AND ce.performed_prsnl_id=cep.action_prsnl_id)
  ORDER BY s.encounter_id
  HEAD s.encounter_id
   idx = 0, idx = locateval(indx,1,t_record->encntr_appt_cnt,s.encounter_id,t_record->
    encntr_appt_qual[indx].encntr_id)
   IF (idx > 0)
    t_record->encntr_appt_qual[idx].doc_ind = 1, t_record->encntr_appt_qual[idx].encntr_id = 0
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
    AND cep.action_type_cd=sign_cd
    AND ((cep.action_prsnl_id+ 0)=ce.performed_prsnl_id))
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
    t_record->encntr_appt_qual[idx].doc_ind = 1, t_record->encntr_appt_qual[idx].encntr_id = 0
   ENDIF
  WITH orahint("index(cep XIE1CE_EVENT_PRSNL) index(ce FK10CLINICAL_EVENT)")
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   clinical_event ce,
   ce_event_prsnl cep,
   encounter e
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
    AND cep.action_type_cd=sign_cd
    AND cep.request_prsnl_id != cep.action_prsnl_id)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND  NOT (e.encntr_type_cd IN (appt1_cd, appt2_cd, appt3_cd, appt4_cd, appt5_cd,
   appt6_cd, appt7_cd, appt8_cd, appt9_cd, appt10_cd)))
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
 ;end select
 SELECT INTO "nl:"
  FROM pco_temp pt,
   allergy a,
   person p,
   encounter e
  PLAN (pt)
   JOIN (a
   WHERE a.encntr_id=pt.encntr_id
    AND a.updt_id=pt.person_id
    AND a.updt_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND a.updt_dt_tm <= cnvtdatetime(t_record->end_date))
   JOIN (p
   WHERE p.person_id=a.person_id)
   JOIN (e
   WHERE e.encntr_id=a.encntr_id
    AND  NOT (e.encntr_type_cd IN (appt1_cd, appt2_cd, appt3_cd, appt4_cd, appt5_cd,
   appt6_cd, appt7_cd, appt8_cd, appt9_cd, appt10_cd)))
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
   WHERE e.encntr_id=pt.encntr_id
    AND  NOT (e.encntr_type_cd IN (appt1_cd, appt2_cd, appt3_cd, appt4_cd, appt5_cd,
   appt6_cd, appt7_cd, appt8_cd, appt9_cd, appt10_cd)))
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
   WHERE e.encntr_id=d.encntr_id
    AND  NOT (e.encntr_type_cd IN (appt1_cd, appt2_cd, appt3_cd, appt4_cd, appt5_cd,
   appt6_cd, appt7_cd, appt8_cd, appt9_cd, appt10_cd)))
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
   WHERE e.encntr_id=pr.encntr_id
    AND  NOT (e.encntr_type_cd IN (appt1_cd, appt2_cd, appt3_cd, appt4_cd, appt5_cd,
   appt6_cd, appt7_cd, appt8_cd, appt9_cd, appt10_cd)))
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
   WHERE e.encntr_id=o.encntr_id
    AND  NOT (e.encntr_type_cd IN (appt1_cd, appt2_cd, appt3_cd, appt4_cd, appt5_cd,
   appt6_cd, appt7_cd, appt8_cd, appt9_cd, appt10_cd)))
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
   WHERE e.encntr_id=o.encntr_id
    AND  NOT (e.encntr_type_cd IN (appt1_cd, appt2_cd, appt3_cd, appt4_cd, appt5_cd,
   appt6_cd, appt7_cd, appt8_cd, appt9_cd, appt10_cd)))
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
   WHERE e.encntr_id=pt.encntr_id
    AND  NOT (e.encntr_type_cd IN (appt1_cd, appt2_cd, appt3_cd, appt4_cd, appt5_cd,
   appt6_cd, appt7_cd, appt8_cd, appt9_cd, appt10_cd)))
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
   WHERE e.encntr_id=o.encntr_id
    AND  NOT (e.encntr_type_cd IN (appt1_cd, appt2_cd, appt3_cd, appt4_cd, appt5_cd,
   appt6_cd, appt7_cd, appt8_cd, appt9_cd, appt10_cd)))
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
   WHERE e.encntr_id=c.encntr_id
    AND  NOT (e.encntr_type_cd IN (appt1_cd, appt2_cd, appt3_cd, appt4_cd, appt5_cd,
   appt6_cd, appt7_cd, appt8_cd, appt9_cd, appt10_cd)))
  ORDER BY pt.phys_id, c.charge_item_id
  HEAD pt.phys_id
   idx = locateval(indx,1,t_record->phys_cnt,pt.phys_id,t_record->phys_qual[indx].phys_id)
  HEAD c.charge_item_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].charges_cnt = (t_record->phys_qual[idx].charges_cnt+ 1)
   ENDIF
 ;end select
 SELECT INTO "pco_metrics.xls"
  total_docs = ((t_record->phys_qual[d.seq].signed_pn_cnt+ t_record->phys_qual[d.seq].signed_cn_cnt)
  + t_record->phys_qual[d.seq].fwd_doc_cnt), percent_signed_docs = substring(0,3,cnvtstring(cnvtint((
     100 * (cnvtreal(t_record->phys_qual[d.seq].encntr_appt_doc_cnt)/ t_record->phys_qual[d.seq].
     encntr_appt_cnt))))), phys_id = t_record->phys_qual[d.seq].phys_id
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
   t_line, row + 1, t_line = concat("Physcian Name",char(9),"Position",char(9),"Location",
    char(9),"Charts Opened",char(9),"Signed Prescriptions",char(9),
    "Allergy Additions/Updates",char(9),"Problem Additions/Updates",char(9),
    "Diagnosis Additions/Updates",
    char(9),"Procedure Additions/Updates",char(9),"Signed PowerNotes",char(9),
    "Signed Clinical Notes",char(9),"Forwarded Documents Modified and Signed",char(9),
    "Total Documents Signed",
    char(9),"Forwarded Documents Signed",char(9),"Forwarded Documents Reviewed",char(9),
    "Forwarded Documents Not Signed or Reviewed",char(9),"Forwarded Orders Not Signed or Reviewed",
    char(9),"Unread Messages",
    char(9),"Results Endorsed",char(9),"Manual Satisfiers into HM",char(9),
    "Orders",char(9),"Charges",char(9),"Number of Patients Seen",
    char(9),"Number of Appts with Docs",char(9),"% Appointments with Signed Documents",char(9)),
   col 0, t_line, row + 1
  HEAD pr.name_full_formatted
   null
  HEAD phys_id
   t_line = concat(trim(pr.name_full_formatted),char(9),trim(t_record->phys_qual[d.seq].position),
    char(9),trim(t_record->phys_qual[d.seq].location),
    char(9),trim(cnvtstring(t_record->phys_qual[d.seq].charts)),char(9),trim(cnvtstring(t_record->
      phys_qual[d.seq].signed_med_cnt)),char(9),
    trim(cnvtstring(t_record->phys_qual[d.seq].allergy_cnt)),char(9),trim(cnvtstring(t_record->
      phys_qual[d.seq].problem_cnt)),char(9),trim(cnvtstring(t_record->phys_qual[d.seq].diagnosis_cnt
      )),
    char(9),trim(cnvtstring(t_record->phys_qual[d.seq].procedure_cnt)),char(9),trim(cnvtstring(
      t_record->phys_qual[d.seq].signed_pn_cnt)),char(9),
    trim(cnvtstring(t_record->phys_qual[d.seq].signed_cn_cnt)),char(9),trim(cnvtstring(t_record->
      phys_qual[d.seq].fwd_doc_cnt)),char(9),trim(cnvtstring(total_docs)),
    char(9),trim(cnvtstring(t_record->phys_qual[d.seq].fwd_doc_sign_cnt)),char(9),trim(cnvtstring(
      t_record->phys_qual[d.seq].fwd_doc_rev_cnt)),char(9),
    trim(cnvtstring(t_record->phys_qual[d.seq].fwd_doc_not_sign_cnt)),char(9),trim(cnvtstring(
      t_record->phys_qual[d.seq].fwd_ord_not_sign_cnt)),char(9),trim(cnvtstring(t_record->phys_qual[d
      .seq].unread_msgs)),
    char(9),trim(cnvtstring(t_record->phys_qual[d.seq].endorse_cnt)),char(9),trim(cnvtstring(t_record
      ->phys_qual[d.seq].man_sat_hm_cnt)),char(9),
    trim(cnvtstring(t_record->phys_qual[d.seq].orders_cnt)),char(9),trim(cnvtstring(t_record->
      phys_qual[d.seq].charges_cnt)),char(9),trim(cnvtstring(t_record->phys_qual[d.seq].sch_appt_cnt)
     ),
    char(9),trim(cnvtstring(t_record->phys_qual[d.seq].encntr_appt_doc_cnt)),char(9),trim(cnvtstring(
      percent_signed_docs)),char(9)), col 0, t_line,
   row + 1
  WITH nocounter, maxcol = 1000, formfeed = none
 ;end select
 SELECT INTO "pn_type_counts.xls"
  FROM (dummyt d  WITH seq = t_record->pn_cnt),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.event_id=t_record->pn_qual[d.seq].event_id))
  ORDER BY ce.event_tag, ce.event_title_text
  HEAD REPORT
   t_line = "PCO PN Type Count Report", col 0, t_line,
   row + 1, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
     end_date,"DD-MMM-YYYY;;Q"),char(9)), col 0,
   t_line, row + 1, t_line = concat("Powernote Type",char(9),"Powernote Title",char(9),
    "Number Signed",
    char(9)),
   col 0, t_line, row + 1
  HEAD ce.event_title_text
   count = 0
  DETAIL
   count = (count+ 1)
  FOOT  ce.event_title_text
   t_line = concat(trim(ce.event_tag),char(9),trim(ce.event_title_text),char(9),trim(cnvtstring(count
      )),
    char(9)), col 0, t_line,
   row + 1
  WITH maxcol = 1000, formfeed = none
 ;end select
 IF (findfile("pco_metrics.xls")=1
  AND findfile("pn_type_counts.xls")=1)
  SET subject_line = concat("PCO Metrics Report ",format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",
   format(t_record->end_date,"DD-MMM-YYYY;;Q"))
  SET dclcom = concat('echo " " | mailx -s "',subject_line,'" ','-a "pco_metrics.xls" ',
   '-a "pn_type_counts.xls" ',
   email_list)
  SET len = size(trim(dclcom))
  SET status = 0
  SET stat = dcl(dclcom,len,status)
  SET stat = remove("pco_metrics.xls")
  SET stat = remove("pn_type_counts.xls")
 ENDIF
 DROP TABLE pco_temp
 DROP TABLE phys_temp
 SET dclcom = "rm -f pco_temp*"
 SET len = size(trim(dclcom))
 SET status = 0
 SET stat = dcl(dclcom,len,status)
 SET dclcom = "rm -f phys_temp*"
 SET len = size(trim(dclcom))
 SET status = 0
 SET stat = dcl(dclcom,len,status)
#exit_script
 SET reply->status_data[1].status = "S"
END GO
