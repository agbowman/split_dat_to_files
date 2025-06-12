CREATE PROGRAM cp_drop_micchart_tables:dba
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
 SET trace = nowarning
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failure. Starting cp_drop_micchart_tables.prg script"
 FREE RECORD parser_rec
 RECORD parser_rec(
   1 qual[*]
     2 statement = vc
 )
 SET stat = alterlist(parser_rec->qual,21)
 SET parser_rec->qual[1].statement = "drop table cp_micro go"
 SET parser_rec->qual[2].statement =
 "drop ddlrecord cp_micro from database cp_micro with deps_deleted go"
 SET parser_rec->qual[3].statement = "drop database cp_micro with deps_deleted go"
 SET parser_rec->qual[4].statement = "drop table cp_micro_ak2 go"
 SET parser_rec->qual[5].statement =
 "drop ddlrecord cp_micro_ak2 from database cp_micro_ak2 with deps_deleted go"
 SET parser_rec->qual[6].statement = "drop database cp_micro_ak2 with deps_deleted go"
 SET parser_rec->qual[7].statement = "drop table cp_microx1 go"
 SET parser_rec->qual[8].statement =
 "drop ddlrecord cp_microx1 from database cp_microx1 with deps_deleted go"
 SET parser_rec->qual[9].statement = "drop database cp_microx1 with deps_deleted go"
 SET parser_rec->qual[10].statement = "drop table cp_microx1_2 go"
 SET parser_rec->qual[11].statement =
 "drop ddlrecord cp_microx1_2 from database cp_microx1_2 with deps_deleted go"
 SET parser_rec->qual[12].statement = "drop database cp_microx1_2 with deps_deleted go"
 SET parser_rec->qual[13].statement = "drop table cp_microy go"
 SET parser_rec->qual[14].statement =
 "drop ddlrecord cp_microy from database cp_microy with deps_deleted go"
 SET parser_rec->qual[15].statement = "drop database cp_microy with deps_deleted go"
 SET parser_rec->qual[16].statement = "drop table cp_microy_2 go"
 SET parser_rec->qual[17].statement =
 "drop ddlrecord cp_microy_2 from database cp_microy_2 with deps_deleted go"
 SET parser_rec->qual[18].statement = "drop database cp_microy_2 with deps_deleted go"
 SET parser_rec->qual[19].statement = "drop table cp_micro_2 go"
 SET parser_rec->qual[20].statement =
 "drop ddlrecord cp_micro_2 from database cp_micro_2 with deps_deleted go"
 SET parser_rec->qual[21].statement = "drop database cp_micro_2 with deps_deleted go"
 SET x = 0
 CALL echo("DROPPING MICRO/CHARTING TEMP TABLES...............")
 FOR (x = 1 TO 21)
  CALL echo(parser_rec->qual[x].statement)
  CALL parser(parser_rec->qual[x].statement)
 ENDFOR
 SELECT INTO "nl:"
  FROM dtable dp
  WHERE dp.table_name IN ("CP_MICROX1_2", "CP_MICROX1", "CP_MICRO", "CP_MICRO_AK2", "CP_MICROY",
  "CP_MICROY_2", "CP_MICRO_2")
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->status = "S"
 ELSE
  SET readme_data->status = "F"
 ENDIF
#exit_script
 IF ((readme_data->status="F"))
  SET readme_data->message = "Failure in dropping micro/charting temp tables - FAILURE"
 ELSEIF ((readme_data->status="S"))
  SET readme_data->message = "Successfully dropped micro/charting temp tables - SUCCESSFUL"
 ELSE
  SET readme_data->message = "Unknown Error Occured in cp_drop_micchart_tables"
 ENDIF
 COMMIT
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echo("*********************************************************")
  CALL echorecord(readme_data)
  CALL echo("*********************************************************")
 ENDIF
END GO
