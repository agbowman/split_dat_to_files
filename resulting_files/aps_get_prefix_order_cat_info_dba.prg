CREATE PROGRAM aps_get_prefix_order_cat_info:dba
 RECORD reply(
   1 prefix_qual[1]
     2 prefix_cd = f8
     2 prefix_desc = c50
     2 prefix_name = c4
     2 default_proc_catalog_cd = f8
     2 site_cd = f8
     2 site_disp = vc
     2 active_ind = i2
     2 updt_cnt = i4
   1 report_proc_qual[*]
     2 catalog_cd = f8
     2 description = vc
   1 process_proc_qual[*]
     2 catalog_cd = f8
     2 description = vc
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
 SET pre_cnt = 0
 SET report_proc_cnt = 0
 SET process_proc_cnt = 0
 SET primary_mnemonic_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.cdf_meaning="PRIMARY"
  HEAD REPORT
   primary_mnemonic_cd = 0.0
  DETAIL
   primary_mnemonic_cd = cv.code_value
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->report_proc_qual,1)
 SET stat = alterlist(reply->process_proc_qual,1)
 SELECT INTO "nl:"
  ap.prefix_id
  FROM ap_prefix ap
  WHERE ap.prefix_id != 0.0
  HEAD REPORT
   pre_cnt = 0
  HEAD ap.prefix_id
   proc_cnt = 0, report_cnt = 0, pre_cnt = (pre_cnt+ 1)
   IF (pre_cnt > size(reply->prefix_qual,5))
    stat = alter(reply->prefix_qual,pre_cnt)
   ENDIF
   reply->prefix_qual[pre_cnt].prefix_cd = ap.prefix_id, reply->prefix_qual[pre_cnt].prefix_desc = ap
   .prefix_desc, reply->prefix_qual[pre_cnt].prefix_name = ap.prefix_name,
   reply->prefix_qual[pre_cnt].default_proc_catalog_cd = ap.default_proc_catalog_cd, reply->
   prefix_qual[pre_cnt].site_cd = ap.site_cd, reply->prefix_qual[pre_cnt].active_ind = ap.active_ind,
   reply->prefix_qual[pre_cnt].updt_cnt = ap.updt_cnt
  WITH nocounter
 ;end select
 SET stat = alter(reply->prefix_qual,pre_cnt)
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PREFIX"
  SET failed = "T"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  ocs.catalog_cd
  FROM code_value c,
   order_catalog_synonym ocs,
   order_catalog oc
  PLAN (c
   WHERE c.code_set=5801
    AND ((c.cdf_meaning="APREPORT") OR (c.cdf_meaning="APPROCESS"))
    AND c.active_ind=1)
   JOIN (ocs
   WHERE c.code_value=ocs.activity_subtype_cd
    AND ocs.mnemonic_type_cd=primary_mnemonic_cd
    AND 1=ocs.active_ind)
   JOIN (oc
   WHERE ocs.catalog_cd=oc.catalog_cd)
  HEAD REPORT
   report_proc_cnt = 0, process_proc_cnt = 0
  DETAIL
   IF (c.cdf_meaning="APREPORT")
    report_proc_cnt = (report_proc_cnt+ 1), stat = alterlist(reply->report_proc_qual,report_proc_cnt),
    reply->report_proc_qual[report_proc_cnt].catalog_cd = ocs.catalog_cd,
    reply->report_proc_qual[report_proc_cnt].description = oc.description
   ELSE
    process_proc_cnt = (process_proc_cnt+ 1), stat = alterlist(reply->process_proc_qual,
     process_proc_cnt), reply->process_proc_qual[process_proc_cnt].catalog_cd = ocs.catalog_cd,
    reply->process_proc_qual[process_proc_cnt].description = oc.description
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->report_proc_qual,report_proc_cnt)
 SET stat = alterlist(reply->process_proc_qual,process_proc_cnt)
END GO
