CREATE PROGRAM bed_get_sn_surgarea_by_ord:dba
 FREE SET reply
 RECORD reply(
   1 slist1[*]
     2 surg_area_code_value = f8
     2 surg_area_display = c40
     2 pick_list_created_ind = i2
     2 specialties[*]
       3 id = f8
       3 name = vc
       3 pick_list_created_ind = i2
   1 slist2[*]
     2 surg_area_code_value = f8
     2 surg_area_display = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 slist[*]
     2 surg_area_code_value = f8
     2 surg_area_display = c40
     2 related_ind = i2
     2 pick_list_created_ind = i2
     2 allowed_by_fac_ind = i2
     2 specialties[*]
       3 id = f8
       3 name = vc
       3 pick_list_created_ind = i2
 )
 SET reply->status_data.status = "F"
 SET return_specialties_ind = 0
 IF (validate(request->return_specialties_ind))
  SET return_specialties_ind = request->return_specialties_ind
 ENDIF
 SET tcnt = 0
 SET alterlist_tcnt = 0
 SET stat = alterlist(temp->slist,50)
 IF ((request->return_other_areas_ind=1))
  SELECT INTO "NL:"
   FROM code_value cv,
    surg_proc_detail spd,
    sn_doc_ref sdr,
    code_value cv2
   PLAN (cv
    WHERE cv.code_set=221
     AND cv.cdf_meaning="SURGAREA"
     AND cv.active_ind=1)
    JOIN (sdr
    WHERE sdr.area_cd=cv.code_value)
    JOIN (cv2
    WHERE cv2.code_set=14258
     AND cv2.code_value=sdr.doc_type_cd
     AND cv2.cdf_meaning="ORNURSE"
     AND cv2.active_ind=1)
    JOIN (spd
    WHERE spd.catalog_cd=outerjoin(request->catalog_code_value)
     AND spd.surg_area_cd=outerjoin(cv.code_value))
   DETAIL
    tcnt = (tcnt+ 1), alterlist_tcnt = (alterlist_tcnt+ 1)
    IF (alterlist_tcnt > 50)
     stat = alterlist(temp->slist,(tcnt+ 50)), alterlist_tcnt = 1
    ENDIF
    temp->slist[tcnt].surg_area_code_value = cv.code_value, temp->slist[tcnt].surg_area_display = cv
    .display, temp->slist[tcnt].allowed_by_fac_ind = 1,
    temp->slist[tcnt].pick_list_created_ind = 0
    IF (spd.catalog_cd > 0
     AND spd.surg_area_cd > 0)
     temp->slist[tcnt].related_ind = 1
    ELSE
     temp->slist[tcnt].related_ind = 0
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "NL:"
   FROM surg_proc_detail spd,
    code_value cv,
    sn_doc_ref sdr,
    code_value cv2
   PLAN (spd
    WHERE (spd.catalog_cd=request->catalog_code_value))
    JOIN (cv
    WHERE cv.code_value=spd.surg_area_cd
     AND cv.active_ind=1)
    JOIN (sdr
    WHERE sdr.area_cd=cv.code_value)
    JOIN (cv2
    WHERE cv2.code_set=14258
     AND cv2.code_value=sdr.doc_type_cd
     AND cv2.cdf_meaning="ORNURSE"
     AND cv2.active_ind=1)
   ORDER BY cv.code_value
   HEAD cv.code_value
    tcnt = (tcnt+ 1), alterlist_tcnt = (alterlist_tcnt+ 1)
    IF (alterlist_tcnt > 50)
     stat = alterlist(temp->slist,(tcnt+ 50)), alterlist_tcnt = 1
    ENDIF
    temp->slist[tcnt].surg_area_code_value = cv.code_value, temp->slist[tcnt].surg_area_display = cv
    .display, temp->slist[tcnt].allowed_by_fac_ind = 1,
    temp->slist[tcnt].related_ind = 1, temp->slist[tcnt].pick_list_created_ind = 0
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(temp->slist,tcnt)
 IF (tcnt > 0)
  IF (return_specialties_ind=0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = tcnt),
     preference_card pc,
     pref_card_pick_list pl
    PLAN (d)
     JOIN (pc
     WHERE (pc.catalog_cd=request->catalog_code_value)
      AND (pc.surg_area_cd=temp->slist[d.seq].surg_area_code_value)
      AND (pc.prsnl_id=request->surgeon_id))
     JOIN (pl
     WHERE pl.pref_card_id=pc.pref_card_id
      AND pl.active_ind=1)
    DETAIL
     temp->slist[d.seq].pick_list_created_ind = 1
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = tcnt),
     preference_card pc,
     pref_card_pick_list pl,
     prsnl_group pg
    PLAN (d)
     JOIN (pc
     WHERE (pc.catalog_cd=request->catalog_code_value)
      AND (pc.surg_area_cd=temp->slist[d.seq].surg_area_code_value)
      AND (pc.prsnl_id=request->surgeon_id))
     JOIN (pl
     WHERE pl.pref_card_id=pc.pref_card_id
      AND pl.active_ind=1)
     JOIN (pg
     WHERE pg.prsnl_group_id=outerjoin(pc.surg_specialty_id)
      AND pg.active_ind=outerjoin(1))
    ORDER BY pc.surg_area_cd, pc.surg_specialty_id
    HEAD pc.surg_area_cd
     spectot = 0
    HEAD pc.surg_specialty_id
     spectot = (spectot+ 1), stat = alterlist(temp->slist[d.seq].specialties,spectot), temp->slist[d
     .seq].specialties[spectot].id = pc.surg_specialty_id,
     temp->slist[d.seq].specialties[spectot].name = pg.prsnl_group_name
    DETAIL
     temp->slist[d.seq].specialties[spectot].pick_list_created_ind = 1
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (tcnt > 0)
  SET fcnt = 0
  SET fcnt = size(request->flist,5)
  IF (fcnt > 0
   AND (request->flist[1].facility_code_value > 0.0))
   FOR (t = 1 TO tcnt)
    SET temp->slist[t].allowed_by_fac_ind = 0
    SELECT INTO "NL:"
     FROM service_resource sr,
      location loc1,
      location loc2,
      code_value cv
     PLAN (sr
      WHERE (sr.service_resource_cd=temp->slist[t].surg_area_code_value)
       AND sr.active_ind=1)
      JOIN (loc1
      WHERE loc1.location_cd=sr.location_cd
       AND loc1.active_ind=1)
      JOIN (loc2
      WHERE loc2.organization_id=loc1.organization_id
       AND loc2.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=loc2.location_cd
       AND cv.code_set=220
       AND cv.cdf_meaning="FACILITY"
       AND cv.active_ind=1)
     DETAIL
      FOR (f = 1 TO fcnt)
        IF ((cv.code_value=request->flist[f].facility_code_value))
         temp->slist[t].allowed_by_fac_ind = 1
        ENDIF
      ENDFOR
     WITH nocounter
    ;end select
   ENDFOR
  ENDIF
 ENDIF
 SET scnt1 = 0
 SET rcnt1 = 0
 SET alterlist_scnt1 = 0
 SET stat = alterlist(reply->slist1,50)
 SET scnt2 = 0
 SET rcnt2 = 0
 SET alterlist_scnt2 = 0
 SET stat = alterlist(reply->slist2,50)
 IF (tcnt > 0)
  FOR (t = 1 TO tcnt)
    IF ((temp->slist[t].allowed_by_fac_ind=1))
     IF ((temp->slist[t].related_ind=1))
      SET scnt1 = (scnt1+ 1)
      SET alterlist_scnt1 = (alterlist_scnt1+ 1)
      IF (alterlist_scnt1 > 50)
       SET stat = alterlist(reply->slist1,(scnt1+ 50))
       SET alterlist_scnt1 = 1
      ENDIF
      SET reply->slist1[scnt1].surg_area_code_value = temp->slist[t].surg_area_code_value
      SET reply->slist1[scnt1].surg_area_display = temp->slist[t].surg_area_display
      SET reply->slist1[scnt1].pick_list_created_ind = temp->slist[t].pick_list_created_ind
      IF (return_specialties_ind=1)
       SET speccnt = size(temp->slist[t].specialties,5)
       SET stat = alterlist(reply->slist1[scnt1].specialties,speccnt)
       FOR (s = 1 TO speccnt)
         SET reply->slist1[scnt1].specialties[s].id = temp->slist[t].specialties[s].id
         SET reply->slist1[scnt1].specialties[s].name = temp->slist[t].specialties[s].name
         SET reply->slist1[scnt1].specialties[s].pick_list_created_ind = temp->slist[t].specialties[s
         ].pick_list_created_ind
       ENDFOR
      ENDIF
     ELSE
      SET scnt2 = (scnt2+ 1)
      SET alterlist_scnt2 = (alterlist_scnt2+ 1)
      IF (alterlist_scnt2 > 50)
       SET stat = alterlist(reply->slist1,(scnt2+ 50))
       SET alterlist_scnt2 = 1
      ENDIF
      SET reply->slist2[scnt2].surg_area_code_value = temp->slist[t].surg_area_code_value
      SET reply->slist2[scnt2].surg_area_display = temp->slist[t].surg_area_display
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SET stat = alterlist(reply->slist1,scnt1)
 SET stat = alterlist(reply->slist2,scnt2)
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
