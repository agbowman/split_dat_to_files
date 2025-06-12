CREATE PROGRAM bed_aud_hla_orc_dta:dba
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
   1 ocnt = i2
   1 oqual[*]
     2 activity_type = vc
     2 activity_subtype = vc
     2 ord = vc
     2 catalog_cd = f8
     2 mnemonic = vc
     2 dept_name = vc
     2 dcnt = i2
     2 dqual[*]
       3 mnemonic = vc
       3 dta_cd = f8
       3 description = vc
       3 pending = vc
       3 item = vc
       3 post_prompt = vc
       3 restrict_display = vc
       3 sequence = vc
       3 result_type = vc
 )
 DECLARE lab = f8 WITH public, noconstant(0.0)
 DECLARE hla = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="GENERAL LAB"
    AND cv.active_ind=1)
  DETAIL
   lab = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="HLA"
    AND cv.active_ind=1)
  DETAIL
   hla = cv.code_value
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM order_catalog oc
   PLAN (oc
    WHERE oc.catalog_type_cd=lab
     AND oc.activity_type_cd=hla
     AND oc.active_ind=1)
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
 SET dcnt = 0
 SET ocnt = 0
 SELECT INTO "nl:"
  FROM order_catalog oc,
   code_value cv,
   code_value cv2,
   profile_task_r ptr,
   discrete_task_assay dta,
   code_value cv3
  PLAN (oc
   WHERE oc.catalog_type_cd=lab
    AND oc.activity_type_cd=hla
    AND  NOT (oc.orderable_type_flag IN (2, 6))
    AND oc.active_ind=1
    AND oc.bill_only_ind IN (0, null))
   JOIN (cv
   WHERE cv.code_value=oc.activity_type_cd
    AND cv.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=oc.activity_subtype_cd)
   JOIN (ptr
   WHERE ptr.catalog_cd=outerjoin(oc.catalog_cd)
    AND ptr.active_ind=outerjoin(1))
   JOIN (dta
   WHERE dta.task_assay_cd=outerjoin(ptr.task_assay_cd)
    AND dta.active_ind=outerjoin(1))
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(dta.default_result_type_cd)
    AND cv3.active_ind=outerjoin(1))
  ORDER BY cnvtupper(oc.primary_mnemonic), ptr.sequence
  HEAD oc.catalog_cd
   dcnt = 0, ocnt = (ocnt+ 1), temp->ocnt = ocnt,
   stat = alterlist(temp->oqual,ocnt), temp->oqual[ocnt].activity_type = cv.display, temp->oqual[ocnt
   ].activity_subtype = cv2.display,
   temp->oqual[ocnt].ord = oc.description, temp->oqual[ocnt].mnemonic = oc.primary_mnemonic, temp->
   oqual[ocnt].dept_name = oc.dept_display_name,
   temp->oqual[ocnt].catalog_cd = oc.catalog_cd, temp->oqual[ocnt].dcnt = 0
  DETAIL
   IF (dta.task_assay_cd > 0)
    dcnt = (dcnt+ 1), temp->oqual[ocnt].dcnt = dcnt, stat = alterlist(temp->oqual[ocnt].dqual,dcnt),
    temp->oqual[ocnt].dqual[dcnt].mnemonic = dta.mnemonic, temp->oqual[ocnt].dqual[dcnt].dta_cd = dta
    .task_assay_cd, temp->oqual[ocnt].dqual[dcnt].description = dta.description
    IF (ptr.pending_ind=1)
     temp->oqual[ocnt].dqual[dcnt].pending = "Yes"
    ELSE
     temp->oqual[ocnt].dqual[dcnt].pending = "No"
    ENDIF
    IF (ptr.item_type_flag=1)
     temp->oqual[ocnt].dqual[dcnt].item = "X"
    ENDIF
    IF (ptr.post_prompt_ind=1)
     temp->oqual[ocnt].dqual[dcnt].post_prompt = "X"
    ENDIF
    IF (ptr.restrict_display_ind=1)
     temp->oqual[ocnt].dqual[dcnt].restrict_display = "X"
    ENDIF
    temp->oqual[ocnt].dqual[dcnt].result_type = cv3.description, temp->oqual[ocnt].dqual[dcnt].
    sequence = cnvtstring(ptr.sequence)
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,14)
 SET reply->collist[1].header_text = "Activity Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 1
 SET reply->collist[2].header_text = "Millennium Name (Primary Synonym)"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Department Name (Label Display)"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Assay Display"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Assay Description"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Default Result Type"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Required"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Sequence"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Prompt"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Post Prompt"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Restrict Display"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Subactivity Type"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "catalog_cd"
 SET reply->collist[13].data_type = 2
 SET reply->collist[13].hide_ind = 1
 SET reply->collist[14].header_text = "task_assay_cd"
 SET reply->collist[14].data_type = 2
 SET reply->collist[14].hide_ind = 1
 IF (ocnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO temp->ocnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,14)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->oqual[x].activity_type
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->oqual[x].mnemonic
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->oqual[x].dept_name
   SET reply->rowlist[row_nbr].celllist[12].string_value = temp->oqual[x].activity_subtype
   SET reply->rowlist[row_nbr].celllist[13].double_value = temp->oqual[x].catalog_cd
   FOR (y = 1 TO temp->oqual[x].dcnt)
     IF (y > 1)
      SET row_nbr = (row_nbr+ 1)
      SET stat = alterlist(reply->rowlist,row_nbr)
      SET stat = alterlist(reply->rowlist[row_nbr].celllist,14)
     ENDIF
     SET reply->rowlist[row_nbr].celllist[1].string_value = temp->oqual[x].activity_type
     SET reply->rowlist[row_nbr].celllist[2].string_value = temp->oqual[x].mnemonic
     SET reply->rowlist[row_nbr].celllist[4].string_value = temp->oqual[x].dqual[y].mnemonic
     SET reply->rowlist[row_nbr].celllist[5].string_value = temp->oqual[x].dqual[y].description
     SET reply->rowlist[row_nbr].celllist[7].string_value = temp->oqual[x].dqual[y].pending
     SET reply->rowlist[row_nbr].celllist[8].string_value = temp->oqual[x].dqual[y].sequence
     SET reply->rowlist[row_nbr].celllist[9].string_value = temp->oqual[x].dqual[y].item
     SET reply->rowlist[row_nbr].celllist[10].string_value = temp->oqual[x].dqual[y].post_prompt
     SET reply->rowlist[row_nbr].celllist[11].string_value = temp->oqual[x].dqual[y].restrict_display
     SET reply->rowlist[row_nbr].celllist[6].string_value = temp->oqual[x].dqual[y].result_type
     SET reply->rowlist[row_nbr].celllist[3].string_value = temp->oqual[x].dept_name
     SET reply->rowlist[row_nbr].celllist[12].string_value = temp->oqual[x].activity_subtype
     SET reply->rowlist[row_nbr].celllist[13].double_value = temp->oqual[x].catalog_cd
     SET reply->rowlist[row_nbr].celllist[14].double_value = temp->oqual[x].dqual[y].dta_cd
   ENDFOR
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("hla_orc_dta_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
