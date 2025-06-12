CREATE PROGRAM afc_pricemaint_cleanup:dba
 EXECUTE cclseclogin
 SET message = nowindow
 RECORD overlappingpsi(
   1 bill_items[*]
     2 bill_item_id = f8
     2 ext_description = c200
     2 psi[*]
       3 price_sched_items_id = f8
       3 old_beg_effective_dt_tm = dq8
       3 old_end_effective_dt_tm = dq8
       3 new_end_effective_dt_tm = dq8
       3 inactivate_ind = i2
       3 update_ind = i2
       3 price_sched_desc = vc
 )
 RECORD activity_types(
   1 list[*]
     2 activity_type_cd = f8
     2 name = vc
 )
 RECORD price_scheds(
   1 list[*]
     2 price_sched_id = f8
     2 name = vc
 )
 DECLARE one_sec = f8
 DECLARE cnt = i4
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE inactive_cd = f8
 SET codeset = 48
 SET cdf_meaning = "INACTIVE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,inactive_cd)
 CALL echo(build("the inactive code value is: ",inactive_cd))
 SET fuser = 0.0
 SET cuser = curuser
 SELECT INTO "NL:"
  p.person_id
  FROM prsnl p
  WHERE p.username=cuser
  DETAIL
   fuser = p.person_id
  WITH nocounter
 ;end select
 SET run_mode =  $1
 IF (run_mode=1)
  CALL echo("Running in report mode.")
 ELSE
  CALL echo("Running in regular mode.")
 ENDIF
 SET counter = 0
 SET pscheds = 0
 CALL get_activity_types(0)
 CALL get_price_scheds(0)
 FOR (counter = 1 TO value(size(activity_types->list,5)))
   SET found_price = 0
   SET found_some = 0
   CALL get_bill_items(activity_types->list[counter].activity_type_cd)
   IF (value(size(overlappingpsi->bill_items,5)) > 0)
    CALL get_psi(0)
   ELSE
    CALL echo(build("No bill items found for activity type:",activity_types->list[counter].
      activity_type_cd))
   ENDIF
 ENDFOR
 CALL echo("Type commit go to commit the changes.")
 SUBROUTINE get_activity_types(a)
   CALL echo("Getting activity types...")
   SET num_act_types = 0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=106
     AND cv.active_ind=1
    DETAIL
     num_act_types = (num_act_types+ 1), stat = alterlist(activity_types->list,num_act_types),
     activity_types->list[num_act_types].activity_type_cd = cv.code_value,
     activity_types->list[num_act_types].name = cv.display
    WITH nocounter
   ;end select
   CALL echorecord(activity_types,"ccluserdir:afc_act_type.dat")
 END ;Subroutine
 SUBROUTINE get_price_scheds(b)
   CALL echo("Getting price schedules...")
   SET num_price_scheds = 0
   SELECT INTO "nl:"
    FROM price_sched p
    WHERE p.active_ind=1
     AND p.pharm_ind=0
    DETAIL
     num_price_scheds = (num_price_scheds+ 1), stat = alterlist(price_scheds->list,num_price_scheds),
     price_scheds->list[num_price_scheds].price_sched_id = p.price_sched_id,
     price_scheds->list[num_price_scheds].name = p.price_sched_desc
    WITH nocounter
   ;end select
   CALL echorecord(price_scheds,"ccluserdir:afc_p_sched.dat")
 END ;Subroutine
 SUBROUTINE get_bill_items(ext_owner_cd)
   CALL echo(build("Getting bill items for activity type:",ext_owner_cd))
   SET bi_count = 0
   SELECT INTO "nl:"
    b.bill_item_id, b.ext_description
    FROM bill_item b
    WHERE b.ext_owner_cd=ext_owner_cd
     AND b.active_ind=1
    DETAIL
     bi_count = (bi_count+ 1), stat = alterlist(overlappingpsi->bill_items,bi_count), overlappingpsi
     ->bill_items[bi_count].bill_item_id = b.bill_item_id,
     overlappingpsi->bill_items[bi_count].ext_description = b.ext_description
    WITH nocounter
   ;end select
   IF (curqual > 0)
    CALL echorecord(overlappingpsi,"ccluserdir:afc_overlap.dat")
   ELSE
    SET stat = alterlist(overlappingpsi->bill_items,0)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_psi(c)
  CALL echo("Getting prices...")
  FOR (pscheds = 1 TO value(size(price_scheds->list,5)))
    SET found_some = 0
    FOR (reset_array = 1 TO value(size(overlappingpsi->bill_items,5)))
      SET stat = alterlist(overlappingpsi->bill_items[reset_array].psi,0)
    ENDFOR
    SET psi_count = 0
    SELECT INTO "nl:"
     psi.price_sched_items_id, psi.end_effective_dt_tm, psi.beg_effective_dt_tm
     FROM (dummyt d  WITH seq = value(size(overlappingpsi->bill_items,5))),
      price_sched_items psi
     PLAN (d)
      JOIN (psi
      WHERE (psi.bill_item_id=overlappingpsi->bill_items[d.seq].bill_item_id)
       AND psi.active_ind=1
       AND (psi.price_sched_id=price_scheds->list[pscheds].price_sched_id))
     ORDER BY psi.bill_item_id, cnvtdatetime(psi.end_effective_dt_tm) DESC, cnvtdatetime(psi
       .beg_effective_dt_tm) DESC
     HEAD psi.bill_item_id
      psi_count = 0
     DETAIL
      found_price = 1, psi_count = (psi_count+ 1), stat = alterlist(overlappingpsi->bill_items[d.seq]
       .psi,psi_count),
      overlappingpsi->bill_items[d.seq].psi[psi_count].price_sched_items_id = psi
      .price_sched_items_id, overlappingpsi->bill_items[d.seq].psi[psi_count].old_beg_effective_dt_tm
       = psi.beg_effective_dt_tm, overlappingpsi->bill_items[d.seq].psi[psi_count].
      old_end_effective_dt_tm = psi.end_effective_dt_tm,
      overlappingpsi->bill_items[d.seq].psi[psi_count].price_sched_desc = trim(price_scheds->list[
       pscheds].name)
     WITH nocounter
    ;end select
    CALL echorecord(overlappingpsi,"ccluserdir:afc_ol_psi.dat")
    IF (curqual > 0)
     CALL find_overlap(0)
    ELSE
     CALL echo(build("No prices found for price_sched:",price_scheds->list[pscheds].price_sched_id))
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE find_overlap(d)
   CALL echo("Searching for overlap")
   SET one_sec = (1.0/ 86400.0)
   FOR (bi = 1 TO value(size(overlappingpsi->bill_items,5)))
     SET last_active = 1
     SET first_time = 1
     FOR (prices = 1 TO value(size(overlappingpsi->bill_items[bi].psi,5)))
      IF (first_time != 1)
       IF ((overlappingpsi->bill_items[bi].psi[(prices - 1)].inactivate_ind=1))
        IF (((cnvtdatetime(overlappingpsi->bill_items[bi].psi[prices].old_beg_effective_dt_tm) >=
        cnvtdatetime(overlappingpsi->bill_items[bi].psi[last_active].old_beg_effective_dt_tm)
         AND cnvtdatetime(overlappingpsi->bill_items[bi].psi[prices].old_end_effective_dt_tm) <=
        cnvtdatetime(overlappingpsi->bill_items[bi].psi[last_active].old_end_effective_dt_tm)) OR (((
        cnvtdatetime(overlappingpsi->bill_items[bi].psi[prices].old_beg_effective_dt_tm) <
        cnvtdatetime(overlappingpsi->bill_items[bi].psi[last_active].old_beg_effective_dt_tm)
         AND cnvtdatetime(overlappingpsi->bill_items[bi].psi[prices].old_end_effective_dt_tm) >=
        cnvtdatetime(overlappingpsi->bill_items[bi].psi[last_active].old_beg_effective_dt_tm)) OR (
        cnvtdatetime(overlappingpsi->bill_items[bi].psi[prices].old_beg_effective_dt_tm) >=
        cnvtdatetime(overlappingpsi->bill_items[bi].psi[last_active].old_beg_effective_dt_tm)
         AND cnvtdatetime(overlappingpsi->bill_items[bi].psi[prices].old_beg_effective_dt_tm) <=
        cnvtdatetime(overlappingpsi->bill_items[bi].psi[last_active].old_end_effective_dt_tm)
         AND cnvtdatetime(overlappingpsi->bill_items[bi].psi[prices].old_end_effective_dt_tm) >
        cnvtdatetime(overlappingpsi->bill_items[bi].psi[last_active].old_end_effective_dt_tm))) )) )
         SET overlappingpsi->bill_items[bi].psi[prices].new_end_effective_dt_tm = datetimeadd(
          overlappingpsi->bill_items[bi].psi[last_active].old_beg_effective_dt_tm,- (one_sec))
         SET found_some = 1
         IF (cnvtdatetime(overlappingpsi->bill_items[bi].psi[prices].new_end_effective_dt_tm) <=
         cnvtdatetime(overlappingpsi->bill_items[bi].psi[prices].old_beg_effective_dt_tm))
          SET overlappingpsi->bill_items[bi].psi[prices].inactivate_ind = 1
         ELSE
          SET overlappingpsi->bill_items[bi].psi[prices].update_ind = 1
          SET last_active = prices
         ENDIF
        ELSE
         SET last_active = prices
        ENDIF
       ELSE
        IF (((cnvtdatetime(overlappingpsi->bill_items[bi].psi[prices].old_beg_effective_dt_tm) >=
        cnvtdatetime(overlappingpsi->bill_items[bi].psi[(prices - 1)].old_beg_effective_dt_tm)
         AND cnvtdatetime(overlappingpsi->bill_items[bi].psi[prices].old_end_effective_dt_tm) <=
        cnvtdatetime(overlappingpsi->bill_items[bi].psi[(prices - 1)].old_end_effective_dt_tm)) OR (
        ((cnvtdatetime(overlappingpsi->bill_items[bi].psi[prices].old_beg_effective_dt_tm) <
        cnvtdatetime(overlappingpsi->bill_items[bi].psi[(prices - 1)].old_beg_effective_dt_tm)
         AND cnvtdatetime(overlappingpsi->bill_items[bi].psi[prices].old_end_effective_dt_tm) >=
        cnvtdatetime(overlappingpsi->bill_items[bi].psi[(prices - 1)].old_beg_effective_dt_tm)) OR (
        cnvtdatetime(overlappingpsi->bill_items[bi].psi[prices].old_beg_effective_dt_tm) >=
        cnvtdatetime(overlappingpsi->bill_items[bi].psi[(prices - 1)].old_beg_effective_dt_tm)
         AND cnvtdatetime(overlappingpsi->bill_items[bi].psi[prices].old_beg_effective_dt_tm) <=
        cnvtdatetime(overlappingpsi->bill_items[bi].psi[(prices - 1)].old_end_effective_dt_tm)
         AND cnvtdatetime(overlappingpsi->bill_items[bi].psi[prices].old_end_effective_dt_tm) >
        cnvtdatetime(overlappingpsi->bill_items[bi].psi[(prices - 1)].old_end_effective_dt_tm))) )) )
         SET overlappingpsi->bill_items[bi].psi[prices].new_end_effective_dt_tm = datetimeadd(
          overlappingpsi->bill_items[bi].psi[(prices - 1)].old_beg_effective_dt_tm,- (one_sec))
         SET found_some = 1
         IF (cnvtdatetime(overlappingpsi->bill_items[bi].psi[prices].new_end_effective_dt_tm) <=
         cnvtdatetime(overlappingpsi->bill_items[bi].psi[prices].old_beg_effective_dt_tm))
          SET overlappingpsi->bill_items[bi].psi[prices].inactivate_ind = 1
         ELSE
          SET overlappingpsi->bill_items[bi].psi[prices].update_ind = 1
          SET last_active = prices
         ENDIF
        ELSE
         SET last_active = prices
        ENDIF
       ENDIF
      ENDIF
      SET first_time = 0
     ENDFOR
   ENDFOR
   CALL echorecord(overlappingpsi,"ccluserdir:afc_upt.dat")
   CALL update_dates(0)
   IF (found_some=0)
    CALL echo(build("No overlapping prices found for price_sched:",price_scheds->list[pscheds].name))
   ELSE
    IF (run_mode=1)
     CALL create_report(0)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE update_dates(e)
   FOR (bi = 1 TO value(size(overlappingpsi->bill_items,5)))
     FOR (prices = 1 TO value(size(overlappingpsi->bill_items[bi].psi,5)))
       IF ((overlappingpsi->bill_items[bi].psi[prices].inactivate_ind=1))
        SELECT INTO "nl:"
         psi2.price_sched_items_id
         FROM price_sched_items psi,
          price_sched_items psi2
         PLAN (psi
          WHERE (psi.price_sched_items_id=overlappingpsi->bill_items[bi].psi[prices].
          price_sched_items_id))
          JOIN (psi2
          WHERE psi2.price_sched_items_id != psi.price_sched_items_id
           AND psi2.price_sched_id=psi.price_sched_id
           AND psi2.bill_item_id=psi.bill_item_id
           AND psi2.beg_effective_dt_tm=psi.beg_effective_dt_tm
           AND psi2.end_effective_dt_tm=psi.end_effective_dt_tm
           AND psi2.active_ind=0)
         WITH nocounter
        ;end select
        IF (curqual=0)
         UPDATE  FROM price_sched_items p
          SET p.active_ind = 0, p.active_status_prsnl_id = fuser, p.active_status_cd = inactive_cd,
           p.active_status_dt_tm = cnvtdatetime(curdate,curtime), p.updt_id = fuser, p.updt_cnt = (p
           .updt_cnt+ 1),
           p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_task = 951233, p.updt_applctx = 0
          WHERE (p.price_sched_items_id=overlappingpsi->bill_items[bi].psi[prices].
          price_sched_items_id)
         ;end update
        ELSE
         DELETE  FROM price_sched_items p
          WHERE (p.price_sched_items_id=overlappingpsi->bill_items[bi].psi[prices].
          price_sched_items_id)
         ;end delete
        ENDIF
       ELSEIF ((overlappingpsi->bill_items[bi].psi[prices].update_ind=1))
        SELECT INTO "nl:"
         psi2.price_sched_items_id
         FROM price_sched_items psi,
          price_sched_items psi2
         PLAN (psi
          WHERE (psi.price_sched_items_id=overlappingpsi->bill_items[bi].psi[prices].
          price_sched_items_id))
          JOIN (psi2
          WHERE psi2.price_sched_items_id != psi.price_sched_items_id
           AND psi2.price_sched_id=psi.price_sched_id
           AND psi2.bill_item_id=psi.bill_item_id
           AND psi2.beg_effective_dt_tm=psi.beg_effective_dt_tm
           AND psi2.end_effective_dt_tm=psi.end_effective_dt_tm
           AND psi2.active_ind=1)
         WITH nocounter
        ;end select
        IF (curqual=0)
         UPDATE  FROM price_sched_items p
          SET p.end_effective_dt_tm = cnvtdatetime(overlappingpsi->bill_items[bi].psi[prices].
            new_end_effective_dt_tm), p.updt_id = fuser, p.updt_cnt = (p.updt_cnt+ 1),
           p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_task = 951233, p.updt_applctx = 0
          WHERE (p.price_sched_items_id=overlappingpsi->bill_items[bi].psi[prices].
          price_sched_items_id)
         ;end update
        ELSE
         DELETE  FROM price_sched_items p
          WHERE (p.price_sched_items_id=overlappingpsi->bill_items[bi].psi[prices].
          price_sched_items_id)
         ;end delete
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE create_report(f)
   CALL echo("Creating reports...")
   SET first_time = 1
   SELECT
    desc = trim(overlappingpsi->bill_items[d.seq].ext_description), bill_item_id = overlappingpsi->
    bill_items[d.seq].bill_item_id, act_type = trim(activity_types->list[counter].name),
    price_sched = trim(price_scheds->list[pscheds].name)
    FROM (dummyt d  WITH seq = value(size(overlappingpsi->bill_items,5))),
     dummyt d2,
     dummyt d1
    PLAN (d)
     JOIN (d2)
     JOIN (d1
     WHERE d1.seq <= size(overlappingpsi->bill_items[d.seq].psi,5))
    ORDER BY desc, bill_item_id, price_sched
    HEAD REPORT
     line = fillstring(130,"="), col 0, "Price Maintenance Cleanup",
     col 100, curdate"MMM-DD-YYYY;;D", col 112,
     curtime"HH:MM:SS;;M", row + 1, col 0,
     line, row + 1, col 0,
     "Activity Type:", col 15, act_type,
     col 60, "Price Sched:", col 74,
     price_sched, row + 1, col 0,
     line, row + 1, col 0,
     "Action", row + 1, col 3,
     "Bill Item", col 35, "Bill Item Id",
     col 52, "Begin Effective Date", col 75,
     "Old End Effective Date", col 100, "New End Effective Date",
     row + 1, col 0, line,
     row + 1
    DETAIL
     FOR (k = 1 TO size(overlappingpsi->bill_items[d.seq].psi,5))
       IF ((overlappingpsi->bill_items[d.seq].psi[k].inactivate_ind=1))
        IF (first_time != 1)
         row + 1
        ENDIF
        firt_time = 0, col 0, "INACTIVATE",
        row + 1, col 3, desc"###############################",
        col 35, bill_item_id, col 52,
        overlappingpsi->bill_items[d.seq].psi[k].old_beg_effective_dt_tm"MM/DD/YYYY HH:MM:SS;;D", col
         75, overlappingpsi->bill_items[d.seq].psi[k].old_end_effective_dt_tm"MM/DD/YYYY HH:MM:SS;;D",
        row + 1
       ELSEIF ((overlappingpsi->bill_items[d.seq].psi[k].update_ind=1))
        IF (first_time != 1)
         row + 1
        ENDIF
        firt_time = 0, col 0, "UPDATE",
        row + 1, col 3, desc"###############################",
        col 35, bill_item_id, col 52,
        overlappingpsi->bill_items[d.seq].psi[k].old_beg_effective_dt_tm"MM/DD/YYYY HH:MM:SS;;D", col
         75, overlappingpsi->bill_items[d.seq].psi[k].old_end_effective_dt_tm"MM/DD/YYYY HH:MM:SS;;D",
        col 100, overlappingpsi->bill_items[d.seq].psi[k].new_end_effective_dt_tm
        "MM/DD/YYYY HH:MM:SS;;D", row + 1
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
 END ;Subroutine
 FREE SET overlappingpsi
 FREE SET activity_types
 FREE SET price_scheds
END GO
