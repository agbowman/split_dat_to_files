CREATE PROGRAM bed_chk_dup_powerplan_syns:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 display_dup_ind = i2
    1 description_dup_ind = i2
    1 duplicate_synonyms[*]
      2 synonym_name = vc
    1 facilities[*]
      2 facility_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET reply->display_dup_ind = 0
 SET reply->description_dup_ind = 0
 DECLARE highest_plan_version_id = f8
 SET highest_plan_version_id = 0.0
 IF ((request->power_plan_id > 0.0))
  SELECT INTO "nl:"
   FROM pathway_catalog pc
   PLAN (pc
    WHERE (pc.pathway_catalog_id=request->power_plan_id))
   DETAIL
    highest_plan_version_id = pc.version_pw_cat_id
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM pathway_catalog pc
  WHERE pc.description_key=cnvtupper(request->power_plan_description)
   AND pc.type_mean IN ("PATHWAY", "CAREPLAN")
   AND (pc.pathway_catalog_id != request->power_plan_id)
   AND pc.version_pw_cat_id != highest_plan_version_id
   AND pc.active_ind=1
  DETAIL
   reply->description_dup_ind = 1
  WITH nocounter
 ;end select
 IF ((request->all_facilities_ind=1))
  SELECT INTO "nl:"
   FROM pw_cat_synonym pcs,
    pathway_catalog pc
   WHERE pcs.synonym_name_key=cnvtupper(request->power_plan_display)
    AND pcs.pathway_catalog_id=pc.pathway_catalog_id
    AND pc.type_mean IN ("PATHWAY", "CAREPLAN")
    AND (pc.pathway_catalog_id != request->power_plan_id)
    AND pc.version_pw_cat_id != highest_plan_version_id
    AND pc.active_ind=1
   DETAIL
    reply->display_dup_ind = 1
   WITH nocounter
  ;end select
  SET syn_num = size(request->synonyms,5)
  IF (syn_num > 0)
   SELECT INTO "nl:"
    FROM pw_cat_synonym pcs,
     pathway_catalog pc,
     (dummyt d  WITH seq = syn_num)
    PLAN (d)
     JOIN (pcs
     WHERE pcs.synonym_name_key=cnvtupper(request->synonyms[d.seq].synonym_name))
     JOIN (pc
     WHERE pcs.pathway_catalog_id=pc.pathway_catalog_id
      AND pc.type_mean IN ("PATHWAY", "CAREPLAN")
      AND (pc.pathway_catalog_id != request->power_plan_id)
      AND pc.version_pw_cat_id != highest_plan_version_id
      AND pc.active_ind=1)
    ORDER BY pcs.synonym_name_key
    HEAD REPORT
     syn_cnt = 0
    HEAD pcs.synonym_name_key
     syn_cnt = (syn_cnt+ 1)
     IF (syn_cnt > size(reply->duplicate_synonyms,5))
      stat = alterlist(reply->duplicate_synonyms,(syn_cnt+ 10))
     ENDIF
     reply->duplicate_synonyms[syn_cnt].synonym_name = pcs.synonym_name
    FOOT REPORT
     stat = alterlist(reply->duplicate_synonyms,syn_cnt)
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  DECLARE num = i4
  DECLARE idx = i4
  DECLARE facility_cnt = i4
  SET facility_cnt = 0
  IF (size(request->facilities,5) > 0)
   FREE RECORD temp_facilities
   RECORD temp_facilities(
     1 facilities[*]
       2 facility_id = f8
   )
   SELECT INTO "nl:"
    FROM pathway_catalog pc,
     pw_cat_synonym pcs,
     pw_cat_flex pcf
    PLAN (pcs
     WHERE pcs.synonym_name_key=cnvtupper(request->power_plan_display))
     JOIN (pc
     WHERE pcs.pathway_catalog_id=pc.pathway_catalog_id
      AND pc.type_mean IN ("PATHWAY", "CAREPLAN")
      AND (pc.pathway_catalog_id != request->power_plan_id)
      AND pc.version_pw_cat_id != highest_plan_version_id
      AND pc.active_ind=1)
     JOIN (pcf
     WHERE pc.pathway_catalog_id=pcf.pathway_catalog_id
      AND pcf.parent_entity_name="CODE_VALUE"
      AND ((pcf.parent_entity_id=0.0) OR (expand(num,1,size(request->facilities,5),pcf
      .parent_entity_id,request->facilities[num].facility_id))) )
    ORDER BY pcf.parent_entity_id
    HEAD pcf.parent_entity_id
     IF (pcf.parent_entity_id > 0.0)
      facility_cnt = (facility_cnt+ 1)
      IF (facility_cnt > size(temp_facilities->facilities,5))
       stat = alterlist(temp_facilities->facilities,(facility_cnt+ 10))
      ENDIF
      temp_facilities->facilities[facility_cnt].facility_id = pcf.parent_entity_id
     ENDIF
    DETAIL
     reply->display_dup_ind = 1
    FOOT REPORT
     stat = alterlist(temp_facilities->facilities,facility_cnt)
    WITH nocounter
   ;end select
   SET syn_num = size(request->synonyms,5)
   IF (syn_num > 0)
    SELECT INTO "nl:"
     FROM pw_cat_synonym pcs,
      pathway_catalog pc,
      (dummyt d  WITH seq = syn_num),
      pw_cat_flex pcf
     PLAN (d)
      JOIN (pcs
      WHERE pcs.synonym_name_key=cnvtupper(request->synonyms[d.seq].synonym_name))
      JOIN (pc
      WHERE pcs.pathway_catalog_id=pc.pathway_catalog_id
       AND pc.type_mean IN ("PATHWAY", "CAREPLAN")
       AND (pc.pathway_catalog_id != request->power_plan_id)
       AND pc.version_pw_cat_id != highest_plan_version_id
       AND pc.active_ind=1)
      JOIN (pcf
      WHERE pc.pathway_catalog_id=pcf.pathway_catalog_id
       AND pcf.parent_entity_name="CODE_VALUE"
       AND ((pcf.parent_entity_id=0.0) OR (expand(num,1,size(request->facilities,5),pcf
       .parent_entity_id,request->facilities[num].facility_id))) )
     ORDER BY pcs.synonym_name_key
     HEAD REPORT
      syn_cnt = 0
     HEAD pcs.synonym_name_key
      syn_cnt = (syn_cnt+ 1)
      IF (syn_cnt > size(reply->duplicate_synonyms,5))
       stat = alterlist(reply->duplicate_synonyms,(syn_cnt+ 10))
      ENDIF
      reply->duplicate_synonyms[syn_cnt].synonym_name = pcs.synonym_name
     HEAD pcf.parent_entity_id
      IF (pcf.parent_entity_id > 0.0)
       facility_cnt = (facility_cnt+ 1)
       IF (facility_cnt > size(temp_facilities->facilities,5))
        stat = alterlist(temp_facilities->facilities,(facility_cnt+ 10))
       ENDIF
       temp_facilities->facilities[facility_cnt].facility_id = pcf.parent_entity_id
      ENDIF
     FOOT REPORT
      stat = alterlist(reply->duplicate_synonyms,syn_cnt), stat = alterlist(temp_facilities->
       facilities,facility_cnt)
     WITH nocounter
    ;end select
   ENDIF
   IF (facility_cnt > 0)
    SET stat = alterlist(reply->facilities,facility_cnt)
    SELECT INTO "nl:"
     facility_id = temp_facilities->facilities[d.seq].facility_id
     FROM (dummyt d  WITH seq = size(temp_facilities->facilities,5))
     ORDER BY facility_id
     HEAD REPORT
      cnt = 0
     HEAD facility_id
      cnt = (cnt+ 1), reply->facilities[cnt].facility_id = facility_id
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
