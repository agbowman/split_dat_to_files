CREATE PROGRAM aps_get_prefixes_by_spec:dba
 RECORD reply(
   1 prefix_qual[*]
     2 site_cd = f8
     2 unformatted_site_disp = c40
     2 prefix_cd = f8
     2 prefix_desc = c40
     2 prefix_name = c2
     2 case_type_cd = f8
     2 accession_format_cd = f8
     2 active_ind = i4
     2 group_id = f8
     2 site_disp = c40
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
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
#script
 SET reply->status_data.status = "F"
 DECLARE prefix_cnt = i2 WITH protect, noconstant(0)
 DECLARE prefixes_where = vc WITH protect, noconstant(" ")
 DECLARE site_format = c5 WITH protect, constant("00000")
 DECLARE specimen_cdf = c12 WITH protect, noconstant(fillstring(12," "))
 EXECUTE accession_settings
 IF (accession_status != acc_success)
  SET reply->status_data.status = "F"
  SET stat = alter(reply->prefix_qual,1)
  GO TO exit_script
 ENDIF
 IF ((request->bshowinactives=1))
  SET prefixes_where = "p.active_ind in (0,1)"
 ELSE
  SET prefixes_where = "p.active_ind = 1"
 ENDIF
 SELECT INTO "nl:"
  p.prefix_name, p.prefix_id, site_unformatted = uar_get_code_display(p.site_cd)
  FROM ap_prefix p,
   specimen_grouping_r gr
  PLAN (gr
   WHERE (gr.source_cd=request->specimen_cd))
   JOIN (p
   WHERE p.specimen_grouping_cd=gr.category_cd
    AND parser(prefixes_where))
  ORDER BY p.prefix_name, p.prefix_id
  DETAIL
   prefix_cnt = (prefix_cnt+ 1)
   IF (mod(prefix_cnt,10)=1)
    stat = alterlist(reply->prefix_qual,(prefix_cnt+ 9))
   ENDIF
   reply->prefix_qual[prefix_cnt].prefix_cd = p.prefix_id, reply->prefix_qual[prefix_cnt].prefix_name
    = p.prefix_name, reply->prefix_qual[prefix_cnt].site_cd = p.site_cd,
   reply->prefix_qual[prefix_cnt].case_type_cd = p.case_type_cd, reply->prefix_qual[prefix_cnt].
   accession_format_cd = p.accession_format_cd, reply->prefix_qual[prefix_cnt].prefix_desc = p
   .prefix_desc,
   reply->prefix_qual[prefix_cnt].active_ind = p.active_ind, reply->prefix_qual[prefix_cnt].group_id
    = p.group_id
   IF (cnvtint(site_unformatted) != 0)
    reply->prefix_qual[prefix_cnt].unformatted_site_disp = site_unformatted, reply->prefix_qual[
    prefix_cnt].site_disp = build(substring(1,(acc_settings->site_code_length - textlen(trim(
        cnvtstring(cnvtint(site_unformatted))))),site_format),cnvtint(site_unformatted))
   ENDIF
 ;end select
 SET specimen_cdf = uar_get_code_meaning(request->specimen_cd)
 SELECT INTO "nl:"
  site_unformatted = uar_get_code_display(p.site_cd)
  FROM case_specimen_type_r c,
   ap_prefix p
  PLAN (c
   WHERE c.specimen_meaning=specimen_cdf)
   JOIN (p
   WHERE c.case_type_cd=p.case_type_cd
    AND p.specimen_grouping_cd IN (0, null)
    AND parser(prefixes_where))
  DETAIL
   prefix_cnt = (prefix_cnt+ 1)
   IF (mod(prefix_cnt,10)=1)
    stat = alterlist(reply->prefix_qual,(prefix_cnt+ 9))
   ENDIF
   reply->prefix_qual[prefix_cnt].prefix_cd = p.prefix_id, reply->prefix_qual[prefix_cnt].prefix_name
    = p.prefix_name, reply->prefix_qual[prefix_cnt].site_cd = p.site_cd,
   reply->prefix_qual[prefix_cnt].case_type_cd = p.case_type_cd, reply->prefix_qual[prefix_cnt].
   accession_format_cd = p.accession_format_cd, reply->prefix_qual[prefix_cnt].prefix_desc = p
   .prefix_desc,
   reply->prefix_qual[prefix_cnt].active_ind = p.active_ind, reply->prefix_qual[prefix_cnt].group_id
    = p.group_id
   IF (cnvtint(site_unformatted) != 0)
    reply->prefix_qual[prefix_cnt].unformatted_site_disp = site_unformatted, reply->prefix_qual[
    prefix_cnt].site_disp = build(substring(1,(acc_settings->site_code_length - textlen(trim(
        cnvtstring(cnvtint(site_unformatted))))),site_format),cnvtint(site_unformatted))
   ENDIF
 ;end select
 SET stat = alterlist(reply->prefix_qual,prefix_cnt)
 IF (prefix_cnt=0)
  SET reply->status_data.status = "Z"
  SET stat = alterlist(reply->prefix_qual,1)
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
