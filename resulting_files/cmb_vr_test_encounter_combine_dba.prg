CREATE PROGRAM cmb_vr_test_encounter_combine:dba
 FREE RECORD cmb_test_values
 RECORD cmb_test_values(
   1 cmb_from_id = f8
   1 cmb_to_id = f8
   1 combine_id = f8
   1 test_stage = i2
   1 detail_cnt = i4
   1 noop_cnt = i4
 )
 DECLARE combine_complete = i2 WITH public, constant(1)
 DECLARE combine_failed = i2 WITH public, constant(2)
 DECLARE captured_ids = i2 WITH public, constant(3)
 DECLARE uncombine_complete = i2 WITH public, constant(4)
 DECLARE uncombine_failed = i2 WITH public, constant(5)
 DECLARE cleanup_complete = i2 WITH public, constant(6)
 DECLARE errcode = i4 WITH public, noconstant(0)
 DECLARE errmsg = vc WITH public, noconstant("")
 DECLARE noop = f8 WITH public, noconstant(0.0)
 SET modify = nopredeclare
 SET trace = nodeprecated
 SET trace = rdbdebug
 SET trace = rdbbind
 SET trace = echoprogall
 SET reqinfo->updt_task = 200701
 SET reqinfo->updt_applctx = 200701
 SET reqdata->data_status_cd = 200701
 SET reqdata->contributor_system_cd = 200701
 SET noop = uar_get_code_by("MEANING",327,nullterm("NOOP"))
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  ROLLBACK
  GO TO exit_script
 ENDIF
 SET stat = initrec(cmb_test_values)
 IF ((validate(cmb_test_from_encounter_id,- (99.00)) != - (99.00))
  AND (validate(cmb_test_to_encounter_id,- (99.00)) != - (99.00)))
  SET cmb_test_values->cmb_from_id = cmb_test_from_encounter_id
  SET cmb_test_values->cmb_to_id = cmb_test_to_encounter_id
 ELSE
  SELECT INTO "nl:"
   p.person_id, e1.encntr_id, e2.encntr_id,
   p.name_full_formatted
   FROM person p,
    encounter e1,
    encounter e2
   WHERE p.active_ind=1
    AND p.person_id > 1000.0
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND p.deceased_dt_tm = null
    AND p.person_id=e1.person_id
    AND p.person_id=e2.person_id
    AND e1.active_ind=1
    AND e2.active_ind=1
    AND e1.encntr_id != e2.encntr_id
    AND e1.encntr_type_cd > 0
    AND e1.encntr_type_cd=e2.encntr_type_cd
    AND e1.updt_dt_tm > cnvtdatetime("01-JAN-2018 12:00:00")
    AND  NOT ( EXISTS (
   (SELECT
    1
    FROM prsnl p2
    WHERE p2.person_id=p.person_id)))
   DETAIL
    cmb_test_values->cmb_from_id = e1.encntr_id, cmb_test_values->cmb_to_id = e2.encntr_id
   WITH maxqual(e1,1), nocounter
  ;end select
 ENDIF
 FREE RECORD request
 RECORD request(
   1 parent_table = c50
   1 cmb_mode = vc
   1 error_message = c132
   1 xxx_combine[*]
     2 xxx_combine_id = f8
     2 from_xxx_id = f8
     2 from_mrn = vc
     2 from_alias_pool_cd = f8
     2 from_alias_type_cd = f8
     2 to_xxx_id = f8
     2 to_mrn = vc
     2 to_alias_pool_cd = f8
     2 to_alias_type_cd = f8
     2 encntr_id = f8
     2 application_flag = i2
     2 combine_weight = f8
   1 transaction_type = vc
   1 xxx_combine_det[*]
     2 xxx_combine_det_id = f8
     2 xxx_combine_id = f8
     2 entity_name = c32
     2 entity_id = f8
     2 entity_pk[*]
       3 col_name = c30
       3 data_type = c30
       3 data_char = c100
       3 data_number = f8
       3 data_date = dq8
     2 combine_action_cd = f8
     2 attribute_name = c32
     2 prev_active_ind = i2
     2 prev_active_status_cd = f8
     2 prev_end_eff_dt_tm = dq8
     2 combine_desc_cd = f8
     2 to_record_ind = i2
   1 reverse_cmb_ind = i2
 )
 FREE RECORD reply
 RECORD reply(
   1 xxx_combine_id[*]
     2 combine_id = f8
     2 parent_table = c50
     2 from_xxx_id = f8
     2 to_xxx_id = f8
     2 encntr_id = f8
   1 error[*]
     2 create_dt_tm = dq8
     2 parent_table = c50
     2 from_id = f8
     2 to_id = f8
     2 encntr_id = f8
     2 error_table = c32
     2 error_type = vc
     2 error_msg = vc
     2 combine_error_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET request->parent_table = "ENCOUNTER"
 SET request->transaction_type = curuser
 SET stat = alterlist(request->xxx_combine,1)
 SET request->xxx_combine[1].from_xxx_id = cmb_test_values->cmb_from_id
 SET request->xxx_combine[1].to_xxx_id = cmb_test_values->cmb_to_id
 SET request->xxx_combine[1].encntr_id = 0
 SET request->xxx_combine[1].application_flag = 1
 EXECUTE dm_call_combine
 CALL echo("==================================================================================")
 CALL echo("Dumping out the dm_call_combine request...")
 CALL echorecord(request)
 CALL echo("==================================================================================")
 CALL echo("Dumping out the dm_call_combine reply...")
 CALL echorecord(reply)
 CALL echo("==================================================================================")
 IF ((reply->status_data.status="S"))
  COMMIT
  SET cmb_test_values->test_stage = combine_complete
 ELSE
  ROLLBACK
  SET cmb_test_values->test_stage = combine_failed
  GO TO exit_script
 ENDIF
 SET cmb_test_values->combine_id = reply->xxx_combine_id[1].combine_id
 CALL echo("==================================================================================")
 CALL echo("Listing out the core Combine IDs...")
 CALL echo(build2("Encounter Combine ID: ",cmb_test_values->combine_id))
 CALL echo("==================================================================================")
 IF ((cmb_test_values->combine_id=0))
  CALL echo("")
  GO TO exit_script
 ENDIF
 SET cmb_test_values->detail_cnt = 0
 SET cmb_test_values->noop_cnt = 0
 SELECT INTO "nl:"
  ecd.encntr_combine_det_id, ecd.combine_action_cd
  FROM encntr_combine_det ecd
  WHERE (ecd.encntr_combine_id=cmb_test_values->combine_id)
  DETAIL
   IF (ecd.combine_action_cd=noop)
    cmb_test_values->noop_cnt += 1
   ELSE
    cmb_test_values->detail_cnt += 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("==================================================================================")
 CALL echo("Listing out the combined row counts...")
 CALL echo(build2("True Rows Combined: ",cmb_test_values->detail_cnt))
 CALL echo(build2("NOOP Rows Combined: ",cmb_test_values->noop_cnt))
 CALL echo("==================================================================================")
 SET cmb_test_values->test_stage = captured_ids
 FREE RECORD request
 RECORD request(
   1 parent_table = c50
   1 cmb_mode = vc
   1 error_message = vc
   1 xxx_uncombine[*]
     2 xxx_combine_id = f8
     2 from_xxx_id = f8
     2 from_mrn = c200
     2 from_alias_pool_cd = f8
     2 from_alias_type_cd = f8
     2 to_xxx_id = f8
     2 to_mrn = c200
     2 to_alias_pool_cd = f8
     2 to_alias_type_cd = f8
     2 encntr_id = f8
     2 application_flag = i2
   1 xxx_combine[*]
     2 xxx_combine_id = f8
     2 from_xxx_id = f8
     2 from_mrn = c200
     2 from_alias_pool_cd = f8
     2 from_alias_type_cd = f8
     2 to_xxx_id = f8
     2 to_mrn = c200
     2 to_alias_pool_cd = f8
     2 to_alias_type_cd = f8
     2 encntr_id = f8
     2 application_flag = i2
     2 combine_weight = f8
   1 xxx_combine_det[*]
     2 xxx_combine_det_id = f8
     2 xxx_combine_id = f8
     2 entity_name = c32
     2 entity_id = f8
     2 entity_pk[*]
       3 col_name = c30
       3 data_type = c30
       3 data_char = c100
       3 data_number = f8
       3 data_date = dq8
     2 combine_action_cd = f8
     2 attribute_name = c32
     2 prev_active_ind = i2
     2 prev_active_status_cd = f8
     2 prev_end_eff_dt_tm = dq8
     2 combine_desc_cd = f8
     2 to_record_ind = i2
   1 transaction_type = c8
 )
 FREE RECORD reply
 RECORD reply(
   1 xxx_combine_id[*]
     2 combine_id = f8
     2 parent_table = c50
     2 from_xxx_id = f8
     2 to_xxx_id = f8
     2 encntr_id = f8
   1 error[*]
     2 create_dt_tm = dq8
     2 parent_table = c50
     2 from_id = f8
     2 to_id = f8
     2 encntr_id = f8
     2 error_table = c32
     2 error_type = vc
     2 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET request->parent_table = "ENCOUNTER"
 SET request->transaction_type = curuser
 SET stat = alterlist(request->xxx_uncombine,1)
 SET request->xxx_uncombine[1].xxx_combine_id = cmb_test_values->combine_id
 SET request->xxx_uncombine[1].from_xxx_id = cmb_test_values->cmb_from_id
 SET request->xxx_uncombine[1].to_xxx_id = cmb_test_values->cmb_to_id
 SET request->xxx_uncombine[1].encntr_id = 0
 SET request->xxx_uncombine[1].application_flag = 1
 EXECUTE dm_call_uncombine
 CALL echo("==================================================================================")
 CALL echo("Dumping out the dm_call_uncombine request...")
 CALL echorecord(request)
 CALL echo("==================================================================================")
 CALL echo("Dumping out the dm_call_uncombine reply...")
 CALL echorecord(reply)
 CALL echo("==================================================================================")
 IF ((reply->status_data.status="S"))
  SET cmb_test_values->test_stage = uncombine_complete
 ELSE
  ROLLBACK
  SET cmb_test_values->test_stage = uncombine_failed
  GO TO exit_script
 ENDIF
 DELETE  FROM encntr_combine_det
  WHERE (encntr_combine_id=cmb_test_values->combine_id)
  WITH nocounter
 ;end delete
 DELETE  FROM encntr_combine
  WHERE (encntr_combine_id=cmb_test_values->combine_id)
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  ROLLBACK
  GO TO exit_script
 ELSE
  SET cmb_test_values->test_stage = cleanup_complete
  COMMIT
 ENDIF
 CALL echo("==================================================================================")
 CALL echorecord(cmb_test_values)
 IF ((cmb_test_values->test_stage=cleanup_complete))
  CALL echo("  ---  Test Successful  ---  ")
 ENDIF
 CALL echo("==================================================================================")
#exit_script
 SET trace = nordbdebug
 SET trace = nordbbind
 SET trace = noechoprogall
 FREE RECORD request
 FREE RECORD reply
 FREE RECORD cmb_test_values
END GO
