CREATE PROGRAM br_upd_ref_range_notify_trig:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting <br_upd_ref_range_notify_trig.prg> script"
 DECLARE errmsg = vc WITH protect
 DECLARE errcode = i4 WITH protect, noconstant(0)
 FREE SET temp1
 RECORD temp1(
   1 reference_ranges[*]
     2 id = f8
 )
 FREE SET temp2
 RECORD temp2(
   1 triggers[*]
     2 id = f8
 )
 SET tcnt1 = 0
 SELECT INTO "nl:"
  FROM ref_range_notify_trig r
  WHERE r.ref_range_notify_trig_id > 0
  ORDER BY r.reference_range_factor_id, r.trigger_seq_nbr
  HEAD r.reference_range_factor_id
   zero_row_found = 0
  DETAIL
   IF (r.trigger_seq_nbr=0)
    zero_row_found = 1
   ENDIF
  FOOT  r.reference_range_factor_id
   IF (zero_row_found=1)
    tcnt1 = (tcnt1+ 1), stat = alterlist(temp1->reference_ranges,tcnt1), temp1->reference_ranges[
    tcnt1].id = r.reference_range_factor_id
   ENDIF
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Selecting ref_range_notify_trig row: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (tcnt1 > 0)
  SET tcnt2 = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tcnt1)),
    ref_range_notify_trig r
   PLAN (d)
    JOIN (r
    WHERE (r.reference_range_factor_id=temp1->reference_ranges[d.seq].id))
   ORDER BY r.reference_range_factor_id DESC, r.trigger_seq_nbr DESC
   DETAIL
    tcnt2 = (tcnt2+ 1), stat = alterlist(temp2->triggers,tcnt2), temp2->triggers[tcnt2].id = r
    .ref_range_notify_trig_id
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Readme Failed: Selecting ref_range_notify_trig row: ",errmsg)
   GO TO exit_script
  ENDIF
  IF (tcnt2 > 0)
   UPDATE  FROM ref_range_notify_trig r,
     (dummyt d  WITH seq = value(tcnt2))
    SET r.trigger_seq_nbr = (r.trigger_seq_nbr+ 1), r.updt_dt_tm = cnvtdatetime(curdate,curtime), r
     .updt_id = reqinfo->updt_id,
     r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->updt_applctx, r.updt_cnt = (r
     .updt_cnt+ 1)
    PLAN (d)
     JOIN (r
     WHERE (r.ref_range_notify_trig_id=temp2->triggers[d.seq].id))
    WITH nocounter
   ;end update
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Readme Failed: Updating ref_range_notify_trig row: ",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_upd_ref_range_notify_trig.prg> script"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
