CREATE PROGRAM bhs_min_max:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Choose a Day" = "CURDATE"
  WITH outdev, date
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 FREE RECORD t_record
 RECORD t_record(
   1 beg_date = dq8
   1 end_date = dq8
   1 action_dt_tm = dq8
 )
 DECLARE t_start = q8
 DECLARE t_end = q8
 DECLARE t_min_e_id = f8
 DECLARE t_max_e_id = f8
 DECLARE t_min_ce_id = f8
 DECLARE t_max_ce_id = f8
 DECLARE t_min_o_id = f8
 DECLARE t_max_o_id = f8
 DECLARE t_min_oa_id = f8
 DECLARE t_max_oa_id = f8
 DECLARE t_min_ch_id = f8
 DECLARE t_max_ch_id = f8
 DECLARE t_min_ic_id = f8
 DECLARE t_max_ic_id = f8
 DECLARE row_exists = i2
 IF (validate(request->batch_selection))
  SET t_record->action_dt_tm = cnvtdatetime(request->ops_date)
  IF ((t_record->action_dt_tm <= 0))
   SET t_record->action_dt_tm = cnvtdatetime(curdate,curtime3)
  ENDIF
  SET t_record->action_dt_tm = datetimeadd(t_record->action_dt_tm,- (1))
  SET t_record->beg_date = datetimefind(t_record->action_dt_tm,"D","B","B")
  SET t_record->end_date = datetimefind(t_record->action_dt_tm,"D","E","E")
 ELSE
  SET t_record->action_dt_tm = cnvtdatetime(cnvtdate2( $DATE,"mm/dd/yy"),0)
  SET t_record->beg_date = datetimefind(t_record->action_dt_tm,"D","B","B")
  SET t_record->end_date = datetimefind(t_record->action_dt_tm,"D","E","E")
 ENDIF
 DECLARE num_days = i4
 SET num_days = ceil(datetimediff(t_record->end_date,t_record->beg_date))
 SET t_start = cnvtdatetime(t_record->beg_date)
 SET t_end = datetimefind(t_start,"D","E","E")
 FOR (i = 1 TO num_days)
   SELECT INTO "nl:"
    min_id = min(ce.clinical_event_id), e_min_id = min(ce.encntr_id)
    FROM clinical_event ce
    PLAN (ce
     WHERE ce.clinsig_updt_dt_tm >= cnvtdatetime(t_start)
      AND ce.clinsig_updt_dt_tm <= cnvtdatetime(t_end)
      AND ((ce.encntr_id+ 0) > 0))
    DETAIL
     t_min_ce_id = min_id, t_min_e_id = e_min_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    max_id = max(ce.clinical_event_id), e_max_id = max(ce.encntr_id)
    FROM clinical_event ce
    PLAN (ce
     WHERE ce.clinsig_updt_dt_tm >= cnvtdatetime(t_start)
      AND ce.clinsig_updt_dt_tm <= cnvtdatetime(t_end)
      AND ((ce.encntr_id+ 0) > 0))
    DETAIL
     t_max_ce_id = max_id, t_max_e_id = e_max_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM min_max mm
    PLAN (mm
     WHERE mm.mm_table="ENCOUNTER"
      AND mm.mm_date=cnvtdatetime(t_start))
    DETAIL
     row_exists = 1
    WITH nocounter
   ;end select
   IF (row_exists)
    UPDATE  FROM min_max mm
     SET mm.mm_table = "ENCOUNTER", mm.mm_date = cnvtdatetime(t_start), mm.mm_min_id = t_min_e_id,
      mm.mm_max_id = t_max_e_id
     WHERE mm.mm_table="ENCOUNTER"
      AND mm.mm_date=cnvtdatetime(t_start)
     WITH nocounter
    ;end update
    COMMIT
   ELSE
    INSERT  FROM min_max mm
     SET mm.mm_table = "ENCOUNTER", mm.mm_date = cnvtdatetime(t_start), mm.mm_min_id = t_min_e_id,
      mm.mm_max_id = t_max_e_id
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
   SET row_exists = 0
   SELECT INTO "nl:"
    FROM min_max mm
    PLAN (mm
     WHERE mm.mm_table="CLINICAL_EVENT"
      AND mm.mm_date=cnvtdatetime(t_start))
    DETAIL
     row_exists = 1
    WITH nocounter
   ;end select
   IF (row_exists)
    UPDATE  FROM min_max mm
     SET mm.mm_table = "CLINICAL_EVENT", mm.mm_date = cnvtdatetime(t_start), mm.mm_min_id =
      t_min_ce_id,
      mm.mm_max_id = t_max_ce_id
     WHERE mm.mm_table="CLINICAL_EVENT"
      AND mm.mm_date=cnvtdatetime(t_start)
     WITH nocounter
    ;end update
    COMMIT
   ELSE
    INSERT  FROM min_max mm
     SET mm.mm_table = "CLINICAL_EVENT", mm.mm_date = cnvtdatetime(t_start), mm.mm_min_id =
      t_min_ce_id,
      mm.mm_max_id = t_max_ce_id
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
   SET row_exists = 0
   SELECT INTO "nl:"
    min_id = min(o.order_id)
    FROM orders o
    PLAN (o
     WHERE o.orig_order_dt_tm >= cnvtdatetime(t_start)
      AND o.orig_order_dt_tm <= cnvtdatetime(t_end)
      AND ((o.order_id+ 0) > 0))
    DETAIL
     t_min_o_id = min_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    max_id = max(o.order_id)
    FROM orders o
    PLAN (o
     WHERE o.orig_order_dt_tm >= cnvtdatetime(t_start)
      AND o.orig_order_dt_tm <= cnvtdatetime(t_end)
      AND ((o.order_id+ 0) > 0))
    DETAIL
     t_max_o_id = max_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM min_max mm
    PLAN (mm
     WHERE mm.mm_table="ORDERS"
      AND mm.mm_date=cnvtdatetime(t_start))
    DETAIL
     row_exists = 1
    WITH nocounter
   ;end select
   IF (row_exists)
    UPDATE  FROM min_max mm
     SET mm.mm_table = "ORDERS", mm.mm_date = cnvtdatetime(t_start), mm.mm_min_id = t_min_o_id,
      mm.mm_max_id = t_max_o_id
     WHERE mm.mm_table="ORDERS"
      AND mm.mm_date=cnvtdatetime(t_start)
     WITH nocounter
    ;end update
    COMMIT
   ELSE
    INSERT  FROM min_max mm
     SET mm.mm_table = "ORDERS", mm.mm_date = cnvtdatetime(t_start), mm.mm_min_id = t_min_o_id,
      mm.mm_max_id = t_max_o_id
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
   SET row_exists = 0
   SELECT INTO "nl:"
    min_id = min(oa.order_action_id)
    FROM order_action oa
    PLAN (oa
     WHERE oa.action_dt_tm >= cnvtdatetime(t_start)
      AND oa.action_dt_tm <= cnvtdatetime(t_end)
      AND ((oa.order_action_id+ 0) > 0))
    DETAIL
     t_min_oa_id = min_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    max_id = max(oa.order_action_id)
    FROM order_action oa
    PLAN (oa
     WHERE oa.action_dt_tm >= cnvtdatetime(t_start)
      AND oa.action_dt_tm <= cnvtdatetime(t_end)
      AND ((oa.order_action_id+ 0) > 0))
    DETAIL
     t_max_oa_id = max_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM min_max mm
    PLAN (mm
     WHERE mm.mm_table="ORDER_ACTION"
      AND mm.mm_date=cnvtdatetime(t_start))
    DETAIL
     row_exists = 1
    WITH nocounter
   ;end select
   IF (row_exists)
    UPDATE  FROM min_max mm
     SET mm.mm_table = "ORDER_ACTION", mm.mm_date = cnvtdatetime(t_start), mm.mm_min_id = t_min_oa_id,
      mm.mm_max_id = t_max_oa_id
     WHERE mm.mm_table="ORDER_ACTION"
      AND mm.mm_date=cnvtdatetime(t_start)
     WITH nocounter
    ;end update
    COMMIT
   ELSE
    INSERT  FROM min_max mm
     SET mm.mm_table = "ORDER_ACTION", mm.mm_date = cnvtdatetime(t_start), mm.mm_min_id = t_min_oa_id,
      mm.mm_max_id = t_max_oa_id
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
   SET row_exists = 0
   SELECT INTO "nl:"
    min_id = min(ch.charge_item_id)
    FROM charge ch
    PLAN (ch
     WHERE ch.service_dt_tm >= cnvtdatetime(t_start)
      AND ch.service_dt_tm <= cnvtdatetime(t_end)
      AND ((ch.charge_item_id+ 0) > 0))
    DETAIL
     t_min_ch_id = min_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    max_id = max(ch.charge_item_id)
    FROM charge ch
    PLAN (ch
     WHERE ch.service_dt_tm >= cnvtdatetime(t_start)
      AND ch.service_dt_tm <= cnvtdatetime(t_end)
      AND ((ch.charge_item_id+ 0) > 0))
    DETAIL
     t_max_ch_id = max_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM min_max mm
    PLAN (mm
     WHERE mm.mm_table="CHARGE"
      AND mm.mm_date=cnvtdatetime(t_start))
    DETAIL
     row_exists = 1
    WITH nocounter
   ;end select
   IF (row_exists)
    UPDATE  FROM min_max mm
     SET mm.mm_table = "CHARGE", mm.mm_date = cnvtdatetime(t_start), mm.mm_min_id = t_min_ch_id,
      mm.mm_max_id = t_max_ch_id
     WHERE mm.mm_table="CHARGE"
      AND mm.mm_date=cnvtdatetime(t_start)
     WITH nocounter
    ;end update
    COMMIT
   ELSE
    INSERT  FROM min_max mm
     SET mm.mm_table = "CHARGE", mm.mm_date = cnvtdatetime(t_start), mm.mm_min_id = t_min_ch_id,
      mm.mm_max_id = t_max_ch_id
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
   SET row_exists = 0
   SELECT INTO "nl:"
    min_id = min(ic.interface_charge_id)
    FROM interface_charge ic
    PLAN (ic
     WHERE ic.posted_dt_tm >= cnvtdatetime(t_start)
      AND ic.posted_dt_tm <= cnvtdatetime(t_end)
      AND ((ic.interface_charge_id+ 0) > 0))
    DETAIL
     t_min_ic_id = min_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    max_id = max(ic.interface_charge_id)
    FROM interface_charge ic
    PLAN (ic
     WHERE ic.posted_dt_tm >= cnvtdatetime(t_start)
      AND ic.posted_dt_tm <= cnvtdatetime(t_end)
      AND ((ic.interface_charge_id+ 0) > 0))
    DETAIL
     t_max_ic_id = max_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM min_max mm
    PLAN (mm
     WHERE mm.mm_table="INTERFACE_CHARGE"
      AND mm.mm_date=cnvtdatetime(t_start))
    DETAIL
     row_exists = 1
    WITH nocounter
   ;end select
   IF (row_exists)
    UPDATE  FROM min_max mm
     SET mm.mm_table = "INTERFACE_CHARGE", mm.mm_date = cnvtdatetime(t_start), mm.mm_min_id =
      t_min_ic_id,
      mm.mm_max_id = t_max_ic_id
     WHERE mm.mm_table="INTERFACE_CHARGE"
      AND mm.mm_date=cnvtdatetime(t_start)
     WITH nocounter
    ;end update
    COMMIT
   ELSE
    INSERT  FROM min_max mm
     SET mm.mm_table = "INTERFACE_CHARGE", mm.mm_date = cnvtdatetime(t_start), mm.mm_min_id =
      t_min_ic_id,
      mm.mm_max_id = t_max_ic_id
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
   SET row_exists = 0
   SET t_start = datetimeadd(t_start,1)
   SET t_end = datetimefind(t_start,"D","E","E")
 ENDFOR
#exit_script
 SET reply->status_data[1].status = "S"
END GO
