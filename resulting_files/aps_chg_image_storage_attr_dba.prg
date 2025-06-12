CREATE PROGRAM aps_chg_image_storage_attr:dba
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE lock_failed = c1 WITH noconstant("F")
 DECLARE dicom_storage_cd = f8 WITH noconstant(0.0)
 DECLARE code_set = i4 WITH noconstant(0)
 DECLARE cdf_meaning = c12 WITH noconstant(fillstring(12," "))
 DECLARE code_value = f8 WITH noconstant(0.0)
 DECLARE founduid = c1 WITH noconstant("F")
 DECLARE pc_accession_nbr = c20 WITH noconstant(fillstring(20," "))
 SET ap_reply->status_data.status = "F"
 SET code_set = 25
 SET cdf_meaning = "DICOM_SIUID"
 EXECUTE cpm_get_cd_for_cdf
 SET dicom_storage_cd = code_value
 IF ((ap_request->case_id > 0))
  SET ap_reply->case_parent_entity_name = "PATHOLOGY_CASE"
  SET ap_reply->case_parent_entity_id = ap_request->case_id
  SELECT INTO "nl:"
   br.blob_ref_id
   FROM blob_reference br
   WHERE (br.blob_handle=ap_request->image_ds_uid)
   DETAIL
    ap_reply->image_parent_entity_id = br.blob_ref_id, ap_reply->image_parent_entity_name =
    "BLOB_REFERENCE"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SELECT INTO "nl:"
    pc.accession_nbr
    FROM pathology_case pc
    WHERE (pc.case_id=ap_request->case_id)
    DETAIL
     pc_accession_nbr = pc.accession_nbr
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL handle_errors("SELECT","F","TABLE","PATHOLOGY_CASE")
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    ce.event_id, cbr.blob_handle
    FROM clinical_event ce,
     ce_blob_result cbr
    PLAN (ce
     WHERE ce.accession_nbr=pc_accession_nbr
      AND ce.valid_until_dt_tm >= sysdate)
     JOIN (cbr
     WHERE cbr.event_id=ce.event_id
      AND cbr.valid_until_dt_tm >= sysdate)
    HEAD REPORT
     founduid = "F"
    DETAIL
     IF (trim(ap_request->image_ds_uid)=trim(cbr.blob_handle))
      founduid = "T", ap_reply->image_parent_entity_id = cbr.event_id, ap_reply->
      image_parent_entity_name = "CLINICAL_EVENT"
     ENDIF
    WITH nocounter
   ;end select
   IF (founduid="F")
    CALL handle_errors("SELECT","F","TABLE","CE_BLOB_RESULT")
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((ap_reply->image_parent_entity_name="BLOB_REFERENCE"))
   SELECT INTO "nl:"
    br.blob_ref_id
    FROM blob_reference br
    WHERE (br.blob_ref_id=ap_reply->image_parent_entity_id)
    WITH nocounter, forupdate(br)
   ;end select
   IF (curqual=0)
    CALL handle_errors("LOCK","F","TABLE","BLOB_REFERENCE")
    GO TO exit_script
   ENDIF
   UPDATE  FROM blob_reference br
    SET br.storage_cd = dicom_storage_cd, br.updt_id = reqinfo->updt_id, br.updt_dt_tm = cnvtdatetime
     (curdate,curtime3),
     br.updt_task = reqinfo->updt_task, br.updt_applctx = reqinfo->updt_applctx
    WHERE (br.blob_ref_id=ap_reply->image_parent_entity_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL handle_errors("UPDATE","F","TABLE","BLOB_REFERENCE")
    GO TO exit_script
   ENDIF
  ELSE
   SELECT INTO "nl:"
    cbr.event_id
    FROM ce_blob_result cbr
    WHERE (cbr.event_id=ap_reply->image_parent_entity_id)
     AND cbr.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    WITH nocounter, forupdate(cbr)
   ;end select
   IF (curqual=0)
    CALL handle_errors("LOCK","F","TABLE","CE_BLOB_RESULT")
    GO TO exit_script
   ENDIF
   UPDATE  FROM ce_blob_result cbr
    SET cbr.storage_cd = dicom_storage_cd, cbr.updt_id = reqinfo->updt_id, cbr.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     cbr.updt_task = reqinfo->updt_task, cbr.updt_applctx = reqinfo->updt_applctx
    WHERE (cbr.event_id=ap_reply->image_parent_entity_id)
     AND cbr.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL handle_errors("UPDATE","F","TABLE","CE_BLOB_RESULT")
    GO TO exit_script
   ENDIF
  ENDIF
 ELSE
  SELECT INTO "nl:"
   br.blob_ref_id
   FROM blob_reference br
   WHERE (br.blob_handle=ap_request->image_ds_uid)
   DETAIL
    ap_reply->image_parent_entity_id = br.blob_ref_id, ap_reply->image_parent_entity_name =
    "BLOB_REFERENCE"
   WITH nocounter
  ;end select
  IF (curqual != 0)
   SELECT INTO "nl:"
    br.blob_ref_id
    FROM blob_reference br
    WHERE (br.blob_ref_id=ap_reply->image_parent_entity_id)
    WITH nocounter, forupdate(br)
   ;end select
   IF (curqual=0)
    CALL handle_errors("LOCK","F","TABLE","BLOB_REFERENCE")
    GO TO exit_script
   ENDIF
   UPDATE  FROM blob_reference br
    SET br.storage_cd = dicom_storage_cd, br.updt_id = reqinfo->updt_id, br.updt_dt_tm = cnvtdatetime
     (curdate,curtime3),
     br.updt_task = reqinfo->updt_task, br.updt_applctx = reqinfo->updt_applctx
    WHERE (br.blob_ref_id=ap_reply->image_parent_entity_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL handle_errors("UPDATE","F","TABLE","BLOB_REFERENCE")
    GO TO exit_script
   ENDIF
  ELSE
   CALL handle_errors("SELECT","F","TABLE","BLOB_REFERENCE")
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  SET ap_reply->status_data.status = "F"
 ELSE
  SET ap_reply->status_data.status = "S"
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   DECLARE error_cnt = i2 WITH noconstant(0)
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(ap_reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET ap_reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET ap_reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET ap_reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET ap_reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
   SET failed = "T"
 END ;Subroutine
END GO
