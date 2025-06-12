CREATE PROGRAM bed_get_assay_br:dba
 FREE SET reply
 RECORD reply(
   1 assays[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 result_type
       3 code_value = f8
       3 display = vc
       3 cdf_meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE concept_cki = vc
 SET cnt = 0
 SELECT INTO "nl:"
  FROM order_catalog o
  PLAN (o
   WHERE (o.catalog_cd=request->orderable_code_value))
  DETAIL
   concept_cki = o.concept_cki
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM br_auto_oc_dta b,
   br_auto_order_catalog oc,
   br_auto_dta dta
  PLAN (oc
   WHERE oc.concept_cki=concept_cki)
   JOIN (b
   WHERE b.catalog_cd=oc.catalog_cd)
   JOIN (dta
   WHERE dta.task_assay_cd=outerjoin(b.task_assay_cd))
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->assays,cnt), reply->assays[cnt].code_value = b
   .task_assay_cd,
   reply->assays[cnt].result_type.code_value = dta.result_type_cd
   IF (dta.mnemonic > "   ")
    reply->assays[cnt].display = dta.mnemonic, reply->assays[cnt].description = dta.description
   ENDIF
  WITH nocounter, skipbedrock = 1
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    code_value c
   PLAN (d)
    JOIN (c
    WHERE (c.code_value=reply->assays[d.seq].result_type.code_value))
   ORDER BY d.seq
   HEAD d.seq
    reply->assays[d.seq].result_type.display = c.display, reply->assays[d.seq].result_type.
    cdf_meaning = c.cdf_meaning
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = value(cnt)),
    code_value cv
   PLAN (d
    WHERE (reply->assays[d.seq].display=null))
    JOIN (cv
    WHERE cv.code_set=14003
     AND cv.active_ind=1
     AND (cv.code_value=reply->assays[d.seq].code_value))
   DETAIL
    reply->assays[d.seq].display = cv.display, reply->assays[d.seq].description = cv.description
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
