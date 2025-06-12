CREATE PROGRAM dm_bmdi_del_acquired_res:dba
 DECLARE v_hours_to_keep = i4 WITH noconstant(0)
 DECLARE v_max_rows = i4 WITH noconstant(0)
 DECLARE v_data = vc WITH noconstant("")
 DECLARE str = vc WITH noconstant("")
 DECLARE v_rows_deleted = i4 WITH noconstant(0)
 DECLARE rows_to_delete = i4 WITH noconstant(0)
 DECLARE total_rows = i4 WITH noconstant(0)
 DECLARE batch_num = i4 WITH noconstant(0)
 DECLARE spancheck = vc WITH noconstant("")
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET curpos = 0
 SET prevpos = 0
 SELECT INTO "nl:"
  FROM strt_model_custom smc
  WHERE smc.strt_model_id=0
   AND smc.strt_config_id=1290015.00
   AND process_flag=10
  DETAIL
   v_data = smc.custom_option
  WITH nocounter
 ;end select
 IF (curqual=1)
  SET curpos = findstring("#",v_data,1,0)
  SET prevpos = curpos
  SET str = substring(1,(curpos - 1),v_data)
  SET v_hours_to_keep = cnvtint(cnvtalphanum(str))
  SET curpos = findstring("#",v_data,(prevpos+ 1),1)
  SET str = substring((prevpos+ 1),((curpos - prevpos) - 1),v_data)
  SET v_max_rows = cnvtint(str)
 ENDIF
 IF (v_hours_to_keep=0)
  CALL echo(build("You must enter a number greater than Zero for hours ,you entered  ",
    v_hours_to_keep))
  GO TO exit_script
 ENDIF
 IF (v_max_rows=0)
  CALL echo(build("You must enter a number greater than Zero for Max Rows ,you entered  ",v_max_rows)
   )
  GO TO exit_script
 ENDIF
 SET spancheck = build2(v_hours_to_keep,",H")
 SELECT INTO "nl:"
  FROM bmdi_acquired_results
  WHERE updt_dt_tm < cnvtlookbehind(spancheck)
 ;end select
 CALL echo(curqual)
 IF (curqual=0)
  CALL echo("No Rows selected.....")
  SET v_rows_deleted = curqual
  GO TO exit_script
 ELSE
  SET rows_to_delete = curqual
  SET total_rows = rows_to_delete
  SET v_rows_deleted = 0
  SET batch_num = (rows_to_delete/ v_max_rows)
  SET i = mod(rows_to_delete,v_max_rows)
  IF (i > 0)
   SET batch_num = (batch_num+ 1)
   CALL echo(batch_num)
  ENDIF
  FOR (i = 1 TO batch_num)
    IF (rows_to_delete < v_max_rows)
     SET v_max_rows = rows_to_delete
    ENDIF
    DELETE  FROM bmdi_acquired_results
     WHERE updt_dt_tm < cnvtlookbehind(spancheck)
     WITH maxqual(bmdi_acquired_results,value(v_max_rows))
    ;end delete
    SET rows_to_delete = (rows_to_delete - curqual)
    SET v_rows_deleted = (v_rows_deleted+ curqual)
    COMMIT
    IF (rows_to_delete=0)
     CALL echo("All rows deleted")
    ENDIF
  ENDFOR
 ENDIF
 IF (total_rows=v_rows_deleted)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 COMMIT
 GO TO exit_script
#exit_script
 IF ((reply->status_data.status="S"))
  SET v_max_rows = v_rows_deleted
  SET v_data = "DM_BMDI_DELETE_ACQUIRED_RESULTS Deleted"
  SET v_data = concat(v_data," ",cnvtstring(v_max_rows))
  SET v_data = concat(v_data," rows")
 ELSE
  IF (v_hours_to_keep=0)
   SET reply->status_data.status = "F"
   SET v_data = "DM_BMDI_DELETE_ACQUIRED_RESULTS Failed ,as hours to keep is ZERO"
  ELSEIF (v_max_rows=0)
   SET reply->status_data.status = "F"
   SET v_data = "DM_BMDI_DELETE_ACQUIRED_RESULTS Failed ,as Max Rows to delete is ZERO"
  ELSEIF (v_rows_deleted=0)
   SET reply->status_data.status = "Z"
   SET v_max_rows = v_rows_deleted
   SET v_data = "DM_BMDI_DELETE_ACQUIRED_RESULTS Failed ,No Rows Qualified for deletion"
  ELSEIF (v_rows_deleted < total_rows)
   SET reply->status_data.status = "Z"
   SET v_max_rows = v_rows_deleted
   SET v_data = "DM_BMDI_DELETE_ACQUIRED_RESULTS Failed ,Partial deletion"
  ENDIF
  SET v_data = concat(v_data," ",cnvtstring(v_rows_deleted))
  SET v_data = concat(v_data," rows")
 ENDIF
 UPDATE  FROM dm_info di
  SET di.info_char = v_data, di.info_number = v_max_rows, di.info_date = cnvtdatetime(curdate,
    curtime3),
   di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE di.info_domain="DM PURGE INFO_MDI"
   AND di.info_name="DM_BMDI_DELETE_ACQUIRED_RESULTS"
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "DM PURGE INFO_MDI", di.info_name = "dm_bmdi_del_acq_res_rows", di
    .info_number = v_max_rows,
    di.info_date = cnvtdatetime(curdate,curtime3), di.info_char = v_data
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
END GO
