CREATE PROGRAM dms_event_reason_r_readme:dba
 CALL echo("<==================== Entering DMS_EVENT_REASON_R_README Script ====================>")
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
 SET readme_data->message = "Starting import of DMS Event Reason Reference data"
 DECLARE listsize = i4 WITH constant(size(requestin->list_0,5))
 FOR (i = 1 TO listsize)
   FREE SET refid
   DECLARE refid = f8 WITH noconstant(0.0)
   FREE SET contenttypeid
   DECLARE contenttypeid = f8 WITH noconstant(0.0)
   FREE SET eventreasonid
   DECLARE eventreasonid = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    dmc.content_type_id
    FROM dms_content_type dmc
    WHERE dmc.content_type_key=cnvtupper(requestin->list_0[i].content_type_key)
    DETAIL
     contenttypeid = dmc.dms_content_type_id
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    SET readme_data->status = "F"
    SET readme_data->message = "Failed to lookup specified content type"
    GO TO end_script
   ENDIF
   SELECT INTO "nl:"
    dmr.dms_ref_id
    FROM dms_ref dmr
    WHERE dmr.ref_group="REASON"
     AND dmr.ref_key=cnvtupper(requestin->list_0[i].ref_key)
    DETAIL
     eventreasonid = dmr.dms_ref_id
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    SET readme_data->status = "F"
    SET readme_data->message = "Failed to lookup specified event reason"
    GO TO end_script
   ENDIF
   SELECT INTO "nl:"
    dme.dme_event_reason_r_id, dme.dms_content_type_id, dme.dms_reason_ref_id
    FROM dms_event_reason_r dme
    WHERE dme.dms_content_type_id=contenttypeid
     AND dme.dms_reason_ref_id=eventreasonid
    DETAIL
     refid = dme.dms_event_reason_r_id
    WITH nocounter
   ;end select
   IF (refid <= 0.0)
    SELECT INTO "nl:"
     nextseqnum = seq(dms_seq,nextval)
     FROM dual
     DETAIL
      refid = nextseqnum
     WITH nocounter
    ;end select
    INSERT  FROM dms_event_reason_r dme
     SET dme.dms_event_reason_r_id = refid, dme.dms_reason_ref_id = eventreasonid, dme
      .dms_content_type_id = contenttypeid,
      dme.updt_dt_tm = cnvtdatetime(sysdate), dme.updt_id = reqinfo->updt_id, dme.updt_task = reqinfo
      ->updt_task,
      dme.updt_cnt = 0, dme.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual <= 0)
     SET readme_data->status = "F"
     SET readme_data->message = "Insert into DMS_EVENT_REASON_R failed"
    ENDIF
   ENDIF
 ENDFOR
 COMMIT
#end_script
 IF ((readme_data->status="Z"))
  SET readme_data->status = "S"
  SET readme_data->message = "DMS Event Reason Reference data successfully imported"
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 CALL echo("<==================== Exiting DMS_EVENT_REASON_R_README Script ====================>")
END GO
