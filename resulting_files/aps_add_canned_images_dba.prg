CREATE PROGRAM aps_add_canned_images:dba
 RECORD reply(
   1 image_qual[*]
     2 image_index = i4
     2 entity_id = f8
     2 blob_ref_id = f8
     2 tbnl_long_blob_id = f8
     2 chartable_note_id = f8
     2 non_chartable_note_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp_data_copy(
   1 qual[*]
     2 image_index = i4
     2 entity_id = f8
     2 blob_ref_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 valid_from_dt_tm = dq8
     2 sequence_nbr = i4
     2 owner_cd = f8
     2 storage_cd = f8
     2 format_cd = f8
     2 blob_handle = vc
     2 blob_title = vc
     2 tbnl_long_blob_id = f8
     2 tbnl_format_cd = f8
     2 chartable_note_id = f8
     2 non_chartable_note_id = f8
     2 create_prsnl_id = f8
     2 source_device_cd = f8
     2 publish_flag = i2
     2 updt_cnt = i4
     2 tbnl_long_blob_id = f8
     2 tbnl_image = vgc
     2 chartable_comment_id = f8
     2 chartable_comment = vc
     2 chartable_updt_cnt = i4
     2 non_chartable_comment_id = f8
     2 non_chartable_comment = vc
     2 non_chartable_updt_cnt = i4
     2 blob_foreign_ident = vc
 )
 RECORD temp_add_discrete_entity(
   1 qual[*]
     2 entity_id = f8
 )
 RECORD temp_copy_ce_images(
   1 qual[*]
     2 image_index = i4
     2 parent_entity_id = f8
     2 parent_entity_name = c32
     2 blob_handle = vc
 )
 RECORD temp_copy_dept_images(
   1 qual[*]
     2 image_index = i4
     2 parent_entity_id = f8
     2 parent_entity_name = c32
     2 blob_handle = vc
 )
 RECORD temp_add_images(
   1 qual[*]
     2 blob_ref_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 valid_from_dt_tm = dq8
     2 sequence_nbr = i4
     2 owner_cd = f8
     2 storage_cd = f8
     2 format_cd = f8
     2 blob_handle = vc
     2 blob_title = vc
     2 tbnl_long_blob_id = f8
     2 tbnl_format_cd = f8
     2 chartable_note_id = f8
     2 non_chartable_note_id = f8
     2 create_prsnl_id = f8
     2 source_device_cd = f8
     2 publish_flag = i2
     2 updt_cnt = i4
     2 blob_foreign_ident = vc
 )
 RECORD temp_add_comment(
   1 qual[*]
     2 comment_id = f8
     2 comment = vc
     2 blob_ref_id = f8
     2 updt_cnt = i4
 )
 RECORD temp_add_tbnl_images(
   1 qual[*]
     2 tbnl_long_blob_id = f8
     2 tbnl_image = vgc
     2 blob_ref_id = f8
 )
 RECORD temp_chg_pvw_dataset(
   1 qual[*]
     2 dataset_uid = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
 )
 RECORD temp_add_pvw_dataset(
   1 qual[*]
 )
#script
 SET failed = "F"
 SET eadd = 1
 SET eupdate = 2
 SET image_index = 0
 SET image_cnt = cnvtint(size(request->image_qual,5))
 SET new_canned_cnt = 0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET author_type_cd = 0.0
 SET deleted_status_cd = 0.0
 SET chartable_note_cd = 0.0
 SET non_chartable_note_cd = 0.0
 SET blob_ref_id = 0.0
 SET entity_id = 0.0
 SET chg_pvw_dataset_cnt = 0
 SET tbnl_images_cnt = 0
 SET tbnl_long_blob_id = 0.0
 SET note_cnt = 0
 SET chartable_note_id = 0.0
 SET non_chartable_note_id = 0.0
 SET tempblobsize = 0
 SET active_status_cd = 0.0
 SET nbr_items = 0
 SET n_canned_image = 6
 SET copy_ce_cnt = 0
 SET copy_dept_cnt = 0
 SET temp_copy_cnt = 0
 SET ocf_compression_cd = 0.0
 SET dicom_storage_cd = 0.0
 SET ap_foreign_image_ident_note_cd = 0.0
 DECLARE outbufmaxsiz = i2
 SET cdf_meaning = "ACTIVE"
 SET code_set = 48
 EXECUTE cpm_get_cd_for_cdf
 SET active_status_cd = code_value
 SET code_set = 21
 SET cdf_meaning = "AUTHOR"
 EXECUTE cpm_get_cd_for_cdf
 SET author_type_cd = code_value
 SET code_set = 48
 SET cdf_meaning = "DELETED"
 EXECUTE cpm_get_cd_for_cdf
 SET deleted_status_cd = code_value
 SET code_set = 14
 SET cdf_meaning = "APIMGCHART"
 EXECUTE cpm_get_cd_for_cdf
 SET chartable_note_cd = code_value
 SET code_set = 14
 SET cdf_meaning = "APNOIMGCHART"
 EXECUTE cpm_get_cd_for_cdf
 SET non_chartable_note_cd = code_value
 SET code_set = 14
 SET cdf_meaning = "APIMGFRGNID"
 EXECUTE cpm_get_cd_for_cdf
 SET ap_foreign_image_ident_note_cd = code_value
 SET code_set = 120
 SET cdf_meaning = "OCFCOMP"
 EXECUTE cpm_get_cd_for_cdf
 SET ocf_compression_cd = code_value
 SET code_set = 25
 SET cdf_meaning = "DICOM_SIUID"
 EXECUTE cpm_get_cd_for_cdf
 SET dicom_storage_cd = code_value
 SET stat = alterlist(reply->image_qual,image_cnt)
 FOR (image_index = 1 TO image_cnt)
   CASE (request->image_qual[image_index].ensure_type)
    OF eadd:
     SET new_canned_cnt = (new_canned_cnt+ 1)
     SET reply->image_qual[new_canned_cnt].image_index = request->image_qual[image_index].image_index
     SET stat = alterlist(temp_add_discrete_entity->qual,new_canned_cnt)
     SET stat = alterlist(temp_add_images->qual,new_canned_cnt)
     SELECT INTO "nl:"
      seq_nbr = seq(pathnet_seq,nextval)
      FROM dual
      DETAIL
       entity_id = seq_nbr
      WITH format, nocounter
     ;end select
     IF (curqual=0)
      GO TO seq_failed
     ENDIF
     SET temp_add_discrete_entity->qual[new_canned_cnt].entity_id = entity_id
     SET reply->image_qual[new_canned_cnt].entity_id = entity_id
     SELECT INTO "nl:"
      seq_nbr = seq(pathnet_seq,nextval)
      FROM dual
      DETAIL
       blob_ref_id = seq_nbr
      WITH format, nocounter
     ;end select
     IF (curqual=0)
      GO TO seq_failed
     ENDIF
     SET reply->image_qual[new_canned_cnt].blob_ref_id = blob_ref_id
     SET temp_add_images->qual[new_canned_cnt].blob_ref_id = blob_ref_id
     SET temp_add_images->qual[new_canned_cnt].parent_entity_name = "AP_DISCRETE_ENTITY"
     SET temp_add_images->qual[new_canned_cnt].parent_entity_id = entity_id
     SET temp_add_images->qual[new_canned_cnt].valid_from_dt_tm = cnvtdatetime(request->image_qual[
      image_index].valid_from_dt_tm)
     SET temp_add_images->qual[new_canned_cnt].sequence_nbr = request->image_qual[image_index].
     sequence_nbr
     SET temp_add_images->qual[new_canned_cnt].owner_cd = request->image_qual[image_index].owner_cd
     SET temp_add_images->qual[new_canned_cnt].storage_cd = request->image_qual[image_index].
     storage_cd
     SET temp_add_images->qual[new_canned_cnt].format_cd = request->image_qual[image_index].format_cd
     SET temp_add_images->qual[new_canned_cnt].blob_handle = request->image_qual[image_index].
     blob_handle
     SET temp_add_images->qual[new_canned_cnt].blob_title = request->image_qual[image_index].
     blob_title
     SET temp_add_images->qual[new_canned_cnt].create_prsnl_id = request->image_qual[image_index].
     create_prsnl_id
     SET temp_add_images->qual[new_canned_cnt].source_device_cd = request->image_qual[image_index].
     source_device_cd
     SET temp_add_images->qual[new_canned_cnt].publish_flag = request->image_qual[image_index].
     publish_flag
     SET temp_add_images->qual[new_canned_cnt].updt_cnt = request->image_qual[image_index].updt_cnt
     SET temp_add_images->qual[new_canned_cnt].blob_foreign_ident = request->image_qual[image_index].
     blob_foreign_ident
     SET tbnl_images_cnt = (tbnl_images_cnt+ 1)
     SET stat = alterlist(temp_add_tbnl_images->qual,tbnl_images_cnt)
     SELECT INTO "nl:"
      seq_nbr = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       tbnl_long_blob_id = seq_nbr
      WITH format, nocounter
     ;end select
     IF (curqual=0)
      GO TO seq_failed
     ENDIF
     SET reply->image_qual[new_canned_cnt].tbnl_long_blob_id = tbnl_long_blob_id
     SET temp_add_tbnl_images->qual[tbnl_images_cnt].tbnl_long_blob_id = tbnl_long_blob_id
     SET temp_add_images->qual[new_canned_cnt].tbnl_format_cd = request->image_qual[image_index].
     tbnl_format_cd
     SET temp_add_tbnl_images->qual[tbnl_images_cnt].blob_ref_id = blob_ref_id
     SET temp_add_tbnl_images->qual[tbnl_images_cnt].tbnl_image = request->image_qual[image_index].
     long_blob
     SET temp_add_images->qual[new_canned_cnt].tbnl_long_blob_id = tbnl_long_blob_id
     IF (textlen(request->image_qual[image_index].chartable_note) > 0)
      SET note_cnt = (note_cnt+ 1)
      SET stat = alterlist(temp_add_comment->qual,note_cnt)
      SET temp_add_comment->qual[note_cnt].blob_ref_id = blob_ref_id
      SELECT INTO "nl:"
       seq_nbr = seq(long_data_seq,nextval)
       FROM dual
       DETAIL
        chartable_note_id = seq_nbr
       WITH format, nocounter
      ;end select
      IF (curqual=0)
       GO TO seq_failed
      ENDIF
      SET reply->image_qual[new_canned_cnt].chartable_note_id = chartable_note_id
      SET temp_add_comment->qual[note_cnt].comment_id = chartable_note_id
      SET temp_add_comment->qual[note_cnt].comment = request->image_qual[image_index].chartable_note
      SET temp_add_comment->qual[note_cnt].updt_cnt = request->image_qual[image_index].
      chartable_note_updt_cnt
      SET temp_add_images->qual[new_canned_cnt].chartable_note_id = chartable_note_id
     ELSE
      SET temp_add_images->qual[new_canned_cnt].chartable_note_id = 0
     ENDIF
     IF (textlen(request->image_qual[image_index].non_chartable_note) > 0)
      SET note_cnt = (note_cnt+ 1)
      SET stat = alterlist(temp_add_comment->qual,note_cnt)
      SET temp_add_comment->qual[note_cnt].blob_ref_id = blob_ref_id
      SELECT INTO "nl:"
       seq_nbr = seq(long_data_seq,nextval)
       FROM dual
       DETAIL
        non_chartable_note_id = seq_nbr
       WITH format, nocounter
      ;end select
      IF (curqual=0)
       GO TO seq_failed
      ENDIF
      SET reply->image_qual[new_canned_cnt].non_chartable_note_id = non_chartable_note_id
      SET temp_add_comment->qual[note_cnt].comment_id = non_chartable_note_id
      SET temp_add_comment->qual[note_cnt].comment = request->image_qual[image_index].
      non_chartable_note
      SET temp_add_comment->qual[note_cnt].updt_cnt = request->image_qual[image_index].
      non_chartable_note_updt_cnt
      SET temp_add_images->qual[new_canned_cnt].non_chartable_note_id = non_chartable_note_id
     ELSE
      SET temp_add_images->qual[new_canned_cnt].non_chartable_note_id = 0
     ENDIF
     IF ((request->image_qual[new_canned_cnt].storage_cd=dicom_storage_cd))
      SET chg_pvw_dataset_cnt = (chg_pvw_dataset_cnt+ 1)
      SET stat = alterlist(temp_chg_pvw_dataset->qual,chg_pvw_dataset_cnt)
      SET temp_chg_pvw_dataset->qual[chg_pvw_dataset_cnt].dataset_uid = request->image_qual[
      new_canned_cnt].blob_handle
      SET temp_chg_pvw_dataset->qual[chg_pvw_dataset_cnt].parent_entity_name = "BLOB_REFERENCE"
      SET temp_chg_pvw_dataset->qual[chg_pvw_dataset_cnt].parent_entity_id = blob_ref_id
     ENDIF
    OF eupdate:
     IF ((request->image_qual[image_index].parent_entity_name="CLINICAL_EVENT"))
      SET copy_ce_cnt = (copy_ce_cnt+ 1)
      SET stat = alterlist(temp_copy_ce_images->qual,copy_ce_cnt)
      SET temp_copy_ce_images->qual[copy_ce_cnt].parent_entity_name = request->image_qual[image_index
      ].parent_entity_name
      SET temp_copy_ce_images->qual[copy_ce_cnt].parent_entity_id = request->image_qual[image_index].
      parent_entity_id
      SET temp_copy_ce_images->qual[copy_ce_cnt].image_index = request->image_qual[image_index].
      image_index
      SET temp_copy_ce_images->qual[copy_ce_cnt].blob_handle = request->image_qual[image_index].
      blob_handle
     ELSEIF ((request->image_qual[image_index].parent_entity_name="BLOB_REFERENCE"))
      SET copy_dept_cnt = (copy_dept_cnt+ 1)
      SET stat = alterlist(temp_copy_dept_images->qual,copy_dept_cnt)
      SET temp_copy_dept_images->qual[copy_dept_cnt].parent_entity_name = request->image_qual[
      image_index].parent_entity_name
      SET temp_copy_dept_images->qual[copy_dept_cnt].parent_entity_id = request->image_qual[
      image_index].parent_entity_id
      SET temp_copy_dept_images->qual[copy_dept_cnt].image_index = request->image_qual[image_index].
      image_index
      SET temp_copy_dept_images->qual[copy_dept_cnt].blob_handle = request->image_qual[image_index].
      blob_handle
     ENDIF
   ENDCASE
 ENDFOR
 IF (copy_ce_cnt > 0)
  SELECT INTO "nl:"
   ce.event_id, cbr.event_id, cbs.ce_blob_summary_id,
   lb.long_blob_id, cep.action_prsnl_id, p.person_id,
   cen.ce_event_note_id, lt.long_blob_id
   FROM clinical_event ce,
    ce_blob_result cbr,
    ce_blob_summary cbs,
    long_blob lb,
    ce_event_prsnl cep,
    ce_event_note cen,
    long_blob lt,
    prsnl p,
    (dummyt d1  WITH seq = value(copy_ce_cnt)),
    (dummyt d2  WITH seq = 1)
   PLAN (d1)
    JOIN (ce
    WHERE (ce.event_id=temp_copy_ce_images->qual[d1.seq].parent_entity_id)
     AND (temp_copy_ce_images->qual[d1.seq].parent_entity_name="CLINICAL_EVENT")
     AND ce.valid_from_dt_tm < cnvtdatetime(curdate,curtime3)
     AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
     AND ce.record_status_cd != deleted_status_cd)
    JOIN (cbr
    WHERE cbr.event_id=ce.event_id
     AND cbr.valid_from_dt_tm < cnvtdatetime(curdate,curtime3)
     AND cbr.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (cbs
    WHERE cbs.event_id=ce.event_id
     AND cbs.valid_from_dt_tm < cnvtdatetime(curdate,curtime3)
     AND cbs.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (lb
    WHERE lb.parent_entity_id=cbs.ce_blob_summary_id
     AND lb.parent_entity_name="CE_BLOB_SUMMARY")
    JOIN (cep
    WHERE cep.event_id=ce.event_id
     AND cep.valid_from_dt_tm < cnvtdatetime(curdate,curtime3)
     AND cep.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
     AND cep.action_type_cd=author_type_cd)
    JOIN (p
    WHERE p.person_id=cep.action_prsnl_id)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (cen
    WHERE cen.event_id=ce.event_id
     AND cen.valid_from_dt_tm < cnvtdatetime(curdate,curtime3)
     AND cen.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
     AND cen.record_status_cd != deleted_status_cd)
    JOIN (lt
    WHERE lt.parent_entity_id=cen.ce_event_note_id
     AND lt.parent_entity_name="CE_EVENT_NOTE")
   ORDER BY ce.event_id
   HEAD ce.event_id
    temp_copy_cnt = (temp_copy_cnt+ 1)
    IF (mod(temp_copy_cnt,10)=1)
     stat = alterlist(temp_data_copy->qual,(temp_copy_cnt+ 9))
    ENDIF
    temp_data_copy->qual[temp_copy_cnt].image_index = temp_copy_ce_images->qual[d1.seq].image_index,
    temp_data_copy->qual[temp_copy_cnt].sequence_nbr = cnvtint(ce.collating_seq), temp_data_copy->
    qual[temp_copy_cnt].storage_cd = cbr.storage_cd,
    temp_data_copy->qual[temp_copy_cnt].format_cd = cbr.format_cd, temp_data_copy->qual[temp_copy_cnt
    ].blob_handle = temp_copy_ce_images->qual[d1.seq].blob_handle, temp_data_copy->qual[temp_copy_cnt
    ].blob_title = ce.event_title_text,
    temp_data_copy->qual[temp_copy_cnt].tbnl_format_cd = cbs.format_cd, temp_data_copy->qual[
    temp_copy_cnt].create_prsnl_id = p.person_id, temp_data_copy->qual[temp_copy_cnt].
    source_device_cd = cbr.device_cd,
    temp_data_copy->qual[temp_copy_cnt].publish_flag = ce.publish_flag, temp_data_copy->qual[
    temp_copy_cnt].valid_from_dt_tm = ce.valid_from_dt_tm, temp_data_copy->qual[temp_copy_cnt].
    tbnl_image = lb.long_blob
    IF (cbs.compression_cd=ocf_compression_cd)
     tempblobsize = 0, outbufmaxsiz = 0,
     CALL uar_ocf_uncompress(lb.long_blob,size(lb.long_blob),temp_data_copy->qual[temp_copy_cnt].
     tbnl_image,tempblobsize,outbufmaxsiz)
    ELSE
     temp_data_copy->qual[temp_copy_cnt].tbnl_image = lb.long_blob
    ENDIF
   DETAIL
    IF (cen.note_type_cd=chartable_note_cd)
     IF (cen.compression_cd=ocf_compression_cd)
      tempblobsize = 0, outbufmaxsiz = 0,
      CALL uar_ocf_uncompress(lt.long_blob,size(lt.long_blob),temp_data_copy->qual[temp_copy_cnt].
      chartable_comment,tempblobsize,outbufmaxsiz)
     ELSE
      temp_data_copy->qual[temp_copy_cnt].chartable_comment = substring(1,(size(trim(lt.long_blob))
        - 8),lt.long_blob)
     ENDIF
    ELSEIF (cen.note_type_cd=non_chartable_note_cd)
     IF (cen.compression_cd=ocf_compression_cd)
      tempblobsize = 0, outbufmaxsiz = 0,
      CALL uar_ocf_uncompress(lt.long_blob,size(lt.long_blob),temp_data_copy->qual[temp_copy_cnt].
      non_chartable_comment,tempblobsize,outbufmaxsiz)
     ELSE
      temp_data_copy->qual[temp_copy_cnt].non_chartable_comment = substring(1,(size(trim(lt.long_blob
         )) - 8),lt.long_blob)
     ENDIF
    ELSEIF (cen.note_type_cd=ap_foreign_image_ident_note_cd)
     IF (cen.compression_cd=ocf_compression_cd)
      tempblobsize = 0, outbufmaxsiz = 0,
      CALL uar_ocf_uncompress(lt.long_blob,size(lt.long_blob),temp_data_copy->qual[temp_copy_cnt].
      blob_foreign_ident,tempblobsize,outbufmaxsiz)
     ELSE
      temp_data_copy->qual[temp_copy_cnt].blob_foreign_ident = substring(1,(size(trim(lt.long_blob))
        - 8),lt.long_blob)
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist(temp_data_copy->qual,temp_copy_cnt)
   WITH nocounter, memsort, outerjoin = d2
  ;end select
 ENDIF
 IF (copy_dept_cnt > 0)
  SELECT INTO "nl:"
   br.blob_ref_id, bsr.blob_ref_id, p.person_id,
   lb.long_blob_id, lt.long_text_id, lt2.long_text_id
   FROM blob_reference br,
    blob_summary_ref bsr,
    prsnl p,
    long_blob lb,
    long_text lt,
    long_text lt2,
    (dummyt d1  WITH seq = value(copy_dept_cnt))
   PLAN (d1)
    JOIN (br
    WHERE (br.blob_ref_id=temp_copy_dept_images->qual[d1.seq].parent_entity_id)
     AND (temp_copy_dept_images->qual[d1.seq].parent_entity_name="BLOB_REFERENCE"))
    JOIN (bsr
    WHERE br.blob_ref_id=bsr.blob_ref_id)
    JOIN (p
    WHERE br.create_prsnl_id=p.person_id)
    JOIN (lb
    WHERE lb.long_blob_id=bsr.long_blob_id)
    JOIN (lt
    WHERE lt.long_text_id=br.chartable_note_id)
    JOIN (lt2
    WHERE lt2.long_text_id=br.non_chartable_note_id)
   DETAIL
    temp_copy_cnt = (temp_copy_cnt+ 1)
    IF (mod(temp_copy_cnt,10)=1)
     stat = alterlist(temp_data_copy->qual,(temp_copy_cnt+ 9))
    ENDIF
    temp_data_copy->qual[temp_copy_cnt].image_index = temp_copy_dept_images->qual[d1.seq].image_index,
    temp_data_copy->qual[temp_copy_cnt].valid_from_dt_tm = br.valid_from_dt_tm, temp_data_copy->qual[
    temp_copy_cnt].sequence_nbr = br.sequence_nbr,
    temp_data_copy->qual[temp_copy_cnt].owner_cd = br.owner_cd, temp_data_copy->qual[temp_copy_cnt].
    storage_cd = br.storage_cd, temp_data_copy->qual[temp_copy_cnt].format_cd = br.format_cd,
    temp_data_copy->qual[temp_copy_cnt].blob_handle = temp_copy_dept_images->qual[d1.seq].blob_handle,
    temp_data_copy->qual[temp_copy_cnt].blob_title = br.blob_title, temp_data_copy->qual[
    temp_copy_cnt].tbnl_format_cd = bsr.format_cd,
    temp_data_copy->qual[temp_copy_cnt].create_prsnl_id = br.create_prsnl_id, temp_data_copy->qual[
    temp_copy_cnt].source_device_cd = br.source_device_cd, temp_data_copy->qual[temp_copy_cnt].
    publish_flag = br.publish_flag,
    temp_data_copy->qual[temp_copy_cnt].updt_cnt = br.updt_cnt, temp_data_copy->qual[temp_copy_cnt].
    tbnl_image = lb.long_blob
    IF (lt.long_text_id > 0)
     temp_data_copy->qual[temp_copy_cnt].chartable_comment = lt.long_text, temp_data_copy->qual[
     temp_copy_cnt].chartable_updt_cnt = lt.updt_cnt
    ENDIF
    IF (lt2.long_text_id > 0)
     temp_data_copy->qual[temp_copy_cnt].non_chartable_comment = lt2.long_text, temp_data_copy->qual[
     temp_copy_cnt].non_chartable_updt_cnt = lt2.updt_cnt
    ENDIF
    temp_data_copy->qual[temp_copy_cnt].blob_foreign_ident = br.blob_foreign_ident
   FOOT REPORT
    stat = alterlist(temp_data_copy->qual,temp_copy_cnt)
   WITH nocounter, memsort
  ;end select
 ENDIF
 FOR (copy_index = 1 TO temp_copy_cnt)
   SET new_canned_cnt = (new_canned_cnt+ 1)
   SET stat = alterlist(temp_add_discrete_entity->qual,new_canned_cnt)
   SET stat = alterlist(temp_add_images->qual,new_canned_cnt)
   SET reply->image_qual[new_canned_cnt].image_index = temp_data_copy->qual[copy_index].image_index
   SELECT INTO "nl:"
    seq_nbr = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     entity_id = seq_nbr
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    GO TO seq_failed
   ENDIF
   SET temp_add_discrete_entity->qual[new_canned_cnt].entity_id = entity_id
   SET reply->image_qual[new_canned_cnt].entity_id = entity_id
   SELECT INTO "nl:"
    seq_nbr = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     blob_ref_id = seq_nbr
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    GO TO seq_failed
   ENDIF
   SET temp_add_images->qual[new_canned_cnt].parent_entity_name = "AP_DISCRETE_ENTITY"
   SET temp_add_images->qual[new_canned_cnt].parent_entity_id = entity_id
   SET temp_add_images->qual[new_canned_cnt].blob_ref_id = blob_ref_id
   SET reply->image_qual[new_canned_cnt].blob_ref_id = blob_ref_id
   SET temp_add_images->qual[new_canned_cnt].sequence_nbr = temp_data_copy->qual[copy_index].
   sequence_nbr
   SET temp_add_images->qual[new_canned_cnt].owner_cd = temp_data_copy->qual[copy_index].owner_cd
   SET temp_add_images->qual[new_canned_cnt].storage_cd = temp_data_copy->qual[copy_index].storage_cd
   SET temp_add_images->qual[new_canned_cnt].format_cd = temp_data_copy->qual[copy_index].format_cd
   SET temp_add_images->qual[new_canned_cnt].blob_handle = temp_data_copy->qual[copy_index].
   blob_handle
   SET temp_add_images->qual[new_canned_cnt].blob_title = temp_data_copy->qual[copy_index].blob_title
   SET temp_add_images->qual[new_canned_cnt].tbnl_format_cd = temp_data_copy->qual[copy_index].
   tbnl_format_cd
   SET temp_add_images->qual[new_canned_cnt].create_prsnl_id = temp_data_copy->qual[copy_index].
   create_prsnl_id
   SET temp_add_images->qual[new_canned_cnt].source_device_cd = temp_data_copy->qual[copy_index].
   source_device_cd
   SET temp_add_images->qual[new_canned_cnt].publish_flag = temp_data_copy->qual[copy_index].
   publish_flag
   SET temp_add_images->qual[new_canned_cnt].valid_from_dt_tm = temp_data_copy->qual[copy_index].
   valid_from_dt_tm
   SET temp_add_images->qual[new_canned_cnt].blob_foreign_ident = temp_data_copy->qual[copy_index].
   blob_foreign_ident
   SET tbnl_images_cnt = (tbnl_images_cnt+ 1)
   SET stat = alterlist(temp_add_tbnl_images->qual,tbnl_images_cnt)
   SELECT INTO "nl:"
    seq_nbr = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     tbnl_long_blob_id = seq_nbr
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    GO TO seq_failed
   ENDIF
   SET temp_add_images->qual[new_canned_cnt].tbnl_long_blob_id = tbnl_long_blob_id
   SET temp_add_tbnl_images->qual[tbnl_images_cnt].tbnl_long_blob_id = tbnl_long_blob_id
   SET temp_add_tbnl_images->qual[tbnl_images_cnt].blob_ref_id = blob_ref_id
   SET temp_add_tbnl_images->qual[tbnl_images_cnt].tbnl_image = temp_data_copy->qual[copy_index].
   tbnl_image
   SET reply->image_qual[new_canned_cnt].tbnl_long_blob_id = tbnl_long_blob_id
   IF (textlen(temp_data_copy->qual[copy_index].chartable_comment) > 0)
    SET note_cnt = (note_cnt+ 1)
    SET stat = alterlist(temp_add_comment->qual,note_cnt)
    SET temp_add_comment->qual[note_cnt].blob_ref_id = blob_ref_id
    SELECT INTO "nl:"
     seq_nbr = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      chartable_note_id = seq_nbr
     WITH format, nocounter
    ;end select
    IF (curqual=0)
     GO TO seq_failed
    ENDIF
    SET temp_add_comment->qual[note_cnt].comment_id = chartable_note_id
    SET temp_add_comment->qual[note_cnt].comment = temp_data_copy->qual[copy_index].chartable_comment
    SET temp_add_comment->qual[note_cnt].updt_cnt = 0
    SET temp_add_images->qual[new_canned_cnt].chartable_note_id = chartable_note_id
    SET reply->image_qual[new_canned_cnt].chartable_note_id = chartable_note_id
   ENDIF
   IF (textlen(temp_data_copy->qual[copy_index].non_chartable_comment) > 0)
    SET note_cnt = (note_cnt+ 1)
    SET stat = alterlist(temp_add_comment->qual,note_cnt)
    SET temp_add_comment->qual[note_cnt].blob_ref_id = blob_ref_id
    SELECT INTO "nl:"
     seq_nbr = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      non_chartable_note_id = seq_nbr
     WITH format, nocounter
    ;end select
    IF (curqual=0)
     GO TO seq_failed
    ENDIF
    SET temp_add_comment->qual[note_cnt].comment_id = non_chartable_note_id
    SET temp_add_comment->qual[note_cnt].comment = temp_data_copy->qual[copy_index].
    non_chartable_comment
    SET temp_add_comment->qual[note_cnt].updt_cnt = 0
    SET temp_add_images->qual[new_canned_cnt].non_chartable_note_id = non_chartable_note_id
    SET reply->image_qual[new_canned_cnt].non_chartable_note_id = non_chartable_note_id
   ENDIF
   IF ((temp_data_copy->qual[copy_index].storage_cd=dicom_storage_cd))
    SET chg_pvw_dataset_cnt = (chg_pvw_dataset_cnt+ 1)
    SET stat = alterlist(temp_chg_pvw_dataset->qual,chg_pvw_dataset_cnt)
    SET temp_chg_pvw_dataset->qual[chg_pvw_dataset_cnt].dataset_uid = temp_data_copy->qual[copy_index
    ].blob_handle
    SET temp_chg_pvw_dataset->qual[chg_pvw_dataset_cnt].parent_entity_name = "BLOB_REFERENCE"
    SET temp_chg_pvw_dataset->qual[chg_pvw_dataset_cnt].parent_entity_id = blob_ref_id
   ENDIF
 ENDFOR
 IF (note_cnt > 0)
  INSERT  FROM long_text lt,
    (dummyt d  WITH seq = value(note_cnt))
   SET lt.long_text_id = temp_add_comment->qual[d.seq].comment_id, lt.parent_entity_name =
    "BLOB_REFERENCE", lt.parent_entity_id = temp_add_comment->qual[d.seq].blob_ref_id,
    lt.long_text = temp_add_comment->qual[d.seq].comment, lt.active_ind = 1, lt.active_status_cd =
    active_status_cd,
    lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
    updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
    lt.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (lt)
   WITH nocounter
  ;end insert
  IF (curqual != note_cnt)
   GO TO comment_failed
  ENDIF
 ENDIF
 IF (tbnl_images_cnt > 0)
  INSERT  FROM long_blob lb,
    (dummyt d  WITH seq = value(tbnl_images_cnt))
   SET lb.long_blob_id = temp_add_tbnl_images->qual[d.seq].tbnl_long_blob_id, lb.parent_entity_name
     = "BLOB_REFERENCE", lb.parent_entity_id = temp_add_tbnl_images->qual[d.seq].blob_ref_id,
    lb.long_blob = temp_add_tbnl_images->qual[d.seq].tbnl_image, lb.active_ind = 1, lb
    .active_status_cd = active_status_cd,
    lb.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lb.active_status_prsnl_id = reqinfo->
    updt_id, lb.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    lb.updt_id = reqinfo->updt_id, lb.updt_task = reqinfo->updt_task, lb.updt_cnt = 0,
    lb.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (lb)
   WITH nocounter
  ;end insert
  IF (curqual != tbnl_images_cnt)
   GO TO add_tbnl_images_failed
  ENDIF
 ENDIF
 IF (new_canned_cnt > 0)
  INSERT  FROM blob_reference br,
    (dummyt d  WITH seq = value(new_canned_cnt))
   SET br.blob_ref_id = temp_add_images->qual[d.seq].blob_ref_id, br.valid_until_dt_tm = cnvtdatetime
    ("31-DEC-2100 23:23:59"), br.valid_from_dt_tm = cnvtdatetime(temp_add_images->qual[d.seq].
     valid_from_dt_tm),
    br.parent_entity_name = temp_add_images->qual[d.seq].parent_entity_name, br.parent_entity_id =
    temp_add_images->qual[d.seq].parent_entity_id, br.sequence_nbr = temp_add_images->qual[d.seq].
    sequence_nbr,
    br.owner_cd = temp_add_images->qual[d.seq].owner_cd, br.storage_cd = temp_add_images->qual[d.seq]
    .storage_cd, br.format_cd = temp_add_images->qual[d.seq].format_cd,
    br.blob_handle = temp_add_images->qual[d.seq].blob_handle, br.blob_title = temp_add_images->qual[
    d.seq].blob_title, br.blob_foreign_ident = temp_add_images->qual[d.seq].blob_foreign_ident,
    br.create_prsnl_id = temp_add_images->qual[d.seq].create_prsnl_id, br.source_device_cd =
    temp_add_images->qual[d.seq].source_device_cd, br.chartable_note_id = temp_add_images->qual[d.seq
    ].chartable_note_id,
    br.non_chartable_note_id = temp_add_images->qual[d.seq].non_chartable_note_id, br.publish_flag =
    temp_add_images->qual[d.seq].publish_flag, br.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    br.updt_id = reqinfo->updt_id, br.updt_task = reqinfo->updt_task, br.updt_cnt = 0,
    br.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (br)
   WITH nocounter
  ;end insert
  IF (curqual != new_canned_cnt)
   GO TO image_failed
  ENDIF
  INSERT  FROM blob_summary_ref bsr,
    (dummyt d  WITH seq = value(new_canned_cnt))
   SET bsr.blob_ref_id = temp_add_images->qual[d.seq].blob_ref_id, bsr.compression_cd = 0, bsr
    .long_blob_id = temp_add_images->qual[d.seq].tbnl_long_blob_id,
    bsr.format_cd = temp_add_images->qual[d.seq].tbnl_format_cd, bsr.updt_dt_tm = cnvtdatetime(
     curdate,curtime3), bsr.updt_id = reqinfo->updt_id,
    bsr.updt_task = reqinfo->updt_task, bsr.updt_cnt = 0, bsr.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (bsr)
   WITH nocounter
  ;end insert
  IF (curqual != new_canned_cnt)
   GO TO insert_tbnl_failed
  ENDIF
  INSERT  FROM ap_discrete_entity ade,
    (dummyt d  WITH seq = value(new_canned_cnt))
   SET ade.entity_id = temp_add_discrete_entity->qual[d.seq].entity_id, ade.entity_type_flag =
    n_canned_image, ade.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    ade.updt_id = reqinfo->updt_id, ade.updt_task = reqinfo->updt_task, ade.updt_cnt = 0,
    ade.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (ade)
   WITH nocounter
  ;end insert
  IF (curqual != new_canned_cnt)
   GO TO insert_discrete_entity_failed
  ENDIF
 ENDIF
 IF (chg_pvw_dataset_cnt > 0)
  SELECT INTO "nl:"
   pd.dataset_uid
   FROM pvw_dataset pd,
    (dummyt d  WITH seq = value(chg_pvw_dataset_cnt))
   PLAN (d)
    JOIN (pd
    WHERE (pd.dataset_uid=temp_chg_pvw_dataset->qual[d.seq].dataset_uid))
   HEAD REPORT
    nbr_items = 0
   DETAIL
    nbr_items = (nbr_items+ 1)
   WITH nocounter, forupdate(pd)
  ;end select
  IF (nbr_items != chg_pvw_dataset_cnt)
   GO TO lock_pvw_failed
  ENDIF
  UPDATE  FROM pvw_dataset pd,
    (dummyt d  WITH seq = value(chg_pvw_dataset_cnt))
   SET pd.parent_entity_name = temp_chg_pvw_dataset->qual[d.seq].parent_entity_name, pd
    .parent_entity_id = temp_chg_pvw_dataset->qual[d.seq].parent_entity_id, pd.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    pd.updt_id = reqinfo->updt_id, pd.updt_task = reqinfo->updt_task, pd.updt_cnt = (pd.updt_cnt+ 1),
    pd.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (pd
    WHERE (pd.dataset_uid=temp_chg_pvw_dataset->qual[d.seq].dataset_uid))
   WITH nocounter
  ;end update
  IF (curqual != chg_pvw_dataset_cnt)
   GO TO pvw_dataset_failed
  ENDIF
 ENDIF
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "NEXTVAL"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "SEQ"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHNET_SEQ"
 SET failed = "T"
 GO TO exit_script
#pvw_dataset_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PVW_DATASET"
 SET failed = "T"
 GO TO exit_script
#insert_discrete_entity_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_DISCRETE_ENTITY"
 SET failed = "T"
 GO TO exit_script
#comment_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#add_tbnl_images_failed
 SET reply->status_data.subeventstatus[1].operationname = "ADD"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_BLOB"
 SET failed = "T"
 GO TO exit_script
#insert_pvw_dataset_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PVW_DATASET"
 SET failed = "T"
 GO TO exit_script
#insert_tbnl_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "BLOB_SUMMARY_REF"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error inserting thumbnail"
 SET failed = "T"
 GO TO exit_script
#image_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "BLOB_REFERENCE"
 SET failed = "T"
 GO TO exit_script
#lock_pvw_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PVW_DATASET"
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
