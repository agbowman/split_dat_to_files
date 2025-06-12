CREATE PROGRAM bed_aud_rad_mammo_notif_letter
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 DECLARE study = f8
 DECLARE g_mamm_lett_cd = f8
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM mammo_letter ml
   PLAN (ml
    WHERE ml.recommendation_id > 0)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 500)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 250)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "Assessment"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Recommendation"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Letter"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Default?"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Template Description"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Facility"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SELECT INTO "NL:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning="STUDY"
   AND cv.code_set=14267
   AND cv.active_ind=1
  DETAIL
   study = cv.code_value
  WITH noheading, nocounter
 ;end select
 SELECT INTO "NL:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning="RADMAMLETT"
   AND cv.code_set=30620
   AND cv.active_ind=1
  DETAIL
   g_mamm_lett_cd = cv.code_value
  WITH noheading, nocounter
 ;end select
 SELECT INTO "NL:"
  r3.field_description, r5.field_description, m.description,
  m.default_ind, wp.short_desc, cv.display
  FROM rad_sys_controls rsc,
   rad_fol_up_field r,
   rad_fol_up_field r1,
   rad_fol_up_field r2,
   rad_fol_up_field r3,
   rad_fol_up_field r4,
   rad_fol_up_field r5,
   mammo_letter m,
   mammo_letter_detail mld,
   dummyt d1,
   wp_template wp,
   dummyt d2,
   filter_entity_reltn fer,
   code_value cv
  PLAN (rsc)
   JOIN (r
   WHERE r.edition_nbr=rsc.birads_edition_nbr
    AND r.reference_cd=study
    AND r.parent_id=0.00
    AND r.active_ind=1)
   JOIN (r1
   WHERE r1.parent_id=r.follow_up_field_id
    AND r1.cerner_meaning_str="ACR130"
    AND r1.active_ind=1)
   JOIN (r2
   WHERE r2.parent_id=r1.follow_up_field_id
    AND r2.active_ind=1)
   JOIN (r3
   WHERE r3.parent_id=r2.follow_up_field_id
    AND r3.active_ind=1)
   JOIN (r4
   WHERE r4.parent_id=r3.follow_up_field_id
    AND r4.active_ind=1)
   JOIN (r5
   WHERE r5.parent_id=r4.follow_up_field_id
    AND r5.active_ind=1)
   JOIN (d1)
   JOIN (m
   WHERE m.recommendation_id=r5.follow_up_field_id)
   JOIN (mld
   WHERE mld.letter_id=m.letter_id)
   JOIN (wp
   WHERE wp.template_id=mld.template_id)
   JOIN (d2)
   JOIN (fer
   WHERE fer.filter_type_cd=g_mamm_lett_cd
    AND fer.parent_entity_name="MAMMO_LETTER"
    AND fer.parent_entity_id=m.letter_id
    AND fer.filter_entity1_name="LOCATION")
   JOIN (cv
   WHERE cv.code_value=fer.filter_entity1_id
    AND cv.active_ind=1)
  ORDER BY r.sequence, r2.sequence, r3.sequence,
   r4.sequence, r5.sequence
  HEAD REPORT
   cnt = 0, end_cnt = 0, stat = alterlist(reply->rowlist,10)
  HEAD r3.field_description
   IF (end_cnt=cnt)
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=0)
     stat = alterlist(reply->rowlist,(10+ cnt))
    ENDIF
    stat = alterlist(reply->rowlist[cnt].celllist,6)
   ENDIF
   reply->rowlist[cnt].celllist[1].string_value = r3.field_description
  HEAD r5.field_description
   IF (end_cnt=cnt)
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=0)
     stat = alterlist(reply->rowlist,(10+ cnt))
    ENDIF
    stat = alterlist(reply->rowlist[cnt].celllist,6)
   ENDIF
   reply->rowlist[cnt].celllist[2].string_value = r5.field_description
  HEAD m.description
   IF (end_cnt=cnt)
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=0)
     stat = alterlist(reply->rowlist,(10+ cnt))
    ENDIF
    stat = alterlist(reply->rowlist[cnt].celllist,6)
   ENDIF
   reply->rowlist[cnt].celllist[3].string_value = m.description
   IF (m.description != " ")
    CASE (m.default_ind)
     OF 0:
      reply->rowlist[cnt].celllist[4].string_value = "No"
     OF 1:
      reply->rowlist[cnt].celllist[4].string_value = "Yes"
    ENDCASE
    reply->rowlist[cnt].celllist[5].string_value = wp.short_desc
    IF (cv.display=" ")
     reply->rowlist[cnt].celllist[6].string_value = "All Facilities"
    ELSE
     reply->rowlist[cnt].celllist[6].string_value = cv.display
    ENDIF
   ENDIF
   end_cnt = cnt
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading, outerjoin = d1,
   outerjoin = d2
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("radnet_note_letter_r.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
