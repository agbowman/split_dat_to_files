CREATE PROGRAM bed_get_sn_surgarea_by_surgeon:dba
 FREE SET reply
 RECORD reply(
   1 surgery_areas[*]
     2 code_value = f8
     2 display = c40
     2 comments_ind = i2
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
     2 comments_ind = i2
 )
 SET reply->status_data.status = "F"
 SET prsnl_comm_type_cd = 0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=16289
   AND cv.cdf_meaning="PRSNL"
   AND cv.active_ind=1
  DETAIL
   prsnl_comm_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET tcnt = 0
 SET alterlist_tcnt = 0
 SET stat = alterlist(temp->surgery_areas,50)
 SELECT INTO "NL:"
  FROM code_value cv,
   sn_comment_text sct,
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
   JOIN (sct
   WHERE sct.root_id=outerjoin(request->surgeon_id)
    AND sct.root_name=outerjoin("PRSNL")
    AND sct.surg_area_cd=outerjoin(cv.code_value)
    AND sct.comment_type_cd=outerjoin(prsnl_comm_type_cd)
    AND sct.active_ind=outerjoin(1))
  DETAIL
   tcnt = (tcnt+ 1), alterlist_tcnt = (alterlist_tcnt+ 1)
   IF (alterlist_tcnt > 50)
    stat = alterlist(temp->surgery_areas,(tcnt+ 50)), alterlist_tcnt = 1
   ENDIF
   temp->surgery_areas[tcnt].code_value = cv.code_value, temp->surgery_areas[tcnt].display = cv
   .display
   IF (sct.surg_area_cd > 0)
    temp->surgery_areas[tcnt].comments_ind = 1
   ELSE
    temp->surgery_areas[tcnt].comments_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(temp->surgery_areas,tcnt)
 IF (tcnt > 0)
  SET fcnt = 0
  SET fcnt = size(request->facilities,5)
  IF (fcnt > 0
   AND (request->facilities[1].code_value > 0.0))
   SET rcnt = 0
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
          rcnt = (rcnt+ 1), alterlist_rcnt = (alterlist_rcnt+ 1)
          IF (alterlist_rcnt > 50)
           stat = alterlist(reply->surgery_areas,(rcnt+ 50)), alterlist_rcnt = 1
          ENDIF
          reply->surgery_areas[rcnt].code_value = temp->surgery_areas[t].code_value, reply->
          surgery_areas[rcnt].display = temp->surgery_areas[t].display, reply->surgery_areas[rcnt].
          comments_ind = temp->surgery_areas[t].comments_ind
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
     SET reply->surgery_areas[t].comments_ind = temp->surgery_areas[t].comments_ind
   ENDFOR
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
