CREATE PROGRAM bed_get_sn_orders_list:dba
 FREE SET reply
 RECORD reply(
   1 clist[*]
     2 catalog_code_value = f8
     2 description = c100
     2 nbr_pick_lists = i4
     2 nbr_rel_surgery_areas = i4
     2 active_ind = i2
     2 surgical_area_code_value = f8
     2 pref_card_specialty_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD ordtemp(
   1 oc_list[*]
     2 catalog_code_value = f8
     2 description = c100
     2 allowed_ind = i2
     2 active_ind = i2
     2 surgical_area_code_value = f8
     2 pref_card_specialty_id = f8
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
 CALL echo(oc_parse)
 SET ccnt = 0
 SET rcnt = 0
 SET alterlist_ccnt = 0
 SET stat = alterlist(ordtemp->oc_list,50)
 IF ((request->specialty_code_value=0.0)
  AND (request->load_only_orders_with_gen_cards=0))
  SELECT INTO "NL"
   FROM order_catalog oc
   WHERE parser(oc_parse)
   DETAIL
    ccnt = (ccnt+ 1), alterlist_ccnt = (alterlist_ccnt+ 1)
    IF (alterlist_ccnt > 50)
     stat = alterlist(ordtemp->oc_list,(ccnt+ 50)), alterlist_ccnt = 1
    ENDIF
    ordtemp->oc_list[ccnt].catalog_code_value = oc.catalog_cd, ordtemp->oc_list[ccnt].description =
    oc.description, ordtemp->oc_list[ccnt].allowed_ind = 0
   WITH nocounter
  ;end select
 ELSEIF ((request->specialty_code_value=0.0)
  AND (request->load_only_orders_with_gen_cards=1))
  SELECT INTO "NL"
   FROM order_catalog oc,
    preference_card pc
   PLAN (oc
    WHERE parser(oc_parse))
    JOIN (pc
    WHERE pc.catalog_cd=oc.catalog_cd
     AND pc.prsnl_id=0.0)
   ORDER BY pc.catalog_cd
   DETAIL
    ccnt = (ccnt+ 1), alterlist_ccnt = (alterlist_ccnt+ 1)
    IF (alterlist_ccnt > 50)
     stat = alterlist(ordtemp->oc_list,(ccnt+ 50)), alterlist_ccnt = 1
    ENDIF
    ordtemp->oc_list[ccnt].catalog_code_value = pc.catalog_cd, ordtemp->oc_list[ccnt].description =
    oc.description, ordtemp->oc_list[ccnt].allowed_ind = 0,
    ordtemp->oc_list[ccnt].active_ind = pc.active_ind, ordtemp->oc_list[ccnt].
    surgical_area_code_value = pc.surg_area_cd, ordtemp->oc_list[ccnt].pref_card_specialty_id = pc
    .surg_specialty_id
   WITH nocounter
  ;end select
 ELSEIF ((request->specialty_code_value > 0.0)
  AND (request->load_only_orders_with_gen_cards=0))
  SELECT INTO "NL"
   FROM order_catalog oc,
    surg_proc_detail spd,
    prsnl_group pg
   PLAN (oc
    WHERE parser(oc_parse))
    JOIN (spd
    WHERE spd.catalog_cd=oc.catalog_cd)
    JOIN (pg
    WHERE pg.prsnl_group_id=spd.surg_specialty_id
     AND (pg.prsnl_group_type_cd=request->specialty_code_value))
   ORDER BY spd.catalog_cd
   HEAD spd.catalog_cd
    ccnt = (ccnt+ 1), alterlist_ccnt = (alterlist_ccnt+ 1)
    IF (alterlist_ccnt > 50)
     stat = alterlist(ordtemp->oc_list,(ccnt+ 50)), alterlist_ccnt = 1
    ENDIF
    ordtemp->oc_list[ccnt].catalog_code_value = spd.catalog_cd, ordtemp->oc_list[ccnt].description =
    oc.description, ordtemp->oc_list[ccnt].allowed_ind = 0
   WITH nocounter
  ;end select
 ELSEIF ((request->specialty_code_value > 0.0)
  AND (request->load_only_orders_with_gen_cards=1))
  SELECT INTO "NL"
   FROM order_catalog oc,
    preference_card pc,
    surg_proc_detail spd,
    prsnl_group pg
   PLAN (oc
    WHERE parser(oc_parse))
    JOIN (pc
    WHERE pc.catalog_cd=oc.catalog_cd
     AND pc.prsnl_id=0.0)
    JOIN (spd
    WHERE spd.catalog_cd=pc.catalog_cd)
    JOIN (pg
    WHERE pg.prsnl_group_id=spd.surg_specialty_id
     AND (pg.prsnl_group_type_cd=request->specialty_code_value))
   ORDER BY spd.catalog_cd
   HEAD spd.catalog_cd
    ccnt = (ccnt+ 1), alterlist_ccnt = (alterlist_ccnt+ 1)
    IF (alterlist_ccnt > 50)
     stat = alterlist(ordtemp->oc_list,(ccnt+ 50)), alterlist_ccnt = 1
    ENDIF
    ordtemp->oc_list[ccnt].catalog_code_value = spd.catalog_cd, ordtemp->oc_list[ccnt].description =
    oc.description, ordtemp->oc_list[ccnt].allowed_ind = 0,
    ordtemp->oc_list[ccnt].pref_card_specialty_id = pc.surg_specialty_id
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(ordtemp->oc_list,ccnt)
 IF (ccnt > 0)
  SET fcnt = 0
  SET fcnt = size(request->flist,5)
  IF (((fcnt=0) OR ((request->flist[1].facility_code_value=0.0))) )
   SET stat = alterlist(reply->clist,ccnt)
   FOR (c = 1 TO ccnt)
     SET reply->clist[c].catalog_code_value = ordtemp->oc_list[c].catalog_code_value
     SET reply->clist[c].description = ordtemp->oc_list[c].description
     SET reply->clist[c].active_ind = ordtemp->oc_list[c].active_ind
     SET reply->clist[c].surgical_area_code_value = ordtemp->oc_list[c].surgical_area_code_value
     SET reply->clist[c].pref_card_specialty_id = ordtemp->oc_list[c].pref_card_specialty_id
   ENDFOR
   SET rcnt = ccnt
  ELSE
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = ccnt),
     order_catalog_synonym ocs,
     ocs_facility_r ofr
    PLAN (d)
     JOIN (ocs
     WHERE (ocs.catalog_cd=ordtemp->oc_list[d.seq].catalog_code_value)
      AND ocs.active_ind=1)
     JOIN (ofr
     WHERE ofr.synonym_id=ocs.synonym_id)
    DETAIL
     IF ((ordtemp->oc_list[d.seq].allowed_ind=0))
      IF (ofr.facility_cd=0.0)
       ordtemp->oc_list[d.seq].allowed_ind = 1
      ELSE
       FOR (f = 1 TO fcnt)
         IF ((ofr.facility_cd=request->flist[f].facility_code_value))
          ordtemp->oc_list[d.seq].allowed_ind = 1
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET rcnt = 0
   SET alterlist_rcnt = 0
   SET stat = alterlist(reply->clist,50)
   FOR (c = 1 TO ccnt)
     IF ((ordtemp->oc_list[c].allowed_ind=1))
      SET rcnt = (rcnt+ 1)
      SET alterlist_rcnt = (alterlist_rcnt+ 1)
      IF (alterlist_rcnt > 50)
       SET stat = alterlist(reply->clist,(rcnt+ 50))
       SET alterlist_rcnt = 1
      ENDIF
      SET reply->clist[rcnt].catalog_code_value = ordtemp->oc_list[c].catalog_code_value
      SET reply->clist[rcnt].description = ordtemp->oc_list[c].description
      SET reply->clist[c].active_ind = ordtemp->oc_list[c].active_ind
      SET reply->clist[c].surgical_area_code_value = ordtemp->oc_list[c].surgical_area_code_value
      SET reply->clist[c].pref_card_specialty_id = ordtemp->oc_list[c].pref_card_specialty_id
     ENDIF
   ENDFOR
   SET stat = alterlist(reply->clist,rcnt)
  ENDIF
 ENDIF
 IF (rcnt > 0)
  IF (fcnt > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = rcnt),
     preference_card pc,
     code_value cv,
     sn_doc_ref sdr,
     code_value cvsdr,
     service_resource sr,
     location loc1,
     location loc2,
     code_value cv2,
     pref_card_pick_list pl
    PLAN (d)
     JOIN (pc
     WHERE (pc.catalog_cd=reply->clist[d.seq].catalog_code_value)
      AND (pc.prsnl_id=request->surgeon_id)
      AND pc.surg_area_cd > 0)
     JOIN (cv
     WHERE cv.code_value=pc.surg_area_cd
      AND cv.active_ind=1)
     JOIN (sdr
     WHERE sdr.area_cd=cv.code_value)
     JOIN (cvsdr
     WHERE cvsdr.code_set=14258
      AND cvsdr.code_value=sdr.doc_type_cd
      AND cvsdr.cdf_meaning="ORNURSE"
      AND cvsdr.active_ind=1)
     JOIN (sr
     WHERE sr.service_resource_cd=cv.code_value
      AND sr.active_ind=1)
     JOIN (loc1
     WHERE loc1.location_cd=sr.location_cd
      AND loc1.active_ind=1)
     JOIN (loc2
     WHERE loc2.organization_id=loc1.organization_id
      AND loc2.active_ind=1)
     JOIN (cv2
     WHERE cv2.code_value=loc2.location_cd
      AND cv2.code_set=220
      AND cv2.cdf_meaning="FACILITY"
      AND cv2.active_ind=1)
     JOIN (pl
     WHERE pl.pref_card_id=pc.pref_card_id
      AND pl.active_ind=1)
    ORDER BY pl.pref_card_id
    HEAD pl.pref_card_id
     FOR (f = 1 TO fcnt)
       IF ((cv2.code_value=request->flist[f].facility_code_value))
        reply->clist[d.seq].nbr_pick_lists = (reply->clist[d.seq].nbr_pick_lists+ 1)
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = rcnt),
     preference_card pc,
     code_value cv,
     sn_doc_ref sdr,
     code_value cvsdr,
     pref_card_pick_list pl
    PLAN (d)
     JOIN (pc
     WHERE (pc.catalog_cd=reply->clist[d.seq].catalog_code_value)
      AND (pc.prsnl_id=request->surgeon_id)
      AND pc.surg_area_cd > 0)
     JOIN (cv
     WHERE cv.code_value=pc.surg_area_cd
      AND cv.active_ind=1)
     JOIN (sdr
     WHERE sdr.area_cd=cv.code_value)
     JOIN (cvsdr
     WHERE cvsdr.code_set=14258
      AND cvsdr.code_value=sdr.doc_type_cd
      AND cvsdr.cdf_meaning="ORNURSE"
      AND cvsdr.active_ind=1)
     JOIN (pl
     WHERE pl.pref_card_id=pc.pref_card_id
      AND pl.active_ind=1)
    ORDER BY pl.pref_card_id
    HEAD pl.pref_card_id
     reply->clist[d.seq].nbr_pick_lists = (reply->clist[d.seq].nbr_pick_lists+ 1)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (rcnt > 0)
  IF (fcnt > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = rcnt),
     surg_proc_detail spd,
     code_value cv,
     sn_doc_ref sdr,
     code_value cvsdr,
     service_resource sr,
     location loc1,
     location loc2,
     code_value cv2
    PLAN (d)
     JOIN (spd
     WHERE (spd.catalog_cd=reply->clist[d.seq].catalog_code_value)
      AND spd.surg_area_cd > 0)
     JOIN (cv
     WHERE cv.code_value=spd.surg_area_cd
      AND cv.active_ind=1)
     JOIN (sdr
     WHERE sdr.area_cd=cv.code_value)
     JOIN (cvsdr
     WHERE cvsdr.code_set=14258
      AND cvsdr.code_value=sdr.doc_type_cd
      AND cvsdr.cdf_meaning="ORNURSE"
      AND cvsdr.active_ind=1)
     JOIN (sr
     WHERE sr.service_resource_cd=cv.code_value
      AND sr.active_ind=1)
     JOIN (loc1
     WHERE loc1.location_cd=sr.location_cd
      AND loc1.active_ind=1)
     JOIN (loc2
     WHERE loc2.organization_id=loc1.organization_id
      AND loc2.active_ind=1)
     JOIN (cv2
     WHERE cv2.code_value=loc2.location_cd
      AND cv2.code_set=220
      AND cv2.cdf_meaning="FACILITY"
      AND cv2.active_ind=1)
    DETAIL
     FOR (f = 1 TO fcnt)
       IF ((cv2.code_value=request->flist[f].facility_code_value))
        reply->clist[d.seq].nbr_rel_surgery_areas = (reply->clist[d.seq].nbr_rel_surgery_areas+ 1)
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = rcnt),
     surg_proc_detail spd,
     code_value cv,
     sn_doc_ref sdr,
     code_value cvsdr
    PLAN (d)
     JOIN (spd
     WHERE (spd.catalog_cd=reply->clist[d.seq].catalog_code_value)
      AND spd.surg_area_cd > 0)
     JOIN (cv
     WHERE cv.code_value=spd.surg_area_cd
      AND cv.active_ind=1)
     JOIN (sdr
     WHERE sdr.area_cd=cv.code_value)
     JOIN (cvsdr
     WHERE cvsdr.code_set=14258
      AND cvsdr.code_value=sdr.doc_type_cd
      AND cvsdr.cdf_meaning="ORNURSE"
      AND cvsdr.active_ind=1)
    DETAIL
     reply->clist[d.seq].nbr_rel_surgery_areas = (reply->clist[d.seq].nbr_rel_surgery_areas+ 1)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
