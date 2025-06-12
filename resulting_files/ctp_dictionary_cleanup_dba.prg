CREATE PROGRAM ctp_dictionary_cleanup:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Report Type:" = "",
  "Look Back Days:" = "",
  "Time:" = ""
  WITH outdev, report_type, days_back,
  time
 RECORD prompts_dates(
   1 temp_date = dq8
   1 comp_date = di4
   1 comp_time = ti4
   1 report_type = vc
   1 days_back = vc
   1 time = i4
 ) WITH protect
 RECORD objects(
   1 obj_cnt = i4
   1 obj_qual[*]
     2 object_name = vc
     2 group = i1
     2 datestamp = di4
     2 timestamp = ti4
 ) WITH protect
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE drop_parser = vc WITH protect, noconstant("")
 DECLARE group_name = vc WITH protect, noconstant("")
 DECLARE dba = vc WITH protect, constant("DBA")
 DECLARE groupn = vc WITH protect, constant("GROUP")
 DECLARE date_parser = vc WITH protect, noconstant("")
 DECLARE out_msg = vc WITH protect, noconstant("")
 IF (textlen(trim( $REPORT_TYPE)) > 0)
  IF ( NOT (cnvtupper( $REPORT_TYPE) IN ("A", "U")))
   SET out_msg = "Invalid Report Type entered, must be A or U"
   GO TO out_report
  ELSE
   SET prompts_dates->report_type =  $REPORT_TYPE
  ENDIF
 ELSE
  SET prompts_dates->report_type = "U"
 ENDIF
 IF (textlen(trim( $DAYS_BACK)) > 0)
  SET date_parser = build("curdate-", $DAYS_BACK)
 ELSE
  SET date_parser = "curdate-1"
 ENDIF
 IF (textlen(trim( $TIME)) > 0)
  SET prompts_dates->time = cnvtint( $TIME)
  IF ((prompts_dates->time >= 0)
   AND (prompts_dates->time <= 2359))
   SET prompts_dates->temp_date = cnvtdatetime(parser(date_parser),prompts_dates->time)
   SET prompts_dates->comp_time = cnvttime3(cnvttime(prompts_dates->time),2)
  ELSE
   SET out_msg = "Invalid Time entered, must be a value from 0 - 2359"
   GO TO out_report
  ENDIF
 ELSE
  SET prompts_dates->temp_date = cnvtdatetime(parser(date_parser),curtime)
  SET prompts_dates->comp_time = cnvttime3(cnvttime(curtime),2)
 ENDIF
 SET prompts_dates->comp_date = cnvtdate(prompts_dates->temp_date)
 SELECT INTO "nl:"
  FROM dprotect d
  PLAN (d
   WHERE d.object_name="CTPRT*"
    AND cnvtdatetime(d.datestamp,d.timestamp) < cnvtdatetime(prompts_dates->comp_date,prompts_dates->
    comp_time)
    AND d.object="P")
  ORDER BY d.object_name
  HEAD REPORT
   idx = 0
  DETAIL
   idx += 1
   IF (mod(idx,10)=1)
    stat = alterlist(objects->obj_qual,(idx+ 9))
   ENDIF
   objects->obj_qual[idx].object_name = d.object_name, objects->obj_qual[idx].group = d.group,
   objects->obj_qual[idx].datestamp = d.datestamp,
   objects->obj_qual[idx].timestamp = d.timestamp
  FOOT REPORT
   stat = alterlist(objects->obj_qual,idx), objects->obj_cnt = idx
  WITH nocounter
 ;end select
 IF ((prompts_dates->report_type="U"))
  FOR (oidx = 1 TO objects->obj_cnt)
    IF ((objects->obj_qual[oidx].group=0))
     SET group_name = dba
    ELSE
     SET group_name = build(groupn,objects->obj_qual[oidx].group)
    ENDIF
    SET drop_parser = build2("drop program ",objects->obj_qual[oidx].object_name,":",group_name," go"
     )
    CALL parser(drop_parser)
  ENDFOR
 ENDIF
#out_report
 IF ((objects->obj_cnt > 0))
  SELECT INTO  $OUTDEV
   object_name = trim(substring(1,30,objects->obj_qual[d.seq].object_name),3), group = evaluate(
    objects->obj_qual[d.seq].group,0,"DBA",1,"GROUP1",
    ""), datestamp = format(objects->obj_qual[d.seq].datestamp,"mm/dd/yy;;d"),
   timestamp = format(objects->obj_qual[d.seq].timestamp,"HH:MM;;M")
   FROM (dummyt d  WITH seq = objects->obj_cnt)
   WITH nocounter, format, separator = " "
  ;end select
 ELSE
  IF (textlen(trim(out_msg))=0)
   SET out_msg = "No Objects found"
  ENDIF
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   HEAD REPORT
    row + 2, col 5, out_msg,
    row + 1
   FOOT REPORT
    null
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_script
END GO
