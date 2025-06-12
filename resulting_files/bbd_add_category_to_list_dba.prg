CREATE PROGRAM bbd_add_category_to_list:dba
 RECORD reply(
   1 report_category_cd = f8
   1 module_categ_id = f8
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
 SET code_value = 0.0
 SET next_code = 0.0
 SET failed = "F"
 EXECUTE cpm_next_code
 SET code_value = next_code
 IF (code_value=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_report_to_list"
  SET reply->status_data.subeventstatus[1].operationname = "retrieve"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "sequence"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "cpm_next_code"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 INSERT  FROM code_value c
  SET c.code_set = 16069, c.code_value = code_value, c.display = request->category_name,
   c.display_key = trim(cnvtupper(cnvtalphanum(request->category_name))), c.active_ind = 1, c
   .active_type_cd = reqdata->active_status_cd,
   c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_task = reqinfo->updt_task, c.updt_cnt = 0,
   c.updt_applctx = reqinfo->updt_applctx, c.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100 23:59:59:59"), c.data_status_cd = reqdata->data_status_cd,
   c.data_status_prsnl_id = reqinfo->updt_id, c.active_status_prsnl_id = reqinfo->updt_id
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
 ELSE
  SET reply->report_category_cd = code_value
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
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_report_to_list"
  SET reply->status_data.subeventstatus[1].operationname = "retrieve"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "sequence"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbt_get_pathent_seq"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 INSERT  FROM bb_report_mod_cat_r m
  SET m.module_categ_id = new_pathnet_seq, m.report_module_cd = request->report_module_cd, m
   .report_category_cd = code_value,
   m.active_ind = 1, m.active_status_cd = reqdata->active_status_cd, m.active_status_dt_tm =
   cnvtdatetime(curdate,curtime3),
   m.active_status_prsnl_id = reqinfo->updt_id, m.updt_dt_tm = cnvtdatetime(curdate,curtime3), m
   .updt_cnt = 0,
   m.updt_task = reqinfo->updt_task, m.updt_applctx = reqinfo->updt_applctx, m.create_dt_tm =
   cnvtdatetime(curdate,curtime3)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
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
  SET reply->module_categ_id = new_pathnet_seq
  SET reply->report_category_cd = code_value
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
