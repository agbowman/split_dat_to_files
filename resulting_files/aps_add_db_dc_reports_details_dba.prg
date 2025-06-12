CREATE PROGRAM aps_add_db_dc_reports_details:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 exception_data[1]
     2 study_id = f8
     2 updt_cnt = i4
 )
#script
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET nbr_of_reports = cnvtint(size(request->report_qual,5))
 SELECT INTO "nl:"
  ads.description
  FROM ap_dc_study ads
  WHERE cnvtupper(ads.description)=cnvtupper(request->description)
  DETAIL
   reply->exception_data[1].study_id = ads.study_id, reply->exception_data[1].updt_cnt = ads.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual > 0)
  GO TO dup_desc
 ENDIF
 SELECT INTO "nl:"
  seq_nbr = seq(reference_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   request->study_id = cnvtreal(seq_nbr)
  WITH format, counter
 ;end select
 IF (curqual=0)
  GO TO seq_failed
 ENDIF
 INSERT  FROM ap_dc_study ads
  SET ads.study_id = request->study_id, ads.description = request->description, ads.across_case_ind
    = request->across_case_ind,
   ads.active_ind = request->active_ind, ads.slide_counts_prompt_ind = request->
   slide_counts_prompt_ind, ads.include_cytotechs_ind = request->include_cytotechs_ind,
   ads.default_to_group_ind = request->default_to_group_ind, ads.updt_dt_tm = cnvtdatetime(curdate,
    curtime), ads.updt_id = reqinfo->updt_id,
   ads.updt_task = reqinfo->updt_task, ads.updt_applctx = reqinfo->updt_applctx, ads.updt_cnt = 0,
   ads.service_resource_cd = request->service_resource_cd
  PLAN (ads)
  WITH nocounter
 ;end insert
 IF (curqual != 1)
  GO TO c_failed
 ENDIF
 INSERT  FROM ap_dc_study_rpt_proc adsrp,
   (dummyt d1  WITH seq = value(nbr_of_reports))
  SET adsrp.study_id = request->study_id, adsrp.task_assay_cd = request->report_qual[d1.seq].
   task_assay_cd, adsrp.updt_dt_tm = cnvtdatetime(curdate,curtime),
   adsrp.updt_id = reqinfo->updt_id, adsrp.updt_task = reqinfo->updt_task, adsrp.updt_applctx =
   reqinfo->updt_applctx,
   adsrp.updt_cnt = 0
  PLAN (d1)
   JOIN (adsrp)
  WITH nocounter
 ;end insert
 IF (curqual != nbr_of_reports
  AND nbr_of_reports > 0)
  GO TO child_failed
 ENDIF
 GO TO exit_script
#dup_desc
 SET reply->status_data.subeventstatus[1].operationname = "CHECK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "SELECT"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "APS_DC_STUDY"
 SET failed = "P"
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "NEXTVAL"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "SEQ"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "REFERENCE_SEQ"
 SET failed = "T"
 GO TO exit_script
#c_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_DC_STUDY"
 SET failed = "T"
 GO TO exit_script
#child_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "APS_DC_STUDY_RPT_PROC"
 SET failed = "T"
#exit_script
 IF (failed="P")
  SET reply->status_data.status = "P"
  SET reqinfo->commit_ind = 0
 ELSEIF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
