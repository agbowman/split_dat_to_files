CREATE PROGRAM bed_rec_cap_usage_detail:dba
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
 SET col_cnt = 4
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Check Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Actual Setting"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Recommended Setting"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Resolution"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET rcnt = 0
 SET reply->run_status_flag = 1
 DECLARE short_desc = vc
 DECLARE resolution_txt = vc
 SET plsize = size(request->paramlist,5)
 FOR (x = 1 TO plsize)
   IF ((request->paramlist[x].meaning="IVIEWSPECIALTY"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="IVIEWSPECIALTY")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SET match_ind = 1
    SET all_okay_ind = 0
    SET allresult_cd = 0.0
    SET allspec_cd = 0.0
    SET workview_cd = 0.0
    SELECT INTO "nl:"
     FROM v500_event_set_code vesc
     PLAN (vesc
      WHERE vesc.event_set_name_key IN ("ALLSPECIALTYSECTIONS", "WORKINGVIEWSECTIONS",
      "ALLRESULTSECTIONS"))
     DETAIL
      IF (vesc.event_set_name_key="ALLSPECIALTYSECTIONS")
       allspec_cd = vesc.event_set_cd
      ELSEIF (vesc.event_set_name_key="ALLRESULTSECTIONS")
       allresult_cd = vesc.event_set_cd
      ELSE
       workview_cd = vesc.event_set_cd
      ENDIF
     WITH nocounter
    ;end select
    IF (allspec_cd > 0
     AND workview_cd > 0)
     SELECT INTO "nl:"
      FROM v500_event_set_canon vesc
      PLAN (vesc
       WHERE vesc.parent_event_set_cd=allspec_cd
        AND vesc.event_set_cd=workview_cd)
      DETAIL
       all_okay_ind = 1
      WITH nocounter
     ;end select
    ENDIF
    IF (all_okay_ind=0)
     SET tcnt = size(reply->rowlist,5)
     SET tcnt = (tcnt+ 1)
     SET stat = alterlist(reply->rowlist,tcnt)
     SET stat = alterlist(reply->rowlist[tcnt].celllist,col_cnt)
     SET reply->rowlist[tcnt].celllist[1].string_value = short_desc
     SET reply->rowlist[tcnt].celllist[2].string_value = concat("The Working View Sections ",
      "specialty event set must be directly below the ","All Specialty Sections event set.")
     SET reply->rowlist[tcnt].celllist[3].string_value = resolution_txt
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="RADDEFAULTPERSONNEL"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="RADDEFAULTPERSONNEL")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SET fail_ind = 0
    SELECT INTO "NL:"
     FROM rad_sys_controls rsc
     DETAIL
      IF (rsc.default_exam_prsnl_ind != 1)
       fail_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET fail_ind = 1
    ENDIF
    IF (fail_ind=1)
     SET tcnt = size(reply->rowlist,5)
     SET tcnt = (tcnt+ 1)
     SET stat = alterlist(reply->rowlist,tcnt)
     SET stat = alterlist(reply->rowlist[tcnt].celllist,col_cnt)
     SET reply->rowlist[tcnt].celllist[1].string_value = short_desc
     SET reply->rowlist[tcnt].celllist[2].string_value =
     "Signed in technologist does not default as the performing person"
     SET reply->rowlist[tcnt].celllist[3].string_value =
     "Signed in technologist defaults as the performing person"
     SET reply->rowlist[tcnt].celllist[4].string_value = resolution_txt
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="EVNTWINDOWFORMAT"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="EVNTWINDOWFORMAT")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SET fail_ind = 0
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_set=19009
      AND cv.cdf_meaning="SHOWNEWEVT"
     DETAIL
      IF (cv.active_ind=0)
       fail_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET fail_ind = 1
    ENDIF
    IF (fail_ind=1)
     SET tcnt = size(reply->rowlist,5)
     SET tcnt = (tcnt+ 1)
     SET stat = alterlist(reply->rowlist,tcnt)
     SET stat = alterlist(reply->rowlist[tcnt].celllist,col_cnt)
     SET reply->rowlist[tcnt].celllist[1].string_value = short_desc
     SET reply->rowlist[tcnt].celllist[2].string_value = "0 - Does not use New Event Functionality"
     SET reply->rowlist[tcnt].celllist[3].string_value = "1 - Uses New Event Functionality"
     SET reply->rowlist[tcnt].celllist[4].string_value = resolution_txt
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="HIMABSTRACTNOTRUN"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="HIMABSTRACTNOTRUN")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SET fail_ind = 0
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=52)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
     DETAIL
      IF (j.active_flag=1)
       fail_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (fail_ind=1)
     SET tcnt = size(reply->rowlist,5)
     SET tcnt = (tcnt+ 1)
     SET stat = alterlist(reply->rowlist,tcnt)
     SET stat = alterlist(reply->rowlist[tcnt].celllist,col_cnt)
     SET reply->rowlist[tcnt].celllist[1].string_value = short_desc
     SET reply->rowlist[tcnt].celllist[2].string_value = "Yes - Running"
     SET reply->rowlist[tcnt].celllist[3].string_value = "No - Do not run"
     SET reply->rowlist[tcnt].celllist[4].string_value = resolution_txt
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="HIMDSM4NOTRUN"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="HIMDSM4NOTRUN")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SET fail_ind = 0
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=53)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
     DETAIL
      IF (j.active_flag=1)
       fail_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (fail_ind=1)
     SET tcnt = size(reply->rowlist,5)
     SET tcnt = (tcnt+ 1)
     SET stat = alterlist(reply->rowlist,tcnt)
     SET stat = alterlist(reply->rowlist[tcnt].celllist,col_cnt)
     SET reply->rowlist[tcnt].celllist[1].string_value = short_desc
     SET reply->rowlist[tcnt].celllist[2].string_value = "Yes - Running"
     SET reply->rowlist[tcnt].celllist[3].string_value = "No - Do not run"
     SET reply->rowlist[tcnt].celllist[4].string_value = resolution_txt
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="HIMCODENOTRUN"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="HIMCODENOTRUN")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SET fail_ind = 0
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=51)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
     DETAIL
      IF (j.active_flag=1)
       fail_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (fail_ind=1)
     SET tcnt = size(reply->rowlist,5)
     SET tcnt = (tcnt+ 1)
     SET stat = alterlist(reply->rowlist,tcnt)
     SET stat = alterlist(reply->rowlist[tcnt].celllist,col_cnt)
     SET reply->rowlist[tcnt].celllist[1].string_value = short_desc
     SET reply->rowlist[tcnt].celllist[2].string_value = "Yes - Running"
     SET reply->rowlist[tcnt].celllist[3].string_value = "No - Do not run"
     SET reply->rowlist[tcnt].celllist[4].string_value = resolution_txt
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="HIMMEDIAHISTNOTRUN"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="HIMMEDIAHISTNOTRUN")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SET fail_ind = 0
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=50)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
     DETAIL
      IF (j.active_flag=1)
       fail_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (fail_ind=1)
     SET tcnt = size(reply->rowlist,5)
     SET tcnt = (tcnt+ 1)
     SET stat = alterlist(reply->rowlist,tcnt)
     SET stat = alterlist(reply->rowlist[tcnt].celllist,col_cnt)
     SET reply->rowlist[tcnt].celllist[1].string_value = short_desc
     SET reply->rowlist[tcnt].celllist[2].string_value = "Yes - Running"
     SET reply->rowlist[tcnt].celllist[3].string_value = "No - Do not run"
     SET reply->rowlist[tcnt].celllist[4].string_value = resolution_txt
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="HIMPATINFONOTRUN"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="HIMPATINFONOTRUN")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SET fail_ind = 0
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=48)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
     DETAIL
      IF (j.active_flag=1)
       fail_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (fail_ind=1)
     SET tcnt = size(reply->rowlist,5)
     SET tcnt = (tcnt+ 1)
     SET stat = alterlist(reply->rowlist,tcnt)
     SET stat = alterlist(reply->rowlist[tcnt].celllist,col_cnt)
     SET reply->rowlist[tcnt].celllist[1].string_value = short_desc
     SET reply->rowlist[tcnt].celllist[2].string_value = "Yes - Running"
     SET reply->rowlist[tcnt].celllist[3].string_value = "No - Do not run"
     SET reply->rowlist[tcnt].celllist[4].string_value = resolution_txt
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="HIMPRSNLSUSPNOTRUN"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="HIMPRSNLSUSPNOTRUN")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SET fail_ind = 0
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=9998)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
     DETAIL
      IF (j.active_flag=1)
       fail_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (fail_ind=1)
     SET tcnt = size(reply->rowlist,5)
     SET tcnt = (tcnt+ 1)
     SET stat = alterlist(reply->rowlist,tcnt)
     SET stat = alterlist(reply->rowlist[tcnt].celllist,col_cnt)
     SET reply->rowlist[tcnt].celllist[1].string_value = short_desc
     SET reply->rowlist[tcnt].celllist[2].string_value = "Yes - Running"
     SET reply->rowlist[tcnt].celllist[3].string_value = "No - Do not run"
     SET reply->rowlist[tcnt].celllist[4].string_value = resolution_txt
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="HIMRELEASINFONOTRUN"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="HIMRELEASINFONOTRUN")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SET fail_ind = 0
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=49)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
     DETAIL
      IF (j.active_flag=1)
       fail_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (fail_ind=1)
     SET tcnt = size(reply->rowlist,5)
     SET tcnt = (tcnt+ 1)
     SET stat = alterlist(reply->rowlist,tcnt)
     SET stat = alterlist(reply->rowlist[tcnt].celllist,col_cnt)
     SET reply->rowlist[tcnt].celllist[1].string_value = short_desc
     SET reply->rowlist[tcnt].celllist[2].string_value = "Yes - Running"
     SET reply->rowlist[tcnt].celllist[3].string_value = "No - Do not run"
     SET reply->rowlist[tcnt].celllist[4].string_value = resolution_txt
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
