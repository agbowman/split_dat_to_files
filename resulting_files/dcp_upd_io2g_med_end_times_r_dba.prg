CREATE PROGRAM dcp_upd_io2g_med_end_times_r:dba
 FREE RECORD dm_sql_reply
 RECORD dm_sql_reply(
   1 status = c1
   1 msg = vc
 )
 FREE RECORD struct_p
 RECORD struct_p(
   1 ms_err_msg = vc
   1 ms_spawn1_info_char = vc
   1 ms_spawn2_info_char = vc
   1 ms_spawn3_info_char = vc
 )
 DECLARE child_success_ind = i2 WITH public, noconstant(0)
 DECLARE child_proc_rows = i4 WITH protect, noconstant(0)
 DECLARE child_proc_success_cnt = i4 WITH protect, noconstant(0)
 DECLARE success_ind = i2 WITH protect, noconstant(0)
 DECLARE write_dm_info(null) = null WITH protect
 DECLARE spawn_child_proc(null) = null WITH protect
 DECLARE check_sql_proc(name=vc,type=vc) = null WITH protect
 DECLARE insert_dm_info(info_domain=vc,info_name=vc,info_char=vc) = null WITH protect
 DECLARE update_dm_info(info_domain=vc,info_name=vc,info_char=vc) = null WITH protect
 SELECT INTO "nl:"
  FROM dm_info dm
  WHERE dm.info_domain="UPDATE EXISTING IO2G MED RESULTS PARENT*"
  DETAIL
   child_proc_rows = (child_proc_rows+ 1)
  WITH nocounter
 ;end select
 IF (error(struct_p->ms_err_msg,0) != 0)
  CALL echo(concat("FAILED TO RETRIEVE SETUP INFO FROM DM_INFO:",cnvtupper(struct_p->ms_err_msg)))
  GO TO exit_program
 ENDIF
 IF (child_proc_rows=3)
  CALL spawn_child_proc(null)
 ELSE
  CALL write_dm_info(null)
  CALL spawn_child_proc(null)
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info dm
  WHERE dm.info_domain="UPDATE EXISTING IO2G MED RESULTS*"
   AND dm.info_name="MAX EVENT_ID EVALUATED BY*"
  DETAIL
   IF (dm.info_char="SUCCESS")
    child_proc_success_cnt = (child_proc_success_cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 IF (child_proc_success_cnt=3)
  CALL echo("***************************************************************")
  CALL echo("ALL SESSIONS SUCCESSFULLY COMPLETED")
  CALL echo("***************************************************************")
  CALL parser("rdb drop procedure upd_io2g_med_end_time_p go")
  CALL parser("rdb drop function upd_io2g_med_end_time go")
 ELSE
  CALL echo("***************************************************************")
  CALL echo("THIS SESSION COMPLETED SUCCESSFULLY")
  CALL echo(concat((3 - child_proc_success_cnt)," SESSION(S) STILL IN PROCESS"))
  CALL echo("***************************************************************")
 ENDIF
 SET success_ind = 1
 SUBROUTINE spawn_child_proc(null)
  DECLARE spawn_cnt = i4 WITH protect, noconstant(0)
  FOR (spawn_cnt = 1 TO 3)
   EXECUTE dcp_upd_io2g_med_end_times_c
   IF (child_success_ind=0)
    CALL echo("THE CHILD PROCESS HAS ENCOUNTERED AN ERROR")
    GO TO exit_program
   ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE write_dm_info(null)
   DECLARE range_min_id = f8 WITH protect, noconstant(1.0)
   DECLARE range_max_id = f8 WITH protect, noconstant(0.0)
   DECLARE range1_min_id = f8 WITH protect, noconstant(0.0)
   DECLARE range1_max_id = f8 WITH protect, noconstant(0.0)
   DECLARE range2_min_id = f8 WITH protect, noconstant(0.0)
   DECLARE range2_max_id = f8 WITH protect, noconstant(0.0)
   DECLARE range3_min_id = f8 WITH protect, noconstant(0.0)
   DECLARE range3_max_id = f8 WITH protect, noconstant(0.0)
   CALL echo("DETERMINING THE MIN/MAX EVENT_ID ON CE_INTAKE_OUTPUT_RESULT...")
   SELECT INTO "nl:"
    min_id = min(cir.event_id)
    FROM ce_intake_output_result cir
    WHERE cir.event_id > 0.0
     AND cir.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND cir.io_type_flag=1
    DETAIL
     range_min_id = min_id
    WITH nocounter
   ;end select
   IF (error(struct_p->ms_err_msg,0) != 0)
    CALL echo(concat("FAILED TO DETERMINE MIN EVENT_ID:",cnvtupper(struct_p->ms_err_msg)))
    GO TO exit_program
   ENDIF
   SELECT INTO "nl:"
    max_id = max(cir.event_id)
    FROM ce_intake_output_result cir
    WHERE cir.event_id > 0.0
     AND cir.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND cir.io_type_flag=1
    DETAIL
     range_max_id = max_id
    WITH nocounter
   ;end select
   IF (error(struct_p->ms_err_msg,0) != 0)
    CALL echo(concat("FAILED TO DETERMINE MAX EVENT_ID:",cnvtupper(struct_p->ms_err_msg)))
    GO TO exit_program
   ENDIF
   CALL echo("PERFORMING INITIAL DM_INFO SETUP...")
   SET range_size = ceil(((range_max_id - range_min_id)/ 3))
   SET range1_min_id = range_min_id
   SET range1_max_id = ((range_min_id+ range_size) - 1)
   SET range2_min_id = (range1_max_id+ 1)
   SET range2_max_id = ((range1_max_id+ range_size) - 1)
   SET range3_min_id = (range2_max_id+ 1)
   SET range3_max_id = range_max_id
   SET struct_p->ms_spawn1_info_char = concat("min:",cnvtstring(range1_min_id),":max:",cnvtstring(
     range1_max_id))
   SET struct_p->ms_spawn2_info_char = concat("min:",cnvtstring(range2_min_id),":max:",cnvtstring(
     range2_max_id))
   SET struct_p->ms_spawn3_info_char = concat("min:",cnvtstring(range3_min_id),":max:",cnvtstring(
     range3_max_id))
   CALL echo(struct_p->ms_spawn1_info_char)
   CALL echo(struct_p->ms_spawn2_info_char)
   CALL echo(struct_p->ms_spawn3_info_char)
   IF (error(struct_p->ms_err_msg,0) != 0)
    CALL echo(concat("DM_INFO SETUP FAILED:",cnvtupper(struct_p->ms_err_msg)))
    GO TO exit_program
   ENDIF
   CALL insert_dm_info("UPDATE EXISTING IO2G MED RESULTS PARENT - IO_END_DT_TM",
    "EVENT_ID RANGE 1 EVALUATED",struct_p->ms_spawn1_info_char)
   CALL insert_dm_info("UPDATE EXISTING IO2G MED RESULTS PARENT - IO_END_DT_TM",
    "EVENT_ID RANGE 2 EVALUATED",struct_p->ms_spawn2_info_char)
   CALL insert_dm_info("UPDATE EXISTING IO2G MED RESULTS PARENT - IO_END_DT_TM",
    "EVENT_ID RANGE 3 EVALUATED",struct_p->ms_spawn3_info_char)
   CALL echo("INSTALLING SQL FUNCTIONS/PROCEDURES...")
   EXECUTE dm_readme_include_sql "cer_install:upd_io2g_med_end_time_proc.sql"
   EXECUTE dm_readme_include_sql "cer_install:upd_io2g_med_end_time_func.sql"
   CALL check_sql_proc("upd_io2g_med_end_time_p","procedure")
   CALL check_sql_proc("upd_io2g_med_end_time","function")
 END ;Subroutine
 SUBROUTINE check_sql_proc(name,type)
  EXECUTE dm_readme_include_sql_chk cnvtupper(value(name)), value(type)
  IF ((dm_sql_reply->status="F"))
   CALL echo(concat("INSTALL FAILED FOR SQL FUNCTION/PROCEDURE: ",cnvtupper(name)))
   CALL echo("EXITTING")
   GO TO exit_program
  ENDIF
 END ;Subroutine
 SUBROUTINE insert_dm_info(info_domain,info_name,info_char)
  INSERT  FROM dm_info dm
   SET dm.info_domain = info_domain, dm.info_name = info_name, dm.info_char = info_char,
    dm.info_number = 0, dm.info_date = cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
  IF (error(struct_p->ms_err_msg,0) != 0)
   CALL echo(concat("FAILED TO INSERT RANGE INTO DM_INFO TABLE:",cnvtupper(struct_p->ms_err_msg)))
   CALL echo("EXITTING")
   GO TO exit_program
  ENDIF
 END ;Subroutine
 SUBROUTINE update_dm_info(info_domain,info_name,info_char)
  UPDATE  FROM dm_info dm
   SET dm.info_number = 0, dm.info_date = cnvtdatetime(curdate,curtime3), dm.info_char = info_char
   WHERE dm.info_domain=info_domain
    AND dm.info_name=info_name
   WITH nocounter
  ;end update
  IF (error(struct_p->ms_err_msg,0) != 0)
   CALL echo(concat("FAILED TO UPDATE RANGE ON DM_INFO TABLE:",cnvtupper(struct_p->ms_err_msg)))
   CALL echo("EXITTING")
   GO TO exit_program
  ENDIF
 END ;Subroutine
#exit_program
 IF (success_ind=0)
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 FREE RECORD struct_p
END GO
