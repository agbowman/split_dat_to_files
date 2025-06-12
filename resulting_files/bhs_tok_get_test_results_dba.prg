CREATE PROGRAM bhs_tok_get_test_results:dba
 IF (validate(reply->text,"-1")="-1")
  FREE RECORD reply
  RECORD reply(
    1 text = vc
    1 format = i4
  ) WITH protect
 ENDIF
 FREE RECORD prsn_orders
 RECORD prsn_orders(
   1 n_cnt = i4
   1 list[*]
     2 s_order_name = vc
     2 f_order_id = f8
     2 f_catalog_cd = f8
     2 n_rcnt = i4
     2 results[*]
       3 n_event_cd = f8
       3 s_result_val = vc
       3 n_event_name = vc
 ) WITH protect
 FREE RECORD ord_cat
 RECORD ord_cat(
   1 n_cnt = i4
   1 list[*]
     2 f_catalog_cd = f8
     2 s_mnemonic_key_cap = vc
     2 s_display_key = vc
 ) WITH protect
 DECLARE f_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE f_inprocess_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE f_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE f_medstudent_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"MEDSTUDENT"))
 DECLARE f_pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE f_pending_rev_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 DECLARE f_glu_orgclia = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "POCGLUCOSEORGCLIA"))
 DECLARE f_glu_repto = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "POCGLUCOSERESULTREPORTEDTO"))
 DECLARE f_glu_comment = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "POCGLUCOSECOMMENT"))
 DECLARE n_idx = i4 WITH protect, noconstant(0)
 DECLARE n_loc = i4 WITH protect, noconstant(0)
 DECLARE n_idx2 = i4 WITH protect, noconstant(0)
 DECLARE n_loc2 = i4 WITH protect, noconstant(0)
 DECLARE s_text = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs,
   code_value cv
  PLAN (ocs
   WHERE ocs.mnemonic_key_cap IN ("ELECTROLYTES", "LYTES", "GLUCOSE (POC)", "GLUCOSE LEVEL",
   "POC GLUCOSE",
   "HGB A1C (MONITORING)", "LIPID PANEL", "LIPID PANEL NON FASTING", "CARDIAC LIPID PANEL", "INR",
   "PT (INR)", "BILIRUBIN TOTAL", "BILIRUBIN TOTAL + DIRECT", "C REACTIVE PROTEIN")
    AND ocs.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=ocs.catalog_cd
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate)
  ORDER BY ocs.mnemonic_key_cap
  HEAD REPORT
   ord_cat->n_cnt = 0
  DETAIL
   ord_cat->n_cnt += 1, stat = alterlist(ord_cat->list,ord_cat->n_cnt), ord_cat->list[ord_cat->n_cnt]
   .f_catalog_cd = ocs.catalog_cd,
   ord_cat->list[ord_cat->n_cnt].s_mnemonic_key_cap = ocs.mnemonic_key_cap, ord_cat->list[ord_cat->
   n_cnt].s_display_key = cv.display_key
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  WHERE (o.person_id=request->person_id)
   AND (o.encntr_id=request->encntr_id)
   AND o.active_ind=1
   AND o.order_status_cd IN (f_completed_cd)
  ORDER BY o.catalog_cd, o.current_start_dt_tm DESC, o.orig_order_dt_tm DESC
  HEAD REPORT
   prsn_orders->n_cnt = 0
  HEAD o.catalog_cd
   n_loc = 0, n_loc = locateval(n_idx,1,ord_cat->n_cnt,o.catalog_cd,ord_cat->list[n_idx].f_catalog_cd
    )
   IF (n_loc > 0)
    prsn_orders->n_cnt += 1, stat = alterlist(prsn_orders->list,prsn_orders->n_cnt)
    IF (cnvtupper(trim(o.order_mnemonic)) != cnvtupper(trim(o.ordered_as_mnemonic))
     AND size(trim(o.ordered_as_mnemonic)) != 0
     AND cnvtupper(trim(o.order_mnemonic)) != "HEMOGLOBIN A1C (MONITORING)")
     prsn_orders->list[prsn_orders->n_cnt].s_order_name = concat(trim(o.order_mnemonic)," (",trim(o
       .ordered_as_mnemonic),")")
    ELSE
     prsn_orders->list[prsn_orders->n_cnt].s_order_name = o.order_mnemonic
    ENDIF
    prsn_orders->list[prsn_orders->n_cnt].f_order_id = o.order_id, prsn_orders->list[prsn_orders->
    n_cnt].f_catalog_cd = o.catalog_cd
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   code_value cv2,
   code_value cv
  PLAN (ce
   WHERE (ce.person_id=request->person_id)
    AND (ce.encntr_id=request->encntr_id)
    AND expand(n_idx,1,prsn_orders->n_cnt,ce.order_id,prsn_orders->list[n_idx].f_order_id)
    AND ce.view_level=1
    AND  NOT (ce.event_cd IN (f_glu_orgclia, f_glu_repto, f_glu_comment))
    AND textlen(trim(ce.result_val)) > 0)
   JOIN (cv2
   WHERE cv2.code_value=ce.result_status_cd
    AND  NOT (cv2.display_key IN ("NOTDONE", "INERROR", "CANCELED", "INLAB", "INPROGRESS",
   "REJECTED", "PRELIMINARY", "UNKNOWN")))
   JOIN (cv
   WHERE cv.code_value=ce.event_cd)
  ORDER BY ce.order_id, ce.event_cd, ce.event_end_dt_tm DESC
  DETAIL
   n_loc = locateval(n_idx,1,prsn_orders->n_cnt,ce.order_id,prsn_orders->list[n_idx].f_order_id)
   IF (n_loc > 0)
    n_loc2 = 0, n_loc2 = locateval(n_idx2,1,prsn_orders->list[n_loc].n_rcnt,ce.event_cd,prsn_orders->
     list[n_loc].results[n_idx2].n_event_cd)
    IF (n_loc2=0)
     prsn_orders->list[n_loc].n_rcnt += 1, stat = alterlist(prsn_orders->list[n_loc].results,
      prsn_orders->list[n_loc].n_rcnt), prsn_orders->list[n_loc].results[prsn_orders->list[n_loc].
     n_rcnt].n_event_cd = ce.event_cd,
     prsn_orders->list[n_loc].results[prsn_orders->list[n_loc].n_rcnt].n_event_name = cv.display,
     prsn_orders->list[n_loc].results[prsn_orders->list[n_loc].n_rcnt].s_result_val = ce.result_val
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET s_text = "<html><body><table border=0 cellspacing=0 cellpadding=0 width=100%>"
 IF ((prsn_orders->n_cnt > 0))
  FOR (n_idx = 1 TO prsn_orders->n_cnt)
    IF (n_idx=1)
     SET s_text = concat(s_text,"<tr><td><p><b>",prsn_orders->list[n_idx].s_order_name,
      "</b></p></td></tr>")
     IF ((prsn_orders->list[n_idx].n_rcnt > 0))
      FOR (n_loc = 1 TO prsn_orders->list[n_idx].n_rcnt)
        SET s_text = concat(s_text,"<tr><td><p><b>&nbsp;&nbsp;&nbsp;&nbsp;",prsn_orders->list[n_idx].
         results[n_loc].n_event_name,":&nbsp; </b>",prsn_orders->list[n_idx].results[n_loc].
         s_result_val,
         "</p></td></tr>")
      ENDFOR
     ELSE
      SET s_text = concat(s_text,"<tr><td><p><b>&nbsp;&nbsp;&nbsp;&nbsp;",
       "Contact the Follow-up Physician listed above for any pending test results.",
       "</b></p></td></tr>")
     ENDIF
    ELSE
     SET s_text = concat(s_text,"<tr><td><p>&nbsp;</p></td></tr>","<tr><td><p><b>",prsn_orders->list[
      n_idx].s_order_name,"</b></p></td></tr>")
     IF ((prsn_orders->list[n_idx].n_rcnt > 0))
      FOR (n_loc = 1 TO prsn_orders->list[n_idx].n_rcnt)
        SET s_text = concat(s_text,"<tr><td><p><b>&nbsp;&nbsp;&nbsp;&nbsp;",prsn_orders->list[n_idx].
         results[n_loc].n_event_name,":&nbsp; </b>",prsn_orders->list[n_idx].results[n_loc].
         s_result_val,
         "</p></td></tr>")
      ENDFOR
     ELSE
      SET s_text = concat(s_text,"<tr><td><p><b>&nbsp;&nbsp;&nbsp;&nbsp;",
       "Contact the Follow-up Physician listed above for any pending test results.",
       "</b></p></td></tr>")
     ENDIF
    ENDIF
  ENDFOR
 ELSE
  SET s_text = concat(s_text,"<tr><td><p>Not Applicable</p></td></tr>")
 ENDIF
 SET s_text = concat(s_text,"</table></body></html>")
 SET reply->text = s_text
 SET reply->format = 1
 CALL echo(s_text)
 CALL echorecord(prsn_orders)
 FREE RECORD prsn_orders
 FREE RECORD ord_cat
END GO
