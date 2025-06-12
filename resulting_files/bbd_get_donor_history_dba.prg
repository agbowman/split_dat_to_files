CREATE PROGRAM bbd_get_donor_history:dba
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
 SET donation_contact_cd = 0.0
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14220,"DONATE",cv_cnt,donation_contact_cd)
 SELECT
  IF ((request->date_range=1))
   PLAN (dr
    WHERE (dr.person_id=request->person_id)
     AND dr.active_ind=1)
    JOIN (c1
    WHERE c1.code_set=14221
     AND dr.outcome_cd=c1.code_value
     AND (((request->donation_successful=1)
     AND c1.cdf_meaning="SUCCESS") OR ((((request->donation_unsuccessful=1)
     AND c1.cdf_meaning="FAILED") OR ((request->donation_deferrals=1)
     AND ((c1.cdf_meaning="TEMPDEF") OR (c1.cdf_meaning="PERMDEF")) )) )) )
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (dp
    WHERE dr.donation_result_id=dp.donation_results_id
     AND dp.active_ind=1)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (pr
    WHERE dp.product_id=pr.product_id
     AND pr.active_ind=1)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (bcn
    WHERE bcn.encntr_id=dr.encntr_id
     AND (bcn.person_id=request->person_id)
     AND bcn.active_ind=1)
  ELSE
   PLAN (dr
    WHERE (dr.person_id=request->person_id)
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
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (dp
    WHERE dr.donation_result_id=dp.donation_results_id
     AND dp.active_ind=1)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (pr
    WHERE dp.product_id=pr.product_id
     AND pr.active_ind=1)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (bcn
    WHERE bcn.encntr_id=dr.encntr_id
     AND (bcn.person_id=request->person_id)
     AND bcn.active_ind=1)
  ENDIF
  INTO "nl:"
  dr.donation_result_id, dr.drawn_dt_tm, dr.procedure_cd,
  dr.outcome_cd, pr.product_nbr, pr.product_sub_nbr,
  dr.encntr_id, dr.contact_id
  FROM bbd_donation_results dr,
   code_value c1,
   (dummyt d1  WITH seq = 1),
   bbd_don_product_r dp,
   (dummyt d2  WITH seq = 1),
   bbd_contact_note bcn,
   (dummyt d3  WITH seq = 1),
   product pr
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].drawn_dt_tm =
   cnvtdatetime(dr.drawn_dt_tm),
   reply->qual[count].procedure_cd = dr.procedure_cd, reply->qual[count].outcome_cd = dr.outcome_cd,
   reply->qual[count].product_nbr = pr.product_nbr,
   reply->qual[count].product_sub_nbr = pr.product_sub_nbr, reply->qual[count].donation_result_id =
   dr.donation_result_id, reply->qual[count].encntr_id = dr.encntr_id
   IF (dr.contact_id > 0)
    reply->qual[count].contact_id = dr.contact_id
   ELSE
    reply->qual[count].contact_id = 0
   ENDIF
   IF (bcn.contact_note_id > 0)
    reply->qual[count].comment_ind = 1
   ELSE
    reply->qual[count].comment_ind = 0
   ENDIF
  WITH counter, outerjoin(d1), outerjoin(d2),
   outerjoin(d3)
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
