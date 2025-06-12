CREATE PROGRAM aps_get_prefix_rpt_assoc_ref:dba
 RECORD reply(
   1 prefix_qual[5]
     2 prefix_cd = f8
     2 prefix_desc = c50
     2 prefix_name = c2
     2 default_proc_catalog_cd = f8
     2 site_cd = f8
     2 site_disp = vc
     2 active_ind = i2
     2 updt_cnt = i4
   1 report_proc_qual[5]
     2 catalog_cd = f8
     2 description = vc
     2 proc_qual[*]
       3 task_assay_cd = f8
       3 task_assay_disp = c40
       3 sequence = i4
       3 default_result_type_cd = f8
       3 default_result_type_disp = c40
       3 default_result_type_desc = vc
       3 default_result_type_mean = c12
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
 SET proc_cnt = 0
 SELECT INTO "nl:"
  ap.prefix_id
  FROM ap_prefix ap
  PLAN (ap
   WHERE ap.prefix_id != 0
    AND ap.active_ind=1)
  HEAD REPORT
   pre_cnt = 0
  HEAD ap.prefix_id
   proc_cnt = 0, report_cnt = 0, pre_cnt = (pre_cnt+ 1)
   IF (mod(pre_cnt,5)=1
    AND pre_cnt != 1)
    stat = alter(reply->prefix_qual,(pre_cnt+ 4))
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
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  oc.catalog_cd, ptr.task_assay_cd
  FROM code_value c,
   order_catalog oc,
   profile_task_r ptr,
   discrete_task_assay dta
  PLAN (c
   WHERE c.code_set=5801
    AND c.cdf_meaning="APREPORT"
    AND c.active_ind=1)
   JOIN (oc
   WHERE c.code_value=oc.activity_subtype_cd
    AND 1=oc.active_ind)
   JOIN (ptr
   WHERE oc.catalog_cd=ptr.catalog_cd
    AND ptr.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm)
   JOIN (dta
   WHERE ptr.task_assay_cd=dta.task_assay_cd)
  ORDER BY oc.catalog_cd, ptr.sequence
  HEAD REPORT
   report_proc_cnt = 0
  HEAD oc.catalog_cd
   report_proc_cnt = (report_proc_cnt+ 1), proc_cnt = 0
   IF (mod(report_proc_cnt,5)=1
    AND report_proc_cnt != 1)
    stat = alter(reply->report_proc_qual,(report_proc_cnt+ 4))
   ENDIF
   reply->report_proc_qual[report_proc_cnt].catalog_cd = oc.catalog_cd, reply->report_proc_qual[
   report_proc_cnt].description = oc.description
  HEAD ptr.task_assay_cd
   IF (oc.catalog_cd=ptr.catalog_cd
    AND ptr.task_assay_cd > 0)
    proc_cnt = (proc_cnt+ 1), stat = alterlist(reply->report_proc_qual[report_proc_cnt].proc_qual,
     proc_cnt), reply->report_proc_qual[report_proc_cnt].proc_qual[proc_cnt].task_assay_cd = ptr
    .task_assay_cd,
    reply->report_proc_qual[report_proc_cnt].proc_qual[proc_cnt].sequence = ptr.sequence, reply->
    report_proc_qual[report_proc_cnt].proc_qual[proc_cnt].default_result_type_cd = dta
    .default_result_type_cd
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alter(reply->report_proc_qual,report_proc_cnt)
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROFILE_TASK_R"
  SET failed = "T"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
