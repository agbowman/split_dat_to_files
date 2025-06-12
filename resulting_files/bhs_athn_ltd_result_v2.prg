CREATE PROGRAM bhs_athn_ltd_result_v2
 DECLARE encntr_id = f8 WITH protect, constant( $2)
 DECLARE iview = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",29520,"WORKINGVIEW"))
 DECLARE coding_status = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 SET begindate =  $3
 SET enddate =  $4
 DECLARE working_view_id = f8
 RECORD reply(
   1 group[*]
     2 group_name = vc
     2 band[*]
       3 band_name = vc
       3 dynamic_label[*]
         4 section[*]
           5 section_name = vc
           5 last_document_date = vc
           5 last_document_result = vc
         4 dynamic_label_name = vc
         4 initial_document_date = vc
 )
 SELECT INTO "NL:"
  w.working_view_id
  FROM working_view w
  PLAN (w
   WHERE cnvtupper(w.display_name)="CRITICAL CARE QUICKVIEW")
  DETAIL
   working_view_id = w.working_view_id
  WITH time = 10
 ;end select
 SELECT INTO "NL:"
  g_name =
  IF (trim(wv.display_name) != "Tubes/Drains") "Lines"
  ELSE "Tubes/Drains"
  ENDIF
  FROM working_view_section wv,
   working_view_item wvi,
   code_value cv1,
   v500_event_set_code v1,
   v500_event_set_explode v2,
   v500_event_code v3,
   clinical_event ce,
   ce_dynamic_label c,
   ce_date_result cd
  PLAN (wv
   WHERE wv.working_view_id=working_view_id
    AND wv.display_name > " ")
   JOIN (wvi
   WHERE wv.working_view_section_id=wvi.working_view_section_id)
   JOIN (cv1
   WHERE wvi.primitive_event_set_name=cv1.description
    AND cv1.code_set=93)
   JOIN (v1
   WHERE v1.event_set_name=wvi.primitive_event_set_name
    AND v1.code_status_cd=coding_status)
   JOIN (v2
   WHERE v2.event_set_cd=v1.event_set_cd)
   JOIN (v3
   WHERE v3.event_cd=v2.event_cd
    AND v3.code_status_cd=coding_status)
   JOIN (ce
   WHERE ce.event_cd=v3.event_cd
    AND ce.encntr_id=encntr_id
    AND ce.entry_mode_cd=iview
    AND ce.valid_from_dt_tm < sysdate
    AND ce.valid_until_dt_tm > sysdate
    AND ce.verified_dt_tm BETWEEN cnvtdatetime(begindate) AND cnvtdatetime(enddate))
   JOIN (c
   WHERE c.ce_dynamic_label_id=ce.ce_dynamic_label_id)
   JOIN (cd
   WHERE (cd.event_id= Outerjoin(ce.event_id)) )
  ORDER BY g_name, wv.display_name, c.ce_dynamic_label_id,
   ce.event_cd, ce.clinsig_updt_dt_tm DESC
  HEAD REPORT
   cnt = 0
  HEAD g_name
   cnt += 1, stat = alterlist(reply->group,cnt), reply->group[cnt].group_name = g_name,
   cnt1 = 0
  HEAD wv.display_name
   cnt1 += 1, stat = alterlist(reply->group[cnt].band,cnt1), reply->group[cnt].band[cnt1].band_name
    = wv.display_name,
   cnt2 = 0
  HEAD c.ce_dynamic_label_id
   cnt2 += 1, stat = alterlist(reply->group[cnt].band[cnt1].dynamic_label,cnt2), temp_cnt = 0,
   cnt3 = 0
  HEAD ce.event_cd
   cnt3 += 1, stat = alterlist(reply->group[cnt].band[cnt1].dynamic_label[cnt2].section,cnt3), reply
   ->group[cnt].band[cnt1].dynamic_label[cnt2].section[cnt3].section_name = cv1.display,
   reply->group[cnt].band[cnt1].dynamic_label[cnt2].section[cnt3].last_document_date = format(ce
    .performed_dt_tm,"MM/DD/YYYY HH:MM:SS;;D")
   IF (cd.event_id=0.0)
    reply->group[cnt].band[cnt1].dynamic_label[cnt2].section[cnt3].last_document_result = ce
    .result_val
   ELSE
    reply->group[cnt].band[cnt1].dynamic_label[cnt2].section[cnt3].last_document_result = format(cd
     .result_dt_tm,"MM/DD/YYYY HH:MM:SS;;D")
   ENDIF
  FOOT  ce.event_cd
   IF (temp_cnt=0)
    initial_doc_dt = format(ce.clinsig_updt_dt_tm,"MM/DD/YYYY HH:MM:SS;;D")
   ELSE
    IF (initial_doc_dt > format(ce.clinsig_updt_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"))
     initial_doc_dt = format(ce.clinsig_updt_dt_tm,"MM/DD/YYYY HH:MM:SS;;D")
    ENDIF
   ENDIF
   temp_cnt += 1
  FOOT  c.ce_dynamic_label_id
   reply->group[cnt].band[cnt1].dynamic_label[cnt2].dynamic_label_name = c.label_name, reply->group[
   cnt].band[cnt1].dynamic_label[cnt2].initial_document_date = initial_doc_dt
  WITH nocounter, time = 90
 ;end select
 SET _memory_reply_string = cnvtrectojson(reply)
END GO
