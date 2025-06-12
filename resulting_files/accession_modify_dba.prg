CREATE PROGRAM accession_modify:dba
 RECORD reply(
   1 accession = c20
   1 accession_id = f8
   1 accession_status = i2
   1 accession_meaning = vc
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
 SET reqinfo->commit_ind = 0
 SET reply->status_data.status = "F"
 SET assignment_status = acc_error
 SET accession_chk->accession = request->acc_to.accession
 SET accession_chk->accession_nbr_check = request->acc_to.accession_nbr_check
 SET accession_chk->action_ind = 1
 EXECUTE accession_check
 IF (accession_status != acc_success)
  SET reply->accession_status = accession_status
  SET reply->accession_meaning = build("To Accession:  ",accession_meaning)
  SET reply->accession_id = accession_dup_id
  SET reply->accession = request->accession
  GO TO exit_script
 ENDIF
 SET accession_chk->accession = request->acc_from.accession
 SET accession_chk->accession_nbr_check = request->acc_from.accession_nbr_check
 SET accession_chk->action_ind = 1
 EXECUTE accession_check
 IF (accession_status != acc_duplicate)
  SET reply->accession_status = accession_status
  SET reply->accession_meaning = build("From Accession:  ",accession_meaning)
  SET reply->accession_id = accession_dup_id
  SET reply->accession = request->accession
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  a.accession_id
  FROM accession a
  WHERE a.accession_id=accession_dup_id
  WITH nocounter, forupdate(a)
 ;end select
 IF (curqual > 0)
  UPDATE  FROM accession a
   SET a.accession = request->acc_to.accession, a.accession_nbr_check = trim(request->acc_to.
     accession_nbr_check), a.site_prefix_cd = request->acc_to.site_prefix_cd,
    a.accession_year = request->acc_to.accession_year, a.accession_day = request->acc_to.
    accession_day, a.accession_format_cd = request->acc_to.accession_format_cd,
    a.alpha_prefix = request->acc_to.alpha_prefix, a.accession_sequence_nbr = request->acc_to.
    accession_sequence_nbr, a.accession_pool_id = request->acc_to.accession_pool_id,
    a.preactive_ind = request->acc_to.preactive_ind, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a
    .updt_id = reqinfo->updt_id,
    a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = (a
    .updt_cnt+ 1)
   WHERE a.accession_id=accession_dup_id
    AND a.updt_cnt=accession_updt_cnt
   WITH nocounter
  ;end update
  IF (curqual > 0)
   SET reply->accession_status = acc_success
   SET reply->accession_meaning = "Accession modified on the accession table"
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
  ENDIF
 ELSE
  SET reply->accession_meaning = "Update failed on the Accession table"
 ENDIF
#exit_script
END GO
