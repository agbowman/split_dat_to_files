CREATE PROGRAM aps_reserve_pathology_case:dba
 RECORD reply(
   1 qual[*]
     2 case_id = f8
     2 case_number = i4
     2 accession = c20
     2 comments_long_text_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET x = 0
 SET stat = 0
 SET stat = alterlist(accession_fmt->qual,1)
 FOR (x = 1 TO request->nbr_cases)
   SET accession_fmt->qual[1].order_id = 0.0
   SET accession_fmt->qual[1].catalog_cd = 0.0
   SET accession_fmt->qual[1].accession_class_cd = 0.0
   SET accession_fmt->qual[1].specimen_type_cd = 0.0
   SET accession_fmt->qual[1].site_prefix_cd = request->site_cd
   SET accession_fmt->qual[1].accession_format_cd = request->accession_format_cd
   SET accession_fmt->qual[1].accession_dt_tm = cnvtdatetime(curdate,curtime)
   EXECUTE accession_assign
   IF (accession_status != acc_success)
    SET reply->status_data.subeventstatus[1].operationname = "ACC_ASSIGNMENT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "ACCESSION"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = accession_meaning
    SET failed = "T"
    GO TO exit_script
   ENDIF
   CALL echo(build("X: ",x))
   SET stat = alterlist(reply->qual,x)
   SET reply->qual[x].case_id = accession_fmt->qual[1].accession_id
   SET reply->qual[x].case_number = accession_fmt->qual[1].accession_seq_nbr
   SET reply->qual[x].accession = accession_fmt->qual[1].accession
   SET reply->qual[x].comments_long_text_id = 0.0
 ENDFOR
 IF (textlen(request->comments) > 0)
  SET s_active_cd = 0.0
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
  FOR (xx = 1 TO value(request->nbr_cases))
   SELECT INTO "nl:"
    seq_nbr = seq(long_data_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     reply->qual[xx].comments_long_text_id = seq_nbr
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationname = "NEWSEQ"
    SET reply->status_data.subeventstatus[1].operationstatus = "Z"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "REFERENCE_SEQ"
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ENDFOR
 ENDIF
 IF (textlen(request->comments) > 0)
  INSERT  FROM long_text lt,
    (dummyt d1  WITH seq = value(request->nbr_cases))
   SET lt.long_text_id = reply->qual[d1.seq].comments_long_text_id, lt.updt_cnt = 0, lt.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
    updt_applctx,
    lt.active_ind = 1, lt.active_status_cd = s_active_cd, lt.active_status_dt_tm = cnvtdatetime(
     curdate,curtime3),
    lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "PATHOLOGY_CASE", lt
    .parent_entity_id = reply->qual[d1.seq].case_id,
    lt.long_text = request->comments
   PLAN (d1
    WHERE (reply->qual[d1.seq].comments_long_text_id > 0)
     AND (reply->qual[d1.seq].case_id > 0))
    JOIN (lt)
   WITH nocounter
  ;end insert
  IF ((curqual != request->nbr_cases))
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 INSERT  FROM pathology_case p,
   (dummyt d  WITH seq = value(request->nbr_cases))
  SET p.case_id = reply->qual[d.seq].case_id, p.person_id = request->person_id, p.encntr_id = request
   ->encntr_id,
   p.prefix_id = request->prefix_cd, p.case_type_cd = request->case_type_cd, p.group_id =
   accession_fmt->qual[1].accession_pool_id,
   p.case_year = accession_fmt->qual[1].accession_year, p.case_number = reply->qual[d.seq].
   case_number, p.accession_nbr = reply->qual[d.seq].accession,
   p.reserved_ind = 1, p.accession_prsnl_id = reqinfo->updt_id, p.accessioned_dt_tm = cnvtdatetime(
    curdate,curtime),
   p.comments_long_text_id = reply->qual[d.seq].comments_long_text_id, p.origin_flag = 0, p
   .updt_dt_tm = cnvtdatetime(curdate,curtime),
   p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
   updt_applctx,
   p.updt_cnt = 0
  PLAN (d)
   JOIN (p)
  WITH nocounter
 ;end insert
 IF ((curqual != request->nbr_cases))
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  ROLLBACK
 ELSE
  SET reqinfo->commit_ind = 1
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alterlist(accession_fmt->qual,0)
 CALL echo(build("Status :",reply->status_data.status))
END GO
