CREATE PROGRAM bhs_ma_pathway_orders_cleanup:dba
 FREE RECORD reply
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
 DECLARE populateorderwriterequest(orderlistitem=i4,orderid=f8,actiontypecd=f8,oeformatid=f8,
  catalogtypecd=f8,
  updtcnt=i4,catalogcd=f8,orderstatuscd=f8,discontinuetypecd=f8) = null
 SUBROUTINE populateorderwriterequest(orderlistitem,orderid,actiontypecd,oeformatid,catalogtypecd,
  updtcnt,catalogcd,orderstatuscd,discontinuetypecd)
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
 DECLARE logorderwriteprogress(numberofreqitems=i4,currentnumberprocessed=i4,totalnumberprocessed=i4)
  = null
 SUBROUTINE logorderwriteprogress(numberofreqitems,currentnumberprocessed,totalnumberprocessed)
   CALL echo(build("> Process status update: [",numberofreqitems," items, ",format(((cnvtreal(
       currentnumberprocessed)/ cnvtreal(totalnumberprocessed)) * 100.0),"###.##"),"% complete]...")
    )
 END ;Subroutine
 DECLARE callorderwriteserver(stephandle=i4,requestlistsize=i4,logerrormessageind=i2) = i4
 SUBROUTINE callorderwriteserver(stephandle,requestlistsize,logerrormessageind)
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
 DECLARE getorderwriteerrormessagesfromreply(orderlistreplyitem=i4) = vc
 SUBROUTINE getorderwriteerrormessagesfromreply(orderlistreplyitem)
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
 DECLARE message_line(msg=vc) = null
 SUBROUTINE message_line(msg)
   CALL echo(build2("********************",msg,"********************"))
 END ;Subroutine
 FREE RECORD exception_criteria
 RECORD exception_criteria(
   1 criteria[*]
     2 pathway_catalog_id = f8
     2 time_qty = i4
     2 time_unit_cd = f8
 )
 FREE RECORD discontinue
 RECORD discontinue(
   1 phases[*]
     2 pw_group_nbr = f8
     2 pathway_id = f8
     2 encntr_id = f8
     2 updt_cnt = i4
     2 add_to_request_ind = i2
     2 type_mean = vc
     2 pathway_group_id = f8
 )
 FREE RECORD disc_orders
 RECORD disc_orders(
   1 orders_cnt = i4
   1 orders[*]
     2 order_id = f8
     2 order_status_cd = f8
     2 action_type_cd = f8
     2 action = c20
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 updt_cnt = i4
     2 oe_format_id = f8
 )
 DECLARE cstatus = c1 WITH protect, noconstant("Z")
 DECLARE cexpiretypemean = c12 WITH constant("EXPIRATION"), protect
 DECLARE ccareplantypemean = c12 WITH constant("CAREPLAN"), protect
 DECLARE cphasetypemean = c12 WITH constant("PHASE"), protect
 DECLARE csubphasetypemean = c12 WITH constant("SUBPHASE"), protect
 DECLARE cdottypemean = c12 WITH constant("DOT"), protect
 DECLARE stat = i2 WITH noconstant(0), protect
 DECLARE icriteriacnt = i4 WITH noconstant(0), protect
 DECLARE ddiscontinuedstatuscd = f8 WITH constant(uar_get_code_by("MEANING",16769,"DISCONTINUED")),
 protect
 DECLARE dhourscd = f8 WITH constant(uar_get_code_by("MEANING",340,"HOURS")), protect
 DECLARE iindex = i4 WITH noconstant(0), protect
 DECLARE itimeqty = i4 WITH noconstant(0), protect
 DECLARE dtimeunitcd = f8 WITH noconstant(0.0), protect
 DECLARE iglobaltimeqty = i4 WITH noconstant(0), protect
 DECLARE dglobaltimeunitcd = f8 WITH noconstant(dhourscd), protect
 DECLARE parameter_value = vc
 DECLARE imaxphasestodisc = i4 WITH noconstant(0), protect
 DECLARE ddate = dq8
 DECLARE dcurrentdate = dq8
 DECLARE iphasecnt = i4 WITH noconstant(0), protect
 DECLARE ocnt = i4 WITH noconstant(0), protect
 DECLARE loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE start = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, constant(20)
 DECLARE exception_size = i4 WITH protect, noconstant(0)
 DECLARE phase_size = i4 WITH protect, noconstant(0)
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 DECLARE 6003_cancel_action_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"CANCEL")), protect
 DECLARE 6003_discontinue_action_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"DISCONTINUE")),
 protect
 DECLARE 6004_voided_order_status_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!2488992")),
 protect
 DECLARE 6004_transfered_order_status_cd = f8 WITH constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!406488")), protect
 DECLARE 6004_discont_order_status_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3101")),
 protect
 DECLARE 6004_deleted_order_status_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!44311")),
 protect
 DECLARE 6004_completed_order_status_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3100")),
 protect
 DECLARE 6004_canceled_order_status_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3099")),
 protect
 DECLARE 4038_disc_type_cd = f8 WITH constant(uar_get_code_by("MEANING",4038,"SYSTEMDISCH")), protect
 DECLARE failed_ind = i2 WITH noconstant(0), protect
 DECLARE max_orders_size = i4 WITH constant(50)
 DECLARE debug_mode_on = i2 WITH noconstant(0)
 IF (validate(isdebug)=1)
  IF (build(isdebug)="1")
   SET debug_mode_on = 1
   CALL message_line("******************")
   CALL message_line(" Debug Mode is on ")
   CALL message_line("******************")
  ENDIF
 ENDIF
 SET parameter_value = parameter(1,0)
 IF (parameter_value=" ")
  SET imaxphasestodisc = 500
 ELSE
  SET imaxphasestodisc = cnvtint(parameter_value)
  IF (imaxphasestodisc < batch_size)
   SET imaxphasestodisc = batch_size
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM pw_maintenance_criteria pmc
  WHERE pmc.version_pw_cat_id=0
   AND pmc.type_mean=cexpiretypemean
  DETAIL
   iglobaltimeqty = pmc.time_qty, dglobaltimeunitcd = pmc.time_unit_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL report_failure("LOAD_GLOBAL_EXPIRATION_CRITERIA","F","DCP_OPS_PW_CLEANUP_EXPIRE",
   "Unable to find PW_MAINTENANCE_CRITERIA global expiration record")
  SET cstatus = "F"
  GO TO exit_script
 ELSEIF (curqual > 1)
  CALL report_failure("LOAD_GLOBAL_EXPIRATION_CRITERIA","F","DCP_OPS_PW_CLEANUP_EXPIRE",
   "Found invalid number of PW_MAINTENANCE_CRITERIA global expiration records")
  SET cstatus = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM pw_maintenance_criteria pmc,
   pathway_catalog pc
  PLAN (pmc
   WHERE pmc.type_mean=cexpiretypemean
    AND pmc.version_pw_cat_id != 0)
   JOIN (pc
   WHERE pmc.version_pw_cat_id=outerjoin(pc.version_pw_cat_id))
  ORDER BY pc.pathway_catalog_id
  HEAD REPORT
   icriteriacnt = 0, stat = alterlist(exception_criteria->criteria,5), exception_size = 5
  DETAIL
   icriteriacnt = (icriteriacnt+ 1)
   IF (icriteriacnt > exception_size)
    stat = alterlist(exception_criteria->criteria,(icriteriacnt+ 4)), exception_size = (icriteriacnt
    + 4)
   ENDIF
   exception_criteria->criteria[icriteriacnt].pathway_catalog_id = pc.pathway_catalog_id,
   exception_criteria->criteria[icriteriacnt].time_qty = pmc.time_qty, exception_criteria->criteria[
   icriteriacnt].time_unit_cd = pmc.time_unit_cd
  FOOT REPORT
   stat = alterlist(exception_criteria->criteria,icriteriacnt), exception_size = icriteriacnt
  WITH nocounter
 ;end select
 SELECT INTO "n1:"
  FROM pathway p
  WHERE p.pw_status_cd=ddiscontinuedstatuscd
   AND ((p.type_mean=ccareplantypemean) OR (((p.type_mean=cphasetypemean) OR (p.type_mean=
  cdottypemean)) ))
   AND p.pw_cat_group_id != 0
  ORDER BY p.pw_cat_group_id, p.pw_group_nbr, p.pathway_id
  HEAD REPORT
   iphasecnt = 0, stat = alterlist(discontinue->phases,batch_size), loop_cnt = 1,
   phase_size = batch_size, bexpireddot = 0, ifirstphase = 0,
   idiscontinueindex = 0, dcurrentdate = cnvtdatetime(curdate,curtime3), dcurrentdate =
   cnvtdatetimeutc(dcurrentdate,3)
  HEAD p.pw_cat_group_id
   iindex = locatevalsort(iindex,1,value(size(exception_criteria->criteria,5)),p.pw_cat_group_id,
    exception_criteria->criteria[iindex].pathway_catalog_id)
   IF (iindex > 0)
    itimeqty = exception_criteria->criteria[iindex].time_qty, dtimeunitcd = exception_criteria->
    criteria[iindex].time_unit_cd
   ELSE
    itimeqty = iglobaltimeqty, dtimeunitcd = dglobaltimeunitcd
   ENDIF
  HEAD p.pw_group_nbr
   bexpireddot = 0, ifirstphase = 0, idiscontinueindex = 0
   IF ((imaxphasestodisc <= (iphasecnt+ 1)))
    CALL cancel(1)
   ENDIF
  DETAIL
   IF (((p.pathway_group_id <= 0.0) OR (p.type_mean=cdottypemean)) )
    IF (p.start_dt_tm)
     ddate = cnvtdatetimeutc(p.start_dt_tm,3,p.start_tz)
    ELSE
     ddate = cnvtdatetimeutc(p.order_dt_tm,3,p.order_tz)
    ENDIF
    ddate = cnvtlookahead(build(itimeqty,",H"),cnvtdatetime(ddate)), ddate = datetimediff(
     cnvtdatetime(ddate),cnvtdatetime(dcurrentdate))
    IF (((ddate <= 0) OR (p.type_mean=cdottypemean)) )
     iphasecnt = (iphasecnt+ 1)
     IF (iphasecnt > phase_size)
      stat = alterlist(discontinue->phases,(iphasecnt+ (batch_size - 1))), loop_cnt = (loop_cnt+ 1),
      phase_size = (iphasecnt+ (batch_size - 1))
     ENDIF
     discontinue->phases[iphasecnt].pathway_id = p.pathway_id, discontinue->phases[iphasecnt].
     pw_group_nbr = p.pw_group_nbr, discontinue->phases[iphasecnt].encntr_id = p.encntr_id,
     discontinue->phases[iphasecnt].updt_cnt = p.updt_cnt, discontinue->phases[iphasecnt].type_mean
      = trim(p.type_mean), discontinue->phases[iphasecnt].pathway_group_id = p.pathway_group_id
     IF (ifirstphase=0)
      ifirstphase = iphasecnt
     ENDIF
     IF (((ddate <= 0) OR (bexpireddot=1
      AND p.type_mean=cdottypemean)) )
      discontinue->phases[iphasecnt].add_to_request_ind = 1
      IF (bexpireddot=0
       AND p.type_mean=cdottypemean)
       bexpireddot = 1
       IF (ifirstphase > 0)
        FOR (idiscontinueindex = ifirstphase TO iphasecnt)
          IF ((discontinue->phases[idiscontinueindex].type_mean=cdottypemean)
           AND (discontinue->phases[idiscontinueindex].pathway_group_id=p.pathway_group_id))
           discontinue->phases[idiscontinueindex].add_to_request_ind = 1
          ENDIF
        ENDFOR
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(discontinue->phases,iphasecnt), phase_size = iphasecnt
  WITH nocounter
 ;end select
 IF (iphasecnt <= 0)
  CALL report_failure("LOAD_PHASES TO DISCONTINUE","F","BHS_MA_PATHWAY_ORDERS_CLEANUP",
   "Unable to find careplans and phases to discontinue orders")
  SET cstatus = "F"
  GO TO exit_script
 ENDIF
 FOR (iindex = (iphasecnt+ 1) TO phase_size)
   SET discontinue->phases[iindex].pathway_id = discontinue->phases[iphasecnt].pathway_id
   SET discontinue->phases[iindex].pw_group_nbr = discontinue->phases[iphasecnt].pw_group_nbr
   SET discontinue->phases[iindex].encntr_id = discontinue->phases[iphasecnt].encntr_id
   SET discontinue->phases[iindex].updt_cnt = discontinue->phases[iphasecnt].updt_cnt
   SET discontinue->phases[iindex].add_to_request_ind = discontinue->phases[iphasecnt].
   add_to_request_ind
 ENDFOR
 SET disc_orders->orders_cnt = 0
 SET iindex = 0
 SET start = 1
 SELECT INTO "nl:"
  FROM pathway p,
   act_pw_comp apc,
   orders o
  PLAN (p
   WHERE expand(iindex,start,(start+ (batch_size - 1)),p.pathway_id,discontinue->phases[iindex].
    pathway_id)
    AND p.pw_status_cd=ddiscontinuedstatuscd)
   JOIN (apc
   WHERE apc.pathway_id=p.pathway_id
    AND apc.parent_entity_name="ORDERS"
    AND apc.active_ind=1)
   JOIN (o
   WHERE o.order_id=apc.parent_entity_id
    AND  NOT (o.order_status_cd IN (6004_voided_order_status_cd, 6004_transfered_order_status_cd,
   6004_discont_order_status_cd, 6004_deleted_order_status_cd, 6004_completed_order_status_cd,
   6004_canceled_order_status_cd))
    AND o.active_ind=1)
  HEAD REPORT
   ocnt = 0
  DETAIL
   ocnt = (ocnt+ 1)
   IF (mod(ocnt,20)=1)
    stat = alterlist(disc_orders->orders,(ocnt+ 19))
   ENDIF
   disc_orders->orders[ocnt].order_id = o.order_id, disc_orders->orders[ocnt].catalog_cd = o
   .catalog_cd, disc_orders->orders[ocnt].catalog_type_cd = o.catalog_type_cd,
   disc_orders->orders[ocnt].updt_cnt = o.updt_cnt, disc_orders->orders[ocnt].oe_format_id = o
   .oe_format_id
   IF (o.current_start_dt_tm < cnvtdatetime(curdate,curtime3))
    disc_orders->orders[ocnt].order_status_cd = 6004_discont_order_status_cd, disc_orders->orders[
    ocnt].action_type_cd = 6003_discontinue_action_cd, disc_orders->orders[ocnt].action =
    "DISCONTINUE"
   ELSE
    disc_orders->orders[ocnt].order_status_cd = 6004_canceled_order_status_cd, disc_orders->orders[
    ocnt].action_type_cd = 6003_cancel_action_cd, disc_orders->orders[ocnt].action = "CANCEL"
   ENDIF
  FOOT REPORT
   disc_orders->orders_cnt = ocnt, stat = alterlist(disc_orders->orders,ocnt)
  WITH nocounter
 ;end select
 IF ((disc_orders->orders_cnt=0))
  GO TO exit_script
 ENDIF
 CALL echorecord(disc_orders)
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
 DECLARE orders_counter = i4 WITH noconstant(0)
 FOR (ord = 1 TO disc_orders->orders_cnt)
   SET hitem = uar_srvadditem(hreq,"orderList")
   CALL populateorderwriterequest(hitem,disc_orders->orders[ord].order_id,disc_orders->orders[ord].
    action_type_cd,disc_orders->orders[ord].oe_format_id,disc_orders->orders[ord].catalog_type_cd,
    disc_orders->orders[ord].updt_cnt,disc_orders->orders[ord].catalog_cd,disc_orders->orders[ord].
    order_status_cd,4038_disc_type_cd)
   SET orders_counter = (orders_counter+ 1)
   IF (((mod(orders_counter,max_orders_size)=0) OR ((orders_counter=disc_orders->orders_cnt))) )
    SET failed_ind = callorderwriteserver(hstep,max_orders_size,debug_mode_on)
    CALL uar_srvreset(hreq,0)
    IF (debug_mode_on)
     CALL message_line(build2("Memory Status after ",build((orders_counter/ max_orders_size)),
       " call/calls to the server"))
     CALL trace(7)
     CALL message_line("********************************************************")
    ENDIF
    IF (failed_ind)
     GO TO exit_script
    ENDIF
    CALL logorderwriteprogress(max_orders_size,orders_counter,disc_orders->orders_cnt)
   ENDIF
 ENDFOR
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt = (cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,value(cnt))
   ENDIF
   SET reply->status_data.subeventstatus[cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[cnt].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[cnt].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
 SET cstatus = "S"
#exit_script
 SET reply->status_data.status = cstatus
END GO
