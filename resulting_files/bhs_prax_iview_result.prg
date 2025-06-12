CREATE PROGRAM bhs_prax_iview_result
 SET file_name = request->output_device
 DECLARE encntr_id = f8 WITH protect, constant(request->visit[1].encntr_id)
 DECLARE iview = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",29520,"WORKINGVIEW"))
 DECLARE active_ind = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4002015,"ACTIVE"))
 DECLARE coding_status = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 SET begindate = request->nv[1].pvc_value
 SET enddate = request->nv[2].pvc_value
 SELECT DISTINCT INTO value(file_name)
  band = trim(replace(replace(replace(replace(replace(wv.display_name,"&","&amp;",0),"<","&lt;",0),
      ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), dynamic_label = trim(replace(replace(replace(
      replace(replace(c.label_name,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3), section = trim(replace(replace(replace(replace(replace(cv1.display,"&","&amp;",0),
       "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  g_name = trim(replace(replace(replace(replace(replace(
        IF (trim(wv.display_name) != "Tubes/Drains") "Lines"
        ELSE "Tubes/Drains"
        ENDIF
        ,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), result =
  IF (cd.event_id=0.0) trim(replace(replace(replace(replace(replace(ce.result_val,"&","&amp;",0),"<",
        "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
  ELSE format(cd.result_dt_tm,"MM/DD/YYYY HH:MM:SS;;D")
  ENDIF
  , perf_dt = format(ce.performed_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
  clinsig_updt_dt_tm = format(ce.clinsig_updt_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), ce.event_id, ce
  .encntr_id
  FROM working_view w,
   working_view_section wv,
   working_view_item wvi,
   code_value cv1,
   v500_event_set_code v1,
   v500_event_set_explode v2,
   v500_event_code v3,
   clinical_event ce,
   ce_dynamic_label c,
   ce_date_result cd
  PLAN (w
   WHERE cnvtupper(w.display_name)="CRITICAL CARE QUICKVIEW")
   JOIN (wv
   WHERE w.working_view_id=wv.working_view_id
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
    AND ce.verified_dt_tm BETWEEN cnvtdatetime(cnvtdate2(substring(1,8,begindate),"YYYYMMDD"),
    cnvttime2(substring(9,4,begindate),"HHMM")) AND cnvtdatetime(cnvtdate2(substring(1,8,enddate),
     "YYYYMMDD"),cnvttime2(substring(9,4,enddate),"HHMM")))
   JOIN (c
   WHERE c.ce_dynamic_label_id=ce.ce_dynamic_label_id)
   JOIN (cd
   WHERE cd.event_id=outerjoin(ce.event_id))
  ORDER BY g_name, wv.display_name, c.ce_dynamic_label_id,
   ce.event_cd, ce.clinsig_updt_dt_tm DESC
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  HEAD g_name
   col 1, "<Group>", row + 1,
   group_name = build("<GroupName>",g_name,"</GroupName>"), col + 1, group_name,
   row + 1
  HEAD wv.display_name
   col 1, "<Band>", row + 1,
   band_name = build("<BandName>",band,"</BandName>"), col + 1, band_name,
   row + 1
  HEAD c.ce_dynamic_label_id
   col 1, "<DynamicLabel>", row + 1,
   temp_cnt = 0
  HEAD ce.event_cd
   col 1, "<Section>", row + 1,
   section_name = build("<SectionName>",section,"</SectionName>"), col + 1, section_name,
   row + 1, lp_date = build("<LastDocumentDate>",perf_dt,"</LastDocumentDate>"), col + 1,
   lp_date, row + 1, lp_result = build("<LastDocumentResult>",result,"</LastDocumentResult>"),
   col + 1, lp_result, row + 1,
   col 1, "</Section>", row + 1
  FOOT  ce.event_cd
   IF (temp_cnt=0)
    initial_doc_dt = clinsig_updt_dt_tm
   ELSE
    IF (initial_doc_dt > clinsig_updt_dt_tm)
     initial_doc_dt = clinsig_updt_dt_tm
    ENDIF
   ENDIF
   temp_cnt = (temp_cnt+ 1)
  FOOT  c.ce_dynamic_label_id
   label_name = build("<DynamicLabelName>",dynamic_label,"</DynamicLabelName>"), col + 1, label_name,
   row + 1, init_document = build("<InitialDocumentDate>",initial_doc_dt,"</InitialDocumentDate>"),
   col + 1,
   init_document, row + 1, col 1,
   "</DynamicLabel>", row + 1
  FOOT  wv.display_name
   col 1, "</Band>", row + 1
  FOOT  g_name
   col 1, "</Group>", row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH nocounter, nullreport, formfeed = none,
   maxcol = 1000, format = variable, maxrow = 0,
   time = 90
 ;end select
END GO
