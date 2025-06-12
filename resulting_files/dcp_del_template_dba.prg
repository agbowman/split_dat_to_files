CREATE PROGRAM dcp_del_template:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reqinfo->commit_ind = 0
 SET reply->status_data.status = "F"
 DECLARE smart_template_ind = i4
 SELECT INTO "nl:"
  FROM clinical_note_template c
  WHERE (c.template_id=request->template_id)
  DETAIL
   smart_template_ind = c.smart_template_ind
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL failed("SELECT","CLINICAL_NOTE_TEMPLATE")
 ENDIF
 IF (smart_template_ind=0)
  DELETE  FROM long_blob lb
   WHERE (lb.parent_entity_id=request->template_id)
    AND lb.parent_entity_name="CLINICAL_NOTE_TEMPLATE"
   WITH nocounter
  ;end delete
  IF (curqual=0)
   CALL failed("DELETE","LONG_BLOB")
  ENDIF
 ENDIF
 DELETE  FROM prsnl_loc_template_reltn pltr
  WHERE (pltr.note_type_template_reltn_id=
  (SELECT
   nttr.note_type_template_reltn_id
   FROM note_type_template_reltn nttr
   WHERE (nttr.template_id=request->template_id)
   WITH nocounter))
  WITH nocounter
 ;end delete
 DELETE  FROM note_type_template_reltn
  WHERE (template_id=request->template_id)
  WITH nocounter
 ;end delete
 DELETE  FROM clinical_note_template
  WHERE (template_id=request->template_id)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  CALL failed("DELETE","CLINICAL_NOTE_TEMPLATE")
 ENDIF
 SET reqinfo->commit_ind = 1
 SET reply->status_data.status = "S"
#exit_script
 SUBROUTINE failed(operationname,targetobjectvalue)
   SET reqinfo->commit_ind = 0
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = operationname
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
END GO
