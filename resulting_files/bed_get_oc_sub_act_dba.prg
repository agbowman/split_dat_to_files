CREATE PROGRAM bed_get_oc_sub_act:dba
 FREE SET reply
 RECORD reply(
   1 slist[*]
     2 subactivity_type_code_value = f8
     2 subactivity_type_display = c40
     2 subactivity_type_cdf_meaning = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_scount = 0
 SET scount = 0
 IF ((request->return_all > 0))
  SET activity_type_cdf_mean = fillstring(12," ")
  IF ((request->activity_type_code_value > 0))
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE (cv.code_value=request->activity_type_code_value)
    DETAIL
     activity_type_cdf_mean = cnvtupper(cv.cdf_meaning)
    WITH nocounter
   ;end select
  ENDIF
  SELECT DISTINCT INTO "NL:"
   FROM code_value c5801
   WHERE ((cnvtupper(c5801.definition)=activity_type_cdf_mean) OR ((request->activity_type_code_value
   =0.0)))
    AND c5801.active_ind=1
    AND c5801.code_set=5801
   ORDER BY c5801.code_value, c5801.display_key
   HEAD REPORT
    stat = alterlist(reply->slist,50)
   DETAIL
    tot_scount = (tot_scount+ 1), scount = (scount+ 1)
    IF (scount > 50)
     stat = alterlist(reply->slist,(tot_scount+ 50)), scount = 0
    ENDIF
    reply->slist[tot_scount].subactivity_type_code_value = c5801.code_value, reply->slist[tot_scount]
    .subactivity_type_display = c5801.display, reply->slist[tot_scount].subactivity_type_cdf_meaning
     = c5801.cdf_meaning
   FOOT REPORT
    stat = alterlist(reply->slist,tot_scount)
   WITH nocounter
  ;end select
 ELSE
  DECLARE oparse = vc
  SET oparse = concat("(o.catalog_type_cd = request->catalog_type_code_value or ",
   " request->catalog_type_code_value = 0.0) and ",
   " (o.activity_type_cd = request->activity_type_code_value or ",
   " request->activity_type_code_value = 0.0) ")
  IF (validate(request->exclude_careset_ind,0)=1)
   SET oparse = concat(oparse,
    " and not o.orderable_type_flag in (2,6) and o.bill_only_ind in (0,null) ")
  ENDIF
  IF (validate(request->exclude_inactive_ind,0)=1)
   SET oparse = concat(oparse," and o.active_ind = 1 ")
  ENDIF
  SELECT DISTINCT INTO "NL:"
   o.catalog_type_cd, o.activity_type_cd, o.activity_subtype_cd
   FROM order_catalog o,
    code_value c5801
   PLAN (o
    WHERE parser(oparse))
    JOIN (c5801
    WHERE o.activity_subtype_cd=c5801.code_value
     AND c5801.active_ind=1
     AND c5801.code_value > 0)
   ORDER BY o.activity_subtype_cd, c5801.display_key
   HEAD REPORT
    stat = alterlist(reply->slist,50)
   DETAIL
    tot_scount = (tot_scount+ 1), scount = (scount+ 1)
    IF (scount > 50)
     stat = alterlist(reply->slist,(tot_scount+ 50)), scount = 0
    ENDIF
    reply->slist[tot_scount].subactivity_type_code_value = o.activity_subtype_cd, reply->slist[
    tot_scount].subactivity_type_display = c5801.display, reply->slist[tot_scount].
    subactivity_type_cdf_meaning = c5801.cdf_meaning
   FOOT REPORT
    stat = alterlist(reply->slist,tot_scount)
   WITH nocounter
  ;end select
  CALL echo(oparse)
 ENDIF
 IF (tot_scount=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
