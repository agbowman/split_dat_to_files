CREATE PROGRAM bbd_get_donor_eligibility:dba
 RECORD reply(
   1 eligibility_id = f8
   1 eligibility_type_cd = f8
   1 eligibility_type_cd_disp = c40
   1 eligibility_type_cd_mean = c12
   1 eligible_dt_tm = dq8
   1 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  d.*
  FROM bbd_donor_eligibility d
  PLAN (d
   WHERE (d.person_id=request->person_id)
    AND (d.encntr_id=request->encntr_id)
    AND (d.contact_id=request->contact_id)
    AND d.active_ind=1)
  DETAIL
   reply->eligibility_id = d.eligibility_id, reply->eligibility_type_cd = d.eligibility_type_cd,
   reply->eligible_dt_tm = d.eligible_dt_tm,
   reply->updt_cnt = d.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  GO TO exitscript
 ENDIF
#exitscript
END GO
