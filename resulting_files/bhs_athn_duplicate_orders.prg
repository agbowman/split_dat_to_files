CREATE PROGRAM bhs_athn_duplicate_orders
 SET where_params = build("O.PERSON_ID =", $2," ")
 IF (((( $6=0)) OR (((( $6=4)) OR (( $6=5))) )) )
  SET where_params1 = build("o.freq_type_flag IN (0,4,5)")
 ELSE
  SET where_params1 = build("o.freq_type_flag IN (1,2,3) ")
 ENDIF
 DECLARE v_catalog_cd = f8
 DECLARE v_catalog_type_cd = f8
 DECLARE v_activity_type_cd = f8
 DECLARE header_grp = vc WITH noconstant(" ")
 DECLARE foot_grp = vc WITH noconstant(" ")
 SELECT INTO "nl:"
  oc.catalog_cd, oc.catalog_type_cd, oc.activity_type_cd
  FROM order_catalog oc
  PLAN (oc
   WHERE (oc.catalog_cd= $3))
  DETAIL
   v_catalog_cd = oc.catalog_cd, v_catalog_type_cd = oc.catalog_type_cd, v_activity_type_cd = oc
   .activity_type_cd
  WITH nocounter, time = 10
 ;end select
 IF (( $7=2))
  SET where_params2 = build("O.catalog_type_cd =",v_catalog_type_cd," ")
 ELSEIF (( $7=3))
  SET where_params2 = build("O.activity_type_cd =",v_activity_type_cd," ")
 ELSE
  SET where_params2 = build("O.catalog_cd =",v_catalog_cd," ")
 ENDIF
 SELECT DISTINCT INTO  $1
  o_order_id = trim(replace(cnvtstring(o.order_id),".0*","",0),3), o.person_id, o.encntr_id,
  catalog_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(o.catalog_cd),"&",
        "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), o.catalog_cd, o
  .synonym_id,
  o.oe_format_id, o.catalog_type_cd, o.activity_type_cd,
  hna_order_mnemonic = trim(replace(replace(replace(replace(replace(o.hna_order_mnemonic,"&","&amp;",
        0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), ordered_as_mnemonic = trim
  (replace(replace(replace(replace(replace(o.ordered_as_mnemonic,"&","&amp;",0),"<","&lt;",0),">",
      "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), ordereddatetime = format(o.orig_order_dt_tm,
   "MM/DD/YYYY HH:MM:SS;;D"),
  orderedtimezone = substring(21,3,datetimezoneformat(o.orig_order_dt_tm,o.orig_order_tz,
    "MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)), startdatetime = format(o.current_start_dt_tm,
   "MM/DD/YYYY HH:MM:SS;;D"), startdatetimezone = substring(21,3,datetimezoneformat(o
    .current_start_dt_tm,o.current_start_tz,"MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)),
  stopdatetime = format(o.projected_stop_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), stopdatetimezone =
  substring(21,3,datetimezoneformat(o.projected_stop_dt_tm,o.projected_stop_tz,
    "MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)), orderstatus_display = trim(replace(replace(replace(
      replace(replace(uar_get_code_display(o.order_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",
      0),"'","&apos;",0),'"',"&quot;",0),3),
  o.order_status_cd, clinicaldisplayline = trim(replace(replace(replace(replace(replace(o
        .clinical_display_line,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3), orderable_type_flag = trim(replace(replace(replace(replace(replace(substring(0,8,
         IF (o.orderable_type_flag=0) "NORMAL"
         ENDIF
         ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  dept_status_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(o
         .dept_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),
   3), o.dept_status_cd, template_order_flag = trim(replace(replace(replace(replace(replace(substring
        (0,25,
         IF (o.template_order_flag=0) "None"
         ELSEIF (o.template_order_flag=1) "Template"
         ELSEIF (o.template_order_flag=2) "Order Based Instance"
         ELSEIF (o.template_order_flag=3) "Task Based Instance"
         ELSEIF (o.template_order_flag=4) "Rx Based Instance"
         ELSEIF (o.template_order_flag=5) "Future Recurring Template"
         ELSEIF (o.template_order_flag=6) "Future Recurring Instance"
         ELSEIF (o.template_order_flag=7) "Protocol"
         ENDIF
         ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  o.template_order_id, o.dcp_clin_cat_cd, originalorderingprovidername = trim(replace(replace(replace
     (replace(replace(prl.name_full_formatted,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",
     0),'"',"&quot;",0),3)
  FROM orders o,
   order_action oa,
   prsnl prl
  PLAN (o
   WHERE parser(where_params2)
    AND parser(where_params)
    AND parser(where_params1)
    AND o.current_start_dt_tm BETWEEN cnvtdatetime( $4) AND cnvtdatetime( $5)
    AND o.order_status_cd IN (2548, 2549, 2551, 2550, 2552,
   2543))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=2534.00)
   JOIN (prl
   WHERE prl.person_id=oa.order_provider_id)
  ORDER BY o.order_id DESC
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  HEAD o.order_id
   IF (o.dcp_clin_cat_cd=10576)
    header_grp = build("<","StandardLaboratoryOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=10573)
    header_grp = build("<","StandardRadiologyOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=10581)
    header_grp = build("<","AdmitTransferDischarge",">")
   ELSEIF (o.dcp_clin_cat_cd=10571)
    header_grp = build("<","StandardDirectCare",">")
   ELSEIF (o.dcp_clin_cat_cd=10574)
    header_grp = build("<","StandardDietOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=10584)
    header_grp = build("<","StandardChargeOrder",">")
   ELSEIF (((o.dcp_clin_cat_cd=2064789) OR (o.dcp_clin_cat_cd=0)) )
    header_grp = build("<","NonCategorizedOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=10578)
    header_grp = build("<","NursingOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=10582)
    header_grp = build("<","RespiratoryOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=10583)
    header_grp = build("<","RehabServicesOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=10579)
    header_grp = build("<","SpecialServicesOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=10585)
    header_grp = build("<","VitalOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=559676402)
    header_grp = build("<","MedicalSuppliesOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=10568)
    header_grp = build("<","ActivityOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=10580)
    header_grp = build("<","CareSet",">")
   ELSEIF (o.dcp_clin_cat_cd=10570)
    header_grp = build("<","Condition",">")
   ENDIF
   col + 1, header_grp, row + 1,
   v1 = build("<OrderId>",o_order_id,"</OrderId>"), col + 1, v1,
   row + 1, v2 = build("<PersonId>",cnvtint(o.person_id),"</PersonId>"), col + 1,
   v2, row + 1, v3 = build("<EncounterId>",cnvtint(o.encntr_id),"</EncounterId>"),
   col + 1, v3, row + 1,
   v4 = build("<","Catalog",">"), col + 1, v4,
   row + 1, v5 = build("<Display>",catalog_disp,"</Display>"), col + 1,
   v5, row + 1, v6 = build("<Value>",cnvtint(o.catalog_cd),"</Value>"),
   col + 1, v6, row + 1,
   v7 = build("</","Catalog",">"), col + 1, v7,
   row + 1, v8 = build("<OrderCatalogSynonymId>",cnvtint(o.synonym_id),"</OrderCatalogSynonymId>"),
   col + 1,
   v8, row + 1, v9 = build("<OrderFormatId>",cnvtint(o.oe_format_id),"</OrderFormatId>"),
   col + 1, v9, row + 1,
   v10 = build("<HNAOrderMnemonic>",hna_order_mnemonic,"</HNAOrderMnemonic>"), col + 1, v10,
   row + 1, v11 = build("<OrderedAsMnemonic>",ordered_as_mnemonic,"</OrderedAsMnemonic>"), col + 1,
   v11, row + 1, v12 = build("<OrderedDateTime>",ordereddatetime,"</OrderedDateTime>"),
   col + 1, v12, row + 1,
   v13 = build("<OrderedTimeZone>",orderedtimezone,"</OrderedTimeZone>"), col + 1, v13,
   row + 1, v14 = build("<StartDateTime>",startdatetime,"</StartDateTime>"), col + 1,
   v14, row + 1, v15 = build("<StartDateTimeZone>",startdatetimezone,"</StartDateTimeZone>"),
   col + 1, v15, row + 1,
   v16 = build("<StopDateTime>",stopdatetime,"</StopDateTime>"), col + 1, v16,
   row + 1, v17 = build("<StopDateTimeZone>",stopdatetimezone,"</StopDateTimeZone>"), col + 1,
   v17, row + 1, v18 = build("<","OrderStatus",">"),
   col + 1, v18, row + 1,
   v28 = build("<Display>",orderstatus_display,"</Display>"), col + 1, v28,
   row + 1, v29 = build("<Meaning>",uar_get_code_meaning(o.order_status_cd),"</Meaning>"), col + 1,
   v29, row + 1, v30 = build("<Value>",cnvtint(o.order_status_cd),"</Value>"),
   col + 1, v30, row + 1,
   v31 = build("</","OrderStatus",">"), col + 1, v31,
   row + 1, v35 = build("<ClinicalDisplayLine>",clinicaldisplayline,"</ClinicalDisplayLine>"), col +
   1,
   v35, row + 1, v46 = build("<","ClinicalCategory",">"),
   col + 1, v46, row + 1,
   v49 = build("<Value>",cnvtint(o.dcp_clin_cat_cd),"</Value>"), col + 1, v49,
   row + 1, v50 = build("</","ClinicalCategory",">"), col + 1,
   v50, row + 1, v56 = build("<OrderableTypeFlag>",orderable_type_flag,"</OrderableTypeFlag>"),
   col + 1, v56, row + 1,
   v71 = build("<","DepartmentStatus",">"), col + 1, v71,
   row + 1, v72 = build("<Display>",dept_status_disp,"</Display>"), col + 1,
   v72, row + 1, v74 = build("<Value>",cnvtint(o.dept_status_cd),"</Value>"),
   col + 1, v74, row + 1,
   v75 = build("</","DepartmentStatus",">"), col + 1, v75,
   row + 1, v77 = build("<TemplateOrderFlag>",template_order_flag,"</TemplateOrderFlag>"), col + 1,
   v77, row + 1, v78 = build("<TemplateOrderId>",cnvtstring(o.template_order_id),"</TemplateOrderId>"
    ),
   col + 1, v78, row + 1,
   v79 = build("<","CatalogType",">"), col + 1, v79,
   row + 1, v80 = build("<Value>",cnvtint(o.catalog_type_cd),"</Value>"), col + 1,
   v80, row + 1, v81 = build("</","CatalogType",">"),
   col + 1, v81, row + 1,
   v82 = build("<","ActivityType",">"), col + 1, v82,
   row + 1, v83 = build("<Value>",cnvtint(o.activity_type_cd),"</Value>"), col + 1,
   v83, row + 1, v84 = build("</","ActivityType",">"),
   col + 1, v84, row + 1,
   v85 = build("<OriginalOrderingProviderName>",originalorderingprovidername,
    "</OriginalOrderingProviderName>"), col + 1, v85,
   row + 1, v86 = build("<FrequencyType>",cnvtint(o.freq_type_flag),"</FrequencyType>"), col + 1,
   v86, row + 1
  FOOT  o.order_id
   IF (o.dcp_clin_cat_cd=10576)
    foot_grp = build("</","StandardLaboratoryOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=10573)
    foot_grp = build("</","StandardRadiologyOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=10581)
    foot_grp = build("</","AdmitTransferDischarge",">")
   ELSEIF (o.dcp_clin_cat_cd=10571)
    foot_grp = build("</","StandardDirectCare",">")
   ELSEIF (o.dcp_clin_cat_cd=10574)
    foot_grp = build("</","StandardDietOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=10584)
    foot_grp = build("</","StandardChargeOrder",">")
   ELSEIF (((o.dcp_clin_cat_cd=2064789) OR (o.dcp_clin_cat_cd=0)) )
    foot_grp = build("</","NonCategorizedOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=10578)
    foot_grp = build("</","NursingOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=10582)
    foot_grp = build("</","RespiratoryOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=10583)
    foot_grp = build("</","RehabServicesOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=10579)
    foot_grp = build("</","SpecialServicesOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=10585)
    foot_grp = build("</","VitalOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=559676402)
    foot_grp = build("</","MedicalSuppliesOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=10568)
    foot_grp = build("</","ActivityOrder",">")
   ELSEIF (o.dcp_clin_cat_cd=10580)
    foot_grp = build("</","CareSet",">")
   ELSEIF (o.dcp_clin_cat_cd=10570)
    foot_grp = build("</","Condition",">")
   ENDIF
   col + 1, foot_grp, row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 30
 ;end select
END GO
