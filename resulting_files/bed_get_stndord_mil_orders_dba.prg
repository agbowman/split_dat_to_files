CREATE PROGRAM bed_get_stndord_mil_orders:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 code_value = f8
     2 mnemonic = vc
     2 description = vc
     2 existing_match_ind = i2
     2 synonyms[*]
       3 mnemonic = vc
     2 catalog_type
       3 code_value = f8
       3 display = vc
       3 meaning = vc
     2 activity_type
       3 code_value = f8
       3 display = vc
       3 meaning = vc
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
 SET ccnt = 0
 SET scnt = 0
 SET ccnt = size(request->catalog_types,5)
 IF (ccnt=0)
  GO TO exit_script
 ENDIF
 RECORD temp(
   1 qual[*]
     2 cd = f8
     2 mnemonic = vc
     2 description = vc
     2 concept_cki = vc
     2 bedrock_cd = f8
     2 match_ind = i2
     2 syn[*]
       3 mnemonic = vc
     2 catalog_type
       3 code_value = f8
       3 display = vc
       3 meaning = vc
     2 activity_type
       3 code_value = f8
       3 display = vc
       3 meaning = vc
     2 include = i2
 )
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(ccnt)),
   order_catalog oc,
   code_value cv1,
   code_value cv2,
   order_catalog_synonym ocs
  PLAN (d)
   JOIN (oc
   WHERE (oc.catalog_type_cd=request->catalog_types[d.seq].code_value)
    AND  NOT (oc.orderable_type_flag IN (2, 6))
    AND oc.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=oc.catalog_type_cd
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=oc.activity_type_cd
    AND cv2.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.active_ind=1)
  ORDER BY oc.primary_mnemonic, ocs.mnemonic
  HEAD oc.primary_mnemonic
   scnt = 0, cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt),
   temp->qual[cnt].cd = oc.catalog_cd, temp->qual[cnt].mnemonic = oc.primary_mnemonic, temp->qual[cnt
   ].description = oc.description,
   temp->qual[cnt].concept_cki = oc.concept_cki, temp->qual[cnt].catalog_type.code_value = cv1
   .code_value, temp->qual[cnt].catalog_type.display = cv1.display,
   temp->qual[cnt].catalog_type.meaning = cv1.cdf_meaning, temp->qual[cnt].activity_type.code_value
    = cv2.code_value, temp->qual[cnt].activity_type.display = cv2.display,
   temp->qual[cnt].activity_type.meaning = cv2.cdf_meaning, temp->qual[cnt].include = 1
  DETAIL
   scnt = (scnt+ 1), stat = alterlist(temp->qual[cnt].syn,scnt), temp->qual[cnt].syn[scnt].mnemonic
    = ocs.mnemonic
  WITH nocounter
 ;end select
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_oc_work b
  PLAN (d)
   JOIN (b
   WHERE (b.match_orderable_cd=temp->qual[d.seq].cd)
    AND (b.catalog_type=request->department_name))
  ORDER BY d.seq
  HEAD d.seq
   IF (b.match_orderable_cd > 0)
    temp->qual[d.seq].match_ind = 1
    IF ((request->include_legacy_ind=0))
     IF (b.match_ind=0)
      temp->qual[d.seq].include = 0
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_auto_order_catalog b
  PLAN (d)
   JOIN (b
   WHERE (b.concept_cki=temp->qual[d.seq].concept_cki)
    AND (temp->qual[d.seq].match_ind=0)
    AND (temp->qual[d.seq].concept_cki > " "))
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].bedrock_cd = b.catalog_cd
  WITH nocounter, skipbedrock = 1
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_oc_work b
  PLAN (d
   WHERE (temp->qual[d.seq].bedrock_cd > 0))
   JOIN (b
   WHERE (b.match_orderable_cd=temp->qual[d.seq].bedrock_cd)
    AND (b.catalog_type=request->department_name))
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].match_ind = 1
   IF ((request->include_legacy_ind=0))
    IF (b.match_ind=0)
     temp->qual[d.seq].include = 0
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
   IF ((temp->qual[x].include=1))
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->orderables,rcnt)
    SET reply->orderables[rcnt].code_value = temp->qual[x].cd
    SET reply->orderables[rcnt].mnemonic = temp->qual[x].mnemonic
    SET reply->orderables[rcnt].description = temp->qual[x].description
    SET reply->orderables[rcnt].existing_match_ind = temp->qual[x].match_ind
    SET reply->orderables[rcnt].catalog_type.code_value = temp->qual[x].catalog_type.code_value
    SET reply->orderables[rcnt].catalog_type.display = temp->qual[x].catalog_type.display
    SET reply->orderables[rcnt].catalog_type.meaning = temp->qual[x].catalog_type.meaning
    SET reply->orderables[rcnt].activity_type.code_value = temp->qual[x].activity_type.code_value
    SET reply->orderables[rcnt].activity_type.display = temp->qual[x].activity_type.display
    SET reply->orderables[rcnt].activity_type.meaning = temp->qual[x].activity_type.meaning
    SET scnt = size(temp->qual[x].syn,5)
    FOR (y = 1 TO scnt)
     SET stat = alterlist(reply->orderables[rcnt].synonyms,y)
     SET reply->orderables[rcnt].synonyms[y].mnemonic = temp->qual[x].syn[y].mnemonic
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
END GO
