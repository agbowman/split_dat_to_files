CREATE PROGRAM bed_aud_fn_bed_status:dba
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
   1 fcnt = i2
   1 fqual[*]
     2 facility = vc
     2 cnt = i2
     2 qual[*]
       3 catalog_type = vc
       3 activity_type = vc
       3 desc = vc
       3 mnemonic = vc
       3 match = vc
       3 add = vc
       3 oc_desc = vc
       3 oc_cd = f8
       3 synonym = vc
       3 remove = vc
       3 match_ind = i2
       3 match_cd = f8
       3 concept_cki = vc
 )
 DECLARE work_value = i4
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=291)
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
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "Bed Status"
 SET reply->collist[1].data_type = 1
 SET reply->collist[2].header_text = "Meaning"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Bed Status Color ID"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Bed Status Icon ID"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Last Update By"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET row_nbr = 0
 SELECT INTO "nl:"
  FROM code_value cv,
   (dummyt d  WITH seq = 1),
   code_value_extension cve,
   person p
  PLAN (cv
   WHERE cv.code_set=291
    AND cv.active_ind=1)
   JOIN (d)
   JOIN (cve
   WHERE cve.code_value=cv.code_value
    AND cve.field_name IN ("Bed Status Color", "Bed Status Icon"))
   JOIN (p
   WHERE p.person_id=outerjoin(cve.updt_id))
  ORDER BY cv.display_key, cv.code_value, cnvtdatetime(cve.updt_dt_tm)
  HEAD REPORT
   xcnt = 0
  HEAD cv.code_value
   row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->rowlist[
    row_nbr].celllist,5),
   reply->rowlist[row_nbr].celllist[1].string_value = cv.display, reply->rowlist[row_nbr].celllist[2]
   .string_value = cv.cdf_meaning
  DETAIL
   IF (cve.field_name="Bed Status Color")
    reply->rowlist[row_nbr].celllist[3].string_value = cve.field_value, reply->rowlist[row_nbr].
    celllist[5].string_value = p.name_full_formatted
   ELSEIF (cve.field_name="Bed Status Icon")
    IF (cnvtint(cve.field_value) > 10000)
     work_value = (cnvtint(cve.field_value) - 10000), reply->rowlist[row_nbr].celllist[4].
     string_value = cnvtstring(work_value)
    ELSE
     reply->rowlist[row_nbr].celllist[4].string_value = cve.field_value
    ENDIF
    reply->rowlist[row_nbr].celllist[5].string_value = p.name_full_formatted
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("firstnet_bed_status_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
