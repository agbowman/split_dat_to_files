CREATE PROGRAM co_calc_loc_admit_dt:dba
 RECORD reply(
   1 encntr_list[*]
     2 encntr_id = f8
     2 icu_transfer_in_dt_tm = dq8
 )
 SET num = 0
 SET stat = alterlist(reply->encntr_list,size(request->encntr_list,5))
 SET prev_icu_ind = - (1)
 SELECT INTO "nl:"
  FROM encntr_loc_hist elh,
   location l
  PLAN (elh
   WHERE expand(num,1,size(request->encntr_list,5),elh.encntr_id,request->encntr_list[num].encntr_id)
    AND elh.active_ind=1)
   JOIN (l
   WHERE l.location_cd=elh.loc_nurse_unit_cd)
  ORDER BY elh.encntr_id, cnvtdatetime(elh.transaction_dt_tm) DESC
  HEAD REPORT
   cnt = 0
  HEAD elh.encntr_id
   IF (elh.encntr_id > 0)
    cnt = (cnt+ 1), stop_ind = 0, prev_icu_ind = - (1),
    stat = alterlist(reply->encntr_list,cnt), reply->encntr_list[cnt].encntr_id = elh.encntr_id
   ENDIF
  DETAIL
   curr_icu_ind = l.icu_ind
   IF (((stop_ind=0
    AND curr_icu_ind=1) OR (stop_ind=0
    AND curr_icu_ind=1
    AND prev_icu_ind=1)) )
    this_transfer = cnvtdatetime(elh.transaction_dt_tm)
   ENDIF
   IF (prev_icu_ind=1
    AND curr_icu_ind=0)
    stop_ind = 1
   ENDIF
   IF (stop_ind=0)
    prev_icu_ind = curr_icu_ind
   ENDIF
  FOOT  elh.encntr_id
   this_date_no_seconds = format(this_transfer,"DD-MMM-YYYY HH:MM;;D"), reply->encntr_list[cnt].
   icu_transfer_in_dt_tm = cnvtdatetime(this_date_no_seconds)
  FOOT REPORT
   stat = alterlist(reply->encntr_list,cnt)
  WITH nocounter
 ;end select
END GO
