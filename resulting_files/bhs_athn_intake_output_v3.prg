CREATE PROGRAM bhs_athn_intake_output_v3
 DECLARE file_name = vc
 DECLARE encntr_id = f8 WITH protect, constant( $3)
 DECLARE person_id = f8 WITH protect, constant( $2)
 DECLARE io = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,"INTAKEANDOUTPUT"))
 DECLARE routeofadmin = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "ROUTEOFADMINISTRATION"))
 DECLARE intermittent = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",18309,"INTERMITTENT"))
 DECLARE med = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",18309,"MED"))
 DECLARE io_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",93,"IO"))
 DECLARE intake_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,"INTAKE"))
 DECLARE output_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,"OUTPUT"))
 DECLARE event_reltn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",24,"R"))
 FREE RECORD continuousorders
 RECORD continuousorders(
   1 orders[*]
     2 orderid = c50
     2 deptmiscline = c500
     2 startdate = c50
     2 stopdate = c50
     2 orderstatus = c50
     2 events[*]
       3 eventid = c50
       3 parenteventid = c50
       3 result = c50
       3 resultunits = c50
       3 performdate = c50
       3 resultstatus = c50
 )
 FREE RECORD medications
 RECORD medications(
   1 ordercatalog[*]
     2 catalogcd = c50
     2 catalogdisplay = c500
     2 hnaordermnemonic = c500
     2 parentevents[*]
       3 childevents[*]
         4 eventid = c50
         4 parenteventid = c50
         4 eventdisplay = c500
         4 admindate = c50
         4 infusevolume = c500
         4 infusevolumeunit = c50
         4 admindosage = c50
         4 dosageunit = c50
         4 dosageunit = c50
         4 diluentdisplay = c500
         4 iostartdate = c50
         4 ioenddate = c50
 )
 FREE RECORD miscintake
 RECORD miscintake(
   1 iotype[*]
     2 iotypedisplay = c500
     2 ioseq = c50
     2 section[*]
       3 sectionname = c500
       3 sectionseq = c50
       3 dynamiclabel[*]
         4 dynlabelid = c50
         4 dynlabelname = c500
         4 events[*]
           5 eventname = c500
           5 eventcode = c500
           5 results[*]
             6 eventid = c50
             6 parenteventid = c50
             6 resultval = c50
             6 resultunits = c50
             6 resultdttime = c50
             6 resultstatus = c50
 )
 FREE RECORD intakeoutput
 RECORD intakeoutput(
   1 iotype[*]
     2 iotypedisplay = c500
     2 ioseq = c50
     2 section[*]
       3 sectionname = c500
       3 sectionseq = c50
       3 dynamiclabel[*]
         4 dynlabelid = c50
         4 dynlabelname = c500
         4 events[*]
           5 eventname = c500
           5 eventcode = c500
           5 results[*]
             6 eventid = c50
             6 parenteventid = c50
             6 resultval = c50
             6 resultunits = c50
             6 resultdttime = c50
             6 resultstatus = c50
             6 intakeoutputfl = c50
 )
 DECLARE ocnt1 = i4 WITH protect, noconstant(0)
 DECLARE ocnt2 = i4 WITH protect, noconstant(0)
 DECLARE mcnt1 = i4 WITH protect, noconstant(0)
 DECLARE mcnt2 = i4 WITH protect, noconstant(0)
 DECLARE mcnt3 = i4 WITH protect, noconstant(0)
 DECLARE icnt1 = i4 WITH protect, noconstant(0)
 DECLARE icnt2 = i4 WITH protect, noconstant(0)
 DECLARE icnt3 = i4 WITH protect, noconstant(0)
 DECLARE icnt4 = i4 WITH protect, noconstant(0)
 DECLARE icnt5 = i4 WITH protect, noconstant(0)
 DECLARE cnt1 = i4 WITH protect, noconstant(0)
 DECLARE cnt2 = i4 WITH protect, noconstant(0)
 DECLARE cnt3 = i4 WITH protect, noconstant(0)
 DECLARE cnt4 = i4 WITH protect, noconstant(0)
 DECLARE cnt5 = i4 WITH protect, noconstant(0)
 SET begindate =  $4
 SET enddate =  $5
 IF (encntr_id > 1)
  SET where_params = build("O.ENCNTR_ID =",encntr_id," ")
  SET where_params1 = build("ce.ENCNTR_ID =",encntr_id," ")
 ELSE
  SET where_params = build("O.person_ID =",person_id," ")
  SET where_params1 = build("ce.person_ID =",person_id," ")
 ENDIF
 SELECT INTO "NL:"
  FROM orders o,
   clinical_event ce,
   ce_intake_output_result cr
  PLAN (o
   WHERE parser(where_params)
    AND o.iv_ind=1)
   JOIN (ce
   WHERE ce.order_id=o.order_id
    AND ce.event_tag != "DCP GENERIC CODE"
    AND ce.valid_from_dt_tm < sysdate
    AND ce.valid_until_dt_tm > sysdate
    AND ce.event_reltn_cd=event_reltn_cd
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(begindate) AND cnvtdatetime(enddate))
   JOIN (cr
   WHERE cr.reference_event_id=ce.parent_event_id
    AND cr.encntr_id=o.encntr_id)
  ORDER BY o.order_id, ce.parent_event_id
  HEAD o.order_id
   ocnt1 += 1, stat = alterlist(continuousorders->orders,ocnt1), continuousorders->orders[ocnt1].
   orderid = cnvtstring(o.order_id),
   continuousorders->orders[ocnt1].deptmiscline = trim(replace(replace(replace(replace(replace(o
         .dept_misc_line,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3
    ), continuousorders->orders[ocnt1].startdate = format(o.current_start_dt_tm,
    "MM/DD/YYYY HH:MM:SS;;D"), continuousorders->orders[ocnt1].stopdate = format(o
    .projected_stop_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
   continuousorders->orders[ocnt1].orderstatus = uar_get_code_display(o.order_status_cd), ocnt2 = 0
  HEAD ce.parent_event_id
   IF (ce.parent_event_id > 0)
    ocnt2 += 1, stat = alterlist(continuousorders->orders[ocnt1].events,ocnt2), continuousorders->
    orders[ocnt1].events[ocnt2].eventid = cnvtstring(ce.parent_event_id),
    continuousorders->orders[ocnt1].events[ocnt2].parenteventid = cnvtstring(ce.parent_event_id),
    continuousorders->orders[ocnt1].events[ocnt2].result = trim(replace(replace(replace(replace(
         replace(ce.result_val,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
      "&quot;",0),3), continuousorders->orders[ocnt1].events[ocnt2].resultunits = trim(replace(
      replace(replace(replace(replace(uar_get_code_display(ce.result_units_cd),"&","&amp;",0),"<",
         "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
    continuousorders->orders[ocnt1].events[ocnt2].performdate = format(ce.event_end_dt_tm,
     "MM/DD/YYYY HH:MM:SS;;D"), continuousorders->orders[ocnt1].events[ocnt2].resultstatus =
    uar_get_code_display(ce.result_status_cd)
   ENDIF
  WITH time = 30
 ;end select
 SELECT INTO "NL:"
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
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(begindate) AND cnvtdatetime(enddate))
   JOIN (c
   WHERE c.event_id=ce.event_id)
   JOIN (cr
   WHERE cr.reference_event_id=ce.parent_event_id
    AND cr.encntr_id=o.encntr_id)
  ORDER BY o.catalog_cd, ce.parent_event_id, ce.event_id,
   ce.updt_dt_tm DESC
  HEAD o.catalog_cd
   mcnt1 += 1, stat = alterlist(medications->ordercatalog,mcnt1), medications->ordercatalog[mcnt1].
   catalogcd = cnvtstring(o.catalog_cd),
   medications->ordercatalog[mcnt1].catalogdisplay = trim(replace(replace(replace(replace(replace(
         uar_get_code_display(o.catalog_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0
      ),'"',"&quot;",0),3), medications->ordercatalog[mcnt1].hnaordermnemonic = trim(replace(replace(
      replace(replace(replace(o.hna_order_mnemonic,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
      "&apos;",0),'"',"&quot;",0),3), mcnt2 = 0
  HEAD ce.parent_event_id
   mcnt2 += 1, stat = alterlist(medications->ordercatalog[mcnt1].parentevents,mcnt2), mcnt3 = 0
  DETAIL
   mcnt3 += 1, stat = alterlist(medications->ordercatalog[mcnt1].parentevents[mcnt2].childevents,
    mcnt3), medications->ordercatalog[mcnt1].parentevents[mcnt2].childevents[mcnt3].eventdisplay =
   trim(replace(replace(replace(replace(replace(uar_get_code_display(ce.event_cd),"&","&amp;",0),"<",
        "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   medications->ordercatalog[mcnt1].parentevents[mcnt2].childevents[mcnt3].eventid = cnvtstring(c
    .event_id), medications->ordercatalog[mcnt1].parentevents[mcnt2].childevents[mcnt3].parenteventid
    = cnvtstring(ce.parent_event_id), medications->ordercatalog[mcnt1].parentevents[mcnt2].
   childevents[mcnt3].admindate = format(c.admin_end_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
   medications->ordercatalog[mcnt1].parentevents[mcnt2].childevents[mcnt3].infusevolume = cnvtstring(
    cr.io_volume), medications->ordercatalog[mcnt1].parentevents[mcnt2].childevents[mcnt3].
   infusevolumeunit = trim(replace(replace(replace(replace(replace(uar_get_code_display(c
          .infused_volume_unit_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
     "&quot;",0),3), medications->ordercatalog[mcnt1].parentevents[mcnt2].childevents[mcnt3].
   admindosage = cnvtstring(c.admin_dosage),
   medications->ordercatalog[mcnt1].parentevents[mcnt2].childevents[mcnt3].dosageunit = trim(replace(
     replace(replace(replace(replace(uar_get_code_display(c.dosage_unit_cd),"&","&amp;",0),"<","&lt;",
        0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), medications->ordercatalog[mcnt1].
   parentevents[mcnt2].childevents[mcnt3].diluentdisplay = trim(replace(replace(replace(replace(
        replace(uar_get_code_display(c.diluent_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
      "'","&apos;",0),'"',"&quot;",0),3), medications->ordercatalog[mcnt1].parentevents[mcnt2].
   childevents[mcnt3].iostartdate = format(cr.io_start_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
   medications->ordercatalog[mcnt1].parentevents[mcnt2].childevents[mcnt3].ioenddate = format(cr
    .io_end_dt_tm,"MM/DD/YYYY HH:MM:SS;;D")
  WITH time = 30
 ;end select
 SELECT DISTINCT INTO "NL:"
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
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(begindate) AND cnvtdatetime(enddate)
    AND ce.valid_from_dt_tm < sysdate
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (d
   WHERE (d.event_cd= Outerjoin(ce.event_cd)) )
   JOIN (cd
   WHERE (cd.ce_dynamic_label_id= Outerjoin(ce.ce_dynamic_label_id)) )
  ORDER BY v.event_set_cd, v1.event_set_cd, cd.label_name,
   ve1.event_cd, ce.event_id, ce.updt_dt_tm DESC
  HEAD v.event_set_cd
   cnt1 += 1, stat = alterlist(intakeoutput->iotype,cnt1), intakeoutput->iotype[cnt1].iotypedisplay
    = trim(replace(replace(replace(replace(replace(uar_get_code_display(v.event_set_cd),"&","&amp;",0
         ),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   intakeoutput->iotype[cnt1].ioseq = cnvtstring(v.event_set_collating_seq), cnt2 = 0
  HEAD v1.event_set_cd
   cnt2 += 1, stat = alterlist(intakeoutput->iotype[cnt1].section,cnt2), intakeoutput->iotype[cnt1].
   section[cnt2].sectionname = trim(replace(replace(replace(replace(replace(uar_get_code_display(v1
          .event_set_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3
    ),
   intakeoutput->iotype[cnt1].section[cnt2].sectionseq = cnvtstring(v1.event_set_collating_seq), cnt3
    = 0
  HEAD cd.label_name
   cnt3 += 1, stat = alterlist(intakeoutput->iotype[cnt1].section[cnt2].dynamiclabel,cnt3),
   intakeoutput->iotype[cnt1].section[cnt2].dynamiclabel[cnt3].dynlabelid = cnvtstring(cd
    .label_template_id),
   intakeoutput->iotype[cnt1].section[cnt2].dynamiclabel[cnt3].dynlabelname = trim(replace(replace(
      replace(replace(replace(cd.label_name,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0
      ),'"',"&quot;",0),3), cnt4 = 0
  HEAD ve1.event_cd
   cnt4 += 1, stat = alterlist(intakeoutput->iotype[cnt1].section[cnt2].dynamiclabel[cnt3].events,
    cnt4), intakeoutput->iotype[cnt1].section[cnt2].dynamiclabel[cnt3].events[cnt4].eventname = trim(
    replace(replace(replace(replace(replace(uar_get_code_display(ve1.event_cd),"&","&amp;",0),"<",
        "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   intakeoutput->iotype[cnt1].section[cnt2].dynamiclabel[cnt3].events[cnt4].eventcode = cnvtstring(ce
    .event_cd), cnt5 = 0
  DETAIL
   cnt5 += 1, stat = alterlist(intakeoutput->iotype[cnt1].section[cnt2].dynamiclabel[cnt3].events[
    cnt4].results,cnt5), intakeoutput->iotype[cnt1].section[cnt2].dynamiclabel[cnt3].events[cnt4].
   results[cnt5].eventid = cnvtstring(ce.event_id),
   intakeoutput->iotype[cnt1].section[cnt2].dynamiclabel[cnt3].events[cnt4].results[cnt5].
   parenteventid = cnvtstring(ce.parent_event_id), intakeoutput->iotype[cnt1].section[cnt2].
   dynamiclabel[cnt3].events[cnt4].results[cnt5].resultval = trim(replace(replace(replace(replace(
        replace(ce.result_val,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
     0),3), intakeoutput->iotype[cnt1].section[cnt2].dynamiclabel[cnt3].events[cnt4].results[cnt5].
   resultunits = trim(replace(replace(replace(replace(replace(uar_get_code_display(ce.result_units_cd
          ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   intakeoutput->iotype[cnt1].section[cnt2].dynamiclabel[cnt3].events[cnt4].results[cnt5].
   resultdttime = format(ce.event_end_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), intakeoutput->iotype[cnt1].
   section[cnt2].dynamiclabel[cnt3].events[cnt4].results[cnt5].resultstatus = trim(replace(replace(
      replace(replace(replace(uar_get_code_display(ce.result_status_cd),"&","&amp;",0),"<","&lt;",0),
       ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), intakeoutput->iotype[cnt1].section[cnt2].
   dynamiclabel[cnt3].events[cnt4].results[cnt5].intakeoutputfl = cnvtstring(d.io_flag)
  WITH time = 45
 ;end select
 SELECT INTO  $1
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   t_line = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, t_line,
   row + 1, col 0, "<ReplyMessage>",
   row + 1
  DETAIL
   col + 1, "<ContinuousOrders>", row + 1
   FOR (i1 = 1 TO size(continuousorders->orders,5))
     col 1, "<Orders>", row + 1,
     oid = build("<OrderId>",trim(continuousorders->orders[i1].orderid,3),"</OrderId>"), col + 1, oid,
     row + 1, dep_disp = build("<DeptMiscLine>",trim(continuousorders->orders[i1].deptmiscline,3),
      "</DeptMiscLine>"), col + 1,
     dep_disp, row + 1, current_start = build("<StartDate>",trim(continuousorders->orders[i1].
       startdate,3),"</StartDate>"),
     col + 1, current_start, row + 1,
     proj_stop = build("<StopDate>",trim(continuousorders->orders[i1].stopdate,3),"</StopDate>"), col
      + 1, proj_stop,
     row + 1, ord_status = build("<OrderStatus>",trim(continuousorders->orders[i1].orderstatus),
      "</OrderStatus>"), col + 1,
     ord_status, row + 1
     FOR (i2 = 1 TO size(continuousorders->orders[i1].events,5))
       col 1, "<Events>", row + 1,
       eid = build("<EventId>",trim(continuousorders->orders[i1].events[i2].eventid,3),"</EventId>"),
       col + 1, eid,
       row + 1, epid = build("<ParentEventId>",trim(continuousorders->orders[i1].events[i2].
         parenteventid,3),"</ParentEventId>"), col + 1,
       epid, row + 1, result_v = build("<Result>",trim(continuousorders->orders[i1].events[i2].result,
         3),"</Result>"),
       col + 1, result_v, row + 1,
       result_u = build("<ResultUnits>",trim(continuousorders->orders[i1].events[i2].resultunits,3),
        "</ResultUnits>"), col + 1, result_u,
       row + 1, perf_dt = build("<PerformDate>",trim(continuousorders->orders[i1].events[i2].
         performdate,3),"</PerformDate>"), col + 1,
       perf_dt, row + 1, result_st = build("<ResultStatus>",trim(continuousorders->orders[i1].events[
         i2].resultstatus,3),"</ResultStatus>"),
       col + 1, result_st, row + 1,
       col 1, "</Events>", row + 1
     ENDFOR
     col 1, "</Orders>", row + 1
   ENDFOR
   col + 1, "</ContinuousOrders>", row + 1,
   col + 1, "<Medications>", row + 1
   FOR (i1 = 1 TO size(medications->ordercatalog,5))
     col 1, "<OrderCatalog>", row + 1,
     oid = build("<CatalogCd>",trim(medications->ordercatalog[i1].catalogcd,3),"</CatalogCd>"), col
      + 1, oid,
     row + 1, ccd = build("<CatalogDisplay>",trim(medications->ordercatalog[i1].catalogdisplay,3),
      "</CatalogDisplay>"), col + 1,
     ccd, row + 1, hna = build("<HNAOrderMnemonic>",trim(medications->ordercatalog[i1].
       hnaordermnemonic,3),"</HNAOrderMnemonic>"),
     col + 1, hna, row + 1
     FOR (i2 = 1 TO size(medications->ordercatalog[i1].parentevents,5))
       col 1, "<ParentEvents>", row + 1
       FOR (i3 = 1 TO size(medications->ordercatalog[i1].parentevents[i2].childevents,5))
         col 1, "<ChildEvents>", row + 1,
         v0 = build("<EventDisplay>",trim(medications->ordercatalog[i1].parentevents[i2].childevents[
           i3].eventdisplay,3),"</EventDisplay>"), col + 1, v0,
         row + 1, v1 = build("<EventId>",trim(medications->ordercatalog[i1].parentevents[i2].
           childevents[i3].eventid,3),"</EventId>"), col + 1,
         v1, row + 1, v1_1 = build("<ParentEventId>",trim(medications->ordercatalog[i1].parentevents[
           i2].childevents[i3].parenteventid,3),"</ParentEventId>"),
         col + 1, v1_1, row + 1,
         v2 = build("<AdminDate>",trim(medications->ordercatalog[i1].parentevents[i2].childevents[i3]
           .admindate,3),"</AdminDate>"), col + 1, v2,
         row + 1, v3 = build("<InfuseVolume>",trim(medications->ordercatalog[i1].parentevents[i2].
           childevents[i3].infusevolume,3),"</InfuseVolume>"), col + 1,
         v3, row + 1, v4 = build("<InfuseVolumeUnit>",trim(medications->ordercatalog[i1].
           parentevents[i2].childevents[i3].infusevolumeunit,3),"</InfuseVolumeUnit>"),
         col + 1, v4, row + 1,
         v5 = build("<AdminDosage>",trim(medications->ordercatalog[i1].parentevents[i2].childevents[
           i3].admindosage,3),"</AdminDosage>"), col + 1, v5,
         row + 1, v6 = build("<DosageUnit>",trim(medications->ordercatalog[i1].parentevents[i2].
           childevents[i3].dosageunit,3),"</DosageUnit>"), col + 1,
         v6, row + 1, v8 = build("<DiluentDisplay>",trim(medications->ordercatalog[i1].parentevents[
           i2].childevents[i3].diluentdisplay,3),"</DiluentDisplay>"),
         col + 1, v8, row + 1,
         v9 = build("<IOStartDate>",trim(medications->ordercatalog[i1].parentevents[i2].childevents[
           i3].iostartdate,3),"</IOStartDate>"), col + 1, v9,
         row + 1, v10 = build("<IOEndDate>",trim(medications->ordercatalog[i1].parentevents[i2].
           childevents[i3].ioenddate,3),"</IOEndDate>"), col + 1,
         v10, row + 1, col 1,
         "</ChildEvents>", row + 1
       ENDFOR
       col 1, "</ParentEvents>", row + 1
     ENDFOR
     col 1, "</OrderCatalog>", row + 1
   ENDFOR
   col + 1, "</Medications>", row + 1,
   col + 1, "<MiscIntake>", row + 1
   FOR (i1 = 1 TO size(miscintake->iotype,5))
     col 1, "<IOType>", row + 1,
     io_name = build("<IOTypeDisplay>",trim(miscintake->iotype[i1].iotypedisplay,3),
      "</IOTypeDisplay>"), col + 1, io_name,
     row + 1, io_seq = build("<IOSeq>",trim(miscintake->iotype[i1].ioseq,3),"</IOSeq>"), col + 1,
     io_seq, row + 1
     FOR (i2 = 1 TO size(miscintake->iotype[i1].section,5))
       col 1, "<Section>", row + 1,
       sec_name = build("<SectionName>",trim(miscintake->iotype[i1].section[i2].sectionname,3),
        "</SectionName>"), col + 1, sec_name,
       row + 1, sec_seq = build("<SectionSeq>",trim(miscintake->iotype[i1].section[i2].sectionseq,3),
        "</SectionSeq>"), col + 1,
       sec_seq, row + 1
       FOR (i3 = 1 TO size(miscintake->iotype[i1].section[i2].dynamiclabel,5))
         col 1, "<DynamicLabel>", row + 1,
         dyn_id = build("<DynLabelID>",trim(miscintake->iotype[i1].section[i2].dynamiclabel[i3].
           dynlabelid,3),"</DynLabelID>"), col + 1, dyn_id,
         row + 1, dyn_name = build("<DynLabelName>",trim(miscintake->iotype[i1].section[i2].
           dynamiclabel[i3].dynlabelname,3),"</DynLabelName>"), col + 1,
         dyn_name, row + 1
         FOR (i4 = 1 TO size(miscintake->iotype[i1].section[i2].dynamiclabel[i3].events,5))
           col 1, "<Events>", row + 1,
           event_name = build("<EventName>",trim(miscintake->iotype[i1].section[i2].dynamiclabel[i3].
             events[i4].eventname,3),"</EventName>"), col + 1, event_name,
           row + 1, event_code = build("<EventCode>",trim(miscintake->iotype[i1].section[i2].
             dynamiclabel[i3].events[i4].eventcode,3),"</EventCode>"), col + 1,
           event_code, row + 1
           FOR (i5 = 1 TO size(miscintake->iotype[i1].section[i2].dynamiclabel[i3].events[i4].results,
            5))
             col 1, "<Results>", row + 1,
             event_id = build("<EventId>",trim(miscintake->iotype[i1].section[i2].dynamiclabel[i3].
               events[i4].results[i5].eventid,3),"</EventId>"), col + 1, event_id,
             row + 1, epid = build("<ParentEventId>",trim(miscintake->iotype[i1].section[i2].
               dynamiclabel[i3].events[i4].results[i5].parenteventid,3),"</ParentEventId>"), col + 1,
             epid, row + 1, result_value = build("<ResultVal>",trim(miscintake->iotype[i1].section[i2
               ].dynamiclabel[i3].events[i4].results[i5].resultval,3),"</ResultVal>"),
             col + 1, result_value, row + 1,
             result_units = build("<ResultUnits>",trim(miscintake->iotype[i1].section[i2].
               dynamiclabel[i3].events[i4].results[i5].resultunits,3),"</ResultUnits>"), col + 1,
             result_units,
             row + 1, result_dt = build("<ResultDtTime>",trim(miscintake->iotype[i1].section[i2].
               dynamiclabel[i3].events[i4].results[i5].resultdttime,3),"</ResultDtTime>"), col + 1,
             result_dt, row + 1, result_st = build("<ResultStatus>",trim(miscintake->iotype[i1].
               section[i2].dynamiclabel[i3].events[i4].results[i5].resultstatus,3),"</ResultStatus>"),
             col + 1, result_st, row + 1,
             col 1, "</Results>", row + 1
           ENDFOR
           col 1, "</Events>", row + 1
         ENDFOR
         col 1, "</DynamicLabel>", row + 1
       ENDFOR
       col 1, "</Section>", row + 1
     ENDFOR
     col 1, "</IOType>", row + 1
   ENDFOR
   row + 1, col + 1, "</MiscIntake>",
   row + 1, col + 1, "<IntakeOutput>",
   row + 1
   FOR (i1 = 1 TO size(intakeoutput->iotype,5))
     col 1, "<IOType>", row + 1,
     io_name = build("<IOTypeDisplay>",trim(intakeoutput->iotype[i1].iotypedisplay,3),
      "</IOTypeDisplay>"), col + 1, io_name,
     row + 1, io_seq = build("<IOSeq>",trim(intakeoutput->iotype[i1].ioseq,3),"</IOSeq>"), col + 1,
     io_seq, row + 1
     FOR (i2 = 1 TO size(intakeoutput->iotype[i1].section,5))
       col 1, "<Section>", row + 1,
       sec_name = build("<SectionName>",trim(intakeoutput->iotype[i1].section[i2].sectionname,3),
        "</SectionName>"), col + 1, sec_name,
       row + 1, sec_seq = build("<SectionSeq>",trim(intakeoutput->iotype[i1].section[i2].sectionseq,3
         ),"</SectionSeq>"), col + 1,
       sec_seq, row + 1
       FOR (i3 = 1 TO size(intakeoutput->iotype[i1].section[i2].dynamiclabel,5))
         col 1, "<DynamicLabel>", row + 1,
         dyn_id = build("<DynLabelID>",trim(intakeoutput->iotype[i1].section[i2].dynamiclabel[i3].
           dynlabelid,3),"</DynLabelID>"), col + 1, dyn_id,
         row + 1, dyn_name = build("<DynLabelName>",trim(intakeoutput->iotype[i1].section[i2].
           dynamiclabel[i3].dynlabelname,3),"</DynLabelName>"), col + 1,
         dyn_name, row + 1
         FOR (i4 = 1 TO size(intakeoutput->iotype[i1].section[i2].dynamiclabel[i3].events,5))
           col 1, "<Events>", row + 1,
           event_name = build("<EventName>",trim(intakeoutput->iotype[i1].section[i2].dynamiclabel[i3
             ].events[i4].eventname,3),"</EventName>"), col + 1, event_name,
           row + 1, event_code = build("<EventCode>",trim(intakeoutput->iotype[i1].section[i2].
             dynamiclabel[i3].events[i4].eventcode,3),"</EventCode>"), col + 1,
           event_code, row + 1
           FOR (i5 = 1 TO size(intakeoutput->iotype[i1].section[i2].dynamiclabel[i3].events[i4].
            results,5))
             col 1, "<Results>", row + 1,
             event_id = build("<EventId>",trim(intakeoutput->iotype[i1].section[i2].dynamiclabel[i3].
               events[i4].results[i5].eventid,3),"</EventId>"), col + 1, event_id,
             row + 1, epid = build("<ParentEventId>",trim(intakeoutput->iotype[i1].section[i2].
               dynamiclabel[i3].events[i4].results[i5].parenteventid,3),"</ParentEventId>"), col + 1,
             epid, row + 1, result_value = build("<ResultVal>",trim(intakeoutput->iotype[i1].section[
               i2].dynamiclabel[i3].events[i4].results[i5].resultval,3),"</ResultVal>"),
             col + 1, result_value, row + 1,
             result_units = build("<ResultUnits>",trim(intakeoutput->iotype[i1].section[i2].
               dynamiclabel[i3].events[i4].results[i5].resultunits,3),"</ResultUnits>"), col + 1,
             result_units,
             row + 1, result_dt = build("<ResultDtTime>",trim(intakeoutput->iotype[i1].section[i2].
               dynamiclabel[i3].events[i4].results[i5].resultdttime,3),"</ResultDtTime>"), col + 1,
             result_dt, row + 1, result_st = build("<ResultStatus>",trim(intakeoutput->iotype[i1].
               section[i2].dynamiclabel[i3].events[i4].results[i5].resultstatus,3),"</ResultStatus>"),
             col + 1, result_st, row + 1,
             io_flag = build("<IntakeOutputFl>",trim(intakeoutput->iotype[i1].section[i2].
               dynamiclabel[i3].events[i4].results[i5].intakeoutputfl,3),"</IntakeOutputFl>"), col +
             1, io_flag,
             row + 1, col 1, "</Results>",
             row + 1
           ENDFOR
           col 1, "</Events>", row + 1
         ENDFOR
         col 1, "</DynamicLabel>", row + 1
       ENDFOR
       col 1, "</Section>", row + 1
     ENDFOR
     col 1, "</IOType>", row + 1
   ENDFOR
   row + 1, col + 1, "</IntakeOutput>",
   row + 1
  FOOT REPORT
   col 0, "</ReplyMessage>"
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 30
 ;end select
END GO
