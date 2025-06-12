CREATE PROGRAM bed_aud_rad_assoc_templates
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
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM rad_template_group rtg
   PLAN (rtg
    WHERE rtg.template_group_id > 0)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 15000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,11)
 SET reply->collist[1].header_text = "person_id"
 SET reply->collist[1].data_type = 2
 SET reply->collist[1].hide_ind = 1
 SET reply->collist[2].header_text = "Radiologist/Resident"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "catalog_cd"
 SET reply->collist[3].data_type = 2
 SET reply->collist[3].hide_ind = 1
 SET reply->collist[4].header_text = "Procedure"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "template_group_id"
 SET reply->collist[5].data_type = 2
 SET reply->collist[5].hide_ind = 1
 SET reply->collist[6].header_text = "Template Group Name"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "template_id"
 SET reply->collist[7].data_type = 2
 SET reply->collist[7].hide_ind = 1
 SET reply->collist[8].header_text = "Template Name"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Modification Required"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Assessment"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Recommendation"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SELECT INTO "NL:"
  oc.catalog_cd, oc.primary_mnemonic, rtg.template_group_id,
  rtg.group_desc, wt.template_id, wt.short_desc
  FROM rad_template_group rtg,
   rad_template_assoc rta,
   order_catalog oc,
   prsnl p,
   wp_template wt,
   rad_fol_up_field rfup1,
   rad_fol_up_field rfup2
  PLAN (rtg
   WHERE rtg.template_group_id > 0)
   JOIN (rta
   WHERE rta.template_group_id=rtg.template_group_id)
   JOIN (oc
   WHERE oc.catalog_cd=rtg.catalog_cd
    AND oc.active_ind=1)
   JOIN (wt
   WHERE wt.template_id=rta.template_id
    AND wt.active_ind=1)
   JOIN (rfup1
   WHERE rfup1.follow_up_field_id=outerjoin(rtg.assessment_id)
    AND rfup1.active_ind=outerjoin(1))
   JOIN (rfup2
   WHERE rfup2.follow_up_field_id=outerjoin(rtg.recommendation_id)
    AND rfup2.active_ind=outerjoin(1))
   JOIN (p
   WHERE p.person_id=outerjoin(rtg.person_id)
    AND p.active_ind=outerjoin(1))
  ORDER BY oc.primary_mnemonic
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=0)
    stat = alterlist(reply->rowlist,(10+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,11), reply->rowlist[cnt].celllist[1].double_value =
   p.person_id
   IF (p.person_id > 0)
    reply->rowlist[cnt].celllist[2].string_value = p.name_full_formatted
   ELSE
    reply->rowlist[cnt].celllist[2].string_value = "All"
   ENDIF
   reply->rowlist[cnt].celllist[3].double_value = oc.catalog_cd, reply->rowlist[cnt].celllist[4].
   string_value = oc.primary_mnemonic, reply->rowlist[cnt].celllist[5].double_value = rtg
   .template_group_id,
   reply->rowlist[cnt].celllist[6].string_value = rtg.group_desc, reply->rowlist[cnt].celllist[7].
   double_value = wt.template_id, reply->rowlist[cnt].celllist[8].string_value = wt.short_desc
   CASE (rtg.mod_text_flag)
    OF 0:
     reply->rowlist[cnt].celllist[9].string_value = "No"
    OF 1:
     reply->rowlist[cnt].celllist[9].string_value = "Yes"
   ENDCASE
   reply->rowlist[cnt].celllist[10].string_value = rfup1.field_description, reply->rowlist[cnt].
   celllist[11].string_value = rfup2.field_description
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("radnet_template_association.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
