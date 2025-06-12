CREATE PROGRAM bed_aud_clinrpt_trig_cht_fmt:dba
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
     2 trigger_name = vc
     2 trigger_id = f8
     2 chart_format_name = vc
     2 chart_format_id = f8
 )
 SET hi18n = 0
 SET stat = uar_i18nlocalizationinit(hi18n,curprog,"",curcclrev)
 IF ( NOT (validate(trig_name)))
  DECLARE trig_name = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_TRIG_CHT_FMT.TRIG_NAME","Trigger Name"))
 ENDIF
 IF ( NOT (validate(chart_format)))
  DECLARE chart_format = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_TRIG_CHT_FMT.CHART_FORMAT","Chart Format"))
 ENDIF
 DECLARE trig_nbr = i4 WITH noconstant(0)
 DECLARE row_nbr = i4 WITH noconstant(0)
 SET stat = alterlist(reply->collist,2)
 SET reply->collist[1].header_text = trig_name
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = chart_format
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SELECT DISTINCT INTO "nl:"
  FROM chart_trigger ct,
   chart_format cf
  PLAN (ct
   WHERE ct.chart_trigger_id > 0
    AND ct.chart_trigger_id=ct.prev_chart_trigger_id
    AND ct.active_ind=1
    AND ct.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (cf
   WHERE cf.chart_format_id=ct.chart_format_id
    AND cf.chart_format_id > 0)
  ORDER BY cnvtupper(ct.trigger_name)
  HEAD REPORT
   trig_nbr = 0
  DETAIL
   trig_nbr = (trig_nbr+ 1)
   IF (mod(trig_nbr,10)=1)
    stat = alterlist(triggers->trigger,(trig_nbr+ 9))
   ENDIF
   triggers->trigger[trig_nbr].trigger_name = ct.trigger_name, triggers->trigger[trig_nbr].trigger_id
    = ct.chart_trigger_id, triggers->trigger[trig_nbr].chart_format_name = cf.chart_format_desc,
   triggers->trigger[trig_nbr].chart_format_id = cf.chart_format_id
  FOOT REPORT
   stat = alterlist(triggers->trigger,trig_nbr)
  WITH nocounter
 ;end select
 CALL echorecord(triggers)
 IF (trig_nbr=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->rowlist,trig_nbr)
 FOR (row_nbr = 1 TO trig_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,2)
   SET reply->rowlist[row_nbr].celllist[1].string_value = build2(triggers->trigger[row_nbr].
    trigger_name," (",trim(cnvtstringchk(triggers->trigger[row_nbr].trigger_id)),")")
   SET reply->rowlist[row_nbr].celllist[2].string_value = build2(triggers->trigger[row_nbr].
    chart_format_name," (",trim(cnvtstringchk(triggers->trigger[row_nbr].chart_format_id)),")")
 ENDFOR
 CALL echorecord(reply)
#exit_script
END GO
