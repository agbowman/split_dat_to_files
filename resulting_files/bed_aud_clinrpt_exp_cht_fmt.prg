CREATE PROGRAM bed_aud_clinrpt_exp_cht_fmt
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
        3 string_value = vc
  )
 ENDIF
 FREE RECORD triggers
 RECORD triggers(
   1 trigger[*]
     2 expedite_name = vc
     2 param_name = vc
     2 chart_format_name = vc
 )
 SET tcnt = 0
 SELECT DISTINCT INTO "NL:"
  FROM expedite_trigger et,
   expedite_params_r epr,
   expedite_params ep,
   chart_format cf
  PLAN (et
   WHERE et.expedite_trigger_id > 0
    AND et.active_ind=1)
   JOIN (epr
   WHERE epr.expedite_trigger_id=et.expedite_trigger_id)
   JOIN (ep
   WHERE ep.expedite_params_id=epr.expedite_params_id)
   JOIN (cf
   WHERE cf.chart_format_id=ep.chart_format_id
    AND cf.chart_format_id > 0)
  ORDER BY et.name, ep.name, ep.chart_format_id
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(triggers->trigger,tcnt), triggers->trigger[tcnt].expedite_name
    = et.name,
   triggers->trigger[tcnt].param_name = ep.name, triggers->trigger[tcnt].chart_format_name = cf
   .chart_format_desc
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,3)
 SET reply->collist[1].header_text = "Expedite Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Param Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Chart Format"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (t = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,3)
   SET reply->rowlist[row_nbr].celllist[1].string_value = triggers->trigger[t].expedite_name
   SET reply->rowlist[row_nbr].celllist[2].string_value = triggers->trigger[t].param_name
   SET reply->rowlist[row_nbr].celllist[3].string_value = triggers->trigger[t].chart_format_name
 ENDFOR
#exit_script
END GO
