CREATE PROGRAM cps_get_chart_list:dba
 FREE RECORD reply
 RECORD reply(
   1 chart_cnt = i4
   1 chart[*]
     2 chart_definition_id = f8
     2 chart_source_cd = f8
     2 chart_type_cd = f8
     2 chart_title = vc
     2 sex_cd = f8
     2 min_age = f8
     2 max_age = f8
     2 x_type_cd = f8
     2 y_type_cd = f8
     2 y_axis_min_val = f8
     2 y_axis_max_val = f8
     2 y_axis_unit_cd = f8
     2 x_axis_section1_min_val = f8
     2 x_axis_section1_max_val = f8
     2 x_axis_section2_min_val = f8
     2 x_axis_section2_max_val = f8
     2 x_axis_section2_multiplier = f8
     2 x_axis_section1_unit_cd = f8
     2 x_axis_section2_unit_cd = f8
     2 version = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE RECORD charts
 RECORD charts(
   1 chart_cnt = i4
   1 chart[*]
     2 chart_source_cd = f8
 )
 DECLARE ierrcode = i4 WITH protect, noconstant(0)
 DECLARE iloop = i4 WITH protect, noconstant(0)
 DECLARE icount = i4 WITH protect, noconstant(0)
 SELECT INTO "NL:"
  FROM chart_definition chd,
   code_value cv
  PLAN (chd
   WHERE chd.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND chd.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND chd.active_ind=1)
   JOIN (cv
   WHERE cv.code_set=255550
    AND cv.code_value=chd.chart_source_cd
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY cv.collation_seq, chd.chart_source_cd, chd.min_age,
   chd.max_age
  HEAD REPORT
   knt = 0, stat = alterlist(charts->chart,10)
  HEAD chd.chart_source_cd
   knt = (knt+ 1)
   IF (mod(knt,10)=1)
    stat = alterlist(charts->chart,(knt+ 9))
   ENDIF
   charts->chart[knt].chart_source_cd = chd.chart_source_cd
  FOOT  chd.chart_source_cd
   row + 0
  FOOT REPORT
   charts->chart_cnt = knt, stat = alterlist(charts->chart,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (((ierrcode > 0) OR ((charts->chart_cnt <= 0))) )
  SET failed = select_error
  SET table_name = "CHART_DEFINITION"
  GO TO exit_script
 ENDIF
 FOR (iloop = 1 TO charts->chart_cnt)
   SET ierrcode = 0
   SELECT INTO "NL:"
    FROM chart_definition chd,
     code_value cv
    PLAN (chd
     WHERE (chd.chart_source_cd=charts->chart[iloop].chart_source_cd)
      AND chd.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND chd.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND chd.active_ind=1)
     JOIN (cv
     WHERE cv.code_set=255551
      AND cv.code_value=chd.chart_type_cd
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    ORDER BY cv.collation_seq, chd.chart_type_cd, chd.sex_cd,
     chd.min_age, chd.max_age
    HEAD REPORT
     stat = alterlist(reply->chart,(icount+ 10))
    DETAIL
     icount = (icount+ 1)
     IF (mod(icount,10)=1)
      stat = alterlist(reply->chart,(icount+ 9))
     ENDIF
     reply->chart[icount].chart_definition_id = chd.chart_definition_id, reply->chart[icount].
     chart_source_cd = chd.chart_source_cd, reply->chart[icount].chart_type_cd = chd.chart_type_cd,
     reply->chart[icount].sex_cd = chd.sex_cd, reply->chart[icount].min_age = chd.min_age, reply->
     chart[icount].max_age = chd.max_age,
     reply->chart[icount].chart_title = chd.chart_title, reply->chart[icount].x_type_cd = chd
     .x_type_cd, reply->chart[icount].y_type_cd = chd.y_type_cd,
     reply->chart[icount].y_axis_min_val = chd.y_axis_min_val, reply->chart[icount].y_axis_max_val =
     chd.y_axis_max_val, reply->chart[icount].y_axis_unit_cd = chd.y_axis_unit_cd,
     reply->chart[icount].x_axis_section1_min_val = chd.x_axis_section1_min_val, reply->chart[icount]
     .x_axis_section1_max_val = chd.x_axis_section1_max_val, reply->chart[icount].
     x_axis_section2_min_val = chd.x_axis_section2_min_val,
     reply->chart[icount].x_axis_section2_max_val = chd.x_axis_section2_max_val, reply->chart[icount]
     .x_axis_section2_multiplier = chd.x_axis_section2_multiplier, reply->chart[icount].
     x_axis_section1_unit_cd = chd.x_axis_section1_unit_cd,
     reply->chart[icount].x_axis_section2_unit_cd = chd.x_axis_section2_unit_cd, reply->chart[icount]
     .version = chd.version, reply->chart[icount].beg_effective_dt_tm = chd.beg_effective_dt_tm,
     reply->chart[icount].end_effective_dt_tm = chd.end_effective_dt_tm
    FOOT REPORT
     reply->chart_cnt = icount, stat = alterlist(reply->chart,icount)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "CHART_DEFINITION"
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 CALL echo("***")
 CALL echo("***   Exit Script")
 CALL echo("***")
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSEIF ((reply->chart_cnt > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
