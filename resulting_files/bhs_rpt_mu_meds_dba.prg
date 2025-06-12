CREATE PROGRAM bhs_rpt_mu_meds:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE str = vc WITH noconstant(" ")
 DECLARE notfnd = vc WITH constant("<not_found>")
 DECLARE num = i4 WITH noconstant(1)
 DECLARE data = vc
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 line = vc
     2 mrn = vc
     2 cismrn = vc
     2 fname = vc
     2 lname = vc
     2 pid = f8
     2 eid = f8
     2 reg = vc
     2 probflag = i2
     2 epresflag = i2
     2 medallergyflag = i2
     2 smokeflag = i2
     2 vitalflag = i2
     2 ageless13 = i2
     2 age = vc
 )
 FREE DEFINE rtl
 DEFINE rtl "ccluserdir:mu_amb.csv"
 SELECT INTO "nl:"
  FROM rtlt r
  WHERE r.line > " "
  HEAD REPORT
   x = 0
  DETAIL
   x = (x+ 1), stat = alterlist(temp->qual,x), temp->qual[x].line = trim(r.line,3)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "mu_meds.csv"
  organization = substring(1,50,org.org_name), ord_provider = substring(1,30,prsnl
   .name_full_formatted), entering_user = substring(1,30,prsnl2.name_full_formatted),
  entering_user_position = substring(1,20,uar_get_code_display(prsnl2.position_cd)), patient =
  substring(1,30,p.name_full_formatted), order_date = format(o.orig_order_dt_tm,"MM/DD/YYYY HH:MM;;d"
   ),
  order_name = substring(1,50,o.ordered_as_mnemonic), primary_mnemonic = substring(1,100,oc
   .primary_mnemonic), order_type = cnvtstring(o.orig_ord_as_flag),
  multum_csa_schedule = substring(1,20,mmdc.csa_schedule), order_detail = substring(1,100,o
   .clinical_display_line), current_status = substring(1,20,uar_get_code_display(o.order_status_cd)),
  order_id = cnvtstring(1,30,cnvtstring(o.order_id)), person_id = substring(1,20,cnvtstring(p
    .person_id))
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   orders o,
   order_action oa,
   order_catalog oc,
   encounter e,
   person p,
   prsnl prsnl,
   prsnl prsnl2,
   organization org,
   mltm_ndc_main_drug_code mmdc,
   dummyt d1
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=temp->qual[d.seq].eid)
    AND o.active_ind=1
    AND ((o.catalog_type_cd+ 0)=2516))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.order_status_cd IN (2550))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (org
   WHERE e.organization_id=org.organization_id)
   JOIN (prsnl
   WHERE prsnl.person_id=oa.order_provider_id)
   JOIN (prsnl2
   WHERE prsnl2.person_id=o.active_status_prsnl_id)
   JOIN (oc
   WHERE o.catalog_cd=oc.catalog_cd)
   JOIN (d1)
   JOIN (mmdc
   WHERE oc.cki=concat("MUL.ORD!",trim(cnvtstring(mmdc.drug_identifier))))
  WITH outerjoin = d1, nocounter, format,
   separator = ", "
 ;end select
END GO
