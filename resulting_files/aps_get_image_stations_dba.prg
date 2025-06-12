CREATE PROGRAM aps_get_image_stations:dba
 RECORD reply(
   1 station_qual[*]
     2 station_id = f8
     2 station_name = c40
     2 source_device_cd = f8
     2 source_device_disp = c40
     2 updt_cnt = i4
     2 prefix_qual[*]
       3 prefix_id = f8
       3 prefix_disp = c40
       3 catalog_cd = f8
       3 catalog_disp = c40
       3 task_assay_cd = f8
       3 task_assay_disp = c40
       3 publish_flag = i2
       3 updt_cnt = i4
       3 site_cd = f8
       3 site_disp = c40
     2 source_device_url = vc
     2 source_device_folder = vc
     2 source_device_username = vc
     2 source_device_password = vc
     2 source_device_image_server_url = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET station_cnt = 0
 SET prefix_cnt = 0
 DECLARE site_format = c5 WITH protect, constant("00000")
 DECLARE site_display = c40 WITH protect
 DECLARE site_unformat = c40 WITH protect
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
 IF ((request->station_id > 0.0))
  SELECT INTO "nl:"
   ais.station_id, apsr_exists = evaluate(nullind(apsr.station_id),1,0,1), apsr.station_id,
   apsr.prefix_id, ap.prefix_id, site_display = cnvtupper(uar_get_code_display(ap.site_cd))
   FROM ap_image_station ais,
    ap_prefix_station_r apsr,
    ap_prefix ap,
    ap_source_device_addl asd
   PLAN (ais
    WHERE (ais.station_id=request->station_id))
    JOIN (apsr
    WHERE apsr.station_id=outerjoin(ais.station_id))
    JOIN (ap
    WHERE ap.prefix_id=outerjoin(apsr.prefix_id))
    JOIN (asd
    WHERE asd.source_device_cd=outerjoin(ais.source_device_cd)
     AND asd.source_device_cd > outerjoin(0.0))
   ORDER BY cnvtupper(ais.station_name), site_display, trim(cnvtupper(ap.prefix_name),2)
   HEAD REPORT
    station_cnt = 0, stat = alterlist(reply->station_qual,10)
   HEAD ais.station_id
    station_cnt = (station_cnt+ 1)
    IF (mod(station_cnt,10)=1
     AND station_cnt != 1)
     stat = alterlist(reply->station_qual,(station_cnt+ 9))
    ENDIF
    reply->station_qual[station_cnt].station_id = ais.station_id, reply->station_qual[station_cnt].
    station_name = ais.station_name, reply->station_qual[station_cnt].source_device_cd = ais
    .source_device_cd,
    reply->station_qual[station_cnt].updt_cnt = ais.updt_cnt
    IF (asd.source_device_cd > 0)
     reply->station_qual[station_cnt].source_device_url = asd.source_device_url, reply->station_qual[
     station_cnt].source_device_folder = asd.network_share_path, reply->station_qual[station_cnt].
     source_device_username = asd.device_username,
     reply->station_qual[station_cnt].source_device_password = asd.device_password, reply->
     station_qual[station_cnt].source_device_image_server_url = asd.image_server_url
    ENDIF
    prefix_cnt = 0, stat = alterlist(reply->station_qual[station_cnt].prefix_qual,10)
   DETAIL
    IF (apsr_exists=1)
     prefix_cnt = (prefix_cnt+ 1)
     IF (mod(prefix_cnt,10)=1
      AND prefix_cnt != 1)
      stat = alterlist(reply->station_qual[station_cnt].prefix_qual,(prefix_cnt+ 9))
     ENDIF
     reply->station_qual[station_cnt].prefix_qual[prefix_cnt].prefix_id = apsr.prefix_id, reply->
     station_qual[station_cnt].prefix_qual[prefix_cnt].prefix_disp = ap.prefix_name, reply->
     station_qual[station_cnt].prefix_qual[prefix_cnt].catalog_cd = apsr.catalog_cd,
     reply->station_qual[station_cnt].prefix_qual[prefix_cnt].task_assay_cd = apsr.task_assay_cd,
     reply->station_qual[station_cnt].prefix_qual[prefix_cnt].publish_flag = apsr.publish_flag, reply
     ->station_qual[station_cnt].prefix_qual[prefix_cnt].updt_cnt = apsr.updt_cnt,
     site_unformat = uar_get_code_display(ap.site_cd)
     IF (trim(site_unformat) != "")
      reply->station_qual[station_cnt].prefix_qual[prefix_cnt].site_disp = build(substring(1,(
        acc_settings->site_code_length - textlen(trim(site_unformat))),site_format),site_unformat)
     ENDIF
    ENDIF
   FOOT  ais.station_id
    stat = alterlist(reply->station_qual[station_cnt].prefix_qual,prefix_cnt)
   FOOT REPORT
    stat = alterlist(reply->station_qual,station_cnt)
   WITH nocounter
  ;end select
 ELSE
  IF ((request->stations_without_assoc_ind != 0))
   SELECT INTO "nl:"
    ais.station_id, apsr_exists = evaluate(nullind(apsr.station_id),1,0,1), apsr.station_id,
    apsr.prefix_id, ap.prefix_id, site_display = cnvtupper(uar_get_code_display(ap.site_cd))
    FROM ap_image_station ais,
     ap_prefix_station_r apsr,
     ap_prefix ap,
     ap_source_device_addl asd
    PLAN (ais
     WHERE ais.station_id != 0.0)
     JOIN (apsr
     WHERE apsr.station_id=outerjoin(ais.station_id))
     JOIN (ap
     WHERE ap.prefix_id=outerjoin(apsr.prefix_id))
     JOIN (asd
     WHERE asd.source_device_cd=outerjoin(ais.source_device_cd)
      AND asd.source_device_cd > outerjoin(0.0))
    ORDER BY cnvtupper(ais.station_name), site_display, trim(cnvtupper(ap.prefix_name),2)
    HEAD REPORT
     station_cnt = 0, stat = alterlist(reply->station_qual,10)
    HEAD ais.station_id
     station_cnt = (station_cnt+ 1)
     IF (mod(station_cnt,10)=1
      AND station_cnt != 1)
      stat = alterlist(reply->station_qual,(station_cnt+ 9))
     ENDIF
     reply->station_qual[station_cnt].station_id = ais.station_id, reply->station_qual[station_cnt].
     station_name = ais.station_name, reply->station_qual[station_cnt].source_device_cd = ais
     .source_device_cd,
     reply->station_qual[station_cnt].updt_cnt = ais.updt_cnt
     IF (asd.source_device_cd > 0)
      reply->station_qual[station_cnt].source_device_url = asd.source_device_url, reply->
      station_qual[station_cnt].source_device_folder = asd.network_share_path, reply->station_qual[
      station_cnt].source_device_username = asd.device_username,
      reply->station_qual[station_cnt].source_device_password = asd.device_password, reply->
      station_qual[station_cnt].source_device_image_server_url = asd.image_server_url
     ENDIF
     prefix_cnt = 0, stat = alterlist(reply->station_qual[station_cnt].prefix_qual,10)
    DETAIL
     IF (apsr_exists=1)
      prefix_cnt = (prefix_cnt+ 1)
      IF (mod(prefix_cnt,10)=1
       AND prefix_cnt != 1)
       stat = alterlist(reply->station_qual[station_cnt].prefix_qual,(prefix_cnt+ 9))
      ENDIF
      reply->station_qual[station_cnt].prefix_qual[prefix_cnt].prefix_id = apsr.prefix_id, reply->
      station_qual[station_cnt].prefix_qual[prefix_cnt].prefix_disp = ap.prefix_name, reply->
      station_qual[station_cnt].prefix_qual[prefix_cnt].catalog_cd = apsr.catalog_cd,
      reply->station_qual[station_cnt].prefix_qual[prefix_cnt].task_assay_cd = apsr.task_assay_cd,
      reply->station_qual[station_cnt].prefix_qual[prefix_cnt].publish_flag = apsr.publish_flag,
      reply->station_qual[station_cnt].prefix_qual[prefix_cnt].updt_cnt = apsr.updt_cnt,
      site_unformat = uar_get_code_display(ap.site_cd)
      IF (trim(site_unformat) != "")
       reply->station_qual[station_cnt].prefix_qual[prefix_cnt].site_disp = build(substring(1,(
         acc_settings->site_code_length - textlen(trim(site_unformat))),site_format),site_unformat)
      ENDIF
     ENDIF
    FOOT  ais.station_id
     stat = alterlist(reply->station_qual[station_cnt].prefix_qual,prefix_cnt)
    FOOT REPORT
     stat = alterlist(reply->station_qual,station_cnt), stat = alterlist(reply->station_qual[
      station_cnt].prefix_qual,prefix_cnt)
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    ais.station_id, apsr.station_id, apsr.prefix_id
    FROM ap_image_station ais,
     ap_prefix_station_r apsr,
     ap_source_device_addl asd
    PLAN (ais
     WHERE ais.station_id != 0.0)
     JOIN (apsr
     WHERE ais.station_id=apsr.station_id)
     JOIN (asd
     WHERE asd.source_device_cd=outerjoin(ais.source_device_cd)
      AND asd.source_device_cd > outerjoin(0.0))
    ORDER BY ais.station_id, apsr.prefix_id
    HEAD REPORT
     station_cnt = 0, stat = alterlist(reply->station_qual,10)
    HEAD ais.station_id
     station_cnt = (station_cnt+ 1)
     IF (mod(station_cnt,10)=1
      AND station_cnt != 1)
      stat = alterlist(reply->station_qual,(station_cnt+ 9))
     ENDIF
     reply->station_qual[station_cnt].station_id = ais.station_id, reply->station_qual[station_cnt].
     station_name = ais.station_name, reply->station_qual[station_cnt].source_device_cd = ais
     .source_device_cd,
     reply->station_qual[station_cnt].updt_cnt = ais.updt_cnt
     IF (asd.source_device_cd > 0)
      reply->station_qual[station_cnt].source_device_url = asd.source_device_url, reply->
      station_qual[station_cnt].source_device_folder = asd.network_share_path, reply->station_qual[
      station_cnt].source_device_username = asd.device_username,
      reply->station_qual[station_cnt].source_device_password = asd.device_password, reply->
      station_qual[station_cnt].source_device_image_server_url = asd.image_server_url
     ENDIF
     prefix_cnt = 0, stat = alterlist(reply->station_qual[station_cnt].prefix_qual,10)
    DETAIL
     prefix_cnt = (prefix_cnt+ 1)
     IF (mod(prefix_cnt,10)=1
      AND prefix_cnt != 1)
      stat = alterlist(reply->station_qual[station_cnt].prefix_qual,(prefix_cnt+ 9))
     ENDIF
     reply->station_qual[station_cnt].prefix_qual[prefix_cnt].prefix_id = apsr.prefix_id, reply->
     station_qual[station_cnt].prefix_qual[prefix_cnt].catalog_cd = apsr.catalog_cd, reply->
     station_qual[station_cnt].prefix_qual[prefix_cnt].task_assay_cd = apsr.task_assay_cd,
     reply->station_qual[station_cnt].prefix_qual[prefix_cnt].publish_flag = apsr.publish_flag, reply
     ->station_qual[station_cnt].prefix_qual[prefix_cnt].updt_cnt = apsr.updt_cnt
    FOOT  ais.station_id
     stat = alterlist(reply->station_qual[station_cnt].prefix_qual,prefix_cnt)
    FOOT REPORT
     stat = alterlist(reply->station_qual,station_cnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PREFIX_STATION_R"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
