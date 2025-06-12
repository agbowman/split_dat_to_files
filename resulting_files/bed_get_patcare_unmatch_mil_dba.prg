CREATE PROGRAM bed_get_patcare_unmatch_mil:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 code_value = f8
     2 mnemonic = vc
     2 description = vc
     2 catalog_type
       3 code_value = f8
       3 display = vc
       3 cdf_meaning = vc
     2 activity_type
       3 code_value = f8
       3 display = vc
       3 cdf_meaning = vc
     2 autobuild_ind = i2
     2 selected_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET rcnt = 0
 RECORD temp(
   1 qual[*]
     2 cd = f8
     2 mnemonic = vc
     2 description = vc
     2 catalog_type
       3 code_value = f8
       3 display = vc
       3 cdf_meaning = vc
     2 activity_type
       3 code_value = f8
       3 display = vc
       3 cdf_meaning = vc
     2 concept_cki = vc
     2 autobuild_ind = i2
     2 selected_ind = i2
     2 bedrock_cd = f8
     2 match_ind = i2
 )
 SET lab_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="GENERAL LAB")
  DETAIL
   lab_cd = cv.code_value
  WITH nocounter
 ;end select
 SET rad_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="RADIOLOGY")
  DETAIL
   rad_cd = cv.code_value
  WITH nocounter
 ;end select
 SET surg_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="SURGERY")
  DETAIL
   surg_cd = cv.code_value
  WITH nocounter
 ;end select
 SET pharm_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="PHARMACY")
  DETAIL
   pharm_cd = cv.code_value
  WITH nocounter
 ;end select
 SET found = 0
 SELECT INTO "nl:"
  FROM order_catalog oc,
   code_value cv1,
   code_value cv2
  PLAN (oc
   WHERE  NOT (oc.catalog_type_cd IN (lab_cd, rad_cd, surg_cd, pharm_cd))
    AND  NOT (oc.orderable_type_flag IN (2, 6)))
   JOIN (cv1
   WHERE cv1.code_value=oc.catalog_type_cd)
   JOIN (cv2
   WHERE cv2.code_value=oc.activity_type_cd)
  ORDER BY oc.primary_mnemonic
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].cd = oc.catalog_cd,
   temp->qual[cnt].mnemonic = oc.primary_mnemonic, temp->qual[cnt].description = oc.description, temp
   ->qual[cnt].catalog_type.code_value = oc.catalog_type_cd,
   temp->qual[cnt].catalog_type.display = cv1.display, temp->qual[cnt].catalog_type.cdf_meaning = cv1
   .cdf_meaning, temp->qual[cnt].activity_type.code_value = oc.activity_type_cd,
   temp->qual[cnt].activity_type.display = cv2.display, temp->qual[cnt].activity_type.cdf_meaning =
   cv2.cdf_meaning, temp->qual[cnt].concept_cki = oc.concept_cki,
   temp->qual[cnt].autobuild_ind = 0
   IF (oc.active_ind=0)
    temp->qual[cnt].selected_ind = 0
   ELSE
    temp->qual[cnt].selected_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_auto_order_catalog oc
  PLAN (oc
   WHERE oc.patient_care_ind=1)
  ORDER BY oc.primary_mnemonic
  DETAIL
   found = 0
   FOR (x = 1 TO cnt)
     IF ((((oc.concept_cki=temp->qual[x].concept_cki)) OR (cnvtupper(oc.primary_mnemonic)=cnvtupper(
      temp->qual[x].mnemonic))) )
      found = 1, temp->qual[x].bedrock_cd = oc.catalog_cd
     ENDIF
   ENDFOR
   IF (found=0)
    cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].cd = oc.catalog_cd,
    temp->qual[cnt].mnemonic = oc.primary_mnemonic, temp->qual[cnt].description = oc.description,
    temp->qual[cnt].catalog_type.code_value = oc.catalog_type_cd,
    temp->qual[cnt].activity_type.code_value = oc.activity_type_cd, temp->qual[cnt].concept_cki = oc
    .concept_cki, temp->qual[cnt].autobuild_ind = 1,
    temp->qual[cnt].bedrock_cd = oc.catalog_cd
   ENDIF
  WITH nocounter, skipbedrock = 1
 ;end select
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = cnt),
   code_value cv
  PLAN (d
   WHERE (temp->qual[d.seq].catalog_type.code_value > 0)
    AND (temp->qual[d.seq].autobuild_ind=1))
   JOIN (cv
   WHERE (cv.code_value=temp->qual[d.seq].catalog_type.code_value))
  DETAIL
   temp->qual[d.seq].catalog_type.display = cv.display, temp->qual[d.seq].catalog_type.cdf_meaning =
   cv.cdf_meaning
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = cnt),
   code_value cv
  PLAN (d
   WHERE (temp->qual[d.seq].activity_type.code_value > 0)
    AND (temp->qual[d.seq].autobuild_ind=1))
   JOIN (cv
   WHERE (cv.code_value=temp->qual[d.seq].activity_type.code_value))
  DETAIL
   temp->qual[d.seq].activity_type.display = cv.display, temp->qual[d.seq].activity_type.cdf_meaning
    = cv.cdf_meaning
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_oc_work b
  PLAN (d)
   JOIN (b
   WHERE b.match_orderable_cd > 0
    AND (((b.match_orderable_cd=temp->qual[d.seq].cd)) OR ((b.match_orderable_cd=temp->qual[d.seq].
   bedrock_cd))) )
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].match_ind = 1
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
   IF ((temp->qual[x].match_ind=0))
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->orderables,rcnt)
    SET reply->orderables[rcnt].code_value = temp->qual[x].cd
    SET reply->orderables[rcnt].mnemonic = temp->qual[x].mnemonic
    SET reply->orderables[rcnt].description = temp->qual[x].description
    SET reply->orderables[rcnt].catalog_type.code_value = temp->qual[x].catalog_type.code_value
    SET reply->orderables[rcnt].catalog_type.display = temp->qual[x].catalog_type.display
    SET reply->orderables[rcnt].catalog_type.cdf_meaning = temp->qual[x].catalog_type.cdf_meaning
    SET reply->orderables[rcnt].activity_type.code_value = temp->qual[x].activity_type.code_value
    SET reply->orderables[rcnt].activity_type.display = temp->qual[x].activity_type.display
    SET reply->orderables[rcnt].activity_type.cdf_meaning = temp->qual[x].activity_type.cdf_meaning
    SET reply->orderables[rcnt].autobuild_ind = temp->qual[x].autobuild_ind
    SET reply->orderables[rcnt].selected_ind = temp->qual[x].selected_ind
   ENDIF
 ENDFOR
 CALL echorecord(reply)
#exit_script
 IF (rcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
