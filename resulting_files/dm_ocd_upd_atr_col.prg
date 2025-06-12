CREATE PROGRAM dm_ocd_upd_atr_col
 DECLARE rdm_table_name = c255 WITH public, variable
 DECLARE rdm_table_key = i4 WITH public, variable
 DECLARE rdm_table_field = c255 WITH public, variable
 DECLARE rdm_field_type = c2 WITH public, variable
 DECLARE rdm_field_exists = c1 WITH public, variable
 DECLARE rdm_key_exists = c1 WITH public, variable
 DECLARE rdm_ocd_table = c20 WITH public, variable
 DECLARE rdm_atr_number = i4 WITH public, variable
 DECLARE rdm_ocd_field = c20 WITH public, variable
 DECLARE dm_errcode = i4 WITH public, variable
 DECLARE rdm_errmsg = c132 WITH public, variable
 DECLARE rdm_requestclass = i4 WITH public, variable
 SET rdm_table_key = cnvtint( $2)
 SET rdm_table_field = cnvtupper( $3)
 SET rdm_field_value =  $4
#start_process
 IF (cnvtupper( $1)="REQ")
  SET rdm_table_name = "REQUEST"
  SET rdm_ocd_table = "DM_OCD_REQUEST"
  SET rdm_ocd_field = "REQUEST_NUMBER"
  SELECT INTO "nl:"
   r.request_number, r.requestclass
   FROM request r
   WHERE r.request_number=value(rdm_table_key)
   HEAD REPORT
    rdm_key_exists = "N"
   DETAIL
    rdm_requestclass = r.requestclass, rdm_key_exists = "Y"
   WITH nullreport
  ;end select
 ELSEIF (cnvtupper( $1)="TASK")
  SET rdm_table_name = "APPLICATION_TASK"
  SET rdm_ocd_table = "DM_OCD_TASK"
  SET rdm_ocd_field = "TASK_NUMBER"
  SELECT INTO "nl:"
   a.task_number
   FROM application_task a
   WHERE a.task_number=value(rdm_table_key)
   HEAD REPORT
    rdm_key_exists = "N"
   DETAIL
    rdm_key_exists = "Y"
   WITH nullreport
  ;end select
 ELSEIF (cnvtupper( $1)="APP")
  SET rdm_table_name = "APPLICATION"
  SET rdm_ocd_table = "DM_OCD_APPLICATION"
  SET rdm_ocd_field = "APPLICATION_NUMBER"
  SELECT INTO "nl:"
   a.application_number
   FROM application a
   WHERE a.application_number=value(rdm_table_key)
   HEAD REPORT
    rdm_key_exists = "N"
   DETAIL
    rdm_key_exists = "Y"
   WITH nullreport
  ;end select
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = 'The file name passed was not "REQ", "TASK" or "APP"'
  GO TO exit_program
 ENDIF
 IF (rdm_key_exists="N")
  SET readme_data->status = "F"
  SET readme_data->message = concat("The key field for the table passed does ",
   "not have row that matches the key value passed")
  GO TO exit_program
 ENDIF
 IF (cnvtupper( $1)="REQ"
  AND rdm_table_field="REQUESTCLASS"
  AND rdm_requestclass > 0)
  SET readme_data->status = "S"
  SET readme_data->message = concat("This field has been set already and can be set by the client.")
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  dl.attr_name, dl.type, dl.len
  FROM dtableattr dr,
   dtableattrl dl
  PLAN (dr
   WHERE dr.table_name=value(rdm_table_name))
   JOIN (dl
   WHERE dl.attr_name=value(rdm_table_field))
  HEAD REPORT
   rdm_field_exists = "N"
  DETAIL
   rdm_field_type = dl.type, rdm_field_exists = "Y"
  WITH nocounter, nullreport
 ;end select
 IF (rdm_field_exists="N")
  SET readme_data->status = "F"
  SET readme_data->message = "The field name passed to be updated does not exist on the table"
  GO TO exit_program
 ENDIF
 IF (rdm_field_type IN ("VC", "C"))
  CALL parser("update into ")
  CALL parser(rdm_table_name)
  CALL parser(" rtf  ")
  CALL parser(build("set rtf.",rdm_table_field,'  = "',rdm_field_value,'"'))
  CALL parser(build("where rtf.",rdm_ocd_field,"=",rdm_table_key))
  CALL parser(" go")
 ELSEIF (rdm_field_type IN ("I", "R"))
  CALL parser("update into ")
  CALL parser(rdm_table_name)
  CALL parser(" rtf  ")
  CALL parser(build("set rtf.",rdm_table_field,"  = cnvtreal(",rdm_field_value,")"))
  CALL parser(build("where rtf.",rdm_ocd_field,"=",rdm_table_key))
  CALL parser(" go")
 ELSEIF (rdm_field_type IN ("Q"))
  CALL parser("update into ")
  CALL parser(rdm_table_name)
  CALL parser(" rtf  ")
  CALL parser(build("set rtf.",rdm_table_field,'  = cnvtdatetime("',rdm_field_value,'")'))
  CALL parser(build("where rtf.",rdm_ocd_field,"=",rdm_table_key))
  CALL parser(" go")
 ENDIF
 SET rdm_errcode = error(rdm_errmsg,0)
 IF (rdm_errcode != 0)
  SET readme_data->message = rdm_errmsg
  SET readme_data->status = "F"
  ROLLBACK
 ELSE
  SET readme_data->message = "Updated the ATR table and field correctly"
  SET readme_data->status = "S"
  COMMIT
 ENDIF
#exit_program
END GO
