CREATE PROGRAM afc_rpt_orders:dba
 PAINT
 DECLARE afc_rpt_orders_version = vc
 SET afc_rpt_orders_version = "98372.FT.015"
 SET width = 132
 SET modify = system
 CALL clear(1,1)
 CALL video(n)
 CALL video(n)
 IF (validate(getcodevalue,char(128))=char(128))
  DECLARE getcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) = f8
 ENDIF
 IF (validate(s_cdf_meaning,char(128))=char(128))
  DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 ENDIF
 IF ((validate(s_code_value,- (0.00001))=- (0.00001)))
  DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 ENDIF
 DECLARE pa_table_name = vc WITH protect, noconstant("")
 SUBROUTINE getcodevalue(code_set,cdf_meaning,option_flag)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0.0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      SET pft_failed = uar_error
      EXECUTE pft_log "getcodevalue", pa_table_name, 0
      GO TO exit_script
     OF 1:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
     OF 2:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      EXECUTE pft_log "getcodevalue", pa_table_name, 3
     OF 3:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      CALL err_add_message(pa_table_name)
      SET pft_failed = uar_error
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE dpharmcreditcd = f8 WITH noconstant(getcodevalue(13028,"PHARMCR",0))
 DECLARE dpharmnochargecd = f8 WITH noconstant(getcodevalue(13028,"PHARMNC",0))
 DECLARE rpttitle = vc
 DECLARE rptbegindate = vc
 DECLARE rptenddate = vc
 DECLARE rptrundate = vc
 DECLARE rptpage = vc
 DECLARE hdrfinnum = vc
 DECLARE hdrordermnemonic = vc
 DECLARE hdrpatientname = vc
 DECLARE hdrorderstatus1 = vc
 DECLARE hdrservicedate1 = vc
 DECLARE hdrservicedate2 = vc
 DECLARE hdrcharge = vc
 DECLARE hdrchargedesc2 = vc
 DECLARE hdrprice = vc
 DECLARE hdrchargetype2 = vc
 DECLARE hdrinterfacestatus1 = vc
 DECLARE hdrstatus = vc
 DECLARE hdrbatchnum1 = vc
 DECLARE hdrbatchnum2 = vc
 DECLARE hdractivitytype = vc
 DECLARE hdrfinancialnumber = vc
 DECLARE hdrordercount = vc
 DECLARE hdrchargecount = vc
 DECLARE hdrchargetotal = vc
 DECLARE hdrintchargecnt = vc
 DECLARE dtlactivitytype = vc
 DECLARE dtlordermnemonic = vc
 DECLARE dtlorderstatus = vc
 DECLARE dtlchargedesc = vc
 DECLARE dtlchargestatus = vc
 DECLARE dtlchargetype = vc
 DECLARE dtlinterfacestatus = vc
 DECLARE dtlitemextndedprice = f8
 DECLARE srhdrrpttitle = vc
 DECLARE srhdrorders = vc
 DECLARE srhdrcharges = vc
 DECLARE srhdrinterfacedcharges = vc
 DECLARE srhdrgrandtotal = vc
 DECLARE srhdrcount = vc
 DECLARE srhdrcountnocharges = vc
 DECLARE srhdrordered = vc
 DECLARE srhdrcompleted = vc
 DECLARE srhdrother = vc
 DECLARE srhdrpending = vc
 DECLARE srhdrsuspended = vc
 DECLARE srhdrheld = vc
 DECLARE srhdrinterfaced = vc
 DECLARE srhdramount = vc
 DECLARE srhdrmanual = vc
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 FREE SET reply
 RECORD reply(
   1 t01_qual = i2
   1 t01_recs[*]
     2 t01_id = f8
     2 t01_charge_item_id = f8
     2 t01_interfaced = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 IF (validate(request->ops_date,999)=999)
  SET message = nowindow
  EXECUTE cclseclogin
 ENDIF
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
       3 service_dt_tm = f8
       3 interface_charge[*]
         4 interface_charge_id = f8
         4 ic_process_flg = i4
         4 ic_batch_num = f8
 )
 SET reply->status_data.status = "F"
 IF (validate(request->ops_date,999) != 999)
  IF ((request->ops_date > 0))
   SET begdate = datetimeadd(cnvtdatetime(curdate,0),- (1))
   SET enddate = datetimeadd(cnvtdatetime(curdate,235959),- (1))
   SET fbegdate = concat(format(datetimeadd(cnvtdatetime(curdate,0),- (1)),"DD-MMM-YYYY;;D")," 00:00"
    )
   SET fenddate = concat(format(datetimeadd(cnvtdatetime(curdate,235959),- (1)),"DD-MMM-YYYY;;D"),
    " 23:59")
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
  SET fbegdate = begdate
  SET fenddate = enddate
 ENDIF
 CALL text(7,4,"Processing....")
 SET printer = fillstring(100," ")
 IF (validate(request->output_dist," ") != " ")
  SET printer = request->output_dist
  SET printer = trim(printer)
 ENDIF
 IF (trim(printer) != " ")
  SET prtr_name = printer
 ELSE
  SET prtr_name = "MINE"
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
 SET number_of_manual_charges = 0
 SET amount_of_manual_charges = 0.0
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
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 SET codeset = 319
 SET cdf_meaning = "FIN NBR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,g_encounter_alias_fin_num)
 DECLARE credittype = f8
 SET codeset = 13028
 SET cdf_meaning = "CR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,credittype)
 DECLARE ordered_code_value = f8
 SET codeset = 6004
 SET cdf_meaning = "ORDERED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,ordered_code_value)
 DECLARE completed_code_value = f8
 SET codeset = 6004
 SET cdf_meaning = "COMPLETED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,completed_code_value)
 DECLARE ord_id = f8
 SET codeset = 13016
 SET cdf_meaning = "ORD ID"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,ord_id)
 SET count1 = 0
 SELECT INTO "nl:"
  o.activity_type_cd, o.order_id, o.order_status_cd,
  o.updt_dt_tm, p.name_full_formatted, ea.alias,
  c.charge_item_id
  FROM orders o,
   person p,
   encntr_alias ea,
   code_value cv
  PLAN (o
   WHERE o.updt_dt_tm BETWEEN cnvtdatetime(begdate) AND cnvtdatetime(enddate)
    AND o.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=o.activity_type_cd)
   JOIN (p
   WHERE o.person_id=p.person_id)
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(o.encntr_id)
    AND ea.encntr_alias_type_cd=outerjoin(g_encounter_alias_fin_num)
    AND ea.active_ind=outerjoin(1))
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
     AND c.order_id > 0
     AND c.charge_type_cd != dpharmnochargecd)
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
     ordersstruct->orders[d1.seq].charges_list[count2].service_dt_tm = c.service_dt_tm
     IF ( NOT (c.process_flg IN (7, 10, 177, 777, 977,
     996, 997)))
      IF (c.process_flg=0)
       number_of_pending_charges = (number_of_pending_charges+ 1), amount_of_pending_charges = (
       amount_of_pending_charges+ c.item_extended_price)
      ELSEIF (c.process_flg=1)
       number_of_suspended_charges = (number_of_suspended_charges+ 1), amount_of_suspended_charges =
       (amount_of_suspended_charges+ c.item_extended_price)
      ELSEIF (c.process_flg=3)
       number_of_held_charges = (number_of_held_charges+ 1), amount_of_held_charges = (
       amount_of_held_charges+ c.item_extended_price)
      ELSEIF (c.process_flg=999)
       number_of_interfaced_charges = (number_of_interfaced_charges+ 1), amount_of_interfaced_charges
        = (amount_of_interfaced_charges+ c.item_extended_price)
      ELSEIF (c.process_flg=4)
       number_of_manual_charges = (number_of_manual_charges+ 1), amount_of_manual_charges = (
       amount_of_manual_charges+ c.item_extended_price)
      ELSE
       number_of_other_charges = (number_of_other_charges+ 1), amount_of_other_charges = (
       amount_of_other_charges+ c.item_extended_price)
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter, outerjoin = d2
  ;end select
  SET grandtotalcharges = (((((number_of_pending_charges+ number_of_suspended_charges)+
  number_of_held_charges)+ number_of_interfaced_charges)+ number_of_manual_charges)+
  number_of_other_charges)
  SET grandtotalchargesamount = (((((amount_of_pending_charges+ amount_of_suspended_charges)+
  amount_of_held_charges)+ amount_of_interfaced_charges)+ amount_of_manual_charges)+
  amount_of_other_charges)
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
       IF ( NOT (ic.process_flg IN (7, 10, 177, 777, 977,
       996, 997)))
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
  SET rpttitle = uar_i18ngetmessage(i18nhandle,"k1","ORDERS TO CHARGES AUDIT")
  SET rptbegindate = uar_i18ngetmessage(i18nhandle,"k1","BEGIN DATE:")
  SET rptenddate = uar_i18ngetmessage(i18nhandle,"k1","END DATE:")
  SET rptrundate = uar_i18ngetmessage(i18nhandle,"k1","REPORT DATE:")
  SET rptpage = uar_i18ngetmessage(i18nhandle,"k1","PAGE:")
  SET hdrfinnum = uar_i18ngetmessage(i18nhandle,"k1","FIN")
  SET hdrordermnemonic = uar_i18ngetmessage(i18nhandle,"k1","ORDER MNEMONIC")
  SET hdrpatientname = uar_i18ngetmessage(i18nhandle,"k1","PATIENT NAME")
  SET hdrorderstatus1 = uar_i18ngetmessage(i18nhandle,"k1","ORDER")
  SET hdrstatus = uar_i18ngetmessage(i18nhandle,"k1","STATUS")
  SET hdrservicedate1 = uar_i18ngetmessage(i18nhandle,"k1","SERVICE")
  SET hdrservicedate2 = uar_i18ngetmessage(i18nhandle,"k1","DATE")
  SET hdrchargedesc2 = uar_i18ngetmessage(i18nhandle,"k1","DESCRIPTION")
  SET hdrcharge = uar_i18ngetmessage(i18nhandle,"k1","CHARGE")
  SET hdrprice = uar_i18ngetmessage(i18nhandle,"k1","PRICE")
  SET hdrchargetype2 = uar_i18ngetmessage(i18nhandle,"k1","TYPE")
  SET hdrinterfacestatus1 = uar_i18ngetmessage(i18nhandle,"k1","INTERFACE")
  SET hdrbatchnum1 = uar_i18ngetmessage(i18nhandle,"k1","BATCH")
  SET hdrbatchnum2 = uar_i18ngetmessage(i18nhandle,"k1","NUMBER")
  SET hdractivitytype = uar_i18ngetmessage(i18nhandle,"k1","ACTIVITY TYPE:")
  SET hdrfinancialnumber = uar_i18ngetmessage(i18nhandle,"k1","FINANCIAL NUMBER:")
  SET hdrordercount = uar_i18ngetmessage(i18nhandle,"k1","ORDER COUNT:")
  SET hdrchargecount = uar_i18ngetmessage(i18nhandle,"k1","CHARGE COUNT:")
  SET hdrchargetotal = uar_i18ngetmessage(i18nhandle,"k1","CHARGE TOTAL:")
  SET hdrintchargecnt = uar_i18ngetmessage(i18nhandle,"k1","INT CHG COUNT:")
  SELECT INTO value(prtr_name)
   finnbr = trim(ordersstruct->orders[d1.seq].e_financial_number), patientname = ordersstruct->
   orders[d1.seq].name_full_formatted, orderid = ordersstruct->orders[d1.seq].order_id,
   ordermnemonic = ordersstruct->orders[d1.seq].order_mnemonic, orderstatus = ordersstruct->orders[d1
   .seq].order_status_cd, activitytype = ordersstruct->orders[d1.seq].activity_type_cd,
   activitytypedisp = ordersstruct->orders[d1.seq].activity_type_disp, chargedate = format(
    ordersstruct->orders[d1.seq].charges_list[d2.seq].service_dt_tm,"DD-MMM-YY;;D"), price =
   ordersstruct->orders[d1.seq].charges_list[d2.seq].item_extended_price,
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
   ORDER BY activitytypedisp, finnbr, ordermnemonic
   HEAD REPORT
    todaysdate = concat(format(cnvtdatetime(curdate,curtime),"DD-MMM-YYYY;;D")), underline =
    fillstring(131,"="), row + 1,
    col 56, rpttitle, row + 1
   HEAD PAGE
    col 112, rptpage, col 119,
    curpage, row + 1, col 105,
    rptrundate, col 119, todaysdate,
    row + 1, col 0, rptbegindate,
    col 14, fbegdate, row + 1,
    col 0, rptenddate, col 14,
    fenddate, row + 1, col 0,
    underline, row + 1, col 0,
    hdrfinnum, col 28, hdrpatientname,
    row + 1, col 2, hdrordermnemonic,
    row + 1, col 4, hdrorderstatus1,
    col 18, hdrservicedate1, col 28,
    hdrcharge, col 72, hdrcharge,
    col 97, hdrcharge, col 108,
    hdrinterfacestatus1, col 123, hdrbatchnum1,
    row + 1, col 4, hdrstatus,
    col 18, hdrservicedate2, col 28,
    hdrchargedesc2, col 72, hdrstatus,
    col 88, hdrprice, col 97,
    hdrchargetype2, col 108, hdrstatus,
    col 123, hdrbatchnum2, row + 1,
    col 0, underline, row + 1
   HEAD activitytypedisp
    col 0, hdractivitytype, dtlactivitytype = uar_i18ngetmessage(i18nhandle,"k1",nullterm(trim(
       activitytypedisp))),
    col 16, dtlactivitytype"########################################", row + 1
   HEAD finnbr
    row + 1, col 0, finnbr"####################",
    col 28, patientname"##################################################"
   HEAD ordermnemonic
    ordercount = (ordercount+ 1), pageordercount = (pageordercount+ 1), row + 1,
    dtlordermnemonic = uar_i18ngetmessage(i18nhandle,"k1",nullterm(trim(ordermnemonic))), col 2,
    dtlordermnemonic"##################################################",
    row + 1
    FOR (x = 1 TO size(orderstatusstruct->codevalue,5))
      IF ((orderstatusstruct->codevalue[x].code_value=orderstatus))
       dtlorderstatus = uar_i18ngetmessage(i18nhandle,"k1",nullterm(trim(orderstatusstruct->
          codevalue[x].display))), col 4, dtlorderstatus"#############"
      ENDIF
    ENDFOR
    FOR (chargecnt = 1 TO size(ordersstruct->orders[d1.seq].charges_list,5))
      IF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].charge_item_id > 0))
       IF ( NOT ((ordersstruct->orders[d1.seq].charges_list[chargecnt].process_flg IN (7, 10, 177,
       777, 977,
       996, 997))))
        chargecount = (chargecount+ 1), pagechargecount = (pagechargecount+ 1), total = (total+
        ordersstruct->orders[d1.seq].charges_list[chargecnt].item_extended_price),
        pagetotal = (pagetotal+ ordersstruct->orders[d1.seq].charges_list[chargecnt].
        item_extended_price)
       ENDIF
       col 18, chargedate, dtlchargedesc = uar_i18ngetmessage(i18nhandle,"k1",nullterm(trim(
          ordersstruct->orders[d1.seq].charges_list[chargecnt].charge_description))),
       col 28, dtlchargedesc"############################################"
       IF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].process_flg=0))
        dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","PENDING"), col 72, dtlchargestatus
        "#############"
       ELSEIF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].process_flg=1))
        dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","SUSPENDED"), col 72, dtlchargestatus
        "#############"
       ELSEIF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].process_flg=2))
        dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","REVIEW"), col 72, dtlchargestatus
        "#############"
       ELSEIF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].process_flg=3))
        dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","ON HOLD"), col 72, dtlchargestatus
        "#############"
       ELSEIF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].process_flg=4))
        dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","MANUAL"), col 72, dtlchargestatus
        "#############"
       ELSEIF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].process_flg=5))
        dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","SKIPPED"), col 72, dtlchargestatus
        "#############"
       ELSEIF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].process_flg=6))
        dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","COMBINED"), col 72, dtlchargestatus
        "#############"
       ELSEIF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].process_flg=7))
        dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","ABSORBED"), col 72, dtlchargestatus
        "#############"
       ELSEIF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].process_flg=8))
        dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","ABN"), col 72, dtlchargestatus
        "#############"
       ELSEIF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].process_flg=10))
        dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","OFFSET"), col 72, dtlchargestatus
        "#############"
       ELSEIF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].process_flg=11))
        dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","ADJUSTED"), col 72, dtlchargestatus
        "#############"
       ELSEIF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].process_flg=12))
        dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","GROUPED"), col 72, dtlchargestatus
        "#############"
       ELSEIF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].process_flg=777))
        dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","BUNDLED"), col 72, dtlchargestatus
        "#############"
       ELSEIF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].process_flg=999))
        dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","INTERFACED"), col 72, dtlchargestatus
        "#############"
       ELSEIF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].process_flg=997))
        dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","STATS ONLY"), col 72, dtlchargestatus
        "#############"
       ELSEIF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].process_flg=100))
        dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","POSTED"), col 72, dtlchargestatus
        "#############"
       ELSEIF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].process_flg=177))
        dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","BNDLD-PROFIT"), col 72, dtlchargestatus
        "#############"
       ELSEIF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].process_flg=977))
        dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","BNDLD-INTRFCD"), col 72,
        dtlchargestatus"#############"
       ELSEIF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].process_flg=996))
        dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","OMFSTATSONLY"), col 72, dtlchargestatus
        "#############"
       ENDIF
       IF ((((ordersstruct->orders[d1.seq].charges_list[chargecnt].charge_type_cd=credittype)) OR ((
       ordersstruct->orders[d1.seq].charges_list[chargecnt].charge_type_cd=dpharmcreditcd)))
        AND ((dtlitemextndedprice=ordersstruct->orders[d1.seq].charges_list[chargecnt].
       item_extended_price) != 0))
        dtlitemextndedprice = (abs(ordersstruct->orders[d1.seq].charges_list[chargecnt].
         item_extended_price) * - (1))
       ELSE
        dtlitemextndedprice = ordersstruct->orders[d1.seq].charges_list[chargecnt].
        item_extended_price
       ENDIF
       col 86, dtlitemextndedprice"#######.##"
       FOR (x = 1 TO size(chargetypestruct->codevalue,5))
         IF ((chargetypestruct->codevalue[x].code_value=ordersstruct->orders[d1.seq].charges_list[
         chargecnt].charge_type_cd))
          dtlchargetype = uar_i18ngetmessage(i18nhandle,"k1",nullterm(trim(chargetypestruct->
             codevalue[x].display))), col 97, dtlchargetype"##########"
         ENDIF
       ENDFOR
      ENDIF
      FOR (interfacechargecnt = 1 TO size(ordersstruct->orders[d1.seq].charges_list[chargecnt].
       interface_charge,5))
        IF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].interface_charge[interfacechargecnt
        ].interface_charge_id > 0))
         IF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].interface_charge[
         interfacechargecnt].ic_process_flg=999))
          interfacedchargecount = (interfacedchargecount+ 1), pageinterfacedchargecount = (
          pageinterfacedchargecount+ 1)
         ENDIF
         IF ((ordersstruct->orders[d1.seq].charges_list[chargecnt].interface_charge[
         interfacechargecnt].ic_process_flg=999))
          dtlinterfacestatus = uar_i18ngetmessage(i18nhandle,"k1","INTERFACED"), col 108,
          dtlinterfacestatus
         ENDIF
         col 121, ordersstruct->orders[d1.seq].charges_list[chargecnt].interface_charge[
         interfacechargecnt].ic_batch_num"##########"
        ENDIF
      ENDFOR
      row + 1
    ENDFOR
   FOOT  finnbr
    row + 2, col 41, hdrfinancialnumber,
    col 59, finnbr"####################", col 80,
    hdrordercount, col 95, ordercount"##########",
    ordercount = 0, row + 1, col 80,
    hdrchargecount, col 95, chargecount"##########",
    chargecount = 0, row + 1, col 80,
    hdrchargetotal, col 95, total"#######.##",
    total = 0, row + 1, col 80,
    hdrintchargecnt, col 95, interfacedchargecount"##########",
    interfacedchargecount = 0, firstfinnbr = 0, row + 1
   FOOT  activitytypedisp
    row + 2, col 48, dtlactivitytype"########################################",
    col 89, hdrordercount, col 104,
    pageordercount"##########", pageordercount = 0, row + 1,
    col 89, hdrchargecount, col 104,
    pagechargecount"##########", pagechargecount = 0, row + 1,
    col 89, hdrchargetotal, col 104,
    pagetotal"#######.##", pagetotal = 0, row + 1,
    col 89, hdrintchargecnt, col 104,
    pageinterfacedchargecount"##########", pageinterfacedchargecount = 0
   WITH nocounter, compress, landscape,
    maxrow = 45, maxcol = 180, outerjoin = d4,
    outerjoin = d5
  ;end select
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
  SET srhdrrpttitle = uar_i18ngetmessage(i18nhandle,"k1","ORDERS TO CHARGES AUDIT REPORT TOTALS")
  SET srhdrorders = uar_i18ngetmessage(i18nhandle,"k1","ORDERS")
  SET srhdrcharges = uar_i18ngetmessage(i18nhandle,"k1","CHARGES")
  SET srhdrinterfacedcharges = uar_i18ngetmessage(i18nhandle,"k1","INTERFACED CHARGES")
  SET srhdrgrandtotal = uar_i18ngetmessage(i18nhandle,"k1","GRAND TOTAL:")
  SET srhdrcount = uar_i18ngetmessage(i18nhandle,"k1","Count")
  SET srhdrcountnocharges = uar_i18ngetmessage(i18nhandle,"k1","Count with no charges")
  SET srhdrordered = uar_i18ngetmessage(i18nhandle,"k1","Ordered")
  SET srhdrcompleted = uar_i18ngetmessage(i18nhandle,"k1","Completed")
  SET srhdrother = uar_i18ngetmessage(i18nhandle,"k1","Other")
  SET srhdrpending = uar_i18ngetmessage(i18nhandle,"k1","Pending")
  SET srhdrsuspended = uar_i18ngetmessage(i18nhandle,"k1","Suspended")
  SET srhdrheld = uar_i18ngetmessage(i18nhandle,"k1","Held")
  SET srhdrinterfaced = uar_i18ngetmessage(i18nhandle,"k1","Interfaced")
  SET srhdramount = uar_i18ngetmessage(i18nhandle,"k1","Amount")
  SET srhdrmanual = uar_i18ngetmessage(i18nhandle,"k1","Manual")
  SELECT INTO value(prtr_name)
   count(*)
   FROM orders o
   WHERE o.updt_dt_tm > cnvtdatetime(begdate)
    AND o.updt_dt_tm < cnvtdatetime(enddate)
   HEAD REPORT
    row + 1, col 50, srhdrrpttitle,
    row + 2
   DETAIL
    row + 1, col 10, srhdrorders,
    row + 1, col 39, srhdrcount,
    col 59, srhdrcountnocharges, row + 1,
    col 39, "-----", col 59,
    "---------------------", row + 1, col 20,
    srhdrordered, col 34, ordered_qual"##########",
    col 70, ordered_no_charge_qual"##########", row + 1,
    col 20, srhdrcompleted, col 34,
    completed_qual"##########", col 70, completed_no_charge_qual"##########",
    row + 1, col 20, srhdrother,
    col 34, other_qual"##########", col 70,
    other_no_charge_qual"##########", row + 1, col 90,
    srhdrcount, row + 1, col 90,
    "-----", row + 1, col 71,
    srhdrgrandtotal, col 85, grandtotalorders"##########",
    row + 2, col 10, srhdrcharges,
    row + 1, col 39, srhdrcount,
    col 64, srhdramount, row + 1,
    col 39, "-----", col 64,
    "------", row + 1, col 20,
    srhdrpending, col 34, number_of_pending_charges"##########",
    col 58, amount_of_pending_charges"#########.##", row + 1,
    col 20, srhdrsuspended, col 34,
    number_of_suspended_charges"##########", col 58, amount_of_suspended_charges"#########.##",
    row + 1, col 20, srhdrheld,
    col 34, number_of_held_charges"##########", col 58,
    amount_of_held_charges"#########.##", row + 1, col 20,
    srhdrinterfaced, col 34, number_of_interfaced_charges"##########",
    col 58, amount_of_interfaced_charges"#########.##", row + 1,
    col 20, srhdrmanual, col 34,
    number_of_manual_charges"##########", col 58, amount_of_manual_charges"#########.##",
    row + 1, col 20, srhdrother,
    col 34, number_of_other_charges"##########", col 58,
    amount_of_other_charges"#########.##", row + 1, col 90,
    srhdrcount, col 105, srhdramount,
    row + 1, col 90, "-----",
    col 105, "------", row + 1,
    col 71, srhdrgrandtotal, col 85,
    grandtotalcharges"##########", col 99, grandtotalchargesamount"#########.##",
    row + 2, col 10, srhdrinterfacedcharges,
    row + 1, col 39, srhdrcount,
    col 64, srhdramount, row + 1,
    col 39, "-----", col 64,
    "------", row + 1, col 20,
    srhdrpending, col 34, number_pending_interface_charge"##########",
    col 58, amount_pending_interface_charge"#########.##", row + 1,
    col 20, srhdrinterfaced, col 34,
    number_interfaced_interface_charge"##########", col 58, amount_interfaced_interface_charge
    "#########.##",
    row + 1, col 20, srhdrother,
    col 34, number_other_interface_charge"##########", col 58,
    amount_other_interface_charge"#########.##", row + 1, col 90,
    srhdrcount, col 105, srhdramount,
    row + 1, col 90, "-----",
    col 105, "------", row + 1,
    col 71, srhdrgrandtotal, col 85,
    grandtotalinterfacecharge"##########", col 99, grandtotalinterfacechargeamount"#########.##",
    row + 2
   WITH nocounter, compress, landscape,
    maxrow = 60, maxcol = 132
  ;end select
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  CALL text(9,4,"No orders qualified")
 ENDIF
END GO
