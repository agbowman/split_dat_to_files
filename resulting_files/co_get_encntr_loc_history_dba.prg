CREATE PROGRAM co_get_encntr_loc_history:dba
 RECORD reply(
   1 encntr_list[*]
     2 encntr_id = f8
     2 location_hist_list[*]
       3 nurse_unit_cd = f8
       3 nurse_unit_desc = vc
       3 nurse_unit_disp = vc
       3 nurse_unit_mean = vc
       3 room_cd = f8
       3 room_desc = vc
       3 room_disp = vc
       3 room_mean = vc
       3 bed_cd = f8
       3 bed_desc = vc
       3 bed_disp = vc
       3 bed_mean = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 transaction_dt_tm = dq8
       3 icu_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET replylistsize = size(request->encntr_list,5)
 SET stat = alterlist(reply->encntr_list,replylistsize)
 SET reply->status_data.status = "S"
 IF (size(request->encntr_list,5) > 0)
  SELECT INTO "nl:"
   FROM encntr_loc_hist elh,
    location l,
    (dummyt d  WITH seq = replylistsize)
   PLAN (d)
    JOIN (elh
    WHERE (elh.encntr_id=request->encntr_list[d.seq].encntr_id)
     AND elh.active_ind=1)
    JOIN (l
    WHERE l.location_cd=elh.loc_nurse_unit_cd
     AND l.active_ind=1)
   ORDER BY d.seq, elh.end_effective_dt_tm DESC
   HEAD d.seq
    reply->encntr_list[d.seq].encntr_id = request->encntr_list[d.seq].encntr_id, cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->encntr_list[d.seq].location_hist_list,cnt), reply->
    encntr_list[d.seq].location_hist_list[cnt].beg_effective_dt_tm = elh.beg_effective_dt_tm,
    reply->encntr_list[d.seq].location_hist_list[cnt].end_effective_dt_tm = elh.end_effective_dt_tm,
    reply->encntr_list[d.seq].location_hist_list[cnt].nurse_unit_cd = elh.loc_nurse_unit_cd, reply->
    encntr_list[d.seq].location_hist_list[cnt].room_cd = elh.loc_room_cd,
    reply->encntr_list[d.seq].location_hist_list[cnt].bed_cd = elh.loc_bed_cd, reply->encntr_list[d
    .seq].location_hist_list[cnt].transaction_dt_tm = elh.transaction_dt_tm, reply->encntr_list[d.seq
    ].location_hist_list[cnt].icu_ind = l.icu_ind
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(reply)
END GO
