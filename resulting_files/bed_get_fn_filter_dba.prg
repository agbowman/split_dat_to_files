CREATE PROGRAM bed_get_fn_filter:dba
 FREE SET reply
 RECORD reply(
   1 column_views[*]
     2 id = f8
     2 name = vc
     2 custom_filters[*]
       3 id = f8
       3 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SET tot_count = 0
 SET view_cnt = size(request->column_views,5)
 SET stat = alterlist(reply->column_views,view_cnt)
 IF (view_cnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = view_cnt),
    predefined_prefs pp
   PLAN (d)
    JOIN (pp
    WHERE pp.active_ind=1
     AND (pp.predefined_prefs_id=request->column_views[d.seq].id))
   DETAIL
    reply->column_views[d.seq].id = request->column_views[d.seq].id, reply->column_views[d.seq].name
     = pp.name
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = view_cnt),
    predefined_prefs pp
   PLAN (d)
    JOIN (pp
    WHERE pp.active_ind=1
     AND pp.predefined_type_meaning=cnvtstring(request->column_views[d.seq].id))
   ORDER BY d.seq
   HEAD d.seq
    stat = alterlist(reply->column_views[d.seq].custom_filters,20), count = 0, tot_count = 0
   DETAIL
    count = (count+ 1), tot_count = (tot_count+ 1)
    IF (count > 20)
     stat = alterlist(reply->column_views[d.seq].custom_filters,(tot_count+ 20)), count = 1
    ENDIF
    reply->column_views[d.seq].custom_filters[tot_count].id = pp.predefined_prefs_id, reply->
    column_views[d.seq].custom_filters[tot_count].name = pp.name
   FOOT  d.seq
    stat = alterlist(reply->column_views[d.seq].custom_filters,tot_count)
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (view_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
