CREATE PROGRAM afc_rpt_audit_orders:dba
 PAINT
 SET width = 132
 SET modify = system
 CALL clear(1,1)
 CALL video(n)
 CALL video(n)
 SET message = nowindow
 EXECUTE cclseclogin
 FREE SET ordersstruct
 RECORD ordersstruct(
   1 orders[*]
     2 order_id = f8
     2 order_status_cd = f8
     2 activity_type_cd = f8
     2 activity_type_disp = c40
     2 order_mnemonic = c100
     2 updt_dt_tm = dq8
     2 name_full_formatted = c25
     2 person_id = f8
     2 e_financial_number = c50
     2 charges_list[*]
       3 charge_description = vc
       3 process_flg = i4
       3 charge_item_id = f8
       3 item_extended_price = f8
       3 charge_type_cd = f8
       3 activity_type_cd = f8
       3 beg_effective_dt_tm = dq8
       3 interface_charge[*]
         4 interface_charge_id = f8
         4 ic_process_flg = i4
         4 ic_batch_num = f8
 )
 IF (validate(request->ops_date,999) != 999)
  IF ((request->ops_date > 0))
   SET begdate = cnvtdatetime(request->ops_date)
   SET enddate = cnvtdatetime(request->ops_date)
   SET begdate = cnvtdatetime(concat(format(begdate,"DD-MMM-YYYY;;D")," 00:00:00.00"))
   SET enddate = cnvtdatetime(concat(format(enddate,"DD-MMM-YYYY;;D")," 23:59:59.99"))
  ENDIF
 ELSE
  CALL text(4,4,"Beg Date            :")
  CALL text(5,4,"End Date            :")
  CALL accept(4,29,"nndpppdnnnndnndnn;cs",format(curdate,"dd-mmm-yyyy hh:mm;;d")
   WHERE format(cnvtdatetime(curaccept),"dd-mmm-yyyy hh:mm;;d")=cnvtupper(curaccept))
  SET begdate = curaccept
  CALL accept(5,29,"nndpppdnnnndnndnn;cs",format(curdate,"dd-mmm-yyyy hh:mm;;d")
   WHERE format(cnvtdatetime(curaccept),"dd-mmm-yyyy hh:mm;;d")=cnvtupper(curaccept))
  SET enddate = curaccept
 ENDIF
 CALL text(7,4,"Processing....")
 SET printer = fillstring(100," ")
 IF (validate(request->output_dist," ") != " ")
  SET printer = request->output_dist
  SET printer = trim(printer)
 ENDIF
 IF (trim(printer) != " ")
  SET prtr_name = printer
  SET file_name = "ccluserdir:afc_audit_ordrs.dat"
  SET summary_file_name = "ccluserdir:afc_rpt_sum.dat"
 ELSE
  SET prtr_name = "FILE"
  SET file_name = "MINE"
  SET summary_file_name = "FILE"
 ENDIF
 RECORD orderstatusstruct(
   1 codevalue[*]
     2 code_value = f8
     2 display = c40
 )
 RECORD chargetypestruct(
   1 codevalue[*]
     2 code_value = f8
     2 display = c40
 )
 SET ordered_qual = 0
 SET completed_qual = 0
 SET other_qual = 0
 SET grandtotalorders = 0
 SET ordered_no_charge_qual = 0
 SET completed_no_charge_qual = 0
 SET other_no_charge_qual = 0
 SET number_of_pending_charges = 0
 SET amount_of_pending_charges = 0.0
 SET number_of_suspended_charges = 0
 SET amount_of_suspended_charges = 0.0
 SET number_of_held_charges = 0
 SET amount_of_held_charges = 0.0
 SET number_of_interfaced_charges = 0
 SET amount_of_interfaced_charges = 0.0
 SET number_of_other_charges = 0
 SET amount_of_other_charges = 0.0
 SET grandtotalcharges = 0
 SET grandtotalchargesamount = 0.0
 SET number_pending_interface_charge = 0
 SET amount_pending_interface_charge = 0.0
 SET number_interfaced_interface_charge = 0
 SET amount_interfaced_interface_charge = 0.0
 SET number_other_interface_charge = 0
 SET amount_other_interface_charge = 0.0
 SET grandtotalinterfacecharge = 0
 SET grandtotalinterfacechargeamount = 0.0
 SET codevaluecount = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6004
   AND cv.active_ind=1
  DETAIL
   codevaluecount = (codevaluecount+ 1), stat = alterlist(orderstatusstruct->codevalue,codevaluecount
    ), orderstatusstruct->codevalue[codevaluecount].code_value = cv.code_value,
   orderstatusstruct->codevalue[codevaluecount].display = cv.display
  WITH nocounter
 ;end select
 SET codevaluecount = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=13028
   AND cv.active_ind=1
  DETAIL
   codevaluecount = (codevaluecount+ 1), stat = alterlist(chargetypestruct->codevalue,codevaluecount),
   chargetypestruct->codevalue[codevaluecount].code_value = cv.code_value,
   chargetypestruct->codevalue[codevaluecount].display = cv.display
  WITH nocounter
 ;end select
 DECLARE g_encounter_alias_fin_num = f8
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=319
   AND cv.cdf_meaning="FIN NBR"
   AND cv.active_ind=1
  DETAIL
   g_encounter_alias_fin_num = cv.code_value
  WITH nocounter
 ;end select
 DECLARE credittype = f8
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=13028
   AND cv.cdf_meaning="CR"
   AND cv.active_ind=1
  DETAIL
   credittype = cv.code_value
  WITH nocounter
 ;end select
 DECLARE ordered_code_value = f8
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6004
   AND cv.cdf_meaning="ORDERED"
   AND cv.active_ind=1
  DETAIL
   ordered_code_value = cv.code_value
  WITH nocounter
 ;end select
 DECLARE completed_code_value = f8
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6004
   AND cv.cdf_meaning="COMPLETED"
   AND cv.active_ind=1
  DETAIL
   completed_code_value = cv.code_value
  WITH nocounter
 ;end select
 DECLARE ord_id = f8
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=13016
   AND cv.cdf_meaning="ORD ID"
   AND cv.active_ind=1
  DETAIL
   ord_id = cv.code_value
  WITH nocounter
 ;end select
 SET count1 = 0
 SELECT INTO "nl:"
  o.activity_type_cd, o.order_id, o.order_status_cd,
  o.updt_dt_tm, p.name_full_formatted, ea.alias,
  ce.charge_event_id, c.charge_item_id
  FROM orders o,
   person p,
   encntr_alias ea,
   code_value cv
  PLAN (o
   WHERE o.updt_dt_tm > cnvtdatetime(begdate)
    AND o.updt_dt_tm < cnvtdatetime(enddate)
    AND o.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=o.activity_type_cd)
   JOIN (p
   WHERE o.person_id=p.person_id)
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ea.encntr_alias_type_cd=g_encounter_alias_fin_num
    AND ea.active_ind=1)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(ordersstruct->orders,count1), ordersstruct->orders[count1].
   order_id = o.order_id,
   ordersstruct->orders[count1].updt_dt_tm = o.updt_dt_tm, ordersstruct->orders[count1].
   activity_type_cd = o.activity_type_cd, ordersstruct->orders[count1].activity_type_disp = cv
   .display,
   ordersstruct->orders[count1].order_mnemonic = o.order_mnemonic, ordersstruct->orders[count1].
   order_status_cd = o.order_status_cd, ordersstruct->orders[count1].e_financial_number = ea.alias,
   ordersstruct->orders[count1].name_full_formatted = p.name_full_formatted, ordersstruct->orders[
   count1].person_id = p.person_id
   IF ((ordersstruct->orders[count1].order_status_cd=ordered_code_value))
    ordered_qual = (ordered_qual+ 1)
   ELSEIF ((ordersstruct->orders[count1].order_status_cd=completed_code_value))
    completed_qual = (completed_qual+ 1)
   ELSE
    other_qual = (other_qual+ 1)
   ENDIF
  WITH nocounter
 ;end select
 SET grandtotalorders = count1
 IF (size(ordersstruct->orders,5) > 0)
  SET count2 = 0
  SET totalcount = 0
  SELECT INTO "nl:"
   c.process_flg, c.charge_item_id, c.item_extended_price,
   c.charge_type_cd, orders_order_id = ordersstruct->orders[d1.seq].order_id
   FROM charge c,
    (dummyt d1  WITH seq = value(size(ordersstruct->orders,5))),
    dummyt d2
   PLAN (d1)
    JOIN (d2)
    JOIN (c
    WHERE (c.order_id=ordersstruct->orders[d1.seq].order_id)
     AND c.order_id > 0)
   HEAD orders_order_id
    count2 = 0
   DETAIL
    IF (c.charge_item_id > 0)
     count2 = (count2+ 1), totalcount = (totalcount+ 1), stat = alterlist(ordersstruct->orders[d1.seq
      ].charges_list,count2),
     ordersstruct->orders[d1.seq].charges_list[count2].charge_item_id = c.charge_item_id,
     ordersstruct->orders[d1.seq].charges_list[count2].charge_description = c.charge_description,
     ordersstruct->orders[d1.seq].charges_list[count2].process_flg = c.process_flg,
     ordersstruct->orders[d1.seq].charges_list[count2].item_extended_price = c.item_extended_price,
     ordersstruct->orders[d1.seq].charges_list[count2].charge_type_cd = c.charge_type_cd,
     ordersstruct->orders[d1.seq].charges_list[count2].activity_type_cd = c.activity_type_cd,
     ordersstruct->orders[d1.seq].charges_list[count2].beg_effective_dt_tm = c.beg_effective_dt_tm
     IF (c.process_flg=0)
      number_of_pending_charges = (number_of_pending_charges+ 1), amount_of_pending_charges = (
      amount_of_pending_charges+ c.item_extended_price)
     ELSEIF (c.process_flg=1)
      number_of_suspended_charges = (number_of_suspended_charges+ 1), amount_of_suspended_charges = (
      amount_of_suspended_charges+ c.item_extended_price)
     ELSEIF (c.process_flg=3)
      number_of_held_charges = (number_of_held_charges+ 1), amount_of_held_charges = (
      amount_of_held_charges+ c.item_extended_price)
     ELSEIF (c.process_flg=999)
      number_of_interfaced_charges = (number_of_interfaced_charges+ 1), amount_of_interfaced_charges
       = (amount_of_interfaced_charges+ c.item_extended_price)
     ELSE
      number_of_other_charges = (number_of_other_charges+ 1), amount_of_other_charges = (
      amount_of_other_charges+ c.item_extended_price)
     ENDIF
    ENDIF
   WITH nocounter, outerjoin = d2
  ;end select
  SET grandtotalcharges = ((((number_of_pending_charges+ number_of_suspended_charges)+
  number_of_held_charges)+ number_of_interfaced_charges)+ number_of_other_charges)
  SET grandtotalchargesamount = ((((amount_of_pending_charges+ amount_of_suspended_charges)+
  amount_of_held_charges)+ amount_of_interfaced_charges)+ amount_of_other_charges)
  FOR (i = 1 TO size(ordersstruct->orders,5))
    FOR (j = 1 TO size(ordersstruct->orders[i].charges_list,5))
     SET count3 = 0
     SELECT INTO "nl:"
      ic.interface_charge_id
      FROM interface_charge ic
      WHERE (ic.charge_item_id=ordersstruct->orders[i].charges_list[j].charge_item_id)
      DETAIL
       count3 = (count3+ 1), stat = alterlist(ordersstruct->orders[i].charges_list[j].
        interface_charge,count3), ordersstruct->orders[i].charges_list[j].interface_charge[count3].
       interface_charge_id = ic.interface_charge_id,
       ordersstruct->orders[i].charges_list[j].interface_charge[count3].ic_process_flg = ic
       .process_flg, ordersstruct->orders[i].charges_list[j].interface_charge[count3].ic_batch_num =
       ic.batch_num
       IF (ic.process_flg=0)
        number_pending_interface_charge = (number_pending_interface_charge+ 1),
        amount_pending_interface_charge = (amount_pending_interface_charge+ ic.net_ext_price)
       ELSEIF (ic.process_flg=999)
        number_interfaced_interface_charge = (number_interfaced_interface_charge+ 1),
        amount_interfaced_interface_charge = (amount_interfaced_interface_charge+ ic.net_ext_price)
       ELSE
        number_other_interface_charge = (number_other_interface_charge+ 1),
        amount_other_interface_charge = (amount_other_interface_charge+ ic.net_ext_price)
       ENDIF
      WITH nocounter
     ;end select
    ENDFOR
  ENDFOR
  SET grandtotalinterfacecharge = ((number_pending_interface_charge+
  number_interfaced_interface_charge)+ number_other_interface_charge)
  SET grandtotalinterfacechargeamount = ((amount_pending_interface_charge+
  amount_interfaced_interface_charge)+ amount_other_interface_charge)
  SET firsttime = 1
  SET x = 0
  SET pagenum = 0
  SET ordercount = 0
  SET pageordercount = 0
  SET total = 0.0
  SET pagetotal = 0.0
  SET chargecount = 0
  SET pagechargecount = 0
  SET interfacedchargecount = 0
  SET pageinterfacedchargecount = 0
  SELECT INTO value(file_name)
   finnbr = trim(ordersstruct->orders[d1.seq].e_financial_number), patientname = ordersstruct->
   orders[d1.seq].name_full_formatted, ordermnemonic = ordersstruct->orders[d1.seq].order_mnemonic,
   orderstatus = ordersstruct->orders[d1.seq].order_status_cd, activitytype = ordersstruct->orders[d1
   .seq].activity_type_cd, activitytypedisp = ordersstruct->orders[d1.seq].activity_type_disp,
   chargedate = format(ordersstruct->orders[d1.seq].charges_list[d2.seq].beg_effective_dt_tm,
    "MM/DD/YY;R;DATE"), price = ordersstruct->orders[d1.seq].charges_list[d2.seq].item_extended_price,
   batchnumber = ordersstruct->orders[d1.seq].charges_list[d2.seq].interface_charge[d3.seq].
   ic_batch_num
   FROM (dummyt d1  WITH seq = value(size(ordersstruct->orders,5))),
    dummyt d2,
    dummyt d3,
    dummyt d4,
    dummyt d5
   PLAN (d1)
    JOIN (d4)
    JOIN (d2
    WHERE d2.seq <= size(ordersstruct->orders[d1.seq].charges_list,5))
    JOIN (d5)
    JOIN (d3
    WHERE d3.seq <= size(ordersstruct->orders[d1.seq].charges_list[d2.seq].interface_charge,5))
   ORDER BY activitytypedisp, finnbr
   HEAD REPORT
    mainheading = "O R D E R S  T O  C H A R G E S  A U D I T", todaysdate = concat(format(
      cnvtdatetime(curdate,curtime),"DD-MMM-YYYY;;D")), underline = fillstring(125,"-"),
    col 0, "Date: ", col 6,
    todaysdate, col 44, mainheading,
    col 116, "Page:  1 ", row + 1,
    col 0, "Begin Date: ", col 12,
    begdate, row + 1, col 0,
    "End Date: ", col 10, enddate,
    row + 2
   HEAD PAGE
    pagenum = (pagenum+ 1)
    IF (firsttime=0)
     col 116, "Page:", col 124,
     pagenum"##", row + 1
    ENDIF
    firsttime = 0, col 0, "FIN NBR",
    col 10, "PATIENT NAME", col 27,
    "ORDER", col 36, "ORDER",
    col 46, "CHARGE", col 56,
    "CHARGE", col 73, "CHARGE",
    col 86, "PRICE", col 96,
    "CHARGE", col 106, "INTERFACE",
    col 120, "BATCH", row + 1,
    col 27, "MNEMONIC", col 36,
    "STATUS", col 46, "DATE",
    col 56, "DESCRIPTION", col 73,
    "STATUS", col 96, "TYPE",
    col 106, "STATUS", col 120,
    "NUM", row + 1, col 0,
    underline
   HEAD activitytypedisp
    row + 2, col 0, "ACTIVITY TYPE: ",
    col 15, activitytypedisp
   HEAD finnbr
    ordercount = ordercount
   DETAIL
    IF (((row+ 22) > maxrow))
     BREAK
    ENDIF
    ordercount = (ordercount+ 1), pageordercount = (pageordercount+ 1), row + 1,
    col 0, finnbr"#########", col 10,
    patientname"###############", col 27, ordermnemonic"##########"
    FOR (x = 1 TO size(orderstatusstruct->codevalue,5))
      IF ((orderstatusstruct->codevalue[x].code_value=orderstatus))
       col 36, orderstatusstruct->codevalue[x].display"############"
      ENDIF
    ENDFOR
    IF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].charge_item_id > 0))
     chargecount = (chargecount+ 1), pagechargecount = (pagechargecount+ 1), total = (total+ price),
     pagetotal = (pagetotal+ price), col 46, chargedate,
     col 56, ordersstruct->orders[d1.seq].charges_list[d2.seq].charge_description"###############"
     IF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].process_flg=0))
      col 73, "PENDING"
     ELSEIF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].process_flg=1))
      col 73, "SUSPENDED"
     ELSEIF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].process_flg=2))
      col 73, "REVIEW"
     ELSEIF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].process_flg=3))
      col 73, "ON HOLD"
     ELSEIF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].process_flg=4))
      col 73, "MANUAL"
     ELSEIF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].process_flg=5))
      col 73, "SKIPPED"
     ELSEIF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].process_flg=6))
      col 73, "COMBINED"
     ELSEIF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].process_flg=7))
      col 73, "ABSORBED"
     ELSEIF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].process_flg=8))
      col 73, "ABN"
     ELSEIF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].process_flg=10))
      col 73, "OFFSET"
     ELSEIF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].process_flg=11))
      col 73, "ADJUSTED"
     ELSEIF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].process_flg=12))
      col 73, "GROUPED"
     ELSEIF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].process_flg=777))
      col 73, "BUNDLED"
     ELSEIF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].process_flg=999))
      col 73, "INTERFACED"
     ELSEIF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].process_flg=997))
      col 73, "STATISTICS ONLY"
     ENDIF
     IF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].charge_type_cd=credittype))
      col 84, price"$-#####.##"
     ELSE
      col 84, price"$######.##"
     ENDIF
     FOR (x = 1 TO size(chargetypestruct->codevalue,5))
       IF ((chargetypestruct->codevalue[x].code_value=ordersstruct->orders[d1.seq].charges_list[d2
       .seq].charge_type_cd))
        col 96, chargetypestruct->codevalue[x].display"############"
       ENDIF
     ENDFOR
    ENDIF
    IF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].interface_charge[d3.seq].
    interface_charge_id > 0))
     IF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].interface_charge[d3.seq].ic_process_flg=
     999))
      interfacedchargecount = (interfacedchargecount+ 1), pageinterfacedchargecount = (
      pageinterfacedchargecount+ 1)
     ENDIF
     IF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].interface_charge[d3.seq].ic_process_flg=
     999))
      col 106, "INTERFACED"
     ELSEIF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].interface_charge[d3.seq].
     ic_process_flg=0))
      col 106, "PENDING"
     ELSEIF ((ordersstruct->orders[d1.seq].charges_list[d2.seq].interface_charge[d3.seq].
     ic_process_flg=998))
      col 106, "998"
     ENDIF
     col 120, batchnumber"#####"
    ENDIF
   FOOT  finnbr
    row + 2, col 36, "FINANCIAL NUMBER",
    col 53, finnbr"#########", col 71,
    "ORDER COUNT:", col 86, ordercount"########",
    ordercount = 0, row + 1, col 36,
    "FINANCIAL NUMBER", col 53, finnbr"#########",
    col 71, "Total:", col 84,
    total"$######.##", total = 0, row + 1,
    col 36, "FINANCIAL NUMBER", col 53,
    finnbr"#########", col 71, "CHARGE COUNT:",
    col 86, chargecount"########", chargecount = 0,
    row + 1, col 36, "FINANCIAL NUMBER",
    col 53, finnbr"#########", col 71,
    "INT CHG COUNT:", col 86, interfacedchargecount"########",
    interfacedchargecount = 0, firstfinnbr = 0
   FOOT  activitytype
    row + 2, col 55, activitytypedisp"####################",
    col 77, "Order Count:", col 90,
    pageordercount"#########", pageordercount = 0, row + 1,
    col 55, activitytypedisp"####################", col 77,
    "TOTAL:", col 84, pagetotal"$###########.##",
    pagetotal = 0, row + 1, col 55,
    activitytypedisp"####################", col 77, "Charge Count:",
    col 90, pagechargecount"#########", pagechargecount = 0,
    row + 1, col 55, activitytypedisp"####################",
    col 77, "Int Chg Count:", col 91,
    pageinterfacedchargecount"########", pageinterfacedchargecount = 0, BREAK
   WITH nocounter, landscape, maxrow = 66,
    outerjoin = d4, outerjoin = d5
  ;end select
  IF (trim(printer) != " ")
   SET com = concat("print/que=",trim(prtr_name)," ",value(file_name))
   CALL dcl(com,size(trim(com)),0)
  ENDIF
  FOR (i = 1 TO size(ordersstruct->orders,5))
    IF ((ordersstruct->orders[i].order_status_cd=ordered_code_value))
     IF (size(ordersstruct->orders[i].charges_list,5)=0)
      SET ordered_no_charge_qual = (ordered_no_charge_qual+ 1)
     ENDIF
    ENDIF
  ENDFOR
  FOR (i = 1 TO size(ordersstruct->orders,5))
    IF ((ordersstruct->orders[i].order_status_cd=completed_code_value))
     IF (size(ordersstruct->orders[i].charges_list,5)=0)
      SET completed_no_charge_qual = (completed_no_charge_qual+ 1)
     ENDIF
    ENDIF
  ENDFOR
  FOR (i = 1 TO size(ordersstruct->orders,5))
    IF ((ordersstruct->orders[i].order_status_cd != ordered_code_value))
     IF ((ordersstruct->orders[i].order_status_cd != completed_code_value))
      IF (size(ordersstruct->orders[i].charges_list,5)=0)
       SET other_no_charge_qual = (other_no_charge_qual+ 1)
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
  SELECT INTO value(file_name)
   count(*)
   FROM orders o
   WHERE o.updt_dt_tm > cnvtdatetime(begdate)
    AND o.updt_dt_tm < cnvtdatetime(enddate)
   HEAD REPORT
    asterik = fillstring(130,"*"), mainheading = "R E P O R T   T O T A L S", col 0,
    asterik, row + 1, col 50,
    mainheading, row + 1, col 0,
    asterik, row + 1
   DETAIL
    col 0, "ORDERS", row + 1,
    col 25, "Count", col 45,
    "Count w/No Charges", row + 1, col 25,
    "-----", col 45, "------------------",
    row + 1, col 10, "Ordered",
    col 24, ordered_qual"######", col 57,
    ordered_no_charge_qual"######", row + 1, col 10,
    "Completed", col 24, completed_qual"######",
    col 57, completed_no_charge_qual"######", row + 1,
    col 10, "Other", col 24,
    other_qual"######", col 57, other_no_charge_qual"######",
    row + 1, col 80, "Count",
    row + 1, col 80, "-----",
    row + 1, col 56, "GRAND TOTAL:",
    col 78, grandtotalorders"#######", row + 2,
    col 0, "CHARGES", row + 1,
    col 25, "Count", col 45,
    "Amount", row + 1, col 25,
    "-----", col 45, "------",
    row + 1, col 10, "Pending",
    col 24, number_of_pending_charges"######", col 41,
    amount_of_pending_charges"$######.##", row + 1, col 10,
    "Suspended", col 24, number_of_suspended_charges"######",
    col 41, amount_of_suspended_charges"$######.##", row + 1,
    col 10, "Held", col 24,
    number_of_held_charges"######", col 41, amount_of_held_charges"$######.##",
    row + 1, col 10, "Interfaced",
    col 24, number_of_interfaced_charges"######", col 41,
    amount_of_interfaced_charges"$######.##", row + 1, col 10,
    "Other", col 24, number_of_other_charges"######",
    col 41, amount_of_other_charges"$######.##", row + 1,
    col 80, "Count", col 95,
    "Amount", row + 1, col 80,
    "-----", col 95, "------",
    row + 1, col 56, "GRAND TOTAL:",
    col 78, grandtotalcharges"#######", col 92,
    grandtotalchargesamount"$######.##", row + 2, col 0,
    "INTERFACE CHARGES", row + 1, col 25,
    "Count", col 45, "Amount",
    row + 1, col 25, "-----",
    col 45, "------", row + 1,
    col 10, "Pending", col 24,
    number_pending_interface_charge"######", col 41, amount_pending_interface_charge"$######.##",
    row + 1, col 10, "Interfaced",
    col 24, number_interfaced_interface_charge"######", col 41,
    amount_interfaced_interface_charge"$######.##", row + 1, col 10,
    "Other", col 24, number_other_interface_charge"######",
    col 41, amount_other_interface_charge"$######.##", row + 1,
    col 80, "Count", col 95,
    "Amount", row + 1, col 80,
    "-----", col 95, "------",
    row + 1, col 56, "GRAND TOTAL:",
    col 78, grandtotalinterfacecharge"#######", col 92,
    grandtotalinterfacechargeamount"$#######.##", row + 2
   WITH nocounter
  ;end select
 ENDIF
END GO
