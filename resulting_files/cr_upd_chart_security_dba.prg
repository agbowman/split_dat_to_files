CREATE PROGRAM cr_upd_chart_security:dba
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
 DECLARE info_value_str = vc WITH noconstant(" "), protect
 DECLARE info_value_nbr = f8 WITH noconstant(0.0), protect
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE section_level_info_domain = vc WITH constant("CHARTING SECURITY"), protect
 DECLARE section_level_auth_lbl = vc WITH constant("Section level auth"), protect
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed:  Starting script cr_upd_chart_security..."
 SELECT INTO "nl:"
  FROM dm_info df
  WHERE df.info_domain=section_level_info_domain
  DETAIL
   info_value_str = trim(df.info_name)
  WITH nocounter
 ;end select
 IF (((curqual=0) OR (size(info_value_str) > 1)) )
  SET readme_data->status = "S"
  SET readme_data->message = "Success: No records found that needed to be updated (1)"
  GO TO exit_script
 ENDIF
 CALL echo(size(info_value_str))
 UPDATE  FROM dm_info df
  SET df.info_name = section_level_auth_lbl, df.info_number = cnvtreal(info_value_str), df.info_date
    = cnvtdatetime(sysdate),
   df.updt_applctx = reqinfo->updt_applctx, df.updt_id = reqinfo->updt_id, df.updt_task = reqinfo->
   updt_task,
   df.updt_dt_tm = cnvtdatetime(sysdate), df.updt_cnt = (df.updt_cnt+ 1)
  WHERE df.info_domain=section_level_info_domain
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme failed to update dm_info table:",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 IF (curqual > 0)
  SET readme_data->status = "S"
  SET readme_data->message = "Success: Finished updating dm_info table"
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Success: No records found that needed to be updated (2)"
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
