CREATE PROGRAM bmdi_get_cqm_results:dba
 RECORD reply(
   1 bmdi_rawresults[*]
     2 queue_id = f8
     2 creat_dt_tm = dq8
     2 process_status_flag = i2
     2 contributor_refnum = c48
     2 type = c15
     2 lab_type_cd = f8
     2 subtype = c15
     2 result_format_cd = f8
     2 message = vc
     2 message_len = i4
     2 contributor_id = f8
     2 priority = i4
     2 class = c15
     2 subtype_detail = c15
     2 debug_ind = i2
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET sfailed = "S"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM cqm_bmdi_results_que cbq
  WHERE (cbq.queue_id=request->queue_id)
  ORDER BY cbq.queue_id
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->bmdi_rawresults,cnt), reply->bmdi_rawresults[cnt].queue_id
    = cbq.queue_id,
   reply->bmdi_rawresults[cnt].creat_dt_tm = cbq.create_dt_tm, reply->bmdi_rawresults[cnt].message =
   cbq.message, reply->bmdi_rawresults[cnt].message_len = cbq.message_len,
   reply->bmdi_rawresults[cnt].process_status_flag = cbq.process_status_flag, reply->bmdi_rawresults[
   cnt].contributor_refnum = cbq.contributor_refnum, reply->bmdi_rawresults[cnt].type = cbq.type,
   reply->bmdi_rawresults[cnt].lab_type_cd = uar_get_code_by("MEANING",31520,nullterm(cnvtupper(trim(
       cbq.type)))), reply->bmdi_rawresults[cnt].subtype = cbq.subtype, reply->bmdi_rawresults[cnt].
   result_format_cd = uar_get_code_by("MEANING",359575,nullterm(cnvtupper(trim(cbq.subtype)))),
   reply->bmdi_rawresults[cnt].active_ind = cbq.active_ind
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  SET sfailed = "T"
  IF (ierrcode > 0)
   SET stat = alter(reply->status_data.subeventstatus,2)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Data Retrieval failed!"
  ELSE
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "No data matching request"
  ENDIF
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_cqm_results"
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[2].operationname = "SELECT"
   SET reply->status_data.subeventstatus[2].operationstatus = "F"
   SET reply->status_data.subeventstatus[2].targetobjectname = "bmdi_get_cqm_results"
   SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  ENDIF
  GO TO exit_script
 ENDIF
 GO TO exit_script
#no_valid_ids
 IF (sfailed="I")
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "Check Request"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_cqm_results"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No valid identifier in request"
  GO TO exit_script
 ENDIF
#exit_script
 IF (sfailed="T")
  IF (ierrcode > 0)
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSEIF (sfailed="I")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
