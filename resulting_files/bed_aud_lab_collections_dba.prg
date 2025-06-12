CREATE PROGRAM bed_aud_lab_collections:dba
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
   1 cnt = i4
   1 qual[*]
     2 primary_mnem = vc
     2 resource_route_lvl = i2
     2 catalog_cd = f8
     2 accn_class = vc
     2 spec_type = vc
     2 def_coll_method = vc
     2 srvres = vc
     2 srvres_cd = f8
     2 age_from_min = i4
     2 age_from = vc
     2 age_to_min = i4
     2 age_to = vc
     2 min_vol = vc
     2 min_vol_units = vc
     2 spec_cont = vc
     2 coll_class = vc
     2 spec_handling = vc
     2 activity_type = vc
     2 activity_subtype = vc
     2 instr_bench_status = vc
 )
 DECLARE lab = f8 WITH public, noconstant(0.0)
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
 SET ap_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="AP"
    AND cv.active_ind=1)
  DETAIL
   ap_cd = cv.code_value
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
 SET cnt = 0
 SELECT INTO "nl:"
  FROM order_catalog oc,
   code_value cv8,
   code_value cv9,
   (dummyt d  WITH seq = 1),
   procedure_specimen_type pst,
   code_value cv1,
   code_value cv2,
   code_value cv3,
   collection_info_qualifiers ciq,
   code_value cv4,
   code_value cv5,
   code_value cv6,
   code_value cv7
  PLAN (oc
   WHERE oc.catalog_type_cd=lab
    AND oc.active_ind=1
    AND  NOT (oc.orderable_type_flag IN (2, 6))
    AND oc.bill_only_ind IN (0, null))
   JOIN (cv8
   WHERE cv8.code_value=oc.activity_type_cd)
   JOIN (cv9
   WHERE cv9.code_value=oc.activity_subtype_cd)
   JOIN (d)
   JOIN (pst
   WHERE pst.catalog_cd=oc.catalog_cd)
   JOIN (cv1
   WHERE cv1.code_value=pst.accession_class_cd)
   JOIN (cv2
   WHERE cv2.code_value=pst.specimen_type_cd)
   JOIN (cv3
   WHERE cv3.code_value=pst.default_collection_method_cd)
   JOIN (ciq
   WHERE ciq.catalog_cd=pst.catalog_cd
    AND ciq.specimen_type_cd=pst.specimen_type_cd)
   JOIN (cv4
   WHERE cv4.code_value=ciq.service_resource_cd)
   JOIN (cv5
   WHERE cv5.code_value=ciq.spec_cntnr_cd)
   JOIN (cv6
   WHERE cv6.code_value=ciq.coll_class_cd)
   JOIN (cv7
   WHERE cv7.code_value=ciq.spec_hndl_cd)
  ORDER BY cv8.display, cnvtupper(oc.primary_mnemonic), cv2.display,
   ciq.sequence
  DETAIL
   IF (((oc.activity_type_cd=ap_cd
    AND pst.catalog_cd > 0
    AND ciq.catalog_cd > 0) OR (oc.activity_type_cd != ap_cd)) )
    cnt = (cnt+ 1), temp->cnt = cnt, stat = alterlist(temp->qual,cnt),
    temp->qual[cnt].primary_mnem = oc.primary_mnemonic, temp->qual[cnt].catalog_cd = oc.catalog_cd,
    temp->qual[cnt].resource_route_lvl = oc.resource_route_lvl,
    temp->qual[cnt].activity_type = cv8.display, temp->qual[cnt].activity_subtype = cv9.display
    IF (pst.catalog_cd > 0)
     temp->qual[cnt].accn_class = cv1.display, temp->qual[cnt].spec_type = cv2.display, temp->qual[
     cnt].def_coll_method = cv3.display
    ENDIF
    IF (ciq.catalog_cd > 0)
     IF (ciq.service_resource_cd=0)
      temp->qual[cnt].srvres = "ALL"
     ELSE
      temp->qual[cnt].srvres = cv4.display, temp->qual[cnt].srvres_cd = ciq.service_resource_cd
      IF (cv4.active_ind=0)
       temp->qual[cnt].instr_bench_status = "Inactive"
      ELSE
       temp->qual[cnt].instr_bench_status = "Active"
      ENDIF
     ENDIF
     temp->qual[cnt].age_to_min = ciq.age_to_minutes, temp->qual[cnt].age_from_min = ciq
     .age_from_minutes
     IF (ciq.age_from_minutes < 60)
      temp->qual[cnt].age_from = build(ciq.age_from_minutes," Minutes")
     ELSEIF (ciq.age_from_minutes >= 60
      AND ciq.age_from_minutes < 1440)
      temp->qual[cnt].age_from = build((ciq.age_from_minutes/ 60)," Hours")
     ELSEIF (ciq.age_from_minutes >= 1440
      AND ciq.age_from_minutes < 10080)
      temp->qual[cnt].age_from = build((ciq.age_from_minutes/ 1440)," Days")
     ELSEIF (ciq.age_from_minutes >= 10080
      AND ciq.age_from_minutes < 43200)
      temp->qual[cnt].age_from = build((ciq.age_from_minutes/ 10080)," Weeks")
     ELSEIF (ciq.age_from_minutes >= 43200
      AND ciq.age_from_minutes < 525600)
      temp->qual[cnt].age_from = build((ciq.age_from_minutes/ 43200)," Months")
     ELSEIF (ciq.age_from_minutes >= 525600)
      temp->qual[cnt].age_from = build((ciq.age_from_minutes/ 525600)," Years")
     ELSE
      temp->qual[cnt].age_from = " "
     ENDIF
     IF (ciq.age_to_minutes < 60)
      temp->qual[cnt].age_to = build(ciq.age_to_minutes," Minutes")
     ELSEIF (ciq.age_to_minutes >= 60
      AND ciq.age_to_minutes < 1440)
      temp->qual[cnt].age_to = build((ciq.age_to_minutes/ 60)," Hours")
     ELSEIF (ciq.age_to_minutes >= 1440
      AND ciq.age_to_minutes < 10080)
      temp->qual[cnt].age_to = build((ciq.age_to_minutes/ 1440)," Days")
     ELSEIF (ciq.age_to_minutes >= 10080
      AND ciq.age_to_minutes < 43200)
      temp->qual[cnt].age_to = build((ciq.age_to_minutes/ 10080)," Weeks")
     ELSEIF (ciq.age_to_minutes >= 43200
      AND ciq.age_to_minutes < 525600)
      temp->qual[cnt].age_to = build((ciq.age_to_minutes/ 43200)," Months")
     ELSEIF (ciq.age_to_minutes >= 525600)
      temp->qual[cnt].age_to = build((ciq.age_to_minutes/ 525600)," Years")
     ELSE
      temp->qual[cnt].age_to = " "
     ENDIF
     temp->qual[cnt].min_vol = format(ciq.min_vol,"#####.##"), temp->qual[cnt].min_vol_units = ciq
     .min_vol_units, temp->qual[cnt].min_vol = concat(temp->qual[cnt].min_vol," ",temp->qual[cnt].
      min_vol_units),
     temp->qual[cnt].spec_cont = cv5.display, temp->qual[cnt].coll_class = cv6.display, temp->qual[
     cnt].spec_handling = cv7.display
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 SET stat = alterlist(reply->collist,15)
 SET reply->collist[1].header_text = "Activity Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Primary Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Accession Class"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Specimen Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Collection Method"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Intsrument/Bench"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Age From"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Age To"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Minimum Volume"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Container"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Collection Class"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Special Handling"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Subactivity Type"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "catalog_cd"
 SET reply->collist[14].data_type = 2
 SET reply->collist[14].hide_ind = 1
 SET reply->collist[15].header_text = "Instrument/Bench Status"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = cnt),
   orc_resource_list orl
  PLAN (d
   WHERE (temp->qual[d.seq].srvres_cd > 0)
    AND (temp->qual[d.seq].resource_route_lvl < 2))
   JOIN (orl
   WHERE (orl.catalog_cd=temp->qual[d.seq].catalog_cd)
    AND (orl.service_resource_cd=temp->qual[d.seq].srvres_cd))
  DETAIL
   IF ((orl.catalog_cd=temp->qual[d.seq].catalog_cd)
    AND (orl.service_resource_cd=temp->qual[d.seq].srvres_cd))
    IF (orl.active_ind=0)
     temp->qual[d.seq].instr_bench_status = "Inactive Relation"
    ENDIF
   ELSE
    temp->qual[d.seq].instr_bench_status = "Invalid"
   ENDIF
  WITH outerjoin = d
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = cnt),
   profile_task_r ptr,
   assay_resource_list arl
  PLAN (d
   WHERE (temp->qual[d.seq].srvres_cd > 0)
    AND (temp->qual[d.seq].resource_route_lvl=2))
   JOIN (ptr
   WHERE (ptr.catalog_cd=temp->qual[d.seq].catalog_cd)
    AND ptr.active_ind=1)
   JOIN (arl
   WHERE arl.task_assay_cd=ptr.task_assay_cd
    AND (arl.service_resource_cd=temp->qual[d.seq].srvres_cd))
  DETAIL
   IF (arl.task_assay_cd > 0
    AND (arl.service_resource_cd=temp->qual[d.seq].srvres_cd))
    IF (arl.active_ind=0)
     temp->qual[d.seq].instr_bench_status = "Inactive Relation"
    ENDIF
   ELSE
    temp->qual[d.seq].instr_bench_status = "Invalid"
   ENDIF
  WITH outerjoin = d
 ;end select
 SET row_nbr = 0
 FOR (x = 1 TO cnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,15)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->qual[x].activity_type
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->qual[x].primary_mnem
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->qual[x].accn_class
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->qual[x].spec_type
   SET reply->rowlist[row_nbr].celllist[5].string_value = temp->qual[x].def_coll_method
   SET reply->rowlist[row_nbr].celllist[6].string_value = temp->qual[x].srvres
   SET reply->rowlist[row_nbr].celllist[7].string_value = temp->qual[x].age_from
   SET reply->rowlist[row_nbr].celllist[8].string_value = temp->qual[x].age_to
   SET reply->rowlist[row_nbr].celllist[9].string_value = temp->qual[x].min_vol
   SET reply->rowlist[row_nbr].celllist[10].string_value = temp->qual[x].spec_cont
   SET reply->rowlist[row_nbr].celllist[11].string_value = temp->qual[x].coll_class
   SET reply->rowlist[row_nbr].celllist[12].string_value = temp->qual[x].spec_handling
   SET reply->rowlist[row_nbr].celllist[13].string_value = temp->qual[x].activity_subtype
   SET reply->rowlist[row_nbr].celllist[14].double_value = temp->qual[x].catalog_cd
   SET reply->rowlist[row_nbr].celllist[15].string_value = temp->qual[x].instr_bench_status
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("lab_collections_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
