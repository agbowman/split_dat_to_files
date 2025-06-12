CREATE PROGRAM bed_aud_ap_reports:dba
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
   1 orderables[*]
     2 code_value = f8
     2 description = vc
     2 dept_name = vc
     2 resource_route_lvl = i4
     2 assays[*]
       3 code_value = f8
       3 display = vc
       3 description = vc
       3 result_type = vc
       3 required_ind = i2
       3 prompt_ind = i2
     2 benches[*]
       3 code_value = f8
       3 description = vc
       3 default_ind = i2
 )
 DECLARE apacttype = f8 WITH public, noconstant(0.0)
 DECLARE apsubtype = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="AP"
    AND cv.active_ind=1)
  DETAIL
   apacttype = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=5801
    AND cv.cdf_meaning="APREPORT"
    AND cv.active_ind=1)
  DETAIL
   apsubtype = cv.code_value
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM order_catalog oc,
    profile_task_r ptr
   PLAN (oc
    WHERE oc.activity_type_cd=apacttype
     AND oc.activity_subtype_cd=apsubtype
     AND oc.active_ind=1)
    JOIN (ptr
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND ptr.active_ind=1)
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
 SELECT INTO "NL:"
  FROM order_catalog oc,
   profile_task_r ptr,
   discrete_task_assay dta,
   code_value cv
  PLAN (oc
   WHERE oc.activity_type_cd=apacttype
    AND oc.activity_subtype_cd=apsubtype
    AND oc.active_ind=1)
   JOIN (ptr
   WHERE ptr.catalog_cd=outerjoin(oc.catalog_cd)
    AND ptr.active_ind=outerjoin(1))
   JOIN (dta
   WHERE dta.task_assay_cd=outerjoin(ptr.task_assay_cd)
    AND dta.active_ind=outerjoin(1))
   JOIN (cv
   WHERE cv.code_value=outerjoin(dta.default_result_type_cd)
    AND cv.active_ind=outerjoin(1))
  ORDER BY oc.description, oc.catalog_cd, ptr.sequence
  HEAD oc.catalog_cd
   ocnt = (ocnt+ 1), stat = alterlist(temp->orderables,ocnt), temp->orderables[ocnt].code_value = oc
   .catalog_cd,
   temp->orderables[ocnt].description = oc.description, temp->orderables[ocnt].dept_name = oc
   .dept_display_name, temp->orderables[ocnt].resource_route_lvl = oc.resource_route_lvl,
   acnt = 0
  DETAIL
   IF (dta.task_assay_cd > 0)
    acnt = (acnt+ 1), stat = alterlist(temp->orderables[ocnt].assays,acnt), temp->orderables[ocnt].
    assays[acnt].code_value = dta.task_assay_cd,
    temp->orderables[ocnt].assays[acnt].display = dta.mnemonic, temp->orderables[ocnt].assays[acnt].
    description = dta.description, temp->orderables[ocnt].assays[acnt].result_type = cv.display,
    temp->orderables[ocnt].assays[acnt].required_ind = ptr.pending_ind, temp->orderables[ocnt].
    assays[acnt].prompt_ind = ptr.item_type_flag
   ENDIF
  WITH nocounter
 ;end select
 IF (ocnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = ocnt),
    orc_resource_list orl,
    code_value cv
   PLAN (d)
    JOIN (orl
    WHERE (orl.catalog_cd=temp->orderables[d.seq].code_value)
     AND orl.active_ind=1
     AND (temp->orderables[d.seq].resource_route_lvl=1))
    JOIN (cv
    WHERE cv.code_value=orl.service_resource_cd
     AND cv.active_ind=1)
   ORDER BY d.seq, orl.sequence
   HEAD d.seq
    bcnt = 0
   DETAIL
    bcnt = (bcnt+ 1), stat = alterlist(temp->orderables[d.seq].benches,bcnt), temp->orderables[d.seq]
    .benches[bcnt].code_value = orl.service_resource_cd,
    temp->orderables[d.seq].benches[bcnt].description = cv.description, temp->orderables[d.seq].
    benches[bcnt].default_ind = orl.primary_ind
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->collist,9)
 SET reply->collist[1].header_text = "Millennium Name (Long Description)"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Department Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Assay Display"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Assay Description"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Result Type"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Required"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Prompt"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Bench"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Default Bench"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 IF (ocnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (o = 1 TO ocnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,9)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->orderables[o].description
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->orderables[o].dept_name
   SET acnt = size(temp->orderables[o].assays,5)
   SET bcnt = size(temp->orderables[o].benches,5)
   SET b = 0
   IF (acnt > 0)
    FOR (a = 1 TO acnt)
      SET reply->rowlist[row_nbr].celllist[3].string_value = temp->orderables[o].assays[a].display
      SET reply->rowlist[row_nbr].celllist[4].string_value = temp->orderables[o].assays[a].
      description
      SET reply->rowlist[row_nbr].celllist[5].string_value = temp->orderables[o].assays[a].
      result_type
      IF ((temp->orderables[o].assays[a].required_ind=1))
       SET reply->rowlist[row_nbr].celllist[6].string_value = "X"
      ELSE
       SET reply->rowlist[row_nbr].celllist[6].string_value = " "
      ENDIF
      IF ((temp->orderables[o].assays[a].prompt_ind=1))
       SET reply->rowlist[row_nbr].celllist[7].string_value = "X"
      ELSE
       SET reply->rowlist[row_nbr].celllist[7].string_value = " "
      ENDIF
      SET b = (b+ 1)
      IF (((b < bcnt) OR (b=bcnt)) )
       SET reply->rowlist[row_nbr].celllist[8].string_value = temp->orderables[o].benches[b].
       description
       IF ((temp->orderables[o].benches[b].default_ind=1))
        SET reply->rowlist[row_nbr].celllist[9].string_value = "X"
       ELSE
        SET reply->rowlist[row_nbr].celllist[9].string_value = " "
       ENDIF
      ENDIF
      IF (a < acnt)
       SET row_nbr = (row_nbr+ 1)
       SET stat = alterlist(reply->rowlist,row_nbr)
       SET stat = alterlist(reply->rowlist[row_nbr].celllist,9)
      ENDIF
    ENDFOR
    IF (b < bcnt)
     SET b = (b+ 1)
     FOR (b = b TO bcnt)
       SET row_nbr = (row_nbr+ 1)
       SET stat = alterlist(reply->rowlist,row_nbr)
       SET stat = alterlist(reply->rowlist[row_nbr].celllist,9)
       SET reply->rowlist[row_nbr].celllist[8].string_value = temp->orderables[o].benches[b].
       description
       IF ((temp->orderables[o].benches[b].default_ind=1))
        SET reply->rowlist[row_nbr].celllist[9].string_value = "X"
       ELSE
        SET reply->rowlist[row_nbr].celllist[9].string_value = " "
       ENDIF
     ENDFOR
    ENDIF
   ELSEIF (bcnt > 0)
    FOR (b = 1 TO bcnt)
      SET reply->rowlist[row_nbr].celllist[8].string_value = temp->orderables[o].benches[b].
      description
      IF ((temp->orderables[o].benches[b].default_ind=1))
       SET reply->rowlist[row_nbr].celllist[9].string_value = "X"
      ELSE
       SET reply->rowlist[row_nbr].celllist[9].string_value = " "
      ENDIF
      IF (b < bcnt)
       SET row_nbr = (row_nbr+ 1)
       SET stat = alterlist(reply->rowlist,row_nbr)
       SET stat = alterlist(reply->rowlist[row_nbr].celllist,9)
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("ap_reports.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
