CREATE PROGRAM bed_rec_gen_param_detail:dba
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
 SET reply->collist[2].header_text = "Display"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Actual Setting"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Recommended Setting"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Resolution"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET rcnt = 0
 SET reply->run_status_flag = 1
 DECLARE short_desc = vc
 DECLARE resolution_txt = vc
 SET plsize = size(request->paramlist,5)
 FOR (x = 1 TO plsize)
   IF ((request->paramlist[x].meaning="REGMGMTAD"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="REGMGMTAD")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM code_value c69,
      code_value_group cg,
      code_value c71
     PLAN (c69
      WHERE c69.code_set=69
       AND c69.cdf_meaning != "INPATIENT"
       AND c69.active_ind=1)
      JOIN (cg
      WHERE cg.parent_code_value=c69.code_value
       AND cg.code_set=71)
      JOIN (c71
      WHERE c71.code_value=cg.child_code_value
       AND c71.active_ind=1
       AND  NOT ( EXISTS (
      (SELECT
       ep.encntr_type_cd
       FROM encntr_type_params ep
       WHERE ep.encntr_type_cd=c71.code_value
        AND ep.param_name="AUTO_DISCH*"))))
     ORDER BY c71.display
     HEAD REPORT
      tcnt = size(reply->rowlist,5), cnt = 0, stat = alterlist(reply->rowlist,(tcnt+ 100))
     HEAD c71.code_value
      tcnt = (tcnt+ 1), cnt = (cnt+ 1)
      IF (cnt > 100)
       stat = alterlist(reply->rowlist,(tcnt+ 100)), cnt = 1
      ENDIF
      stat = alterlist(reply->rowlist[tcnt].celllist,col_cnt), reply->rowlist[tcnt].celllist[1].
      string_value = short_desc, reply->rowlist[tcnt].celllist[2].string_value = c71.display,
      reply->rowlist[tcnt].celllist[3].string_value = "Not set", reply->rowlist[tcnt].celllist[4].
      string_value = "Set auto discharge parameters", reply->rowlist[tcnt].celllist[5].string_value
       = resolution_txt
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
