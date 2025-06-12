CREATE PROGRAM bed_aud_ap_alpha_responses:dba
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
 FREE RECORD temp
 RECORD temp(
   1 tcnt = i2
   1 tqual[*]
     2 assay_display = vc
     2 alpha_response = vc
 )
 DECLARE apsourcevocab = f8 WITH public, noconstant(0.0)
 DECLARE alpharesp = f8 WITH public, noconstant(0.0)
 DECLARE ap = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=400
    AND cv.cdf_meaning="ANATOMIC PAT"
    AND cv.active_ind=1)
  DETAIL
   apsourcevocab = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=401
    AND cv.cdf_meaning="ALPHA RESPON"
    AND cv.active_ind=1)
  DETAIL
   alpharesp = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="AP"
    AND cv.active_ind=1)
  DETAIL
   ap = cv.code_value
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM nomenclature n,
    alpha_responses a,
    reference_range_factor r,
    discrete_task_assay d
   PLAN (n
    WHERE n.source_vocabulary_cd=apsourcevocab
     AND n.principle_type_cd=alpharesp
     AND n.active_ind=1)
    JOIN (a
    WHERE a.nomenclature_id=n.nomenclature_id
     AND a.active_ind=1)
    JOIN (r
    WHERE r.reference_range_factor_id=a.reference_range_factor_id
     AND r.active_ind=1)
    JOIN (d
    WHERE d.task_assay_cd=r.task_assay_cd
     AND d.activity_type_cd=ap
     AND d.active_ind=1)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE last_assay = vc
 SET last_assay = " "
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM nomenclature n,
   alpha_responses a,
   reference_range_factor r,
   discrete_task_assay d,
   code_value cv1
  PLAN (n
   WHERE n.source_vocabulary_cd=apsourcevocab
    AND n.principle_type_cd=alpharesp
    AND n.active_ind=1)
   JOIN (a
   WHERE a.nomenclature_id=n.nomenclature_id
    AND a.active_ind=1)
   JOIN (r
   WHERE r.reference_range_factor_id=a.reference_range_factor_id
    AND r.active_ind=1)
   JOIN (d
   WHERE d.task_assay_cd=r.task_assay_cd
    AND d.activity_type_cd=ap
    AND d.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=d.task_assay_cd
    AND cv1.active_ind=1)
  ORDER BY cv1.display, n.mnemonic
  DETAIL
   tcnt = (tcnt+ 1), temp->tcnt = tcnt, stat = alterlist(temp->tqual,tcnt)
   IF (cv1.display != last_assay)
    last_assay = cv1.display, temp->tqual[tcnt].assay_display = cv1.display
   ELSE
    temp->tqual[tcnt].assay_display = " "
   ENDIF
   temp->tqual[tcnt].alpha_response = n.mnemonic
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,2)
 SET reply->collist[1].header_text = "Assay Display"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Alpha Response"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,2)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].assay_display
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].alpha_response
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("ap_alpha_responses.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
