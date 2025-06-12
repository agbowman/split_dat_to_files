CREATE PROGRAM afc_purge_activity:dba
 DECLARE afc_purge_activity_version = vc WITH private, noconstant("76354.FT.015")
 IF (validate(request->ops_date,999)=999)
  EXECUTE cclseclogin
  SET message = nowindow
  IF ((xxcclseclogin->loggedin != 1))
   CALL echo("******************************************")
   CALL echo("*** User Not Signed In.                ***")
   CALL echo("*** Type 'CCLSECLOGIN GO'              ***")
   CALL echo("*** and sign in to continue.           ***")
   CALL echo("******************************************")
   GO TO end_program
  ENDIF
 ENDIF
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 FREE SET ce
 RECORD ce(
   1 qual[*]
     2 charge_event_id = f8
 )
 FREE SET cea
 RECORD cea(
   1 qual[*]
     2 charge_event_act_id = f8
 )
 FREE SET cem
 RECORD cem(
   1 qual[*]
     2 charge_event_mod_id = f8
 )
 FREE SET cer
 RECORD cer(
   1 qual[*]
     2 charge_event_id = f8
 )
 FREE SET ceap
 RECORD ceap(
   1 qual[*]
     2 charge_event_act_id = f8
 )
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE completed_cd = f8
 DECLARE cancelled_cd = f8
 DECLARE ordered_cd = f8
 DECLARE ddiscontinued_cd = f8
 DECLARE ddeleted_cd = f8
 DECLARE dtransfercancel_cd = f8
 DECLARE dvoided_cd = f8
 DECLARE max_charge_event_id = f8
 DECLARE max_charge_event_act_id = f8
 DECLARE max_charge_event_act_prsnl_id = f8
 DECLARE max_charge_event_mod_id = f8
 DECLARE min_charge_event_id = f8
 DECLARE min_charge_event_act_id = f8
 DECLARE min_charge_event_act_prsnl_id = f8
 DECLARE min_charge_event_mod_id = f8
 DECLARE start_value = f8
 DECLARE end_value = f8
 SET code_set = 6004
 SET cdf_meaning = "COMPLETED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,completed_cd)
 CALL echo(build("the completed code value is: ",completed_cd))
 IF (stat != 0)
  CALL echo("Unable to find completed_cd.")
  GO TO end_program
 ENDIF
 SET code_set = 6004
 SET cdf_meaning = "CANCELED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,cancelled_cd)
 CALL echo(build("the cancelled code value is: ",cancelled_cd))
 IF (stat != 0)
  CALL echo("Unable to find cancelled_cd.")
  GO TO end_program
 ENDIF
 SET code_set = 6004
 SET cdf_meaning = "ORDERED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,ordered_cd)
 CALL echo(build("the ordered code value is: ",ordered_cd))
 IF (stat != 0)
  CALL echo("Unable to find ordered_cd.")
  GO TO end_program
 ENDIF
 SET code_set = 6004
 SET cdf_meaning = "DISCONTINUED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,ddiscontinued_cd)
 CALL echo(build("the discontinued code value is: ",ddiscontinued_cd))
 IF (stat != 0)
  CALL echo("Unable to find dDiscontinued_cd.")
  GO TO end_program
 ENDIF
 SET code_set = 6004
 SET cdf_meaning = "DELETED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,ddeleted_cd)
 CALL echo(build("the deleted code value is: ",ddeleted_cd))
 IF (stat != 0)
  CALL echo("Unable to find dDeleted_cd.")
  GO TO end_program
 ENDIF
 SET code_set = 6004
 SET cdf_meaning = "TRANS/CANCEL"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,dtransfercancel_cd)
 CALL echo(build("the transfered/cancelled code value is: ",dtransfercancel_cd))
 IF (stat != 0)
  CALL echo("Unable to find dTransferCancel_cd.")
  GO TO end_program
 ENDIF
 SET code_set = 6004
 SET cdf_meaning = "VOIDEDWRSLT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,dvoided_cd)
 CALL echo(build("the voided code value is: ",dvoided_cd))
 IF (stat != 0)
  CALL echo("Unable to find dVoided_cd.")
  GO TO end_program
 ENDIF
 SET reply->status_data.status = "F"
 SET retention_days = cnvtint( $1)
 CALL echo(build("the # of retention days is: ",retention_days))
 SET test_mode = cnvtint( $2)
 IF (test_mode=1)
  CALL echo("Running in test mode.")
 ELSE
  CALL echo("Running in commit mode.")
 ENDIF
 SET num_to_purge = cnvtint( $3)
 CALL echo(build("purging: ",num_to_purge," rows"))
 SET today = cnvtdatetime(curdate,curtime3)
 SET today_dt = cnvtdatetime(concat(format(today,"DD-MMM-YYYY;;D")," 23:59:59.99"))
 SET from_date = datetimeadd(today_dt,- (retention_days))
 CALL echo(build("the from date is: ",format(from_date,"DD-MMM-YYYY HH:MM:SS;;d")))
 SET mode = "R"
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="CHARGE SERVICES"
   AND d.info_name="CS PURGE RUN MODE"
  DETAIL
   mode = d.info_char
  WITH nocounter
 ;end select
 CALL echo(build("mode is: ",mode))
 SELECT INTO "nl:"
  FROM charge_event ce
  WHERE ce.charge_event_id != 0
   AND ((ce.updt_dt_tm+ 0) < cnvtdatetime(from_date))
  ORDER BY ce.charge_event_id DESC
  DETAIL
   max_charge_event_id = ce.charge_event_id
  WITH nocounter, maxrec = 1
 ;end select
 SELECT INTO "nl:"
  FROM charge_event ce
  WHERE ce.charge_event_id != 0
   AND ((ce.updt_dt_tm+ 0) < cnvtdatetime(from_date))
  ORDER BY ce.charge_event_id
  DETAIL
   min_charge_event_id = ce.charge_event_id
  WITH nocounter, maxrec = 1
 ;end select
 CALL echo(build("Min_charge_event_id is: ",min_charge_event_id))
 CALL echo(build("Max_charge_event_id is: ",max_charge_event_id))
 SELECT INTO "nl:"
  FROM charge_event_act cea
  WHERE cea.charge_event_act_id != 0
   AND ((cea.updt_dt_tm+ 0) < cnvtdatetime(from_date))
  ORDER BY cea.charge_event_act_id DESC
  DETAIL
   max_charge_event_act_id = cea.charge_event_act_id
  WITH nocounter, maxrec = 1
 ;end select
 SELECT INTO "nl:"
  FROM charge_event_act cea
  WHERE cea.charge_event_act_id != 0
   AND ((cea.updt_dt_tm+ 0) < cnvtdatetime(from_date))
  ORDER BY cea.charge_event_act_id
  DETAIL
   min_charge_event_act_id = cea.charge_event_act_id
  WITH nocounter, maxrec = 1
 ;end select
 CALL echo(build("Min_charge_event_act_id is: ",min_charge_event_act_id))
 CALL echo(build("Max_charge_event_act_id is: ",max_charge_event_act_id))
 SELECT INTO "nl:"
  FROM charge_event_mod cem
  WHERE cem.charge_event_mod_id != 0
   AND ((cem.updt_dt_tm+ 0) < cnvtdatetime(from_date))
  ORDER BY cem.charge_event_mod_id DESC
  DETAIL
   max_charge_event_mod_id = cem.charge_event_mod_id
  WITH nocounter, maxrec = 1
 ;end select
 SELECT INTO "nl:"
  FROM charge_event_mod cem
  WHERE cem.charge_event_mod_id != 0
   AND ((cem.updt_dt_tm+ 0) < cnvtdatetime(from_date))
  ORDER BY cem.charge_event_mod_id
  DETAIL
   min_charge_event_mod_id = cem.charge_event_mod_id
  WITH nocounter, maxrec = 1
 ;end select
 CALL echo(build("Min_charge_event_mod_id is: ",min_charge_event_mod_id))
 CALL echo(build("Max_charge_event_mod_id is: ",max_charge_event_mod_id))
 SELECT INTO "nl:"
  FROM charge_event_act_prsnl ceap
  WHERE ceap.charge_event_act_id != 0
   AND ((ceap.updt_dt_tm+ 0) < cnvtdatetime(from_date))
  ORDER BY ceap.charge_event_act_id DESC
  DETAIL
   max_charge_event_act_prsnl_id = ceap.charge_event_act_id
  WITH nocounter, maxrec = 1
 ;end select
 SELECT INTO "nl:"
  FROM charge_event_act_prsnl ceap
  WHERE ceap.charge_event_act_id != 0
   AND ((ceap.updt_dt_tm+ 0) < cnvtdatetime(from_date))
  ORDER BY ceap.charge_event_act_id
  DETAIL
   min_charge_event_act_prsnl_id = ceap.charge_event_act_id
  WITH nocounter, maxrec = 1
 ;end select
 CALL echo(build("Min_charge_event_act_prsnl_id is: ",min_charge_event_act_prsnl_id))
 CALL echo(build("Max_charge_event_act_prsnl_id is: ",max_charge_event_act_prsnl_id))
 SET total_ce_rows_found = 0
 SET total_cea_rows_found = 0
 SET total_cem_rows_found = 0
 SET total_ceap_rows_found = 0
 CALL echo("Checking for rows to purge from charge_event where")
 CALL echo("the charge doesn't exist and the updt_dt_tm < from_date")
 SET start_value = min_charge_event_id
 SET end_value = (start_value+ num_to_purge)
 WHILE (start_value < max_charge_event_id)
   CALL echo(build("Charge_event_start_value is: ",start_value))
   CALL echo(build("Charge_event_end_value is: ",end_value))
   SELECT INTO "nl:"
    FROM charge_event ce
    WHERE ce.charge_event_id BETWEEN start_value AND end_value
     AND ((ce.updt_dt_tm+ 0) < cnvtdatetime(from_date))
     AND  NOT ( EXISTS (
    (SELECT
     c.charge_item_id
     FROM charge c
     WHERE c.charge_event_id=ce.charge_event_id)))
     AND  NOT ( EXISTS (
    (SELECT
     o.order_id
     FROM orders o
     WHERE o.order_id=ce.order_id
      AND ((ce.order_id+ 0) > 0)
      AND ((o.order_status_cd+ 0)=ordered_cd))))
    HEAD REPORT
     cnt1 = 0
    DETAIL
     cnt1 = (cnt1+ 1), stat = alterlist(ce->qual,cnt1), ce->qual[cnt1].charge_event_id = ce
     .charge_event_id
    WITH counter
   ;end select
   SET total_ce_rows_found = (total_ce_rows_found+ curqual)
   CALL echo(build("total_ce_rows_found is: ",curqual))
   IF (curqual > 0)
    DELETE  FROM charge_event ce,
      (dummyt d  WITH seq = value(size(ce->qual,5)))
     SET ce.seq = 1
     PLAN (d)
      JOIN (ce
      WHERE (ce.charge_event_id=ce->qual[d.seq].charge_event_id))
    ;end delete
    IF (test_mode=0)
     COMMIT
    ENDIF
   ENDIF
   SET start_value = (end_value+ 1)
   IF (((start_value+ num_to_purge) <= max_charge_event_id))
    SET end_value = (start_value+ num_to_purge)
   ELSE
    SET end_value = max_charge_event_id
   ENDIF
   FREE SET ce
   RECORD ce(
     1 qual[*]
       2 charge_event_id = f8
   )
 ENDWHILE
 CALL echo("Purge from charge_event_act_prsnl where the charge_event_act doesn't exist...")
 SET start_value = min_charge_event_act_prsnl_id
 SET end_value = (start_value+ num_to_purge)
 WHILE (start_value < max_charge_event_act_prsnl_id)
   SELECT INTO "nl:"
    FROM charge_event_act_prsnl ceap
    WHERE ceap.charge_event_act_id BETWEEN start_value AND end_value
     AND ((ceap.updt_dt_tm+ 0) < cnvtdatetime(from_date))
     AND ((ceap.charge_event_act_id+ 0) != 0)
     AND  NOT ( EXISTS (
    (SELECT
     cea.charge_event_act_id
     FROM charge_event_act cea
     WHERE cea.charge_event_act_id=ceap.charge_event_act_id)))
    HEAD REPORT
     cnt1 = 0
    DETAIL
     cnt1 = (cnt1+ 1), stat = alterlist(ceap->qual,cnt1), ceap->qual[cnt1].charge_event_act_id = ceap
     .charge_event_act_id
    WITH nocounter
   ;end select
   SET total_ceap_rows_found = (total_ceap_rows_found+ curqual)
   CALL echo(build("total_ceap_rows_found is: ",total_ceap_rows_found))
   IF (curqual > 0)
    DELETE  FROM charge_event_act_prsnl ceap,
      (dummyt d  WITH seq = value(size(ceap->qual,5)))
     SET ceap.seq = 1
     PLAN (d)
      JOIN (ceap
      WHERE (ceap.charge_event_act_id=ceap->qual[d.seq].charge_event_act_id))
     WITH counter
    ;end delete
    IF (test_mode=0)
     COMMIT
    ENDIF
   ENDIF
   SET start_value = (end_value+ 1)
   IF (((start_value+ num_to_purge) <= max_charge_event_act_prsnl_id))
    SET end_value = (start_value+ num_to_purge)
   ELSE
    SET end_value = max_charge_event_act_prsnl_id
   ENDIF
   FREE SET ceap
   RECORD ceap(
     1 qual[*]
       2 charge_event_act_id = f8
   )
 ENDWHILE
 CALL echo("Checking for rows to purge from charge_event_act where")
 CALL echo("the charge event doesn't exist and the updt_dt_tm < from_date")
 SET start_value = min_charge_event_act_id
 SET end_value = (start_value+ num_to_purge)
 WHILE (start_value < max_charge_event_act_id)
   CALL echo(build("Charge_event_act_start_value is: ",start_value))
   CALL echo(build("Charge_event_act_end_value is: ",end_value))
   SELECT INTO "nl:"
    FROM charge_event_act cea
    WHERE cea.charge_event_act_id BETWEEN start_value AND end_value
     AND ((cea.updt_dt_tm+ 0) < cnvtdatetime(from_date))
     AND  NOT ( EXISTS (
    (SELECT
     ce.charge_event_id
     FROM charge_event ce
     WHERE ce.charge_event_id=cea.charge_event_id)))
    HEAD REPORT
     cnt1 = 0
    DETAIL
     cnt1 = (cnt1+ 1), stat = alterlist(cea->qual,cnt1), cea->qual[cnt1].charge_event_act_id = cea
     .charge_event_act_id
    WITH counter
   ;end select
   SET total_cea_rows_found = (total_cea_rows_found+ curqual)
   CALL echo(build("total_cea_rows_found is: ",total_cea_rows_found))
   IF (curqual > 0)
    DELETE  FROM charge_event_act cea,
      (dummyt d  WITH seq = value(size(cea->qual,5)))
     SET cea.seq = 1
     PLAN (d)
      JOIN (cea
      WHERE (cea.charge_event_act_id=cea->qual[d.seq].charge_event_act_id))
    ;end delete
    IF (test_mode=0)
     COMMIT
    ENDIF
   ENDIF
   SET start_value = (end_value+ 1)
   IF (((start_value+ num_to_purge) <= max_charge_event_act_id))
    SET end_value = (start_value+ num_to_purge)
   ELSE
    SET end_value = max_charge_event_act_id
   ENDIF
   FREE SET cea
   RECORD cea(
     1 qual[*]
       2 charge_event_act_id = f8
   )
 ENDWHILE
 CALL echo("Checking for rows to purge from charge_event_mod where")
 CALL echo("the charge event doesn't exist and the updt_dt_tm < from_date")
 SET start_value = min_charge_event_mod_id
 SET end_value = (start_value+ num_to_purge)
 WHILE (start_value < max_charge_event_mod_id)
   CALL echo(build("Charge_event_mod_start_value is: ",start_value))
   CALL echo(build("Charge_event_mod_end_value is: ",end_value))
   SELECT INTO "nl:"
    FROM charge_event_mod cem
    WHERE cem.charge_event_mod_id BETWEEN start_value AND end_value
     AND ((cem.updt_dt_tm+ 0) < cnvtdatetime(from_date))
     AND  NOT ( EXISTS (
    (SELECT
     ce.charge_event_id
     FROM charge_event ce
     WHERE ce.charge_event_id=cem.charge_event_id)))
    HEAD REPORT
     cnt1 = 0
    DETAIL
     cnt1 = (cnt1+ 1), stat = alterlist(cem->qual,cnt1), cem->qual[cnt1].charge_event_mod_id = cem
     .charge_event_mod_id
    WITH counter
   ;end select
   SET total_cem_rows_found = (total_cem_rows_found+ curqual)
   CALL echo(build("total_cem_rows_found is: ",total_cem_rows_found))
   IF (curqual > 0)
    DELETE  FROM charge_event_mod cem,
      (dummyt d  WITH seq = value(size(cem->qual,5)))
     SET cem.seq = 1
     PLAN (d)
      JOIN (cem
      WHERE (cem.charge_event_mod_id=cem->qual[d.seq].charge_event_mod_id))
    ;end delete
    IF (test_mode=0)
     COMMIT
    ENDIF
   ENDIF
   SET start_value = (end_value+ 1)
   IF (((start_value+ num_to_purge) <= max_charge_event_mod_id))
    SET end_value = (start_value+ num_to_purge)
   ELSE
    SET end_value = max_charge_event_mod_id
   ENDIF
   FREE SET cem
   RECORD cem(
     1 qual[*]
       2 charge_event_mod_id = f8
   )
 ENDWHILE
 IF (mode="R")
  CALL echo("Checking for rows to purge from charge_event where")
  CALL echo("a charge doesn't exist with the process_flg = 0,1,2,3,4,8,100")
  CALL echo("and the order_action.action_dt_tm < from date and the")
  CALL echo("order_action.order_status_cd in (COMPLETED, cancelled)")
  SET start_value = min_charge_event_id
  SET end_value = (start_value+ num_to_purge)
  WHILE (start_value < max_charge_event_id)
    SET cnt1 = 0
    SELECT INTO "nl:"
     ce.charge_event_id
     FROM charge_event ce,
      orders o
     PLAN (ce
      WHERE ce.charge_event_id BETWEEN start_value AND end_value
       AND ((ce.updt_dt_tm+ 0) < cnvtdatetime(from_date))
       AND ((ce.order_id+ 0) != 0)
       AND  NOT ( EXISTS (
      (SELECT
       c.charge_event_id
       FROM charge c
       WHERE c.charge_event_id=ce.charge_event_id
        AND ((c.process_flg+ 0) IN (0, 1, 2, 3, 4,
       8, 100))))))
      JOIN (o
      WHERE (o.order_id=(ce.order_id+ 0))
       AND ((o.order_status_cd+ 0) IN (completed_cd, cancelled_cd, ddiscontinued_cd, ddeleted_cd,
      dtransfercancel_cd,
      dvoided_cd))
       AND  NOT ( EXISTS (
      (SELECT
       oa.order_id
       FROM order_action oa
       WHERE oa.order_id=o.order_id
        AND ((oa.order_status_cd+ 0)=o.order_status_cd)
        AND oa.action_dt_tm > cnvtdatetime(from_date)))))
     DETAIL
      cnt1 = (cnt1+ 1), stat = alterlist(cer->qual,cnt1), cer->qual[cnt1].charge_event_id = ce
      .charge_event_id
     WITH nocounter
    ;end select
    SET total_ce_rows_found = (total_ce_rows_found+ curqual)
    CALL echo(build("total_ce_rows_found is: ",total_ce_rows_found))
    IF (curqual > 0)
     DELETE  FROM charge_event ce,
       (dummyt d  WITH seq = value(size(cer->qual,5)))
      SET ce.seq = 1
      PLAN (d)
       JOIN (ce
       WHERE (ce.charge_event_id=cer->qual[d.seq].charge_event_id))
     ;end delete
     IF (test_mode=0)
      COMMIT
     ENDIF
    ENDIF
    SET start_value = (end_value+ 1)
    IF (((start_value+ num_to_purge) <= max_charge_event_id))
     SET end_value = (start_value+ num_to_purge)
    ELSE
     SET end_value = max_charge_event_id
    ENDIF
    FREE SET cer
    RECORD cer(
      1 qual[*]
        2 charge_event_id = f8
    )
  ENDWHILE
 ENDIF
 IF (((total_ce_rows_found > 0) OR (((total_cea_rows_found > 0) OR (total_cem_rows_found > 0)) )) )
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echo("Finished.")
 CALL echo(build("Beg Time: "," ",format(today,"DD-MMM-YYYY;;d"),format(today," HH:MM:SS;;S")))
 CALL echo(build("End Time: "," ",format(curdate,"DD-MMM-YYYY;;D"),format(curtime," HH:MM:SS;;S")))
#end_program
 FREE SET ce
 FREE SET cea
 FREE SET cem
 FREE SET cer
 FREE SET ceap
END GO
