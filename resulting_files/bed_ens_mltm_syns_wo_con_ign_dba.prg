CREATE PROGRAM bed_ens_mltm_syns_wo_con_ign:dba
 FREE SET reply
 RECORD reply(
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
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET cnt = size(request->synonyms,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM br_name_value b,
   (dummyt d  WITH seq = value(cnt))
  SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_nv_key1 = "MLTM_IGN_CONCEPT", b.br_name =
   "ORDER_CATALOG_SYNONYM",
   b.br_value = cnvtstring(request->synonyms[d.seq].synonym_id), b.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), b.updt_id = reqinfo->updt_id,
   b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (request->synonyms[d.seq].remove_ind=0))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = build("Unable to insert ignored rows")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 DELETE  FROM br_name_value b,
   (dummyt d  WITH seq = value(cnt))
  SET b.seq = 1
  PLAN (d
   WHERE (request->synonyms[d.seq].remove_ind=1))
   JOIN (b
   WHERE b.br_nv_key1="MLTM_IGN_CONCEPT"
    AND b.br_name="ORDER_CATALOG_SYNONYM"
    AND b.br_value=cnvtstring(request->synonyms[d.seq].synonym_id))
  WITH nocounter
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = build("Unable to delete ignored rows")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
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
