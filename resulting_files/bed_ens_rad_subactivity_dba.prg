CREATE PROGRAM bed_ens_rad_subactivity:dba
 FREE SET reply
 RECORD reply(
   1 relations[*]
     2 subactivity
       3 code_value = f8
       3 display = vc
     2 accession_format
       3 code_value = f8
       3 display = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET cnt = size(request->relations,5)
 SET stat = alterlist(reply->relations,cnt)
 FOR (x = 1 TO cnt)
   IF ((request->relations[x].accession_format.code_value=0))
    SELECT INTO "nl:"
     FROM br_name_value b
     WHERE b.br_nv_key1="RAD_SUB_ACC_FORMAT"
      AND b.br_name=cnvtstring(request->relations[x].subactivity.code_value)
    ;end select
    IF (curqual > 0)
     DELETE  FROM br_name_value b
      WHERE b.br_nv_key1="RAD_SUB_ACC_FORMAT"
       AND b.br_name=cnvtstring(request->relations[x].subactivity.code_value)
      WITH nocounter
     ;end delete
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to delete subactivity: ",trim(request->relations[x].subactivity.
        display)," from the br_name_value table.")
      GO TO exit_script
     ENDIF
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM br_name_value b
     WHERE b.br_name=cnvtstring(request->relations[x].subactivity.code_value)
      AND b.br_nv_key1="RAD_SUB_ACC_FORMAT"
     WITH nocounter
    ;end select
    IF (curqual > 0)
     UPDATE  FROM br_name_value b
      SET b.br_value = cnvtstring(request->relations[x].accession_format.code_value), b.updt_dt_tm =
       cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->
       updt_applctx
      WHERE b.br_name=cnvtstring(request->relations[x].subactivity.code_value)
       AND b.br_nv_key1="RAD_SUB_ACC_FORMAT"
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to update subactivity: ",trim(request->relations[x].subactivity.
        display)," with accession format: ",trim(request->relations[x].accession_format.display),
       " in the br_name_value table.")
      GO TO exit_script
     ENDIF
    ELSE
     SET new_name_id = 0.0
     SELECT INTO "NL:"
      j = seq(bedrock_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_name_id = cnvtreal(j)
      WITH format, counter
     ;end select
     INSERT  FROM br_name_value b
      SET b.br_name_value_id = new_name_id, b.br_nv_key1 = "RAD_SUB_ACC_FORMAT", b.br_name =
       cnvtstring(request->relations[x].subactivity.code_value),
       b.br_value = cnvtstring(request->relations[x].accession_format.code_value), b.updt_dt_tm =
       cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to insert subactivity: ",trim(request->relations[x].subactivity.
        display)," with accession format: ",trim(request->relations[x].accession_format.display),
       " into the br_name_value table.")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   SET reply->relations[x].subactivity.code_value = request->relations[x].subactivity.code_value
   SET reply->relations[x].subactivity.display = request->relations[x].subactivity.display
   SET reply->relations[x].accession_format.code_value = request->relations[x].accession_format.
   code_value
   SET reply->relations[x].accession_format.display = request->relations[x].accession_format.display
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
