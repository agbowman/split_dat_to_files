CREATE PROGRAM aps_chg_migrated_handles:dba
 SET modify = predeclare
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 RECORD request(
   1 accession_nbr = c21
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD migrate_handle(
   1 qual[*]
     2 old_blob_handle = vc
     2 new_blob_handle = vc
     2 event_id = f8
 )
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE ddeletedstatuscd = f8 WITH protect, noconstant(0.0)
 DECLARE ddicomstoragecd = f8 WITH protect, noconstant(0.0)
 DECLARE dcachestoragecd = f8 WITH protect, noconstant(0.0)
 DECLARE dmmfstoragecd = f8 WITH protect, noconstant(0.0)
 DECLARE lblobcnt = i4 WITH protect, noconstant(0)
 DECLARE lmigratecnt = i4 WITH protect, noconstant(0)
 DECLARE dmigrateind = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  aim.ap_image_migrated_id
  FROM ap_image_migrated aim
  WHERE aim.ap_image_migrated_id > 0
  DETAIL
   dmigrateind = aim.ap_image_migrated_id
  WITH nocounter, maxrec = 1
 ;end select
 IF (dmigrateind > 0)
  SET reply->status_data.status = "F"
  SET lstat = uar_get_meaning_by_codeset(48,"DELETED",1,ddeletedstatuscd)
  IF (ddeletedstatuscd=0)
   CALL subevent_add("UAR","F","UAR","CODE_VALUE (48 - DELETED)")
   GO TO exit_script
  ENDIF
  SET lstat = uar_get_meaning_by_codeset(25,"DICOM_SIUID",1,ddicomstoragecd)
  IF (ddicomstoragecd=0)
   CALL subevent_add("UAR","F","UAR","CODE_VALUE (25 - DICOM_SIUID)")
   GO TO exit_script
  ENDIF
  SET lstat = uar_get_meaning_by_codeset(25,"IMGCACHE",1,dcachestoragecd)
  IF (dcachestoragecd=0)
   CALL subevent_add("UAR","F","UAR","CODE_VALUE (25 - IMGCACHE)")
   GO TO exit_script
  ENDIF
  SET lstat = uar_get_meaning_by_codeset(25,"MMF",1,dmmfstoragecd)
  IF (dmmfstoragecd=0)
   CALL subevent_add("UAR","F","UAR","CODE_VALUE (25 - MMF)")
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   cbr.blob_handle
   FROM ce_blob_result cbr,
    ap_image_migrated aim
   PLAN (cbr
    WHERE (cbr.event_id=
    (SELECT
     ce.event_id
     FROM clinical_event ce
     WHERE (ce.accession_nbr=request->accession_nbr)
      AND ce.record_status_cd != ddeletedstatuscd))
     AND cbr.blob_handle > "0"
     AND cbr.storage_cd IN (ddicomstoragecd, dcachestoragecd)
     AND cbr.valid_from_dt_tm < cnvtdatetime(curdate,curtime3)
     AND cbr.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (aim
    WHERE cbr.blob_handle=aim.dicom_blob_handle_ident)
   DETAIL
    lmigratecnt = (lmigratecnt+ 1)
    IF (size(migrate_handle->qual,5) < lmigratecnt)
     lstat = alterlist(migrate_handle->qual,(lmigratecnt+ 5))
    ENDIF
    migrate_handle->qual[lmigratecnt].old_blob_handle = aim.dicom_blob_handle_ident, migrate_handle->
    qual[lmigratecnt].new_blob_handle = aim.mmf_blob_handle_ident, migrate_handle->qual[lmigratecnt].
    event_id = cbr.event_id
   WITH nocounter
  ;end select
  SET lstat = alterlist(migrate_handle->qual,lmigratecnt)
  IF (lmigratecnt > 0)
   UPDATE  FROM ce_blob_result cbr,
     (dummyt d  WITH seq = value(lmigratecnt))
    SET cbr.blob_handle = migrate_handle->qual[d.seq].new_blob_handle
    PLAN (d)
     JOIN (cbr
     WHERE (cbr.event_id=migrate_handle->qual[d.seq].event_id)
      AND (cbr.blob_handle=migrate_handle->qual[d.seq].old_blob_handle))
    WITH nocounter
   ;end update
  ENDIF
 ENDIF
 IF (lmigratecnt=0)
  SET reply->status_data.status = "Z"
 ELSEIF (curqual < lmigratecnt)
  SET reply->status_data.status = "F"
  CALL subevent_add("UPDATE","F","CE_BLOB_RESULT","Failure - Error updating migrated blob handles.")
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 SET modify = nopredeclare
END GO
