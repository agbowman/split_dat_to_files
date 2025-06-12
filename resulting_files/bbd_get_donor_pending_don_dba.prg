CREATE PROGRAM bbd_get_donor_pending_don:dba
 RECORD reply(
   1 contact_dt_tm = dq8
   1 procedure_cd = f8
   1 owner_area_cd = f8
   1 inventory_area_cd = f8
   1 encntr_id = f8
   1 contact_id = f8
   1 encntr_person_reltn_id = f8
   1 person_reltn_type_cd = f8
   1 qual[*]
     2 exception_id = f8
     2 exception_type_mean = c12
     2 updt_cnt = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET donate_cd = 0.0
 SET pending_cd = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14220,"DONATE",code_cnt,code_value)
 IF (code_value=0)
  SET failed = "T"
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "retrieve"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get__meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "unable to retrieve code value for 14420 and DONATE"
  GO TO exit_script
 ENDIF
 SET donate_cd = code_value
 SET code_value = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14224,"PENDING",code_cnt,code_value)
 IF (code_value=0)
  SET failed = "T"
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "retrieve"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get__meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "unable to retrieve code value for 14224 and PENDING"
  GO TO exit_script
 ENDIF
 SET pending_cd = code_value
 SET index = 1
 SELECT DISTINCT INTO "nl:"
  dc.contact_dt_tm, dc.encntr_id, e.bbd_procedure_cd,
  bb.exception_id, bb.updt_cnt, exception_type_mean = uar_get_code_meaning(bb.exception_type_cd)
  FROM bbd_donor_contact dc,
   encounter e,
   (dummyt d1  WITH seq = 1),
   encntr_person_reltn epr,
   dummyt d2,
   bb_exception bb
  PLAN (dc
   WHERE (dc.person_id=request->person_id)
    AND dc.active_ind=1
    AND dc.contact_type_cd=donate_cd
    AND dc.contact_status_cd=pending_cd)
   JOIN (e
   WHERE e.encntr_id=dc.encntr_id
    AND e.active_ind=1)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (((epr
   WHERE epr.encntr_id=dc.encntr_id)
   ) ORJOIN ((d2)
   JOIN (bb
   WHERE bb.person_id=dc.person_id
    AND bb.donor_contact_id=dc.contact_id
    AND bb.active_ind=1)
   ))
  ORDER BY dc.person_id, 0
  HEAD dc.person_id
   reply->contact_dt_tm = dc.contact_dt_tm, reply->procedure_cd = e.bbd_procedure_cd, reply->
   owner_area_cd = dc.owner_area_cd,
   reply->inventory_area_cd = dc.inventory_area_cd, reply->encntr_id = e.encntr_id, reply->contact_id
    = dc.contact_id,
   reply->encntr_person_reltn_id = epr.encntr_person_reltn_id, reply->person_reltn_type_cd = epr
   .person_reltn_type_cd
  DETAIL
   stat = alterlist(reply->qual,index), reply->qual[index].exception_id = bb.exception_id, reply->
   qual[index].exception_type_mean = exception_type_mean,
   reply->qual[index].updt_cnt = bb.updt_cnt, index = (index+ 1)
  WITH nocounter, outerjoin(d1)
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSEIF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
#exit_script
END GO
