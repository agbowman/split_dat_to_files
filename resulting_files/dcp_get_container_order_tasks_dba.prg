CREATE PROGRAM dcp_get_container_order_tasks:dba
 FREE RECORD reply
 RECORD reply(
   1 container_list[*]
     2 task_id = f8
     2 container_id = f8
     2 task_status_cd = f8
     2 task_status_meaning = c12
     2 task_updt_cnt = i4
   1 order_list[*]
     2 task_id = f8
     2 order_id = f8
     2 task_status_cd = f8
     2 task_status_meaning = c12
     2 task_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 FREE RECORD counts
 RECORD counts(
   1 container_cnt = i4
   1 container_task_status_cnt = i4
   1 order_cnt = i4
   1 order_task_status_cnt = i4
   1 order_task_activity_cnt = i4
 )
 SET counts->container_cnt = size(request->container_tasks.container_list,5)
 SET counts->order_cnt = size(request->order_tasks.order_list,5)
 SET counts->container_task_status_cnt = size(request->container_tasks.task_status_list,5)
 SET counts->order_task_status_cnt = size(request->order_tasks.task_status_list,5)
 IF (validate(request->order_tasks.task_activity_list))
  SET counts->order_task_activity_cnt = size(request->order_tasks.task_activity_list,5)
 ELSE
  SET counts->order_task_activity_cnt = 0
 ENDIF
 IF (((counts->container_cnt+ counts->order_cnt)=0))
  SET reply->status_data.subeventstatus[1].operationname = "Request Validation"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Invalid Request"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Either order_list or container_list must be populated."
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 IF ((counts->container_cnt > 0)
  AND (counts->container_task_status_cnt=0))
  SET reply->status_data.subeventstatus[1].operationname = "Request Validation"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Invalid Request"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "If container_list is populated its task_status_list"," must be populated.")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 IF ((counts->order_cnt > 0)
  AND (counts->order_task_status_cnt=0))
  SET reply->status_data.subeventstatus[1].operationname = "Request Validation"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Invalid Request"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "If order_list is populated its task_status_list"," must be populated.")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 DECLARE container_idx = i4 WITH noconstant(0)
 FOR (container_idx = 1 TO counts->container_cnt)
   IF ((request->container_tasks.container_list[container_idx].container_id=0))
    SET reply->status_data.subeventstatus[1].operationname = "Request Validation"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Invalid Request"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Cannot query for a container_id of 0."
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
 ENDFOR
 DECLARE order_idx = i4 WITH noconstant(0)
 FOR (order_idx = 1 TO counts->order_cnt)
   IF ((request->order_tasks.order_list[order_idx].order_id=0))
    SET reply->status_data.subeventstatus[1].operationname = "Request Validation"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Invalid Request"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Cannot query for a order_id of 0."
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
 ENDFOR
 DECLARE status_idx = i4 WITH noconstant(0)
 FOR (status_idx = 1 TO counts->container_task_status_cnt)
   IF ((request->container_tasks.task_status_list[status_idx].task_status_cd=0))
    SET reply->status_data.subeventstatus[1].operationname = "Request Validation"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Invalid Request"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Container Tasks: Cannot query for task_status_cd of 0."
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
 ENDFOR
 FOR (status_idx = 1 TO counts->order_task_status_cnt)
   IF ((request->order_tasks.task_status_list[status_idx].task_status_cd=0))
    SET reply->status_data.subeventstatus[1].operationname = "Request Validation"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Invalid Request"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Order Tasks: Cannot query for task_status_cd of 0."
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
 ENDFOR
 DECLARE checkerrors(operation=vc) = c1
 IF ((counts->container_cnt > 0))
  SET container_idx = 0
  DECLARE cont_status_idx = i4 WITH noconstant(0)
  DECLARE container_task_cnt = i4 WITH noconstant(0)
  SELECT INTO "nl"
   FROM task_activity ta
   WHERE expand(container_idx,1,counts->container_cnt,ta.container_id,request->container_tasks.
    container_list[container_idx].container_id)
    AND expand(cont_status_idx,1,counts->container_task_status_cnt,(ta.task_status_cd+ 0),request->
    container_tasks.task_status_list[cont_status_idx].task_status_cd)
    AND ta.active_ind=1
   HEAD REPORT
    container_task_cnt = 0
   DETAIL
    container_task_cnt = (container_task_cnt+ 1)
    IF (container_task_cnt > size(reply->container_list,5))
     stat = alterlist(reply->container_list,(container_task_cnt+ 10))
    ENDIF
    reply->container_list[container_task_cnt].task_id = ta.task_id, reply->container_list[
    container_task_cnt].container_id = ta.container_id, reply->container_list[container_task_cnt].
    task_status_cd = ta.task_status_cd,
    reply->container_list[container_task_cnt].task_status_meaning = uar_get_code_meaning(ta
     .task_status_cd), reply->container_list[container_task_cnt].task_updt_cnt = ta.updt_cnt
   FOOT REPORT
    stat = alterlist(reply->container_list,container_task_cnt)
   WITH nocounter
  ;end select
  IF (checkerrors("Retrieve Container Tasks")="F")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (counts->order_cnt)
  SET order_idx = 0
  DECLARE ord_status_idx = i4 WITH noconstant(0)
  DECLARE order_task_cnt = i4 WITH noconstant(0)
  DECLARE activity_idx = i4 WITH noconstant(0)
  SELECT
   IF ((counts->order_task_activity_cnt > 0))
    FROM task_activity ta
    WHERE expand(order_idx,1,counts->order_cnt,ta.order_id,request->order_tasks.order_list[order_idx]
     .order_id)
     AND expand(ord_status_idx,1,counts->order_task_status_cnt,(ta.task_status_cd+ 0),request->
     order_tasks.task_status_list[ord_status_idx].task_status_cd)
     AND expand(activity_idx,1,counts->order_task_activity_cnt,ta.task_activity_cd,request->
     order_tasks.task_activity_list[activity_idx].task_activity_cd)
     AND ta.active_ind=1
   ELSE
    FROM task_activity ta
    WHERE expand(order_idx,1,counts->order_cnt,ta.order_id,request->order_tasks.order_list[order_idx]
     .order_id)
     AND expand(ord_status_idx,1,counts->order_task_status_cnt,(ta.task_status_cd+ 0),request->
     order_tasks.task_status_list[ord_status_idx].task_status_cd)
     AND ta.active_ind=1
   ENDIF
   INTO "nl"
   HEAD REPORT
    order_task_cnt = 0
   DETAIL
    order_task_cnt = (order_task_cnt+ 1)
    IF (order_task_cnt > size(reply->order_list,5))
     stat = alterlist(reply->order_list,(order_task_cnt+ 10))
    ENDIF
    reply->order_list[order_task_cnt].task_id = ta.task_id, reply->order_list[order_task_cnt].
    order_id = ta.order_id, reply->order_list[order_task_cnt].task_status_cd = ta.task_status_cd,
    reply->order_list[order_task_cnt].task_status_meaning = uar_get_code_meaning(ta.task_status_cd),
    reply->order_list[order_task_cnt].task_updt_cnt = ta.updt_cnt
   FOOT REPORT
    stat = alterlist(reply->order_list,order_task_cnt)
   WITH nocounter
  ;end select
  IF (checkerrors("Retrieve Container Tasks")="F")
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 GO TO exit_script
 SUBROUTINE checkerrors(operation)
   DECLARE errormsg = c255 WITH noconstant("")
   DECLARE errorcode = i4 WITH noconstant(0)
   SET errorcode = error(errormsg,0)
   IF (errorcode != 0)
    SET reply->status_data.subeventstatus[1].operationname = substring(1,25,trim(operation))
    SET reply->status_data.subeventstatus[1].targetobjectname = cnvtstring(errorcode)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errormsg
    SET reply->status_data.status = "F"
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
#exit_script
END GO
