CREATE PROGRAM bed_get_rad_oc:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 history_ind = i2
     2 subactivity_type
       3 code_value = f8
       3 display = vc
       3 description = vc
     2 accession_class
       3 code_value = f8
       3 display = vc
       3 description = vc
     2 accession_format
       3 code_value = f8
       3 display = vc
       3 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE catalog_type_cd = f8
 DECLARE activity_type_cd = f8
 SET catalog_type_cd = 0.0
 SET activity_type_cd = 0.0
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET list_count = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.active_ind=1
   AND cv.cdf_meaning="RADIOLOGY"
  DETAIL
   catalog_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.active_ind=1
   AND cv.cdf_meaning="RADIOLOGY"
  DETAIL
   activity_type_cd = cv.code_value
  WITH nocounter
 ;end select
 IF ((request->load_wo_accession_class_ind=1))
  SELECT INTO "nl:"
   FROM order_catalog oc
   PLAN (oc
    WHERE oc.catalog_type_cd=catalog_type_cd
     AND oc.activity_type_cd=activity_type_cd
     AND oc.active_ind=1
     AND  NOT ( EXISTS (
    (SELECT
     p.catalog_cd
     FROM procedure_specimen_type p
     WHERE p.catalog_cd=oc.catalog_cd))))
   HEAD REPORT
    cnt = 0, list_count = 0, stat = alterlist(reply->orderables,200)
   DETAIL
    list_count = (list_count+ 1), cnt = (cnt+ 1)
    IF (list_count > 200)
     stat = alterlist(reply->orderables,(cnt+ 200)), list_count = 1
    ENDIF
    reply->orderables[cnt].code_value = oc.catalog_cd, reply->orderables[cnt].display = oc
    .primary_mnemonic, reply->orderables[cnt].description = oc.description,
    reply->orderables[cnt].subactivity_type.code_value = oc.activity_subtype_cd
   FOOT REPORT
    stat = alterlist(reply->orderables,cnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM order_catalog oc,
    procedure_specimen_type p,
    accession_class a
   PLAN (oc
    WHERE oc.catalog_type_cd=catalog_type_cd
     AND oc.activity_type_cd=activity_type_cd
     AND oc.active_ind=1)
    JOIN (p
    WHERE p.catalog_cd=oc.catalog_cd)
    JOIN (a
    WHERE a.accession_class_cd=p.accession_class_cd)
   HEAD REPORT
    cnt = 0, list_count = 0, stat = alterlist(reply->orderables,200)
   DETAIL
    list_count = (list_count+ 1), cnt = (cnt+ 1)
    IF (list_count > 200)
     stat = alterlist(reply->orderables,(cnt+ 200)), list_count = 1
    ENDIF
    reply->orderables[cnt].code_value = oc.catalog_cd, reply->orderables[cnt].display = oc
    .primary_mnemonic, reply->orderables[cnt].description = oc.description,
    reply->orderables[cnt].subactivity_type.code_value = oc.activity_subtype_cd, reply->orderables[
    cnt].accession_class.code_value = p.accession_class_cd, reply->orderables[cnt].accession_format.
    code_value = a.accession_format_cd
   FOOT REPORT
    stat = alterlist(reply->orderables,cnt)
   WITH nocounter
  ;end select
 ENDIF
 SET cnt = size(reply->orderables,5)
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=reply->orderables[d.seq].subactivity_type.code_value))
   DETAIL
    reply->orderables[d.seq].subactivity_type.display = cv.display, reply->orderables[d.seq].
    subactivity_type.description = cv.description
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=reply->orderables[d.seq].accession_class.code_value))
   DETAIL
    reply->orderables[d.seq].accession_class.display = cv.display, reply->orderables[d.seq].
    accession_class.description = cv.description
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=reply->orderables[d.seq].accession_format.code_value))
   DETAIL
    reply->orderables[d.seq].accession_format.display = cv.display, reply->orderables[d.seq].
    accession_format.description = cv.description
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    br_oc_work b
   PLAN (d)
    JOIN (b
    WHERE (b.match_orderable_cd=reply->orderables[d.seq].code_value)
     AND b.history_ind=1)
   DETAIL
    reply->orderables[d.seq].history_ind = 1
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
