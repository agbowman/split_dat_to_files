CREATE PROGRAM br_get_step_detail:dba
 FREE SET reply
 RECORD reply(
   1 slist[*]
     2 step_mean = vc
     2 step_disp = vc
     2 step_cat_mean = vc
     2 status_flag = i2
     2 plist[*]
       3 br_prsnl_id = f8
       3 username = vc
       3 name_full_formatted = vc
       3 email = vc
       3 lead_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 IF ((request->step_mean > " ")
  AND (request->availability_flag IN (2, 3)))
  SET cnt = 0
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "BR_GET_STEP_DETAIL"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid script call."
  GO TO exit_script
 ENDIF
 IF ((request->availability_flag=3))
  SET stat = alterlist(reply->slist,1)
  SET reply->slist[1].step_mean = request->step_mean
  SELECT INTO "nl:"
   FROM br_client_item_reltn bcir
   PLAN (bcir
    WHERE bcir.item_type="STEP"
     AND (bcir.item_mean=request->step_mean))
   DETAIL
    reply->slist[1].step_cat_mean = bcir.step_cat_mean, reply->slist[1].step_disp = bcir.item_display,
    reply->slist[1].status_flag = bcir.status_flag
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM br_prsnl_item_reltn bpir,
    br_client_prsnl_reltn bcpr,
    br_prsnl bp
   PLAN (bpir
    WHERE ((bpir.item_type="STEP"
     AND (bpir.item_mean=request->step_mean)) OR (bpir.item_type="STEPCAT"
     AND (bpir.item_mean=reply->slist[1].step_cat_mean))) )
    JOIN (bcpr
    WHERE bcpr.br_prsnl_id=bpir.br_prsnl_id
     AND bcpr.active_ind=1)
    JOIN (bp
    WHERE bp.br_prsnl_id=bcpr.br_prsnl_id
     AND bp.active_ind=1)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->slist[1].plist,cnt), reply->slist[1].plist[cnt].
    br_prsnl_id = bp.br_prsnl_id,
    reply->slist[1].plist[cnt].username = bp.username, reply->slist[1].plist[cnt].email = bp.email,
    reply->slist[1].plist[cnt].name_full_formatted = bp.name_full_formatted
    IF (bpir.item_lead_ind=1)
     reply->slist[1].plist[cnt].lead_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SET cnt = 0
  SELECT INTO "nl:"
   FROM br_step_dep bsd,
    br_client_item_reltn bcir
   PLAN (bsd
    WHERE (bsd.step_mean=request->step_mean))
    JOIN (bcir
    WHERE bcir.item_type="STEP"
     AND bcir.item_mean=bsd.dep_step_mean)
   HEAD bcir.item_mean
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->slist,cnt), reply->slist[cnt].step_mean = bcir.item_mean,
    reply->slist[cnt].step_cat_mean = bcir.step_cat_mean, reply->slist[cnt].step_disp = bcir
    .item_display, reply->slist[cnt].status_flag = bcir.status_flag
   WITH nocounter
  ;end select
  IF (cnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = cnt),
     br_prsnl_item_reltn bpir,
     br_client_prsnl_reltn bcpr,
     br_prsnl bp
    PLAN (d)
     JOIN (bpir
     WHERE ((bpir.item_type="STEP"
      AND (bpir.item_mean=reply->slist[d.seq].step_mean)) OR (bpir.item_type="STEPCAT"
      AND (bpir.item_mean=reply->slist[d.seq].step_cat_mean))) )
     JOIN (bcpr
     WHERE bcpr.br_prsnl_id=bpir.br_prsnl_id
      AND bcpr.active_ind=1)
     JOIN (bp
     WHERE bp.br_prsnl_id=bcpr.br_prsnl_id
      AND bp.active_ind=1)
    ORDER BY d.seq
    HEAD REPORT
     pcnt = 0
    HEAD d.seq
     pcnt = 0
    DETAIL
     pcnt = (pcnt+ 1), stat = alterlist(reply->slist[d.seq].plist,pcnt), reply->slist[d.seq].plist[
     pcnt].br_prsnl_id = bp.br_prsnl_id,
     reply->slist[d.seq].plist[pcnt].username = bp.username, reply->slist[d.seq].plist[pcnt].email =
     bp.email, reply->slist[d.seq].plist[pcnt].name_full_formatted = bp.name_full_formatted
     IF (bpir.item_lead_ind=1)
      reply->slist[d.seq].plist[pcnt].lead_ind = 1
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
