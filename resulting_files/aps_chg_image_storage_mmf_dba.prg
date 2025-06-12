CREATE PROGRAM aps_chg_image_storage_mmf:dba
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
 DECLARE logcclerror(soperation=vc(value),stable=vc(value)) = i2 WITH protect
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE dmmfcachestoragecd = f8 WITH protect, noconstant(0.0)
 DECLARE dmmfstoragecd = f8 WITH protect, noconstant(0.0)
 DECLARE scclerror = vc WITH protect, noconstant(" ")
 DECLARE lrowsupdated = i4 WITH protect, noconstant(0)
 RECORD update_ids(
   1 id_cnt = i4
   1 id_qual[*]
     2 id = f8
 )
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET lstat = uar_get_meaning_by_codeset(25,"APS_IMGCACHE",1,dmmfcachestoragecd)
 IF (dmmfcachestoragecd=0)
  CALL subevent_add("UAR","F","UAR","CODE_VALUE (25 - APS_IMGCACHE)")
  GO TO exit_script
 ENDIF
 SET lstat = uar_get_meaning_by_codeset(25,"MMF",1,dmmfstoragecd)
 IF (dmmfstoragecd=0)
  CALL subevent_add("UAR","F","UAR","CODE_VALUE (25 - MMF)")
  GO TO exit_script
 ENDIF
 SET lstat = error(scclerror,1)
 IF ((request->canned_ind=0))
  SET update_ids->id_cnt = 0
  SELECT DISTINCT INTO "nl:"
   ce.event_id
   FROM clinical_event ce,
    ce_blob_result cbr
   PLAN (ce
    WHERE ce.accession_nbr=trim(request->accession_nbr))
    JOIN (cbr
    WHERE cbr.event_id=ce.event_id
     AND cbr.storage_cd=dmmfcachestoragecd
     AND (cbr.blob_handle=request->blob_handle))
   ORDER BY ce.event_id, 0
   DETAIL
    update_ids->id_cnt = (update_ids->id_cnt+ 1)
    IF ((size(update_ids->id_qual,5) < update_ids->id_cnt))
     lstat = alterlist(update_ids->id_qual,(update_ids->id_cnt+ 9))
    ENDIF
    update_ids->id_qual[update_ids->id_cnt].id = ce.event_id
   WITH nocounter, forupdate
  ;end select
  IF (logcclerror("SELECT","CLINICAL_EVENT")=0)
   GO TO exit_script
  ENDIF
  IF ((update_ids->id_cnt > 0))
   UPDATE  FROM ce_blob_result cbr,
     (dummyt d  WITH seq = value(update_ids->id_cnt))
    SET cbr.storage_cd = dmmfstoragecd
    PLAN (d)
     JOIN (cbr
     WHERE (cbr.event_id=update_ids->id_qual[d.seq].id)
      AND (cbr.blob_handle=request->blob_handle)
      AND cbr.storage_cd=dmmfcachestoragecd)
    WITH nocounter
   ;end update
   IF (logcclerror("UPDATE","CE_BLOB_RESULT")=0)
    GO TO exit_script
   ENDIF
   SET lrowsupdated = (lrowsupdated+ curqual)
  ENDIF
 ENDIF
 UPDATE  FROM blob_reference br
  SET br.storage_cd = dmmfstoragecd
  PLAN (br
   WHERE (br.blob_handle=request->blob_handle)
    AND br.storage_cd=dmmfcachestoragecd)
  WITH nocounter
 ;end update
 IF (logcclerror("UPDATE","BLOB_REFERENCE")=0)
  GO TO exit_script
 ENDIF
 SET lrowsupdated = (lrowsupdated+ curqual)
 IF (lrowsupdated > 0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 GO TO exit_script
 SUBROUTINE logcclerror(soperation,stablename)
  IF (error(scclerror,1) != 0)
   CALL subevent_add(build(soperation),"F",build(stablename),scclerror)
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
#exit_script
 SET modify = nopredeclare
END GO
