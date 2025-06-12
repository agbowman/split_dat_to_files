CREATE PROGRAM afc_del_dup_interval_table:dba
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
 SET table_exists = "F"
 SELECT INTO "NL:"
  FROM user_tab_columns utc
  WHERE utc.table_name="INTERVAL_TABLE"
  DETAIL
   table_exists = "T"
  WITH nocounter
 ;end select
 IF (table_exists="F")
  SET readme_data->status = "S"
  SET readme_data->message = "New table, readme not needed to remove duplicates."
  GO TO exit_script
 ENDIF
 SET readme_data->status = "F"
 FREE SET dups
 RECORD dups(
   1 items_to_delete[*]
     2 interval_id = f8
 )
 SET count = 0
 SET total_dups = 0
 SELECT INTO "nl:"
  i.interval_id, i.interval_template_cd, i.beg_value,
  i.end_value, i.active_ind, i.updt_dt_tm
  FROM interval_table i
  ORDER BY i.interval_template_cd, i.beg_value, i.end_value,
   i.active_ind, i.updt_dt_tm DESC
  HEAD i.interval_template_cd
   dummy_var = 0
  HEAD i.beg_value
   dummy_var = 0
  HEAD i.end_value
   dummy_var = 0
  HEAD i.active_ind
   dummy_var = 0, count = 0
  DETAIL
   count = (count+ 1)
   IF (count > 1)
    total_dups = (total_dups+ 1), stat = alterlist(dups->items_to_delete,total_dups), dups->
    items_to_delete[total_dups].interval_id = i.interval_id
   ENDIF
  WITH nocounter
 ;end select
 FOR (counter = 1 TO total_dups)
   DELETE  FROM interval_table
    WHERE (interval_id=dups->items_to_delete[counter].interval_id)
   ;end delete
 ENDFOR
 IF (total_dups > 0)
  CALL echo("committing changes")
  CALL echo(build("# dups deleted:",total_dups))
  COMMIT
 ELSE
  CALL echo("No dups found.")
 ENDIF
 SET count = 0
 SET total_dups = 0
 SELECT INTO "nl:"
  i.interval_id, i.interval_template_cd, i.beg_value,
  i.end_value, i.active_ind, i.updt_dt_tm
  FROM interval_table i
  ORDER BY i.interval_template_cd, i.beg_value, i.end_value,
   i.active_ind, i.updt_dt_tm DESC
  HEAD i.interval_template_cd
   dummy_var = 0
  HEAD i.beg_value
   dummy_var = 0
  HEAD i.end_value
   dummy_var = 0
  HEAD i.active_ind
   dummy_var = 0, count = 0
  DETAIL
   count = (count+ 1)
   IF (count > 1)
    total_dups = (total_dups+ 1), stat = alterlist(dups->items_to_delete,total_dups), dups->
    items_to_delete[total_dups].interval_id = i.interval_id
   ENDIF
  WITH nocounter
 ;end select
 IF (total_dups > 0)
  SET readme_data->status = "F"
  SET readme_data->message = "Duplicates still exist."
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Duplicates removed."
 ENDIF
#exit_script
 EXECUTE dm_readme_status
END GO
