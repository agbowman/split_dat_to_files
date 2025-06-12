CREATE PROGRAM dcp_get_bill_code_dup_rule:dba
 RECORD dup_request(
   1 person_id = f8
   1 encntr_id = f8
   1 orders[*]
     2 order_id = f8
     2 start_dt_tm = dq8
     2 catalog_cd = f8
     2 detaillist[*]
       3 oefieldmeaning = vc
       3 oefieldvalue = f8
 )
 RECORD dup_reply(
   1 orders[*]
     2 order_id = f8
     2 dup_orders[*]
       3 dup_order_id = f8
       3 hna_order_mnemonic = vc
       3 clinical_display_line = vc
       3 order_status_cd = f8
       3 scratch_pad_ind = i2
   1 returnval = i4
   1 statusmsg = vc
 )
 CALL echo("******************************")
 CALL echo("Beginning DCP_GET_BILL_CODE_DUP_RULE...")
 CALL echo("******************************")
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
 DECLARE sreturnmsg = vc WITH noconstant(""), protect
 DECLARE nreqordercnt = i2 WITH noconstant(size(request->orderlist,5)), protect
 DECLARE nreqdetailcnt = i2 WITH noconstant(0), protect
 DECLARE nfailed = i4 WITH constant(- (1)), protect
 DECLARE ntrue = i4 WITH constant(100), protect
 DECLARE nfalse = i4 WITH constant(0), protect
 DECLARE nno_orders_in_request = i4 WITH constant(10), protect
 DECLARE norders_not_covered = i4 WITH constant(20), protect
 DECLARE lf = vc WITH constant(" @NEWLINE "), protect
 DECLARE nscriptstatus = i2 WITH private, noconstant(nsuccess)
 DECLARE nqualstatus = i2 WITH private, noconstant(nsuccess)
 DECLARE stat = i2 WITH private, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c20 WITH private, noconstant(fillstring(20," "))
 SET retval = 0
 IF (nreqordercnt=0)
  SET retval = nno_orders_in_request
  GO TO exit_script
 ENDIF
 SET dup_request->person_id = request->person_id
 SET dup_request->encntr_id = request->encntr_id
 SET stat = alterlist(dup_request->orders,value(nreqordercnt))
 FOR (icnt = 1 TO nreqordercnt)
   SET dup_request->orders[icnt].order_id = request->orderlist[icnt].orderid
   SET dup_request->orders[icnt].start_dt_tm = request->orderlist[icnt].start_dt_tm
   SET dup_request->orders[icnt].catalog_cd = request->orderlist[icnt].catalog_code
   SET nreqdetailcnt = size(request->orderlist[icnt].detaillist,5)
   SET stat = alterlist(dup_request->orders[icnt].detaillist,nreqdetailcnt)
   FOR (icnt1 = 1 TO nreqdetailcnt)
    SET dup_request->orders[icnt].detaillist[icnt1].oefieldmeaning = request->orderlist[icnt].
    detaillist[icnt1].oefieldmeaning
    SET dup_request->orders[icnt].detaillist[icnt1].oefieldvalue = request->orderlist[icnt].
    detaillist[icnt1].oefieldvalue
   ENDFOR
 ENDFOR
 CALL echorecord(dup_request)
 CALL echo("<--Executing dcp_get_bill_code_dup...")
 EXECUTE dcp_get_bill_code_dup  WITH replace("REQUEST","DUP_REQUEST"), replace("REPLY","DUP_REPLY")
 CALL echo("<--Finished Executing dcp_get_bill_codes...")
 SET retval = dup_reply->returnval
#exit_script
 CALL echo("<-- RULE: Translating retval -->")
 SET resp_txt_cnt = 0
 SET ocnt = size(dup_reply->orders,5)
 FOR (oidx = 1 TO ocnt)
   SET save_oidx = 0
   SET idx_str = concat(trim(cnvtstring(oidx)),"|")
   IF (size(dup_reply->orders[oidx].dup_orders,5) > 0)
    IF (resp_txt_cnt=0)
     SET resp_txt_cnt = (resp_txt_cnt+ 1)
     SET stat = alterlist(eksdata->tqual[3].qual[curindex].data,resp_txt_cnt)
     SET eksdata->tqual[3].qual[curindex].data[resp_txt_cnt].misc = "<SPINDEX>"
    ENDIF
    SET resp_txt_cnt = (resp_txt_cnt+ 1)
    SET stat = alterlist(eksdata->tqual[3].qual[curindex].data,resp_txt_cnt)
    SET icnt3 = size(dup_reply->orders[oidx].dup_orders,5)
    FOR (x = 1 TO icnt3)
      IF (oidx != save_oidx)
       SET eksdata->tqual[3].qual[curindex].data[resp_txt_cnt].misc = idx_str
       SET save_oidx = oidx
      ENDIF
      SET eksdata->tqual[3].qual[curindex].data[resp_txt_cnt].misc = concat(eksdata->tqual[3].qual[
       curindex].data[resp_txt_cnt].misc,trim(dup_reply->orders[oidx].dup_orders[x].
        hna_order_mnemonic,3),"-",dup_reply->orders[oidx].dup_orders[x].clinical_display_line,lf)
      CALL echo(build("MISC-",eksdata->tqual[3].qual[curindex].data[resp_txt_cnt].misc))
    ENDFOR
   ENDIF
 ENDFOR
 IF (retval=nno_orders_in_request)
  SET sreturnmsg = "There were 0 orders in the request, checking will not be performed"
  CALL echo(sreturnmsg)
  SET retval = nfalse
 ELSEIF (retval=norders_not_covered)
  SET sreturnmsg = "The orders required patient signatures, checking will not be performed"
  CALL echo(sreturnmsg)
  SET retval = nfalse
 ELSEIF (retval=nfalse)
  SET sreturnmsg = "Checking did not find any duplicates"
  CALL echo(sreturnmsg)
 ELSEIF (retval=ntrue)
  SET sreturnmsg = "We have duplicate bill codes."
  CALL echo(sreturnmsg)
 ENDIF
 SET eksdata->tqual[3].qual[curindex].logging = sreturnmsg
 SET eksdata->tqual[3].qual[curindex].cnt = resp_txt_cnt
 SET eksdata->tqual[3].qual[curindex].person_id = request->person_id
 SET eksdata->tqual[3].qual[curindex].encntr_id = request->encntr_id
END GO
