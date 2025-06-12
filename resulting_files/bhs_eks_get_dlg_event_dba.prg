CREATE PROGRAM bhs_eks_get_dlg_event:dba
 RECORD eksdlgevent(
   1 qual_cnt = i4
   1 status = c1
   1 status_msg = vc
   1 qual[*]
     2 dlg_event_id = f8
     2 dlg_name = vc
     2 module_name = c30
     2 dlg_prsnl_id = f8
     2 updt_dt_tm = dq8
     2 person_id = f8
     2 encntr_id = f8
     2 long_text_id = f8
     2 trigger_entity_id = f8
     2 trigger_entity_name = c32
     2 trigger_order_id = f8
     2 override_reason_cd = f8
     2 long_text_id = f8
     2 alert_long_text_id = f8
     2 srcstring = vc
     2 catdisp = c40
     2 severity = vc
     2 attr_cnt = i4
     2 attr[*]
       3 attr_name = c32
       3 attr_id = f8
       3 attr_value = vc
 )
 SELECT INTO "nl:"
  dlgname = trim(e.dlg_name)
  FROM eks_dlg_event e,
   eks_dlg_event_attr ea
  PLAN (e
   WHERE (e.updt_dt_tm > (sysdate - 1)))
   JOIN (ea
   WHERE e.dlg_event_id=ea.dlg_event_id)
  ORDER BY e.dlg_event_id
  HEAD REPORT
   rec_cnt = 0
  HEAD e.dlg_event_id
   rec_cnt = (rec_cnt+ 1)
   IF (mod(rec_cnt,100)=1)
    stat = alterlist(eksdlgevent->qual,(rec_cnt+ 99))
   ENDIF
   eksdlgevent->qual[rec_cnt].dlg_event_id = e.dlg_event_id, eksdlgevent->qual[rec_cnt].dlg_name =
   dlgname, exclptr = findstring("!",dlgname)
   IF (exclptr)
    eksdlgevent->qual[rec_cnt].module_name = substring((exclptr+ 1),(size(dlgname) - exclptr),dlgname
     )
   ELSE
    eksdlgevent->qual[rec_cnt].module_name = dlgname
   ENDIF
   eksdlgevent->qual[rec_cnt].dlg_prsnl_id = e.dlg_prsnl_id, eksdlgevent->qual[rec_cnt].updt_dt_tm =
   e.updt_dt_tm, eksdlgevent->qual[rec_cnt].person_id = e.person_id,
   eksdlgevent->qual[rec_cnt].encntr_id = e.encntr_id, eksdlgevent->qual[rec_cnt].long_text_id = e
   .long_text_id, eksdlgevent->qual[rec_cnt].trigger_entity_id = e.trigger_entity_id,
   eksdlgevent->qual[rec_cnt].trigger_entity_name = e.trigger_entity_name, eksdlgevent->qual[rec_cnt]
   .trigger_order_id = e.trigger_order_id, eksdlgevent->qual[rec_cnt].override_reason_cd = e
   .override_reason_cd,
   eksdlgevent->qual[rec_cnt].long_text_id = e.long_text_id, eksdlgevent->qual[rec_cnt].
   alert_long_text_id = e.alert_long_text_id, eksdlgevent->qual[rec_cnt].attr_cnt = 0,
   attr_cnt = 0
  DETAIL
   IF (ea.dlg_event_id > 0)
    attr_cnt = (attr_cnt+ 1)
    IF (mod(attr_cnt,10)=1)
     stat = alterlist(eksdlgevent->qual[rec_cnt].attr,(attr_cnt+ 9))
    ENDIF
    eksdlgevent->qual[rec_cnt].attr[attr_cnt].attr_name = ea.attr_name, eksdlgevent->qual[rec_cnt].
    attr[attr_cnt].attr_id = ea.attr_id, eksdlgevent->qual[rec_cnt].attr[attr_cnt].attr_value = ea
    .attr_value
    IF (trim(ea.attr_name) IN ("CATALOG_CD", "ORDER_CATALOG")
     AND ea.attr_id > 0)
     eksdlgevent->qual[rec_cnt].catdisp = uar_get_code_display(ea.attr_id)
    ELSEIF (trim(ea.attr_name)="SEVERITY*")
     eksdlgevent->qual[rec_cnt].severity = trim(ea.attr_value)
    ENDIF
   ENDIF
  FOOT  e.dlg_event_id
   stat = alterlist(eksdlgevent->qual[rec_cnt].attr,attr_cnt), eksdlgevent->qual[rec_cnt].attr_cnt =
   attr_cnt
  FOOT REPORT
   stat = alterlist(eksdlgevent->qual,rec_cnt), eksdlgevent->qual_cnt = rec_cnt, eksdlgevent->status
    = "S",
   eksdlgevent->status_msg = build(rec_cnt," qualifying records were found")
  WITH nocounter
 ;end select
#endprogram
 CALL echorecord(eksdlgevent)
END GO
