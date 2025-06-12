CREATE PROGRAM bmdi_build:dba
 DECLARE custom_options = vc
 DECLARE cstored = vc
 DECLARE curpos = i4
 DECLARE v_hours_to_keep = vc
 DECLARE v_max_rows = vc
 DECLARE v_data = vc
 DECLARE str = vc
#main_menu
 CALL clear(1,1)
 CALL video(nw)
 CALL box(2,1,18,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"BMDI TROUBLESHOOTING UTILITY")
 CALL box(5,9,17,76)
 CALL line(7,9,68,xhor)
 CALL text(6,11,"BMDI Options")
 CALL text(8,11," 1. Activate to view associations at room level")
 CALL text(10,11," 2. Activate to view unique device associations")
 CALL text(12,11," 3. Add stub rows")
 CALL text(14,11," 4. Set BMDI Purge Parameters")
 CALL text(16,11," 5. Back to main menu")
 CALL text(19,2,"Select an item number:  ")
 CALL accept(19,25,"9",0
  WHERE curaccept > 0
   AND curaccept <= 5)
 CASE (curaccept)
  OF 1:
   GO TO room_def_assoc
  OF 2:
   GO TO unique_assoc
  OF 3:
   EXECUTE bmdi_add_adt_stub
   GO TO main_menu
  OF 4:
   CALL clear(1,1)
   CALL video(nw)
   CALL box(1,9,9,68)
   CALL line(3,9,60,xhor)
   CALL text(2,12,"BMDI Enter Values to update")
   CALL text(4,12," 1. To update/insert the new Value")
   CALL text(6,12," 2. To view the current value")
   CALL text(8,12," 3. To Main Menu")
   CALL text(10,12,"Select an item number:  ")
   CALL accept(10,34,"3",0
    WHERE curaccept > 0
     AND curaccept <= 4)
   CASE (curaccept)
    OF 1:
     GO TO hours_max_rows
    OF 2:
     GO TO display_hours_max_rows
    OF 3:
     GO TO main_menu
   ENDCASE
  ELSE
   GO TO exit_script
 ENDCASE
#room_def_assoc
 SET cstored = "01"
 SELECT INTO "nl:"
  FROM strt_model_custom smc
  WHERE smc.strt_model_id=0
   AND smc.strt_config_id=1282103
   AND process_flag=10
  DETAIL
   custom_options = smc.custom_option
  WITH nocounter
 ;end select
 IF (curqual=1)
  IF (size(custom_options,1)=2
   AND substring(2,1,custom_options) != "1")
   SET cstored = substring(1,1,custom_options)
   SET cstored = concat(cstored,"1")
  ELSEIF (size(custom_options,1)=1)
   SET cstored = concat(custom_options,"1")
  ELSEIF (size(custom_options,1)=0)
   SET cstored = "01"
  ELSE
   GO TO end_update
  ENDIF
  UPDATE  FROM strt_model_custom smc
   SET smc.custom_option = cstored, smc.updt_id = reqinfo->updt_id, smc.updt_applctx = reqinfo->
    updt_applctx,
    smc.updt_task = reqinfo->updt_task, smc.updt_dt_tm = cnvtdatetime(curdate,curtime3), smc.updt_cnt
     = (smc.updt_cnt+ 1)
   WHERE smc.strt_config_id=1282103
    AND smc.strt_model_id=0
    AND smc.process_flag=10
   WITH nocounter
  ;end update
  COMMIT
  GO TO end_update
 ELSE
  INSERT  FROM strt_model_custom smc
   SET smc.strt_config_id = 1282103, smc.strt_model_id = 0, smc.description =
    "View across all facilities",
    smc.display = "BMDI_GET_ADT_BY_NURSEUNIT", smc.custom_option = "01", smc.process_flag = 10
  ;end insert
  COMMIT
 ENDIF
 GO TO end_update
#end_update
 SELECT
  smc.strt_config_id, smc.strt_model_id, smc.custom_option,
  smc.process_flag
  FROM strt_model_custom smc
  WHERE smc.strt_config_id=1282103
   AND smc.strt_model_id=0
   AND smc.process_flag=10
  WITH nocounter
 ;end select
 GO TO main_menu
#unique_assoc
 SELECT INTO "nl:"
  FROM strt_model_custom smc
  WHERE smc.strt_config_id=1282105
   AND strt_model_id=0
   AND smc.process_flag=10
  DETAIL
   custom_options = smc.custom_option
  WITH nocounter
 ;end select
 IF (curqual=1)
  IF (substring(1,1,custom_options) != "1")
   UPDATE  FROM strt_model_custom smc
    SET smc.custom_option = "1", smc.updt_id = reqinfo->updt_id, smc.updt_applctx = reqinfo->
     updt_applctx,
     smc.updt_task = reqinfo->updt_task, smc.updt_dt_tm = cnvtdatetime(curdate,curtime3), smc
     .updt_cnt = (smc.updt_cnt+ 1)
    WHERE smc.strt_config_id=1282105
     AND strt_model_id=0
     AND smc.process_flag=10
   ;end update
   COMMIT
  ENDIF
 ELSE
  INSERT  FROM strt_model_custom smc
   SET smc.strt_config_id = 1282105, strt_model_id = 0, smc.process_flag = 10,
    smc.description = "Enable unique WTS assoc/dissoc", smc.custom_option = "1"
  ;end insert
  COMMIT
 ENDIF
 SELECT
  smc.strt_config_id, smc.strt_model_id, smc.custom_option,
  smc.process_flag
  FROM strt_model_custom smc
  WHERE smc.strt_config_id=1282105
   AND smc.strt_model_id=0
   AND smc.process_flag=10
  WITH nocounter
 ;end select
 GO TO main_menu
