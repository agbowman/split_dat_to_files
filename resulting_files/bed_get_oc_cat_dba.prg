CREATE PROGRAM bed_get_oc_cat:dba
 FREE SET reply
 RECORD reply(
   1 clist[*]
     2 catalog_type_code_value = f8
     2 catalog_type_display = c40
     2 catalog_type_cdf_meaning = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_ccount = 0
 SET ccount = 0
 DECLARE oc_parse = vc
 IF ((request->return_all > 0))
  SELECT INTO "NL:"
   FROM code_value c6000
   WHERE c6000.active_ind=1
    AND c6000.code_set=6000
   ORDER BY c6000.code_value, c6000.display_key
   HEAD REPORT
    stat = alterlist(reply->clist,50)
   DETAIL
    tot_ccount = (tot_ccount+ 1), ccount = (ccount+ 1)
    IF (ccount > 50)
     stat = alterlist(reply->clist,(tot_ccount+ 50)), ccount = 0
    ENDIF
    reply->clist[tot_ccount].catalog_type_code_value = c6000.code_value, reply->clist[tot_ccount].
    catalog_type_display = c6000.display, reply->clist[tot_ccount].catalog_type_cdf_meaning = c6000
    .cdf_meaning
   FOOT REPORT
    stat = alterlist(reply->clist,tot_ccount)
   WITH nocounter
  ;end select
 ELSE
  IF ((request->clin_cat_code_value > 0))
   SET oc_parse = build(" o.active_ind = 1 and o.dcp_clin_cat_cd = ",request->clin_cat_code_value)
  ELSE
   SET oc_parse = " o.active_ind = 1"
  ENDIF
  SELECT DISTINCT INTO "NL:"
   FROM order_catalog o,
    code_value c6000
   PLAN (o
    WHERE parser(oc_parse)
     AND o.catalog_type_cd > 0)
    JOIN (c6000
    WHERE c6000.code_value=o.catalog_type_cd
     AND c6000.active_ind=1)
   ORDER BY o.catalog_type_cd, c6000.display_key
   HEAD REPORT
    stat = alterlist(reply->clist,50)
   DETAIL
    tot_ccount = (tot_ccount+ 1), ccount = (ccount+ 1)
    IF (ccount > 50)
     stat = alterlist(reply->clist,(tot_ccount+ 50)), ccount = 0
    ENDIF
    reply->clist[tot_ccount].catalog_type_code_value = o.catalog_type_cd, reply->clist[tot_ccount].
    catalog_type_display = c6000.display, reply->clist[tot_ccount].catalog_type_cdf_meaning = c6000
    .cdf_meaning
   FOOT REPORT
    stat = alterlist(reply->clist,tot_ccount)
   WITH nocounter
  ;end select
 ENDIF
 IF (tot_ccount=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
