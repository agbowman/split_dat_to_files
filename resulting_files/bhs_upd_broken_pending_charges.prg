CREATE PROGRAM bhs_upd_broken_pending_charges
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Order_id" = 0,
  "Automaticly update rx_pending_charge rows? (yes/no):" = "no"
  WITH outdev, orderid, updatetable
 SET update_table = cnvtupper( $UPDATETABLE)
 IF (update_table="YES")
  SET out_dev = concat("jrw_test_charge2",format(curdate,"mm_dd_yyyy"),".csv")
 ELSE
  SET out_dev =  $OUTDEV
 ENDIF
 FREE SET charges
 RECORD charges(
   1 list[*]
     2 rx_pending_charge_id = f8
     2 action_seq = i4
     2 old_action_seq = i4
 )
 SELECT INTO value(out_dev)
  rpc.updt_dt_tm"mm:dd:yyyy hh:ss", rpc.rx_pending_charge_id, rpc.ingred_action_seq,
  oc.updt_dt_tm"mm:dd:yyyy hh:ss", oc.action_sequence
  FROM rx_pending_charge rpc,
   order_ingredient oc
  PLAN (rpc
   WHERE (rpc.order_id= $ORDERID))
   JOIN (oc
   WHERE oc.order_id=rpc.order_id
    AND oc.updt_dt_tm <= rpc.updt_dt_tm)
  ORDER BY rpc.rx_pending_charge_id, oc.action_sequence DESC
  HEAD REPORT
   row + 1, "Purpose", row + 1,
   col 10, "To locate (by order_id) and display the update commands to fix certain pending", row + 1,
   col 10, "phaChargeCredit transactions that do NOT contain product/ingredient info when trying",
   row + 1,
   col 10, "to resolve those transactions in the phaChargeCredit.exe.", row + 2,
   col 0, "Once the data displayed has been verified run the update commands and", row + 1,
   "Save this output as a .csv for your records.", row + 1,
   "__________________________________________________________________________________________________",
   row + 1, listcnt = 0
  HEAD rpc.rx_pending_charge_id
   x = 0
  HEAD oc.action_sequence
   IF (x=0)
    IF (rpc.ingred_action_seq != oc.action_sequence)
     listcnt = (listcnt+ 1), stat = alterlist(charges->list,listcnt), charges->list[listcnt].
     action_seq = oc.action_sequence,
     charges->list[listcnt].old_action_seq = rpc.ingred_action_seq, charges->list[listcnt].
     rx_pending_charge_id = rpc.rx_pending_charge_id, x = (x+ 1),
     row + 1, col 0, "rx_pending_charge_id",
     ",", col 30, "RPCingred_act_seq",
     ",", col 50, "action_sequence",
     ",", col 70, "RPCupdt_dt_tm",
     ",", col 90, "updt_dt_tm",
     ",", row + 1, col 0,
     rpc.rx_pending_charge_id, ",", col 30,
     rpc.ingred_action_seq, ",", col 50,
     oc.action_sequence, ",", col 70,
     rpc.updt_dt_tm"mm:dd:yyyy hh:ss", ",", col 90,
     oc.updt_dt_tm"mm:dd:yyyy hh:ss", ",", col 10,
     row + 2, temp_update = concat("update into rx_pending_charge set ingred_action_seq = ",trim(
       cnvtstring(oc.action_sequence))," where rx_pending_charge_id = ",trim(cnvtstring(rpc
        .rx_pending_charge_id))), temp_update,
     row + 1
    ELSEIF (rpc.ingred_action_seq=oc.action_sequence)
     x = 1, row + 1, rpc.rx_pending_charge_id,
     row + 1, "This charge ID has correct Seq. values", row + 1
    ENDIF
    "__________________________________________________________________________________________________"
   ENDIF
  WITH maxcol = 300, maxrec = 100
 ;end select
 IF (update_table="YES")
  IF (value(size(charges->list,5)) > 0)
   UPDATE  FROM (dummyt d  WITH seq = value(size(charges->list,5))),
     rx_pending_charge rx
    SET rx.ingred_action_seq = charges->list[d.seq].action_seq
    PLAN (d)
     JOIN (rx
     WHERE (rx.rx_pending_charge_id=charges->list[d.seq].rx_pending_charge_id))
    WITH nocounter
   ;end update
   IF (curqual=value(size(charges->list,5)))
    COMMIT
    SELECT INTO  $OUTDEV
     rp.updt_dt_tm"mm:dd:yyyy hh:ss", rp.rx_pending_charge_id, rp.ingred_action_seq
     FROM (dummyt d  WITH seq = value(size(charges->list,5))),
      rx_pending_charge rp
     PLAN (d)
      JOIN (rp
      WHERE (rp.rx_pending_charge_id=charges->list[d.seq].rx_pending_charge_id))
     HEAD REPORT
      row + 1, "The table rx_pending_charge was successfully updated.", row + 2,
      "Please save the following file from CCLUSERDIR as a record of these updates", row + 1, col 10,
      out_dev
     HEAD rp.rx_pending_charge_id
      row + 1, col 0, "rx_pending_charge_id",
      ",", col 30, "old_ingred_act_seq",
      ",", col 50, "new_ingred_action_sequence",
      ",", row + 1, col 0,
      rp.rx_pending_charge_id, ",", col 30,
      charges->list[d.seq].old_action_seq, ",", col 50,
      rp.ingred_action_seq, ","
     WITH nocounter
    ;end select
   ELSE
    ROLLBACK
    SELECT INTO  $OUTDEV
     FROM dummyt
     HEAD REPORT
      col 20, "UPDATE FAILED", row + 2,
      "Please load the following file from CCLUSERDIR and manually run the updates", row + 1, col 10,
      out_dev
    ;end select
   ENDIF
  ELSE
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     col 20, "No rows found needing update"
   ;end select
  ENDIF
 ENDIF
END GO
