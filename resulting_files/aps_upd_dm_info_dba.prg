CREATE PROGRAM aps_upd_dm_info:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE add_cnt = i4 WITH noconstant(0)
 DECLARE chg_cnt = i4 WITH noconstant(0)
 DECLARE lock_failed = c1 WITH noconstant("F")
 DECLARE error_cnt = i2 WITH noconstant(0)
 DECLARE dicom_ind = i2 WITH noconstant(0)
 DECLARE mmf_ind = i2 WITH noconstant(0)
 DECLARE index = i2 WITH noconstant(0)
 DECLARE ap_domain = c18 WITH constant("ANATOMIC PATHOLOGY")
 DECLARE dicom_info = c13 WITH constant("DICOM STORAGE")
 DECLARE mmf_info = c11 WITH constant("MMF STORAGE")
 SET reply->status_data.status = "F"
 SET add_cnt = size(request->add_qual,5)
 SET chg_cnt = size(request->chg_qual,5)
 IF (add_cnt > 0)
  INSERT  FROM dm_info di,
    (dummyt d  WITH seq = value(add_cnt))
   SET di.info_domain = request->add_qual[d.seq].dm_info_domain, di.info_name = request->add_qual[d
    .seq].dm_info_name, di.info_date = cnvtdatetime(request->add_qual[d.seq].dm_info_date),
    di.info_char = request->add_qual[d.seq].dm_info_char, di.info_number = request->add_qual[d.seq].
    dm_info_number, di.info_long_id = request->add_qual[d.seq].dm_info_long_id,
    di.updt_cnt = 0
   PLAN (d)
    JOIN (di)
   WITH nocounter
  ;end insert
  IF (curqual != add_cnt)
   CALL handle_errors("INSERT","F","Add","DM_INFO")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (chg_cnt > 0)
  SELECT INTO "nl:"
   di.info_domain
   FROM dm_info di,
    (dummyt d  WITH seq = value(chg_cnt))
   PLAN (d)
    JOIN (di
    WHERE (di.info_domain=request->chg_qual[d.seq].dm_info_domain)
     AND (di.info_name=request->chg_qual[d.seq].dm_info_name))
   DETAIL
    IF ((request->chg_qual[d.seq].updt_cnt != di.updt_cnt))
     lock_failed = "T"
    ENDIF
   WITH forupdate(di)
  ;end select
  IF (lock_failed="T")
   CALL handle_errors("LOCK","F","TABLE","DM_INFO")
   GO TO exit_script
  ENDIF
  UPDATE  FROM dm_info di,
    (dummyt d  WITH seq = value(chg_cnt))
   SET di.info_domain = request->chg_qual[d.seq].dm_info_domain, di.info_name = request->chg_qual[d
    .seq].dm_info_name, di.info_date = cnvtdatetime(request->chg_qual[d.seq].dm_info_date),
    di.info_char = request->chg_qual[d.seq].dm_info_char, di.info_number = request->chg_qual[d.seq].
    dm_info_number, di.info_long_id = request->chg_qual[d.seq].dm_info_long_id,
    di.updt_cnt = (di.updt_cnt+ 1)
   PLAN (d)
    JOIN (di
    WHERE (di.info_domain=request->chg_qual[d.seq].dm_info_domain)
     AND (di.info_name=request->chg_qual[d.seq].dm_info_name))
   WITH nocounter
  ;end update
  IF (curqual != chg_cnt)
   CALL handle_errors("UPDATE","F","Chg","DM_INFO")
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (index = 1 TO add_cnt)
   IF ((request->add_qual[index].dm_info_domain=ap_domain)
    AND (request->add_qual[index].dm_info_name=dicom_info))
    SET dicom_ind = 1
   ELSEIF ((request->add_qual[index].dm_info_domain=ap_domain)
    AND (request->add_qual[index].dm_info_name=mmf_info))
    SET mmf_ind = 1
   ENDIF
 ENDFOR
 FOR (index = 1 TO chg_cnt)
   IF ((request->chg_qual[index].dm_info_domain=ap_domain)
    AND (request->chg_qual[index].dm_info_name=dicom_info))
    SET dicom_ind = 1
   ELSEIF ((request->chg_qual[index].dm_info_domain=ap_domain)
    AND (request->chg_qual[index].dm_info_name=mmf_info))
    SET mmf_ind = 1
   ENDIF
 ENDFOR
 IF (dicom_ind=1
  AND mmf_ind=0)
  DELETE  FROM dm_info d
   WHERE d.info_domain=ap_domain
    AND d.info_name=mmf_info
   WITH nocounter
  ;end delete
 ELSEIF (dicom_ind=0
  AND mmf_ind=1)
  DELETE  FROM dm_info d
   WHERE d.info_domain=ap_domain
    AND d.info_name=dicom_info
   WITH nocounter
  ;end delete
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
   SET failed = "T"
 END ;Subroutine
END GO
