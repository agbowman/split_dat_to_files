CREATE PROGRAM dm_ins_arc_dm_info_check:dba
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
 SET readme_data->message = "Starting dm_ins_arc_dm_info_check"
 EXECUTE dm_readme_status
 DECLARE dia_info_domain = vc
 DECLARE dia_info_name = vc
 DECLARE dia_row_cnt = i4 WITH constant(4)
 EXECUTE dm_dbimport "cer_install:dm_ins_arc_dm_info.csv", "dm_ins_arc_dm_info", 1500
 IF ((readme_data->status="F"))
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  cnt = count(*)
  FROM dm_info di
  WHERE ((di.info_domain="ARCHIVE-DOMAIN"
   AND di.info_name="PERSON") OR (di.info_domain="ARCHIVE-PERSON"
   AND di.info_name IN ("CONSTRAINT PREFIX", "NUM BETWEEN CHECKS", "NUM PER CYCLE")))
  DETAIL
   IF (cnt=dia_row_cnt)
    readme_data->message = "Import of dm_info rows successful.", readme_data->status = "S"
   ELSE
    readme_data->message = concat("Import of dm_info rows unsuccessful.",cnvtstring(dia_row_cnt),
     " rows expected but ",cnvtstring(cnt)," rows were found."), readme_data->status = "F"
   ENDIF
  WITH nocounter
 ;end select
#exit_program
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
