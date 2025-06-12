CREATE PROGRAM dcp_chg_clinical_txt:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD blobsize(
   1 blobs[*]
     2 blob_length = i4
 )
 SET reply->status_data.status = "S"
 DECLARE template_text = vc
 DECLARE segment_cnt = i4 WITH noconstant(0)
 DECLARE itr = i4 WITH noconstant(0)
 DECLARE buildtext = vc
 SET segment_cnt = size(request->large_text_qual,5)
 SET stat = alterlist(blobsize->blobs,segment_cnt)
 DELETE  FROM long_blob lb
  WHERE (lb.parent_entity_id=request->template_id)
   AND lb.parent_entity_name="CLINICAL_NOTE_TEMPLATE"
  WITH nocounter
 ;end delete
 IF (segment_cnt > 1)
  FOR (itr = 1 TO segment_cnt)
    SET buildtext = notrim(concat(build(itr),"<BLOCKID>",request->large_text_qual[itr].text_segment))
    SET request->large_text_qual[itr].text_segment = notrim(buildtext)
    SET blobsize->blobs[itr].blob_length = size(request->large_text_qual[itr].text_segment,1)
  ENDFOR
 ELSE
  IF (segment_cnt=1)
   SET blobsize->blobs[1].blob_length = size(request->large_text_qual[1].text_segment,1)
  ENDIF
 ENDIF
 INSERT  FROM long_blob lb,
   (dummyt d  WITH seq = segment_cnt)
  SET lb.long_blob_id = cnvtreal(seq(long_data_seq,nextval)), lb.long_blob = request->
   large_text_qual[d.seq].text_segment, lb.updt_dt_tm = cnvtdatetime(curdate,curtime),
   lb.blob_length = blobsize->blobs[d.seq].blob_length, lb.updt_id = reqinfo->updt_id, lb.updt_task
    = reqinfo->updt_task,
   lb.updt_applctx = reqinfo->updt_applctx, lb.updt_cnt = 0, lb.parent_entity_name =
   "CLINICAL_NOTE_TEMPLATE",
   lb.parent_entity_id = request->template_id, lb.active_ind = 1, lb.active_status_cd = reqdata->
   active_status_cd,
   lb.active_status_dt_tm = cnvtdatetime(curdate,curtime), lb.active_status_prsnl_id = reqinfo->
   updt_id
  PLAN (d)
   JOIN (lb)
  WITH nocounter
 ;end insert
 UPDATE  FROM clinical_note_template cnt
  SET cnt.updt_dt_tm = cnvtdatetime(curdate,curtime3), cnt.updt_id = reqinfo->updt_id, cnt.updt_task
    = reqinfo->updt_task,
   cnt.updt_applctx = reqinfo->updt_applctx, cnt.updt_cnt = (cnt.updt_cnt+ 1), cnt.long_blob_id = 0
  WHERE (cnt.template_id=request->template_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reply->status_data.status = "F"
 ENDIF
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CLINICAL_NOTE_TEMPLATE"
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
END GO
