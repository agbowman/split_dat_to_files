CREATE PROGRAM bed_aud_med_orc_issues:dba
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
   1 o_cnt = i4
   1 olist[*]
     2 catalog_cd = f8
     2 primary_mnemonic = vc
     2 primary_mnemonic_key_cap = vc
     2 description = vc
     2 description_key_cap = vc
     2 no_ec_ind = i2
     2 no_clin_cat_orc_ind = i2
 )
 SET cpharm = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="PHARMACY"
    AND cv.active_ind=1)
  DETAIL
   cpharm = cv.code_value
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 SELECT INTO "nl:"
  hv_cnt = count(*)
  FROM order_catalog oc
  PLAN (oc
   WHERE oc.catalog_type_cd=cpharm
    AND oc.active_ind=1
    AND oc.orderable_type_flag IN (0, 1, 10))
  DETAIL
   high_volume_cnt = hv_cnt
  WITH nocounter
 ;end select
 CALL echo(high_volume_cnt)
 IF ((request->skip_volume_check_ind=0))
  IF (high_volume_cnt > 20000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET temp->o_cnt = 0
 SELECT INTO "nl:"
  FROM order_catalog oc
  PLAN (oc
   WHERE oc.catalog_type_cd=cpharm
    AND oc.active_ind=1
    AND oc.orderable_type_flag IN (0, 1, 10))
  HEAD REPORT
   o_cnt = 0
  DETAIL
   o_cnt = (o_cnt+ 1), temp->o_cnt = o_cnt, stat = alterlist(temp->olist,o_cnt),
   temp->olist[o_cnt].catalog_cd = oc.catalog_cd, temp->olist[o_cnt].primary_mnemonic = oc
   .primary_mnemonic, temp->olist[o_cnt].primary_mnemonic_key_cap = cnvtupper(oc.primary_mnemonic),
   temp->olist[o_cnt].description = oc.description, temp->olist[o_cnt].description_key_cap =
   cnvtupper(oc.description)
   IF (oc.dcp_clin_cat_cd=0)
    temp->olist[o_cnt].no_clin_cat_orc_ind = 1
   ELSE
    temp->olist[o_cnt].no_clin_cat_orc_ind = 0
   ENDIF
   temp->olist[o_cnt].no_ec_ind = 1
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "Description"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Primary Mnemonic"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "No Clinical Category"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "No Event Code"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "catalog_cd"
 SET reply->collist[5].data_type = 2
 SET reply->collist[5].hide_ind = 1
 IF ((temp->o_cnt=0))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = temp->o_cnt),
   code_value_event_r cver
  PLAN (d)
   JOIN (cver
   WHERE (cver.parent_cd=temp->olist[d.seq].catalog_cd))
  DETAIL
   temp->olist[d.seq].no_ec_ind = 0
  WITH nocounter
 ;end select
 SET row_nbr = 0
 SET no_ec_cnt = 0
 SET no_clin_cat_orc_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = temp->o_cnt)
  PLAN (d)
  ORDER BY temp->olist[d.seq].description_key_cap, temp->olist[d.seq].primary_mnemonic_key_cap
  DETAIL
   IF ((((temp->olist[d.seq].no_ec_ind=1)) OR ((temp->olist[d.seq].no_clin_cat_orc_ind=1))) )
    row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->
     rowlist[row_nbr].celllist,5),
    reply->rowlist[row_nbr].celllist[1].string_value = temp->olist[d.seq].description, reply->
    rowlist[row_nbr].celllist[2].string_value = temp->olist[d.seq].primary_mnemonic
    IF ((temp->olist[d.seq].no_clin_cat_orc_ind=1))
     no_clin_cat_orc_cnt = (no_clin_cat_orc_cnt+ 1), reply->rowlist[row_nbr].celllist[3].string_value
      = "X"
    ELSE
     reply->rowlist[row_nbr].celllist[3].string_value = " "
    ENDIF
    IF ((temp->olist[d.seq].no_ec_ind=1))
     no_ec_cnt = (no_ec_cnt+ 1), reply->rowlist[row_nbr].celllist[4].string_value = "X"
    ELSE
     reply->rowlist[row_nbr].celllist[4].string_value = " "
    ENDIF
    reply->rowlist[row_nbr].celllist[5].double_value = temp->olist[d.seq].catalog_cd
   ENDIF
  WITH nocounter
 ;end select
 IF (no_ec_cnt=0
  AND no_clin_cat_orc_cnt=0)
  SET reply->run_status_flag = 1
 ELSE
  SET reply->run_status_flag = 3
 ENDIF
 SET stat = alterlist(reply->statlist,2)
 SET reply->statlist[1].total_items = high_volume_cnt
 SET reply->statlist[1].qualifying_items = no_ec_cnt
 SET reply->statlist[1].statistic_meaning = "RXORCNOEVENTCD"
 IF (no_ec_cnt > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->statlist[2].total_items = high_volume_cnt
 SET reply->statlist[2].qualifying_items = no_clin_cat_orc_cnt
 SET reply->statlist[2].statistic_meaning = "RXORCNOCLINCAT"
 IF (no_clin_cat_orc_cnt > 0)
  SET reply->statlist[2].status_flag = 3
 ELSE
  SET reply->statlist[2].status_flag = 1
 ENDIF
 CALL echorecord(reply)
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("med_orc_issues_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
