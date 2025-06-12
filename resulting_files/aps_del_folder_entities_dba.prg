CREATE PROGRAM aps_del_folder_entities:dba
 IF (validate(reply->status_data.status,null)=null)
  RECORD reply(
    1 entity_qual[*]
      2 folder_id = f8
      2 entity_id = f8
      2 parent_entity_name = c32
      2 entity_type_flag = i2
      2 accession_nbr = c21
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD comment(
   1 comment_qual[*]
     2 comment_id = f8
 )
#script
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET entity_cnt = cnvtint(size(request->entity_qual,5))
 SET comment_cnt = 0
 SET folder_entity_cnt = 0
 IF (entity_cnt > 0)
  SELECT INTO "nl:"
   afe.folder_id, afe.entity_id, afe.display
   FROM ap_folder_entity afe,
    (dummyt d1  WITH seq = value(entity_cnt))
   PLAN (d1)
    JOIN (afe
    WHERE (afe.parent_entity_id=request->entity_qual[d1.seq].parent_entity_id)
     AND (afe.parent_entity_name=request->entity_qual[d1.seq].parent_entity_name))
   HEAD REPORT
    folder_entity_cnt = 0, comment_cnt = 0
   DETAIL
    folder_entity_cnt = (folder_entity_cnt+ 1)
    IF (mod(folder_entity_cnt,10)=1)
     stat = alterlist(request->folder_entity_qual,(folder_entity_cnt+ 9)), stat = alterlist(reply->
      entity_qual,(folder_entity_cnt+ 9)), stat = alterlist(comment->comment_qual,(folder_entity_cnt
      + 9))
    ENDIF
    request->folder_entity_qual[folder_entity_cnt].entity_id = afe.entity_id, reply->entity_qual[
    folder_entity_cnt].folder_id = afe.folder_id, reply->entity_qual[folder_entity_cnt].entity_id =
    afe.entity_id,
    reply->entity_qual[folder_entity_cnt].parent_entity_name = afe.parent_entity_name, reply->
    entity_qual[folder_entity_cnt].entity_type_flag = afe.entity_type_flag, reply->entity_qual[
    folder_entity_cnt].accession_nbr = afe.accession_nbr
    IF (afe.comment_id != 0.0)
     comment_cnt = (comment_cnt+ 1), stat = alterlist(comment->comment_qual,comment_cnt), comment->
     comment_qual[comment_cnt].comment_id = afe.comment_id
    ENDIF
   FOOT REPORT
    stat = alterlist(request->folder_entity_qual,folder_entity_cnt), stat = alterlist(reply->
     entity_qual,folder_entity_cnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER_ENTITY"
   SET reply->status_data.status = "Z"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ELSE
  SET folder_entity_cnt = cnvtint(size(request->folder_entity_qual,5))
  SELECT INTO "nl:"
   afe.entity_id
   FROM ap_folder_entity afe,
    (dummyt d  WITH seq = value(folder_entity_cnt))
   PLAN (d)
    JOIN (afe
    WHERE (afe.entity_id=request->folder_entity_qual[d.seq].entity_id)
     AND afe.comment_id != 0.0)
   HEAD REPORT
    comment_cnt = 0
   DETAIL
    comment_cnt = (comment_cnt+ 1), stat = alterlist(comment->comment_qual,comment_cnt), comment->
    comment_qual[comment_cnt].comment_id = afe.comment_id
   WITH nocounter
  ;end select
 ENDIF
 DELETE  FROM ap_folder_entity afe,
   (dummyt d  WITH seq = value(folder_entity_cnt))
  SET afe.entity_id = request->folder_entity_qual[d.seq].entity_id
  PLAN (d)
   JOIN (afe
   WHERE (afe.entity_id=request->folder_entity_qual[d.seq].entity_id))
  WITH nocounter
 ;end delete
 IF (curqual != folder_entity_cnt)
  GO TO afe_del_failed
 ENDIF
 IF (comment_cnt > 0)
  DELETE  FROM long_text lt,
    (dummyt d  WITH seq = value(comment_cnt))
   SET lt.long_text_id = comment->comment_qual[d.seq].comment_id
   PLAN (d)
    JOIN (lt
    WHERE (lt.long_text_id=comment->comment_qual[d.seq].comment_id)
     AND lt.long_text_id != 0.0)
   WITH nocounter
  ;end delete
  IF (curqual != comment_cnt)
   GO TO lt_del_failed
  ENDIF
 ENDIF
 GO TO exit_script
#lt_del_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#afe_del_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER_ENTITY"
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
