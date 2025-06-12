CREATE PROGRAM bed_rec_cr_purge_detail:dba
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
 SET reply->collist[1].header_text = "Purge Template Number"
 SET reply->collist[1].data_type = 3
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Purge Script Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Defined To Run"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Purge Script Question"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Recommended Setting"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Actual Setting"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 DECLARE recommendation_txt = vc
 SET reply->run_status_flag = 1
 SET row_tot_cnt = 0
 SET plsize = 0
 SET plsize = size(request->paramlist,5)
 FOR (x = 1 TO plsize)
  IF ((request->paramlist[x].meaning="CRPURGEDIST"))
   SELECT INTO "nl:"
    FROM dm_purge_job j,
     dm_purge_template t,
     dm_purge_job_token jt,
     dm_purge_token pt
    PLAN (j
     WHERE j.active_flag=1)
     JOIN (t
     WHERE t.active_ind=1
      AND t.template_nbr=j.template_nbr
      AND t.name="Chart Request Purge and Archive")
     JOIN (jt
     WHERE jt.job_id=j.job_id
      AND jt.token_str="PURGEDISTIND")
     JOIN (pt
     WHERE pt.template_nbr=t.template_nbr
      AND pt.token_str="PURGEDISTIND")
    HEAD t.template_nbr
     row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat =
     alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
     reply->rowlist[row_tot_cnt].celllist[1].nbr_value = t.template_nbr, reply->rowlist[row_tot_cnt].
     celllist[2].string_value = t.name, reply->rowlist[row_tot_cnt].celllist[3].string_value = "Yes",
     reply->rowlist[row_tot_cnt].celllist[4].string_value = pt.prompt_str, reply->rowlist[row_tot_cnt
     ].celllist[5].string_value = "Yes"
     IF (cnvtint(trim(jt.value))=0)
      reply->rowlist[row_tot_cnt].celllist[6].string_value = "No"
     ELSE
      reply->rowlist[row_tot_cnt].celllist[6].string_value = "Yes"
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET row_tot_cnt = (size(reply->rowlist,5)+ 1)
    SET stat = alterlist(reply->rowlist,row_tot_cnt)
    SET stat = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt)
    SET reply->rowlist[row_tot_cnt].celllist[2].string_value = "Chart Request Purge and Archive"
    SET reply->rowlist[row_tot_cnt].celllist[3].string_value = "No"
   ENDIF
  ENDIF
  IF ((request->paramlist[x].meaning="CRPURGEADHOC"))
   SELECT INTO "nl:"
    FROM dm_purge_job j,
     dm_purge_template t,
     dm_purge_job_token jt,
     dm_purge_token pt
    PLAN (j
     WHERE j.active_flag=1)
     JOIN (t
     WHERE t.active_ind=1
      AND t.template_nbr=j.template_nbr
      AND t.name="Chart Request Purge and Archive")
     JOIN (jt
     WHERE jt.job_id=j.job_id
      AND jt.token_str="PURGEADHOCEXPIND")
     JOIN (pt
     WHERE pt.template_nbr=t.template_nbr
      AND pt.token_str="PURGEADHOCEXPIND")
    HEAD t.template_nbr
     row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat =
     alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
     reply->rowlist[row_tot_cnt].celllist[1].nbr_value = t.template_nbr, reply->rowlist[row_tot_cnt].
     celllist[2].string_value = t.name, reply->rowlist[row_tot_cnt].celllist[3].string_value = "Yes",
     reply->rowlist[row_tot_cnt].celllist[4].string_value = pt.prompt_str, reply->rowlist[row_tot_cnt
     ].celllist[5].string_value = "Yes"
     IF (cnvtint(trim(jt.value))=0)
      reply->rowlist[row_tot_cnt].celllist[6].string_value = "No"
     ELSE
      reply->rowlist[row_tot_cnt].celllist[6].string_value = "Yes"
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET row_tot_cnt = (size(reply->rowlist,5)+ 1)
    SET stat = alterlist(reply->rowlist,row_tot_cnt)
    SET stat = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt)
    SET reply->rowlist[row_tot_cnt].celllist[2].string_value = "Chart Request Purge and Archive"
    SET reply->rowlist[row_tot_cnt].celllist[3].string_value = "No"
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
