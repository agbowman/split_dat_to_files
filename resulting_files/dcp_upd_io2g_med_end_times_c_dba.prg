CREATE PROGRAM dcp_upd_io2g_med_end_times_c:dba
 SET starttime = cnvtdatetime(curdate,curtime3)
 IF (validate(inc_size,0)=0)
  SET inc_size = 100000
 ENDIF
 FREE SET struct_c
 RECORD struct_c(
   1 ms_err_msg = vc
   1 ms_info_name = vc
   1 ms_min_max_string = vc
   1 ms_parent_rowid = vc
   1 ms_child_rowid = vc
 )
 DECLARE child_failed_ind = i2 WITH public, noconstant(0)
 DECLARE seg_rollback_ind = i2 WITH public, noconstant(0)
 DECLARE io = f8 WITH public, constant(uar_get_code_by("MEANING",53,"IO"))
 DECLARE success_ind = i2 WITH protect, noconstant(0)
 DECLARE range_min_id = f8 WITH protect, noconstant(0.0)
 DECLARE range_max_id = f8 WITH protect, noconstant(0.0)
 DECLARE curr_min_id = f8 WITH protect, noconstant(0.0)
 DECLARE curr_max_id = f8 WITH protect, noconstant(0.0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE pos_end = i4 WITH protect, noconstant(0)
 DECLARE min_inc_size = i4 WITH protect, noconstant(25000)
 SET child_success_ind = 0
 IF (io < 0.0)
  CALL echo("FAILED TO RETRIEVE IO CODE VALUE FROM THE CODE_VALUE TABLE")
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info dm
  WHERE dm.info_domain="UPDATE EXISTING IO2G MED RESULTS - IO_END_DT_TM*"
   AND dm.info_name="MAX EVENT_ID EVALUATED BY*"
   AND dm.info_char != "IN PROCESS"
   AND dm.info_char != "SUCCESS"
  HEAD REPORT
   tmp_ptr = 0
  DETAIL
   struct_c->ms_child_rowid = dm.rowid, tmp_ptr = findstring("BY ",dm.info_name,1), struct_c->
   ms_parent_rowid = trim(substring((tmp_ptr+ 3),18,dm.info_name)),
   range_min_id = dm.info_number
  WITH nocounter, forupdatewait(dm), maxqual(dm,1)
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   FROM dm_info dm
   WHERE dm.info_domain="UPDATE EXISTING IO2G MED RESULTS PARENT - IO_END_DT_TM"
    AND dm.info_number=0
    AND dm.info_name="EVENT_ID RANGE*EVALUATED"
    AND dm.info_number != 1
   DETAIL
    struct_c->ms_info_name = dm.info_name, struct_c->ms_min_max_string = dm.info_char, struct_c->
    ms_parent_rowid = dm.rowid
   WITH nocounter, forupdatewait(dm), maxqual(dm,1)
  ;end select
  IF (curqual=1)
   CALL echo(build("INFO_NAME = ",cnvtupper(struct_c->ms_info_name)))
   CALL echo(build("INFO_CHAR = ",cnvtupper(struct_c->ms_min_max_string)))
   UPDATE  FROM dm_info dm
    SET dm.info_number = 1
    WHERE (dm.rowid=struct_c->ms_parent_rowid)
    WITH nocounter
   ;end update
   IF (error(struct_c->ms_err_msg,0) != 0)
    CALL echo(concat("FAILED TO OBTAIN ROW LEVEL LOCK ON DM_INFO:",cnvtupper(struct_c->ms_err_msg)))
    GO TO exit_program
   ENDIF
   COMMIT
   SET pos_end = findstring(":max:",struct_c->ms_min_max_string)
   SET range_max_id = cnvtreal(substring((pos_end+ 5),textlen(struct_c->ms_min_max_string),struct_c->
     ms_min_max_string))
   CALL echo(build("MAX EVENT_ID = ",range_max_id))
   SET pos = (findstring("min:",struct_c->ms_min_max_string)+ 4)
   SET range_min_id = cnvtreal(substring(pos,(pos_end - pos),struct_c->ms_min_max_string))
   CALL echo(build("MIN EVENT_ID = ",range_min_id))
   INSERT  FROM dm_info dm
    SET dm.info_domain = "UPDATE EXISTING IO2G MED RESULTS - IO_END_DT_TM", dm.info_name = concat(
      "MAX EVENT_ID EVALUATED BY ",struct_c->ms_parent_rowid), dm.info_number = range_min_id,
     dm.info_date = cnvtdatetime(curdate,curtime3), dm.info_char = "IN PROCESS"
    WITH nocounter
   ;end insert
   SELECT INTO "nl:"
    FROM dm_info dm
    WHERE dm.info_domain="UPDATE EXISTING IO2G MED RESULTS - IO_END_DT_TM"
     AND dm.info_name="MAX EVENT_ID EVALUATED BY*"
     AND dm.info_char="IN PROCESS"
     AND dm.info_number=range_min_id
    DETAIL
     struct_c->ms_child_rowid = dm.rowid
    WITH nocounter
   ;end select
   IF (error(struct_c->ms_err_msg,0) != 0)
    CALL echo(concat("FAILED TO INSERT CHILD ROW IN DM_INFO:",cnvtupper(struct_c->ms_err_msg)))
    GO TO exit_program
   ENDIF
   COMMIT
  ELSE
   IF (error(struct_c->ms_err_msg,0) != 0)
    CALL echo(concat("FAILED TO LOCK OR FIND PARENT ROW ON DM_INFO FOR UPDATE.",cnvtupper(struct_c->
       ms_err_msg)))
    GO TO exit_program
   ENDIF
   SET success_ind = 1
   SET child_success_ind = 1
   GO TO exit_program
  ENDIF
 ELSE
  UPDATE  FROM dm_info dm
   SET dm.info_char = "IN PROCESS"
   WHERE (dm.rowid=struct_c->ms_child_rowid)
   WITH nocounter
  ;end update
  IF (error(struct_c->ms_err_msg,0) != 0)
   CALL echo(concat("FAILED TO OBTAIN ROW LEVEL LOCK ON DM_INFO:",cnvtupper(struct_c->ms_err_msg)))
   GO TO exit_program
  ENDIF
  COMMIT
  SELECT INTO "nl:"
   FROM dm_info dm
   WHERE (dm.rowid=struct_c->ms_parent_rowid)
   DETAIL
    struct_c->ms_info_name = dm.info_name, struct_c->ms_min_max_string = dm.info_char
   WITH nocounter, forupdatewait(dm), maxqual(dm,1)
  ;end select
  SET pos_end = findstring(":max:",struct_c->ms_min_max_string)
  SET range_max_id = cnvtreal(substring((pos_end+ 5),textlen(struct_c->ms_min_max_string),struct_c->
    ms_min_max_string))
  CALL echo(build("MIN EVENT_ID = ",range_min_id))
  CALL echo(build("MAX EVENT_ID = ",range_max_id))
 ENDIF
 IF (range_max_id <= 0.0)
  CALL echo("AUTO-SUCCESS: THERE WERE NO EVENT_IDS FOR THIS CHILD PROCESS TO UPDATE.")
  SET stoptime = datetimediff(cnvtdatetime(curdate,curtime3),starttime,5)
  UPDATE  FROM dm_info dm
   SET dm.info_char = "SUCCESS", dm.updt_applctx = stoptime
   WHERE (dm.rowid=struct_c->ms_child_rowid)
   WITH nocounter
  ;end update
  IF (error(struct_c->ms_err_msg,0) != 0)
   CALL echo(concat("FAILED TO UPDATE CHILD ROW IN DM_INFO:",cnvtupper(struct_c->ms_err_msg)))
   GO TO exit_program
  ENDIF
  COMMIT
  SET success_ind = 1
  SET child_success_ind = 1
  GO TO exit_program
 ENDIF
 SET curr_min_id = range_min_id
 SET curr_max_id = (curr_min_id+ inc_size)
 WHILE (curr_min_id <= range_max_id)
   IF (curr_max_id > range_max_id)
    SET curr_max_id = range_max_id
   ENDIF
   EXECUTE dcp_upd_io2g_med_end_times value(curr_min_id), value(curr_max_id)
   IF (child_failed_ind=1)
    GO TO exit_program
   ENDIF
   IF (seg_rollback_ind=1)
    IF (inc_size=min_inc_size)
     CALL echo("ENCOUNTERED ROLLBACK SEGMENT FAILURE...COULD NOT CONTINUE")
     GO TO exit_program
    ENDIF
    SET inc_size = ceil((inc_size/ 2))
    SET curr_max_id = ((curr_min_id+ inc_size) - 1)
    SET seg_rollback_ind = 0
   ELSE
    SET curr_min_id = (curr_max_id+ 1)
    SET curr_max_id = ((curr_min_id+ inc_size) - 1)
   ENDIF
 ENDWHILE
 SET stoptime = datetimediff(cnvtdatetime(curdate,curtime3),starttime,5)
 UPDATE  FROM dm_info dm
  SET dm.info_char = "SUCCESS", dm.updt_applctx = stoptime
  WHERE (dm.rowid=struct_c->ms_child_rowid)
  WITH nocounter
 ;end update
 IF (error(struct_c->ms_err_msg,0) != 0)
  CALL echo(concat("FAILED TO UPDATE CHILD ROW IN DM_INFO:",cnvtupper(struct_c->ms_err_msg)))
  GO TO exit_program
 ENDIF
 COMMIT
 SET success_ind = 1
 SET child_success_ind = 1
 CALL echo(concat("IO_END_DT_TM OF EVENT_IDs ",trim(cnvtstring(range_min_id))," TO ",trim(cnvtstring(
     range_max_id))," HAVE BEEN UPDATED"))
 CALL echo(build("ELAPSED TIME IN SECONDS: ",datetimediff(cnvtdatetime(curdate,curtime3),starttime,5)
   ))
#exit_program
 IF (success_ind=0)
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 FREE RECORD struct_c
END GO
