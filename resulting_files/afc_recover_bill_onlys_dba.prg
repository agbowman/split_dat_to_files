CREATE PROGRAM afc_recover_bill_onlys:dba
 EXECUTE cclseclogin
 SET message = nowindow
 FREE SET bo
 RECORD bo(
   1 bos[*]
     2 order_id = f8
     2 ref_id = f8
 )
 SET test_mode = cnvtint( $1)
 IF (test_mode=1)
  CALL echo("Running in test mode.")
 ELSE
  CALL echo("Running in commit mode.")
 ENDIF
 SET from_date = cnvtdatetime( $2)
 CALL echo(build("the from date is: ",format(from_date,"DD-MMM-YYYY HH:MM:SS;;d")))
 SET to_date = cnvtdatetime( $3)
 CALL echo(build("the to date is: ",format(to_date,"DD-MMM-YYYY HH:MM:SS;;d")))
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE bill_only_cd = f8
 DECLARE exam_complete_cd = f8
 SET code_set = 289
 SET cdf_meaning = "17"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,bill_only_cd)
 CALL echo(build("the bill only code value is: ",bill_only_cd))
 SET code_set = 13029
 SET cdf_meaning = "EXAMCOMPLETE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,exam_complete_cd)
 CALL echo(build("the exam complete code value is: ",exam_complete_cd))
 SET count = 0
 SELECT INTO "nl:"
  FROM rad_exam r,
   discrete_task_assay dta
  PLAN (r
   WHERE r.complete_dt_tm BETWEEN cnvtdatetime(from_date) AND cnvtdatetime(to_date))
   JOIN (dta
   WHERE dta.task_assay_cd=r.task_assay_cd
    AND dta.default_result_type_cd=bill_only_cd)
  DETAIL
   count = (count+ 1), stat = alterlist(bo->bos,count), bo->bos[count].order_id = r.order_id,
   bo->bos[count].ref_id = r.task_assay_cd
  WITH nocounter
 ;end select
 CALL echo(build("the count is: ",count))
 IF (count > 0)
  SET done = 0
  SET next_cs_id = 0.0
  WHILE (done=0)
   SET done = 1
   SELECT INTO "nl:"
    next_cs_id = o.cs_order_id
    FROM (dummyt d1  WITH seq = value(size(bo->bos,5))),
     orders o
    PLAN (d1)
     JOIN (o
     WHERE (o.order_id=bo->bos[d1.seq].order_id))
    DETAIL
     IF (o.cs_order_id != 0)
      done = 0, bo->bos[d1.seq].order_id = o.cs_order_id
     ENDIF
    WITH nocounter
   ;end select
  ENDWHILE
  RECORD del_events(
    1 events[*]
      2 cea_id = f8
      2 bo_desc = vc
      2 order_id = f8
  )
  SET count = 0
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(bo->bos,5))),
    charge_event ce,
    charge_event_act cea,
    charge c,
    dummyt d2
   PLAN (d1)
    JOIN (ce
    WHERE (ce.ext_m_event_id=bo->bos[d1.seq].order_id)
     AND (ce.ext_i_reference_id=bo->bos[d1.seq].ref_id))
    JOIN (cea
    WHERE cea.charge_event_id=ce.charge_event_id
     AND cea.cea_type_cd=exam_complete_cd)
    JOIN (d2)
    JOIN (c
    WHERE c.charge_event_act_id=cea.charge_event_act_id)
   ORDER BY ce.ext_m_event_id
   DETAIL
    count = (count+ 1), stat = alterlist(del_events->events,count), del_events->events[count].cea_id
     = cea.charge_event_act_id,
    del_events->events[count].bo_desc = trim(uar_get_code_display(ce.ext_i_reference_id)), del_events
    ->events[count].order_id = ce.ext_m_event_id
   WITH nocounter, outerjoin = d2, dontexist
  ;end select
  IF (test_mode=0)
   DELETE  FROM charge_event_act cea,
     (dummyt d1  WITH seq = value(size(del_events->events,5)))
    SET cea.seq = 1
    PLAN (d1)
     JOIN (cea
     WHERE (cea.charge_event_act_id=del_events->events[d1.seq].cea_id))
   ;end delete
   COMMIT
  ENDIF
  SET file_name = "afc_bo_recovery.dat"
  CALL echo(file_name)
  SET equal_line = fillstring(130,"=")
  CALL echo("printing charge_event_act audit report")
  SELECT INTO value(file_name)
   charge_event_act_id = del_events->events[d1.seq].cea_id, num_rows = count, rpt_date = concat(
    format(cnvtdatetime(curdate,curtime),"DD-MMM-YYYY HH:MM;;D")),
   order_id = del_events->events[d1.seq].order_id, bo = del_events->events[d1.seq].bo_desc
   FROM (dummyt d1  WITH seq = value(size(del_events->events,5)))
   HEAD REPORT
    col 50, "** AFC_RECOVER_BILL_ONLYS **", col 90,
    "Run Date: ", rpt_date, row + 2
   HEAD PAGE
    col 120, "Page: ", curpage"##",
    row + 1, col 00, equal_line,
    row + 2, col 00, "Charge Event Act ID",
    col 30, "Order ID", col 50,
    "Bill Only Description", row + 2
   DETAIL
    col 00, charge_event_act_id, col 30,
    order_id, col 50, bo,
    row + 1
   FOOT REPORT
    row + 2, col 70, "# of rows deleted: ",
    num_rows
   WITH nocounter
  ;end select
 ELSE
  CALL echo("No bill onlys qualified.")
 ENDIF
END GO
