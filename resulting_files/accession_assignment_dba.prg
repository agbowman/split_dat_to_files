CREATE PROGRAM accession_assignment:dba
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
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 insert_aor_ind = i2
    1 cpri_info_ind = i2
    1 time_ind = i2
    1 qual[*]
      2 request_tag = vc
      2 order_id = f8
      2 facility_cd = f8
      2 site_prefix_cd = f8
      2 site_prefix_disp = c5
      2 activity_type_cd = f8
      2 accession_format_cd = f8
      2 catalog_cd = f8
      2 specimen_type_cd = f8
      2 collection_priority_cd = f8
      2 group_with_other_flag = i2
      2 accession_dt_tm = dq8
      2 accession_flag = i2
      2 service_area_cd = f8
      2 body_site_cd = f8
    1 group_qual[*]
      2 accession_id = f8
      2 accession_dt_tm = dq8
      2 catalog_cd = f8
      2 specimen_type_cd = f8
      2 activity_type_cd = f8
      2 accession_flag = i2
      2 collection_priority_cd = f8
      2 group_with_other_flag = i2
      2 service_area_cd = f8
      2 body_site_cd = f8
  ) WITH public
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 assignment_meaning = vc
    1 qual[*]
      2 reply_tag = vc
      2 order_id = f8
      2 catalog_cd = f8
      2 facility_cd = f8
      2 site_prefix_cd = f8
      2 site_prefix_disp = c5
      2 accession_id = f8
      2 accession_day = i4
      2 accession_year = i4
      2 accession_format_cd = f8
      2 accession_format_meaning = c12
      2 alpha_prefix = c2
      2 accession_pool_id = f8
      2 accession_seq_nbr = i4
      2 accession = c20
      2 accession_formatted = c25
      2 assignment_meaning = vc
      2 assignment_status = i2
      2 accession_class_cd = f8
      2 activity_type_cd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH public
 ENDIF
 DECLARE fmt_sze = i2 WITH noconstant(size(request->qual,5))
 DECLARE cpri_ind = i2 WITH noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lindex = i4 WITH protect, noconstant(0)
