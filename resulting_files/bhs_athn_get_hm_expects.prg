CREATE PROGRAM bhs_athn_get_hm_expects
 FREE RECORD result
 RECORD result(
   1 sched[*]
     2 expect_sched_id = f8
     2 expect_sched_name = vc
     2 series[*]
       3 expect_series_id = f8
       3 expect_series_name = vc
       3 expect[*]
         4 expect_id = f8
         4 expect_name = vc
         4 frequency_value = i4
         4 frequency_unit_cd = f8
         4 step[*]
           5 expect_step_id = f8
           5 expect_step_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req966302
 RECORD req966302(
   1 last_load_dt_tm = dq8
 ) WITH protect
 FREE RECORD rep966302
 RECORD rep966302(
   1 load_dt_tm = dq8
   1 sched[*]
     2 expect_sched_id = f8
     2 expect_sched_name = vc
     2 expect_sched_meaning = vc
     2 expect_sched_type_flag = i2
     2 expect_sched_loc_cd = f8
     2 expect_sched_loc_disp = vc
     2 expect_sched_loc_mean = vc
     2 on_time_start_age = i4
     2 sched_level_flag = i2
     2 series[*]
       3 expect_series_id = f8
       3 expect_series_name = vc
       3 series_meaning = vc
       3 priority_meaning = vc
       3 priority_disp = vc
       3 priority_seq = i4
       3 rule_associated_ind = i2
       3 first_step_age = i4
       3 expect[*]
         4 expect_id = f8
         4 expect_name = vc
         4 expect_meaning = vc
         4 step_count = i4
         4 inverval_only_ind = i2
         4 seq_nbr = i4
         4 max_age = i4
         4 frequency_value = i4
         4 frequency_unit_cd = f8
         4 expect_count_hist_ind = i2
         4 step[*]
           5 expect_step_id = f8
           5 expect_step_name = vc
           5 step_meaning = vc
           5 valid_recommend_start_age = i4
           5 valid_recommend_end_age = i4
           5 step_nbr = i4
           5 max_interval_to_count = i4
           5 min_interval_to_count = i4
           5 min_interval_to_admin = i4
           5 recommended_interval = i4
           5 min_age = i4
           5 skip_age = i4
           5 due_duration = i4
           5 audience_flag = i4
           5 start_time_of_year = i4
           5 end_time_of_year = i4
           5 near_due_duration = i4
         4 satisfier[*]
           5 expect_sat_id = f8
           5 expect_sat_name = vc
           5 satisfier_meaning = vc
           5 parent_type_flag = i2
           5 parent_nbr = f8
           5 parent_value = vc
           5 seq_nbr = i4
           5 entry_type_cd = f8
           5 entry_type_disp = vc
           5 entry_type_mean = vc
           5 entry_nbr = f8
           5 entry_value = vc
           5 pending_duration = i4
           5 satisfied_duration = i4
           5 nomenclature_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callgetexprefdata(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE kdx = i4 WITH protect, noconstant(0)
 DECLARE ldx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 SET stat = callgetexprefdata(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  DECLARE v3 = vc WITH protect, noconstant("")
  DECLARE v4 = vc WITH protect, noconstant("")
  DECLARE v5 = vc WITH protect, noconstant("")
  DECLARE v6 = vc WITH protect, noconstant("")
  DECLARE v7 = vc WITH protect, noconstant("")
  DECLARE v8 = vc WITH protect, noconstant("")
  DECLARE v9 = vc WITH protect, noconstant("")
  DECLARE v10 = vc WITH protect, noconstant("")
  DECLARE v11 = vc WITH protect, noconstant("")
  DECLARE v12 = vc WITH protect, noconstant("")
  DECLARE v13 = vc WITH protect, noconstant("")
  DECLARE v14 = vc WITH protect, noconstant("")
  DECLARE v15 = vc WITH protect, noconstant("")
  DECLARE v16 = vc WITH protect, noconstant("")
  DECLARE v17 = vc WITH protect, noconstant("")
  DECLARE v18 = vc WITH protect, noconstant("")
  DECLARE v19 = vc WITH protect, noconstant("")
  DECLARE v20 = vc WITH protect, noconstant("")
  DECLARE v21 = vc WITH protect, noconstant("")
  DECLARE v22 = vc WITH protect, noconstant("")
  IF ((rep966302->status_data.status="S"))
   SELECT INTO value(moutputdevice)
    FROM dummyt d
    PLAN (d
     WHERE d.seq > 0)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1, col + 1, "<Scheds>",
     row + 1
     FOR (idx = 1 TO size(result->sched,5))
       col + 1, "<Sched>", row + 1,
       v1 = build("<SchedId>",cnvtint(result->sched[idx].expect_sched_id),"</SchedId>"), col + 1, v1,
       row + 1, v2 = build("<SchedName>",trim(replace(replace(replace(replace(replace(result->sched[
              idx].expect_sched_name,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
          "&quot;",0),3),"</SchedName>"), col + 1,
       v2, row + 1, col + 1,
       "<Series>", row + 1
       FOR (jdx = 1 TO size(result->sched[idx].series,5))
         col + 1, "<SeriesItem>", row + 1,
         v3 = build("<SeriesId>",cnvtint(result->sched[idx].series[jdx].expect_series_id),
          "</SeriesId>"), col + 1, v3,
         row + 1, v4 = build("<SeriesName>",trim(replace(replace(replace(replace(replace(result->
                sched[idx].series[jdx].expect_series_name,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
             "'","&apos;",0),'"',"&quot;",0),3),"</SeriesName>"), col + 1,
         v4, row + 1, col + 1,
         "<Expects>", row + 1
         FOR (kdx = 1 TO size(result->sched[idx].series[jdx].expect,5))
           col + 1, "<Expect>", row + 1,
           v5 = build("<ExpectId>",cnvtint(result->sched[idx].series[jdx].expect[kdx].expect_id),
            "</ExpectId>"), col + 1, v5,
           row + 1, v6 = build("<ExpectName>",trim(replace(replace(replace(replace(replace(result->
                  sched[idx].series[jdx].expect[kdx].expect_name,"&","&amp;",0),"<","&lt;",0),">",
                "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</ExpectName>"), col + 1,
           v6, row + 1, v7 = build("<FrequencyValue>",result->sched[idx].series[jdx].expect[kdx].
            frequency_value,"</FrequencyValue>"),
           col + 1, v7, row + 1,
           v8 = build("<FrequencyUnitCd>",cnvtint(result->sched[idx].series[jdx].expect[kdx].
             frequency_unit_cd),"</FrequencyUnitCd>"), col + 1, v8,
           row + 1, col + 1, "<Steps>",
           row + 1
           FOR (ldx = 1 TO size(result->sched[idx].series[jdx].expect[kdx].step,5))
             col + 1, "<Step>", row + 1,
             v9 = build("<StepId>",cnvtint(result->sched[idx].series[jdx].expect[kdx].step[ldx].
               expect_step_id),"</StepId>"), col + 1, v9,
             row + 1, v10 = build("<StepName>",trim(replace(replace(replace(replace(replace(result->
                    sched[idx].series[jdx].expect[kdx].step[ldx].expect_step_name,"&","&amp;",0),"<",
                   "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</StepName>"), col + 1,
             v10, row + 1, col + 1,
             "<Step>", row + 1
           ENDFOR
           col + 1, "</Steps>", row + 1,
           col + 1, "<Expect>", row + 1
         ENDFOR
         col + 1, "</Expects>", row + 1,
         col + 1, "</SeriesItem>", row + 1
       ENDFOR
       col + 1, "</Series>", row + 1,
       col + 1, "</Sched>", row + 1
     ENDFOR
     col + 1, "</Scheds>", row + 1,
     col + 1, "</ReplyMessage>", row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
  ENDIF
 ENDIF
 FREE RECORD result
 FREE RECORD req966302
 FREE RECORD rep966302
 SUBROUTINE callgetexprefdata(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(966310)
   DECLARE requestid = i4 WITH protect, constant(966302)
   DECLARE health_maintenance_flag = i4 WITH protect, constant(0)
   DECLARE expect_sched_cnt = i4 WITH protect, noconstant(0)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req966302,
    "REC",rep966302,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep966302)
   IF ((rep966302->status_data.status != "F"))
    SET stat = alterlist(result->sched,size(rep966302->sched,5))
    FOR (idx = 1 TO size(rep966302->sched,5))
      IF ((rep966302->sched[idx].expect_sched_type_flag=health_maintenance_flag))
       SET expect_sched_cnt = (expect_sched_cnt+ 1)
       SET result->sched[expect_sched_cnt].expect_sched_id = rep966302->sched[idx].expect_sched_id
       SET result->sched[expect_sched_cnt].expect_sched_name = rep966302->sched[idx].
       expect_sched_name
       SET stat = alterlist(result->sched[expect_sched_cnt].series,size(rep966302->sched[idx].series,
         5))
       FOR (jdx = 1 TO size(rep966302->sched[idx].series,5))
         SET result->sched[expect_sched_cnt].series[jdx].expect_series_id = rep966302->sched[idx].
         series[jdx].expect_series_id
         SET result->sched[expect_sched_cnt].series[jdx].expect_series_name = rep966302->sched[idx].
         series[jdx].expect_series_name
         SET stat = alterlist(result->sched[expect_sched_cnt].series[jdx].expect,size(rep966302->
           sched[idx].series[jdx].expect,5))
         FOR (kdx = 1 TO size(rep966302->sched[idx].series[jdx].expect,5))
           SET result->sched[expect_sched_cnt].series[jdx].expect[kdx].expect_id = rep966302->sched[
           idx].series[jdx].expect[kdx].expect_id
           SET result->sched[expect_sched_cnt].series[jdx].expect[kdx].expect_name = rep966302->
           sched[idx].series[jdx].expect[kdx].expect_name
           SET result->sched[expect_sched_cnt].series[jdx].expect[kdx].frequency_value = rep966302->
           sched[idx].series[jdx].expect[kdx].frequency_value
           SET result->sched[expect_sched_cnt].series[jdx].expect[kdx].frequency_unit_cd = rep966302
           ->sched[idx].series[jdx].expect[kdx].frequency_unit_cd
           SET stat = alterlist(result->sched[expect_sched_cnt].series[jdx].expect[kdx].step,size(
             rep966302->sched[idx].series[jdx].expect[kdx].step,5))
           FOR (ldx = 1 TO size(rep966302->sched[idx].series[jdx].expect[kdx].step,5))
            SET result->sched[expect_sched_cnt].series[jdx].expect[kdx].step[ldx].expect_step_id =
            rep966302->sched[idx].series[jdx].expect[kdx].step[ldx].expect_step_id
            SET result->sched[expect_sched_cnt].series[jdx].expect[kdx].step[ldx].expect_step_name =
            rep966302->sched[idx].series[jdx].expect[kdx].step[ldx].expect_step_name
           ENDFOR
         ENDFOR
       ENDFOR
      ENDIF
    ENDFOR
    SET stat = alterlist(result->sched,expect_sched_cnt)
    CALL echorecord(result)
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
