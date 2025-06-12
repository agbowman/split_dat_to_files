CREATE PROGRAM bed_get_nurse_witness_parms:dba
 FREE SET reply
 RECORD reply(
   1 synonyms[*]
     2 id = f8
     2 witness_default_ind = i2
     2 groups[*]
       3 id = f8
       3 facility
         4 code_value = f8
         4 display = vc
         4 mean = vc
         4 description = vc
       3 location
         4 code_value = f8
         4 display = vc
         4 mean = vc
         4 description = vc
       3 route
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 iv_event
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 age_range
         4 code_value = f8
         4 display = vc
         4 mean = vc
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE age_range_cd = f8 WITH public, noconstant(0.0)
 DECLARE iv_event_cd = f8 WITH public, noconstant(0.0)
 DECLARE location_cd = f8 WITH public, noconstant(0.0)
 DECLARE route_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=4000047
    AND cv.cdf_meaning IN ("AGECODE", "IVEVENT", "LOCATION", "ROUTE")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="AGECODE")
    age_range_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="IVEVENT")
    iv_event_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="LOCATION")
    location_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="ROUTE")
    route_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET scnt = size(request->synonyms,5)
 SET stat = alterlist(reply->synonyms,scnt)
 DECLARE total_groups = f8
 SET total_groups = 0
 IF (scnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = scnt),
    order_catalog_synonym ocs,
    ocs_attr_xcptn oax,
    code_value cv1,
    code_value cv2
   PLAN (d)
    JOIN (ocs
    WHERE (ocs.synonym_id=request->synonyms[d.seq].id))
    JOIN (oax
    WHERE oax.synonym_id=outerjoin(ocs.synonym_id)
     AND oax.facility_cd > outerjoin(0))
    JOIN (cv1
    WHERE cv1.code_value=outerjoin(oax.facility_cd)
     AND cv1.active_ind=outerjoin(1))
    JOIN (cv2
    WHERE cv2.code_value=outerjoin(oax.flex_obj_cd)
     AND cv2.active_ind=outerjoin(1))
   ORDER BY d.seq, oax.ocs_attr_xcptn_group_id
   HEAD d.seq
    reply->synonyms[d.seq].id = ocs.synonym_id, reply->synonyms[d.seq].witness_default_ind = ocs
    .witness_flag, gcnt = 0
   HEAD oax.ocs_attr_xcptn_group_id
    IF (oax.ocs_attr_xcptn_group_id > 0
     AND cv1.code_value > 0)
     total_groups = (total_groups+ 1), gcnt = (gcnt+ 1), stat = alterlist(reply->synonyms[d.seq].
      groups,gcnt),
     reply->synonyms[d.seq].groups[gcnt].id = oax.ocs_attr_xcptn_group_id
    ENDIF
   DETAIL
    IF (oax.flex_obj_type_cd=location_cd
     AND cv2.code_value=0)
     IF (total_groups > 0)
      total_groups = (total_groups - 1), gcnt = (gcnt - 1)
     ENDIF
     stat = alterlist(reply->synonyms[d.seq].groups,gcnt)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((total_groups > request->max_reply))
  SET stat = alterlist(reply->synonyms,0)
  SET reply->too_many_results_ind = 1
 ELSE
  FOR (s = 1 TO scnt)
   SET gcnt = size(reply->synonyms[s].groups,5)
   IF (gcnt > 0)
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = gcnt),
      ocs_attr_xcptn oax,
      code_value cv1,
      code_value cv2
     PLAN (d)
      JOIN (oax
      WHERE (oax.ocs_attr_xcptn_group_id=reply->synonyms[s].groups[d.seq].id))
      JOIN (cv1
      WHERE cv1.code_value=oax.facility_cd
       AND cv1.active_ind=1)
      JOIN (cv2
      WHERE cv2.code_value=outerjoin(oax.flex_obj_cd)
       AND cv2.active_ind=outerjoin(1))
     DETAIL
      reply->synonyms[s].groups[d.seq].facility.code_value = cv1.code_value, reply->synonyms[s].
      groups[d.seq].facility.display = cv1.display, reply->synonyms[s].groups[d.seq].facility.mean =
      cv1.cdf_meaning,
      reply->synonyms[s].groups[d.seq].facility.description = cv1.description
      IF (oax.flex_obj_type_cd=location_cd)
       reply->synonyms[s].groups[d.seq].location.code_value = cv2.code_value, reply->synonyms[s].
       groups[d.seq].location.display = cv2.display, reply->synonyms[s].groups[d.seq].location.mean
        = cv2.cdf_meaning,
       reply->synonyms[s].groups[d.seq].location.description = cv2.description
      ELSEIF (oax.flex_obj_type_cd=route_cd)
       reply->synonyms[s].groups[d.seq].route.code_value = cv2.code_value, reply->synonyms[s].groups[
       d.seq].route.display = cv2.display, reply->synonyms[s].groups[d.seq].route.mean = cv2
       .cdf_meaning
      ELSEIF (oax.flex_obj_type_cd=iv_event_cd)
       reply->synonyms[s].groups[d.seq].iv_event.code_value = cv2.code_value, reply->synonyms[s].
       groups[d.seq].iv_event.display = cv2.display, reply->synonyms[s].groups[d.seq].iv_event.mean
        = cv2.cdf_meaning
      ELSEIF (oax.flex_obj_type_cd=age_range_cd)
       reply->synonyms[s].groups[d.seq].age_range.code_value = cv2.code_value, reply->synonyms[s].
       groups[d.seq].age_range.display = cv2.display, reply->synonyms[s].groups[d.seq].age_range.mean
        = cv2.cdf_meaning
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
