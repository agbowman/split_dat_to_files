CREATE PROGRAM bbd_get_don_elig_dt:dba
 RECORD reply(
   1 success = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET nbr_days = 0
 SET reply->success = 1
 SELECT INTO "nl:"
  p.days_until_eligible, d.drawn_dt_tm
  FROM bbd_donation_results d,
   procedure_eligibility_r p,
   procedure_outcome_r r
  PLAN (d
   WHERE (d.person_id=request->person_id)
    AND d.active_ind=1)
   JOIN (p
   WHERE (p.procedure_cd=request->procedure_cd)
    AND p.prev_procedure_cd=d.procedure_cd)
   JOIN (r
   WHERE r.procedure_cd=d.procedure_cd
    AND r.outcome_cd=d.outcome_cd)
  DETAIL
   nbr_days = datetimediff(request->registration_dt,d.drawn_dt_tm), nbr_days = floor(nbr_days)
   IF (p.days_until_eligible > nbr_days
    AND r.count_as_donation_ind=1)
    reply->success = 0
   ENDIF
  WITH nocounter
 ;end select
#end_script
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
