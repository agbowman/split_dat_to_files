CREATE PROGRAM dcp_copy_io_results_iv:dba
 FREE RECORD string_struct_c
 RECORD string_struct_c(
   1 ms_maxqual_string = vc
   1 ms_err_msg = vc
 )
 DECLARE mn_success = i2 WITH protect, noconstant(0)
 DECLARE mf_min_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_max_id = f8 WITH protect, noconstant(0.0)
 SET mf_min_id =  $1
 SET mf_max_id =  $2
 CALL echo("Checking and copying IV results:")
 CALL echo(build("MIN_ID = ",mf_min_id))
 CALL echo(build("MAX_ID = ",mf_max_id))
 CALL parser("rdb asis(^insert into ce_intake_output_result cir ^)")
 CALL parser("asis(^( ^)")
 CALL parser("asis(^		cir.ce_io_result_id, ^)")
 CALL parser("asis(^		cir.io_result_id, ^)")
 CALL parser("asis(^		cir.event_id, ^)")
 CALL parser("asis(^		cir.person_id, ^)")
 CALL parser("asis(^		cir.encntr_id, ^)")
 CALL parser("asis(^		cir.io_type_flag, ^)")
 CALL parser("asis(^		cir.io_volume, ^)")
 CALL parser("asis(^		cir.io_status_cd, ^)")
 CALL parser("asis(^		cir.io_start_dt_tm, ^)")
 CALL parser("asis(^		cir.io_end_dt_tm, ^)")
 CALL parser("asis(^		cir.reference_event_id, ^)")
 CALL parser("asis(^		cir.reference_event_cd, ^)")
 CALL parser("asis(^		cir.valid_from_dt_tm, ^)")
 CALL parser("asis(^		cir.valid_until_dt_tm, ^)")
 CALL parser("asis(^		cir.updt_dt_tm, ^)")
 CALL parser("asis(^		cir.updt_id, ^)")
 CALL parser("asis(^		cir.updt_task, ^)")
 CALL parser("asis(^		cir.updt_cnt, ^)")
 CALL parser("asis(^		cir.updt_applctx ^)")
 CALL parser("asis(^) ^)")
 CALL parser("asis(^( ^)")
 CALL parser("asis(^select ocf_seq.nextval, ^)")
 CALL parser("asis(^		ocf_seq.nextval, ^)")
 CALL parser("asis(^		a.event_id, ^)")
 CALL parser("asis(^		a.person_id, ^)")
 CALL parser("asis(^		a.encntr_id, ^)")
 CALL parser("asis(^		1, ^)")
 CALL parser("asis(^		a.io_volume, ^)")
 CALL parser(concat("asis(^	    ",cnvtstring(confirmed),", ^)"))
 CALL parser("asis(^	a.event_end_dt_tm, ^)")
 CALL parser("asis(^	a.event_end_dt_tm, ^)")
 CALL parser("asis(^	a.event_id, ^)")
 CALL parser("asis(^	a.event_cd, ^)")
 CALL parser("asis(^	sysdate, ^)")
 CALL parser("asis(^a.valid_until_dt_tm, ^)")
 CALL parser("asis(^	sysdate, ^)")
 CALL parser(concat("asis(^		",cnvtstring(reqinfo->updt_id),", ^)"))
 CALL parser("asis(^	-2, ^)")
 CALL parser("asis(^	1, ^)")
 CALL parser("asis(^	0 ^)")
 CALL parser("asis(^from (( ^)")
 CALL parser(
  "asis(^select ce.event_id as event_id, ce.person_id as person_id, ce.encntr_id as encntr_id, ^)")
 CALL parser(concat("asis(^		decode(cmr.dosage_unit_cd, ",cnvtstring(ml),
   ", cmr.admin_dosage, 0.0) + ^)"))
 CALL parser(concat("asis(^			decode(cmr.infused_volume_unit_cd, ",cnvtstring(ml),", ^)"))
 CALL parser("asis(^				cmr.infused_volume, 0.0) as io_volume, ^)")
 CALL parser("asis(^		ce.event_end_dt_tm as event_end_dt_tm, ce.event_cd as event_cd, ^)")
 CALL parser("asis(^		ce.valid_until_dt_tm as valid_until_dt_tm ^)")
 CALL parser("asis(^from clinical_event ce, ce_med_result cmr ^)")
 CALL parser(concat("asis(^where ce.event_id >= ",cnvtstring(mf_min_id)," ^)"))
 CALL parser(concat("asis(^		and ce.event_id <= ",cnvtstring(mf_max_id)," ^)"))
 CALL parser("asis(^		and ce.valid_until_dt_tm = '31-DEC-2100' ^)")
 CALL parser(concat("asis(^		and ce.event_cd = ",cnvtstring(ivparent)," ^)"))
 CALL parser("asis(^		and bitand(ce.subtable_bit_map, 8) = 0 ^)")
 CALL parser("asis(^		and cmr.event_id = ce.event_id ^)")
 CALL parser("asis(^		and cmr.valid_until_dt_tm = '31-DEC-2100' ^)")
 CALL parser(concat("asis(^		and cmr.iv_event_cd in (",cnvtstring(bolus),", ",cnvtstring(infuse),
   ") ^)"))
 CALL parser(concat("asis(^		and (cmr.dosage_unit_cd = ",cnvtstring(ml)," or ^)"))
 CALL parser(concat("asis(^			cmr.infused_volume_unit_cd = ",cnvtstring(ml),") ^)"))
 CALL parser("asis(^) union ( ^)")
 CALL parser(
  "asis(^select ce1.event_id as event_id, ce1.person_id as person_id, ce1.encntr_id as encntr_id, ^)"
  )
 CALL parser(concat("asis(^		decode(cmr.dosage_unit_cd, ",cnvtstring(ml),
   ", cmr.admin_dosage, 0.0) + ^)"))
 CALL parser(concat("asis(^			decode(cmr.infused_volume_unit_cd, ",cnvtstring(ml),", ^)"))
 CALL parser("asis(^				cmr.infused_volume, 0.0) as io_volume, ^)")
 CALL parser("asis(^		ce1.event_end_dt_tm as event_end_dt_tm, ce1.event_cd as event_cd, ^)")
 CALL parser("asis(^		ce1.valid_until_dt_tm as valid_until_dt_tm ^)")
 CALL parser("asis(^from clinical_event ce1, ce_med_result cmr ^)")
 CALL parser(concat("asis(^where ce1.event_id >= ",cnvtstring(mf_min_id)," ^)"))
 CALL parser(concat("asis(^		and ce1.event_id <= ",cnvtstring(mf_max_id)," ^)"))
 CALL parser("asis(^		and ce1.valid_until_dt_tm = '31-DEC-2100' ^)")
 CALL parser(concat("asis(^		and ce1.event_class_cd = ",cnvtstring(med)," ^)"))
 CALL parser(concat("asis(^		and ce1.event_cd != ",cnvtstring(ivparent)," ^)"))
 CALL parser("asis(^		and ce1.view_level = 1 ^)")
 CALL parser("asis(^		and bitand(ce1.subtable_bit_map, 8) = 0 ^)")
 CALL parser(
  "asis(^		and exists(select 1 from clinical_event ce2	where ce2.event_id = ce1.parent_event_id ^)")
 CALL parser("asis(^		and ce2.valid_until_dt_tm = '31-DEC-2100' ^)")
 CALL parser(concat("asis(^		and ce2.event_cd = ",cnvtstring(dcpgeneric)," ^)"))
 CALL parser("asis(^		and ce2.view_level = 0) ^)")
 CALL parser("asis(^		and cmr.event_id = ce1.event_id ^)")
 CALL parser("asis(^		and cmr.valid_until_dt_tm = '31-DEC-2100' ^)")
 CALL parser(concat("asis(^		and cmr.iv_event_cd in (",cnvtstring(bolus),", ",cnvtstring(infuse),
   ") ^)"))
 CALL parser(concat("asis(^		and (cmr.dosage_unit_cd = ",cnvtstring(ml)," or ^)"))
 CALL parser(concat("asis(^			cmr.infused_volume_unit_cd = ",cnvtstring(ml),") ^)"))
 CALL parser("asis(^		and not exists(select 1 from clinical_event ce3, ce_med_result cmr2 ^)")
 CALL parser("asis(^			where ce3.parent_event_id = ce1.event_id ^)")
 CALL parser("asis(^				and ce3.valid_until_dt_tm = '31-DEC-2100' ^)")
 CALL parser(concat("asis(^				and ce3.event_class_cd = ",cnvtstring(med)," ^)"))
 CALL parser("asis(^			and ce3.view_level = 1 ^)")
 CALL parser("asis(^			and cmr2.event_id = ce3.event_id ^)")
 CALL parser("asis(^			and cmr2.valid_until_dt_tm = '31-DEC-2100' ^)")
 CALL parser(concat("asis(^			and cmr2.iv_event_cd in (",cnvtstring(bolus),", ",cnvtstring(infuse),
   ") ^)"))
 CALL parser(concat("asis(^			and (cmr2.dosage_unit_cd = ",cnvtstring(ml)," or ^)"))
 CALL parser(concat("asis(^				cmr2.infused_volume_unit_cd = ",cnvtstring(ml),")) ^)"))
 CALL parser("asis(^) union ( ^)")
 CALL parser(
  "asis(^select ce3.parent_event_id as parent_event_id, ce1.person_id as person_id, ce1.encntr_id as encntr_id, ^)"
  )
 CALL parser(concat("asis(^		max(decode(cmr.dosage_unit_cd, ",cnvtstring(ml),
   ", cmr.admin_dosage, 0.0)) + ^)"))
 CALL parser(concat("asis(^		max(decode(cmr.infused_volume_unit_cd, ",cnvtstring(ml),
   ", cmr.infused_volume, 0.0)) + ^)"))
 CALL parser(concat("asis(^		sum(decode(cmr2.dosage_unit_cd, ",cnvtstring(ml),
   ", cmr2.admin_dosage, 0.0)) + ^)"))
 CALL parser(concat("asis(^		sum(decode(cmr2.infused_volume_unit_cd, ",cnvtstring(ml),", ^)"))
 CALL parser("asis(^					cmr2.infused_volume, 0.0)) as io_volume, ^)")
 CALL parser("asis(^		ce1.event_end_dt_tm as event_end_dt_tm, ce1.event_cd as event_cd, ^)")
 CALL parser("asis(^		ce1.valid_until_dt_tm as valid_until_dt_tm ^)")
 CALL parser("asis(^from clinical_event ce1, ^)")
 CALL parser("asis(^		ce_med_result cmr, ^)")
 CALL parser("asis(^		clinical_event ce3, ^)")
 CALL parser("asis(^		ce_med_result cmr2 ^)")
 CALL parser(concat("asis(^where ce1.event_id >= ",cnvtstring(mf_min_id)," ^)"))
 CALL parser(concat("asis(^		and ce1.event_id <= ",cnvtstring(mf_max_id)," ^)"))
 CALL parser("asis(^		and ce1.valid_until_dt_tm = '31-DEC-2100' ^)")
 CALL parser(concat("asis(^		and ce1.event_class_cd = ",cnvtstring(med)," ^)"))
 CALL parser(concat("asis(^		and ce1.event_cd != ",cnvtstring(ivparent)," ^)"))
 CALL parser("asis(^		and ce1.view_level = 1 ^)")
 CALL parser(
  "asis(^		and exists(select 1 from clinical_event ce2 where ce2.event_id = ce1.parent_event_id ^)")
 CALL parser("asis(^			and ce2.valid_until_dt_tm = '31-DEC-2100' ^)")
 CALL parser(concat("asis(^		and ce2.event_cd = ",cnvtstring(dcpgeneric)," ^)"))
 CALL parser("asis(^					and ce2.view_level = 0) ^)")
 CALL parser("asis(^		and cmr.event_id = ce1.event_id ^)")
 CALL parser("asis(^		and cmr.valid_until_dt_tm = '31-DEC-2100' ^)")
 CALL parser(concat("asis(^		and cmr.iv_event_cd in (",cnvtstring(bolus),", ",cnvtstring(infuse),
   ") ^)"))
 CALL parser(concat("asis(^		and (cmr.dosage_unit_cd = ",cnvtstring(ml)," or ^)"))
 CALL parser(concat("asis(^			cmr.infused_volume_unit_cd = ",cnvtstring(ml),") ^)"))
 CALL parser("asis(^		and ce3.parent_event_id = ce1.event_id ^)")
 CALL parser("asis(^		and ce3.valid_until_dt_tm = '31-DEC-2100' ^)")
 CALL parser(concat("asis(^		and ce3.event_class_cd = ",cnvtstring(med)," ^)"))
 CALL parser("asis(^		and ce3.view_level = 1 ^)")
 CALL parser("asis(^		and cmr2.event_id = ce3.event_id ^)")
 CALL parser("asis(^		and cmr2.valid_until_dt_tm = '31-DEC-2100' ^)")
 CALL parser(concat("asis(^		and cmr2.iv_event_cd in (",cnvtstring(bolus),", ",cnvtstring(infuse),
   ") ^)"))
 CALL parser(concat("asis(^		and (cmr2.dosage_unit_cd = ",cnvtstring(ml)," or ^)"))
 CALL parser(concat("asis(^			cmr2.infused_volume_unit_cd = ",cnvtstring(ml),") ^)"))
 CALL parser(
  "asis(^group by ce3.parent_event_id, ce1.person_id, ce1.encntr_id, ce1.event_end_dt_tm, ^)")
 CALL parser("asis(^		ce1.event_cd, ce1.valid_until_dt_tm)) a) ^) go")
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
   WHERE ce.event_id >= mf_min_id
    AND ce.event_id <= mf_max_id
    AND  EXISTS (
   (SELECT
    cir.event_id
    FROM ce_intake_output_result cir
    WHERE cir.event_id=ce.event_id
     AND cir.valid_until_dt_tm=ce.valid_until_dt_tm
     AND cir.io_start_dt_tm=ce.event_end_dt_tm
     AND (cir.updt_task=- (2))))
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
   CALL echo(concat("FAILURE DURING CLINICAL_EVENT UPDATE:",string_struct_c->ms_err_msg))
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
