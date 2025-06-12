CREATE PROGRAM dcp_get_bill_code_dup:dba
 RECORD reply(
   1 orders[*]
     2 order_id = f8
     2 dup_orders[*]
       3 dup_order_id = f8
       3 hna_order_mnemonic = vc
       3 clinical_display_line = vc
       3 order_status_cd = f8
   1 returnval = i4
   1 statusmsg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD templateord(
   1 orders[*]
     2 order_id = f8
     2 catalog_cd = f8
     2 start_dt_tm = dq8
     2 abn_status_cd = f8
     2 bill_codes[*]
       3 bill_code = vc
       3 bill_code_type_cd = f8
 )
 RECORD profileord(
   1 orders[*]
     2 order_id = f8
     2 clinical_display_line = vc
     2 hna_order_mnemonic = vc
     2 catalog_cd = f8
     2 start_dt_tm = dq8
     2 related_sp_order_id = f8
     2 order_status_cd = f8
     2 bill_codes[*]
       3 bill_code = vc
       3 bill_code_type_cd = f8
 )
 RECORD sptempord(
   1 orders[*]
     2 order_id = f8
     2 catalog_cd = f8
     2 start_dt_tm = dq8
     2 abn_status_cd = f8
     2 clinical_display_line = c255
     2 hna_order_mnemonic = c100
     2 action_type_cd = f8
     2 bill_codes[*]
       3 bill_code = vc
       3 bill_code_type_cd = f8
 )
 RECORD catalog_request(
   1 qual[*]
     2 catalog_cd = f8
 )
 RECORD catalog_reply(
   1 qual[*]
     2 catalog_cd = f8
     2 bill[*]
       3 bill_code = vc
       3 sequence = f8
       3 nomen_entity_name = vc
       3 nomen_entity_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(errors,0)))
  RECORD errors(
    1 err_cnt = i4
    1 err[*]
      2 err_code = i4
      2 err_msg = vc
  ) WITH protect
 ENDIF
 DECLARE errcode = i4 WITH noconstant(0), protect
 DECLARE errcnt = i4 WITH noconstant(0), protect
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," ")), protect
 DECLARE nsuccess = i2 WITH constant(0), private
 DECLARE nfailed_ccl_error = i2 WITH constant(1), private
 DECLARE nfailed_code_value_query = i2 WITH constant(1), private
 DECLARE icnt = i4 WITH noconstant(0), protect
 DECLARE icnt1 = i4 WITH noconstant(0), protect
 DECLARE icnt2 = i4 WITH noconstant(0), protect
 DECLARE icnt3 = i4 WITH noconstant(0), protect
 DECLARE icnt4 = i4 WITH noconstant(0), protect
 DECLARE icnt5 = i4 WITH noconstant(0), protect
 DECLARE icnt6 = i4 WITH noconstant(0), protect
 DECLARE nperformdupcheck = i2 WITH noconstant(0), protect
 DECLARE sreturnmsg = vc WITH noconstant(""), protect
 DECLARE dnotrequired = f8 WITH noconstant(0.0), protect
 DECLARE returnval = i4 WITH noconstant(0), protect
 DECLARE nfailed = i4 WITH constant(- (1)), protect
 DECLARE nfalse = i4 WITH constant(0), protect
 DECLARE nno_orders_in_request = i4 WITH constant(10), protect
 DECLARE norders_not_covered = i4 WITH constant(20), protect
 DECLARE ntrue = i4 WITH constant(100), protect
 DECLARE scptmodifier = c11 WITH constant("CPTMODIFIER"), protect
 DECLARE nreqordercnt = i2 WITH noconstant(size(request->orders,5)), protect
 DECLARE norddetcnt = i2 WITH noconstant(0), protect
 DECLARE ndoescatcdexist = i2 WITH noconstant(0), protect
 DECLARE nisadup = i2 WITH noconstant(0), protect
 DECLARE dordered = f8 WITH noconstant(0.0), protect
 DECLARE dcompleted = f8 WITH noconstant(0.0), protect
 DECLARE dpendingcomplete = f8 WITH noconstant(0.0), protect
 DECLARE dpendingreview = f8 WITH noconstant(0.0), protect
 DECLARE dinprocess = f8 WITH noconstant(0.0), protect
 DECLARE donhold = f8 WITH noconstant(0.0), protect
 DECLARE bhascptmodifier = i2 WITH noconstant(0), protect
 DECLARE nscriptstatus = i2 WITH private, noconstant(nsuccess)
 DECLARE nqualstatus = i2 WITH private, noconstant(nsuccess)
 DECLARE stat = i2 WITH private, noconstant(0)
 DECLARE dcodeset = i4 WITH private, noconstant(0)
 DECLARE scdfmeaning = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c20 WITH private, noconstant(fillstring(20," "))
 IF (nreqordercnt=0)
  SET returnval = nno_orders_in_request
  CALL echo("Zero orders in request, exiting duplicate cpt4 script")
  GO TO exit_script
 ENDIF
 CALL echo("******************************")
 CALL echo("Looking for code values...")
 CALL echo("******************************")
 SET dcodeset = 27112.0
 SET scdfmeaning = "NOTREQUIRED"
 SET stat = uar_get_meaning_by_codeset(dcodeset,scdfmeaning,1,dnotrequired)
 CALL echo(build("Medically Necessary Cd: ",dnotrequired))
 SET dcodeset = 6004.0
 SET scdfmeaning = "ORDERED"
 SET stat = uar_get_meaning_by_codeset(dcodeset,scdfmeaning,1,dordered)
 CALL echo(build("Ordered Cd: ",dordered))
 SET scdfmeaning = "COMPLETED"
 SET stat = uar_get_meaning_by_codeset(dcodeset,scdfmeaning,1,dcompleted)
 CALL echo(build("Completed Cd: ",dcompleted))
 SET scdfmeaning = "PENDING"
 SET stat = uar_get_meaning_by_codeset(dcodeset,scdfmeaning,1,dpendingcomplete)
 CALL echo(build("Pending Complete Cd: ",dpendingcomplete))
 SET scdfmeaning = "PENDING REV"
 SET stat = uar_get_meaning_by_codeset(dcodeset,scdfmeaning,1,dpendingreview)
 CALL echo(build("Pending Review Cd: ",dpendingreview))
 SET scdfmeaning = "INPROCESS"
 SET stat = uar_get_meaning_by_codeset(dcodeset,scdfmeaning,1,dinprocess)
 CALL echo(build("In Process Cd: ",dinprocess))
 SET scdfmeaning = "MEDSTUDENT"
 SET stat = uar_get_meaning_by_codeset(dcodeset,scdfmeaning,1,donhold)
 CALL echo(build("On Hold Cd: ",donhold))
 IF (((dnotrequired <= 0) OR (((donhold <= 0) OR (((dinprocess <= 0) OR (((dpendingreview <= 0) OR (
 ((dpendingcomplete <= 0) OR (((dcompleted <= 0) OR (dordered <= 0)) )) )) )) )) )) )
  CALL echo("Missing a required code value.")
  SET nqualstatus = nfailed_code_value_query
  SET returnval = nfailed
  GO TO exit_script
 ENDIF
 SET icnt2 = 0
 FOR (icnt = 1 TO nreqordercnt)
   SET norddetcnt = size(request->orders[icnt].detaillist,5)
   SET bhascptmodifier = false
   FOR (icnt1 = 1 TO norddetcnt)
     IF ((request->orders[icnt].detaillist[icnt1].oefieldmeaning=scptmodifier))
      IF ((request->orders[icnt].detaillist[icnt1].oefieldvalue > 0))
       CALL echo("This order has a CPTMODIFIER value > 0")
       SET bhascptmodifier = true
      ELSE
       CALL echo("This order does not have a CPTMODIFIER value")
      ENDIF
      SET icnt1 = norddetcnt
     ENDIF
   ENDFOR
   IF (bhascptmodifier=false)
    SET icnt2 = (icnt2+ 1)
    IF (icnt2 > size(templateord->orders,5))
     SET stat = alterlist(templateord->orders,(icnt2+ 10))
    ENDIF
    SET templateord->orders[icnt].order_id = request->orders[icnt].order_id
    SET templateord->orders[icnt].start_dt_tm = request->orders[icnt].start_dt_tm
    SET templateord->orders[icnt].catalog_cd = request->orders[icnt].catalog_cd
   ENDIF
 ENDFOR
 SET stat = alterlist(templateord->orders,icnt2)
 IF (size(templateord->orders,5) <= 0)
  CALL echo(
   "There are no orders to check duplicate bill codes for because there were modifiers on each order."
   )
  SET returnval = nno_orders_in_request
  GO TO exit_script
 ENDIF
 SET nreqordercnt = size(templateord->orders,5)
 CALL echo("******************************")
 CALL echo("Checking ABN Status...")
 CALL echo("******************************")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nreqordercnt),
   eem_abn_check eac
  PLAN (d)
   JOIN (eac
   WHERE (eac.parent1_id=templateord->orders[d.seq].order_id)
    AND eac.parent1_table="ORDERS")
  DETAIL
   eac.parent1_id, templateord->orders[d.seq].abn_status_cd = eac.high_status_cd,
   CALL echo(build("MedStatusCd for order_id:",templateord->orders[d.seq].order_id," . ",eac
    .high_status_meaning))
  WITH nocounter
 ;end select
 SET nperformdupcheck = false
 FOR (icnt = 1 TO nreqordercnt)
   IF ((((templateord->orders[icnt].abn_status_cd=dnotrequired)) OR ((templateord->orders[icnt].
   abn_status_cd=0)))
    AND nperformdupcheck=false)
    SET nperformdupcheck = true
    CALL echo("Found an order that requires duplicate checking in the request")
    SET icnt = nreqordercnt
   ENDIF
 ENDFOR
 IF (nperformdupcheck=false)
  SET returnval = norders_not_covered
  CALL echo(
   "All the orders in this request are _not covered_, duplicate checking will not be performed.")
  GO TO exit_script
 ENDIF
 CALL echo("******************************")
 CALL echo("Retrieving Profile Orders...")
 CALL echo("******************************")
 SET icnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nreqordercnt),
   orders o
  PLAN (d
   WHERE d.seq > 0)
   JOIN (o
   WHERE (o.encntr_id=request->encntr_id)
    AND (o.person_id=request->person_id)
    AND o.current_start_dt_tm BETWEEN cnvtdatetime(cnvtdate(request->orders[d.seq].start_dt_tm),0)
    AND cnvtdatetime(cnvtdate(request->orders[d.seq].start_dt_tm),235959)
    AND o.template_order_id=0
    AND o.order_status_cd IN (dordered, dcompleted, dpendingcomplete, dpendingreview, dinprocess,
   donhold))
  ORDER BY o.order_id
  HEAD REPORT
   CALL echo("Profile Orders that qualify for checking:")
  HEAD o.order_id
   icnt = (icnt+ 1)
   IF (icnt > size(profileord->orders,5))
    stat = alterlist(profileord->orders,(icnt+ 10))
   ENDIF
   profileord->orders[icnt].order_id = o.order_id, profileord->orders[icnt].catalog_cd = o.catalog_cd,
   profileord->orders[icnt].start_dt_tm = o.current_start_dt_tm,
   profileord->orders[icnt].clinical_display_line = o.clinical_display_line, profileord->orders[icnt]
   .hna_order_mnemonic = o.hna_order_mnemonic, profileord->orders[icnt].related_sp_order_id = request
   ->orders[d.seq].order_id,
   profileord->orders[icnt].order_status_cd = o.order_status_cd,
   CALL echo(o.order_id)
  WITH nocounter
 ;end select
 SET stat = alterlist(profileord->orders,icnt)
 CALL echo(build("Number of Profile Orders that Qualified:",icnt))
 IF (size(profileord->orders,5)=0)
  SET returnval = nfalse
  CALL echo("--Zero orders found on the profile, no duplicates...exiting script")
  GO TO exit_script
 ENDIF
 CALL echo("******************************")
 CALL echo("Retrieving Bill Codes for Orders...")
 CALL echo("******************************")
 SET icnt3 = 0
 SET icnt6 = size(profileord->orders,5)
 FOR (icnt1 = 1 TO icnt6)
  CALL fxdoescatcdexist(profileord->orders[icnt1].catalog_cd)
  IF (ndoescatcdexist=false)
   SET icnt3 = (icnt3+ 1)
   IF (icnt1 > size(catalog_request->qual,5))
    SET stat = alterlist(catalog_request->qual,(icnt1+ 10))
   ENDIF
   SET catalog_request->qual[icnt1].catalog_cd = profileord->orders[icnt1].catalog_cd
   CALL echo(build("Added catalog cd:",profileord->orders[icnt1].catalog_cd))
  ENDIF
 ENDFOR
 SET stat = alterlist(catalog_request->qual,icnt3)
 SET icnt6 = size(templateord->orders,5)
 FOR (icnt1 = 1 TO icnt6)
  CALL fxdoescatcdexist(templateord->orders[icnt1].catalog_cd)
  IF (ndoescatcdexist=false)
   SET icnt3 = (icnt3+ 1)
   IF (icnt3 > size(catalog_request->qual,5))
    SET stat = alterlist(catalog_request->qual,(icnt3+ 10))
   ENDIF
   SET catalog_request->qual[icnt3].catalog_cd = templateord->orders[icnt1].catalog_cd
   CALL echo(build("Added catalog cd:",templateord->orders[icnt1].catalog_cd))
  ENDIF
 ENDFOR
 SET stat = alterlist(catalog_request->qual,icnt3)
 CALL echo("Executing dcp_get_bill_codes...")
 EXECUTE dcp_get_bill_codes  WITH replace("REQUEST","CATALOG_REQUEST"), replace("REPLY",
  "CATALOG_REPLY")
 CALL echo("Finished Executing dcp_get_bill_codes...")
 SET icnt6 = size(profileord->orders,5)
 FOR (icnt1 = 1 TO icnt6)
   FOR (icnt2 = 1 TO size(catalog_reply->qual,5))
     IF ((profileord->orders[icnt1].catalog_cd=catalog_reply->qual[icnt2].catalog_cd))
      SET stat = alterlist(profileord->orders[icnt1].bill_codes,size(catalog_reply->qual[icnt2].bill,
        5))
      FOR (icnt3 = 1 TO size(catalog_reply->qual[icnt2].bill,5))
       SET profileord->orders[icnt1].bill_codes[icnt3].bill_code = catalog_reply->qual[icnt2].bill[
       icnt3].bill_code
       SET profileord->orders[icnt1].bill_codes[icnt3].bill_code_type_cd = catalog_reply->qual[icnt2]
       .bill[icnt3].nomen_entity_id
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 SET icnt6 = size(templateord->orders,5)
 FOR (icnt1 = 1 TO icnt6)
   FOR (icnt2 = 1 TO size(catalog_reply->qual,5))
     IF ((templateord->orders[icnt1].catalog_cd=catalog_reply->qual[icnt2].catalog_cd))
      SET stat = alterlist(templateord->orders[icnt1].bill_codes,size(catalog_reply->qual[icnt2].bill,
        5))
      FOR (icnt3 = 1 TO size(catalog_reply->qual[icnt2].bill,5))
        SET icnt5 = (icnt5+ 1)
        SET templateord->orders[icnt1].bill_codes[icnt3].bill_code = catalog_reply->qual[icnt2].bill[
        icnt3].bill_code
        SET templateord->orders[icnt1].bill_codes[icnt3].bill_code_type_cd = catalog_reply->qual[
        icnt2].bill[icnt3].nomen_entity_id
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 CALL echo("******************************")
 CALL echo("Examining Profile Order's Bill Codes for Duplicates...")
 CALL echo("******************************")
 SET icnt5 = 0
 SET icnt6 = size(templateord->orders,5)
 FOR (icnt = 1 TO icnt6)
   SET nisadup = false
   SET icnt4 = 0
   IF ((((templateord->orders[icnt].abn_status_cd=dnotrequired)) OR ((templateord->orders[icnt].
   abn_status_cd=0))) )
    SET icnt5 = (icnt5+ 1)
    IF (icnt > size(reply->orders,5))
     SET stat = alterlist(reply->orders,(icnt+ 10))
    ENDIF
    SET reply->orders[icnt].order_id = templateord->orders[icnt].order_id
    FOR (icnt1 = 1 TO size(templateord->orders[icnt].bill_codes,5))
     SET sbillcd = templateord->orders[icnt].bill_codes[icnt1].bill_code
     FOR (icnt2 = 1 TO size(profileord->orders,5))
      FOR (icnt3 = 1 TO size(profileord->orders[icnt2].bill_codes,5))
       CALL echo(build("Checking .",sbillcd,"|",profileord->orders[icnt2].bill_codes[icnt3].bill_code
         ))
       IF ((sbillcd=profileord->orders[icnt2].bill_codes[icnt3].bill_code))
        CALL echo(build("A duplicate bill_code has been found at order_id: ",profileord->orders[icnt2
          ].order_id," for billCd: ",profileord->orders[icnt2].bill_codes[icnt3].bill_code))
        SET nisadup = true
        SET icnt3 = size(profileord->orders[icnt2].bill_codes,5)
       ENDIF
      ENDFOR
      IF (nisadup=true)
       SET icnt4 = (icnt4+ 1)
       SET returnval = ntrue
       IF (icnt4 > size(reply->orders[icnt].dup_orders,5))
        SET stat = alterlist(reply->orders[icnt].dup_orders,(icnt4+ 10))
       ENDIF
       SET reply->orders[icnt].dup_orders[icnt4].dup_order_id = profileord->orders[icnt2].order_id
       SET reply->orders[icnt].dup_orders[icnt4].clinical_display_line = profileord->orders[icnt2].
       clinical_display_line
       SET reply->orders[icnt].dup_orders[icnt4].hna_order_mnemonic = profileord->orders[icnt2].
       hna_order_mnemonic
       SET reply->orders[icnt].dup_orders[icnt4].order_status_cd = profileord->orders[icnt2].
       order_status_cd
       SET nisadup = false
       SET icnt1 = size(templateord->orders[icnt].bill_codes,5)
      ENDIF
     ENDFOR
    ENDFOR
    SET stat = alterlist(reply->orders[icnt].dup_orders,icnt4)
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->orders,icnt5)
 GO TO exit_script
 SUBROUTINE fxdoescatcdexist(catalog_cd)
  SET ndoescatcdexist = false
  FOR (icnt2 = 1 TO size(catalog_request->qual,5))
    IF ((catalog_cd=catalog_request->qual[icnt2].catalog_cd))
     SET ndoescatcdexist = true
     SET icnt2 = size(catalog_request->qual,5)
    ENDIF
  ENDFOR
 END ;Subroutine