#hours_max_rows
 SELECT INTO "nl:"
  FROM strt_model_custom smc
  WHERE smc.strt_model_id=0
   AND smc.strt_config_id=1290015
   AND process_flag=10
  DETAIL
   custom_options = smc.custom_option
  WITH nocounter
 ;end select
 IF (curqual=1)
  SET curpos = findstring("#",custom_options,1,0)
  IF (curpos != 0)
   CALL clear(1,1)
   CALL video(nw)
   CALL text(2,12,"Enter the value to modify ")
   CALL text(3,12,"Enter the number of hours to keep the data:")
   CALL accept(3,67,"P(50);CU")
   SET curpos = 0
   SET curpos = isnumeric(curaccept)
   IF (curpos != 1)
    CALL text(5,12,"Please enter a valid number")
    CALL pause(5)
    GO TO main_menu
   ELSE
    SET v_hours_to_keep = curaccept
   ENDIF
   CALL text(4,12,"Enter the number of rows to delete:")
   CALL accept(4,67,"P(50);CU")
   SET curpos = 0
   SET curpos = isnumeric(curaccept)
   IF (curpos != 1)
    CALL text(5,12,"Please enter a valid Rows")
    CALL pause(5)
    GO TO main_menu
   ELSE
    SET v_max_rows = curaccept
   ENDIF
   SET v_hours_to_keep = concat(v_hours_to_keep,"#")
   SET v_hours_to_keep = concat(v_hours_to_keep,v_max_rows)
   SET v_hours_to_keep = concat(v_hours_to_keep,"#")
   UPDATE  FROM strt_model_custom smc
    SET smc.custom_option = v_hours_to_keep, smc.updt_id = reqinfo->updt_id, smc.updt_applctx =
     reqinfo->updt_applctx,
     smc.updt_task = reqinfo->updt_task, smc.updt_dt_tm = cnvtdatetime(curdate,curtime3), smc
     .updt_cnt = (smc.updt_cnt+ 1)
    WHERE smc.strt_config_id=1290015
     AND smc.strt_model_id=0
     AND smc.process_flag=10
    WITH nocounter
   ;end update
   COMMIT
   CALL clear(1,1)
   GO TO display_hours_max_rows
  ENDIF
 ELSE
  CALL clear(1,1)
  CALL video(nw)
  CALL text(2,12,"Enter the value to insert")
  CALL text(3,12,"Enter the number of hours to keep the data:")
  CALL accept(3,67,"P(50);CU")
  SET curpos = 0
  SET curpos = isnumeric(curaccept)
  IF (curpos != 1)
   CALL text(5,12,"Please enter a valid number")
   CALL pause(5)
   GO TO main_menu
  ELSE
   SET v_hours_to_keep = curaccept
  ENDIF
  CALL text(4,12,"Enter the number of rows to delete:")
  CALL accept(4,67,"P(50);CU")
  SET curpos = 0
  SET curpos = isnumeric(curaccept)
  IF (curpos != 1)
   CALL text(5,12,"Please enter a valid Rows")
   CALL pause(5)
   GO TO main_menu
  ELSE
   SET v_max_rows = curaccept
  ENDIF
  SET v_hours_to_keep = concat(v_hours_to_keep,"#")
  SET v_hours_to_keep = concat(v_hours_to_keep,v_max_rows)
  SET v_hours_to_keep = concat(v_hours_to_keep,"#")
  INSERT  FROM strt_model_custom smc
   SET smc.strt_config_id = 1290015, smc.strt_model_id = 0, smc.description =
    "Hours to keep and MAX Rows to delete",
    smc.display = "DM_BMDI_DELETE_ACQUIRED_RESULTS", smc.custom_option = v_hours_to_keep, smc
    .process_flag = 10
  ;end insert
  COMMIT
 ENDIF
 CALL clear(1,1)
 GO TO display_hours_max_rows
 SELECT
  smc.strt_config_id, smc.strt_model_id, smc.custom_option,
  smc.process_flag
  FROM strt_model_custom smc
  WHERE smc.strt_config_id=1290015
   AND smc.strt_model_id=0
   AND smc.process_flag=10
  WITH nocounter
 ;end select
 GO TO main_menu
#display_hours_max_rows
 CALL clear(1,1)
 SELECT INTO "nl:"
  FROM strt_model_custom smc
  WHERE smc.strt_model_id=0
   AND smc.strt_config_id=1290015
   AND process_flag=10
  DETAIL
   v_data = smc.custom_option
  WITH nocounter
 ;end select
 CALL clear(1,1)
 IF (curqual=1)
  SET curpos = findstring("#",v_data,1,0)
  SET prevpos = curpos
  SET str = substring(1,(curpos - 1),v_data)
  CALL echo(str)
  SET v_hours_to_keep = str
  SET curpos = findstring("#",v_data,(prevpos+ 1),1)
  SET str = substring((prevpos+ 1),((curpos - prevpos) - 1),v_data)
  SET v_max_rows = str
 ENDIF
 CALL clear(1,1)
 CALL video(nw)
 CALL echo(build("Number of Hours to keep the data : ",v_hours_to_keep))
 CALL echo(build("Max Rows to delete : ",v_max_rows))
 CALL pause(5)
 CALL clear(1,1)
 GO TO exit_script
#exit_script
END GO
