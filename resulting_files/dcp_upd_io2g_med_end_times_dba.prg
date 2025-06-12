CREATE PROGRAM dcp_upd_io2g_med_end_times:dba
 SET child_failed_ind = 1
 FREE RECORD struct_r
 RECORD struct_r(
   1 ms_maxqual_string = vc
   1 ms_err_msg = vc
 )
 DECLARE success_ind = i2 WITH protect, noconstant(0)
 DECLARE range_min_id = f8 WITH protect, noconstant(0.0)
 DECLARE range_max_id = f8 WITH protect, noconstant(0.0)
 DECLARE upd_io2g_med_end_time() = dq8
 SET range_min_id =  $1
 SET range_max_id =  $2
 CALL echo(build("MIN EVENT_ID = ",range_min_id))
 CALL echo(build("MAX EVENT_ID = ",range_max_id))
 UPDATE  FROM ce_intake_output_result cir
  SET cir.io_end_dt_tm = upd_io2g_med_end_time(cir.io_start_dt_tm,cir.io_end_dt_tm), cir.updt_task =
   - (8), cir.updt_cnt = (cir.updt_cnt+ 1),
   cir.updt_dt_tm = cnvtdatetime(curdate,curtime3), cir.updt_id = reqinfo->updt_id, cir.updt_applctx
    = 0
  WHERE cir.event_id >= range_min_id
   AND cir.event_id <= range_max_id
   AND cir.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
   AND cir.io_type_flag=1
   AND (cir.updt_task != - (8))
   AND  EXISTS (
  (SELECT
   1
   FROM clinical_event ce
   WHERE ce.event_id=cir.event_id
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
    AND ce.event_class_cd=io))
  WITH nocounter
 ;end update
 IF (error(struct_r->ms_err_msg,0) != 0)
  IF (((findstring("ORA-01555",struct_r->ms_err_msg) != 0) OR (((findstring("ORA-01650",struct_r->
   ms_err_msg) != 0) OR (findstring("ORA-01562",struct_r->ms_err_msg) != 0)) )) )
   ROLLBACK
   SET seg_rollback_ind = 1
   SET child_failed_ind = 0
   CALL echo("CAUGHT ROLLBACK SEGMENT ERROR......TRYING TO RESTRUCTURE RANGE")
   GO TO exit_program
  ENDIF
  CALL echo(concat("UPDATE TO CE_INTAKE_OUTPUT_RESULT TABLE FAILED:",cnvtupper(struct_r->ms_err_msg))
   )
  GO TO exit_program
 ENDIF
 IF (curqual > 0)
  UPDATE  FROM clinical_event ce
   SET ce.event_end_dt_tm = upd_io2g_med_end_time(ce.event_start_dt_tm,ce.event_end_dt_tm), ce
    .updt_task = - (8), ce.updt_cnt = (ce.updt_cnt+ 1),
    ce.updt_dt_tm = cnvtdatetime(curdate,curtime3), ce.updt_id = reqinfo->updt_id, ce.updt_applctx =
    0
   WHERE ce.event_id >= range_min_id
    AND ce.event_id <= range_max_id
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
    AND ce.event_class_cd=io
    AND sqlpassthru("bitand(ce.subtable_bit_map,8)=8")
    AND (ce.updt_task != - (8))
   WITH nocounter
  ;end update
  IF (error(struct_r->ms_err_msg,0) != 0)
   IF (((findstring("ORA-01555",struct_r->ms_err_msg) != 0) OR (((findstring("ORA-01650",struct_r->
    ms_err_msg) != 0) OR (findstring("ORA-01562",struct_r->ms_err_msg) != 0)) )) )
    ROLLBACK
    SET seg_rollback_ind = 1
    SET child_failed_ind = 0
    CALL echo("TRAPPED ROLLBACK SEGMENT ERROR......TRYING TO RESTRUCTURE RANGE")
    GO TO exit_program
   ENDIF
   CALL echo(concat("UPDATE TO CLINICAL EVENT TABLE FAILED:",cnvtupper(struct_r->ms_err_msg)))
   GO TO exit_program
  ENDIF
 ENDIF
 UPDATE  FROM dm_info dm
  SET dm.info_number = range_max_id, dm.info_date = cnvtdatetime(curdate,curtime3)
  WHERE (dm.rowid=struct_c->ms_child_rowid)
  WITH nocounter
 ;end update
 IF (error(struct_r->ms_err_msg,0) != 0)
  CALL echo(concat("FAILED TRYING TO UPDATE DM_INFO TABLE WITH NEW MINIMUM ID:",cnvtupper(struct_r->
     ms_err_msg)))
  GO TO exit_program
 ENDIF
 SET success_ind = 1
 SET child_failed_ind = 0
#exit_program
 IF (success_ind=0)
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
END GO
