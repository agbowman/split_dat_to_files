CREATE PROGRAM aps_get_prefix_info1:dba
 DECLARE failed = c1 WITH private, noconstant("F")
 DECLARE site_format = c5 WITH protect, constant("00000")
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
 EXECUTE accession_settings
 IF (accession_status != acc_success)
  SET reply->status_data.subeventstatus[1].operationname = "ACC_SETTINGS"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ACCESSION"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = accession_settings
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  p.prefix_id, tag_type_flag = decode(tg.seq,tg.tag_type_flag,- (1)), tag_group_id = decode(tg.seq,tg
   .tag_group_id,0.0),
  t.tag_id, join_path = decode(tg.seq,"T",cs.seq,"S"), cs.specimen_meaning,
  site_unformatted = uar_get_code_display(p.site_cd)
  FROM ap_prefix p,
   (dummyt d  WITH seq = 1),
   ap_prefix_tag_group_r tg,
   ap_tag t,
   (dummyt d1  WITH seq = 1),
   case_specimen_type_r cs
  PLAN (p
   WHERE  $1)
   JOIN (((d
   WHERE 1=d.seq)
   JOIN (tg
   WHERE p.prefix_id=tg.prefix_id
    AND  $2)
   JOIN (t
   WHERE tg.tag_group_id=t.tag_group_id
    AND t.active_ind=1)
   ) ORJOIN ((d1
   WHERE 1=d1.seq)
   JOIN (cs
   WHERE p.case_type_cd=cs.case_type_cd)
   ))
  ORDER BY tag_type_flag, tag_group_id
  HEAD REPORT
   tag_group_cnt = 0, spec_cnt = 0, reply->prefix_cd = p.prefix_id,
   reply->prefix_name = p.prefix_name, reply->prefix_desc = p.prefix_desc, reply->site_cd = p.site_cd,
   reply->accession_format_cd = p.accession_format_cd, reply->order_catalog_cd = p.order_catalog_cd,
   reply->case_type_cd = p.case_type_cd,
   reply->group_cd = p.group_id, reply->specimen_grouping_cd = p.specimen_grouping_cd
   IF (cnvtint(site_unformatted) != 0)
    reply->unformatted_site_disp = site_unformatted, reply->site_disp = build(substring(1,(
      acc_settings->site_code_length - textlen(trim(cnvtstring(cnvtint(site_unformatted))))),
      site_format),cnvtint(site_unformatted))
   ENDIF
  HEAD tag_type_flag
   tag_group_cnt = tag_group_cnt
  HEAD tag_group_id
   IF (join_path="T")
    tag_cnt = 0, tag_group_cnt = (tag_group_cnt+ 1)
    IF (tag_group_cnt > 1)
     stat = alter(reply->tag_group_qual,tag_group_cnt)
    ENDIF
    reply->tag_group_qual[tag_group_cnt].tag_group_cd = tag_group_id, reply->tag_group_qual[
    tag_group_cnt].tag_type_flag = tag_type_flag, reply->tag_group_qual[tag_group_cnt].tag_separator
     = tg.tag_separator,
    reply->tag_group_qual[tag_group_cnt].primary_ind = tg.primary_ind, reply->tag_group_qual[
    tag_group_cnt].tag_cnt = 0, stat = alterlist(reply->tag_group_qual[tag_group_cnt].tag_qual,26)
   ENDIF
  FOOT  tag_group_id
   IF (join_path="T")
    reply->tag_group_qual[tag_group_cnt].tag_cnt = tag_cnt, stat = alterlist(reply->tag_group_qual[
     tag_group_cnt].tag_qual,tag_cnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PREFIX"
  SET failed = "T"
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
 ENDIF
END GO
