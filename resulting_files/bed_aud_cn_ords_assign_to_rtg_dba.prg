CREATE PROGRAM bed_aud_cn_ords_assign_to_rtg:dba
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
     2 mnemonic = vc
     2 req_route = vc
     2 req_format = vc
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SET tcnt = 0
  SELECT INTO "nl:"
   FROM order_catalog oc,
    dcp_output_route dor,
    code_value cv
   PLAN (oc
    WHERE ((oc.requisition_routing_cd > 0) OR (oc.requisition_format_cd > 0))
     AND oc.active_ind=1)
    JOIN (dor
    WHERE dor.dcp_output_route_id=outerjoin(oc.requisition_routing_cd)
     AND dor.route_description > outerjoin(" "))
    JOIN (cv
    WHERE cv.code_value=outerjoin(oc.requisition_format_cd)
     AND cv.active_ind=outerjoin(1))
   HEAD REPORT
    tcnt = 0
   DETAIL
    IF (((dor.dcp_output_route_id > 0) OR (cv.code_value > 0)) )
     tcnt = (tcnt+ 1)
    ENDIF
   FOOT REPORT
    high_volume_cnt = tcnt
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
 SET stat = alterlist(reply->collist,3)
 SET reply->collist[1].header_text = "Millennium Name (Primary Synonym)"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Requisition Format"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Requisition Route"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM order_catalog oc,
   dcp_output_route dor,
   code_value cv
  PLAN (oc
   WHERE ((oc.requisition_routing_cd > 0) OR (oc.requisition_format_cd > 0))
    AND oc.active_ind=1)
   JOIN (dor
   WHERE dor.dcp_output_route_id=outerjoin(oc.requisition_routing_cd)
    AND dor.route_description > outerjoin(" "))
   JOIN (cv
   WHERE cv.code_value=outerjoin(oc.requisition_format_cd)
    AND cv.active_ind=outerjoin(1))
  ORDER BY oc.primary_mnemonic
  HEAD oc.primary_mnemonic
   IF (((dor.dcp_output_route_id > 0) OR (cv.code_value > 0)) )
    row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->
     rowlist[row_nbr].celllist,3),
    reply->rowlist[row_nbr].celllist[1].string_value = oc.primary_mnemonic
    IF (cv.code_value > 0)
     reply->rowlist[row_nbr].celllist[2].string_value = cv.display
    ELSE
     reply->rowlist[row_nbr].celllist[2].string_value = "<None>"
    ENDIF
    IF (dor.dcp_output_route_id > 0)
     reply->rowlist[row_nbr].celllist[3].string_value = dor.route_description
    ELSE
     reply->rowlist[row_nbr].celllist[3].string_value = "<None>"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("cn_orders_assigned_to_req_routing.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
