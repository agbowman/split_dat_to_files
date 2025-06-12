CREATE PROGRAM bed_get_sn_ord_by_surgarea:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 code_value = f8
     2 description = c100
     2 comments_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD ordtemp(
   1 orderables[*]
     2 code_value = f8
     2 description = c100
     2 comments_ind = i2
     2 allowed_ind = i2
 )
 SET reply->status_data.status = "F"
 SET surgery_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="SURGERY"
  DETAIL
   surgery_cd = cv.code_value
  WITH nocounter
 ;end select
 SET prsnl_comm_type_cd = 0.0
 SET prefcard_comm_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=16289
   AND cv.cdf_meaning="PRSNL"
   AND cv.active_ind=1
  DETAIL
   prsnl_comm_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16289
   AND cv.cdf_meaning="PREFCARD"
   AND cv.display_key="PREFERENCECARDCOMMENTS"
   AND cv.active_ind=1
  DETAIL
   prefcard_comm_type_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (prefcard_comm_type_cd=0.0)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=16289
    AND cv.cdf_meaning="PREFCARD"
    AND cv.display="*Preference*"
    AND cv.active_ind=1
   DETAIL
    prefcard_comm_type_cd = cv.code_value
   WITH nocounter
  ;end select
  IF (prefcard_comm_type_cd=0.0)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=16289
     AND cv.cdf_meaning="PREFCARD"
     AND cv.active_ind=1
    DETAIL
     prefcard_comm_type_cd = 0.0
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 DECLARE search_string = vc
 SET search_string = "*"
 IF ((request->search_type_flag="S"))
  SET search_string = concat('"',trim(request->search_string),'*"')
 ELSE
  SET search_string = concat('"*',trim(request->search_string),'*"')
 ENDIF
 SET search_string = cnvtupper(search_string)
 DECLARE oc_parse = vc
 SET oc_parse = build("oc.active_ind = 1 and oc.catalog_type_cd = ",surgery_cd)
 IF (search_string > "    ")
  SET oc_parse = concat(oc_parse," and cnvtupper(oc.description) = ",search_string)
 ENDIF
 SET ocnt = 0
 SET alterlist_ocnt = 0
 SET stat = alterlist(ordtemp->orderables,50)
 IF ((request->specialty_code_value=0.0))
  SELECT INTO "NL"
   FROM order_catalog oc,
    preference_card pc,
    sn_comment_text sct
   PLAN (oc
    WHERE parser(oc_parse))
    JOIN (pc
    WHERE pc.catalog_cd=outerjoin(oc.catalog_cd)
     AND pc.prsnl_id=outerjoin(request->surgeon_id)
     AND pc.surg_area_cd=outerjoin(request->surgery_area_code_value))
    JOIN (sct
    WHERE sct.root_id=outerjoin(pc.pref_card_id)
     AND sct.root_name=outerjoin("PREFERENCE_CARD")
     AND sct.surg_area_cd=outerjoin(request->surgery_area_code_value)
     AND sct.comment_type_cd=outerjoin(prefcard_comm_type_cd)
     AND sct.active_ind=outerjoin(1))
   ORDER BY oc.catalog_cd
   HEAD oc.catalog_cd
    ocnt = (ocnt+ 1), alterlist_ocnt = (alterlist_ocnt+ 1)
    IF (alterlist_ocnt > 50)
     stat = alterlist(ordtemp->orderables,(ocnt+ 50)), alterlist_ocnt = 1
    ENDIF
    ordtemp->orderables[ocnt].code_value = oc.catalog_cd, ordtemp->orderables[ocnt].description = oc
    .description, ordtemp->orderables[ocnt].allowed_ind = 0,
    ordtemp->orderables[ocnt].comments_ind = 0
   DETAIL
    IF (sct.sn_comment_id > 0)
     ordtemp->orderables[ocnt].comments_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "NL"
   FROM order_catalog oc,
    preference_card pc,
    sn_comment_text sct,
    surg_proc_detail spd,
    prsnl_group pg
   PLAN (oc
    WHERE parser(oc_parse))
    JOIN (spd
    WHERE spd.catalog_cd=oc.catalog_cd)
    JOIN (pg
    WHERE pg.prsnl_group_id=spd.surg_specialty_id
     AND (pg.prsnl_group_type_cd=request->specialty_code_value))
    JOIN (pc
    WHERE pc.catalog_cd=outerjoin(oc.catalog_cd)
     AND pc.prsnl_id=outerjoin(request->surgeon_id)
     AND pc.surg_area_cd=outerjoin(request->surgery_area_code_value))
    JOIN (sct
    WHERE sct.root_id=outerjoin(pc.pref_card_id)
     AND sct.root_name=outerjoin("PREFERENCE_CARD")
     AND sct.surg_area_cd=outerjoin(request->surgery_area_code_value)
     AND sct.comment_type_cd=outerjoin(prefcard_comm_type_cd)
     AND sct.active_ind=outerjoin(1))
   ORDER BY oc.catalog_cd
   HEAD oc.catalog_cd
    ocnt = (ocnt+ 1), alterlist_ocnt = (alterlist_ocnt+ 1)
    IF (alterlist_ocnt > 50)
     stat = alterlist(ordtemp->orderables,(ocnt+ 50)), alterlist_ocnt = 1
    ENDIF
    ordtemp->orderables[ocnt].code_value = oc.catalog_cd, ordtemp->orderables[ocnt].description = oc
    .description, ordtemp->orderables[ocnt].allowed_ind = 0,
    ordtemp->orderables[ocnt].comments_ind = 0
   DETAIL
    IF (sct.sn_comment_id > 0)
     ordtemp->orderables[ocnt].comments_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(ordtemp->orderables,ocnt)
 IF (ocnt > 0)
  SET fcnt = 0
  SET fcnt = size(request->facilities,5)
  IF (((fcnt=0) OR ((request->facilities[1].code_value=0.0))) )
   SET stat = alterlist(reply->orderables,ocnt)
   FOR (c = 1 TO ocnt)
     SET reply->orderables[c].code_value = ordtemp->orderables[c].code_value
     SET reply->orderables[c].description = ordtemp->orderables[c].description
     SET reply->orderables[c].comments_ind = ordtemp->orderables[c].comments_ind
   ENDFOR
  ELSE
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = ocnt),
     order_catalog_synonym ocs,
     ocs_facility_r ofr
    PLAN (d)
     JOIN (ocs
     WHERE (ocs.catalog_cd=ordtemp->orderables[d.seq].code_value)
      AND ocs.active_ind=1)
     JOIN (ofr
     WHERE ofr.synonym_id=ocs.synonym_id)
    DETAIL
     IF ((ordtemp->orderables[d.seq].allowed_ind=0))
      IF (ofr.facility_cd=0.0)
       ordtemp->orderables[d.seq].allowed_ind = 1
      ELSE
       FOR (f = 1 TO fcnt)
         IF ((ofr.facility_cd=request->facilities[f].code_value))
          ordtemp->orderables[d.seq].allowed_ind = 1
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET rcnt = 0
   SET alterlist_rcnt = 0
   SET stat = alterlist(reply->orderables,50)
   FOR (c = 1 TO ocnt)
     IF ((ordtemp->orderables[c].allowed_ind=1))
      SET rcnt = (rcnt+ 1)
      SET alterlist_rcnt = (alterlist_rcnt+ 1)
      IF (alterlist_rcnt > 50)
       SET stat = alterlist(reply->orderables,(rcnt+ 50))
       SET alterlist_rcnt = 1
      ENDIF
      SET reply->orderables[rcnt].code_value = ordtemp->orderables[c].code_value
      SET reply->orderables[rcnt].description = ordtemp->orderables[c].description
      SET reply->orderables[rcnt].comments_ind = ordtemp->orderables[c].comments_ind
     ENDIF
   ENDFOR
   SET stat = alterlist(reply->orderables,rcnt)
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
