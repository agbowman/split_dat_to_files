CREATE PROGRAM dcp_get_clinical_nt:dba
 RECORD reply(
   1 note_template[*]
     2 template_id = f8
     2 template_name = vc
     2 template_active_ind = i2
     2 owner_type_flag = i2
     2 prsnl_id = f8
     2 smart_template_cd = f8
     2 smart_template_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM clinical_note_template nt
  WHERE nt.smart_template_ind < 2
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(reply->note_template,5))
    stat = alterlist(reply->note_template,(cnt+ 10))
   ENDIF
   reply->note_template[cnt].template_id = nt.template_id, reply->note_template[cnt].template_name =
   trim(nt.template_name), reply->note_template[cnt].template_active_ind = nt.template_active_ind,
   reply->note_template[cnt].owner_type_flag = nt.owner_type_flag, reply->note_template[cnt].prsnl_id
    = nt.prsnl_id, reply->note_template[cnt].smart_template_cd = nt.smart_template_cd,
   reply->note_template[cnt].smart_template_ind = nt.smart_template_ind
  WITH nocounter
 ;end select
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CLINICAL_NOTE_TEMPLATE"
 ENDIF
 SET stat = alterlist(reply->note_template,cnt)
END GO
