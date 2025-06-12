CREATE PROGRAM aps_add_hist_path_case:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 case_id = f8
   1 updt_cnt = i4
 )
 IF ((validate(accession_common_version,- (1))=- (1)))
  DECLARE accession_common_version = i2 WITH constant(0)
  DECLARE acc_success = i2 WITH constant(0)
  DECLARE acc_error = i2 WITH constant(1)
  DECLARE acc_future = i2 WITH constant(2)
  DECLARE acc_null_dt_tm = i2 WITH constant(3)
  DECLARE acc_template = i2 WITH constant(300)
  DECLARE acc_pool = i2 WITH constant(310)
  DECLARE acc_pool_sequence = i2 WITH constant(320)
  DECLARE acc_duplicate = i2 WITH constant(410)
  DECLARE acc_modify = i2 WITH constant(420)
  DECLARE acc_sequence_id = i2 WITH constant(430)
  DECLARE acc_insert = i2 WITH constant(440)
  DECLARE acc_pool_id = i2 WITH constant(450)
  DECLARE acc_aor_false = i2 WITH constant(500)
  DECLARE acc_aor_true = i2 WITH constant(501)
  DECLARE acc_person_false = i2 WITH constant(502)
  DECLARE acc_person_true = i2 WITH constant(503)
  DECLARE site_length = i2 WITH constant(5)
  DECLARE julian_sequence_length = i2 WITH constant(6)
  DECLARE prefix_sequence_length = i2 WITH constant(7)
  DECLARE accession_status = i4 WITH noconstant(acc_success)
  DECLARE accession_meaning = c200 WITH noconstant(fillstring(200," "))
  RECORD acc_settings(
    1 acc_settings_loaded = i2
    1 site_code_length = i4
    1 julian_sequence_length = i4
    1 alpha_sequence_length = i4
    1 year_display_length = i4
    1 default_site_cd = f8
    1 default_site_prefix = c5
    1 assignment_days = i4
    1 assignment_dt_tm = dq8
    1 check_disp_ind = i2
  )
  RECORD accession_fmt(
    1 time_ind = i2
    1 insert_aor_ind = i2
    1 cpri_lookup = i2
    1 act_lookup = i2
    1 qual[*]
      2 order_id = f8
      2 catalog_cd = f8
      2 facility_cd = f8
      2 site_prefix_cd = f8
      2 site_prefix_disp = c5
      2 accession_format_cd = f8
      2 accession_format_mean = c12
      2 accession_class_cd = f8
      2 specimen_type_cd = f8
      2 accession_dt_tm = dq8
      2 accession_day = i4
      2 accession_year = i4
      2 alpha_prefix = c2
      2 accession_seq_nbr = i4
      2 accession_pool_id = f8
      2 assignment_meaning = vc
      2 assignment_status = i2
      2 accession_id = f8
      2 accession = c20
      2 accession_formatted = c25
      2 activity_type_cd = f8
      2 activity_type_mean = c12
      2 order_tag = i2
      2 accession_info_pos = i2
      2 accession_flag = i2
      2 collection_priority_cd = f8
      2 group_with_other_flag = i2
      2 accession_parent = i2
      2 body_site_cd = f8
      2 body_site_ind = i2
      2 specimen_type_ind = i2
      2 service_area_cd = f8
      2 linked_qual[*]
        3 linked_pos = i2
  )
  RECORD accession_grp(
    1 cpri_lookup = i2
    1 act_lookup = i2
    1 qual[*]
      2 catalog_cd = f8
      2 specimen_type_cd = f8
      2 site_prefix_cd = f8
      2 accession_format_cd = f8
      2 accession_class_cd = f8
      2 accession_dt_tm = dq8
      2 accession_pool_id = f8
      2 accession_id = f8
      2 accession = c20
      2 activity_type_cd = f8
      2 accession_flag = i2
      2 collection_priority_cd = f8
      2 group_with_other_flag = i2
      2 body_site_cd = f8
      2 service_area_cd = f8
  )
  DECLARE accession_nbr = c20 WITH noconstant(fillstring(20," "))
  DECLARE accession_nbr_chk = c50 WITH noconstant(fillstring(50," "))
  RECORD accession_str(
    1 site_prefix_disp = c5
    1 accession_year = i4
    1 accession_day = i4
    1 alpha_prefix = c2
    1 accession_seq_nbr = i4
    1 accession_pool_id = f8
  )
  DECLARE acc_site_prefix_cd = f8 WITH noconstant(0.0)
  DECLARE acc_site_prefix = c5 WITH noconstant(fillstring(value(site_length)," "))
  DECLARE accession_id = f8 WITH noconstant(0.0)
  DECLARE accession_dup_id = f8 WITH noconstant(0.0)
  DECLARE accession_updt_cnt = i4 WITH noconstant(0)
  DECLARE accession_assignment_ind = i2 WITH noconstant(0)
  RECORD accession_chk(
    1 check_disp_ind = i2
    1 site_prefix_cd = f8
    1 accession_year = i4
    1 accession_day = i4
    1 accession_pool_id = f8
    1 accession_seq_nbr = i4
    1 accession_class_cd = f8
    1 accession_format_cd = f8
    1 alpha_prefix = c2
    1 accession_id = f8
    1 accession = c20
    1 accession_nbr_check = c50
    1 accession_updt_cnt = i4
    1 action_ind = i2
    1 preactive_ind = i2
    1 assignment_ind = i2
  )
 ENDIF
