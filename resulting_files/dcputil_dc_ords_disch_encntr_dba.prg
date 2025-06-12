CREATE PROGRAM dcputil_dc_ords_disch_encntr:dba
 PAINT
 DECLARE program_version = vc WITH private, constant("005")
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 SET reply->status_data.status = "F"
 DECLARE failed_ind = i2 WITH noconstant(0)
 DECLARE crm_ok = i2 WITH constant(0)
 DECLARE crm_com_error = i2 WITH constant(1)
 DECLARE crm_sec_context_err = i2 WITH constant(69)
 DECLARE current_time = f8 WITH noconstant(0.0)
 DECLARE previous_time = f8 WITH noconstant(0.0)
 DECLARE ows_block_size = i4 WITH constant(50)
 DECLARE number_of_servers = i2 WITH noconstant(2)
 DECLARE debug_mode_on = i2 WITH noconstant(0)
 IF (validate(isdebug)=1)
  IF (build(isdebug)="1")
   SET debug_mode_on = 1
   SET number_of_servers = 1
  ENDIF
 ENDIF
 DECLARE srvstat = i4 WITH protect, noconstant(0)
 DECLARE hitem = i4 WITH protect, noconstant(0)
 EXECUTE crmrtl
 EXECUTE srvrtl
 DECLARE happ = i4 WITH protect, noconstant(0)
 DECLARE htask = i4 WITH protect, noconstant(0)
 DECLARE sync_hstep = i4 WITH protect, noconstant(0)
 DECLARE sync_hreq = i4 WITH protect, noconstant(0)
 DECLARE async_hstep = i4 WITH protect, noconstant(0)
 DECLARE async_hreq = i4 WITH protect, noconstant(0)
 SET message = nowindow
 SET crmstatus = uar_crmbeginapp(560210,happ)
 IF (crmstatus=crm_sec_context_err)
  CALL echo(concat(
    "Error: Current user is not authorized to use the Order Write servers in Current CCL session. ",
    "Please login to CCL before executing this script."))
  CALL echo(build("Crm Status:",crmstatus))
  GO TO exit_script
 ENDIF
 IF (crmstatus != crm_ok)
  CALL echo("Error in Begin App for application 560210!")
  CALL echo(build("Crm Status:",crmstatus))
  GO TO exit_script
 ENDIF
 SET crmstatus = uar_crmbegintask(happ,500210,htask)
 IF (crmstatus != crm_ok)
  CALL echo("Error in Begin Task for task 500210.")
  CALL echo(build("Crm Status:",crmstatus))
  GO TO exit_script
 ENDIF
 SET crmstatus = uar_crmbeginreq(htask,"",560201,sync_hstep)
 IF (crmstatus != crm_ok)
  CALL echo("Error in Begin Request for request 560201.")
  CALL echo(build("Crm Status:",crmstatus))
  GO TO exit_script
 ENDIF
 SET sync_hreq = uar_crmgetrequest(sync_hstep)
 IF (number_of_servers > 1)
  SET crmstatus = uar_crmbeginreq(htask,"",560200,async_hstep)
  IF (crmstatus != crm_ok)
   CALL echo("Error in Begin Request for request 560200.")
   CALL echo(build("Crm Status:",crmstatus))
   GO TO exit_script
  ENDIF
  SET async_hreq = uar_crmgetrequest(async_hstep)
 ENDIF
 SET message = window
 DECLARE ordered_status_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE inprocess_status_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE discontinued_status_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
 DECLARE canceled_status_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"CANCELED"))
 DECLARE incomplete_status_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE medstudent_status_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"MEDSTUDENT"))
 DECLARE suspended_status_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
 DECLARE inpatient_cd = f8 WITH constant(uar_get_code_by("MEANING",69,"INPATIENT"))
 DECLARE disc_type_cd = f8 WITH constant(uar_get_code_by("MEANING",4038,"SYSTEMDISCH"))
 DECLARE discontinue_action_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"DISCONTINUE"))
 DECLARE cancel_action_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"CANCEL"))
 IF (((canceled_status_cd=0) OR (discontinued_status_cd=0)) )
  SET failed_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = "dcputil_dc_ords_disch_encntr"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "order status missing"
  GO TO exit_script
 ENDIF
 IF (inpatient_cd=0)
  SET failed_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = "dcputil_dc_ords_disch_encntr"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "inpatient (cs 69) missing"
  GO TO exit_script
 ENDIF
 IF (((discontinue_action_cd=0) OR (cancel_action_cd=0)) )
  SET failed_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = "dcputil_dc_ords_disch_encntr"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "order action missing"
  GO TO exit_script
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
 RECORD dstat(
   1 cnt = i4
   1 qual[*]
     2 dstat_code_value = f8
 )
 DECLARE dcp_allow_cancel_unsch = i2 WITH protect, noconstant(0)
 DECLARE dcp_allow_cancel_prn = i2 WITH protect, noconstant(0)
 DECLARE dsch_hours = f8 WITH protect, noconstant(0.0)
 DECLARE dsch_cancel_flag = i2 WITH protect, noconstant(3)
 DECLARE tmp_val = vc WITH protect, noconstant("")
 CALL echo("Looking up preferences from config_prefs table...")
 SELECT INTO "nl:"
  cp.config_name
  FROM config_prefs cp
  WHERE cp.config_name IN ("DCPCNCLUNSCH", "DCPCNCLPRN", "INDSCH_HRS", "INDSCH_FLAG")
  DETAIL
   IF (cp.config_name="DCPCNCLUNSCH"
    AND cp.config_value="1")
    dcp_allow_cancel_unsch = 1
   ELSEIF (cp.config_name="DCPCNCLPRN"
    AND cp.config_value="1")
    dcp_allow_cancel_prn = 1
   ELSEIF (cp.config_name="INDSCH_HRS")
    dsch_hours = cnvtreal(trim(cp.config_value))
   ELSEIF (cp.config_name="INDSCH_FLAG")
    tmp_val = substring(1,3,trim(cp.config_value))
    IF (tmp_val="ALL")
     dsch_cancel_flag = 1
    ELSEIF (tmp_val="ORD")
     dsch_cancel_flag = 2
    ELSE
     dsch_cancel_flag = 3
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 DECLARE dsch_days = i4
 SET dsch_days = ((dsch_hours/ 24)+ 2)
 DECLARE now = f8 WITH constant(cnvtdatetime(sysdate))
 DECLARE clean_days = i4 WITH noconstant(0)
 DECLARE clean_hours = f8 WITH noconstant(0.0)
 DECLARE temp_min_dsch_dt_tm = f8 WITH noconstant(0.0)
 DECLARE temp_max_dsch_dt_tm = f8 WITH noconstant(0.0)
 IF (dsch_cancel_flag=2)
  SELECT INTO "nl:"
   cp.config_name
   FROM config_prefs cp
   WHERE cp.config_name="INCLEAN_HRS"
   DETAIL
    clean_hours = cnvtreal(trim(cp.config_value))
   WITH nocounter
  ;end select
  IF (clean_hours > 0)
   SET clean_days = ((clean_hours/ 24)+ 2)
  ENDIF
 ENDIF
 IF (dsch_days > clean_days)
  SET temp_min_dsch_dt_tm = datetimeadd(now,- (dsch_days))
 ELSE
  SET temp_min_dsch_dt_tm = datetimeadd(now,- (clean_days))
 ENDIF
 SET temp_max_dsch_dt_tm = cnvtdatetime(sysdate)
 IF (dsch_hours > 0)
  SET temp_max_dsch_dt_tm = datetimeadd(now,- ((dsch_hours/ 24.0)))
 ENDIF
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
 DECLARE min_dsch_dt_tm = f8 WITH noconstant(0.0)
 DECLARE max_dsch_dt_tm = f8 WITH noconstant(0.0)
 DECLARE default_begin_dt = f8 WITH noconstant(0.0)
 SET default_begin_dt = cnvtdatetime(datetimeadd(temp_min_dsch_dt_tm,- (4)))
 DECLARE default_end_dt = f8 WITH noconstant(0.0)
 SET default_end_dt = cnvtdatetime(datetimeadd(temp_min_dsch_dt_tm,- (1)))
 DECLARE cancel_all_encntr_types = c1
 CALL clear(1,1)
 CALL box(1,2,24,125)
 CALL text(3,4,"Cancel Orders On Discharge Ops Job")
 CALL text(7,4,
  "Purpose: This program will cancel all appropriate orders on discharged patients for the given date/time range.  "
  )
 CALL text(8,4,
  "         The program will also allow the user to decide if they want to cancel orders on all encounter types,   "
  )
 CALL text(9,4,
  "         or only for inpatient encounters.                                                                      "
  )
 CALL text(11,4,
  "Note:    1) The user will only be allowed to enter in a date/time range that precedes the minimum date/time that"
  )
 CALL text(12,4,
  "            is at least 2 days in the past from now to an additional number of hours in the past as defined by  "
  )
 CALL text(13,4,
  "            the INDSCH_HRS preference unless the INDSCH_FLAG value starts with 'ORD' in which case it will use  "
  )
 CALL text(14,4,
  "            the greater of two configured hours set in INDSCH_HRS and INCLEAN_HRS.                              "
  )
 CALL text(15,4,
  "         2) The user may want to start up more instances of server 101 while this job is running.               "
  )
 CALL text(16,4,
  "         3) If orders are setup to print requisitions on a cancel or discontinue action, then requisitions will "
  )
 CALL text(17,4,
  "            print for this job.                                                                                 "
  )
 CALL text(18,4,
  "         4) If charges are setup to credit for canceled or discontinued orders, they will be credited back.     "
  )
 CALL text(19,4,
  "         5) Outbound order interfaces may get backed up when this ops job is ran.                               "
  )
 IF (number_of_servers=2)
  CALL text(20,4,
   "         6) To achieve optimal performance, please ensure at least one Order Write Asynchronous Server (104) "
   )
  CALL text(21,4,
   "         instance is running before starting this process                                                    "
   )
 ENDIF
 CALL text(24,4,
  "Do you want to continue? Y or N                                                                                 "
  )
 CALL accept(24,36,"P;CU"," "
  WHERE curaccept IN ("Y", "N"))
 IF (cnvtupper(curaccept)="N")
  GO TO exit_script
 ENDIF
 CALL clear(1,1)
 CALL video(nw)
 CALL box(1,2,15,115)
 CALL text(3,4,"Cancel Orders On Discharge Ops Job")
 WHILE (((min_dsch_dt_tm=0) OR (max_dsch_dt_tm=0)) )
   CALL text(7,4,"1)  Enter The Minimum Discharge Date And Time (dd-mmm-yyyy hh:mm)")
   CALL accept(7,80,"nndpppdnnnndnndnn;c",format(default_begin_dt,"dd-mmm-yyyy hh:mm;;d"))
   SET min_dsch_dt_tm = evaluate(format(cnvtdatetime(curaccept),"dd-mmm-yyyy hh:mm;3;q"),cnvtupper(
     curaccept),cnvtdatetime(curaccept),0.0)
   CALL text(9,4,"2)  Enter The Maximum Discharge Date And Time (dd-mmm-yyyy hh:mm)")
   CALL text(10,4,build("Note: This date should be less than: ",format(temp_min_dsch_dt_tm,
      "DD-MMM-YYYY;;D")))
   CALL accept(9,80,"nndpppdnnnndnndnn;c",format(default_end_dt,"dd-mmm-yyyy hh:mm;;d"))
   SET max_dsch_dt_tm = evaluate(format(cnvtdatetime(curaccept),"dd-mmm-yyyy hh:mm;3;q"),cnvtupper(
     curaccept),cnvtdatetime(curaccept),0.0)
   CALL text(12,4,
    "3)  Would you like to cancel orders on all encounter types? Y-All, N-Only Inpatient")
   CALL accept(12,88,"P;CU","Y")
   SET cancel_all_encntr_types = cnvtupper(curaccept)
   IF (max_dsch_dt_tm < min_dsch_dt_tm)
    CALL text(18,4,
     "The entered maximum discharge date and time cannot be less than the entered minimum discharge date and time."
     )
    GO TO exit_script
   ENDIF
   IF (max_dsch_dt_tm >= temp_min_dsch_dt_tm)
    CALL text(18,4,
     "The maximum discharge date and time entered needs to be less than 2 days from now plus INDSCH_HRS."
     )
    IF (dsch_cancel_flag=2)
     CALL text(19,4,
      "Since config_name INDSCH_FLAG is set with a config_value starting with ORD, the program")
     CALL text(20,4,"uses the greater of the INCLEAN_HRS and INDSCH_HRS.")
    ENDIF
    GO TO exit_script
   ENDIF
   IF (((max_dsch_dt_tm=0) OR (min_dsch_dt_tm=0)) )
    CALL text(12,4,"The date and time range entered is invalid, please re-enter")
   ENDIF
 ENDWHILE
 CALL text(18,4,"Canceling Orders Please Wait...")
 SET message = nowindow
 IF (debug_mode_on=1)
  CALL message_line("******************")
  CALL message_line(" Debug Mode is on ")
  CALL message_line("******************")
 ENDIF
 DECLARE max_order_qual_cnt = i4 WITH noconstant(100000)
 IF (validate(max_orders_qual)=1)
  IF (isnumeric(max_orders_qual))
   DECLARE temp_max = i4 WITH noconstant(max_orders_qual)
   IF (temp_max >= 1000)
    SET max_order_qual_cnt = temp_max
    CALL echo(concat(">> Setting custom maximum qualification of orders at: ",build(
       max_order_qual_cnt)))
   ELSE
    CALL echo(concat(">> Custom maximum is below bounds (less than 1000), using standard at: ",build(
       max_order_qual_cnt)))
   ENDIF
  ENDIF
 ENDIF
 DECLARE c_init_encntr_id = f8 WITH constant(1.0)
 DECLARE workload_complete_ind = i2 WITH noconstant(0)
 DECLARE cur_rec_processed = i4 WITH noconstant(0)
 DECLARE last_encntr_id_processed = f8 WITH noconstant(c_init_encntr_id)
 DECLARE number_of_orders = i4 WITH noconstant(0)
 DECLARE orders_counter = i4 WITH noconstant(0)
 DECLARE remainder_of_orders_in_req = i4 WITH noconstant(0)
 DECLARE cancel_ind = i2 WITH protect, noconstant(0)
 WHILE (workload_complete_ind=0)
   IF (debug_mode_on)
    SET previous_time = cnvtdatetime(sysdate)
   ENDIF
   SET number_of_orders = 0
   SET orders_counter = 0
   SET cur_rec_processed = 0
   SET stat = initrec(hold)
   DECLARE oc = i4 WITH protect, noconstant(0)
   SET hold->enc_cnt = 0
   IF (last_encntr_id_processed <= 1.0)
    CALL echo("Searching for qualified orders...")
   ELSE
    CALL echo(build("Searching for qualified orders [starting from encntr_Id = ",
      last_encntr_id_processed,"]..."))
   ENDIF
   IF (dsch_cancel_flag=1)
    IF (cancel_all_encntr_types="N")
     SELECT INTO "nl:"
      e.encntr_id, o.order_id
      FROM encounter e,
       orders o
      PLAN (e
       WHERE e.disch_dt_tm > cnvtdatetime(min_dsch_dt_tm)
        AND e.disch_dt_tm < cnvtdatetime(max_dsch_dt_tm)
        AND ((e.encntr_type_class_cd+ 0)=inpatient_cd)
        AND ((e.encntr_id+ 0) >= last_encntr_id_processed))
       JOIN (o
       WHERE o.encntr_id=e.encntr_id
        AND ((o.order_status_cd+ 0) IN (ordered_status_cd, inprocess_status_cd, medstudent_status_cd,
       incomplete_status_cd, suspended_status_cd))
        AND ((o.orig_ord_as_flag+ 0) IN (0, 5)))
      ORDER BY e.encntr_id
      HEAD e.encntr_id
       hold->enc_cnt += 1
       IF ((hold->enc_cnt > size(hold->enc,5)))
        stat = alterlist(hold->enc,(hold->enc_cnt+ 5))
       ENDIF
       hold->enc[hold->enc_cnt].ord_cnt = 0, hold->enc[hold->enc_cnt].encntr_id = e.encntr_id
      DETAIL
       cancel_ind = 0
       IF (o.cs_flag IN (1, 3, 4, 6))
        cancel_ind = 0
       ELSE
        cancel_ind = 0
        FOR (dd = 1 TO dstat->cnt)
          IF ((dstat->qual[dd].dstat_code_value=o.dept_status_cd))
           cancel_ind = 1
          ENDIF
        ENDFOR
       ENDIF
       IF (((o.template_order_flag=1) OR (((o.prn_ind=1) OR (((o.constant_ind=1) OR (o.freq_type_flag
       =5)) )) )) )
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
         stat = alterlist(hold->enc[hold->enc_cnt].ord,(oc+ 10))
        ENDIF
        hold->enc[hold->enc_cnt].ord[oc].order_id = o.order_id, hold->enc[hold->enc_cnt].ord[oc].
        catalog_cd = o.catalog_cd, hold->enc[hold->enc_cnt].ord[oc].catalog_type_cd = o
        .catalog_type_cd,
        hold->enc[hold->enc_cnt].ord[oc].updt_cnt = o.updt_cnt, hold->enc[hold->enc_cnt].ord[oc].
        oe_format_id = o.oe_format_id
        IF (o.current_start_dt_tm < cnvtdatetime(sysdate)
         AND o.order_status_cd != medstudent_status_cd)
         hold->enc[hold->enc_cnt].ord[oc].order_status_cd = discontinued_status_cd, hold->enc[hold->
         enc_cnt].ord[oc].action_type_cd = discontinue_action_cd, hold->enc[hold->enc_cnt].ord[oc].
         action = "DISCONTINUE"
        ELSE
         hold->enc[hold->enc_cnt].ord[oc].order_status_cd = canceled_status_cd, hold->enc[hold->
         enc_cnt].ord[oc].action_type_cd = cancel_action_cd, hold->enc[hold->enc_cnt].ord[oc].action
          = "CANCEL"
        ENDIF
        number_of_orders += 1
       ENDIF
       cur_rec_processed += 1
      FOOT  e.encntr_id
       stat = alterlist(hold->enc[hold->enc_cnt].ord,oc), last_encntr_id_processed = e.encntr_id
      WITH nocounter, maxrec = value(max_order_qual_cnt)
     ;end select
    ELSE
     SELECT INTO "nl:"
      e.encntr_id, o.order_id
      FROM encounter e,
       orders o
      PLAN (e
       WHERE e.disch_dt_tm > cnvtdatetime(min_dsch_dt_tm)
        AND e.disch_dt_tm < cnvtdatetime(max_dsch_dt_tm)
        AND ((e.encntr_id+ 0) >= last_encntr_id_processed))
       JOIN (o
       WHERE o.encntr_id=e.encntr_id
        AND ((o.order_status_cd+ 0) IN (ordered_status_cd, inprocess_status_cd, medstudent_status_cd,
       incomplete_status_cd, suspended_status_cd))
        AND ((o.orig_ord_as_flag+ 0) IN (0, 5)))
      ORDER BY e.encntr_id
      HEAD e.encntr_id
       hold->enc_cnt += 1
       IF ((hold->enc_cnt > size(hold->enc,5)))
        stat = alterlist(hold->enc,(hold->enc_cnt+ 5))
       ENDIF
       hold->enc[hold->enc_cnt].ord_cnt = 0, hold->enc[hold->enc_cnt].encntr_id = e.encntr_id
      DETAIL
       cancel_ind = 0
       IF (o.cs_flag IN (1, 3, 4, 6))
        cancel_ind = 0
       ELSE
        cancel_ind = 0
        FOR (dd = 1 TO dstat->cnt)
          IF ((dstat->qual[dd].dstat_code_value=o.dept_status_cd))
           cancel_ind = 1
          ENDIF
        ENDFOR
       ENDIF
       IF (((o.template_order_flag=1) OR (((o.prn_ind=1) OR (((o.constant_ind=1) OR (o.freq_type_flag
       =5)) )) )) )
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
         stat = alterlist(hold->enc[hold->enc_cnt].ord,(oc+ 10))
        ENDIF
        hold->enc[hold->enc_cnt].ord[oc].order_id = o.order_id, hold->enc[hold->enc_cnt].ord[oc].
        catalog_cd = o.catalog_cd, hold->enc[hold->enc_cnt].ord[oc].catalog_type_cd = o
        .catalog_type_cd,
        hold->enc[hold->enc_cnt].ord[oc].updt_cnt = o.updt_cnt, hold->enc[hold->enc_cnt].ord[oc].
        oe_format_id = o.oe_format_id
        IF (o.current_start_dt_tm < cnvtdatetime(sysdate)
         AND o.order_status_cd != medstudent_status_cd)
         hold->enc[hold->enc_cnt].ord[oc].order_status_cd = discontinued_status_cd, hold->enc[hold->
         enc_cnt].ord[oc].action_type_cd = discontinue_action_cd, hold->enc[hold->enc_cnt].ord[oc].
         action = "DISCONTINUE"
        ELSE
         hold->enc[hold->enc_cnt].ord[oc].order_status_cd = canceled_status_cd, hold->enc[hold->
         enc_cnt].ord[oc].action_type_cd = cancel_action_cd, hold->enc[hold->enc_cnt].ord[oc].action
          = "CANCEL"
        ENDIF
        number_of_orders += 1
       ENDIF
       cur_rec_processed += 1
      FOOT  e.encntr_id
       stat = alterlist(hold->enc[hold->enc_cnt].ord,oc), last_encntr_id_processed = e.encntr_id
      WITH nocounter, maxrec = value(max_order_qual_cnt)
     ;end select
    ENDIF
   ENDIF
   IF (dsch_cancel_flag=2)
    IF (cancel_all_encntr_types="N")
     SELECT INTO "nl:"
      e.encntr_id, o.order_id, oc.catalog_cd
      FROM encounter e,
       orders o,
       order_catalog oc
      PLAN (e
       WHERE e.disch_dt_tm > cnvtdatetime(min_dsch_dt_tm)
        AND e.disch_dt_tm < cnvtdatetime(max_dsch_dt_tm)
        AND ((e.encntr_type_class_cd+ 0)=inpatient_cd)
        AND ((e.encntr_id+ 0) >= last_encntr_id_processed))
       JOIN (o
       WHERE o.encntr_id=e.encntr_id
        AND ((o.order_status_cd+ 0) IN (ordered_status_cd, inprocess_status_cd, medstudent_status_cd,
       incomplete_status_cd, suspended_status_cd))
        AND o.orig_ord_as_flag IN (0, 5))
       JOIN (oc
       WHERE oc.catalog_cd=o.catalog_cd)
      ORDER BY e.encntr_id
      HEAD e.encntr_id
       hold->enc_cnt += 1
       IF ((hold->enc_cnt > size(hold->enc,5)))
        stat = alterlist(hold->enc,(hold->enc_cnt+ 5))
       ENDIF
       hold->enc[hold->enc_cnt].ord_cnt = 0, hold->enc[hold->enc_cnt].encntr_id = e.encntr_id
      DETAIL
       cancel_ind = 0
       IF (o.cs_flag IN (1, 3, 4, 6))
        cancel_ind = 0
       ELSE
        cancel_ind = 0
        FOR (dd = 1 TO dstat->cnt)
          IF ((dstat->qual[dd].dstat_code_value=o.dept_status_cd))
           cancel_ind = 1
          ENDIF
        ENDFOR
       ENDIF
       orc_cancel_ind = 0
       IF (((o.template_order_flag=1) OR (((o.prn_ind=1) OR (((o.constant_ind=1) OR (((oc
       .auto_cancel_ind=1) OR (o.freq_type_flag=5)) )) )) )) )
        orc_cancel_ind = 1
        IF (((o.template_order_flag=1) OR (((o.prn_ind=1) OR (((o.constant_ind=1) OR (o
        .freq_type_flag=5)) )) )) )
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
        catalog_cd = o.catalog_cd, hold->enc[hold->enc_cnt].ord[oc].catalog_type_cd = o
        .catalog_type_cd,
        hold->enc[hold->enc_cnt].ord[oc].updt_cnt = o.updt_cnt, hold->enc[hold->enc_cnt].ord[oc].
        oe_format_id = o.oe_format_id
        IF (o.current_start_dt_tm < cnvtdatetime(sysdate)
         AND o.order_status_cd != medstudent_status_cd)
         hold->enc[hold->enc_cnt].ord[oc].order_status_cd = discontinued_status_cd, hold->enc[hold->
         enc_cnt].ord[oc].action_type_cd = discontinue_action_cd, hold->enc[hold->enc_cnt].ord[oc].
         action = "DISCONTINUE"
        ELSE
         hold->enc[hold->enc_cnt].ord[oc].order_status_cd = canceled_status_cd, hold->enc[hold->
         enc_cnt].ord[oc].action_type_cd = cancel_action_cd, hold->enc[hold->enc_cnt].ord[oc].action
          = "CANCEL"
        ENDIF
        number_of_orders += 1
       ENDIF
       cur_rec_processed += 1
      FOOT  e.encntr_id
       stat = alterlist(hold->enc[hold->enc_cnt].ord,oc), last_encntr_id_processed = e.encntr_id
      WITH nocounter, maxrec = value(max_order_qual_cnt)
     ;end select
    ELSE
     SELECT INTO "nl:"
      e.encntr_id, o.order_id, oc.catalog_cd
      FROM encounter e,
       orders o,
       order_catalog oc
      PLAN (e
       WHERE e.disch_dt_tm > cnvtdatetime(min_dsch_dt_tm)
        AND e.disch_dt_tm < cnvtdatetime(max_dsch_dt_tm)
        AND ((e.encntr_id+ 0) >= last_encntr_id_processed))
       JOIN (o
       WHERE o.encntr_id=e.encntr_id
        AND ((o.order_status_cd+ 0) IN (ordered_status_cd, inprocess_status_cd, medstudent_status_cd,
       incomplete_status_cd, suspended_status_cd))
        AND o.orig_ord_as_flag IN (0, 5))
       JOIN (oc
       WHERE oc.catalog_cd=o.catalog_cd)
      ORDER BY e.encntr_id
      HEAD e.encntr_id
       hold->enc_cnt += 1
       IF ((hold->enc_cnt > size(hold->enc,5)))
        stat = alterlist(hold->enc,(hold->enc_cnt+ 5))
       ENDIF
       hold->enc[hold->enc_cnt].ord_cnt = 0, hold->enc[hold->enc_cnt].encntr_id = e.encntr_id
      DETAIL
       cancel_ind = 0
       IF (o.cs_flag IN (1, 3, 4, 6))
        cancel_ind = 0
       ELSE
        cancel_ind = 0
        FOR (dd = 1 TO dstat->cnt)
          IF ((dstat->qual[dd].dstat_code_value=o.dept_status_cd))
           cancel_ind = 1
          ENDIF
        ENDFOR
       ENDIF
       orc_cancel_ind = 0
       IF (((o.template_order_flag=1) OR (((o.prn_ind=1) OR (((o.constant_ind=1) OR (((oc
       .auto_cancel_ind=1) OR (o.freq_type_flag=5)) )) )) )) )
        orc_cancel_ind = 1
        IF (((o.template_order_flag=1) OR (((o.prn_ind=1) OR (((o.constant_ind=1) OR (o
        .freq_type_flag=5)) )) )) )
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
        catalog_cd = o.catalog_cd, hold->enc[hold->enc_cnt].ord[oc].catalog_type_cd = o
        .catalog_type_cd,
        hold->enc[hold->enc_cnt].ord[oc].updt_cnt = o.updt_cnt, hold->enc[hold->enc_cnt].ord[oc].
        oe_format_id = o.oe_format_id
        IF (o.current_start_dt_tm < cnvtdatetime(sysdate)
         AND o.order_status_cd != medstudent_status_cd)
         hold->enc[hold->enc_cnt].ord[oc].order_status_cd = discontinued_status_cd, hold->enc[hold->
         enc_cnt].ord[oc].action_type_cd = discontinue_action_cd, hold->enc[hold->enc_cnt].ord[oc].
         action = "DISCONTINUE"
        ELSE
         hold->enc[hold->enc_cnt].ord[oc].order_status_cd = canceled_status_cd, hold->enc[hold->
         enc_cnt].ord[oc].action_type_cd = cancel_action_cd, hold->enc[hold->enc_cnt].ord[oc].action
          = "CANCEL"
        ENDIF
        number_of_orders += 1
       ENDIF
       cur_rec_processed += 1
      FOOT  e.encntr_id
       stat = alterlist(hold->enc[hold->enc_cnt].ord,oc), last_encntr_id_processed = e.encntr_id
      WITH nocounter, maxrec = value(max_order_qual_cnt)
     ;end select
    ENDIF
   ENDIF
   IF (dsch_cancel_flag=3)
    IF (cancel_all_encntr_types="N")
     SELECT INTO "nl:"
      e.encntr_id, o.order_id
      FROM encounter e,
       orders o
      PLAN (e
       WHERE e.disch_dt_tm > cnvtdatetime(min_dsch_dt_tm)
        AND e.disch_dt_tm < cnvtdatetime(max_dsch_dt_tm)
        AND ((e.encntr_type_class_cd+ 0)=inpatient_cd)
        AND ((e.encntr_id+ 0) >= last_encntr_id_processed))
       JOIN (o
       WHERE o.encntr_id=e.encntr_id
        AND ((o.order_status_cd+ 0) IN (ordered_status_cd, inprocess_status_cd, medstudent_status_cd,
       incomplete_status_cd, suspended_status_cd))
        AND o.orig_ord_as_flag IN (0, 5)
        AND ((o.template_order_flag=1) OR (((o.prn_ind=1) OR (((o.constant_ind=1) OR (o
       .freq_type_flag=5)) )) )) )
      ORDER BY e.encntr_id
      HEAD e.encntr_id
       hold->enc_cnt += 1
       IF ((hold->enc_cnt > size(hold->enc,5)))
        stat = alterlist(hold->enc,(hold->enc_cnt+ 5))
       ENDIF
       hold->enc[hold->enc_cnt].ord_cnt = 0, hold->enc[hold->enc_cnt].encntr_id = e.encntr_id
      DETAIL
       hold->enc[hold->enc_cnt].ord_cnt += 1, oc = hold->enc[hold->enc_cnt].ord_cnt
       IF (oc > size(hold->enc[hold->enc_cnt].ord,5))
        stat = alterlist(hold->enc[hold->enc_cnt].ord,(oc+ 10))
       ENDIF
       hold->enc[hold->enc_cnt].ord[oc].order_id = o.order_id, hold->enc[hold->enc_cnt].ord[oc].
       catalog_cd = o.catalog_cd, hold->enc[hold->enc_cnt].ord[oc].catalog_type_cd = o
       .catalog_type_cd,
       hold->enc[hold->enc_cnt].ord[oc].updt_cnt = o.updt_cnt, hold->enc[hold->enc_cnt].ord[oc].
       oe_format_id = o.oe_format_id
       IF (o.current_start_dt_tm < cnvtdatetime(sysdate)
        AND o.order_status_cd != medstudent_status_cd)
        hold->enc[hold->enc_cnt].ord[oc].order_status_cd = discontinued_status_cd, hold->enc[hold->
        enc_cnt].ord[oc].action_type_cd = discontinue_action_cd, hold->enc[hold->enc_cnt].ord[oc].
        action = "DISCONTINUE"
       ELSE
        hold->enc[hold->enc_cnt].ord[oc].order_status_cd = canceled_status_cd, hold->enc[hold->
        enc_cnt].ord[oc].action_type_cd = cancel_action_cd, hold->enc[hold->enc_cnt].ord[oc].action
         = "CANCEL"
       ENDIF
       number_of_orders += 1, cur_rec_processed += 1
      FOOT  e.encntr_id
       stat = alterlist(hold->enc[hold->enc_cnt].ord,oc), last_encntr_id_processed = e.encntr_id
      WITH nocounter, maxrec = value(max_order_qual_cnt)
     ;end select
    ELSE
     SELECT INTO "nl:"
      e.encntr_id, o.order_id
      FROM encounter e,
       orders o
      PLAN (e
       WHERE e.disch_dt_tm > cnvtdatetime(min_dsch_dt_tm)
        AND e.disch_dt_tm < cnvtdatetime(max_dsch_dt_tm)
        AND ((e.encntr_id+ 0) >= last_encntr_id_processed))
       JOIN (o
       WHERE o.encntr_id=e.encntr_id
        AND ((o.order_status_cd+ 0) IN (ordered_status_cd, inprocess_status_cd, medstudent_status_cd,
       incomplete_status_cd, suspended_status_cd))
        AND o.orig_ord_as_flag IN (0, 5)
        AND ((o.template_order_flag=1) OR (((o.prn_ind=1) OR (((o.constant_ind=1) OR (o
       .freq_type_flag=5)) )) )) )
      ORDER BY e.encntr_id
      HEAD e.encntr_id
       hold->enc_cnt += 1
       IF ((hold->enc_cnt > size(hold->enc,5)))
        stat = alterlist(hold->enc,(hold->enc_cnt+ 5))
       ENDIF
       hold->enc[hold->enc_cnt].ord_cnt = 0, hold->enc[hold->enc_cnt].encntr_id = e.encntr_id
      DETAIL
       hold->enc[hold->enc_cnt].ord_cnt += 1, oc = hold->enc[hold->enc_cnt].ord_cnt
       IF (oc > size(hold->enc[hold->enc_cnt].ord,5))
        stat = alterlist(hold->enc[hold->enc_cnt].ord,(oc+ 10))
       ENDIF
       hold->enc[hold->enc_cnt].ord[oc].order_id = o.order_id, hold->enc[hold->enc_cnt].ord[oc].
       catalog_cd = o.catalog_cd, hold->enc[hold->enc_cnt].ord[oc].catalog_type_cd = o
       .catalog_type_cd,
       hold->enc[hold->enc_cnt].ord[oc].updt_cnt = o.updt_cnt, hold->enc[hold->enc_cnt].ord[oc].
       oe_format_id = o.oe_format_id
       IF (o.current_start_dt_tm < cnvtdatetime(sysdate)
        AND o.order_status_cd != medstudent_status_cd)
        hold->enc[hold->enc_cnt].ord[oc].order_status_cd = discontinued_status_cd, hold->enc[hold->
        enc_cnt].ord[oc].action_type_cd = discontinue_action_cd, hold->enc[hold->enc_cnt].ord[oc].
        action = "DISCONTINUE"
       ELSE
        hold->enc[hold->enc_cnt].ord[oc].order_status_cd = canceled_status_cd, hold->enc[hold->
        enc_cnt].ord[oc].action_type_cd = cancel_action_cd, hold->enc[hold->enc_cnt].ord[oc].action
         = "CANCEL"
       ENDIF
       number_of_orders += 1, cur_rec_processed += 1
      FOOT  e.encntr_id
       stat = alterlist(hold->enc[hold->enc_cnt].ord,oc), last_encntr_id_processed = e.encntr_id
      WITH nocounter, maxrec = value(max_order_qual_cnt)
     ;end select
    ENDIF
   ENDIF
   IF (max_order_qual_cnt > cur_rec_processed)
    SET workload_complete_ind = 1
    CALL echo(">> Complete with qualification.")
   ELSE
    CALL echo(
     ">> Reached maximum qualification, will re-attempt after processing current qualification.")
   ENDIF
   CALL message_line("********************")
   CALL echo(build2(">> Number of qualified encounters = ",build(hold->enc_cnt)))
   CALL echo(build2(">> Number of qualified orders = ",build(number_of_orders)))
   IF (debug_mode_on)
    SET current_time = cnvtdatetime(sysdate)
    CALL echo(build2(">> Time cost to qualify orders = ",trim(cnvtstring(round(datetimediff(
          current_time,previous_time,5),3),7,3)),"s"))
    SET previous_time = current_time
   ENDIF
   IF (number_of_orders > 0)
    CALL echo(build2(">> Orders will be processed in blocks of: ",build((ows_block_size *
       number_of_servers))))
    CALL echo(">> Updating qualified orders...")
   ENDIF
   CALL message_line("********************")
   SET stat = alterlist(hold->enc,hold->enc_cnt)
   FOR (encntr = 1 TO hold->enc_cnt)
     FOR (ord = 1 TO hold->enc[encntr].ord_cnt)
       SET orders_counter += 1
       SET remainder_of_orders_in_req = mod(orders_counter,(number_of_servers * ows_block_size))
       IF (((number_of_servers=1) OR (remainder_of_orders_in_req > 0
        AND remainder_of_orders_in_req <= ows_block_size)) )
        SET hitem = uar_srvadditem(sync_hreq,"orderList")
       ELSE
        SET hitem = uar_srvadditem(async_hreq,"orderList")
       ENDIF
       CALL populateorderwriterequest(hitem,hold->enc[encntr].ord[ord].order_id,hold->enc[encntr].
        ord[ord].action_type_cd,hold->enc[encntr].ord[ord].oe_format_id,hold->enc[encntr].ord[ord].
        catalog_type_cd,
        hold->enc[encntr].ord[ord].updt_cnt,hold->enc[encntr].ord[ord].catalog_cd,hold->enc[encntr].
        ord[ord].order_status_cd,disc_type_cd)
       IF (mod(orders_counter,ows_block_size)=0)
        IF (((number_of_servers=1) OR (remainder_of_orders_in_req > 0
         AND remainder_of_orders_in_req <= ows_block_size)) )
         SET crmstatus = callorderwriteserver(sync_hstep,ows_block_size,debug_mode_on)
         CALL uar_srvreset(sync_hreq,0)
        ELSE
         SET crmstatus = callorderwriteserver(async_hstep,ows_block_size,0)
         CALL uar_srvreset(async_hreq,0)
        ENDIF
        IF (debug_mode_on)
         CALL message_line(build2("Memory Status after ",build((orders_counter/ ows_block_size)),
           " call/calls to the server"))
         CALL trace(7)
         CALL message_line("********************************************************")
        ENDIF
        IF (crmstatus != crm_ok)
         IF (crmstatus=crm_com_error)
          CALL echo("Error: Problem communicating with Order Write Server!")
         ELSE
          CALL echo("Error: CRM error in calling Order Write Server")
         ENDIF
         CALL echo(build("Crm Status:",crmstatus))
         GO TO exit_script
        ENDIF
        IF (mod(orders_counter,(ows_block_size * number_of_servers))=0)
         CALL logorderwriteprogress((ows_block_size * number_of_servers),orders_counter,
          number_of_orders)
         IF (debug_mode_on)
          SET current_time = cnvtdatetime(sysdate)
          CALL echo(build2("> Time cost to process ",build((ows_block_size * number_of_servers)),
            " orders = ",trim(cnvtstring(round(datetimediff(current_time,previous_time,5),2),7,2)),
            "s"))
          SET previous_time = current_time
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   IF (mod(orders_counter,ows_block_size) != 0)
    SET remainder_of_orders_in_req = mod(orders_counter,(number_of_servers * ows_block_size))
    IF (((number_of_servers=1) OR (remainder_of_orders_in_req > 0
     AND remainder_of_orders_in_req <= ows_block_size)) )
     SET crmstatus = callorderwriteserver(sync_hstep,ows_block_size,debug_mode_on)
     CALL uar_srvreset(sync_hreq,0)
    ELSE
     SET crmstatus = callorderwriteserver(async_hstep,ows_block_size,0)
     CALL uar_srvreset(async_hreq,0)
    ENDIF
    IF (debug_mode_on)
     CALL message_line(build2("Memory Status after ",build(((orders_counter/ ows_block_size)+ 1)),
       " call/calls to the server"))
     CALL trace(7)
     CALL message_line("********************************************************")
    ENDIF
    IF (crmstatus != crm_ok)
     IF (crmstatus=crm_com_error)
      CALL echo("Error: Problem communicating with Order Write Server!")
     ELSE
      CALL echo("Error: CRM error in calling Order Write Server")
     ENDIF
     CALL echo(build("Crm Status:",crmstatus))
     GO TO exit_script
    ENDIF
    CALL logorderwriteprogress(mod(orders_counter,(ows_block_size * number_of_servers)),
     orders_counter,number_of_orders)
    IF (debug_mode_on)
     SET current_time = cnvtdatetime(sysdate)
     CALL echo(build2("> Time cost to process ",build(mod(orders_counter,(ows_block_size *
         number_of_servers)))," orders = ",trim(cnvtstring(round(datetimediff(current_time,
           previous_time,5),2),7,2)),"s"))
    ENDIF
   ENDIF
   IF (mod(orders_counter,ows_block_size)=0
    AND mod(orders_counter,(ows_block_size * number_of_servers)) != 0)
    CALL logorderwriteprogress(mod(orders_counter,(ows_block_size * number_of_servers)),
     orders_counter,number_of_orders)
    IF (debug_mode_on)
     SET current_time = cnvtdatetime(sysdate)
     CALL echo(build2("> Time cost to process ",build(mod(orders_counter,(ows_block_size *
         number_of_servers)))," orders = ",trim(cnvtstring(round(datetimediff(current_time,
           previous_time,5),2),7,2)),"s"))
    ENDIF
   ENDIF
 ENDWHILE
#exit_script
 IF (failed_ind=0)
  SET reply->status_data.status = "S"
 ELSE
  CALL echo("Error occured!")
  SET reply->status_data.status = "F"
 ENDIF
 IF (sync_hstep != 0)
  CALL uar_crmendreq(sync_hstep)
  SET sync_hstep = 0
 ENDIF
 IF (number_of_servers > 1)
  IF (async_hstep != 0)
   CALL uar_crmendreq(async_hstep)
   SET async_hstep = 0
  ENDIF
 ENDIF
 IF (htask != 0)
  CALL uar_crmendtask(htask)
  SET htask = 0
 ENDIF
 IF (happ != 0)
  CALL uar_crmendapp(happ)
  SET happ = 0
 ENDIF
 FREE RECORD hold
 FREE RECORD dstat
END GO
