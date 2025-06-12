CREATE PROGRAM bed_ens_mltm_syns_wo_concept:dba
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
 UPDATE  FROM order_catalog_synonym o,
   (dummyt d  WITH seq = value(cnt))
  SET o.concept_cki = request->synonyms[d.seq].concept_cki, o.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), o.updt_id = reqinfo->updt_id,
   o.updt_task = reqinfo->updt_task, o.updt_cnt = (o.updt_cnt+ 1), o.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d)
   JOIN (o
   WHERE (o.synonym_id=request->synonyms[d.seq].synonym_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = build("Unable to update rows")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 DELETE  FROM br_name_value b,
   (dummyt d  WITH seq = value(cnt))
  SET b.seq = 1
  PLAN (d)
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
