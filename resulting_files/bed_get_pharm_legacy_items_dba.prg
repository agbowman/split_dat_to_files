CREATE PROGRAM bed_get_pharm_legacy_items:dba
 FREE SET reply
 RECORD reply(
   1 legacy_items[*]
     2 facility
       3 code_value = f8
       3 display = vc
     2 ndc = vc
     2 description = vc
     2 match_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET lcnt = 0
 SET alterlist_lcnt = 0
 SET stat = alterlist(reply->legacy_items,100)
 IF ((request->return_dup_ndc_ind=1))
  SELECT INTO "NL:"
   FROM br_pharm_product_work b,
    code_value cv
   PLAN (b)
    JOIN (cv
    WHERE cv.code_value=outerjoin(b.facility_cd))
   DETAIL
    lcnt = (lcnt+ 1), alterlist_lcnt = (alterlist_lcnt+ 1)
    IF (alterlist_lcnt > 100)
     stat = alterlist(reply->legacy_items,(lcnt+ 100)), alterlist_lcnt = 1
    ENDIF
    reply->legacy_items[lcnt].facility.code_value = b.facility_cd
    IF (b.facility_cd > 0.0)
     reply->legacy_items[lcnt].facility.display = cv.display
    ENDIF
    reply->legacy_items[lcnt].ndc = b.ndc, reply->legacy_items[lcnt].description = b.description,
    reply->legacy_items[lcnt].match_ind = b.match_ind
   WITH nocounter
  ;end select
 ELSE
  SELECT DISTINCT INTO "NL:"
   b.facility_cd, b.ndc
   FROM br_pharm_product_work b,
    code_value cv
   PLAN (b)
    JOIN (cv
    WHERE cv.code_value=b.facility_cd)
   ORDER BY b.facility_cd, b.ndc
   HEAD b.facility_cd
    lcnt = lcnt
   HEAD b.ndc
    lcnt = (lcnt+ 1), alterlist_lcnt = (alterlist_lcnt+ 1)
    IF (alterlist_lcnt > 100)
     stat = alterlist(reply->legacy_items,(lcnt+ 100)), alterlist_lcnt = 1
    ENDIF
    reply->legacy_items[lcnt].facility.code_value = b.facility_cd
    IF (b.facility_cd > 0.0)
     reply->legacy_items[lcnt].facility.display = cv.display
    ENDIF
    reply->legacy_items[lcnt].ndc = b.ndc, reply->legacy_items[lcnt].description = b.description,
    reply->legacy_items[lcnt].match_ind = b.match_ind
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->legacy_items,lcnt)
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
