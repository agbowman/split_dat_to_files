CREATE PROGRAM bhs_rpt_pdc_orders:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 RECORD m_rec(
   1 l_pcnt = i4
   1 plist[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 c_name = c100
     2 c_fin = c25
     2 c_cmrn = c25
     2 c_dob = c25
     2 c_room = c25
     2 l_ocnt = i4
     2 c_admit_diagnosis = c255
     2 olist[*]
       3 f_order_id = f8
       3 f_encntr_id = f8
       3 c_order_mnemonic = c100
       3 c_start_dt_tm = c35
 ) WITH protect
 FREE RECORD g_request
 RECORD g_request(
   1 person_id = f8
   1 print_prsnl_id = f8
   1 order_qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 conversation_id = f8
   1 printer_name = c50
 ) WITH public, persist
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 ops_event = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH public
 ENDIF
 DECLARE mf_orderaction_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE mf_orderedstatus_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE mf_inpatenctypeclass_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",69,"INPATIENT"
   ))
 DECLARE mf_bmcfacility_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE MEDICAL CENTER"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE ml_pcnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ocnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ploop = i4 WITH protect, noconstant(0)
 DECLARE ml_oloop = i4 WITH protect, noconstant(0)
 DECLARE mc_rpt_title = c255 WITH protect, noconstant(" ")
 DECLARE mc_rpt_date = c50 WITH protect, noconstant(" ")
 DECLARE ms_call_program = vc WITH protect, noconstant(" ")
 SET ms_call_program = "bhs_req_preg"
 SELECT INTO "nl:"
  FROM orders o,
   order_catalog oc,
   encounter e,
   person p,
   encntr_alias fin,
   person_alias cmrn,
   order_detail od,
   order_detail oddx
  PLAN (o
   WHERE o.order_status_cd=mf_orderedstatus_cd
    AND o.template_order_flag=2)
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd
    AND oc.primary_mnemonic="PDC*"
    AND oc.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.loc_facility_cd=mf_bmcfacility_cd
    AND e.disch_dt_tm=null
    AND e.encntr_type_class_cd=mf_inpatenctypeclass_cd)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.encntr_alias_type_cd=mf_fin_cd
    AND fin.active_ind=1
    AND fin.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (cmrn
   WHERE cmrn.person_id=p.person_id
    AND cmrn.person_alias_type_cd=mf_cmrn_cd
    AND cmrn.active_ind=1
    AND cmrn.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_meaning="REQSTARTDTTM"
    AND od.oe_field_dt_tm_value >= cnvtdatetime((curdate - 2),0)
    AND od.oe_field_dt_tm_value < cnvtdatetime((curdate+ 1),0))
   JOIN (oddx
   WHERE (oddx.order_id= Outerjoin(o.order_id))
    AND (oddx.oe_field_meaning= Outerjoin("ICD9")) )
  ORDER BY o.person_id, o.order_id, od.action_sequence DESC,
   oddx.action_sequence DESC
  HEAD REPORT
   ml_pcnt = 0
  HEAD o.person_id
   ml_pcnt += 1, m_rec->l_pcnt = ml_pcnt, stat = alterlist(m_rec->plist,ml_pcnt),
   m_rec->plist[ml_pcnt].f_person_id = o.person_id, m_rec->plist[ml_pcnt].f_encntr_id = o.encntr_id,
   m_rec->plist[ml_pcnt].c_name = trim(p.name_full_formatted,3),
   m_rec->plist[ml_pcnt].c_fin = trim(fin.alias,3), m_rec->plist[ml_pcnt].c_cmrn = trim(cmrn.alias,3),
   m_rec->plist[ml_pcnt].c_dob = format(p.birth_dt_tm,"mm/dd/yyyy;;D")
   IF (e.loc_nurse_unit_cd > 0.00
    AND e.loc_room_cd > 0.00)
    m_rec->plist[ml_pcnt].c_room = build(uar_get_code_display(e.loc_nurse_unit_cd),"/",
     uar_get_code_display(e.loc_room_cd))
   ELSEIF (e.loc_nurse_unit_cd > 0.00
    AND e.loc_room_cd <= 0.00)
    m_rec->plist[ml_pcnt].c_room = build(uar_get_code_display(e.loc_nurse_unit_cd))
   ELSEIF (e.loc_nurse_unit_cd <= 0.00
    AND e.loc_room_cd > 0.00)
    m_rec->plist[ml_pcnt].c_room = build(uar_get_code_display(e.loc_room_cd))
   ENDIF
   ml_ocnt = 0
  HEAD o.order_id
   ml_ocnt += 1, m_rec->plist[ml_pcnt].l_ocnt = ml_ocnt, stat = alterlist(m_rec->plist[ml_pcnt].olist,
    ml_ocnt),
   m_rec->plist[ml_pcnt].olist[ml_ocnt].f_encntr_id = o.encntr_id, m_rec->plist[ml_pcnt].olist[
   ml_ocnt].f_order_id = o.order_id, m_rec->plist[ml_pcnt].olist[ml_ocnt].c_order_mnemonic = o
   .order_mnemonic,
   m_rec->plist[ml_pcnt].olist[ml_ocnt].c_start_dt_tm = format(od.oe_field_dt_tm_value,"HH:mm;;D")
   IF (oddx.oe_field_display_value > " ")
    m_rec->plist[ml_pcnt].c_admit_diagnosis = concat(trim(oddx.oe_field_display_value,3),"/",trim(e
      .reason_for_visit,3))
   ELSE
    m_rec->plist[ml_pcnt].c_admit_diagnosis = trim(e.reason_for_visit,3)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 FOR (ml_ploop = 1 TO ml_pcnt)
   FOR (ml_oloop = 1 TO m_rec->plist[ml_ploop].l_ocnt)
     SET g_request->person_id = m_rec->plist[ml_ploop].f_person_id
     SET g_request->printer_name =  $OUTDEV
     SET g_request->print_prsnl_id = 1.00
     SET stat = alterlist(g_request->order_qual,1)
     SET g_request->order_qual[1].encntr_id = m_rec->plist[ml_ploop].olist[ml_oloop].f_encntr_id
     SET g_request->order_qual[1].order_id = m_rec->plist[ml_ploop].olist[ml_oloop].f_order_id
     CALL echo("****** execute bhs_req_preg_layout - begin ******")
     CALL echorecord(g_request)
     EXECUTE bhs_req_preg_layout ms_call_program WITH replace("REQUEST",g_request)
     CALL echo("****** execute bhs_req_preg_layout - end ******")
   ENDFOR
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
END GO
