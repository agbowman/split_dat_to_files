CREATE PROGRAM bed_rec_dm_info_detail:dba
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
 SET col_cnt = 6
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Check Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "DM_INFO Domain"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Setting Name"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Recommended Setting"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Actual Setting"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Resolution"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET rcnt = 0
 SET reply->run_status_flag = 1
 DECLARE short_desc = vc
 DECLARE resolution_txt = vc
 SET plsize = size(request->paramlist,5)
 FOR (x = 1 TO plsize)
  IF ((request->paramlist[x].meaning="PATCAREDTAUPD"))
   SET short_desc = ""
   SET resolution_txt = ""
   SELECT INTO "nl:"
    FROM br_rec b,
     br_long_text bl2
    PLAN (b
     WHERE b.rec_mean="PATCAREDTAUPD")
     JOIN (bl2
     WHERE bl2.long_text_id=b.resolution_txt_id)
    DETAIL
     short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="KNOWLEDGE INDEX APPLICATIONS"
     AND d.info_name="DTA UPDATE"
     AND d.info_number != 0
    ORDER BY d.info_domain, d.info_name
    HEAD REPORT
     tcnt = size(reply->rowlist,5), cnt = 0, stat = alterlist(reply->rowlist,(tcnt+ 100))
    DETAIL
     tcnt = (tcnt+ 1), cnt = (cnt+ 1)
     IF (cnt > 100)
      stat = alterlist(reply->rowlist,(tcnt+ 100)), cnt = 1
     ENDIF
     stat = alterlist(reply->rowlist[tcnt].celllist,col_cnt), reply->rowlist[tcnt].celllist[1].
     string_value = short_desc, reply->rowlist[tcnt].celllist[2].string_value = d.info_domain,
     reply->rowlist[tcnt].celllist[3].string_value = d.info_name, reply->rowlist[tcnt].celllist[4].
     string_value = "0", reply->rowlist[tcnt].celllist[5].string_value = cnvtstring(d.info_number),
     reply->rowlist[tcnt].celllist[6].string_value = resolution_txt
    FOOT REPORT
     stat = alterlist(reply->rowlist,tcnt)
    WITH nocounter
   ;end select
  ENDIF
  IF ((request->paramlist[x].meaning="CSTIERMAINTVIEW"))
   SET short_desc = ""
   SET resolution_txt = ""
   SELECT INTO "nl:"
    FROM br_rec b,
     br_long_text bl2
    PLAN (b
     WHERE b.rec_mean="CSTIERMAINTVIEW")
     JOIN (bl2
     WHERE bl2.long_text_id=b.resolution_txt_id)
    DETAIL
     short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="CHARGE SERVICES"
     AND d.info_name="TIERMAINT-VIEW"
    DETAIL
     IF (d.info_char != "Y")
      tcnt = size(reply->rowlist,5), tcnt = (tcnt+ 1), stat = alterlist(reply->rowlist,tcnt),
      stat = alterlist(reply->rowlist[tcnt].celllist,col_cnt), reply->rowlist[tcnt].celllist[1].
      string_value = short_desc, reply->rowlist[tcnt].celllist[2].string_value = d.info_domain,
      reply->rowlist[tcnt].celllist[3].string_value = d.info_name, reply->rowlist[tcnt].celllist[4].
      string_value = "Y", reply->rowlist[tcnt].celllist[5].string_value = d.info_char,
      reply->rowlist[tcnt].celllist[6].string_value = resolution_txt
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
