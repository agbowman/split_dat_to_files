CREATE PROGRAM bed_aud_lab_orc_synonyms:dba
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
     2 subtype = vc
     2 ord = vc
     2 catalog_cd = f8
     2 clin_category = vc
     2 dept = vc
     2 bill_only = vc
     2 dept_only = vc
     2 careset = vc
     2 syncnt = i2
     2 synqual[*]
       3 synonym = vc
       3 synonym_type = vc
       3 format = vc
       3 hide = vc
 )
 DECLARE ord = f8 WITH public, noconstant(0.0)
 DECLARE lab = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6003
    AND cv.cdf_meaning="ORDER"
    AND cv.active_ind=1)
  DETAIL
   ord = cv.code_value
  WITH nocounter
 ;end select
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
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM order_catalog oc
   PLAN (oc
    WHERE oc.catalog_type_cd=lab
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
 SET ocnt = 0
 SET syncnt = 0
 SELECT INTO "nl:"
  FROM order_catalog oc,
   order_entry_format oef,
   code_value cv,
   code_value cv2,
   order_catalog_synonym ocs,
   code_value cv3,
   code_value cv4
  PLAN (oc
   WHERE oc.catalog_type_cd=lab
    AND oc.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=oc.activity_type_cd)
   JOIN (cv2
   WHERE cv2.code_value=oc.activity_subtype_cd)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.active_ind=1)
   JOIN (oef
   WHERE oef.oe_format_id=ocs.oe_format_id
    AND oef.action_type_cd=ord)
   JOIN (cv3
   WHERE cv3.code_value=ocs.mnemonic_type_cd)
   JOIN (cv4
   WHERE cv4.code_value=outerjoin(oc.dcp_clin_cat_cd)
    AND cv4.active_ind=outerjoin(1))
  ORDER BY oc.activity_type_cd, cnvtupper(oc.description), cv3.cdf_meaning DESC
  HEAD oc.description
   syncnt = 0, ocnt = (ocnt+ 1), temp->ocnt = ocnt,
   stat = alterlist(temp->oqual,ocnt), temp->oqual[ocnt].activity_type = cv.description, temp->oqual[
   ocnt].subtype = cv2.description,
   temp->oqual[ocnt].ord = oc.description, temp->oqual[ocnt].catalog_cd = oc.catalog_cd, temp->oqual[
   ocnt].dept = oc.dept_display_name,
   temp->oqual[ocnt].clin_category = cv4.display
   IF (oc.bill_only_ind=1)
    temp->oqual[ocnt].bill_only = "X"
   ENDIF
   IF (oc.orderable_type_flag=5)
    temp->oqual[ocnt].dept_only = "X"
   ENDIF
   IF (oc.orderable_type_flag IN (2, 6))
    temp->oqual[ocnt].careset = "X"
   ENDIF
  HEAD ocs.synonym_id
   syncnt = (syncnt+ 1), temp->oqual[ocnt].syncnt = syncnt, stat = alterlist(temp->oqual[ocnt].
    synqual,syncnt),
   temp->oqual[ocnt].synqual[syncnt].synonym = ocs.mnemonic, temp->oqual[ocnt].synqual[syncnt].
   synonym_type = cv3.display, temp->oqual[ocnt].synqual[syncnt].format = oef.oe_format_name
   IF (ocs.hide_flag=1)
    temp->oqual[ocnt].synqual[syncnt].hide = "X"
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,13)
 SET reply->collist[1].header_text = "Activity Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Orderable Item Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Synonym Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Synonym"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Department Name (Label Display)"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Subactivity Type"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Order Entry Format"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Hide"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Bill Only"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Department Only"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Careset"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Clinical Category"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "catalog_cd"
 SET reply->collist[13].data_type = 2
 SET reply->collist[13].hide_ind = 1
 IF (ocnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (z = 1 TO temp->ocnt)
   FOR (w = 1 TO temp->oqual[z].syncnt)
     SET row_nbr = (row_nbr+ 1)
     SET stat = alterlist(reply->rowlist,row_nbr)
     SET stat = alterlist(reply->rowlist[row_nbr].celllist,13)
     SET reply->rowlist[row_nbr].celllist[1].string_value = temp->oqual[z].activity_type
     SET reply->rowlist[row_nbr].celllist[2].string_value = temp->oqual[z].ord
     SET reply->rowlist[row_nbr].celllist[3].string_value = temp->oqual[z].synqual[w].synonym_type
     SET reply->rowlist[row_nbr].celllist[4].string_value = temp->oqual[z].synqual[w].synonym
     SET reply->rowlist[row_nbr].celllist[5].string_value = temp->oqual[z].dept
     SET reply->rowlist[row_nbr].celllist[6].string_value = temp->oqual[z].subtype
     SET reply->rowlist[row_nbr].celllist[8].string_value = temp->oqual[z].synqual[w].hide
     SET reply->rowlist[row_nbr].celllist[9].string_value = temp->oqual[z].bill_only
     SET reply->rowlist[row_nbr].celllist[10].string_value = temp->oqual[z].dept_only
     SET reply->rowlist[row_nbr].celllist[11].string_value = temp->oqual[z].careset
     SET reply->rowlist[row_nbr].celllist[7].string_value = temp->oqual[z].synqual[w].format
     SET reply->rowlist[row_nbr].celllist[12].string_value = temp->oqual[z].clin_category
     SET reply->rowlist[row_nbr].celllist[13].double_value = temp->oqual[z].catalog_cd
   ENDFOR
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("lab_orc_synonyms_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
