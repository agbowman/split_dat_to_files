CREATE PROGRAM bhs_eks_rad_read:dba
 SET complete_cd = uar_get_code_by("MEANING",16369,"COMPLETE")
 DECLARE tracking_event_id = f8
 SET tracking_event_id = 0.0
 SET eid = trigger_encntrid
 SELECT INTO "nl:"
  FROM tracking_item ti,
   tracking_event te,
   track_event t_e
  PLAN (ti
   WHERE ti.encntr_id=eid)
   JOIN (te
   WHERE te.tracking_id=ti.tracking_id)
   JOIN (t_e
   WHERE t_e.track_event_id=te.track_event_id
    AND t_e.display="SYSTEM USE:Rad Read"
    AND t_e.active_ind=1)
  DETAIL
   tracking_event_id = te.tracking_event_id
  WITH nocounter
 ;end select
 CALL echo(build(" *** "))
 CALL echo(build(" The te.tracking_event_id found is  :  ",tracking_event_id))
 CALL echo(build(" *** "))
 IF (tracking_event_id > 0)
  CALL echo(build("***** doing the update ******* "))
  UPDATE  FROM tracking_event te
   SET te.updt_dt_tm = cnvtdatetime(curdate,curtime3), te.updt_id = reqinfo->updt_id, te.updt_task =
    reqinfo->updt_task,
    te.updt_applctx = reqinfo->updt_applctx, te.event_status_cd = complete_cd, te.updt_cnt = (te
    .updt_cnt+ 1),
    te.complete_dt_tm = cnvtdatetime(curdate,curtime3), te.complete_id = reqinfo->updt_id, te
    .onset_dt_tm = cnvtdatetime(curdate,curtime3),
    te.onset_id = reqinfo->updt_id
   WHERE te.tracking_event_id=tracking_event_id
   WITH nocounter
  ;end update
  COMMIT
  SET reqinfo->commit_ind = 1
  SET log_message = build("Update completed te.tracking_event_id::",tracking_event_id)
  CALL echo(log_message)
  GO TO exit_success
 ELSE
  SET log_message = concat("General failure - No tracking_event_id found!")
  CALL echo(log_message)
  GO TO exit_fail
 ENDIF
#exit_fail
 SET retval = - (1)
 GO TO exit_script
#exit_success
 CALL echo(build("***** exit_success ******* "))
 SET retval = 100
 CALL echorecord(request)
 CALL echorecord(reqinfo)
#exit_script
 CALL echo(build("***** exit_script retval: ",retval))
 COMMIT
END GO
