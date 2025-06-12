CREATE PROGRAM bhs_pim_gather_data
 FREE RECORD followup
 RECORD followup(
   1 updt_cnt = i4
   1 updts[*]
     2 activity_id = f8
     2 eks_dig_event_id = f8
     2 override_reason_cd = f8
   1 e_cnt = i4
   1 encntrs[*]
     2 encntr_id = f8
     2 person_id = f8
     2 create_dt_tm = dq8
     2 disch_ind = i2
   1 de_cnt = i4
   1 disch[*]
     2 encntr_id = f8
 )
 EXECUTE bhs_pim_drug_lists
 SELECT INTO "nl:"
  bpaa.activity_id, bpaa.encntr_id, ede.dlg_event_id,
  ede.override_reason_cd, ede.long_text_id
  FROM bhs_pim_alert_activity bpaa,
   eks_dlg_event ede
  PLAN (bpaa
   WHERE bpaa.eks_dig_event_id=0.00
    AND bpaa.order_id > 0.00)
   JOIN (ede
   WHERE bpaa.order_id=ede.trigger_order_id
    AND ede.dlg_name="BHS_EKM!BHS_SYN_PIM_INAPPR_DRUGS")
  DETAIL
   followup->updt_cnt = (followup->updt_cnt+ 1)
   IF ((followup->updt_cnt > size(followup->updts,5)))
    stat = alterlist(followup->updts,(followup->updt_cnt+ 100))
   ENDIF
   followup->updts[followup->updt_cnt].activity_id = bpaa.activity_id, followup->updts[followup->
   updt_cnt].eks_dig_event_id = ede.dlg_event_id
   IF (ede.long_text_id > 0.00)
    followup->updts[followup->updt_cnt].override_reason_cd = - (1.00)
   ELSE
    followup->updts[followup->updt_cnt].override_reason_cd = ede.override_reason_cd
   ENDIF
  FOOT REPORT
   stat = alterlist(followup->updts,followup->updt_cnt)
  WITH nocounter
 ;end select
 FOR (u = 1 TO followup->updt_cnt)
  UPDATE  FROM bhs_pim_alert_activity bpaa
   SET bpaa.eks_dig_event_id = value(followup->updts[u].eks_dig_event_id), bpaa.override_reason_cd =
    value(followup->updts[u].override_reason_cd)
   PLAN (bpaa
    WHERE (bpaa.activity_id=followup->updts[u].activity_id))
   WITH nocounter
  ;end update
  COMMIT
 ENDFOR
 SELECT DISTINCT INTO "nl:"
  e.person_id, e.encntr_id, e.create_dt_tm,
  e.disch_dt_tm, bpp.encntr_id
  FROM bhs_pim_alert_activity bpaa,
   encounter e,
   bhs_pim_patient bpp
  PLAN (bpaa
   WHERE bpaa.active_ind=1)
   JOIN (e
   WHERE bpaa.encntr_id=e.encntr_id)
   JOIN (bpp
   WHERE outerjoin(bpaa.encntr_id)=bpp.encntr_id
    AND bpp.encntr_disch_ind=outerjoin(0))
  HEAD e.encntr_id
   IF (bpp.encntr_id=null)
    followup->e_cnt = (followup->e_cnt+ 1)
    IF ((followup->e_cnt > size(followup->encntrs,5)))
     stat = alterlist(followup->encntrs,(followup->e_cnt+ 100))
    ENDIF
    followup->encntrs[followup->e_cnt].person_id = e.person_id, followup->encntrs[followup->e_cnt].
    encntr_id = e.encntr_id, followup->encntrs[followup->e_cnt].create_dt_tm = e.create_dt_tm
    IF (datetimediff(cnvtdatetime(curdate,curtime3),e.disch_dt_tm) >= 1.00)
     followup->encntrs[followup->e_cnt].disch_ind = 1
    ENDIF
   ELSEIF (bpp.encntr_id=e.encntr_id
    AND datetimediff(cnvtdatetime(curdate,curtime3),e.disch_dt_tm) >= 1.00)
    followup->de_cnt = (followup->de_cnt+ 1)
    IF ((followup->de_cnt > size(followup->disch,5)))
     stat = alterlist(followup->disch,(followup->de_cnt+ 100))
    ENDIF
    followup->disch[followup->de_cnt].encntr_id = e.encntr_id
   ENDIF
  FOOT REPORT
   stat = alterlist(followup->encntrs,followup->e_cnt), stat = alterlist(followup->disch,followup->
    de_cnt)
  WITH nocounter
 ;end select
 IF ((followup->e_cnt > 0))
  INSERT  FROM bhs_pim_patient bp,
    (dummyt d  WITH seq = value(followup->e_cnt))
   SET bp.person_id = followup->encntrs[d.seq].person_id, bp.encntr_id = followup->encntrs[d.seq].
    encntr_id, bp.encntr_create_dt_tm = sysdate,
    bp.encntr_disch_ind = followup->encntrs[d.seq].disch_ind, bp.active_ind = 1
   PLAN (d)
    JOIN (bp)
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
 IF ((followup->de_cnt > 0))
  UPDATE  FROM bhs_pim_patient bpp,
    (dummyt d  WITH seq = value(followup->de_cnt))
   SET bpp.encntr_disch_ind = 1
   PLAN (d)
    JOIN (bpp
    WHERE (bpp.encntr_id=followup->disch[d.seq].encntr_id))
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
END GO
