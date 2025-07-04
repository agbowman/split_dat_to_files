CREATE PROGRAM dcp_ops_outp_dc_dords:dba
 DECLARE program_version = vc WITH private, constant("015")
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
 DECLARE failed_ind = i2
 SET failed_ind = 0
 DECLARE crm_status_ok = i2 WITH protect, constant(0)
 DECLARE crm_status_com_error = i2 WITH protect, constant(1)
 DECLARE crm_status_sec_context_err = i2 WITH protect, constant(69)
 DECLARE isdebugmodeon(null) = i2
 SUBROUTINE isdebugmodeon(null)
   DECLARE debug_mode_on = i2 WITH noconstant(0)
   IF (validate(isdebug)=1)
    IF (build(isdebug)="1")
     SET debug_mode_on = 1
     CALL message_line("******************")
     CALL message_line(" Debug Mode is on ")
     CALL message_line("******************")
    ENDIF
   ENDIF
   RETURN(debug_mode_on)
 END ;Subroutine
 SUBROUTINE (populateorderwriterequest(orderlistitem=i4,orderid=f8,actiontypecd=f8,oeformatid=f8,
  catalogtypecd=f8,updtcnt=i4,catalogcd=f8,orderstatuscd=f8,discontinuetypecd=f8) =null)
   DECLARE srvstat = i4 WITH protect, noconstant(0)
   SET srvstat = uar_srvsetdouble(orderlistitem,"orderId",orderid)
   SET srvstat = uar_srvsetdouble(orderlistitem,"actionTypeCd",actiontypecd)
   SET srvstat = uar_srvsetdouble(orderlistitem,"oeFormatId",oeformatid)
   SET srvstat = uar_srvsetdouble(orderlistitem,"catalogTypeCd",catalogtypecd)
   SET srvstat = uar_srvsetlong(orderlistitem,"lastUpdtCnt",updtcnt)
   SET srvstat = uar_srvsetdouble(orderlistitem,"catalogCd",catalogcd)
   SET srvstat = uar_srvsetdouble(orderlistitem,"orderStatusCd",orderstatuscd)
   SET srvstat = uar_srvsetdouble(orderlistitem,"discontinueTypeCd",discontinuetypecd)
 END ;Subroutine
 SUBROUTINE (logorderwriteprogress(numberofreqitems=i4,currentnumberprocessed=i4,totalnumberprocessed
  =i4) =null)
   CALL echo(build("> Process status update: [",numberofreqitems," items, ",format(((cnvtreal(
       currentnumberprocessed)/ cnvtreal(totalnumberprocessed)) * 100.0),"###.##"),"% complete]...")
    )
 END ;Subroutine
 SUBROUTINE (callorderwriteserver(stephandle=i4,requestlistsize=i4,logerrormessageind=i2) =i4)
   DECLARE crmstatus = i4 WITH protect, noconstant(uar_crmperform(stephandle))
   IF (crmstatus != 0)
    CALL echo(build2("CRM error in calling Order Write Synch server: ",crmstatus))
    RETURN(crmstatus)
   ENDIF
   IF (logerrormessageind=1)
    DECLARE owsreply = i4 WITH noconstant(uar_crmgetreply(stephandle))
    DECLARE owsreplystatusblock = i4 WITH protect, noconstant(uar_srvgetstruct(owsreply,"status_data"
      ))
    DECLARE owsreplystatus = vc WITH noconstant(uar_srvgetstringptr(owsreplystatusblock,"status"))
    IF (owsreplystatus="F")
     DECLARE orderlistrepitem = i4 WITH noconstant(0)
     FOR (replylistidx = 0 TO requestlistsize)
      SET orderlistrepitem = uar_srvgetitem(owsreply,"orderList",replylistidx)
      IF (uar_srvgetlong(orderlistrepitem,"errorNbr") > 0)
       CALL echo(build("-> Order (ID:",uar_srvgetdouble(orderlistrepitem,"orderId"),
         ") failed due to ->",getorderwriteerrormessagesfromreply(orderlistrepitem)))
      ENDIF
     ENDFOR
     SET orderlistrepitem = 0
    ENDIF
   ENDIF
   SET stephandle = 0
   RETURN(crmstatus)
 END ;Subroutine
 SUBROUTINE (getorderwriteerrormessagesfromreply(orderlistreplyitem=i4) =vc)
   DECLARE specificerrorstr = vc WITH noconstant("")
   DECLARE substrbegin = i4 WITH noconstant(0)
   DECLARE substrlength = i4 WITH noconstant(0)
   SET specificerrorstr = uar_srvgetstringptr(orderlistreplyitem,"specificErrorStr")
   IF (specificerrorstr != "")
    SET substrbegin = (findstring("]: ",specificerrorstr,1)+ 3)
    SET substrlength = ((size(specificerrorstr,1) - substrbegin)+ 1)
    RETURN(substring(substrbegin,substrlength,specificerrorstr))
   ENDIF
   RETURN("")
 END ;Subroutine
 SUBROUTINE (message_line(msg=vc) =null)
   CALL echo(build2("********************",msg,"********************"))
 END ;Subroutine
 SUBROUTINE (callorderwriteserverforsingleorderprocessing(htask=i4,hreq=i4,debugmodeon=i2,testmodeon=
  i2) =i4)
   DECLARE hreqforsingleorderprocessing = i4 WITH protect, noconstant(0)
   DECLARE hitemforsingleorderprocessing = i4 WITH protect, noconstant(0)
   DECLARE hstepforsingleorderprocessing = i4 WITH protect, noconstant(0)
   DECLARE failedindsingleorderprocessing = i2 WITH protect, noconstant(0)
   SET crmstatus = uar_crmbeginreq(htask,"",560201,hstepforsingleorderprocessing)
   IF (crmstatus != 0)
    CALL echo(build2("CRM error in calling Order Write Synch server: ",crmstatus))
    RETURN(crmstatus)
   ENDIF
   SET hreqforsingleorderprocessing = uar_crmgetrequest(hstepforsingleorderprocessing)
   SET orderscount = uar_srvgetitemcount(hreq,"orderList")
   FOR (orderlistidx = 0 TO (orderscount - 1))
    SET orderlistreqitem = uar_srvgetitem(hreq,"orderList",orderlistidx)
    IF (orderlistreqitem=null)
     CALL echo(build("Invalid handle return from SrvGetItem for orderList",orderlistidx))
    ELSE
     SET hitemforsingleorderprocessing = uar_srvadditem(hreqforsingleorderprocessing,"orderList")
     CALL populateorderwriterequest(hitemforsingleorderprocessing,uar_srvgetdouble(orderlistreqitem,
       "orderId"),uar_srvgetdouble(orderlistreqitem,"actionTypeCd"),uar_srvgetdouble(orderlistreqitem,
       "oeFormatId"),uar_srvgetdouble(orderlistreqitem,"catalogTypeCd"),
      uar_srvgetlong(orderlistreqitem,"lastUpdtCnt"),uar_srvgetdouble(orderlistreqitem,"catalogCd"),
      uar_srvgetdouble(orderlistreqitem,"orderStatusCd"),uar_srvgetdouble(orderlistreqitem,
       "discontinueTypeCd"))
     IF (testmodeon
      AND orderlistidx=0)
      CALL echo("Test mode is ON for the first order")
      SET failedindsingleorderprocessing = 1
     ELSE
      SET failedindsingleorderprocessing = callorderwriteserver(hstepforsingleorderprocessing,1,
       debugmodeon)
     ENDIF
     IF (failedindsingleorderprocessing)
      CALL echo(build("Order failed during the processing of one order at a time: ",uar_srvgetdouble(
         orderlistreqitem,"orderId")))
     ENDIF
     CALL uar_srvreset(hreqforsingleorderprocessing,0)
    ENDIF
   ENDFOR
   RETURN(crmstatus)
 END ;Subroutine
 DECLARE max_orders_size = i4 WITH constant(50)
 DECLARE number_of_orders = i4 WITH noconstant(0)
 DECLARE debug_mode_on = i2 WITH noconstant(0)
 IF (validate(isdebug)=1)
  IF (build(isdebug)="1")
   SET debug_mode_on = 1
   CALL message_line("******************")
   CALL message_line(" Debug Mode is on ")
   CALL message_line("******************")
  ENDIF
 ENDIF
 DECLARE test_mode_on = i2 WITH noconstant(0)
 IF (validate(testmodecancelondischarge)=1)
  IF (build(testmodecancelondischarge)="1")
   SET test_mode_on = 1
   CALL message_line("******************")
   CALL message_line(" Test Mode is on ")
   CALL message_line("******************")
  ENDIF
 ENDIF
 RECORD hold(
   1 enc_cnt = i4
   1 enc[*]
     2 encntr_id = f8
     2 ord_cnt = i4
     2 ord[*]
       3 order_id = f8
       3 order_status_cd = f8
       3 action_type_cd = f8
       3 action = c20
       3 catalog_cd = f8
       3 catalog_type_cd = f8
       3 updt_cnt = i4
       3 oe_format_id = f8
 )
 RECORD cval(
   1 inprocess_status_cd = f8
   1 ordered_status_cd = f8
   1 discontinued_status_cd = f8
   1 canceled_status_cd = f8
   1 medstudent_status_cd = f8
   1 incomplete_status_cd = f8
   1 suspended_status_cd = f8
   1 discontinue_action_cd = f8
   1 cancel_action_cd = f8
   1 inpatient_cd = f8
   1 disc_type_cd = f8
 )
 RECORD dstat(
   1 cnt = i4
   1 qual[*]
     2 dstat_code_value = f8
 )
 RECORD enc_type_flex(
   1 qual[*]
     2 encntr_type_cd = f8
     2 organization_id = f8
     2 clean_days = i4
     2 dsch_days = i4
     2 max_dsch_dt_tm = dq8
     2 min_dsch_dt_tm = dq8
     2 start_plus_days = i4
     2 check_start_ind = i2
 )
 RECORD discharged_encounters(
   1 qual[*]
     2 encntr_id = f8
     2 check_clean_ind = i2
     2 check_start_ind = i2
     2 clean_disch_time = dq8
     2 start_check_time = dq8
 ) WITH protect
 DECLARE dcp_allow_cancel_unsch = i2 WITH protect, noconstant(0)
 DECLARE dcp_allow_cancel_prn = i2 WITH protect, noconstant(0)
 DECLARE dsch_hours = f8 WITH protect, noconstant(12.0)
 DECLARE dsch_lookback_days = i4 WITH protect, noconstant(2)
 CALL echo("Looking up preferences from config_prefs table...")
 SELECT INTO "nl:"
  cp.config_name
  FROM config_prefs cp
  WHERE cp.config_name IN ("DCPCNCLUNSCH", "DCPCNCLPRN", "OUTDSCH_HRS", "OUTDSCH_LOOKBACK_DAYS")
  DETAIL
   IF (cp.config_name="DCPCNCLUNSCH"
    AND cp.config_value="1")
    dcp_allow_cancel_unsch = 1
   ELSEIF (cp.config_name="DCPCNCLPRN"
    AND cp.config_value="1")
    dcp_allow_cancel_prn = 1
   ELSEIF (cp.config_name="OUTDSCH_HRS")
    dsch_hours = cnvtreal(trim(cp.config_value))
   ELSEIF (cp.config_name="OUTDSCH_LOOKBACK_DAYS")
    dsch_lookback_days = cnvtint(trim(cp.config_value))
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("DCPCNCLUNSCH:",dcp_allow_cancel_unsch))
 CALL echo(build("DCPCNCLPRN:",dcp_allow_cancel_prn))
 CALL echo(build("disch hours: ",dsch_hours))
 CALL echo(build("dsch_lookback_days: ",dsch_lookback_days))
 DECLARE check_start_ind = i2
 SET check_start_ind = 0
 DECLARE start_plus_hrs = i4
 SET start_plus_hrs = 0
 DECLARE check_start_workflow_ind = i2 WITH protect, noconstant(0)
 DECLARE start_check_time = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
 DECLARE dsch_cancel_flag = i2
 SET dsch_cancel_flag = 3
 SELECT INTO "nl:"
  cp.config_name
  FROM config_prefs cp
  WHERE cp.config_name="OUTDSCH_FLAG"
  DETAIL
   tmp_val = substring(1,3,trim(cp.config_value))
   IF (tmp_val="ALL")
    dsch_cancel_flag = 1
   ELSEIF (tmp_val="ORD")
    dsch_cancel_flag = 2
   ELSE
    dsch_cancel_flag = 3
   ENDIF
   IF (((dsch_cancel_flag=1) OR (dsch_cancel_flag=2)) )
    tmp_val2 = substring(4,1,trim(cp.config_value))
    IF (tmp_val2=">")
     tmp_val3 = substring(5,1,trim(cp.config_value))
     IF (tmp_val3 > " ")
      check_start_workflow_ind = 1, start_plus_hrs = dsch_hours
      IF (start_plus_hrs >= 0)
       check_start_ind = 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("disch cancel flag: ",dsch_cancel_flag))
 CALL echo("Looking up code_values...")
 SET cval->ordered_status_cd = uar_get_code_by("MEANING",6004,"ORDERED")
 SET cval->inprocess_status_cd = uar_get_code_by("MEANING",6004,"INPROCESS")
 SET cval->discontinued_status_cd = uar_get_code_by("MEANING",6004,"DISCONTINUED")
 SET cval->canceled_status_cd = uar_get_code_by("MEANING",6004,"CANCELED")
 SET cval->incomplete_status_cd = uar_get_code_by("MEANING",6004,"INCOMPLETE")
 SET cval->medstudent_status_cd = uar_get_code_by("MEANING",6004,"MEDSTUDENT")
 SET cval->suspended_status_cd = uar_get_code_by("MEANING",6004,"SUSPENDED")
 SET cval->inpatient_cd = uar_get_code_by("MEANING",69,"INPATIENT")
 SET cval->disc_type_cd = uar_get_code_by("MEANING",4038,"SYSTEMDISCH")
 SET cval->discontinue_action_cd = uar_get_code_by("MEANING",6003,"DISCONTINUE")
 SET cval->cancel_action_cd = uar_get_code_by("MEANING",6003,"CANCEL")
 IF ((((cval->canceled_status_cd=0)) OR ((cval->discontinued_status_cd=0))) )
  CALL echo("**** missing an order status code****")
  SET failed_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = "dcp_ops_outp_dc_dords"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "order status missing"
  GO TO exit_script
 ENDIF
 IF ((cval->inpatient_cd=0))
  CALL echo("**** missing inpatient encntr type class on codeset 69 ****")
  SET failed_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = "dcp_ops_outp_dc_dords"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "inpatient (cs 69) missing"
  GO TO exit_script
 ENDIF
 IF ((((cval->discontinue_action_cd=0)) OR ((cval->cancel_action_cd=0))) )
  CALL echo("**** missing an order action code****")
  SET failed_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = "dcp_ops_outp_dc_dords"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "order action missing"
  GO TO exit_script
 ENDIF
 DECLARE encntr_type_flex_cnt = i4 WITH protect, noconstant(0)
 DECLARE temp_dsch_days = i4 WITH protect
 DECLARE temp_clean_days = i4 WITH protect
 DECLARE now = f8 WITH protect, constant(cnvtdatetime(sysdate))
 SELECT INTO "nl:"
  FROM encntr_type_params etp
  PLAN (etp
   WHERE etp.param_name IN ("OUTCLEAN_DAYS", "OUTDSCH_DAYS"))
  ORDER BY etp.organization_id, etp.encntr_type_cd
  HEAD etp.organization_id
   null
  HEAD etp.encntr_type_cd
   temp_dsch_days = 0, temp_clean_days = 0
  DETAIL
   IF (etp.param_name="OUTCLEAN_DAYS")
    temp_clean_days = etp.value_nbr
   ELSEIF (etp.param_name="OUTDSCH_DAYS")
    temp_dsch_days = etp.value_nbr
   ENDIF
  FOOT  etp.encntr_type_cd
   IF (temp_dsch_days > 0
    AND ((check_start_workflow_ind=0) OR (temp_clean_days > temp_dsch_days)) )
    encntr_type_flex_cnt += 1
    IF (encntr_type_flex_cnt > size(enc_type_flex->qual,5))
     stat = alterlist(enc_type_flex->qual,(encntr_type_flex_cnt+ 9))
    ENDIF
    stat = alterlist(enc_type_flex->qual,encntr_type_flex_cnt), enc_type_flex->qual[
    encntr_type_flex_cnt].encntr_type_cd = etp.encntr_type_cd, enc_type_flex->qual[
    encntr_type_flex_cnt].organization_id = etp.organization_id,
    enc_type_flex->qual[encntr_type_flex_cnt].clean_days = temp_clean_days, enc_type_flex->qual[
    encntr_type_flex_cnt].dsch_days = temp_dsch_days, enc_type_flex->qual[encntr_type_flex_cnt].
    max_dsch_dt_tm = datetimeadd(now,- (temp_dsch_days))
    IF (check_start_workflow_ind=1)
     enc_type_flex->qual[encntr_type_flex_cnt].start_plus_days = temp_dsch_days, enc_type_flex->qual[
     encntr_type_flex_cnt].check_start_ind = 1
    ENDIF
    IF (((check_start_workflow_ind=1) OR (dsch_cancel_flag=2))
     AND temp_clean_days > temp_dsch_days)
     enc_type_flex->qual[encntr_type_flex_cnt].min_dsch_dt_tm = datetimeadd(now,- ((temp_clean_days+
      dsch_lookback_days)))
    ELSE
     enc_type_flex->qual[encntr_type_flex_cnt].min_dsch_dt_tm = datetimeadd(now,- ((temp_dsch_days+
      dsch_lookback_days)))
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(enc_type_flex->qual,encntr_type_flex_cnt)
  WITH nocounter
 ;end select
 IF (debug_mode_on=1)
  CALL echorecord(enc_type_flex)
 ENDIF
 DECLARE enc_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(encntr_type_flex_cnt)),
   encounter e
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_type_cd=enc_type_flex->qual[d.seq].encntr_type_cd)
    AND (e.organization_id=enc_type_flex->qual[d.seq].organization_id)
    AND e.disch_dt_tm > cnvtdatetime(enc_type_flex->qual[d.seq].min_dsch_dt_tm)
    AND e.disch_dt_tm < cnvtdatetime(enc_type_flex->qual[d.seq].max_dsch_dt_tm)
    AND ((e.encntr_type_class_cd+ 0) != cval->inpatient_cd))
  DETAIL
   enc_cnt += 1
   IF (enc_cnt > size(discharged_encounters->qual,5))
    stat = alterlist(discharged_encounters->qual,(enc_cnt+ 9))
   ENDIF
   discharged_encounters->qual[enc_cnt].encntr_id = e.encntr_id, discharged_encounters->qual[enc_cnt]
   .check_start_ind = enc_type_flex->qual[d.seq].check_start_ind, discharged_encounters->qual[enc_cnt
   ].start_check_time = datetimeadd(e.disch_dt_tm,enc_type_flex->qual[d.seq].start_plus_days),
   discharged_encounters->qual[enc_cnt].clean_disch_time = datetimeadd(e.disch_dt_tm,enc_type_flex->
    qual[d.seq].clean_days)
   IF ((((enc_type_flex->qual[d.seq].check_start_ind=1)) OR (dsch_cancel_flag=2)) )
    discharged_encounters->qual[enc_cnt].check_clean_ind = 1
   ENDIF
  FOOT REPORT
   stat = alterlist(discharged_encounters->qual,enc_cnt)
  WITH nocounter
 ;end select
 IF (debug_mode_on=1)
  CALL echorecord(discharged_encounters)
 ENDIF
 DECLARE clean_days = i4
 SET clean_days = 0
 DECLARE dsch_days = i4
 SET dsch_days = ((dsch_hours/ 24)+ dsch_lookback_days)
 CALL echo(build("dsch_days-->",dsch_days))
 DECLARE check_clean_ind = i2
 SET check_clean_ind = 0
 DECLARE clean_hours = i4
 SET clean_hours = 0
 IF (((check_start_ind=1) OR (dsch_cancel_flag=2)) )
  SELECT INTO "nl:"
   cp.config_name
   FROM config_prefs cp
   WHERE cp.config_name="OUTCLEAN_HRS"
   DETAIL
    clean_hours = cnvtreal(trim(cp.config_value))
   WITH nocounter
  ;end select
  IF (clean_hours > 0)
   CALL echo(build("disch hours: ",dsch_hours))
   SET clean_days = ((clean_hours/ 24)+ dsch_lookback_days)
   CALL echo(build("clean_days-->",clean_days))
  ENDIF
 ENDIF
 DECLARE min_dsch_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE max_dsch_dt_tm = f8 WITH protect, noconstant(0.0)
 CALL echo(build("now->",format(now,";;q")))
 IF (dsch_days > clean_days)
  SET min_dsch_dt_tm = datetimeadd(now,- (dsch_days))
 ELSE
  SET min_dsch_dt_tm = datetimeadd(now,- (clean_days))
 ENDIF
 CALL echo(build("min_dsch_dt_tm->",format(min_dsch_dt_tm,";;q")))
 SET max_dsch_dt_tm = cnvtdatetime(sysdate)
 IF (dsch_hours > 0)
  SET max_dsch_dt_tm = datetimeadd(now,- ((dsch_hours/ 24.0)))
 ENDIF
 CALL echo(build("max_dsch_dt_tm->",format(max_dsch_dt_tm,";;q")))
 SELECT INTO "nl:"
  cve.code_value
  FROM code_value_extension cve
  WHERE cve.code_set=14281
   AND cve.field_name="DCP_ALLOW_CANCEL_IND"
  DETAIL
   cancel_ind = cnvtint(trim(cve.field_value))
   IF (cancel_ind=1)
    dstat->cnt += 1, stat = alterlist(dstat->qual,dstat->cnt), dstat->qual[dstat->cnt].
    dstat_code_value = cve.code_value
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Searching for qualified orders...")
 DECLARE loc_idx = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM encounter e
  WHERE  NOT (expand(loc_idx,1,encntr_type_flex_cnt,e.encntr_type_cd,enc_type_flex->qual[loc_idx].
   encntr_type_cd,
   e.organization_id,enc_type_flex->qual[loc_idx].organization_id))
   AND e.disch_dt_tm > cnvtdatetime(min_dsch_dt_tm)
   AND e.disch_dt_tm < cnvtdatetime(max_dsch_dt_tm)
   AND ((e.encntr_type_class_cd+ 0) != cval->inpatient_cd)
  DETAIL
   enc_cnt += 1
   IF (enc_cnt > size(discharged_encounters->qual,5))
    stat = alterlist(discharged_encounters->qual,(enc_cnt+ 9))
   ENDIF
   discharged_encounters->qual[enc_cnt].encntr_id = e.encntr_id
   IF (clean_hours > 0)
    discharged_encounters->qual[enc_cnt].check_clean_ind = 1
   ENDIF
   discharged_encounters->qual[enc_cnt].check_start_ind = check_start_ind, discharged_encounters->
   qual[enc_cnt].start_check_time = datetimeadd(e.disch_dt_tm,(start_plus_hrs/ 24.0)),
   discharged_encounters->qual[enc_cnt].clean_disch_time = datetimeadd(e.disch_dt_tm,(clean_hours/
    24.0))
  FOOT REPORT
   stat = alterlist(discharged_encounters->qual,enc_cnt)
  WITH expand = 1, nocounter
 ;end select
 IF (debug_mode_on=1)
  CALL echorecord(discharged_encounters)
 ENDIF
 SET hold->enc_cnt = 0
 DECLARE cancel_ind = i2 WITH protect, noconstant(0)
 DECLARE oc = i4 WITH protect, noconstant(0)
 DECLARE enc_pos = i4 WITH protect, noconstant(0)
 IF (dsch_cancel_flag=1)
  SELECT INTO "nl:"
   o.order_id
   FROM orders o
   PLAN (o
    WHERE expand(loc_idx,1,enc_cnt,o.encntr_id,discharged_encounters->qual[loc_idx].encntr_id)
     AND ((o.order_status_cd+ 0) IN (cval->ordered_status_cd, cval->inprocess_status_cd, cval->
    medstudent_status_cd, cval->incomplete_status_cd, cval->suspended_status_cd))
     AND ((o.orig_ord_as_flag+ 0) IN (0, 5)))
   ORDER BY o.encntr_id
   HEAD o.encntr_id
    hold->enc_cnt += 1
    IF ((hold->enc_cnt > size(hold->enc,5)))
     stat = alterlist(hold->enc,(hold->enc_cnt+ 5))
    ENDIF
    hold->enc[hold->enc_cnt].ord_cnt = 0, hold->enc[hold->enc_cnt].encntr_id = o.encntr_id, enc_pos
     = locateval(loc_idx,1,enc_cnt,o.encntr_id,discharged_encounters->qual[loc_idx].encntr_id)
   DETAIL
    cancel_ind = 0
    IF (o.cs_flag IN (1, 3, 4, 6))
     cancel_ind = 0
    ELSE
     cancel_ind = 0
     FOR (dd = 1 TO dstat->cnt)
       IF ((dstat->qual[dd].dstat_code_value=o.dept_status_cd))
        IF (discharged_encounters->qual[enc_pos].check_start_ind)
         IF (o.current_start_dt_tm > cnvtdatetime(discharged_encounters->qual[enc_pos].
          start_check_time)
          AND o.template_order_flag IN (0, 1, 2, 6))
          cancel_ind = 1
         ELSE
          IF (discharged_encounters->qual[enc_pos].check_clean_ind)
           CALL echo(build("clean disch:",discharged_encounters->qual[enc_pos].clean_disch_time)),
           CALL echo(build("now:",now))
           IF (cnvtdatetime(sysdate) > cnvtdatetime(discharged_encounters->qual[enc_pos].
            clean_disch_time))
            cancel_ind = 1,
            CALL echo("build because of clean")
           ENDIF
          ENDIF
         ENDIF
        ELSE
         cancel_ind = 1
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    IF (((o.template_order_flag=1) OR (((o.prn_ind=1) OR (((o.constant_ind=1) OR (o.freq_type_flag=5
    )) )) )) )
     IF (((o.prn_ind=1
      AND dcp_allow_cancel_prn=1) OR (o.freq_type_flag=5
      AND dcp_allow_cancel_unsch=1)) )
      FOR (dd = 1 TO dstat->cnt)
        IF ((dstat->qual[dd].dstat_code_value=o.dept_status_cd))
         cancel_ind = 1
        ENDIF
      ENDFOR
     ELSE
      cancel_ind = 1
     ENDIF
    ENDIF
    IF (cancel_ind=1)
     hold->enc[hold->enc_cnt].ord_cnt += 1, oc = hold->enc[hold->enc_cnt].ord_cnt
     IF (oc > size(hold->enc[hold->enc_cnt].ord,5))
      stat = alterlist(hold->enc[hold->enc_cnt].ord,(oc+ 5))
     ENDIF
     hold->enc[hold->enc_cnt].ord[oc].order_id = o.order_id, hold->enc[hold->enc_cnt].ord[oc].
     catalog_cd = o.catalog_cd, hold->enc[hold->enc_cnt].ord[oc].catalog_type_cd = o.catalog_type_cd,
     hold->enc[hold->enc_cnt].ord[oc].updt_cnt = o.updt_cnt, hold->enc[hold->enc_cnt].ord[oc].
     oe_format_id = o.oe_format_id
     IF (o.current_start_dt_tm < cnvtdatetime(sysdate)
      AND (o.order_status_cd != cval->medstudent_status_cd))
      hold->enc[hold->enc_cnt].ord[oc].order_status_cd = cval->discontinued_status_cd, hold->enc[hold
      ->enc_cnt].ord[oc].action_type_cd = cval->discontinue_action_cd, hold->enc[hold->enc_cnt].ord[
      oc].action = "DISCONTINUE"
     ELSE
      hold->enc[hold->enc_cnt].ord[oc].order_status_cd = cval->canceled_status_cd, hold->enc[hold->
      enc_cnt].ord[oc].action_type_cd = cval->cancel_action_cd, hold->enc[hold->enc_cnt].ord[oc].
      action = "CANCEL"
     ENDIF
     number_of_orders += 1
    ENDIF
   FOOT  o.encntr_id
    stat = alterlist(hold->enc[hold->enc_cnt].ord,oc)
   WITH expand = 1, nocounter
  ;end select
  IF ((hold->enc_cnt=0))
   GO TO exit_script
  ENDIF
 ENDIF
 IF (dsch_cancel_flag=2)
  SELECT INTO "nl:"
   o.order_id, oc.catalog_cd
   FROM orders o,
    order_catalog oc
   PLAN (o
    WHERE expand(loc_idx,1,enc_cnt,o.encntr_id,discharged_encounters->qual[loc_idx].encntr_id)
     AND ((o.order_status_cd+ 0) IN (cval->ordered_status_cd, cval->inprocess_status_cd, cval->
    medstudent_status_cd, cval->incomplete_status_cd, cval->suspended_status_cd))
     AND o.orig_ord_as_flag IN (0, 5))
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
   ORDER BY o.encntr_id
   HEAD o.encntr_id
    hold->enc_cnt += 1
    IF ((hold->enc_cnt > size(hold->enc,5)))
     stat = alterlist(hold->enc,(hold->enc_cnt+ 5))
    ENDIF
    hold->enc[hold->enc_cnt].ord_cnt = 0, hold->enc[hold->enc_cnt].encntr_id = o.encntr_id, enc_pos
     = locateval(loc_idx,1,enc_cnt,o.encntr_id,discharged_encounters->qual[loc_idx].encntr_id)
   DETAIL
    cancel_ind = 0
    IF (o.cs_flag IN (1, 3, 4, 6))
     cancel_ind = 0
    ELSE
     cancel_ind = 0
     FOR (dd = 1 TO dstat->cnt)
       IF ((dstat->qual[dd].dstat_code_value=o.dept_status_cd))
        IF ((discharged_encounters->qual[enc_pos].check_start_ind=1))
         IF (o.current_start_dt_tm > cnvtdatetime(discharged_encounters->qual[enc_pos].
          start_check_time)
          AND o.template_order_flag IN (0, 1, 2, 6))
          cancel_ind = 1
         ELSE
          IF ((discharged_encounters->qual[enc_pos].check_clean_ind=1))
           CALL echo(build("clean disch:",discharged_encounters->qual[enc_pos].clean_disch_time)),
           CALL echo(build("now:",now))
           IF (cnvtdatetime(sysdate) > cnvtdatetime(discharged_encounters->qual[enc_pos].
            clean_disch_time))
            cancel_ind = 1,
            CALL echo("build because of clean")
           ENDIF
          ENDIF
         ENDIF
        ELSE
         cancel_ind = 1
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    orc_cancel_ind = 0
    IF (((o.template_order_flag=1) OR (((o.prn_ind=1) OR (((o.constant_ind=1) OR (((oc
    .auto_cancel_ind=1) OR (o.freq_type_flag=5)) )) )) )) )
     orc_cancel_ind = 1
     IF (((o.template_order_flag=1) OR (((o.prn_ind=1) OR (((o.constant_ind=1) OR (o.freq_type_flag=5
     )) )) )) )
      IF (((o.prn_ind=1
       AND dcp_allow_cancel_prn=1) OR (o.freq_type_flag=5
       AND dcp_allow_cancel_unsch=1)) )
       FOR (dd = 1 TO dstat->cnt)
         IF ((dstat->qual[dd].dstat_code_value=o.dept_status_cd))
          cancel_ind = 1
         ENDIF
       ENDFOR
      ELSE
       cancel_ind = 1
      ENDIF
     ENDIF
    ENDIF
    IF (cancel_ind=1
     AND orc_cancel_ind=1)
     hold->enc[hold->enc_cnt].ord_cnt += 1, oc = hold->enc[hold->enc_cnt].ord_cnt
     IF (oc > size(hold->enc[hold->enc_cnt].ord,5))
      stat = alterlist(hold->enc[hold->enc_cnt].ord,(oc+ 10))
     ENDIF
     hold->enc[hold->enc_cnt].ord[oc].order_id = o.order_id, hold->enc[hold->enc_cnt].ord[oc].
     catalog_cd = o.catalog_cd, hold->enc[hold->enc_cnt].ord[oc].catalog_type_cd = o.catalog_type_cd,
     hold->enc[hold->enc_cnt].ord[oc].updt_cnt = o.updt_cnt, hold->enc[hold->enc_cnt].ord[oc].
     oe_format_id = o.oe_format_id
     IF (o.current_start_dt_tm < cnvtdatetime(sysdate)
      AND (o.order_status_cd != cval->medstudent_status_cd))
      hold->enc[hold->enc_cnt].ord[oc].order_status_cd = cval->discontinued_status_cd, hold->enc[hold
      ->enc_cnt].ord[oc].action_type_cd = cval->discontinue_action_cd, hold->enc[hold->enc_cnt].ord[
      oc].action = "DISCONTINUE"
     ELSE
      hold->enc[hold->enc_cnt].ord[oc].order_status_cd = cval->canceled_status_cd, hold->enc[hold->
      enc_cnt].ord[oc].action_type_cd = cval->cancel_action_cd, hold->enc[hold->enc_cnt].ord[oc].
      action = "CANCEL"
     ENDIF
     number_of_orders += 1
    ENDIF
   FOOT  o.encntr_id
    stat = alterlist(hold->enc[hold->enc_cnt].ord,oc)
   WITH expand = 1, nocounter
  ;end select
  IF ((hold->enc_cnt=0))
   GO TO exit_script
  ENDIF
 ENDIF
 IF (dsch_cancel_flag=3)
  SELECT INTO "nl:"
   o.order_id
   FROM orders o
   PLAN (o
    WHERE expand(loc_idx,1,enc_cnt,o.encntr_id,discharged_encounters->qual[loc_idx].encntr_id)
     AND ((o.order_status_cd+ 0) IN (cval->ordered_status_cd, cval->inprocess_status_cd, cval->
    medstudent_status_cd, cval->incomplete_status_cd, cval->suspended_status_cd))
     AND o.orig_ord_as_flag IN (0, 5)
     AND ((o.template_order_flag=1) OR (((o.prn_ind=1) OR (((o.constant_ind=1) OR (o.freq_type_flag=5
    )) )) )) )
   ORDER BY o.encntr_id
   HEAD o.encntr_id
    hold->enc_cnt += 1
    IF ((hold->enc_cnt > size(hold->enc,5)))
     stat = alterlist(hold->enc,(hold->enc_cnt+ 5))
    ENDIF
    hold->enc[hold->enc_cnt].ord_cnt = 0, hold->enc[hold->enc_cnt].encntr_id = o.encntr_id
   DETAIL
    hold->enc[hold->enc_cnt].ord_cnt += 1, oc = hold->enc[hold->enc_cnt].ord_cnt
    IF (oc > size(hold->enc[hold->enc_cnt].ord,5))
     stat = alterlist(hold->enc[hold->enc_cnt].ord,(oc+ 10))
    ENDIF
    hold->enc[hold->enc_cnt].ord[oc].order_id = o.order_id, hold->enc[hold->enc_cnt].ord[oc].
    catalog_cd = o.catalog_cd, hold->enc[hold->enc_cnt].ord[oc].catalog_type_cd = o.catalog_type_cd,
    hold->enc[hold->enc_cnt].ord[oc].updt_cnt = o.updt_cnt, hold->enc[hold->enc_cnt].ord[oc].
    oe_format_id = o.oe_format_id
    IF (o.current_start_dt_tm < cnvtdatetime(sysdate)
     AND (o.order_status_cd != cval->medstudent_status_cd))
     hold->enc[hold->enc_cnt].ord[oc].order_status_cd = cval->discontinued_status_cd, hold->enc[hold
     ->enc_cnt].ord[oc].action_type_cd = cval->discontinue_action_cd, hold->enc[hold->enc_cnt].ord[oc
     ].action = "DISCONTINUE"
    ELSE
     hold->enc[hold->enc_cnt].ord[oc].order_status_cd = cval->canceled_status_cd, hold->enc[hold->
     enc_cnt].ord[oc].action_type_cd = cval->cancel_action_cd, hold->enc[hold->enc_cnt].ord[oc].
     action = "CANCEL"
    ENDIF
    number_of_orders += 1
   FOOT  o.encntr_id
    stat = alterlist(hold->enc[hold->enc_cnt].ord,oc)
   WITH expand = 1, nocounter
  ;end select
  IF ((hold->enc_cnt=0))
   GO TO exit_script
  ENDIF
 ENDIF
 CALL message_line("********************")
 CALL echo(build("Number of qualified encounters =",hold->enc_cnt))
 CALL echo(build("Number of qualified orders =",number_of_orders))
 CALL message_line("********************")
 DECLARE happ = i4 WITH protect, noconstant(0)
 DECLARE htask = i4 WITH protect, noconstant(0)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 EXECUTE crmrtl
 EXECUTE srvrtl
 DECLARE hreq = i4 WITH protect, noconstant(0)
 DECLARE hitem = i4 WITH protect, noconstant(0)
 DECLARE srvstat = i4 WITH protect, noconstant(0)
 DECLARE ows_request_size = i4 WITH protect, noconstant(0)
 SET crmstatus = uar_crmbeginapp(560210,happ)
 IF (crmstatus != 0)
  CALL echo("Error in Begin App for application 560210.")
  CALL echo(build("Crm Status:",crmstatus))
  GO TO exit_script
 ENDIF
 SET crmstatus = uar_crmbegintask(happ,500210,htask)
 IF (crmstatus != 0)
  CALL echo("Error in Begin Task for task 500210.")
  CALL echo(build("Crm Status:",crmstatus))
  GO TO exit_script
 ENDIF
 SET crmstatus = uar_crmbeginreq(htask,"",560201,hstep)
 IF (crmstatus != 0)
  CALL echo("Error in Begin Request for request 560201.")
  CALL echo(build("Crm Status:",crmstatus))
  GO TO exit_script
 ENDIF
 SET hreq = uar_crmgetrequest(hstep)
 CALL echo(build2("Orders will be processed in blocks of: ",build(max_orders_size)))
 CALL echo("Updating qualified orders...")
 DECLARE orders_counter = i4 WITH noconstant(0)
 DECLARE failedindsingleorderprocessing = i2 WITH protect, noconstant(0)
 SET stat = alterlist(hold->enc,hold->enc_cnt)
 FOR (encntr = 1 TO hold->enc_cnt)
   FOR (ord = 1 TO hold->enc[encntr].ord_cnt)
     SET hitem = uar_srvadditem(hreq,"orderList")
     CALL populateorderwriterequest(hitem,hold->enc[encntr].ord[ord].order_id,hold->enc[encntr].ord[
      ord].action_type_cd,hold->enc[encntr].ord[ord].oe_format_id,hold->enc[encntr].ord[ord].
      catalog_type_cd,
      hold->enc[encntr].ord[ord].updt_cnt,hold->enc[encntr].ord[ord].catalog_cd,hold->enc[encntr].
      ord[ord].order_status_cd,cval->disc_type_cd)
     SET orders_counter += 1
     IF (mod(orders_counter,max_orders_size)=0)
      IF (test_mode_on
       AND orders_counter=max_orders_size)
       SET failed_ind = 1
      ELSE
       SET failed_ind = callorderwriteserver(hstep,max_orders_size,debug_mode_on)
      ENDIF
      IF (debug_mode_on)
       CALL message_line(build2("Memory Status after ",build((orders_counter/ max_orders_size)),
         " call/calls to the server"))
       CALL trace(7)
       CALL message_line("********************************************************")
      ENDIF
      IF (failed_ind)
       CALL echo("Failed batch of orders will be processed one at a time")
       SET failedindsingleorderprocessing = callorderwriteserverforsingleorderprocessing(htask,hreq,
        debug_mode_on,test_mode_on)
       IF (failedindsingleorderprocessing)
        GO TO exit_script
       ENDIF
      ELSE
       CALL echo("All orders in current batch processed successfully")
      ENDIF
      CALL uar_srvreset(hreq,0)
      CALL logorderwriteprogress(max_orders_size,orders_counter,number_of_orders)
     ENDIF
   ENDFOR
 ENDFOR
 IF (mod(orders_counter,max_orders_size) != 0)
  IF (test_mode_on=1
   AND orders_counter < max_orders_size)
   SET failed_ind = 1
  ELSE
   SET failed_ind = callorderwriteserver(hstep,max_orders_size,debug_mode_on)
  ENDIF
  IF (debug_mode_on)
   CALL message_line(build2("Memory Status after ",build(((orders_counter/ max_orders_size)+ 1)),
     " call/calls to the server"))
   CALL trace(7)
   CALL message_line("********************************************************")
  ENDIF
  IF (failed_ind)
   CALL echo("Failed batch of orders will be processed one at a time")
   SET failedindsingleorderprocessing = callorderwriteserverforsingleorderprocessing(htask,hreq,
    debug_mode_on,test_mode_on)
   IF (failedindsingleorderprocessing)
    GO TO exit_script
   ENDIF
  ELSE
   CALL echo("All orders in current batch processed successfully")
  ENDIF
  CALL uar_srvreset(hreq,0)
  CALL logorderwriteprogress(mod(orders_counter,max_orders_size),orders_counter,number_of_orders)
 ENDIF
#exit_script
 IF (failed_ind=0)
  SET reply->status_data.status = "S"
  CALL echo(build("status:",reply->status_data.status))
 ELSE
  CALL echo("Error occured!")
  SET reply->status_data.status = "F"
  CALL echo(build("status:",reply->status_data.status))
  CALL echo(build("failed uar:",reply->status_data.subeventstatus[1].targetobjectname))
  CALL echo(build("buf string:",reply->status_data.subeventstatus[1].targetobjectvalue))
 ENDIF
 IF ((hold->enc_cnt > 0))
  IF (hstep != 0)
   CALL uar_crmendreq(hstep)
   SET hstep = 0
  ENDIF
  IF (htask != 0)
   CALL uar_crmendtask(htask)
   SET htask = 0
  ENDIF
  IF (happ != 0)
   CALL uar_crmendapp(happ)
   SET happ = 0
  ENDIF
 ELSE
  CALL message_line(" no encounter qualified! ")
 ENDIF
 FREE RECORD hold
 FREE RECORD cval
 FREE RECORD dstat
 FREE RECORD enc_type_flex
 FREE RECORD discharged_encounters
END GO
