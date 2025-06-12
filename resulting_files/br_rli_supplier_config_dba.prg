CREATE PROGRAM br_rli_supplier_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_rli_supplier_config.prg> script"
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE error_msg = vc WITH private
 DECLARE error_flag = vc WITH private
 SET error_flag = "N"
 SET row_cnt = size(requestin->list_0,5)
 FOR (x = 1 TO row_cnt)
  SELECT INTO "NL:"
   FROM br_rli_supplier brs
   WHERE cnvtupper(brs.supplier_name)=cnvtupper(trim(requestin->list_0[x].supplier_name))
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM br_rli_supplier brs
    SET brs.supplier_flag = cnvtint(requestin->list_0[x].supplier_flag), brs.supplier_meaning =
     requestin->list_0[x].supplier_meaning, brs.supplier_name = requestin->list_0[x].supplier_name,
     brs.supplier_prefix = requestin->list_0[x].supplier_prefix, brs.default_selected_ind = cnvtint(
      requestin->list_0[x].default_selected_ind), brs.content_loaded_ind = cnvtint(requestin->list_0[
      x].content_loaded_ind),
     brs.start_version_nbr = cnvtint(requestin->list_0[x].start_version_nbr)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error inserting",requestin->list_0[x].supplier_name,
     " into br_rli_supplier")
    CALL echo(error_msg)
   ENDIF
  ENDIF
 ENDFOR
 IF (((error_flag="N") OR (error_flag="T")) )
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeeded: <br_rli_supplier_config.prg> script"
  COMMIT
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed: <br_rli_supplier_config.prg> script"
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
