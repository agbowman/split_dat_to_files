CREATE PROGRAM dcp_add_phx_action:dba
 RECORD reply(
   1 pregnancy_actions[*]
     2 pregnancy_action_id = f8
   1 action_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD pregnancies
 RECORD pregnancies(
   1 list[*]
     2 pregnancy_id = f8
     2 pregnancy_instance_id = f8
 )
 DECLARE idx = i4 WITH public, noconstant(0)
 DECLARE action_cnt = i4 WITH public, noconstant(size(request->pregnancies,5))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE new_action_id = i4 WITH public, noconstant(0)
 DECLARE current_time = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime))
 DECLARE getactionid(aidx=i4) = null
 SET modify = predeclare
 SET reply->status_data.status = "F"
 SELECT
  IF (action_cnt=0)
   FROM pregnancy_instance pi
   WHERE (pi.person_id=request->person_id)
  ELSE
   FROM pregnancy_instance pi
   WHERE expand(idx,1,action_cnt,pi.pregnancy_id,request->pregnancies[idx].pregnancy_id)
    AND pi.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100")
    AND pi.active_ind=1
  ENDIF
  INTO "nl:"
  HEAD REPORT
   idx = 0
  DETAIL
   idx = (idx+ 1)
   IF (mod(idx,5)=1)
    stat = alterlist(pregnancies->list,(idx+ 4))
   ENDIF
   pregnancies->list[idx].pregnancy_id = pi.pregnancy_id, pregnancies->list[idx].
   pregnancy_instance_id = pi.pregnancy_instance_id
  FOOT REPORT
   stat = alterlist(pregnancies->list,idx), action_cnt = idx
  WITH nocounter
 ;end select
 IF (action_cnt=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->pregnancy_actions,action_cnt)
 FOR (idx = 1 TO action_cnt)
   CALL getactionid(idx)
 ENDFOR
 INSERT  FROM pregnancy_action pa,
   (dummyt d  WITH seq = value(action_cnt))
  SET pa.pregnancy_action_id = reply->pregnancy_actions[d.seq].pregnancy_action_id, pa.prsnl_id =
   request->prsnl_id, pa.action_type_cd = request->action_type_cd,
   pa.pregnancy_id = pregnancies->list[d.seq].pregnancy_id, pa.action_dt_tm = cnvtdatetime(
    current_time), pa.action_tz = curtimezoneapp,
   pa.updt_dt_tm = cnvtdatetime(current_time), pa.updt_applctx = reqinfo->updt_applctx, pa.updt_id =
   reqinfo->updt_id,
   pa.updt_task = reqinfo->updt_task, pa.updt_cnt = 0, pa.pregnancy_instance_id = pregnancies->list[d
   .seq].pregnancy_instance_id
  PLAN (d)
   JOIN (pa)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->action_dt_tm = cnvtdatetime(current_time)
  SET reqinfo->commit_ind = 1
 ENDIF
 SUBROUTINE getactionid(aidx)
   SELECT INTO "nl:"
    val = seq(pregnancy_seq,nextval)
    FROM dual
    DETAIL
     reply->pregnancy_actions[aidx].pregnancy_action_id = cnvtreal(val)
    WITH nocounter
   ;end select
 END ;Subroutine
#exit_script
END GO
