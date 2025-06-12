CREATE PROGRAM bed_get_oc_match_status:dba
 FREE SET reply
 RECORD reply(
   1 matched_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->matched_ind = 0
 SET cat_surg_ind = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="SURGERY"
   AND cv.active_ind=1
  DETAIL
   IF ((cv.code_value=request->catalog_type_code_value)
    AND (request->catalog_type_code_value > 0))
    cat_surg_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 DECLARE oc_parse = vc
 SET oc_parse = "oc.catalog_cd = b.match_orderable_cd"
 IF ((request->catalog_type_code_value > 0))
  SET oc_parse = build(oc_parse," and oc.catalog_type_cd = ",request->catalog_type_code_value)
 ENDIF
 IF ((request->activity_type_code_value > 0))
  SET oc_parse = build(oc_parse," and oc.activity_type_cd = ",request->activity_type_code_value)
 ENDIF
 IF ((request->subactivity_type_code_value > 0))
  SET oc_parse = build(oc_parse," and oc.activity_subtype_cd = ",request->subactivity_type_code_value
   )
 ENDIF
 CALL echo(build("parser = ",oc_parse))
 SELECT INTO "NL:"
  FROM br_oc_work b,
   order_catalog oc
  PLAN (b
   WHERE b.match_orderable_cd > 0)
   JOIN (oc
   WHERE parser(oc_parse))
  DETAIL
   reply->matched_ind = 1
  WITH maxqual(oc,1)
 ;end select
 IF ((reply->matched_ind=0))
  FREE SET temp
  RECORD temp(
    1 qual[*]
      2 cd = f8
  )
  SET cnt = 0
  SELECT INTO "nl:"
   FROM br_oc_work b
   PLAN (b
    WHERE b.match_orderable_cd > 0)
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].cd = b.match_orderable_cd
   WITH nocounter
  ;end select
  IF (cnt > 0)
   DECLARE oc_parse = vc
   IF (cat_surg_ind=1)
    SET oc_parse = "oc.surgery_ind = 1"
   ELSE
    IF ((request->catalog_type_code_value > 0))
     SET oc_parse = build("oc.catalog_type_cd = ",request->catalog_type_code_value)
    ENDIF
    IF ((request->activity_type_code_value > 0))
     SET oc_parse = build(oc_parse," and oc.activity_type_cd = ",request->activity_type_code_value)
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(cnt)),
     br_auto_order_catalog oc
    PLAN (d)
     JOIN (oc
     WHERE (oc.catalog_cd=temp->qual[d.seq].cd)
      AND parser(oc_parse))
    DETAIL
     reply->matched_ind = 1
    WITH nocounter, skipbedrock = 1
   ;end select
  ENDIF
 ENDIF
#exit_script
 IF ((reply->matched_ind=1))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
