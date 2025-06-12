CREATE PROGRAM dcp_chk_tasks_change:dba
 RECORD reply(
   1 qual[*]
     2 task_id = f8
     2 updt_cnt = i4
     2 task_status_cd = f8
     2 task_status_mean = vc
     2 event_id = f8
     2 task_status_disp = vc
     2 location_cd = f8
     2 room_cd = f8
     2 bed_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH noconstant("F")
 SET reply->status_data.status = "F"
 DECLARE comp_idx = i4 WITH protect, noconstant(0)
 DECLARE expand_idx = i4 WITH protect, noconstant(0)
 DECLARE expand_start = i4 WITH protect, noconstant(1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE find_idx = i4 WITH protect, noconstant(0)
 DECLARE expand_size = i4 WITH public, constant(200)
 DECLARE total_ids = i4 WITH protect, constant(size(request->task_qual,5))
 IF (total_ids=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 DECLARE expand_blocks = i4 WITH protect, constant(ceil((total_ids/ (1.0 * expand_size))))
 DECLARE total_items = i4 WITH protect, constant((expand_blocks * expand_size))
 SET stat = alterlist(request->task_qual,total_items)
 SET stat = alterlist(reply->qual,total_ids)
 FOR (comp_idx = (total_ids+ 1) TO total_items)
   SET request->task_qual[comp_idx].task_id = request->task_qual[total_ids].task_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(expand_blocks)),
   task_activity ta
  PLAN (d
   WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
   JOIN (ta
   WHERE expand(expand_idx,expand_start,(expand_start+ (expand_size - 1)),ta.task_id,request->
    task_qual[expand_idx].task_id))
  HEAD REPORT
   idx = 0
  HEAD ta.task_id
   idx += 1
  DETAIL
   reply->qual[idx].task_id = ta.task_id, reply->qual[idx].updt_cnt = ta.updt_cnt, reply->qual[idx].
   task_status_cd = ta.task_status_cd,
   reply->qual[idx].event_id = ta.event_id, reply->qual[idx].task_status_mean = uar_get_code_meaning(
    ta.task_status_cd), reply->qual[idx].task_status_disp = uar_get_code_display(ta.task_status_cd),
   reply->qual[idx].location_cd = ta.location_cd, reply->qual[idx].room_cd = ta.loc_room_cd, reply->
   qual[idx].bed_cd = ta.loc_bed_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TASK_ACTIVITY"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NO TASKS SELECTED"
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
