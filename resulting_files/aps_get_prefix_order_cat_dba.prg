CREATE PROGRAM aps_get_prefix_order_cat:dba
 RECORD reply(
   1 report_qual[*]
     2 catalog_cd = f8
     2 primary_ind = i2
     2 mult_allowed_ind = i2
     2 system_order_ind = i2
     2 reporting_sequence = i4
     2 updt_cnt = i4
     2 mnemonic = vc
   1 proc_qual[*]
     2 catalog_cd = f8
     2 per_spec_ind = i2
     2 updt_cnt = i4
     2 mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET report_cnt = 0
 SET proc_cnt = 0
 SET stat = alterlist(reply->report_qual,1)
 SET stat = alterlist(reply->proc_qual,1)
 SELECT INTO "nl:"
  prr.catalog_cd
  FROM prefix_report_r prr,
   order_catalog_synonym ocs,
   (dummyt d  WITH seq = 1),
   ap_prefix_auto_task apat
  PLAN (prr
   WHERE (request->prefix_cd=prr.prefix_id))
   JOIN (ocs
   WHERE prr.catalog_cd=ocs.catalog_cd)
   JOIN (d
   WHERE 1=d.seq)
   JOIN (apat
   WHERE (request->prefix_cd=apat.prefix_id)
    AND prr.catalog_cd=apat.catalog_cd)
  HEAD REPORT
   report_cnt = 0
  DETAIL
   report_cnt = (report_cnt+ 1), stat = alterlist(reply->report_qual,report_cnt), reply->report_qual[
   report_cnt].catalog_cd = prr.catalog_cd,
   reply->report_qual[report_cnt].primary_ind = prr.primary_ind, reply->report_qual[report_cnt].
   mult_allowed_ind = prr.mult_allowed_ind, reply->report_qual[report_cnt].reporting_sequence = prr
   .reporting_sequence,
   reply->report_qual[report_cnt].system_order_ind =
   IF (apat.catalog_cd > 0.0) 1
   ELSE 0
   ENDIF
   , reply->report_qual[report_cnt].updt_cnt = prr.updt_cnt, reply->report_qual[report_cnt].mnemonic
    = ocs.mnemonic
  WITH outerjoin = d, dontcare = apat, nocounter
 ;end select
 SET stat = alterlist(reply->report_qual,report_cnt)
 SELECT INTO "nl:"
  apat.catalog_cd
  FROM ap_prefix_auto_task apat,
   order_catalog_synonym ocs,
   code_value c
  PLAN (apat
   WHERE (request->prefix_cd=apat.prefix_id))
   JOIN (ocs
   WHERE apat.catalog_cd=ocs.catalog_cd
    AND 1=ocs.active_ind)
   JOIN (c
   WHERE ocs.activity_subtype_cd=c.code_value
    AND c.cdf_meaning="APPROCESS"
    AND c.active_ind=1)
  HEAD REPORT
   proc_cnt = 0
  DETAIL
   proc_cnt = (proc_cnt+ 1), stat = alterlist(reply->proc_qual,proc_cnt), reply->proc_qual[proc_cnt].
   catalog_cd = ocs.catalog_cd,
   reply->proc_qual[proc_cnt].mnemonic = ocs.mnemonic, reply->proc_qual[proc_cnt].per_spec_ind = apat
   .specimen_ind
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->proc_qual,proc_cnt)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
