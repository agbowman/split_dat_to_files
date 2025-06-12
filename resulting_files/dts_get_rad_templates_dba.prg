CREATE PROGRAM dts_get_rad_templates:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 catalog_cd = f8
    1 temp_grp[10]
      2 template_group_id = f8
      2 person_id = f8
      2 group_desc = c50
      2 mod_text_flag = i2
      2 classification_cd = f8
      2 classification_disp = c40
      2 assess_id = f8
      2 rec_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET cnt = 0
 IF ((request->person_id=0)
  AND (request->catalog_cd=0))
  SELECT INTO "nl:"
   rtg.*
   FROM rad_template_group rtg
   ORDER BY rtg.template_group_id
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1
     AND cnt != 1)
     stat = alter(reply->temp_grp,(cnt+ 9))
    ENDIF
    reply->catalog_cd = rtg.catalog_cd, reply->temp_grp[cnt].template_group_id = rtg
    .template_group_id, reply->temp_grp[cnt].person_id = rtg.person_id,
    reply->temp_grp[cnt].group_desc = rtg.group_desc, reply->temp_grp[cnt].mod_text_flag = rtg
    .mod_text_flag, reply->temp_grp[cnt].classification_cd = rtg.classification_cd,
    reply->temp_grp[cnt].assess_id = rtg.assessment_id, reply->temp_grp[cnt].rec_id = rtg
    .recommendation_id
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   rtg.*
   FROM rad_template_group rtg
   WHERE (((rtg.person_id=request->person_id)) OR (rtg.person_id=0))
    AND (rtg.catalog_cd=request->catalog_cd)
   ORDER BY rtg.template_group_id
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1
     AND cnt != 1)
     stat = alter(reply->temp_grp,(cnt+ 9))
    ENDIF
    reply->catalog_cd = rtg.catalog_cd, reply->temp_grp[cnt].template_group_id = rtg
    .template_group_id, reply->temp_grp[cnt].person_id = rtg.person_id,
    reply->temp_grp[cnt].group_desc = rtg.group_desc, reply->temp_grp[cnt].mod_text_flag = rtg
    .mod_text_flag, reply->temp_grp[cnt].classification_cd = rtg.classification_cd,
    reply->temp_grp[cnt].assess_id = rtg.assessment_id, reply->temp_grp[cnt].rec_id = rtg
    .recommendation_id
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "RAD_TEMPLATE_GROUP"
 ENDIF
 SET stat = alter(reply->temp_grp,cnt)
END GO
