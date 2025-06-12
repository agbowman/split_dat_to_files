CREATE PROGRAM bmdi_add_get_preference:dba
 RECORD reply(
   1 qual[*]
     2 display = vc
     2 description = vc
     2 custom_option = vc
     2 strt_config_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE lstatus = i2
 DECLARE addbmdidefaultpreference(null) = i4
 DECLARE getbmdipreference(null) = i4
 DECLARE updatebmdipreference(null) = i4
 SET reply->status_data.status = "F"
 IF ((request->action_type=1))
  SET lstatus = getbmdipreference(null)
  IF (lstatus != 0)
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->action_type=2))
  SET lstatus = updatebmdipreference(null)
  IF (lstatus != 0)
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE getbmdipreference(null)
   SET count = 0
   SELECT INTO "nl:"
    FROM strt_model_custom smc
    WHERE strt_config_id IN (1282103, 1282105, 1282154)
    DETAIL
     count += 1, stat = alterlist(reply->qual,count), reply->qual[count].strt_config_id = smc
     .strt_config_id,
     reply->qual[count].custom_option = smc.custom_option, reply->qual[count].description = smc
     .description, reply->qual[count].display = smc.display
    WITH nocounter
   ;end select
   IF (count=3)
    SET reply->status_data.status = "S"
    CALL echorecord(reply)
    RETURN(0)
   ELSE
    SET lstatus = addbmdidefaultpreference(null)
    RETURN(lstatus)
   ENDIF
 END ;Subroutine
 SUBROUTINE addbmdidefaultpreference(null)
   SET stat = alterlist(reply->qual,3)
   SET reply->qual[1].strt_config_id = 1282103
   SET reply->qual[1].custom_option = "0"
   SET reply->qual[1].description = "View across all facilities"
   SET reply->qual[1].display = "BMDI_GET_ADT_BY_NURSEUNIT"
   SET reply->qual[2].strt_config_id = 1282105
   SET reply->qual[2].custom_option = "1"
   SET reply->qual[2].description = "Enable unique WTS assoc/dissoc"
   SET reply->qual[2].display = "BMDI_MANAGE_ADT"
   SET reply->qual[3].strt_config_id = 1282154
   SET reply->qual[3].custom_option = "0"
   SET reply->qual[3].description = "Hide monitors based on monitor type"
   SET reply->qual[3].display = "BMDI_GET_DEVINFO_BY_PERSON"
   FOR (i = 1 TO 3)
    INSERT  FROM strt_model_custom smc
     SET smc.strt_config_id = reply->qual[i].strt_config_id, smc.description = reply->qual[i].
      description, smc.display = reply->qual[i].display,
      smc.custom_option = reply->qual[i].custom_option, smc.process_flag = 10, smc.updt_id = reqinfo
      ->updt_id,
      smc.updt_dt_tm = cnvtdatetime(sysdate), smc.updt_task = reqinfo->updt_task, smc.updt_applctx =
      reqinfo->updt_applctx,
      smc.updt_cnt = 0
     WITH nocounter
    ;end insert
    COMMIT
   ENDFOR
   SET lstatus = getbmdipreference(null)
   RETURN(0)
 END ;Subroutine
 SUBROUTINE updatebmdipreference(null)
   SET qual_cnt = size(request->qual,5)
   FOR (count1 = 1 TO qual_cnt)
     UPDATE  FROM strt_model_custom smc
      SET smc.custom_option = request->qual[count1].custom_option, smc.updt_id = reqinfo->updt_id,
       smc.updt_dt_tm = cnvtdatetime(sysdate),
       smc.updt_task = reqinfo->updt_task, smc.updt_applctx = reqinfo->updt_applctx, smc.updt_cnt = (
       smc.updt_cnt+ 1)
      PLAN (smc
       WHERE (smc.strt_config_id=request->qual[count1].strt_config_id))
      WITH nocounter
     ;end update
   ENDFOR
   IF (curqual=0)
    RETURN(1)
   ELSE
    COMMIT
    SET lstatus = getbmdipreference(null)
    RETURN(0)
   ENDIF
 END ;Subroutine
END GO
