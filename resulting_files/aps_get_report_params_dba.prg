CREATE PROGRAM aps_get_report_params:dba
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
 RECORD reply(
   1 qual[10]
     2 query_cd = f8
     2 code_value_updt_cnt = i4
     2 param_qual[*]
       3 query_param_id = f8
       3 param_name = c20
       3 criteria_type_flag = i4
       3 date_type_flag = i2
       3 beg_value_id = f8
       3 beg_value_disp = c40
       3 beg_value_dt_tm = dq8
       3 end_value_id = f8
       3 end_value_disp = c40
       3 end_value_dt_tm = dq8
       3 negation_ind = i2
       3 source_vocabulary_cd = f8
       3 updt_cnt = i4
       3 sequence = i4
       3 freetext_query_flag = i2
       3 freetext_query = vc
       3 freetext_long_text_id = f8
       3 freetext_updt_cnt = i4
       3 synoptic_query_flag = i2
       3 synoptic_ccl_query = vc
       3 synoptic_xml_query = vc
       3 synoptic_ccl_long_text_id = f8
       3 synoptic_xml_long_text_id = f8
       3 synoptic_updt_cnt = i4
     2 org_qual[*]
       3 organization_id = f8
       3 filter_entity1_id = f8
       3 organization_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp_prefix(
   1 qual[*]
     2 prefix_id = f8
     2 prefix_name = c40
     2 formatted_prefix = vc
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
 DECLARE site_format = c5 WITH protect, constant("00000")
 DECLARE site_display = c40 WITH protect, noconstant(" ")
 DECLARE max_params = i4 WITH protect, noconstant(0)
 DECLARE dtemplatefiltertype = f8 WITH protect, noconstant(0.0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE ap_alpha_source_vocab_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",400,
   "ANATOMIC PAT"))
 SET reply->status_data.status = "F"
 SET dynamic_where = fillstring(50," ")
 SET max_cnt = 0
 SET max_param_cnt = 0
 SET param_cnt = 0
 SET cnt = 0
 SET dtemplatefiltertype = uar_get_code_by("MEANING",30620,"CS14252")
 IF (dtemplatefiltertype <= 0)
  CALL subevent_add("UAR","F","UAR_GET_CODE_BY","30620_CS14252")
  GO TO exit_script
 ENDIF
 IF ((request->query_cd > 0))
  SET dynamic_where = build("cv.code_value = ",request->query_cd)
 ELSE
  SET dynamic_where = "cv.code_set = 14252"
 ENDIF
 SELECT INTO "nl:"
  cv.code_value, cv2.code_value, adqp.query_cd,
  n.nomenclature_id, n2.nomenclature_id, p.person_id,
  ap.prefix_id, o.organization_id, apcq.case_query_id,
  lt.long_text_id, lt2.long_text_id, lt3.long_text_id
  FROM code_value cv,
   code_value cv2,
   ap_diag_query_param adqp,
   long_text lt,
   long_text lt2,
   long_text lt3,
   nomenclature n,
   nomenclature n2,
   prsnl p,
   ap_prefix ap,
   organization o,
   ap_case_query apcq,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   (dummyt d4  WITH seq = 1),
   (dummyt d5  WITH seq = 1),
   (dummyt d6  WITH seq = 1)
  PLAN (cv
   WHERE parser(dynamic_where))
   JOIN (adqp
   WHERE adqp.query_cd=cv.code_value)
   JOIN (lt
   WHERE lt.long_text_id=adqp.freetext_long_text_id)
   JOIN (lt2
   WHERE lt2.long_text_id=adqp.synoptic_ccl_long_text_id)
   JOIN (lt3
   WHERE lt3.long_text_id=adqp.synoptic_xml_long_text_id)
   JOIN (d6
   WHERE d6.seq=1)
   JOIN (cv2
   WHERE cv2.code_value=adqp.beg_value_id
    AND adqp.param_name IN ("PATIENT_ETHNICGROUP", "PATIENT_GENDER", "PATIENT_RACE",
   "PATIENT_SPECIES", "PATIENT_MILITARY",
   "CASE_CASETYPE", "CASE_TASKASSAY", "CASE_IMAGETASKASSAY", "CASE_SPECIMEN"))
   JOIN (d5
   WHERE d5.seq=1)
   JOIN (ap
   WHERE ap.prefix_id=adqp.beg_value_id
    AND adqp.param_name="CASE_ACCPREFIX")
   JOIN (d4
   WHERE d4.seq=1)
   JOIN (p
   WHERE p.person_id=adqp.beg_value_id
    AND adqp.param_name IN ("CASE_VERID", "CASE_REQPHYS", "CASE_RESPPATH", "CASE_RESPRESI"))
   JOIN (d3
   WHERE d3.seq=1)
   JOIN (n
   WHERE n.nomenclature_id=adqp.beg_value_id
    AND adqp.criteria_type_flag=3)
   JOIN (n2
   WHERE n2.nomenclature_id=adqp.end_value_id
    AND adqp.criteria_type_flag=3)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (o
   WHERE o.organization_id=adqp.beg_value_id
    AND adqp.param_name="CASE_CLIENT")
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (apcq
   WHERE apcq.case_query_id=adqp.beg_value_id
    AND adqp.param_name="CASE_QUERYRESULT")
  ORDER BY cv.code_value
  HEAD REPORT
   max_cnt = 10, cnt = 0, max_params = 0,
   temp_cnt = 0, add_ind = 0
  HEAD cv.code_value
   cnt = (cnt+ 1), max_param_cnt = 10, param_cnt = 0
   IF (cnt > max_cnt)
    stat = alter(reply->qual,(cnt+ 10)), max_cnt = (cnt+ 10)
   ENDIF
   stat = alterlist(reply->qual[cnt].param_qual,(param_cnt+ 10))
  DETAIL
   param_cnt = (param_cnt+ 1)
   IF (param_cnt > max_param_cnt)
    stat = alterlist(reply->qual[cnt].param_qual,(param_cnt+ 10)), max_param_cnt = (param_cnt+ 10)
   ENDIF
   reply->qual[cnt].query_cd = cv.code_value, reply->qual[cnt].code_value_updt_cnt = cv.updt_cnt,
   reply->qual[cnt].param_qual[param_cnt].query_param_id = adqp.query_param_id,
   reply->qual[cnt].param_qual[param_cnt].param_name = adqp.param_name, reply->qual[cnt].param_qual[
   param_cnt].criteria_type_flag = adqp.criteria_type_flag, reply->qual[cnt].param_qual[param_cnt].
   date_type_flag = adqp.date_type_flag,
   reply->qual[cnt].param_qual[param_cnt].beg_value_id = adqp.beg_value_id, reply->qual[cnt].
   param_qual[param_cnt].beg_value_dt_tm = adqp.beg_value_dt_tm, reply->qual[cnt].param_qual[
   param_cnt].end_value_id = adqp.end_value_id,
   reply->qual[cnt].param_qual[param_cnt].end_value_dt_tm = adqp.end_value_dt_tm, reply->qual[cnt].
   param_qual[param_cnt].negation_ind = adqp.negation_ind, reply->qual[cnt].param_qual[param_cnt].
   source_vocabulary_cd = adqp.source_vocabulary_cd,
   reply->qual[cnt].param_qual[param_cnt].updt_cnt = adqp.updt_cnt, reply->qual[cnt].param_qual[
   param_cnt].sequence = adqp.sequence, reply->qual[cnt].param_qual[param_cnt].freetext_query_flag =
   adqp.freetext_query_flag,
   reply->qual[cnt].param_qual[param_cnt].synoptic_query_flag = adqp.synoptic_query_flag
   IF (adqp.freetext_long_text_id != 0.0)
    reply->qual[cnt].param_qual[param_cnt].freetext_query = lt.long_text, reply->qual[cnt].
    param_qual[param_cnt].freetext_long_text_id = lt.long_text_id, reply->qual[cnt].param_qual[
    param_cnt].freetext_updt_cnt = lt.updt_cnt
   ENDIF
   IF (adqp.synoptic_ccl_long_text_id != 0.0
    AND adqp.synoptic_xml_long_text_id != 0.0)
    reply->qual[cnt].param_qual[param_cnt].synoptic_ccl_query = lt2.long_text, reply->qual[cnt].
    param_qual[param_cnt].synoptic_ccl_long_text_id = lt2.long_text_id, reply->qual[cnt].param_qual[
    param_cnt].synoptic_xml_query = lt3.long_text,
    reply->qual[cnt].param_qual[param_cnt].synoptic_xml_long_text_id = lt3.long_text_id, reply->qual[
    cnt].param_qual[param_cnt].synoptic_updt_cnt = lt3.updt_cnt
   ENDIF
   IF ((reply->qual[cnt].param_qual[param_cnt].criteria_type_flag=3))
    IF ((reply->qual[cnt].param_qual[param_cnt].source_vocabulary_cd=ap_alpha_source_vocab_cd))
     reply->qual[cnt].param_qual[param_cnt].beg_value_disp = n.source_string, reply->qual[cnt].
     param_qual[param_cnt].end_value_disp = n2.source_string
    ELSE
     reply->qual[cnt].param_qual[param_cnt].beg_value_disp = n.source_identifier, reply->qual[cnt].
     param_qual[param_cnt].end_value_disp = n2.source_identifier
    ENDIF
   ELSEIF ((reply->qual[cnt].param_qual[param_cnt].param_name IN ("PATIENT_ETHNICGROUP",
   "PATIENT_GENDER", "PATIENT_RACE", "PATIENT_SPECIES", "PATIENT_MILITARY",
   "CASE_CASETYPE", "CASE_TASKASSAY", "CASE_IMAGETASKASSAY")))
    reply->qual[cnt].param_qual[param_cnt].beg_value_disp = cv2.display
   ELSEIF ((reply->qual[cnt].param_qual[param_cnt].param_name="CASE_ACCPREFIX"))
    add_ind = 1
    IF (temp_cnt > 0)
     FOR (i = 1 TO temp_cnt)
       IF ((temp_prefix->qual[i].prefix_id=ap.prefix_id))
        add_ind = 0, i = (temp_cnt+ 1)
       ENDIF
     ENDFOR
    ENDIF
    IF (add_ind=1)
     temp_cnt = (temp_cnt+ 1), stat = alterlist(temp_prefix->qual,temp_cnt), temp_prefix->qual[
     temp_cnt].prefix_id = ap.prefix_id,
     temp_prefix->qual[temp_cnt].prefix_name = ap.prefix_name
    ENDIF
   ELSEIF ((reply->qual[cnt].param_qual[param_cnt].param_name IN ("CASE_VERID", "CASE_REQPHYS",
   "CASE_RESPPATH", "CASE_RESPRESI")))
    reply->qual[cnt].param_qual[param_cnt].beg_value_disp = p.name_full_formatted
   ELSEIF ((reply->qual[cnt].param_qual[param_cnt].param_name="CASE_SPECIMEN"))
    reply->qual[cnt].param_qual[param_cnt].beg_value_disp = cv2.description
   ELSEIF ((reply->qual[cnt].param_qual[param_cnt].param_name="CASE_CLIENT"))
    reply->qual[cnt].param_qual[param_cnt].beg_value_disp = o.org_name
   ELSEIF ((reply->qual[cnt].param_qual[param_cnt].param_name="CASE_QUERYRESULT"))
    reply->qual[cnt].param_qual[param_cnt].beg_value_disp = apcq.result_name
   ENDIF
  FOOT  cv.code_value
   stat = alterlist(reply->qual[cnt].param_qual,param_cnt)
   IF (param_cnt > max_params)
    max_params = param_cnt
   ENDIF
  FOOT REPORT
   stat = alter(reply->qual,cnt)
  WITH nocounter, outerjoin = d1, outerjoin = d2,
   outerjoin = d3, dontcare = p, outerjoin = d4,
   dontcare = ap, outerjoin = d5, dontcare = cv2,
   dontcare = n, dontcare = n2, dontcare = o,
   outerjoin = apcq
 ;end select
 IF (size(temp_prefix->qual,5) > 0)
  EXECUTE accession_settings
  IF (accession_status != acc_success)
   SET acc_settings->site_code_length = 5
  ENDIF
  SELECT INTO "nl:"
   d.seq, site_unformatted = uar_get_code_display(a.site_cd)
   FROM (dummyt d  WITH seq = value(size(temp_prefix->qual,5))),
    ap_prefix a
   PLAN (d)
    JOIN (a
    WHERE (temp_prefix->qual[d.seq].prefix_id=a.prefix_id))
   DETAIL
    IF (cnvtint(site_unformatted) != 0)
     IF ((acc_settings->site_code_length > textlen(trim(cnvtstring(site_unformatted)))))
      site_display = build(substring(1,(acc_settings->site_code_length - textlen(trim(cnvtstring(
           cnvtint(site_unformatted))))),site_format),cnvtint(site_unformatted))
     ELSE
      site_display = cnvtstring(site_unformatted)
     ENDIF
    ELSE
     site_display = " "
    ENDIF
    temp_prefix->qual[d.seq].formatted_prefix = concat(trim(site_display),trim(temp_prefix->qual[d
      .seq].prefix_name))
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(reply->qual,5))),
    (dummyt d2  WITH seq = value(max_params)),
    (dummyt d3  WITH seq = value(size(temp_prefix->qual,5)))
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(reply->qual[d1.seq].param_qual,5)
     AND (reply->qual[d1.seq].param_qual[d2.seq].param_name="CASE_ACCPREFIX"))
    JOIN (d3
    WHERE (reply->qual[d1.seq].param_qual[d2.seq].beg_value_id=temp_prefix->qual[d3.seq].prefix_id))
   DETAIL
    reply->qual[d1.seq].param_qual[d2.seq].beg_value_disp = temp_prefix->qual[d3.seq].
    formatted_prefix
   WITH nocounter
  ;end select
 ENDIF
 FREE SET temp_prefix
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_DIAG_QUERY_PARAM"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  o.org_name, f.filter_entity1_id
  FROM organization o,
   filter_entity_reltn f
  PLAN (f
   WHERE (f.parent_entity_id=request->query_cd)
    AND f.parent_entity_name="CODE_VALUE"
    AND cnvtdatetime(curdate,curtime3) BETWEEN f.beg_effective_dt_tm AND f.end_effective_dt_tm
    AND f.filter_type_cd=dtemplatefiltertype
    AND f.filter_entity1_name="ORGANIZATION")
   JOIN (o
   WHERE f.filter_entity1_id=o.organization_id
    AND o.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN o.beg_effective_dt_tm AND o.end_effective_dt_tm)
  DETAIL
   lcnt = (lcnt+ 1)
   IF (mod(lcnt,10)=1)
    stat = alterlist(reply->qual[cnt].org_qual,(lcnt+ 9))
   ENDIF
   reply->qual[cnt].org_qual[lcnt].organization_id = f.filter_entity1_id, reply->qual[cnt].org_qual[
   lcnt].filter_entity1_id = f.filter_entity_reltn_id, reply->qual[cnt].org_qual[lcnt].
   organization_name = o.org_name
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual[cnt].org_qual,lcnt)
#exit_script
END GO
