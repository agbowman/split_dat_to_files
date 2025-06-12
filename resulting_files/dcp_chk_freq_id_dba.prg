CREATE PROGRAM dcp_chk_freq_id:dba
 RECORD orders(
   1 order_list[*]
     2 order_id = f8
 )
 RECORD freq(
   1 freq_list[*]
     2 order_id = f8
     2 freq_value = f8
     2 status = f8
 )
 SET failures = 0
 SET count1 = 0
 SET count2 = 0
 SELECT INTO "nl:"
  o.order_id
  FROM orders o
  WHERE o.frequency_id=0
   AND freq_type_flag > 0
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(orders->order_list,5))
    stat = alterlist(orders->order_list,(count1+ 10))
   ENDIF
   orders->order_list[count1].order_id = o.order_id
  FOOT REPORT
   stat = alterlist(orders->order_list,count1)
  WITH check
 ;end select
 SELECT INTO "nl:"
  od.oe_field_value
  FROM (dummyt d  WITH seq = value(count1)),
   order_detail od
  PLAN (d)
   JOIN (od
   WHERE (od.order_id=orders->order_list[d.seq].order_id)
    AND od.oe_field_meaning_id=2094)
  ORDER BY od.order_id, od.action_sequence DESC
  HEAD REPORT
   count2 = 0, failures = 0
  HEAD od.order_id
   count2 = (count2+ 1)
   IF (count2 > size(freq->freq_list,5))
    stat = alterlist(freq->freq_list,(count2+ 10))
   ENDIF
   IF (od.oe_field_value > 0)
    freq->freq_list[count2].status = 1, failures = (failures+ 1)
   ELSE
    freq->freq_list[count2].status = 0
   ENDIF
   freq->freq_list[count2].order_id = orders->order_list[d.seq].order_id, freq->freq_list[count2].
   freq_value = od.oe_field_value
  DETAIL
   col + 0
  FOOT REPORT
   stat = alterlist(freq->freq_list,count2)
  WITH check
 ;end select
 SET request->setup_proc[1].process_id = 798
 IF (failures=0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "Update of FREQ_ID for ORDERS SUCCEEDED"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Update of FREQ_ID for ORDERS FAILED"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
 IF (failures=0)
  CALL echo("dcp_upd_freq_id succeeded.  No outstanding orders need to have frequency_id updated.")
 ELSE
  CALL echo(build("number of failures: ",failures))
  CALL echo(
   "dcp_upd_freq_type failed.  There are still outstanding orders with frequency_id's that were not updated."
   )
 ENDIF
END GO
