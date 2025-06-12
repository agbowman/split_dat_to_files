CREATE PROGRAM dcp_copy_io_results_med:dba
 FREE RECORD string_struct_c
 RECORD string_struct_c(
   1 ms_maxqual_string = vc
   1 ms_err_msg = vc
 )
 DECLARE mn_success = i2 WITH protect, noconstant(0)
 DECLARE mf_min_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_max_id = f8 WITH protect, noconstant(0.0)
 DECLARE inerror = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 SET mf_min_id =  $1
 SET mf_max_id =  $2
 CALL echo("Checking and copying med results:")
 CALL echo(build("MIN_ID = ",mf_min_id))
 CALL echo(build("MAX_ID = ",mf_max_id))
 CALL parser('rdb asis("insert into dcp_copy_meds_temp dcmt")')
 CALL parser('asis("(")')
 CALL parser('asis("    dcmt.unique_id,")')
 CALL parser('asis("    dcmt.parent_id,")')
 CALL parser('asis("    dcmt.io_volume")')
 CALL parser('asis(")")')
 CALL parser('asis("(select clinical_event_seq.nextval,")')
 CALL parser('asis("    css.event_id,")')
 CALL parser('asis("    nvl(css.b_sum,nvl(css.a_sum,0)) as volume")')
 CALL parser('asis("from")')
 CALL parser('asis("    ((select sum(a.y) as a_sum,sum(b.z) as b_sum,ce2.event_id as event_id from")'
  )
 CALL parser('asis("    ((")')
 CALL parser('asis("          select sum(cmr.admin_dosage) as y,")')
 CALL parser('asis("		         cmr.event_id as event_id")')
 CALL parser('asis("          from ce_med_result cmr")')
 CALL parser(concat("asis(^where cmr.event_id >= ",cnvtstring(mf_min_id),"^)"))
 CALL parser(concat("asis(^    and cmr.event_id <= ",cnvtstring(mf_max_id),"^)"))
 CALL parser(^asis("          and cmr.valid_until_dt_tm = '31-DEC-2100'")^)
 CALL parser('asis("              and (cmr.iv_event_cd = 0.0 or cmr.iv_event_cd is NULL)")')
 CALL parser(concat("asis(^              and (cmr.admin_dosage > 0.0 and cmr.dosage_unit_cd = ",
   cnvtstring(ml),")^)"))
 CALL parser('asis("          group by event_id )) a,")')
 CALL parser('asis("    ((")')
 CALL parser('asis("          select sum(cmr.infused_volume) as z,")')
 CALL parser('asis("              cmr.event_id as event_id")')
 CALL parser('asis("	         from ce_med_result cmr")')
 CALL parser(concat("asis(^where cmr.event_id >= ",cnvtstring(mf_min_id),"^)"))
 CALL parser(concat("asis(^    and cmr.event_id <= ",cnvtstring(mf_max_id),"^)"))
 CALL parser(^asis("          and cmr.valid_until_dt_tm = '31-DEC-2100'")^)
 CALL parser('asis("              and (cmr.iv_event_cd = 0.0 or cmr.iv_event_cd is NULL)")')
 CALL parser(concat(
   "asis(^              and (cmr.infused_volume > 0.0 and cmr.infused_volume_unit_cd = ",cnvtstring(
    ml),")^)"))
 CALL parser('asis("          group by event_id )) b,")')
 CALL parser('asis("    clinical_event ce1,")')
 CALL parser('asis("    clinical_event ce2,")')
 CALL parser('asis("    ce_result_set_link crsl")')
 CALL parser(concat("asis(^where ce1.event_id >= ",cnvtstring(mf_min_id),"^)"))
 CALL parser(concat("asis(^    and ce1.event_id <= ",cnvtstring(mf_max_id),"^)"))
 CALL parser(^asis("    and ce1.valid_until_dt_tm = '31-DEC-2100'")^)
 CALL parser(concat("asis(^    and ce1.event_class_cd = ",cnvtstring(med),"^)"))
 CALL parser(concat("asis(^    and ce1.event_cd != ",cnvtstring(ivparent),"^)"))
 CALL parser(concat("asis(^    and ce1.result_status_cd != ",cnvtstring(inerror),"^)"))
 CALL parser(
  'asis("    and exists(select 1 from dcp_copy_medsin_temp dcmit where dcmit.event_cd = ce1.event_cd)")'
  )
 CALL parser('asis("    and ce1.view_level = 1")')
 CALL parser('asis("    and bitand(ce1.subtable_bit_map,8) = 0")')
 CALL parser('asis("    and exists(select 1")')
 CALL parser('asis("               from ce_med_result cmr")')
 CALL parser('asis("               where cmr.event_id = ce1.event_id")')
 CALL parser(^asis("                   and cmr.valid_until_dt_tm = '31-DEC-2100'")^)
 CALL parser('asis("                       and (cmr.iv_event_cd = 0.0 or cmr.iv_event_cd is NULL)")')
 CALL parser(concat("asis(^and (cmr.dosage_unit_cd = ",cnvtstring(ml),
   " or cmr.infused_volume_unit_cd = ",cnvtstring(ml),"))^)"))
 CALL parser('asis("    and ce2.event_id = ce1.parent_event_id")')
 CALL parser(^asis("    and ce2.valid_until_dt_tm = '31-DEC-2100'")^)
 CALL parser(concat("asis(^    and ce2.result_status_cd != ",cnvtstring(inerror),"^)"))
 CALL parser(concat("asis(^    and ce2.event_cd = ",cnvtstring(dcpgeneric),"^)"))
 CALL parser('asis("    and ce2.view_level = 0")')
 CALL parser('asis("    and not exists(select 1")')
 CALL parser('asis("                   from ce_intake_output_result cir")')
 CALL parser('asis("                   where cir.person_id = ce2.person_id")')
 CALL parser(^asis("                           and cir.valid_until_dt_tm = '31-DEC-2100'")^)
 CALL parser('asis("					              and cir.reference_event_id = ce2.event_id)")')
 CALL parser('asis("    and crsl.event_id (+)= ce2.event_id")')
 CALL parser('asis("    and crsl.event_id (+)> 0.0")')
 CALL parser(^asis("    and crsl.valid_until_dt_tm (+)= '31-DEC-2100'")^)
 CALL parser(concat("asis(^    and crsl.entry_type_cd (+)!= ",cnvtstring(medadmin),"^)"))
 CALL parser('asis("    and a.event_id (+)= ce1.event_id")')
 CALL parser('asis("    and b.event_id (+)= ce1.event_id")')
 CALL parser('asis("group by ce2.event_id)) css)") go')
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  IF (((findstring("ORA-01555",string_struct_c->ms_err_msg) != 0) OR (((findstring("ORA-01650",
   string_struct_c->ms_err_msg) != 0) OR (findstring("ORA-01562",string_struct_c->ms_err_msg) != 0))
  )) )
   ROLLBACK
   SET gn_rollback_seg_failed = 1
   CALL echo("TRAPPED ROLLBACK SEGMENT ERROR......RESTRUCTURING README")
   GO TO exit_program
  ENDIF
  CALL echo(concat("FAILED INSERTING INTO TEMP TABLE DCP_COPY_MEDS_TEMP:",string_struct_c->ms_err_msg
    ))
  SET gn_child_failed = 1
  GO TO exit_program
 ENDIF
 IF (curqual > 0)
  INSERT  FROM ce_result_set_link crsl1
   (crsl1.entry_type_cd, crsl1.event_id, crsl1.result_set_id,
   crsl1.valid_from_dt_tm, crsl1.valid_until_dt_tm, crsl1.updt_dt_tm,
   crsl1.updt_id, crsl1.updt_task, crsl1.updt_cnt,
   crsl1.updt_applctx)(SELECT
    medadmin, ce.event_id, seq(result_set_seq,nextval),
    ce.valid_from_dt_tm, ce.valid_until_dt_tm, sysdate,
    reqinfo->updt_id, - (3), 1,
    0
    FROM dcp_copy_meds_temp dcmt,
     clinical_event ce
    WHERE ((ce.event_id=dcmt.parent_id) OR (ce.parent_event_id=dcmt.parent_id))
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND  NOT ( EXISTS (
    (SELECT
     1
     FROM ce_result_set_link crsl2
     WHERE crsl2.event_id=ce.event_id
      AND crsl2.entry_type_cd=medadmin))))
   WITH nocounter
  ;end insert
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   IF (((findstring("ORA-01555",string_struct_c->ms_err_msg) != 0) OR (((findstring("ORA-01650",
    string_struct_c->ms_err_msg) != 0) OR (findstring("ORA-01562",string_struct_c->ms_err_msg) != 0
   )) )) )
    ROLLBACK
    SET gn_rollback_seg_failed = 1
    CALL echo("TRAPPED ROLLBACK SEGMENT ERROR......RESTRUCTURING README")
    GO TO exit_program
   ENDIF
   CALL echo(concat("FAILED INSERTING INTO TABLE CE_RESULT_SET_LINK:",string_struct_c->ms_err_msg))
   SET gn_child_failed = 1
   GO TO exit_program
  ENDIF
  INSERT  FROM clinical_event ce
   (ce.clinical_event_id, ce.person_id, ce.encntr_id,
   ce.event_id, ce.event_cd, ce.parent_event_id,
   ce.contributor_system_cd, ce.event_class_cd, ce.event_reltn_cd,
   ce.record_status_cd, ce.result_status_cd, ce.entry_mode_cd,
   ce.view_level, ce.publish_flag, ce.result_val,
   ce.event_tag, ce.reference_nbr, ce.event_end_dt_tm,
   ce.event_end_tz, ce.valid_from_dt_tm, ce.valid_until_dt_tm,
   ce.subtable_bit_map, ce.updt_dt_tm, ce.updt_id,
   ce.updt_task, ce.updt_cnt, ce.updt_applctx)(SELECT
    seq(clinical_event_seq,nextval), ce.person_id, ce.encntr_id,
    dcmt.unique_id, medintake, dcmt.unique_id,
    powerchart89, io, root,
    active, auth, medadmin,
    1, 1, dcmt.io_volume,
    dcmt.io_volume, trim(cnvtstring(dcmt.unique_id,30,0),3), ce.event_end_dt_tm,
    ce.event_end_tz, ce.valid_from_dt_tm, ce.valid_until_dt_tm,
    8, sysdate, reqinfo->updt_id,
    0, 1, 0
    FROM dcp_copy_meds_temp dcmt,
     clinical_event ce
    WHERE ce.event_id=dcmt.parent_id
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
   WITH nocounter
  ;end insert
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   IF (((findstring("ORA-01555",string_struct_c->ms_err_msg) != 0) OR (((findstring("ORA-01650",
    string_struct_c->ms_err_msg) != 0) OR (findstring("ORA-01562",string_struct_c->ms_err_msg) != 0
   )) )) )
    ROLLBACK
    SET gn_rollback_seg_failed = 1
    CALL echo("TRAPPED ROLLBACK SEGMENT ERROR......RESTRUCTURING README")
    GO TO exit_program
   ENDIF
   CALL echo(concat("FAILED INSERTING INTO TABLE CLINICAL EVENT:",string_struct_c->ms_err_msg))
   SET gn_child_failed = 1
   GO TO exit_program
  ENDIF
  INSERT  FROM ce_intake_output_result cir
   (cir.ce_io_result_id, cir.io_result_id, cir.event_id,
   cir.person_id, cir.encntr_id, cir.io_type_flag,
   cir.io_volume, cir.io_status_cd, cir.io_start_dt_tm,
   cir.io_end_dt_tm, cir.reference_event_id, cir.reference_event_cd,
   cir.valid_from_dt_tm, cir.valid_until_dt_tm, cir.updt_dt_tm,
   cir.updt_id, cir.updt_task, cir.updt_cnt,
   cir.updt_applctx)(SELECT
    seq(ocf_seq,nextval), seq(ocf_seq,nextval), dcmt.unique_id,
    ce.person_id, ce.encntr_id, 1,
    dcmt.io_volume, confirmed, ce.event_end_dt_tm,
    ce.event_end_dt_tm, dcmt.parent_id, dcpgeneric,
    cnvtdatetime(curdate,curtime3), cnvtdatetime("31-DEC-2100"), cnvtdatetime(curdate,curtime3),
    reqinfo->updt_id, 0, 1,
    0
    FROM dcp_copy_meds_temp dcmt,
     clinical_event ce
    WHERE ce.event_id=dcmt.parent_id
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
   WITH nocounter
  ;end insert
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   IF (((findstring("ORA-01555",string_struct_c->ms_err_msg) != 0) OR (((findstring("ORA-01650",
    string_struct_c->ms_err_msg) != 0) OR (findstring("ORA-01562",string_struct_c->ms_err_msg) != 0
   )) )) )
    ROLLBACK
    SET gn_rollback_seg_failed = 1
    CALL echo("TRAPPED ROLLBACK SEGMENT ERROR......RESTRUCTURING README")
    GO TO exit_program
   ENDIF
   CALL echo(concat("FAILED INSERTING INTO TABLE CE_INTAKE_OUTPUT_RESULT:",string_struct_c->
     ms_err_msg))
   SET gn_child_failed = 1
   GO TO exit_program
  ENDIF
  INSERT  FROM ce_result_set_link crsl1
   (crsl1.entry_type_cd, crsl1.event_id, crsl1.result_set_id,
   crsl1.valid_from_dt_tm, crsl1.valid_until_dt_tm, crsl1.updt_dt_tm,
   crsl1.updt_id, crsl1.updt_task, crsl1.updt_cnt,
   crsl1.updt_applctx)(SELECT
    medadmin, dcmt.unique_id, crsl2.result_set_id,
    ce.valid_from_dt_tm, ce.valid_until_dt_tm, cnvtdatetime(curdate,curtime3),
    reqinfo->updt_id, 0, 1,
    0
    FROM dcp_copy_meds_temp dcmt,
     clinical_event ce,
     ce_result_set_link crsl2
    WHERE ce.event_id=dcmt.parent_id
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND crsl2.event_id=ce.event_id
     AND (crsl2.updt_task=- (3))
     AND crsl2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND crsl2.entry_type_cd=medadmin)
   WITH nocounter
  ;end insert
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   IF (((findstring("ORA-01555",string_struct_c->ms_err_msg) != 0) OR (((findstring("ORA-01650",
    string_struct_c->ms_err_msg) != 0) OR (findstring("ORA-01562",string_struct_c->ms_err_msg) != 0
   )) )) )
    ROLLBACK
    SET gn_rollback_seg_failed = 1
    CALL echo("TRAPPED ROLLBACK SEGMENT ERROR......RESTRUCTURING README")
    GO TO exit_program
   ENDIF
   CALL echo(concat("FAILED INSERTING INTO TABLE CE_RESULT_SET_LINK:",string_struct_c->ms_err_msg))
   SET gn_child_failed = 1
   GO TO exit_program
  ENDIF
  CALL parser("rdb truncate table dcp_copy_meds_temp go")
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
