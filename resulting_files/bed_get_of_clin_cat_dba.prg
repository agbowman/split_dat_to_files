CREATE PROGRAM bed_get_of_clin_cat:dba
 FREE SET reply
 RECORD reply(
   1 clist[*]
     2 clin_cat_code_value = f8
     2 clin_cat_display = c40
     2 clin_cat_cdf_meaning = c12
     2 selected_ind = i2
     2 folder_name = c500
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
 IF ((request->return_all > 0))
  SELECT INTO "NL:"
   FROM code_value cv,
    br_of_parent_reltn b,
    alt_sel_cat a
   PLAN (cv
    WHERE cv.active_ind=1
     AND cv.code_set=16389)
    JOIN (b
    WHERE b.source_id=outerjoin(cv.code_value)
     AND b.source_name=outerjoin("CODE_VALUE"))
    JOIN (a
    WHERE a.alt_sel_category_id=outerjoin(b.alt_sel_category_id))
   ORDER BY cv.display
   HEAD REPORT
    stat = alterlist(reply->clist,20)
   DETAIL
    tot_ccount = (tot_ccount+ 1), ccount = (ccount+ 1)
    IF (ccount > 20)
     stat = alterlist(reply->clist,(tot_ccount+ 20)), ccount = 0
    ENDIF
    reply->clist[tot_ccount].clin_cat_code_value = cv.code_value, reply->clist[tot_ccount].
    clin_cat_display = cv.display, reply->clist[tot_ccount].clin_cat_cdf_meaning = cv.cdf_meaning
    IF (b.alt_sel_category_id > 0.0)
     reply->clist[tot_ccount].selected_ind = 1, reply->clist[tot_ccount].folder_name = a
     .short_description
    ELSE
     reply->clist[tot_ccount].selected_ind = 0
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->clist,tot_ccount)
   WITH nocounter
  ;end select
 ELSE
  SELECT DISTINCT INTO "NL:"
   FROM order_catalog o,
    code_value cv,
    br_of_parent_reltn b,
    alt_sel_cat a
   PLAN (o
    WHERE o.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=o.dcp_clin_cat_cd
     AND cv.active_ind=1)
    JOIN (b
    WHERE b.source_id=outerjoin(cv.code_value)
     AND b.source_name=outerjoin("CODE_VALUE"))
    JOIN (a
    WHERE a.alt_sel_category_id=outerjoin(b.alt_sel_category_id))
   ORDER BY cv.display
   HEAD REPORT
    stat = alterlist(reply->clist,20)
   DETAIL
    tot_ccount = (tot_ccount+ 1), ccount = (ccount+ 1)
    IF (ccount > 20)
     stat = alterlist(reply->clist,(tot_ccount+ 20)), ccount = 0
    ENDIF
    reply->clist[tot_ccount].clin_cat_code_value = o.dcp_clin_cat_cd, reply->clist[tot_ccount].
    clin_cat_display = cv.display, reply->clist[tot_ccount].clin_cat_cdf_meaning = cv.cdf_meaning
    IF (b.alt_sel_category_id > 0.0)
     reply->clist[tot_ccount].selected_ind = 1, reply->clist[tot_ccount].folder_name = a
     .short_description
    ELSE
     reply->clist[tot_ccount].selected_ind = 0
    ENDIF
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
