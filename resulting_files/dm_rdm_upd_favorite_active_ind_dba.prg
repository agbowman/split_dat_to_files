CREATE PROGRAM dm_rdm_upd_favorite_active_ind:dba
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
 SET readme_data->message = "Readme failed: Starting dm_rdm_upd_favorite_active_ind..."
 DECLARE error_cd = f8 WITH protected, noconstant(0.0)
 DECLARE error_msg = c132 WITH protected, noconstant("")
 SET readme_data->message = "Readme failed..."
 DECLARE range_inc = f8 WITH protect, noconstant(250000.0)
 DECLARE min_range = f8 WITH protect, noconstant(1.0)
 DECLARE max_range = f8 WITH protect, noconstant(range_inc)
 DECLARE min_id = f8 WITH protect, noconstant(0.0)
 DECLARE max_id = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  min_val = min(mf.favorite_id), max_val = max(mf.favorite_id)
  FROM messaging_favorites mf
  WHERE mf.favorite_id > 1.0
  DETAIL
   min_id = min_val, max_id = max_val
  WITH nocounter
 ;end select
 SET max_range = (min_id+ range_inc)
 SET min_range = min_id
 SET error_cd = error(error_msg,0)
 IF (error_cd != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Favorite_Ids retrieval from Messaging_Favorites: ",error_msg)
  GO TO exit_program
 ENDIF
 SET readme_data->message = "Readme failed: Updating Messaging_Favorites with active_ind = 1..."
 DECLARE total_updt_cnt = f8 WITH protect, noconstant(0.0)
 CALL echo("*******************************************************")
 CALL echo("Updating Messaging_Favorites with Active_Ind value 1..")
 CALL echo(concat("-> Process started at: ",format(sysdate,";;q")))
 CALL echo("*******************************************************")
 WHILE (min_range <= max_id)
   CALL echo(build("max_range--> ",max_range))
   UPDATE  FROM messaging_favorites mf
    SET mf.active_ind = 1, mf.updt_cnt = (mf.updt_cnt+ 1), mf.updt_id = reqinfo->updt_id,
     mf.updt_task = reqinfo->updt_task, mf.updt_applctx = reqinfo->updt_applctx
    WHERE mf.favorite_id BETWEEN min_range AND max_range
     AND mf.active_ind=null
    WITH nocounter
   ;end update
   SET total_updt_cnt = (curqual+ total_updt_cnt)
   IF (error(error_msg,0) != 0)
    CALL echo("Processing FAILED...")
    CALL echo(concat("Failure during update of Messaging_Favorites table:",error_msg))
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failure during Messaging_Favorites update:",error_msg)
    GO TO exit_program
   ELSE
    COMMIT
   ENDIF
   SET min_range = (max_range+ 1)
   SET max_range += range_inc
 ENDWHILE
 SET readme_data->status = "S"
 SET readme_data->message = concat("Readme updated ",trim(cnvtstring(total_updt_cnt)),
  " record(s) successfully.")
#exit_program
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
