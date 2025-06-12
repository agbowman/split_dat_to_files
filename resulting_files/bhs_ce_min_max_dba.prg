CREATE PROGRAM bhs_ce_min_max:dba
 FREE RECORD t_record
 RECORD t_record(
   1 beg_date = dq8
   1 end_date = dq8
 )
 DECLARE t_min_encntr_id = f8
 DECLARE t_min_ce_id = f8
 DECLARE t_min_oa_id = f8
 DECLARE t_min_o_id = f8
 DECLARE t_max_o_id = f8
 DECLARE t_max_oa_id = f8
 DECLARE t_max_encntr_id = f8
 DECLARE t_max_ce_id = f8
 DECLARE row_exists = i2
 SET start_date = cnvtdatetime("01-jul-2007 00:00:00")
 SET end_date = cnvtdatetime("31-jul-2007 23:59:59")
 DECLARE num_days = i4
 SET num_days = ceil(datetimediff(end_date,start_date))
 CALL echo(num_days)
 SET t_record->beg_date = cnvtdatetime(start_date)
 SET t_record->end_date = cnvtdatetime(end_date)
 CALL echo(format(t_record->beg_date,"DD-MM-YYYY HH:MM:SS;;Q"))
 CALL echo(format(t_record->end_date,"DD-MM-YYYY HH:MM:SS;;Q"))
 SELECT INTO "nl:"
  min_id = min(o.order_id)
  FROM orders o
  PLAN (o
   WHERE o.orig_order_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND o.orig_order_dt_tm < cnvtdatetime(t_record->end_date)
    AND ((o.order_id+ 0) > 0))
  DETAIL
   t_min_o_id = min_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  max_id = max(o.order_id)
  FROM orders o
  PLAN (o
   WHERE o.orig_order_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND o.orig_order_dt_tm < cnvtdatetime(t_record->end_date)
    AND ((o.order_id+ 0) > 0))
  DETAIL
   t_max_o_id = max_id
  WITH nocounter
 ;end select
 CALL echo(t_min_o_id)
 CALL echo(t_max_o_id)
END GO
