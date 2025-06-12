CREATE PROGRAM accession_validate:dba
 RECORD reply(
   1 assignment_status = i4
   1 assignment_meaning = c12
   1 qual[*]
     2 order_id = f8
     2 accession = c20
     2 accession_updt_cnt = i4
     2 accession_id = f8
     2 accession_status = i2
     2 accession_meaning = vc
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
 SET err_cnt = 0
 SET reqinfo->commit_ind = 0
 SET reply->status_data.status = "F"
 SET assignment_status = acc_error
 SET nbr_of_accessions = size(request->qual,5)
 IF (nbr_of_accessions=0)
  SET reply->assignment_meaning = "No accessions in request"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d1.seq, aax.site_prefix_cd, aax.accession_format_cd,
  aax.accession_assignment_pool_id
  FROM (dummyt d1  WITH seq = value(nbr_of_accessions)),
   accession_assign_xref aax
  PLAN (d1
   WHERE (request->qual[d1.seq].accession_pool_id=0))
   JOIN (aax
   WHERE (aax.accession_format_cd=request->qual[d1.seq].accession_format_cd)
    AND (aax.site_prefix_cd=request->qual[d1.seq].site_prefix_cd))
  DETAIL
   request->qual[d1.seq].accession_pool_id = aax.accession_assignment_pool_id
  WITH nocounter, outerjoin = d1, dontcare = aax
 ;end select
 SET stat = alterlist(reply->qual,nbr_of_accessions)
 FOR (i = 1 TO nbr_of_accessions)
   IF ((request->qual[i].accession_pool_id > 0))
    SET acc_site_prefix_cd = request->qual[i].site_prefix_cd
    EXECUTE accession_site_code
    SET request->qual[i].site_prefix_disp = acc_site_prefix
    IF ((request->qual[i].accession_format_cd > 0))
     SET acc_year = cnvtint(substring(8,4,request->qual[i].accession))
     IF ((acc_year > request->qual[i].accession_year))
      SET request->qual[i].accession_year = acc_year
     ENDIF
    ELSE
     SET acc_year = cnvtint(substring(6,4,request->qual[i].accession))
     IF ((acc_year > request->qual[i].accession_year))
      SET request->qual[i].accession_year = acc_year
     ENDIF
    ENDIF
    SET accession_str->accession_year = request->qual[i].accession_year
    SET accession_str->accession_day = request->qual[i].accession_day
    SET accession_str->alpha_prefix = request->qual[i].alpha_prefix
    SET accession_str->accession_seq_nbr = request->qual[i].accession_seq_nbr
    SET accession_str->accession_pool_id = request->qual[i].accession_pool_id
    EXECUTE accession_string
    SET accession_chk->site_prefix_cd = request->qual[i].site_prefix_cd
    SET accession_chk->accession_year = request->qual[i].accession_year
    SET accession_chk->accession_day = request->qual[i].accession_day
    SET accession_chk->accession_pool_id = request->qual[i].accession_pool_id
    SET accession_chk->accession_seq_nbr = request->qual[i].accession_seq_nbr
    SET accession_chk->accession_class_cd = 0
    SET accession_chk->accession_format_cd = request->qual[i].accession_format_cd
    SET accession_chk->alpha_prefix = request->qual[i].alpha_prefix
    SET accession_chk->accession = accession_nbr
    SET accession_chk->accession_nbr_check = accession_nbr_chk
    SET accession_chk->action_ind = request->action_ind
    SET accession_chk->preactive_ind = request->qual[i].preactive_ind
    SET accession_chk->accession_updt_cnt = request->qual[i].accession_updt_cnt
    SET accession_chk->accession_id = request->qual[i].accession_id
    EXECUTE accession_check
    SET reply->qual[i].accession = accession_nbr
    SET reply->qual[i].accession_meaning = accession_meaning
    SET reply->qual[i].accession_status = accession_status
    SET reply->qual[i].accession_updt_cnt = accession_updt_cnt
    IF (accession_status=acc_success)
     SET reply->qual[i].accession_id = accession_id
    ELSE
     SET err_cnt = (err_cnt+ 1)
     SET reply->qual[i].accession_id = accession_dup_id
    ENDIF
   ENDIF
 ENDFOR
 IF (err_cnt > 0)
  SET reply->assignment_status = acc_error
  IF ((request->action_ind=1))
   SET reply->accession_meaning = "Not all accessions are valid"
  ELSE
   SET reply->assignment_meaning = "Not all accessions assigned"
  ENDIF
  GO TO exit_script
 ENDIF
 IF ((request->insert_aor_ind=1))
  INSERT  FROM accession_order_r aor,
    (dummyt d1  WITH seq = value(nbr_of_accessions))
   SET aor.order_id = reply->qual[d1.seq].order_id, aor.accession_id = reply->qual[d1.seq].
    accession_id, aor.accession = reply->qual[d1.seq].accession,
    aor.updt_dt_tm = cnvtdatetime(curdate,curtime3), aor.updt_id = reqinfo->updt_id, aor.updt_task =
    reqinfo->updt_task,
    aor.updt_applctx = reqinfo->updt_applctx, aor.updt_cnt = 0
   PLAN (d1
    WHERE (reply->qual[d1.seq].order_id > 0)
     AND (reply->qual[d1.seq].accession_status=1))
    JOIN (aor)
   WITH nocounter
  ;end insert
  IF (curqual != nbr_of_accessions)
   SET reply->assignment_status = acc_error
   SET reply->assignment_meaning = "Error inserting accession_order table"
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->assignment_status = acc_success
 CASE (request->action_ind)
  OF 0:
   SET reply->assignment_meaning = "All accessions assigned"
  OF 1:
   SET reply->assignment_meaning = "All accessions are valid"
  OF 2:
   SET reply->assignment_meaning = "All accessions modified"
 ENDCASE
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
