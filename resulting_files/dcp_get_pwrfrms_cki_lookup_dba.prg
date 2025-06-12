CREATE PROGRAM dcp_get_pwrfrms_cki_lookup:dba
 RECORD reply(
   1 parent_entity_name = vc
   1 parent_entity_id = f8
   1 description = vc
   1 definition = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM cki_entity_reltn cki
  WHERE (cki.cki=request->cki)
  DETAIL
   reply->parent_entity_name = cki.parent_entity_name, reply->parent_entity_id = cki.parent_entity_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 IF ((reply->parent_entity_name="DCP_SECTION_REF"))
  SELECT INTO "nl:"
   FROM dcp_section_ref dsr
   WHERE (dsr.dcp_section_ref_id=reply->parent_entity_id)
    AND dsr.active_ind=1
   DETAIL
    reply->description = dsr.description, reply->definition = dsr.definition
   WITH nocounter
  ;end select
 ELSEIF ((reply->parent_entity_name="DCP_FORMS_REF"))
  SELECT INTO "nl:"
   FROM dcp_forms_ref dfr
   WHERE (dfr.dcp_forms_ref_id=reply->parent_entity_id)
    AND dfr.active_ind=1
   DETAIL
    reply->description = dfr.description, reply->definition = dfr.definition
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->parent_entity_id=0))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
