CREATE PROGRAM bbd_get_lock_on_person_donor:dba
 RECORD reply(
   1 qual[*]
     2 reply = i2
     2 locked_by = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET pending_cd = 0.0
 SET stat = 0
 SET number_in = size(request->qual,5)
 SET stat = alterlist(reply->qual,value(number_in))
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_cnt = 0
 SET code_set = 14224
 SET cdf_meaning = "PENDING"
 SET code_cnt = 1
 SET status = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,pending_cd)
 SELECT DISTINCT INTO "nl:"
  dc.contact_status_cd, pd.lock_ind, pd.updt_id,
  pe.name_full_formatted
  FROM bbd_donor_contact dc,
   person_donor pd,
   prsnl pe,
   (dummyt d1  WITH seq = value(number_in)),
   (dummyt d2  WITH seq = 1)
  PLAN (d1)
   JOIN (pd
   WHERE (pd.person_id=request->qual[d1.seq].person_id))
   JOIN (dc
   WHERE dc.active_ind=1
    AND (dc.contact_id=request->qual[d1.seq].contact_id))
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (pe
   WHERE pe.person_id=pd.updt_id)
  ORDER BY dc.contact_dt_tm, dc.contact_id, 0
  DETAIL
   reply->qual[d1.seq].reply = pd.lock_ind, reply->qual[d1.seq].locked_by = pe.name_full_formatted
   IF (dc.contact_status_cd != pending_cd)
    reply->qual[d1.seq].reply = 2
   ENDIF
  WITH nocounter, outerjoin(d2)
 ;end select
 SET reply->status_data.status = "S"
END GO
