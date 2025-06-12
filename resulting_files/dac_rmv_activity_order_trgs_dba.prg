CREATE PROGRAM dac_rmv_activity_order_trgs:dba
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
 SET readme_data->message = "Readme Failed: Starting script dac_rmv_activity_order_trgs..."
 DECLARE draot_errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE draot_count = i4 WITH protect, noconstant(0)
 DECLARE draot_loop = i4 WITH protect, noconstant(0)
 DECLARE draot_entity_count = i4 WITH protect, noconstant(0)
 FREE RECORD draot_trigger
 RECORD draot_trigger(
   1 trigger[*]
     2 trigger_name = vc
 )
 SELECT INTO "nl:"
  FROM user_triggers ut
  WHERE ut.trigger_name IN ("TRGORDER_DETAIL_EA", "TRGORDER_INGREDIENT_EA")
  DETAIL
   draot_count = (draot_count+ 1), stat = alterlist(draot_trigger->trigger,draot_count),
   draot_trigger->trigger[draot_count].trigger_name = ut.trigger_name
  WITH nocounter
 ;end select
 IF (error(draot_errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure on user_triggers select: ",draot_errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_entity_activity_trigger deat
  WHERE deat.table_name IN ("ORDER_DETAIL", "ORDER_INGREDIENT")
  DETAIL
   draot_entity_count = (draot_entity_count+ 1)
  WITH nocounter
 ;end select
 IF (error(draot_errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure on DM_ENTITY_ACTIVITY_TRIGGER select: ",draot_errmsg)
  GO TO exit_script
 ENDIF
 IF (draot_count=0
  AND draot_entity_count=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-Success: No triggers or table entries found; exiting"
  GO TO exit_script
 ENDIF
 FOR (draot_loop = 1 TO size(draot_trigger->trigger,5))
  EXECUTE dm_drop_obsolete_objects value(draot_trigger->trigger[draot_loop].trigger_name), "TRIGGER",
  1
  IF (errcode != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failure on drop - ",draot_trigger->trigger[draot_loop].
    trigger_name,": ",errmsg)
   GO TO exit_script
  ENDIF
 ENDFOR
 DELETE  FROM dm_entity_activity_trigger deat
  WHERE deat.table_name IN ("ORDER_DETAIL", "ORDER_INGREDIENT")
  WITH nocounter
 ;end delete
 IF (error(draot_errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete: ",draot_errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 FREE RECORD draot_trigger
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
