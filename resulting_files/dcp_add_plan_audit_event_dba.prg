CREATE PROGRAM dcp_add_plan_audit_event:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE audit_list_size = i4 WITH protect, constant(size(request->audit_list,5))
 SET reply->status_data.status = "S"
 FOR (x = 1 TO audit_list_size)
  INSERT  FROM pp_audit_event pae
   SET pae.pp_audit_event_id = seq(carenet_seq,nextval), pae.event_type = request->audit_list[x].
    event_type, pae.event_name = request->audit_list[x].event_name,
    pae.event_message = request->audit_list[x].event_message, pae.event_dt_tm = cnvtdatetime(request
     ->audit_list[x].event_dt_tm), pae.event_entity_id = request->audit_list[x].event_entity_id,
    pae.event_entity_name = request->audit_list[x].event_entity_name, pae.event_enum = request->
    audit_list[x].event_enum, pae.person_id = request->audit_list[x].person_id,
    pae.encntr_id = request->audit_list[x].encntr_id, pae.user_id = request->audit_list[x].user_id,
    pae.app_nbr = request->audit_list[x].app_nbr
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 ENDFOR
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "ADD AUDIT EVENT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "PP AUDIT EVENT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PP AUDIT EVENT"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
