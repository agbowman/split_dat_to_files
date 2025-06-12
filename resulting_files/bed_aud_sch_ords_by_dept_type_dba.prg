CREATE PROGRAM bed_aud_sch_ords_by_dept_type:dba
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
   1 tqual[*]
     2 dept_type = vc
     2 catalog_type = vc
     2 activity_type = vc
     2 activity_subtype = vc
     2 orderables[*]
       3 primary_mnemonic = vc
 )
 SET reply->status_data.status = "S"
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   FROM br_sched_dept_type_r br1,
    br_sched_dept_type br2,
    code_value cv1,
    code_value cv2,
    code_value cv3,
    order_catalog oc
   PLAN (br1)
    JOIN (br2
    WHERE br2.dept_type_id=br1.dept_type_id)
    JOIN (cv1
    WHERE cv1.code_value=outerjoin(br1.catalog_type_cd)
     AND cv1.active_ind=outerjoin(1))
    JOIN (cv2
    WHERE cv2.code_value=outerjoin(br1.activity_type_cd)
     AND cv2.active_ind=outerjoin(1))
    JOIN (cv3
    WHERE cv3.code_value=outerjoin(br1.activity_subtype_cd)
     AND cv3.active_ind=outerjoin(1))
    JOIN (oc
    WHERE oc.catalog_type_cd=outerjoin(br1.catalog_type_cd)
     AND oc.active_ind=outerjoin(1))
   ORDER BY br2.dept_type_display, cv1.display, cv2.display,
    cv3.display, br1.dept_type_id, cnvtupper(oc.primary_mnemonic)
   HEAD br1.dept_type_id
    IF (((cv1.code_value > 0
     AND cv1.active_ind=0) OR (((cv2.code_value > 0
     AND cv2.active_ind=0) OR (cv3.code_value > 0
     AND cv3.active_ind=0)) )) )
     high_volume_cnt = high_volume_cnt
    ELSE
     high_volume_cnt = (high_volume_cnt+ 1)
    ENDIF
   HEAD oc.primary_mnemonic
    IF (oc.catalog_cd > 0
     AND oc.active_ind=1)
     IF (((br1.activity_type_cd=0) OR (br1.activity_type_cd > 0
      AND br1.activity_type_cd=oc.activity_type_cd))
      AND ((br1.activity_subtype_cd=0) OR (br1.activity_subtype_cd > 0
      AND br1.activity_subtype_cd=oc.activity_subtype_cd)) )
      high_volume_cnt = (high_volume_cnt+ 1)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 60000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 30000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM br_sched_dept_type_r br1,
   br_sched_dept_type br2,
   code_value cv1,
   code_value cv2,
   code_value cv3,
   order_catalog oc
  PLAN (br1)
   JOIN (br2
   WHERE br2.dept_type_id=br1.dept_type_id)
   JOIN (cv1
   WHERE cv1.code_value=outerjoin(br1.catalog_type_cd)
    AND cv1.active_ind=outerjoin(1))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(br1.activity_type_cd)
    AND cv2.active_ind=outerjoin(1))
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(br1.activity_subtype_cd)
    AND cv3.active_ind=outerjoin(1))
   JOIN (oc
   WHERE oc.catalog_type_cd=outerjoin(br1.catalog_type_cd)
    AND oc.active_ind=outerjoin(1))
  ORDER BY br2.dept_type_display, cv1.display, cv2.display,
   cv3.display, br1.dept_type_id, cnvtupper(oc.primary_mnemonic)
  HEAD br1.dept_type_id
   IF (((cv1.code_value > 0
    AND cv1.active_ind=0) OR (((cv2.code_value > 0
    AND cv2.active_ind=0) OR (cv3.code_value > 0
    AND cv3.active_ind=0)) )) )
    tcnt = tcnt
   ELSE
    tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].dept_type = br2
    .dept_type_display,
    temp->tqual[tcnt].catalog_type = cv1.display, temp->tqual[tcnt].activity_type = cv2.display, temp
    ->tqual[tcnt].activity_subtype = cv3.display,
    ocnt = 0
   ENDIF
  HEAD oc.primary_mnemonic
   IF (oc.catalog_cd > 0
    AND oc.active_ind=1)
    IF (((br1.activity_type_cd=0) OR (br1.activity_type_cd > 0
     AND br1.activity_type_cd=oc.activity_type_cd))
     AND ((br1.activity_subtype_cd=0) OR (br1.activity_subtype_cd > 0
     AND br1.activity_subtype_cd=oc.activity_subtype_cd)) )
     ocnt = (ocnt+ 1), stat = alterlist(temp->tqual[tcnt].orderables,ocnt), temp->tqual[tcnt].
     orderables[ocnt].primary_mnemonic = oc.primary_mnemonic
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "Department Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Order Catalog Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Activity Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Activity Subtype"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Orderable Item"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,5)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].dept_type
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].catalog_type
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].activity_type
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].activity_subtype
   SET ocnt = size(temp->tqual[x].orderables,5)
   IF (ocnt > 0)
    SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].orderables[1].
    primary_mnemonic
    FOR (o = 2 TO ocnt)
      SET row_nbr = (row_nbr+ 1)
      SET stat = alterlist(reply->rowlist,row_nbr)
      SET stat = alterlist(reply->rowlist[row_nbr].celllist,5)
      SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].orderables[o].
      primary_mnemonic
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("suggested_orders_by_dept_type.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
