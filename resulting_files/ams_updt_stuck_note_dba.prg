CREATE PROGRAM ams_updt_stuck_note:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter the task_id for the report to update" = "",
  "Task Information" = 0,
  "Select the status to which to set the report" = 0
  WITH outdev, taskid, status
 DECLARE completed_cd = f8
 DECLARE inerror_cd = f8
 DECLARE prog_name = vc
 DECLARE run_ind = i2
 DECLARE task_id = f8
 DECLARE task_status = vc
 DECLARE task_status_cd = f8
 SET completed_cd = uar_get_code_by("MEANING",103,"COMPLETED")
 SET completed_cd = uar_get_code_by("MEANING",103,"INERROR")
 SET prog_name = "AMS_UPDT_STUCK_NOTE"
 SET run_ind = 0
 SET task_id = cnvtreal( $TASKID)
 SET task_status_cd = cnvtreal( $STATUS)
 SET run_ind = amsuser(reqinfo->updt_id)
 IF (run_ind=1)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_value=cnvtreal( $STATUS)
   DETAIL
    task_status = cv.display
   WITH nocounter
  ;end select
  UPDATE  FROM task_activity t
   SET t.task_status_cd = task_status_cd, t.updt_id = reqinfo->updt_id, t.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    t.updt_cnt = (updt_cnt+ 1)
   WHERE t.task_id=task_id
   WITH nocounter
  ;end update
  COMMIT
  UPDATE  FROM task_activity_assignment ta
   SET ta.task_status_cd = task_status_cd, ta.updt_id = reqinfo->updt_id, ta.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    ta.updt_cnt = (updt_cnt+ 1)
   WHERE ta.task_id=task_id
   WITH nocounter
  ;end update
  COMMIT
  SELECT INTO  $1
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "UPDATED FOLLOWING TASKS:",
    row 4, col 20, "Task_id:",
    task_id, row 5, col 20,
    "Status:", task_status
   WITH nocounter
  ;end select
  CALL updtdminfo(prog_name)
 ELSE
  SELECT INTO  $1
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "THIS PROGRAM IS INTENDED FOR USE BY AMS ASSOCIATES ONLY"
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE updtdminfo(prog_name)
   DECLARE found = i2
   DECLARE info_nbr = i4
   SET found = 0
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="AMS_TOOLKIT"
     AND d.info_name=prog_name
    DETAIL
     found = 1, info_nbr = (d.info_number+ 1)
    WITH nocounter
   ;end select
   IF (found=0)
    INSERT  FROM dm_info d
     SET d.info_domain = "AMS_TOOLKIT", d.info_name = prog_name, d.info_date = cnvtdatetime(curdate,
       curtime3),
      d.info_number = 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info d
     SET d.info_number = info_nbr
     WHERE d.info_domain="AMS_TOOLKIT"
      AND d.info_name=prog_name
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
 SUBROUTINE amsuser(person_id)
   DECLARE user_ind = i2
   DECLARE prsnl_cd = f8
   SET user_ind = 0
   SET prsnl_cd = uar_get_code_by("MEANING",213,"PRSNL")
   SELECT
    p.person_id
    FROM person_name p
    WHERE (p.person_id=reqinfo->updt_id)
     AND p.name_type_cd=prsnl_cd
     AND p.name_title="Cerner AMS"
    DETAIL
     IF (p.person_id > 0)
      user_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   RETURN(user_ind)
 END ;Subroutine
 SET script_ver = "001 04/11/2012"
END GO
