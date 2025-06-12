CREATE PROGRAM bhs_tok_med_given:dba
 FREE RECORD prsn_orders
 RECORD prsn_orders(
   1 l_cnt = i4
   1 list[*]
     2 s_med = vc
     2 s_dose = vc
     2 s_route = vc
     2 s_last_dose = vc
 ) WITH protect
 IF (validate(reply->text,"-1")="-1")
  FREE RECORD reply
  RECORD reply(
    1 text = vc
    1 format = i4
  ) WITH protect
 ENDIF
 DECLARE v_ce_stat_inerror_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE active_status_cd = f8 WITH public, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE dplaceholdercd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"PLACEHOLDER"))
 DECLARE divparentcd = f8 WITH public, constant(uar_get_code_by("MEANING",72,"IVPARENT"))
 DECLARE l_idx = i4 WITH protect, noconstant(0)
 DECLARE s_text = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_med_result cmr,
   clinical_event ce2
  PLAN (ce
   WHERE (ce.encntr_id=request->encntr_id)
    AND ((ce.person_id+ 0)=request->person_id)
    AND ((ce.valid_until_dt_tm+ 0) > cnvtdatetime(sysdate))
    AND ce.result_status_cd != v_ce_stat_inerror_cd
    AND ce.record_status_cd=active_status_cd
    AND ce.event_class_cd != dplaceholdercd
    AND ((ce.order_id+ 0) != 0.0)
    AND ((ce.event_cd+ 0) != 0.0))
   JOIN (cmr
   WHERE cmr.event_id=ce.event_id
    AND cmr.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND cmr.admin_start_dt_tm <= cnvtdatetime(sysdate)
    AND ((cmr.diluent_type_cd+ 0)=0.0))
   JOIN (ce2
   WHERE (ce2.parent_event_id= Outerjoin(ce.event_id)) )
  ORDER BY ce.event_cd, ce2.event_cd, cmr.admin_start_dt_tm DESC
  HEAD ce.event_cd
   IF (ce.event_cd != divparentcd)
    prsn_orders->l_cnt += 1, stat = alterlist(prsn_orders->list,prsn_orders->l_cnt), prsn_orders->
    list[prsn_orders->l_cnt].s_med = ce.event_title_text,
    prsn_orders->list[prsn_orders->l_cnt].s_dose = build2(cmr.admin_dosage," ",uar_get_code_display(
      cmr.dosage_unit_cd)), prsn_orders->list[prsn_orders->l_cnt].s_route = uar_get_code_display(cmr
     .admin_route_cd), prsn_orders->list[prsn_orders->l_cnt].s_last_dose = format(cmr
     .admin_start_dt_tm,";;q")
   ENDIF
  HEAD ce2.event_cd
   IF (ce.event_cd=divparentcd
    AND ce2.event_cd != divparentcd
    AND ce2.event_cd > 0.0
    AND ce2.valid_until_dt_tm > cnvtdatetime(sysdate))
    prsn_orders->l_cnt += 1, stat = alterlist(prsn_orders->list,prsn_orders->l_cnt), prsn_orders->
    list[prsn_orders->l_cnt].s_med = ce2.event_title_text,
    prsn_orders->list[prsn_orders->l_cnt].s_dose = build2(cmr.admin_dosage," ",uar_get_code_display(
      cmr.dosage_unit_cd)), prsn_orders->list[prsn_orders->l_cnt].s_route = uar_get_code_display(cmr
     .admin_route_cd), prsn_orders->list[prsn_orders->l_cnt].s_last_dose = format(cmr
     .admin_start_dt_tm,";;q")
   ENDIF
  WITH nocounter
 ;end select
 SET s_text = "<html><body><table border=1 cellspacing=0 cellpadding=0 width=100%>"
 IF ((prsn_orders->l_cnt > 0))
  FOR (l_idx = 1 TO prsn_orders->l_cnt)
   IF (l_idx=1)
    SET s_text = build2(s_text,"<tr><td><p><b>Medication</b></p></td><td><p><b>Dose</b></p></td>",
     "<td><p><b>Route</b></p></td><td><p><b>Last Dose Times</b></p></td>")
   ENDIF
   SET s_text = build2(s_text,"<tr><td><p>",prsn_orders->list[l_idx].s_med,"</p></td>","<td><p>",
    prsn_orders->list[l_idx].s_dose,"</p></td>","<td><p>",prsn_orders->list[l_idx].s_route,
    "</p></td>",
    "<td><p>",prsn_orders->list[l_idx].s_last_dose,"</p></td></tr>")
  ENDFOR
 ELSE
  SET s_text = build2(s_text,"<tr><td><p>No medications given during this visit.</p></td></tr>")
 ENDIF
 SET s_text = build2(s_text,"</table><br><br><br><br><br></body></html>")
 SET reply->text = s_text
 SET reply->format = 1
#exit_script
END GO
