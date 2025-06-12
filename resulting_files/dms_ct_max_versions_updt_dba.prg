CREATE PROGRAM dms_ct_max_versions_updt:dba
 CALL echo("<==================== Entering DMS_CT_MAX_VERSIONS_UPDT Script ====================>")
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
 SET readme_data->status = "Z"
 SET readme_data->message = "Starting update of content types' max_versions"
 DECLARE listsize = i4 WITH constant(size(requestin->list_0,5))
 FOR (i = 1 TO listsize)
   FREE SET contenttypeid
   DECLARE contenttypeid = f8 WITH noconstant(0.0)
   FREE SET maxversions
   DECLARE maxversions = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    dct.dms_content_type_id, dct.content_type_key
    FROM dms_content_type dct
    WHERE dct.content_type_key=cnvtupper(requestin->list_0[i].content_type_key)
    DETAIL
     contenttypeid = dct.dms_content_type_id, maxversions = dct.max_versions
    WITH nocounter
   ;end select
   IF (contenttypeid > 0.0
    AND maxversions=0
    AND cnvtint(requestin->list_0[i].max_versions) != 0)
    SELECT INTO "nl:"
     dct.*
     FROM dms_content_type dct
     WHERE dct.dms_content_type_id=contenttypeid
     WITH forupdate(dct)
    ;end select
    IF (curqual <= 0)
     SET readme_data->status = "F"
     SET readme_data->message = "Update lock on DMS_CONTENT_TYPE failed"
    ENDIF
    UPDATE  FROM dms_content_type dct
     SET dct.max_versions = cnvtint(requestin->list_0[i].max_versions), dct.updt_dt_tm = cnvtdatetime
      (sysdate), dct.updt_id = reqinfo->updt_id,
      dct.updt_task = reqinfo->updt_task, dct.updt_cnt = (dct.updt_cnt+ 1), dct.updt_applctx =
      reqinfo->updt_applctx
     WHERE dct.dms_content_type_id=contenttypeid
     WITH nocounter
    ;end update
    IF (curqual <= 0)
     SET readme_data->status = "F"
     SET readme_data->message = "Update into DMS_CONTENT_TYPE failed"
    ENDIF
   ENDIF
 ENDFOR
 COMMIT
#end_script
 IF ((readme_data->status="Z"))
  SET readme_data->status = "S"
  SET readme_data->message = "Content types' max_versions successfully updated"
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 CALL echo("<==================== Exiting DMS_CT_MAX_VERSIONS_UPDT Script ====================>")
END GO
