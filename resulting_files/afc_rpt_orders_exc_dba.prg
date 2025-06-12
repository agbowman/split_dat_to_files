CREATE PROGRAM afc_rpt_orders_exc:dba
 PAINT
 SET width = 132
 SET modify = system
 CALL clear(1,1)
 CALL video(n)
 CALL video(n)
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
     2 order_mnemonic = c100
     2 updt_dt_tm = dq8
     2 name_full_formatted = c25
     2 person_id = f8
     2 encntr_id = f8
     2 foundce = i2
     2 foundcea = i2
     2 foundc = i2
     2 foundb = i2
     2 charge_event_list[*]
       3 charge_event_id = f8
       3 ext_m_reference_id = f8
       3 ext_m_reference_cont_cd = f8
 )
 SET reply->status_data.status = "F"
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
  SET begdate = cnvtdatetime(curaccept)
  CALL accept(5,29,"nndpppdnnnndnndnn;cs",format(curdate,"dd-mmm-yyyy hh:mm;;d")
   WHERE format(cnvtdatetime(curaccept),"dd-mmm-yyyy hh:mm;;d")=cnvtupper(curaccept))
  SET enddate = cnvtdatetime(curaccept)
 ENDIF
 CALL text(7,4,"Processing.")
 SET printer = fillstring(100," ")
 IF (validate(request->output_dist," ") != " ")
  SET printer = request->output_dist
  SET printer = trim(printer)
 ENDIF
 IF (trim(printer) != " ")
  SET prtr_name = printer
  SET file_name = "ccluserdir:afc_rpt_ordexc.dat"
 ELSE
  SET prtr_name = "FILE"
  SET file_name = "MINE"
  SET summary_file_name = "FILE"
 ENDIF
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE iret = i4
 DECLARE completed_code_value = f8
 SET codeset = 6004
 SET cdf_meaning = "COMPLETED"
 SET cnt = 1
 SET iret = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,completed_code_value)
 DECLARE 13019_chargepoint = f8
 SET codeset = 13019
 SET cdf_meaning = "CHARGE POINT"
 SET cnt = 1
 SET iret = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,13019_chargepoint)
 DECLARE 13020_null = f8
 SET codeset = 13020
 SET cdf_meaning = "NULL"
 SET cnt = 1
 SET iret = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,13020_null)
 DECLARE 13029_clear = f8
 SET codeset = 13029
 SET cdf_meaning = "CLEAR"
 SET cnt = 1
 SET iret = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,13029_clear)
 CALL text(7,4,"Processing orders...............")
 SET count1 = 0
 SELECT INTO "nl:"
  o.activity_type_cd, o.order_id, o.order_status_cd,
  o.updt_dt_tm
  FROM orders o
  WHERE o.updt_dt_tm BETWEEN cnvtdatetime(begdate) AND cnvtdatetime(enddate)
   AND o.active_ind=1
   AND ((o.order_status_cd+ 0)=completed_code_value)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(ordersstruct->orders,count1), ordersstruct->orders[count1].
   order_id = o.order_id,
   ordersstruct->orders[count1].updt_dt_tm = o.updt_dt_tm, ordersstruct->orders[count1].
   order_mnemonic = o.order_mnemonic, ordersstruct->orders[count1].order_status_cd = o
   .order_status_cd,
   ordersstruct->orders[count1].person_id = o.person_id, ordersstruct->orders[count1].encntr_id = o
   .encntr_id
  WITH nocounter
 ;end select
 IF (size(ordersstruct->orders,5) > 0)
  CALL text(7,4,"Processing charge events........")
  SET count2 = 0
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(ordersstruct->orders,5))),
    charge_event ce,
    charge_event_act cea
   PLAN (d1)
    JOIN (ce
    WHERE (ce.ext_m_event_id=ordersstruct->orders[d1.seq].order_id)
     AND ce.ext_p_event_id=0
     AND (ce.ext_i_event_id=ordersstruct->orders[d1.seq].order_id))
    JOIN (cea
    WHERE cea.charge_event_id=outerjoin(ce.charge_event_id))
   HEAD ce.ext_m_event_id
    count2 = 0
   DETAIL
    ordersstruct->orders[d1.seq].foundce = 1, count2 = (count2+ 1), stat = alterlist(ordersstruct->
     orders[d1.seq].charge_event_list,count2),
    ordersstruct->orders[d1.seq].charge_event_list[count2].charge_event_id = ce.charge_event_id,
    ordersstruct->orders[d1.seq].charge_event_list[count2].ext_m_reference_id = ce.ext_m_reference_id,
    ordersstruct->orders[d1.seq].charge_event_list[count2].ext_m_reference_cont_cd = ce
    .ext_m_reference_cont_cd
    IF (cea.charge_event_act_id > 0)
     ordersstruct->orders[d1.seq].foundcea = 1
    ENDIF
   WITH nocounter
  ;end select
  CALL text(7,4,"Processing charges..............")
  SET count2 = 0
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(ordersstruct->orders,5))),
    charge c
   PLAN (d1
    WHERE (ordersstruct->orders[d1.seq].foundce=1)
     AND (ordersstruct->orders[d1.seq].foundcea=1))
    JOIN (c
    WHERE c.charge_event_id IN (
    (SELECT
     ce.charge_event_id
     FROM charge_event ce
     WHERE (ce.ext_m_event_id=ordersstruct->orders[d1.seq].order_id)))
     AND c.active_ind=1)
   DETAIL
    ordersstruct->orders[d1.seq].foundc = 1
   WITH nocounter
  ;end select
  CALL text(7,4,"Processing bill item modifiers......")
  SET count2 = 0
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(ordersstruct->orders,5))),
    (dummyt d2  WITH seq = 1),
    bill_item b,
    bill_item_modifier bim
   PLAN (d1
    WHERE maxrec(d2,size(ordersstruct->orders[d1.seq].charge_event_list,5)))
    JOIN (d2)
    JOIN (b
    WHERE (b.ext_parent_reference_id=ordersstruct->orders[d1.seq].charge_event_list[d2.seq].
    ext_m_reference_id)
     AND (b.ext_parent_contributor_cd=ordersstruct->orders[d1.seq].charge_event_list[d2.seq].
    ext_m_reference_cont_cd)
     AND b.ext_child_reference_id=0)
    JOIN (bim
    WHERE bim.bill_item_id=b.bill_item_id
     AND bim.bill_item_type_cd=13019_chargepoint
     AND bim.active_ind=1
     AND bim.key4_id != 13020_null)
   DETAIL
    ordersstruct->orders[d1.seq].foundb = 1
   WITH nocounter
  ;end select
  CALL echorecord(ordersstruct,"ccluserdir:ddsexc.dat")
  CALL text(7,4,"Building report....")
  SET firsttime = 1
  SET pagenum = 0
  SET pagetotal = 0.0
  SELECT INTO value(file_name)
   personname = p.name_full_formatted, encntrid = ordersstruct->orders[d1.seq].encntr_id, orderid =
   ordersstruct->orders[d1.seq].order_id,
   ordermnemonic = ordersstruct->orders[d1.seq].order_mnemonic, orderstatus = uar_get_code_display(
    ordersstruct->orders[d1.seq].order_status_cd)
   FROM (dummyt d1  WITH seq = value(size(ordersstruct->orders,5))),
    person p
   PLAN (d1
    WHERE (((ordersstruct->orders[d1.seq].foundb=1)
     AND (ordersstruct->orders[d1.seq].foundc != 1)) OR ((((ordersstruct->orders[d1.seq].foundce != 1
    )) OR ((ordersstruct->orders[d1.seq].foundcea != 1))) )) )
    JOIN (p
    WHERE (p.person_id=ordersstruct->orders[d1.seq].person_id))
   ORDER BY orderid
   HEAD REPORT
    mainheading = "O R D E R S  E X C E P T I O N  A U D I T", todaysdate = concat(format(
      cnvtdatetime(curdate,curtime),"DD-MMM-YYYY;;D")), underline = fillstring(125,"-"),
    col 0, "Date: ", col 6,
    todaysdate, col 44, mainheading,
    col 116, "Page:  1 ", row + 2,
    col 0, "Begin Date: ", col 12,
    begdate"dd-mmm-yyyy hh:mm;;d", row + 1, col 0,
    "End Date: ", col 10, enddate"dd-mmm-yyyy hh:mm;;d",
    row + 2
   HEAD PAGE
    pagenum = (pagenum+ 1)
    IF (firsttime=0)
     col 116, "Page:", col 124,
     pagenum"##", row + 2
    ENDIF
    firsttime = 0, col 0, "PATIENT NAME",
    col 22, "ENCNTR ID", col 37,
    "ORDER ID", col 50, "ORDER",
    col 80, "ORDER", col 95,
    "MISSING", col 105, "MISSING",
    row + 1, col 50, "MNEMONIC",
    col 80, "STATUS", col 95,
    "EVENT", col 105, "CHARGE",
    row + 1, col 0, underline
   HEAD orderid
    row + 1, col 0, personname"####################",
    col 22, encntrid"##########", col 37,
    orderid"##########", col 50, ordermnemonic"############################",
    col 80, orderstatus"##########"
   DETAIL
    IF ((ordersstruct->orders[d1.seq].foundce != 1))
     col 98, "X"
    ELSEIF ((ordersstruct->orders[d1.seq].foundcea != 1))
     col 98, "X"
    ENDIF
    IF ((ordersstruct->orders[d1.seq].foundc != 1)
     AND (ordersstruct->orders[d1.seq].foundb=1))
     col 108, "X"
    ENDIF
   WITH nocounter, landscape, maxrow = 65
  ;end select
  IF (trim(printer) != " ")
   SET com = concat("print/que=",trim(prtr_name)," ",value(file_name))
   CALL dcl(com,size(trim(com)),0)
  ENDIF
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
