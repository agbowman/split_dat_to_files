CREATE PROGRAM bed_imp_time_zone:dba
 FREE SET reply
 RECORD reply(
   1 tzlist[*]
     2 tz_id = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET new_id = 0.0
 SET row_cnt = size(requestin->list_0,5)
 SET stat = alterlist(reply->tzlist,row_cnt)
 FOR (x = 1 TO row_cnt)
   SELECT INTO "NL:"
    j = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_id = cnvtreal(j)
    WITH format, counter
   ;end select
   SET reply->tzlist[x].tz_id = new_id
   INSERT  FROM br_time_zone b
    SET b.time_zone_id = new_id, b.description = requestin->list_0[x].description, b.time_zone =
     requestin->list_0[x].time_zone,
     b.sequence = cnvtint(requestin->list_0[x].sequence), b.region = requestin->list_0[x].region, b
     .active_ind = 1,
     b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
     reqinfo->updt_task,
     b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].description),
     " into the br_time_zone table.")
    GO TO exit_script
   ENDIF
 ENDFOR
 GO TO exit_script
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_TIME_ZONE","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
