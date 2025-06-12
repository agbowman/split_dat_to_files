CREATE PROGRAM dcp_pl_insert_removed_rows:dba
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET col_to_add = size(request->qual,5)
 INSERT  FROM dcp_pl_prioritization p,
   (dummyt d3  WITH seq = value(col_to_add))
  SET p.patient_list_id = request->patient_list_id, p.encntr_id = request->qual[d3.seq].encounter_id,
   p.person_id = request->qual[d3.seq].person_id,
   p.priority_id = seq(dcp_patient_list_seq,nextval), p.priority = 0, p.updt_applctx = reqinfo->
   updt_applctx,
   p.remove_dt_tm = cnvtdatetime(curdate,curtime3), p.remove_ind = 1, p.updt_id = reqinfo->updt_id,
   p.updt_task = reqinfo->updt_task, p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d3)
   JOIN (p)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_PL_INSERT_REMOVED_ROWS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "UNABLE TO INSERT"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
