CREATE PROGRAM bed_ens_mltm_route_ign:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET cnt = size(request->multum_routes,5)
 FOR (x = 1 TO cnt)
   SET new_name_id = 0.0
   SELECT INTO "NL:"
    j = seq(bedrock_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_name_id = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM br_name_value b
    SET b.br_name_value_id = new_name_id, b.br_nv_key1 = "MLTM_IGN_ROUTE", b.br_name =
     "MLTM_DRC_PREMISE",
     b.br_value = cnvtstring(request->multum_routes[x].route_id), b.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET reply->error_msg = concat("Unable to insert: ",trim(cnvtstring(request->multum_routes[x].
       route_id))," into the br_name_value table.")
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
