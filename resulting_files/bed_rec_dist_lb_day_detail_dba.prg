CREATE PROGRAM bed_rec_dist_lb_day_detail:dba
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
 SET col_cnt = 5
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Check Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Distribution Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Lookback Days Actual Setting"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Recommended Setting"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Resolution"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->run_status_flag = 1
 DECLARE short_desc = vc
 DECLARE resolution_txt = vc
 SET plsize = size(request->paramlist,5)
 FOR (x = 1 TO plsize)
   IF ((request->paramlist[x].meaning="CLINREPDSTLBD2"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="CLINREPDSTLBD2")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM chart_distribution c
     PLAN (c
      WHERE c.active_ind=1
       AND ((c.absolute_lookback_ind=3
       AND ((c.absolute_qualification_days < 120) OR (c.absolute_qualification_days > 730)) ) OR (c
      .absolute_lookback_ind != 3)) )
     ORDER BY c.dist_descr
     HEAD REPORT
      tcnt = size(reply->rowlist,5), cnt = 0, stat = alterlist(reply->rowlist,(tcnt+ 100))
     DETAIL
      tcnt = (tcnt+ 1), cnt = (cnt+ 1)
      IF (cnt > 100)
       stat = alterlist(reply->rowlist,(tcnt+ 100)), cnt = 1
      ENDIF
      stat = alterlist(reply->rowlist[tcnt].celllist,col_cnt), reply->rowlist[tcnt].celllist[1].
      string_value = short_desc, reply->rowlist[tcnt].celllist[2].string_value = c.dist_descr
      IF (c.absolute_lookback_ind=3)
       reply->rowlist[tcnt].celllist[3].string_value = trim(cnvtstring(c.absolute_qualification_days)
        )
      ELSE
       reply->rowlist[tcnt].celllist[3].string_value = "set to date"
      ENDIF
      reply->rowlist[tcnt].celllist[4].string_value = "120 - 730 days", reply->rowlist[tcnt].
      celllist[5].string_value = resolution_txt
     FOOT REPORT
      stat = alterlist(reply->rowlist,tcnt)
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[x].meaning="CLINREPINITDISTLBD"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="CLINREPINITDISTLBD")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM chart_distribution c
     PLAN (c
      WHERE c.active_ind=1
       AND ((c.max_lookback_ind=3
       AND ((c.max_lookback_days < 1) OR (c.max_lookback_days > 30)) ) OR (c.max_lookback_ind != 3))
      )
     ORDER BY c.dist_descr
     HEAD REPORT
      tcnt = size(reply->rowlist,5), cnt = 0, stat = alterlist(reply->rowlist,(tcnt+ 100))
     DETAIL
      tcnt = (tcnt+ 1), cnt = (cnt+ 1)
      IF (cnt > 100)
       stat = alterlist(reply->rowlist,(tcnt+ 100)), cnt = 1
      ENDIF
      stat = alterlist(reply->rowlist[tcnt].celllist,col_cnt), reply->rowlist[tcnt].celllist[1].
      string_value = short_desc, reply->rowlist[tcnt].celllist[2].string_value = c.dist_descr
      IF (c.max_lookback_ind=3)
       reply->rowlist[tcnt].celllist[3].string_value = trim(cnvtstring(c.max_lookback_days))
      ELSE
       reply->rowlist[tcnt].celllist[3].string_value = "set to date"
      ENDIF
      reply->rowlist[tcnt].celllist[4].string_value = "1 - 30 days", reply->rowlist[tcnt].celllist[5]
      .string_value = resolution_txt
     FOOT REPORT
      stat = alterlist(reply->rowlist,tcnt)
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[x].meaning="CLINREPFIRSTQUALLBD"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="CLINREPFIRSTQUALLBD")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM chart_distribution c
     PLAN (c
      WHERE c.active_ind=1
       AND ((c.print_lookback_ind=3
       AND ((c.first_qualification_days < 1) OR (c.first_qualification_days > 30)) ) OR (c
      .print_lookback_ind != 3)) )
     ORDER BY c.dist_descr
     HEAD REPORT
      tcnt = size(reply->rowlist,5), cnt = 0, stat = alterlist(reply->rowlist,(tcnt+ 100))
     DETAIL
      tcnt = (tcnt+ 1), cnt = (cnt+ 1)
      IF (cnt > 100)
       stat = alterlist(reply->rowlist,(tcnt+ 100)), cnt = 1
      ENDIF
      stat = alterlist(reply->rowlist[tcnt].celllist,col_cnt), reply->rowlist[tcnt].celllist[1].
      string_value = short_desc, reply->rowlist[tcnt].celllist[2].string_value = c.dist_descr
      IF (c.print_lookback_ind=3)
       reply->rowlist[tcnt].celllist[3].string_value = trim(cnvtstring(c.first_qualification_days))
      ELSEIF (c.print_lookback_ind=0)
       reply->rowlist[tcnt].celllist[3].string_value = "set to date"
      ELSEIF (c.print_lookback_ind=2)
       reply->rowlist[tcnt].celllist[3].string_value = "set to patient admit date"
      ELSEIF (c.print_lookback_ind=1)
       reply->rowlist[tcnt].celllist[3].string_value = "set to previous distribution run"
      ENDIF
      reply->rowlist[tcnt].celllist[4].string_value = "1 - 30 days", reply->rowlist[tcnt].celllist[5]
      .string_value = resolution_txt
     FOOT REPORT
      stat = alterlist(reply->rowlist,tcnt)
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
