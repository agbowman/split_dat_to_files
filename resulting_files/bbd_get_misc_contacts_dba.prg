CREATE PROGRAM bbd_get_misc_contacts:dba
 RECORD reply(
   1 contact_dt_tm = dq8
   1 outcome_cd = f8
   1 contact_prsnl_id = f8
   1 method_cd = f8
   1 other_contact_updt_cnt = i4
   1 donor_contact_updt_cnt = i4
   1 eligibility_id = f8
   1 eligibility_updt_cnt = i4
   1 qual[*]
     2 deferral_reason_id = f8
     2 updt_cnt = i4
     2 reason_cd = f8
     2 reason_cd_disp = c40
     2 reason_cd_mean = c12
     2 eligible_dt_tm = di8
     2 occurred_dt_tm = di8
     2 calc_elig_dt_tm = di8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->qual,0)
 SET count = 0
 SELECT INTO "nl:"
  dc.contact_id, dc.*
  FROM bbd_donor_contact dc,
   bbd_other_contact oc,
   bbd_donor_eligibility de,
   (dummyt d1  WITH seq = 1),
   bbd_deferral_reason dr,
   (dummyt d2  WITH seq = 1)
  PLAN (dc
   WHERE (dc.contact_id=request->contact_id)
    AND dc.active_ind=1)
   JOIN (oc
   WHERE oc.contact_id=dc.contact_id
    AND oc.active_ind=1)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (de
   WHERE de.contact_id=dc.contact_id
    AND de.active_ind=1)
   JOIN (d2
   WHERE d1.seq=1)
   JOIN (dr
   WHERE dr.eligibility_id=de.eligibility_id
    AND dr.active_ind=1)
  ORDER BY dc.contact_id, 0
  HEAD dc.contact_id
   reply->contact_dt_tm = oc.contact_dt_tm, reply->outcome_cd = oc.outcome_cd, reply->method_cd = oc
   .method_cd,
   reply->contact_prsnl_id = oc.contact_prsnl_id, reply->other_contact_updt_cnt = oc.updt_cnt, reply
   ->donor_contact_updt_cnt = dc.updt_cnt,
   reply->eligibility_id = de.eligibility_id, reply->eligibility_updt_cnt = de.updt_cnt
  DETAIL
   IF (dr.deferral_reason_id > 0)
    count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].deferral_reason_id =
    dr.deferral_reason_id,
    reply->qual[count].updt_cnt = dr.updt_cnt, reply->qual[count].reason_cd = dr.reason_cd, reply->
    qual[count].eligible_dt_tm = dr.eligible_dt_tm,
    reply->qual[count].occurred_dt_tm = dr.occurred_dt_tm, reply->qual[count].calc_elig_dt_tm = dr
    .calc_elig_dt_tm
   ENDIF
  WITH nocounter, outerjoin(d1), outerjoin(d2)
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_get_misc_contact.prg"
  SET reply->status_data.subeventstatus[1].operationname = "get"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_other_contact"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "unable to retrieve bbd_other_contact table fields"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 0
 ENDIF
#exit_script
END GO
