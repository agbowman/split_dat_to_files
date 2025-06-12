CREATE PROGRAM bed_get_fn_event_oc_list:dba
 FREE SET reply
 RECORD reply(
   1 events[*]
     2 id = f8
     2 display = vc
     2 oc_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET tot_cnt = 0
 SET stat = alterlist(reply->events,50)
 SET depart_code_value = 0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6202
   AND cv.active_ind=1
   AND cv.cdf_meaning="DPTACTION"
  DETAIL
   depart_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM track_event te,
   track_ord_event_reltn t,
   order_catalog oc
  PLAN (te
   WHERE (te.tracking_group_cd=request->trk_group_code_value)
    AND te.active_ind=1
    AND te.tracking_event_type_cd != depart_code_value)
   JOIN (t
   WHERE t.track_group_cd=outerjoin(request->trk_group_code_value)
    AND t.track_event_id=outerjoin(te.track_event_id)
    AND t.association_type_cd=outerjoin(0))
   JOIN (oc
   WHERE oc.catalog_cd=outerjoin(t.cat_or_cattype_cd))
  ORDER BY te.track_event_id, t.track_event_id
  HEAD te.track_event_id
   tot_cnt = (tot_cnt+ 1), cnt = (cnt+ 1)
   IF (cnt > 50)
    stat = alterlist(reply->events,(tot_cnt+ 50)), cnt = 1
   ENDIF
   reply->events[tot_cnt].id = te.track_event_id, reply->events[tot_cnt].display = te.display, reply
   ->events[tot_cnt].oc_ind = 0
  DETAIL
   IF (t.track_event_id > 0
    AND oc.orderable_type_flag != 6
    AND oc.orderable_type_flag != 2)
    reply->events[tot_cnt].oc_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->events,tot_cnt)
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
