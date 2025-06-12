CREATE PROGRAM bbd_chg_person_donor_unlock:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 results[1]
     2 status = c1
     2 person_id = f8
     2 person_updt_cnt = i4
     2 person_updt_dt_tm = di8
     2 person_updt_id = f8
     2 person_updt_task = i4
     2 person_updt_applctx = i4
 )
 SET nbr_to_unlock = cnvtint(size(request->donorlist,5))
 SET stat = alter(reply->results,nbr_to_unlock)
 SET person_count = 0
 SET success_count = 0
 SET reply->status_data.status = "F"
 SET cur_updt_cnt = 0
 SET failed = "F"
 FOR (person_count = 1 TO nbr_to_unlock)
   SELECT INTO "nl:"
    p.*
    FROM person_donor p
    PLAN (p
     WHERE (p.person_id=request->donorlist[person_count].person_id)
      AND p.lock_ind=1)
    DETAIL
     cur_updt_cnt = p.updt_cnt
   ;end select
   SET reply->results[person_count].person_id = request->donorlist[person_count].person_id
   SET reply->results[person_count].person_updt_cnt = (cur_updt_cnt+ 1)
   SET reply->results[person_count].person_updt_dt_tm = cnvtdatetime(curdate,curtime3)
   SET reply->results[person_count].person_updt_id = reqinfo->updt_id
   SET reply->results[person_count].person_updt_task = reqinfo->updt_task
   SET reply->results[person_count].person_updt_applctx = reqinfo->updt_applctx WITH nocounter,
   forupdate(p)
   UPDATE  FROM person_donor p
    SET p.lock_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
     updt_applctx
    PLAN (p
     WHERE (p.person_id=request->donorlist[person_count].person_id)
      AND (p.updt_cnt=request->donorlist[person_count].updt_cnt)
      AND p.lock_ind=1)
    WITH nocounter
   ;end update
   IF (curqual=0)
    ROLLBACK
    SET reply->results[person_count].status = "F"
   ELSE
    COMMIT
    SET reply->results[person_count].status = "S"
    SET success_count = (success_count+ 1)
   ENDIF
 ENDFOR
 IF (success_count=0)
  SET reply->status_data.status = "F"
 ELSEIF (success_count < nbr_to_unlock)
  SET reply->status_data.status = "P"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
