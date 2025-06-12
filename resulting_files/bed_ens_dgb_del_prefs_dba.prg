CREATE PROGRAM bed_ens_dgb_del_prefs:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET treq
 RECORD treq(
   1 req[*]
     2 id = f8
 )
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET req_cnt = size(request->del_from,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   app_prefs a,
   name_value_prefs n,
   br_prefs b
  PLAN (d)
   JOIN (a
   WHERE (a.application_number=request->del_from[d.seq].application_number)
    AND ((a.position_cd+ 0)=request->del_from[d.seq].position_code_value)
    AND (a.prsnl_id=request->del_from[d.seq].prsnl_id)
    AND a.active_ind=1)
   JOIN (n
   WHERE n.parent_entity_id=a.app_prefs_id
    AND n.parent_entity_name="APP_PREFS")
   JOIN (b
   WHERE b.pvc_name=n.pvc_name
    AND (((request->del_from[d.seq].chart_ind=1)
    AND b.view_name="CHART") OR ((request->del_from[d.seq].mc_ind=1)
    AND b.view_name="PVINBOX")) )
  ORDER BY n.name_value_prefs_id
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(treq->req,100)
  HEAD n.name_value_prefs_id
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(treq->req,(tcnt+ 100)), cnt = 1
   ENDIF
   treq->req[tcnt].id = n.name_value_prefs_id
  FOOT REPORT
   stat = alterlist(treq->req,tcnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   app_prefs a,
   name_value_prefs n
  PLAN (d)
   JOIN (a
   WHERE (a.application_number=request->del_from[d.seq].application_number)
    AND ((a.position_cd+ 0)=request->del_from[d.seq].position_code_value)
    AND (a.prsnl_id=request->del_from[d.seq].prsnl_id)
    AND a.active_ind=1)
   JOIN (n
   WHERE n.parent_entity_id=a.app_prefs_id
    AND n.parent_entity_name="APP_PREFS"
    AND ((trim(n.pvc_name) IN ("DB_ALLOW_HIDE", "DB_ALLOW_CUSTOM", "CHT_DB_ROWS", "CHT_DB_COLS",
   "CHT_DB_EVENT_STATUS",
   "CHT_DB_PATIENT_PICTURE", "CHT_DB_CUSTOM_SCRIPT")
    AND (request->del_from[d.seq].chart_ind=1)) OR (trim(n.pvc_name) IN ("MSG_DB_CUSTOM_SCRIPT",
   "MSG_DB_EVENT_STATUS", "MSG_DB_ROWS", "MSG_DB_COLS", "MSG_DB_PATIENT_PICTURE",
   "MSG_DB_ALLOW_CUSTOM")
    AND (request->del_from[d.seq].mc_ind=1))) )
  ORDER BY n.name_value_prefs_id
  HEAD REPORT
   cnt = 0, stat = alterlist(treq->req,(tcnt+ 10))
  HEAD n.name_value_prefs_id
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 10)
    stat = alterlist(treq->req,(tcnt+ 10)), cnt = 1
   ENDIF
   treq->req[tcnt].id = n.name_value_prefs_id
  FOOT REPORT
   stat = alterlist(treq->req,tcnt)
  WITH nocounter
 ;end select
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 DELETE  FROM name_value_prefs n,
   (dummyt d  WITH seq = value(tcnt))
  SET n.seq = 1
  PLAN (d)
   JOIN (n
   WHERE (n.name_value_prefs_id=treq->req[d.seq].id))
  WITH nocounter
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error on name_value_prefs delete")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
 CALL echorecord(treq)
END GO