#script
 SET reply->status_data.status = "F"
 SET failed = "F"
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=2062
   AND cv.display=substring(1,5,request->accession_nbr)
  DETAIL
   request->site_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=2057
   AND cv.display=substring(6,2,request->accession_nbr)
  DETAIL
   request->accession_format_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  aar.accession_assignment_pool_id
  FROM accession_assign_xref aar
  WHERE (request->accession_format_cd=aar.accession_format_cd)
   AND (request->site_cd=aar.site_prefix_cd)
  DETAIL
   accession_str->accession_pool_id = aar.accession_assignment_pool_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ACCESSION_ASSIGN_XREF"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET accession_str->site_prefix_disp = substring(1,5,request->accession_nbr)
 SET accession_str->alpha_prefix = substring(6,2,request->accession_nbr)
 SET accession_str->accession_year = cnvtint(substring(8,4,request->accession_nbr))
 SET accession_str->accession_seq_nbr = cnvtint(substring(12,7,request->accession_nbr))
 SET accession_str->accession_day = 0
 EXECUTE accession_string
 SET accession_chk->site_prefix_cd = request->site_cd
 SET accession_chk->accession_year = accession_str->accession_year
 SET accession_chk->accession_day = accession_str->accession_day
 SET accession_chk->accession_pool_id = accession_str->accession_pool_id
 SET accession_chk->accession_seq_nbr = accession_str->accession_seq_nbr
 SET accession_chk->accession_class_cd = 0.0
 SET accession_chk->accession_format_cd = request->accession_format_cd
 SET accession_chk->alpha_prefix = accession_str->alpha_prefix
 SET accession_chk->accession = accession_nbr
 SET accession_chk->accession_nbr_check = accession_nbr_chk
 SET accession_chk->action_ind = 0
 SET accession_chk->preactive_ind = 0
 SET accession_chk->check_disp_ind = 2
 EXECUTE accession_check
 IF (accession_status != acc_success)
  SET reply->status_data.subeventstatus[1].operationname = "ACC_ASSIGNMENT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ACCESSION"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = accession_meaning
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET reply->case_id = accession_id
 SET stat = alterlist(accession_fmt->qual,1)
 SET accession_fmt->qual[1].accession_pool_id = accession_chk->accession_pool_id
 SET accession_fmt->qual[1].accession_year = accession_chk->accession_year
 SET accession_fmt->qual[1].accession_seq_nbr = accession_chk->accession_seq_nbr
 SET accession_fmt->qual[1].accession = accession_chk->accession
 DECLARE new_comments_long_text_id = f8 WITH protect, noconstant(0.0)
 SET s_active_cd = 0.00
 IF (textlen(trim(request->case_comment)) > 0)
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE"
    AND cv.active_ind=1
   HEAD REPORT
    s_active_cd = 0.0
   DETAIL
    s_active_cd = cv.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   seq_nbr = seq(long_data_seq,nextval)
   FROM dual
   DETAIL
    new_comments_long_text_id = seq_nbr
   WITH format, counter
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "DUAL"
   GO TO exit_script
  ENDIF
  INSERT  FROM long_text lt
   SET lt.long_text_id = new_comments_long_text_id, lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(
     sysdate),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
    updt_applctx,
    lt.active_ind = 1, lt.active_status_cd = s_active_cd, lt.active_status_dt_tm = cnvtdatetime(
     sysdate),
    lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "PATHOLOGY_CASE", lt
    .parent_entity_id = reply->case_id,
    lt.long_text = request->case_comment
   WITH nocounter
  ;end insert
 ENDIF
 INSERT  FROM pathology_case pc
  SET pc.case_id = reply->case_id, pc.person_id = request->person_id, pc.accessioned_dt_tm =
   cnvtdatetime(sysdate),
   pc.case_year = cnvtint(substring(8,4,request->accession_nbr)), pc.case_number = cnvtint(substring(
     12,7,request->accession_nbr)), pc.case_type_cd = request->case_type_cd,
   pc.requesting_physician_id = request->requesting_physician_id, pc.encntr_id = request->encntr_id,
   pc.accession_prsnl_id = reqinfo->updt_id,
   pc.accession_nbr = request->accession_nbr, pc.prefix_id = request->prefix_cd, pc.group_id =
   accession_str->accession_pool_id,
   pc.case_collect_dt_tm =
   IF ((request->collected_dt_tm > 0)) cnvtdatetime(request->collected_dt_tm)
   ELSE null
   ENDIF
   , pc.origin_flag = 1, pc.reserved_ind = 0,
   pc.updt_dt_tm = cnvtdatetime(sysdate), pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->
   updt_task,
   pc.updt_applctx = reqinfo->updt_applctx, pc.comments_long_text_id = new_comments_long_text_id, pc
   .updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobject = "PATHOLOGY_CASE"
  GO TO exit_script
 ENDIF
 IF ((request->flag_type_cd > 0.0))
  INSERT  FROM ap_qa_info aq
   SET aq.qa_flag_id = seq(pathnet_seq,nextval), aq.case_id = reply->case_id, aq.flag_type_cd =
    request->flag_type_cd,
    aq.activated_id = reqinfo->updt_id, aq.activated_dt_tm = cnvtdatetime(sysdate), aq.person_id =
    request->person_id,
    aq.active_ind = 1, aq.updt_dt_tm = cnvtdatetime(sysdate), aq.updt_id = reqinfo->updt_id,
    aq.updt_task = reqinfo->updt_task, aq.updt_applctx = reqinfo->updt_applctx, aq.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobject = "AP_QA_INFO"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  SET reply->case_id = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
