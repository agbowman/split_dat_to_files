CREATE PROGRAM dcp_icu_del_required_fields:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET col_to_del = size(request->qual,5)
 FOR (x = 1 TO col_to_del)
   IF ((request->qual[x].specialty_event_set_cd > 0))
    DELETE  FROM eventset_task_rltn etr
     WHERE (etr.specialty_event_set_cd=request->qual[x].specialty_event_set_cd)
      AND (etr.position_cd=request->qual[x].position_cd)
      AND (etr.task_assay_cd=request->qual[x].task_assay_cd)
     WITH counter
    ;end delete
   ENDIF
 ENDFOR
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "eventset_task_rltn Table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "delete"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to delete from table"
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
