CREATE PROGRAM aps_add_departmental_images:dba
 RECORD reply_addl(
   1 case_updt_cnt = i4
   1 report_qual[*]
     2 report_index = i4
     2 report_id = f8
     2 report_updt_cnt = i4
     2 status_cd = f8
     2 status_disp = c40
     2 skip_ind = i2
     2 updt_id = f8
     2 updt_name_full_formatted = vc
     2 section_qual[*]
       3 section_index = i4
       3 report_detail_id = f8
       3 section_updt_cnt = i4
       3 image_qual[*]
         4 image_index = i4
         4 blob_ref_id = f8
         4 tbnl_long_blob_id = f8
         4 chartable_note_id = f8
         4 chartable_note_updt_cnt = i4
         4 non_chartable_note_id = f8
         4 non_chartable_note_updt_cnt = i4
         4 image_updt_cnt = i4
     2 image_qual[*]
       3 image_index = i4
       3 blob_ref_id = f8
       3 tbnl_long_blob_id = f8
       3 chartable_note_id = f8
       3 chartable_note_updt_cnt = i4
       3 non_chartable_note_id = f8
       3 non_chartable_note_updt_cnt = i4
       3 image_updt_cnt = i4
 )
 RECORD temp_chg_reports(
   1 qual[*]
     2 report_id = f8
     2 blob_bitmap = i4
     2 updt_cnt = i4
 )
 RECORD temp_add_sections(
   1 qual[*]
     2 report_detail_id = f8
     2 report_id = f8
     2 task_assay_cd = f8
     2 updt_cnt = i4
 )
 RECORD temp_del_sections(
   1 qual[*]
     2 report_detail_id = f8
 )
 RECORD temp_add_images(
   1 qual[*]
     2 blob_ref_id = f8
     2 sequence_nbr = i4
     2 owner_cd = f8
     2 storage_cd = f8
     2 format_cd = f8
     2 blob_handle = vc
     2 blob_title = vc
     2 tbnl_long_blob_id = f8
     2 tbnl_format_cd = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 chartable_note_id = f8
     2 non_chartable_note_id = f8
     2 create_prsnl_id = f8
     2 source_device_cd = f8
     2 valid_from_dt_tm = dq8
     2 valid_until_dt_tm = dq8
     2 publish_flag = i2
     2 updt_cnt = i4
     2 blob_foreign_ident = vc
 )
 RECORD temp_chg_images(
   1 qual[*]
     2 blob_ref_id = f8
     2 sequence_nbr = i4
     2 owner_cd = f8
     2 storage_cd = f8
     2 format_cd = f8
     2 blob_handle = vc
     2 blob_title = vc
     2 tbnl_long_blob_id = f8
     2 tbnl_format_cd = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 chartable_note_id = f8
     2 create_prsnl_id = f8
     2 non_chartable_note_id = f8
     2 source_device_cd = f8
     2 valid_from_dt_tm = dq8
     2 valid_until_dt_tm = dq8
     2 publish_flag = i2
     2 updt_cnt = i4
 )
 RECORD temp_del_images(
   1 qual[*]
     2 blob_ref_id = f8
     2 storage_cd = f8
 )
 RECORD temp_chg_pvw_dataset(
   1 qual[*]
     2 dataset_uid = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
 )
 RECORD temp_add_comment(
   1 qual[*]
     2 comment_id = f8
     2 comment = vc
     2 blob_ref_id = f8
     2 updt_cnt = i4
 )
 RECORD temp_chg_comment(
   1 qual[*]
     2 comment_id = f8
     2 comment = vc
     2 blob_ref_id = f8
     2 updt_cnt = i4
 )
 RECORD temp_del_comment(
   1 qual[*]
     2 comment_id = f8
 )
 RECORD temp_add_tbnl_images(
   1 qual[*]
     2 tbnl_long_blob_id = f8
     2 tbnl_image = vgc
     2 blob_ref_id = f8
 )
 RECORD temp_del_tbnl_images(
   1 qual[*]
     2 tbnl_long_blob_id = f8
 )
 RECORD input_rec(
   1 qual[*]
     2 prev_table = vc
     2 prev_id = f8
     2 new_table = vc
     2 new_id = f8
 )
 RECORD chg_loc_reply(
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
#script
 SET nbr_reports = 0
 SET lr = 0
 SET nbr_sections = 0
 SET ls = 0
 SET nbr_images = 0
 SET li = 0
 IF ((request->initiated_by_err_correct_ind=0)
  AND (request->initiated_by_event_server_ind=0))
  RECORD reply(
    1 case_updt_cnt = i4
    1 report_qual[*]
      2 report_index = i4
      2 report_id = f8
      2 report_updt_cnt = i4
      2 status_cd = f8
      2 status_disp = c40
      2 skip_ind = i2
      2 updt_id = f8
      2 updt_name_full_formatted = vc
      2 section_qual[*]
        3 section_index = i4
        3 report_detail_id = f8
        3 section_updt_cnt = i4
        3 image_qual[*]
          4 image_index = i4
          4 blob_ref_id = f8
          4 tbnl_long_blob_id = f8
          4 chartable_note_id = f8
          4 chartable_note_updt_cnt = i4
          4 non_chartable_note_id = f8
          4 non_chartable_note_updt_cnt = i4
          4 image_updt_cnt = i4
      2 image_qual[*]
        3 image_index = i4
        3 blob_ref_id = f8
        3 tbnl_long_blob_id = f8
        3 chartable_note_id = f8
        3 chartable_note_updt_cnt = i4
        3 non_chartable_note_id = f8
        3 non_chartable_note_updt_cnt = i4
        3 image_updt_cnt = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 entity_qual[*]
      2 folder_id = f8
      2 entity_id = f8
      2 parent_entity_name = c32
      2 entity_type_flag = i2
      2 accession_nbr = c21
  )
 ENDIF
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET nbr_reports = cnvtint(size(request->report_qual,5))
 SET nbr_sections = 0
 SET nbr_images = 0
 SET code_value = 0.0
 SET active_status_cd = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0
 SET reportcnt = 0
 SET sectioncnt = 0
 SET imagecnt = 0
 SET eadd = 1
 SET eupdate = 2
 SET edelete = 4
 SET tempchgpvwdatasetcnt = 0
 SET tempchgreportscnt = 0
 SET tempaddsectionscnt = 0
 SET tempdelsectionscnt = 0
 SET tempaddimagescnt = 0
 SET tempchgimagescnt = 0
 SET tempdelimagescnt = 0
 SET tempaddcommentcnt = 0
 SET tempchgcommentcnt = 0
 SET tempdelcommentcnt = 0
 SET tempaddtbnlimagescnt = 0
 SET tempdeltbnlimagescnt = 0
 SET updt_cnts_array[1000] = 0
 SET nbr_items = 0
 SET invalid_status_ind = 0
 SET reportstatuscnt = 0
 SET input_rec_cnt = 0
 SET tempdelpurgecnt = 0
 SET dicom_storage_cd = 0.0
 SET upd_case_dataset_uid = 1
 SET verified_status_cd = 0.0
 SET corrected_status_cd = 0.0
 SET signinproc_status_cd = 0.0
 SET csigninproc_status_cd = 0.0
 DECLARE tbnl_long_blob_id = f8 WITH protect, noconstant(0.0)
 DECLARE chartable_note_id = f8 WITH protect, noconstant(0.0)
 DECLARE non_chartable_note_id = f8 WITH protect, noconstant(0.0)
 DECLARE report_detail_id = f8 WITH protect, noconstant(0.0)
 DECLARE blob_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE get_migrated_handles(handle_input=vc(ref)) = null WITH private
 DECLARE lnbrdocimagesdel = i4 WITH protect, noconstant(0)
 DECLARE lnbrdocimageschg = i4 WITH protect, noconstant(0)
 DECLARE lnbrdocimagesadd = i4 WITH protect, noconstant(0)
 DECLARE pcsdocimg_storage_cd = f8 WITH protect, noconstant(0.0)
 SET cdf_meaning = "ACTIVE"
 SET code_set = 48
 EXECUTE cpm_get_cd_for_cdf
 SET active_status_cd = code_value
 SET code_set = 25
 SET cdf_meaning = "DICOM_SIUID"
 EXECUTE cpm_get_cd_for_cdf
 SET dicom_storage_cd = code_value
 SET code_set = 25
 SET cdf_meaning = "PCSDOCIMG"
 EXECUTE cpm_get_cd_for_cdf
 SET pcsdocimg_storage_cd = code_value
 SET code_set = 1305
 SET cdf_meaning = "VERIFIED"
 EXECUTE cpm_get_cd_for_cdf
 SET verified_status_cd = code_value
 SET code_set = 1305
 SET cdf_meaning = "CORRECTED"
 EXECUTE cpm_get_cd_for_cdf
 SET corrected_status_cd = code_value
 SET code_set = 1305
 SET cdf_meaning = "SIGNINPROC"
 EXECUTE cpm_get_cd_for_cdf
 SET signinproc_status_cd = code_value
 SET code_set = 1305
 SET cdf_meaning = "CSIGNINPROC"
 EXECUTE cpm_get_cd_for_cdf
 SET csigninproc_status_cd = code_value
 SET stat = alterlist(reply_addl->report_qual,nbr_reports)
 SET stat = alterlist(temp_chg_reports->qual,nbr_reports)
 SELECT INTO "nl:"
  cr.report_id
  FROM case_report cr,
   (dummyt d  WITH seq = value(nbr_reports))
  PLAN (d)
   JOIN (cr
   WHERE (cr.report_id=request->report_qual[d.seq].report_id))
  HEAD REPORT
   invalid_status_ind = 0, reportstatuscnt = 0
  DETAIL
   reportstatuscnt = (reportstatuscnt+ 1)
   IF (((cr.status_cd=verified_status_cd) OR (((cr.status_cd=corrected_status_cd) OR (((cr.status_cd=
   signinproc_status_cd) OR (cr.status_cd=csigninproc_status_cd)) )) )) )
    reply_addl->report_qual[d.seq].status_cd = cr.status_cd, reply_addl->report_qual[d.seq].skip_ind
     = 1, reply_addl->report_qual[d.seq].updt_id = cr.updt_id,
    invalid_status_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (reportstatuscnt != nbr_reports)
  GO TO report_status_failed
 ENDIF
 IF (invalid_status_ind=1)
  IF ((request->initiated_by_err_correct_ind=1))
   GO TO invalid_report_status
  ELSE
   SELECT INTO "nl:"
    cr.report_id, p.person_id
    FROM case_report cr,
     prsnl p,
     (dummyt d  WITH seq = value(nbr_reports))
    PLAN (d)
     JOIN (cr
     WHERE (cr.report_id=request->report_qual[d.seq].report_id))
     JOIN (p
     WHERE p.person_id=cr.updt_id)
    DETAIL
     reply_addl->report_qual[d.seq].updt_id = cr.updt_id, reply_addl->report_qual[d.seq].
     updt_name_full_formatted = p.name_full_formatted
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 FOR (reportcnt = 1 TO nbr_reports)
   IF ((reply_addl->report_qual[reportcnt].skip_ind=0))
    IF ((request->initiated_by_err_correct_ind=0))
     SET reply_addl->report_qual[reportcnt].report_index = request->report_qual[reportcnt].
     report_index
     SET reply_addl->report_qual[reportcnt].report_id = request->report_qual[reportcnt].report_id
     SET reply_addl->report_qual[reportcnt].report_updt_cnt = (request->report_qual[reportcnt].
     updt_cnt+ 1)
     SET tempchgreportscnt = (tempchgreportscnt+ 1)
     SET temp_chg_reports->qual[reportcnt].report_id = request->report_qual[reportcnt].report_id
     SET temp_chg_reports->qual[reportcnt].blob_bitmap = request->report_qual[reportcnt].blob_bitmap
     SET temp_chg_reports->qual[reportcnt].updt_cnt = request->report_qual[reportcnt].updt_cnt
    ENDIF
    SET nbr_images = cnvtint(size(request->report_qual[reportcnt].image_qual,5))
    SET stat = alterlist(reply_addl->report_qual[reportcnt].image_qual,nbr_images)
    FOR (imagecnt = 1 TO nbr_images)
      CASE (request->report_qual[reportcnt].image_qual[imagecnt].ensure_type)
       OF eadd:
        SET tempaddimagescnt = (tempaddimagescnt+ 1)
        SET stat = alterlist(temp_add_images->qual,tempaddimagescnt)
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
        SET temp_add_images->qual[tempaddimagescnt].blob_ref_id = blob_ref_id
        SET temp_add_images->qual[tempaddimagescnt].parent_entity_name = "CASE_REPORT"
        SET temp_add_images->qual[tempaddimagescnt].parent_entity_id = request->report_qual[reportcnt
        ].report_id
        SET temp_add_images->qual[tempaddimagescnt].valid_from_dt_tm = request->report_qual[reportcnt
        ].image_qual[imagecnt].valid_from_dt_tm
        SET temp_add_images->qual[tempaddimagescnt].sequence_nbr = request->report_qual[reportcnt].
        image_qual[imagecnt].sequence_nbr
        SET temp_add_images->qual[tempaddimagescnt].owner_cd = request->report_qual[reportcnt].
        image_qual[imagecnt].owner_cd
        SET temp_add_images->qual[tempaddimagescnt].storage_cd = request->report_qual[reportcnt].
        image_qual[imagecnt].storage_cd
        SET temp_add_images->qual[tempaddimagescnt].format_cd = request->report_qual[reportcnt].
        image_qual[imagecnt].format_cd
        SET temp_add_images->qual[tempaddimagescnt].blob_handle = request->report_qual[reportcnt].
        image_qual[imagecnt].blob_handle
        SET temp_add_images->qual[tempaddimagescnt].blob_title = request->report_qual[reportcnt].
        image_qual[imagecnt].blob_title
        SET temp_add_images->qual[tempaddimagescnt].create_prsnl_id = request->report_qual[reportcnt]
        .image_qual[imagecnt].create_prsnl_id
        SET temp_add_images->qual[tempaddimagescnt].source_device_cd = request->report_qual[reportcnt
        ].image_qual[imagecnt].source_device_cd
        SET temp_add_images->qual[tempaddimagescnt].publish_flag = request->report_qual[reportcnt].
        image_qual[imagecnt].publish_flag
        SET temp_add_images->qual[tempaddimagescnt].updt_cnt = request->report_qual[reportcnt].
        image_qual[imagecnt].updt_cnt
        SET temp_add_images->qual[tempaddimagescnt].blob_foreign_ident = request->report_qual[
        reportcnt].image_qual[imagecnt].blob_foreign_ident
        SET reply_addl->report_qual[reportcnt].image_qual[imagecnt].image_index = request->
        report_qual[reportcnt].image_qual[imagecnt].image_index
        SET reply_addl->report_qual[reportcnt].image_qual[imagecnt].blob_ref_id = blob_ref_id
        SET reply_addl->report_qual[reportcnt].image_qual[imagecnt].image_updt_cnt = 0
        SET reply_addl->report_qual[reportcnt].image_qual[imagecnt].chartable_note_id = 0.0
        SET reply_addl->report_qual[reportcnt].image_qual[imagecnt].chartable_note_updt_cnt = 0
        SET reply_addl->report_qual[reportcnt].image_qual[imagecnt].non_chartable_note_id = 0.0
        SET reply_addl->report_qual[reportcnt].image_qual[imagecnt].non_chartable_note_updt_cnt = 0
        SET lnbrdocimagesadd = (lnbrdocimagesadd+ 1)
       OF eupdate:
        SET tempchgimagescnt = (tempchgimagescnt+ 1)
        SET stat = alterlist(temp_chg_images->qual,tempchgimagescnt)
        SET temp_chg_images->qual[tempchgimagescnt].blob_ref_id = request->report_qual[reportcnt].
        image_qual[imagecnt].blob_ref_id
        SET temp_chg_images->qual[tempchgimagescnt].parent_entity_name = "CASE_REPORT"
        SET temp_chg_images->qual[tempchgimagescnt].parent_entity_id = request->report_qual[reportcnt
        ].report_id
        SET temp_chg_images->qual[tempchgimagescnt].sequence_nbr = request->report_qual[reportcnt].
        image_qual[imagecnt].sequence_nbr
        SET temp_chg_images->qual[tempchgimagescnt].owner_cd = request->report_qual[reportcnt].
        image_qual[imagecnt].owner_cd
        SET temp_chg_images->qual[tempchgimagescnt].storage_cd = request->report_qual[reportcnt].
        image_qual[imagecnt].storage_cd
        SET temp_chg_images->qual[tempchgimagescnt].format_cd = request->report_qual[reportcnt].
        image_qual[imagecnt].format_cd
        SET temp_chg_images->qual[tempchgimagescnt].blob_handle = request->report_qual[reportcnt].
        image_qual[imagecnt].blob_handle
        SET temp_chg_images->qual[tempchgimagescnt].blob_title = request->report_qual[reportcnt].
        image_qual[imagecnt].blob_title
        SET temp_chg_images->qual[tempchgimagescnt].create_prsnl_id = request->report_qual[reportcnt]
        .image_qual[imagecnt].create_prsnl_id
        SET temp_chg_images->qual[tempchgimagescnt].tbnl_long_blob_id = request->report_qual[
        reportcnt].image_qual[imagecnt].tbnl_long_blob_id
        SET reply_addl->report_qual[reportcnt].image_qual[imagecnt].tbnl_long_blob_id = request->
        report_qual[reportcnt].image_qual[imagecnt].tbnl_long_blob_id
        SET temp_chg_images->qual[tempchgimagescnt].tbnl_format_cd = request->report_qual[reportcnt].
        image_qual[imagecnt].tbnl_format_cd
        SET temp_chg_images->qual[tempchgimagescnt].source_device_cd = request->report_qual[reportcnt
        ].image_qual[imagecnt].source_device_cd
        SET temp_chg_images->qual[tempchgimagescnt].publish_flag = request->report_qual[reportcnt].
        image_qual[imagecnt].publish_flag
        SET temp_chg_images->qual[tempchgimagescnt].updt_cnt = request->report_qual[reportcnt].
        image_qual[imagecnt].updt_cnt
        SET reply_addl->report_qual[reportcnt].image_qual[imagecnt].image_index = request->
        report_qual[reportcnt].image_qual[imagecnt].image_index
        SET reply_addl->report_qual[reportcnt].image_qual[imagecnt].blob_ref_id = request->
        report_qual[reportcnt].image_qual[imagecnt].blob_ref_id
        SET reply_addl->report_qual[reportcnt].image_qual[imagecnt].image_updt_cnt = (request->
        report_qual[reportcnt].image_qual[imagecnt].updt_cnt+ 1)
        SET lnbrdocimageschg = (lnbrdocimageschg+ 1)
       OF edelete:
        SET tempdelimagescnt = (tempdelimagescnt+ 1)
        SET stat = alterlist(temp_del_images->qual,tempdelimagescnt)
        SET temp_del_images->qual[tempdelimagescnt].blob_ref_id = request->report_qual[reportcnt].
        image_qual[imagecnt].blob_ref_id
        SET reply_addl->report_qual[reportcnt].image_qual[imagecnt].image_index = request->
        report_qual[reportcnt].image_qual[imagecnt].image_index
        SET reply_addl->report_qual[reportcnt].image_qual[imagecnt].blob_ref_id = request->
        report_qual[reportcnt].image_qual[imagecnt].blob_ref_id
        SET temp_del_images->qual[tempdelimagescnt].storage_cd = request->report_qual[reportcnt].
        image_qual[imagecnt].storage_cd
        SET lnbrdocimagesdel = (lnbrdocimagesdel+ 1)
      ENDCASE
    ENDFOR
    SET nbr_sections = cnvtint(size(request->report_qual[reportcnt].section_qual,5))
    SET stat = alterlist(reply_addl->report_qual[reportcnt].section_qual,nbr_sections)
    FOR (sectioncnt = 1 TO nbr_sections)
      IF ((request->report_qual[reportcnt].section_qual[sectioncnt].blob_bitmap=0))
       SET tempdelsectionscnt = (tempdelsectionscnt+ 1)
       SET stat = alterlist(temp_del_sections->qual,tempdelsectionscnt)
       SET temp_del_sections->qual[tempdelsectionscnt].report_detail_id = request->report_qual[
       reportcnt].section_qual[sectioncnt].report_detail_id
       SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].section_index = request->
       report_qual[reportcnt].section_qual[sectioncnt].section_index
       SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].report_detail_id = 0.0
       SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].section_updt_cnt = 0
      ELSEIF ((request->report_qual[reportcnt].section_qual[sectioncnt].report_detail_id=0.0))
       SET tempaddsectionscnt = (tempaddsectionscnt+ 1)
       SET stat = alterlist(temp_add_sections->qual,tempaddsectionscnt)
       SELECT INTO "nl:"
        seq_nbr = seq(pathnet_seq,nextval)
        FROM dual
        DETAIL
         report_detail_id = seq_nbr
        WITH format, nocounter
       ;end select
       IF (curqual=0)
        GO TO seq_failed
       ENDIF
       SET temp_add_sections->qual[tempaddsectionscnt].report_detail_id = report_detail_id
       SET temp_add_sections->qual[tempaddsectionscnt].report_id = request->report_qual[reportcnt].
       report_id
       SET temp_add_sections->qual[tempaddsectionscnt].task_assay_cd = request->report_qual[reportcnt
       ].section_qual[sectioncnt].task_assay_cd
       SET temp_add_sections->qual[tempaddsectionscnt].updt_cnt = request->report_qual[reportcnt].
       section_qual[sectioncnt].updt_cnt
       SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].section_index = request->
       report_qual[reportcnt].section_qual[sectioncnt].section_index
       SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].report_detail_id =
       report_detail_id
       SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].section_updt_cnt = 0
      ELSE
       SET report_detail_id = request->report_qual[reportcnt].section_qual[sectioncnt].
       report_detail_id
       SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].section_index = request->
       report_qual[reportcnt].section_qual[sectioncnt].section_index
       SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].report_detail_id = request->
       report_qual[reportcnt].section_qual[sectioncnt].report_detail_id
       SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].section_updt_cnt = request->
       report_qual[reportcnt].section_qual[sectioncnt].updt_cnt
      ENDIF
      SET nbr_images = cnvtint(size(request->report_qual[reportcnt].section_qual[sectioncnt].
        image_qual,5))
      SET stat = alterlist(reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual,
       nbr_images)
      FOR (imagecnt = 1 TO nbr_images)
        CASE (request->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
        ensure_type)
         OF eadd:
          SET tempaddimagescnt = (tempaddimagescnt+ 1)
          SET stat = alterlist(temp_add_images->qual,tempaddimagescnt)
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
          SET temp_add_images->qual[tempaddimagescnt].blob_ref_id = blob_ref_id
          SET temp_add_images->qual[tempaddimagescnt].parent_entity_name = "REPORT_DETAIL_IMAGE"
          SET temp_add_images->qual[tempaddimagescnt].parent_entity_id = report_detail_id
          SET temp_add_images->qual[tempaddimagescnt].valid_from_dt_tm = request->report_qual[
          reportcnt].section_qual[sectioncnt].image_qual[imagecnt].valid_from_dt_tm
          SET temp_add_images->qual[tempaddimagescnt].sequence_nbr = request->report_qual[reportcnt].
          section_qual[sectioncnt].image_qual[imagecnt].sequence_nbr
          SET temp_add_images->qual[tempaddimagescnt].owner_cd = request->report_qual[reportcnt].
          section_qual[sectioncnt].image_qual[imagecnt].owner_cd
          SET temp_add_images->qual[tempaddimagescnt].storage_cd = request->report_qual[reportcnt].
          section_qual[sectioncnt].image_qual[imagecnt].storage_cd
          SET temp_add_images->qual[tempaddimagescnt].format_cd = request->report_qual[reportcnt].
          section_qual[sectioncnt].image_qual[imagecnt].format_cd
          SET temp_add_images->qual[tempaddimagescnt].blob_handle = request->report_qual[reportcnt].
          section_qual[sectioncnt].image_qual[imagecnt].blob_handle
          SET temp_add_images->qual[tempaddimagescnt].blob_title = request->report_qual[reportcnt].
          section_qual[sectioncnt].image_qual[imagecnt].blob_title
          SET temp_add_images->qual[tempaddimagescnt].create_prsnl_id = request->report_qual[
          reportcnt].section_qual[sectioncnt].image_qual[imagecnt].create_prsnl_id
          SET temp_add_images->qual[tempaddimagescnt].source_device_cd = request->report_qual[
          reportcnt].section_qual[sectioncnt].image_qual[imagecnt].source_device_cd
          SET temp_add_images->qual[tempaddimagescnt].publish_flag = request->report_qual[reportcnt].
          section_qual[sectioncnt].image_qual[imagecnt].publish_flag
          SET temp_add_images->qual[tempaddimagescnt].updt_cnt = request->report_qual[reportcnt].
          section_qual[sectioncnt].image_qual[imagecnt].updt_cnt
          SET temp_add_images->qual[tempaddimagescnt].blob_foreign_ident = request->report_qual[
          reportcnt].section_qual[sectioncnt].image_qual[imagecnt].blob_foreign_ident
          SET tempaddtbnlimagescnt = (tempaddtbnlimagescnt+ 1)
          SET stat = alterlist(temp_add_tbnl_images->qual,tempaddtbnlimagescnt)
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
          SET temp_add_tbnl_images->qual[tempaddtbnlimagescnt].tbnl_long_blob_id = tbnl_long_blob_id
          SET temp_add_images->qual[tempaddimagescnt].tbnl_format_cd = request->report_qual[reportcnt
          ].section_qual[sectioncnt].image_qual[imagecnt].tbnl_format_cd
          SET temp_add_tbnl_images->qual[tempaddtbnlimagescnt].blob_ref_id = blob_ref_id
          SET temp_add_tbnl_images->qual[tempaddtbnlimagescnt].tbnl_image = request->report_qual[
          reportcnt].section_qual[sectioncnt].image_qual[imagecnt].long_blob
          SET temp_add_images->qual[tempaddimagescnt].tbnl_long_blob_id = tbnl_long_blob_id
          SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          tbnl_long_blob_id = tbnl_long_blob_id
          IF (textlen(request->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
           chartable_note) > 0)
           SET tempaddcommentcnt = (tempaddcommentcnt+ 1)
           SET stat = alterlist(temp_add_comment->qual,tempaddcommentcnt)
           SET temp_add_comment->qual[tempaddcommentcnt].blob_ref_id = blob_ref_id
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
           SET temp_add_comment->qual[tempaddcommentcnt].comment_id = chartable_note_id
           SET temp_add_comment->qual[tempaddcommentcnt].comment = request->report_qual[reportcnt].
           section_qual[sectioncnt].image_qual[imagecnt].chartable_note
           SET temp_add_comment->qual[tempaddcommentcnt].updt_cnt = request->report_qual[reportcnt].
           section_qual[sectioncnt].image_qual[imagecnt].chartable_note_updt_cnt
           SET temp_add_images->qual[tempaddimagescnt].chartable_note_id = chartable_note_id
          ELSE
           SET temp_add_images->qual[tempaddimagescnt].chartable_note_id = 0
          ENDIF
          IF (textlen(request->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
           non_chartable_note) > 0)
           SET tempaddcommentcnt = (tempaddcommentcnt+ 1)
           SET stat = alterlist(temp_add_comment->qual,tempaddcommentcnt)
           SET temp_add_comment->qual[tempaddcommentcnt].blob_ref_id = blob_ref_id
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
           SET temp_add_comment->qual[tempaddcommentcnt].comment_id = non_chartable_note_id
           SET temp_add_comment->qual[tempaddcommentcnt].comment = request->report_qual[reportcnt].
           section_qual[sectioncnt].image_qual[imagecnt].non_chartable_note
           SET temp_add_comment->qual[tempaddcommentcnt].updt_cnt = request->report_qual[reportcnt].
           section_qual[sectioncnt].image_qual[imagecnt].non_chartable_note_updt_cnt
           SET temp_add_images->qual[tempaddimagescnt].non_chartable_note_id = non_chartable_note_id
          ELSE
           SET temp_add_images->qual[tempaddimagescnt].non_chartable_note_id = 0
          ENDIF
          SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          image_index = request->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt]
          .image_index
          SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          blob_ref_id = blob_ref_id
          SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          image_updt_cnt = 0
          SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          chartable_note_id = temp_add_images->qual[tempaddimagescnt].chartable_note_id
          SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          chartable_note_updt_cnt = 0
          SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          non_chartable_note_id = temp_add_images->qual[tempaddimagescnt].non_chartable_note_id
          SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          non_chartable_note_updt_cnt = 0
          IF ((request->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          storage_cd=dicom_storage_cd))
           SET tempchgpvwdatasetcnt = (tempchgpvwdatasetcnt+ 1)
           SET stat = alterlist(temp_chg_pvw_dataset->qual,tempchgpvwdatasetcnt)
           SET temp_chg_pvw_dataset->qual[tempchgpvwdatasetcnt].dataset_uid = request->report_qual[
           reportcnt].section_qual[sectioncnt].image_qual[imagecnt].blob_handle
           SET temp_chg_pvw_dataset->qual[tempchgpvwdatasetcnt].parent_entity_name = "BLOB_REFERENCE"
           SET temp_chg_pvw_dataset->qual[tempchgpvwdatasetcnt].parent_entity_id = blob_ref_id
           IF ((request->initiated_by_err_correct_ind=0)
            AND upd_case_dataset_uid=1)
            IF (trim(request->case_dataset_uid) != "0"
             AND trim(request->case_dataset_uid) != "")
             SET tempchgpvwdatasetcnt = (tempchgpvwdatasetcnt+ 1)
             SET stat = alterlist(temp_chg_pvw_dataset->qual,tempchgpvwdatasetcnt)
             SET temp_chg_pvw_dataset->qual[tempchgpvwdatasetcnt].dataset_uid = request->
             case_dataset_uid
             SET temp_chg_pvw_dataset->qual[tempchgpvwdatasetcnt].parent_entity_name =
             "PATHOLOGY_CASE"
             SET temp_chg_pvw_dataset->qual[tempchgpvwdatasetcnt].parent_entity_id = request->case_id
            ENDIF
            SET upd_case_dataset_uid = 0
           ENDIF
          ENDIF
          IF ((request->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          orig_parent_id > 0))
           SET input_rec_cnt = (input_rec_cnt+ 1)
           SET stat = alterlist(input_rec->qual,input_rec_cnt)
           SET input_rec->qual[input_rec_cnt].prev_table = request->report_qual[reportcnt].
           section_qual[sectioncnt].image_qual[imagecnt].orig_parent_table
           SET input_rec->qual[input_rec_cnt].prev_id = request->report_qual[reportcnt].section_qual[
           sectioncnt].image_qual[imagecnt].orig_parent_id
           SET input_rec->qual[input_rec_cnt].new_table = "BLOB_REFERENCE"
           SET input_rec->qual[input_rec_cnt].new_id = blob_ref_id
          ENDIF
         OF eupdate:
          SET tempchgimagescnt = (tempchgimagescnt+ 1)
          SET stat = alterlist(temp_chg_images->qual,tempchgimagescnt)
          SET temp_chg_images->qual[tempchgimagescnt].blob_ref_id = request->report_qual[reportcnt].
          section_qual[sectioncnt].image_qual[imagecnt].blob_ref_id
          SET temp_chg_images->qual[tempchgimagescnt].parent_entity_name = "REPORT_DETAIL_IMAGE"
          SET temp_chg_images->qual[tempchgimagescnt].parent_entity_id = report_detail_id
          SET temp_chg_images->qual[tempchgimagescnt].sequence_nbr = request->report_qual[reportcnt].
          section_qual[sectioncnt].image_qual[imagecnt].sequence_nbr
          SET temp_chg_images->qual[tempchgimagescnt].owner_cd = request->report_qual[reportcnt].
          section_qual[sectioncnt].image_qual[imagecnt].owner_cd
          SET temp_chg_images->qual[tempchgimagescnt].storage_cd = request->report_qual[reportcnt].
          section_qual[sectioncnt].image_qual[imagecnt].storage_cd
          SET temp_chg_images->qual[tempchgimagescnt].format_cd = request->report_qual[reportcnt].
          section_qual[sectioncnt].image_qual[imagecnt].format_cd
          SET temp_chg_images->qual[tempchgimagescnt].blob_handle = request->report_qual[reportcnt].
          section_qual[sectioncnt].image_qual[imagecnt].blob_handle
          SET temp_chg_images->qual[tempchgimagescnt].blob_title = request->report_qual[reportcnt].
          section_qual[sectioncnt].image_qual[imagecnt].blob_title
          SET temp_chg_images->qual[tempchgimagescnt].create_prsnl_id = request->report_qual[
          reportcnt].section_qual[sectioncnt].image_qual[imagecnt].create_prsnl_id
          SET temp_chg_images->qual[tempchgimagescnt].tbnl_long_blob_id = request->report_qual[
          reportcnt].section_qual[sectioncnt].image_qual[imagecnt].tbnl_long_blob_id
          SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          tbnl_long_blob_id = request->report_qual[reportcnt].section_qual[sectioncnt].image_qual[
          imagecnt].tbnl_long_blob_id
          SET temp_chg_images->qual[tempchgimagescnt].tbnl_format_cd = request->report_qual[reportcnt
          ].section_qual[sectioncnt].image_qual[imagecnt].tbnl_format_cd
          SET temp_chg_images->qual[tempchgimagescnt].source_device_cd = request->report_qual[
          reportcnt].section_qual[sectioncnt].image_qual[imagecnt].source_device_cd
          SET temp_chg_images->qual[tempchgimagescnt].publish_flag = request->report_qual[reportcnt].
          section_qual[sectioncnt].image_qual[imagecnt].publish_flag
          SET temp_chg_images->qual[tempchgimagescnt].updt_cnt = request->report_qual[reportcnt].
          section_qual[sectioncnt].image_qual[imagecnt].updt_cnt
          IF ((request->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          chartable_note_id > 0))
           SET tempchgcommentcnt = (tempchgcommentcnt+ 1)
           SET stat = alterlist(temp_chg_comment->qual,tempchgcommentcnt)
           SET temp_chg_comment->qual[tempchgcommentcnt].blob_ref_id = request->report_qual[reportcnt
           ].section_qual[sectioncnt].image_qual[imagecnt].blob_ref_id
           SET temp_chg_comment->qual[tempchgcommentcnt].comment_id = request->report_qual[reportcnt]
           .section_qual[sectioncnt].image_qual[imagecnt].chartable_note_id
           SET temp_chg_comment->qual[tempchgcommentcnt].comment = request->report_qual[reportcnt].
           section_qual[sectioncnt].image_qual[imagecnt].chartable_note
           SET temp_chg_comment->qual[tempchgcommentcnt].updt_cnt = request->report_qual[reportcnt].
           section_qual[sectioncnt].image_qual[imagecnt].chartable_note_updt_cnt
           SET temp_chg_images->qual[tempchgimagescnt].chartable_note_id = request->report_qual[
           reportcnt].section_qual[sectioncnt].image_qual[imagecnt].chartable_note_id
           SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
           chartable_note_id = request->report_qual[reportcnt].section_qual[sectioncnt].image_qual[
           imagecnt].chartable_note_id
           SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
           chartable_note_updt_cnt = (request->report_qual[reportcnt].section_qual[sectioncnt].
           image_qual[imagecnt].chartable_note_updt_cnt+ 1)
          ELSEIF (textlen(request->report_qual[reportcnt].section_qual[sectioncnt].image_qual[
           imagecnt].chartable_note) > 0)
           SET tempaddcommentcnt = (tempaddcommentcnt+ 1)
           SET stat = alterlist(temp_add_comment->qual,tempaddcommentcnt)
           SET temp_add_comment->qual[tempaddcommentcnt].blob_ref_id = request->report_qual[reportcnt
           ].section_qual[sectioncnt].image_qual[imagecnt].blob_ref_id
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
           SET temp_add_comment->qual[tempaddcommentcnt].comment_id = chartable_note_id
           SET temp_add_comment->qual[tempaddcommentcnt].comment = request->report_qual[reportcnt].
           section_qual[sectioncnt].image_qual[imagecnt].chartable_note
           SET temp_add_comment->qual[tempaddcommentcnt].updt_cnt = request->report_qual[reportcnt].
           section_qual[sectioncnt].image_qual[imagecnt].chartable_note_updt_cnt
           SET temp_chg_images->qual[tempchgimagescnt].chartable_note_id = chartable_note_id
           SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
           chartable_note_id = chartable_note_id
           SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
           chartable_note_updt_cnt = 0
          ELSE
           SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
           chartable_note_id = 0
           SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
           chartable_note_updt_cnt = 0
          ENDIF
          IF ((request->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          non_chartable_note_id > 0))
           SET tempchgcommentcnt = (tempchgcommentcnt+ 1)
           SET stat = alterlist(temp_chg_comment->qual,tempchgcommentcnt)
           SET temp_chg_comment->qual[tempchgcommentcnt].blob_ref_id = request->report_qual[reportcnt
           ].section_qual[sectioncnt].image_qual[imagecnt].blob_ref_id
           SET temp_chg_comment->qual[tempchgcommentcnt].comment_id = request->report_qual[reportcnt]
           .section_qual[sectioncnt].image_qual[imagecnt].non_chartable_note_id
           SET temp_chg_comment->qual[tempchgcommentcnt].comment = request->report_qual[reportcnt].
           section_qual[sectioncnt].image_qual[imagecnt].non_chartable_note
           SET temp_chg_comment->qual[tempchgcommentcnt].updt_cnt = request->report_qual[reportcnt].
           section_qual[sectioncnt].image_qual[imagecnt].non_chartable_note_updt_cnt
           SET temp_chg_images->qual[tempchgimagescnt].non_chartable_note_id = request->report_qual[
           reportcnt].section_qual[sectioncnt].image_qual[imagecnt].non_chartable_note_id
           SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
           non_chartable_note_id = request->report_qual[reportcnt].section_qual[sectioncnt].
           image_qual[imagecnt].non_chartable_note_id
           SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
           non_chartable_note_updt_cnt = (request->report_qual[reportcnt].section_qual[sectioncnt].
           image_qual[imagecnt].non_chartable_note_updt_cnt+ 1)
          ELSEIF (textlen(request->report_qual[reportcnt].section_qual[sectioncnt].image_qual[
           imagecnt].non_chartable_note) > 0)
           SET tempaddcommentcnt = (tempaddcommentcnt+ 1)
           SET stat = alterlist(temp_add_comment->qual,tempaddcommentcnt)
           SET temp_add_comment->qual[tempaddcommentcnt].blob_ref_id = request->report_qual[reportcnt
           ].section_qual[sectioncnt].image_qual[imagecnt].blob_ref_id
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
           SET temp_add_comment->qual[tempaddcommentcnt].comment_id = non_chartable_note_id
           SET temp_add_comment->qual[tempaddcommentcnt].comment = request->report_qual[reportcnt].
           section_qual[sectioncnt].image_qual[imagecnt].non_chartable_note
           SET temp_add_comment->qual[tempaddcommentcnt].updt_cnt = request->report_qual[reportcnt].
           section_qual[sectioncnt].image_qual[imagecnt].non_chartable_note_updt_cnt
           SET temp_chg_images->qual[tempchgimagescnt].non_chartable_note_id = non_chartable_note_id
           SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
           non_chartable_note_id = non_chartable_note_id
           SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
           non_chartable_note_updt_cnt = 0
          ELSE
           SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
           non_chartable_note_id = 0
           SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
           non_chartable_note_updt_cnt = 0
          ENDIF
          SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          image_index = request->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt]
          .image_index
          SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          blob_ref_id = request->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt]
          .blob_ref_id
          SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          image_updt_cnt = (request->report_qual[reportcnt].section_qual[sectioncnt].image_qual[
          imagecnt].updt_cnt+ 1)
         OF edelete:
          SET tempdelimagescnt = (tempdelimagescnt+ 1)
          SET stat = alterlist(temp_del_images->qual,tempdelimagescnt)
          SET temp_del_images->qual[tempdelimagescnt].blob_ref_id = request->report_qual[reportcnt].
          section_qual[sectioncnt].image_qual[imagecnt].blob_ref_id
          SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          image_index = request->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt]
          .image_index
          SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          blob_ref_id = request->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt]
          .blob_ref_id
          SET stat = alterlist(request->entity_qual,tempdelimagescnt)
          SET request->entity_qual[tempdelimagescnt].parent_entity_id = request->report_qual[
          reportcnt].section_qual[sectioncnt].image_qual[imagecnt].blob_ref_id
          SET request->entity_qual[tempdelimagescnt].parent_entity_name = "BLOB_REFERENCE"
          SET tempdeltbnlimagescnt = (tempdeltbnlimagescnt+ 1)
          SET stat = alterlist(temp_del_tbnl_images->qual,tempdeltbnlimagescnt)
          SET temp_del_tbnl_images->qual[tempdeltbnlimagescnt].tbnl_long_blob_id = request->
          report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].tbnl_long_blob_id
          IF ((request->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          chartable_note_id > 0))
           SET tempdelcommentcnt = (tempdelcommentcnt+ 1)
           SET stat = alterlist(temp_del_comment->qual,tempdelcommentcnt)
           SET temp_del_comment->qual[tempdelcommentcnt].comment_id = request->report_qual[reportcnt]
           .section_qual[sectioncnt].image_qual[imagecnt].chartable_note_id
          ENDIF
          SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          chartable_note_id = 0
          SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          chartable_note_updt_cnt = 0
          IF ((request->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          non_chartable_note_id > 0))
           SET tempdelcommentcnt = (tempdelcommentcnt+ 1)
           SET stat = alterlist(temp_del_comment->qual,tempdelcommentcnt)
           SET temp_del_comment->qual[tempdelcommentcnt].comment_id = request->report_qual[reportcnt]
           .section_qual[sectioncnt].image_qual[imagecnt].non_chartable_note_id
          ENDIF
          SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          non_chartable_note_id = 0
          SET reply_addl->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          non_chartable_note_updt_cnt = 0
          IF ((request->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
          purge_image_file=1))
           IF ((request->report_qual[reportcnt].section_qual[sectioncnt].image_qual[imagecnt].
           storage_cd=dicom_storage_cd))
            SET tempdelpurgecnt = (tempdelpurgecnt+ 1)
            SET stat = alterlist(purge_input->qual,tempdelpurgecnt)
            SET purge_input->qual[tempdelpurgecnt].blob_identifier = request->report_qual[reportcnt].
            section_qual[sectioncnt].image_qual[imagecnt].blob_handle
           ENDIF
          ENDIF
        ENDCASE
      ENDFOR
    ENDFOR
   ELSE
    SET tempchgreportscnt = (tempchgreportscnt+ 1)
    SET temp_chg_reports->qual[reportcnt].report_id = request->report_qual[reportcnt].report_id
    SET temp_chg_reports->qual[reportcnt].blob_bitmap = request->report_qual[reportcnt].blob_bitmap
    SET temp_chg_reports->qual[reportcnt].updt_cnt = request->report_qual[reportcnt].updt_cnt
   ENDIF
 ENDFOR
 IF (tempdelimagescnt > 0)
  DELETE  FROM blob_summary_ref bsr,
    (dummyt d  WITH seq = value(tempdelimagescnt))
   SET bsr.blob_ref_id = temp_del_images->qual[d.seq].blob_ref_id
   PLAN (d
    WHERE (temp_del_images->qual[d.seq].storage_cd != pcsdocimg_storage_cd))
    JOIN (bsr
    WHERE (bsr.blob_ref_id=temp_del_images->qual[d.seq].blob_ref_id))
   WITH nocounter
  ;end delete
  IF ((curqual != (tempdelimagescnt - lnbrdocimagesdel)))
   GO TO del_tbnl_images_failed
  ENDIF
 ENDIF
 IF (tempdelimagescnt > 0)
  DELETE  FROM blob_reference br,
    (dummyt d  WITH seq = value(tempdelimagescnt))
   SET br.blob_ref_id = temp_del_images->qual[d.seq].blob_ref_id
   PLAN (d)
    JOIN (br
    WHERE (br.blob_ref_id=temp_del_images->qual[d.seq].blob_ref_id))
   WITH nocounter
  ;end delete
  IF (curqual != tempdelimagescnt)
   GO TO image_failed
  ENDIF
 ENDIF
 IF (tempdelpurgecnt > 0)
  EXECUTE aps_add_blobs_to_purge
  IF ((purge_output->status_data.status != "S"))
   GO TO add_to_purge_failed
  ENDIF
 ENDIF
 IF (tempdeltbnlimagescnt > 0)
  DELETE  FROM long_blob lb,
    (dummyt d  WITH seq = value(tempdeltbnlimagescnt))
   SET lb.long_blob_id = temp_del_tbnl_images->qual[d.seq].tbnl_long_blob_id
   PLAN (d)
    JOIN (lb
    WHERE (lb.long_blob_id=temp_del_tbnl_images->qual[d.seq].tbnl_long_blob_id))
   WITH nocounter
  ;end delete
  IF (curqual != tempdeltbnlimagescnt)
   GO TO tbnl_images_failed
  ENDIF
 ENDIF
 IF (((tempdelimagescnt - lnbrdocimagesdel) > 0))
  EXECUTE aps_del_folder_entities
  IF ((reply->status_data.status="F"))
   SET failed = "T"
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "F"
   SET failed = "F"
  ENDIF
 ENDIF
 IF (tempdelcommentcnt > 0)
  DELETE  FROM long_text lt,
    (dummyt d  WITH seq = value(tempdelcommentcnt))
   SET lt.long_text_id = temp_del_comment->qual[d.seq].comment_id
   PLAN (d)
    JOIN (lt
    WHERE (lt.long_text_id=temp_del_comment->qual[d.seq].comment_id))
   WITH nocounter
  ;end delete
  IF (curqual != tempdelcommentcnt)
   GO TO comment_failed
  ENDIF
 ENDIF
 IF (tempdelsectionscnt > 0)
  DELETE  FROM report_detail_image rdi,
    (dummyt d  WITH seq = value(tempdelsectionscnt))
   SET rdi.report_detail_id = temp_del_sections->qual[d.seq].report_detail_id
   PLAN (d)
    JOIN (rdi
    WHERE (rdi.report_detail_id=temp_del_sections->qual[d.seq].report_detail_id))
   WITH nocounter
  ;end delete
  IF (curqual != tempdelsectionscnt)
   GO TO section_failed
  ENDIF
 ENDIF
 IF (tempaddsectionscnt > 0)
  INSERT  FROM report_detail_image rdi,
    (dummyt d  WITH seq = value(tempaddsectionscnt))
   SET rdi.report_detail_id = temp_add_sections->qual[d.seq].report_detail_id, rdi.report_id =
    temp_add_sections->qual[d.seq].report_id, rdi.task_assay_cd = temp_add_sections->qual[d.seq].
    task_assay_cd,
    rdi.updt_dt_tm = cnvtdatetime(curdate,curtime3), rdi.updt_id = reqinfo->updt_id, rdi.updt_task =
    reqinfo->updt_task,
    rdi.updt_cnt = 0, rdi.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (rdi)
   WITH nocounter
  ;end insert
  IF (curqual != tempaddsectionscnt)
   GO TO section_failed
  ENDIF
 ENDIF
 IF (tempaddcommentcnt > 0)
  INSERT  FROM long_text lt,
    (dummyt d  WITH seq = value(tempaddcommentcnt))
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
  IF (curqual != tempaddcommentcnt)
   GO TO comment_failed
  ENDIF
 ENDIF
 IF (tempaddtbnlimagescnt > 0)
  INSERT  FROM long_blob lb,
    (dummyt d  WITH seq = value(tempaddtbnlimagescnt))
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
  IF (curqual != tempaddtbnlimagescnt)
   GO TO add_tbnl_images_failed
  ENDIF
 ENDIF
 IF (tempaddimagescnt > 0)
  CALL get_migrated_handles(temp_add_images)
  CALL echo(build("Updt_id is: ",reqinfo->updt_id))
  INSERT  FROM blob_reference br,
    (dummyt d  WITH seq = value(tempaddimagescnt))
   SET br.blob_ref_id = temp_add_images->qual[d.seq].blob_ref_id, br.valid_until_dt_tm = cnvtdatetime
    ("31-DEC-2100 23:23:59"), br.valid_from_dt_tm = cnvtdatetime(temp_add_images->qual[d.seq].
     valid_from_dt_tm),
    br.parent_entity_name = temp_add_images->qual[d.seq].parent_entity_name, br.parent_entity_id =
    temp_add_images->qual[d.seq].parent_entity_id, br.sequence_nbr = temp_add_images->qual[d.seq].
    sequence_nbr,
    br.owner_cd = temp_add_images->qual[d.seq].owner_cd, br.storage_cd = temp_add_images->qual[d.seq]
    .storage_cd, br.format_cd = temp_add_images->qual[d.seq].format_cd,
    br.blob_handle = temp_add_images->qual[d.seq].blob_handle, br.blob_title = temp_add_images->qual[
    d.seq].blob_title, br.create_prsnl_id = temp_add_images->qual[d.seq].create_prsnl_id,
    br.source_device_cd = temp_add_images->qual[d.seq].source_device_cd, br.chartable_note_id =
    temp_add_images->qual[d.seq].chartable_note_id, br.non_chartable_note_id = temp_add_images->qual[
    d.seq].non_chartable_note_id,
    br.publish_flag = temp_add_images->qual[d.seq].publish_flag, br.blob_foreign_ident =
    temp_add_images->qual[d.seq].blob_foreign_ident, br.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    br.updt_id = reqinfo->updt_id, br.updt_task = reqinfo->updt_task, br.updt_cnt = 0,
    br.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (br)
   WITH nocounter
  ;end insert
  IF (curqual != tempaddimagescnt)
   GO TO image_failed
  ELSE
   IF (input_rec_cnt > 0)
    EXECUTE aps_chg_folder_entity_loc
    IF ((chg_loc_reply->status_data.status != "S"))
     GO TO chg_loc_failed
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF (tempaddimagescnt > 0)
  INSERT  FROM blob_summary_ref bsr,
    (dummyt d  WITH seq = value(tempaddimagescnt))
   SET bsr.blob_ref_id = temp_add_images->qual[d.seq].blob_ref_id, bsr.compression_cd = 0, bsr
    .long_blob_id = temp_add_images->qual[d.seq].tbnl_long_blob_id,
    bsr.format_cd = temp_add_images->qual[d.seq].tbnl_format_cd, bsr.updt_dt_tm = cnvtdatetime(
     curdate,curtime3), bsr.updt_id = reqinfo->updt_id,
    bsr.updt_task = reqinfo->updt_task, bsr.updt_cnt = 0, bsr.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (temp_add_images->qual[d.seq].storage_cd != pcsdocimg_storage_cd))
    JOIN (bsr)
   WITH nocounter
  ;end insert
  IF ((curqual != (tempaddimagescnt - lnbrdocimagesadd)))
   GO TO insert_tbnl_failed
  ENDIF
 ENDIF
 FOR (x = 1 TO 100)
   SET updt_cnts_array[x] = 0
 ENDFOR
 IF ((request->initiated_by_err_correct_ind=0))
  SELECT INTO "nl:"
   pc.case_id
   FROM pathology_case pc
   WHERE (pc.case_id=request->case_id)
   DETAIL
    updt_cnts_array[1] = pc.updt_cnt
   WITH nocounter, forupdate(pc)
  ;end select
  IF (curqual=0)
   GO TO lock_case_failed
  ENDIF
  IF ((request->case_updt_cnt != updt_cnts_array[1]))
   GO TO lock_case_failed
  ENDIF
 ENDIF
 FOR (x = 1 TO 100)
   SET updt_cnts_array[x] = 0
 ENDFOR
 IF (tempchgreportscnt > 0)
  SELECT INTO "nl:"
   cr.report_id
   FROM case_report cr,
    (dummyt d  WITH seq = value(tempchgreportscnt))
   PLAN (d)
    JOIN (cr
    WHERE (cr.report_id=temp_chg_reports->qual[d.seq].report_id))
   HEAD REPORT
    nbr_items = 0
   DETAIL
    nbr_items = (nbr_items+ 1), updt_cnts_array[nbr_items] = cr.updt_cnt
   WITH nocounter, forupdate(cr)
  ;end select
  IF (nbr_items != tempchgreportscnt)
   GO TO lock_report_failed
  ENDIF
  FOR (nbr_items = 1 TO tempchgreportscnt)
    IF ((temp_chg_reports->qual[nbr_items].updt_cnt != updt_cnts_array[nbr_items]))
     GO TO lock_report_failed
    ENDIF
  ENDFOR
 ENDIF
 FOR (x = 1 TO 100)
   SET updt_cnts_array[x] = 0
 ENDFOR
 IF (tempchgimagescnt > 0)
  SELECT INTO "nl:"
   br.blob_ref_id
   FROM blob_reference br,
    (dummyt d  WITH seq = value(tempchgimagescnt))
   PLAN (d)
    JOIN (br
    WHERE (br.blob_ref_id=temp_chg_images->qual[d.seq].blob_ref_id))
   HEAD REPORT
    nbr_items = 0
   DETAIL
    nbr_items = (nbr_items+ 1), updt_cnts_array[nbr_items] = br.updt_cnt
   WITH nocounter, forupdate(br)
  ;end select
  IF (nbr_items != tempchgimagescnt)
   GO TO lock_image_failed
  ENDIF
  FOR (nbr_items = 1 TO tempchgimagescnt)
    IF ((temp_chg_images->qual[nbr_items].updt_cnt != updt_cnts_array[nbr_items]))
     GO TO lock_image_failed2
    ENDIF
  ENDFOR
 ENDIF
 FOR (x = 1 TO 100)
   SET updt_cnts_array[x] = 0
 ENDFOR
 IF (tempchgcommentcnt > 0)
  SELECT INTO "nl:"
   lt.long_text_id
   FROM long_text lt,
    (dummyt d  WITH seq = value(tempchgcommentcnt))
   PLAN (d)
    JOIN (lt
    WHERE (lt.long_text_id=temp_chg_comment->qual[d.seq].comment_id))
   HEAD REPORT
    nbr_items = 0
   DETAIL
    nbr_items = (nbr_items+ 1), updt_cnts_array[nbr_items] = lt.updt_cnt
   WITH nocounter, forupdate(lt)
  ;end select
  IF (nbr_items != tempchgcommentcnt)
   GO TO lock_comment_failed
  ENDIF
  FOR (nbr_items = 1 TO tempchgcommentcnt)
    IF ((temp_chg_comment->qual[nbr_items].updt_cnt != updt_cnts_array[nbr_items]))
     GO TO lock_comment_failed
    ENDIF
  ENDFOR
 ENDIF
 IF ((request->initiated_by_err_correct_ind=0))
  UPDATE  FROM pathology_case pc
   SET pc.case_id = request->case_id, pc.blob_bitmap = request->case_blob_bitmap, pc.dataset_uid =
    request->case_dataset_uid,
    pc.updt_dt_tm = cnvtdatetime(curdate,curtime3), pc.updt_id = reqinfo->updt_id, pc.updt_task =
    reqinfo->updt_task,
    pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = (pc.updt_cnt+ 1)
   WHERE (pc.case_id=request->case_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   GO TO case_failed
  ENDIF
  SET reply_addl->case_updt_cnt = (request->case_updt_cnt+ 1)
 ENDIF
 IF (tempchgreportscnt > 0)
  UPDATE  FROM case_report cr,
    (dummyt d  WITH seq = value(tempchgreportscnt))
   SET cr.report_id = temp_chg_reports->qual[d.seq].report_id, cr.blob_bitmap = temp_chg_reports->
    qual[d.seq].blob_bitmap, cr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    cr.updt_id = reqinfo->updt_id, cr.updt_task = reqinfo->updt_task, cr.updt_applctx = reqinfo->
    updt_applctx,
    cr.updt_cnt = (cr.updt_cnt+ 1)
   PLAN (d)
    JOIN (cr
    WHERE (cr.report_id=temp_chg_reports->qual[d.seq].report_id))
   WITH nocounter
  ;end update
  IF (curqual != tempchgreportscnt)
   GO TO report_failed
  ENDIF
 ENDIF
 IF (tempchgimagescnt > 0)
  CALL get_migrated_handles(temp_chg_images)
  UPDATE  FROM blob_reference br,
    (dummyt d  WITH seq = value(tempchgimagescnt))
   SET br.parent_entity_name = temp_chg_images->qual[d.seq].parent_entity_name, br.parent_entity_id
     = temp_chg_images->qual[d.seq].parent_entity_id, br.sequence_nbr = temp_chg_images->qual[d.seq].
    sequence_nbr,
    br.owner_cd = temp_chg_images->qual[d.seq].owner_cd, br.storage_cd = temp_chg_images->qual[d.seq]
    .storage_cd, br.format_cd = temp_chg_images->qual[d.seq].format_cd,
    br.blob_handle = temp_chg_images->qual[d.seq].blob_handle, br.create_prsnl_id = temp_chg_images->
    qual[d.seq].create_prsnl_id, br.blob_title = temp_chg_images->qual[d.seq].blob_title,
    br.source_device_cd = temp_chg_images->qual[d.seq].source_device_cd, br.chartable_note_id =
    temp_chg_images->qual[d.seq].chartable_note_id, br.non_chartable_note_id = temp_chg_images->qual[
    d.seq].non_chartable_note_id,
    br.publish_flag = temp_chg_images->qual[d.seq].publish_flag, br.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), br.updt_id = reqinfo->updt_id,
    br.updt_task = reqinfo->updt_task, br.updt_applctx = reqinfo->updt_applctx, br.updt_cnt = (br
    .updt_cnt+ 1)
   PLAN (d)
    JOIN (br
    WHERE (br.blob_ref_id=temp_chg_images->qual[d.seq].blob_ref_id))
   WITH nocounter
  ;end update
  IF (curqual != tempchgimagescnt)
   GO TO image_failed
  ENDIF
 ENDIF
 IF (tempchgcommentcnt > 0)
  UPDATE  FROM long_text lt,
    (dummyt d  WITH seq = value(tempchgcommentcnt))
   SET lt.long_text = temp_chg_comment->qual[d.seq].comment, lt.parent_entity_id = temp_chg_comment->
    qual[d.seq].blob_ref_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
    updt_applctx,
    lt.updt_cnt = (lt.updt_cnt+ 1)
   PLAN (d)
    JOIN (lt
    WHERE (lt.long_text_id=temp_chg_comment->qual[d.seq].comment_id))
   WITH nocounter
  ;end update
  IF (curqual != tempchgcommentcnt)
   GO TO comment_failed
  ENDIF
 ENDIF
 IF (tempchgpvwdatasetcnt > 0)
  SELECT INTO "nl:"
   pd.dataset_uid
   FROM pvw_dataset pd,
    (dummyt d  WITH seq = value(tempchgpvwdatasetcnt))
   PLAN (d)
    JOIN (pd
    WHERE (pd.dataset_uid=temp_chg_pvw_dataset->qual[d.seq].dataset_uid))
   HEAD REPORT
    nbr_items = 0
   DETAIL
    nbr_items = (nbr_items+ 1)
   WITH nocounter, forupdate(pd)
  ;end select
  IF (nbr_items != tempchgpvwdatasetcnt)
   GO TO lock_pvw_failed
  ENDIF
  UPDATE  FROM pvw_dataset pd,
    (dummyt d  WITH seq = value(tempchgpvwdatasetcnt))
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
  IF (curqual != tempchgpvwdatasetcnt)
   GO TO pvw_dataset_failed
  ENDIF
 ENDIF
 GO TO exit_script
 SUBROUTINE copy_addl_to_reply(dummyvar)
   SET reply->case_updt_cnt = reply_addl->case_updt_cnt
   SET nbr_reports = cnvtint(size(reply_addl->report_qual,5))
   SET stat = alterlist(reply->report_qual,nbr_reports)
   FOR (lr = 1 TO nbr_reports)
     SET reply->report_qual[lr].report_index = reply_addl->report_qual[lr].report_index
     SET reply->report_qual[lr].report_id = reply_addl->report_qual[lr].report_id
     SET reply->report_qual[lr].report_updt_cnt = reply_addl->report_qual[lr].report_updt_cnt
     SET reply->report_qual[lr].status_cd = reply_addl->report_qual[lr].status_cd
     SET reply->report_qual[lr].status_disp = reply_addl->report_qual[lr].status_disp
     SET reply->report_qual[lr].skip_ind = reply_addl->report_qual[lr].skip_ind
     SET reply->report_qual[lr].updt_id = reply_addl->report_qual[lr].updt_id
     SET reply->report_qual[lr].updt_name_full_formatted = reply_addl->report_qual[lr].
     updt_name_full_formatted
     SET nbr_images = cnvtint(size(reply_addl->report_qual[lr].image_qual,5))
     SET stat = alterlist(reply->report_qual[lr].image_qual,nbr_images)
     FOR (li = 1 TO nbr_images)
       SET reply->report_qual[lr].image_qual[li].image_index = reply_addl->report_qual[lr].
       image_qual[li].image_index
       SET reply->report_qual[lr].image_qual[li].blob_ref_id = reply_addl->report_qual[lr].
       image_qual[li].blob_ref_id
       SET reply->report_qual[lr].image_qual[li].tbnl_long_blob_id = reply_addl->report_qual[lr].
       image_qual[li].tbnl_long_blob_id
       SET reply->report_qual[lr].image_qual[li].chartable_note_id = reply_addl->report_qual[lr].
       image_qual[li].chartable_note_id
       SET reply->report_qual[lr].image_qual[li].chartable_note_updt_cnt = reply_addl->report_qual[lr
       ].image_qual[li].chartable_note_updt_cnt
       SET reply->report_qual[lr].image_qual[li].non_chartable_note_id = reply_addl->report_qual[lr].
       image_qual[li].non_chartable_note_id
       SET reply->report_qual[lr].image_qual[li].non_chartable_note_updt_cnt = reply_addl->
       report_qual[lr].image_qual[li].non_chartable_note_updt_cnt
       SET reply->report_qual[lr].image_qual[li].image_updt_cnt = reply_addl->report_qual[lr].
       image_qual[li].image_updt_cnt
     ENDFOR
     SET nbr_sections = cnvtint(size(reply_addl->report_qual[lr].section_qual,5))
     SET stat = alterlist(reply->report_qual[lr].section_qual,nbr_sections)
     FOR (ls = 1 TO nbr_sections)
       SET reply->report_qual[lr].section_qual[ls].section_index = reply_addl->report_qual[lr].
       section_qual[ls].section_index
       SET reply->report_qual[lr].section_qual[ls].report_detail_id = reply_addl->report_qual[lr].
       section_qual[ls].report_detail_id
       SET reply->report_qual[lr].section_qual[ls].section_updt_cnt = reply_addl->report_qual[lr].
       section_qual[ls].section_updt_cnt
       SET nbr_images = cnvtint(size(reply_addl->report_qual[lr].section_qual[ls].image_qual,5))
       SET stat = alterlist(reply->report_qual[lr].section_qual[ls].image_qual,nbr_images)
       FOR (li = 1 TO nbr_images)
         SET reply->report_qual[lr].section_qual[ls].image_qual[li].image_index = reply_addl->
         report_qual[lr].section_qual[ls].image_qual[li].image_index
         SET reply->report_qual[lr].section_qual[ls].image_qual[li].blob_ref_id = reply_addl->
         report_qual[lr].section_qual[ls].image_qual[li].blob_ref_id
         SET reply->report_qual[lr].section_qual[ls].image_qual[li].tbnl_long_blob_id = reply_addl->
         report_qual[lr].section_qual[ls].image_qual[li].tbnl_long_blob_id
         SET reply->report_qual[lr].section_qual[ls].image_qual[li].chartable_note_id = reply_addl->
         report_qual[lr].section_qual[ls].image_qual[li].chartable_note_id
         SET reply->report_qual[lr].section_qual[ls].image_qual[li].chartable_note_updt_cnt =
         reply_addl->report_qual[lr].section_qual[ls].image_qual[li].chartable_note_updt_cnt
         SET reply->report_qual[lr].section_qual[ls].image_qual[li].non_chartable_note_id =
         reply_addl->report_qual[lr].section_qual[ls].image_qual[li].non_chartable_note_id
         SET reply->report_qual[lr].section_qual[ls].image_qual[li].non_chartable_note_updt_cnt =
         reply_addl->report_qual[lr].section_qual[ls].image_qual[li].non_chartable_note_updt_cnt
         SET reply->report_qual[lr].section_qual[ls].image_qual[li].image_updt_cnt = reply_addl->
         report_qual[lr].section_qual[ls].image_qual[li].image_updt_cnt
       ENDFOR
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE get_migrated_handles(handle_input)
   DECLARE lidxin = i4 WITH protect, noconstant(0)
   DECLARE lidxout = i4 WITH protect, noconstant(0)
   DECLARE linputcnt = i4 WITH protect, noconstant(0)
   DECLARE loutputcnt = i4 WITH protect, noconstant(0)
   RECORD reply_200436(
     1 qual[*]
       2 old_handle = vc
       2 old_storage_cd = f8
       2 new_handle = vc
       2 new_storage_cd = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   EXECUTE aps_get_current_image_handle  WITH replace("REQUEST","HANDLE_INPUT"), replace("REPLY",
    "REPLY_200436")
   SET linputcnt = cnvtint(size(handle_input->qual,5))
   SET loutputcnt = cnvtint(size(reply_200436->qual,5))
   FOR (lidxout = 1 TO loutputcnt)
    SET lidxin = locateval(lidxin,1,linputcnt,reply_200436->qual[lidxout].old_handle,handle_input->
     qual[lidxin].blob_handle)
    IF (lidxin > 0)
     SET handle_input->qual[lidxin].blob_handle = reply_200436->qual[lidxout].new_handle
     SET handle_input->qual[lidxin].storage_cd = reply_200436->qual[lidxout].new_storage_cd
    ENDIF
   ENDFOR
 END ;Subroutine
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
#chg_loc_failed
 SET reply->status_data.subeventstatus[1].operationname = chg_loc_reply->status_data.subeventstatus[1
 ].operationname
 SET reply->status_data.subeventstatus[1].operationstatus = chg_loc_reply->status_data.
 subeventstatus[1].operationstatus
 SET reply->status_data.subeventstatus[1].targetobjectname = chg_loc_reply->status_data.
 subeventstatus[1].targetobjectname
 SET reply->status_data.subeventstatus[1].targetobjectvalue = chg_loc_reply->status_data.
 subeventstatus[1].targetobjectvalue
 SET failed = "T"
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
#case_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
 SET failed = "T"
 GO TO exit_script
#report_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_REPORT"
 SET failed = "T"
 GO TO exit_script
#section_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "REPORT_DETAIL_IMAGE"
 SET failed = "T"
 GO TO exit_script
#image_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "BLOB_REFERENCE"
 SET failed = "T"
 GO TO exit_script
#comment_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#tbnl_images_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_BLOB"
 SET failed = "T"
 GO TO exit_script
#add_tbnl_images_failed
 SET reply->status_data.subeventstatus[1].operationname = "ADD"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_BLOB"
 SET failed = "T"
 GO TO exit_script
#lock_pvw_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PVW_DATASET"
 SET failed = "T"
 GO TO exit_script
#lock_case_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
 SET failed = "T"
 GO TO exit_script
#lock_report_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_REPORT"
 SET failed = "T"
 GO TO exit_script
#lock_sections_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "REPORT_DETAIL_IMAGE"
 SET failed = "T"
 GO TO exit_script
#lock_comment_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#lock_image_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "BLOB_REFERENCE"
 SET failed = "T"
 GO TO exit_script
#lock_image_failed2
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "BLOB_REFERENCE2"
 SET failed = "T"
 GO TO exit_script
#report_status_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CASE_REPORT"
 SET reply->status_data.subeventstatus[1].targetobjectvalue =
 "Unable to locate report to check its status."
 SET failed = "T"
 GO TO exit_script
#invalid_report_status
 SET reply->status_data.subeventstatus[1].operationname = "VALIDATE STATUS"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CASE_REPORT"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid Report Status"
 SET failed = "T"
 GO TO exit_script
#insert_tbnl_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "BLOB_SUMMARY_REF"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error inserting thumbnail"
 SET failed = "T"
 GO TO exit_script
#del_tbnl_images_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "BLOB_SUMMARY_REF"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error deleting thumbnail"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF ((request->initiated_by_err_correct_ind=0))
  CALL copy_addl_to_reply(0)
 ENDIF
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echo(build("Leaving aps_add_departmental_images.prg with status of: ",reply->status_data.status
   ))
END GO
