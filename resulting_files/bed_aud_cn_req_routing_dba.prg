CREATE PROGRAM bed_aud_cn_req_routing:dba
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
   1 tcnt = i2
   1 tqual[*]
     2 route_id = f8
     2 req_route = vc
     2 param1 = vc
     2 param2 = vc
     2 param3 = vc
     2 param4 = vc
     2 param5 = vc
     2 values[*]
       3 value1 = vc
       3 value2 = vc
       3 value3 = vc
       3 value4 = vc
       3 value5 = vc
       3 printer = vc
 )
 DECLARE pharmacy = f8 WITH public, noconstant(0.0)
 DECLARE materialmgmt = f8 WITH public, noconstant(0.0)
 DECLARE surgery = f8 WITH public, noconstant(0.0)
 DECLARE supplies = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning IN ("PHARMACY", "MATERIALMGMT", "SURGERY", "SUPPLIES")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="PHARMACY")
    pharmacy = cv.code_value
   ELSEIF (cv.cdf_meaning="MATERIALMGMT")
    materialmgmt = cv.code_value
   ELSEIF (cv.cdf_meaning="SURGERY")
    surgery = cv.code_value
   ELSEIF (cv.cdf_meaning="SUPPLIES")
    supplies = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM dcp_output_route dor,
    dcp_flex_rtg dfr
   PLAN (dor
    WHERE dor.route_description != " ")
    JOIN (dfr
    WHERE dfr.dcp_output_route_id=dor.dcp_output_route_id)
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
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM dcp_output_route dor,
   dcp_flex_rtg dfr,
   dcp_flex_printer dfp,
   code_value cvparam1,
   code_value cvparam2,
   code_value cvparam3,
   code_value cvparam4,
   code_value cvparam5,
   code_value cvvalue1,
   code_value cvvalue2,
   code_value cvvalue3,
   code_value cvvalue4,
   code_value cvvalue5
  PLAN (dor
   WHERE dor.route_description != " ")
   JOIN (dfr
   WHERE dfr.dcp_output_route_id=dor.dcp_output_route_id)
   JOIN (dfp
   WHERE dfp.dcp_flex_rtg_id=outerjoin(dfr.dcp_flex_rtg_id))
   JOIN (cvparam1
   WHERE cvparam1.code_value=outerjoin(dor.param1_cd)
    AND cvparam1.active_ind=outerjoin(1))
   JOIN (cvparam2
   WHERE cvparam2.code_value=outerjoin(dor.param2_cd)
    AND cvparam2.active_ind=outerjoin(1))
   JOIN (cvparam3
   WHERE cvparam3.code_value=outerjoin(dor.param3_cd)
    AND cvparam3.active_ind=outerjoin(1))
   JOIN (cvparam4
   WHERE cvparam4.code_value=outerjoin(dor.param4_cd)
    AND cvparam4.active_ind=outerjoin(1))
   JOIN (cvparam5
   WHERE cvparam5.code_value=outerjoin(dor.param5_cd)
    AND cvparam5.active_ind=outerjoin(1))
   JOIN (cvvalue1
   WHERE cvvalue1.code_value=outerjoin(dfr.value1_cd)
    AND cvvalue1.active_ind=outerjoin(1))
   JOIN (cvvalue2
   WHERE cvvalue2.code_value=outerjoin(dfr.value2_cd)
    AND cvvalue2.active_ind=outerjoin(1))
   JOIN (cvvalue3
   WHERE cvvalue3.code_value=outerjoin(dfr.value3_cd)
    AND cvvalue3.active_ind=outerjoin(1))
   JOIN (cvvalue4
   WHERE cvvalue4.code_value=outerjoin(dfr.value4_cd)
    AND cvvalue4.active_ind=outerjoin(1))
   JOIN (cvvalue5
   WHERE cvvalue5.code_value=outerjoin(dfr.value5_cd)
    AND cvvalue5.active_ind=outerjoin(1))
  ORDER BY dor.route_description, dor.dcp_output_route_id, dfr.dcp_flex_rtg_id
  HEAD dor.dcp_output_route_id
   tcnt = (tcnt+ 1), temp->tcnt = tcnt, stat = alterlist(temp->tqual,tcnt),
   temp->tqual[tcnt].route_id = dor.dcp_output_route_id, temp->tqual[tcnt].req_route = dor
   .route_description, temp->tqual[tcnt].param1 = cvparam1.display,
   temp->tqual[tcnt].param2 = cvparam2.display, temp->tqual[tcnt].param3 = cvparam3.display, temp->
   tqual[tcnt].param4 = cvparam4.display,
   temp->tqual[tcnt].param5 = cvparam5.display, vcnt = 0
  DETAIL
   vcnt = (vcnt+ 1), stat = alterlist(temp->tqual[tcnt].values,vcnt), temp->tqual[tcnt].values[vcnt].
   value1 = cvvalue1.display,
   temp->tqual[tcnt].values[vcnt].value2 = cvvalue2.display, temp->tqual[tcnt].values[vcnt].value3 =
   cvvalue3.display, temp->tqual[tcnt].values[vcnt].value4 = cvvalue4.display,
   temp->tqual[tcnt].values[vcnt].value5 = cvvalue5.display, temp->tqual[tcnt].values[vcnt].printer
    = dfp.printer_name
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,12)
 SET reply->collist[1].header_text = "Requisition Route"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Parameter 1"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Value 1"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Parameter 2"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Value 2"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Parameter 3"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Value 3"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Parameter 4"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Value 4"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Parameter 5"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Value 5"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Printer"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,12)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].req_route
   SET vcnt = size(temp->tqual[x].values,5)
   FOR (v = 1 TO vcnt)
     SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].param1
     SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].values[v].value1
     SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].param2
     SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].values[v].value2
     SET reply->rowlist[row_nbr].celllist[6].string_value = temp->tqual[x].param3
     SET reply->rowlist[row_nbr].celllist[7].string_value = temp->tqual[x].values[v].value3
     SET reply->rowlist[row_nbr].celllist[8].string_value = temp->tqual[x].param4
     SET reply->rowlist[row_nbr].celllist[9].string_value = temp->tqual[x].values[v].value4
     SET reply->rowlist[row_nbr].celllist[10].string_value = temp->tqual[x].param5
     SET reply->rowlist[row_nbr].celllist[11].string_value = temp->tqual[x].values[v].value5
     SET reply->rowlist[row_nbr].celllist[12].string_value = temp->tqual[x].values[v].printer
     IF (v < vcnt)
      SET row_nbr = (row_nbr+ 1)
      SET stat = alterlist(reply->rowlist,row_nbr)
      SET stat = alterlist(reply->rowlist[row_nbr].celllist,12)
     ENDIF
   ENDFOR
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("cn_requition_routing.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
