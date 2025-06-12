CREATE PROGRAM bbd_get_all_donor_history:dba
 RECORD reply(
   1 qual[*]
     2 drawn_dt_tm = dq8
     2 procedure_cd = f8
     2 procedure_cd_disp = vc
     2 outcome_cd = f8
     2 outcome_cd_disp = vc
     2 product_nbr = vc
     2 product_sub_nbr = vc
     2 donation_result_id = f8
     2 encntr_id = f8
     2 comment_ind = i2
     2 contact_id = f8
     2 contact_type_cd = f8
     2 contact_type_cd_disp = vc
     2 contact_type_cd_mean = c12
     2 reasonqual[*]
       3 reason_cd = f8
       3 reason_cd_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SET reascount = 0
 SET hold_contact_id = 0.0
 SET donate_contact_cd = 0.0
 SET recruit_contact_cd = 0.0
 SET counsel_contact_cd = 0.0
 SET other_contact_cd = 0.0
 SET cv_cnt = 1
 IF ((request->donate_contact_type=1))
  SET stat = uar_get_meaning_by_codeset(14220,"DONATE",cv_cnt,donate_contact_cd)
 ENDIF
 SET cv_cnt = 1
 IF ((request->recruit_contact_type=2))
  SET stat = uar_get_meaning_by_codeset(14220,"RECRUIT",cv_cnt,recruit_contact_cd)
 ENDIF
 SET cv_cnt = 1
 IF ((request->counsel_contact_type=3))
  SET stat = uar_get_meaning_by_codeset(14220,"COUNSEL",cv_cnt,counsel_contact_cd)
 ENDIF
 SET cv_cnt = 1
 IF ((request->other_contact_type=4))
  SET stat = uar_get_meaning_by_codeset(14220,"OTHER",cv_cnt,other_contact_cd)
 ENDIF
 IF (((donate_contact_cd=0.0
  AND (request->donate_contact_type=1)) OR (((recruit_contact_cd=0.0
  AND (request->recruit_contact_type=2)) OR (((counsel_contact_cd=0.0
  AND (request->counsel_contact_type=3)) OR (other_contact_cd=0.0
  AND (request->other_contact_type=4))) )) )) )
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
  IF (donate_contact_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read donate contact type code value"
  ELSEIF (recruit_contact_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read recruit contact type code value"
  ELSEIF (counsel_contact_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read counsel contact type code value"
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read other contact type code value"
  ENDIF
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 IF ((request->donate_contact_type=1))
  SELECT
   IF ((request->date_range=1))
    PLAN (dc
     WHERE (dc.person_id=request->person_id)
      AND dc.contact_type_cd=donate_contact_cd
      AND dc.active_ind=1)
     JOIN (dr
     WHERE (dr.person_id=request->person_id)
      AND dr.contact_id=dc.contact_id
      AND dr.active_ind=1)
     JOIN (c1
     WHERE c1.code_set=14221
      AND dr.outcome_cd=c1.code_value
      AND (((request->donation_successful=1)
      AND c1.cdf_meaning="SUCCESS") OR ((((request->donation_unsuccessful=1)
      AND c1.cdf_meaning="FAILED") OR ((request->donation_deferrals=1)
      AND ((c1.cdf_meaning="TEMPDEF") OR (c1.cdf_meaning="PERMDEF")) )) )) )
     JOIN (de
     WHERE (de.person_id=request->person_id)
      AND de.contact_id=dc.contact_id
      AND de.active_ind=1)
     JOIN (dp
     WHERE dp.donation_results_id=outerjoin(dr.donation_result_id)
      AND dp.active_ind=outerjoin(1))
     JOIN (pr
     WHERE pr.product_id=outerjoin(dp.product_id)
      AND pr.active_ind=outerjoin(1))
     JOIN (bcn
     WHERE bcn.encntr_id=outerjoin(dr.encntr_id)
      AND bcn.person_id=outerjoin(request->person_id)
      AND bcn.active_ind=outerjoin(1))
     JOIN (bdr
     WHERE bdr.person_id=outerjoin(request->person_id)
      AND bdr.eligibility_id=outerjoin(de.eligibility_id)
      AND bdr.active_ind=outerjoin(1))
   ELSE
    PLAN (dc
     WHERE (dc.person_id=request->person_id)
      AND dc.contact_type_cd=donate_contact_cd
      AND dc.active_ind=1)
     JOIN (dr
     WHERE (dr.person_id=request->person_id)
      AND dr.contact_id=dc.contact_id
      AND dr.drawn_dt_tm BETWEEN cnvtdatetime(request->donation_from_date) AND cnvtdatetime(request->
      donation_to_date)
      AND dr.active_ind=1)
     JOIN (c1
     WHERE c1.code_set=14221
      AND dr.outcome_cd=c1.code_value
      AND (((request->donation_successful=1)
      AND c1.cdf_meaning="SUCCESS") OR ((((request->donation_unsuccessful=1)
      AND c1.cdf_meaning="FAILED") OR ((request->donation_deferrals=1)
      AND ((c1.cdf_meaning="TEMPDEF") OR (c1.cdf_meaning="PERMDEF")) )) )) )
     JOIN (de
     WHERE (de.person_id=request->person_id)
      AND de.contact_id=dc.contact_id
      AND de.active_ind=1)
     JOIN (dp
     WHERE dp.donation_results_id=outerjoin(dr.donation_result_id)
      AND dp.active_ind=outerjoin(1))
     JOIN (pr
     WHERE pr.product_id=outerjoin(dp.product_id)
      AND pr.active_ind=outerjoin(1))
     JOIN (bcn
     WHERE bcn.encntr_id=outerjoin(dr.encntr_id)
      AND bcn.person_id=outerjoin(request->person_id)
      AND bcn.active_ind=outerjoin(1))
     JOIN (bdr
     WHERE bdr.person_id=outerjoin(request->person_id)
      AND bdr.eligibility_id=outerjoin(de.eligibility_id)
      AND bdr.active_ind=outerjoin(1))
   ENDIF
   INTO "nl:"
   dc.contact_id
   FROM bbd_donor_contact dc,
    bbd_donation_results dr,
    code_value c1,
    bbd_donor_eligibility de,
    bbd_don_product_r dp,
    product pr,
    bbd_contact_note bcn,
    bbd_deferral_reason bdr
   ORDER BY dc.contact_id
   HEAD REPORT
    count = count
   HEAD dc.contact_id
    IF (dc.contact_id != hold_contact_id)
     hold_contact_id = dc.contact_id, reascount = 0, count = (count+ 1),
     stat = alterlist(reply->qual,count), reply->qual[count].drawn_dt_tm = cnvtdatetime(dr
      .drawn_dt_tm), reply->qual[count].procedure_cd = dr.procedure_cd,
     reply->qual[count].outcome_cd = dr.outcome_cd, reply->qual[count].product_nbr = pr.product_nbr,
     reply->qual[count].product_sub_nbr = pr.product_sub_nbr,
     reply->qual[count].donation_result_id = dr.donation_result_id, reply->qual[count].encntr_id = dr
     .encntr_id, reply->qual[count].contact_type_cd = dc.contact_type_cd
     IF (dc.contact_id > 0)
      reply->qual[count].contact_id = dc.contact_id
     ELSE
      reply->qual[count].contact_id = 0
     ENDIF
     IF (bcn.contact_note_id > 0)
      reply->qual[count].comment_ind = 1
     ELSE
      reply->qual[count].comment_ind = 0
     ENDIF
    ENDIF
   DETAIL
    row + 0
   FOOT  bdr.deferral_reason_id
    IF (bdr.deferral_reason_id > 0.0)
     reascount = (reascount+ 1), stat = alterlist(reply->qual[count].reasonqual,reascount), reply->
     qual[count].reasonqual[reascount].reason_cd = bdr.reason_cd
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->recruit_contact_type=2))
  SELECT
   IF ((request->date_range=1))
    PLAN (dc
     WHERE (dc.person_id=request->person_id)
      AND dc.contact_type_cd=recruit_contact_cd
      AND dc.active_ind=1)
     JOIN (rr
     WHERE (rr.person_id=request->person_id)
      AND rr.contact_id=dc.contact_id
      AND rr.active_ind=1)
     JOIN (bcn
     WHERE bcn.person_id=outerjoin(request->person_id)
      AND bcn.contact_id=outerjoin(dc.contact_id)
      AND bcn.active_ind=outerjoin(1))
     JOIN (bdr
     WHERE bdr.person_id=outerjoin(request->person_id)
      AND bdr.contact_id=outerjoin(dc.contact_id)
      AND bdr.active_ind=outerjoin(1))
   ELSE
    PLAN (dc
     WHERE (dc.person_id=request->person_id)
      AND dc.contact_type_cd=recruit_contact_cd
      AND dc.contact_dt_tm BETWEEN cnvtdatetime(request->donation_from_date) AND cnvtdatetime(request
      ->donation_to_date)
      AND dc.active_ind=1)
     JOIN (rr
     WHERE (rr.person_id=request->person_id)
      AND rr.contact_id=dc.contact_id
      AND rr.active_ind=1)
     JOIN (bcn
     WHERE bcn.person_id=outerjoin(request->person_id)
      AND bcn.contact_id=outerjoin(dc.contact_id)
      AND bcn.active_ind=outerjoin(1))
     JOIN (bdr
     WHERE bdr.person_id=outerjoin(request->person_id)
      AND bdr.contact_id=outerjoin(dc.contact_id)
      AND bdr.active_ind=outerjoin(1))
   ENDIF
   INTO "nl:"
   dc.contact_id
   FROM bbd_donor_contact dc,
    bbd_recruitment_rslts rr,
    bbd_contact_note bcn,
    bbd_deferral_reason bdr
   ORDER BY dc.contact_id
   HEAD REPORT
    count = count
   HEAD dc.contact_id
    IF (dc.contact_id != hold_contact_id)
     hold_contact_id = dc.contact_id, reascount = 0, count = (count+ 1),
     stat = alterlist(reply->qual,count), reply->qual[count].drawn_dt_tm = cnvtdatetime(dc
      .contact_dt_tm), reply->qual[count].procedure_cd = 0,
     reply->qual[count].outcome_cd = dc.contact_outcome_cd, reply->qual[count].contact_type_cd = dc
     .contact_type_cd
     IF (dc.contact_id > 0)
      reply->qual[count].contact_id = dc.contact_id
     ELSE
      reply->qual[count].contact_id = 0
     ENDIF
     IF (bcn.contact_note_id > 0)
      reply->qual[count].comment_ind = 1
     ELSE
      reply->qual[count].comment_ind = 0
     ENDIF
    ENDIF
   DETAIL
    row + 0
   FOOT  bdr.deferral_reason_id
    IF (bdr.deferral_reason_id > 0.0)
     reascount = (reascount+ 1), stat = alterlist(reply->qual[count].reasonqual,reascount), reply->
     qual[count].reasonqual[reascount].reason_cd = bdr.reason_cd
    ENDIF
   WITH counter
  ;end select
 ENDIF
 IF ((request->counsel_contact_type=3))
  SELECT
   IF ((request->date_range=1))
    PLAN (dc
     WHERE (dc.person_id=request->person_id)
      AND dc.contact_type_cd=counsel_contact_cd
      AND dc.active_ind=1)
     JOIN (oc
     WHERE (oc.person_id=request->person_id)
      AND oc.contact_id=dc.contact_id
      AND oc.active_ind=1)
     JOIN (bcn
     WHERE bcn.person_id=outerjoin(request->person_id)
      AND bcn.contact_id=outerjoin(dc.contact_id)
      AND bcn.active_ind=outerjoin(1))
     JOIN (bdr
     WHERE bdr.person_id=outerjoin(request->person_id)
      AND bdr.contact_id=outerjoin(dc.contact_id)
      AND bdr.active_ind=outerjoin(1))
   ELSE
    PLAN (dc
     WHERE (dc.person_id=request->person_id)
      AND dc.contact_type_cd=counsel_contact_cd
      AND dc.contact_dt_tm BETWEEN cnvtdatetime(request->donation_from_date) AND cnvtdatetime(request
      ->donation_to_date)
      AND dc.active_ind=1)
     JOIN (oc
     WHERE (oc.person_id=request->person_id)
      AND oc.contact_id=dc.contact_id
      AND oc.active_ind=1)
     JOIN (bcn
     WHERE bcn.person_id=outerjoin(request->person_id)
      AND bcn.contact_id=outerjoin(dc.contact_id)
      AND bcn.active_ind=outerjoin(1))
     JOIN (bdr
     WHERE bdr.person_id=outerjoin(request->person_id)
      AND bdr.contact_id=outerjoin(dc.contact_id)
      AND bdr.active_ind=outerjoin(1))
   ENDIF
   INTO "nl:"
   dc.contact_id
   FROM bbd_donor_contact dc,
    bbd_other_contact oc,
    bbd_contact_note bcn,
    bbd_deferral_reason bdr
   ORDER BY dc.contact_id
   HEAD REPORT
    count = count
   HEAD dc.contact_id
    IF (dc.contact_id != hold_contact_id)
     hold_contact_id = dc.contact_id, reascount = 0, count = (count+ 1),
     stat = alterlist(reply->qual,count), reply->qual[count].drawn_dt_tm = cnvtdatetime(dc
      .contact_dt_tm), reply->qual[count].procedure_cd = 0,
     reply->qual[count].outcome_cd = dc.contact_outcome_cd, reply->qual[count].contact_type_cd = dc
     .contact_type_cd
     IF (dc.contact_id > 0)
      reply->qual[count].contact_id = dc.contact_id
     ELSE
      reply->qual[count].contact_id = 0
     ENDIF
     IF (bcn.contact_note_id > 0)
      reply->qual[count].comment_ind = 1
     ELSE
      reply->qual[count].comment_ind = 0
     ENDIF
    ENDIF
   DETAIL
    row + 0
   FOOT  bdr.deferral_reason_id
    IF (bdr.deferral_reason_id > 0.0)
     reascount = (reascount+ 1), stat = alterlist(reply->qual[count].reasonqual,reascount), reply->
     qual[count].reasonqual[reascount].reason_cd = bdr.reason_cd
    ENDIF
   WITH counter
  ;end select
 ENDIF
 IF ((request->other_contact_type=4))
  SELECT
   IF ((request->date_range=1))
    PLAN (dc
     WHERE (dc.person_id=request->person_id)
      AND dc.contact_type_cd=other_contact_cd
      AND dc.active_ind=1)
     JOIN (oc
     WHERE (oc.person_id=request->person_id)
      AND oc.contact_id=dc.contact_id
      AND oc.active_ind=1)
     JOIN (bcn
     WHERE bcn.person_id=outerjoin(request->person_id)
      AND bcn.contact_id=outerjoin(dc.contact_id)
      AND bcn.active_ind=outerjoin(1))
     JOIN (bdr
     WHERE bdr.person_id=outerjoin(request->person_id)
      AND bdr.contact_id=outerjoin(dc.contact_id)
      AND bdr.active_ind=outerjoin(1))
   ELSE
    PLAN (dc
     WHERE (dc.person_id=request->person_id)
      AND dc.contact_type_cd=other_contact_cd
      AND dc.contact_dt_tm BETWEEN cnvtdatetime(request->donation_from_date) AND cnvtdatetime(request
      ->donation_to_date)
      AND dc.active_ind=1)
     JOIN (oc
     WHERE (oc.person_id=request->person_id)
      AND oc.contact_id=dc.contact_id
      AND oc.active_ind=1)
     JOIN (bcn
     WHERE bcn.person_id=outerjoin(request->person_id)
      AND bcn.contact_id=outerjoin(dc.contact_id)
      AND bcn.active_ind=outerjoin(1))
     JOIN (bdr
     WHERE bdr.person_id=outerjoin(request->person_id)
      AND bdr.contact_id=outerjoin(dc.contact_id)
      AND bdr.active_ind=outerjoin(1))
   ENDIF
   INTO "nl:"
   dc.contact_id
   FROM bbd_donor_contact dc,
    bbd_other_contact oc,
    bbd_contact_note bcn,
    bbd_deferral_reason bdr
   ORDER BY dc.contact_id
   HEAD REPORT
    count = count
   HEAD dc.contact_id
    IF (dc.contact_id != hold_contact_id)
     hold_contact_id = dc.contact_id, reascount = 0, count = (count+ 1),
     stat = alterlist(reply->qual,count), reply->qual[count].drawn_dt_tm = cnvtdatetime(dc
      .contact_dt_tm), reply->qual[count].procedure_cd = 0,
     reply->qual[count].outcome_cd = dc.contact_outcome_cd, reply->qual[count].contact_type_cd = dc
     .contact_type_cd
     IF (dc.contact_id > 0)
      reply->qual[count].contact_id = dc.contact_id
     ELSE
      reply->qual[count].contact_id = 0
     ENDIF
     IF (bcn.contact_note_id > 0)
      reply->qual[count].comment_ind = 1
     ELSE
      reply->qual[count].comment_ind = 0
     ENDIF
    ENDIF
   DETAIL
    row + 0
   FOOT  bdr.deferral_reason_id
    IF (bdr.deferral_reason_id > 0.0)
     reascount = (reascount+ 1), stat = alterlist(reply->qual[count].reasonqual,reascount), reply->
     qual[count].reasonqual[reascount].reason_cd = bdr.reason_cd
    ENDIF
   WITH counter
  ;end select
 ENDIF
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
