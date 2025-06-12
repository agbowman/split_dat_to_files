CREATE PROGRAM dm_schema_log:dba
 PAINT
 SET width = 132
 SET dsl_mode_ind = 0
 SET dsl_status = fillstring(20,"")
 SET dsl_header_str = fillstring(80,"*")
 SET dsl_max_colsize = 300
 IF ( NOT (validate(dsl_calling_script,"") IN ("DM_OCD_SCHEMA_LOG", "DM_INSTALL_SCHEMA_LOG")))
  SET message = nowindow
  CALL echo(dsl_header_str)
  CALL echo(
   "This program has to be called from either DM_INSTALL_SCHEMA_LOG or DM_OCD_SCHEMA_LOG.  QUIT PROGRAM..."
   )
  CALL echo(dsl_header_str)
  GO TO end_program
 ENDIF
 CALL clear(1,1)
 CALL box(1,1,3,132)
 IF (dsl_calling_script="DM_OCD_SCHEMA_LOG")
  CALL text(2,3,build("D M  I N S T A L L  S C H E M A  --  L O G   V I E W E R   ( OCD #",dsl_input,
    " )"))
 ELSE
  CALL text(2,3,build("D M  I N S T A L L  S C H E M A  --  L O G   V I E W E R   ( Schema Date : ",
    dsl_input," )"))
 ENDIF
 CALL text(5,3,"1) View log of all Schema Operations.")
 CALL text(6,3,"2) View log of all Successful Schema Operations.")
 CALL text(7,3,"3) View log of all Running Schema Operations.")
 CALL text(8,3,"4) View log of all Failed Schema Operations.")
 CALL text(10,3,">>> Enter selection ('0' to exit): ")
 CALL accept(10,38,"9",1
  WHERE curaccept IN (0, 1, 2, 3, 4))
 CASE (curaccept)
  OF 0:
   GO TO end_program
  OF 1:
   SET dsl_mode_ind = 1
   SET dsl_status = "*"
  OF 2:
   SET dsl_mode_ind = 2
   SET dsl_status = "COMPLETE"
  OF 3:
   SET dsl_mode_ind = 3
   SET dsl_status = "RUNNING"
  OF 4:
   SET dsl_mode_ind = 4
   SET dsl_status = "ERROR"
 ENDCASE
 CALL text(24,2,"Working...")
 SET message = nowindow
 SELECT
  IF (dsl_calling_script="DM_OCD_SCHEMA_LOG"
   AND dsl_mode_ind=1)
   FROM dm_schema_op_log o,
    dm_schema_log d
   WHERE d.ocd=dsl_input
    AND o.run_id=d.run_id
  ELSEIF (dsl_calling_script="DM_OCD_SCHEMA_LOG"
   AND dsl_mode_ind != 1)
   FROM dm_schema_op_log o,
    dm_schema_log d
   WHERE d.ocd=dsl_input
    AND o.run_id=d.run_id
    AND o.status=dsl_status
    AND  NOT ( EXISTS (
   (SELECT
    i.info_name
    FROM dm_info i
    WHERE i.info_domain="DATA MANAGEMENT"
     AND i.info_char="SCHEMA_IGNORED_ERROR"
     AND findstring(i.info_name,o.error_msg) > 0)))
  ELSEIF (dsl_mode_ind=1
   AND disl_utc_ind=1)
   FROM dm_schema_op_log o,
    dm_schema_log d
   WHERE d.schema_date=cnvtdatetimeutc(dsl_input)
    AND o.run_id=d.run_id
  ELSEIF (dsl_mode_ind=1
   AND disl_utc_ind=0)
   FROM dm_schema_op_log o,
    dm_schema_log d
   WHERE d.schema_date=cnvtdatetime(dsl_input)
    AND o.run_id=d.run_id
  ELSEIF (disl_utc_ind=1)
   FROM dm_schema_op_log o,
    dm_schema_log d
   WHERE d.schema_date=cnvtdatetimeutc(dsl_input)
    AND o.run_id=d.run_id
    AND o.status=dsl_status
    AND  NOT ( EXISTS (
   (SELECT
    i.info_name
    FROM dm_info i
    WHERE i.info_domain="DATA MANAGEMENT"
     AND i.info_char="SCHEMA_IGNORED_ERROR"
     AND findstring(i.info_name,o.error_msg) > 0)))
  ELSE
   FROM dm_schema_op_log o,
    dm_schema_log d
   WHERE d.schema_date=cnvtdatetime(dsl_input)
    AND o.run_id=d.run_id
    AND o.status=dsl_status
    AND  NOT ( EXISTS (
   (SELECT
    i.info_name
    FROM dm_info i
    WHERE i.info_domain="DATA MANAGEMENT"
     AND i.info_char="SCHEMA_IGNORED_ERROR"
     AND findstring(i.info_name,o.error_msg) > 0)))
  ENDIF
  o.run_id, o.op_id, o.begin_dt_tm,
  o.end_dt_tm, o.row_cnt
  ORDER BY o.filename, o.op_id
  HEAD REPORT
   SUBROUTINE duration(d_value)
     d_hun = mod(ceil((d_value * 100.0)),100), d_text = concat(trim(format((d_value/ 86400.0),
        "DD.HH:MM:SS;3;Z"),3),".",format(d_hun,"##;P0")),
     CALL print(d_text)
   END ;Subroutine report
   , prev_flag = 0, cur_flag = 0,
   row 0, dsl_header_str
   IF (dsl_mode_ind=1)
    row + 1, "  SCHEMA LOG - ALL OPERATIONS"
   ELSEIF (dsl_mode_ind=2)
    row + 1, "  SCHEMA LOG - ALL SUCCESSFUL OPERATIONS"
   ELSEIF (dsl_mode_ind=3)
    row + 1, "  SCHEMA LOG - ALL RUNNING OPERATIONS"
   ELSE
    row + 1, "  SCHEMA LOG - ALL FAILED OPERATIONS"
   ENDIF
   row + 1, dsl_header_str, row + 1,
   rows_exist = 0
  HEAD o.filename
   prev_flag = 0, cur_flag = 0, row + 1,
   col 1, "-----------", row + 1
   IF (dsl_status="ERROR")
    dsl_fname = fillstring(30," ")
    IF (findstring("2.dat",o.filename))
     dsl_fname = replace(o.filename,"2.dat","3.dat",2)
    ELSE
     dsl_fname = replace(o.filename,"2d.dat","3d.dat",2)
    ENDIF
    col 1, "File Name : ", dsl_fname
   ELSE
    col 1, "File Name : ", o.filename
   ENDIF
   row + 1, col 1, "-----------",
   row + 2, col 1, "Table Name",
   col 33, "Operation Type", col 65,
   "Object Name", col 97, "Status",
   col 110, "Est. Duration", col 125,
   "Act. Duration", row + 1, col 1,
   "----------", col 33, "--------------",
   col 65, "-----------", col 97,
   "------", col 110, "-------------",
   col 125, "-------------", tot_est_time = 0.0,
   tot_act_time = 0.0
  DETAIL
   rows_exist = 1, tot_est_time = (tot_est_time+ o.est_duration), tot_act_time = (tot_act_time+ o
   .act_duration)
   IF (o.begin_dt_tm != null
    AND o.begin_dt_tm < d.gen_dt_tm
    AND prev_flag=0)
    row + 1, col 1, "Previously executed Operations: ",
    prev_flag = 1
   ENDIF
   IF (((o.begin_dt_tm >= d.gen_dt_tm
    AND cur_flag=0) OR (o.begin_dt_tm=null
    AND cur_flag=0)) )
    IF (prev_flag=1)
     row + 2, col 110, "-------------",
     col 125, "-------------", row + 1,
     col 97, "Total Time: ", col 110,
     CALL duration(tot_est_time), col 125,
     CALL duration(tot_act_time),
     row + 1, col 110, "=============",
     col 125, "=============", row + 1,
     tot_est_time = 0.0, tot_act_time = 0.0
    ENDIF
    row + 1, col 1, "Current Operations: ",
    cur_flag = 1
   ENDIF
   row + 1, col 1, o.table_name,
   col 33, o.op_type, col 65,
   o.obj_name, col 97, o.status,
   col 110,
   CALL duration(o.est_duration), col 125,
   CALL duration(o.act_duration)
   IF (o.error_msg != null)
    row + 1, col 3, "Error Message: ",
    col 18, o.error_msg
   ENDIF
  FOOT  o.filename
   row + 2, col 110, "-------------",
   col 125, "-------------", row + 1,
   col 97, "Total Time: ", col 110,
   CALL duration(tot_est_time), col 125,
   CALL duration(tot_act_time),
   row + 1, col 110, "=============",
   col 125, "=============", row + 1
  FOOT REPORT
   IF (rows_exist=0)
    row + 1, "    No Schema Operations found in this status."
   ENDIF
   row + 2, dsl_header_str, row + 1,
   "  END OF SCHEMA LOG", row + 1, dsl_header_str
  WITH nocounter, maxcol = value(dsl_max_colsize), formfeed = none,
   nullreport
 ;end select
#end_program
END GO
