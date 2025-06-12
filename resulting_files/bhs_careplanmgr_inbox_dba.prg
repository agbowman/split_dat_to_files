CREATE PROGRAM bhs_careplanmgr_inbox:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "event id:" = "0"
  WITH outdev, eventid
 SET retval = - (1)
 DECLARE deventid = f8 WITH public, noconstant(0.0)
 DECLARE dnpicd = f8 WITH protected, constant(uar_get_code_by("DISPLAY_KEY",263,
   "NATIONALPROVIDERIDENTIFIER"))
 IF (validate(req->prsnl_group_id,9999999999)=9999999999)
  RECORD req(
    1 task_activity_assign_id = f8
    1 prsnl_group_id = f8
  )
 ENDIF
 SET req->task_activity_assign_id = 0.0
 SET req->prsnl_group_id = 0.0
 SET deventid = cnvtreal( $EVENTID)
 IF (deventid > 0.0)
  CALL pause(1)
  SELECT INTO "nl:"
   ta.task_activity_assign_id, pg.prsnl_group_id
   FROM task_activity_assignment ta,
    task_activity t,
    prsnl_alias pa,
    prsnl_group pg
   PLAN (t
    WHERE t.event_id=deventid)
    JOIN (ta
    WHERE t.task_id=ta.task_id)
    JOIN (pa
    WHERE pa.person_id=ta.assign_prsnl_id
     AND pa.alias_pool_cd=dnpicd)
    JOIN (pg
    WHERE pg.prsnl_group_id=cnvtreal(pa.alias))
   DETAIL
    req->task_activity_assign_id = ta.task_activity_assign_id, req->prsnl_group_id = pg
    .prsnl_group_id
   WITH nocounter
  ;end select
  IF ((req->task_activity_assign_id > 0.0))
   UPDATE  FROM task_activity_assignment ta
    SET ta.assign_prsnl_group_id = req->prsnl_group_id, ta.assign_prsnl_id = 0.0
    WHERE (ta.task_activity_assign_id=req->task_activity_assign_id)
    WITH nocounter
   ;end update
   IF (curqual > 0)
    COMMIT
   ENDIF
  ENDIF
 ENDIF
 DECLARE status_text = vc
 SET retval = 100
 IF ((req->task_activity_assign_id > 0.0))
  SET status_text = build("task activity assignment row:",req->task_activity_assign_id,
   " updated to prsnl group id:",req->prsnl_group_id)
  SET log_misc1 = build("Event_id: ",deventid,", status_text=",status_text)
  SET log_message = build("Event_id: ",deventid,", status_text=",status_text)
 ELSEIF (deventid > 0.0)
  SET status_text = "no prsnl group/task activity assignment row found"
  SET log_misc1 = build("Event_id: ",deventid,", status_text=",status_text)
  SET log_message = build("Event_id: ",deventid,", status_text=",status_text)
 ELSE
  SET log_misc1 = build("No Event Found")
  SET log_message = build("No Event Found")
 ENDIF
 CALL echo("<==================== Exiting  Script ====================>")
END GO
