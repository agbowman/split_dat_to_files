CREATE PROGRAM clip_rdm_upd_ext_data:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed:  Starting script clip_rdm_upd_ext_data"
 FREE RECORD extdatainfo
 RECORD extdatainfo(
   1 submissions[*]
     2 ext_data_group_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 data_source_cd = f8
     2 data_status_cd = f8
     2 source_reference_id = f8
     2 source_reference_name = vc
     2 submitted_dt_tm = dq8
     2 ext_data_ids[*]
       3 ext_data_id = f8
   1 long_text_data[*]
     2 ext_data_clob_id = f8
     2 ext_data_id = f8
     2 long_text_id = f8
 )
 FREE RECORD m_dm2_seq_stat
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 )
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE nstop = i4 WITH noconstant(0)
 DECLARE err_code = i4 WITH protect, noconstant(0)
 DECLARE err_msg = vc WITH protect, noconstant("")
 DECLARE findextdatawithnogroup() = null
 DECLARE createextdatagroup() = null
 DECLARE findextdataonlongtext() = null
 DECLARE createextdataclob() = null
 DECLARE ext_data_group_id = f8 WITH public, noconstant(0.0)
 DECLARE contrib_cd = f8 WITH public, noconstant(0.0)
 CALL findextdatawithnogroup(null)
 CALL findextdataonlongtext(null)
 IF (size(extdatainfo->long_text_data,5) <= 0
  AND size(extdatainfo->submissions,5) <= 0)
  SET readme_data->message = concat("clip_rdm_upd_ext_data -  No external data found to update: ",
   err_msg)
  SET readme_data->status = "S"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4142002
   AND cv.cdf_meaning="HEALTHELIFE"
   AND cv.active_ind=1
  DETAIL
   contrib_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(err_msg,0) > 0)
  CALL echo("Readme Failed: Could not select the code_value rows")
  SET readme_data->message = concat("Failed to select from code_value table : ",err_msg)
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 IF (contrib_cd < 1)
  SET readme_data->status = "S"
  SET readme_data->message = "Cannot find the code_value for HEALTHELIFE from code_set 4142002 "
  GO TO exit_script
 ENDIF
 IF (size(extdatainfo->submissions,5) > 0)
  CALL createextdatagroup(null)
 ENDIF
 IF (size(extdatainfo->long_text_data,5) > 0)
  CALL createextdataclob(null)
 ENDIF
 SUBROUTINE findextdatawithnogroup(dummyvar)
  SELECT INTO "nl:"
   FROM ext_data_info edi
   PLAN (edi
    WHERE edi.ext_data_group_id=0.0)
   ORDER BY edi.source_reference_id
   HEAD REPORT
    submission_cnt = 0, ext_data_cnt = 0
   HEAD edi.source_reference_id
    ext_data_cnt = 0, submission_cnt = (submission_cnt+ 1)
    IF (mod(submission_cnt,50)=1)
     status = alterlist(extdatainfo->submissions,(submission_cnt+ 49))
    ENDIF
    extdatainfo->submissions[submission_cnt].person_id = edi.person_id, extdatainfo->submissions[
    submission_cnt].encntr_id = edi.encntr_id, extdatainfo->submissions[submission_cnt].
    data_status_cd = edi.data_status_cd,
    extdatainfo->submissions[submission_cnt].data_source_cd = edi.data_source_cd, extdatainfo->
    submissions[submission_cnt].source_reference_name = edi.source_reference_name, extdatainfo->
    submissions[submission_cnt].source_reference_id = edi.source_reference_id,
    extdatainfo->submissions[submission_cnt].submitted_dt_tm = edi.requested_action_dt_tm
   DETAIL
    ext_data_cnt = (ext_data_cnt+ 1)
    IF (mod(ext_data_cnt,50)=1)
     status = alterlist(extdatainfo->submissions[submission_cnt].ext_data_ids,(ext_data_cnt+ 49))
    ENDIF
    extdatainfo->submissions[submission_cnt].ext_data_ids[ext_data_cnt].ext_data_id = edi
    .ext_data_info_id
   FOOT  edi.source_reference_id
    status = alterlist(extdatainfo->submissions[submission_cnt].ext_data_ids,ext_data_cnt)
   FOOT REPORT
    status = alterlist(extdatainfo->submissions,submission_cnt)
   WITH nocounter
  ;end select
  IF (error(err_msg,0) > 0)
   CALL echo("Readme Failed: Could not select the ext_data_info rows")
   SET readme_data->message = concat(
    "ext_data_info - Failed to select from ext_data_info table rows: ",err_msg)
   SET readme_data->status = "F"
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE createextdatagroup(dummyvar)
   SET nstop = size(extdatainfo->submissions,5)
   EXECUTE dm2_dar_get_bulk_seq "ExtDataInfo->submissions", nstop, "ext_data_group_id",
   nstart, "SI_REGISTRY_SEQ"
   IF ((m_dm2_seq_stat->n_status != 1))
    SET readme_data->status = "F"
    SET readme_data->message = concat("ext_data_group_id sequence could not be generated: ",err_msg)
    GO TO exit_script
   ENDIF
   CALL echo("Insert to ext_data_group table")
   INSERT  FROM ext_data_group edg,
     (dummyt d  WITH seq = value(size(extdatainfo->submissions,5)))
    SET edg.ext_data_group_id = extdatainfo->submissions[d.seq].ext_data_group_id, edg.person_id =
     extdatainfo->submissions[d.seq].person_id, edg.submitted_encntr_id = extdatainfo->submissions[d
     .seq].encntr_id,
     edg.data_group_source_cd = extdatainfo->submissions[d.seq].data_source_cd, edg
     .data_group_status_cd = extdatainfo->submissions[d.seq].data_status_cd, edg.source_reference_id
      = extdatainfo->submissions[d.seq].source_reference_id,
     edg.source_reference_name = extdatainfo->submissions[d.seq].source_reference_name, edg
     .submitted_dt_tm = cnvtdatetime(extdatainfo->submissions[d.seq].submitted_dt_tm), edg
     .data_contrib_cd = contrib_cd,
     edg.updt_dt_tm = cnvtdatetime(curdate,curtime3), edg.updt_id = reqinfo->updt_id, edg.updt_task
      = reqinfo->updt_task,
     edg.updt_applctx = reqinfo->updt_applctx, edg.updt_cnt = 0
    PLAN (d)
     JOIN (edg)
   ;end insert
   IF (error(err_msg,0) > 0)
    ROLLBACK
    CALL echo("Readme Failed: Could not insert the ext_data_group rows")
    SET readme_data->message = concat("ext_data_group - Failed to insert ext_data_group table rows: ",
     err_msg)
    SET readme_data->status = "F"
    GO TO exit_script
   ENDIF
   CALL echo("update ext_data_info rows")
   UPDATE  FROM ext_data_info edi,
     (dummyt d1  WITH seq = value(size(extdatainfo->submissions,5))),
     (dummyt d2  WITH seq = 1)
    SET edi.ext_data_group_id = extdatainfo->submissions[d1.seq].ext_data_group_id, edi.updt_dt_tm =
     cnvtdatetime(curdate,curtime3), edi.updt_id = reqinfo->updt_id,
     edi.updt_task = reqinfo->updt_task, edi.updt_applctx = reqinfo->updt_applctx, edi.updt_cnt = (
     edi.updt_cnt+ 1)
    PLAN (d1
     WHERE d1.seq > 0
      AND maxrec(d2,size(extdatainfo->submissions[d1.seq].ext_data_ids,5)))
     JOIN (d2
     WHERE d2.seq > 0)
     JOIN (edi
     WHERE (edi.ext_data_info_id=extdatainfo->submissions[d1.seq].ext_data_ids[d2.seq].ext_data_id))
    WITH nocounter
   ;end update
   IF (error(err_msg,0) > 0)
    ROLLBACK
    CALL echo("Readme Failed: Could not update the ext_data_info rows")
    SET readme_data->message = concat(
     "ext_data_info - Failed to update ext_data_group_id on ext_data_info table rows: ",err_msg)
    SET readme_data->status = "F"
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE findextdataonlongtext(dummyvar)
  SELECT INTO "nl:"
   FROM ext_data_info edi,
    long_text lt
   PLAN (edi
    WHERE edi.long_text_id > 0.0)
    JOIN (lt
    WHERE edi.long_text_id=lt.long_text_id
     AND edi.ext_data_clob_id=0)
   HEAD REPORT
    ext_data_cnt = 0
   DETAIL
    ext_data_cnt = (ext_data_cnt+ 1)
    IF (mod(ext_data_cnt,50)=1)
     status = alterlist(extdatainfo->long_text_data,(ext_data_cnt+ 49))
    ENDIF
    extdatainfo->long_text_data[ext_data_cnt].ext_data_id = edi.ext_data_info_id, extdatainfo->
    long_text_data[ext_data_cnt].long_text_id = edi.long_text_id
   FOOT REPORT
    status = alterlist(extdatainfo->long_text_data,ext_data_cnt)
   WITH nocounter
  ;end select
  IF (error(err_msg,0) > 0)
   CALL echo("Readme Failed: Could not select the ext_data_info and long_text rows")
   SET readme_data->message = concat(
    "ext_data_info - Failed to select from the ext_data_info or long_text table rows: ",err_msg)
   SET readme_data->status = "F"
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE createextdataclob(dummyvar)
   CALL echo("Get new sequence IDs")
   SET nstop = size(extdatainfo->long_text_data,5)
   EXECUTE dm2_dar_get_bulk_seq "ExtDataInfo->long_text_data", nstop, "ext_data_clob_id",
   nstart, "SI_REGISTRY_SEQ"
   IF ((m_dm2_seq_stat->n_status != 1))
    SET readme_data->status = "F"
    SET readme_data->message = concat("ext_data_group_id sequence could not be generated: ",err_msg)
    GO TO exit_script
   ENDIF
   CALL echo("Insert to ext_data_clob table")
   INSERT  FROM ext_data_clob edc,
     (dummyt d  WITH seq = value(size(extdatainfo->long_text_data,5)))
    SET edc.ext_data_clob_id = extdatainfo->long_text_data[d.seq].ext_data_clob_id, edc.data_clob =
     (SELECT
      long_text
      FROM long_text
      WHERE (long_text_id=extdatainfo->long_text_data[d.seq].long_text_id)), edc.clob_type_txt =
     "JSON",
     edc.updt_dt_tm = cnvtdatetime(curdate,curtime3), edc.updt_id = reqinfo->updt_id, edc.updt_task
      = reqinfo->updt_task,
     edc.updt_applctx = reqinfo->updt_applctx, edc.updt_cnt = 0
    PLAN (d)
     JOIN (edc)
   ;end insert
   IF (error(err_msg,0) > 0)
    ROLLBACK
    CALL echo("Readme Failed: Could not insert the ext_data_clob rows")
    SET readme_data->message = concat("ext_data_clob - Failed to insert ext_data_clob table rows: ",
     err_msg)
    SET readme_data->status = "F"
    GO TO exit_script
   ENDIF
   CALL echo("update ext_data_info rows")
   UPDATE  FROM ext_data_info edi,
     (dummyt d1  WITH seq = value(size(extdatainfo->long_text_data,5)))
    SET edi.ext_data_clob_id = extdatainfo->long_text_data[d1.seq].ext_data_clob_id, edi.updt_dt_tm
      = cnvtdatetime(curdate,curtime3), edi.updt_id = reqinfo->updt_id,
     edi.updt_task = reqinfo->updt_task, edi.updt_applctx = reqinfo->updt_applctx, edi.updt_cnt = (
     edi.updt_cnt+ 1)
    PLAN (d1
     WHERE d1.seq > 0)
     JOIN (edi
     WHERE (edi.ext_data_info_id=extdatainfo->long_text_data[d1.seq].ext_data_id))
    WITH nocounter
   ;end update
   IF (error(err_msg,0) > 0)
    ROLLBACK
    CALL echo("Readme Failed: Could not update the ext_data_info rows")
    SET readme_data->message = concat(
     "ext_data_info - Failed to update ext_data_clob_id on ext_data_info table rows: ",err_msg)
    SET readme_data->status = "F"
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(extdatainfo)
 FREE RECORD extdatainfo
 FREE RECORD m_dm2_seq_stat
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
