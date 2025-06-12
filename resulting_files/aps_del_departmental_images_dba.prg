CREATE PROGRAM aps_del_departmental_images:dba
 RECORD temp_del_sections(
   1 qual[*]
     2 report_detail_id = f8
 )
 RECORD temp_del_images(
   1 qual[*]
     2 blob_ref_id = f8
     2 storage_cd = f8
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
 DECLARE deldocimagecnt = i4 WITH protect, noconstant(0)
 DECLARE code_value = f8 WITH protect, noconstant(0.0)
 DECLARE code_set = i4 WITH protect, noconstant(0)
 DECLARE pcsdocimg_storage_cd = f8 WITH protect, noconstant(0.0)
 DECLARE spcsdocimg_cdf_meaning = c9 WITH protect, constant("PCSDOCIMG")
 DECLARE sparent_entity_case_report = c11 WITH protect, constant("CASE_REPORT")
 SET del_report_id = 0.0
 SET delsectioncnt = 0
 SET delimagecnt = 0
 SET delcommentcnt = 0
 SET deltbnlimagecnt = 0
 SET dummy_var = 0
 SET called_from_process_server = " "
 IF ((validate(crequest->qual[1].report_id,- (1)) != - (1)))
  CALL echo("aps_del_departmental_images::called_from_process_server = T")
  SET del_report_id = crequest->qual[cd->taskcnt].report_id
  SET called_from_process_server = "T"
 ELSE
  CALL echo("aps_del_departmental_images::called_from_process_server = F")
  SET del_report_id = request->report_id
  SET called_from_process_server = "F"
 ENDIF
 SET code_set = 25
 SET cdf_meaning = spcsdocimg_cdf_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET pcsdocimg_storage_cd = code_value
 IF (del_report_id=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  br.blob_ref_id, br.sequence_nbr, bsr.blob_ref_id,
  rdi.task_assay_cd, lt.long_text_id, lt2.long_text_id,
  lb.long_blob_id, br_exists = decode(br.seq,"Y","N")
  FROM blob_reference br,
   blob_summary_ref bsr,
   report_detail_image rdi,
   long_text lt,
   long_text lt2,
   long_blob lb,
   dummyt d
  PLAN (rdi
   WHERE del_report_id=rdi.report_id)
   JOIN (d)
   JOIN (br
   WHERE rdi.report_detail_id=br.parent_entity_id
    AND br.parent_entity_name="REPORT_DETAIL_IMAGE")
   JOIN (bsr
   WHERE br.blob_ref_id=bsr.blob_ref_id)
   JOIN (lt
   WHERE br.chartable_note_id=lt.long_text_id)
   JOIN (lt2
   WHERE br.non_chartable_note_id=lt2.long_text_id)
   JOIN (lb
   WHERE bsr.long_blob_id=lb.long_blob_id)
  ORDER BY rdi.task_assay_cd, br.sequence_nbr, br.blob_ref_id
  HEAD REPORT
   delsectioncnt = 0, delimagecnt = 0, delcommentcnt = 0,
   deltbnlimagecnt = 0
  HEAD rdi.task_assay_cd
   delsectioncnt = (delsectioncnt+ 1), stat = alterlist(temp_del_sections->qual,delsectioncnt),
   temp_del_sections->qual[delsectioncnt].report_detail_id = rdi.report_detail_id
  HEAD br.blob_ref_id
   IF (br_exists="Y")
    delimagecnt = (delimagecnt+ 1), stat = alterlist(temp_del_images->qual,delimagecnt),
    temp_del_images->qual[delimagecnt].blob_ref_id = br.blob_ref_id,
    temp_del_images->qual[delimagecnt].storage_cd = br.storage_cd
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
   ENDIF
  DETAIL
   dummy_var = 0
  WITH nocounter, outerjoin = d
 ;end select
 SELECT INTO "nl:"
  FROM blob_reference br
  PLAN (br
   WHERE br.parent_entity_id=del_report_id
    AND br.parent_entity_name=sparent_entity_case_report
    AND cnvtdatetime(curdate,curtime3) BETWEEN br.valid_from_dt_tm AND br.valid_until_dt_tm)
  HEAD br.blob_ref_id
   delimagecnt = (delimagecnt+ 1), deldocimagecnt = (deldocimagecnt+ 1), stat = alterlist(
    temp_del_images->qual,delimagecnt),
   temp_del_images->qual[delimagecnt].blob_ref_id = br.blob_ref_id, temp_del_images->qual[delimagecnt
   ].storage_cd = br.storage_cd
  DETAIL
   row + 0
  FOOT  br.blob_ref_id
   stat = alterlist(temp_del_images->qual,delimagecnt)
  WITH nocounter
 ;end select
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
   PLAN (d
    WHERE (temp_del_images->qual[d.seq].storage_cd != pcsdocimg_storage_cd))
    JOIN (bsr
    WHERE (bsr.blob_ref_id=temp_del_images->qual[d.seq].blob_ref_id))
   WITH nocounter
  ;end delete
  IF ((curqual != (delimagecnt - deldocimagecnt)))
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
 IF (delsectioncnt > 0)
  DELETE  FROM report_detail_image rdi,
    (dummyt d  WITH seq = value(delsectioncnt))
   SET rdi.report_detail_id = temp_del_sections->qual[d.seq].report_detail_id
   PLAN (d)
    JOIN (rdi
    WHERE (rdi.report_detail_id=temp_del_sections->qual[d.seq].report_detail_id))
   WITH nocounter
  ;end delete
  IF (curqual != delsectioncnt)
   GO TO section_failed
  ENDIF
 ENDIF
 GO TO exit_script
#tbnl_images_failed
 CALL echo("APS_DEL_DEPARTMENTAL_IMAGES: Error deleting from long_blob.")
 GO TO exit_script
#comment_failed
 CALL echo("APS_DEL_DEPARTMENTAL_IMAGES: Error deleting from long_text.")
 GO TO exit_script
#image_failed
 CALL echo("APS_DEL_DEPARTMENTAL_IMAGES: Error deleting from blob_reference.")
 GO TO exit_script
#image_tbnl_failed
 CALL echo("APS_DEL_DEPARTMENTAL_IMAGES: Error deleting from blob_summary_ref.")
 GO TO exit_script
#section_failed
 CALL echo("APS_DEL_DEPARTMENTAL_IMAGES: Error deleting from report_detail_image.")
 GO TO exit_script
#exit_script
 CALL echo("APS_DEL_DEPARTMENTAL_IMAGES: Exiting.")
 IF (called_from_process_server="T")
  COMMIT
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
