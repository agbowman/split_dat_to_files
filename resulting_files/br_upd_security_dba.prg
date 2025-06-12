CREATE PROGRAM br_upd_security:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_upd_security.prg> script"
 DECLARE errmsg = vc WITH protect
 DECLARE errcode = i4 WITH protect, noconstant(0)
 UPDATE  FROM br_name_value b
  SET b.br_name =
   (SELECT
    cnvtstring(p.person_id)
    FROM prsnl p
    WHERE p.username=cnvtupper(b.br_name)
     AND p.active_ind=1), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task,
   b.updt_applctx = reqinfo->updt_applctx, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_cnt
    = (b.updt_cnt+ 1)
  WHERE b.br_nv_key1="WIZARDSECURITY"
   AND  EXISTS (
  (SELECT
   p2.username
   FROM prsnl p2
   WHERE p2.username=cnvtupper(b.br_name)
    AND p2.active_ind=1))
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Updating br_name_value: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_upd_security.prg> script"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
