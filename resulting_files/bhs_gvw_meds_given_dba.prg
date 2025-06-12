CREATE PROGRAM bhs_gvw_meds_given:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data[1]
      2 status = c4
    1 text = gvc
  )
 ENDIF
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[1]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[1]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
 ENDIF
 FREE RECORD prsn_orders
 RECORD prsn_orders(
   1 l_cnt = i4
   1 list[*]
     2 s_med = vc
     2 s_dose = vc
     2 s_route = vc
     2 s_last_dose = vc
 ) WITH protect
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
   WHERE (ce.encntr_id=request->visit[1].encntr_id)
    AND ((ce.person_id+ 0)=request->person[1].person_id)
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
 SET s_text = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Tahoma;}}\fs18"
 IF ((prsn_orders->l_cnt > 0))
  FOR (l_idx = 1 TO prsn_orders->l_cnt)
   IF (l_idx=1)
    SET s_text = concat(s_text," \trowd\trgaph30\cellx2000\cellx3500\cellx5000\cellx7000\intbl ",
     "Medication "," \cell ","Dose ",
     " \cell ","Route "," \cell ","Last Dose Times "," \cell ",
     "\row ")
   ENDIF
   SET s_text = concat(s_text," \trowd\trgaph30\cellx2000\cellx3500\cellx5000\cellx7000\intbl ",
    prsn_orders->list[l_idx].s_med," \cell ",prsn_orders->list[l_idx].s_dose,
    " \cell ",prsn_orders->list[l_idx].s_route," \cell ",prsn_orders->list[l_idx].s_last_dose,
    " \cell ",
    "\row ")
  ENDFOR
 ELSE
  SET s_text = concat(s_text," No medications given during this visit. \par ")
 ENDIF
 SET s_text = concat(s_text,"}")
 SET reply->text = s_text
 CALL echorecord(reply)
#exit_script
END GO
