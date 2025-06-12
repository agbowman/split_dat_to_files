CREATE PROGRAM bed_copy_org_info:dba
 FREE SET values_to_copy
 RECORD values_to_copy(
   1 value[*]
     2 chartable_ind = i2
     2 contributor_system_code = f8
     2 info_sub_type_code = f8
     2 info_type_code = f8
     2 long_text_id = f8
     2 value_code = f8
     2 value_numeric = i4
 )
 FREE SET copy_request
 RECORD copy_request(
   1 value[*]
     2 org_id = f8
     2 chartable_ind = i2
     2 contributor_system_code = f8
     2 info_sub_type_code = f8
     2 info_type_code = f8
     2 long_text_id = f8
     2 value_code = f8
     2 value_numeric = i4
 )
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET req_cnt = size(request->copy_to,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 UPDATE  FROM org_info o,
   (dummyt d  WITH seq = value(req_cnt))
  SET o.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o
   .updt_dt_tm = cnvtdatetime(curdate,curtime),
   o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = (o.updt_cnt
   + 1)
  PLAN (d)
   JOIN (o
   WHERE (o.organization_id=request->copy_to[d.seq].code)
    AND (o.info_type_cd=request->info_type_code)
    AND o.active_ind=1
    AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Update org info table"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET total_cnt = 0
 SELECT INTO "nl:"
  FROM org_info o
  WHERE (o.organization_id=request->copy_from_code)
   AND (o.info_type_cd=request->info_type_code)
   AND o.active_ind=1
   AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND o.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  HEAD REPORT
   cnt = 0, total_cnt = 0, stat = alterlist(values_to_copy->value,100)
  DETAIL
   cnt = (cnt+ 1), total_cnt = (total_cnt+ 1)
   IF (cnt > 100)
    cnt = 1, stat = alterlist(values_to_copy->value,(total_cnt+ 100))
   ENDIF
   values_to_copy->value[total_cnt].chartable_ind = o.chartable_ind, values_to_copy->value[total_cnt]
   .info_sub_type_code = o.info_sub_type_cd, values_to_copy->value[total_cnt].info_type_code = o
   .info_type_cd,
   values_to_copy->value[total_cnt].long_text_id = o.long_text_id, values_to_copy->value[total_cnt].
   value_code = o.value_cd, values_to_copy->value[total_cnt].value_numeric = o.value_numeric
  FOOT REPORT
   stat = alterlist(values_to_copy->value,total_cnt)
  WITH nocounter
 ;end select
 IF (total_cnt=0)
  GO TO exit_script
 ENDIF
 SET request_size = (req_cnt * total_cnt)
 SET stat = alterlist(copy_request->value,request_size)
 SET copy_cnt = 0
 FOR (x = 1 TO req_cnt)
   FOR (y = 1 TO total_cnt)
     SET copy_cnt = (copy_cnt+ 1)
     SET copy_request->value[copy_cnt].org_id = request->copy_to[x].code
     SET copy_request->value[copy_cnt].chartable_ind = values_to_copy->value[y].chartable_ind
     SET copy_request->value[copy_cnt].contributor_system_code = values_to_copy->value[y].
     contributor_system_code
     SET copy_request->value[copy_cnt].info_sub_type_code = values_to_copy->value[y].
     info_sub_type_code
     SET copy_request->value[copy_cnt].info_type_code = values_to_copy->value[y].info_type_code
     SET copy_request->value[copy_cnt].long_text_id = values_to_copy->value[y].long_text_id
     SET copy_request->value[copy_cnt].value_code = values_to_copy->value[y].value_code
     SET copy_request->value[copy_cnt].value_numeric = values_to_copy->value[y].value_numeric
   ENDFOR
 ENDFOR
 SET active_code = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=48
   AND c.cdf_meaning="ACTIVE"
  DETAIL
   active_code = c.code_value
  WITH nocounter
 ;end select
 INSERT  FROM org_info o,
   (dummyt d  WITH seq = value(copy_cnt))
  SET o.org_info_id = seq(organization_seq,nextval), o.active_ind = 1, o.active_status_cd =
   active_code,
   o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
   updt_id, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   o.chartable_ind = copy_request->value[d.seq].chartable_ind, o.contributor_system_cd = copy_request
   ->value[d.seq].contributor_system_code, o.end_effective_dt_tm = cnvtdatetime(
    "31-dec-2100 00:00:00.00"),
   o.info_sub_type_cd = copy_request->value[d.seq].info_sub_type_code, o.info_type_cd = copy_request
   ->value[d.seq].info_type_code, o.long_text_id = copy_request->value[d.seq].long_text_id,
   o.organization_id = copy_request->value[d.seq].org_id, o.updt_applctx = reqinfo->updt_applctx, o
   .updt_cnt = 0,
   o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_id = reqinfo->updt_id, o.updt_task = reqinfo
   ->updt_task,
   o.value_cd = copy_request->value[d.seq].value_code, o.value_dt_tm = cnvtdatetime(curdate,curtime),
   o.value_numeric = copy_request->value[d.seq].value_numeric
  PLAN (d)
   JOIN (o)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Insert org info table"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
