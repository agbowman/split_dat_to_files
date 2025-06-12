CREATE PROGRAM bed_del_dmart_flex_params:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET req_cnt = size(request->flex_ids,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 FREE RECORD idstodelete
 RECORD idstodelete(
   1 deleted_items[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
 )
 DECLARE idx = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM br_datamart_value b
  PLAN (b
   WHERE expand(idx,1,req_cnt,b.br_datamart_flex_id,request->flex_ids[idx].flex_id)
    AND (b.br_datamart_category_id=request->category_id))
  HEAD REPORT
   cnt = 0, stat = alterlist(idstodelete->deleted_items,50)
  HEAD b.br_datamart_value_id
   cnt = (cnt+ 1)
   IF (mod(cnt,50)=1)
    stat = alterlist(idstodelete->deleted_items,(cnt+ 49))
   ENDIF
   idstodelete->deleted_items[cnt].parent_entity_id = b.br_datamart_value_id, idstodelete->
   deleted_items[cnt].parent_entity_name = "BR_DATAMART_VALUE"
  FOOT REPORT
   stat = alterlist(idstodelete->deleted_items,cnt)
  WITH nocounter
 ;end select
 DELETE  FROM br_datamart_value b,
   (dummyt d  WITH seq = value(req_cnt))
  SET b.seq = 1
  PLAN (d)
   JOIN (b
   WHERE (b.br_datamart_category_id=request->category_id)
    AND (b.br_datamart_flex_id=request->flex_ids[d.seq].flex_id))
  WITH nocounter
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Remove from datamart value failure"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 EXECUTE bed_ens_del_hist_rows  WITH replace("REQUEST",idstodelete)
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
