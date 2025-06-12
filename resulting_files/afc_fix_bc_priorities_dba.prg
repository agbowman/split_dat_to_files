CREATE PROGRAM afc_fix_bc_priorities:dba
 RECORD bim(
   1 b_l[*]
     2 bi_id = f8
     2 bim_id = f8
     2 old_pri = i4
     2 new_pri = i4
 )
 SET bill_code = 0.0
 SET code_value = 0.0
 SET code_set = 13019
 SET cdf_meaning = "BILL CODE"
 EXECUTE cpm_get_cd_for_cdf
 SET bill_code = code_value
 CALL echo(build("BILL_CODE: ",bill_code))
 UPDATE  FROM bill_item_modifier b
  SET b.bim1_int = b.key2_id
  WHERE b.bill_item_type_cd=bill_code
   AND b.bim1_int=0
   AND b.active_ind=1
  WITH nocounter
 ;end update
 SET count1 = 0
 SET 132_line = fillstring(130,"=")
 SET readme = 0
 IF (validate(request->setup_proc[1].success_ind,999) != 999)
  SET readme = 1
  CALL echo("no report")
  SET filename = "nl:"
 ELSE
  CALL echo("preparing report")
  SET filename = "MINE"
 ENDIF
 SELECT INTO value(filename)
  b.bill_item_id, desc = substring(1,25,b.ext_description), bm.key1_id,
  bm.bim1_int, bc = substring(1,10,bm.key6), bm.bill_item_mod_id,
  bm.beg_effective_dt_tm, bm.end_effective_dt_tm, sched_disp = substring(1,20,cv.display),
  dt = format(curdate,"dd-mmm-yyyy;;d"), tm = format(curtime,"hh:mm;;s")
  FROM bill_item b,
   bill_item_modifier bm,
   code_value cv
  PLAN (bm
   WHERE bm.bill_item_type_cd=bill_code
    AND bm.active_ind=1
    AND cnvtdatetime(curdate,curtime) BETWEEN bm.beg_effective_dt_tm AND bm.end_effective_dt_tm)
   JOIN (b
   WHERE b.bill_item_id=bm.bill_item_id)
   JOIN (cv
   WHERE cv.code_value=bm.key1_id)
  ORDER BY b.bill_item_id, bm.key1_id, bm.beg_effective_dt_tm,
   bm.end_effective_dt_tm, bm.bim1_int, bm.bill_item_mod_id
  HEAD REPORT
   col 25, "/* THIS REPORT SHOWS THE CURRENT BILL CODE PRIORITIES AND THE NEW PRIORITIES */", row + 1,
   col 75, "Report Date: ", col 90,
   dt, col 105, tm,
   row + 1
  HEAD PAGE
   col 05, "bill item", col 75,
   "priorities", row + 1, col 03,
   "id", col 10, "description",
   col 40, "schedule", col 65,
   "bill code", col 77, "old",
   col 81, "new", col 85,
   "bim id", col 95, "beg date",
   col 105, "end date", row + 1,
   col 00, 132_line, row + 1
  HEAD b.bill_item_id
   row + 1, col 00, b.bill_item_id"########",
   col 10, desc
  HEAD bm.key1_id
   col 40, sched_disp, pri = 0
  DETAIL
   pri = (pri+ 1), count1 = (count1+ 1), col 65,
   bc, col 78, bm.bim1_int"##",
   col 82, pri"##", col 85,
   bm.bill_item_mod_id"########", col 95, bm.beg_effective_dt_tm,
   col 105, bm.end_effective_dt_tm, row + 1,
   stat = alterlist(bim->b_l,count1), bim->b_l[count1].bi_id = b.bill_item_id, bim->b_l[count1].
   bim_id = bm.bill_item_mod_id,
   bim->b_l[count1].old_pri = bm.bim1_int, bim->b_l[count1].new_pri = pri
  WITH nocounter
 ;end select
 UPDATE  FROM bill_item_modifier bm,
   (dummyt d1  WITH seq = value(size(bim->b_l,5)))
  SET bm.bim1_int = bim->b_l[d1.seq].new_pri
  PLAN (d1
   WHERE (bim->b_l[d1.seq].old_pri != bim->b_l[d1.seq].new_pri))
   JOIN (bm
   WHERE (bm.bill_item_mod_id=bim->b_l[d1.seq].bim_id))
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL echo("No priorities updated")
 ELSE
  IF (readme=1)
   COMMIT
  ELSE
   CALL echo("bill code priorities updated, type 'commit go' to save changes.")
  ENDIF
 ENDIF
 FREE SET bim
END GO
