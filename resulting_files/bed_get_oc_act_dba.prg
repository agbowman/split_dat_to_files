CREATE PROGRAM bed_get_oc_act:dba
 FREE SET reply
 RECORD reply(
   1 alist[*]
     2 activity_type_code_value = f8
     2 activity_type_display = c40
     2 activity_type_cdf_meaning = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_acount = 0
 SET acount = 0
 DECLARE oc_parse = vc
 IF ((request->return_all > 0))
  SET catalog_type_cdf_mean = fillstring(12," ")
  IF ((request->catalog_type_code_value > 0))
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE (cv.code_value=request->catalog_type_code_value)
    DETAIL
     catalog_type_cdf_mean = cnvtupper(cv.cdf_meaning)
    WITH nocounter
   ;end select
  ENDIF
  SELECT DISTINCT INTO "NL:"
   FROM code_value c106
   WHERE ((cnvtupper(c106.definition)=catalog_type_cdf_mean) OR ((request->catalog_type_code_value=
   0.0)))
    AND c106.active_ind=1
    AND c106.code_set=106
   ORDER BY c106.code_value, c106.display_key
   HEAD REPORT
    stat = alterlist(reply->alist,50)
   DETAIL
    tot_acount = (tot_acount+ 1), acount = (acount+ 1)
    IF (acount > 50)
     stat = alterlist(reply->alist,(tot_acount+ 50)), acount = 0
    ENDIF
    reply->alist[tot_acount].activity_type_code_value = c106.code_value, reply->alist[tot_acount].
    activity_type_display = c106.display, reply->alist[tot_acount].activity_type_cdf_meaning = c106
    .cdf_meaning
   FOOT REPORT
    stat = alterlist(reply->alist,tot_acount)
   WITH nocounter
  ;end select
 ELSE
  SET oc_parse = " o.active_ind = 1 "
  IF ((request->catalog_type_code_value > 0))
   SET oc_parse = build(oc_parse," and o.catalog_type_cd = ",request->catalog_type_code_value)
  ENDIF
  SET field_exists = validate(request->clin_cat_code_value)
  IF (field_exists=1)
   IF ((request->clin_cat_code_value > 0))
    SET oc_parse = build(oc_parse," and o.dcp_clin_cat_cd = ",request->clin_cat_code_value)
   ENDIF
  ENDIF
  SELECT DISTINCT INTO "NL:"
   o.catalog_type_cd, o.activity_type_cd
   FROM order_catalog o,
    code_value c106
   PLAN (o
    WHERE parser(oc_parse))
    JOIN (c106
    WHERE o.activity_type_cd=c106.code_value
     AND c106.active_ind=1)
   ORDER BY o.activity_type_cd, c106.display_key
   HEAD REPORT
    stat = alterlist(reply->alist,50)
   DETAIL
    tot_acount = (tot_acount+ 1), acount = (acount+ 1)
    IF (acount > 50)
     stat = alterlist(reply->alist,(tot_acount+ 50)), acount = 0
    ENDIF
    reply->alist[tot_acount].activity_type_code_value = o.activity_type_cd, reply->alist[tot_acount].
    activity_type_display = c106.display, reply->alist[tot_acount].activity_type_cdf_meaning = c106
    .cdf_meaning
   FOOT REPORT
    stat = alterlist(reply->alist,tot_acount)
   WITH nocounter
  ;end select
 ENDIF
 IF (tot_acount=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
