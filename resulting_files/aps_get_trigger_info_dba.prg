CREATE PROGRAM aps_get_trigger_info:dba
 RECORD reply(
   1 valid_from_dt_tm = dq8
   1 event_cd = f8
   1 result_status_cd = f8
   1 contributor_system_cd = f8
   1 reference_nbr = vc
   1 parent_event_id = f8
   1 prsnl_qual[*]
     2 event_prsnl_id = f8
     2 action_prsnl_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET deleted_status_cd = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(10," ")
 SET cnt = 0
 SET code_set = 48
 SET code_value = 0.0
 SET cdf_meaning = "DELETED"
 EXECUTE cpm_get_cd_for_cdf
 SET deleted_status_cd = code_value
 SELECT INTO mine
  ce.event_id, cep_exists = decode(cep.seq,"Y","N")
  FROM clinical_event ce,
   ce_event_prsnl cep,
   (dummyt d1  WITH seq = 1)
  PLAN (ce
   WHERE ce.event_id != 0
    AND (ce.event_id=request->event_id)
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ce.record_status_cd != deleted_status_cd)
   JOIN (d1)
   JOIN (cep
   WHERE ce.event_id=cep.event_id)
  HEAD REPORT
   cnt = 0, reply->valid_from_dt_tm = ce.valid_from_dt_tm, reply->event_cd = ce.event_cd,
   reply->result_status_cd = ce.result_status_cd, reply->contributor_system_cd = ce
   .contributor_system_cd, reply->reference_nbr = ce.reference_nbr,
   reply->parent_event_id = ce.parent_event_id
  DETAIL
   IF (cep_exists="Y")
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->prsnl_qual,(cnt+ 9))
    ENDIF
    reply->prsnl_qual[cnt].event_prsnl_id = cep.event_prsnl_id, reply->prsnl_qual[cnt].
    action_prsnl_id = cep.action_prsnl_id
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->prsnl_qual,cnt)
  WITH nocounter, outerjoin = d1
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CLINICAL_EVENT"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
