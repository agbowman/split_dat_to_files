CREATE PROGRAM aps_del_folders:dba
 RECORD temp(
   1 comment_qual[*]
     2 comment_id = f8
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET proxy_cnt = 0
 SET entity_cnt = 0
 SET image_cnt = 0
 SET folders_comment_cnt = 0
 SET folder_cnt = cnvtint(size(request->folder_qual,5))
 SELECT INTO "nl:"
  af.folder_id
  FROM ap_folder af,
   (dummyt d  WITH seq = value(entity_cnt))
  PLAN (d)
   JOIN (af
   WHERE (af.folder_id=request->folder_qual[d.seq].folder_id)
    AND af.comment_id != 0.0)
  HEAD REPORT
   folders_comment_cnt = 0
  DETAIL
   folders_comment_cnt = (folders_comment_cnt+ 1)
   IF (mod(folders_comment_cnt,10)=1)
    stat = alterlist(temp->comment_qual,(folders_comment_cnt+ 9))
   ENDIF
   temp->comment_qual[folders_comment_cnt].comment_id = af.comment_id
  WITH nocounter
 ;end select
 SET stat = alterlist(temp->comment_qual,folders_comment_cnt)
 SELECT INTO "nl:"
  afe.entity_id
  FROM ap_folder_entity afe,
   (dummyt d  WITH seq = value(folder_cnt))
  PLAN (d)
   JOIN (afe
   WHERE (afe.folder_id=request->folder_qual[d.seq].folder_id)
    AND afe.entity_id != 0.0)
  HEAD REPORT
   entity_cnt = 0
  DETAIL
   entity_cnt = (entity_cnt+ 1)
   IF (mod(entity_cnt,10)=1)
    stat = alterlist(request->folder_entity_qual,(entity_cnt+ 9))
   ENDIF
   request->folder_entity_qual[entity_cnt].entity_id = afe.entity_id
  FOOT REPORT
   stat = alterlist(request->folder_entity_qual,entity_cnt)
  WITH nocounter
 ;end select
 CALL echo(entity_cnt)
 IF (entity_cnt > 0)
  EXECUTE aps_del_folder_entities
  IF ((reply->status_data.status="F"))
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 DELETE  FROM ap_folder af,
   (dummyt d  WITH seq = value(folder_cnt))
  SET af.seq = 1
  PLAN (d)
   JOIN (af
   WHERE (af.folder_id=request->folder_qual[d.seq].folder_id))
  WITH nocounter
 ;end delete
 IF (curqual != folder_cnt)
  GO TO af_del_failed
 ENDIF
 SELECT INTO "nl:"
  afp.folder_id
  FROM ap_folder_proxy afp,
   (dummyt d  WITH seq = value(folder_cnt))
  PLAN (d)
   JOIN (afp
   WHERE (afp.folder_id=request->folder_qual[d.seq].folder_id))
  HEAD REPORT
   proxy_cnt = 0
  DETAIL
   proxy_cnt = (proxy_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  aiii.person_id
  FROM ap_image_item_ini aiii,
   (dummyt d  WITH seq = value(folder_cnt))
  PLAN (d)
   JOIN (aiii
   WHERE (aiii.parent_entity_id=request->folder_qual[d.seq].folder_id)
    AND aiii.parent_entity_name="AP_FOLDER")
  HEAD REPORT
   image_cnt = 0
  DETAIL
   image_cnt = (image_cnt+ 1)
  WITH nocounter
 ;end select
 IF (proxy_cnt > 0)
  DELETE  FROM ap_folder_proxy afp,
    (dummyt d  WITH seq = value(folder_cnt))
   SET afp.folder_id = request->folder_qual[d.seq].folder_id
   PLAN (d)
    JOIN (afp
    WHERE (afp.folder_id=request->folder_qual[d.seq].folder_id))
   WITH nocounter
  ;end delete
  IF (curqual != proxy_cnt)
   GO TO afp_del_failed
  ENDIF
 ENDIF
 DELETE  FROM long_text lt,
   (dummyt d  WITH seq = value(folders_comment_cnt))
  SET lt.long_text_id = temp->comment_qual[d.seq].comment_id
  PLAN (d)
   JOIN (lt
   WHERE (lt.long_text_id=temp->comment_qual[d.seq].comment_id)
    AND lt.long_text_id != 0.0)
  WITH nocounter
 ;end delete
 IF (curqual != folders_comment_cnt)
  GO TO lt_del_failed
 ENDIF
 DELETE  FROM ap_image_item_ini aiii,
   (dummyt d  WITH seq = value(folder_cnt))
  SET aiii.parent_entity_id = request->folder_qual[d.seq].folder_id
  PLAN (d)
   JOIN (aiii
   WHERE (aiii.parent_entity_id=request->folder_qual[d.seq].folder_id)
    AND aiii.parent_entity_name="AP_FOLDER")
  WITH nocounter
 ;end delete
 IF (curqual != image_cnt)
  GO TO aiii_del_failed
 ENDIF
 GO TO exit_script
#lt_del_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#afp_del_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER_PROXY"
 SET failed = "T"
 GO TO exit_script
#aiii_del_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_IMAGE_ITEM_INI"
 SET failed = "T"
 GO TO exit_script
#af_del_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
