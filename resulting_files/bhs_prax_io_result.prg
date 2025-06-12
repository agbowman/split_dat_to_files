CREATE PROGRAM bhs_prax_io_result
 SET file_name = request->output_device
 DECLARE encntr_id = f8 WITH protect, constant(request->visit[1].encntr_id)
 DECLARE person_id = f8 WITH protect, constant(request->person[1].person_id)
 DECLARE io = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,"INTAKEANDOUTPUT"))
 DECLARE routeofadmin = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "ROUTEOFADMINISTRATION"))
 DECLARE intermittent = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",18309,"INTERMITTENT"))
 DECLARE med = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",18309,"MED"))
 DECLARE io_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",93,"IO"))
 DECLARE intake_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,"INTAKE"))
 DECLARE output_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,"OUTPUT"))
 SET begindate = request->nv[1].pvc_value
 SET enddate = request->nv[2].pvc_value
 IF (encntr_id != 1)
  SET where_params = build("O.ENCNTR_ID =",encntr_id," ")
  SET where_params1 = build("ce.ENCNTR_ID =",encntr_id," ")
 ELSE
  SET where_params = build("O.person_ID =",person_id," ")
  SET where_params1 = build("ce.person_ID =",person_id," ")
 ENDIF
 SELECT INTO value(file_name)
  dept_misc_line = trim(replace(replace(replace(replace(replace(o.dept_misc_line,"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), current_start_dt_tm = format(o
   .current_start_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), projected_stop_dt_tm = format(o
   .projected_stop_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
  order_status_cd = trim(replace(replace(replace(replace(replace(uar_get_code_display(o
         .order_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),
   3), result_val = trim(replace(replace(replace(replace(replace(ce.result_val,"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), result_units_cd = trim(replace(
    replace(replace(replace(replace(uar_get_code_display(ce.result_units_cd),"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  performed_dt_tm = format(ce.event_end_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), o_order_id = replace(
   cnvtstring(o.order_id),".00*","",0), ce_event_id = replace(cnvtstring(ce.parent_event_id),".00*",
   "",0),
  ce_result_status_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(ce
         .result_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
    ),3)
  FROM orders o,
   clinical_event ce
  PLAN (o
   WHERE parser(where_params)
    AND o.iv_ind=1)
   JOIN (ce
   WHERE ce.order_id=outerjoin(o.order_id)
    AND ce.event_tag != outerjoin("DCP GENERIC CODE")
    AND ce.valid_from_dt_tm < outerjoin(sysdate)
    AND ce.valid_until_dt_tm > outerjoin(sysdate)
    AND ce.event_reltn_cd=outerjoin(135.00)
    AND ce.event_end_dt_tm >= outerjoin(cnvtdatetime(cnvtdate2(substring(1,8,begindate),"YYYYMMDD"),
     cnvttime2(substring(9,4,begindate),"HHMM")))
    AND ce.event_end_dt_tm <= outerjoin(cnvtdatetime(cnvtdate2(substring(1,8,enddate),"YYYYMMDD"),
     cnvttime2(substring(9,4,enddate),"HHMM"))))
  ORDER BY o.order_id, ce.parent_event_id
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1, col + 1, "<ContinuousOrders>",
   row + 1
  HEAD o.order_id
   col 1, "<Orders>", row + 1,
   oid = build("<OrderId>",o_order_id,"</OrderId>"), col + 1, oid,
   row + 1, dep_disp = build("<DeptMiscLine>",dept_misc_line,"</DeptMiscLine>"), col + 1,
   dep_disp, row + 1, current_start = build("<StartDate>",current_start_dt_tm,"</StartDate>"),
   col + 1, current_start, row + 1,
   proj_stop = build("<StopDate>",projected_stop_dt_tm,"</StopDate>"), col + 1, proj_stop,
   row + 1, ord_status = build("<OrderStatus>",order_status_cd,"</OrderStatus>"), col + 1,
   ord_status, row + 1
  HEAD ce.parent_event_id
   IF (ce.parent_event_id > 0)
    col 1, "<Events>", row + 1,
    eid = build("<EventId>",ce_event_id,"</EventId>"), col + 1, eid,
    row + 1, epid = build("<ParentEventId>",ce_event_id,"</ParentEventId>"), col + 1,
    epid, row + 1, result_v = build("<Result>",result_val,"</Result>"),
    col + 1, result_v, row + 1,
    result_u = build("<ResultUnits>",result_units_cd,"</ResultUnits>"), col + 1, result_u,
    row + 1, perf_dt = build("<PerformDate>",performed_dt_tm,"</PerformDate>"), col + 1,
    perf_dt, row + 1, result_st = build("<ResultStatus>",ce_result_status_disp,"</ResultStatus>"),
    col + 1, result_st, row + 1,
    col 1, "</Events>", row + 1
   ENDIF
  FOOT  o.order_id
   col 1, "</Orders>", row + 1
  FOOT REPORT
   col + 1, "</ContinuousOrders>", row + 1
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 60
 ;end select
 SELECT INTO value(file_name)
  ce_parent_event_id = replace(cnvtstring(ce.parent_event_id),".00*","",0), c_event_id = replace(
   cnvtstring(c.event_id),".00*","",0), o_catalog_disp = trim(replace(replace(replace(replace(replace
       (uar_get_code_display(o.catalog_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
    '"',"&quot;",0),3),
  admin_end_dt_tm = format(c.admin_end_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), io_start_dt_tm = format(cr
   .io_start_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), io_end_dt_tm = format(cr.io_end_dt_tm,
   "MM/DD/YYYY HH:MM:SS;;D"),
  infused_volume = cr.io_volume, infused_volume_unit = trim(replace(replace(replace(replace(replace(
        uar_get_code_display(c.infused_volume_unit_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3), admin_dosage = c.admin_dosage,
  dosage_unit = trim(replace(replace(replace(replace(replace(uar_get_code_display(c.dosage_unit_cd),
        "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), c.event_id,
  hna_order_mnemonic = trim(replace(replace(replace(replace(replace(o.hna_order_mnemonic,"&","&amp;",
        0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  event_display = trim(replace(replace(replace(replace(replace(uar_get_code_display(ce.event_cd),"&",
        "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), diluent_display =
  trim(replace(replace(replace(replace(replace(uar_get_code_display(c.diluent_type_cd),"&","&amp;",0),
       "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
  FROM orders o,
   order_detail od,
   clinical_event ce,
   ce_med_result c,
   ce_intake_output_result cr
  PLAN (o
   WHERE parser(where_params)
    AND o.med_order_type_cd IN (intermittent, med))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id=routeofadmin
    AND od.oe_field_value IN (
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=4001
     AND cv.active_ind=1
     AND ((cv.cdf_meaning="IV") OR (cv.display_key="SWISHANDSPIT")) )))
   JOIN (ce
   WHERE ce.order_id=o.order_id
    AND ce.valid_from_dt_tm < sysdate
    AND ce.valid_until_dt_tm > sysdate
    AND ce.event_end_dt_tm >= cnvtdatetime(cnvtdate2(substring(1,8,begindate),"YYYYMMDD"),cnvttime2(
     substring(9,4,begindate),"HHMM"))
    AND ce.event_end_dt_tm <= cnvtdatetime(cnvtdate2(substring(1,8,enddate),"YYYYMMDD"),cnvttime2(
     substring(9,4,enddate),"HHMM")))
   JOIN (c
   WHERE c.event_id=ce.event_id)
   JOIN (cr
   WHERE cr.reference_event_id=ce.parent_event_id
    AND cr.encntr_id=o.encntr_id)
  ORDER BY o.catalog_cd, ce.parent_event_id, ce.event_id,
   ce.updt_dt_tm DESC
  HEAD REPORT
   col + 1, "<Medications>", row + 1
  HEAD o.catalog_cd
   col 1, "<OrderCatalog>", row + 1,
   oid = build("<CatalogCd>",cnvtint(o.catalog_cd),"</CatalogCd>"), col + 1, oid,
   row + 1, ccd = build("<CatalogDisplay>",o_catalog_disp,"</CatalogDisplay>"), col + 1,
   ccd, row + 1, hna = build("<HNAOrderMnemonic>",hna_order_mnemonic,"</HNAOrderMnemonic>"),
   col + 1, hna, row + 1
  HEAD ce.parent_event_id
   col 1, "<ParentEvents>", row + 1
  DETAIL
   col 1, "<ChildEvents>", row + 1,
   v0 = build("<EventDisplay>",event_display,"</EventDisplay>"), col + 1, v0,
   row + 1, v1 = build("<EventId>",c_event_id,"</EventId>"), col + 1,
   v1, row + 1, v1_1 = build("<ParentEventId>",ce_parent_event_id,"</ParentEventId>"),
   col + 1, v1_1, row + 1,
   v2 = build("<AdminDate>",admin_end_dt_tm,"</AdminDate>"), col + 1, v2,
   row + 1, v3 = build("<InfuseVolume>",infused_volume,"</InfuseVolume>"), col + 1,
   v3, row + 1, v4 = build("<InfuseVolumeUnit>",infused_volume_unit,"</InfuseVolumeUnit>"),
   col + 1, v4, row + 1,
   v5 = build("<AdminDosage>",admin_dosage,"</AdminDosage>"), col + 1, v5,
   row + 1, v6 = build("<DosageUnit>",dosage_unit,"</DosageUnit>"), col + 1,
   v6, row + 1, v7 = build("<DosageUnit>",dosage_unit,"</DosageUnit>"),
   col + 1, v7, row + 1,
   v8 = build("<DiluentDisplay>",diluent_display,"</DiluentDisplay>"), col + 1, v8,
   row + 1, v9 = build("<IOStartDate>",io_start_dt_tm,"</IOStartDate>"), col + 1,
   v9, row + 1, v10 = build("<IOEndDate>",io_end_dt_tm,"</IOEndDate>"),
   col + 1, v10, row + 1,
   col 1, "</ChildEvents>", row + 1
  FOOT  ce.parent_event_id
   col 1, "</ParentEvents>", row + 1
  FOOT  o.catalog_cd
   col 1, "</OrderCatalog>", row + 1
  FOOT REPORT
   col + 1, "</Medications>", row + 1
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 60, append
 ;end select
 SELECT DISTINCT INTO value(file_name)
  band = trim(replace(replace(replace(replace(replace(uar_get_code_display(v.parent_event_set_cd),"&",
        "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), io_type = trim(
   replace(replace(replace(replace(replace(uar_get_code_display(v.event_set_cd),"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), io_disp_seq = v
  .event_set_collating_seq,
  section = trim(replace(replace(replace(replace(replace(uar_get_code_display(v1.event_set_cd),"&",
        "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), section_disp_seq
   = v1.event_set_collating_seq, dynamic_label = trim(replace(replace(replace(replace(replace(cd
        .label_name,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  dynamic_label_id = cnvtint(cd.label_template_id), event_disp = trim(replace(replace(replace(replace
      (replace(uar_get_code_display(ve1.event_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3), result_val = trim(replace(replace(replace(replace(replace(ce
        .result_val,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  ce_result_units_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(ce
         .result_units_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),
   3), event_end_dt = format(ce.event_end_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), ce_event_id = replace(
   cnvtstring(ce.event_id),".00*","",0),
  ce_result_status_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(ce
         .result_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
    ),3), ce_parent_event_id = replace(cnvtstring(ce.parent_event_id),".00*","",0)
  FROM v500_event_set_canon v,
   v500_event_set_canon v1,
   v500_event_set_explode ve1,
   clinical_event ce,
   ce_dynamic_label cd
  PLAN (v
   WHERE v.parent_event_set_cd=0)
   JOIN (v1
   WHERE v1.parent_event_set_cd=v.event_set_cd)
   JOIN (ve1
   WHERE ve1.event_set_cd=v1.event_set_cd)
   JOIN (ce
   WHERE ce.event_cd=ve1.event_cd
    AND parser(where_params1)
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(cnvtdate2(substring(1,8,begindate),"YYYYMMDD"),
    cnvttime2(substring(9,4,begindate),"HHMM")) AND cnvtdatetime(cnvtdate2(substring(1,8,enddate),
     "YYYYMMDD"),cnvttime2(substring(9,4,enddate),"HHMM"))
    AND ce.valid_from_dt_tm < sysdate
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (cd
   WHERE cd.ce_dynamic_label_id=outerjoin(ce.ce_dynamic_label_id))
  ORDER BY v.event_set_cd, v1.event_set_cd, cd.label_name,
   ve1.event_cd, ce.event_id, ce.updt_dt_tm DESC
  HEAD REPORT
   col + 1, "<MiscIntake>", row + 1
  HEAD v.event_set_cd
   col 1, "<IOType>", row + 1,
   io_name = build("<IOTypeDisplay>",io_type,"</IOTypeDisplay>"), col + 1, io_name,
   row + 1, io_seq = build("<IOSeq>",io_disp_seq,"</IOSeq>"), col + 1,
   io_seq, row + 1
  HEAD v1.event_set_cd
   col 1, "<Section>", row + 1,
   sec_name = build("<SectionName>",section,"</SectionName>"), col + 1, sec_name,
   row + 1, sec_seq = build("<SectionSeq>",section_disp_seq,"</SectionSeq>"), col + 1,
   sec_seq, row + 1
  HEAD cd.label_name
   col 1, "<DynamicLabel>", row + 1,
   dyn_id = build("<DynLabelID>",dynamic_label_id,"</DynLabelID>"), col + 1, dyn_id,
   row + 1, dyn_name = build("<DynLabelName>",dynamic_label,"</DynLabelName>"), col + 1,
   dyn_name, row + 1
  HEAD ve1.event_cd
   col 1, "<Events>", row + 1,
   event_name = build("<EventName>",event_disp,"</EventName>"), col + 1, event_name,
   row + 1, event_code = build("<EventCode>",cnvtint(ce.event_cd),"</EventCode>"), col + 1,
   event_code, row + 1
  DETAIL
   col 1, "<Results>", row + 1,
   event_id = build("<EventId>",ce_event_id,"</EventId>"), col + 1, event_id,
   row + 1, epid = build("<ParentEventId>",ce_parent_event_id,"</ParentEventId>"), col + 1,
   epid, row + 1, result_value = build("<ResultVal>",result_val,"</ResultVal>"),
   col + 1, result_value, row + 1,
   result_units = build("<ResultUnits>",ce_result_units_disp,"</ResultUnits>"), col + 1, result_units,
   row + 1, result_dt = build("<ResultDtTime>",event_end_dt,"</ResultDtTime>"), col + 1,
   result_dt, row + 1, result_st = build("<ResultStatus>",ce_result_status_disp,"</ResultStatus>"),
   col + 1, result_st, row + 1,
   col 1, "</Results>", row + 1
  FOOT  ve1.event_cd
   col 1, "</Events>", row + 1
  FOOT  cd.label_name
   col 1, "</DynamicLabel>", row + 1
  FOOT  v1.event_set_cd
   col 1, "</Section>", row + 1
  FOOT  v.event_set_cd
   col 1, "</IOType>", row + 1
  FOOT REPORT
   row + 1, col + 1, "</MiscIntake>",
   row + 1
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 120, append
 ;end select
 SELECT DISTINCT INTO value(file_name)
  band = trim(replace(replace(replace(replace(replace(uar_get_code_display(v.parent_event_set_cd),"&",
        "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), io_type = trim(
   replace(replace(replace(replace(replace(uar_get_code_display(v.event_set_cd),"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), io_disp_seq = v
  .event_set_collating_seq,
  section = trim(replace(replace(replace(replace(replace(uar_get_code_display(v1.event_set_cd),"&",
        "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), section_disp_seq
   = v1.event_set_collating_seq, dynamic_label = trim(replace(replace(replace(replace(replace(cd
        .label_name,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  dynamic_label_id = cnvtint(cd.label_template_id), event_disp = trim(replace(replace(replace(replace
      (replace(uar_get_code_display(ve1.event_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3), result_val = trim(replace(replace(replace(replace(replace(ce
        .result_val,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  ce_result_units_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(ce
         .result_units_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),
   3), event_end_dt = format(ce.event_end_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), ce_event_id = replace(
   cnvtstring(ce.event_id),".00*","",0),
  ce_result_status_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(ce
         .result_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
    ),3), d.io_flag, ce_parent_event_id = replace(cnvtstring(ce.parent_event_id),".00*","",0)
  FROM v500_event_set_canon v,
   v500_event_set_canon v1,
   v500_event_set_explode ve1,
   clinical_event ce,
   ce_dynamic_label cd,
   discrete_task_assay d
  PLAN (v
   WHERE v.parent_event_set_cd=io_cd)
   JOIN (v1
   WHERE v1.parent_event_set_cd=v.event_set_cd)
   JOIN (ve1
   WHERE ve1.event_set_cd=v1.event_set_cd)
   JOIN (ce
   WHERE ce.event_cd=ve1.event_cd
    AND parser(where_params1)
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(cnvtdate2(substring(1,8,begindate),"YYYYMMDD"),
    cnvttime2(substring(9,4,begindate),"HHMM")) AND cnvtdatetime(cnvtdate2(substring(1,8,enddate),
     "YYYYMMDD"),cnvttime2(substring(9,4,enddate),"HHMM"))
    AND ce.valid_from_dt_tm < sysdate
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (d
   WHERE d.event_cd=outerjoin(ce.event_cd))
   JOIN (cd
   WHERE cd.ce_dynamic_label_id=outerjoin(ce.ce_dynamic_label_id))
  ORDER BY v.event_set_cd, v1.event_set_cd, cd.label_name,
   ve1.event_cd, ce.event_id, ce.updt_dt_tm DESC
  HEAD REPORT
   col + 1, "<IntakeOutput>", row + 1
  HEAD v.event_set_cd
   col 1, "<IOType>", row + 1,
   io_name = build("<IOTypeDisplay>",io_type,"</IOTypeDisplay>"), col + 1, io_name,
   row + 1, io_seq = build("<IOSeq>",io_disp_seq,"</IOSeq>"), col + 1,
   io_seq, row + 1
  HEAD v1.event_set_cd
   col 1, "<Section>", row + 1,
   sec_name = build("<SectionName>",section,"</SectionName>"), col + 1, sec_name,
   row + 1, sec_seq = build("<SectionSeq>",section_disp_seq,"</SectionSeq>"), col + 1,
   sec_seq, row + 1
  HEAD cd.label_name
   col 1, "<DynamicLabel>", row + 1,
   dyn_id = build("<DynLabelID>",dynamic_label_id,"</DynLabelID>"), col + 1, dyn_id,
   row + 1, dyn_name = build("<DynLabelName>",dynamic_label,"</DynLabelName>"), col + 1,
   dyn_name, row + 1
  HEAD ve1.event_cd
   col 1, "<Events>", row + 1,
   event_name = build("<EventName>",event_disp,"</EventName>"), col + 1, event_name,
   row + 1, event_code = build("<EventCode>",cnvtint(ce.event_cd),"</EventCode>"), col + 1,
   event_code, row + 1
  DETAIL
   col 1, "<Results>", row + 1,
   event_id = build("<EventId>",ce_event_id,"</EventId>"), col + 1, event_id,
   row + 1, epid = build("<ParentEventId>",ce_parent_event_id,"</ParentEventId>"), col + 1,
   epid, row + 1, result_value = build("<ResultVal>",result_val,"</ResultVal>"),
   col + 1, result_value, row + 1,
   result_units = build("<ResultUnits>",ce_result_units_disp,"</ResultUnits>"), col + 1, result_units,
   row + 1, result_dt = build("<ResultDtTime>",event_end_dt,"</ResultDtTime>"), col + 1,
   result_dt, row + 1, result_st = build("<ResultStatus>",ce_result_status_disp,"</ResultStatus>"),
   col + 1, result_st, row + 1,
   io_flag = build("<IntakeOutputFl>",cnvtint(d.io_flag),"</IntakeOutputFl>"), col + 1, io_flag,
   row + 1, col 1, "</Results>",
   row + 1
  FOOT  ve1.event_cd
   col 1, "</Events>", row + 1
  FOOT  cd.label_name
   col 1, "</DynamicLabel>", row + 1
  FOOT  v1.event_set_cd
   col 1, "</Section>", row + 1
  FOOT  v.event_set_cd
   col 1, "</IOType>", row + 1
  FOOT REPORT
   row + 1, col + 1, "</IntakeOutput>",
   row + 1, col + 1, "</ReplyMessage>",
   row + 1
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 120, append
 ;end select
END GO
