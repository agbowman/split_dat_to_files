CREATE PROGRAM afc_rpt_realtime_audit:dba
 PAINT
 SET width = 132
 SET modify = system
 EXECUTE cclseclogin
 CALL text(5,10,"REAL-TIME AUDIT REPORT")
 CALL text(6,10,"----------------------")
 RECORD interfacechargereq(
   1 first_time = c1
   1 file_name = c80
   1 charge_qual = i4
   1 charge[*]
     2 interface_charge_id = f8
     2 charge_event_id = f8
     2 charge_item_id = f8
     2 charge_act_id = f8
     2 charge_mod_id = f8
     2 person_id = f8
     2 birth_dt_tm = dq8
     2 age = c12
     2 sex_cd = f8
     2 encntr_id = f8
     2 payor_id = f8
     2 adm_loc_cd = f8
     2 ord_loc_cd = f8
     2 ord_dept_cd = f8
     2 ord_department = c40
     2 ord_doc_nbr = c20
     2 doc_nbr = i4
     2 ord_sect_cd = f8
     2 ord_section = c40
     2 perf_loc_cd = f8
     2 adm_phys_id = f8
     2 ord_phys_id = f8
     2 perf_phys_id = f8
     2 ref_phys_id = f8
     2 price_sched_id = f8
     2 item_quantity = i4
     2 item_price = f8
     2 item_extended_price = f8
     2 item_allowable = f8
     2 item_copay = f8
     2 research_acct_id = f8
     2 service_dt_tm = dq8
     2 prim_mnem = c40
     2 prim_cdm = c40
     2 prim_cpt = c50
     2 prim_cdm_desc = c200
     2 cpt_desc = c200
     2 order_nbr = c20
     2 med_nbr = c20
     2 fin_nbr = c20
     2 client = c20
     2 person_name = c30
     2 charge_description = c200
     2 charge_pt = c1
     2 encntr_type = c1
     2 charge_type = c6
     2 trans_type = f8
     2 updt_applctx = i4
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 active_ind = i2
     2 interface_file_id = f8
     2 charge_type_cd = f8
     2 active_status_cd = f8
     2 active_status_prsnl_id = f8
     2 active_status_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 institution_cd = f8
     2 department_cd = f8
     2 subsection_cd = f8
     2 section_cd = f8
     2 order_nbr = c200
     2 perf_phys_id = f8
     2 process_flg = i4
     2 cost_center_cd = f8
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD fileid(
   1 count = i2
   1 interface[*]
     2 id_number = f8
 )
 DECLARE cur_cost_center = f8
 DECLARE loop_count = i4
 DECLARE cost_center_cnt = i4
 DECLARE fileid_count = i4
 SET message = nowindow
 IF (validate(request->ops_date,999) != 999)
  IF ((request->ops_date > 0))
   SET rn_dt = cnvtdatetime(request->ops_date)
   SET rn_dt_f = cnvtdatetime(concat(format(rn_dt,"DD-MMM-YYYY;;D")," 00:00:00.00"))
   SET rn_dt_t = cnvtdatetime(concat(format(rn_dt,"DD-MMM-YYYY;;D")," 23:59:59.99"))
  ENDIF
 ELSE
  CALL text(10,2,"Enter the date for the report (dd-mmm-yyyy): ")
  CALL accept(10,46,"nndpppdnnnn;cs",format(curdate,"dd-mmm-yyyy;;d")
   WHERE format(cnvtdatetime(curaccept),"dd-mmm-yyyy;;d")=cnvtupper(curaccept))
  SET rn_dt = curaccept
  SET rn_dt_f = concat(rn_dt," 00:00:00.00")
  SET rn_dt_t = concat(rn_dt," 23:59:59.99")
 ENDIF
 SET fileid_count = 0
 SET stat = alterlist(fileid->interface,fileid_count)
 SELECT DISTINCT INTO "nl:"
  inf.interface_file_id
  FROM interface_file inf
  WHERE inf.realtime_ind=1
  DETAIL
   fileid_count = (fileid_count+ 1), stat = alterlist(fileid->interface,fileid_count), fileid->
   interface[fileid_count].id_number = inf.interface_file_id,
   CALL text(13,1,concat("Interface file id found: ",cnvtstring(inf.interface_file_id,17)))
  WITH nocounter
 ;end select
 SET fileid->count = fileid_count
 SET fileid_count = 0
 SET stat = alterlist(interfacechargereq->charge,fileid_count)
 FOR (y = 1 TO fileid->count)
   SELECT DISTINCT INTO "nl:"
    ic.charge_item_id, ic.beg_effective_dt_tm
    FROM interface_charge ic
    WHERE (ic.interface_file_id=fileid->interface[y].id_number)
     AND ic.beg_effective_dt_tm BETWEEN cnvtdatetime(rn_dt_f) AND cnvtdatetime(rn_dt_t)
    ORDER BY ic.cost_center_cd
    DETAIL
     fileid_count = (fileid_count+ 1), stat = alterlist(interfacechargereq->charge,fileid_count),
     interfacechargereq->charge[y].interface_charge_id = ic.interface_charge_id,
     interfacechargereq->charge[fileid_count].prim_cdm = ic.prim_cdm, interfacechargereq->charge[
     fileid_count].person_name = ic.person_name, interfacechargereq->charge[fileid_count].fin_nbr =
     ic.fin_nbr,
     interfacechargereq->charge[fileid_count].service_dt_tm = ic.service_dt_tm, interfacechargereq->
     charge[fileid_count].ord_section = uar_get_code_display(ic.section_cd), interfacechargereq->
     charge[fileid_count].encntr_type = uar_get_code_display(ic.encntr_type_cd),
     interfacechargereq->charge[fileid_count].payor_id = ic.payor_id, interfacechargereq->charge[
     fileid_count].item_quantity = ic.quantity, interfacechargereq->charge[fileid_count].item_price
      = ic.gross_price,
     interfacechargereq->charge[fileid_count].item_extended_price = ic.net_ext_price,
     interfacechargereq->charge[fileid_count].charge_description = ic.charge_description,
     interfacechargereq->charge[fileid_count].med_nbr = ic.med_nbr,
     interfacechargereq->charge[fileid_count].order_nbr = ic.order_nbr, interfacechargereq->charge[
     fileid_count].ord_phys_id = ic.ord_phys_id, interfacechargereq->charge[fileid_count].prim_cpt =
     ic.prim_cpt,
     interfacechargereq->charge[fileid_count].cpt_desc = ic.prim_cpt_desc, interfacechargereq->
     charge[fileid_count].charge_type = uar_get_code_display(ic.charge_type_cd), interfacechargereq->
     charge[fileid_count].cost_center_cd = ic.cost_center_cd
    WITH counter
   ;end select
   SET interfacechargereq->charge_qual = fileid_count
   IF ((interfacechargereq->charge_qual > 0))
    CALL text(14,1,concat("Charge_qual: ",cnvtstring(interfacechargereq->charge_qual)))
    CALL create_bfa("INTEXT")
   ELSE
    CALL text(14,1,"No qualifying records found")
   ENDIF
   SUBROUTINE create_bfa(intext)
     SET loop_count = 0
     SET cost_center_cnt = 0
     SET quantity = 0
     SET accum_amount = 0.0
     SET accum_quantity = 0
     WHILE ((loop_count < interfacechargereq->charge_qual))
       SET file_name = fillstring(30," ")
       SET cur_cost_center_name = fillstring(30," ")
       SET cur_cost_center = interfacechargereq->charge[(loop_count+ 1)].cost_center_cd
       SET cost_center_cnt = (cost_center_cnt+ 1)
       IF (cur_cost_center > 0)
        SELECT INTO "nl:"
         cv.display_key
         FROM code_value cv
         WHERE cv.code_value=cur_cost_center
         DETAIL
          file_name = concat("ccluserdir:BF1_",cnvtalphanum(cv.description)), cur_cost_center_name =
          cv.description
         WITH nocounter
        ;end select
       ELSE
        SET file_name = concat("ccluserdir:bf1_t01_",cnvtstring(cost_center_cnt))
        SET cur_cost_center_name = cnvtstring(cost_center_cnt)
       ENDIF
       SET num_records = 0
       SELECT INTO "nl:"
        FROM (dummyt d1  WITH seq = value(interfacechargereq->charge_qual))
        WHERE (interfacechargereq->charge[d1.seq].cost_center_cd=cur_cost_center)
        DETAIL
         num_records = (num_records+ 1)
        WITH nocounter
       ;end select
       SET numbset = 0
       CALL text(18,2,file_name)
       SELECT INTO value(file_name)
        t01_id = d.seq, t01_ord_dept = interfacechargereq->charge[d.seq].ord_department,
        t01_bill_code = interfacechargereq->charge[d.seq].prim_cdm,
        t01_name = interfacechargereq->charge[d.seq].person_name, t01_fin = interfacechargereq->
        charge[d.seq].fin_nbr, t01_fin1 = interfacechargereq->charge[d.seq].fin_nbr,
        t01_service_dt_tm = interfacechargereq->charge[d.seq].service_dt_tm, t01_section =
        interfacechargereq->charge[d.seq].ord_section, t01_encounter_type = interfacechargereq->
        charge[d.seq].encntr_type,
        t01_org_id = interfacechargereq->charge[d.seq].payor_id, t01_client = interfacechargereq->
        charge[d.seq].client, t01_tcode = interfacechargereq->charge[d.seq].trans_type,
        t01_charge_pt = interfacechargereq->charge[d.seq].charge_pt, t01_item_quantity =
        interfacechargereq->charge[d.seq].item_quantity, t01_item_price = interfacechargereq->charge[
        d.seq].item_price,
        t01_item_ext_price = interfacechargereq->charge[d.seq].item_extended_price, t01_charge_desc
         = interfacechargereq->charge[d.seq].charge_description, t01_med_nbr = interfacechargereq->
        charge[d.seq].med_nbr,
        t01_order_nbr = interfacechargereq->charge[d.seq].order_nbr, t01_mne = interfacechargereq->
        charge[d.seq].prim_mnem, t01_ord_phys_id = interfacechargereq->charge[d.seq].ord_phys_id,
        t01_code = interfacechargereq->charge[d.seq].prim_cpt, t01_code_desc = interfacechargereq->
        charge[d.seq].cpt_desc, t01_srv_id = interfacechargereq->charge[d.seq].ord_phys_id,
        t01_bill_type = interfacechargereq->charge[d.seq].charge_type, t01_service_dt =
        interfacechargereq->charge[d.seq].service_dt_tm, "DD-MMM-YYYY;;D"
        FROM (dummyt d  WITH seq = value(interfacechargereq->charge_qual))
        WHERE (interfacechargereq->charge[d.seq].cost_center_cd=cur_cost_center)
        ORDER BY t01_name, t01_fin1, t01_bill_code,
         t01_service_dt_tm, t01_client, t01_med_nbr
        HEAD REPORT
         charge_desc = fillstring(25," "), print_cnt = 0, rec_cnt = 0,
         first_time = "Y", do_line = "N", frr_accum_cnt = 0,
         frr_accum_amt = 0.00, frr_accum_qty = 0, icr_accum_cnt = 0,
         icr_accum_amt = 0.00, icr_accum_qty = 0, bfa_accum_cnt = 0,
         bfa_accum_amt = 0.00, bfa_accum_qty = 0, dept_accum_cr_qty = 0,
         dept_accum_cr_amt = 0.00, dept_accum_cr_cnt = 0, prev_bfa_pat = fillstring(40,"*"),
         pat_accum_cnt = 0, pat_accum_amt = 0.00, pat_accum_qty = 0,
         prev_bfa_fin = fillstring(40,"*"), fin_accum_cnt = 0, fin_accum_amt = 0.00,
         fin_accum_qty = 0, prev_bfa_bill = fillstring(40,"*"), prev_bfa_bill_s = fillstring(3,"*"),
         report_name = "Billing File Audit Report ", line90 = fillstring(90,"-"), line120 =
         fillstring(120,"-"),
         eqline120 = fillstring(120,"="), head10 =
         "                               FINANCIAL  MEDICAL  P    SERVICE   BILLING ", head20 =
         "PATIENT NAME                     NUMBER   REC NBR  T  DATE   TIME   CODE  ",
         head30 = "----------------------------- ----------- -------- - ------- ---- --------",
         head15 = "   CPT4                                CHARGE          ", head25 =
         "   CODE   PROCEDURE NAME               AMOUNT    QTY   ",
         head35 = " -------- --------------------------- -------- -------"
        HEAD PAGE
         col 00, report_name, col 35,
         cur_cost_center_name, col 70, curdate"DD-MMM-YYYY;;D",
         col 82, curtime"HH:MM;;M", col 89,
         "By: ", col 93, curuser"######",
         col 114, "Page: ", col 120,
         curpage"###", row + 1, col 00,
         line120, row + 1, col 00,
         head10, col 74, head15,
         row + 1, col 00, head20,
         col 74, head25, row + 1,
         col 00, head30, col 74,
         head35, row + 1, pname = interfacechargereq->charge[d.seq].person_name,
         fin = format(interfacechargereq->charge[d.seq].fin_nbr,"#########"), bill_code =
         interfacechargereq->charge[d.seq].prim_cdm, client = format(interfacechargereq->charge[d.seq
          ].client,"####"),
         med_rec = interfacechargereq->charge[d.seq].med_nbr, sdt = "Y"
        HEAD t01_name
         IF (first_time != "Y")
          numbset = 0, col 70, "Total For Name: ",
          col 87, prev_bfa_pat, col 111,
          pat_accum_amt"######.##", col 122, pat_accum_qty"######",
          row + 1, numbset = (numbset+ (2** 2)),
          CALL zero_counts(numbset),
          do_line = "Y"
         ELSE
          first_time = "N"
         ENDIF
         pname = interfacechargereq->charge[d.seq].person_name, fin = format(interfacechargereq->
          charge[d.seq].fin_nbr,"##########")
        HEAD t01_fin1
         row + 1, fin_accum_amt = 0.0, fin_accum_qty = 0,
         fin = format(interfacechargereq->charge[d.seq].fin_nbr,"##########")
        HEAD t01_bill_code
         bill_code = interfacechargereq->charge[d.seq].prim_cdm, charge_desc = t01_charge_desc
         IF (trim(bill_code,3)="")
          bill_code = trim(interfacechargereq->charge[d.seq].prim_cpt,3), charge_desc = trim(
           interfacechargereq->charge[d.seq].cpt_desc,3)
         ENDIF
        HEAD t01_service_dt
         sdt = "Y"
        HEAD t01_client
         client = format(interfacechargereq->charge[d.seq].client,"####")
        HEAD t01_med_nbr
         med_rec = interfacechargereq->charge[d.seq].med_nbr
        HEAD t01_encounter_type
         encntr_type = interfacechargereq->charge[d.seq].encntr_type
        DETAIL
         loop_count = (loop_count+ 1)
         IF (do_line="Y")
          col 00, line120, row + 3,
          do_line = "N"
         ENDIF
         print_cnt = (print_cnt+ 1), prev_bfa_bill = interfacechargereq->charge[d.seq].prim_cdm,
         prev_bfa_bill_s = substring(1,3,interfacechargereq->charge[d.seq].prim_cdm),
         prev_bfa_pat = interfacechargereq->charge[d.seq].person_name, prev_bfa_fin =
         interfacechargereq->charge[d.seq].fin_nbr, col 00,
         pname, pname = " ", col 31,
         fin"##########", fin = " ", col 41,
         " ", col 42, med_rec"########",
         med_rec = " ", col 51, encntr_type"#",
         encntr_type = " "
         IF (sdt="Y")
          col 53, interfacechargereq->charge[d.seq].service_dt_tm"DDMMMYY;R;DATE", sdt = "N"
         ENDIF
         col 61, interfacechargereq->charge[d.seq].service_dt_tm"HHMM;;M", col 66,
         bill_code, bill_code = " ", col 75,
         " ", col 76, interfacechargereq->charge[d.seq].prim_cpt,
         col 84, charge_desc, col 112,
         interfacechargereq->charge[d.seq].item_extended_price"#####.##"
         IF ((interfacechargereq->charge[d.seq].item_price < 0))
          quantity = - ((1 * interfacechargereq->charge[d.seq].item_quantity)), interfacechargereq->
          charge[d.seq].item_quantity = (quantity * - (1))
         ELSEIF ((interfacechargereq->charge[d.seq].item_price >= 0))
          quantity = interfacechargereq->charge[d.seq].item_quantity
         ENDIF
         col 122, quantity"######", row + 1
         IF ((interfacechargereq->charge[d.seq].item_price >= 0))
          frr_accum_cnt = (frr_accum_cnt+ 1), frr_accum_amt = (frr_accum_amt+ interfacechargereq->
          charge[d.seq].item_extended_price), frr_accum_qty = (frr_accum_qty+ quantity)
         ENDIF
         IF ((interfacechargereq->charge[d.seq].item_price < 0))
          icr_accum_cnt = (icr_accum_cnt+ 1), icr_accum_amt = (icr_accum_amt+ - ((1 *
          interfacechargereq->charge[d.seq].item_extended_price))), icr_accum_qty = (icr_accum_qty+
          interfacechargereq->charge[d.seq].item_quantity),
          dept_accum_cr_cnt = (dept_accum_cr_cnt+ 1), dept_accum_cr_qty = (dept_accum_cr_qty+
          quantity)
         ENDIF
         bfa_accum_cnt = (bfa_accum_cnt+ 1), bfa_accum_amt = (bfa_accum_amt+ interfacechargereq->
         charge[d.seq].item_extended_price), bfa_accum_qty = (bfa_accum_qty+ quantity),
         pat_accum_cnt = (pat_accum_cnt+ 1), pat_accum_amt = (pat_accum_amt+ interfacechargereq->
         charge[d.seq].item_extended_price), pat_accum_qty = (pat_accum_qty+ quantity),
         fin_accum_cnt = (fin_accum_cnt+ 1), fin_accum_amt = (fin_accum_amt+ interfacechargereq->
         charge[d.seq].item_extended_price), fin_accum_qty = (fin_accum_qty+ quantity),
         row + 1, rec_cnt = (rec_cnt+ 1)
         IF (rec_cnt=num_records)
          col 00, line120, row + 1,
          col 70, "Total For Fin #:", col 87,
          prev_bfa_fin, col 111, fin_accum_amt"######.##",
          col 122, fin_accum_qty"######", row + 1,
          col 70, "Total For Name: ", col 87,
          prev_bfa_pat, col 111, pat_accum_amt"######.##",
          col 122, pat_accum_qty"######", row + 1,
          row + 2, col 00, line120,
          row + 1, col 05, frr_accum_cnt"#######",
          col 14, "Transactions For ", col 31,
          "DR ", col 111, frr_accum_amt"######.##",
          col 122, frr_accum_qty"######", row + 1,
          col 05, icr_accum_cnt"#######", col 14,
          "Transactions For ", col 31, "CR ",
          accum_amount = 0.0, accum_quantity = 0, accum_amount = (accum_amount+ (icr_accum_amt * - (1
          ))),
          col 111, accum_amount"######.##", accum_quantity = (accum_quantity+ (icr_accum_qty * - (1))
          ),
          col 123, accum_quantity"#####", row + 1,
          col 05, bfa_accum_cnt"#######", col 14,
          "Transactions For ", col 31, "BFA",
          col 70, "Total For Cost Center: ", col 93,
          cur_cost_center_name"##################", col 111, bfa_accum_amt"######.##",
          col 122, bfa_accum_qty"######", row + 1
         ENDIF
        FOOT  t01_fin1
         IF (rec_cnt != num_records)
          col 30, line90, row + 1,
          col 70, "Total For Fin #:", col 87,
          prev_bfa_fin, col 111, fin_accum_amt"######.##",
          col 122, fin_accum_qty"######", row + 1
         ELSE
          row + 0
         ENDIF
        WITH nocounter
       ;end select
     ENDWHILE
   END ;Subroutine
   SUBROUTINE zero_counts(numb)
     IF ((numb >= (2** 3)))
      SET dept_accum_cr_cnt = 0
      SET dept_accum_cr_amt = 0.00
      SET dept_accum_cr_qty = 0
      SET numb = (numb - (2** 3))
     ENDIF
     IF ((numb >= (2** 3)))
      SET dept_accum_cnt = 0
      SET dept_accum_amt = 0.00
      SET dept_accum_qty = 0
      SET dept_accum_cr_cnt = 0
      SET dept_accum_cr_amt = 0.0
      SET dept_accum_cr_qty = 0
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
 ENDFOR
#end_of_bfa
 SET reply->status_data.status = "S"
 SET reply->status_data.subeventstatus[1].operationname = "BF1 Audit Report"
 SET reply->status_data.subeventstatus[1].operationstatus = "S"
 SET reply->status_data.subeventstatus[1].targetobjectname = "AFC_RPT_REALTIME_AUDIT"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AFC_RPT_REALTIME_AUDIT"
END GO
