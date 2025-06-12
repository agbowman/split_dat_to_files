CREATE PROGRAM bhs_rw_get_order_fax_details:dba
 IF (validate(link_orderid,0.00) <= 0.00)
  DECLARE retval = i4
  DECLARE link_orderid = f8
  DECLARE log_message = vc
  DECLARE log_misc1 = vc
  DECLARE log_orderid = f8
  IF (cnvtreal(parameter(1,0)) <= 0.00)
   SET retval = 100
   SET log_message = "No ORDER_ID passed in. Exitting Script"
   GO TO exit_script
  ELSE
   SET link_orderid = cnvtreal(parameter(1,0))
  ENDIF
 ENDIF
 SET retval = 100
 SET log_orderid = 0.00
 SET log_message = build2("ORDER_ID = ",trim(cnvtstring(link_orderid),3),".")
 DECLARE msg_line = vc
 DECLARE fax_station = vc
 SET msg_line = build2("Your faxed prescription(s) are not deliverable.",
  "  This may be because our fax server encountered a busy signal,",
  " or because the receiving fax is not functioning or is out of paper.",
  "Please call the pharmacy to order this prescription.",
  "  You may wish to call the patient to let them know that their prescription may be delayed")
 DECLARE line_return = vc WITH constant(concat(char(13)))
 DECLARE cs2209_error_cd = f8 WITH constant(uar_get_code_by("MEANING",2209,"ERROR"))
 DECLARE cs2209_queued_cd = f8 WITH constant(uar_get_code_by("MEANING",2209,"QUEUED"))
 DECLARE cs2209_untrans_cd = f8 WITH constant(uar_get_code_by("MEANING",2209,"UNXMITTED"))
 DECLARE cs2209_trans_cd = f8 WITH constant(uar_get_code_by("MEANING",2209,"XMITTED"))
 SELECT INTO "NL:"
  rq.transmission_status_cd, sx.session_num, sl.qualifier,
  sl.message_cd, sl.message_text
  FROM report_queue rq,
   session_xref sx,
   session_log sl,
   station st,
   outputctx ctx
  PLAN (rq
   WHERE rq.converted_file_name=patstring(build("*",format(link_orderid,"#############;P0"),"*")))
   JOIN (sx
   WHERE outerjoin(rq.output_handle_id)=sx.output_handle_id
    AND sx.output_handle_id > outerjoin(0))
   JOIN (sl
   WHERE outerjoin(sx.session_num)=sl.session_num)
   JOIN (ctx
   WHERE ctx.handle_id=rq.output_handle_id)
   JOIN (st
   WHERE st.output_dest_cd=ctx.output_dest_cd)
  HEAD rq.output_handle_id
   fax_station = build2("Fax Location: ",trim(st.description))
   CASE (rq.transmission_status_cd)
    OF cs2209_error_cd:
     log_orderid = 1.00,log_message = build2(log_message," Faxed found in ERROR status.")
    OF cs2209_queued_cd:
     log_orderid = 2.00,log_message = build2(log_message," Faxed found in QUEUED status.")
    OF cs2209_untrans_cd:
     log_orderid = 3.00,log_message = build2(log_message," Faxed found in UNXMITTED status.")
    OF cs2209_trans_cd:
     log_orderid = 4.00,log_message = build2(log_message," Faxed found in XMITTED status.")
   ENDCASE
  HEAD sx.session_num
   log_misc1 = build2(log_misc1," ",line_return,line_return," Session Number: ",
    sx.session_num)
  DETAIL
   log_misc1 = build2(log_misc1," ",line_return,"  ",sl.message_text)
  WITH nocounter
 ;end select
 IF (log_orderid=0.00)
  SET log_message = build2(log_message," Fax not found for order.")
 ENDIF
 SELECT INTO "NL:"
  o.order_id, o.ordered_as_mnemonic, o.orig_order_dt_tm,
  p.name_full_formatted, pa.alias, ea.alias
  FROM orders o,
   person p,
   person_alias pa,
   encntr_alias ea
  PLAN (o
   WHERE o.order_id=link_orderid)
   JOIN (p
   WHERE o.person_id=p.person_id)
   JOIN (pa
   WHERE o.person_id=pa.person_id
    AND pa.person_alias_type_cd=value(uar_get_code_by("MEANING",4,"CMRN"))
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (ea
   WHERE o.encntr_id=ea.encntr_id
    AND ea.encntr_alias_type_cd=value(uar_get_code_by("MEANING",319,"FIN NBR"))
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  HEAD o.order_id
   log_misc1 = build2('"',trim(o.ordered_as_mnemonic),'" ordered at ',format(o.orig_order_dt_tm,
     "MM/DD/YYYY;;D")," ",
    cnvtupper(format(o.orig_order_dt_tm,"HH:MM;;S")),line_return,fax_station,line_return,log_misc1),
   log_misc1 = build2(msg_line,line_return,log_misc1)
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET log_message = build2(log_message," ORDER_ID NOT found on ORDERS table.")
 ELSE
  SET log_message = build2(log_message," ORDER_ID found on ORDERS table.")
 ENDIF
 CALL echo(" ")
 CALL echo("LOG_MESSAGE:")
 CALL echo(log_message)
 CALL echo(" ")
 CALL echo("LOG_MISC1:")
 CALL echo(log_misc1)
 CALL echo(" ")
 CALL echo(build2("LOG_ORDERID = ",log_orderid))
 CALL echo(" ")
#exit_script
 FREE SET line_return
 FREE SET cs2209_error_cd
 FREE SET cs2209_queued_cd
 FREE SET cs2209_untrans_cd
 FREE SET cs2209_trans_cd
END GO
