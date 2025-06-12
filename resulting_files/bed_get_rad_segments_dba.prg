CREATE PROGRAM bed_get_rad_segments:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 code_value = f8
     2 proposed_assay = vc
     2 duplicate_ind = i2
     2 subactivity_type
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 assays[*]
       3 code_value = f8
       3 mnemonic = vc
       3 result_type
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 sequence = i4
       3 pending_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET dcnt = 0
 SET rad_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="RADIOLOGY"
    AND cv.active_ind=1)
  DETAIL
   rad_cd = cv.code_value
  WITH nocounter
 ;end select
 SET text_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=289
    AND cv.display_key="TEXT"
    AND cv.active_ind=1)
  DETAIL
   text_cd = cv.code_value
  WITH nocounter
 ;end select
 SET date_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=289
    AND cv.display_key="DATEANDTIME"
    AND cv.active_ind=1)
  DETAIL
   date_cd = cv.code_value
  WITH nocounter
 ;end select
 SET cnt = size(request->orderables,5)
 IF (cnt > 0)
  SET stat = alterlist(reply->orderables,cnt)
  FOR (x = 1 TO cnt)
    SET reply->orderables[x].code_value = request->orderables[x].code_value
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    order_catalog oc
   PLAN (d)
    JOIN (oc
    WHERE (oc.catalog_cd=reply->orderables[d.seq].code_value))
   ORDER BY d.seq
   HEAD d.seq
    reply->orderables[d.seq].proposed_assay = substring(1,40,oc.primary_mnemonic), reply->orderables[
    d.seq].subactivity_type.code_value = oc.activity_subtype_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    code_value cv
   PLAN (d
    WHERE (reply->orderables[d.seq].proposed_assay > " "))
    JOIN (cv
    WHERE cv.code_set=14003
     AND (cv.display_key=reply->orderables[d.seq].proposed_assay))
   HEAD d.seq
    reply->orderables[d.seq].duplicate_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    code_value cv
   PLAN (d
    WHERE (reply->orderables[d.seq].subactivity_type.code_value > 0))
    JOIN (cv
    WHERE (cv.code_value=reply->orderables[d.seq].subactivity_type.code_value))
   HEAD d.seq
    reply->orderables[d.seq].subactivity_type.display = cv.display, reply->orderables[d.seq].
    subactivity_type.mean = cv.cdf_meaning
   WITH nocounter
  ;end select
 ENDIF
 IF (size(reply->orderables,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(reply->orderables,5))),
    profile_task_r ptr,
    discrete_task_assay dta,
    code_value cv
   PLAN (d)
    JOIN (ptr
    WHERE (ptr.catalog_cd=reply->orderables[d.seq].code_value)
     AND ((ptr.active_ind+ 0)=1))
    JOIN (dta
    WHERE dta.task_assay_cd=ptr.task_assay_cd
     AND ((dta.activity_type_cd+ 0)=rad_cd)
     AND ((dta.default_result_type_cd+ 0) IN (text_cd, date_cd))
     AND ((dta.active_ind+ 0)=1))
    JOIN (cv
    WHERE cv.code_value=dta.default_result_type_cd)
   ORDER BY d.seq
   HEAD d.seq
    dcnt = 0
   DETAIL
    dcnt = (dcnt+ 1), stat = alterlist(reply->orderables[d.seq].assays,dcnt), reply->orderables[d.seq
    ].assays[dcnt].code_value = dta.task_assay_cd,
    reply->orderables[d.seq].assays[dcnt].mnemonic = dta.mnemonic, reply->orderables[d.seq].assays[
    dcnt].result_type.code_value = dta.default_result_type_cd, reply->orderables[d.seq].assays[dcnt].
    result_type.display = cv.display,
    reply->orderables[d.seq].assays[dcnt].result_type.mean = cv.cdf_meaning, reply->orderables[d.seq]
    .assays[dcnt].sequence = ptr.sequence, reply->orderables[d.seq].assays[dcnt].pending_ind = ptr
    .pending_ind
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (size(reply->orderables,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
