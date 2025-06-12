CREATE PROGRAM afc_srv_get_service_resources:dba
 RECORD reply(
   1 service_resource_cd = f8
   1 level5_cd = f8
   1 subsection_cd = f8
   1 section_cd = f8
   1 department_cd = f8
   1 institution_cd = f8
   1 organization_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET curqual1 = 0
 SET start_loc_cd = request->service_resource_cd
 SET temp_loc_cd = 0
 SET reply->service_resource_cd = start_loc_cd
 DECLARE meaning = c12
 SET meaning = uar_get_code_meaning(start_loc_cd)
 IF (meaning="INSTITUTION")
  SET reply->institution_cd = start_loc_cd
 ELSEIF (meaning="DEPARTMENT")
  SET reply->department_cd = start_loc_cd
 ELSEIF (((meaning="SECTION") OR (meaning="SURGAREA")) )
  SET reply->section_cd = start_loc_cd
 ELSEIF (((meaning="SUBSECTION") OR (meaning="SURGSTAGE")) )
  SET reply->subsection_cd = start_loc_cd
 ELSE
  SET reply->level5_cd = start_loc_cd
 ENDIF
 FOR (x = 1 TO 10)
  SELECT INTO "nl:"
   r.child_service_resource_cd, r.parent_service_resource_cd
   FROM resource_group r
   WHERE r.child_service_resource_cd=start_loc_cd
    AND r.active_ind=1
   DETAIL
    meaning = uar_get_code_meaning(r.parent_service_resource_cd)
    IF (((meaning="SUBSECTION") OR (meaning="SURGSTAGE")) )
     reply->level5_cd = start_loc_cd, reply->subsection_cd = r.parent_service_resource_cd
    ELSEIF (((meaning="SECTION") OR (meaning="SURGAREA")) )
     reply->section_cd = r.parent_service_resource_cd
    ELSEIF (meaning="DEPARTMENT")
     reply->department_cd = r.parent_service_resource_cd
    ELSEIF (meaning="INSTITUTION")
     reply->institution_cd = r.parent_service_resource_cd
    ELSE
     CALL echo(build("Unknown meaning: ",meaning))
    ENDIF
    start_loc_cd = r.parent_service_resource_cd
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET x = 10
   SET start_loc_cd = 0
  ELSE
   SET curqual1 = 1
  ENDIF
 ENDFOR
 IF ((reply->institution_cd != 0))
  SELECT INTO "nl:"
   sr.organization_id
   FROM service_resource sr
   WHERE (sr.service_resource_cd=reply->institution_cd)
   DETAIL
    reply->organization_id = sr.organization_id
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(build("reply: ",reply->service_resource_cd," : ",reply->level5_cd," : ",
   reply->subsection_cd," : ",reply->section_cd," : ",reply->department_cd,
   " : ",reply->institution_cd," : ",reply->organization_id))
 IF (curqual1 != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ITEM"
  SET reply->status_data.status = "Z"
 ENDIF
END GO
