CREATE PROGRAM accession_generate:dba
 RECORD reply(
   1 accession_status = i4
   1 accession_meaning = vc
   1 qual[*]
     2 accession = c20
     2 accession_id = f8
     2 accession_formatted = c25
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
 SET reply->status_data.status = "Z"
 SET reqinfo->commit_ind = 0
 DECLARE acc_date = q8
 IF ((request->quantity=0))
  SET accession_status = acc_error
  SET accession_meaning = "No accessions requested"
  GO TO exit_script
 ENDIF
 SET sequence_length = julian_sequence_length
 IF ((request->accession_format_cd > 0))
  SET sequence_length = prefix_sequence_length
 ENDIF
 SET increment_value = 1
 SET acc_seq_number = 0
 IF ((request->accession_sequence_nbr > acc_seq_number))
  SET acc_seq_number = request->accession_sequence_nbr
 ENDIF
 SELECT INTO "nl:"
  aa.accession_seq_nbr, aa.increment_value
  FROM accession_assignment aa
  WHERE (aa.acc_assign_pool_id=request->accession_pool_id)
   AND aa.acc_assign_date=cnvtdatetimeutc(request->acc_assign_date,2)
  DETAIL
   IF (aa.accession_seq_nbr > acc_seq_number)
    acc_seq_number = aa.accession_seq_nbr
   ENDIF
   increment_value = aa.increment_value
  WITH nocounter, forupdatewait(aa)
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   aap.increment_value, aap.initial_value
   FROM accession_assign_pool aap
   WHERE (aap.accession_assignment_pool_id=request->accession_pool_id)
   DETAIL
    increment_value = aap.increment_value
    IF (acc_seq_number=0)
     acc_seq_number = aap.initial_value
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET assignment_status = acc_template
   SET assignment_meaning = "Error getting accession pool information"
   GO TO exit_script
  ENDIF
  IF (cnvtdatetimeutc(request->acc_assign_date)=null)
   SET iyear = request->accession_year
   SET iday = request->accession_day
   SET sdate = build("01-JAN-",iyear," 12:00:00")
   SET date_3 = cnvtdate2(sdate,"DD-MMM-YYYY")
   SET acc_date = cnvtdatetime(((date_3+ iday) - 1),curtime3)
  ELSE
   SET acc_date = cnvtdatetimeutc(request->acc_assign_date,2)
  ENDIF
  INSERT  FROM accession_assignment aa
   SET aa.acc_assign_pool_id = request->accession_pool_id, aa.acc_assign_date = cnvtdatetimeutc(
     acc_date), aa.accession_seq_nbr = acc_seq_number,
    aa.increment_value = increment_value, aa.last_increment_dt_tm = cnvtdatetime(curdate,curtime3),
    aa.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    aa.updt_id = reqinfo->updt_id, aa.updt_task = reqinfo->updt_task, aa.updt_applctx = reqinfo->
    updt_applctx,
    aa.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET assignment_status = acc_pool
   SET assignment_meaning = "Error inserting accession pool on the accession_assignment table"
   GO TO exit_script
  ENDIF
 ENDIF
 SET acc_cnt = 0
 SET accession_id = 0.0
 FOR (i = 1 TO request->quantity)
  SET acc_loop = 1
  WHILE (acc_loop=1)
    SET accession_chk->accession = fillstring(20," ")
    SET accession_chk->accession_nbr_check = fillstring(50," ")
    SET accession_chk->accession = concat(trim(accession_chk->accession),trim(request->accession),
     cnvtstring(acc_seq_number,value(sequence_length),0,r))
    SET accession_chk->accession_nbr_check = concat(trim(accession_chk->accession_nbr_check),request
     ->accession_nbr_check,cnvtstring(acc_seq_number,value(sequence_length),0,r))
    SET accession_chk->check_disp_ind = 0
    SET accession_chk->site_prefix_cd = request->site_prefix_cd
    SET accession_chk->accession_year = request->accession_year
    SET accession_chk->accession_day = request->accession_day
    SET accession_chk->accession_pool_id = request->accession_pool_id
    SET accession_chk->accession_seq_nbr = acc_seq_number
    SET accession_chk->accession_class_cd = 0
    SET accession_chk->accession_format_cd = request->accession_format_cd
    SET accession_chk->alpha_prefix = request->alpha_prefix
    SET accession_chk->action_ind = 0
    SET accession_chk->preactive_ind = 0
    SET accession_chk->assignment_ind = request->assignment_ind
    EXECUTE accession_check
    IF (accession_status=acc_success)
     IF (accession_dup_id=0
      AND accession_id > 0)
      SET acc_loop = 0
      SET acc_cnt = (acc_cnt+ 1)
      IF (acc_cnt > size(reply->qual,5))
       SET stat = alterlist(reply->qual,(acc_cnt+ 10))
      ENDIF
      SET reply->qual[acc_cnt].accession = accession_chk->accession
      SET reply->qual[acc_cnt].accession_id = accession_id
      SET reply->qual[acc_cnt].accession_formatted = uar_fmt_accession(accession_chk->accession,size(
        accession_chk->accession))
     ENDIF
    ELSEIF (accession_status != acc_duplicate)
     GO TO exit_script
    ENDIF
    SET acc_seq_number = (acc_seq_number+ increment_value)
  ENDWHILE
 ENDFOR
 SET stat = alterlist(reply->qual,acc_cnt)
 SET accession_status = acc_success
#exit_script
 SET reply->accession_status = accession_status
 SET reply->accession_meaning = accession_meaning
 IF (accession_status=acc_success)
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
