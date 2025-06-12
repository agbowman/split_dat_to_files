CREATE PROGRAM dcp_copy_io_results_numeric:dba
 FREE RECORD string_struct_c
 RECORD string_struct_c(
   1 ms_maxqual_string = vc
   1 ms_err_msg = vc
 )
 DECLARE mn_success = i2 WITH protect, noconstant(0)
 DECLARE mf_min_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_max_id = f8 WITH protect, noconstant(0.0)
 DECLARE inerror = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE dcp_parse_numeric_string() = f8
 SET mf_min_id =  $1
 SET mf_max_id =  $2
 CALL echo("Checking and copying numeric results:")
 CALL echo(build("MIN_ID = ",mf_min_id))
 CALL echo(build("MAX_ID = ",mf_max_id))
 INSERT  FROM ce_intake_output_result cir
  (cir.ce_io_result_id, cir.io_result_id, cir.event_id,
  cir.person_id, cir.encntr_id, cir.io_type_flag,
  cir.io_volume, cir.io_status_cd, cir.io_start_dt_tm,
  cir.io_end_dt_tm, cir.reference_event_id, cir.reference_event_cd,
  cir.valid_from_dt_tm, cir.valid_until_dt_tm, cir.updt_dt_tm,
  cir.updt_id, cir.updt_task, cir.updt_cnt,
  cir.updt_applctx)(SELECT
   seq(ocf_seq,nextval), seq(ocf_seq,nextval), ce.event_id,
   ce.person_id, ce.encntr_id, vesca.event_set_collating_seq,
   x = dcp_parse_numeric_string(ce.result_val), confirmed, ce.event_end_dt_tm,
   ce.event_end_dt_tm, ce.event_id, ce.event_cd,
   cnvtdatetime(curdate,curtime3), ce.valid_until_dt_tm, cnvtdatetime(curdate,curtime3),
   reqinfo->updt_id, - (1), 1,
   0
   FROM clinical_event ce,
    v500_event_set_canon vesca,
    v500_event_set_explode vese,
    v500_event_code vec,
    v500_event_set_explode vese2,
    v500_event_set_code vesc2
   WHERE ce.event_id >= mf_min_id
    AND ce.event_id <= mf_max_id
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
    AND ce.event_class_cd=num
    AND ce.view_level=1
    AND ce.result_status_cd != inerror
    AND sqlpassthru("bitand(ce.subtable_bit_map,8)=0")
    AND substring(1,1,ce.result_val) IN ("0", "1", "2", "3", "4",
   "5", "6", "7", "8", "9",
   ".", "-", "+")
    AND vec.event_cd=ce.event_cd
    AND vese.event_cd=vec.event_cd
    AND vesca.event_set_cd=vese.event_set_cd
    AND (vesca.parent_event_set_cd=event_sets->sets[1].event_set_cd)
    AND (vese2.event_cd=(vec.event_cd+ 0))
    AND vese2.event_set_level=0
    AND (vesc2.event_set_cd=(vese2.event_set_cd+ 0))
    AND vesc2.accumulation_ind=1)
  WITH nocounter
 ;end insert
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  IF (((findstring("ORA-01555",string_struct_c->ms_err_msg) != 0) OR (((findstring("ORA-01650",
   string_struct_c->ms_err_msg) != 0) OR (findstring("ORA-01562",string_struct_c->ms_err_msg) != 0))
  )) )
   ROLLBACK
   SET gn_rollback_seg_failed = 1
   CALL echo("TRAPPED ROLLBACK SEGMENT ERROR......RESTRUCTURING README")
   GO TO exit_program
  ENDIF
  CALL echo(concat("FAILURE DURING CE_INTAKE_OUTPUT_RESULT INSERT:",string_struct_c->ms_err_msg))
  SET gn_child_failed = 1
  GO TO exit_program
 ENDIF
 IF (curqual > 0)
  UPDATE  FROM clinical_event ce
   SET ce.subtable_bit_map = sqlpassthru("ce.subtable_bit_map-bitand(ce.subtable_bit_map,8)+8")
   WHERE list(ce.event_id,ce.valid_until_dt_tm,ce.event_end_dt_tm) IN (
   (SELECT
    cir.event_id, cir.valid_until_dt_tm, cir.io_start_dt_tm
    FROM ce_intake_output_result cir
    WHERE cir.event_id >= mf_min_id
     AND cir.event_id <= mf_max_id
     AND (cir.updt_task=- (1))))
   WITH nocounter
  ;end update
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   IF (((findstring("ORA-01555",string_struct_c->ms_err_msg) != 0) OR (((findstring("ORA-01650",
    string_struct_c->ms_err_msg) != 0) OR (findstring("ORA-01562",string_struct_c->ms_err_msg) != 0
   )) )) )
    ROLLBACK
    SET gn_rollback_seg_failed = 1
    CALL echo("TRAPPED ROLLBACK SEGMENT ERROR......RESTRUCTURING README")
    GO TO exit_program
   ENDIF
   CALL echo(concat("FAILURE DURING CE_INTAKE_OUTPUT_RESULT INSERT:",string_struct_c->ms_err_msg))
   SET gn_child_failed = 1
   GO TO exit_program
  ENDIF
 ENDIF
 UPDATE  FROM dm_info di
  SET di.info_number = mf_max_id, di.info_date = cnvtdatetime(curdate,curtime3)
  WHERE (di.rowid=string_struct->ms_child_rowid)
  WITH nocounter
 ;end update
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  CALL echo(concat("FAILED TRYING TO UPDATE DM_INFO TABLE WITH NEW MINIMUM ID:",string_struct_c->
    ms_err_msg))
  SET gn_child_failed = 1
  GO TO exit_program
 ENDIF
 SET mn_success = 1
#exit_program
 IF (mn_success=0)
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
END GO
