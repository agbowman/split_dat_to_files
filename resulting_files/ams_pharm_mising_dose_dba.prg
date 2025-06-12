CREATE PROGRAM ams_pharm_mising_dose:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH outdev, sdate, edate
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET exe_error = 10
 SET failed = false
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE RECORD rprt
 RECORD rprt(
   1 qual[*]
     2 name = vc
     2 nurse_unit = vc
     2 order_name = vc
     2 order_id_sec = f8
     2 orders[*]
       3 order_id = f8
       3 date_tm = dq8
       3 tot_dispense = i4
       3 administered = i4
       3 not_administered = i4
       3 credited_dose = i4
 )
 DECLARE dcpgenericcode_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"DCPGENERICCODE")),
 protect
 DECLARE count = i4 WITH noconstant(0), protect
 DECLARE indx = i4 WITH noconstant(0), protect
 DECLARE temp = i4 WITH noconstant(0), protect
 DECLARE sample = i4 WITH noconstant(0), protect
 DECLARE temp2 = i4 WITH noconstant(0), protect
 DECLARE index = i4
 SELECT INTO "nl:"
  c.event_tag, c.result_val, ord.order_id,
  c.order_id, ord.template_order_id, e_loc_nurse_unit_disp = uar_get_code_display(e.loc_nurse_unit_cd
   ),
  p.name_full_formatted, ord_catalog_disp = uar_get_code_display(ord.catalog_cd), order_date = format
  (c.event_end_dt_tm,"dd/mm/yyyy;;Q")
  FROM order_dispense o,
   orders ord,
   clinical_event c,
   person p,
   encounter e
  PLAN (o
   WHERE o.next_dispense_dt_tm BETWEEN cnvtdatetime(cnvtdate( $SDATE),0) AND cnvtdatetime(cnvtdate(
      $EDATE),2359)
    AND o.order_id != 0)
   JOIN (ord
   WHERE o.order_id=ord.template_order_id)
   JOIN (c
   WHERE outerjoin(ord.order_id)=c.order_id
    AND c.event_cd != outerjoin(dcpgenericcode_var))
   JOIN (e
   WHERE o.encntr_id=e.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY o.order_id, order_date, c.order_id
  HEAD o.order_id
   indx = (indx+ 1)
   IF (mod(indx,10)=1)
    stat = alterlist(rprt->qual,(indx+ 9))
   ENDIF
   rprt->qual[indx].name = trim(p.name_full_formatted), rprt->qual[indx].nurse_unit =
   e_loc_nurse_unit_disp, rprt->qual[indx].order_name = ord_catalog_disp,
   rprt->qual[indx].order_id_sec = o.order_id
  HEAD order_date
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(rprt->qual[indx].orders,(count+ 9))
   ENDIF
   temp = count, rprt->qual[indx].orders[count].administered = 0, rprt->qual[indx].orders[count].
   not_administered = 0
   IF (c.event_end_dt_tm != null)
    rprt->qual[indx].orders[count].date_tm = c.event_end_dt_tm
   ELSE
    rprt->qual[indx].orders[count].date_tm = o.next_dispense_dt_tm
   ENDIF
   rprt->qual[indx].orders[count].order_id = o.order_id
  HEAD c.order_id
   IF (c.event_tag != "Not Given*"
    AND c.event_tag_set_flag=1)
    rprt->qual[indx].orders[count].administered = (rprt->qual[indx].orders[count].administered+ 1)
   ELSEIF (c.event_tag_set_flag=1)
    rprt->qual[indx].orders[count].not_administered = (rprt->qual[indx].orders[count].
    not_administered+ 1)
   ENDIF
  FOOT  o.order_id
   stat = alterlist(rprt->qual[indx].orders,count), count = 0
  FOOT REPORT
   stat = alterlist(rprt->qual,indx)
  WITH nocounter, separator = " ", format
 ;end select
 SELECT INTO "nl:"
  dispense_dt = format(hx.dispense_dt_tm,"dd/mm/yyyy;;Q")
  FROM dispense_hx hx,
   order_dispense od
  PLAN (od
   WHERE od.next_dispense_dt_tm BETWEEN cnvtdatetime(cnvtdate( $SDATE),0) AND cnvtdatetime(cnvtdate(
      $EDATE),2359)
    AND od.order_id != 0)
   JOIN (hx
   WHERE od.order_id=hx.order_id)
  ORDER BY hx.order_id, dispense_dt DESC
  HEAD hx.order_id
   null
  HEAD dispense_dt
   temp = 0, temp2 = 0
  DETAIL
   CALL echo(build("Doses : ",hx.doses))
   IF (hx.disp_event_type_cd=638940.00)
    temp2 = (temp2+ hx.doses)
   ELSE
    temp = (hx.doses+ temp)
   ENDIF
  FOOT  dispense_dt
   index = locateval(sample,1,size(rprt->qual,5),hx.order_id,rprt->qual[sample].order_id_sec)
   IF (index != 0)
    eval = locateval(count,1,size(rprt->qual[index].orders,5),dispense_dt,format(rprt->qual[index].
      orders[count].date_tm,"dd/mm/yyyy;;Q"))
    IF (eval != 0)
     rprt->qual[index].orders[eval].tot_dispense = temp, rprt->qual[index].orders[eval].credited_dose
      = temp2
    ELSE
     stat = alterlist(rprt->qual[index].orders,(size(rprt->qual[index].orders,5)+ 1)), rprt->qual[
     index].orders[size(rprt->qual[index].orders,5)].credited_dose = temp2, rprt->qual[index].orders[
     size(rprt->qual[index].orders,5)].tot_dispense = temp,
     rprt->qual[index].orders[size(rprt->qual[index].orders,5)].date_tm = hx.dispense_dt_tm
    ENDIF
   ENDIF
  FOOT  hx.order_id
   null
  WITH nocounter, separator = " ", format
 ;end select
 SELECT INTO  $1
  name = substring(1,30,rprt->qual[d1.seq].name), nurse_unit = substring(1,30,rprt->qual[d1.seq].
   nurse_unit), order_name = substring(1,30,rprt->qual[d1.seq].order_name),
  order_id_sec = rprt->qual[d1.seq].order_id_sec, date_tm = format(rprt->qual[d1.seq].orders[d2.seq].
   date_tm,"dd/mm/yyyy;;Q"), tot_dispense = rprt->qual[d1.seq].orders[d2.seq].tot_dispense,
  administered = rprt->qual[d1.seq].orders[d2.seq].administered, orders_not_administered = rprt->
  qual[d1.seq].orders[d2.seq].not_administered, credited_doses = rprt->qual[d1.seq].orders[d2.seq].
  credited_dose
  FROM (dummyt d1  WITH seq = value(size(rprt->qual,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(rprt->qual[d1.seq].orders,5)))
   JOIN (d2)
  WITH nocounter, separator = " ", format
 ;end select
 CALL updtdminfo(trim(cnvtupper(curprog),3))
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 SET last_mode = "001 12/15/14 kk032244 initial release"
END GO
