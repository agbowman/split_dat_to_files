CREATE PROGRAM bhs_rpt_echo_time_of_order_2:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Patient Type" = 0,
  "From Date" = "CURDATE",
  "To Date" = "CURDATE"
  WITH outdev, patienttype, fromdate,
  todate
 SET from_date = cnvtdatetime(concat( $FROMDATE," 00:00:00"))
 SET to_date = cnvtdatetime(concat( $TODATE," 23:59:59"))
 DECLARE date = dq8 WITH protect, constant(sysdate)
 DECLARE admitdate = dq8
 DECLARE dischargedate = dq8
 DECLARE orderdate = dq8
 DECLARE ordertime = dq8
 DECLARE datetimecharted = dq8
 DECLARE prodate = dq8
 DECLARE cntorders = i4
 DECLARE ms_weekday = vc WITH noconstant(" ")
 SET patienttype1 = cnvtint( $PATIENTTYPE)
 SET observation = uar_get_code_by("displaykey",71,"OBSERVATION")
 SET disch_obv = uar_get_code_by("displaykey",71,"DISCHOBV")
 SET expired_obv = uar_get_code_by("displaykey",71,"EXPIREDOBV")
 SET inpatient = uar_get_code_by("displaykey",71,"INPATIENT")
 SET preadmit_ip = uar_get_code_by("displaykey",71,"PREADMITIP")
 SET disch_ip = uar_get_code_by("displaykey",71,"DISCHIP")
 SET expired_ip = uar_get_code_by("displaykey",71,"EXPIREDIP")
 SET emergency = uar_get_code_by("displaykey",71,"EMERGENCY")
 SET disch_es = uar_get_code_by("displaykey",71,"DISCHES")
 SET expired_es = uar_get_code_by("displaykey",71,"EXPIREDES")
 SET outpatient = uar_get_code_by("displaykey",71,"OUTPATIENT")
 SET onetime_op = uar_get_code_by("displaykey",71,"ONETIMEOP")
 SET recurring_op = uar_get_code_by("displaykey",71,"RECURRINGOP")
 SET disch_recurring_op = uar_get_code_by("displaykey",71,"DISCHRECURRINGOP")
 SET preadmint_daystay = uar_get_code_by("displaykey",71,"PREADMITDAYSTAY")
 SET reactivate = uar_get_code_by("displaykey",71,"REACTIVITE")
 SET disch_daystay = uar_get_code_by("displaykey",71,"DISCHDAYSTAY")
 SET daystay = uar_get_code_by("displaykey",71,"DAYSTAY")
 SET j_doe = uar_get_code_by("displaykey",71,"JDOE")
 SET pre_outpt = uar_get_code_by("displaykey",71,"PREOUTPT")
 SET expired_daystay = uar_get_code_by("displaykey",71,"EXPIREDDAYSTAY")
 SET triage = uar_get_code_by("displaykey",71,"TRIAGE")
 SET office_visit = uar_get_code_by("displaykey",71,"OFFICEVISIT")
 SET preoffice_visit = uar_get_code_by("displaykey",71,"PREOFFICEVISIT")
 SET recur_office_visit = uar_get_code_by("displaykey",71,"RECUROFFICEVISIT")
 SET prerecur_office_visit = uar_get_code_by("displaykey",71,"PRERECUROFFICEVISIT")
 SET disch_recur_office_visit = uar_get_code_by("displaykey",71,"DISCHRECUROFFICEVISIT")
 SET vnh = uar_get_code_by("displaykey",71,"VNH")
 SET disch_vnh = uar_get_code_by("displaykey",71,"DISCHVNH")
 SET active_vnh = uar_get_code_by("displaykey",71,"ACTIVEVNH")
 SET active_cmty_office_visit = uar_get_code_by("displaykey",71,"ACTIVECMTYOFFICEVISIT")
 SET pre_cmty_office_visit = uar_get_code_by("displaykey",71,"PRECMTYOFFICEVISIT")
 SET outpatient_onetime = uar_get_code_by("displaykey",71,"OUTPATIENTONETIME")
 SET pre_outpatient_onetime = uar_get_code_by("displaykey",71,"PREOUTPATIENTONETIME")
 SET outpatient_recurring = uar_get_code_by("displaykey",71,"OUTPATIENTONETIME")
 SET discharged_outpatient = uar_get_code_by("displaykey",71,"DISCHARGEDOUTPATIENT")
 SET smri = uar_get_code_by("displaykey",71,"SMRI")
 FREE RECORD event
 RECORD event(
   1 orders[*]
     2 cntorders = i4
     2 patientname = vc
     2 patientlocation = vc
     2 patienttype = vc
     2 accountnum = vc
     2 ordername = vc
     2 admit = dq8
     2 dcdate = dq8
     2 orderablestatus = vc
     2 dateordered = dq8
     2 charteddatetime = dq8
     2 projectedstopdatetime = dq8
     2 orderchartdif = vc
     2 orderprojecteddif = vc
     2 dayofweek = vc
 )
 SELECT INTO "NL:"
  orderable = o.order_mnemonic, orderid = o.order_id, ptname = per.name_full_formatted,
  acctnum = ea.alias, orderstatus = uar_get_code_display(o.order_status_cd), orderdate = o
  .orig_order_dt_tm,
  datetimecharted = ce.performed_dt_tm, prodate = o.projected_stop_dt_tm, ordertocharteddif = format(
   datetimediff(ce.performed_dt_tm,o.orig_order_dt_tm),"DD:HH:MM;;Z"),
  ordertotaskdif = format(datetimediff(o.projected_stop_dt_tm,o.orig_order_dt_tm),"DD:HH:MM;;Z"),
  nurseunit = uar_get_code_display(elh.loc_nurse_unit_cd), pttype = uar_get_code_display(enc
   .encntr_type_cd),
  num =
  IF (weekday(o.orig_order_dt_tm)=0) 7
  ELSEIF (weekday(o.orig_order_dt_tm)=1) 1
  ELSEIF (weekday(o.orig_order_dt_tm)=2) 2
  ELSEIF (weekday(o.orig_order_dt_tm)=3) 3
  ELSEIF (weekday(o.orig_order_dt_tm)=4) 4
  ELSEIF (weekday(o.orig_order_dt_tm)=5) 5
  ELSEIF (weekday(o.orig_order_dt_tm)=6) 6
  ENDIF
  FROM orders o,
   encntr_loc_hist elh,
   person per,
   encounter enc,
   encntr_alias ea,
   clinical_event ce
  PLAN (o
   WHERE o.catalog_cd IN (792392, 792404)
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(from_date) AND cnvtdatetime(to_date))
   JOIN (elh
   WHERE elh.encntr_id=o.encntr_id
    AND o.orig_order_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm)
   JOIN (per
   WHERE per.person_id=o.person_id)
   JOIN (enc
   WHERE enc.encntr_id=o.encntr_id
    AND ((patienttype1=1) OR (((patienttype1=2
    AND enc.encntr_type_cd IN (observation, disch_obv, expired_obv, inpatient, preadmit_ip,
   disch_ip, expired_ip, emergency, disch_es, expired_es)) OR (patienttype1=3
    AND enc.encntr_type_cd IN (outpatient, onetime_op, recurring_op, disch_recurring_op,
   preadmint_daystay,
   reactivate, disch_daystay, daystay, j_doe, pre_outpt,
   expired_daystay, triage, office_visit, preoffice_visit, prerecur_office_visit,
   recur_office_visit, disch_recur_office_visit, vnh, disch_vnh, active_vnh,
   active_cmty_office_visit, pre_cmty_office_visit, outpatient_onetime, pre_outpatient_onetime,
   outpatient_recurring,
   discharged_outpatient, smri))) )) )
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ea.encntr_alias_type_cd=1077)
   JOIN (ce
   WHERE ce.order_id=o.order_id
    AND ce.result_status_cd=25)
  ORDER BY num
  HEAD REPORT
   cntorders = 0, stat = alterlist(event->orders,100)
  DETAIL
   cntorders = (cntorders+ 1)
   IF (mod(cntorders,10)=1
    AND cntorders > 100)
    stat = alterlist(event->orders,(cntorders+ 9))
   ENDIF
   CASE (num)
    OF 0:
     ms_weekday = "NoDay"
    OF 1:
     ms_weekday = "Monday"
    OF 2:
     ms_weekday = "Tuesday"
    OF 3:
     ms_weekday = "Wednesday"
    OF 4:
     ms_weekday = "Thursday"
    OF 5:
     ms_weekday = "Friday"
    OF 6:
     ms_weekday = "Saturday"
    OF 7:
     ms_weekday = "Sunday"
    ELSE
     ms_weekday = "error"
   ENDCASE
   event->orders[cntorders].patientname = ptname, event->orders[cntorders].patientlocation =
   nurseunit, event->orders[cntorders].patienttype = pttype,
   event->orders[cntorders].accountnum = acctnum, event->orders[cntorders].ordername = orderable,
   event->orders[cntorders].admit = enc.arrive_dt_tm,
   event->orders[cntorders].dcdate = enc.disch_dt_tm, event->orders[cntorders].orderablestatus =
   orderstatus, event->orders[cntorders].dateordered = o.orig_order_dt_tm,
   event->orders[cntorders].charteddatetime = ce.performed_dt_tm, event->orders[cntorders].
   projectedstopdatetime = o.projected_stop_dt_tm, event->orders[cntorders].orderchartdif =
   ordertotaskdif,
   event->orders[cntorders].orderprojecteddif = ordertocharteddif, event->orders[cntorders].dayofweek
    = ms_weekday
  FOOT REPORT
   stat = alterlist(event->orders,cntorders)
  WITH nocounter, format, separator = " "
 ;end select
 IF (size(event->orders,5) > 0)
  SELECT INTO value( $OUTDEV)
   ptname = substring(1,50,event->orders[d.seq].patientname), patient__________location = event->
   orders[d.seq].patientlocation, pttype = event->orders[d.seq].patienttype,
   acctnum = event->orders[d.seq].accountnum, orderable = substring(1,50,event->orders[d.seq].
    ordername), orderstatus = event->orders[d.seq].orderablestatus,
   admitdate = format(event->orders[d.seq].admit,"DD-MMM-YYYY HH:MM:SS;;D"), dischargedate = format(
    event->orders[d.seq].dcdate,"DD-MMM-YYYY HH:MM:SS;;D"), orderdate = format(event->orders[d.seq].
    dateordered,"DD-MMM-YYYY HH:MM:SS;;D"),
   ordertime = format(event->orders[d.seq].dateordered,"HH:MM:SS;;D"), order_day = trim(event->
    orders[d.seq].dayofweek), datetimecharted = format(event->orders[d.seq].charteddatetime,
    "DD-MMM-YYYY HH:MM:SS;;D"),
   prodate = format(event->orders[d.seq].projectedstopdatetime,"DD-MMM-YYYY HH:MM:SS;;D"),
   ordertocharteddif = event->orders[d.seq].orderprojecteddif, ordertotaskdif = event->orders[d.seq].
   orderchartdif
   FROM (dummyt d  WITH seq = value(size(event->orders,5)))
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
END GO
