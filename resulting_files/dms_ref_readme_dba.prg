CREATE PROGRAM dms_ref_readme:dba
 CALL echo("<==================== Entering DMS_REF_README Script ====================>")
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
 SET readme_data->message = "Starting import of DMS Reference data"
 DECLARE listsize = i4 WITH constant(size(requestin->list_0,5))
 FOR (i = 1 TO listsize)
   FREE SET refid
   DECLARE refid = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    dmr.dms_ref_id, dmr.ref_key, dmr.ref_group
    FROM dms_ref dmr
    WHERE dmr.ref_key=cnvtupper(requestin->list_0[i].ref_key)
     AND dmr.ref_group=cnvtupper(requestin->list_0[i].ref_group)
    DETAIL
     refid = dmr.dms_ref_id
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
    INSERT  FROM dms_ref dmr
     SET dmr.dms_ref_id = refid, dmr.ref_group = cnvtupper(requestin->list_0[i].ref_group), dmr
      .ref_key = cnvtupper(requestin->list_0[i].ref_key),
      dmr.display = requestin->list_0[i].display, dmr.updt_dt_tm = cnvtdatetime(sysdate), dmr.updt_id
       = reqinfo->updt_id,
      dmr.updt_task = reqinfo->updt_task, dmr.updt_cnt = 0, dmr.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual <= 0)
     SET readme_data->status = "F"
     SET readme_data->message = "Insert into DMS_REF failed"
    ENDIF
   ENDIF
 ENDFOR
 COMMIT
#end_script
 IF ((readme_data->status="Z"))
  SET readme_data->status = "S"
  SET readme_data->message = "DMS Reference data successfully imported"
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 CALL echo("<==================== Exiting DMS_REF_README Script ====================>")
END GO
