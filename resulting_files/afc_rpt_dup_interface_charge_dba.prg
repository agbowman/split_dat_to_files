CREATE PROGRAM afc_rpt_dup_interface_charge:dba
 SET upt_dups = cnvtint( $1)
 FREE SET request
 RECORD dup(
   1 qual_cnt = i4
   1 grand_total = i4
   1 qual_arr[*]
     2 reset_total = i4
     2 dup_arr[*]
       3 batch_num = f8
       3 charge_item_id = f8
       3 interface_charge_id = f8
       3 fin_nbr = c50
 )
 SET from_ops = 0
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET out_file = concat(build("rpt_dup_ic_",format(curdate,"DD-MMM-YYYY;;D")))
 SELECT INTO value(out_file)
  ic.batch_num, ic.charge_item_id, ic.interface_charge_id,
  ic.fin_nbr
  FROM interface_charge ic
  WHERE ic.process_flg=0
   AND ic.active_ind=1
  ORDER BY ic.batch_num, ic.charge_item_id, ic.interface_charge_id
  HEAD REPORT
   col 01, "DATE: ", col 09,
   curdate, col 50, "Duplicate Charge Report",
   row + 1, col 01, "Time: ",
   col 09, curtime3, row + 2,
   pagecnt = 0, dupcnt = 0, qual = 0,
   grand_total = 0
  HEAD PAGE
   pagecnt = (pagecnt+ 1), col 80, "Page: ",
   col 90, pagecnt, row + 2,
   col 01, "Charge_", col 25,
   "Interface_", col 75, "Financial",
   row + 1, col 01, "Item_id",
   col 25, "Charge_id", col 50,
   "Batch_num", col 75, "Number",
   row + 1, dash = fillstring(90,"_"), col 01,
   dash, row + 1
  HEAD ic.batch_num
   row + 0, dupcnt = 0
  HEAD ic.charge_item_id
   dupcnt = 0, qual = (qual+ 1), stat = alterlist(dup->qual_arr,qual),
   dup->qual_cnt = qual, x = 0, row + 0
  DETAIL
   dupcnt = (dupcnt+ 1), stat = alterlist(dup->qual_arr[qual].dup_arr,dupcnt), dup->qual_arr[qual].
   dup_arr[dupcnt].charge_item_id = ic.charge_item_id,
   dup->qual_arr[qual].dup_arr[dupcnt].interface_charge_id = ic.interface_charge_id, dup->qual_arr[
   qual].dup_arr[dupcnt].batch_num = ic.batch_num, dup->qual_arr[qual].dup_arr[dupcnt].fin_nbr = ic
   .fin_nbr
  FOOT  ic.charge_item_id
   IF (dupcnt > 1)
    reset_total = (dupcnt - 1), grand_total = (grand_total+ reset_total), dup->grand_total =
    grand_total,
    dup->qual_arr[qual].reset_total = reset_total
    FOR (x = 1 TO reset_total)
      col 01, dup->qual_arr[qual].dup_arr[x].charge_item_id, col 25,
      dup->qual_arr[qual].dup_arr[x].interface_charge_id, col 50, dup->qual_arr[qual].dup_arr[x].
      batch_num,
      col 75, dup->qual_arr[qual].dup_arr[x].fin_nbr, row + 1
    ENDFOR
    row + 1, total_string = concat("Charge Item ID ",cnvtstring(ic.charge_item_id),
     " Total Set to 998: ",cnvtstring(reset_total)), col 55,
    total_string, row + 1, bar = fillstring(40,"_"),
    col 60, bar, row + 1
   ENDIF
  FOOT  ic.batch_num
   row + 0
  FOOT REPORT
   col 55, "Report Total Reset: ", col 82,
   grand_total, row + 1, dblbar = fillstring(40,"="),
   col 60, dblbar
  WITH nocounter
 ;end select
 IF (upt_dups=1)
  CALL echo(build("changing dups"))
  SET i = 0
  SET j = 0
  SET c = 0
  FOR (i = 1 TO dup->qual_cnt)
    FOR (j = 1 TO dup->qual_arr[i].reset_total)
      SET c = (c+ 1)
      UPDATE  FROM interface_charge ic
       SET ic.process_flg = 998
       WHERE (ic.interface_charge_id=dup->qual_arr[i].dup_arr[j].interface_charge_id)
       WITH nocounter
      ;end update
      IF (c > 20)
       COMMIT
       SET c = 0
      ENDIF
    ENDFOR
  ENDFOR
  IF (c < 21)
   COMMIT
   SET c = 0
  ENDIF
  CALL echo(concat(cnvtstring(dup->grand_total),"  Duplicate entries changed to 998."))
 ELSE
  CALL echo(build("none changed"))
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