#exit_script
 IF (returnval=nno_orders_in_request)
  SET returnval = nfalse
  SET sreturnmsg = "Zero orders in the request, duplicate checking not performed."
 ELSEIF (returnval=norders_not_covered)
  SET returnval = nfalse
  SET sreturnmsg = "All orders are not medically necessary, duplicate checking not performed."
 ELSEIF (returnval=nfailed)
  SET returnval = nfailed
  SET sreturnmsg = "Script failed for some reason, see srvrtl/msgview logs."
 ELSEIF (returnval=ntrue)
  SET returnval = ntrue
  SET sreturnmsg = "One or more profile orders contain a duplicate bill code."
 ELSEIF (returnval=nfalse)
  SET returnval = nfalse
  SET sreturnmsg = "There were no duplicate bill codes found."
 ENDIF
 SET reply->returnval = returnval
 SET reply->statusmsg = sreturnmsg
 CALL echorecord(request)
 CALL echorecord(templateord)
 CALL echorecord(profileord)
 CALL echorecord(reply)
 CALL echo("******************************")
 CALL echo("Freeing internal record structures...")
 CALL echo("******************************")
 FREE RECORD errors
 FREE RECORD templateord
 FREE RECORD profileord
 FREE RECORD catalog_request
 FREE RECORD catalog_reply
 FREE RECORD sptempord
 SET mod_date = "Feb 26, 2004"
 SET last_mod = "000"
 CALL echo("-")
 CALL echo(build("<----- END dcp_get_bill_code_dup (ver:",last_mod,":",mod_date,") ----->"))
 CALL echo("-")
END GO
