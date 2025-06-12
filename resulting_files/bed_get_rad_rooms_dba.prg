CREATE PROGRAM bed_get_rad_rooms:dba
 FREE SET reply
 RECORD reply(
   1 oc_list[*]
     2 code_value = f8
     2 short_desc = vc
     2 long_desc = vc
     2 multi_seg_ind = i2
     2 report_req_ind = i2
     2 sr_list[*] = f8
       3 code_value = f8
       3 status = i2
   1 sr_list[*]
     2 code_value = f8
     2 short_desc = vc
     2 long_desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SET tot_count = 0
 SET stat = alterlist(reply->sr_list,50)
 SELECT INTO "NL:"
  FROM code_value cv,
   service_resource s
  PLAN (cv
   WHERE cv.code_set=221
    AND cv.cdf_meaning="RADEXAMROOM"
    AND cv.active_ind=1)
   JOIN (s
   WHERE s.service_resource_cd=cv.code_value
    AND s.active_ind=1
    AND (s.activity_subtype_cd=request->subactivity_type_code_value))
  ORDER BY cv.display_key
  DETAIL
   tot_count = (tot_count+ 1), count = (count+ 1)
   IF (count > 50)
    stat = alterlist(reply->sr_list,(tot_count+ 50)), count = 1
   ENDIF
   reply->sr_list[tot_count].code_value = cv.code_value, reply->sr_list[tot_count].short_desc = cv
   .display, reply->sr_list[tot_count].long_desc = cv.description
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->sr_list,tot_count)
 IF (tot_count=0)
  SET reply->status_data.status = "Z"
 ENDIF
 SET rad_cat_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.cdf_meaning="RADIOLOGY"
   AND cv.code_set=6000
  DETAIL
   rad_cat_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET rad_act_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.cdf_meaning="RADIOLOGY"
   AND cv.code_set=106
  DETAIL
   rad_act_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET count = 0
 SET tot_count = 0
 SET stat = alterlist(reply->oc_list,50)
 SELECT INTO "NL:"
  FROM order_catalog oc,
   br_oc_rad_room b,
   br_order_catalog boc
  PLAN (oc
   WHERE oc.active_ind=1
    AND oc.catalog_type_cd=rad_cat_type_cd
    AND oc.activity_type_cd=rad_act_type_cd
    AND (oc.activity_subtype_cd=request->subactivity_type_code_value))
   JOIN (boc
   WHERE outerjoin(oc.catalog_cd)=boc.catalog_cd)
   JOIN (b
   WHERE outerjoin(oc.catalog_cd)=b.catalog_cd)
  ORDER BY oc.primary_mnemonic
  HEAD oc.catalog_cd
   tot_count = (tot_count+ 1), count = (count+ 1)
   IF (count > 50)
    stat = alterlist(reply->oc_list,(tot_count+ 50)), count = 1
   ENDIF
   reply->oc_list[tot_count].code_value = oc.catalog_cd, reply->oc_list[tot_count].short_desc = oc
   .primary_mnemonic, reply->oc_list[tot_count].long_desc = oc.description,
   reply->oc_list[tot_count].multi_seg_ind = boc.multi_seg_ind, reply->oc_list[tot_count].
   report_req_ind = boc.report_req_ind, sr_tot_count = 0,
   sr_count = 0, stat = alterlist(reply->oc_list[tot_count].sr_list,50)
  DETAIL
   IF (b.catalog_cd > 0)
    sr_tot_count = (sr_tot_count+ 1), sr_count = (sr_count+ 1)
    IF (sr_count > 50)
     stat = alterlist(reply->oc_list[tot_count].sr_list,(sr_tot_count+ 50)), sr_count = 1
    ENDIF
    reply->oc_list[tot_count].sr_list[sr_tot_count].code_value = b.catalog_cd, reply->oc_list[
    tot_count].sr_list[sr_tot_count].status = b.status
   ENDIF
  FOOT  oc.catalog_cd
   stat = alterlist(reply->oc_list[tot_count].sr_list,sr_tot_count)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->oc_list,tot_count)
 IF (tot_count=0)
  SET reply->status_data.status = "Z"
 ENDIF
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
