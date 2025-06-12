CREATE PROGRAM dcp_get_pip_pathway:dba
 RECORD reply(
   1 person_list[*]
     2 person_id = f8
     2 pathway_cnt = i2
     2 qual_pathway[*]
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
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET personlistsz = size(request->person_list,5)
 SET personcnt = 0
 SET pwcnt = 0
 SELECT INTO "nl:"
  pw.pathway_id
  FROM (dummyt d  WITH seq = value(personlistsz)),
   pathway pw
  PLAN (d)
   JOIN (pw
   WHERE (pw.person_id=request->person_list[d.seq].person_id)
    AND pw.active_ind=1)
  ORDER BY pw.person_id
  HEAD pw.person_id
   pwcnt = 0, personcnt = (personcnt+ 1)
   IF (personcnt > size(reply->person_list,5))
    stat = alterlist(reply->person_list,(personcnt+ 5))
   ENDIF
   reply->person_list[personcnt].person_id = pw.person_id
  DETAIL
   pwcnt = (pwcnt+ 1)
   IF (pwcnt > size(reply->person_list[personcnt].qual_pathway,5))
    stat = alterlist(reply->person_list[personcnt].qual_pathway,(pwcnt+ 5))
   ENDIF
   reply->person_list[personcnt].qual_pathway[pwcnt].pathway_id = pw.pathway_id, reply->person_list[
   personcnt].qual_pathway[pwcnt].description = pw.description, reply->person_list[personcnt].
   qual_pathway[pwcnt].pw_status_cd = pw.pw_status_cd,
   reply->person_list[personcnt].qual_pathway[pwcnt].order_dt_tm = cnvtdatetime(pw.order_dt_tm),
   reply->person_list[personcnt].qual_pathway[pwcnt].started_ind = pw.started_ind, reply->
   person_list[personcnt].qual_pathway[pwcnt].start_dt_tm = cnvtdatetime(pw.start_dt_tm),
   reply->person_list[personcnt].qual_pathway[pwcnt].updt_cnt = pw.updt_cnt, reply->person_list[
   personcnt].qual_pathway[pwcnt].updt_dt_tm = pw.updt_dt_tm, reply->person_list[personcnt].
   qual_pathway[pwcnt].status_dt_tm = pw.status_dt_tm,
   reply->person_list[personcnt].qual_pathway[pwcnt].status_prsnl_id = pw.status_prsnl_id
  FOOT  pw.person_id
   stat = alterlist(reply->person_list[personcnt].qual_pathway,pwcnt), reply->person_list[personcnt].
   pathway_cnt = pwcnt
  FOOT REPORT
   stat = alterlist(reply->person_list,personcnt)
  WITH nocounter
 ;end select
 IF (personcnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
