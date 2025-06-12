CREATE PROGRAM dpo_oen_cqm_que_rows:dba
 SET dpo_reply->status_data.status = "F"
 SET dpo_reply->owner_name = "V500"
 SET dpo_reply->table_name = "CQM_OENINTERFACE_QUE"
 SET dpo_reply->fetch_size = minval(10000,b_request->max_rows)
 DECLARE purgedate = dq8 WITH protect, noconstant(0.0)
 SET purgedate = cnvtdatetime((curdate - 1),0)
 SET dpo_reply->cursor_query = build(
  "select rowid from V500.CQM_OENINTERFACE_QUE q WHERE CREATE_DT_TM <"," to_date('",format(purgedate,
   "DD/MM/YYYY HH:MM:SS;;Q"),"','DD/MM/YYYY HH24:MI:SS')"," and queue_id > 0  and  NOT EXISTS(",
  "select t.queue_id from cqm_oeninterface_tr_1 t where t.queue_id = ","q.queue_id )")
 SET dpo_reply->status_data.status = "S"
 SET dpo_reply->err_code = 0
#exit_script
END GO
