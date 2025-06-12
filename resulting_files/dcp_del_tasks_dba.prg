CREATE PROGRAM dcp_del_tasks:dba
 RECORD internal(
   1 assign_list[*]
     2 status = i1
 )
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET nbr_to_chg = size(request->assign_list,5)
 SET stat = alterlist(internal->assign_list,nbr_to_chg)
 SET failures = 0
 SET active_count = 0
 IF (nbr_to_chg > 0)
  SELECT INTO "nl:"
   taa.task_id, taa.assign_prsnl_id
   FROM task_activity_assignment taa,
    (dummyt d  WITH seq = value(nbr_to_chg))
   PLAN (d)
    JOIN (taa
    WHERE (taa.task_id=request->assign_list[d.seq].task_id))
   ORDER BY taa.task_id, taa.assign_prsnl_id
   HEAD REPORT
    col + 0
   HEAD taa.task_id
    active_count = 0
   HEAD taa.assign_prsnl_id
    IF (taa.active_ind=1)
     active_count += 1
    ENDIF
   DETAIL
    col + 0
   FOOT  taa.assign_prsnl_id
    col + 0
   FOOT  taa.task_id
    IF (active_count=0)
     internal->assign_list[d.seq].status = 1
    ENDIF
   FOOT REPORT
    col + 0
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   ta.*
   FROM task_activity ta,
    (dummyt d  WITH seq = value(nbr_to_chg))
   PLAN (d
    WHERE (internal->assign_list[d.seq].status=1))
    JOIN (ta
    WHERE (ta.task_id=request->assign_list[d.seq].task_id)
     AND ta.active_ind=1)
   DETAIL
    IF ((ta.updt_cnt=request->assign_list[d.seq].updt_cnt))
     internal->assign_list[d.seq].status = 1
    ENDIF
   WITH nocounter, forupdatewait(ta)
  ;end select
  UPDATE  FROM task_activity ta,
    (dummyt d  WITH seq = value(nbr_to_chg))
   SET ta.active_ind = 0, ta.active_status_cd = reqdata->inactive_status_cd, ta.active_status_dt_tm
     = cnvtdatetime(sysdate),
    ta.active_status_prsnl_id = reqinfo->updt_id, ta.updt_dt_tm = cnvtdatetime(sysdate), ta.updt_id
     = reqinfo->updt_id,
    ta.updt_task = reqinfo->updt_task, ta.updt_cnt = (ta.updt_cnt+ 1), ta.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d
    WHERE (internal->assign_list[d.seq].status=1))
    JOIN (ta
    WHERE (ta.task_id=request->assign_list[d.seq].task_id)
     AND ta.active_ind=1)
   WITH nocounter, status(internal->assign_list[d.seq].status)
  ;end update
 ENDIF
 IF (curqual != nbr_to_chg)
  FOR (x = 1 TO nbr_to_chg)
    IF ((internal->assign_list[x].status=0))
     SET failures += 1
     IF (failures > 0)
      SET stat = alterlist(reply->task_list,failures)
     ENDIF
     SET reply->task_list[failures].task_id = request->assign_list[x].task_id
    ENDIF
  ENDFOR
 ENDIF
 IF (failures=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (failures != nbr_to_chg)
  SET reply->status_data.status = "P"
  SET reqinfo->commit_ind = 1
 ENDIF
#exit_script
END GO
