CREATE PROGRAM dms_content_type_readme:dba
 CALL echo("<==================== Entering DMS_CONTENT_TYPE_README Script ====================>")
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
 SET readme_data->message = "Readme Failed:  Starting import of DMS Content Type data"
 DECLARE listsize = i4 WITH constant(size(requestin->list_0,5))
 DECLARE errcode = i4 WITH noconstant(0)
 DECLARE errmsg = vc WITH noconstant("DMS Script Failure")
 DECLARE repositoryid = f8 WITH noconstant(0.0)
 FREE SET contenttypeid
 DECLARE contenttypeid = f8 WITH noconstant(0.0)
 EXECUTE mmf_add_mill_repository_rdm
 FOR (i = 1 TO listsize)
   SET contenttypeid = 0
   SELECT INTO "nl:"
    dct.dms_content_type_id, dct.content_type_key
    FROM dms_content_type dct
    WHERE dct.content_type_key=cnvtupper(requestin->list_0[i].content_type_key)
    DETAIL
     contenttypeid = dct.dms_content_type_id
    WITH nocounter
   ;end select
   IF (contenttypeid <= 0.0)
    SELECT INTO "nl:"
     nextseqnum = seq(dms_seq,nextval)
     FROM dual
     DETAIL
      contenttypeid = nextseqnum
     WITH nocounter
    ;end select
    SET repositoryid = 0
    IF (trim(requestin->list_0[i].repository) != "")
     SELECT INTO "nl:"
      FROM dms_repository dr
      WHERE dr.repository_name=trim(requestin->list_0[i].repository)
      DETAIL
       repositoryid = dr.dms_repository_id
      WITH nocounter
     ;end select
    ENDIF
    INSERT  FROM dms_content_type dct
     SET dct.dms_content_type_id = contenttypeid, dct.content_type_key = cnvtupper(requestin->list_0[
       i].content_type_key), dct.display = requestin->list_0[i].display,
      dct.description = requestin->list_0[i].description, dct.max_versions = cnvtint(requestin->
       list_0[i].max_versions), dct.expiration_duration = cnvtint(requestin->list_0[i].
       expiration_duration),
      dct.updt_dt_tm = cnvtdatetime(sysdate), dct.updt_id = reqinfo->updt_id, dct.updt_task = reqinfo
      ->updt_task,
      dct.updt_cnt = 0, dct.updt_applctx = reqinfo->updt_applctx, dct.audit_name = requestin->list_0[
      i].audit_name,
      dct.signature_req_ind = cnvtint(requestin->list_0[i].signature_req_ind), dct.ownership_ind =
      cnvtint(requestin->list_0[i].ownership_ind), dct.cerner_ind = cnvtint(requestin->list_0[i].
       cernerrestricted),
      dct.active_ind = cnvtint(requestin->list_0[i].active_ind), dct.audit_ind = cnvtint(requestin->
       list_0[i].audit_ind), dct.access_flag = cnvtint(requestin->list_0[i].access_flag),
      dct.dms_repository_id = repositoryid, dct.content_group_name = requestin->list_0[i].
      content_group_name
     WITH nocounter
    ;end insert
    SET errcode = error(errmsg,0)
    IF (errcode > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Readme Failed:       Insert into DMS_CONTENT_TYPE: ",errmsg)
     GO TO end_script
    ELSE
     COMMIT
    ENDIF
    SET errcode = error(errmsg,0)
    IF (errcode > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Readme Failed:       Update into DMS_CONTENT_TYPE: ",errmsg)
     GO TO end_script
    ELSE
     COMMIT
     EXECUTE mmf_updt_content_type_rdm
     COMMIT
    ENDIF
   ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = "DMS Content Type data successfully imported"
#end_script
 CALL echo("<==================== Exiting DMS_CONTENT_TYPE_README Script ====================>")
END GO
