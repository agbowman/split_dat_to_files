CREATE PROGRAM bed_rec_surg_appt_detail:dba
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
 SET reply->collist[2].header_text = "Appointment Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Recommended Setting"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Actual Setting"
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
   IF ((request->paramlist[x].meaning="SPENCNTRSCHED"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="SPENCNTRSCHED")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SET surg_code = 0.0
    SET encnt_code = 0.0
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=16127
       AND cv.cdf_meaning IN ("SURGCASE", "ENCNTRBOOK")
       AND cv.active_ind=1)
     DETAIL
      CASE (cv.cdf_meaning)
       OF "SURGCASE":
        surg_code = cv.code_value
       OF "ENCNTRBOOK":
        encnt_code = cv.code_value
      ENDCASE
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM code_value cv,
      sch_appt_type sat,
      sch_appt_option sao,
      sch_appt_option sao2
     PLAN (cv
      WHERE cv.code_set=14230
       AND cv.active_ind=1)
      JOIN (sat
      WHERE sat.appt_type_cd=cv.code_value
       AND sat.active_ind=1)
      JOIN (sao
      WHERE sao.appt_type_cd=sat.appt_type_cd
       AND sao.sch_option_cd=surg_code
       AND sao.active_ind=1)
      JOIN (sao2
      WHERE sao2.appt_type_cd=outerjoin(sao.appt_type_cd)
       AND sao2.sch_option_cd=outerjoin(encnt_code)
       AND sao2.active_ind=outerjoin(1))
     ORDER BY sat.description
     HEAD REPORT
      tcnt = size(reply->rowlist,5), cnt = 0, stat = alterlist(reply->rowlist,(tcnt+ 100))
     HEAD sat.appt_type_cd
      IF (sao2.appt_type_cd=0)
       tcnt = (tcnt+ 1), cnt = (cnt+ 1)
       IF (cnt > 100)
        stat = alterlist(reply->rowlist,(tcnt+ 100)), cnt = 1
       ENDIF
       stat = alterlist(reply->rowlist[tcnt].celllist,col_cnt), reply->rowlist[tcnt].celllist[1].
       string_value = short_desc, reply->rowlist[tcnt].celllist[2].string_value = sat.description,
       reply->rowlist[tcnt].celllist[3].string_value = "require encounter at booking", reply->
       rowlist[tcnt].celllist[4].string_value = "Not Set", reply->rowlist[tcnt].celllist[5].
       string_value = resolution_txt
      ENDIF
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
