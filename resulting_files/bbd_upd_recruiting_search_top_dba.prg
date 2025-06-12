CREATE PROGRAM bbd_upd_recruiting_search_top:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 RECORD current(
   1 system_dt_tm = dq8
 )
 SET current->system_dt_tm = cnvtdatetime(curdate,curtime3)
 SET reply->status_data.status = "F"
 SET failed = "F"
 UPDATE  FROM bbd_recruiting_list l
  SET l.last_person_id = 0, l.completed_ind =
   IF ((request->complete_ind=1)) 1
   ELSE 0
   ENDIF
   , l.updt_applctx = reqinfo->updt_applctx,
   l.updt_task = reqinfo->updt_task, l.updt_cnt = (l.updt_cnt+ 1), l.updt_id = reqinfo->updt_id,
   l.updt_dt_tm = cnvtdatetime(current->system_dt_tm)
  WHERE (l.list_id=request->list_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  SET reply->status = "S"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_recruiting_rslts.prg"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_recruiting_list"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error updating bbd_recruiting_list"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
