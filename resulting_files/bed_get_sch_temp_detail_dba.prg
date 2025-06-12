CREATE PROGRAM bed_get_sch_temp_detail:dba
 FREE SET reply
 RECORD reply(
   1 dayofweek = vc
   1 wlist[7]
     2 active_flag = i2
   1 weekofmonth = vc
   1 mlist[5]
     2 active_flag = i2
   1 daybegin = i4
   1 daybegin_str = vc
   1 dayend = i4
   1 dayend_str = vc
   1 apply_beg_dt_tm = dq8
   1 apply_beg_dt_tm_str = vc
   1 apply_end_dt_tm = dq8
   1 apply_end_dt_tm_str = vc
   1 apply_range = i4
   1 apply_range_str = vc
   1 rlist[*]
     2 br_sch_temp_res_r_id = f8
     2 resource_name = vc
     2 resource_cd = f8
   1 blist[*]
     2 slist[*]
       3 br_sch_temp_slot_r_id = f8
       3 slot_name = vc
       3 slot_start = i4
       3 slot_start_str = vc
       3 slot_end = i4
       3 slot_end_str = vc
       3 slot_release_to = vc
       3 slot_release_to_id = f8
       3 slot_release_hrs = i4
       3 slot_type_id = f8
       3 slot_color = i4
       3 time_block = i4
       3 interval = i4
       3 interval_str = vc
     2 scnt = i4
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM br_sch_template bst
  PLAN (bst
   WHERE (bst.br_sch_template_id=request->br_sch_template_id))
  HEAD REPORT
   fstat = 0
  DETAIL
   reply->dayofweek = bst.dayofweek, fstat = findstring("U",bst.dayofweek)
   IF (fstat > 0)
    reply->wlist[1].active_flag = 1
   ENDIF
   fstat = findstring("M",bst.dayofweek)
   IF (fstat > 0)
    reply->wlist[2].active_flag = 1
   ENDIF
   fstat = findstring("T",bst.dayofweek)
   IF (fstat > 0)
    reply->wlist[3].active_flag = 1
   ENDIF
   fstat = findstring("W",bst.dayofweek)
   IF (fstat > 0)
    reply->wlist[4].active_flag = 1
   ENDIF
   fstat = findstring("H",bst.dayofweek)
   IF (fstat > 0)
    reply->wlist[5].active_flag = 1
   ENDIF
   fstat = findstring("F",bst.dayofweek)
   IF (fstat > 0)
    reply->wlist[6].active_flag = 1
   ENDIF
   fstat = findstring("S",bst.dayofweek)
   IF (fstat > 0)
    reply->wlist[7].active_flag = 1
   ENDIF
   reply->weekofmonth = bst.weekofmonth, fstat = findstring("1",bst.weekofmonth)
   IF (fstat > 0)
    reply->mlist[1].active_flag = 1
   ENDIF
   fstat = findstring("2",bst.weekofmonth)
   IF (fstat > 0)
    reply->mlist[2].active_flag = 1
   ENDIF
   fstat = findstring("3",bst.weekofmonth)
   IF (fstat > 0)
    reply->mlist[3].active_flag = 1
   ENDIF
   fstat = findstring("4",bst.weekofmonth)
   IF (fstat > 0)
    reply->mlist[4].active_flag = 1
   ENDIF
   fstat = findstring("5",bst.weekofmonth)
   IF (fstat > 0)
    reply->mlist[5].active_flag = 1
   ENDIF
   reply->daybegin = bst.daybegin
   IF (mod(reply->daybegin,5) > 0)
    reply->daybegin = (floor((reply->daybegin/ 10)) * 10)
   ENDIF
   reply->daybegin_str = trim(bst.daybegin_str,3), reply->dayend = bst.dayend
   IF (mod(reply->dayend,5) > 0)
    reply->daybegin = (floor((reply->dayend/ 10)) * 10)
   ENDIF
   reply->dayend_str = trim(bst.dayend_str,3), reply->apply_beg_dt_tm = cnvtdatetime(bst
    .apply_beg_dt_tm), reply->apply_beg_dt_tm_str = trim(bst.apply_beg_dt_tm_string,3),
   reply->apply_end_dt_tm = cnvtdatetime(bst.apply_end_dt_tm), reply->apply_end_dt_tm_str = trim(bst
    .apply_end_dt_tm_string,3), reply->apply_range = bst.apply_range,
   reply->apply_range_str = trim(bst.apply_range_str,3)
  WITH nocounter
 ;end select
 SET new_upload = 0
 SELECT INTO "nl:"
  FROM br_sch_temp_slot_r bstsr
  PLAN (bstsr
   WHERE (bstsr.br_sch_template_id=request->br_sch_template_id))
  DETAIL
   IF (bstsr.time_block > 0)
    new_upload = 1
   ENDIF
  WITH nocounter, maxqual(bstsr,1)
 ;end select
 IF (new_upload=1)
  SET bcnt = 0
  SELECT INTO "nl:"
   FROM br_sch_temp_slot_r bstsr
   PLAN (bstsr
    WHERE (bstsr.br_sch_template_id=request->br_sch_template_id))
   DETAIL
    IF (bcnt=0)
     bcnt = (bcnt+ 1), stat = alterlist(reply->blist,bcnt)
    ELSEIF ((reply->blist[bcnt].slist[reply->blist[bcnt].scnt].time_block != bstsr.time_block))
     bcnt = (bcnt+ 1), stat = alterlist(reply->blist,bcnt)
    ENDIF
    reply->blist[bcnt].scnt = (reply->blist[bcnt].scnt+ 1), stat = alterlist(reply->blist[bcnt].slist,
     reply->blist[bcnt].scnt), reply->blist[bcnt].slist[reply->blist[bcnt].scnt].
    br_sch_temp_slot_r_id = bstsr.br_sch_temp_slot_r_id,
    reply->blist[bcnt].slist[reply->blist[bcnt].scnt].slot_name = bstsr.slot_name, reply->blist[bcnt]
    .slist[reply->blist[bcnt].scnt].slot_start = bstsr.slot_start, reply->blist[bcnt].slist[reply->
    blist[bcnt].scnt].slot_start_str = trim(bstsr.slot_start_str,3),
    reply->blist[bcnt].slist[reply->blist[bcnt].scnt].slot_end = bstsr.slot_end, reply->blist[bcnt].
    slist[reply->blist[bcnt].scnt].slot_end_str = trim(bstsr.slot_end_str,3), reply->blist[bcnt].
    slist[reply->blist[bcnt].scnt].slot_release_to = bstsr.slot_release_to,
    reply->blist[bcnt].slist[reply->blist[bcnt].scnt].slot_release_to_id = bstsr.slot_release_to_id,
    reply->blist[bcnt].slist[reply->blist[bcnt].scnt].slot_release_hrs = bstsr.slot_release_hrs,
    reply->blist[bcnt].slist[reply->blist[bcnt].scnt].slot_type_id = bstsr.slot_type_id,
    reply->blist[bcnt].slist[reply->blist[bcnt].scnt].time_block = bstsr.time_block, reply->blist[
    bcnt].slist[reply->blist[bcnt].scnt].interval = bstsr.interval, reply->blist[bcnt].slist[reply->
    blist[bcnt].scnt].interval_str = bstsr.interval_str
   WITH nocounter
  ;end select
 ELSE
  SET bcnt = 0
  SELECT INTO "nl:"
   FROM br_sch_temp_slot_r bstsr
   PLAN (bstsr
    WHERE (bstsr.br_sch_template_id=request->br_sch_template_id))
   HEAD REPORT
    bcnt = 0
   DETAIL
    bcnt = (bcnt+ 1), stat = alterlist(reply->blist,bcnt), reply->blist[bcnt].scnt = 1,
    stat = alterlist(reply->blist[bcnt].slist,1), reply->blist[bcnt].slist[reply->blist[bcnt].scnt].
    br_sch_temp_slot_r_id = bstsr.br_sch_temp_slot_r_id, reply->blist[bcnt].slist[reply->blist[bcnt].
    scnt].slot_name = bstsr.slot_name,
    reply->blist[bcnt].slist[reply->blist[bcnt].scnt].slot_start = bstsr.slot_start, reply->blist[
    bcnt].slist[reply->blist[bcnt].scnt].slot_start_str = trim(bstsr.slot_start_str,3), reply->blist[
    bcnt].slist[reply->blist[bcnt].scnt].slot_end = bstsr.slot_end,
    reply->blist[bcnt].slist[reply->blist[bcnt].scnt].slot_end_str = trim(bstsr.slot_end_str,3),
    reply->blist[bcnt].slist[reply->blist[bcnt].scnt].slot_release_to = bstsr.slot_release_to, reply
    ->blist[bcnt].slist[reply->blist[bcnt].scnt].slot_release_to_id = bstsr.slot_release_to_id,
    reply->blist[bcnt].slist[reply->blist[bcnt].scnt].slot_release_hrs = bstsr.slot_release_hrs,
    reply->blist[bcnt].slist[reply->blist[bcnt].scnt].slot_type_id = bstsr.slot_type_id, reply->
    blist[bcnt].slist[reply->blist[bcnt].scnt].time_block = bstsr.time_block,
    reply->blist[bcnt].slist[reply->blist[bcnt].scnt].interval = bstsr.interval, reply->blist[bcnt].
    slist[reply->blist[bcnt].scnt].interval_str = bstsr.interval_str
   WITH nocounter
  ;end select
 ENDIF
 FOR (j = 1 TO bcnt)
  SELECT INTO "nl:"
   FROM sch_disp_scheme sds,
    sch_slot_type sst,
    (dummyt d  WITH seq = reply->blist[j].scnt)
   PLAN (d)
    JOIN (sst
    WHERE (sst.slot_type_id=reply->blist[j].slist[d.seq].slot_type_id))
    JOIN (sds
    WHERE sst.disp_scheme_id=sds.disp_scheme_id)
   DETAIL
    reply->blist[j].slist[d.seq].slot_color = sds.back_color
   WITH nocounter
  ;end select
  FOR (i = 1 TO reply->blist[j].scnt)
    IF ((((reply->blist[j].slist[i].interval_str="")) OR ((((reply->blist[j].slist[i].interval_str=
    " ")) OR ((reply->blist[j].slist[i].interval != 0)
     AND (reply->blist[j].slist[i].interval != 5)
     AND (reply->blist[j].slist[i].interval != 10)
     AND (reply->blist[j].slist[i].interval != 15)
     AND (reply->blist[j].slist[i].interval != 20)
     AND (reply->blist[j].slist[i].interval != 30)
     AND (reply->blist[j].slist[i].interval != 60)
     AND (reply->blist[j].slist[i].interval != - (1)))) )) )
     SELECT INTO "NL:"
      FROM sch_slot_type sst
      PLAN (sst
       WHERE (sst.slot_type_id=reply->blist[j].slist[i].slot_type_id))
      DETAIL
       reply->blist[j].slist[i].interval = sst.interval
      WITH nocounter
     ;end select
    ENDIF
  ENDFOR
 ENDFOR
 SET found = 0
 SELECT INTO "nl:"
  FROM br_sch_temp_res_r bstrr
  PLAN (bstrr
   WHERE (bstrr.br_sch_template_id=request->br_sch_template_id))
  HEAD REPORT
   rcnt = 0
  DETAIL
   FOR (i = 1 TO rcnt)
     IF ((bstrr.resource_cd=reply->rlist[i].resource_cd))
      found = 1
     ENDIF
   ENDFOR
   IF (found=0)
    rcnt = (rcnt+ 1), stat = alterlist(reply->rlist,rcnt), reply->rlist[rcnt].br_sch_temp_res_r_id =
    bstrr.br_sch_temp_res_r_id,
    reply->rlist[rcnt].resource_name = bstrr.resource_name, reply->rlist[rcnt].resource_cd = bstrr
    .resource_cd
   ENDIF
   found = 0
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
