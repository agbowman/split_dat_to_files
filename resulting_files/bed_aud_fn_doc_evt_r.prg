CREATE PROGRAM bed_aud_fn_doc_evt_r
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
 DECLARE powerform_cd = f8
 DECLARE powernote_cd = f8
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "Tracking Group"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Document Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Document Name"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Tracking Event"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Last Update By"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=20504
   AND cv.cdf_meaning="POWERFORM"
  DETAIL
   powerform_cd = cv.code_value
  WITH nocounter, noheading
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=20504
   AND cv.cdf_meaning="POWERNOTE"
  DETAIL
   powernote_cd = cv.code_value
  WITH nocounter, noheading
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM code_value cv,
    track_ord_event_reltn toer
   PLAN (cv
    WHERE cv.code_set=16370
     AND cv.active_ind=1
     AND cv.cdf_meaning="ER")
    JOIN (toer
    WHERE toer.track_group_cd=cv.code_value
     AND toer.association_type_cd IN (powerform_cd, powernote_cd))
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
  ELSEIF (high_volume_cnt=0)
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv,
   track_ord_event_reltn toer,
   track_event te,
   prsnl p
  PLAN (cv
   WHERE cv.code_set=16370
    AND cv.active_ind=1
    AND cv.cdf_meaning="ER")
   JOIN (toer
   WHERE toer.track_group_cd=cv.code_value
    AND toer.association_type_cd IN (powerform_cd, powernote_cd))
   JOIN (te
   WHERE te.track_event_id=toer.track_event_id
    AND te.tracking_group_cd=toer.track_group_cd
    AND te.active_ind=1)
   JOIN (p
   WHERE p.person_id=toer.updt_id)
  ORDER BY cv.display, te.display
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,25)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,25)=0)
    stat = alterlist(reply->rowlist,(25+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,5), reply->rowlist[cnt].celllist[1].string_value =
   cv.display, reply->rowlist[cnt].celllist[2].double_value = toer.association_type_cd
   CASE (toer.association_type_cd)
    OF powerform_cd:
     reply->rowlist[cnt].celllist[2].string_value = "Power Form"
    OF powernote_cd:
     reply->rowlist[cnt].celllist[2].string_value = "PowerNote"
   ENDCASE
   reply->rowlist[cnt].celllist[3].double_value = toer.cat_or_cattype_cd, reply->rowlist[cnt].
   celllist[4].string_value = te.display, reply->rowlist[cnt].celllist[5].string_value = p
   .name_full_formatted
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH noheading, nocounter, outerjoin = d
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(reply->rowlist,5))),
   dcp_forms_ref dfr
  PLAN (d
   WHERE (reply->rowlist[d.seq].celllist[2].double_value=powerform_cd))
   JOIN (dfr
   WHERE (dfr.dcp_forms_ref_id=reply->rowlist[d.seq].celllist[3].double_value)
    AND dfr.active_ind=1)
  DETAIL
   reply->rowlist[d.seq].celllist[3].string_value = dfr.description
  WITH noheading, nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(reply->rowlist,5))),
   code_value cv
  PLAN (d
   WHERE (reply->rowlist[d.seq].celllist[2].double_value=powernote_cd))
   JOIN (cv
   WHERE (cv.code_value=reply->rowlist[d.seq].celllist[3].double_value))
  DETAIL
   reply->rowlist[d.seq].celllist[3].string_value = cv.display
  WITH noheading, nocounter
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("firstnet_document_event_association.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
