CREATE PROGRAM dm_ins_arc_cons_check:dba
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
 IF (curcclrev < 8.0)
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-Success. Readme should not run in a 7.8 environment."
  GO TO exit_program
 ENDIF
 DECLARE cons_cnt_before = i4 WITH noconstant(0)
 DECLARE cons_cnt_insert = i4 WITH noconstant(0)
 DECLARE arc_cons_cnt = i4 WITH noconstant(0)
 DECLARE arc_cons_logical = vc
 SET readme_data->status = "F"
 SET readme_data->message = "Starting dm_ins_arc_cons_check"
 EXECUTE dm_readme_status
 SET logical arc_cons_logical "cer_install:dm_arc_constraints.csv"
 FREE DEFINE rtl2
 DEFINE rtl2 "arc_cons_logical"
 SELECT INTO "nl:"
  FROM rtl2t
  DETAIL
   arc_cons_cnt = (arc_cons_cnt+ 1)
  WITH nocounter
 ;end select
 SET arc_cons_cnt = (arc_cons_cnt - 5)
 EXECUTE dm_dbimport "cer_install:dm_arc_constraints.csv", "dm_ins_arc_cons", 1500
 IF ((readme_data->status="F"))
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  cnt = count(*)
  FROM dm_arc_constraints dac
  WHERE ((dac.constraint_name = null) OR (dac.constraint_name=""))
  DETAIL
   IF (cnt >= arc_cons_cnt)
    readme_data->message = "Import of dm_arc_constraints rows successful.", readme_data->status = "S"
   ELSE
    readme_data->message = concat("Import of dm_arc_constraints rows failed. ",trim(cnvtstring(
       arc_cons_cnt))," rows expected but ",trim(cnvtstring(cnt))," rows were found."), readme_data->
    status = "F"
   ENDIF
  WITH nocounter
 ;end select
#exit_program
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
END GO
