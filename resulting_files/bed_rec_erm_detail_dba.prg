CREATE PROGRAM bed_rec_erm_detail:dba
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
 SET reply->collist[1].header_text = "Conversation Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Label"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Field"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Recommendation"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET rcnt = 0
 SET reply->run_status_flag = 1
 DECLARE emc_txt = vc
 DECLARE emc_field = vc
 DECLARE nok_txt = vc
 DECLARE nok_field = vc
 DECLARE recommendation_txt = vc
 SET plsize = size(request->paramlist,5)
 SET match_ind = 0
 FOR (x = 1 TO plsize)
   IF ((request->paramlist[x].meaning="ERMEMRGENCYCONTACT"))
    SET recommendation_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="ERMEMRGENCYCONTACT")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      recommendation_txt = trim(bl.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM pm_flx_prompt p,
      pm_flx_conversation pn
     PLAN (p
      WHERE p.field IN ("PERSON.NOK.*", "PERSON.EMC.*")
       AND p.parent_entity_name="PM_FLX_CONVERSATION"
       AND p.active_ind=1)
      JOIN (pn
      WHERE pn.conversation_id=p.parent_entity_id
       AND pn.active_ind=1)
     ORDER BY pn.conversation_id, p.sequence
     HEAD REPORT
      row_tot_cnt = size(reply->rowlist,5)
     HEAD pn.conversation_id
      i = 0, j = 0, nok_ind = 0,
      nok_field_ind = 0, nok_txt = "", nok_field = "",
      emc_ind = 0, emc_field_ind = 0, emc_txt = "",
      emc_field = ""
     DETAIL
      IF (emc_ind=0)
       j = findstring("PERSON.EMC.",p.field)
       IF (j > 0)
        emc_ind = 1, emc_txt = p.label, emc_field = p.field
       ENDIF
      ENDIF
      IF (p.field="PERSON.EMC.FREE_TEXT_PERSON_IND")
       emc_field_ind = 1
      ENDIF
      IF (nok_ind=0)
       i = findstring("PERSON.NOK.",p.field)
       IF (i > 0)
        nok_ind = 1, nok_txt = p.label, nok_field = p.field
       ENDIF
      ENDIF
      IF (p.field="PERSON.NOK.FREE_TEXT_PERSON_IND")
       nok_field_ind = 1
      ENDIF
     FOOT  pn.conversation_id
      IF (emc_ind != emc_field_ind)
       row_tot_cnt = (row_tot_cnt+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat = alterlist
       (reply->rowlist[row_tot_cnt].celllist,col_cnt),
       reply->rowlist[row_tot_cnt].celllist[1].string_value = pn.description, reply->rowlist[
       row_tot_cnt].celllist[2].string_value = emc_txt, reply->rowlist[row_tot_cnt].celllist[3].
       string_value = emc_field,
       reply->rowlist[row_tot_cnt].celllist[4].string_value = recommendation_txt
      ENDIF
      IF (nok_ind != nok_field_ind)
       row_tot_cnt = (row_tot_cnt+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat = alterlist
       (reply->rowlist[row_tot_cnt].celllist,col_cnt),
       reply->rowlist[row_tot_cnt].celllist[1].string_value = pn.description, reply->rowlist[
       row_tot_cnt].celllist[2].string_value = nok_txt, reply->rowlist[row_tot_cnt].celllist[3].
       string_value = nok_field,
       reply->rowlist[row_tot_cnt].celllist[4].string_value = recommendation_txt
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF ((request->paramlist[x].meaning="ERMFREETEXTPROVIDERS"))
    SET recommendation_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="ERMFREETEXTPROVIDERS")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      recommendation_txt = trim(bl.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM pm_flx_prompt p,
      pm_flx_conversation pn
     PLAN (p
      WHERE p.prompt_type="PROVIDER"
       AND p.description IN ("Admitting Physician", "Attending Physician")
       AND p.options="ADD=Y*"
       AND p.active_ind=1)
      JOIN (pn
      WHERE pn.conversation_id=p.parent_entity_id
       AND pn.active_ind=1)
     ORDER BY pn.description, p.prompt_id
     HEAD REPORT
      row_cnt = 0, row_tot_cnt = size(reply->rowlist,5), stat = alterlist(reply->rowlist,(row_tot_cnt
       + 100))
     DETAIL
      row_cnt = (row_cnt+ 1), row_tot_cnt = (row_tot_cnt+ 1)
      IF (row_cnt > 100)
       stat = alterlist(reply->rowlist,(row_tot_cnt+ 100)), row_cnt = 1
      ENDIF
      stat = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt), reply->rowlist[row_tot_cnt].
      celllist[1].string_value = pn.description, reply->rowlist[row_tot_cnt].celllist[2].string_value
       = p.label,
      reply->rowlist[row_tot_cnt].celllist[3].string_value = p.field, reply->rowlist[row_tot_cnt].
      celllist[4].string_value = recommendation_txt
     FOOT REPORT
      stat = alterlist(reply->rowlist,row_tot_cnt)
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
