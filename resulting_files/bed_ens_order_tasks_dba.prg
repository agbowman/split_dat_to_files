CREATE PROGRAM bed_ens_order_tasks:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp_orders
 RECORD temp_orders(
   1 orderables[*]
     2 catalog_code_value = f8
     2 new_task_description = vc
     2 old_task_description = vc
     2 reference_task_id = f8
 )
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET req_cnt = size(request->orderables,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET totaltemp = 0
 SELECT INTO "nl:"
  FROM order_task_xref x,
   order_task t,
   (dummyt d  WITH seq = value(req_cnt))
  PLAN (d)
   JOIN (x
   WHERE (x.catalog_cd=request->orderables[d.seq].catalog_code_value))
   JOIN (t
   WHERE t.reference_task_id=x.reference_task_id
    AND (t.task_description=request->orderables[d.seq].old_task_description))
  DETAIL
   totaltemp = (totaltemp+ 1), stat = alterlist(temp_orders->orderables,totaltemp), temp_orders->
   orderables[totaltemp].new_task_description = request->orderables[d.seq].new_task_description,
   temp_orders->orderables[totaltemp].old_task_description = request->orderables[d.seq].
   old_task_description, temp_orders->orderables[totaltemp].catalog_code_value = request->orderables[
   d.seq].catalog_code_value, temp_orders->orderables[totaltemp].reference_task_id = x
   .reference_task_id
  WITH nocounter
 ;end select
 UPDATE  FROM order_task o,
   (dummyt d  WITH seq = value(req_cnt))
  SET o.task_description = temp_orders->orderables[d.seq].new_task_description, o
   .task_description_key = cnvtupper(temp_orders->orderables[d.seq].new_task_description), o.updt_id
    = reqinfo->updt_id,
   o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_task = reqinfo->updt_task, o.updt_applctx =
   reqinfo->updt_applctx,
   o.updt_cnt = (o.updt_cnt+ 1)
  PLAN (d)
   JOIN (o
   WHERE (o.reference_task_id=temp_orders->orderables[d.seq].reference_task_id))
  WITH nocounter
 ;end update
 SET parent_code_value = uar_get_code_by("MEANING",13016,"ORD CAT")
 SET task_code_value = uar_get_code_by("MEANING",13016,"TASKCAT")
 UPDATE  FROM bill_item bi,
   (dummyt d  WITH seq = value(req_cnt))
  SET bi.ext_description = temp_orders->orderables[d.seq].new_task_description, bi.ext_short_desc =
   substring(0,50,temp_orders->orderables[d.seq].new_task_description), bi.updt_cnt = (bi.updt_cnt+ 1
   ),
   bi.updt_id = reqinfo->updt_id, bi.updt_dt_tm = cnvtdatetime(curdate,curtime), bi.updt_task =
   reqinfo->updt_task,
   bi.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (bi
   WHERE (bi.ext_parent_reference_id=temp_orders->orderables[d.seq].catalog_code_value)
    AND bi.ext_parent_entity_name="CODE_VALUE"
    AND bi.ext_parent_contributor_cd=parent_code_value)
  WITH nocounter
 ;end update
 UPDATE  FROM bill_item bi,
   (dummyt d  WITH seq = value(req_cnt))
  SET bi.ext_description = temp_orders->orderables[d.seq].new_task_description, bi.ext_short_desc =
   cnvtupper(substring(0,50,temp_orders->orderables[d.seq].new_task_description)), bi.updt_cnt = (bi
   .updt_cnt+ 1),
   bi.updt_id = reqinfo->updt_id, bi.updt_dt_tm = cnvtdatetime(curdate,curtime), bi.updt_task =
   reqinfo->updt_task,
   bi.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (bi
   WHERE (bi.ext_parent_reference_id=temp_orders->orderables[d.seq].reference_task_id)
    AND bi.ext_parent_entity_name="CODE_VALUE"
    AND bi.ext_parent_contributor_cd=task_code_value)
  WITH nocounter
 ;end update
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
