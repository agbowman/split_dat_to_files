CREATE PROGRAM afc_rpt_bill_item:dba
 PAINT
 SET bi_id = 0.0
 SET bi_id_type = 0
#menu
 CALL clear(1,1)
 CALL box(1,1,3,79)
 CALL box(1,1,23,79)
 CALL text(2,5,"Bill Item Detail Report")
 SET cur_row = 5
 CALL text(cur_row,10,"1) ID Type: ")
 CALL text(cur_row,33,"1 = Bill Item ID, 2 = Parent Ref ID, 0 = QUIT")
 CALL accept(cur_row,30,"9;",1
  WHERE curaccept IN (0, 1, 2))
 SET cur_row = (cur_row+ 1)
 SET bi_id_type = curaccept
 IF (curaccept=1)
  CALL text(cur_row,10,"2) Bill Item ID: ")
  SET prompt_text = "Create Report for Bill Item ID: "
 ELSEIF (curaccept=0)
  GO TO end_prog
 ELSE
  CALL text(cur_row,10,"2) Parent Ref ID: ")
  SET prompt_text = "Create Report for Parent Ref ID: "
 ENDIF
 CALL accept(cur_row,30,"9(17);C",0)
 SET bi_id = cnvtreal(curaccept)
 CALL text(24,1,concat(prompt_text,trim(cnvtstring(bi_id,17,2),3)," (Y/N/Q)?"))
 CALL accept(24,60,"p;cu","Y"
  WHERE curaccept IN ("Y", "N", "Q"))
 IF (curaccept="Y")
  CALL create_report("dummy")
  GO TO menu
 ELSEIF (curaccept="N")
  GO TO menu
 ELSEIF (curaccept="Q")
  GO TO end_prog
 ENDIF
 SUBROUTINE create_report(dummyvar)
   FREE SET bill_item
   RECORD bill_item(
     1 bill_item_id = f8
     1 ext_description = c50
     1 cp_list[*]
       2 cp_sched_cd = f8
       2 cp_sched_disp = vc
       2 cp_level_cd = f8
       2 cp_level_disp = vc
       2 cp_point_cd = f8
       2 cp_point_disp = vc
     1 ps_list[*]
       2 ps_sched_id = f8
       2 ps_desc = vc
       2 ps_price = f8
       2 ps_beg_dt_tm = dq8
       2 ps_end_dt_tm = dq8
     1 bc_list[*]
       2 bc_sched_cd = f8
       2 bc_sched_dsip = vc
       2 bc_code = vc
       2 bc_desc = vc
     1 ci_list[*]
       2 bill_item_id = f8
       2 ext_description = c50
       2 cp_list[*]
         3 cp_sched_cd = f8
         3 cp_sched_disp = vc
         3 cp_level_cd = f8
         3 cp_level_disp = vc
         3 cp_point_cd = f8
         3 cp_point_disp = vc
       2 ps_list[*]
         3 ps_sched_id = f8
         3 ps_desc = vc
         3 ps_price = f8
         3 ps_beg_dt_tm = dq8
         3 ps_end_dt_tm = dq8
       2 bc_list[*]
         3 bc_sched_cd = f8
         3 bc_sched_dsip = vc
         3 bc_code = vc
         3 bc_desc = vc
   )
   SET count1 = 0
   SET ref_id = 0.0
   SELECT
    IF (bi_id_type=1)
     WHERE b.bill_item_id=bi_id
    ELSE
     WHERE b.ext_parent_reference_id=bi_id
      AND b.ext_child_reference_id=0
    ENDIF
    INTO "nl:"
    b.*
    FROM bill_item b
    DETAIL
     ref_id = b.ext_parent_reference_id, bill_item->bill_item_id = b.bill_item_id, bill_item->
     ext_description = b.ext_description
    WITH nocounter
   ;end select
   SET count1 = 0
   SELECT INTO "nl:"
    bm.key1_id, bm.key2_id, bm.key4_id,
    cv1.display, cv2.display, cv3.display
    FROM bill_item_modifier bm,
     code_value cv1,
     code_value cv2,
     code_value cv3,
     dummyt d1
    PLAN (d1)
     JOIN (bm
     WHERE (bm.bill_item_id=bill_item->bill_item_id)
      AND (bm.bill_item_type_cd=
     (SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.code_set=13019
       AND cv.cdf_meaning="CHARGE POINT")))
     JOIN (cv1
     WHERE cv1.code_value=bm.key1_id)
     JOIN (cv2
     WHERE cv2.code_value=bm.key2_id)
     JOIN (cv3
     WHERE cv3.code_value=bm.key4_id)
    DETAIL
     count1 = (count1+ 1), stat = alterlist(bill_item->cp_list,count1), bill_item->cp_list[count1].
     cp_sched_cd = bm.key1_id,
     bill_item->cp_list[count1].cp_sched_disp = cv1.display, bill_item->cp_list[count1].cp_level_cd
      = bm.key4_id, bill_item->cp_list[count1].cp_level_disp = cv3.display,
     bill_item->cp_list[count1].cp_point_cd = bm.key2_id, bill_item->cp_list[count1].cp_point_disp =
     cv2.display
    WITH nocounter
   ;end select
   SET count1 = 0
   SELECT INTO "nl:"
    psi.price_sched_id, ps.price_sched_desc, psi.price,
    psi.beg_effective_dt_tm, psi.end_effective_dt_tm
    FROM price_sched_items psi,
     (dummyt d1  WITH seq = 1),
     price_sched ps
    PLAN (d1)
     JOIN (psi
     WHERE (psi.bill_item_id=bill_item->bill_item_id)
      AND psi.active_ind=1
      AND cnvtdatetime(curdate,curtime) BETWEEN psi.beg_effective_dt_tm AND psi.end_effective_dt_tm)
     JOIN (ps
     WHERE ps.price_sched_id=psi.price_sched_id)
    DETAIL
     count1 = (count1+ 1), stat = alterlist(bill_item->ps_list,count1), bill_item->ps_list[count1].
     ps_sched_id = psi.price_sched_id,
     bill_item->ps_list[count1].ps_desc = ps.price_sched_desc, bill_item->ps_list[count1].ps_price =
     psi.price, bill_item->ps_list[count1].ps_beg_dt_tm = psi.beg_effective_dt_tm,
     bill_item->ps_list[count1].ps_end_dt_tm = psi.end_effective_dt_tm
    WITH nocounter
   ;end select
   SET count1 = 0
   SELECT INTO "nl:"
    b.bill_item_id, b.ext_description
    FROM bill_item b
    WHERE b.ext_parent_reference_id=ref_id
     AND b.ext_child_reference_id != 0
    DETAIL
     count1 = (count1+ 1), stat = alterlist(bill_item->ci_list,count1), bill_item->ci_list[count1].
     bill_item_id = b.bill_item_id,
     bill_item->ci_list[count1].ext_description = b.ext_description
    WITH nocounter
   ;end select
   SET cp_cnt = 0
   SET ch_cnt = 0
   SET ps_cnt = 0
   SELECT
    par_item = bill_item->ext_description, p_cp_sched = bill_item->cp_list[d3.seq].cp_sched_disp,
    p_cp_lvl = bill_item->cp_list[d3.seq].cp_level_disp,
    p_cp_pnt = bill_item->cp_list[d3.seq].cp_point_disp, chi_item = bill_item->ci_list[d2.seq].
    ext_description, ps_desc = bill_item->ps_list[d4.seq].ps_desc,
    ps_price = bill_item->ps_list[d4.seq].ps_price
    FROM (dummyt d1  WITH seq = 1),
     (dummyt d3  WITH seq = value(size(bill_item->cp_list,5))),
     (dummyt d2  WITH seq = value(size(bill_item->ci_list,5))),
     (dummyt d4  WITH seq = value(size(bill_item->ps_list,5)))
    PLAN (d1)
     JOIN (d3)
     JOIN (d2)
     JOIN (d4)
    ORDER BY d1.seq, d3.seq, d4.seq,
     d2.seq
    HEAD d1.seq
     col 00, par_item, row + 1
    HEAD d3.seq
     IF (cp_cnt=0)
      col 05, "Charge Points:", row + 1,
      col 05, "--------------", row + 1
     ENDIF
     cp_cnt = (cp_cnt+ 1), col 10, p_cp_sched,
     col 60, p_cp_lvl, col 80,
     p_cp_pnt, row + 1
    HEAD d4.seq
     IF (cp_cnt=size(bill_item->cp_list,5)
      AND ps_cnt < size(bill_item->ps_list,5))
      IF (ps_cnt=0)
       col 05, "Price Schedules:", row + 1,
       col 05, "----------------", row + 1
      ENDIF
      ps_cnt = (ps_cnt+ 1), col 10, ps_desc,
      col 30, ps_price, row + 1
     ENDIF
    HEAD d2.seq
     IF (ps_cnt=size(bill_item->ps_list,5)
      AND cp_cnt=size(bill_item->cp_list,5))
      col 05, chi_item, row + 1
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
#end_prog
END GO
