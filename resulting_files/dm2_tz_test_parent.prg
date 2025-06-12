CREATE PROGRAM dm2_tz_test_parent
 RECORD t(
   1 cnt = i4
   1 from_value = i4
   1 to_value = i4
   1 qual[*]
     2 table_name = vc
     2 column_name = vc
     2 tz_value = f8
     2 tz_cnt = i4
     2 conditional_tz_cnt = i4
 )
 SET t->from_value =  $1
 SET t->to_value =  $2
 DECLARE str2 = vc
 EXECUTE dm2_tz_test " ORDER_ACTION", "ACTION_TZ",  $1,
  $2, build(' t.action_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " ORDER_ACTION", "EFFECTIVE_TZ",  $1,
  $2, build(' t.action_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " ORDER_ACTION", "ORDER_TZ",  $1,
  $2, build(' t.action_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " ORDER_ACTION", "PROJECTED_STOP_TZ",  $1,
  $2, build(' t.action_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " ORDER_DETAIL", "OE_FIELD_TZ",  $1,
  $2, build(' t.updt_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " ORDER_REVIEW", "REVIEW_TZ",  $1,
  $2, build(' t.review_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " ORDERS", "CURRENT_START_TZ",  $1,
  $2, build(' t.updt_dt_tm < cnvtdatetime("', $3,'")')
 SET str2 = build(' exists (select "x" from order_action oa where oa.order_id = t.order_id',
  " and oa.action_type_cd in (select cv.code_value from code_value cv ",
  ' where cv.code_set=6003 and cv.cdf_meaning in ("DISCONTINUE","FUTUREDC"))',
  ' and oa.action_dt_tm < cnvtdatetime("', $3,
  '")'," and oa.action_dt_tm = (select max(oa2.action_dt_tm)"," from code_value cv, order_action oa2",
  ' where cv.code_set=6003 and cv.cdf_meaning in ("DISCONTINUE","FUTUREDC")',
  " and oa2.order_id = t.order_id",
  " and oa2.action_type_cd = cv.code_value))")
 EXECUTE dm2_tz_test " ORDERS", "DISCONTINUE_EFFECTIVE_TZ",  $1,
  $2, str2
 SET str2 = build(' exists (select "x" from order_action oa where oa.order_id = t.order_id',
  " and oa.action_sequence = 1",' and oa.action_dt_tm < cnvtdatetime("', $3,'"))')
 EXECUTE dm2_tz_test " ORDERS", "ORIG_ORDER_TZ",  $1,
  $2, str2
 EXECUTE dm2_tz_test " ORDERS", "PROJECTED_STOP_TZ",  $1,
  $2, build(' t.updt_dt_tm < cnvtdatetime("', $3,'")')
 SET str2 = build(' exists (select "x" from order_action oa where oa.order_id = t.order_id',
  " and oa.action_type_cd in (select cv.code_value from code_value cv ",
  ' where cv.code_set=6003 and cv.cdf_meaning in ("RESUME"))',' and oa.action_dt_tm < cnvtdatetime("',
   $3,
  '")'," and oa.action_dt_tm = (select max(oa2.action_dt_tm)"," from code_value cv, order_action oa2",
  ' where cv.code_set=6003 and cv.cdf_meaning in ("RESUME")'," and oa2.order_id = t.order_id",
  " and oa2.action_type_cd = cv.code_value))")
 EXECUTE dm2_tz_test " ORDERS", "RESUME_EFFECTIVE_TZ",  $1,
  $2, str2
 SET str2 = build(' exists (select "x" from order_action oa where oa.order_id = t.order_id',
  " and oa.action_type_cd in (select cv.code_value from code_value cv ",
  ' where cv.code_set=6003 and cv.cdf_meaning in ("SUSPEND"))',
  ' and oa.action_dt_tm < cnvtdatetime("', $3,
  '")'," and oa.action_dt_tm = (select max(oa2.action_dt_tm)"," from code_value cv, order_action oa2",
  ' where cv.code_set=6003 and cv.cdf_meaning in ("SUSPEND")'," and oa2.order_id = t.order_id",
  " and oa2.action_type_cd = cv.code_value))")
 EXECUTE dm2_tz_test " ORDERS", "SUSPEND_EFFECTIVE_TZ",  $1,
  $2, str2
 EXECUTE dm2_tz_test " FILL_BATCH_HX", "FROM_TZ",  $1,
  $2, build(' t.updt_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " FILL_BATCH_HX", "START_TZ",  $1,
  $2, build(' t.updt_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " FILL_BATCH_HX", "TO_TZ",  $1,
  $2, build(' t.updt_dt_tm < cnvtdatetime("', $3,'")')
 SET str2 = build(' exists (select "x"'," from fill_cycle_hx fch ",
  " where fch.fill_hx_id = t.fill_cycle_id",' and fch.start_dt_tm < cnvtdatetime("', $3,
  '"))')
 EXECUTE dm2_tz_test " FILL_CYCLE", "FROM_TZ",  $1,
  $2, str2
 SET str2 = build(' exists (select "x"'," from fill_cycle_hx fch ",
  " where fch.fill_hx_id = t.fill_cycle_id",' and fch.start_dt_tm < cnvtdatetime("', $3,
  '"))')
 EXECUTE dm2_tz_test " FILL_CYCLE", "TO_TZ",  $1,
  $2, str2
 EXECUTE dm2_tz_test " FILL_CYCLE_HX", "FROM_TZ",  $1,
  $2, build(' t.start_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " FILL_CYCLE_HX", "TO_TZ",  $1,
  $2, build(' t.start_dt_tm < cnvtdatetime("', $3,'")')
 SET str2 = build(
  '         t.pharm_type_cd in (select code_value from code_value where code_set = 4500 and cdf_meaning = "INPATIENT") ',
  "  and ",'      ((cnvtdatetime("', $3,'") > ',
  "        (select max(oa.action_dt_tm)","	 	from order_action oa, code_value cv",
  "		where cv.code_set = 6003",
  '		and cv.cdf_meaning in ("MODIFY","RESUME","RENEW","ORDER","RESCHEDULE")',
  "		and oa.action_type_cd = cv.code_value ",
  "		and oa.order_id = t.order_id))","  or",'      (cnvtdatetime("', $3,'") > ',
  "		(select max(dh.updt_dt_tm)","		 from dispense_hx dh, code_value cv",
  "		 where cv.code_set = 4032 and ",
  '		 	  (cv.cdf_meaning in ("CHGONADMIN","CRDTONADMIN","DEVICEDISPEN",',
  '		 	      "DEVICERETURN","MANUALCHARGE","MANUALCREDIT","FIRSTDOSE",',
  '		 	      "INITIALDOSE","FILLLIST"))',"		   and dh.disp_event_type_cd = cv.code_value and ",
  "                                 dh.order_id = t.order_id)))")
 EXECUTE dm2_tz_test " ORDER_DISPENSE", "NEXT_DISPENSE_TZ",  $1,
  $2, str2
 SET str2 = build(' exists (select "x" from order_action oa where oa.order_id = t.order_id',
  " and oa.action_type_cd in (select cv.code_value from code_value cv ",
  ' where cv.code_set=6003 and cv.cdf_meaning in ("RESUME"))',' and oa.action_dt_tm < cnvtdatetime("',
   $3,
  '")'," and oa.action_dt_tm = (select max(oa2.action_dt_tm)"," from code_value cv, order_action oa2",
  ' where cv.code_set=6003 and cv.cdf_meaning in ("RESUME")'," and oa2.order_id = t.order_id",
  " and oa2.action_type_cd = cv.code_value))")
 EXECUTE dm2_tz_test " ORDER_DISPENSE", "RESUME_TZ",  $1,
  $2, str2
 SET str2 = build(' exists (select "x" from order_detail od'," where od.order_id = t.order_id",
  ' and od.oe_field_meaning = "RXSTARTDISPDTTM"',' and od.updt_dt_tm < cnvtdatetime("', $3,
  '")'," and od.updt_dt_tm = (select max(od1.updt_dt_tm)",
  " from order_detail od1 where od1.order_id = t.order_id",
  ' and od.oe_field_meaning = "RXSTARTDISPDTTM"))')
 EXECUTE dm2_tz_test " ORDER_DISPENSE", "START_DISPENSE_TZ",  $1,
  $2, str2
 SET str2 = build(' exists (select "x" from order_detail od'," where od.order_id = t.order_id",
  ' and od.oe_field_meaning = "STOPDTTM"',' and od.updt_dt_tm < cnvtdatetime("', $3,
  '"))')
 EXECUTE dm2_tz_test " ORDER_DISPENSE", "STOP_TZ",  $1,
  $2, str2
 SET str2 = build(' exists (select "x" from order_detail od'," where od.order_id = t.order_id",
  ' and od.oe_field_meaning = "SUSPEND"',' and od.updt_dt_tm < cnvtdatetime("', $3,
  '"))')
 EXECUTE dm2_tz_test " ORDER_DISPENSE", "SUSPEND_TZ",  $1,
  $2, str2
 EXECUTE dm2_tz_test " MED_ADMIN_EVENT", "SCHEDULED_TZ",  $1,
  $2, build(' t.updt_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " MED_ADMIN_EVENT", "VERIFICATION_TZ",  $1,
  $2, build(' t.updt_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " MED_ADMIN_MED_ERROR", "ADMIN_TZ",  $1,
  $2, build(' t.updt_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " MED_ADMIN_MED_ERROR", "SCHEDULED_TZ",  $1,
  $2, build(' t.updt_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " MED_ADMIN_MED_ERROR", "VERIFICATION_TZ",  $1,
  $2, build(' t.updt_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " DCP_FORMS_ACTIVITY", "FORM_TZ",  $1,
  $2, build(' t.updt_dt_tm < cnvtdatetime("', $3,'")',' or t.last_activity_dt_tm < cnvtdatetime("',
   $3,
  '")')
 EXECUTE dm2_tz_test " EEM_ABN_CHECK", "BIRTH_TZ",  $1,
  $2, build(' t.active_status_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " SCH_EVENT_DISP", "DISP_TZ",  $1,
  $2, build(' t.updt_dt_tm < cnvtdatetime("', $3,'")'," and t.disp_field_id = 15")
 EXECUTE dm2_tz_test " TASK_ACTIVITY", "TASK_TZ",  $1,
  $2, build(' t.updt_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " CE_DATE_RESULT", "RESULT_TZ",  $1,
  $2, build(' t.valid_from_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " CE_EVENT_NOTE", "NOTE_TZ",  $1,
  $2, build(' t.valid_from_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " CE_EVENT_PRSNL", "ACTION_TZ",  $1,
  $2, build(' t.valid_from_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " CE_EVENT_PRSNL", "REQUEST_TZ",  $1,
  $2, build(' t.valid_from_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " CE_MED_RESULT", "ADMIN_END_TZ",  $1,
  $2, build(' t.valid_from_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " CE_MED_RESULT", "ADMIN_START_TZ",  $1,
  $2, build(' t.valid_from_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " CE_SPECIMEN_COLL", "COLLECT_TZ",  $1,
  $2, build(' t.valid_from_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " CE_SUSCEPTIBILITY", "RESULT_TZ",  $1,
  $2, build(' t.valid_from_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " CLINICAL_EVENT", "EVENT_END_TZ",  $1,
  $2, build(' t.valid_from_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " CLINICAL_EVENT", "EVENT_START_TZ",  $1,
  $2, build(' t.valid_from_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " CLINICAL_EVENT", "PERFORMED_TZ",  $1,
  $2, build(' t.valid_from_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " CLINICAL_EVENT", "VERIFIED_TZ",  $1,
  $2, build(' t.valid_from_dt_tm < cnvtdatetime("', $3,'")')
 EXECUTE dm2_tz_test " PERSON", "BIRTH_TZ",  $1,
  $2, build(' t.updt_dt_tm < cnvtdatetime("', $3,'")')
 SELECT
  d.*
  FROM (dummyt d  WITH seq = value(t->cnt))
  PLAN (d
   WHERE 1=1)
  HEAD REPORT
   sysdate";;q", row + 1, "From Value",
   t->from_value, row + 1, "To Value",
   t->to_value, row + 1, "SRV Date",
    $3, row + 1, "Table Name",
   col 30, "Column Name", col 60,
   "TZ Value", col 75, "Condition Cnt",
   col 90, "Total Cnt", row + 1
  DETAIL
   t->qual[d.seq].table_name, col 30, t->qual[d.seq].column_name,
   col 60, t->qual[d.seq].tz_value, col 75,
   t->qual[d.seq].conditional_tz_cnt, col 90, t->qual[d.seq].tz_cnt,
   row + 1
  WITH nocounter
 ;end select
END GO
