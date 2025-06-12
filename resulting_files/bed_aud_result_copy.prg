CREATE PROGRAM bed_aud_result_copy
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
 RECORD temp(
   1 relationships[*]
     2 trans_cat = vc
     2 source_event_cd = f8
     2 source_event_disp = vc
     2 assoc_ident = vc
     2 target_event_cd = f8
     2 target_event_disp = vc
     2 source_assays[*]
       3 code_value = f8
       3 description = vc
       3 result_type = vc
       3 alpha_responses[*]
         4 description = vc
     2 target_assays[*]
       3 code_value = f8
       3 description = vc
       3 result_type = vc
       3 alpha_responses[*]
         4 description = vc
 )
 RECORD temp2(
   1 relationships[*]
     2 trans_cat = vc
     2 source_event_disp = vc
     2 assoc_ident = vc
     2 target_event_disp = vc
     2 source_assays[*]
       3 description = vc
       3 result_type = vc
       3 alpha_response = vc
     2 target_assays[*]
       3 description = vc
       3 result_type = vc
       3 alpha_response = vc
 )
 SET rcnt = 0
 SELECT INTO "nl:"
  FROM dcp_cf_trans_cat_reltn d1,
   dcp_cf_trans_cat dcat,
   dcp_cf_trans_event_cd_r d2,
   code_value cv,
   v500_event_code v1,
   v500_event_code v2
  PLAN (d1
   WHERE d1.active_ind=1)
   JOIN (dcat
   WHERE dcat.dcp_cf_trans_cat_id=d1.dcp_cf_trans_cat_id
    AND dcat.active_ind=1)
   JOIN (d2
   WHERE d2.dcp_cf_trans_event_cd_r_id=d1.dcp_cf_trans_event_cd_r_id
    AND d2.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=d2.association_identifier_cd
    AND cv.active_ind=1)
   JOIN (v1
   WHERE v1.event_cd=d2.source_event_cd)
   JOIN (v2
   WHERE v2.event_cd=d2.target_event_cd)
  ORDER BY cnvtupper(dcat.cf_category_name), d1.reltn_sequence
  DETAIL
   rcnt = (rcnt+ 1), stat = alterlist(temp->relationships,rcnt), temp->relationships[rcnt].trans_cat
    = dcat.cf_category_name,
   temp->relationships[rcnt].source_event_cd = d2.source_event_cd, temp->relationships[rcnt].
   source_event_disp = v1.event_cd_disp, temp->relationships[rcnt].assoc_ident = cv.display,
   temp->relationships[rcnt].target_event_cd = d2.target_event_cd, temp->relationships[rcnt].
   target_event_disp = v2.event_cd_disp
  WITH nocounter
 ;end select
 IF (rcnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = rcnt),
   discrete_task_assay dta,
   code_value cv,
   reference_range_factor rrf,
   alpha_responses ar,
   nomenclature n
  PLAN (d)
   JOIN (dta
   WHERE (dta.event_cd=temp->relationships[d.seq].source_event_cd)
    AND dta.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=dta.default_result_type_cd
    AND cv.active_ind=1)
   JOIN (rrf
   WHERE rrf.task_assay_cd=outerjoin(dta.task_assay_cd)
    AND rrf.active_ind=outerjoin(1))
   JOIN (ar
   WHERE ar.reference_range_factor_id=outerjoin(rrf.reference_range_factor_id)
    AND ar.active_ind=outerjoin(1))
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(ar.nomenclature_id)
    AND n.active_ind=outerjoin(1))
  ORDER BY d.seq, dta.description, dta.task_assay_cd,
   ar.sequence
  HEAD d.seq
   acnt = 0
  HEAD dta.task_assay_cd
   acnt = (acnt+ 1), stat = alterlist(temp->relationships[d.seq].source_assays,acnt), temp->
   relationships[d.seq].source_assays[acnt].code_value = dta.task_assay_cd,
   temp->relationships[d.seq].source_assays[acnt].description = dta.description, temp->relationships[
   d.seq].source_assays[acnt].result_type = cv.display, arcnt = 0
  DETAIL
   IF (ar.reference_range_factor_id > 0
    AND n.source_string > " ")
    arcnt = (arcnt+ 1), stat = alterlist(temp->relationships[d.seq].source_assays[acnt].
     alpha_responses,arcnt), temp->relationships[d.seq].source_assays[acnt].alpha_responses[arcnt].
    description = n.source_string
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = rcnt),
   discrete_task_assay dta,
   code_value cv,
   reference_range_factor rrf,
   alpha_responses ar,
   nomenclature n
  PLAN (d)
   JOIN (dta
   WHERE (dta.event_cd=temp->relationships[d.seq].target_event_cd)
    AND dta.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=dta.default_result_type_cd
    AND cv.active_ind=1)
   JOIN (rrf
   WHERE rrf.task_assay_cd=outerjoin(dta.task_assay_cd)
    AND rrf.active_ind=outerjoin(1))
   JOIN (ar
   WHERE ar.reference_range_factor_id=outerjoin(rrf.reference_range_factor_id)
    AND ar.active_ind=outerjoin(1))
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(ar.nomenclature_id)
    AND n.active_ind=outerjoin(1))
  ORDER BY d.seq, dta.description, dta.task_assay_cd,
   ar.sequence
  HEAD d.seq
   acnt = 0
  HEAD dta.task_assay_cd
   acnt = (acnt+ 1), stat = alterlist(temp->relationships[d.seq].target_assays,acnt), temp->
   relationships[d.seq].target_assays[acnt].code_value = dta.task_assay_cd,
   temp->relationships[d.seq].target_assays[acnt].description = dta.description, temp->relationships[
   d.seq].target_assays[acnt].result_type = cv.display, arcnt = 0
  DETAIL
   IF (ar.reference_range_factor_id > 0
    AND n.source_string > " ")
    arcnt = (arcnt+ 1), stat = alterlist(temp->relationships[d.seq].target_assays[acnt].
     alpha_responses,arcnt), temp->relationships[d.seq].target_assays[acnt].alpha_responses[arcnt].
    description = n.source_string
   ENDIF
  WITH nocounter
 ;end select
 SET total_rows = 0
 SET stat = alterlist(temp2->relationships,rcnt)
 FOR (r = 1 TO rcnt)
   SET temp2->relationships[r].trans_cat = temp->relationships[r].trans_cat
   SET temp2->relationships[r].source_event_disp = temp->relationships[r].source_event_disp
   SET temp2->relationships[r].assoc_ident = temp->relationships[r].assoc_ident
   SET temp2->relationships[r].target_event_disp = temp->relationships[r].target_event_disp
   SET temp2_acnt = 0
   SET acnt = size(temp->relationships[r].source_assays,5)
   FOR (a = 1 TO acnt)
    SET arcnt = size(temp->relationships[r].source_assays[a].alpha_responses,5)
    IF (arcnt=0)
     SET total_rows = (total_rows+ 1)
     SET temp2_acnt = (temp2_acnt+ 1)
     SET stat = alterlist(temp2->relationships[r].source_assays,temp2_acnt)
     SET temp2->relationships[r].source_assays[temp2_acnt].description = temp->relationships[r].
     source_assays[a].description
     SET temp2->relationships[r].source_assays[temp2_acnt].result_type = temp->relationships[r].
     source_assays[a].result_type
     SET temp2->relationships[r].source_assays[temp2_acnt].alpha_response = " "
    ELSE
     FOR (ar = 1 TO arcnt)
       SET total_rows = (total_rows+ 1)
       SET temp2_acnt = (temp2_acnt+ 1)
       SET stat = alterlist(temp2->relationships[r].source_assays,temp2_acnt)
       IF (ar=1)
        SET temp2->relationships[r].source_assays[temp2_acnt].description = temp->relationships[r].
        source_assays[a].description
        SET temp2->relationships[r].source_assays[temp2_acnt].result_type = temp->relationships[r].
        source_assays[a].result_type
       ELSE
        SET temp2->relationships[r].source_assays[temp2_acnt].description = " "
        SET temp2->relationships[r].source_assays[temp2_acnt].result_type = " "
       ENDIF
       SET temp2->relationships[r].source_assays[temp2_acnt].alpha_response = temp->relationships[r].
       source_assays[a].alpha_responses[ar].description
     ENDFOR
    ENDIF
   ENDFOR
   SET temp2_acnt = 0
   SET acnt = size(temp->relationships[r].target_assays,5)
   FOR (a = 1 TO acnt)
    SET arcnt = size(temp->relationships[r].target_assays[a].alpha_responses,5)
    IF (arcnt=0)
     SET total_rows = (total_rows+ 1)
     SET temp2_acnt = (temp2_acnt+ 1)
     SET stat = alterlist(temp2->relationships[r].target_assays,temp2_acnt)
     SET temp2->relationships[r].target_assays[temp2_acnt].description = temp->relationships[r].
     target_assays[a].description
     SET temp2->relationships[r].target_assays[temp2_acnt].result_type = temp->relationships[r].
     target_assays[a].result_type
     SET temp2->relationships[r].target_assays[temp2_acnt].alpha_response = " "
    ELSE
     FOR (ar = 1 TO arcnt)
       SET total_rows = (total_rows+ 1)
       SET temp2_acnt = (temp2_acnt+ 1)
       SET stat = alterlist(temp2->relationships[r].target_assays,temp2_acnt)
       IF (ar=1)
        SET temp2->relationships[r].target_assays[temp2_acnt].description = temp->relationships[r].
        target_assays[a].description
        SET temp2->relationships[r].target_assays[temp2_acnt].result_type = temp->relationships[r].
        target_assays[a].result_type
       ELSE
        SET temp2->relationships[r].target_assays[temp2_acnt].description = " "
        SET temp2->relationships[r].target_assays[temp2_acnt].result_type = " "
       ENDIF
       SET temp2->relationships[r].target_assays[temp2_acnt].alpha_response = temp->relationships[r].
       target_assays[a].alpha_responses[ar].description
     ENDFOR
    ENDIF
   ENDFOR
 ENDFOR
 IF ((request->skip_volume_check_ind=0))
  IF (total_rows > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (total_rows > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,10)
 SET reply->collist[1].header_text = "Category"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Source Event Code"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Association Identifier"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Target Event Code"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Source Assay"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Source Assay Result Type"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Source Assay Alpha Responses"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Target Assay"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Target Assay Result Type"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Target Assay Alpha Responses"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET row_nbr = 0
 FOR (r = 1 TO rcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,10)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp2->relationships[r].trans_cat
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp2->relationships[r].source_event_disp
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp2->relationships[r].assoc_ident
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp2->relationships[r].target_event_disp
   SET sourcecnt = size(temp2->relationships[r].source_assays,5)
   SET targetcnt = size(temp2->relationships[r].target_assays,5)
   SET t = 0
   IF (sourcecnt > 0)
    FOR (s = 1 TO sourcecnt)
      SET reply->rowlist[row_nbr].celllist[5].string_value = temp2->relationships[r].source_assays[s]
      .description
      SET reply->rowlist[row_nbr].celllist[6].string_value = temp2->relationships[r].source_assays[s]
      .result_type
      SET reply->rowlist[row_nbr].celllist[7].string_value = temp2->relationships[r].source_assays[s]
      .alpha_response
      SET t = (t+ 1)
      IF (((t < targetcnt) OR (t=targetcnt)) )
       SET reply->rowlist[row_nbr].celllist[8].string_value = temp2->relationships[r].target_assays[t
       ].description
       SET reply->rowlist[row_nbr].celllist[9].string_value = temp2->relationships[r].target_assays[t
       ].result_type
       SET reply->rowlist[row_nbr].celllist[10].string_value = temp2->relationships[r].target_assays[
       t].alpha_response
      ENDIF
      IF (s < sourcecnt)
       SET row_nbr = (row_nbr+ 1)
       SET stat = alterlist(reply->rowlist,row_nbr)
       SET stat = alterlist(reply->rowlist[row_nbr].celllist,10)
      ENDIF
    ENDFOR
    IF (t < targetcnt)
     SET t = (t+ 1)
     FOR (t = t TO targetcnt)
       SET row_nbr = (row_nbr+ 1)
       SET stat = alterlist(reply->rowlist,row_nbr)
       SET stat = alterlist(reply->rowlist[row_nbr].celllist,10)
       SET reply->rowlist[row_nbr].celllist[8].string_value = temp2->relationships[r].target_assays[t
       ].description
       SET reply->rowlist[row_nbr].celllist[9].string_value = temp2->relationships[r].target_assays[t
       ].result_type
       SET reply->rowlist[row_nbr].celllist[10].string_value = temp2->relationships[r].target_assays[
       t].alpha_response
     ENDFOR
    ENDIF
   ELSEIF (targetcnt > 0)
    FOR (t = 1 TO targetcnt)
      SET reply->rowlist[row_nbr].celllist[8].string_value = temp2->relationships[r].target_assays[t]
      .description
      SET reply->rowlist[row_nbr].celllist[9].string_value = temp2->relationships[r].target_assays[t]
      .result_type
      SET reply->rowlist[row_nbr].celllist[10].string_value = temp2->relationships[r].target_assays[t
      ].alpha_response
      IF (t < targetcnt)
       SET row_nbr = (row_nbr+ 1)
       SET stat = alterlist(reply->rowlist,row_nbr)
       SET stat = alterlist(reply->rowlist[row_nbr].celllist,10)
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("result_copy.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
