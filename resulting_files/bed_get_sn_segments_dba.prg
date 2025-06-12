CREATE PROGRAM bed_get_sn_segments:dba
 FREE SET reply
 RECORD reply(
   1 surgery_areas[*]
     2 code_value = f8
     2 display = c40
     2 segments[*]
       3 code_value = f8
       3 display = c40
       3 mean = c12
       3 required_ind = i2
       3 selected_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 surgery_areas[*]
     2 code_value = f8
     2 display = c40
 )
 RECORD doccodes(
   1 codes[*]
     2 ornursecode = f8
 )
 SET reply->status_data.status = "F"
 SET tcnt = 0
 SET alterlist_tcnt = 0
 SET stat = alterlist(temp->surgery_areas,10)
 SELECT INTO "NL:"
  FROM surg_proc_detail spd,
   code_value cv,
   sn_doc_ref sdr,
   code_value cv2
  PLAN (spd
   WHERE (spd.catalog_cd=request->procedure_code_value))
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
  DETAIL
   alterlist_tcnt = (alterlist_tcnt+ 1)
   IF (alterlist_tcnt > 10)
    stat = alterlist(temp->surgery_areas,(tcnt+ 10)), alterlist_tcnt = 1
   ENDIF
   tcnt = (tcnt+ 1), temp->surgery_areas[tcnt].code_value = cv.code_value, temp->surgery_areas[tcnt].
   display = cv.display
  WITH nocounter
 ;end select
 SET stat = alterlist(temp->surgery_areas,tcnt)
 SET rcnt = 0
 IF (tcnt > 0)
  SET fcnt = 0
  SET fcnt = size(request->facilities,5)
  IF (fcnt > 0
   AND (request->facilities[1].code_value > 0.0))
   SET alterlist_rcnt = 0
   SET stat = alterlist(reply->surgery_areas,50)
   FOR (t = 1 TO tcnt)
     SELECT INTO "NL:"
      FROM service_resource sr,
       location loc1,
       location loc2,
       code_value cv
      PLAN (sr
       WHERE (sr.service_resource_cd=temp->surgery_areas[t].code_value)
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
         IF ((cv.code_value=request->facilities[f].code_value))
          alterlist_rcnt = (alterlist_rcnt+ 1)
          IF (alterlist_rcnt > 50)
           stat = alterlist(reply->surgery_areas,(rcnt+ 50)), alterlist_rcnt = 1
          ENDIF
          rcnt = (rcnt+ 1), reply->surgery_areas[rcnt].code_value = temp->surgery_areas[t].code_value,
          reply->surgery_areas[rcnt].display = temp->surgery_areas[t].display
         ENDIF
       ENDFOR
      WITH nocounter
     ;end select
   ENDFOR
   SET stat = alterlist(reply->surgery_areas,rcnt)
  ELSE
   SET stat = alterlist(reply->surgery_areas,tcnt)
   FOR (t = 1 TO tcnt)
    SET reply->surgery_areas[t].code_value = temp->surgery_areas[t].code_value
    SET reply->surgery_areas[t].display = temp->surgery_areas[t].display
   ENDFOR
   SET rcnt = tcnt
  ENDIF
 ENDIF
 IF (rcnt > 0)
  SET dcnt = 0
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = rcnt),
    segment_reference sr,
    code_value cv,
    sn_doc_ref sdr,
    code_value cv2
   PLAN (d)
    JOIN (sdr
    WHERE (sdr.area_cd=reply->surgery_areas[d.seq].code_value))
    JOIN (cv2
    WHERE cv2.code_value=sdr.doc_type_cd
     AND cv2.code_set=14258
     AND cv2.cdf_meaning="ORNURSE"
     AND cv2.active_ind=1)
    JOIN (sr
    WHERE (sr.surg_area_cd=reply->surgery_areas[d.seq].code_value)
     AND sr.doc_type_cd=cv2.code_value
     AND sr.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=sr.seg_cd
     AND cv.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    scnt = 0, alterlist_scnt = 0, stat = alterlist(reply->surgery_areas[d.seq].segments,5),
    dcnt = (dcnt+ 1), stat = alterlist(doccodes->codes,dcnt), doccodes->codes[dcnt].ornursecode = cv2
    .code_value
   DETAIL
    alterlist_scnt = (alterlist_scnt+ 1)
    IF (alterlist_scnt > 5)
     stat = alterlist(reply->surgery_areas[d.seq].segments,(scnt+ 5)), alterlist_scnt = 1
    ENDIF
    scnt = (scnt+ 1), reply->surgery_areas[d.seq].segments[scnt].code_value = cv.code_value, reply->
    surgery_areas[d.seq].segments[scnt].display = cv.display,
    reply->surgery_areas[d.seq].segments[scnt].mean = cv.cdf_meaning
    IF (sr.seg_req_flag=2)
     reply->surgery_areas[d.seq].segments[scnt].required_ind = 1
    ELSE
     reply->surgery_areas[d.seq].segments[scnt].required_ind = 0
    ENDIF
    reply->surgery_areas[d.seq].segments[scnt].selected_ind = 0
   FOOT  d.seq
    stat = alterlist(reply->surgery_areas[d.seq].segments,scnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (rcnt > 0)
  FOR (r = 1 TO rcnt)
    SET scnt = 0
    SET scnt = size(reply->surgery_areas[r].segments,5)
    IF (scnt > 0)
     SELECT INTO "NL:"
      FROM (dummyt d  WITH seq = scnt),
       preference_card pc,
       pref_card_segment pcs
      PLAN (d)
       JOIN (pc
       WHERE (pc.catalog_cd=request->procedure_code_value)
        AND pc.prsnl_id=0.0
        AND (pc.surg_area_cd=reply->surgery_areas[r].code_value)
        AND (pc.doc_type_cd=doccodes->codes[r].ornursecode))
       JOIN (pcs
       WHERE pcs.pref_card_id=pc.pref_card_id
        AND (pcs.seg_cd=reply->surgery_areas[r].segments[d.seq].code_value)
        AND pcs.active_ind=1)
      DETAIL
       reply->surgery_areas[r].segments[d.seq].selected_ind = 1
      WITH nocounter
     ;end select
    ENDIF
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
