CREATE PROGRAM bbd_add_report_to_list:dba
 RECORD reply(
   1 report_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET failed = "F"
 SET module_categ_id = 0
 IF ((request->active_ind=1))
  SET active_status_cd = reqdata->active_status_cd
 ELSE
  SET active_status_cd = reqdata->inactive_status_cd
 ENDIF
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 SET report_id = new_pathnet_seq
 IF (report_id=0)
  SET failed = "T"
  SET reply->status = "F"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_report_to_list"
  SET reply->status_data.subeventstatus[1].operationname = "retrieve"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_pathnet_seq"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "retrieve from pathnet seq failed"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  b.module_categ_id
  FROM bb_report_mod_cat_r b
  WHERE (b.report_module_cd=request->module_cd)
   AND (b.report_category_cd=request->category_cd)
  DETAIL
   module_categ_id = b.module_categ_id
  WITH nocounter
 ;end select
 INSERT  FROM bb_report_management r
  SET r.report_id = report_id, r.report_name = request->report_name, r.description = request->
   description,
   r.task_nbr = request->task_nbr, r.request_nbr = request->request_nbr, r.product_ind = request->
   product_ind,
   r.patient_ind = request->patient_ind, r.donor_ind = request->donor_ind, r.include_donors_ind =
   request->include_donors_ind,
   r.date_range_ind = request->date_range_ind, r.donatn_level_range_ind = request->
   donation_level_range_ind, r.owner_area_ind = request->owner_area_ind,
   r.inventory_area_ind = request->inventory_area_ind, r.deferral_ind = request->deferral_ind, r
   .draw_station_ind = request->draw_station_ind,
   r.organization_ind = request->organization_ind, r.by_organization_ind = request->
   by_organization_ind, r.all_organization_ind = request->all_organization_ind,
   r.mobile_pref_month_ind = request->mobile_pref_month_ind, r.all_location_ind = request->
   all_location_ind, r.reinstate_ind = request->reinstate_ind,
   r.assays_ind = request->assays_ind, r.deferral_reasons_ind = request->deferral_reasons_ind, r
   .exception_ind = request->exception_ind,
   r.recruit_type_ind = request->recruit_type_ind, r.aborh_ind = request->aborh_ind, r.procedure_ind
    = request->procedure_ind,
   r.antigens_ind = request->antigens_ind, r.recruit_list_ind = request->recruit_list_ind, r.race_ind
    = request->race_ind,
   r.rare_type_ind = request->rare_type_ind, r.special_interest_ind = request->special_interest_ind,
   r.zip_code_ind = request->zip_code_ind,
   r.active_ind = request->active_ind, r.active_status_dt_tm = cnvtdatetime(curdate,curtime3), r
   .active_status_cd = active_status_cd,
   r.active_status_prsnl_id = reqinfo->updt_id, r.updt_id = reqinfo->updt_id, r.updt_cnt = 0,
   r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->updt_applctx, r.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   r.create_dt_tm = cnvtdatetime(curdate,curtime3)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status = "F"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_report_to_list"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "BB_REPORT_MANAGEMENT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "bb report management insert"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ELSE
  SET reply->report_id = report_id
 ENDIF
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 IF (new_pathnet_seq=0)
  SET failed = "T"
  SET reply->status = "F"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_report_to_list"
  SET reply->status_data.subeventstatus[1].operationname = "retrieve"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_pathnet_seq"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "retrieve from pathnet seq failed"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 INSERT  FROM bb_categ_report_r c
  SET c.categ_report_rel_id = new_pathnet_seq, c.module_categ_id = module_categ_id, c.report_id =
   report_id,
   c.active_ind = 1, c.active_status_cd = reqdata->active_status_cd, c.active_status_dt_tm =
   cnvtdatetime(curdate,curtime3),
   c.active_status_prsnl_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c
   .updt_task = reqinfo->updt_task,
   c.updt_cnt = 0, c.updt_applctx = reqinfo->updt_applctx, c.create_dt_tm = cnvtdatetime(curdate,
    curtime3)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_report_to_list"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "BB_CATEG_REPORT_R"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "bb categ report r insert"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
