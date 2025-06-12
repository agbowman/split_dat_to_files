CREATE PROGRAM bmdi_add_acquired_result:dba
 RECORD reply(
   1 result_list[*]
     2 result_id = f8
     2 device_id = f8
     2 monitored_device_id = f8
     2 device_parameter_id = f8
     2 nomenclature_id = f8
     2 person_id = f8
     2 parent_entity_id = f8
     2 parent_entity_name = c32
     2 clinical_dt_tm = dq8
     2 acquired_dt_tm = dq8
     2 result_val = c50
     2 lab_type_cd = f8
     2 result_format_cd = f8
     2 verified_dt_tm = dq8
     2 verified_ind = i2
     2 statusinsert = i2
     2 ierrnum = i2
     2 serrmsg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET serrmsg = fillstring(132," ")
 SET reply->status_data.status = "F"
 SET failure = "F"
 SET n = 0
 SET req_size = size(request->result_list,5)
 INSERT  FROM bmdi_acquired_results bar,
   (dummyt d  WITH seq = value(req_size))
  SET bar.result_id = request->result_list[d.seq].result_id, bar.device_id = request->result_list[d
   .seq].device_id, bar.acquired_dt_tm = cnvtdatetime(request->result_list[d.seq].acquired_dt_tm),
   bar.clinical_dt_tm = cnvtdatetime(request->result_list[d.seq].clinical_dt_tm), bar.person_id =
   request->result_list[d.seq].person_id, bar.monitored_device_id = request->result_list[d.seq].
   monitored_device_id,
   bar.device_parameter_id = request->result_list[d.seq].device_parameter_id, bar.nomenclature_id =
   request->result_list[d.seq].nomenclature_id, bar.parent_entity_id = request->result_list[d.seq].
   parent_entity_id,
   bar.parent_entity_name = request->result_list[d.seq].parent_entity_name, bar.verified_ind =
   request->result_list[d.seq].verified_ind, bar.verified_dt_tm = cnvtdatetime(request->result_list[d
    .seq].verified_dt_tm),
   bar.lab_type_cd = request->result_list[d.seq].lab_type_cd, bar.result_format_cd = request->
   result_list[d.seq].result_format_cd, bar.result_val = trim(request->result_list[d.seq].result_val,
    3),
   bar.updt_dt_tm = cnvtdatetime(curdate,curtime3), bar.updt_cnt = 0, bar.updt_id = reqinfo->updt_id,
   bar.updt_task = reqinfo->updt_task, bar.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (bar)
  WITH status(request->result_list[d.seq].statusinsert,request->result_list[d.seq].ierrnum,request->
   result_list[d.seq].serrmsg)
 ;end insert
 CALL echo(build("curqual = ",curqual))
 IF (curqual=req_size)
  SET reply->status_data.status = "S"
 ENDIF
 IF (curqual < req_size)
  SET stat = alterlist(reply->result_list,(req_size - curqual))
  DECLARE q = i4 WITH noconstant(0)
  DECLARE n = i4 WITH noconstant(0)
  FOR (n = 1 TO req_size)
    IF ((request->result_list[n].statusinsert=0))
     SET q = (q+ 1)
     SET reply->result_list[q].result_id = request->result_list[n].result_id
     SET reply->result_list[q].device_id = request->result_list[n].device_id
     SET reply->result_list[q].acquired_dt_tm = request->result_list[n].acquired_dt_tm
     SET reply->result_list[q].clinical_dt_tm = request->result_list[n].clinical_dt_tm
     SET reply->result_list[q].person_id = request->result_list[n].person_id
     SET reply->result_list[q].monitored_device_id = request->result_list[n].monitored_device_id
     SET reply->result_list[q].device_parameter_id = request->result_list[n].device_parameter_id
     SET reply->result_list[q].nomenclature_id = request->result_list[n].nomenclature_id
     SET reply->result_list[q].parent_entity_id = request->result_list[n].parent_entity_id
     SET reply->result_list[q].parent_entity_name = request->result_list[n].parent_entity_name
     SET reply->result_list[q].verified_ind = request->result_list[n].verified_ind
     SET reply->result_list[q].lab_type_cd = request->result_list[n].lab_type_cd
     SET reply->result_list[q].result_format_cd = request->result_list[n].result_format_cd
     SET reply->result_list[q].result_val = request->result_list[n].result_val
     SET reply->result_list[q].verified_dt_tm = request->result_list[n].verified_dt_tm
     SET reply->result_list[q].statusinsert = request->result_list[n].statusinsert
     SET reply->result_list[q].ierrnum = request->result_list[n].ierrnum
     SET reply->result_list[q].serrmsg = request->result_list[n].serrmsg
    ENDIF
  ENDFOR
  IF (curqual >= 1)
   SET reply->status_data.status = "S"
   SET ierrcode = error(serrmsg,1)
   SET failure = "P"
   GO TO get_data_partialsuccess
  ELSEIF (curqual=0)
   SET reply->status_data.status = "F"
   SET ierrcode = error(serrmsg,1)
   SET failure = "T"
   GO TO get_data_failure
  ENDIF
 ENDIF
#get_data_partialsuccess
 IF (failure="P")
  IF (ierrcode > 0)
   SET stat = alter(reply->status_data.subeventstatus,2)
  ELSE
   SET stat = alter(reply->status_data.subeventstatus,1)
  ENDIF
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "P"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_add_acquired_result"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Data Addition Partial Success!"
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[2].operationname = "INSERT"
   SET reply->status_data.subeventstatus[2].operationstatus = "P"
   SET reply->status_data.subeventstatus[2].targetobjectname = "bmdi_add_acquired_result"
   SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  ENDIF
  GO TO exit_script
 ENDIF
#get_data_failure
 IF (failure="T")
  IF (ierrcode > 0)
   SET stat = alter(reply->status_data.subeventstatus,2)
  ELSE
   SET stat = alter(reply->status_data.subeventstatus,1)
  ENDIF
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_add_acquired_result"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Data Addition failed!"
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[2].operationname = "INSERT"
   SET reply->status_data.subeventstatus[2].operationstatus = "F"
   SET reply->status_data.subeventstatus[2].targetobjectname = "bmdi_add_acquired_result"
   SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  ENDIF
  GO TO exit_script
 ENDIF
#exit_script
 IF (failure="T")
  IF (ierrcode > 0)
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
  SET stat = alterlist(reply->result_list,0)
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
