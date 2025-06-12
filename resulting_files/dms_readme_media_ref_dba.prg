CREATE PROGRAM dms_readme_media_ref:dba
 CALL echo("<==================== Entering DMS_README_MEDIA_REF Script ====================>")
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
 CALL echorecord(requestin)
 SET readme_data->status = "F"
 SET readme_data->message = "Starting import of DMS Media Metadata"
 DECLARE listsize = i4 WITH constant(size(requestin->list_0,5))
 DECLARE errmsg = vc WITH protect
 FOR (i = 1 TO listsize)
   FREE SET contenttypeid
   FREE SET mediarefid
   FREE SET longtextid
   DECLARE contenttypeid = f8 WITH noconstant(0.0)
   DECLARE mediarefid = f8 WITH noconstant(0.0)
   DECLARE longtextid = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    dct.dms_content_type_id, dct.content_type_key
    FROM dms_content_type dct
    WHERE dct.content_type_key=cnvtupper(requestin->list_0[i].contenttype)
    DETAIL
     contenttypeid = dct.dms_content_type_id
    WITH nocounter
   ;end select
   IF (contenttypeid > 0.0)
    SELECT INTO "nl:"
     dmmr.dms_content_type_id, dmmr.dms_media_metadata_ref_id, dmmr.long_text_id,
     dmmr.version
     FROM dms_media_metadata_ref dmmr
     WHERE dmmr.dms_content_type_id=contenttypeid
      AND dmmr.version=cnvtint(requestin->list_0[i].version)
     DETAIL
      longtextid = dmmr.long_text_id, mediarefid = dmmr.dms_media_metadata_ref_id
     WITH nocounter
    ;end select
    IF (mediarefid <= 0.0)
     SELECT INTO "nl:"
      nextseqnum = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       longtextid = nextseqnum
      WITH nocounter
     ;end select
     INSERT  FROM long_text_reference ltr
      SET ltr.long_text_id = longtextid, ltr.long_text = requestin->list_0[i].schema, ltr
       .parent_entity_name = "DMS_MEDIA_METADATA_REF",
       ltr.parent_entity_id = mediarefid, ltr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ltr
       .updt_id = reqinfo->updt_id,
       ltr.updt_task = reqinfo->updt_task, ltr.updt_cnt = 0, ltr.updt_applctx = reqinfo->updt_applctx,
       ltr.active_ind = 1, ltr.active_status_cd = reqdata->active_status_cd, ltr.active_status_dt_tm
        = cnvtdatetime(curdate,curtime3),
       ltr.active_status_prsnl_id = reqinfo->updt_id
      WITH nocounter
     ;end insert
     IF (((curqual <= 0) OR (error(errmsg,1) != 0)) )
      SET readme_data->message = concat("Insert into LONG_TEXT_REFERENCE failed:",errmsg)
      ROLLBACK
      GO TO end_script
     ENDIF
     SELECT INTO "nl:"
      nextseqnum = seq(dms_seq,nextval)
      FROM dual
      DETAIL
       mediarefid = nextseqnum
      WITH nocounter
     ;end select
     INSERT  FROM dms_media_metadata_ref dmmr
      SET dmmr.dms_content_type_id = contenttypeid, dmmr.dms_media_metadata_ref_id = mediarefid, dmmr
       .version = cnvtint(requestin->list_0[i].version),
       dmmr.long_text_id = longtextid, dmmr.updt_dt_tm = cnvtdatetime(curdate,curtime3), dmmr.updt_id
        = reqinfo->updt_id,
       dmmr.updt_task = reqinfo->updt_task, dmmr.updt_cnt = 0, dmmr.updt_applctx = reqinfo->
       updt_applctx
      WITH nocounter
     ;end insert
     IF (((curqual <= 0) OR (error(errmsg,1) != 0)) )
      SET readme_data->message = concat("Insert into DMS_MEDIA_METADATA_REF failed:",errmsg)
      ROLLBACK
      GO TO end_script
     ENDIF
    ELSE
     UPDATE  FROM long_text_reference ltr
      SET ltr.long_text = requestin->list_0[i].schema, ltr.updt_dt_tm = cnvtdatetime(curdate,curtime3
        ), ltr.updt_id = reqinfo->updt_id,
       ltr.updt_task = reqinfo->updt_task, ltr.updt_cnt = (ltr.updt_cnt+ 1), ltr.updt_applctx =
       reqinfo->updt_applctx
      WHERE ltr.long_text_id=longtextid
      WITH nocounter
     ;end update
     IF (((curqual <= 0) OR (error(errmsg,1) != 0)) )
      SET readme_data->message = concat("Update into LONG_TEXT_REFERENCE failed:",errmsg)
      ROLLBACK
      GO TO end_script
     ENDIF
    ENDIF
   ELSE
    SET readme_data->message = "An invalid content type was given."
   ENDIF
 ENDFOR
 SET readme_data->status = "S"
 COMMIT
#end_script
 IF ((readme_data->status="S"))
  SET readme_data->message = "DMS METADATA successfully imported"
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 CALL echo("<==================== Exiting DMS_README_MEDIA_REF Script ====================>")
END GO
