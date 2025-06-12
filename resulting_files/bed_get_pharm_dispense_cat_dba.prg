CREATE PROGRAM bed_get_pharm_dispense_cat:dba
 FREE SET reply
 RECORD reply(
   1 order_types[*]
     2 order_type = i2
     2 dispense_cats[*]
       3 disp_cat_code_value = f8
       3 display = vc
       3 meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM dispense_category dc,
   code_value cv
  PLAN (dc
   WHERE dc.dispense_category_cd > 0)
   JOIN (cv
   WHERE cv.code_value=dc.dispense_category_cd
    AND cv.active_ind=1)
  ORDER BY dc.order_type_flag
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->order_types,100)
  HEAD dc.order_type_flag
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->order_types,(tot_cnt+ 100)), cnt = 1
   ENDIF
   reply->order_types[tot_cnt].order_type = dc.order_type_flag, dcnt = 0, dtot_cnt = 0,
   stat = alterlist(reply->order_types[tot_cnt].dispense_cats,100)
  DETAIL
   dcnt = (dcnt+ 1), dtot_cnt = (dtot_cnt+ 1)
   IF (dcnt > 100)
    stat = alterlist(reply->order_types[tot_cnt].dispense_cats,(dtot_cnt+ 100)), cnt = 1
   ENDIF
   reply->order_types[tot_cnt].dispense_cats[dtot_cnt].disp_cat_code_value = cv.code_value, reply->
   order_types[tot_cnt].dispense_cats[dtot_cnt].display = cv.display, reply->order_types[tot_cnt].
   dispense_cats[dtot_cnt].meaning = cv.cdf_meaning
  FOOT  dc.order_type_flag
   stat = alterlist(reply->order_types[tot_cnt].dispense_cats,dtot_cnt)
  FOOT REPORT
   stat = alterlist(reply->order_types,tot_cnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
