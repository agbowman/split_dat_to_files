CREATE PROGRAM br_upd_mdro_resist_cnt:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_drug_group_organism.prg> script"
 DECLARE errmsg = vc WITH protect
 DECLARE errcode = i4 WITH protect, noconstant(0)
 UPDATE  FROM br_drug_group_organism dgo
  SET dgo.drug_resistant_cnt = 1, dgo.updt_dt_tm = cnvtdatetime(curdate,curtime), dgo.updt_id =
   reqinfo->updt_id,
   dgo.updt_task = reqinfo->updt_task, dgo.updt_applctx = reqinfo->updt_applctx, dgo.updt_cnt = (dgo
   .updt_cnt+ 1)
  WHERE dgo.br_drug_group_organism_id > 0
   AND dgo.br_mdro_cat_organism_id > 0
   AND dgo.drug_resistant_cnt=0
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Updating br_drug_group_organism row: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_drug_group_organism.prg> script"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
