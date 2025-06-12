CREATE PROGRAM bed_get_fn_event_oc_detail:dba
 FREE SET reply
 RECORD reply(
   1 hide_ind = i2
   1 orderables[*]
     2 code_value = f8
     2 display = vc
     2 catalog_type_code_value = f8
     2 activity_type_code_value = f8
     2 subactivity_type_code_value = f8
   1 catalog_types[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ocnt = 0
 SET tot_ocnt = 0
 SET cnt = 0
 SET tot_cnt = 0
 SET stat = alterlist(reply->orderables,50)
 SET stat = alterlist(reply->catalog_types,20)
 SELECT INTO "NL:"
  FROM track_event t
  WHERE (t.tracking_group_cd=request->trk_group_code_value)
   AND (t.track_event_id=request->track_event_id)
   AND t.active_ind=1
  DETAIL
   reply->hide_ind = t.hide_event_ind
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM track_ord_event_reltn t,
   order_catalog oc
  PLAN (t
   WHERE (t.track_group_cd=request->trk_group_code_value)
    AND (t.track_event_id=request->track_event_id))
   JOIN (oc
   WHERE oc.catalog_cd=t.cat_or_cattype_cd
    AND oc.orderable_type_flag != 6
    AND oc.orderable_type_flag != 2)
  DETAIL
   tot_ocnt = (tot_ocnt+ 1), ocnt = (ocnt+ 1)
   IF (ocnt > 50)
    stat = alterlist(reply->orderables,(tot_ocnt+ 50)), cnt = 1
   ENDIF
   reply->orderables[tot_ocnt].code_value = oc.catalog_cd, reply->orderables[tot_ocnt].display = oc
   .primary_mnemonic, reply->orderables[tot_ocnt].catalog_type_code_value = oc.catalog_type_cd,
   reply->orderables[tot_ocnt].activity_type_code_value = oc.activity_type_cd, reply->orderables[
   tot_ocnt].subactivity_type_code_value = oc.activity_subtype_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->orderables,tot_ocnt)
 SELECT INTO "NL:"
  FROM track_ord_event_reltn t,
   code_value cv
  PLAN (t
   WHERE (t.track_group_cd=request->trk_group_code_value)
    AND (t.track_event_id=request->track_event_id)
    AND t.association_type_cd=0)
   JOIN (cv
   WHERE cv.code_value=t.cat_or_cattype_cd
    AND cv.code_set=6000)
  DETAIL
   tot_cnt = (tot_cnt+ 1), cnt = (cnt+ 1)
   IF (cnt > 50)
    stat = alterlist(reply->orderables,(tot_cnt+ 50)), cnt = 1
   ENDIF
   reply->catalog_types[tot_cnt].code_value = cv.code_value, reply->catalog_types[tot_cnt].display =
   cv.display, reply->catalog_types[tot_cnt].mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->catalog_types,tot_cnt)
#exit_script
 IF (tot_cnt=0
  AND tot_ocnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
