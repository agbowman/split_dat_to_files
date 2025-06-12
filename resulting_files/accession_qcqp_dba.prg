CREATE PROGRAM accession_qcqp:dba
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
 RECORD acc(
   1 qual[*]
     2 accession_id = f8
     2 accession = vc
     2 accession_check = vc
     2 format_cd = f8
     2 site_prefix = c5
     2 site_prefix_cd = f8
     2 year = i4
     2 day = i4
     2 alpha_prefix = c2
     2 sequence = i4
     2 pool_id = f8
     2 acc = vc
     2 acc_chk = vc
     2 preactive_ind = i2
 )
 SET qp_format_cd = 0
 SET qc_format_cd = 0
 SELECT INTO "nl:"
  c.code_set, c.code_value, c.display
  FROM code_value c
  WHERE c.code_set=2057
   AND c.cdf_meaning IN ("QP", "QC")
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   CASE (c.cdf_meaning)
    OF "QC":
     qc_format_cd = c.code_value
    OF "QP":
     qp_format_cd = c.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (((qc_format_cd=0) OR (qp_format_cd=0)) )
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  a.accession_id, a.accession, a.accession_nbr_check
  FROM accession a
  WHERE a.alpha_prefix IN ("QP", "QC")
  HEAD REPORT
   x = 0
  DETAIL
   x = (x+ 1)
   IF (x > size(acc->qual,5))
    stat = alterlist(acc->qual,(x+ 10))
   ENDIF
   acc->qual[x].accession_id = a.accession_id, acc->qual[x].accession = a.accession, acc->qual[x].
   accession_check = a.accession_nbr_check
   IF (a.preactive_ind=1)
    acc->qual[x].preactive_ind = a.preactive_ind
   ELSE
    acc->qual[x].preactive_ind = 0
   ENDIF
   IF (a.alpha_prefix="QP")
    acc->qual[x].format_cd = qp_format_cd
   ELSE
    acc->qual[x].format_cd = qc_format_cd
   ENDIF
   acc->qual[x].alpha_prefix = a.alpha_prefix, acc->qual[x].sequence = a.accession_sequence_nbr, acc
   ->qual[x].site_prefix = substring(1,5,a.accession)
   IF ((acc->qual[x].site_prefix=" "))
    acc->qual[x].site_prefix = "00000"
   ENDIF
   acc->qual[x].site_prefix_cd = a.site_prefix_cd, acc->qual[x].year = a.accession_year, acc->qual[x]
   .day = a.accession_day,
   acc->qual[x].pool_id = 0
  FOOT REPORT
   stat = alterlist(acc->qual,x)
  WITH nocounter
 ;end select
 SET aax_cnt = 0
 SELECT INTO "nl:"
  d1.seq, aax.accession_format_cd, aax.site_prefix_cd,
  aax.accession_assignment_pool_id
  FROM (dummyt d1  WITH seq = value(size(acc->qual,5))),
   accession_assign_xref aax
  PLAN (d1)
   JOIN (aax
   WHERE (acc->qual[d1.seq].site_prefix_cd=aax.site_prefix_cd)
    AND (acc->qual[d1.seq].format_cd=aax.accession_format_cd))
  HEAD REPORT
   aax_cnt = 0
  DETAIL
   aax_cnt = (aax_cnt+ 1), acc->qual[d1.seq].pool_id = aax.accession_assignment_pool_id
  WITH nocounter
 ;end select
 IF (aax_cnt != value(size(acc->qual,5)))
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO aax_cnt)
   SET accession_str->site_prefix_disp = acc->qual[i].site_prefix
   SET accession_str->accession_year = 0
   SET accession_str->accession_day = acc->qual[i].day
   SET accession_str->alpha_prefix = acc->qual[i].alpha_prefix
   SET accession_str->accession_seq_nbr = acc->qual[i].sequence
   SET accession_str->accession_pool_id = acc->qual[i].pool_id
   EXECUTE accession_string
   SET acc->qual[i].acc = accession_nbr
   SET acc->qual[i].acc_chk = accession_nbr_chk
 ENDFOR
 UPDATE  FROM accession a,
   (dummyt d1  WITH seq = value(aax_cnt))
  SET a.accession_id = acc->qual[d1.seq].accession_id, a.accession = acc->qual[d1.seq].acc, a
   .accession_nbr_check = acc->qual[d1.seq].acc_chk,
   a.accession_format_cd = acc->qual[d1.seq].format_cd, a.accession_pool_id = acc->qual[d1.seq].
   pool_id, a.accession_year = 0,
   a.preactive_ind = acc->qual[d1.seq].preactive_ind, a.updt_applctx = 0, a.updt_dt_tm = cnvtdatetime
   (curdate,curtime3),
   a.updt_id = 0, a.updt_cnt = (a.updt_cnt+ 1), a.updt_task = 0
  PLAN (d1)
   JOIN (a
   WHERE (a.accession_id=acc->qual[d1.seq].accession_id))
  WITH nocounter
 ;end update
 IF (curqual=aax_cnt)
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
#exit_script
END GO
