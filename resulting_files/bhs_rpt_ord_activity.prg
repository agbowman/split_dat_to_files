CREATE PROGRAM bhs_rpt_ord_activity
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin date/time" = "SYSDATE",
  "End date/time" = "SYSDATE",
  "Order provider filter" = "",
  "Order provider" = "",
  "Organization filter" = "",
  "Organization" = "",
  "Report type" = ""
  WITH outdev, begin_date, end_date,
  ord_prov_filter, ord_prov_id, org_filter,
  org_id, report_type
 SELECT DISTINCT INTO  $OUTDEV
  organization = substring(1,50,org.org_name), ord_provider = substring(1,30,prsnl
   .name_full_formatted), entering_user = substring(1,30,prsnl2.name_full_formatted),
  entering_user_position = uar_get_code_display(prsnl2.position_cd), order_date = format(o
   .orig_order_dt_tm,"MM/DD/YYYY HH:MM;;d"), order_name = substring(1,50,o.ordered_as_mnemonic),
  primary_mnemonic = oc.primary_mnemonic, order_type = o.orig_ord_as_flag, multum_csa_schedule = mmdc
  .csa_schedule,
  routing_type = substring(1,30,od.oe_field_display_value), order_detail = o.clinical_display_line,
  current_status = uar_get_code_display(o.order_status_cd),
  organization_id = org.organization_id, prsnl_id = prsnl.person_id, order_id = o.order_id,
  ord_provider_id = prsnl.person_id, entry_provider_id = prsnl2.person_id, patient_id = p.person_id
  FROM orders o,
   order_action oa,
   order_detail od,
   order_catalog oc,
   encounter e,
   person p,
   prsnl prsnl,
   prsnl prsnl2,
   organization org,
   mltm_ndc_main_drug_code mmdc,
   dummyt d1
  PLAN (o
   WHERE o.orig_order_dt_tm > cnvtdatetime( $BEGIN_DATE)
    AND o.orig_order_dt_tm < cnvtdatetime( $END_DATE)
    AND o.active_ind=1
    AND o.catalog_type_cd=2516
    AND o.orig_ord_as_flag=cnvtint( $REPORT_TYPE))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.order_status_cd IN (2550)
    AND oa.order_provider_id IN (cnvtint( $ORD_PROV_ID)))
   JOIN (od
   WHERE o.order_id=od.order_id
    AND od.oe_field_meaning IN ("REQROUTINGTYPE"))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (org
   WHERE e.organization_id=org.organization_id
    AND org.organization_id IN (cnvtint( $ORG_ID)))
   JOIN (prsnl
   WHERE prsnl.person_id=oa.order_provider_id)
   JOIN (prsnl2
   WHERE prsnl2.person_id=o.active_status_prsnl_id)
   JOIN (oc
   WHERE o.catalog_cd=oc.catalog_cd)
   JOIN (d1)
   JOIN (mmdc
   WHERE oc.cki=concat("MUL.ORD!",trim(cnvtstring(mmdc.drug_identifier))))
  ORDER BY organization, order_date
  WITH outerjoin = d1, nocounter, format,
   separator = " "
 ;end select
END GO
