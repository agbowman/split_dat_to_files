CREATE PROGRAM br_upd_br_ccn_nbr:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_upd_br_ccn_nbr.prg> script"
 DECLARE errmsg = vc WITH protect
 DECLARE errcode = i4 WITH protect, noconstant(0)
 FREE SET temp
 RECORD temp(
   1 ccns[*]
     2 id = f8
     2 nbr_txt = vc
 )
 DECLARE temp_string = vc
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM br_ccn b
  WHERE b.ccn_nbr > 0
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(temp->ccns,tcnt), temp->ccns[tcnt].id = b.br_ccn_id,
   temp_string = build(b.ccn_nbr), beg_pos = 1, end_pos = findstring(".",temp_string,1),
   txt_len = (end_pos - beg_pos), temp->ccns[tcnt].nbr_txt = substring(1,txt_len,temp_string)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: selecting br_ccn row: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (tcnt > 0)
  UPDATE  FROM br_ccn b,
    (dummyt d  WITH seq = value(tcnt))
   SET b.ccn_nbr_txt = temp->ccns[d.seq].nbr_txt, b.ccn_nbr = 0, b.updt_dt_tm = cnvtdatetime(curdate,
     curtime),
    b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
    updt_applctx,
    b.updt_cnt = (b.updt_cnt+ 1)
   PLAN (d)
    JOIN (b
    WHERE (b.br_ccn_id=temp->ccns[d.seq].id))
   WITH nocounter
  ;end update
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Readme Failed: updating br_ccn row: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_upd_br_ccn_nbr.prg> script"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 FREE SET temp
END GO
