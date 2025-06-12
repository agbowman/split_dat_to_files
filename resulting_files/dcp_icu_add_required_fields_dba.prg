CREATE PROGRAM dcp_icu_add_required_fields:dba
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
 SET count1 = 0
 SET col_to_add = size(request->qual,5)
 INSERT  FROM eventset_task_rltn etr,
   (dummyt d1  WITH seq = value(col_to_add))
  SET etr.specialty_event_set_cd = request->qual[d1.seq].specialty_event_set_cd, etr
   .eventset_task_rltn_id = cnvtint(seq(reference_seq,nextval)), etr.position_cd = request->qual[d1
   .seq].position_cd,
   etr.task_assay_cd = request->qual[d1.seq].task_assay_cd, etr.group_event_set_cd = 1, etr
   .required_ind = 1,
   etr.updt_dt_tm = cnvtdatetime(curdate,curtime3), etr.updt_id = reqinfo->updt_id, etr.updt_task =
   reqinfo->updt_task,
   etr.updt_applctx = reqinfo->updt_applctx, etr.updt_cnt = 1
  PLAN (d1)
   JOIN (etr)
  WITH counter
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
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP CUSTOM COLUMNS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "UNABLE TO INSERT"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
