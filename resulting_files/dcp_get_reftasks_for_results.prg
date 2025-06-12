CREATE PROGRAM dcp_get_reftasks_for_results
 RECORD reply(
   1 tasks[*]
     2 task_ref_id = f8
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
 DECLARE result_cnt = i4 WITH protect, constant(size(request->results,5))
 IF (result_cnt=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 DECLARE comp_idx = i4 WITH protect, noconstant(0)
 DECLARE expand_idx = i4 WITH protect, noconstant(0)
 DECLARE expand_start = i4 WITH protect, noconstant(1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE expand_size = i4 WITH public, constant(40)
 DECLARE expand_blocks = i4 WITH protect, constant(ceil((result_cnt/ (1.0 * expand_size))))
 DECLARE total_items = i4 WITH protect, constant((expand_blocks * expand_size))
 SET stat = alterlist(request->results,total_items)
 SET stat = alterlist(reply->tasks,result_cnt)
 FOR (comp_idx = (result_cnt+ 1) TO total_items)
   SET request->results[comp_idx].result_set_id = request->results[result_cnt].result_set_id
 ENDFOR
 SELECT INTO "nl:"
  ta.reference_task_id
  FROM (dummyt d  WITH seq = value(expand_blocks)),
   task_activity ta
  PLAN (d
   WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
   JOIN (ta
   WHERE expand(expand_idx,expand_start,(expand_start+ (expand_size - 1)),ta.result_set_id,request->
    results[expand_idx].result_set_id))
  HEAD REPORT
   idx = 0
  HEAD ta.reference_task_id
   idx = (idx+ 1)
  DETAIL
   reply->tasks[idx].task_ref_id = ta.reference_task_id
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
 ENDIF
END GO
