CREATE PROGRAM bed_aud_orders_without_aliases:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 activity_types[*]
      2 code_value = f8
    1 contributor_source_code_value = f8
    1 direction = vc
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
   1 tqual[*]
     2 cat_type_disp = vc
     2 act_type_disp = vc
     2 code_value = f8
     2 primary_mnem = vc
     2 description = vc
     2 subactivity_type = vc
     2 active_ind = i2
 )
 SET acnt = size(request->activity_types,5)
 IF (acnt=0)
  GO TO exit_script
 ENDIF
 DECLARE act_type_list = vc
 SET act_type_list = build(" oc.activity_type_cd in (",request->activity_types[1].code_value)
 FOR (a = 2 TO acnt)
   SET act_type_list = build(act_type_list,",",request->activity_types[a].code_value)
 ENDFOR
 SET act_type_list = concat(act_type_list,")")
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  IF ((request->direction="I"))
   SELECT INTO "nl:"
    FROM code_value cv1,
     order_catalog oc,
     code_value_alias cva,
     code_value cv4
    PLAN (cv1
     WHERE cv1.code_set=200)
     JOIN (oc
     WHERE oc.catalog_cd=cv1.code_value
      AND parser(act_type_list))
     JOIN (cva
     WHERE cva.code_value=outerjoin(oc.catalog_cd)
      AND cva.contributor_source_cd=outerjoin(request->contributor_source_code_value))
     JOIN (cv4
     WHERE cv4.code_value=outerjoin(oc.activity_subtype_cd)
      AND cv4.active_ind=outerjoin(1))
    DETAIL
     IF (cva.alias IN (" ", null))
      high_volume_cnt = (high_volume_cnt+ 1)
     ENDIF
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
  ELSEIF ((request->direction="O"))
   SELECT INTO "nl:"
    FROM code_value cv1,
     order_catalog oc,
     code_value_outbound cva,
     code_value cv4
    PLAN (cv1
     WHERE cv1.code_set=200)
     JOIN (oc
     WHERE oc.catalog_cd=cv1.code_value
      AND parser(act_type_list))
     JOIN (cva
     WHERE cva.code_value=outerjoin(oc.catalog_cd)
      AND cva.contributor_source_cd=outerjoin(request->contributor_source_code_value))
     JOIN (cv4
     WHERE cv4.code_value=outerjoin(oc.activity_subtype_cd)
      AND cv4.active_ind=outerjoin(1))
    DETAIL
     IF (cva.alias IN (" ", null))
      high_volume_cnt = (high_volume_cnt+ 1)
     ENDIF
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
 ENDIF
 SET tcnt = 0
 IF ((request->direction="I"))
  SELECT INTO "NL:"
   FROM code_value cv1,
    order_catalog oc,
    code_value cv2,
    code_value cv3,
    code_value_alias cva,
    code_value cv4
   PLAN (cv1
    WHERE cv1.code_set=200)
    JOIN (oc
    WHERE oc.catalog_cd=cv1.code_value
     AND parser(act_type_list))
    JOIN (cv2
    WHERE cv2.code_value=oc.catalog_type_cd
     AND cv2.active_ind=1)
    JOIN (cv3
    WHERE cv3.code_value=oc.activity_type_cd
     AND cv3.active_ind=1)
    JOIN (cva
    WHERE cva.code_value=outerjoin(oc.catalog_cd)
     AND cva.contributor_source_cd=outerjoin(request->contributor_source_code_value))
    JOIN (cv4
    WHERE cv4.code_value=outerjoin(oc.activity_subtype_cd)
     AND cv4.active_ind=outerjoin(1))
   ORDER BY oc.catalog_cd
   DETAIL
    IF (cva.alias IN (" ", null))
     tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].cat_type_disp = cv2
     .display,
     temp->tqual[tcnt].act_type_disp = cv3.display, temp->tqual[tcnt].code_value = cv1.code_value,
     temp->tqual[tcnt].primary_mnem = cv1.display,
     temp->tqual[tcnt].description = cv1.description, temp->tqual[tcnt].subactivity_type = cv4
     .display, temp->tqual[tcnt].active_ind = cv1.active_ind
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF ((request->direction="O"))
  SELECT INTO "NL:"
   FROM code_value cv1,
    order_catalog oc,
    code_value cv2,
    code_value cv3,
    code_value_outbound cva,
    code_value cv4
   PLAN (cv1
    WHERE cv1.code_set=200)
    JOIN (oc
    WHERE oc.catalog_cd=cv1.code_value
     AND parser(act_type_list))
    JOIN (cv2
    WHERE cv2.code_value=oc.catalog_type_cd
     AND cv2.active_ind=1)
    JOIN (cv3
    WHERE cv3.code_value=oc.activity_type_cd
     AND cv3.active_ind=1)
    JOIN (cva
    WHERE cva.code_value=outerjoin(oc.catalog_cd)
     AND cva.contributor_source_cd=outerjoin(request->contributor_source_code_value))
    JOIN (cv4
    WHERE cv4.code_value=outerjoin(oc.activity_subtype_cd)
     AND cv4.active_ind=outerjoin(1))
   ORDER BY oc.catalog_cd
   DETAIL
    IF (cva.alias IN (" ", null))
     tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].cat_type_disp = cv2
     .display,
     temp->tqual[tcnt].act_type_disp = cv3.display, temp->tqual[tcnt].code_value = cv1.code_value,
     temp->tqual[tcnt].primary_mnem = cv1.display,
     temp->tqual[tcnt].description = cv1.description, temp->tqual[tcnt].subactivity_type = cv4
     .display, temp->tqual[tcnt].active_ind = cv1.active_ind
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->collist,9)
 SET reply->collist[1].header_text = "Catalog Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Activity Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Contributor Source"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Direction"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Code Value"
 SET reply->collist[5].data_type = 2
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Primary Name"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Orderable Description"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Subactivity Type"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Active Indicator"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 DECLARE contr_disp = vc
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE (cv.code_value=request->contributor_source_code_value)
   AND cv.active_ind=1
  DETAIL
   contr_disp = cv.display
  WITH nocounter
 ;end select
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,9)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].cat_type_disp
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].act_type_disp
   SET reply->rowlist[row_nbr].celllist[3].string_value = contr_disp
   IF ((request->direction="I"))
    SET reply->rowlist[row_nbr].celllist[4].string_value = "Inbound"
   ELSE
    SET reply->rowlist[row_nbr].celllist[4].string_value = "Outbound"
   ENDIF
   SET reply->rowlist[row_nbr].celllist[5].double_value = temp->tqual[x].code_value
   SET reply->rowlist[row_nbr].celllist[6].string_value = temp->tqual[x].primary_mnem
   SET reply->rowlist[row_nbr].celllist[7].string_value = temp->tqual[x].description
   SET reply->rowlist[row_nbr].celllist[8].string_value = temp->tqual[x].subactivity_type
   IF ((temp->tqual[x].active_ind=1))
    SET reply->rowlist[row_nbr].celllist[9].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[9].string_value = " "
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("orders_without_aliases.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
