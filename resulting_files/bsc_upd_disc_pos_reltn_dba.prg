CREATE PROGRAM bsc_upd_disc_pos_reltn:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE list_count = i4 WITH noconstant(0)
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE loop = i4 WITH noconstant(0)
 DECLARE exp_cnt = i4 WITH noconstant(0)
 DECLARE child_count = i4 WITH noconstant(0)
 SET list_count = size(request->remove_list,5)
 FOR (loop = 1 TO list_count)
  SET child_count = size(request->remove_list[loop].child_list,5)
  IF (child_count > 0)
   DELETE  FROM code_value_group cvg
    WHERE cvg.code_set=88.0
     AND expand(exp_cnt,1,child_count,cvg.child_code_value,request->remove_list[loop].child_list[
     exp_cnt].child_code_value)
   ;end delete
   IF (curqual=0)
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
 SET list_count = size(request->add_list,5)
 FOR (loop = 1 TO list_count)
  SET child_count = size(request->add_list[loop].child_list,5)
  IF (child_count > 0)
   INSERT  FROM code_value_group cvg,
     (dummyt d  WITH seq = child_count)
    SET cvg.child_code_value = request->add_list[loop].child_list[d.seq].child_code_value, cvg
     .code_set = 88, cvg.collation_seq = 0,
     cvg.parent_code_value = request->add_list[loop].parent_code_value, cvg.updt_cnt = 0, cvg
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     cvg.updt_id = reqinfo->updt_id, cvg.updt_task = reqinfo->updt_task, cvg.updt_applctx = reqinfo->
     updt_applctx
    PLAN (d)
     JOIN (cvg)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE_GROUP TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "UNABLE TO UPDATE"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
