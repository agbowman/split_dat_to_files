CREATE PROGRAM cps_t_hm_orders:dba
 FREE RECORD orderslist
 RECORD orderslist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
     2 f_value = f8
 ) WITH protect
 FREE RECORD statuslist
 RECORD statuslist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 ) WITH protect
 DECLARE ml_time_num = i4 WITH protect, noconstant(0)
 DECLARE ml_time_option = i4 WITH protect, noconstant(0)
 DECLARE ml_count_qualified = i4 WITH protect, noconstant(0)
 DECLARE ms_order_method = vc WITH protect, noconstant("")
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE mf_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ms_order_type = vc WITH protect, noconstant("")
 DECLARE qualify_until_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(null))
 DECLARE earliest_order_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(null))
 DECLARE status_count = i4 WITH protect, noconstant(0)
 DECLARE status_list_size = i4 WITH protect, noconstant(0)
 DECLARE status_display = vc WITH protect, noconstant("")
 IF (validate(time_num,"0")="0")
  CALL echo("TIME_NUM not defined")
  SET ml_time_num = 0
 ELSEIF (isnumeric(time_num))
  SET ml_time_num = cnvtreal(time_num)
 ELSE
  CALL echo("TIME_NUM not numeric")
  SET ml_time_num = 0
 ENDIF
 IF (validate(time_unit,"Z")="Z")
  CALL echo("TIME_UNIT not defined")
 ELSE
  IF (cnvtupper(time_unit)="HOURS")
   SET ml_time_option = 3
  ELSEIF (cnvtupper(time_unit)="DAYS")
   SET ml_time_option = 1
  ELSEIF (cnvtupper(time_unit)="WEEKS")
   SET ml_time_option = 2
  ENDIF
 ENDIF
 IF (ml_time_num > 0
  AND ml_time_option > 0)
  CALL echo("Time parameters entered correctly.")
 ELSEIF (ml_time_num=0
  AND ml_time_option=0)
  CALL echo("Time parameters entered correctly.")
 ELSE
  CALL echo("Some but not all time parameters entered.")
  SET retval = - (1)
  GO TO exit_program
 ENDIF
 IF (validate(order_type,"Z")="Z")
  CALL echo("ORDER_TYPE not defined")
  SET ms_order_type = "ORDER"
 ELSEIF (trim(cnvtupper(order_type)) IN ("PRESCRIPTION", "ORDER"))
  SET ms_order_type = trim(cnvtupper(order_type))
 ELSE
  CALL echo("ORDER_TYPE not valid")
  SET ms_order_type = "ORDER"
 ENDIF
 IF (validate(order_method,"Z")="Z")
  CALL echo("ORDER_METHOD not defined")
  SET retval = - (1)
  GO TO exit_program
 ELSEIF (trim(cnvtupper(order_method)) IN ("THAT WAS ORDERED AS", "WHOSE PRIMARY MNEMONIC IS",
 "WITH DRUG CLASS AS"))
  SET ms_order_method = trim(cnvtupper(order_method))
 ELSE
  CALL echo("ORDER_METHOD not valid")
  SET retval = - (1)
  GO TO exit_program
 ENDIF
 IF (validate(orders,"Z")="Z"
  AND validate(orders,"Y")="Y")
  CALL echo("ORDERS not defined. This parameter is required.")
 ELSE
  SET orig_param = orders
  EXECUTE eks_t_parse_list  WITH replace(reply,orderslist)
  FREE SET orig_param
  IF ((orderslist->cnt=0))
   CALL echo("ORDERS empty. This parameter is required.")
   SET retval = - (1)
   GO TO exit_program
  ENDIF
 ENDIF
 IF (validate(status,"Z")="Z"
  AND validate(status,"Y")="Y")
  CALL echo("STATUS not defined")
 ELSE
  SET orig_param = status
  EXECUTE eks_t_parse_list  WITH replace(reply,statuslist)
  FREE SET orig_param
  SET status_list_size = statuslist->cnt
  IF (status_list_size > 0)
   SET status_count = 1
   WHILE (status_count <= status_list_size)
    SET status_display = statuslist->qual[status_count].display
    SET status_count = (status_count+ 1)
   ENDWHILE
   SET mf_status_cd = uar_get_code_by("DISPLAYKEY",6004,status_display)
   CALL echo(build2("STATUS: Order status found. Code Id:",mf_status_cd))
  ENDIF
 ENDIF
 IF (ms_order_method="WITH DRUG CLASS AS")
  SELECT DISTINCT INTO "nl:"
   cat_cd = eksdrugclassex->qual[d2.seq].catalog_cd, cat_id = eksdrugclassex->qual[d2.seq].
   category_id
   FROM (dummyt d1  WITH seq = value(orderslist->cnt)),
    (dummyt d2  WITH seq = value(eksdrugclassex->cnt))
   PLAN (d1)
    JOIN (d2
    WHERE (eksdrugclassex->qual[d2.seq].category_id=cnvtreal(orderslist->qual[d1.seq].value)))
   ORDER BY cat_cd
   HEAD REPORT
    orderslist->cnt = 0
   DETAIL
    orderslist->cnt = (orderslist->cnt+ 1)
    IF (mod(orderslist->cnt,100)=1)
     stat = alterlist(orderslist->qual,(orderslist->cnt+ 99))
    ENDIF
    orderslist->qual[orderslist->cnt].value = cnvtstring(cat_cd), orderslist->qual[orderslist->cnt].
    display = uar_get_code_display(cat_cd)
   FOOT REPORT
    stat = alterlist(orderslist->qual,orderslist->cnt)
   WITH nocounter, nullreport
  ;end select
  IF ((orderslist->cnt=0))
   CALL echo("Drug Class names entered did not match drug classes loaded by server.")
   SET retval = - (1)
   GO TO exit_program
  ENDIF
 ENDIF
 FOR (ml_idx = 1 TO orderslist->cnt)
   IF (isnumeric(orderslist->qual[ml_idx].value))
    SET orderslist->qual[ml_idx].f_value = cnvtreal(orderslist->qual[ml_idx].value)
   ENDIF
 ENDFOR
 SELECT
  IF (ms_order_method IN ("WITH DRUG CLASS AS", "WHOSE PRIMARY MNEMONIC IS"))
   WHERE expand(ml_idx,1,orderslist->cnt,request->orders[d.seq].catalog_cd,orderslist->qual[ml_idx].
    f_value)
  ELSE
   WHERE expand(ml_idx,1,orderslist->cnt,request->orders[d.seq].synonym_id,orderslist->qual[ml_idx].
    f_value)
  ENDIF
  INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(request->orders,5)))
  PLAN (d)
  ORDER BY request->orders[d.seq].orig_order_dt_tm DESC
  HEAD REPORT
   mn_past_date_range = 0
  DETAIL
   mn_date_qualifies = 0, mn_status_qualifies = 0, mn_type_qualifies = 0
   IF (ml_time_num > 0)
    IF (mn_past_date_range=0)
     IF (datetimediff(sysdate,request->orders[d.seq].orig_order_dt_tm,ml_time_option) <= ml_time_num)
      mn_date_qualifies = 1
     ELSE
      mn_past_date_range = 1
     ENDIF
    ENDIF
   ELSE
    mn_date_qualifies = 1
   ENDIF
   IF (mf_status_cd > 0)
    IF ((request->orders[d.seq].order_status_cd=mf_status_cd))
     mn_status_qualifies = 1
    ENDIF
   ELSEIF ((mf_status_cd=- (1)))
    mn_status_qualifies = 0
   ELSE
    mn_status_qualifies = 1
   ENDIF
   IF (ms_order_type="PRESCRIPTION")
    IF ((request->orders[d.seq].orig_ord_as_flag IN (1, 2)))
     mn_type_qualifies = 1
    ELSE
     mn_type_qualifies = 0
    ENDIF
   ELSE
    mn_type_qualifies = 1
   ENDIF
   IF (mn_date_qualifies=1
    AND mn_status_qualifies=1
    AND mn_type_qualifies=1)
    IF (earliest_order_dt_tm=null)
     earliest_order_dt_tm = request->orders[d.seq].orig_order_dt_tm
    ELSEIF ((earliest_order_dt_tm < request->orders[d.seq].orig_order_dt_tm))
     earliest_order_dt_tm = request->orders[d.seq].orig_order_dt_tm
    ENDIF
    ml_count_qualified = (ml_count_qualified+ 1)
   ENDIF
  WITH nocounter
 ;end select
 IF (ml_count_qualified > 0)
  CALL echo("Rule evaluated to TRUE")
  SET retval = 100
 ELSE
  CALL echo("Rule evaluated to FALSE")
  SET retval = 0
 ENDIF
#exit_program
 IF (retval=100
  AND ml_time_option > 0
  AND ml_time_num > 0
  AND earliest_order_dt_tm != null)
  IF (ml_time_option=1)
   SET look_ahead = build2(ml_time_num,",D")
  ELSEIF (ml_time_option=2)
   SET look_ahead = build2(ml_time_num,",W")
  ELSEIF (ml_time_option=3)
   SET look_ahead = build2(ml_time_num,",H")
  ENDIF
  SET cur_series_index = size(reply->expectation_series,5)
  SET qualify_until_dt_tm = cnvtlookahead(look_ahead,earliest_order_dt_tm)
  IF ((reply->expectation_series[cur_series_index].qualify_until_dt_tm=null))
   SET reply->expectation_series[cur_series_index].qualify_until_dt_tm = qualify_until_dt_tm
  ELSEIF ((reply->expectation_series[cur_series_index].qualify_until_dt_tm != null)
   AND (reply->expectation_series[cur_series_index].qualify_until_dt_tm < qualify_until_dt_tm))
   SET reply->expectation_series[cur_series_index].qualify_until_dt_tm = qualify_until_dt_tm
  ENDIF
 ENDIF
 FREE RECORD order_typelist
END GO
