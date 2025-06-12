CREATE PROGRAM aps_get_report_images:dba
#script
 DECLARE n_images = i4 WITH protect, constant(1)
 DECLARE n_doc_images = i4 WITH protect, constant(2)
 DECLARE lreportimgcnt = i4 WITH protect, noconstant(0)
 SET failed = "F"
 SET imagecnt = 0
 SET sectioncnt = 0
 SET sectionindex = 0
 SET called_ind = 1
 SET error_cnt = 0
 SET max_sections = 0
 SET max_images = 0
 SET nnoqualifyingreports = 0
 IF ((request->blob_bitmap=0))
  SET request->blob_bitmap = bor(n_images,n_doc_images)
 ENDIF
 IF (validate(call_aps_get_report_images_ind,0)=0)
  RECORD reply(
    1 rpt_info_qual[1]
      2 report_id = f8
      2 section_qual[*]
        3 report_detail_id = f8
        3 task_assay_cd = f8
        3 image_qual[*]
          4 blob_ref_id = f8
          4 sequence_nbr = i4
          4 owner_cd = f8
          4 storage_cd = f8
          4 format_cd = f8
          4 blob_handle = vc
          4 blob_title = vc
          4 tbnl_long_blob_id = f8
          4 tbnl_format_cd = f8
          4 long_blob = vgc
          4 create_prsnl_id = f8
          4 create_prsnl_name = vc
          4 source_device_cd = f8
          4 source_device_disp = c40
          4 chartable_note = vc
          4 chartable_note_id = f8
          4 chartable_note_updt_cnt = i4
          4 non_chartable_note = vc
          4 non_chartable_note_id = f8
          4 non_chartable_note_updt_cnt = i4
          4 publish_flag = i2
          4 valid_from_dt_tm = dq8
          4 updt_id = f8
          4 updt_cnt = i4
          4 blob_foreign_ident = vc
      2 image_qual[*]
        3 blob_ref_id = f8
        3 sequence_nbr = i4
        3 owner_cd = f8
        3 storage_cd = f8
        3 format_cd = f8
        3 blob_handle = vc
        3 blob_title = vc
        3 tbnl_long_blob_id = f8
        3 tbnl_format_cd = f8
        3 long_blob = vgc
        3 create_prsnl_id = f8
        3 create_prsnl_name = vc
        3 source_device_cd = f8
        3 source_device_disp = c40
        3 chartable_note = vc
        3 chartable_note_id = f8
        3 chartable_note_updt_cnt = i4
        3 non_chartable_note = vc
        3 non_chartable_note_id = f8
        3 non_chartable_note_updt_cnt = i4
        3 publish_flag = i2
        3 valid_from_dt_tm = dq8
        3 updt_id = f8
        3 updt_cnt = i4
        3 blob_foreign_ident = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET reply->status_data.status = "F"
  SET called_ind = 0
 ENDIF
 IF (band(request->blob_bitmap,n_images))
  SELECT INTO "nl:"
   br.blob_ref_id, br.sequence_nbr, bsr.blob_ref_id,
   rdi.task_assay_cd, p.person_id, lb.long_blob_id,
   lt.long_text_id, lt2.long_text_id
   FROM blob_reference br,
    blob_summary_ref bsr,
    report_detail_image rdi,
    prsnl p,
    long_blob lb,
    long_text lt,
    long_text lt2
   PLAN (rdi
    WHERE (request->report_id=rdi.report_id))
    JOIN (br
    WHERE br.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND br.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND br.parent_entity_name="REPORT_DETAIL_IMAGE"
     AND br.parent_entity_id=rdi.report_detail_id)
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
   ORDER BY rdi.task_assay_cd, br.sequence_nbr, br.blob_ref_id
   HEAD REPORT
    imagecnt = 0
    IF (called_ind=1)
     sectioncnt = cnvtint(size(reply->rpt_info_qual[1].section_qual,5))
    ENDIF
    reply->rpt_info_qual[1].report_id = rdi.report_id
   HEAD rdi.task_assay_cd
    IF (called_ind=1)
     sectionindex = 1
     WHILE (sectionindex <= sectioncnt
      AND (rdi.task_assay_cd != reply->rpt_info_qual[1].section_qual[sectionindex].task_assay_cd))
       sectionindex = (sectionindex+ 1)
     ENDWHILE
     IF (sectionindex >= sectioncnt
      AND (rdi.task_assay_cd != reply->rpt_info_qual[1].section_qual[sectioncnt].task_assay_cd))
      sectionindex = 0
     ENDIF
    ELSE
     sectionindex = (sectionindex+ 1), stat = alterlist(reply->rpt_info_qual[1].section_qual,
      sectionindex), reply->rpt_info_qual[1].section_qual[sectionindex].task_assay_cd = rdi
     .task_assay_cd,
     reply->rpt_info_qual[1].section_qual[sectionindex].report_detail_id = rdi.report_detail_id
    ENDIF
    IF (sectionindex > 0)
     imagecnt = 0, stat = alterlist(reply->rpt_info_qual[1].section_qual[sectionindex].image_qual,10),
     reply->rpt_info_qual[1].section_qual[sectionindex].report_detail_id = rdi.report_detail_id
    ENDIF
   HEAD br.blob_ref_id
    IF (sectionindex > 0)
     imagecnt = (imagecnt+ 1)
     IF (mod(imagecnt,10)=1
      AND imagecnt != 1)
      stat = alterlist(reply->rpt_info_qual[1].section_qual[sectionindex].image_qual,(imagecnt+ 9))
     ENDIF
     reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].blob_ref_id = br
     .blob_ref_id, reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].
     sequence_nbr = br.sequence_nbr, reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[
     imagecnt].owner_cd = br.owner_cd,
     reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].storage_cd = br
     .storage_cd, reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].format_cd
      = br.format_cd, reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].
     blob_handle = br.blob_handle,
     reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].blob_title = br
     .blob_title, reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].
     tbnl_long_blob_id = bsr.long_blob_id, reply->rpt_info_qual[1].section_qual[sectionindex].
     image_qual[imagecnt].tbnl_format_cd = bsr.format_cd,
     reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].chartable_note_id = br
     .chartable_note_id, reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].
     non_chartable_note_id = br.non_chartable_note_id, reply->rpt_info_qual[1].section_qual[
     sectionindex].image_qual[imagecnt].create_prsnl_id = br.create_prsnl_id,
     reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].create_prsnl_name = p
     .name_full_formatted, reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].
     source_device_cd = br.source_device_cd, reply->rpt_info_qual[1].section_qual[sectionindex].
     image_qual[imagecnt].updt_id = br.updt_id,
     reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].updt_cnt = br.updt_cnt,
     reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].publish_flag = br
     .publish_flag, reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].
     valid_from_dt_tm = cnvtdatetime(br.valid_from_dt_tm),
     reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].long_blob = lb.long_blob
     IF (lt.long_text_id=0)
      reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].chartable_note = "",
      reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].chartable_note_id = 0,
      reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].chartable_note_updt_cnt
       = 0
     ELSE
      reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].chartable_note = lt
      .long_text, reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].
      chartable_note_id = lt.long_text_id, reply->rpt_info_qual[1].section_qual[sectionindex].
      image_qual[imagecnt].chartable_note_updt_cnt = lt.updt_cnt
     ENDIF
     IF (lt2.long_text_id=0)
      reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].non_chartable_note = "",
      reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].non_chartable_note_id
       = 0, reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].
      non_chartable_note_updt_cnt = 0
     ELSE
      reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].non_chartable_note =
      lt2.long_text, reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].
      non_chartable_note_id = lt2.long_text_id, reply->rpt_info_qual[1].section_qual[sectionindex].
      image_qual[imagecnt].non_chartable_note_updt_cnt = lt2.updt_cnt
     ENDIF
     reply->rpt_info_qual[1].section_qual[sectionindex].image_qual[imagecnt].blob_foreign_ident = br
     .blob_foreign_ident
    ENDIF
   FOOT  rdi.task_assay_cd
    IF (sectionindex > 0)
     stat = alterlist(reply->rpt_info_qual[1].section_qual[sectionindex].image_qual,imagecnt)
    ENDIF
   WITH nocounter, memsort
  ;end select
 ENDIF
 IF (band(request->blob_bitmap,n_doc_images))
  SELECT INTO "nl:"
   FROM blob_reference br,
    prsnl p
   PLAN (br
    WHERE (br.parent_entity_id=request->report_id)
     AND br.parent_entity_name="CASE_REPORT"
     AND br.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (p
    WHERE p.person_id=br.create_prsnl_id)
   HEAD REPORT
    reply->rpt_info_qual[1].report_id = br.parent_entity_id, lreportimgcnt = 0
   DETAIL
    lreportimgcnt = (lreportimgcnt+ 1)
    IF (mod(lreportimgcnt,10)=1)
     stat = alterlist(reply->rpt_info_qual[1].image_qual,(lreportimgcnt+ 9))
    ENDIF
    reply->rpt_info_qual[1].image_qual[lreportimgcnt].blob_ref_id = br.blob_ref_id, reply->
    rpt_info_qual[1].image_qual[lreportimgcnt].sequence_nbr = br.sequence_nbr, reply->rpt_info_qual[1
    ].image_qual[lreportimgcnt].owner_cd = br.owner_cd,
    reply->rpt_info_qual[1].image_qual[lreportimgcnt].storage_cd = br.storage_cd, reply->
    rpt_info_qual[1].image_qual[lreportimgcnt].format_cd = br.format_cd, reply->rpt_info_qual[1].
    image_qual[lreportimgcnt].blob_handle = br.blob_handle,
    reply->rpt_info_qual[1].image_qual[lreportimgcnt].blob_title = br.blob_title, reply->
    rpt_info_qual[1].image_qual[lreportimgcnt].chartable_note_id = br.chartable_note_id, reply->
    rpt_info_qual[1].image_qual[lreportimgcnt].non_chartable_note_id = br.non_chartable_note_id,
    reply->rpt_info_qual[1].image_qual[lreportimgcnt].create_prsnl_id = br.create_prsnl_id, reply->
    rpt_info_qual[1].image_qual[lreportimgcnt].create_prsnl_name = p.name_full_formatted, reply->
    rpt_info_qual[1].image_qual[lreportimgcnt].source_device_cd = br.source_device_cd,
    reply->rpt_info_qual[1].image_qual[lreportimgcnt].updt_id = br.updt_id, reply->rpt_info_qual[1].
    image_qual[lreportimgcnt].updt_cnt = br.updt_cnt, reply->rpt_info_qual[1].image_qual[
    lreportimgcnt].publish_flag = br.publish_flag,
    reply->rpt_info_qual[1].image_qual[lreportimgcnt].valid_from_dt_tm = cnvtdatetime(br
     .valid_from_dt_tm), reply->rpt_info_qual[1].image_qual[lreportimgcnt].blob_foreign_ident = br
    .blob_foreign_ident
   FOOT REPORT
    stat = alterlist(reply->rpt_info_qual[1].image_qual,lreportimgcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (imagecnt=0
  AND lreportimgcnt=0)
  SET nnoqualifyingreports = 1
 ENDIF
 SUBROUTINE handle_locate_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#exit_script
 IF (failed="F")
  IF (nnoqualifyingreports=1)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
