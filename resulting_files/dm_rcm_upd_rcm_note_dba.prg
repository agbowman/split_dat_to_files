CREATE PROGRAM dm_rcm_upd_rcm_note:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script dm_rcm_upd_rcm_note..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE maxid = f8 WITH protect, noconstant(0.0)
 DECLARE minid = f8 WITH protect, noconstant(0.0)
 DECLARE curminid = f8 WITH protect, noconstant(0.0)
 DECLARE curmaxid = f8 WITH protect, noconstant(0.0)
 DECLARE batchsize = i4 WITH protect, noconstant(250000)
 IF ((validate(debugme,- (9))=- (9)))
  DECLARE debugme = i2 WITH noconstant(false)
 ENDIF
 FREE RECORD combinedencounters
 RECORD combinedencounters(
   1 encounter_list[*]
     2 encntr_id = f8
 )
 FREE RECORD movedencounters
 RECORD movedencounters(
   1 encounter_list[*]
     2 encntr_id = f8
 )
 FREE RECORD combinedpersons
 RECORD combinedpersons(
   1 person_list[*]
     2 person_id = f8
 )
 SELECT INTO "nl:"
  FROM rcm_note n,
   encntr_combine ec
  PLAN (n
   WHERE n.last_updt_prsnl_id=0
    AND n.active_ind=1
    AND n.encntr_id > 0
    AND n.beg_effective_dt_tm > cnvtdatetime(cnvtdate(02282012),0000)
    AND n.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (ec
   WHERE ec.to_encntr_id=n.encntr_id)
  HEAD REPORT
   stat = alterlist(combinedencounters->encounter_list,10), count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1
    AND count > 10)
    stat = alterlist(combinedencounters->encounter_list,(count+ 9))
   ENDIF
   combinedencounters->encounter_list[count].encntr_id = ec.to_encntr_id
  FOOT REPORT
   IF (mod(count,10) != 0)
    stat = alterlist(combinedencounters->encounter_list,count)
   ENDIF
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to retrieve combineded encounter: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (debugme)
  CALL echorecord(combinedencounters)
 ENDIF
 SELECT INTO "nl:"
  FROM rcm_note n,
   person_combine pc
  PLAN (n
   WHERE n.last_updt_prsnl_id=0
    AND n.active_ind=1
    AND n.encntr_id > 0
    AND n.beg_effective_dt_tm > cnvtdatetime(cnvtdate(02282012),0000)
    AND n.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pc
   WHERE pc.encntr_id=n.encntr_id)
  HEAD REPORT
   stat = alterlist(movedencounters->encounter_list,10), count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1
    AND count > 10)
    stat = alterlist(movedencounters->encounter_list,(count+ 9))
   ENDIF
   movedencounters->encounter_list[count].encntr_id = pc.encntr_id
  FOOT REPORT
   IF (mod(count,10) != 0)
    stat = alterlist(movedencounters->encounter_list,count)
   ENDIF
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to retrieve moved encounter: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (debugme)
  CALL echorecord(movedencounters)
 ENDIF
 SELECT INTO "nl:"
  FROM rcm_note n,
   person_combine pc
  PLAN (n
   WHERE n.last_updt_prsnl_id=0
    AND n.active_ind=1
    AND n.person_id > 0
    AND n.beg_effective_dt_tm > cnvtdatetime(cnvtdate(02282012),0000)
    AND n.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pc
   WHERE pc.to_person_id=n.person_id)
  HEAD REPORT
   stat = alterlist(combinedpersons->person_list,10), count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1
    AND count > 10)
    stat = alterlist(combinedpersons->person_list,(count+ 9))
   ENDIF
   combinedpersons->person_list[count].person_id = pc.to_person_id
  FOOT REPORT
   IF (mod(count,10) != 0)
    stat = alterlist(combinedpersons->person_list,count)
   ENDIF
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to retrieve combined person: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (debugme)
  CALL echorecord(combinedpersons)
 ENDIF
 IF (size(combinedencounters->encounter_list,5) > 0)
  UPDATE  FROM rcm_note n,
    (dummyt d  WITH seq = value(size(combinedencounters->encounter_list,5)))
   SET n.last_updt_prsnl_id = n.create_prsnl_id, n.updt_applctx = reqinfo->updt_applctx, n.updt_cnt
     = (n.updt_cnt+ 1),
    n.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (n
    WHERE (n.encntr_id=combinedencounters->encounter_list[d.seq].encntr_id)
     AND n.last_updt_prsnl_id=0)
   WITH nocounter
  ;end update
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to update combined encounter notes: ",errmsg)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (size(movedencounters->encounter_list,5) > 0)
  UPDATE  FROM rcm_note n,
    (dummyt d  WITH seq = value(size(movedencounters->encounter_list,5)))
   SET n.last_updt_prsnl_id = n.create_prsnl_id, n.updt_applctx = reqinfo->updt_applctx, n.updt_cnt
     = (n.updt_cnt+ 1),
    n.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (n
    WHERE (n.encntr_id=movedencounters->encounter_list[d.seq].encntr_id)
     AND n.last_updt_prsnl_id=0)
   WITH nocounter
  ;end update
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to update moved encounter notes: ",errmsg)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (size(combinedpersons->person_list,5) > 0)
  UPDATE  FROM rcm_note n,
    (dummyt d  WITH seq = value(size(combinedpersons->person_list,5)))
   SET n.last_updt_prsnl_id = n.create_prsnl_id, n.updt_applctx = reqinfo->updt_applctx, n.updt_cnt
     = (n.updt_cnt+ 1),
    n.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (n
    WHERE (n.person_id=combinedpersons->person_list[d.seq].person_id)
     AND n.last_updt_prsnl_id=0)
   WITH nocounter
  ;end update
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to update combined person notes: ",errmsg)
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  minidval = min(n.rcm_note_id)
  FROM rcm_note n
  WHERE n.rcm_note_id > 0
  DETAIL
   minid = maxval(minidval,1.0)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->status = concat("Failed to get minimum ID: ",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  maxidval = max(n.rcm_note_id)
  FROM rcm_note n
  DETAIL
   maxid = maxidval
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->status = concat("Failed to get maximum ID: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (minid > maxid)
  SET readme_data->status = "S"
  SET readme_data->message = "No work needs to be done; exiting"
  GO TO exit_script
 ENDIF
 SET curminid = minid
 SET curmaxid = ((curminid+ batchsize) - 1)
 WHILE (curminid <= maxid)
   UPDATE  FROM rcm_note n
    SET n.last_updt_prsnl_id = n.updt_id, n.updt_applctx = reqinfo->updt_applctx, n.updt_cnt = (n
     .updt_cnt+ 1),
     n.updt_task = reqinfo->updt_task
    WHERE n.rcm_note_id BETWEEN curminid AND curmaxid
     AND n.last_updt_prsnl_id=0
     AND n.active_ind=1
     AND n.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end update
   IF (error(errmsg,0) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update RCM_NOTE table: ",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   SET curminid = (curmaxid+ 1)
   SET curmaxid = ((curminid+ batchsize) - 1)
 ENDWHILE
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update rcm_note: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
