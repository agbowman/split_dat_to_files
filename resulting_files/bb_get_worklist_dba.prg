CREATE PROGRAM bb_get_worklist:dba
 RECORD reply(
   1 worklist_list[*]
     2 worklist_id = f8
     2 worklist_name = c40
     2 worklist_name_key = c40
     2 create_dt_tm = dq8
     2 create_prsnl_id = f8
     2 create_prsnl_username = vc
     2 qc_group_id = f8
     2 qc_group_name = c40
     2 test_group_id = f8
     2 test_group_name = c40
     2 download_ind = i2
     2 last_download_dt_tm = dq8
     2 updt_cnt = i4
     2 worklist_detail_list[*]
       3 worklist_detail_id = f8
       3 order_id = f8
       3 product_id = f8
       3 product_nbr = vc
       3 accession = c20
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE select_ok_flag = i2 WITH protected, noconstant(0)
 DECLARE count1 = i4 WITH private, noconstant(0)
 SELECT INTO "nl:"
  FROM bb_worklist w,
   bb_worklist_detail wd,
   bb_qc_group qc,
   bb_test_group tg,
   prsnl pnl,
   orders o,
   accession_order_r aor,
   product pr
  PLAN (w
   WHERE w.worklist_id > 0.0)
   JOIN (wd
   WHERE wd.worklist_id=w.worklist_id
    AND wd.worklist_detail_id > 0.0)
   JOIN (qc
   WHERE qc.group_id=w.qc_group_id)
   JOIN (tg
   WHERE tg.bb_test_group_id=w.test_group_id)
   JOIN (pnl
   WHERE pnl.person_id=w.create_prsnl_id)
   JOIN (o
   WHERE o.order_id=wd.order_id)
   JOIN (aor
   WHERE aor.order_id=outerjoin(wd.order_id)
    AND aor.primary_flag=outerjoin(0))
   JOIN (pr
   WHERE pr.product_id=outerjoin(o.product_id))
  ORDER BY w.worklist_id, wd.worklist_detail_id
  HEAD REPORT
   w_cnt = 0, wd_cnt = 0
  HEAD w.worklist_id
   w_cnt = (w_cnt+ 1), wd_cnt = 0
   IF (size(reply->worklist_list,5) <= w_cnt)
    stat = alterlist(reply->worklist_list,(w_cnt+ 5))
   ENDIF
   reply->worklist_list[w_cnt].worklist_id = w.worklist_id, reply->worklist_list[w_cnt].worklist_name
    = w.worklist_name, reply->worklist_list[w_cnt].worklist_name_key = w.worklist_name_key,
   reply->worklist_list[w_cnt].create_dt_tm = cnvtdatetime(w.create_dt_tm), reply->worklist_list[
   w_cnt].create_prsnl_id = w.create_prsnl_id, reply->worklist_list[w_cnt].create_prsnl_username =
   pnl.username,
   reply->worklist_list[w_cnt].qc_group_id = qc.group_id, reply->worklist_list[w_cnt].qc_group_name
    = qc.group_name, reply->worklist_list[w_cnt].test_group_id = tg.bb_test_group_id,
   reply->worklist_list[w_cnt].test_group_name = tg.test_group_display, reply->worklist_list[w_cnt].
   download_ind = w.download_ind, reply->worklist_list[w_cnt].last_download_dt_tm = cnvtdatetime(w
    .last_download_dt_tm),
   reply->worklist_list[w_cnt].updt_cnt = w.updt_cnt
  HEAD wd.worklist_detail_id
   wd_cnt = (wd_cnt+ 1)
   IF (size(reply->worklist_list[w_cnt].worklist_detail_list,5) <= wd_cnt)
    stat = alterlist(reply->worklist_list[w_cnt].worklist_detail_list,(wd_cnt+ 10))
   ENDIF
   reply->worklist_list[w_cnt].worklist_detail_list[wd_cnt].worklist_detail_id = wd
   .worklist_detail_id
   IF (aor.accession_id > 0)
    reply->worklist_list[w_cnt].worklist_detail_list[wd_cnt].accession = aor.accession
   ENDIF
   reply->worklist_list[w_cnt].worklist_detail_list[wd_cnt].order_id = o.order_id, reply->
   worklist_list[w_cnt].worklist_detail_list[wd_cnt].product_id = o.product_id
   IF (pr.product_id > 0)
    reply->worklist_list[w_cnt].worklist_detail_list[wd_cnt].product_nbr = pr.product_nbr
   ENDIF
   reply->worklist_list[w_cnt].worklist_detail_list[wd_cnt].updt_cnt = wd.updt_cnt
  DETAIL
   row + 0
  FOOT  wd.worklist_detail_id
   row + 0
  FOOT  w.worklist_id
   IF (wd_cnt > 0)
    stat = alterlist(reply->worklist_list[w_cnt].worklist_detail_list,wd_cnt)
   ENDIF
  FOOT REPORT
   select_ok_flag = 1
   IF (w_cnt > 0)
    stat = alterlist(reply->worklist_list,w_cnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET select_ok_flag = 2
 ENDIF
 IF (select_ok_flag=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "Select failed"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bb_get_worklist"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = build("Failed to retrieve data.")
 ELSEIF (select_ok_flag=1)
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = "Select successful"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bb_get_worklist"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = build(
   "All possible data generated successfully.")
 ELSEIF (select_ok_flag=2)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "Select successful"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bb_get_worklist"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = build(
   "BB_WORKLIST data does not exist.")
 ENDIF
END GO