#begin_script
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 IF (fmt_sze=0)
  SET reply->status_data.status = "Z"
  CALL subevent_add("REQUEST",reply->status_data.status,"REQUEST","No items passed in the request")
  GO TO exit_script
 ENDIF
 SET stat = alterlist(accession_fmt->qual,fmt_sze)
 SET accession_fmt->act_lookup = 0
 SET accession_fmt->cpri_lookup = request->cpri_info_ind
 SET accession_fmt->time_ind = request->time_ind
 SET accession_fmt->insert_aor_ind = request->insert_aor_ind
 FOR (i = 1 TO fmt_sze)
   SET accession_fmt->qual[i].order_id = request->qual[i].order_id
   SET accession_fmt->qual[i].catalog_cd = request->qual[i].catalog_cd
   SET accession_fmt->qual[i].facility_cd = request->qual[i].facility_cd
   SET accession_fmt->qual[i].site_prefix_cd = request->qual[i].site_prefix_cd
   SET accession_fmt->qual[i].site_prefix_disp = request->qual[i].site_prefix_disp
   SET accession_fmt->qual[i].accession_format_cd = request->qual[i].accession_format_cd
   SET accession_fmt->qual[i].accession_format_mean = ""
   IF ((request->qual[i].accession_format_cd > 0))
    SET accession_fmt->qual[i].accession_class_cd = 0
   ELSE
    SET accession_fmt->qual[i].accession_class_cd = - (1)
   ENDIF
   SET accession_fmt->qual[i].specimen_type_cd = request->qual[i].specimen_type_cd
   SET accession_fmt->qual[i].accession_dt_tm = request->qual[i].accession_dt_tm
   SET accession_fmt->qual[i].accession_day = 0
   SET accession_fmt->qual[i].accession_year = 0
   SET accession_fmt->qual[i].alpha_prefix = ""
   SET accession_fmt->qual[i].accession_seq_nbr = 0
   SET accession_fmt->qual[i].accession_pool_id = 0
   SET accession_fmt->qual[i].assignment_meaning = ""
   SET accession_fmt->qual[i].assignment_status = 0
   SET accession_fmt->qual[i].accession_id = 0
   SET accession_fmt->qual[i].accession = ""
   SET accession_fmt->qual[i].accession_formatted = ""
   SET accession_fmt->qual[i].activity_type_cd = request->qual[i].activity_type_cd
   SET accession_fmt->qual[i].activity_type_mean = ""
   SET accession_fmt->qual[i].order_tag = 0
   SET accession_fmt->qual[i].accession_info_pos = 0
   SET accession_fmt->qual[i].accession_flag = request->qual[i].accession_flag
   SET accession_fmt->qual[i].collection_priority_cd = request->qual[i].collection_priority_cd
   SET accession_fmt->qual[i].group_with_other_flag = request->qual[i].group_with_other_flag
   SET accession_fmt->qual[i].accession_parent = 0
   SET accession_fmt->qual[i].body_site_ind = 0
   SET accession_fmt->qual[i].specimen_type_ind = 0
   SET stat = alterlist(accession_fmt->qual[i].linked_qual,0)
   IF ((accession_fmt->qual[i].collection_priority_cd > 0))
    SET cpri_ind = 1
   ENDIF
   IF ((accession_fmt->qual[i].activity_type_cd=0)
    AND (accession_fmt->qual[i].catalog_cd > 0))
    SET accession_fmt->act_lookup = 1
   ENDIF
 ENDFOR
 IF (cpri_ind > 0
  AND (request->cpri_info_ind=0))
  SET accession_fmt->cpri_lookup = 1
 ENDIF
 IF (size(request->group_qual,5) > 0)
  SET accession_grp->act_lookup = 0
  SET accession_grp->cpri_lookup = request->cpri_info_ind
  SELECT INTO "nl:"
   a.accession_id
   FROM accession a
   WHERE a.accession_id > 0
    AND expand(lcnt,1,size(request->group_qual,5),a.accession_id,request->group_qual[lcnt].
    accession_id)
   HEAD REPORT
    grp_cnt = 0, cpri_ind = 0, lcnt = 0
   DETAIL
    grp_cnt = (grp_cnt+ 1)
    IF (grp_cnt > size(accession_grp->qual,5))
     stat = alterlist(accession_grp->qual,(grp_cnt+ 1))
    ENDIF
    lindex = locateval(lcnt,1,size(request->group_qual,5),a.accession_id,request->group_qual[lcnt].
     accession_id), accession_grp->qual[grp_cnt].catalog_cd = request->group_qual[lindex].catalog_cd,
    accession_grp->qual[grp_cnt].specimen_type_cd = request->group_qual[lindex].specimen_type_cd,
    accession_grp->qual[grp_cnt].site_prefix_cd = a.site_prefix_cd, accession_grp->qual[grp_cnt].
    accession_format_cd = a.accession_format_cd, accession_grp->qual[grp_cnt].accession_class_cd = a
    .accession_class_cd,
    accession_grp->qual[grp_cnt].accession_dt_tm = request->group_qual[lindex].accession_dt_tm,
    accession_grp->qual[grp_cnt].accession_pool_id = a.accession_pool_id, accession_grp->qual[grp_cnt
    ].accession_id = request->group_qual[lindex].accession_id,
    accession_grp->qual[grp_cnt].accession = a.accession, accession_grp->qual[grp_cnt].
    activity_type_cd = request->group_qual[lindex].activity_type_cd, accession_grp->qual[grp_cnt].
    accession_flag = request->group_qual[lindex].accession_flag,
    accession_grp->qual[grp_cnt].collection_priority_cd = request->group_qual[lindex].
    collection_priority_cd, accession_grp->qual[grp_cnt].group_with_other_flag = request->group_qual[
    lindex].group_with_other_flag
    IF ((request->group_qual[lindex].collection_priority_cd > 0))
     cpri_ind = 1
    ENDIF
    IF ((accession_grp->qual[grp_cnt].activity_type_cd=0)
     AND (accession_grp->qual[grp_cnt].catalog_cd > 0))
     accession_grp->act_lookup = 1
    ENDIF
   FOOT REPORT
    stat = alterlist(accession_grp->qual,grp_cnt)
    IF (cpri_ind > 0
     AND (request->cpri_info_ind=0))
     accession_grp->cpri_lookup = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#execute_accession_assign
 EXECUTE accession_assign
 SET reply->assignment_meaning = trim(accession_meaning)
 IF (accession_status=acc_success)
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  SET stat = alterlist(reply->qual,fmt_sze)
  FOR (i = 1 TO fmt_sze)
    SET reply->qual[i].reply_tag = request->qual[i].request_tag
    SET reply->qual[i].order_id = accession_fmt->qual[i].order_id
    SET reply->qual[i].catalog_cd = accession_fmt->qual[i].catalog_cd
    SET reply->qual[i].facility_cd = accession_fmt->qual[i].facility_cd
    SET reply->qual[i].site_prefix_cd = accession_fmt->qual[i].site_prefix_cd
    SET reply->qual[i].site_prefix_disp = accession_fmt->qual[i].site_prefix_disp
    SET reply->qual[i].accession_day = accession_fmt->qual[i].accession_day
    SET reply->qual[i].accession_year = accession_fmt->qual[i].accession_year
    SET reply->qual[i].accession_format_cd = accession_fmt->qual[i].accession_format_cd
    SET reply->qual[i].alpha_prefix = accession_fmt->qual[i].alpha_prefix
    SET reply->qual[i].accession_seq_nbr = accession_fmt->qual[i].accession_seq_nbr
    SET reply->qual[i].accession_pool_id = accession_fmt->qual[i].accession_pool_id
    SET reply->qual[i].accession_id = accession_fmt->qual[i].accession_id
    SET reply->qual[i].accession = accession_fmt->qual[i].accession
    SET reply->qual[i].accession_formatted = accession_fmt->qual[i].accession_formatted
    SET reply->qual[i].assignment_status = accession_fmt->qual[i].assignment_status
    SET reply->qual[i].assignment_meaning = accession_fmt->qual[i].assignment_meaning
    SET reply->qual[i].activity_type_cd = accession_fmt->qual[i].activity_type_cd
    SET reply->qual[i].accession_class_cd = accession_fmt->qual[i].accession_class_cd
  ENDFOR
 ENDIF
#exit_script
END GO
