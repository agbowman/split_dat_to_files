CREATE PROGRAM aps_del_discrete_entities:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD purge_input(
   1 qual[*]
     2 blob_identifier = vc
 )
 RECORD purge_output(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp_del_entities(
   1 qual[*]
     2 entity_id = f8
 )
 RECORD temp_del_images(
   1 qual[*]
     2 blob_ref_id = f8
 )
 RECORD temp_del_comments(
   1 qual[*]
     2 comment_id = f8
 )
 RECORD temp_del_tbnl_images(
   1 qual[*]
     2 long_blob_id = f8
 )
#script
 SET failed = "F"
 SET delimagecnt = 0
 SET delcommentcnt = 0
 SET deltbnlimagecnt = 0
 SET deldiscretecnt = 0
 SET dummy_var = 0
 SET tempdelpurgecnt = 0
 SET request_size = cnvtint(size(request->qual,5))
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0
 SET dicom_storage_cd = 0.0
 SET code_set = 25
 SET cdf_meaning = "DICOM_SIUID"
 EXECUTE cpm_get_cd_for_cdf
 SET dicom_storage_cd = code_value
 SELECT INTO "nl:"
  br.blob_ref_id, br.sequence_nbr, bsr.blob_ref_id,
  ade.entity_id, lt.long_text_id, lt2.long_text_id,
  lb.long_blob_id
  FROM blob_reference br,
   blob_summary_ref bsr,
   ap_discrete_entity ade,
   long_text lt,
   long_text lt2,
   long_blob lb,
   (dummyt d1  WITH seq = value(request_size))
  PLAN (d1)
   JOIN (br
   WHERE (br.blob_ref_id=request->qual[d1.seq].parent_entity_id)
    AND (request->qual[d1.seq].parent_entity_name="BLOB_REFERENCE"))
   JOIN (ade
   WHERE ade.entity_id=br.parent_entity_id
    AND br.parent_entity_name="AP_DISCRETE_ENTITY")
   JOIN (bsr
   WHERE bsr.blob_ref_id=br.blob_ref_id)
   JOIN (lt
   WHERE lt.long_text_id=br.chartable_note_id)
   JOIN (lt2
   WHERE lt2.long_text_id=br.non_chartable_note_id)
   JOIN (lb
   WHERE lb.long_blob_id=bsr.long_blob_id)
  ORDER BY br.blob_ref_id
  HEAD REPORT
   deldiscretecnt = 0, delimagecnt = 0, delcommentcnt = 0,
   deltbnlimagecnt = 0, tempdelpurgecnt = 0
  HEAD br.blob_ref_id
   delimagecnt = (delimagecnt+ 1), stat = alterlist(temp_del_images->qual,delimagecnt),
   temp_del_images->qual[delimagecnt].blob_ref_id = br.blob_ref_id,
   deldiscretecnt = (deldiscretecnt+ 1), stat = alterlist(temp_del_entities->qual,deldiscretecnt),
   temp_del_entities->qual[deldiscretecnt].entity_id = ade.entity_id
   IF (br.storage_cd=dicom_storage_cd)
    tempdelpurgecnt = (tempdelpurgecnt+ 1), stat = alterlist(purge_input->qual,tempdelpurgecnt),
    purge_input->qual[tempdelpurgecnt].blob_identifier = br.blob_handle
   ENDIF
   IF (lt.long_text_id > 0)
    delcommentcnt = (delcommentcnt+ 1), stat = alterlist(temp_del_comments->qual,delcommentcnt),
    temp_del_comments->qual[delcommentcnt].comment_id = lt.long_text_id
   ENDIF
   IF (lt2.long_text_id > 0)
    delcommentcnt = (delcommentcnt+ 1), stat = alterlist(temp_del_comments->qual,delcommentcnt),
    temp_del_comments->qual[delcommentcnt].comment_id = lt2.long_text_id
   ENDIF
   IF (lb.long_blob_id > 0)
    deltbnlimagecnt = (deltbnlimagecnt+ 1), stat = alterlist(temp_del_tbnl_images->qual,
     deltbnlimagecnt), temp_del_tbnl_images->qual[deltbnlimagecnt].long_blob_id = lb.long_blob_id
   ENDIF
  DETAIL
   dummy_var = 0
  WITH nocounter
 ;end select
 IF (delimagecnt != request_size)
  GO TO get_items_failed
 ENDIF
 IF (delimagecnt > 0)
  DELETE  FROM blob_reference br,
    (dummyt d  WITH seq = value(delimagecnt))
   SET br.blob_ref_id = temp_del_images->qual[d.seq].blob_ref_id
   PLAN (d)
    JOIN (br
    WHERE (br.blob_ref_id=temp_del_images->qual[d.seq].blob_ref_id))
   WITH nocounter
  ;end delete
  IF (curqual != delimagecnt)
   GO TO image_failed
  ENDIF
  DELETE  FROM blob_summary_ref bsr,
    (dummyt d  WITH seq = value(delimagecnt))
   SET bsr.blob_ref_id = temp_del_images->qual[d.seq].blob_ref_id
   PLAN (d)
    JOIN (bsr
    WHERE (bsr.blob_ref_id=temp_del_images->qual[d.seq].blob_ref_id))
   WITH nocounter
  ;end delete
  IF (curqual != delimagecnt)
   GO TO image_tbnl_failed
  ENDIF
 ENDIF
 IF (deltbnlimagecnt > 0)
  DELETE  FROM long_blob lb,
    (dummyt d  WITH seq = value(deltbnlimagecnt))
   SET lb.long_blob_id = temp_del_tbnl_images->qual[d.seq].long_blob_id
   PLAN (d)
    JOIN (lb
    WHERE (lb.long_blob_id=temp_del_tbnl_images->qual[d.seq].long_blob_id))
   WITH nocounter
  ;end delete
  IF (curqual != deltbnlimagecnt)
   GO TO tbnl_images_failed
  ENDIF
 ENDIF
 IF (delcommentcnt > 0)
  DELETE  FROM long_text lt,
    (dummyt d  WITH seq = value(delcommentcnt))
   SET lt.long_text_id = temp_del_comments->qual[d.seq].comment_id
   PLAN (d)
    JOIN (lt
    WHERE (lt.long_text_id=temp_del_comments->qual[d.seq].comment_id))
   WITH nocounter
  ;end delete
  IF (curqual != delcommentcnt)
   GO TO comment_failed
  ENDIF
 ENDIF
 IF (deldiscretecnt > 0)
  DELETE  FROM ap_discrete_entity ade,
    (dummyt d  WITH seq = value(deldiscretecnt))
   SET ade.entity_id = temp_del_entities->qual[d.seq].entity_id
   PLAN (d)
    JOIN (ade
    WHERE (ade.entity_id=temp_del_entities->qual[d.seq].entity_id))
   WITH nocounter
  ;end delete
  IF (curqual != deldiscretecnt)
   GO TO entity_failed
  ENDIF
 ENDIF
 IF (tempdelpurgecnt > 0)
  EXECUTE aps_add_blobs_to_purge
  IF ((purge_output->status_data.status != "S"))
   GO TO add_to_purge_failed
  ENDIF
 ENDIF
 GO TO exit_script
#get_items_failed
 SET reply->status_data.subeventstatus[1].operationname = "SELECT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "BLOB_REFERENCE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error retrieving items"
 SET failed = "T"
 GO TO exit_script
#add_to_purge_failed
 SET reply->status_data.subeventstatus[1].operationname = purge_output->status_data.subeventstatus[1]
 .operationname
 SET reply->status_data.subeventstatus[1].operationstatus = purge_output->status_data.subeventstatus[
 1].operationstatus
 SET reply->status_data.subeventstatus[1].targetobjectname = purge_output->status_data.
 subeventstatus[1].targetobjectname
 SET reply->status_data.subeventstatus[1].targetobjectvalue = purge_output->status_data.
 subeventstatus[1].targetobjectvalue
 SET failed = "T"
 GO TO exit_script
#image_tbnl_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "BLOB_SUMMARY_REF"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error deleting thumbnail"
 SET failed = "T"
 GO TO exit_script
#tbnl_images_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_BLOB"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error deleting thumbnail"
 SET failed = "T"
 GO TO exit_script
#comment_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error deleting notes"
 SET failed = "T"
 GO TO exit_script
#image_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "BLOB_REFERENCE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error deleting image reference"
 SET failed = "T"
 GO TO exit_script
#entity_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "AP_DISCRETE_ENTITY"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error deleting discrete entity"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
