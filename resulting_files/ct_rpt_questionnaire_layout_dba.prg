CREATE PROGRAM ct_rpt_questionnaire_layout:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Pt_Elig_Tracking_Id" = "",
  "Elig_mode_ind" = ""
  WITH outdev, pt_elig_tracking_id, elig_mode_ind
 EXECUTE reportrtl
 RECORD questionnaire(
   1 pt_elig_tracking_id = f8
   1 prot_amendment_id = f8
   1 primary_mnemonic = vc
   1 patient_name = c100
   1 mrn = c200
   1 principal_invest[*]
     2 pi_name = vc
     2 name_len = i2
   1 cra[*]
     2 cra_name = vc
     2 name_len = i2
   1 primary_physician = c100
   1 elig_request_person = c100
   1 elig_review_person = c100
   1 record_dt_tm = dq8
   1 question_cnt = i2
   1 elig_question_cnt = i2
   1 info_question_cnt = i2
   1 elig_status_cd = f8
   1 last_elig_provide_person = c100
   1 elig_questions[*]
     2 prot_elig_quest_id = f8
     2 question = vc
     2 question_nbr = i4
     2 desired_value = c1
     2 valid_ans = c255
     2 req_value = i2
     2 req_date = i2
     2 elig_indicator_cd = f8
     2 elig_indicator_disp = c40
     2 elig_indicator_mean = c12
     2 value = c255
     2 value_cd = f8
     2 value_disp = c40
     2 value_mean = c12
     2 specimen_test_dt_tm = dq8
     2 verified_specimen_test_dt_tm = dq8
     2 verified_elig_status_cd = f8
     2 verified_elig_status_disp = c40
     2 verified_elig_status_mean = c12
     2 audited_value = c255
     2 audited_value_cd = f8
     2 audited_value_disp = c40
     2 audited_value_mean = c12
     2 elig_provide_person_id = f8
     2 elig_provide_person = c100
   1 info_questions[*]
     2 prot_elig_quest_id = f8
     2 question = vc
     2 question_nbr = i4
     2 desired_value = c1
     2 valid_ans = c255
     2 req_value = i2
     2 req_date = i2
     2 elig_indicator_cd = f8
     2 elig_indicator_disp = c40
     2 elig_indicator_mean = c12
     2 value = c255
     2 value_cd = f8
     2 value_disp = c40
     2 value_mean = c12
     2 specimen_test_dt_tm = dq8
     2 verified_specimen_test_dt_tm = dq8
     2 verified_elig_status_cd = f8
     2 verified_elig_status_disp = c40
     2 verified_elig_status_mean = c12
     2 audited_value = c255
     2 audited_value_cd = f8
     2 audited_value_disp = c40
     2 audited_value_mean = c12
     2 elig_provide_person_id = f8
     2 elig_provide_person = c100
   1 amd_rev_name = vc
   1 amd_irb_appr_dt = dq8
   1 checklist_name = vc
   1 notes[*]
     2 pt_elig_tracking_note_id = f8
     2 note_text = vc
     2 note_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE ct_rpt_questionnaire_drv  $PT_ELIG_TRACKING_ID,  $OUTDEV
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE get_questionnaire(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant( $OUTDEV), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _remprot_mnemonic = i4 WITH noconstant(1), protect
 DECLARE _remprin_inv = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontheadpagesection_one = i2 WITH noconstant(0), protect
 DECLARE _remchecklist_title = i4 WITH noconstant(1), protect
 DECLARE _remcra = i4 WITH noconstant(1), protect
 DECLARE _bcontheadpagesection_two = i2 WITH noconstant(0), protect
 DECLARE _remirb_date = i4 WITH noconstant(1), protect
 DECLARE _bcontheadpagesection_three = i2 WITH noconstant(0), protect
 DECLARE _rempatient_mrn = i4 WITH noconstant(1), protect
 DECLARE _remmrn = i4 WITH noconstant(1), protect
 DECLARE _rempatient_name = i4 WITH noconstant(1), protect
 DECLARE _remname = i4 WITH noconstant(1), protect
 DECLARE _bcontheadpagesection_four = i2 WITH noconstant(0), protect
 DECLARE _remprimary_physician = i4 WITH noconstant(1), protect
 DECLARE _remphysician = i4 WITH noconstant(1), protect
 DECLARE _remdate_header = i4 WITH noconstant(1), protect
 DECLARE _remdate = i4 WITH noconstant(1), protect
 DECLARE _bcontheadpagesection_five = i2 WITH noconstant(0), protect
 DECLARE _remrequesting_person_header = i4 WITH noconstant(1), protect
 DECLARE _remrequesting_person = i4 WITH noconstant(1), protect
 DECLARE _remproviding_person_header = i4 WITH noconstant(1), protect
 DECLARE _remproviding_person = i4 WITH noconstant(1), protect
 DECLARE _bcontheadpagesection_six = i2 WITH noconstant(0), protect
 DECLARE _remsee_notes = i4 WITH noconstant(1), protect
 DECLARE _bcontheadpagesection_seven = i2 WITH noconstant(0), protect
 DECLARE _remeligibility_ans = i4 WITH noconstant(1), protect
 DECLARE _remtrue = i4 WITH noconstant(1), protect
 DECLARE _remfalse = i4 WITH noconstant(1), protect
 DECLARE _remdate = i4 WITH noconstant(1), protect
 DECLARE _remvalue = i4 WITH noconstant(1), protect
 DECLARE _bcontquestionheadersection = i2 WITH noconstant(0), protect
 DECLARE _remeligibility_ans = i4 WITH noconstant(1), protect
 DECLARE _remtrue = i4 WITH noconstant(1), protect
 DECLARE _remfalse = i4 WITH noconstant(1), protect
 DECLARE _remdate = i4 WITH noconstant(1), protect
 DECLARE _remvalue = i4 WITH noconstant(1), protect
 DECLARE _remverification_ans = i4 WITH noconstant(1), protect
 DECLARE _remtrue_v = i4 WITH noconstant(1), protect
 DECLARE _remfalse_v = i4 WITH noconstant(1), protect
 DECLARE _remdate_v = i4 WITH noconstant(1), protect
 DECLARE _remvalue_v = i4 WITH noconstant(1), protect
 DECLARE _bcontverifyheadersection = i2 WITH noconstant(0), protect
 DECLARE _remtrue = i4 WITH noconstant(1), protect
 DECLARE _remfalse = i4 WITH noconstant(1), protect
 DECLARE _remdate = i4 WITH noconstant(1), protect
 DECLARE _remvalue = i4 WITH noconstant(1), protect
 DECLARE _remtrue_v = i4 WITH noconstant(1), protect
 DECLARE _remfalse_v = i4 WITH noconstant(1), protect
 DECLARE _remdate_v = i4 WITH noconstant(1), protect
 DECLARE _remvalue_v = i4 WITH noconstant(1), protect
 DECLARE _remquestion = i4 WITH noconstant(1), protect
 DECLARE _remquestion_nbr = i4 WITH noconstant(1), protect
 DECLARE _bcontdetailsection = i2 WITH noconstant(0), protect
 DECLARE _remtrue = i4 WITH noconstant(1), protect
 DECLARE _remfalse = i4 WITH noconstant(1), protect
 DECLARE _remdate = i4 WITH noconstant(1), protect
 DECLARE _remvalue = i4 WITH noconstant(1), protect
 DECLARE _remquestion = i4 WITH noconstant(1), protect
 DECLARE _remquestion_nbr = i4 WITH noconstant(1), protect
 DECLARE _bcontdetailsection_question = i2 WITH noconstant(0), protect
 DECLARE _remtrue = i4 WITH noconstant(1), protect
 DECLARE _remfalse = i4 WITH noconstant(1), protect
 DECLARE _remdate = i4 WITH noconstant(1), protect
 DECLARE _remvalue = i4 WITH noconstant(1), protect
 DECLARE _remquestion = i4 WITH noconstant(1), protect
 DECLARE _remquestion_nbr = i4 WITH noconstant(1), protect
 DECLARE _bcontdetailsection_info = i2 WITH noconstant(0), protect
 DECLARE _remnote_label = i4 WITH noconstant(1), protect
 DECLARE _remnote = i4 WITH noconstant(1), protect
 DECLARE _bcontdetailsection_note = i2 WITH noconstant(0), protect
 DECLARE _remlabel_rpt_page = i4 WITH noconstant(1), protect
 DECLARE _bcontfootpagesection = i2 WITH noconstant(0), protect
 DECLARE _times90 = i4 WITH noconstant(0), protect
 DECLARE _times80 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times10u0 = i4 WITH noconstant(0), protect
 DECLARE _pen10s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen30s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE get_questionnaire(dummy)
   SELECT
    questionnaire_pt_elig_tracking_id = questionnaire->pt_elig_tracking_id,
    questionnaire_prot_amendment_id = questionnaire->prot_amendment_id,
    questionnaire_primary_mnemonic = questionnaire->primary_mnemonic,
    questionnaire_patient_name = questionnaire->patient_name, questionnaire_mrn = questionnaire->mrn,
    questionnaire_primary_physician = questionnaire->primary_physician,
    questionnaire_elig_request_person = questionnaire->elig_request_person,
    questionnaire_elig_review_person = questionnaire->elig_review_person, questionnaire_record_dt_tm
     = questionnaire->record_dt_tm,
    questionnaire_question_cnt = questionnaire->question_cnt, questionnaire_elig_question_cnt =
    questionnaire->elig_question_cnt, questionnaire_info_question_cnt = questionnaire->
    info_question_cnt
    HEAD REPORT
     _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom), _bholdcontinue = 0,
     _fenddetail -= footpagesection(rpt_calcheight,((rptreport->m_pageheight - rptreport->
      m_marginbottom) - _yoffset),_bholdcontinue),
     elig_cnt = 0, info_cnt = 0, question = fillstring(32000," "),
     type = fillstring(30," "), note_label = fillstring(40," "), stat = 0,
     question_nbr = fillstring(30," "), _hrtfhandle = 0, elig_cnt = 0,
     question = "", trueanswerind = "", falseanswerind = "",
     noheader = 0, type = uar_i18ngetmessage(i18nlabel,"ELIG_ANSWERS","ELIGIBILITY ANSWERS")
     IF (elig_mode=0)
      verifyqnind = 1
     ELSE
      verifyqnind = 0
     ENDIF
     lastqnnbrbreak = 0, curquestionnbr = 0
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     pi_size = size(questionnaire->principal_invest,5)
     FOR (i = 1 TO pi_size)
       IF (i=1)
        pi_name_concat = questionnaire->principal_invest[i].pi_name
       ELSE
        pi_name_concat = concat(pi_name_concat,"; ",questionnaire->principal_invest[i].pi_name)
       ENDIF
     ENDFOR
     cra_size = size(questionnaire->cra,5)
     FOR (x = 1 TO cra_size)
       IF (x=1)
        cra_name_concat = questionnaire->cra[x].cra_name
       ELSE
        cra_name_concat = concat(cra_name_concat,"; ",questionnaire->cra[x].cra_name)
       ENDIF
     ENDFOR
     IF (elig_mode=0)
      tmp_person = build(questionnaire->elig_review_person)
     ELSE
      tmp_person = build(questionnaire->last_elig_provide_person)
     ENDIF
     _bcontheadpagesection_one = 0, dummy_val = headpagesection_one(rpt_render,((rptreport->
      m_pageheight - rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection_one),
     _bcontheadpagesection_two = 0,
     dummy_val = headpagesection_two(rpt_render,((rptreport->m_pageheight - rptreport->m_marginbottom
      ) - _yoffset),_bcontheadpagesection_two), _bcontheadpagesection_three = 0, dummy_val =
     headpagesection_three(rpt_render,((rptreport->m_pageheight - rptreport->m_marginbottom) -
      _yoffset),_bcontheadpagesection_three),
     dummy_val = headpagesection_line_one(rpt_render), _bcontheadpagesection_four = 0, dummy_val =
     headpagesection_four(rpt_render,((rptreport->m_pageheight - rptreport->m_marginbottom) -
      _yoffset),_bcontheadpagesection_four),
     _bcontheadpagesection_five = 0, dummy_val = headpagesection_five(rpt_render,((rptreport->
      m_pageheight - rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection_five),
     _bcontheadpagesection_six = 0,
     dummy_val = headpagesection_six(rpt_render,((rptreport->m_pageheight - rptreport->m_marginbottom
      ) - _yoffset),_bcontheadpagesection_six), _bcontheadpagesection_seven = 0, dummy_val =
     headpagesection_seven(rpt_render,((rptreport->m_pageheight - rptreport->m_marginbottom) -
      _yoffset),_bcontheadpagesection_seven),
     dummy_val = headpagesection_line_two(rpt_render)
     IF (noheader=0)
      _bcontquestionheadersection = 0, dummy_val = questionheadersection(rpt_render,((rptreport->
       m_pageheight - rptreport->m_marginbottom) - _yoffset),_bcontquestionheadersection),
      _bcontverifyheadersection = 0,
      dummy_val = verifyheadersection(rpt_render,((rptreport->m_pageheight - rptreport->
       m_marginbottom) - _yoffset),_bcontverifyheadersection), dummy_val = headpagesection_line_three
      (rpt_render)
     ENDIF
    DETAIL
     IF (questionnaire_elig_question_cnt > 0)
      FOR (elig_cnt = 1 TO questionnaire_elig_question_cnt)
        trueanswerind = "", falseanswerind = "", question = questionnaire->elig_questions[elig_cnt].
        question,
        question_nbr = build(cnvtstring(questionnaire->elig_questions[elig_cnt].question_nbr),".")
        IF (uar_get_code_meaning(questionnaire->elig_questions[elig_cnt].value_cd)="TRUE")
         trueanswerind = "X"
        ENDIF
        IF (uar_get_code_meaning(questionnaire->elig_questions[elig_cnt].value_cd)="FALSE")
         falseanswerind = "X"
        ENDIF
        IF ((questionnaire->elig_questions[elig_cnt].req_date != 0))
         date_valid = 1, datestr = format(questionnaire->elig_questions[elig_cnt].specimen_test_dt_tm,
          cclfmt->shortdatetime)
        ELSE
         date_valid = 0
        ENDIF
        IF ((questionnaire->elig_questions[elig_cnt].req_value != 0))
         value_valid = 1, valuestr = questionnaire->elig_questions[elig_cnt].value
         IF (valuestr="")
          valuestr = " "
         ENDIF
        ELSE
         value_valid = 0, valuestr = ""
        ENDIF
        IF (verifyqnind=1)
         trueanswerind2 = "", falseanswerind2 = ""
         IF (uar_get_code_meaning(questionnaire->elig_questions[elig_cnt].audited_value_cd)="TRUE")
          trueanswerind2 = "X"
         ENDIF
         IF (uar_get_code_meaning(questionnaire->elig_questions[elig_cnt].audited_value_cd)="FALSE")
          falseanswerind2 = "X"
         ENDIF
         IF ((questionnaire->elig_questions[elig_cnt].req_date != 0))
          date_valid2 = 1, datestr2 = format(questionnaire->elig_questions[elig_cnt].
           verified_specimen_test_dt_tm,cclfmt->shortdatetime)
         ELSE
          date_valid2 = 0
         ENDIF
         IF ((questionnaire->elig_questions[elig_cnt].req_value != 0))
          value_valid2 = 1, valuestr2 = questionnaire->elig_questions[elig_cnt].audited_value
          IF (valuestr2="")
           valuestr2 = " "
          ENDIF
         ELSE
          value_valid2 = 0, valuestr2 = ""
         ENDIF
         found = findstring("rtf",question,1,1)
         IF (found > 0)
          inbuflen = size(question), temp = uar_rtf2(question,inbuflen,outbuffer,outbuflen,retbuflen,
           bflag)
         ELSE
          curquestionnbr = elig_cnt, lastqnnbrbreak = 0, outbuffer = question
         ENDIF
         _bcontdetailsection = 0, bfirsttime = 1
         WHILE (((_bcontdetailsection=1) OR (bfirsttime=1)) )
           _bholdcontinue = _bcontdetailsection, _fdrawheight = detailsection(rpt_calcheight,(
            _fenddetail - _yoffset),_bholdcontinue)
           IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
            IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
             _bholdcontinue = 0, _fdrawheight += detailsection_question(rpt_calcheight,((_fenddetail
               - _yoffset) - _fdrawheight),_bholdcontinue)
             IF (_bholdcontinue=1)
              _fdrawheight = (_fenddetail+ 1)
             ENDIF
            ENDIF
            IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
             _bholdcontinue = 0, _fdrawheight += detailsection_info(rpt_calcheight,((_fenddetail -
              _yoffset) - _fdrawheight),_bholdcontinue)
             IF (_bholdcontinue=1)
              _fdrawheight = (_fenddetail+ 1)
             ENDIF
            ENDIF
            IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
             _bholdcontinue = 0, _fdrawheight += detailsection_note(rpt_calcheight,((_fenddetail -
              _yoffset) - _fdrawheight),_bholdcontinue)
             IF (_bholdcontinue=1)
              _fdrawheight = (_fenddetail+ 1)
             ENDIF
            ENDIF
           ENDIF
           IF (((_yoffset+ _fdrawheight) > _fenddetail))
            BREAK
           ELSEIF (_bholdcontinue=1
            AND _bcontdetailsection=0)
            BREAK
           ENDIF
           dummy_val = detailsection(rpt_render,(_fenddetail - _yoffset),_bcontdetailsection),
           bfirsttime = 0
         ENDWHILE
        ELSE
         found = findstring("rtf",question,1,1)
         IF (found > 0)
          inbuflen = size(question), temp = uar_rtf2(question,inbuflen,outbuffer,outbuflen,retbuflen,
           bflag)
         ELSE
          curquestionnbr = elig_cnt, lastqnnbrbreak = 0, outbuffer = question
         ENDIF
         _bcontdetailsection_question = 0, bfirsttime = 1
         WHILE (((_bcontdetailsection_question=1) OR (bfirsttime=1)) )
           _bholdcontinue = _bcontdetailsection_question, _fdrawheight = detailsection_question(
            rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
           IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
            IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
             _bholdcontinue = 0, _fdrawheight += detailsection_info(rpt_calcheight,((_fenddetail -
              _yoffset) - _fdrawheight),_bholdcontinue)
             IF (_bholdcontinue=1)
              _fdrawheight = (_fenddetail+ 1)
             ENDIF
            ENDIF
            IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
             _bholdcontinue = 0, _fdrawheight += detailsection_note(rpt_calcheight,((_fenddetail -
              _yoffset) - _fdrawheight),_bholdcontinue)
             IF (_bholdcontinue=1)
              _fdrawheight = (_fenddetail+ 1)
             ENDIF
            ENDIF
           ENDIF
           IF (((_yoffset+ _fdrawheight) > _fenddetail))
            BREAK
           ELSEIF (_bholdcontinue=1
            AND _bcontdetailsection_question=0)
            BREAK
           ENDIF
           dummy_val = detailsection_question(rpt_render,(_fenddetail - _yoffset),
            _bcontdetailsection_question), bfirsttime = 0
         ENDWHILE
        ENDIF
      ENDFOR
     ENDIF
     value_valid = 1, date_valid = 1
     IF (questionnaire_info_question_cnt > 0)
      verifyqnind = 0, noheader = 0, info_cnt = 0,
      found = 0, question = "", trueanswerind = "",
      falseanswerind = "", type = uar_i18ngetmessage(i18nlabel,"INFO_ANSWERS","INFORMATIONAL ANSWERS"
       ), _bcontquestionheadersection = 0,
      dummy_val = questionheadersection(rpt_render,((rptreport->m_pageheight - rptreport->
       m_marginbottom) - _yoffset),_bcontquestionheadersection), dummy_val =
      headpagesection_line_three(rpt_render)
      FOR (info_cnt = 1 TO questionnaire_info_question_cnt)
        trueanswerind = "", falseanswerind = "", question = questionnaire->info_questions[info_cnt].
        question,
        question_nbr = build(cnvtstring(questionnaire->info_questions[info_cnt].question_nbr),".")
        IF (uar_get_code_meaning(questionnaire->info_questions[info_cnt].value_cd)="TRUE")
         trueanswerind = "X"
        ENDIF
        IF (uar_get_code_meaning(questionnaire->info_questions[info_cnt].value_cd)="FALSE")
         falseanswerind = "X"
        ENDIF
        IF ((questionnaire->info_questions[info_cnt].req_date != 0))
         date_valid = 1, datestr = format(questionnaire->info_questions[info_cnt].specimen_test_dt_tm,
          cclfmt->shortdatetime)
        ELSE
         date_valid = 0
        ENDIF
        IF ((questionnaire->info_questions[info_cnt].req_value != 0))
         value_valid = 1, valuestr = questionnaire->info_questions[info_cnt].value
        ELSE
         value_valid = 0, valuestr = ""
        ENDIF
        found = findstring("rtf",question,1,1)
        IF (found > 0)
         inbuflen = size(question), temp = uar_rtf2(question,inbuflen,outbuffer,outbuflen,retbuflen,
          bflag)
        ELSE
         curquestionnbr = elig_cnt, lastqnnbrbreak = 0, outbuffer = question
        ENDIF
        _bcontdetailsection_info = 0, bfirsttime = 1
        WHILE (((_bcontdetailsection_info=1) OR (bfirsttime=1)) )
          _bholdcontinue = _bcontdetailsection_info, _fdrawheight = detailsection_info(rpt_calcheight,
           (_fenddetail - _yoffset),_bholdcontinue)
          IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
           IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
            _bholdcontinue = 0, _fdrawheight += detailsection_note(rpt_calcheight,((_fenddetail -
             _yoffset) - _fdrawheight),_bholdcontinue)
            IF (_bholdcontinue=1)
             _fdrawheight = (_fenddetail+ 1)
            ENDIF
           ENDIF
          ENDIF
          IF (((_yoffset+ _fdrawheight) > _fenddetail))
           BREAK
          ELSEIF (_bholdcontinue=1
           AND _bcontdetailsection_info=0)
           BREAK
          ENDIF
          dummy_val = detailsection_info(rpt_render,(_fenddetail - _yoffset),_bcontdetailsection_info
           ), bfirsttime = 0
        ENDWHILE
      ENDFOR
     ENDIF
     IF (size(questionnaire->notes,5) > 0)
      noheader = 1, note_cnt = size(questionnaire->notes,5), note_idx = 1,
      note_label = "", note_txt = ""
      FOR (note_idx = 1 TO note_cnt)
        IF (uar_get_code_meaning(questionnaire->notes[note_idx].note_type_cd)="ELIG")
         note_label = uar_get_code_display(questionnaire->notes[note_idx].note_type_cd), note_txt =
         questionnaire->notes[note_idx].note_text
        ELSEIF (uar_get_code_meaning(questionnaire->notes[note_idx].note_type_cd)="VERIFY")
         note_label = uar_get_code_display(questionnaire->notes[note_idx].note_type_cd), note_txt =
         questionnaire->notes[note_idx].note_text
        ENDIF
        _bcontdetailsection_note = 0, bfirsttime = 1
        WHILE (((_bcontdetailsection_note=1) OR (bfirsttime=1)) )
          _bholdcontinue = _bcontdetailsection_note, _fdrawheight = detailsection_note(rpt_calcheight,
           (_fenddetail - _yoffset),_bholdcontinue)
          IF (((_yoffset+ _fdrawheight) > _fenddetail))
           BREAK
          ELSEIF (_bholdcontinue=1
           AND _bcontdetailsection_note=0)
           BREAK
          ENDIF
          dummy_val = detailsection_note(rpt_render,(_fenddetail - _yoffset),_bcontdetailsection_note
           ), bfirsttime = 0
        ENDWHILE
      ENDFOR
     ENDIF
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, _bcontfootpagesection = 0,
     dummy_val = footpagesection(rpt_render,((rptreport->m_pageheight - rptreport->m_marginbottom) -
      _yoffset),_bcontfootpagesection), _yoffset = _yhold
    WITH nocounter, separator = " ", format
   ;end select
 END ;Subroutine
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE (finalizereport(ssendreport=vc) =null WITH protect)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptstat = uar_rptendreport(_hreport)
   DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
   DECLARE bprint = i2 WITH noconstant(0), private
   IF (textlen(sfilename) > 0)
    SET bprint = checkqueue(sfilename)
    IF (bprint)
     EXECUTE cpm_create_file_name "RPT", "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
   IF (bprint)
    SET spool value(sfilename) value(ssendreport) WITH deleted
   ENDIF
   DECLARE _errorfound = i2 WITH noconstant(0), protect
   DECLARE _errcnt = i2 WITH noconstant(0), protect
   SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
   WHILE (_errorfound=rpt_errorfound
    AND _errcnt < 512)
     SET _errcnt += 1
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE (headpagesection_one(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection_oneabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesection_oneabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =
  f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_prot_mnemonic = f8 WITH noconstant(0.0), private
   DECLARE drawheight_prin_inv = f8 WITH noconstant(0.0), private
   DECLARE __prot_mnemonic = vc WITH noconstant(build2(concat(uar_i18ngetmessage(i18nlabel,"PROTOCOL",
       "PROTOCOL: "),trim(questionnaire->primary_mnemonic)),char(0))), protect
   DECLARE __prin_inv = vc WITH noconstant(build2(concat(uar_i18ngetmessage(i18nlabel,"PI",
       "PRINCIPAL INVESTIGATOR:"),pi_name_concat),char(0))), protect
   IF (bcontinue=0)
    SET _remprot_mnemonic = 1
    SET _remprin_inv = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremprot_mnemonic = _remprot_mnemonic
   IF (_remprot_mnemonic > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprot_mnemonic,((size(
        __prot_mnemonic) - _remprot_mnemonic)+ 1),__prot_mnemonic)))
    SET drawheight_prot_mnemonic = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprot_mnemonic = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprot_mnemonic,((size(__prot_mnemonic)
        - _remprot_mnemonic)+ 1),__prot_mnemonic)))))
     SET _remprot_mnemonic += rptsd->m_drawlength
    ELSE
     SET _remprot_mnemonic = 0
    ENDIF
    SET growsum += _remprot_mnemonic
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.010)
   SET rptsd->m_width = 3.490
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremprin_inv = _remprin_inv
   IF (_remprin_inv > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprin_inv,((size(
        __prin_inv) - _remprin_inv)+ 1),__prin_inv)))
    SET drawheight_prin_inv = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprin_inv = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprin_inv,((size(__prin_inv) -
       _remprin_inv)+ 1),__prin_inv)))))
     SET _remprin_inv += rptsd->m_drawlength
    ELSE
     SET _remprin_inv = 0
    ENDIF
    SET growsum += _remprin_inv
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.500
   SET rptsd->m_height = drawheight_prot_mnemonic
   IF (ncalc=rpt_render
    AND _holdremprot_mnemonic > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprot_mnemonic,((
       size(__prot_mnemonic) - _holdremprot_mnemonic)+ 1),__prot_mnemonic)))
   ELSE
    SET _remprot_mnemonic = _holdremprot_mnemonic
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.010)
   SET rptsd->m_width = 3.490
   SET rptsd->m_height = drawheight_prin_inv
   IF (ncalc=rpt_render
    AND _holdremprin_inv > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprin_inv,((size(
        __prin_inv) - _holdremprin_inv)+ 1),__prin_inv)))
   ELSE
    SET _remprin_inv = _holdremprin_inv
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpagesection_two(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection_twoabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesection_twoabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =
  f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_checklist_title = f8 WITH noconstant(0.0), private
   DECLARE drawheight_cra = f8 WITH noconstant(0.0), private
   DECLARE __checklist_title = vc WITH noconstant(build2(concat(uar_i18ngetmessage(i18nlabel,
       "PT_ELIG_CHKLST","CHECKLIST NAME: "),trim(questionnaire->checklist_name)),char(0))), protect
   DECLARE __cra = vc WITH noconstant(build2(concat(uar_i18ngetmessage(i18nlabel,"CRA",
       "CLINICAL RESEARCH ASSOCIATE:"),cra_name_concat),char(0))), protect
   IF (bcontinue=0)
    SET _remchecklist_title = 1
    SET _remcra = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremchecklist_title = _remchecklist_title
   IF (_remchecklist_title > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remchecklist_title,((size
       (__checklist_title) - _remchecklist_title)+ 1),__checklist_title)))
    SET drawheight_checklist_title = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remchecklist_title = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remchecklist_title,((size(
        __checklist_title) - _remchecklist_title)+ 1),__checklist_title)))))
     SET _remchecklist_title += rptsd->m_drawlength
    ELSE
     SET _remchecklist_title = 0
    ENDIF
    SET growsum += _remchecklist_title
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 3.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremcra = _remcra
   IF (_remcra > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcra,((size(__cra) -
       _remcra)+ 1),__cra)))
    SET drawheight_cra = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcra = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcra,((size(__cra) - _remcra)+ 1),__cra
       )))))
     SET _remcra += rptsd->m_drawlength
    ELSE
     SET _remcra = 0
    ENDIF
    SET growsum += _remcra
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.500
   SET rptsd->m_height = drawheight_checklist_title
   IF (ncalc=rpt_render
    AND _holdremchecklist_title > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremchecklist_title,((
       size(__checklist_title) - _holdremchecklist_title)+ 1),__checklist_title)))
   ELSE
    SET _remchecklist_title = _holdremchecklist_title
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 3.500
   SET rptsd->m_height = drawheight_cra
   IF (ncalc=rpt_render
    AND _holdremcra > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcra,((size(__cra)
        - _holdremcra)+ 1),__cra)))
   ELSE
    SET _remcra = _holdremcra
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpagesection_three(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection_threeabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesection_threeabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)
  ) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_irb_date = f8 WITH noconstant(0.0), private
   DECLARE __irb_date = vc WITH noconstant(build2(concat(uar_i18ngetmessage(i18nlabel,"IRB_LABEL",
       "IRB APPROVAL DATE: "),build(format(questionnaire->amd_irb_appr_dt,cclfmt->shortdate))),char(0
      ))), protect
   IF (bcontinue=0)
    SET _remirb_date = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremirb_date = _remirb_date
   IF (_remirb_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remirb_date,((size(
        __irb_date) - _remirb_date)+ 1),__irb_date)))
    SET drawheight_irb_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remirb_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remirb_date,((size(__irb_date) -
       _remirb_date)+ 1),__irb_date)))))
     SET _remirb_date += rptsd->m_drawlength
    ELSE
     SET _remirb_date = 0
    ENDIF
    SET growsum += _remirb_date
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.500
   SET rptsd->m_height = drawheight_irb_date
   IF (ncalc=rpt_render
    AND _holdremirb_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremirb_date,((size(
        __irb_date) - _holdremirb_date)+ 1),__irb_date)))
   ELSE
    SET _remirb_date = _holdremirb_date
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpagesection_line_one(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection_line_oneabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesection_line_oneabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen30s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.063),(offsetx+ 7.510),(offsety+
     0.063))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpagesection_four(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection_fourabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesection_fourabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =
  f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_patient_mrn = f8 WITH noconstant(0.0), private
   DECLARE drawheight_mrn = f8 WITH noconstant(0.0), private
   DECLARE drawheight_patient_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_name = f8 WITH noconstant(0.0), private
   DECLARE __patient_mrn = vc WITH noconstant(build2(uar_i18ngetmessage(i18nlabel,"MRN",
      "PATIENT MRN:"),char(0))), protect
   DECLARE __mrn = vc WITH noconstant(build2(build(questionnaire->mrn),char(0))), protect
   DECLARE __patient_name = vc WITH noconstant(build2(uar_i18ngetmessage(i18nlabel,"PATIENT_NAME",
      "PATIENT NAME:"),char(0))), protect
   DECLARE __name = vc WITH noconstant(build2(build(questionnaire->patient_name),char(0))), protect
   IF (bcontinue=0)
    SET _rempatient_mrn = 1
    SET _remmrn = 1
    SET _rempatient_name = 1
    SET _remname = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdrempatient_mrn = _rempatient_mrn
   IF (_rempatient_mrn > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempatient_mrn,((size(
        __patient_mrn) - _rempatient_mrn)+ 1),__patient_mrn)))
    SET drawheight_patient_mrn = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempatient_mrn = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempatient_mrn,((size(__patient_mrn) -
       _rempatient_mrn)+ 1),__patient_mrn)))))
     SET _rempatient_mrn += rptsd->m_drawlength
    ELSE
     SET _rempatient_mrn = 0
    ENDIF
    SET growsum += _rempatient_mrn
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdbottomborder
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.500)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen10s0c0)
   SET _holdremmrn = _remmrn
   IF (_remmrn > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmrn,((size(__mrn) -
       _remmrn)+ 1),__mrn)))
    SET drawheight_mrn = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmrn = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmrn,((size(__mrn) - _remmrn)+ 1),__mrn
       )))))
     SET _remmrn += rptsd->m_drawlength
    ELSE
     SET _remmrn = 0
    ENDIF
    SET growsum += _remmrn
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdrempatient_name = _rempatient_name
   IF (_rempatient_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempatient_name,((size(
        __patient_name) - _rempatient_name)+ 1),__patient_name)))
    SET drawheight_patient_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempatient_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempatient_name,((size(__patient_name) -
       _rempatient_name)+ 1),__patient_name)))))
     SET _rempatient_name += rptsd->m_drawlength
    ELSE
     SET _rempatient_name = 0
    ENDIF
    SET growsum += _rempatient_name
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdbottomborder
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.500)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen10s0c0)
   SET _holdremname = _remname
   IF (_remname > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remname,((size(__name) -
       _remname)+ 1),__name)))
    SET drawheight_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remname = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remname,((size(__name) - _remname)+ 1),
       __name)))))
     SET _remname += rptsd->m_drawlength
    ELSE
     SET _remname = 0
    ENDIF
    SET growsum += _remname
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_patient_mrn
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND _holdrempatient_mrn > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempatient_mrn,((size
       (__patient_mrn) - _holdrempatient_mrn)+ 1),__patient_mrn)))
   ELSE
    SET _rempatient_mrn = _holdrempatient_mrn
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdbottomborder
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.500)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = drawheight_mrn
   SET _dummypen = uar_rptsetpen(_hreport,_pen10s0c0)
   IF (ncalc=rpt_render
    AND _holdremmrn > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmrn,((size(__mrn)
        - _holdremmrn)+ 1),__mrn)))
   ELSE
    SET _remmrn = _holdremmrn
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_patient_name
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND _holdrempatient_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempatient_name,((
       size(__patient_name) - _holdrempatient_name)+ 1),__patient_name)))
   ELSE
    SET _rempatient_name = _holdrempatient_name
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdbottomborder
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.500)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = drawheight_name
   SET _dummypen = uar_rptsetpen(_hreport,_pen10s0c0)
   IF (ncalc=rpt_render
    AND _holdremname > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremname,((size(__name
        ) - _holdremname)+ 1),__name)))
   ELSE
    SET _remname = _holdremname
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpagesection_five(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection_fiveabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesection_fiveabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =
  f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_primary_physician = f8 WITH noconstant(0.0), private
   DECLARE drawheight_physician = f8 WITH noconstant(0.0), private
   DECLARE drawheight_date_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_date = f8 WITH noconstant(0.0), private
   DECLARE __primary_physician = vc WITH noconstant(build2(uar_i18ngetmessage(i18nlabel,
      "PRIMARY_PHYS","PRIMARY PHYSICIAN:"),char(0))), protect
   DECLARE __physician = vc WITH noconstant(build2(build(questionnaire->primary_physician),char(0))),
   protect
   DECLARE __date_header = vc WITH noconstant(build2(uar_i18ngetmessage(i18nlabel,"DATE","DATE:"),
     char(0))), protect
   DECLARE __date = vc WITH noconstant(build2(build(format(questionnaire->record_dt_tm,cclfmt->
       shortdatetime)),char(0))), protect
   IF (bcontinue=0)
    SET _remprimary_physician = 1
    SET _remphysician = 1
    SET _remdate_header = 1
    SET _remdate = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremprimary_physician = _remprimary_physician
   IF (_remprimary_physician > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprimary_physician,((
       size(__primary_physician) - _remprimary_physician)+ 1),__primary_physician)))
    SET drawheight_primary_physician = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprimary_physician = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprimary_physician,((size(
        __primary_physician) - _remprimary_physician)+ 1),__primary_physician)))))
     SET _remprimary_physician += rptsd->m_drawlength
    ELSE
     SET _remprimary_physician = 0
    ENDIF
    SET growsum += _remprimary_physician
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdbottomborder
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.500)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen10s0c0)
   SET _holdremphysician = _remphysician
   IF (_remphysician > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remphysician,((size(
        __physician) - _remphysician)+ 1),__physician)))
    SET drawheight_physician = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remphysician = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remphysician,((size(__physician) -
       _remphysician)+ 1),__physician)))))
     SET _remphysician += rptsd->m_drawlength
    ELSE
     SET _remphysician = 0
    ENDIF
    SET growsum += _remphysician
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremdate_header = _remdate_header
   IF (_remdate_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdate_header,((size(
        __date_header) - _remdate_header)+ 1),__date_header)))
    SET drawheight_date_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdate_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdate_header,((size(__date_header) -
       _remdate_header)+ 1),__date_header)))))
     SET _remdate_header += rptsd->m_drawlength
    ELSE
     SET _remdate_header = 0
    ENDIF
    SET growsum += _remdate_header
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdbottomborder
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.500)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen10s0c0)
   SET _holdremdate = _remdate
   IF (_remdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdate,((size(__date) -
       _remdate)+ 1),__date)))
    SET drawheight_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdate = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdate,((size(__date) - _remdate)+ 1),
       __date)))))
     SET _remdate += rptsd->m_drawlength
    ELSE
     SET _remdate = 0
    ENDIF
    SET growsum += _remdate
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_primary_physician
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND _holdremprimary_physician > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprimary_physician,
       ((size(__primary_physician) - _holdremprimary_physician)+ 1),__primary_physician)))
   ELSE
    SET _remprimary_physician = _holdremprimary_physician
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdbottomborder
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.500)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = drawheight_physician
   SET _dummypen = uar_rptsetpen(_hreport,_pen10s0c0)
   IF (ncalc=rpt_render
    AND _holdremphysician > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremphysician,((size(
        __physician) - _holdremphysician)+ 1),__physician)))
   ELSE
    SET _remphysician = _holdremphysician
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_date_header
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND _holdremdate_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdate_header,((size
       (__date_header) - _holdremdate_header)+ 1),__date_header)))
   ELSE
    SET _remdate_header = _holdremdate_header
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdbottomborder
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.500)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = drawheight_date
   SET _dummypen = uar_rptsetpen(_hreport,_pen10s0c0)
   IF (ncalc=rpt_render
    AND _holdremdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdate,((size(__date
        ) - _holdremdate)+ 1),__date)))
   ELSE
    SET _remdate = _holdremdate
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpagesection_six(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection_sixabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesection_sixabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =
  f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_requesting_person_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_requesting_person = f8 WITH noconstant(0.0), private
   DECLARE drawheight_providing_person_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_providing_person = f8 WITH noconstant(0.0), private
   DECLARE __requesting_person_header = vc WITH noconstant(build2(uar_i18ngetmessage(i18nlabel,
      "REQUESTING","PERSON REQUESTING ENROLLMENT:"),char(0))), protect
   DECLARE __requesting_person = vc WITH noconstant(build2(build(questionnaire->elig_request_person),
     char(0))), protect
   DECLARE __providing_person_header = vc WITH noconstant(build2(uar_i18ngetmessage(i18nlabel,
      "VERIFYING","PERSON VERIFYING INFORMATION:"),char(0))), protect
   DECLARE __providing_person = vc WITH noconstant(build2(tmp_person,char(0))), protect
   IF (bcontinue=0)
    SET _remrequesting_person_header = 1
    SET _remrequesting_person = 1
    SET _remproviding_person_header = 1
    SET _remproviding_person = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremrequesting_person_header = _remrequesting_person_header
   IF (_remrequesting_person_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remrequesting_person_header,((size(__requesting_person_header) - _remrequesting_person_header
       )+ 1),__requesting_person_header)))
    SET drawheight_requesting_person_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remrequesting_person_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remrequesting_person_header,((size(
        __requesting_person_header) - _remrequesting_person_header)+ 1),__requesting_person_header)))
    ))
     SET _remrequesting_person_header += rptsd->m_drawlength
    ELSE
     SET _remrequesting_person_header = 0
    ENDIF
    SET growsum += _remrequesting_person_header
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdbottomborder
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.500)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen10s0c0)
   SET _holdremrequesting_person = _remrequesting_person
   IF (_remrequesting_person > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remrequesting_person,((
       size(__requesting_person) - _remrequesting_person)+ 1),__requesting_person)))
    SET drawheight_requesting_person = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remrequesting_person = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remrequesting_person,((size(
        __requesting_person) - _remrequesting_person)+ 1),__requesting_person)))))
     SET _remrequesting_person += rptsd->m_drawlength
    ELSE
     SET _remrequesting_person = 0
    ENDIF
    SET growsum += _remrequesting_person
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremproviding_person_header = _remproviding_person_header
   IF (_remproviding_person_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remproviding_person_header,((size(__providing_person_header) - _remproviding_person_header)+
       1),__providing_person_header)))
    SET drawheight_providing_person_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remproviding_person_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remproviding_person_header,((size(
        __providing_person_header) - _remproviding_person_header)+ 1),__providing_person_header)))))
     SET _remproviding_person_header += rptsd->m_drawlength
    ELSE
     SET _remproviding_person_header = 0
    ENDIF
    SET growsum += _remproviding_person_header
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdbottomborder
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.500)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen10s0c0)
   SET _holdremproviding_person = _remproviding_person
   IF (_remproviding_person > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remproviding_person,((
       size(__providing_person) - _remproviding_person)+ 1),__providing_person)))
    SET drawheight_providing_person = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remproviding_person = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remproviding_person,((size(
        __providing_person) - _remproviding_person)+ 1),__providing_person)))))
     SET _remproviding_person += rptsd->m_drawlength
    ELSE
     SET _remproviding_person = 0
    ENDIF
    SET growsum += _remproviding_person
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_requesting_person_header
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND _holdremrequesting_person_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremrequesting_person_header,((size(__requesting_person_header) -
       _holdremrequesting_person_header)+ 1),__requesting_person_header)))
   ELSE
    SET _remrequesting_person_header = _holdremrequesting_person_header
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdbottomborder
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.500)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = drawheight_requesting_person
   SET _dummypen = uar_rptsetpen(_hreport,_pen10s0c0)
   IF (ncalc=rpt_render
    AND _holdremrequesting_person > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremrequesting_person,
       ((size(__requesting_person) - _holdremrequesting_person)+ 1),__requesting_person)))
   ELSE
    SET _remrequesting_person = _holdremrequesting_person
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_providing_person_header
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND _holdremproviding_person_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremproviding_person_header,((size(__providing_person_header) -
       _holdremproviding_person_header)+ 1),__providing_person_header)))
   ELSE
    SET _remproviding_person_header = _holdremproviding_person_header
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdbottomborder
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.500)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = drawheight_providing_person
   SET _dummypen = uar_rptsetpen(_hreport,_pen10s0c0)
   IF (ncalc=rpt_render
    AND _holdremproviding_person > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremproviding_person,(
       (size(__providing_person) - _holdremproviding_person)+ 1),__providing_person)))
   ELSE
    SET _remproviding_person = _holdremproviding_person
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpagesection_seven(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection_sevenabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesection_sevenabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)
  ) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_see_notes = f8 WITH noconstant(0.0), private
   IF (size(questionnaire->notes,5) > 0)
    DECLARE __see_notes = vc WITH noconstant(build2(uar_i18ngetmessage(i18nlabel,"SEE_NOTES",
       "*See notes"),char(0))), protect
   ENDIF
   IF (bcontinue=0)
    SET _remsee_notes = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times90)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (size(questionnaire->notes,5) > 0)
    SET _holdremsee_notes = _remsee_notes
    IF (_remsee_notes > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remsee_notes,((size(
         __see_notes) - _remsee_notes)+ 1),__see_notes)))
     SET drawheight_see_notes = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remsee_notes = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remsee_notes,((size(__see_notes) -
        _remsee_notes)+ 1),__see_notes)))))
      SET _remsee_notes += rptsd->m_drawlength
     ELSE
      SET _remsee_notes = 0
     ENDIF
     SET growsum += _remsee_notes
    ENDIF
   ELSE
    SET _remsee_notes = 0
    SET _holdremsee_notes = _remsee_notes
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = drawheight_see_notes
   IF (ncalc=rpt_render
    AND _holdremsee_notes > 0)
    IF (size(questionnaire->notes,5) > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremsee_notes,((size(
         __see_notes) - _holdremsee_notes)+ 1),__see_notes)))
    ENDIF
   ELSE
    SET _remsee_notes = _holdremsee_notes
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpagesection_line_two(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection_line_twoabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesection_line_twoabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen30s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.063),(offsetx+ 7.510),(offsety+
     0.063))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (questionheadersection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = questionheadersectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (questionheadersectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)
  ) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.750000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_eligibility_ans = f8 WITH noconstant(0.0), private
   DECLARE drawheight_true = f8 WITH noconstant(0.0), private
   DECLARE drawheight_false = f8 WITH noconstant(0.0), private
   DECLARE drawheight_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_value = f8 WITH noconstant(0.0), private
   DECLARE __eligibility_ans = vc WITH noconstant(build2(build(type),char(0))), protect
   DECLARE __true = vc WITH noconstant(build2(uar_i18ngetmessage(i18nlabel,"TRUE","TRUE"),char(0))),
   protect
   DECLARE __false = vc WITH noconstant(build2(uar_i18ngetmessage(i18nlabel,"FALSE","FALSE"),char(0))
    ), protect
   DECLARE __date = vc WITH noconstant(build2(uar_i18ngetmessage(i18nlabel,"DATE_TIME","DATE/TIME"),
     char(0))), protect
   DECLARE __value = vc WITH noconstant(build2(uar_i18ngetmessage(i18nlabel,"VALUE","VALUE"),char(0))
    ), protect
   IF ( NOT (verifyqnind=0))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remeligibility_ans = 1
    SET _remtrue = 1
    SET _remfalse = 1
    SET _remdate = 1
    SET _remvalue = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.344)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times10u0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremeligibility_ans = _remeligibility_ans
   IF (_remeligibility_ans > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remeligibility_ans,((size
       (__eligibility_ans) - _remeligibility_ans)+ 1),__eligibility_ans)))
    SET drawheight_eligibility_ans = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remeligibility_ans = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remeligibility_ans,((size(
        __eligibility_ans) - _remeligibility_ans)+ 1),__eligibility_ans)))))
     SET _remeligibility_ans += rptsd->m_drawlength
    ELSE
     SET _remeligibility_ans = 0
    ENDIF
    SET growsum += _remeligibility_ans
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.594)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times90)
   SET _holdremtrue = _remtrue
   IF (_remtrue > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtrue,((size(__true) -
       _remtrue)+ 1),__true)))
    SET drawheight_true = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtrue = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtrue,((size(__true) - _remtrue)+ 1),
       __true)))))
     SET _remtrue += rptsd->m_drawlength
    ELSE
     SET _remtrue = 0
    ENDIF
    SET growsum += _remtrue
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.594)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfalse = _remfalse
   IF (_remfalse > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfalse,((size(__false)
        - _remfalse)+ 1),__false)))
    SET drawheight_false = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfalse = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfalse,((size(__false) - _remfalse)+ 1),
       __false)))))
     SET _remfalse += rptsd->m_drawlength
    ELSE
     SET _remfalse = 0
    ENDIF
    SET growsum += _remfalse
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.594)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.250)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremdate = _remdate
   IF (_remdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdate,((size(__date) -
       _remdate)+ 1),__date)))
    SET drawheight_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdate = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdate,((size(__date) - _remdate)+ 1),
       __date)))))
     SET _remdate += rptsd->m_drawlength
    ELSE
     SET _remdate = 0
    ENDIF
    SET growsum += _remdate
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.594)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.250)
   SET rptsd->m_width = 0.5
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremvalue = _remvalue
   IF (_remvalue > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remvalue,((size(__value)
        - _remvalue)+ 1),__value)))
    SET drawheight_value = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remvalue = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remvalue,((size(__value) - _remvalue)+ 1),
       __value)))))
     SET _remvalue += rptsd->m_drawlength
    ELSE
     SET _remvalue = 0
    ENDIF
    SET growsum += _remvalue
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.344)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = drawheight_eligibility_ans
   SET _dummyfont = uar_rptsetfont(_hreport,_times10u0)
   IF (ncalc=rpt_render
    AND _holdremeligibility_ans > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremeligibility_ans,((
       size(__eligibility_ans) - _holdremeligibility_ans)+ 1),__eligibility_ans)))
   ELSE
    SET _remeligibility_ans = _holdremeligibility_ans
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.594)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = drawheight_true
   SET _dummyfont = uar_rptsetfont(_hreport,_times90)
   IF (ncalc=rpt_render
    AND _holdremtrue > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtrue,((size(__true
        ) - _holdremtrue)+ 1),__true)))
   ELSE
    SET _remtrue = _holdremtrue
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.594)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = drawheight_false
   IF (ncalc=rpt_render
    AND _holdremfalse > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfalse,((size(
        __false) - _holdremfalse)+ 1),__false)))
   ELSE
    SET _remfalse = _holdremfalse
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.594)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_date
   IF (ncalc=rpt_render
    AND _holdremdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdate,((size(__date
        ) - _holdremdate)+ 1),__date)))
   ELSE
    SET _remdate = _holdremdate
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.594)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.250)
   SET rptsd->m_width = 0.5
   SET rptsd->m_height = drawheight_value
   IF (ncalc=rpt_render
    AND _holdremvalue > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremvalue,((size(
        __value) - _holdremvalue)+ 1),__value)))
   ELSE
    SET _remvalue = _holdremvalue
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (verifyheadersection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = verifyheadersectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (verifyheadersectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =
  f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.400000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_eligibility_ans = f8 WITH noconstant(0.0), private
   DECLARE drawheight_true = f8 WITH noconstant(0.0), private
   DECLARE drawheight_false = f8 WITH noconstant(0.0), private
   DECLARE drawheight_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_value = f8 WITH noconstant(0.0), private
   DECLARE drawheight_verification_ans = f8 WITH noconstant(0.0), private
   DECLARE drawheight_true_v = f8 WITH noconstant(0.0), private
   DECLARE drawheight_false_v = f8 WITH noconstant(0.0), private
   DECLARE drawheight_date_v = f8 WITH noconstant(0.0), private
   DECLARE drawheight_value_v = f8 WITH noconstant(0.0), private
   DECLARE __eligibility_ans = vc WITH noconstant(build2(uar_i18ngetmessage(i18nlabel,
      "ELIGIBILITY_ANS","ELIGIBILITY ANSWERS"),char(0))), protect
   DECLARE __true = vc WITH noconstant(build2(uar_i18ngetmessage(i18nlabel,"TRUE2","TRUE"),char(0))),
   protect
   DECLARE __false = vc WITH noconstant(build2(uar_i18ngetmessage(i18nlabel,"FALSE2","FALSE"),char(0)
     )), protect
   DECLARE __date = vc WITH noconstant(build2(uar_i18ngetmessage(i18nlabel,"DATE_TIME2","DATE/TIME"),
     char(0))), protect
   DECLARE __value = vc WITH noconstant(build2(uar_i18ngetmessage(i18nlabel,"VALUE2","VALUE"),char(0)
     )), protect
   DECLARE __verification_ans = vc WITH noconstant(build2(uar_i18ngetmessage(i18nlabel,
      "VERIFICATION_ANS","VERIFICATION ANSWERS"),char(0))), protect
   DECLARE __true_v = vc WITH noconstant(build2(uar_i18ngetmessage(i18nlabel,"TRUE3","TRUE"),char(0))
    ), protect
   DECLARE __false_v = vc WITH noconstant(build2(uar_i18ngetmessage(i18nlabel,"FALSE3","FALSE"),char(
      0))), protect
   DECLARE __date_v = vc WITH noconstant(build2(uar_i18ngetmessage(i18nlabel,"DATE_TIME3","DATE/TIME"
      ),char(0))), protect
   DECLARE __value_v = vc WITH noconstant(build2(uar_i18ngetmessage(i18nlabel,"VALUE3","VALUE"),char(
      0))), protect
   IF ( NOT (verifyqnind != 0))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remeligibility_ans = 1
    SET _remtrue = 1
    SET _remfalse = 1
    SET _remdate = 1
    SET _remvalue = 1
    SET _remverification_ans = 1
    SET _remtrue_v = 1
    SET _remfalse_v = 1
    SET _remdate_v = 1
    SET _remvalue_v = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times10u0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremeligibility_ans = _remeligibility_ans
   IF (_remeligibility_ans > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remeligibility_ans,((size
       (__eligibility_ans) - _remeligibility_ans)+ 1),__eligibility_ans)))
    SET drawheight_eligibility_ans = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remeligibility_ans = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remeligibility_ans,((size(
        __eligibility_ans) - _remeligibility_ans)+ 1),__eligibility_ans)))))
     SET _remeligibility_ans += rptsd->m_drawlength
    ELSE
     SET _remeligibility_ans = 0
    ENDIF
    SET growsum += _remeligibility_ans
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.425
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times90)
   SET _holdremtrue = _remtrue
   IF (_remtrue > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtrue,((size(__true) -
       _remtrue)+ 1),__true)))
    SET drawheight_true = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtrue = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtrue,((size(__true) - _remtrue)+ 1),
       __true)))))
     SET _remtrue += rptsd->m_drawlength
    ELSE
     SET _remtrue = 0
    ENDIF
    SET growsum += _remtrue
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.550)
   SET rptsd->m_width = 0.425
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfalse = _remfalse
   IF (_remfalse > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfalse,((size(__false)
        - _remfalse)+ 1),__false)))
    SET drawheight_false = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfalse = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfalse,((size(__false) - _remfalse)+ 1),
       __false)))))
     SET _remfalse += rptsd->m_drawlength
    ELSE
     SET _remfalse = 0
    ENDIF
    SET growsum += _remfalse
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.875)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremdate = _remdate
   IF (_remdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdate,((size(__date) -
       _remdate)+ 1),__date)))
    SET drawheight_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdate = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdate,((size(__date) - _remdate)+ 1),
       __date)))))
     SET _remdate += rptsd->m_drawlength
    ELSE
     SET _remdate = 0
    ENDIF
    SET growsum += _remdate
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.100)
   SET rptsd->m_width = 0.45
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremvalue = _remvalue
   IF (_remvalue > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remvalue,((size(__value)
        - _remvalue)+ 1),__value)))
    SET drawheight_value = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remvalue = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remvalue,((size(__value) - _remvalue)+ 1),
       __value)))))
     SET _remvalue += rptsd->m_drawlength
    ELSE
     SET _remvalue = 0
    ENDIF
    SET growsum += _remvalue
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.000)
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times10u0)
   SET _holdremverification_ans = _remverification_ans
   IF (_remverification_ans > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remverification_ans,((
       size(__verification_ans) - _remverification_ans)+ 1),__verification_ans)))
    SET drawheight_verification_ans = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remverification_ans = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remverification_ans,((size(
        __verification_ans) - _remverification_ans)+ 1),__verification_ans)))))
     SET _remverification_ans += rptsd->m_drawlength
    ELSE
     SET _remverification_ans = 0
    ENDIF
    SET growsum += _remverification_ans
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.000)
   SET rptsd->m_width = 0.425
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times90)
   SET _holdremtrue_v = _remtrue_v
   IF (_remtrue_v > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtrue_v,((size(__true_v
        ) - _remtrue_v)+ 1),__true_v)))
    SET drawheight_true_v = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtrue_v = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtrue_v,((size(__true_v) - _remtrue_v)
       + 1),__true_v)))))
     SET _remtrue_v += rptsd->m_drawlength
    ELSE
     SET _remtrue_v = 0
    ENDIF
    SET growsum += _remtrue_v
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.550)
   SET rptsd->m_width = 0.425
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfalse_v = _remfalse_v
   IF (_remfalse_v > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfalse_v,((size(
        __false_v) - _remfalse_v)+ 1),__false_v)))
    SET drawheight_false_v = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfalse_v = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfalse_v,((size(__false_v) -
       _remfalse_v)+ 1),__false_v)))))
     SET _remfalse_v += rptsd->m_drawlength
    ELSE
     SET _remfalse_v = 0
    ENDIF
    SET growsum += _remfalse_v
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.875)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremdate_v = _remdate_v
   IF (_remdate_v > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdate_v,((size(__date_v
        ) - _remdate_v)+ 1),__date_v)))
    SET drawheight_date_v = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdate_v = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdate_v,((size(__date_v) - _remdate_v)
       + 1),__date_v)))))
     SET _remdate_v += rptsd->m_drawlength
    ELSE
     SET _remdate_v = 0
    ENDIF
    SET growsum += _remdate_v
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.100)
   SET rptsd->m_width = 0.45
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremvalue_v = _remvalue_v
   IF (_remvalue_v > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remvalue_v,((size(
        __value_v) - _remvalue_v)+ 1),__value_v)))
    SET drawheight_value_v = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remvalue_v = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remvalue_v,((size(__value_v) -
       _remvalue_v)+ 1),__value_v)))))
     SET _remvalue_v += rptsd->m_drawlength
    ELSE
     SET _remvalue_v = 0
    ENDIF
    SET growsum += _remvalue_v
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = drawheight_eligibility_ans
   SET _dummyfont = uar_rptsetfont(_hreport,_times10u0)
   IF (ncalc=rpt_render
    AND _holdremeligibility_ans > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremeligibility_ans,((
       size(__eligibility_ans) - _holdremeligibility_ans)+ 1),__eligibility_ans)))
   ELSE
    SET _remeligibility_ans = _holdremeligibility_ans
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.425
   SET rptsd->m_height = drawheight_true
   SET _dummyfont = uar_rptsetfont(_hreport,_times90)
   IF (ncalc=rpt_render
    AND _holdremtrue > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtrue,((size(__true
        ) - _holdremtrue)+ 1),__true)))
   ELSE
    SET _remtrue = _holdremtrue
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.550)
   SET rptsd->m_width = 0.425
   SET rptsd->m_height = drawheight_false
   IF (ncalc=rpt_render
    AND _holdremfalse > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfalse,((size(
        __false) - _holdremfalse)+ 1),__false)))
   ELSE
    SET _remfalse = _holdremfalse
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.875)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = drawheight_date
   IF (ncalc=rpt_render
    AND _holdremdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdate,((size(__date
        ) - _holdremdate)+ 1),__date)))
   ELSE
    SET _remdate = _holdremdate
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.100)
   SET rptsd->m_width = 0.700
   SET rptsd->m_height = drawheight_value
   IF (ncalc=rpt_render
    AND _holdremvalue > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremvalue,((size(
        __value) - _holdremvalue)+ 1),__value)))
   ELSE
    SET _remvalue = _holdremvalue
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.000)
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = drawheight_verification_ans
   SET _dummyfont = uar_rptsetfont(_hreport,_times10u0)
   IF (ncalc=rpt_render
    AND _holdremverification_ans > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremverification_ans,(
       (size(__verification_ans) - _holdremverification_ans)+ 1),__verification_ans)))
   ELSE
    SET _remverification_ans = _holdremverification_ans
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.000)
   SET rptsd->m_width = 0.425
   SET rptsd->m_height = drawheight_true_v
   SET _dummyfont = uar_rptsetfont(_hreport,_times90)
   IF (ncalc=rpt_render
    AND _holdremtrue_v > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtrue_v,((size(
        __true_v) - _holdremtrue_v)+ 1),__true_v)))
   ELSE
    SET _remtrue_v = _holdremtrue_v
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.550)
   SET rptsd->m_width = 0.425
   SET rptsd->m_height = drawheight_false_v
   IF (ncalc=rpt_render
    AND _holdremfalse_v > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfalse_v,((size(
        __false_v) - _holdremfalse_v)+ 1),__false_v)))
   ELSE
    SET _remfalse_v = _holdremfalse_v
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.875)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = drawheight_date_v
   IF (ncalc=rpt_render
    AND _holdremdate_v > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdate_v,((size(
        __date_v) - _holdremdate_v)+ 1),__date_v)))
   ELSE
    SET _remdate_v = _holdremdate_v
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.100)
   SET rptsd->m_width = 0.700
   SET rptsd->m_height = drawheight_value_v
   IF (ncalc=rpt_render
    AND _holdremvalue_v > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremvalue_v,((size(
        __value_v) - _holdremvalue_v)+ 1),__value_v)))
   ELSE
    SET _remvalue_v = _holdremvalue_v
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpagesection_line_three(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection_line_threeabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesection_line_threeabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen10s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.063),(offsetx+ 7.510),(offsety+
     0.063))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (detailsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_true = f8 WITH noconstant(0.0), private
   DECLARE drawheight_false = f8 WITH noconstant(0.0), private
   DECLARE drawheight_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_value = f8 WITH noconstant(0.0), private
   DECLARE drawheight_true_v = f8 WITH noconstant(0.0), private
   DECLARE drawheight_false_v = f8 WITH noconstant(0.0), private
   DECLARE drawheight_date_v = f8 WITH noconstant(0.0), private
   DECLARE drawheight_value_v = f8 WITH noconstant(0.0), private
   DECLARE drawheight_question = f8 WITH noconstant(0.0), private
   DECLARE drawheight_question_nbr = f8 WITH noconstant(0.0), private
   DECLARE __true = vc WITH noconstant(build2(build(trueanswerind),char(0))), protect
   DECLARE __false = vc WITH noconstant(build2(build(falseanswerind),char(0))), protect
   IF (date_valid=1
    AND size(datestr,2) != 0)
    DECLARE __date = vc WITH noconstant(build2(build(datestr),char(0))), protect
   ENDIF
   IF (value_valid=1
    AND size(valuestr,2) != 0)
    DECLARE __value = vc WITH noconstant(build2(build(valuestr),char(0))), protect
   ENDIF
   DECLARE __true_v = vc WITH noconstant(build2(build(trueanswerind2),char(0))), protect
   DECLARE __false_v = vc WITH noconstant(build2(build(falseanswerind2),char(0))), protect
   IF (date_valid2=1)
    DECLARE __date_v = vc WITH noconstant(build2(build(datestr2),char(0))), protect
   ENDIF
   IF (value_valid2=1)
    DECLARE __value_v = vc WITH noconstant(build2(build(valuestr2),char(0))), protect
   ENDIF
   DECLARE __question = vc WITH noconstant(build2(outbuffer,char(0))), protect
   DECLARE __question_nbr = vc WITH noconstant(build2(build(question_nbr),char(0))), protect
   IF (bcontinue=0)
    SET _remtrue = 1
    SET _remfalse = 1
    SET _remdate = 1
    SET _remvalue = 1
    SET _remtrue_v = 1
    SET _remfalse_v = 1
    SET _remdate_v = 1
    SET _remvalue_v = 1
    SET _remquestion = 1
    SET _remquestion_nbr = 1
   ENDIF
   SET rptsd->m_flags = 21
   SET rptsd->m_borders = rpt_sdallborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.425
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times90)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremtrue = _remtrue
   IF (_remtrue > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtrue,((size(__true) -
       _remtrue)+ 1),__true)))
    SET drawheight_true = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtrue = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtrue,((size(__true) - _remtrue)+ 1),
       __true)))))
     SET _remtrue += rptsd->m_drawlength
    ELSE
     SET _remtrue = 0
    ENDIF
    SET growsum += _remtrue
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.550)
   SET rptsd->m_width = 0.425
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfalse = _remfalse
   IF (_remfalse > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfalse,((size(__false)
        - _remfalse)+ 1),__false)))
    SET drawheight_false = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfalse = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfalse,((size(__false) - _remfalse)+ 1),
       __false)))))
     SET _remfalse += rptsd->m_drawlength
    ELSE
     SET _remfalse = 0
    ENDIF
    SET growsum += _remfalse
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdbottomborder
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.875)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   IF (date_valid=1
    AND size(datestr,2) != 0)
    SET _holdremdate = _remdate
    IF (_remdate > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdate,((size(__date)
         - _remdate)+ 1),__date)))
     SET drawheight_date = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remdate = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdate,((size(__date) - _remdate)+ 1),
        __date)))))
      SET _remdate += rptsd->m_drawlength
     ELSE
      SET _remdate = 0
     ENDIF
     SET growsum += _remdate
    ENDIF
   ELSE
    SET _remdate = 0
    SET _holdremdate = _remdate
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.100)
   SET rptsd->m_width = 0.5
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   IF (value_valid=1
    AND size(valuestr,2) != 0)
    SET _holdremvalue = _remvalue
    IF (_remvalue > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remvalue,((size(__value)
         - _remvalue)+ 1),__value)))
     SET drawheight_value = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remvalue = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remvalue,((size(__value) - _remvalue)+ 1
        ),__value)))))
      SET _remvalue += rptsd->m_drawlength
     ELSE
      SET _remvalue = 0
     ENDIF
     SET growsum += _remvalue
    ENDIF
   ELSE
    SET _remvalue = 0
    SET _holdremvalue = _remvalue
   ENDIF
   SET rptsd->m_flags = 21
   SET rptsd->m_borders = rpt_sdallborders
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.000)
   SET rptsd->m_width = 0.425
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtrue_v = _remtrue_v
   IF (_remtrue_v > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtrue_v,((size(__true_v
        ) - _remtrue_v)+ 1),__true_v)))
    SET drawheight_true_v = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtrue_v = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtrue_v,((size(__true_v) - _remtrue_v)
       + 1),__true_v)))))
     SET _remtrue_v += rptsd->m_drawlength
    ELSE
     SET _remtrue_v = 0
    ENDIF
    SET growsum += _remtrue_v
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.550)
   SET rptsd->m_width = 0.425
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfalse_v = _remfalse_v
   IF (_remfalse_v > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfalse_v,((size(
        __false_v) - _remfalse_v)+ 1),__false_v)))
    SET drawheight_false_v = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfalse_v = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfalse_v,((size(__false_v) -
       _remfalse_v)+ 1),__false_v)))))
     SET _remfalse_v += rptsd->m_drawlength
    ELSE
     SET _remfalse_v = 0
    ENDIF
    SET growsum += _remfalse_v
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdbottomborder
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.875)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   IF (date_valid2=1)
    SET _holdremdate_v = _remdate_v
    IF (_remdate_v > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdate_v,((size(
         __date_v) - _remdate_v)+ 1),__date_v)))
     SET drawheight_date_v = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remdate_v = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdate_v,((size(__date_v) - _remdate_v)
        + 1),__date_v)))))
      SET _remdate_v += rptsd->m_drawlength
     ELSE
      SET _remdate_v = 0
     ENDIF
     SET growsum += _remdate_v
    ENDIF
   ELSE
    SET _remdate_v = 0
    SET _holdremdate_v = _remdate_v
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.100)
   SET rptsd->m_width = 0.45
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   IF (value_valid2=1)
    SET _holdremvalue_v = _remvalue_v
    IF (_remvalue_v > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remvalue_v,((size(
         __value_v) - _remvalue_v)+ 1),__value_v)))
     SET drawheight_value_v = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remvalue_v = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remvalue_v,((size(__value_v) -
        _remvalue_v)+ 1),__value_v)))))
      SET _remvalue_v += rptsd->m_drawlength
     ELSE
      SET _remvalue_v = 0
     ENDIF
     SET growsum += _remvalue_v
    ENDIF
   ELSE
    SET _remvalue_v = 0
    SET _holdremvalue_v = _remvalue_v
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _holdremquestion = _remquestion
   IF (_remquestion > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remquestion,((size(
        __question) - _remquestion)+ 1),__question)))
    SET drawheight_question = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remquestion = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remquestion,((size(__question) -
       _remquestion)+ 1),__question)))))
     SET _remquestion += rptsd->m_drawlength
    ELSE
     SET _remquestion = 0
    ENDIF
    SET growsum += _remquestion
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.800)
   SET rptsd->m_width = 0.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremquestion_nbr = _remquestion_nbr
   IF (_remquestion_nbr > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remquestion_nbr,((size(
        __question_nbr) - _remquestion_nbr)+ 1),__question_nbr)))
    SET drawheight_question_nbr = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remquestion_nbr = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remquestion_nbr,((size(__question_nbr) -
       _remquestion_nbr)+ 1),__question_nbr)))))
     SET _remquestion_nbr += rptsd->m_drawlength
    ELSE
     SET _remquestion_nbr = 0
    ENDIF
    SET growsum += _remquestion_nbr
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_borders = rpt_sdallborders
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.425
   SET rptsd->m_height = drawheight_true
   SET _dummyfont = uar_rptsetfont(_hreport,_times90)
   IF (ncalc=rpt_render
    AND _holdremtrue > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtrue,((size(__true
        ) - _holdremtrue)+ 1),__true)))
   ELSE
    SET _remtrue = _holdremtrue
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.550)
   SET rptsd->m_width = 0.425
   SET rptsd->m_height = drawheight_false
   IF (ncalc=rpt_render
    AND _holdremfalse > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfalse,((size(
        __false) - _holdremfalse)+ 1),__false)))
   ELSE
    SET _remfalse = _holdremfalse
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdbottomborder
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.875)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = drawheight_date
   IF (ncalc=rpt_render
    AND _holdremdate > 0)
    IF (date_valid=1
     AND size(datestr,2) != 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdate,((size(
         __date) - _holdremdate)+ 1),__date)))
    ENDIF
   ELSE
    SET _remdate = _holdremdate
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.100)
   SET rptsd->m_width = 0.5
   SET rptsd->m_height = drawheight_value
   IF (ncalc=rpt_render
    AND _holdremvalue > 0)
    IF (value_valid=1
     AND size(valuestr,2) != 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremvalue,((size(
         __value) - _holdremvalue)+ 1),__value)))
    ENDIF
   ELSE
    SET _remvalue = _holdremvalue
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_borders = rpt_sdallborders
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.000)
   SET rptsd->m_width = 0.425
   SET rptsd->m_height = drawheight_true_v
   IF (ncalc=rpt_render
    AND _holdremtrue_v > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtrue_v,((size(
        __true_v) - _holdremtrue_v)+ 1),__true_v)))
   ELSE
    SET _remtrue_v = _holdremtrue_v
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.550)
   SET rptsd->m_width = 0.425
   SET rptsd->m_height = drawheight_false_v
   IF (ncalc=rpt_render
    AND _holdremfalse_v > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfalse_v,((size(
        __false_v) - _holdremfalse_v)+ 1),__false_v)))
   ELSE
    SET _remfalse_v = _holdremfalse_v
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdbottomborder
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.875)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = drawheight_date_v
   IF (ncalc=rpt_render
    AND _holdremdate_v > 0)
    IF (date_valid2=1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdate_v,((size(
         __date_v) - _holdremdate_v)+ 1),__date_v)))
    ENDIF
   ELSE
    SET _remdate_v = _holdremdate_v
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.100)
   SET rptsd->m_width = 0.680
   SET rptsd->m_height = drawheight_value_v
   IF (ncalc=rpt_render
    AND _holdremvalue_v > 0)
    IF (value_valid2=1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremvalue_v,((size(
         __value_v) - _holdremvalue_v)+ 1),__value_v)))
    ENDIF
   ELSE
    SET _remvalue_v = _holdremvalue_v
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_question
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND _holdremquestion > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremquestion,((size(
        __question) - _holdremquestion)+ 1),__question)))
   ELSE
    SET _remquestion = _holdremquestion
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.800)
   SET rptsd->m_width = 0.250
   SET rptsd->m_height = drawheight_question_nbr
   IF (ncalc=rpt_render
    AND _holdremquestion_nbr > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremquestion_nbr,((
       size(__question_nbr) - _holdremquestion_nbr)+ 1),__question_nbr)))
   ELSE
    SET _remquestion_nbr = _holdremquestion_nbr
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (detailsection_question(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsection_questionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (detailsection_questionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)
  ) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_true = f8 WITH noconstant(0.0), private
   DECLARE drawheight_false = f8 WITH noconstant(0.0), private
   DECLARE drawheight_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_value = f8 WITH noconstant(0.0), private
   DECLARE drawheight_question = f8 WITH noconstant(0.0), private
   DECLARE drawheight_question_nbr = f8 WITH noconstant(0.0), private
   DECLARE __true = vc WITH noconstant(build2(build(trueanswerind),char(0))), protect
   DECLARE __false = vc WITH noconstant(build2(build(falseanswerind),char(0))), protect
   IF (date_valid=1
    AND size(datestr,2) != 0)
    DECLARE __date = vc WITH noconstant(build2(build(datestr),char(0))), protect
   ENDIF
   IF (value_valid=1
    AND size(valuestr,2) != 0)
    DECLARE __value = vc WITH noconstant(build2(build(valuestr),char(0))), protect
   ENDIF
   DECLARE __question = vc WITH noconstant(build2(outbuffer,char(0))), protect
   DECLARE __question_nbr = vc WITH noconstant(build2(build(question_nbr),char(0))), protect
   IF (bcontinue=0)
    SET _remtrue = 1
    SET _remfalse = 1
    SET _remdate = 1
    SET _remvalue = 1
    SET _remquestion = 1
    SET _remquestion_nbr = 1
   ENDIF
   SET rptsd->m_flags = 21
   SET rptsd->m_borders = rpt_sdallborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times90)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremtrue = _remtrue
   IF (_remtrue > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtrue,((size(__true) -
       _remtrue)+ 1),__true)))
    SET drawheight_true = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtrue = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtrue,((size(__true) - _remtrue)+ 1),
       __true)))))
     SET _remtrue += rptsd->m_drawlength
    ELSE
     SET _remtrue = 0
    ENDIF
    SET growsum += _remtrue
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfalse = _remfalse
   IF (_remfalse > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfalse,((size(__false)
        - _remfalse)+ 1),__false)))
    SET drawheight_false = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfalse = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfalse,((size(__false) - _remfalse)+ 1),
       __false)))))
     SET _remfalse += rptsd->m_drawlength
    ELSE
     SET _remfalse = 0
    ENDIF
    SET growsum += _remfalse
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdbottomborder
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   IF (date_valid=1
    AND size(datestr,2) != 0)
    SET _holdremdate = _remdate
    IF (_remdate > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdate,((size(__date)
         - _remdate)+ 1),__date)))
     SET drawheight_date = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remdate = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdate,((size(__date) - _remdate)+ 1),
        __date)))))
      SET _remdate += rptsd->m_drawlength
     ELSE
      SET _remdate = 0
     ENDIF
     SET growsum += _remdate
    ENDIF
   ELSE
    SET _remdate = 0
    SET _holdremdate = _remdate
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.250)
   SET rptsd->m_width = 0.5
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   IF (value_valid=1
    AND size(valuestr,2) != 0)
    SET _holdremvalue = _remvalue
    IF (_remvalue > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remvalue,((size(__value)
         - _remvalue)+ 1),__value)))
     SET drawheight_value = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remvalue = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remvalue,((size(__value) - _remvalue)+ 1
        ),__value)))))
      SET _remvalue += rptsd->m_drawlength
     ELSE
      SET _remvalue = 0
     ENDIF
     SET growsum += _remvalue
    ENDIF
   ELSE
    SET _remvalue = 0
    SET _holdremvalue = _remvalue
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 3.5
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _holdremquestion = _remquestion
   IF (_remquestion > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remquestion,((size(
        __question) - _remquestion)+ 1),__question)))
    SET drawheight_question = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remquestion = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remquestion,((size(__question) -
       _remquestion)+ 1),__question)))))
     SET _remquestion += rptsd->m_drawlength
    ELSE
     SET _remquestion = 0
    ENDIF
    SET growsum += _remquestion
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.5)
   SET rptsd->m_width = 0.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremquestion_nbr = _remquestion_nbr
   IF (_remquestion_nbr > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remquestion_nbr,((size(
        __question_nbr) - _remquestion_nbr)+ 1),__question_nbr)))
    SET drawheight_question_nbr = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remquestion_nbr = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remquestion_nbr,((size(__question_nbr) -
       _remquestion_nbr)+ 1),__question_nbr)))))
     SET _remquestion_nbr += rptsd->m_drawlength
    ELSE
     SET _remquestion_nbr = 0
    ENDIF
    SET growsum += _remquestion_nbr
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_borders = rpt_sdallborders
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = drawheight_true
   SET _dummyfont = uar_rptsetfont(_hreport,_times90)
   IF (ncalc=rpt_render
    AND _holdremtrue > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtrue,((size(__true
        ) - _holdremtrue)+ 1),__true)))
   ELSE
    SET _remtrue = _holdremtrue
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = drawheight_false
   IF (ncalc=rpt_render
    AND _holdremfalse > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfalse,((size(
        __false) - _holdremfalse)+ 1),__false)))
   ELSE
    SET _remfalse = _holdremfalse
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdbottomborder
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_date
   IF (ncalc=rpt_render
    AND _holdremdate > 0)
    IF (date_valid=1
     AND size(datestr,2) != 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdate,((size(
         __date) - _holdremdate)+ 1),__date)))
    ENDIF
   ELSE
    SET _remdate = _holdremdate
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.250)
   SET rptsd->m_width = 0.5
   SET rptsd->m_height = drawheight_value
   IF (ncalc=rpt_render
    AND _holdremvalue > 0)
    IF (value_valid=1
     AND size(valuestr,2) != 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremvalue,((size(
         __value) - _holdremvalue)+ 1),__value)))
    ENDIF
   ELSE
    SET _remvalue = _holdremvalue
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 3.5
   SET rptsd->m_height = drawheight_question
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND _holdremquestion > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremquestion,((size(
        __question) - _holdremquestion)+ 1),__question)))
   ELSE
    SET _remquestion = _holdremquestion
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.5)
   SET rptsd->m_width = 0.250
   SET rptsd->m_height = drawheight_question_nbr
   IF (ncalc=rpt_render
    AND _holdremquestion_nbr > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremquestion_nbr,((
       size(__question_nbr) - _holdremquestion_nbr)+ 1),__question_nbr)))
   ELSE
    SET _remquestion_nbr = _holdremquestion_nbr
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (detailsection_info(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsection_infoabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (detailsection_infoabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
   WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_true = f8 WITH noconstant(0.0), private
   DECLARE drawheight_false = f8 WITH noconstant(0.0), private
   DECLARE drawheight_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_value = f8 WITH noconstant(0.0), private
   DECLARE drawheight_question = f8 WITH noconstant(0.0), private
   DECLARE drawheight_question_nbr = f8 WITH noconstant(0.0), private
   DECLARE __true = vc WITH noconstant(build2(build(trueanswerind),char(0))), protect
   DECLARE __false = vc WITH noconstant(build2(build(falseanswerind),char(0))), protect
   IF (date_valid=1
    AND size(datestr,2) != 0)
    DECLARE __date = vc WITH noconstant(build2(build(datestr),char(0))), protect
   ENDIF
   IF (value_valid=1
    AND size(valuestr,2) != 0)
    DECLARE __value = vc WITH noconstant(build2(build(valuestr),char(0))), protect
   ENDIF
   DECLARE __question = vc WITH noconstant(build2(outbuffer,char(0))), protect
   DECLARE __question_nbr = vc WITH noconstant(build2(build(question_nbr),char(0))), protect
   IF (bcontinue=0)
    SET _remtrue = 1
    SET _remfalse = 1
    SET _remdate = 1
    SET _remvalue = 1
    SET _remquestion = 1
    SET _remquestion_nbr = 1
   ENDIF
   SET rptsd->m_flags = 21
   SET rptsd->m_borders = rpt_sdallborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times90)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremtrue = _remtrue
   IF (_remtrue > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtrue,((size(__true) -
       _remtrue)+ 1),__true)))
    SET drawheight_true = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtrue = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtrue,((size(__true) - _remtrue)+ 1),
       __true)))))
     SET _remtrue += rptsd->m_drawlength
    ELSE
     SET _remtrue = 0
    ENDIF
    SET growsum += _remtrue
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfalse = _remfalse
   IF (_remfalse > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfalse,((size(__false)
        - _remfalse)+ 1),__false)))
    SET drawheight_false = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfalse = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfalse,((size(__false) - _remfalse)+ 1),
       __false)))))
     SET _remfalse += rptsd->m_drawlength
    ELSE
     SET _remfalse = 0
    ENDIF
    SET growsum += _remfalse
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdbottomborder
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   IF (date_valid=1
    AND size(datestr,2) != 0)
    SET _holdremdate = _remdate
    IF (_remdate > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdate,((size(__date)
         - _remdate)+ 1),__date)))
     SET drawheight_date = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remdate = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdate,((size(__date) - _remdate)+ 1),
        __date)))))
      SET _remdate += rptsd->m_drawlength
     ELSE
      SET _remdate = 0
     ENDIF
     SET growsum += _remdate
    ENDIF
   ELSE
    SET _remdate = 0
    SET _holdremdate = _remdate
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.250)
   SET rptsd->m_width = 0.5
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   IF (value_valid=1
    AND size(valuestr,2) != 0)
    SET _holdremvalue = _remvalue
    IF (_remvalue > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remvalue,((size(__value)
         - _remvalue)+ 1),__value)))
     SET drawheight_value = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remvalue = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remvalue,((size(__value) - _remvalue)+ 1
        ),__value)))))
      SET _remvalue += rptsd->m_drawlength
     ELSE
      SET _remvalue = 0
     ENDIF
     SET growsum += _remvalue
    ENDIF
   ELSE
    SET _remvalue = 0
    SET _holdremvalue = _remvalue
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 3.5
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _holdremquestion = _remquestion
   IF (_remquestion > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remquestion,((size(
        __question) - _remquestion)+ 1),__question)))
    SET drawheight_question = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remquestion = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remquestion,((size(__question) -
       _remquestion)+ 1),__question)))))
     SET _remquestion += rptsd->m_drawlength
    ELSE
     SET _remquestion = 0
    ENDIF
    SET growsum += _remquestion
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.5)
   SET rptsd->m_width = 0.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremquestion_nbr = _remquestion_nbr
   IF (_remquestion_nbr > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remquestion_nbr,((size(
        __question_nbr) - _remquestion_nbr)+ 1),__question_nbr)))
    SET drawheight_question_nbr = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remquestion_nbr = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remquestion_nbr,((size(__question_nbr) -
       _remquestion_nbr)+ 1),__question_nbr)))))
     SET _remquestion_nbr += rptsd->m_drawlength
    ELSE
     SET _remquestion_nbr = 0
    ENDIF
    SET growsum += _remquestion_nbr
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_borders = rpt_sdallborders
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = drawheight_true
   SET _dummyfont = uar_rptsetfont(_hreport,_times90)
   IF (ncalc=rpt_render
    AND _holdremtrue > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtrue,((size(__true
        ) - _holdremtrue)+ 1),__true)))
   ELSE
    SET _remtrue = _holdremtrue
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.625)
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = drawheight_false
   IF (ncalc=rpt_render
    AND _holdremfalse > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfalse,((size(
        __false) - _holdremfalse)+ 1),__false)))
   ELSE
    SET _remfalse = _holdremfalse
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdbottomborder
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_date
   IF (ncalc=rpt_render
    AND _holdremdate > 0)
    IF (date_valid=1
     AND size(datestr,2) != 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdate,((size(
         __date) - _holdremdate)+ 1),__date)))
    ENDIF
   ELSE
    SET _remdate = _holdremdate
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.250)
   SET rptsd->m_width = 0.5
   SET rptsd->m_height = drawheight_value
   IF (ncalc=rpt_render
    AND _holdremvalue > 0)
    IF (value_valid=1
     AND size(valuestr,2) != 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremvalue,((size(
         __value) - _holdremvalue)+ 1),__value)))
    ENDIF
   ELSE
    SET _remvalue = _holdremvalue
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 3.5
   SET rptsd->m_height = drawheight_question
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND _holdremquestion > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremquestion,((size(
        __question) - _holdremquestion)+ 1),__question)))
   ELSE
    SET _remquestion = _holdremquestion
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.5)
   SET rptsd->m_width = 0.250
   SET rptsd->m_height = drawheight_question_nbr
   IF (ncalc=rpt_render
    AND _holdremquestion_nbr > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremquestion_nbr,((
       size(__question_nbr) - _holdremquestion_nbr)+ 1),__question_nbr)))
   ELSE
    SET _remquestion_nbr = _holdremquestion_nbr
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (detailsection_note(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsection_noteabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (detailsection_noteabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
   WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.750000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_note_label = f8 WITH noconstant(0.0), private
   DECLARE drawheight_note = f8 WITH noconstant(0.0), private
   DECLARE __note_label = vc WITH noconstant(build2(build(note_label),char(0))), protect
   DECLARE __note = vc WITH noconstant(build2(build(note_txt),char(0))), protect
   IF (bcontinue=0)
    SET _remnote_label = 1
    SET _remnote = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times10u0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremnote_label = _remnote_label
   IF (_remnote_label > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnote_label,((size(
        __note_label) - _remnote_label)+ 1),__note_label)))
    SET drawheight_note_label = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnote_label = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnote_label,((size(__note_label) -
       _remnote_label)+ 1),__note_label)))))
     SET _remnote_label += rptsd->m_drawlength
    ELSE
     SET _remnote_label = 0
    ENDIF
    SET growsum += _remnote_label
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.500)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times90)
   SET _holdremnote = _remnote
   IF (_remnote > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnote,((size(__note) -
       _remnote)+ 1),__note)))
    SET drawheight_note = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnote = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnote,((size(__note) - _remnote)+ 1),
       __note)))))
     SET _remnote += rptsd->m_drawlength
    ELSE
     SET _remnote = 0
    ENDIF
    SET growsum += _remnote
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = drawheight_note_label
   SET _dummyfont = uar_rptsetfont(_hreport,_times10u0)
   IF (ncalc=rpt_render
    AND _holdremnote_label > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnote_label,((size(
        __note_label) - _holdremnote_label)+ 1),__note_label)))
   ELSE
    SET _remnote_label = _holdremnote_label
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.500)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = drawheight_note
   SET _dummyfont = uar_rptsetfont(_hreport,_times90)
   IF (ncalc=rpt_render
    AND _holdremnote > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnote,((size(__note
        ) - _holdremnote)+ 1),__note)))
   ELSE
    SET _remnote = _holdremnote
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footpagesection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpagesectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_rpt_page = f8 WITH noconstant(0.0), private
   DECLARE __label_rpt_page = vc WITH noconstant(build2(build(concat(uar_i18ngetmessage(i18nlabel,
        "RPT_PAGE","Page:")," ",trim(cnvtstring(curpage),3)),char(0)),char(0))), protect
   IF (bcontinue=0)
    SET _remlabel_rpt_page = 1
   ENDIF
   SET rptsd->m_flags = 21
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_rpt_page = _remlabel_rpt_page
   IF (_remlabel_rpt_page > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_rpt_page,((size(
        __label_rpt_page) - _remlabel_rpt_page)+ 1),__label_rpt_page)))
    SET drawheight_label_rpt_page = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_rpt_page = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_rpt_page,((size(__label_rpt_page
        ) - _remlabel_rpt_page)+ 1),__label_rpt_page)))))
     SET _remlabel_rpt_page += rptsd->m_drawlength
    ELSE
     SET _remlabel_rpt_page = 0
    ENDIF
    SET growsum += _remlabel_rpt_page
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = drawheight_label_rpt_page
   IF (ncalc=rpt_render
    AND _holdremlabel_rpt_page > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_rpt_page,((
       size(__label_rpt_page) - _holdremlabel_rpt_page)+ 1),__label_rpt_page)))
   ELSE
    SET _remlabel_rpt_page = _holdremlabel_rpt_page
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "CT_RPT_QUESTIONNAIRE_LAYOUT"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 60
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 9
   SET _times90 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_underline = rpt_on
   SET _times10u0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET rptfont->m_underline = rpt_off
   SET _times80 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.030
   SET _pen30s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.010
   SET _pen10s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE i18nlabel = i4 WITH public, noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nlabel,curprog,"",curcclrev)
 DECLARE elig_mode = i2 WITH protect, noconstant(1)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE note_txt = vc WITH protect
 DECLARE pi_size = i2 WITH protect, noconstant(0)
 DECLARE pi_name_concat = vc WITH protect
 DECLARE cra_size = i2 WITH protect, noconstant(0)
 DECLARE cra_name_concat = vc WITH protect
 DECLARE inbuflen = i4
 DECLARE outbuffer = c10000 WITH noconstant("")
 DECLARE outbuflen = i4 WITH noconstant(10000)
 DECLARE retbuflen = i4 WITH noconstant(0)
 DECLARE bflag = i4 WITH noconstant(0)
 SET elig_mode = cnvtint( $ELIG_MODE_IND)
 CALL initializereport(0)
 CALL get_questionnaire(0)
 CALL finalizereport(_sendto)
 SET last_mod = "008"
 SET mod_date = "Jul 12, 2018"
END GO
