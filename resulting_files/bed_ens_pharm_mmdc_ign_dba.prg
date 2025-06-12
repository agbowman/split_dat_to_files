CREATE PROGRAM bed_ens_pharm_mmdc_ign:dba
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
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SET cnt = size(request->products,5)
 IF (cnt > 0)
  SET ierrcode = 0
  INSERT  FROM br_name_value b,
    (dummyt d  WITH seq = value(cnt))
   SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_nv_key1 = "MLTM_MMDC_IGN", b.br_name =
    "MEDICATION_DEFINITION",
    b.br_value = cnvtstring(request->products[d.seq].item_id), b.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), b.updt_id = reqinfo->updt_id,
    b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (b)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->error_msg = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
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
