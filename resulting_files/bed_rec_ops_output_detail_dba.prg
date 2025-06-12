CREATE PROGRAM bed_rec_ops_output_detail:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 paramlist[*]
      2 meaning = vc
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET col_cnt = 13
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Check Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Request Number"
 SET reply->collist[3].data_type = 3
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Request Name"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Step Number"
 SET reply->collist[5].data_type = 3
 SET reply->collist[5].hide_ind = 1
 SET reply->collist[6].header_text = "Step Name"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Active Indicator"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Autostart Indicator"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Enable Indicator"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Beginning Effective Date"
 SET reply->collist[10].data_type = 4
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Ending Effective Date"
 SET reply->collist[11].data_type = 4
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Frequency Type"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Recommendation"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 DECLARE short_desc = vc
 DECLARE recommendation_txt = vc
 SET reply->run_status_flag = 1
 SET row_tot_cnt = 0
 SET plsize = size(request->paramlist,5)
 FOR (plcnt = 1 TO plsize)
   IF ((request->paramlist[plcnt].meaning="OPSPATHNETRESREC"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="OPSPATHNETRESREC")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM ops_job_step ojs,
      ops_job oj,
      ops_task ot,
      request r,
      ops_control_group ocg,
      ops_schedule_job_step ocjs
     PLAN (ojs
      WHERE ojs.request_number=250218
       AND ojs.active_ind=1)
      JOIN (oj
      WHERE oj.ops_job_id=ojs.ops_job_id
       AND oj.active_ind=1)
      JOIN (ot
      WHERE ot.ops_job_id=outerjoin(oj.ops_job_id)
       AND ot.active_ind=outerjoin(1))
      JOIN (r
      WHERE r.request_number=ojs.request_number
       AND r.active_ind=1)
      JOIN (ocg
      WHERE ocg.ops_control_grp_id=outerjoin(ot.ops_control_grp_id)
       AND ocg.ops_control_grp_id > outerjoin(0)
       AND ocg.host != outerjoin("SCOUT")
       AND ocg.host != outerjoin("STORM")
       AND ocg.active_ind=outerjoin(1))
      JOIN (ocjs
      WHERE ocjs.ops_job_step_id=ojs.ops_job_step_id)
     ORDER BY ojs.ops_job_id
     HEAD ojs.ops_job_id
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = oj.name, reply->rowlist[row_tot_cnt].celllist[3].nbr_value = ojs
      .request_number,
      reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
      row_tot_cnt].celllist[5].nbr_value = ojs.step_number, reply->rowlist[row_tot_cnt].celllist[6].
      string_value = ojs.step_name
      IF (oj.active_ind=1)
       reply->rowlist[row_tot_cnt].celllist[7].string_value = "X"
      ENDIF
      IF (ot.ops_task_id > 0)
       IF (ot.autostart_ind=1)
        reply->rowlist[row_tot_cnt].celllist[8].string_value = "X"
       ENDIF
       IF (ot.enable_ind=1)
        reply->rowlist[row_tot_cnt].celllist[9].string_value = "X"
       ENDIF
       reply->rowlist[row_tot_cnt].celllist[10].date_value = ot.beg_effective_dt_tm, reply->rowlist[
       row_tot_cnt].celllist[11].date_value = ot.end_effective_dt_tm
       IF (ot.frequency_type=1)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "One Time"
       ELSEIF (ot.frequency_type=2)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Daily"
       ELSEIF (ot.frequency_type=3)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Weekly"
       ELSEIF (ot.frequency_type=4)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Day of Month"
       ELSEIF (ot.frequency_type=5)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Week of Month"
       ENDIF
      ELSE
       reply->rowlist[row_tot_cnt].celllist[8].string_value = "No scheduled instances of this job."
      ENDIF
      reply->rowlist[row_tot_cnt].celllist[13].string_value = recommendation_txt
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM request r
      PLAN (r
       WHERE r.request_number=250218
        AND r.active_ind=1)
      DETAIL
       row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
        = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
       reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt]
       .celllist[2].string_value = "No scheduled jobs found", reply->rowlist[row_tot_cnt].celllist[3]
       .nbr_value = r.request_number,
       reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
       row_tot_cnt].celllist[13].string_value = recommendation_txt
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((request->paramlist[plcnt].meaning="OPSAPBATCHREPORT"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="OPSAPBATCHREPORT")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM ops_job_step ojs,
      ops_job oj,
      ops_task ot,
      request r,
      ops_control_group ocg,
      ops_schedule_job_step ocjs
     PLAN (ojs
      WHERE ojs.request_number=200296
       AND ojs.active_ind=1)
      JOIN (oj
      WHERE oj.ops_job_id=ojs.ops_job_id
       AND oj.active_ind=1)
      JOIN (ot
      WHERE ot.ops_job_id=outerjoin(oj.ops_job_id)
       AND ot.active_ind=outerjoin(1))
      JOIN (r
      WHERE r.request_number=ojs.request_number
       AND r.active_ind=1)
      JOIN (ocg
      WHERE ocg.ops_control_grp_id=outerjoin(ot.ops_control_grp_id)
       AND ocg.ops_control_grp_id > outerjoin(0)
       AND ocg.host != outerjoin("SCOUT")
       AND ocg.host != outerjoin("STORM")
       AND ocg.active_ind=outerjoin(1))
      JOIN (ocjs
      WHERE ocjs.ops_job_step_id=ojs.ops_job_step_id)
     ORDER BY ojs.ops_job_id
     HEAD ojs.ops_job_id
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = oj.name, reply->rowlist[row_tot_cnt].celllist[3].nbr_value = ojs
      .request_number,
      reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
      row_tot_cnt].celllist[5].nbr_value = ojs.step_number, reply->rowlist[row_tot_cnt].celllist[6].
      string_value = ojs.step_name
      IF (oj.active_ind=1)
       reply->rowlist[row_tot_cnt].celllist[7].string_value = "X"
      ENDIF
      IF (ot.ops_task_id > 0)
       IF (ot.autostart_ind=1)
        reply->rowlist[row_tot_cnt].celllist[8].string_value = "X"
       ENDIF
       IF (ot.enable_ind=1)
        reply->rowlist[row_tot_cnt].celllist[9].string_value = "X"
       ENDIF
       reply->rowlist[row_tot_cnt].celllist[10].date_value = ot.beg_effective_dt_tm, reply->rowlist[
       row_tot_cnt].celllist[11].date_value = ot.end_effective_dt_tm
       IF (ot.frequency_type=1)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "One Time"
       ELSEIF (ot.frequency_type=2)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Daily"
       ELSEIF (ot.frequency_type=3)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Weekly"
       ELSEIF (ot.frequency_type=4)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Day of Month"
       ELSEIF (ot.frequency_type=5)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Week of Month"
       ENDIF
      ELSE
       reply->rowlist[row_tot_cnt].celllist[8].string_value = "No scheduled instances of this job."
      ENDIF
      reply->rowlist[row_tot_cnt].celllist[13].string_value = recommendation_txt
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM request r
      PLAN (r
       WHERE r.request_number=200296
        AND r.active_ind=1)
      DETAIL
       row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
        = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
       reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt]
       .celllist[2].string_value = "No scheduled jobs found", reply->rowlist[row_tot_cnt].celllist[3]
       .nbr_value = r.request_number,
       reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
       row_tot_cnt].celllist[13].string_value = recommendation_txt
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((request->paramlist[plcnt].meaning="OPSAPRESENDORDS"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="OPSAPRESENDORDS")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM ops_job_step ojs,
      ops_job oj,
      ops_task ot,
      request r,
      ops_control_group ocg,
      ops_schedule_job_step ocjs
     PLAN (ojs
      WHERE ojs.request_number=200386
       AND ojs.active_ind=1)
      JOIN (oj
      WHERE oj.ops_job_id=ojs.ops_job_id
       AND oj.active_ind=1)
      JOIN (ot
      WHERE ot.ops_job_id=outerjoin(oj.ops_job_id)
       AND ot.active_ind=outerjoin(1))
      JOIN (r
      WHERE r.request_number=ojs.request_number
       AND r.active_ind=1)
      JOIN (ocg
      WHERE ocg.ops_control_grp_id=outerjoin(ot.ops_control_grp_id)
       AND ocg.ops_control_grp_id > outerjoin(0)
       AND ocg.host != outerjoin("SCOUT")
       AND ocg.host != outerjoin("STORM")
       AND ocg.active_ind=outerjoin(1))
      JOIN (ocjs
      WHERE ocjs.ops_job_step_id=ojs.ops_job_step_id)
     ORDER BY ojs.ops_job_id
     HEAD ojs.ops_job_id
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = oj.name, reply->rowlist[row_tot_cnt].celllist[3].nbr_value = ojs
      .request_number,
      reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
      row_tot_cnt].celllist[5].nbr_value = ojs.step_number, reply->rowlist[row_tot_cnt].celllist[6].
      string_value = ojs.step_name
      IF (oj.active_ind=1)
       reply->rowlist[row_tot_cnt].celllist[7].string_value = "X"
      ENDIF
      IF (ot.ops_task_id > 0)
       IF (ot.autostart_ind=1)
        reply->rowlist[row_tot_cnt].celllist[8].string_value = "X"
       ENDIF
       IF (ot.enable_ind=1)
        reply->rowlist[row_tot_cnt].celllist[9].string_value = "X"
       ENDIF
       reply->rowlist[row_tot_cnt].celllist[10].date_value = ot.beg_effective_dt_tm, reply->rowlist[
       row_tot_cnt].celllist[11].date_value = ot.end_effective_dt_tm
       IF (ot.frequency_type=1)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "One Time"
       ELSEIF (ot.frequency_type=2)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Daily"
       ELSEIF (ot.frequency_type=3)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Weekly"
       ELSEIF (ot.frequency_type=4)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Day of Month"
       ELSEIF (ot.frequency_type=5)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Week of Month"
       ENDIF
      ELSE
       reply->rowlist[row_tot_cnt].celllist[8].string_value = "No scheduled instances of this job."
      ENDIF
      reply->rowlist[row_tot_cnt].celllist[13].string_value = recommendation_txt
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM request r
      PLAN (r
       WHERE r.request_number=200386
        AND r.active_ind=1)
      DETAIL
       row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
        = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
       reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt]
       .celllist[2].string_value = "No scheduled jobs found", reply->rowlist[row_tot_cnt].celllist[3]
       .nbr_value = r.request_number,
       reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
       row_tot_cnt].celllist[13].string_value = recommendation_txt
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((request->paramlist[plcnt].meaning="OPSBBCLINEVENT"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="OPSBBCLINEVENT")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM ops_job_step ojs,
      ops_job oj,
      ops_task ot,
      request r,
      ops_control_group ocg,
      ops_schedule_job_step ocjs
     PLAN (ojs
      WHERE ojs.request_number=225625
       AND ojs.active_ind=1)
      JOIN (oj
      WHERE oj.ops_job_id=ojs.ops_job_id
       AND oj.active_ind=1)
      JOIN (ot
      WHERE ot.ops_job_id=outerjoin(oj.ops_job_id)
       AND ot.active_ind=outerjoin(1))
      JOIN (r
      WHERE r.request_number=ojs.request_number
       AND r.active_ind=1)
      JOIN (ocg
      WHERE ocg.ops_control_grp_id=outerjoin(ot.ops_control_grp_id)
       AND ocg.ops_control_grp_id > outerjoin(0)
       AND ocg.host != outerjoin("SCOUT")
       AND ocg.host != outerjoin("STORM")
       AND ocg.active_ind=outerjoin(1))
      JOIN (ocjs
      WHERE ocjs.ops_job_step_id=ojs.ops_job_step_id)
     ORDER BY ojs.ops_job_id
     HEAD ojs.ops_job_id
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = oj.name, reply->rowlist[row_tot_cnt].celllist[3].nbr_value = ojs
      .request_number,
      reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
      row_tot_cnt].celllist[5].nbr_value = ojs.step_number, reply->rowlist[row_tot_cnt].celllist[6].
      string_value = ojs.step_name
      IF (oj.active_ind=1)
       reply->rowlist[row_tot_cnt].celllist[7].string_value = "X"
      ENDIF
      IF (ot.ops_task_id > 0)
       IF (ot.autostart_ind=1)
        reply->rowlist[row_tot_cnt].celllist[8].string_value = "X"
       ENDIF
       IF (ot.enable_ind=1)
        reply->rowlist[row_tot_cnt].celllist[9].string_value = "X"
       ENDIF
       reply->rowlist[row_tot_cnt].celllist[10].date_value = ot.beg_effective_dt_tm, reply->rowlist[
       row_tot_cnt].celllist[11].date_value = ot.end_effective_dt_tm
       IF (ot.frequency_type=1)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "One Time"
       ELSEIF (ot.frequency_type=2)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Daily"
       ELSEIF (ot.frequency_type=3)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Weekly"
       ELSEIF (ot.frequency_type=4)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Day of Month"
       ELSEIF (ot.frequency_type=5)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Week of Month"
       ENDIF
      ELSE
       reply->rowlist[row_tot_cnt].celllist[8].string_value = "No scheduled instances of this job."
      ENDIF
      reply->rowlist[row_tot_cnt].celllist[13].string_value = recommendation_txt
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM request r
      PLAN (r
       WHERE r.request_number=225625
        AND r.active_ind=1)
      DETAIL
       row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
        = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
       reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt]
       .celllist[2].string_value = "No scheduled jobs found", reply->rowlist[row_tot_cnt].celllist[3]
       .nbr_value = r.request_number,
       reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
       row_tot_cnt].celllist[13].string_value = recommendation_txt
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((request->paramlist[plcnt].meaning="OPSBBSPECIMEN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="OPSBBSPECIMEN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM ops_job_step ojs,
      ops_job oj,
      ops_task ot,
      request r,
      ops_control_group ocg,
      ops_schedule_job_step ocjs
     PLAN (ojs
      WHERE ojs.request_number=225241
       AND ojs.active_ind=1)
      JOIN (oj
      WHERE oj.ops_job_id=ojs.ops_job_id
       AND oj.active_ind=1)
      JOIN (ot
      WHERE ot.ops_job_id=outerjoin(oj.ops_job_id)
       AND ot.active_ind=outerjoin(1))
      JOIN (r
      WHERE r.request_number=ojs.request_number
       AND r.active_ind=1)
      JOIN (ocg
      WHERE ocg.ops_control_grp_id=outerjoin(ot.ops_control_grp_id)
       AND ocg.ops_control_grp_id > outerjoin(0)
       AND ocg.host != outerjoin("SCOUT")
       AND ocg.host != outerjoin("STORM")
       AND ocg.active_ind=outerjoin(1))
      JOIN (ocjs
      WHERE ocjs.ops_job_step_id=ojs.ops_job_step_id)
     ORDER BY ojs.ops_job_id
     HEAD ojs.ops_job_id
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = oj.name, reply->rowlist[row_tot_cnt].celllist[3].nbr_value = ojs
      .request_number,
      reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
      row_tot_cnt].celllist[5].nbr_value = ojs.step_number, reply->rowlist[row_tot_cnt].celllist[6].
      string_value = ojs.step_name
      IF (oj.active_ind=1)
       reply->rowlist[row_tot_cnt].celllist[7].string_value = "X"
      ENDIF
      IF (ot.ops_task_id > 0)
       IF (ot.autostart_ind=1)
        reply->rowlist[row_tot_cnt].celllist[8].string_value = "X"
       ENDIF
       IF (ot.enable_ind=1)
        reply->rowlist[row_tot_cnt].celllist[9].string_value = "X"
       ENDIF
       reply->rowlist[row_tot_cnt].celllist[10].date_value = ot.beg_effective_dt_tm, reply->rowlist[
       row_tot_cnt].celllist[11].date_value = ot.end_effective_dt_tm
       IF (ot.frequency_type=1)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "One Time"
       ELSEIF (ot.frequency_type=2)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Daily"
       ELSEIF (ot.frequency_type=3)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Weekly"
       ELSEIF (ot.frequency_type=4)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Day of Month"
       ELSEIF (ot.frequency_type=5)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Week of Month"
       ENDIF
      ELSE
       reply->rowlist[row_tot_cnt].celllist[8].string_value = "No scheduled instances of this job."
      ENDIF
      reply->rowlist[row_tot_cnt].celllist[13].string_value = recommendation_txt
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM request r
      PLAN (r
       WHERE r.request_number=225241
        AND r.active_ind=1)
      DETAIL
       row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
        = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
       reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt]
       .celllist[2].string_value = "No scheduled jobs found", reply->rowlist[row_tot_cnt].celllist[3]
       .nbr_value = r.request_number,
       reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
       row_tot_cnt].celllist[13].string_value = recommendation_txt
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((request->paramlist[plcnt].meaning="OPSBBRELEASEREPORT"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="OPSBBRELEASEREPORT")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM ops_job_step ojs,
      ops_job oj,
      ops_task ot,
      request r,
      ops_control_group ocg,
      ops_schedule_job_step ocjs
     PLAN (ojs
      WHERE ojs.request_number=225211
       AND ojs.active_ind=1)
      JOIN (oj
      WHERE oj.ops_job_id=ojs.ops_job_id
       AND oj.active_ind=1)
      JOIN (ot
      WHERE ot.ops_job_id=outerjoin(oj.ops_job_id)
       AND ot.active_ind=outerjoin(1))
      JOIN (r
      WHERE r.request_number=ojs.request_number
       AND r.active_ind=1)
      JOIN (ocg
      WHERE ocg.ops_control_grp_id=outerjoin(ot.ops_control_grp_id)
       AND ocg.ops_control_grp_id > outerjoin(0)
       AND ocg.host != outerjoin("SCOUT")
       AND ocg.host != outerjoin("STORM")
       AND ocg.active_ind=outerjoin(1))
      JOIN (ocjs
      WHERE ocjs.ops_job_step_id=ojs.ops_job_step_id)
     ORDER BY ojs.ops_job_id
     HEAD ojs.ops_job_id
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = oj.name, reply->rowlist[row_tot_cnt].celllist[3].nbr_value = ojs
      .request_number,
      reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
      row_tot_cnt].celllist[5].nbr_value = ojs.step_number, reply->rowlist[row_tot_cnt].celllist[6].
      string_value = ojs.step_name
      IF (oj.active_ind=1)
       reply->rowlist[row_tot_cnt].celllist[7].string_value = "X"
      ENDIF
      IF (ot.ops_task_id > 0)
       IF (ot.autostart_ind=1)
        reply->rowlist[row_tot_cnt].celllist[8].string_value = "X"
       ENDIF
       IF (ot.enable_ind=1)
        reply->rowlist[row_tot_cnt].celllist[9].string_value = "X"
       ENDIF
       reply->rowlist[row_tot_cnt].celllist[10].date_value = ot.beg_effective_dt_tm, reply->rowlist[
       row_tot_cnt].celllist[11].date_value = ot.end_effective_dt_tm
       IF (ot.frequency_type=1)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "One Time"
       ELSEIF (ot.frequency_type=2)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Daily"
       ELSEIF (ot.frequency_type=3)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Weekly"
       ELSEIF (ot.frequency_type=4)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Day of Month"
       ELSEIF (ot.frequency_type=5)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Week of Month"
       ENDIF
      ELSE
       reply->rowlist[row_tot_cnt].celllist[8].string_value = "No scheduled instances of this job."
      ENDIF
      reply->rowlist[row_tot_cnt].celllist[13].string_value = recommendation_txt
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM request r
      PLAN (r
       WHERE r.request_number=225211
        AND r.active_ind=1)
      DETAIL
       row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
        = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
       reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt]
       .celllist[2].string_value = "No scheduled jobs found", reply->rowlist[row_tot_cnt].celllist[3]
       .nbr_value = r.request_number,
       reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
       row_tot_cnt].celllist[13].string_value = recommendation_txt
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((request->paramlist[plcnt].meaning="OPSBBTRANSREPORT"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="OPSBBTRANSREPORT")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM ops_job_step ojs,
      ops_job oj,
      ops_task ot,
      request r,
      ops_control_group ocg,
      ops_schedule_job_step ocjs
     PLAN (ojs
      WHERE ojs.request_number=225210
       AND ojs.active_ind=1)
      JOIN (oj
      WHERE oj.ops_job_id=ojs.ops_job_id
       AND oj.active_ind=1)
      JOIN (ot
      WHERE ot.ops_job_id=outerjoin(oj.ops_job_id)
       AND ot.active_ind=outerjoin(1))
      JOIN (r
      WHERE r.request_number=ojs.request_number
       AND r.active_ind=1)
      JOIN (ocg
      WHERE ocg.ops_control_grp_id=outerjoin(ot.ops_control_grp_id)
       AND ocg.ops_control_grp_id > outerjoin(0)
       AND ocg.host != outerjoin("SCOUT")
       AND ocg.host != outerjoin("STORM")
       AND ocg.active_ind=outerjoin(1))
      JOIN (ocjs
      WHERE ocjs.ops_job_step_id=ojs.ops_job_step_id)
     ORDER BY ojs.ops_job_id
     HEAD ojs.ops_job_id
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = oj.name, reply->rowlist[row_tot_cnt].celllist[3].nbr_value = ojs
      .request_number,
      reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
      row_tot_cnt].celllist[5].nbr_value = ojs.step_number, reply->rowlist[row_tot_cnt].celllist[6].
      string_value = ojs.step_name
      IF (oj.active_ind=1)
       reply->rowlist[row_tot_cnt].celllist[7].string_value = "X"
      ENDIF
      IF (ot.ops_task_id > 0)
       IF (ot.autostart_ind=1)
        reply->rowlist[row_tot_cnt].celllist[8].string_value = "X"
       ENDIF
       IF (ot.enable_ind=1)
        reply->rowlist[row_tot_cnt].celllist[9].string_value = "X"
       ENDIF
       reply->rowlist[row_tot_cnt].celllist[10].date_value = ot.beg_effective_dt_tm, reply->rowlist[
       row_tot_cnt].celllist[11].date_value = ot.end_effective_dt_tm
       IF (ot.frequency_type=1)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "One Time"
       ELSEIF (ot.frequency_type=2)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Daily"
       ELSEIF (ot.frequency_type=3)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Weekly"
       ELSEIF (ot.frequency_type=4)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Day of Month"
       ELSEIF (ot.frequency_type=5)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Week of Month"
       ENDIF
      ELSE
       reply->rowlist[row_tot_cnt].celllist[8].string_value = "No scheduled instances of this job."
      ENDIF
      reply->rowlist[row_tot_cnt].celllist[13].string_value = recommendation_txt
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM request r
      PLAN (r
       WHERE r.request_number=225110
        AND r.active_ind=1)
      DETAIL
       row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
        = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
       reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt]
       .celllist[2].string_value = "No scheduled jobs found", reply->rowlist[row_tot_cnt].celllist[3]
       .nbr_value = r.request_number,
       reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
       row_tot_cnt].celllist[13].string_value = recommendation_txt
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((request->paramlist[plcnt].meaning="OPSBBLOCKUNITS"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="OPSBBLOCKUNITS")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM ops_job_step ojs,
      ops_job oj,
      ops_task ot,
      request r,
      ops_control_group ocg,
      ops_schedule_job_step ocjs
     PLAN (ojs
      WHERE ojs.request_number=225650
       AND ojs.active_ind=1)
      JOIN (oj
      WHERE oj.ops_job_id=ojs.ops_job_id
       AND oj.active_ind=1)
      JOIN (ot
      WHERE ot.ops_job_id=outerjoin(oj.ops_job_id)
       AND ot.active_ind=outerjoin(1))
      JOIN (r
      WHERE r.request_number=ojs.request_number
       AND r.active_ind=1)
      JOIN (ocg
      WHERE ocg.ops_control_grp_id=outerjoin(ot.ops_control_grp_id)
       AND ocg.ops_control_grp_id > outerjoin(0)
       AND ocg.host != outerjoin("SCOUT")
       AND ocg.host != outerjoin("STORM")
       AND ocg.active_ind=outerjoin(1))
      JOIN (ocjs
      WHERE ocjs.ops_job_step_id=ojs.ops_job_step_id)
     ORDER BY ojs.ops_job_id
     HEAD ojs.ops_job_id
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = oj.name, reply->rowlist[row_tot_cnt].celllist[3].nbr_value = ojs
      .request_number,
      reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
      row_tot_cnt].celllist[5].nbr_value = ojs.step_number, reply->rowlist[row_tot_cnt].celllist[6].
      string_value = ojs.step_name
      IF (oj.active_ind=1)
       reply->rowlist[row_tot_cnt].celllist[7].string_value = "X"
      ENDIF
      IF (ot.ops_task_id > 0)
       IF (ot.autostart_ind=1)
        reply->rowlist[row_tot_cnt].celllist[8].string_value = "X"
       ENDIF
       IF (ot.enable_ind=1)
        reply->rowlist[row_tot_cnt].celllist[9].string_value = "X"
       ENDIF
       reply->rowlist[row_tot_cnt].celllist[10].date_value = ot.beg_effective_dt_tm, reply->rowlist[
       row_tot_cnt].celllist[11].date_value = ot.end_effective_dt_tm
       IF (ot.frequency_type=1)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "One Time"
       ELSEIF (ot.frequency_type=2)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Daily"
       ELSEIF (ot.frequency_type=3)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Weekly"
       ELSEIF (ot.frequency_type=4)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Day of Month"
       ELSEIF (ot.frequency_type=5)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Week of Month"
       ENDIF
      ELSE
       reply->rowlist[row_tot_cnt].celllist[8].string_value = "No scheduled instances of this job."
      ENDIF
      reply->rowlist[row_tot_cnt].celllist[13].string_value = recommendation_txt
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM request r
      PLAN (r
       WHERE r.request_number=225650
        AND r.active_ind=1)
      DETAIL
       row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
        = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
       reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt]
       .celllist[2].string_value = "No scheduled jobs found", reply->rowlist[row_tot_cnt].celllist[3]
       .nbr_value = r.request_number,
       reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
       row_tot_cnt].celllist[13].string_value = recommendation_txt
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((request->paramlist[plcnt].meaning="OPSBBTRANSUNITS"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="OPSBBTRANSUNITS")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM ops_job_step ojs,
      ops_job oj,
      ops_task ot,
      request r,
      ops_control_group ocg,
      ops_schedule_job_step ocjs
     PLAN (ojs
      WHERE ojs.request_number=225651
       AND ojs.active_ind=1)
      JOIN (oj
      WHERE oj.ops_job_id=ojs.ops_job_id
       AND oj.active_ind=1)
      JOIN (ot
      WHERE ot.ops_job_id=outerjoin(oj.ops_job_id)
       AND ot.active_ind=outerjoin(1))
      JOIN (r
      WHERE r.request_number=ojs.request_number
       AND r.active_ind=1)
      JOIN (ocg
      WHERE ocg.ops_control_grp_id=outerjoin(ot.ops_control_grp_id)
       AND ocg.ops_control_grp_id > outerjoin(0)
       AND ocg.host != outerjoin("SCOUT")
       AND ocg.host != outerjoin("STORM")
       AND ocg.active_ind=outerjoin(1))
      JOIN (ocjs
      WHERE ocjs.ops_job_step_id=ojs.ops_job_step_id)
     ORDER BY ojs.ops_job_id
     HEAD ojs.ops_job_id
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = oj.name, reply->rowlist[row_tot_cnt].celllist[3].nbr_value = ojs
      .request_number,
      reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
      row_tot_cnt].celllist[5].nbr_value = ojs.step_number, reply->rowlist[row_tot_cnt].celllist[6].
      string_value = ojs.step_name
      IF (oj.active_ind=1)
       reply->rowlist[row_tot_cnt].celllist[7].string_value = "X"
      ENDIF
      IF (ot.ops_task_id > 0)
       IF (ot.autostart_ind=1)
        reply->rowlist[row_tot_cnt].celllist[8].string_value = "X"
       ENDIF
       IF (ot.enable_ind=1)
        reply->rowlist[row_tot_cnt].celllist[9].string_value = "X"
       ENDIF
       reply->rowlist[row_tot_cnt].celllist[10].date_value = ot.beg_effective_dt_tm, reply->rowlist[
       row_tot_cnt].celllist[11].date_value = ot.end_effective_dt_tm
       IF (ot.frequency_type=1)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "One Time"
       ELSEIF (ot.frequency_type=2)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Daily"
       ELSEIF (ot.frequency_type=3)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Weekly"
       ELSEIF (ot.frequency_type=4)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Day of Month"
       ELSEIF (ot.frequency_type=5)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Week of Month"
       ENDIF
      ELSE
       reply->rowlist[row_tot_cnt].celllist[8].string_value = "No scheduled instances of this job."
      ENDIF
      reply->rowlist[row_tot_cnt].celllist[13].string_value = recommendation_txt
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM request r
      PLAN (r
       WHERE r.request_number=225651
        AND r.active_ind=1)
      DETAIL
       row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
        = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
       reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt]
       .celllist[2].string_value = "No scheduled jobs found", reply->rowlist[row_tot_cnt].celllist[3]
       .nbr_value = r.request_number,
       reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
       row_tot_cnt].celllist[13].string_value = recommendation_txt
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((request->paramlist[plcnt].meaning="OPSMICRORESULTS"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="OPSMICRORESULTS")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM ops_job_step ojs,
      ops_job oj,
      ops_task ot,
      request r,
      ops_control_group ocg,
      ops_schedule_job_step ocjs
     PLAN (ojs
      WHERE ojs.request_number=275260
       AND ojs.active_ind=1)
      JOIN (oj
      WHERE oj.ops_job_id=ojs.ops_job_id
       AND oj.active_ind=1)
      JOIN (ot
      WHERE ot.ops_job_id=outerjoin(oj.ops_job_id)
       AND ot.active_ind=outerjoin(1))
      JOIN (r
      WHERE r.request_number=ojs.request_number
       AND r.active_ind=1)
      JOIN (ocg
      WHERE ocg.ops_control_grp_id=outerjoin(ot.ops_control_grp_id)
       AND ocg.ops_control_grp_id > outerjoin(0)
       AND ocg.host != outerjoin("SCOUT")
       AND ocg.host != outerjoin("STORM")
       AND ocg.active_ind=outerjoin(1))
      JOIN (ocjs
      WHERE ocjs.ops_job_step_id=ojs.ops_job_step_id)
     ORDER BY ojs.ops_job_id
     HEAD ojs.ops_job_id
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = oj.name, reply->rowlist[row_tot_cnt].celllist[3].nbr_value = ojs
      .request_number,
      reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
      row_tot_cnt].celllist[5].nbr_value = ojs.step_number, reply->rowlist[row_tot_cnt].celllist[6].
      string_value = ojs.step_name
      IF (oj.active_ind=1)
       reply->rowlist[row_tot_cnt].celllist[7].string_value = "X"
      ENDIF
      IF (ot.ops_task_id > 0)
       IF (ot.autostart_ind=1)
        reply->rowlist[row_tot_cnt].celllist[8].string_value = "X"
       ENDIF
       IF (ot.enable_ind=1)
        reply->rowlist[row_tot_cnt].celllist[9].string_value = "X"
       ENDIF
       reply->rowlist[row_tot_cnt].celllist[10].date_value = ot.beg_effective_dt_tm, reply->rowlist[
       row_tot_cnt].celllist[11].date_value = ot.end_effective_dt_tm
       IF (ot.frequency_type=1)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "One Time"
       ELSEIF (ot.frequency_type=2)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Daily"
       ELSEIF (ot.frequency_type=3)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Weekly"
       ELSEIF (ot.frequency_type=4)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Day of Month"
       ELSEIF (ot.frequency_type=5)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Week of Month"
       ENDIF
      ELSE
       reply->rowlist[row_tot_cnt].celllist[8].string_value = "No scheduled instances of this job."
      ENDIF
      reply->rowlist[row_tot_cnt].celllist[13].string_value = recommendation_txt
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM request r
      PLAN (r
       WHERE r.request_number=275260
        AND r.active_ind=1)
      DETAIL
       row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
        = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
       reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt]
       .celllist[2].string_value = "No scheduled jobs found", reply->rowlist[row_tot_cnt].celllist[3]
       .nbr_value = r.request_number,
       reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
       row_tot_cnt].celllist[13].string_value = recommendation_txt
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((request->paramlist[plcnt].meaning="OPSCSMPURGEREQUEST"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="OPSCSMPURGEREQUEST")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM ops_job_step ojs,
      ops_job oj,
      ops_task ot,
      request r,
      ops_control_group ocg,
      ops_schedule_job_step ocjs
     PLAN (ojs
      WHERE ojs.request_number=1037603
       AND ojs.active_ind=1)
      JOIN (oj
      WHERE oj.ops_job_id=ojs.ops_job_id
       AND oj.active_ind=1)
      JOIN (ot
      WHERE ot.ops_job_id=outerjoin(oj.ops_job_id)
       AND ot.active_ind=outerjoin(1))
      JOIN (r
      WHERE r.request_number=ojs.request_number
       AND r.active_ind=1)
      JOIN (ocg
      WHERE ocg.ops_control_grp_id=outerjoin(ot.ops_control_grp_id)
       AND ocg.ops_control_grp_id > outerjoin(0)
       AND ocg.host != outerjoin("SCOUT")
       AND ocg.host != outerjoin("STORM")
       AND ocg.active_ind=outerjoin(1))
      JOIN (ocjs
      WHERE ocjs.ops_job_step_id=ojs.ops_job_step_id)
     ORDER BY ojs.ops_job_id
     HEAD ojs.ops_job_id
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = oj.name, reply->rowlist[row_tot_cnt].celllist[3].nbr_value = ojs
      .request_number,
      reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
      row_tot_cnt].celllist[5].nbr_value = ojs.step_number, reply->rowlist[row_tot_cnt].celllist[6].
      string_value = ojs.step_name
      IF (oj.active_ind=1)
       reply->rowlist[row_tot_cnt].celllist[7].string_value = "X"
      ENDIF
      IF (ot.ops_task_id > 0)
       IF (ot.autostart_ind=1)
        reply->rowlist[row_tot_cnt].celllist[8].string_value = "X"
       ENDIF
       IF (ot.enable_ind=1)
        reply->rowlist[row_tot_cnt].celllist[9].string_value = "X"
       ENDIF
       reply->rowlist[row_tot_cnt].celllist[10].date_value = ot.beg_effective_dt_tm, reply->rowlist[
       row_tot_cnt].celllist[11].date_value = ot.end_effective_dt_tm
       IF (ot.frequency_type=1)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "One Time"
       ELSEIF (ot.frequency_type=2)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Daily"
       ELSEIF (ot.frequency_type=3)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Weekly"
       ELSEIF (ot.frequency_type=4)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Day of Month"
       ELSEIF (ot.frequency_type=5)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Week of Month"
       ENDIF
      ELSE
       reply->rowlist[row_tot_cnt].celllist[8].string_value = "No scheduled instances of this job."
      ENDIF
      reply->rowlist[row_tot_cnt].celllist[13].string_value = recommendation_txt
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM request r
      PLAN (r
       WHERE r.request_number=1037603
        AND r.active_ind=1)
      DETAIL
       row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
        = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
       reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt]
       .celllist[2].string_value = "No scheduled jobs found", reply->rowlist[row_tot_cnt].celllist[3]
       .nbr_value = r.request_number,
       reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
       row_tot_cnt].celllist[13].string_value = recommendation_txt
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((request->paramlist[plcnt].meaning="CARENETECOOPS"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="CARENETECOOPS")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM ops_job_step ojs,
      ops_job oj,
      ops_task ot,
      request r,
      ops_control_group ocg,
      ops_schedule_job_step ocjs
     PLAN (ojs
      WHERE ojs.request_number=560501
       AND ojs.active_ind=1)
      JOIN (oj
      WHERE oj.ops_job_id=ojs.ops_job_id
       AND oj.active_ind=1)
      JOIN (ot
      WHERE ot.ops_job_id=outerjoin(oj.ops_job_id)
       AND ot.active_ind=outerjoin(1))
      JOIN (r
      WHERE r.request_number=ojs.request_number
       AND r.active_ind=1)
      JOIN (ocg
      WHERE ocg.ops_control_grp_id=outerjoin(ot.ops_control_grp_id)
       AND ocg.ops_control_grp_id > outerjoin(0)
       AND ocg.host != outerjoin("SCOUT")
       AND ocg.host != outerjoin("STORM")
       AND ocg.active_ind=outerjoin(1))
      JOIN (ocjs
      WHERE ocjs.ops_job_step_id=ojs.ops_job_step_id)
     ORDER BY ojs.ops_job_id
     HEAD ojs.ops_job_id
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = oj.name, reply->rowlist[row_tot_cnt].celllist[3].nbr_value = ojs
      .request_number,
      reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
      row_tot_cnt].celllist[5].nbr_value = ojs.step_number, reply->rowlist[row_tot_cnt].celllist[6].
      string_value = ojs.step_name
      IF (oj.active_ind=1)
       reply->rowlist[row_tot_cnt].celllist[7].string_value = "X"
      ENDIF
      IF (ot.ops_task_id > 0)
       IF (ot.autostart_ind=1)
        reply->rowlist[row_tot_cnt].celllist[8].string_value = "X"
       ENDIF
       IF (ot.enable_ind=1)
        reply->rowlist[row_tot_cnt].celllist[9].string_value = "X"
       ENDIF
       reply->rowlist[row_tot_cnt].celllist[10].date_value = ot.beg_effective_dt_tm, reply->rowlist[
       row_tot_cnt].celllist[11].date_value = ot.end_effective_dt_tm
       IF (ot.frequency_type=1)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "One Time"
       ELSEIF (ot.frequency_type=2)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Daily"
       ELSEIF (ot.frequency_type=3)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Weekly"
       ELSEIF (ot.frequency_type=4)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Day of Month"
       ELSEIF (ot.frequency_type=5)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Week of Month"
       ENDIF
      ELSE
       reply->rowlist[row_tot_cnt].celllist[8].string_value = "No scheduled instances of this job."
      ENDIF
      reply->rowlist[row_tot_cnt].celllist[13].string_value = recommendation_txt
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM request r
      PLAN (r
       WHERE r.request_number=560501
        AND r.active_ind=1)
      DETAIL
       row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
        = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
       reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt]
       .celllist[2].string_value = "No scheduled jobs found", reply->rowlist[row_tot_cnt].celllist[3]
       .nbr_value = r.request_number,
       reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
       row_tot_cnt].celllist[13].string_value = recommendation_txt
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((request->paramlist[plcnt].meaning="CARENETORMORDUPD"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="CARENETORMORDUPD")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM ops_job_step ojs,
      ops_job oj,
      ops_task ot,
      request r,
      ops_control_group ocg,
      ops_schedule_job_step ocjs
     PLAN (ojs
      WHERE ojs.request_number=500423
       AND ojs.active_ind=1)
      JOIN (oj
      WHERE oj.ops_job_id=ojs.ops_job_id
       AND oj.active_ind=1)
      JOIN (ot
      WHERE ot.ops_job_id=outerjoin(oj.ops_job_id)
       AND ot.active_ind=outerjoin(1))
      JOIN (r
      WHERE r.request_number=ojs.request_number
       AND r.active_ind=1)
      JOIN (ocg
      WHERE ocg.ops_control_grp_id=outerjoin(ot.ops_control_grp_id)
       AND ocg.ops_control_grp_id > outerjoin(0)
       AND ocg.host != outerjoin("SCOUT")
       AND ocg.host != outerjoin("STORM")
       AND ocg.active_ind=outerjoin(1))
      JOIN (ocjs
      WHERE ocjs.ops_job_step_id=ojs.ops_job_step_id)
     ORDER BY ojs.ops_job_id
     HEAD ojs.ops_job_id
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = oj.name, reply->rowlist[row_tot_cnt].celllist[3].nbr_value = ojs
      .request_number,
      reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
      row_tot_cnt].celllist[5].nbr_value = ojs.step_number, reply->rowlist[row_tot_cnt].celllist[6].
      string_value = ojs.step_name
      IF (oj.active_ind=1)
       reply->rowlist[row_tot_cnt].celllist[7].string_value = "X"
      ENDIF
      IF (ot.ops_task_id > 0)
       IF (ot.autostart_ind=1)
        reply->rowlist[row_tot_cnt].celllist[8].string_value = "X"
       ENDIF
       IF (ot.enable_ind=1)
        reply->rowlist[row_tot_cnt].celllist[9].string_value = "X"
       ENDIF
       reply->rowlist[row_tot_cnt].celllist[10].date_value = ot.beg_effective_dt_tm, reply->rowlist[
       row_tot_cnt].celllist[11].date_value = ot.end_effective_dt_tm
       IF (ot.frequency_type=1)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "One Time"
       ELSEIF (ot.frequency_type=2)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Daily"
       ELSEIF (ot.frequency_type=3)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Weekly"
       ELSEIF (ot.frequency_type=4)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Day of Month"
       ELSEIF (ot.frequency_type=5)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Week of Month"
       ENDIF
      ELSE
       reply->rowlist[row_tot_cnt].celllist[8].string_value = "No scheduled instances of this job."
      ENDIF
      reply->rowlist[row_tot_cnt].celllist[13].string_value = recommendation_txt
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM request r
      PLAN (r
       WHERE r.request_number=500423
        AND r.active_ind=1)
      DETAIL
       row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
        = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
       reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt]
       .celllist[2].string_value = "No scheduled jobs found", reply->rowlist[row_tot_cnt].celllist[3]
       .nbr_value = r.request_number,
       reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
       row_tot_cnt].celllist[13].string_value = recommendation_txt
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((request->paramlist[plcnt].meaning="RADREPORT"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="RADREPORT")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM ops_job_step ojs,
      ops_job oj,
      ops_task ot,
      request r,
      ops_control_group ocg,
      ops_schedule_job_step ocjs
     PLAN (ojs
      WHERE ojs.request_number=455112
       AND ojs.active_ind=1)
      JOIN (oj
      WHERE oj.ops_job_id=ojs.ops_job_id
       AND oj.active_ind=1)
      JOIN (ot
      WHERE ot.ops_job_id=outerjoin(oj.ops_job_id)
       AND ot.active_ind=outerjoin(1))
      JOIN (r
      WHERE r.request_number=ojs.request_number
       AND r.active_ind=1)
      JOIN (ocg
      WHERE ocg.ops_control_grp_id=outerjoin(ot.ops_control_grp_id)
       AND ocg.ops_control_grp_id > outerjoin(0)
       AND ocg.host != outerjoin("SCOUT")
       AND ocg.host != outerjoin("STORM")
       AND ocg.active_ind=outerjoin(1))
      JOIN (ocjs
      WHERE ocjs.ops_job_step_id=ojs.ops_job_step_id)
     ORDER BY ojs.ops_job_id
     HEAD ojs.ops_job_id
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = oj.name, reply->rowlist[row_tot_cnt].celllist[3].nbr_value = ojs
      .request_number,
      reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
      row_tot_cnt].celllist[5].nbr_value = ojs.step_number, reply->rowlist[row_tot_cnt].celllist[6].
      string_value = ojs.step_name
      IF (oj.active_ind=1)
       reply->rowlist[row_tot_cnt].celllist[7].string_value = "X"
      ENDIF
      IF (ot.ops_task_id > 0)
       IF (ot.autostart_ind=1)
        reply->rowlist[row_tot_cnt].celllist[8].string_value = "X"
       ENDIF
       IF (ot.enable_ind=1)
        reply->rowlist[row_tot_cnt].celllist[9].string_value = "X"
       ENDIF
       reply->rowlist[row_tot_cnt].celllist[10].date_value = ot.beg_effective_dt_tm, reply->rowlist[
       row_tot_cnt].celllist[11].date_value = ot.end_effective_dt_tm
       IF (ot.frequency_type=1)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "One Time"
       ELSEIF (ot.frequency_type=2)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Daily"
       ELSEIF (ot.frequency_type=3)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Weekly"
       ELSEIF (ot.frequency_type=4)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Day of Month"
       ELSEIF (ot.frequency_type=5)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Week of Month"
       ENDIF
      ELSE
       reply->rowlist[row_tot_cnt].celllist[8].string_value = "No scheduled instances of this job."
      ENDIF
      reply->rowlist[row_tot_cnt].celllist[13].string_value = recommendation_txt
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM request r
      PLAN (r
       WHERE r.request_number=455112
        AND r.active_ind=1)
      DETAIL
       row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
        = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
       reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt]
       .celllist[2].string_value = "No scheduled jobs found", reply->rowlist[row_tot_cnt].celllist[3]
       .nbr_value = r.request_number,
       reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
       row_tot_cnt].celllist[13].string_value = recommendation_txt
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((request->paramlist[plcnt].meaning="RADREPORTREQUEUE"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="RADREPORTREQUEUE")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM ops_job_step ojs,
      ops_job oj,
      ops_task ot,
      request r,
      ops_control_group ocg,
      ops_schedule_job_step ocjs
     PLAN (ojs
      WHERE ojs.request_number=480013
       AND ojs.active_ind=1)
      JOIN (oj
      WHERE oj.ops_job_id=ojs.ops_job_id
       AND oj.active_ind=1)
      JOIN (ot
      WHERE ot.ops_job_id=outerjoin(oj.ops_job_id)
       AND ot.active_ind=outerjoin(1))
      JOIN (r
      WHERE r.request_number=ojs.request_number
       AND r.active_ind=1)
      JOIN (ocg
      WHERE ocg.ops_control_grp_id=outerjoin(ot.ops_control_grp_id)
       AND ocg.ops_control_grp_id > outerjoin(0)
       AND ocg.host != outerjoin("SCOUT")
       AND ocg.host != outerjoin("STORM")
       AND ocg.active_ind=outerjoin(1))
      JOIN (ocjs
      WHERE ocjs.ops_job_step_id=ojs.ops_job_step_id)
     ORDER BY ojs.ops_job_id
     HEAD ojs.ops_job_id
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = oj.name, reply->rowlist[row_tot_cnt].celllist[3].nbr_value = ojs
      .request_number,
      reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
      row_tot_cnt].celllist[5].nbr_value = ojs.step_number, reply->rowlist[row_tot_cnt].celllist[6].
      string_value = ojs.step_name
      IF (oj.active_ind=1)
       reply->rowlist[row_tot_cnt].celllist[7].string_value = "X"
      ENDIF
      IF (ot.ops_task_id > 0)
       IF (ot.autostart_ind=1)
        reply->rowlist[row_tot_cnt].celllist[8].string_value = "X"
       ENDIF
       IF (ot.enable_ind=1)
        reply->rowlist[row_tot_cnt].celllist[9].string_value = "X"
       ENDIF
       reply->rowlist[row_tot_cnt].celllist[10].date_value = ot.beg_effective_dt_tm, reply->rowlist[
       row_tot_cnt].celllist[11].date_value = ot.end_effective_dt_tm
       IF (ot.frequency_type=1)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "One Time"
       ELSEIF (ot.frequency_type=2)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Daily"
       ELSEIF (ot.frequency_type=3)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Weekly"
       ELSEIF (ot.frequency_type=4)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Day of Month"
       ELSEIF (ot.frequency_type=5)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Week of Month"
       ENDIF
      ELSE
       reply->rowlist[row_tot_cnt].celllist[8].string_value = "No scheduled instances of this job."
      ENDIF
      reply->rowlist[row_tot_cnt].celllist[13].string_value = recommendation_txt
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM request r
      PLAN (r
       WHERE r.request_number=480013
        AND r.active_ind=1)
      DETAIL
       row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
        = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
       reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt]
       .celllist[2].string_value = "No scheduled jobs found", reply->rowlist[row_tot_cnt].celllist[3]
       .nbr_value = r.request_number,
       reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
       row_tot_cnt].celllist[13].string_value = recommendation_txt
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((request->paramlist[plcnt].meaning="PATHGLORDSOPS"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="PATHGLORDSOPS")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM ops_job_step ojs,
      ops_job oj,
      ops_task ot,
      request r,
      ops_control_group ocg,
      ops_schedule_job_step ocjs
     PLAN (ojs
      WHERE ojs.request_number=265260
       AND ojs.active_ind=1)
      JOIN (oj
      WHERE oj.ops_job_id=ojs.ops_job_id
       AND oj.active_ind=1)
      JOIN (ot
      WHERE ot.ops_job_id=outerjoin(oj.ops_job_id)
       AND ot.active_ind=outerjoin(1))
      JOIN (r
      WHERE r.request_number=ojs.request_number
       AND r.active_ind=1)
      JOIN (ocg
      WHERE ocg.ops_control_grp_id=outerjoin(ot.ops_control_grp_id)
       AND ocg.ops_control_grp_id > outerjoin(0)
       AND ocg.host != outerjoin("SCOUT")
       AND ocg.host != outerjoin("STORM")
       AND ocg.active_ind=outerjoin(1))
      JOIN (ocjs
      WHERE ocjs.ops_job_step_id=ojs.ops_job_step_id)
     ORDER BY ojs.ops_job_id
     HEAD ojs.ops_job_id
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = oj.name, reply->rowlist[row_tot_cnt].celllist[3].nbr_value = ojs
      .request_number,
      reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
      row_tot_cnt].celllist[5].nbr_value = ojs.step_number, reply->rowlist[row_tot_cnt].celllist[6].
      string_value = ojs.step_name
      IF (oj.active_ind=1)
       reply->rowlist[row_tot_cnt].celllist[7].string_value = "X"
      ENDIF
      IF (ot.ops_task_id > 0)
       IF (ot.autostart_ind=1)
        reply->rowlist[row_tot_cnt].celllist[8].string_value = "X"
       ENDIF
       IF (ot.enable_ind=1)
        reply->rowlist[row_tot_cnt].celllist[9].string_value = "X"
       ENDIF
       reply->rowlist[row_tot_cnt].celllist[10].date_value = ot.beg_effective_dt_tm, reply->rowlist[
       row_tot_cnt].celllist[11].date_value = ot.end_effective_dt_tm
       IF (ot.frequency_type=1)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "One Time"
       ELSEIF (ot.frequency_type=2)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Daily"
       ELSEIF (ot.frequency_type=3)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Weekly"
       ELSEIF (ot.frequency_type=4)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Day of Month"
       ELSEIF (ot.frequency_type=5)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Week of Month"
       ENDIF
      ELSE
       reply->rowlist[row_tot_cnt].celllist[8].string_value = "No scheduled instances of this job."
      ENDIF
      reply->rowlist[row_tot_cnt].celllist[13].string_value = recommendation_txt
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM request r
      PLAN (r
       WHERE r.request_number=265260
        AND r.active_ind=1)
      DETAIL
       row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
        = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
       reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt]
       .celllist[2].string_value = "No scheduled jobs found", reply->rowlist[row_tot_cnt].celllist[3]
       .nbr_value = r.request_number,
       reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
       row_tot_cnt].celllist[13].string_value = recommendation_txt
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((request->paramlist[plcnt].meaning="OPSBATCHEEM"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="OPSBATCHEEM")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM ops_job_step ojs,
      ops_job oj,
      ops_task ot,
      request r,
      ops_control_group ocg,
      ops_schedule_job_step ocjs
     PLAN (ojs
      WHERE ojs.request_number=4196230
       AND ojs.active_ind=1)
      JOIN (oj
      WHERE oj.ops_job_id=ojs.ops_job_id
       AND oj.active_ind=1)
      JOIN (ot
      WHERE ot.ops_job_id=outerjoin(oj.ops_job_id)
       AND ot.active_ind=outerjoin(1))
      JOIN (r
      WHERE r.request_number=ojs.request_number
       AND r.active_ind=1)
      JOIN (ocg
      WHERE ocg.ops_control_grp_id=outerjoin(ot.ops_control_grp_id)
       AND ocg.ops_control_grp_id > outerjoin(0)
       AND ocg.host != outerjoin("SCOUT")
       AND ocg.host != outerjoin("STORM")
       AND ocg.active_ind=outerjoin(1))
      JOIN (ocjs
      WHERE ocjs.ops_job_step_id=ojs.ops_job_step_id)
     ORDER BY ojs.ops_job_id
     HEAD ojs.ops_job_id
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = oj.name, reply->rowlist[row_tot_cnt].celllist[3].nbr_value = ojs
      .request_number,
      reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
      row_tot_cnt].celllist[5].nbr_value = ojs.step_number, reply->rowlist[row_tot_cnt].celllist[6].
      string_value = ojs.step_name
      IF (oj.active_ind=1)
       reply->rowlist[row_tot_cnt].celllist[7].string_value = "X"
      ENDIF
      IF (ot.ops_task_id > 0)
       IF (ot.autostart_ind=1)
        reply->rowlist[row_tot_cnt].celllist[8].string_value = "X"
       ENDIF
       IF (ot.enable_ind=1)
        reply->rowlist[row_tot_cnt].celllist[9].string_value = "X"
       ENDIF
       reply->rowlist[row_tot_cnt].celllist[10].date_value = ot.beg_effective_dt_tm, reply->rowlist[
       row_tot_cnt].celllist[11].date_value = ot.end_effective_dt_tm
       IF (ot.frequency_type=1)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "One Time"
       ELSEIF (ot.frequency_type=2)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Daily"
       ELSEIF (ot.frequency_type=3)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Weekly"
       ELSEIF (ot.frequency_type=4)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Day of Month"
       ELSEIF (ot.frequency_type=5)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Week of Month"
       ENDIF
      ELSE
       reply->rowlist[row_tot_cnt].celllist[8].string_value = "No scheduled instances of this job."
      ENDIF
      reply->rowlist[row_tot_cnt].celllist[13].string_value = recommendation_txt
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM request r
      PLAN (r
       WHERE r.request_number=265260
        AND r.active_ind=1)
      DETAIL
       row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
        = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
       reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt]
       .celllist[2].string_value = "No scheduled jobs found", reply->rowlist[row_tot_cnt].celllist[3]
       .nbr_value = r.request_number,
       reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
       row_tot_cnt].celllist[13].string_value = recommendation_txt
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((request->paramlist[plcnt].meaning="OPSAUTODISCHARGE"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="OPSAUTODISCHARGE")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM ops_job_step ojs,
      ops_job oj,
      ops_task ot,
      request r,
      ops_control_group ocg,
      ops_schedule_job_step ocjs
     PLAN (ojs
      WHERE ((ojs.step_name="pm_upt_auto_discharge") OR (ojs.batch_selection="pm_upt_auto_discharge"
      ))
       AND ojs.active_ind=1)
      JOIN (oj
      WHERE oj.ops_job_id=ojs.ops_job_id
       AND oj.active_ind=1)
      JOIN (ot
      WHERE ot.ops_job_id=outerjoin(oj.ops_job_id)
       AND ot.active_ind=outerjoin(1))
      JOIN (r
      WHERE r.request_number=ojs.request_number
       AND r.active_ind=1)
      JOIN (ocg
      WHERE ocg.ops_control_grp_id=outerjoin(ot.ops_control_grp_id)
       AND ocg.ops_control_grp_id > outerjoin(0)
       AND ocg.host != outerjoin("SCOUT")
       AND ocg.host != outerjoin("STORM")
       AND ocg.active_ind=outerjoin(1))
      JOIN (ocjs
      WHERE ocjs.ops_job_step_id=ojs.ops_job_step_id)
     ORDER BY ojs.ops_job_id
     HEAD ojs.ops_job_id
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = oj.name, reply->rowlist[row_tot_cnt].celllist[3].nbr_value = ojs
      .request_number,
      reply->rowlist[row_tot_cnt].celllist[4].string_value = r.request_name, reply->rowlist[
      row_tot_cnt].celllist[5].nbr_value = ojs.step_number, reply->rowlist[row_tot_cnt].celllist[6].
      string_value = ojs.step_name
      IF (oj.active_ind=1)
       reply->rowlist[row_tot_cnt].celllist[7].string_value = "X"
      ENDIF
      IF (ot.ops_task_id > 0)
       IF (ot.autostart_ind=1)
        reply->rowlist[row_tot_cnt].celllist[8].string_value = "X"
       ENDIF
       IF (ot.enable_ind=1)
        reply->rowlist[row_tot_cnt].celllist[9].string_value = "X"
       ENDIF
       reply->rowlist[row_tot_cnt].celllist[10].date_value = ot.beg_effective_dt_tm, reply->rowlist[
       row_tot_cnt].celllist[11].date_value = ot.end_effective_dt_tm
       IF (ot.frequency_type=1)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "One Time"
       ELSEIF (ot.frequency_type=2)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Daily"
       ELSEIF (ot.frequency_type=3)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Weekly"
       ELSEIF (ot.frequency_type=4)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Day of Month"
       ELSEIF (ot.frequency_type=5)
        reply->rowlist[row_tot_cnt].celllist[12].string_value = "Week of Month"
       ENDIF
      ELSE
       reply->rowlist[row_tot_cnt].celllist[8].string_value = "No scheduled instances of this job."
      ENDIF
      reply->rowlist[row_tot_cnt].celllist[13].string_value = recommendation_txt
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET row_tot_cnt = (size(reply->rowlist,5)+ 1)
     SET stat = alterlist(reply->rowlist,row_tot_cnt)
     SET stat = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt)
     SET reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc
     SET reply->rowlist[row_tot_cnt].celllist[2].string_value = "No scheduled jobs found"
     SET reply->rowlist[row_tot_cnt].celllist[6].string_value = "pm_upt_auto_discharge"
     SET reply->rowlist[row_tot_cnt].celllist[13].string_value = recommendation_txt
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
