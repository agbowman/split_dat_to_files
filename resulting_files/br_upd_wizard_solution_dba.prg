CREATE PROGRAM br_upd_wizard_solution:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_upd_wizard_solution.prg> script"
 DECLARE errmsg = vc WITH protect
 DECLARE errcode = i4 WITH protect, noconstant(0)
 SET next_seq = 0
 SELECT INTO "NL:"
  FROM br_client_sol_step
  WHERE step_mean="CONCEPTMAPWIZ"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO "NL:"
   FROM br_client_item_reltn
   WHERE item_type="SOLUTION"
    AND item_mean="CORECKI"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET next_seq = 0
   SELECT INTO "NL:"
    csq = max(bcir.solution_seq)
    FROM br_client_item_reltn bcir
    WHERE bcir.item_type="SOLUTION"
    DETAIL
     next_seq = csq
    WITH nocounter
   ;end select
   SET next_seq = (next_seq+ 1)
   INSERT  FROM br_client_item_reltn bcir
    SET bcir.br_client_item_reltn_id = seq(bedrock_seq,nextval), bcir.br_client_id = 1, bcir
     .item_type = "SOLUTION",
     bcir.item_mean = "CORECKI", bcir.item_display = "Core - Concept CKI Assignment", bcir
     .solution_seq = next_seq,
     bcir.updt_dt_tm = cnvtdatetime(curdate,curtime), bcir.updt_id = reqinfo->updt_id, bcir.updt_task
      = reqinfo->updt_task,
     bcir.updt_applctx = reqinfo->updt_applctx, bcir.updt_cnt = 0
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Readme Failed: Updating br_client_item_reltn row: ",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
  ENDIF
  UPDATE  FROM br_client_sol_step bcss
   SET bcss.solution_mean = "CORECKI", bcss.updt_dt_tm = cnvtdatetime(curdate,curtime), bcss.updt_id
     = reqinfo->updt_id,
    bcss.updt_task = reqinfo->updt_task, bcss.updt_applctx = reqinfo->updt_applctx, bcss.updt_cnt = (
    bcss.updt_cnt+ 1)
   WHERE step_mean IN ("CONCEPTMAPWIZ", "CVCSCKIASSIGN")
    AND bcss.solution_mean != "CORECKI"
   WITH nocounter
  ;end update
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Readme Failed: Updating br_client_item_reltn row: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_upd_wizard_solution.prg> script"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
