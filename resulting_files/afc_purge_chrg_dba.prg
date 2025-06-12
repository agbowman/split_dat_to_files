CREATE PROGRAM afc_purge_chrg:dba
 DECLARE afc_purge_chrg_version = vc WITH private, noconstant("106590.FT.011")
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
 FREE SET charge
 RECORD charge(
   1 qual[*]
     2 charge_item_id = f8
 )
 FREE SET c_mod
 RECORD c_mod(
   1 qual[*]
     2 charge_mod_id = f8
 )
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
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE completed_cd = f8
 DECLARE cancelled_cd = f8
 DECLARE max_charge_item_id = f8
 DECLARE max_charge_mod_id = f8
 DECLARE min_charge_item_id = f8
 DECLARE min_charge_mod_id = f8
 DECLARE start_id = f8
 DECLARE end_id = f8
 DECLARE ddiscontinued_cd = f8
 DECLARE ddeleted_cd = f8
 DECLARE dtransfercancel_cd = f8
 DECLARE dvoided_cd = f8
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
  FROM charge c
  WHERE c.charge_item_id != 0
   AND ((c.updt_dt_tm+ 0) < cnvtdatetime(from_date))
  ORDER BY c.charge_item_id DESC
  DETAIL
   max_charge_item_id = c.charge_item_id
  WITH nocounter, maxrec = 1
 ;end select
 SELECT INTO "nl:"
  FROM charge c
  WHERE c.charge_item_id != 0
   AND ((c.updt_dt_tm+ 0) < cnvtdatetime(from_date))
  ORDER BY c.charge_item_id
  DETAIL
   min_charge_item_id = c.charge_item_id
  WITH nocounter, maxrec = 1
 ;end select
 SELECT INTO "nl:"
  FROM charge_mod cm
  WHERE cm.charge_mod_id != 0
   AND ((cm.updt_dt_tm+ 0) < cnvtdatetime(from_date))
  ORDER BY cm.charge_mod_id DESC
  DETAIL
   max_charge_mod_id = cm.charge_mod_id
  WITH nocounter, maxrec = 1
 ;end select
 SELECT INTO "nl:"
  FROM charge_mod cm
  WHERE cm.charge_mod_id != 0
   AND ((cm.updt_dt_tm+ 0) < cnvtdatetime(from_date))
  ORDER BY cm.charge_mod_id
  DETAIL
   min_charge_mod_id = cm.charge_mod_id
  WITH nocounter, maxrec = 1
 ;end select
 SET total_charge_rows_found = 0
 SET total_cm_rows_found = 0
 CALL echo("Checking for rows to purge from charge with active_ind = 0 . . .")
 SET finished = 0
 SET start_id = min_charge_item_id
 SET end_id = (start_id+ num_to_purge)
 CALL echo(build("Min Charge Item ID: ",min_charge_item_id))
 CALL echo(build("Max Charge Item ID: ",max_charge_item_id))
 WHILE (start_id < max_charge_item_id)
   CALL echo(build("Start ID: ",start_id))
   CALL echo(build("End ID: ",end_id))
   SET cnt = 0
   SELECT INTO "nl:"
    FROM charge c
    WHERE ((c.active_ind+ 0)=0)
     AND c.charge_item_id BETWEEN start_id AND end_id
     AND c.charge_item_id != 0.0
    ORDER BY c.charge_item_id
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(charge->qual,cnt), charge->qual[cnt].charge_item_id = c
     .charge_item_id
    WITH nocounter
   ;end select
   SET total_charge_rows_found = (total_charge_rows_found+ curqual)
   CALL echo(build("total_charge_rows_found is: ",total_charge_rows_found))
   IF (curqual > 0)
    DELETE  FROM charge c,
      (dummyt d  WITH seq = value(size(charge->qual,5)))
     SET c.seq = 1
     PLAN (d)
      JOIN (c
      WHERE (c.charge_item_id=charge->qual[d.seq].charge_item_id))
     WITH nocounter
    ;end delete
   ENDIF
   IF (test_mode=0)
    COMMIT
   ENDIF
   SET start_id = (end_id+ 1)
   SET end_id = (end_id+ num_to_purge)
   FREE SET charge
   RECORD charge(
     1 qual[*]
       2 charge_item_id = f8
   )
 ENDWHILE
 CALL echo("Checking for rows to purge from charge where the charge_event doesn't exist . . .")
 SET finished = 0
 SET start_id = min_charge_item_id
 SET end_id = (start_id+ num_to_purge)
 WHILE (start_id < max_charge_item_id)
   SET cnt = 0
   SELECT INTO "nl:"
    FROM charge c,
     interface_file i
    PLAN (c
     WHERE c.charge_item_id BETWEEN start_id AND end_id
      AND c.charge_item_id != 0.0
      AND  NOT ( EXISTS (
     (SELECT
      ce.charge_event_id
      FROM charge_event ce
      WHERE ce.charge_event_id=c.charge_event_id))))
     JOIN (i
     WHERE (i.interface_file_id=(c.interface_file_id+ 0))
      AND ((i.profit_type_cd+ 0)=0))
    ORDER BY c.charge_item_id
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(charge->qual,cnt), charge->qual[cnt].charge_item_id = c
     .charge_item_id
    WITH nocounter
   ;end select
   SET total_charge_rows_found = (total_charge_rows_found+ curqual)
   CALL echo(build("total_charge_rows_found is: ",total_charge_rows_found))
   IF (curqual > 0)
    DELETE  FROM charge c,
      (dummyt d  WITH seq = value(size(charge->qual,5)))
     SET c.seq = 1
     PLAN (d)
      JOIN (c
      WHERE (c.charge_item_id=charge->qual[d.seq].charge_item_id))
     WITH nocounter
    ;end delete
   ENDIF
   IF (test_mode=0)
    COMMIT
   ENDIF
   SET start_id = (end_id+ 1)
   SET end_id = (end_id+ num_to_purge)
   FREE SET charge
   RECORD charge(
     1 qual[*]
       2 charge_item_id = f8
   )
 ENDWHILE
 CALL echo("Checking for rows to purge from charge_mod where the active_ind = 0")
 SET finished = 0
 SET start_id = min_charge_mod_id
 SET end_id = (start_id+ num_to_purge)
 WHILE (start_id < max_charge_mod_id)
   SET cnt = 0
   SELECT INTO "nl:"
    FROM charge_mod cm
    WHERE ((cm.active_ind+ 0)=0)
     AND cm.charge_mod_id BETWEEN start_id AND end_id
     AND cm.charge_mod_id != 0.0
    ORDER BY cm.charge_mod_id
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(c_mod->qual,cnt), c_mod->qual[cnt].charge_mod_id = cm
     .charge_mod_id
    WITH nocounter
   ;end select
   SET total_cm_rows_found = (total_cm_rows_found+ curqual)
   CALL echo(build("total_cm_rows_found is: ",total_cm_rows_found))
   IF (curqual > 0)
    DELETE  FROM charge_mod cm,
      (dummyt d  WITH seq = value(size(c_mod->qual,5)))
     SET cm.seq = 1
     PLAN (d)
      JOIN (cm
      WHERE (cm.charge_mod_id=c_mod->qual[d.seq].charge_mod_id))
     WITH nocounter
    ;end delete
   ENDIF
   IF (test_mode=0)
    COMMIT
   ENDIF
   SET start_id = (end_id+ 1)
   SET end_id = (end_id+ num_to_purge)
   FREE SET c_mod
   RECORD c_mod(
     1 qual[*]
       2 charge_mod_id = f8
   )
 ENDWHILE
 CALL echo("Checking for rows to purge from charge_mod where the charge")
 CALL echo(" doesn't exist . . .")
 SET finished = 0
 SET start_id = min_charge_mod_id
 SET end_id = (start_id+ num_to_purge)
 WHILE (start_id < max_charge_mod_id)
   SET cnt = 0
   SELECT INTO "nl:"
    FROM charge_mod cm
    WHERE cm.charge_mod_id BETWEEN start_id AND end_id
     AND cm.charge_mod_id != 0.0
     AND  NOT ( EXISTS (
    (SELECT
     c.charge_item_id
     FROM charge c
     WHERE c.charge_item_id=cm.charge_item_id)))
    ORDER BY cm.charge_mod_id
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(c_mod->qual,cnt), c_mod->qual[cnt].charge_mod_id = cm
     .charge_mod_id
    WITH nocounter
   ;end select
   SET total_cm_rows_found = (total_cm_rows_found+ curqual)
   CALL echo(build("total_cm_rows_found is: ",total_cm_rows_found))
   IF (curqual > 0)
    DELETE  FROM charge_mod cm,
      (dummyt d  WITH seq = value(size(c_mod->qual,5)))
     SET cm.seq = 1
     PLAN (d)
      JOIN (cm
      WHERE (cm.charge_mod_id=c_mod->qual[d.seq].charge_mod_id))
     WITH nocounter
    ;end delete
   ENDIF
   IF (test_mode=0)
    COMMIT
   ENDIF
   SET start_id = (end_id+ 1)
   SET end_id = (end_id+ num_to_purge)
   FREE SET c_mod
   RECORD c_mod(
     1 qual[*]
       2 charge_mod_id = f8
   )
 ENDWHILE
 IF (mode="R")
  CALL echo("Checking for rows to purge from charge where")
  CALL echo("process_flg != 0,1,2,3,4,8 and charge_event_act.updt_dt_tm")
  CALL echo(" < from_date and the charge doesn't exist on combine_details")
  SET finished = 0
  SET start_id = 0.0
  SET start_id = min_charge_item_id
  SET end_id = 0.0
  SET end_id = (start_id+ num_to_purge)
  WHILE (start_id < max_charge_item_id)
    SET cnt = 0
    SELECT INTO "nl:"
     FROM charge c,
      charge_event_act cea,
      interface_file i
     PLAN (c
      WHERE c.charge_item_id BETWEEN start_id AND end_id
       AND c.charge_item_id != 0.0
       AND  NOT (((c.process_flg+ 0) IN (0, 1, 2, 3, 4,
      8, 100)))
       AND ((c.order_id+ 0)=0)
       AND  NOT ( EXISTS (
      (SELECT
       cd.combine_detail_id
       FROM combine_detail cd
       WHERE cd.entity_name="CHARGE"
        AND cd.entity_id=c.charge_item_id))))
      JOIN (cea
      WHERE (cea.charge_event_act_id=(c.charge_event_act_id+ 0))
       AND ((cea.updt_dt_tm+ 0) < cnvtdatetime(from_date)))
      JOIN (i
      WHERE (i.interface_file_id=(c.interface_file_id+ 0))
       AND ((i.profit_type_cd+ 0)=0))
     ORDER BY c.charge_item_id
     DETAIL
      cnt = (cnt+ 1), stat = alterlist(charge->qual,cnt), charge->qual[cnt].charge_item_id = c
      .charge_item_id
     WITH nocounter
    ;end select
    SET total_charge_rows_found = (total_charge_rows_found+ curqual)
    CALL echo(build("total_charge_rows_found is: ",total_charge_rows_found))
    IF (curqual > 0)
     DELETE  FROM charge c,
       (dummyt d  WITH seq = value(size(charge->qual,5)))
      SET c.seq = 1
      PLAN (d)
       JOIN (c
       WHERE (c.charge_item_id=charge->qual[d.seq].charge_item_id))
      WITH nocounter
     ;end delete
    ENDIF
    IF (test_mode=0)
     COMMIT
    ENDIF
    SET start_id = (end_id+ 1)
    SET end_id = (end_id+ num_to_purge)
    FREE SET charge
    RECORD charge(
      1 qual[*]
        2 charge_item_id = f8
    )
  ENDWHILE
  CALL echo("Checking for rows to purge from charge where")
  CALL echo("order_id > 0 and order_action.action_dt_tm < from_date")
  CALL echo("and the order_action.order_status_cd = COMPLETED or CANCELED")
  SELECT INTO "nl:"
   FROM charge c,
    order_action oa,
    interface_file i
   PLAN (c
    WHERE ((c.order_id+ 0) > 0)
     AND  NOT (c.process_flg IN (0, 1, 2, 3, 4,
    8, 100))
     AND  NOT ( EXISTS (
    (SELECT
     cd.combine_detail_id
     FROM combine_detail cd
     WHERE cd.entity_name="CHARGE"
      AND cd.entity_id=c.charge_item_id)))
     AND c.charge_item_id != 0.0)
    JOIN (i
    WHERE (i.interface_file_id=(c.interface_file_id+ 0))
     AND ((i.profit_type_cd+ 0)=0))
    JOIN (oa
    WHERE oa.order_id=c.order_id
     AND ((oa.action_dt_tm+ 0) < cnvtdatetime(from_date))
     AND oa.order_status_cd IN (completed_cd, cancelled_cd, ddiscontinued_cd, ddeleted_cd,
    dtransfercancel_cd,
    dvoided_cd))
   ORDER BY c.charge_item_id
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(charge->qual,cnt), charge->qual[cnt].charge_item_id = c
    .charge_item_id
   WITH nocounter
  ;end select
  SET total_charge_rows_found = (total_charge_rows_found+ curqual)
  CALL echo(build("total_charge_rows_found is: ",total_charge_rows_found))
  IF (curqual > 0)
   DELETE  FROM charge c,
     (dummyt d  WITH seq = value(size(charge->qual,5)))
    SET c.seq = 1
    PLAN (d)
     JOIN (c
     WHERE (c.charge_item_id=charge->qual[d.seq].charge_item_id))
    WITH nocounter
   ;end delete
  ENDIF
  IF (test_mode=0)
   COMMIT
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 CALL echo("Finished.")
 CALL echo(build("Beg Time: "," ",format(today,"DD-MMM-YYYY;;d"),format(today," HH:MM:SS;;S")))
 CALL echo(build("End Time: "," ",format(curdate,"DD-MMM-YYYY;;D"),format(curtime," HH:MM:SS;;S")))
#end_program
 FREE SET charge
 FREE SET c_mod
END GO
