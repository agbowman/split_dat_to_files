CREATE PROGRAM dcp_copy_io_results_child_num:dba
 SET starttime = cnvtdatetime(curdate,curtime3)
 SET gn_child_success = 0
 FREE SET string_struct
 RECORD string_struct(
   1 ms_err_msg = vc
   1 ms_info_name = vc
   1 ms_min_max_string = vc
   1 ms_parent_rowid = vc
   1 ms_child_rowid = vc
 )
 DECLARE mn_success = i2 WITH protect, noconstant(0)
 DECLARE mf_min_epr_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_max_epr_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cur_min_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cur_max_id = f8 WITH protect, noconstant(0.0)
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_end_pos = i4 WITH protect, noconstant(0)
 DECLARE gn_child_failed = i2 WITH public, noconstant(0)
 DECLARE gn_rollback_seg_failed = i2 WITH public, noconstant(0)
 DECLARE min_inc_size = i4 WITH protect, noconstant(25000)
 DECLARE mf_success_rows = i2 WITH protect, noconstant(0)
 DECLARE num = f8 WITH public, noconstant(uar_get_code_by("MEANING",53,"NUM"))
 DECLARE confirmed = f8 WITH public, noconstant(uar_get_code_by("MEANING",4000160,"CONFIRMED"))
 IF (((num < 0.0) OR (confirmed < 0.0)) )
  CALL echo("FAILURE TO RETRIEVE ALL CODES FROM THE CODE_VALUE TABLE")
  GO TO exit_program
 ENDIF
 IF (validate(inc_size,0)=0)
  SET inc_size = 100000
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="COPY EXISTING IO RESULTS TO IO2G COMPATIBLE - NUMERIC*"
   AND di.info_name="MAX EVENT_ID EVALUATED BY*"
   AND di.info_char != "IN PROCESS"
   AND di.info_char != "SUCCESS"
  HEAD REPORT
   tmp_ptr = 0
  DETAIL
   string_struct->ms_child_rowid = di.rowid, tmp_ptr = findstring("BY ",di.info_name,1),
   string_struct->ms_parent_rowid = trim(substring((tmp_ptr+ 3),18,di.info_name)),
   mf_min_epr_id = di.info_number
  WITH nocounter, forupdatewait(di), maxqual(di,1)
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="COPY EXISTING IO RESULTS TO IO2G COMPATIBLE PARENT - NUMERIC"
    AND di.info_number=0
    AND di.info_name="EVENT_ID RANGE*EVALUATED"
    AND di.info_number != 1
   DETAIL
    string_struct->ms_info_name = di.info_name, string_struct->ms_min_max_string = di.info_char,
    string_struct->ms_parent_rowid = di.rowid
   WITH maxqual(di,1), forupdatewait(di), nocounter
  ;end select
  CALL echo(build("INFO_NAME = ",string_struct->ms_info_name))
  CALL echo(build("INFO_CHAR = ",string_struct->ms_min_max_string))
  IF (curqual=1)
   UPDATE  FROM dm_info di
    SET di.info_number = 1
    WHERE (di.rowid=string_struct->ms_parent_rowid)
    WITH nocounter
   ;end update
   IF (error(string_struct->ms_err_msg,0) != 0)
    CALL echo(concat("FAILED TO OBTAIN ROW LEVEL LOCK ON DM_INFO:",string_struct->ms_err_msg))
    GO TO exit_program
   ENDIF
   COMMIT
   SET ml_end_pos = findstring(":max:",string_struct->ms_min_max_string)
   SET mf_max_epr_id = cnvtreal(substring((ml_end_pos+ 5),textlen(string_struct->ms_min_max_string),
     string_struct->ms_min_max_string))
   CALL echo(build("mf_max_epr_id = ",mf_max_epr_id))
   SET ml_pos = (findstring("min:",string_struct->ms_min_max_string)+ 4)
   SET mf_min_epr_id = cnvtreal(substring(ml_pos,(ml_end_pos - ml_pos),string_struct->
     ms_min_max_string))
   CALL echo(build("mf_min_epr_id = ",mf_min_epr_id))
   INSERT  FROM dm_info di
    SET di.info_domain = "COPY EXISTING IO RESULTS TO IO2G COMPATIBLE - NUMERIC", di.info_name =
     concat("MAX EVENT_ID EVALUATED BY ",string_struct->ms_parent_rowid), di.info_number =
     mf_min_epr_id,
     di.info_date = cnvtdatetime(curdate,curtime3), di.info_char = "IN PROCESS"
    WITH nocounter
   ;end insert
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="COPY EXISTING IO RESULTS TO IO2G COMPATIBLE - NUMERIC"
     AND di.info_name="MAX EVENT_ID EVALUATED BY*"
     AND di.info_char="IN PROCESS"
     AND di.info_number=mf_min_epr_id
    DETAIL
     string_struct->ms_child_rowid = di.rowid
    WITH nocounter
   ;end select
   IF (error(string_struct->ms_err_msg,0) != 0)
    CALL echo(concat("FAILED TO INSERT CHILD ROW IN DM_INFO:",string_struct->ms_err_msg))
    GO TO exit_program
   ENDIF
   COMMIT
  ELSE
   IF (error(string_struct->ms_err_msg,0) != 0)
    CALL echo(concat("FAILED TO LOCK OR FIND PARENT ROW ON DM_INFO FORUPDATE.",string_struct->
      ms_err_msg))
    GO TO exit_program
   ENDIF
   CALL echo("Done processing Numeric.")
   SET mn_success = 1
   SET gn_child_success = 1
   GO TO exit_program
  ENDIF
 ELSE
  UPDATE  FROM dm_info di
   SET di.info_char = "IN PROCESS"
   WHERE (di.rowid=string_struct->ms_child_rowid)
   WITH nocounter
  ;end update
  IF (error(string_struct->ms_err_msg,0) != 0)
   CALL echo(concat("FAILED TO OBTAIN ROW LEVEL LOCK ON DM_INFO:",string_struct->ms_err_msg))
   GO TO exit_program
  ENDIF
  COMMIT
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE (di.rowid=string_struct->ms_parent_rowid)
   DETAIL
    string_struct->ms_info_name = di.info_name, string_struct->ms_min_max_string = di.info_char
   WITH maxqual(di,1), forupdatewait(di), nocounter
  ;end select
  SET ml_end_pos = findstring(":max:",string_struct->ms_min_max_string)
  SET mf_max_epr_id = cnvtreal(substring((ml_end_pos+ 5),textlen(string_struct->ms_min_max_string),
    string_struct->ms_min_max_string))
  CALL echo(build("mf_max_epr_id = ",mf_max_epr_id))
  CALL echo(build("mf_min_epr_id = ",mf_min_epr_id))
 ENDIF
 IF (mf_max_epr_id <= 0)
  CALL echo("AUTO-SUCCESS: THERE WERE NOT ANY EVENT_IDS FOR THIS CHILD TO UPDATE.")
  SET stoptime = datetimediff(cnvtdatetime(curdate,curtime3),starttime,5)
  UPDATE  FROM dm_info di
   SET di.info_char = "SUCCESS", di.updt_applctx = stoptime
   WHERE (di.rowid=string_struct->ms_child_rowid)
   WITH nocounter
  ;end update
  IF (error(string_struct->ms_err_msg,0) != 0)
   CALL echo(concat("FAILED TO UPDATE CHILD ROW IN DM_INFO:",string_struct->ms_err_msg))
   GO TO exit_program
  ENDIF
  SET mn_success = 1
  SET gn_child_success = 1
  COMMIT
  GO TO exit_program
 ENDIF
 SET mf_cur_min_id = mf_min_epr_id
 SET mf_cur_max_id = (mf_cur_min_id+ inc_size)
 WHILE (mf_cur_min_id <= mf_max_epr_id)
   IF (mf_cur_max_id > mf_max_epr_id)
    SET mf_cur_max_id = mf_max_epr_id
   ENDIF
   EXECUTE dcp_copy_io_results_numeric value(mf_cur_min_id), value(mf_cur_max_id)
   IF (gn_child_failed=1)
    GO TO exit_program
   ENDIF
   IF (gn_rollback_seg_failed=1)
    IF (inc_size=min_inc_size)
     CALL echo("ENCOUNTERED ROLLBACK SEGMENT FAILURE; COULD NOT RECOVER...")
     GO TO exit_program
    ENDIF
    SET inc_size = ceil((inc_size/ 2))
    SET mf_cur_max_id = ((mf_cur_min_id+ inc_size) - 1)
    SET gn_rollback_seg_failed = 0
   ELSE
    SET mf_cur_min_id = (mf_cur_max_id+ 1)
    SET mf_cur_max_id = ((mf_cur_min_id+ inc_size) - 1)
   ENDIF
 ENDWHILE
 SET stoptime = datetimediff(cnvtdatetime(curdate,curtime3),starttime,5)
 UPDATE  FROM dm_info di
  SET di.info_char = "SUCCESS", di.updt_applctx = stoptime
  WHERE (di.rowid=string_struct->ms_child_rowid)
  WITH nocounter
 ;end update
 IF (error(string_struct->ms_err_msg,0) != 0)
  CALL echo(concat("FAILED TO UPDATE CHILD ROW IN DM_INFO:",string_struct->ms_err_msg))
  GO TO exit_program
 ENDIF
 COMMIT
 CALL echo(concat("EVENT_IDs ",trim(cnvtstring(mf_min_epr_id))," TO ",trim(cnvtstring(mf_max_epr_id)),
   " HAVE BEEN UPDATED"))
 SET mn_success = 1
 SET gn_child_success = 1
#exit_program
 FREE RECORD string_struct
 IF (mn_success=0)
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 CALL echo(build("ELAPSED TIME IN SECONDS: ",datetimediff(cnvtdatetime(curdate,curtime3),starttime,5)
   ))
END GO
