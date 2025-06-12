CREATE PROGRAM bhs_eks_find_renewal_ords_v2:dba
 SET retval = 0
 DECLARE display_line = vc
 DECLARE log_misc1 = cv
 DECLARE pharmacy = f8 WITH constant(uar_get_code_by("MEANING",106,"PHARMACY"))
 SET rhead = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}"
 SET rh2r = "\plain \f0 \fs18 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs18 \b \cb2 \pard\sl0 "
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = " \plain \f0 \fs18 "
 SET wb = " \plain \f0 \fs18 \b \cb2 "
 SET wu = " \plain \f0 \fs18 \ul \cb "
 SET wi = " \plain \f0 \fs18 \i \cb2 "
 SET wbi = " \plain \f0 \fs18 \b \i \cb2 "
 SET wiu = " \plain \f0 \fs18 \i \ul \cb2 "
 SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
 SET rtfeof = "}"
 FREE RECORD renewords
 RECORD renewords(
   1 overduenow[*]
     2 displayline = vc
     2 hna_order_mnemonic = vc
   1 overduein12[*]
     2 displayline = vc
     2 hna_order_mnemonic = vc
 )
 SELECT INTO "nl:"
  FROM orders o
  WHERE o.encntr_id=trigger_encntrid
   AND o.order_status_cd=2550
   AND o.stop_type_cd=2338
   AND o.template_order_id=0
   AND o.orig_ord_as_flag=0
   AND o.soft_stop_dt_tm <= cnvtlookahead("12,H")
  HEAD REPORT
   display_line = " ", cnt1 = 0, cnt2 = 0
  DETAIL
   IF (o.soft_stop_dt_tm <= sysdate)
    cnt1 = (cnt1+ 1), stat = alterlist(renewords->overduenow,cnt1), renewords->overduenow[cnt1].
    displayline = build2(wr," ",trim(o.clinical_display_line),reol),
    renewords->overduenow[cnt1].hna_order_mnemonic = build2(wb," ",trim(o.hna_order_mnemonic))
   ELSEIF (o.soft_stop_dt_tm <= cnvtlookahead("12,H")
    AND o.activity_type_cd=pharmacy)
    cnt2 = (cnt2+ 1), stat = alterlist(renewords->overduein12,cnt2), renewords->overduein12[cnt2].
    displayline = build2(wr," ",trim(o.clinical_display_line),reol),
    renewords->overduein12[cnt2].hna_order_mnemonic = build2(wb," ",trim(o.hna_order_mnemonic))
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET display_line = " "
  IF (size(renewords->overduenow,5) > 0)
   SET display_line = concat(
    "The following orders are now overdue and require renewal to remain active ",
    "Please note that an hourglass icon is visible on the orders tab next to all ",
    "orders that require renewal. You can right click and renew 1 or more orders ","simultaneously. ",
    reol,
    reol)
   FOR (x = 1 TO size(renewords->overduenow,5))
     SET display_line = build(trim(display_line),wb,char(13)," ",x,
      ".",trim(renewords->overduenow[x].hna_order_mnemonic,3)," ",trim(renewords->overduenow[x].
       displayline,3))
   ENDFOR
   SET retval = 100
  ENDIF
  IF (size(renewords->overduein12,5) > 0)
   SET display_line = concat(display_line,reol," ",rh2bu,
    "The following orders will require renewal within next 12 hours:",
    reol,reol)
   FOR (x = 1 TO size(renewords->overduein12,5))
     SET display_line = build(trim(display_line),wb,char(13)," ",x,
      ".",trim(renewords->overduein12[x].hna_order_mnemonic,3)," ",trim(renewords->overduein12[x].
       displayline,3))
   ENDFOR
   SET retval = 100
  ENDIF
  SET log_misc1 = concat(display_line)
 ENDIF
 CALL echorecord(display_line)
 SET log_misc1 = concat(rhead,rh2bu,log_misc1,rtfeof)
 SET log_misc1 = concat(log_misc1)
 SET reply->text = concat(rhead,rh2bu,log_misc1,rtfeof)
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
 CALL echo(reply->text)
END GO
