CREATE PROGRAM afc_upt_price_sched_times:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Executing afc_upt_price_sched_times."
 SET table_exists = "F"
 RECORD price_scheds(
   1 scheds[*]
     2 price_sched_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 SELECT INTO "nl:"
  FROM user_tab_columns utc
  WHERE utc.table_name="PRICE_SCHED"
  DETAIL
   table_exists = "T"
  WITH nocounter
 ;end select
 IF (table_exists="T")
  SET num_scheds = 0
  SELECT INTO "nl:"
   FROM price_sched p
   DETAIL
    num_scheds = (num_scheds+ 1), stat = alterlist(price_scheds->scheds,num_scheds), price_scheds->
    scheds[num_scheds].price_sched_id = p.price_sched_id,
    price_scheds->scheds[num_scheds].beg_effective_dt_tm = p.beg_effective_dt_tm, price_scheds->
    scheds[num_scheds].end_effective_dt_tm = p.end_effective_dt_tm
   WITH nocounter
  ;end select
  IF (curqual > 0)
   UPDATE  FROM price_sched p,
     (dummyt d  WITH seq = value(size(price_scheds->scheds,5)))
    SET p.beg_effective_dt_tm = cnvtdatetime(concat(format(price_scheds->scheds[d.seq].
        beg_effective_dt_tm,"DD-MMM-YYYY;;D")," 00:00:00.00")), p.end_effective_dt_tm = cnvtdatetime(
      concat(format(price_scheds->scheds[d.seq].end_effective_dt_tm,"DD-MMM-YYYY;;D")," 23:59:59.99")
      )
    PLAN (d)
     JOIN (p
     WHERE (p.price_sched_id=price_scheds->scheds[d.seq].price_sched_id))
    WITH nocounter
   ;end update
   SET readme_data->message = build("# of price schedules updated: ",value(size(price_scheds->scheds,
      5)))
   COMMIT
   IF (curqual > 0)
    SET readme_data->status = "S"
    SET readme_data->message = "Price sched times updated."
   ELSE
    SET readme_data->status = "F"
    SET readme_data->message = "Price sched times not updated."
   ENDIF
   EXECUTE dm_readme_status
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = "No Rows on Price sched table to update."
  ENDIF
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Price sched table does not exist."
 ENDIF
 FREE SET price_scheds
END GO
