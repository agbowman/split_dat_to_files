CREATE PROGRAM dcp_del_ntt_reltn:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE note_type_template_reltn_id = f8
 SET note_type_template_reltn_id = 0
 SET failed = "F"
 SELECT INTO "nl:"
  FROM note_type_template_reltn ntt
  WHERE (ntt.note_type_id=request->note_type_id)
   AND (ntt.template_id=request->template_id)
  DETAIL
   note_type_template_reltn_id = ntt.note_type_template_reltn_id
  WITH nocounter
 ;end select
 IF (note_type_template_reltn_id > 0)
  DELETE  FROM prsnl_loc_template_reltn pltr
   WHERE pltr.note_type_template_reltn_id=note_type_template_reltn_id
   WITH nocounter
  ;end delete
  DELETE  FROM note_type_template_reltn ntt
   WHERE (ntt.note_type_id=request->note_type_id)
    AND (ntt.template_id=request->template_id)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET reqinfo->commit_ind = 0
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "NOTE_TYPE_TEMPLATE RELTN"
  ELSE
   SET reqinfo->commit_ind = 1
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NOTE_TYPE_TEMPLATE_RELTN"
 ENDIF
END GO
