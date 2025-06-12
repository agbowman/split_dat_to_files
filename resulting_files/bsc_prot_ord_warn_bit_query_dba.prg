CREATE PROGRAM bsc_prot_ord_warn_bit_query:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 order_list[*]
     2 order_id = f8
     2 prot_warning_level_bit = i4
   1 protocol_order_list[*]
     2 order_id = f8
     2 corrupt_protocol_ord_ind = i2
     2 hover_tsk_protocol_ord_ind = i2
     2 template_order_list[*]
       3 order_id = f8
       3 corrupted_dot_found = i4
   1 result_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD protocolanddotorders
 RECORD protocolanddotorders(
   1 dot_ord_list[*]
     2 protocol_ord_id = f8
     2 uncorrupted_dot_cnt = i4
     2 dots[*]
       3 dot_ord_id = f8
       3 uncorrupted_dots = i2
 )
 FREE RECORD templateorders
 RECORD templateorders(
   1 tmp_ord_list[*]
     2 order_id = f8
     2 prot_warning_level_bit = i4
 )
 FREE RECORD dotorders
 RECORD dotorders(
   1 dot_ord_list[*]
     2 protocol_ord_id = f8
     2 dot_ord_id = f8
 )
 DECLARE initialize(null) = null
 DECLARE queryprotocolorder(null) = null
 DECLARE getprotocolorderforgivendotorder(null) = null
 DECLARE loaddotorders(null) = null
 DECLARE updatedotorderforprotocol(null) = null
 DECLARE loadtreatmentdescfordotorders(null) = null
 DECLARE populatereplyfordotorder(null) = null
 DECLARE updateuncorrupteddotorderscount(null) = null
 DECLARE findprotocolorderbygiventaskid = null
 DECLARE order_iter = i4 WITH protect, noconstant(0)
 DECLARE order_cnt = i4 WITH protect, noconstant(size(request->order_list,5))
 DECLARE reply_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_cd = i2 WITH protect, noconstant(0)
 DECLARE total_time = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
 DECLARE last_mod = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE proordcount = i4 WITH protect, noconstant(0)
 DECLARE hover_tsk_id = f8 WITH protect, noconstant(validate(request->task_id,0))
 IF (order_cnt > 0)
  CALL initialize(null)
  CALL queryprotocolorder(null)
  IF (((hover_tsk_id > 0) OR ((request->result_ind=1))) )
   IF ((request->result_ind=1))
    SET reply->result_ind = 1
   ENDIF
   CALL getprotocolorderforgivendotorder(null)
   CALL loaddotorders(null)
   CALL updatedotorderforprotocol(null)
   CALL populatereplyfordotorder(null)
   IF (hover_tsk_id > 0)
    CALL findprotocolorderbygiventaskid(null)
   ENDIF
  ENDIF
 ENDIF
 IF (debug_ind > 0)
  CALL echo("*********************************")
  CALL echo(build("Total Time = ",datetimediff(cnvtdatetime(sysdate),total_time,5)))
  CALL echo("*********************************")
 ENDIF
 IF (reply_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET error_cd = error(error_msg,1)
 IF (error_cd != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE: ",error_msg))
  CALL echo("*********************************")
  SET reply->status_data.status = "F"
 ENDIF
 SUBROUTINE initialize(null)
   CALL echo("********Initialize********")
   DECLARE initializetime = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   SET reply->status_data.status = "F"
   IF (validate(request->debug_ind))
    SET debug_ind = request->debug_ind
   ENDIF
   CALL printdebug(build("********Initialize Time = ",datetimediff(cnvtdatetime(sysdate),
      initializetime,5)))
 END ;Subroutine
 SUBROUTINE queryprotocolorder(null)
   IF (debug_ind > 0)
    CALL echo("********QueryProtocolOrder********")
   ENDIF
   DECLARE queryprotocolordertime = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   SELECT INTO "nl:"
    FROM orders o,
     orders o2
    PLAN (o
     WHERE expand(order_iter,1,order_cnt,o.order_id,request->order_list[order_iter].order_id)
      AND o.protocol_order_id > 0)
     JOIN (o2
     WHERE o2.order_id=o.protocol_order_id)
    HEAD REPORT
     reply_cnt = 0
    DETAIL
     reply_cnt += 1
     IF (reply_cnt > size(reply->order_list,5))
      stat = alterlist(reply->order_list,(reply_cnt+ 9))
     ENDIF
     reply->order_list[reply_cnt].order_id = o.order_id, reply->order_list[reply_cnt].
     prot_warning_level_bit = o2.warning_level_bit
    FOOT REPORT
     stat = alterlist(reply->order_list,reply_cnt)
    WITH nocounter, expand = 2
   ;end select
   CALL printdebug(build("********QueryProtocolOrder Time = ",datetimediff(cnvtdatetime(sysdate),
      queryprotocolordertime,5)))
 END ;Subroutine
 SUBROUTINE getprotocolorderforgivendotorder(null)
   IF (debug_ind=1)
    CALL echo("********Entering  - GetProtocolOrderForGivenDotOrder********")
   ENDIF
   DECLARE ordit = i4 WITH protect, noconstant(0)
   DECLARE locit = i4 WITH protect, noconstant(0)
   DECLARE protoidx = i4 WITH protect, noconstant(0)
   DECLARE replyidx = i4 WITH protect, noconstant(0)
   DECLARE replyordcount = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM orders o
    PLAN (o
     WHERE expand(ordit,1,order_cnt,o.order_id,request->order_list[ordit].order_id)
      AND o.protocol_order_id > 0)
    HEAD o.protocol_order_id
     replyidx = locateval(locit,1,size(reply->protocol_order_list,5),o.protocol_order_id,reply->
      protocol_order_list[locit].order_id)
     IF (replyidx=0)
      replyordcount += 1
      IF (mod(replyordcount,10)=1)
       stat = alterlist(reply->protocol_order_list,(replyordcount+ 9))
      ENDIF
      reply->protocol_order_list[replyordcount].order_id = o.protocol_order_id
     ENDIF
     protoidx = locateval(locit,1,size(protocolanddotorders->dot_ord_list,5),o.protocol_order_id,
      protocolanddotorders->dot_ord_list[locit].protocol_ord_id)
     IF (protoidx=0)
      proordcount += 1
      IF (mod(proordcount,10)=1)
       stat = alterlist(protocolanddotorders->dot_ord_list,(proordcount+ 9))
      ENDIF
      protocolanddotorders->dot_ord_list[proordcount].protocol_ord_id = o.protocol_order_id
     ENDIF
    FOOT REPORT
     IF (replyordcount > 0)
      stat = alterlist(reply->protocol_order_list,replyordcount)
     ENDIF
     IF (proordcount > 0)
      stat = alterlist(protocolanddotorders->dot_ord_list,proordcount)
     ENDIF
    WITH nocounter, expand = 2
   ;end select
   IF (debug_ind=1)
    CALL echo("********Leaving  - GetProtocolOrderForGivenDotOrder********")
   ENDIF
 END ;Subroutine
 SUBROUTINE loaddotorders(null)
   IF (debug_ind=1)
    CALL echo("********Entering  - LoadDotOrders********")
   ENDIF
   DECLARE ordit = i4 WITH protect, noconstant(0)
   DECLARE locit = i4 WITH protect, noconstant(0)
   DECLARE protoidx = i4 WITH protect, noconstant(0)
   DECLARE tmplordcnt = i4 WITH protect, noconstant(0)
   DECLARE protoordcnt = i4 WITH protect, noconstant(size(reply->protocol_order_list,5))
   IF (protoordcnt > 0)
    SELECT INTO "nl:"
     FROM orders o
     WHERE expand(ordit,1,protoordcnt,o.protocol_order_id,reply->protocol_order_list[ordit].order_id)
      AND o.template_order_id=0
     ORDER BY o.protocol_order_id, o.order_id
     HEAD o.order_id
      protoidx = locateval(locit,1,order_cnt,o.protocol_order_id,reply->protocol_order_list[locit].
       order_id)
      IF (protoidx > 0)
       tmplordcnt = (size(reply->protocol_order_list[protoidx].template_order_list,5)+ 1), stat =
       alterlist(reply->protocol_order_list[protoidx].template_order_list,tmplordcnt), reply->
       protocol_order_list[protoidx].template_order_list[tmplordcnt].order_id = o.order_id
      ENDIF
      protoidx = locateval(locit,1,size(protocolanddotorders->dot_ord_list,5),o.protocol_order_id,
       protocolanddotorders->dot_ord_list[locit].protocol_ord_id)
      IF (protoidx > 0)
       dotordcnt = (size(protocolanddotorders->dot_ord_list[protoidx].dots,5)+ 1), stat = alterlist(
        protocolanddotorders->dot_ord_list[protoidx].dots,dotordcnt), protocolanddotorders->
       dot_ord_list[protoidx].dots[dotordcnt].dot_ord_id = o.order_id
      ENDIF
     WITH nocounter, expand = 2
    ;end select
   ENDIF
   IF (debug_ind=1)
    CALL echo("********Leaving  - LoadDotOrders********")
   ENDIF
 END ;Subroutine
 SUBROUTINE updatedotorderforprotocol(null)
   IF (debug_ind=1)
    CALL echo("********Entering  - UpdateDotOrderForProtocol********")
   ENDIF
   DECLARE dotcnt = i4 WITH protect, noconstant(0)
   DECLARE proordit = i4 WITH protect, noconstant(0)
   DECLARE proordidx = i4 WITH protect, noconstant(0)
   DECLARE proordid = f8 WITH protect, noconstant(0)
   DECLARE dorordid = f8 WITH protect, noconstant(0)
   DECLARE sizeprodotordlist = i4 WITH protect, noconstant(size(protocolanddotorders->dot_ord_list,5)
    )
   IF (sizeprodotordlist > 0)
    FOR (x = 1 TO size(protocolanddotorders->dot_ord_list,5))
     SET proordid = protocolanddotorders->dot_ord_list[x].protocol_ord_id
     FOR (y = 1 TO size(protocolanddotorders->dot_ord_list[x].dots,5))
      SET dorordid = protocolanddotorders->dot_ord_list[x].dots[y].dot_ord_id
      IF (dorordid > 0)
       SET dotcnt += 1
       SET stat = alterlist(dotorders->dot_ord_list,dotcnt)
       SET dotorders->dot_ord_list[dotcnt].protocol_ord_id = proordid
       SET dotorders->dot_ord_list[dotcnt].dot_ord_id = dorordid
      ENDIF
     ENDFOR
    ENDFOR
    CALL loadtreatmentdescfordotorders(0)
   ENDIF
   IF (debug_ind=1)
    CALL echo("********Leaving - UpdateDotOrderForProtocol********")
    CALL echorecord(dotorders)
   ENDIF
 END ;Subroutine
 SUBROUTINE loadtreatmentdescfordotorders(null)
   IF (debug_ind=1)
    CALL echo("********Entering - LoadTreatmentDescForDotOrders********")
   ENDIF
   DECLARE dotidx = i4 WITH protect, noconstant(0)
   DECLARE dotpos = i4 WITH protect, noconstant(0)
   DECLARE proidx = i4 WITH protect, noconstant(0)
   DECLARE propos = i4 WITH protect, noconstant(0)
   DECLARE pordid = f8 WITH protect, noconstant(0)
   DECLARE prolistsize = i4 WITH protect, noconstant(0)
   DECLARE dotlistsize = i4 WITH protect, noconstant(0)
   DECLARE dotordlistsize = i4 WITH protect, noconstant(size(dotorders->dot_ord_list,5))
   IF (dotordlistsize > 0)
    SELECT INTO "nl:"
     FROM act_pw_comp apc,
      pathway pw
     PLAN (apc
      WHERE expand(dotidx,1,dotordlistsize,apc.parent_entity_id,dotorders->dot_ord_list[dotidx].
       dot_ord_id)
       AND apc.parent_entity_name="ORDERS")
      JOIN (pw
      WHERE pw.pathway_id=apc.pathway_id)
     HEAD apc.parent_entity_id
      dotpos = locateval(dotidx,1,dotordlistsize,apc.parent_entity_id,dotorders->dot_ord_list[dotidx]
       .dot_ord_id)
      IF (dotpos > 0)
       pordid = dotorders->dot_ord_list[dotpos].protocol_ord_id, prolistsize = size(
        protocolanddotorders->dot_ord_list,5), propos = locateval(proidx,1,prolistsize,pordid,
        protocolanddotorders->dot_ord_list[proidx].protocol_ord_id)
       IF (propos > 0)
        dotlistsize = size(protocolanddotorders->dot_ord_list[propos].dots,5), dotpos = locateval(
         dotidx,1,dotlistsize,apc.parent_entity_id,protocolanddotorders->dot_ord_list[propos].dots[
         dotidx].dot_ord_id)
        IF (dotpos > 0)
         protocolanddotorders->dot_ord_list[propos].dots[dotidx].uncorrupted_dots = 1
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter, expand = 2
    ;end select
   ENDIF
   IF (debug_ind=1)
    CALL echo("********Leaving - LoadTreatmentDescForDotOrders********")
   ENDIF
   CALL echorecord(protocolanddotorders)
 END ;Subroutine
 SUBROUTINE populatereplyfordotorder(null)
   IF (debug_ind=1)
    CALL echo("********Entering - PopulateReplyForDotOrder********")
   ENDIF
   DECLARE protoid = f8 WITH protect, noconstant(0)
   DECLARE propos = i4 WITH protect, noconstant(0)
   DECLARE proidx = i4 WITH protect, noconstant(0)
   DECLARE dorordid = f8 WITH protect, noconstant(0)
   DECLARE dotpos = i4 WITH protect, noconstant(0)
   DECLARE dotidx = i4 WITH protect, noconstant(0)
   DECLARE sizereplydot = i4 WITH protect, noconstant(0)
   DECLARE sizereplypro = i4 WITH protect, noconstant(0)
   DECLARE sizeproordlist = i4 WITH protect, noconstant(size(protocolanddotorders->dot_ord_list,5))
   IF (sizeproordlist > 0)
    CALL updateuncorrupteddotorderscount(0)
    FOR (x = 1 TO size(protocolanddotorders->dot_ord_list,5))
      SET protoid = protocolanddotorders->dot_ord_list[x].protocol_ord_id
      SET sizereplypro = size(reply->protocol_order_list,5)
      SET propos = locateval(proidx,1,sizereplypro,protoid,reply->protocol_order_list[proidx].
       order_id)
      IF (propos > 0)
       FOR (y = 1 TO size(protocolanddotorders->dot_ord_list[x].dots,5))
         SET dorordid = protocolanddotorders->dot_ord_list[x].dots[y].dot_ord_id
         SET sizereplydot = size(reply->protocol_order_list[propos].template_order_list,5)
         SET dotpos = locateval(dotidx,1,sizereplydot,dorordid,reply->protocol_order_list[propos].
          template_order_list[dotidx].order_id)
         IF (dotpos > 0)
          IF ((sizereplydot=protocolanddotorders->dot_ord_list[x].uncorrupted_dot_cnt))
           SET reply->protocol_order_list[propos].template_order_list[dotpos].corrupted_dot_found = 0
          ELSE
           SET reply->protocol_order_list[propos].corrupt_protocol_ord_ind = 1
           IF ((protocolanddotorders->dot_ord_list[x].dots[y].uncorrupted_dots=1))
            SET reply->protocol_order_list[propos].template_order_list[dotpos].corrupted_dot_found =
            1
           ELSE
            SET reply->protocol_order_list[propos].template_order_list[dotpos].corrupted_dot_found =
            2
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
   IF (debug_ind=1)
    CALL echo("********Leaving - PopulateReplyForDotOrder********")
   ENDIF
 END ;Subroutine
 SUBROUTINE updateuncorrupteddotorderscount(null)
   IF (debug_ind=1)
    CALL echo("********Entering - UpdateUnCorruptedDotOrdersCount********")
   ENDIF
   DECLARE uncorrputdotordcnt = i4 WITH protect, noconstant(0)
   DECLARE dotcnt = i4 WITH protect, noconstant(0)
   DECLARE dorordid = f8 WITH protect, noconstant(0)
   FOR (x = 1 TO size(protocolanddotorders->dot_ord_list,5))
     SET dotcnt = 0
     FOR (y = 1 TO size(protocolanddotorders->dot_ord_list[x].dots,5))
       SET dorordid = protocolanddotorders->dot_ord_list[x].dots[y].dot_ord_id
       SET uncorrputdotordcnt = protocolanddotorders->dot_ord_list[x].dots[y].uncorrupted_dots
       IF (uncorrputdotordcnt=1)
        SET dotcnt += 1
       ENDIF
     ENDFOR
     SET protocolanddotorders->dot_ord_list[x].uncorrupted_dot_cnt = dotcnt
   ENDFOR
   IF (debug_ind=1)
    CALL echo("********Leaving - UpdateUnCorruptedDotOrdersCount********")
   ENDIF
 END ;Subroutine
 SUBROUTINE findprotocolorderbygiventaskid(null)
   IF (debug_ind=1)
    CALL echo("********Entering - FindProtocolOrderByGivenTaskId********")
   ENDIF
   DECLARE proidx = i4 WITH protect, noconstant(0)
   DECLARE propos = i4 WITH protect, noconstant(0)
   DECLARE pordid = f8 WITH protect, noconstant(0)
   DECLARE prolistsize = i4 WITH protect, noconstant(0)
   DECLARE dotlistsize = i4 WITH protect, noconstant(0)
   DECLARE protocolorderlist = i4 WITH protect, noconstant(size(reply->protocol_order_list,5))
   SELECT INTO "nl:"
    FROM task_activity ta,
     orders o
    PLAN (ta
     WHERE ta.task_id=hover_tsk_id)
     JOIN (o
     WHERE o.order_id=ta.order_id)
    ORDER BY o.protocol_order_id, o.order_id
    HEAD REPORT
     propos = locateval(proidx,1,protocolorderlist,o.protocol_order_id,reply->protocol_order_list[
      proidx].order_id)
     IF (propos > 0)
      reply->protocol_order_list[proidx].hover_tsk_protocol_ord_ind = 1
     ENDIF
     IF (debug_ind=1)
      CALL echo("********Leaving - FindProtocolOrderByGivenTaskId********")
     ENDIF
   ;end select
 END ;Subroutine
 SUBROUTINE (printdebug(msg=vc) =null)
   IF (debug_ind > 0)
    CALL echo(msg)
   ENDIF
 END ;Subroutine
 IF (debug_ind > 0)
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
 SET last_mod = "003 12/18/20"
 IF (debug_ind=1)
  CALL echo(build("Last Modified = ",last_mod))
 ENDIF
 SET modify = nopredeclare
END GO
