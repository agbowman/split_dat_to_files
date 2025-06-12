CREATE PROGRAM bbd_chg_person_donor_lock:dba
 RECORD reply(
   1 person_donor_updt_cnt = i4
   1 person_donor_updt_dt_tm = di8
   1 person_donor_updt_id = f8
   1 person_donor_updt_task = i4
   1 person_donor_updt_applctx = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cur_updt_cnt = 0
 SET failed = "F"
 SELECT INTO "nl:"
  p.*
  FROM person_donor p
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND ((p.lock_ind = null) OR (p.lock_ind=0)) )
  DETAIL
   cur_updt_cnt = p.updt_cnt
 ;end select
 SET reply->person_donor_updt_cnt = (cur_updt_cnt+ 1)
 SET reply->person_donor_updt_dt_tm = cnvtdatetime(curdate,curtime3)
 SET reply->person_donor_updt_id = reqinfo->updt_id
 SET reply->person_donor_updt_task = reqinfo->updt_task
 SET reply->person_donor_updt_applctx = reqinfo->updt_applctx WITH nocounter, forupdate(p)
 IF (curqual != 1)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF ((request->updt_cnt != cur_updt_cnt))
  SET failed = "T"
  GO TO exit_script
 ENDIF
 UPDATE  FROM person_donor p
  SET p.lock_ind = 1, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
   updt_applctx
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND (p.updt_cnt=request->updt_cnt)
    AND ((p.lock_ind = null) OR (p.lock_ind=0)) )
  WITH nocounter
 ;end update
 IF (curqual != 1)
  SET failed = "T"
 ENDIF
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
