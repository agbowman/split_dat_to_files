CREATE PROGRAM bed_get_sn_ord_surgarea_rel:dba
 FREE SET reply
 RECORD reply(
   1 slist1[*]
     2 surg_area_code_value = f8
     2 surg_area_display = c40
     2 gen_card_created_ind = i2
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
     2 gen_card_created_ind = i2
     2 allowed_by_fac_ind = i2
 )
 SET reply->status_data.status = "F"
 SET tcnt = 0
 SET alterlist_tcnt = 0
 SET stat = alterlist(temp->slist,50)
 IF ((request->return_other_areas_ind=1))
  SELECT INTO "NL:"
   FROM code_value cv,
    surg_proc_detail spd,
    preference_card pc
   PLAN (cv
    WHERE cv.code_set=220
     AND cv.cdf_meaning="ANCILSURG"
     AND cv.active_ind=1)
    JOIN (spd
    WHERE spd.catalog_cd=outerjoin(request->catalog_code_value)
     AND spd.surg_area_cd=outerjoin(cv.code_value))
    JOIN (pc
    WHERE pc.catalog_cd=outerjoin(request->catalog_code_value)
     AND pc.surg_specialty_id=outerjoin(0.0)
     AND pc.surg_area_cd=outerjoin(cv.code_value)
     AND pc.prsnl_id=outerjoin(0.0)
     AND pc.active_ind=outerjoin(1))
   DETAIL
    tcnt = (tcnt+ 1), alterlist_tcnt = (alterlist_tcnt+ 1)
    IF (alterlist_tcnt > 50)
     stat = alterlist(temp->slist,(tcnt+ 50)), alterlist_tcnt = 1
    ENDIF
    temp->slist[tcnt].surg_area_code_value = cv.code_value, temp->slist[tcnt].surg_area_display = cv
    .display, temp->slist[tcnt].allowed_by_fac_ind = 1
    IF (spd.catalog_cd > 0
     AND spd.surg_area_cd > 0)
     temp->slist[tcnt].related_ind = 1
     IF (pc.catalog_cd > 0
      AND pc.surg_area_cd > 0)
      temp->slist[tcnt].gen_card_created_ind = 1
     ELSE
      temp->slist[tcnt].gen_card_created_ind = 0
     ENDIF
    ELSE
     temp->slist[tcnt].related_ind = 0, temp->slist[tcnt].gen_card_created_ind = 0
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "NL:"
   FROM surg_proc_detail spd,
    code_value cv,
    preference_card pc
   PLAN (spd
    WHERE (spd.catalog_cd=request->catalog_code_value))
    JOIN (cv
    WHERE cv.code_value=spd.surg_area_cd
     AND cv.code_set=220
     AND cv.cdf_meaning="ANCILSURG"
     AND cv.active_ind=1)
    JOIN (pc
    WHERE pc.catalog_cd=outerjoin(request->catalog_code_value)
     AND pc.surg_specialty_id=outerjoin(0.0)
     AND pc.surg_area_cd=outerjoin(cv.code_value)
     AND pc.prsnl_id=outerjoin(0.0)
     AND pc.active_ind=outerjoin(1))
   ORDER BY cv.code_value, pc.surg_area_cd
   HEAD cv.code_value
    tcnt = (tcnt+ 1), alterlist_tcnt = (alterlist_tcnt+ 1)
    IF (alterlist_tcnt > 50)
     stat = alterlist(temp->slist,(tcnt+ 50)), alterlist_tcnt = 1
    ENDIF
    temp->slist[tcnt].surg_area_code_value = cv.code_value, temp->slist[tcnt].surg_area_display = cv
    .display, temp->slist[tcnt].allowed_by_fac_ind = 1,
    temp->slist[tcnt].related_ind = 1
   HEAD pc.surg_area_cd
    IF (pc.surg_area_cd > 0.0)
     temp->slist[tcnt].gen_card_created_ind = 1
    ELSE
     temp->slist[tcnt].gen_card_created_ind = 0
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(temp->slist,tcnt)
 IF (tcnt > 0)
  SET fcnt = 0
  SET fcnt = size(request->flist,5)
  IF (fcnt > 0
   AND (request->flist[1].facility_code_value > 0.0))
   FOR (t = 1 TO tcnt)
    SET temp->slist[t].allowed_by_fac_ind = 0
    SELECT INTO "NL:"
     FROM location loc1,
      location loc2,
      code_value cv
     PLAN (loc1
      WHERE (loc1.location_cd=temp->slist[t].surg_area_code_value)
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
      SET reply->slist1[scnt1].gen_card_created_ind = temp->slist[t].gen_card_created_ind
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
