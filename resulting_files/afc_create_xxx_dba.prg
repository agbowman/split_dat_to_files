CREATE PROGRAM afc_create_xxx:dba
 DECLARE cur_cost_center = f8
 DECLARE loop_count = i4
 DECLARE cost_center_cnt = i4
 CALL create_bfa("INTEXT")
 GO TO end_of_bfa
 SUBROUTINE create_bfa(intext)
   SET loop_count = 1
   SET cost_center_cnt = 0
   SET cur_cost_center_name = fillstring(60," ")
   CALL echo("CHARGE QUAL: ",0)
   CALL echo(request2->charge_qual)
   WHILE ((loop_count < request2->charge_qual))
     SET file_name = fillstring(30," ")
     SET cur_cost_center_name = fillstring(30," ")
     SET cur_cost_center = request2->charge[(loop_count+ 1)].cost_center_cd
     SET cost_center_cnt = (cost_center_cnt+ 1)
     IF (cur_cost_center > 0)
      SET cur_cost_center_name = uar_get_code_description(cur_cost_center)
      SET file_name = substring(1,30,concat("ccluserdir:xxx_",cnvtlower(cnvtalphanum(
          cur_cost_center_name))))
     ELSE
      SET file_name = substring(1,30,concat("ccluserdir:XXX_t01_",cnvtstring(cost_center_cnt)))
     ENDIF
     SET num_records = 0
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(request2->charge_qual))
      WHERE (request2->charge[d1.seq].cost_center_cd=cur_cost_center)
      DETAIL
       num_records = (num_records+ 1)
      WITH nocounter
     ;end select
     SET numbset = 0
     CALL echo(file_name)
     SELECT INTO value(file_name)
      t01_id = d.seq, t01_ord_dept = request2->charge[d.seq].order_department, t01_bill_code =
      request2->charge[d.seq].prim_cdm,
      t01_name = request2->charge[d.seq].person_name, t01_fin = request2->charge[d.seq].fin_nbr,
      t01_fin1 = cnvtint(request2->charge[d.seq].fin_nbr),
      t01_service_dt_tm = request2->charge[d.seq].service_dt_tm, t01_section = request2->charge[d.seq
      ].section_cd, t01_encounter_type = request2->charge[d.seq].encntr_type_display,
      t01_org_id = request2->charge[d.seq].payor_id, t01_client = request2->charge[d.seq].client,
      t01_quantity = request2->charge[d.seq].quantity,
      t01_price = request2->charge[d.seq].price, t01_net_ext_price = request2->charge[d.seq].
      net_ext_price, t01_charge_desc = request2->charge[d.seq].charge_description,
      t01_med_nbr = request2->charge[d.seq].med_nbr, t01_order_nbr = trim(request2->charge[d.seq].
       order_nbr,3), t01_ord_phys_id = request2->charge[d.seq].ord_phys_id,
      t01_code = request2->charge[d.seq].prim_cpt, t01_code_desc = request2->charge[d.seq].
      prim_cpt_desc, t01_srv_id = request2->charge[d.seq].ord_phys_id,
      t01_bill_type = request2->charge[d.seq].charge_type, t01_service_dt = format(request2->charge[d
       .seq].service_dt_tm,"DDMMMYY;R;DATE")
      FROM (dummyt d  WITH seq = value(request2->charge_qual))
      WHERE (request2->charge[d.seq].cost_center_cd=cur_cost_center)
      ORDER BY t01_ord_dept, t01_fin1, t01_name,
       t01_bill_code, t01_service_dt_tm, t01_client,
       t01_med_nbr
      HEAD REPORT
       charge_desc = fillstring(25," "), print_cnt = 0, rec_cnt = 0,
       first_time = "Y", do_line = "N", frr_accum_cnt = 0,
       frr_accum_amt = 0.00, frr_accum_qty = 0, icr_accum_cnt = 0,
       icr_accum_amt = 0.00, icr_accum_qty = 0, bfa_accum_cnt = 0,
       bfa_accum_amt = 0.00, bfa_accum_qty = 0, prev_bfa_department = fillstring(40," "),
       dept_accum_cnt = 0, dept_accum_amt = 0.00, dept_accum_qty = 0,
       dept_accum_cr_qty = 0, dept_accum_cr_amt = 0.00, dept_accum_cr_cnt = 0,
       dept_accum_dr_qty = 0, dept_accum_dr_amt = 0.00, dept_accum_dr_cnt = 0,
       prev_bfa_pat = fillstring(40,"*"), pat_accum_cnt = 0, pat_accum_amt = 0.00,
       pat_accum_qty = 0, prev_bfa_fin = fillstring(40,"*"), fin_accum_cnt = 0,
       fin_accum_amt = 0.00, fin_accum_qty = 0, prev_bfa_bill = fillstring(40,"*"),
       prev_bfa_bill_s = fillstring(3,"*"), bill_accum_cnt = 0, bill_accum_amt = 0.00,
       bill_accum_qty = 0, report_name = concat(trim(file_passed_in)," Billing File Audit Report "),
       line120 = fillstring(120,"-"),
       eqline120 = fillstring(120,"="), head10 =
       "                               FINANCIAL  MEDICAL  P SERVICE PROC BILLING ", head20 =
       "PATIENT NAME                     NUMBER   REC NBR  T  DATE   TIME   CODE  ",
       head30 = "------------------------------ ---------- -------- - ------- ---- --------", head15
        = "   CPT4                                CHARGE          ", head25 =
       "   CODE   PROCEDURE NAME               AMOUNT    QTY   ",
       head35 = " -------- --------------------------- -------- -------"
      HEAD PAGE
       col 00, report_name, col 35,
       cur_cost_center_name, col 70, curdate"DDMMMYY;;D",
       col 82, curtime"HH:MM;;M", col 89,
       "By: ", col 93, curuser"######",
       col 32, prev_bfa_department, col 114,
       "Page: ", col 120, curpage"###",
       row + 1, col 00, line120,
       row + 1, col 00, head10,
       col 74, head15, row + 1,
       col 00, head20, col 74,
       head25, row + 1, col 00,
       head30, col 74, head35,
       row + 1, pname = request2->charge[d.seq].person_name, fin = format(request2->charge[d.seq].
        fin_nbr,"##########;P0"),
       bill_code = request2->charge[d.seq].prim_cdm, client = format(request2->charge[d.seq].client,
        "####"), med_rec = request2->charge[d.seq].med_nbr,
       encntr_type = request2->charge[d.seq].encntr_type_display, sdt = "Y"
      HEAD t01_ord_dept
       IF (first_time != "Y")
        IF (((row+ 4) > maxrow))
         BREAK
        ENDIF
        first_time = "Y", numbset = 0, row + 1,
        col 70, "Total For Fin #: ", col 87,
        prev_bfa_fin, col 111, fin_accum_amt"######.##",
        col 122, fin_accum_qty"######", row + 1,
        numbset = (numbset+ (2** 1)),
        CALL zero_counts(numbset), do_line = "Y",
        numbset = 0, col 70, "Total For Name: ",
        col 87, prev_bfa_pat, col 111,
        pat_accum_amt"######.##", col 122, pat_accum_qty"######",
        row + 1, numbset = (numbset+ (2** 2)),
        CALL zero_counts(numbset),
        do_line = "Y", row + 2, col 70,
        "Total For Dept: ", col 87, prev_bfa_department,
        col 05, dept_accum_dr_cnt"#######", col 14,
        "Transactions For ", col 31, "DR ",
        col 111, dept_accum_dr_amt"######.##", col 122,
        dept_accum_dr_qty"######", row + 1, col 05,
        icr_accum_cnt"#######", col 14, "Transactions For ",
        col 31, "CR ", col 111,
        dept_accum_cr_amt"######.##", col 122, dept_accum_cr_qty"######",
        row + 1, col 1, eqline120,
        row + 1, numbset = (numbset+ (2** 3)),
        CALL zero_counts(numbset),
        BREAK
       ELSE
        prev_bfa_department = t01_ord_dept
       ENDIF
       pname = request2->charge[d.seq].person_name
      HEAD t01_fin
       IF (first_time != "Y")
        numbset = 0, row + 1, col 70,
        "Total For Fin #: ", col 87, prev_bfa_fin,
        col 111, fin_accum_amt"######.##", col 122,
        fin_accum_qty"######", row + 1, numbset = (numbset+ (2** 1)),
        CALL zero_counts(numbset), do_line = "Y"
       ENDIF
      HEAD t01_name
       IF (first_time != "Y")
        numbset = 0, col 70, "Total For Name: ",
        col 87, prev_bfa_pat, col 111,
        pat_accum_amt"######.##", col 122, pat_accum_qty"######",
        row + 1, numbset = (numbset+ (2** 2)),
        CALL zero_counts(numbset),
        do_line = "Y"
        IF (prev_bfa_department != t01_ord_dept)
         prev_bfa_department = t01_ord_dept, BREAK
        ENDIF
       ELSE
        first_time = "N"
       ENDIF
       pname = request2->charge[d.seq].person_name, fin = format(request2->charge[d.seq].fin_nbr,
        "##########;P0")
      HEAD t01_bill_code
       bill_code = request2->charge[d.seq].prim_cdm, charge_desc = trim(request2->charge[d.seq].
        charge_description,3)
       IF (trim(bill_code,3)="")
        bill_code = trim(request2->charge[d.seq].prim_cpt,3), charge_desc = trim(request2->charge[d
         .seq].prim_cpt_desc,3)
       ENDIF
      HEAD t01_client
       client = format(request2->charge[d.seq].client,"####")
      HEAD t01_med_nbr
       med_rec = request2->charge[d.seq].med_nbr
      HEAD t01_encounter_type
       encntr_type = request2->charge[d.seq].encntr_type_display
      HEAD t01_service_dt
       sdt = "Y"
      DETAIL
       loop_count = (loop_count+ 1)
       IF (do_line="Y")
        col 00, line120, row + 3,
        do_line = "N"
       ENDIF
       IF ((reply->t01_recs[d.seq].t01_interfaced="Y"))
        print_cnt = (print_cnt+ 1), prev_bfa_department = request2->charge[d.seq].order_department,
        prev_bfa_bill = request2->charge[d.seq].prim_cdm,
        prev_bfa_bill_s = substring(1,3,request2->charge[d.seq].prim_cdm), prev_bfa_pat = request2->
        charge[d.seq].person_name, prev_bfa_fin = request2->charge[d.seq].fin_nbr,
        col 00, pname, pname = " ",
        col 31, fin, fin = " ",
        col 41, " ", col 42,
        med_rec, med_rec = " ", col 51,
        encntr_type, encntr_type = " "
        IF (sdt="Y")
         col 53, request2->charge[d.seq].service_dt_tm"DDMMMYY;R;DATE", sdt = "N"
        ENDIF
        col 61, request2->charge[d.seq].service_dt_tm"HHMM;;M", col 66,
        bill_code, bill_code = " ", col 75,
        "   ", col 84, charge_desc,
        col 112, request2->charge[d.seq].net_ext_price"#####.##", col 122,
        request2->charge[d.seq].quantity"####.##", row + 1, col 64,
        t01_order_nbr"#################"
        IF ((request2->charge[d.seq].price >= 0))
         frr_accum_cnt = (frr_accum_cnt+ 1), frr_accum_amt = (frr_accum_amt+ request2->charge[d.seq].
         net_ext_price), frr_accum_qty = (frr_accum_qty+ request2->charge[d.seq].quantity),
         dept_accum_dr_cnt = (dept_accum_dr_cnt+ 1), dept_accum_dr_amt = (dept_accum_dr_amt+ request2
         ->charge[d.seq].net_ext_price), dept_accum_dr_qty = (dept_accum_dr_qty+ request2->charge[d
         .seq].quantity)
        ENDIF
        IF ((request2->charge[d.seq].price < 0))
         icr_accum_cnt = (icr_accum_cnt+ 1), icr_accum_amt = (icr_accum_amt+ - ((1 * request2->
         charge[d.seq].net_ext_price))), icr_accum_qty = (icr_accum_qty+ request2->charge[d.seq].
         quantity),
         dept_accum_cr_cnt = (dept_accum_cr_cnt+ 1), dept_accum_cr_amt = (dept_accum_cr_amt+ - ((1 *
         request2->charge[d.seq].net_ext_price))), dept_accum_cr_qty = (dept_accum_cr_qty+ request2->
         charge[d.seq].quantity)
        ENDIF
        bfa_accum_cnt = (bfa_accum_cnt+ 1), bfa_accum_amt = (bfa_accum_amt+ request2->charge[d.seq].
        net_ext_price), bfa_accum_qty = (bfa_accum_qty+ request2->charge[d.seq].quantity),
        dept_accum_cnt = (dept_accum_cnt+ 1), dept_accum_amt = (dept_accum_amt+ request2->charge[d
        .seq].net_ext_price), dept_accum_qty = (dept_accum_qty+ request2->charge[d.seq].quantity),
        bill_accum_cnt = (bill_accum_cnt+ 1), bill_accum_amt = (bill_accum_amt+ request2->charge[d
        .seq].net_ext_price), bill_accum_qty = (bill_accum_qty+ request2->charge[d.seq].quantity),
        pat_accum_cnt = (pat_accum_cnt+ 1), pat_accum_amt = (pat_accum_amt+ request2->charge[d.seq].
        net_ext_price), pat_accum_qty = (pat_accum_qty+ request2->charge[d.seq].quantity),
        fin_accum_cnt = (fin_accum_cnt+ 1), fin_accum_amt = (fin_accum_amt+ request2->charge[d.seq].
        net_ext_price), fin_accum_qty = (fin_accum_qty+ request2->charge[d.seq].quantity),
        row + 1
       ENDIF
       rec_cnt = (rec_cnt+ 1)
       IF ((rec_cnt=request2->charge_qual))
        col 00, line120, row + 1,
        col 70, "Total For Fin #:", col 87,
        prev_bfa_fin, col 111, fin_accum_amt"######.##",
        col 122, fin_accum_qty"######", row + 1,
        col 70, "Total For Name: ", col 87,
        prev_bfa_pat, col 111, pat_accum_amt"######.##",
        col 122, pat_accum_qty"######", row + 1,
        row + 2, col 05, dept_accum_cnt"#######",
        col 70, "Total For Dept: ", col 87,
        prev_bfa_department, col 05, dept_accum_dr_cnt"#######",
        col 14, "Transactions For ", col 31,
        "DR ", col 111, dept_accum_dr_amt"######.##",
        col 122, dept_accum_dr_qty"######", row + 1,
        col 05, icr_accum_cnt"#######", col 14,
        "Transactions For ", col 31, "CR ",
        col 111, dept_accum_cr_amt"######.##", col 122,
        dept_accum_cr_qty"######", row + 1, col 00,
        line120, row + 1, col 00,
        line120, row + 1, col 05,
        frr_accum_cnt"#######", col 14, "Transactions For ",
        col 31, "DR ", col 111,
        frr_accum_amt"######.##", col 122, frr_accum_qty"######",
        row + 1, col 05, icr_accum_cnt"#######",
        col 14, "Transactions For ", col 31,
        "CR ", col 111, icr_accum_amt"######.##",
        col 122, icr_accum_qty"######", row + 1,
        col 05, bfa_accum_cnt"#######", col 14,
        "Transactions For ", col 31, "BFA",
        col 70, "Total For Cost Center: ", col 93,
        cur_cost_center_name"##################", col 111, bfa_accum_amt"######.##",
        col 122, bfa_accum_qty"######", row + 1
       ENDIF
      WITH nocounter
     ;end select
   ENDWHILE
 END ;Subroutine
 SUBROUTINE zero_counts(numb)
   IF ((numb >= (2** 3)))
    SET dept_accum_cnt = 0
    SET dept_accum_amt = 0.00
    SET dept_accum_qty = 0
    SET dept_accum_cr_cnt = 0
    SET dept_accum_cr_amt = 0.00
    SET dept_accum_cr_qty = 0
    SET dept_accum_dr_cnt = 0
    SET dept_accum_dr_amt = 0.00
    SET dept_accum_dr_qty = 0
    SET numb = (numb - (2** 3))
   ENDIF
   IF ((numb >= (2** 3)))
    SET dept_accum_cnt = 0
    SET dept_accum_amt = 0.00
    SET dept_accum_qty = 0
    SET dept_accum_cr_cnt = 0
    SET dept_accum_cr_amt = 0
    SET dept_accum_cr_qty = 0
    SET dept_accum_dr_cnt = 0
    SET dept_accum_dr_amt = 0
    SET dept_accum_dr_qty = 0
    SET numb = (numb - (2** 3))
   ENDIF
   IF ((numb >= (2** 2)))
    SET pat_accum_cnt = 0
    SET pat_accum_amt = 0.00
    SET pat_accum_qty = 0
    SET numb = (numb - (2** 2))
   ENDIF
   IF ((numb >= (2** 1)))
    SET fin_accum_cnt = 0
    SET fin_accum_amt = 0.00
    SET fin_accum_qty = 0
    SET numb = (numb - (2** 1))
   ENDIF
 END ;Subroutine
#end_of_bfa
END GO
