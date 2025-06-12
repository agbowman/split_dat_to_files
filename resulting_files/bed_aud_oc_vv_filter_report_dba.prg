CREATE PROGRAM bed_aud_oc_vv_filter_report:dba
 IF ( NOT (validate(request,0)))
  FREE SET request
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 activity_types[*]
      2 code_value = f8
      2 sub_activity_types[*]
        3 code_value = f8
    1 locations[*]
      2 code_value = f8
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
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
     2 description = vc
     2 synonym_id = f8
     2 mnemonic = vc
     2 mnemonic_type_cd = f8
     2 mnemonic_type_disp = vc
     2 catalog_type_cd = f8
     2 catalog_type_disp = vc
     2 activity_type_cd = f8
     2 activity_type_disp = vc
     2 activity_subtype_cd = f8
     2 activity_subtype_disp = vc
     2 dept_display_name = vc
     2 vv_all_fac_ind = i2
 )
 RECORD fac(
   1 flist[*]
     2 fac_cd = f8
     2 fac_disp = vc
     2 vv_ind = i2
     2 index_num = i4
 )
 DECLARE aparse = vc
 DECLARE fac_cd = f8
 DECLARE act_size = i2
 DECLARE subact_size = i2
 DECLARE tot_col = i2
 DECLARE loc_size = i2
 DECLARE fcnt = i2
 DECLARE row_nbr = i2
 SET reply->status_data.status = "F"
 DECLARE idx = i4 WITH noconstant(0), protect
 DECLARE max_org = i4 WITH constant(150)
 DECLARE fac_idx = i4 WITH noconstant(0), protect
 DECLARE fac_idx2 = i4 WITH noconstant(0), protect
 SET fac_cd = 0.0
 SET fac_cd = uar_get_code_by("MEANING",222,"FACILITY")
 SET aparse = "o.active_ind = 1 "
 SET act_size = size(request->activity_types,5)
 SET subact_size = 0
 IF (validate(request->activity_types.sub_activity_types,0))
  SET subact_size = size(request->activity_types.sub_activity_types,5)
 ENDIF
 IF (subact_size > 0
  AND act_size > 0)
  FOR (x = 1 TO subact_size)
    IF (x=1)
     SET aparse = build(aparse," and o.activity_type_cd in (",request->activity_types.code_value)
     SET aparse = build(aparse," ) ")
     SET aparse = build(aparse," and o.activity_subtype_cd in (",request->activity_types.
      sub_activity_types[x].code_value)
    ELSE
     SET aparse = build(aparse," , ",request->activity_types.sub_activity_types[x].code_value)
    ENDIF
  ENDFOR
  SET aparse = build(aparse," ) ")
 ELSE
  IF (act_size > 0)
   FOR (x = 1 TO act_size)
     IF (x=1)
      SET aparse = build(aparse," and o.activity_type_cd in (",request->activity_types[x].code_value)
     ELSE
      SET aparse = build(aparse," , ",request->activity_types[x].code_value)
     ENDIF
   ENDFOR
   SET aparse = build(aparse," ) ")
  ENDIF
 ENDIF
 SET tot_col = 9
 SET stat = alterlist(reply->collist,tot_col)
 SET reply->collist[1].header_text = "Activity Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Subactivity Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Catalog_cd"
 SET reply->collist[3].data_type = 2
 SET reply->collist[3].hide_ind = 1
 SET reply->collist[4].header_text = "Description"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Synonym_id"
 SET reply->collist[5].data_type = 2
 SET reply->collist[5].hide_ind = 1
 SET reply->collist[6].header_text = "Synonym"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Synonym Type"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Department Name"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "All Facilities"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET loc_size = size(request->locations,5)
 SET fcnt = 0
 IF (loc_size > 0)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE expand(idx,1,size(request->locations,5),cv.code_value,request->locations[idx].code_value)
   ORDER BY cv.display_key, cv.code_value
   HEAD REPORT
    fcnt = 0, stat = alterlist(fac->flist,100), stat = alterlist(reply->collist,100)
   HEAD cv.code_value
    fcnt = (fcnt+ 1)
    IF (mod(fcnt,10)=1)
     stat = alterlist(fac->flist,(fcnt+ 9))
    ENDIF
    fac->flist[fcnt].fac_cd = cv.code_value, tot_col = (tot_col+ 1)
    IF (mod(tot_col,10)=1)
     stat = alterlist(reply->collist,(tot_col+ 9))
    ENDIF
    reply->collist[tot_col].header_text = cv.display, reply->collist[tot_col].data_type = 1, reply->
    collist[tot_col].hide_ind = 0
   FOOT REPORT
    stat = alterlist(fac->flist,fcnt), stat = alterlist(reply->collist,tot_col)
   WITH nocounter, expand = 2
  ;end select
 ENDIF
 IF ((request->skip_volume_check_ind=0)
  AND size(fac->flist,5) > max_org)
  SET reply->high_volume_flag = 2
  GO TO exit_script
 ENDIF
 SET fcnt = (fcnt+ 1)
 SET stat = alterlist(fac->flist,fcnt)
 SET fac->flist[fcnt].fac_cd = 0
 SET row_nbr = 0
 SELECT INTO "nl:"
  FROM order_catalog o,
   code_value cv2,
   order_catalog_synonym ocs,
   code_value cv3,
   ocs_facility_r f,
   code_value cv
  PLAN (o
   WHERE parser(aparse))
   JOIN (ocs
   WHERE ocs.catalog_cd=o.catalog_cd
    AND ocs.active_ind=1)
   JOIN (f
   WHERE f.synonym_id=ocs.synonym_id
    AND expand(fac_idx,1,value(fcnt),f.facility_cd,fac->flist[fac_idx].fac_cd))
   JOIN (cv
   WHERE cv.code_value=o.activity_type_cd)
   JOIN (cv2
   WHERE cv2.code_value=o.activity_subtype_cd)
   JOIN (cv3
   WHERE cv3.code_value=ocs.mnemonic_type_cd)
  ORDER BY cv.display_key, cv2.display_key, o.description,
   o.catalog_cd, ocs.mnemonic_key_cap, ocs.synonym_id,
   f.facility_cd
  HEAD REPORT
   row_nbr = 0
  HEAD ocs.synonym_id
   row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->rowlist[
    row_nbr].celllist,tot_col),
   reply->rowlist[row_nbr].celllist[1].string_value = cv.display, reply->rowlist[row_nbr].celllist[2]
   .string_value = cv2.display, reply->rowlist[row_nbr].celllist[3].double_value = o.catalog_cd,
   reply->rowlist[row_nbr].celllist[4].string_value = o.description, reply->rowlist[row_nbr].
   celllist[5].double_value = ocs.synonym_id, reply->rowlist[row_nbr].celllist[6].string_value = ocs
   .mnemonic,
   reply->rowlist[row_nbr].celllist[7].string_value = cv3.display, reply->rowlist[row_nbr].celllist[8
   ].string_value = o.dept_display_name
  HEAD f.facility_cd
   IF (f.facility_cd=0)
    FOR (x = 9 TO tot_col)
      reply->rowlist[row_nbr].celllist[x].string_value = "Yes"
    ENDFOR
   ELSE
    fac_idx2 = locateval(idx,1,value(fcnt),f.facility_cd,fac->flist[idx].fac_cd), reply->rowlist[
    row_nbr].celllist[(fac_idx2+ 9)].string_value = "Yes"
   ENDIF
  WITH nocounter, expand = 2
 ;end select
 IF ((request->skip_volume_check_ind=0))
  IF (row_nbr > 10000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   SET stat = alterlist(reply->collist,0)
   GO TO exit_script
  ELSEIF (row_nbr > 5000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   SET stat = alterlist(reply->collist,0)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 SET reply->run_status_flag = 1
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("virtual_view_filter_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
