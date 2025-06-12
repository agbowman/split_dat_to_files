CREATE PROGRAM bed_aud_careteam_prsnl:dba
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
 SET row_nbr = 0
 SET org_doc = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=320
   AND cv.cdf_meaning="DOCNBR"
   AND cv.active_ind=1
  DETAIL
   org_doc = cv.code_value
  WITH nocounter
 ;end select
 SET doc_nbr = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=263
   AND cv.display_key="DOCTORNBR"
   AND cv.active_ind=1
  DETAIL
   doc_nbr = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv1,
   code_value_group cvg,
   code_value cv2,
   prsnl_group pg,
   prsnl_group_reltn pgr,
   prsnl p,
   prsnl_alias pa
  PLAN (cv1
   WHERE cv1.code_set=357
    AND cv1.active_ind=1)
   JOIN (cvg
   WHERE cvg.child_code_value=cv1.code_value
    AND cvg.code_set=357)
   JOIN (cv2
   WHERE cv2.code_value=cvg.parent_code_value
    AND cv2.code_set=100006
    AND cv2.active_ind=1)
   JOIN (pg
   WHERE pg.prsnl_group_type_cd=cv2.code_value
    AND pg.active_ind=1)
   JOIN (pgr
   WHERE pgr.prsnl_group_id=pg.prsnl_group_id
    AND pgr.active_ind=1)
   JOIN (p
   WHERE p.person_id=pgr.person_id
    AND p.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.prsnl_alias_type_cd=org_doc
    AND pa.alias_pool_cd=doc_nbr
    AND pa.active_ind=1)
  ORDER BY pg.prsnl_group_name_key, p.name_full_formatted
  HEAD REPORT
   row_nbr = 0
  DETAIL
   row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->rowlist[
    row_nbr].celllist,4),
   reply->rowlist[row_nbr].celllist[4].double_value = pa.person_id, reply->rowlist[row_nbr].celllist[
   3].string_value = pa.alias, reply->rowlist[row_nbr].celllist[2].string_value = p
   .name_full_formatted,
   reply->rowlist[row_nbr].celllist[1].string_value = pg.prsnl_group_name
  WITH nocounter
 ;end select
 IF ((request->skip_volume_check_ind=0))
  IF (row_nbr > 5000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ELSEIF (row_nbr > 3000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,4)
 SET reply->collist[1].header_text = "Care Team"
 SET reply->collist[1].data_type = 2
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Personnel"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "UUID"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Person ID"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("careteamprsnlreport.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
