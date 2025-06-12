CREATE PROGRAM dm_alter_pathnet_tables:dba
 DECLARE dm_errmsg = c131 WITH public, noconstant(" ")
 DECLARE dm_errcode = i4 WITH public, noconstant(0)
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
 CALL parser("rdb alter table pn_recovery pctfree 10 pctused 90 go")
 CALL parser("rdb alter table pn_recovery_child pctfree 10 pctused 90 go")
 CALL parser("rdb alter table pn_recovery_detail pctfree 10 pctused 90 go")
 SET dm_errcode = error(dm_errmsg,0)
 IF (dm_errcode != 0)
  CALL echo("Error in altering a table")
  SET readme_data->message =
  "Error in altering pctfree/pctused on pn_recovery, pn_recovery_child, pn_recovery_detail"
  SET readme_data->status = "F"
 ELSE
  CALL echo("Tables updated")
  SET readme_data->message =
  "Pctfree/pctused on pn_recovery, pn_recovery_child, pn_recovery_detail altered"
  SET readme_data->status = "S"
 ENDIF
 EXECUTE dm_readme_status
END GO
