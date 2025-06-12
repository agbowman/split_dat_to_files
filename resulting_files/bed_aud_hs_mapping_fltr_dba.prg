CREATE PROGRAM bed_aud_hs_mapping_fltr:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 subjects[*]
      2 code_set = i4
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 RECORD temprows(
   1 rowlist[*]
     2 code_set = i4
     2 celllist[*]
       3 string_value = vc
 )
 DECLARE req_size = i4 WITH noconstant(0), protect
 DECLARE total_col = i4 WITH constant(9), protect
 DECLARE row_cnt = i4 WITH noconstant(0), protect
 DECLARE primary_var = f8 WITH noconstant(0.0), protect
 SET req_size = size(request->subjects,5)
 IF (req_size=0)
  GO TO exit_script
 ENDIF
 CALL echorecord(request)
 SET stat = alterlist(reply->collist,total_col)
 SET reply->collist[1].header_text = "Subject Area"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Source Description 1"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Source Description 2"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Source Description 3"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Client Description 1"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Client Description 2"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Client Description 3"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Mapped By"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Date Mapped"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SELECT INTO "nl:"
  FROM code_value cv,
   br_hlth_sntry_item bhsi,
   br_hlth_sntry_mill_item bhsir,
   prsnl p,
   code_value_set cvs,
   (dummyt d  WITH seq = req_size)
  PLAN (d
   WHERE  NOT ((request->subjects[d.seq].code_set IN (72, 200))))
   JOIN (bhsi
   WHERE (bhsi.code_set=request->subjects[d.seq].code_set))
   JOIN (cvs
   WHERE bhsi.code_set=cvs.code_set)
   JOIN (bhsir
   WHERE bhsir.br_hlth_sntry_item_id=bhsi.br_hlth_sntry_item_id)
   JOIN (p
   WHERE bhsir.updt_id=p.person_id)
   JOIN (cv
   WHERE cv.active_ind=1
    AND bhsir.code_value=cv.code_value)
  ORDER BY cvs.code_set, cvs.display, bhsi.description_1
  HEAD REPORT
   stat = alterlist(temprows->rowlist,100)
  DETAIL
   row_cnt = (row_cnt+ 1)
   IF (mod(row_cnt,100)=0)
    stat = alterlist(temprows->rowlist,(row_cnt+ 100))
   ENDIF
   stat = alterlist(temprows->rowlist[row_cnt].celllist,total_col), temprows->rowlist[row_cnt].
   code_set = cvs.code_set, temprows->rowlist[row_cnt].celllist[1].string_value = build(bhsi.code_set,
    " - ",cvs.display),
   temprows->rowlist[row_cnt].celllist[2].string_value = bhsi.description_1, temprows->rowlist[
   row_cnt].celllist[3].string_value = bhsi.description_2, temprows->rowlist[row_cnt].celllist[4].
   string_value = bhsi.description_3,
   temprows->rowlist[row_cnt].celllist[5].string_value = cv.display, temprows->rowlist[row_cnt].
   celllist[6].string_value = cv.description, temprows->rowlist[row_cnt].celllist[7].string_value =
   cv.definition,
   temprows->rowlist[row_cnt].celllist[8].string_value = p.name_full_formatted, temprows->rowlist[
   row_cnt].celllist[9].string_value = format(bhsir.updt_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D")
  FOOT REPORT
   stat = alterlist(temprows->rowlist,row_cnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error selecting items for report.")
 SET primary_var = uar_get_code_by("MEANING",6011,"PRIMARY")
 SELECT INTO "nl:"
  FROM code_value cv,
   br_hlth_sntry_item bhsi,
   br_hlth_sntry_mill_item bhsir,
   prsnl p,
   code_value_set cvs,
   order_catalog oc,
   order_catalog_synonym ocs,
   (dummyt d  WITH seq = req_size)
  PLAN (d
   WHERE (request->subjects[d.seq].code_set=200))
   JOIN (bhsi
   WHERE (bhsi.code_set=request->subjects[d.seq].code_set))
   JOIN (cvs
   WHERE bhsi.code_set=cvs.code_set)
   JOIN (bhsir
   WHERE bhsir.br_hlth_sntry_item_id=bhsi.br_hlth_sntry_item_id)
   JOIN (p
   WHERE bhsir.updt_id=p.person_id)
   JOIN (cv
   WHERE cv.active_ind=1
    AND bhsir.code_value=cv.code_value)
   JOIN (oc
   WHERE oc.active_ind=outerjoin(1)
    AND oc.catalog_cd=outerjoin(bhsir.code_value))
   JOIN (ocs
   WHERE ocs.active_ind=outerjoin(1)
    AND ocs.catalog_cd=outerjoin(bhsir.code_value)
    AND ocs.mnemonic_type_cd=outerjoin(primary_var))
  ORDER BY cvs.code_set, cvs.display, bhsi.description_1
  HEAD REPORT
   stat = alterlist(temprows->rowlist,(row_cnt+ 100))
  DETAIL
   row_cnt = (row_cnt+ 1)
   IF (mod(row_cnt,100)=0)
    stat = alterlist(temprows->rowlist,(row_cnt+ 100))
   ENDIF
   stat = alterlist(temprows->rowlist[row_cnt].celllist,total_col), temprows->rowlist[row_cnt].
   code_set = cvs.code_set, temprows->rowlist[row_cnt].celllist[1].string_value = build(bhsi.code_set,
    " - ",cvs.display),
   temprows->rowlist[row_cnt].celllist[2].string_value = bhsi.description_1, temprows->rowlist[
   row_cnt].celllist[3].string_value = bhsi.description_2, temprows->rowlist[row_cnt].celllist[4].
   string_value = bhsi.description_3,
   temprows->rowlist[row_cnt].celllist[5].string_value = oc.description, temprows->rowlist[row_cnt].
   celllist[6].string_value = ocs.mnemonic, temprows->rowlist[row_cnt].celllist[8].string_value = p
   .name_full_formatted,
   temprows->rowlist[row_cnt].celllist[9].string_value = format(bhsir.updt_dt_tm,
    "DD-MMM-YYYY HH:MM:SS;;D")
  FOOT REPORT
   stat = alterlist(temprows->rowlist,row_cnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error selecting CS200 items for report.")
 SELECT INTO "nl:"
  FROM br_hlth_sntry_item bhsi,
   br_hlth_sntry_mill_item bhsir,
   prsnl p,
   code_value_set cvs,
   v500_event_code vec,
   (dummyt d  WITH seq = req_size)
  PLAN (d
   WHERE (request->subjects[d.seq].code_set=72))
   JOIN (bhsi
   WHERE (bhsi.code_set=request->subjects[d.seq].code_set))
   JOIN (cvs
   WHERE bhsi.code_set=cvs.code_set)
   JOIN (bhsir
   WHERE bhsir.br_hlth_sntry_item_id=bhsi.br_hlth_sntry_item_id)
   JOIN (p
   WHERE bhsir.updt_id=p.person_id)
   JOIN (vec
   WHERE vec.event_cd=bhsir.code_value)
  ORDER BY cvs.code_set, cvs.display, bhsi.description_1
  HEAD REPORT
   stat = alterlist(temprows->rowlist,(row_cnt+ 100))
  DETAIL
   row_cnt = (row_cnt+ 1)
   IF (mod(row_cnt,100)=0)
    stat = alterlist(temprows->rowlist,(row_cnt+ 100))
   ENDIF
   stat = alterlist(temprows->rowlist[row_cnt].celllist,total_col), temprows->rowlist[row_cnt].
   code_set = cvs.code_set, temprows->rowlist[row_cnt].celllist[1].string_value = build(bhsi.code_set,
    " - ",cvs.display),
   temprows->rowlist[row_cnt].celllist[2].string_value = bhsi.description_1, temprows->rowlist[
   row_cnt].celllist[3].string_value = bhsi.description_2, temprows->rowlist[row_cnt].celllist[4].
   string_value = bhsi.description_3,
   temprows->rowlist[row_cnt].celllist[5].string_value = vec.event_cd_disp, temprows->rowlist[row_cnt
   ].celllist[6].string_value = vec.event_cd_descr, temprows->rowlist[row_cnt].celllist[7].
   string_value = vec.event_set_name,
   temprows->rowlist[row_cnt].celllist[8].string_value = p.name_full_formatted, temprows->rowlist[
   row_cnt].celllist[9].string_value = format(bhsir.updt_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D")
  FOOT REPORT
   stat = alterlist(temprows->rowlist,row_cnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error selecting CS72 items for report.")
 SET temprowcount = row_cnt
 IF (temprowcount > 0)
  SET stat = alterlist(reply->rowlist,temprowcount)
  SET row_cnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(temprowcount)),
    code_value_set cvs
   PLAN (d)
    JOIN (cvs
    WHERE (cvs.code_set=temprows->rowlist[d.seq].code_set))
   ORDER BY temprows->rowlist[d.seq].code_set, temprows->rowlist[d.seq].celllist[1].string_value,
    trim(temprows->rowlist[d.seq].celllist[2].string_value,3),
    trim(temprows->rowlist[d.seq].celllist[5].string_value,3)
   DETAIL
    row_cnt = (row_cnt+ 1), stat = alterlist(reply->rowlist[row_cnt].celllist,total_col), reply->
    rowlist[row_cnt].celllist[1].string_value = temprows->rowlist[d.seq].celllist[1].string_value,
    reply->rowlist[row_cnt].celllist[2].string_value = temprows->rowlist[d.seq].celllist[2].
    string_value, reply->rowlist[row_cnt].celllist[3].string_value = temprows->rowlist[d.seq].
    celllist[3].string_value, reply->rowlist[row_cnt].celllist[4].string_value = temprows->rowlist[d
    .seq].celllist[4].string_value,
    reply->rowlist[row_cnt].celllist[5].string_value = temprows->rowlist[d.seq].celllist[5].
    string_value, reply->rowlist[row_cnt].celllist[6].string_value = temprows->rowlist[d.seq].
    celllist[6].string_value, reply->rowlist[row_cnt].celllist[7].string_value = temprows->rowlist[d
    .seq].celllist[7].string_value,
    reply->rowlist[row_cnt].celllist[8].string_value = temprows->rowlist[d.seq].celllist[8].
    string_value, reply->rowlist[row_cnt].celllist[9].string_value = temprows->rowlist[d.seq].
    celllist[9].string_value
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error when sorting and filling out the reply structure for report.")
 ENDIF
 IF ((request->skip_volume_check_ind=0))
  IF (row_cnt > 10000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ELSEIF (row_cnt > 5000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echorecord(reply)
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("hs_mapping_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
