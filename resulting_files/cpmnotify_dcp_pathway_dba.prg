CREATE PROGRAM cpmnotify_dcp_pathway:dba
 RECORD reply(
   1 run_dt_tm = dq8
   1 overlay_ind = i2
   1 entity_list[*]
     2 entity_id = f8
     2 datalist[*]
       3 pathway_id = f8
       3 description = vc
       3 pw_status_cd = f8
       3 pw_status_disp = vc
       3 pw_status_mean = c12
       3 status_dt_tm = dq8
       3 status_prsnl_id = f8
       3 order_dt_tm = dq8
       3 started_ind = i2
       3 start_dt_tm = dq8
       3 updt_cnt = i4
       3 updt_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET personlistsz = size(request->entity_list,5)
 SET personcnt = 0
 SET pwcnt = 0
 SET reply->run_dt_tm = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  pw.pathway_id
  FROM (dummyt d  WITH seq = value(personlistsz)),
   pathway pw
  PLAN (d)
   JOIN (pw
   WHERE (pw.person_id=request->entity_list[d.seq].entity_id)
    AND pw.active_ind=1
    AND pw.updt_dt_tm >= cnvtdatetime(request->last_run_dt_tm))
  ORDER BY pw.person_id
  HEAD pw.person_id
   pwcnt = 0, personcnt = (personcnt+ 1)
   IF (personcnt > size(reply->entity_list,5))
    stat = alterlist(reply->entity_list,(personcnt+ 5))
   ENDIF
   reply->entity_list[personcnt].entity_id = pw.person_id
  DETAIL
   pwcnt = (pwcnt+ 1)
   IF (pwcnt > size(reply->entity_list[personcnt].datalist,5))
    stat = alterlist(reply->entity_list[personcnt].datalist,(pwcnt+ 5))
   ENDIF
   reply->entity_list[personcnt].datalist[pwcnt].pathway_id = pw.pathway_id, reply->entity_list[
   personcnt].datalist[pwcnt].description = pw.description, reply->entity_list[personcnt].datalist[
   pwcnt].pw_status_cd = pw.pw_status_cd,
   reply->entity_list[personcnt].datalist[pwcnt].order_dt_tm = cnvtdatetime(pw.order_dt_tm), reply->
   entity_list[personcnt].datalist[pwcnt].started_ind = pw.started_ind, reply->entity_list[personcnt]
   .datalist[pwcnt].start_dt_tm = cnvtdatetime(pw.start_dt_tm),
   reply->entity_list[personcnt].datalist[pwcnt].updt_cnt = pw.updt_cnt, reply->entity_list[personcnt
   ].datalist[pwcnt].updt_dt_tm = pw.updt_dt_tm, reply->entity_list[personcnt].datalist[pwcnt].
   status_dt_tm = pw.status_dt_tm,
   reply->entity_list[personcnt].datalist[pwcnt].status_prsnl_id = pw.status_prsnl_id
  FOOT  pw.person_id
   stat = alterlist(reply->entity_list[personcnt].datalist,pwcnt)
  FOOT REPORT
   stat = alterlist(reply->entity_list,personcnt)
  WITH nocounter
 ;end select
 IF (personcnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
