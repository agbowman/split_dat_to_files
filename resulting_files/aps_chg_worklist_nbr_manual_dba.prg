CREATE PROGRAM aps_chg_worklist_nbr_manual:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 exception_reason = c4
   1 new_worklist_nbr = i4
 )
 RECORD temp(
   1 new_worklist_cd = f8
   1 proc_qual[5]
     2 processing_task_id = f8
   1 qual[1]
     2 service_resource_cd = f8
 )
 SET var_field_name = "Processing Run Number"
 SET var_field_type = 1
 SET var_field_value = 1
 SET var_updt_cnt = 0
#script
 SET reply->status_data.status = "F"
 SET error_cnt = 0
 SET build_pt_select = fillstring(500," ")
 SET build_pc_select = fillstring(500," ")
 SET qual_cntr = 0
 SELECT INTO "nl:"
  pt.worklist_nbr, pt.processing_task_id
  FROM processing_task pt,
   (dummyt d1  WITH seq = value(size(request->qual,5)))
  PLAN (d1)
   JOIN (pt
   WHERE (request->qual[d1.seq].processing_task_id=pt.processing_task_id))
  HEAD REPORT
   qual_cntr = 0
  DETAIL
   qual_cntr = (qual_cntr+ 1)
   IF (mod(qual_cntr,5)=1
    AND qual_cntr != 1)
    stat = alter(temp->proc_qual,(qual_cntr+ 5))
   ENDIF
   temp->proc_qual[qual_cntr].processing_task_id = pt.processing_task_id
  FOOT REPORT
   stat = alter(temp->proc_qual,qual_cntr)
  WITH nocounter
 ;end select
 IF (qual_cntr=0)
  SET reply->exception_reason = "NONE"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 SET failed = "F"
 SELECT INTO "nl:"
  cve.*
  FROM code_value cv,
   code_value_extension cve
  PLAN (cv
   WHERE cv.code_set=1308
    AND cv.cdf_meaning="PROCESSING")
   JOIN (cve
   WHERE cv.code_value=cve.code_value)
  HEAD REPORT
   temp->new_worklist_cd = cve.code_value
  DETAIL
   var_field_name = cve.field_name, var_field_type = cve.field_type, var_field_value = cnvtint(cve
    .field_value),
   var_field_value = (cnvtint(var_field_value)+ 1), var_updt_cnt = cve.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO generate_new_number
 ELSE
  GO TO update_with_new_number
 ENDIF
#generate_new_number
 SET reply->status_data.status = "F"
 SET next_code = 0.0
 EXECUTE cpm_next_code
 INSERT  FROM code_value c
  SET c.code_value = next_code, c.code_set = 1308, c.cdf_meaning = "PROCESSING",
   c.display = "Processing Task Worklist Number", c.display_key = cnvtupper(cnvtalphanum(
     "Processing Task Worklist Number")), c.description = "Processing Task Worklist Number",
   c.definition = "Processing Task Worklist Number", c.active_ind = 1, c.active_dt_tm = cnvtdatetime(
    curdate,curtime),
   c.active_type_cd = reqdata->active_status_cd, c.updt_dt_tm = cnvtdatetime(curdate,curtime), c
   .updt_id = reqinfo->updt_id,
   c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual != 1)
  CALL handle_errors("INSERT","F","TABLE","CODE_VALUE")
  SET reply->status_data.status = "F"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET number_of_ext = 1
 INSERT  FROM code_value_extension cve
  SET cve.code_set = 1308, cve.code_value = next_code, cve.field_name = var_field_name,
   cve.field_type = var_field_type, cve.field_value = cnvtstring(var_field_value), cve.updt_cnt = 0,
   cve.updt_id = reqinfo->updt_id, cve.updt_task = reqinfo->updt_task, cve.updt_applctx = reqinfo->
   updt_applctx,
   cve.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (cve)
 ;end insert
 IF (curqual != number_of_ext)
  IF (curqual=0)
   CALL handle_errors("insrt","f","table","code_value_exten")
  ELSE
   CALL handle_errors("insert","z","table","code_value_exten")
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
  GO TO populate_pt_table
 ENDIF
#update_with_new_number
 SET reply->status_data.status = "F"
 SET updt_cnt = 0
 SET cur_updt_cnt[1] = 0
 SELECT INTO "nl:"
  FROM code_value_extension cve
  WHERE (cve.code_value=temp->new_worklist_cd)
   AND cve.field_name=var_field_name
   AND cve.code_set=1308
  HEAD REPORT
   updt_cnt = 0
  DETAIL
   updt_cnt = (updt_cnt+ 1), cur_updt_cnt[updt_cnt] = cve.updt_cnt
  WITH nocounter, forupdate(cve)
 ;end select
 IF (updt_cnt != 1)
  SET failed = "T"
  CALL handle_errors("LOCK","F","TABLE","CODE_VALUE_EXTENSION")
  GO TO exit_script
 ENDIF
 UPDATE  FROM code_value_extension cve
  SET cve.field_value = cnvtstring(var_field_value), cve.updt_cnt = (cve.updt_cnt+ 1), cve.updt_dt_tm
    = cnvtdatetime(curdate,curtime),
   cve.updt_id = reqinfo->updt_id, cve.updt_task = reqinfo->updt_task, cve.updt_applctx = reqinfo->
   updt_applctx
  WHERE (cve.code_value=temp->new_worklist_cd)
   AND cve.field_name=var_field_name
   AND cve.code_set=1308
  WITH nocounter
 ;end update
 IF (curqual != 1)
  SET failed = "T"
  CALL handle_errors("UPDATE","F","TABLE","CODE_VALUE_EXTENSION")
  GO TO exit_script
 ENDIF
#populate_pt_table
 SET updt_cnt = 0
 SELECT INTO "nl:"
  pt.*
  FROM processing_task pt,
   (dummyt d  WITH seq = value(size(temp->proc_qual,5)))
  PLAN (d)
   JOIN (pt
   WHERE (pt.processing_task_id=temp->proc_qual[d.seq].processing_task_id))
  HEAD REPORT
   updt_cnt = 0
  DETAIL
   updt_cnt = (updt_cnt+ 1)
  WITH nocounter, forupdate(pt)
 ;end select
 IF (updt_cnt=0)
  SET failed = "T"
  CALL handle_errors("LOCK","F","TABLE","PROCESSING_TASK")
  GO TO exit_script
 ENDIF
 UPDATE  FROM processing_task pt,
   (dummyt d  WITH seq = value(size(temp->proc_qual,5)))
  SET pt.worklist_nbr = var_field_value, pt.updt_cnt = (pt.updt_cnt+ 1), pt.updt_dt_tm = cnvtdatetime
   (curdate,curtime),
   pt.updt_id = reqinfo->updt_id, pt.updt_task = reqinfo->updt_task, pt.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d)
   JOIN (pt
   WHERE (temp->proc_qual[d.seq].processing_task_id=pt.processing_task_id))
  WITH nocounter
 ;end update
 IF (curqual != updt_cnt)
  SET failed = "T"
  CALL handle_errors("UPDATE","F","TABLE","PROCESSING_TASK")
 ELSE
  SET reply->new_worklist_nbr = var_field_value
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   ROLLBACK
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
  CALL echo("failed")
 ELSE
  COMMIT
  IF ((reply->status_data.status="Z"))
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
