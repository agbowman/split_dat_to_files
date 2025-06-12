CREATE PROGRAM bed_aud_pharm_creation:dba
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
  )
 ENDIF
 SET stat = alterlist(reply->collist,7)
 SET reply->collist[1].header_text = "NDC"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Facility_Cd"
 SET reply->collist[3].data_type = 2
 SET reply->collist[3].hide_ind = 1
 SET reply->collist[4].header_text = "Facility Description"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Charge Nbr"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "UBC Identifier"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Acquisition Cost"
 SET reply->collist[7].data_type = 2
 SET reply->collist[7].hide_ind = 0
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   tcnt = count(*)
   FROM br_pharm_product_work
   WHERE match_ind=9
   DETAIL
    high_volume_cnt = tcnt
   WITH nocounter
  ;end select
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET rcnt = 0
 SELECT INTO "nl:"
  desc = cnvtupper(bppw.description), ndc = concat(substring(1,5,bppw.ndc),"-",substring(6,4,bppw.ndc
    ),"-",substring(10,2,bppw.ndc))
  FROM br_pharm_product_work bppw,
   code_value cv
  PLAN (bppw
   WHERE bppw.match_ind=9)
   JOIN (cv
   WHERE cv.code_value=bppw.facility_cd)
  ORDER BY desc
  DETAIL
   rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
    celllist,7),
   reply->rowlist[rcnt].celllist[1].string_value = ndc, reply->rowlist[rcnt].celllist[2].string_value
    = bppw.description, reply->rowlist[rcnt].celllist[3].double_value = bppw.facility_cd,
   reply->rowlist[rcnt].celllist[4].string_value = cv.display, reply->rowlist[rcnt].celllist[5].
   string_value = bppw.charge_nbr, reply->rowlist[rcnt].celllist[6].string_value = bppw.ubc_ident,
   reply->rowlist[rcnt].celllist[7].double_value = bppw.acquisition_cost
  WITH nocounter
 ;end select
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("pharm_creation.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
END GO
