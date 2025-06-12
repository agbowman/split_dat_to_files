CREATE PROGRAM bed_get_alias_from_oc_match:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
     2 description = vc
     2 alias1 = vc
     2 alias2 = vc
     2 alias3 = vc
     2 alias4 = vc
     2 alias5 = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 orderables[*]
     2 oc_id = f8
     2 match_orderable_cd = f8
     2 catalog_cd = f8
     2 display = vc
     2 mean = vc
     2 description = vc
     2 alias1 = vc
     2 alias2 = vc
     2 alias3 = vc
     2 alias4 = vc
     2 alias5 = vc
 )
 SET reply->status_data.status = "F"
 DECLARE bow_parse = vc
 SET bow_parse = " bow.match_orderable_cd > 0"
 IF ((request->facility > " "))
  IF ((request->facility="<facility not defined>"))
   SET bow_parse = build2(bow_parse," and bow.facility = ' '")
  ELSE
   SET bow_parse = build2(bow_parse," and bow.facility = request->facility")
  ENDIF
 ENDIF
 DECLARE oc_parse = vc
 SET oc_parse = build2(" oc.catalog_type_cd = outerjoin(",request->catalog_type_code_value,")",
  " and oc.activity_type_cd = outerjoin(",request->activity_type_code_value,
  ")"," and oc.active_ind = outerjoin(1)")
 IF ((request->subactivity_type_code_value > 0))
  SET oc_parse = build2(oc_parse," and oc.activity_subtype_cd = outerjoin(",request->
   subactivity_type_code_value,")")
 ENDIF
 SET oc_match_not_found_ind = 0
 SET ocnt = 0
 SELECT INTO "NL:"
  FROM br_oc_work bow,
   order_catalog oc,
   code_value cv
  PLAN (bow
   WHERE parser(bow_parse)
    AND ((bow.alias1 > " ") OR (((bow.alias2 > " ") OR (((bow.alias3 > " ") OR (((bow.alias4 > " ")
    OR (bow.alias5 > " ")) )) )) )) )
   JOIN (oc
   WHERE parser(oc_parse)
    AND oc.catalog_cd=outerjoin(bow.match_orderable_cd))
   JOIN (cv
   WHERE cv.code_value=outerjoin(oc.catalog_cd)
    AND cv.active_ind=outerjoin(1))
  ORDER BY bow.match_orderable_cd
  DETAIL
   ocnt = (ocnt+ 1), stat = alterlist(temp->orderables,ocnt), temp->orderables[ocnt].oc_id = bow
   .oc_id,
   temp->orderables[ocnt].match_orderable_cd = bow.match_orderable_cd, temp->orderables[ocnt].alias1
    = bow.alias1, temp->orderables[ocnt].alias2 = bow.alias2,
   temp->orderables[ocnt].alias3 = bow.alias3, temp->orderables[ocnt].alias4 = bow.alias4, temp->
   orderables[ocnt].alias5 = bow.alias5
   IF (cv.code_value > 0)
    temp->orderables[ocnt].catalog_cd = cv.code_value, temp->orderables[ocnt].display = cv.display,
    temp->orderables[ocnt].mean = cv.cdf_meaning,
    temp->orderables[ocnt].description = cv.description
   ELSE
    oc_match_not_found_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (oc_match_not_found_ind=1)
  DECLARE oc_parse = vc
  SET oc_parse = build2(" oc.catalog_type_cd = ",request->catalog_type_code_value,
   " and oc.activity_type_cd = ",request->activity_type_code_value," and oc.active_ind = 1")
  IF ((request->subactivity_type_code_value > 0))
   SET oc_parse = build2(oc_parse," and oc.activity_subtype_cd = ",request->
    subactivity_type_code_value)
  ENDIF
  SET new_phasex_match_ind = 0
  SELECT INTO "NL:"
   FROM br_name_value bnv,
    dummyt d
   PLAN (bnv
    WHERE bnv.br_nv_key1="NEW_PHASE_X_MATCH")
    JOIN (d
    WHERE (cnvtreal(bnv.br_name)=request->catalog_type_code_value)
     AND (cnvtreal(bnv.br_value)=request->activity_type_code_value))
   DETAIL
    new_phasex_match_ind = 1
   WITH nocounter
  ;end select
  IF (new_phasex_match_ind=1)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = ocnt),
     br_name_value bnv,
     order_catalog oc,
     code_value cv
    PLAN (d
     WHERE (temp->orderables[d.seq].catalog_cd=0))
     JOIN (bnv
     WHERE bnv.br_nv_key1="PHASE_X_MATCH"
      AND (cnvtreal(bnv.br_name)=temp->orderables[d.seq].oc_id))
     JOIN (oc
     WHERE parser(oc_parse)
      AND oc.catalog_cd=cnvtreal(bnv.br_value))
     JOIN (cv
     WHERE cv.code_value=oc.catalog_cd
      AND cv.active_ind=1)
    DETAIL
     temp->orderables[d.seq].catalog_cd = cv.code_value, temp->orderables[d.seq].display = cv.display,
     temp->orderables[d.seq].mean = cv.cdf_meaning,
     temp->orderables[d.seq].description = cv.description
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = ocnt),
     br_auto_order_catalog baoc,
     order_catalog oc,
     code_value cv
    PLAN (d
     WHERE (temp->orderables[d.seq].catalog_cd=0))
     JOIN (baoc
     WHERE (baoc.catalog_cd=temp->orderables[d.seq].match_orderable_cd))
     JOIN (oc
     WHERE parser(oc_parse)
      AND oc.concept_cki=baoc.concept_cki)
     JOIN (cv
     WHERE cv.code_value=oc.catalog_cd
      AND cv.active_ind=1)
    DETAIL
     temp->orderables[d.seq].catalog_cd = cv.code_value, temp->orderables[d.seq].display = cv.display,
     temp->orderables[d.seq].mean = cv.cdf_meaning,
     temp->orderables[d.seq].description = cv.description
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET rcnt = 0
 FOR (o = 1 TO ocnt)
   IF ((temp->orderables[o].catalog_cd > 0))
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->orderables,rcnt)
    SET reply->orderables[rcnt].code_value = temp->orderables[o].catalog_cd
    SET reply->orderables[rcnt].display = temp->orderables[o].display
    SET reply->orderables[rcnt].mean = temp->orderables[o].mean
    SET reply->orderables[rcnt].description = temp->orderables[o].description
    SET reply->orderables[rcnt].alias1 = temp->orderables[o].alias1
    SET reply->orderables[rcnt].alias2 = temp->orderables[o].alias2
    SET reply->orderables[rcnt].alias3 = temp->orderables[o].alias3
    SET reply->orderables[rcnt].alias4 = temp->orderables[o].alias4
    SET reply->orderables[rcnt].alias5 = temp->orderables[o].alias5
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
