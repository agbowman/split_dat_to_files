CREATE PROGRAM bhs_athn_get_endorsements
 FREE RECORD result
 RECORD result(
   1 endorsements[*]
     2 person_id = f8
     2 person_name = vc
     2 task_activity_cd = f8
     2 task_activity_meaning = vc
     2 type = vc
     2 folder_name = vc
     2 creation_dt_tm = dq8
     2 updated_dt_tm = dq8
     2 status_cd = f8
     2 status_disp = vc
     2 subject = vc
     2 msg_from = vc
     2 comment = vc
     2 discrete_ind = i2
     2 non_discrete_event_id = f8
     2 tasks[*]
       3 task_id = f8
       3 task_status_cd = f8
       3 task_status_meaning = vc
       3 task_status_disp = vc
       3 task_dt_tm = dq8
       3 task_create_dt_tm = dq8
       3 reference_task_id = f8
       3 event_id = f8
       3 event_tag = vc
       3 event_class_cd = f8
       3 event_class_meaning = vc
       3 event_end_dt_tm = dq8
       3 performed_prsnl_id = f8
       3 performed_prsnl_name = vc
       3 result_status_cd = f8
       3 result_status_disp = vc
       3 event_set_cd = f8
       3 event_set_display = vc
       3 parent_event_id = f8
       3 normalcy_cd = f8
       3 normalcy_disp = vc
       3 comment = vc
       3 msg_sender_id = f8
       3 msg_sender_name = vc
       3 updt_dt_tm = dq8
       3 encntr_id = f8
       3 msg_subject = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD normalcy
 RECORD normalcy(
   1 list[*]
     2 normalcy_cd = f8
     2 normalcy_disp = vc
     2 folder_name = vc
     2 folder_weight = i4
 ) WITH protect
 FREE RECORD req967140
 RECORD req967140(
   1 assign_prsnl_list[*]
     2 assign_prsnl_id = f8
   1 task_type_list[*]
     2 task_type = i2
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 get_all_active_status_ind = i2
   1 get_completed_endorsements_ind = i2
   1 get_onhold_endorsements_ind = i2
   1 apply_group_proxy_ind = i2
   1 suppress_unauth_doc_reviews_ind = i2
 ) WITH protect
 FREE RECORD rep967140
 RECORD rep967140(
   1 endorsement_list[*]
     2 task_id = f8
     2 task_type = i2
     2 task_status_cd = f8
     2 task_status_meaning = vc
     2 task_status_display = vc
     2 task_type_cd = f8
     2 task_type_meaning = vc
     2 task_type_display = vc
     2 task_activity_cd = f8
     2 task_activity_meaning = vc
     2 task_dt_tm = dq8
     2 task_create_dt_tm = dq8
     2 reference_task_id = f8
     2 msg_text_id = f8
     2 msg_subject_cd = f8
     2 msg_subject = vc
     2 msg_sender_id = f8
     2 msg_sender_name = vc
     2 comment = vc
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 external_reference_number = vc
     2 contributor_system_cd = f8
     2 encntr_id = f8
     2 person_id = f8
     2 person_name = vc
     2 assign_prsnl_id = f8
     2 assign_prsnl_name = vc
     2 event_id = f8
     2 event_tag = vc
     2 event_class_cd = f8
     2 event_class_meaning = vc
     2 event_class_display = vc
     2 event_end_dt_tm = dq8
     2 event_set_display = vc
     2 performed_prsnl_id = f8
     2 performed_prsnl_name = vc
     2 result_status_cd = f8
     2 result_status_meaning = vc
     2 result_status_display = vc
     2 scheduled_dt_tm = dq8
     2 transcribed_prsnl_id = f8
     2 transcribed_prsnl_name = vc
     2 event_set_cd = f8
     2 event_set_name = vc
     2 task_activity_class_cd = f8
     2 parent_event_id = f8
     2 normalcy_cd = f8
     2 encntr_type_cd = f8
     2 encntr_type_meaning = vc
     2 encntr_type_display = vc
     2 assign_updt_cnt = i4
   1 status_data
     2 status = c1
     2 substatus = i2
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callgetendorsements(null) = i4
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE kdx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE tpos = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 SET result->status_data.status = "F"
 IF (( $2 <= 0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 DECLARE c_abnormal_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"ABNORMAL"))
 DECLARE c_critical_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"CRITICAL"))
 DECLARE c_normal_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"NORMAL"))
 DECLARE c_vabnormal_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"VABNORMAL"))
 DECLARE c_high_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"HIGH"))
 DECLARE c_low_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"LOW"))
 DECLARE c_positive_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"POSITIVE"))
 DECLARE c_extremehigh_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"EXTREMEHIGH"))
 DECLARE c_extremelow_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"EXTREMELOW"))
 DECLARE c_panichigh_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"PANICHIGH"))
 DECLARE c_paniclow_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"PANICLOW"))
 DECLARE c_negative_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"NEGATIVE"))
 DECLARE c_folder_abnormal = vc WITH protect, constant("Abnormal")
 DECLARE c_folder_critical = vc WITH protect, constant("Critical")
 DECLARE c_folder_normal = vc WITH protect, constant("Normal")
 DECLARE c_folder_other = vc WITH protect, constant("Other")
 SET stat = alterlist(normalcy->list,12)
 SET normalcy->list[1].normalcy_cd = c_abnormal_cd
 SET normalcy->list[1].normalcy_disp = uar_get_code_description(c_abnormal_cd)
 SET normalcy->list[1].folder_name = c_folder_abnormal
 SET normalcy->list[1].folder_weight = 100
 SET normalcy->list[2].normalcy_cd = c_high_cd
 SET normalcy->list[2].normalcy_disp = uar_get_code_description(c_high_cd)
 SET normalcy->list[2].folder_name = c_folder_abnormal
 SET normalcy->list[2].folder_weight = 100
 SET normalcy->list[3].normalcy_cd = c_low_cd
 SET normalcy->list[3].normalcy_disp = uar_get_code_description(c_low_cd)
 SET normalcy->list[3].folder_name = c_folder_abnormal
 SET normalcy->list[3].folder_weight = 100
 SET normalcy->list[4].normalcy_cd = c_positive_cd
 SET normalcy->list[4].normalcy_disp = uar_get_code_description(c_positive_cd)
 SET normalcy->list[4].folder_name = c_folder_abnormal
 SET normalcy->list[4].folder_weight = 100
 SET normalcy->list[5].normalcy_cd = c_critical_cd
 SET normalcy->list[5].normalcy_disp = uar_get_code_description(c_critical_cd)
 SET normalcy->list[5].folder_name = c_folder_critical
 SET normalcy->list[5].folder_weight = 1000
 SET normalcy->list[6].normalcy_cd = c_extremehigh_cd
 SET normalcy->list[6].normalcy_disp = uar_get_code_description(c_extremehigh_cd)
 SET normalcy->list[6].folder_name = c_folder_critical
 SET normalcy->list[6].folder_weight = 1000
 SET normalcy->list[7].normalcy_cd = c_extremelow_cd
 SET normalcy->list[7].normalcy_disp = uar_get_code_description(c_extremelow_cd)
 SET normalcy->list[7].folder_name = c_folder_critical
 SET normalcy->list[7].folder_weight = 1000
 SET normalcy->list[8].normalcy_cd = c_panichigh_cd
 SET normalcy->list[8].normalcy_disp = uar_get_code_description(c_panichigh_cd)
 SET normalcy->list[8].folder_name = c_folder_critical
 SET normalcy->list[8].folder_weight = 1000
 SET normalcy->list[9].normalcy_cd = c_paniclow_cd
 SET normalcy->list[9].normalcy_disp = uar_get_code_description(c_paniclow_cd)
 SET normalcy->list[9].folder_name = c_folder_critical
 SET normalcy->list[9].folder_weight = 1000
 SET normalcy->list[10].normalcy_cd = c_vabnormal_cd
 SET normalcy->list[10].normalcy_disp = uar_get_code_description(c_vabnormal_cd)
 SET normalcy->list[10].folder_name = c_folder_critical
 SET normalcy->list[10].folder_weight = 1000
 SET normalcy->list[11].normalcy_cd = c_negative_cd
 SET normalcy->list[11].normalcy_disp = uar_get_code_description(c_negative_cd)
 SET normalcy->list[11].folder_name = c_folder_normal
 SET normalcy->list[11].folder_weight = 1
 SET normalcy->list[12].normalcy_cd = c_normal_cd
 SET normalcy->list[12].normalcy_disp = uar_get_code_description(c_normal_cd)
 SET normalcy->list[12].folder_name = c_folder_normal
 SET normalcy->list[12].folder_weight = 1
 CALL echorecord(normalcy)
 SET stat = callgetendorsements(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v0 = vc WITH protect, noconstant("")
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
  DECLARE v23 = vc WITH protect, noconstant("")
  DECLARE v24 = vc WITH protect, noconstant("")
  DECLARE v25 = vc WITH protect, noconstant("")
  DECLARE v26 = vc WITH protect, noconstant("")
  DECLARE v27 = vc WITH protect, noconstant("")
  DECLARE v28 = vc WITH protect, noconstant("")
  DECLARE v29 = vc WITH protect, noconstant("")
  DECLARE v30 = vc WITH protect, noconstant("")
  DECLARE v31 = vc WITH protect, noconstant("")
  DECLARE v32 = vc WITH protect, noconstant("")
  DECLARE v33 = vc WITH protect, noconstant("")
  DECLARE v34 = vc WITH protect, noconstant("")
  DECLARE v35 = vc WITH protect, noconstant("")
  DECLARE v36 = vc WITH protect, noconstant("")
  DECLARE v37 = vc WITH protect, noconstant("")
  DECLARE v38 = vc WITH protect, noconstant("")
  DECLARE v39 = vc WITH protect, noconstant("")
  DECLARE personname = vc WITH protect, noconstant("")
  DECLARE taskactivity = vc WITH protect, noconstant("")
  SELECT INTO value(moutputdevice)
   personname = result->endorsements[d.seq].person_name, taskactivity = result->endorsements[d.seq].
   task_activity_meaning
   FROM (dummyt d  WITH seq = value(size(result->endorsements,5)))
   PLAN (d
    WHERE d.seq > 0)
   ORDER BY personname, taskactivity
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v0 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v0, row + 1, col + 1,
    "<Endorsements>", row + 1
   DETAIL
    col + 1, "<Endorsement>", row + 1,
    v1 = build("<PersonId>",cnvtint(result->endorsements[d.seq].person_id),"</PersonId>"), col + 1,
    v1,
    row + 1, v2 = build("<PersonName>",trim(replace(replace(replace(replace(replace(result->
           endorsements[d.seq].person_name,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
       '"',"&quot;",0),3),"</PersonName>"), col + 1,
    v2, row + 1, v4 = build("<TaskActivityCd>",cnvtint(result->endorsements[d.seq].task_activity_cd),
     "</TaskActivityCd>"),
    col + 1, v4, row + 1,
    v5 = build("<TaskActivityMeaning>",trim(replace(replace(replace(replace(replace(result->
           endorsements[d.seq].task_activity_meaning,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
        "&apos;",0),'"',"&quot;",0),3),"</TaskActivityMeaning>"), col + 1, v5,
    row + 1, v6 = build("<Type>",trim(replace(replace(replace(replace(replace(result->endorsements[d
           .seq].type,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
     "</Type>"), col + 1,
    v6, row + 1, v7 = build("<FolderName>",trim(replace(replace(replace(replace(replace(result->
           endorsements[d.seq].folder_name,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
       '"',"&quot;",0),3),"</FolderName>"),
    col + 1, v7, row + 1,
    v8 = build("<CreationDate>",format(result->endorsements[d.seq].creation_dt_tm,
      "MM/DD/YYYY HH:MM:SS;;D"),"</CreationDate>"), col + 1, v8,
    row + 1, v9 = build("<UpdatedDate>",format(result->endorsements[d.seq].updated_dt_tm,
      "MM/DD/YYYY HH:MM:SS;;D"),"</UpdatedDate>"), col + 1,
    v9, row + 1, v10 = build("<TaskStatusCd>",cnvtint(result->endorsements[d.seq].status_cd),
     "</TaskStatusCd>"),
    col + 1, v10, row + 1,
    v11 = build("<TaskStatusDisp>",trim(replace(replace(replace(replace(replace(result->endorsements[
           d.seq].status_disp,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
       0),3),"</TaskStatusDisp>"), col + 1, v11,
    row + 1, v12 = build("<Subject>",trim(replace(replace(replace(replace(replace(result->
           endorsements[d.seq].subject,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
       "&quot;",0),3),"</Subject>"), col + 1,
    v12, row + 1, v13 = build("<MsgFrom>",trim(replace(replace(replace(replace(replace(result->
           endorsements[d.seq].msg_from,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
       '"',"&quot;",0),3),"</MsgFrom>"),
    col + 1, v13, row + 1,
    v14 = build("<Comment>",trim(replace(replace(replace(replace(replace(result->endorsements[d.seq].
           comment,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
     "</Comment>"), col + 1, v14,
    row + 1, col + 1, "<Tasks>",
    row + 1
    FOR (jdx = 1 TO size(result->endorsements[d.seq].tasks,5))
      col + 1, "<Task>", row + 1,
      v15 = build("<TaskId>",cnvtint(result->endorsements[d.seq].tasks[jdx].task_id),"</TaskId>"),
      col + 1, v15,
      row + 1, v16 = build("<TaskStatusCd>",cnvtint(result->endorsements[d.seq].tasks[jdx].
        task_status_cd),"</TaskStatusCd>"), col + 1,
      v16, row + 1, v17 = build("<TaskStatusMeaning>",trim(replace(replace(replace(replace(replace(
             result->endorsements[d.seq].tasks[jdx].task_status_meaning,"&","&amp;",0),"<","&lt;",0),
           ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</TaskStatusMeaning>"),
      col + 1, v17, row + 1,
      v18 = build("<TaskStatusDisp>",trim(replace(replace(replace(replace(replace(result->
             endorsements[d.seq].tasks[jdx].task_status_disp,"&","&amp;",0),"<","&lt;",0),">","&gt;",
           0),"'","&apos;",0),'"',"&quot;",0),3),"</TaskStatusDisp>"), col + 1, v18,
      row + 1, v19 = build("<TaskDate>",format(result->endorsements[d.seq].tasks[jdx].task_dt_tm,
        "MM/DD/YYYY HH:MM:SS;;D"),"</TaskDate>"), col + 1,
      v19, row + 1, v20 = build("<TaskCreateDate>",format(result->endorsements[d.seq].tasks[jdx].
        task_create_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),"</TaskCreateDate>"),
      col + 1, v20, row + 1,
      v21 = build("<ReferenceTaskId>",cnvtint(result->endorsements[d.seq].tasks[jdx].
        reference_task_id),"</ReferenceTaskId>"), col + 1, v21,
      row + 1, v22 = build("<EventId>",cnvtint(result->endorsements[d.seq].tasks[jdx].event_id),
       "</EventId>"), col + 1,
      v22, row + 1, v23 = build("<EventTag>",trim(replace(replace(replace(replace(replace(result->
             endorsements[d.seq].tasks[jdx].event_tag,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
          "&apos;",0),'"',"&quot;",0),3),"</EventTag>"),
      col + 1, v23, row + 1,
      v24 = build("<EventClassCd>",cnvtint(result->endorsements[d.seq].tasks[jdx].event_class_cd),
       "</EventClassCd>"), col + 1, v24,
      row + 1, v25 = build("<EventClassMeaning>",trim(replace(replace(replace(replace(replace(result
             ->endorsements[d.seq].tasks[jdx].event_class_meaning,"&","&amp;",0),"<","&lt;",0),">",
           "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</EventClassMeaning>"), col + 1,
      v25, row + 1, v26 = build("<EventEndDate>",format(result->endorsements[d.seq].tasks[jdx].
        event_end_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),"</EventEndDate>"),
      col + 1, v26, row + 1,
      v27 = build("<PerformedPrsnlId>",cnvtint(result->endorsements[d.seq].tasks[jdx].
        performed_prsnl_id),"</PerformedPrsnlId>"), col + 1, v27,
      row + 1, v28 = build("<PerformedPrsnlName>",trim(replace(replace(replace(replace(replace(result
             ->endorsements[d.seq].tasks[jdx].performed_prsnl_name,"&","&amp;",0),"<","&lt;",0),">",
           "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</PerformedPrsnlName>"), col + 1,
      v28, row + 1, v29 = build("<ResultStatusCd>",cnvtint(result->endorsements[d.seq].tasks[jdx].
        result_status_cd),"</ResultStatusCd>"),
      col + 1, v29, row + 1,
      v30 = build("<ResultStatusDisp>",trim(replace(replace(replace(replace(replace(result->
             endorsements[d.seq].tasks[jdx].result_status_disp,"&","&amp;",0),"<","&lt;",0),">",
           "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</ResultStatusDisp>"), col + 1, v30,
      row + 1, v31 = build("<EventSetCd>",cnvtint(result->endorsements[d.seq].tasks[jdx].event_set_cd
        ),"</EventSetCd>"), col + 1,
      v31, row + 1, v32 = build("<EventSetDisp>",trim(replace(replace(replace(replace(replace(result
             ->endorsements[d.seq].tasks[jdx].event_set_display,"&","&amp;",0),"<","&lt;",0),">",
           "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</EventSetDisp>"),
      col + 1, v32, row + 1,
      v33 = build("<ParentEventId>",cnvtint(result->endorsements[d.seq].tasks[jdx].parent_event_id),
       "</ParentEventId>"), col + 1, v33,
      row + 1, v34 = build("<NormalcyCd>",cnvtint(result->endorsements[d.seq].tasks[jdx].normalcy_cd),
       "</NormalcyCd>"), col + 1,
      v34, row + 1, v35 = build("<NormalcyDisp>",trim(replace(replace(replace(replace(replace(result
             ->endorsements[d.seq].tasks[jdx].normalcy_disp,"&","&amp;",0),"<","&lt;",0),">","&gt;",0
           ),"'","&apos;",0),'"',"&quot;",0),3),"</NormalcyDisp>"),
      col + 1, v35, row + 1,
      v36 = build("<Comment>",trim(replace(replace(replace(replace(replace(result->endorsements[d.seq
             ].tasks[jdx].comment,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
         "&quot;",0),3),"</Comment>"), col + 1, v36,
      row + 1, v37 = build("<MsgSenderId>",cnvtint(result->endorsements[d.seq].tasks[jdx].
        msg_sender_id),"</MsgSenderId>"), col + 1,
      v37, row + 1, v38 = build("<MsgSenderName>",trim(replace(replace(replace(replace(replace(result
             ->endorsements[d.seq].tasks[jdx].msg_sender_name,"&","&amp;",0),"<","&lt;",0),">","&gt;",
           0),"'","&apos;",0),'"',"&quot;",0),3),"</MsgSenderName>"),
      col + 1, v38, row + 1,
      v39 = build("<UpdatedDate>",format(result->endorsements[d.seq].tasks[jdx].updt_dt_tm,
        "MM/DD/YYYY HH:MM:SS;;D"),"</UpdatedDate>"), col + 1, v39,
      row + 1, v3 = build("<EncounterID>",cnvtint(result->endorsements[d.seq].tasks[jdx].encntr_id),
       "</EncounterID>"), col + 1,
      v3, row + 1, col + 1,
      "</Task>", row + 1
    ENDFOR
    col + 1, "</Tasks>", row + 1,
    col + 1, "</Endorsement>", row + 1
   FOOT REPORT
    col + 1, "</Endorsements>", row + 1,
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD normalcy
 FREE RECORD req967140
 FREE RECORD rep967140
 SUBROUTINE callgetendorsements(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(967100)
   DECLARE requestid = i4 WITH protect, constant(967140)
   DECLARE ecnt = i4 WITH protect, noconstant(0)
   DECLARE tcnt = i4 WITH protect, noconstant(0)
   DECLARE folder_name = vc WITH protect, noconstant("")
   DECLARE folder_weight = i4 WITH protect, noconstant(0)
   DECLARE creation_dt_tm = dq8 WITH protect, noconstant(0.0)
   DECLARE updated_dt_tm = dq8 WITH protect, noconstant(0.0)
   DECLARE status_cd = f8 WITH protect, noconstant(0.0)
   DECLARE status_disp = vc WITH protect, noconstant("")
   DECLARE msg_sender_id = f8 WITH protect, noconstant(0.0)
   DECLARE msg_from = vc WITH protect, noconstant("")
   DECLARE discrete_ind = i2 WITH protect, noconstant(0)
   DECLARE latest_task_dt_tm = dq8 WITH protect, noconstant(0.0)
   DECLARE c_type_to_sign = vc WITH protect, constant("ForwardedResultToSign")
   DECLARE c_type_to_review = vc WITH protect, constant("ForwardResultToReview")
   DECLARE c_hlatyping_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"HLATYPING"))
   DECLARE c_rad_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"RAD"))
   DECLARE c_ap_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"AP"))
   DECLARE c_mbo_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"MBO"))
   DECLARE c_procedure_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"PROCEDURE"))
   DECLARE c_helix_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"HELIX"))
   SET stat = alterlist(req967140->assign_prsnl_list,1)
   SET req967140->assign_prsnl_list[1].assign_prsnl_id =  $2
   SET stat = alterlist(req967140->task_type_list,2)
   SET req967140->task_type_list[1].task_type = 1
   SET req967140->task_type_list[2].task_type = 3
   SET req967140->beg_dt_tm = cnvtdatetime( $3)
   SET req967140->end_dt_tm = cnvtdatetime( $4)
   SET req967140->get_onhold_endorsements_ind = 1
   CALL echorecord(req967140)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req967140,
    "REC",rep967140,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep967140)
   IF ((rep967140->status_data.status="S"))
    SET stat = alterlist(result->endorsements,size(rep967140->endorsement_list,5))
    FOR (idx = 1 TO size(rep967140->endorsement_list,5))
      SET discrete_ind = evaluate(rep967140->endorsement_list[idx].event_class_cd,c_hlatyping_cd,0,
       c_rad_cd,0,
       c_ap_cd,0,c_mbo_cd,0,c_procedure_cd,
       0,c_helix_cd,0,1)
      IF (discrete_ind=1)
       SET pos = locateval(locidx,1,ecnt,rep967140->endorsement_list[idx].task_activity_cd,result->
        endorsements[locidx].task_activity_cd,
        rep967140->endorsement_list[idx].person_id,result->endorsements[locidx].person_id,1,result->
        endorsements[locidx].discrete_ind)
      ELSE
       SET pos = locateval(locidx,1,ecnt,rep967140->endorsement_list[idx].task_activity_cd,result->
        endorsements[locidx].task_activity_cd,
        rep967140->endorsement_list[idx].person_id,result->endorsements[locidx].person_id,rep967140->
        endorsement_list[idx].event_id,result->endorsements[locidx].non_discrete_event_id)
      ENDIF
      IF (pos=0)
       SET ecnt = (ecnt+ 1)
       SET pos = ecnt
       SET result->endorsements[pos].task_activity_cd = rep967140->endorsement_list[idx].
       task_activity_cd
       SET result->endorsements[pos].task_activity_meaning = rep967140->endorsement_list[idx].
       task_activity_meaning
       SET result->endorsements[pos].person_id = rep967140->endorsement_list[idx].person_id
       SET result->endorsements[pos].person_name = rep967140->endorsement_list[idx].person_name
       IF ((result->endorsements[pos].task_activity_meaning="SIGN RESULT"))
        SET result->endorsements[pos].type = c_type_to_sign
       ELSEIF ((result->endorsements[pos].task_activity_meaning="REVIEW RESUL"))
        SET result->endorsements[pos].type = c_type_to_review
       ELSE
        SET result->endorsements[pos].type = "Unknown"
       ENDIF
       SET result->endorsements[pos].discrete_ind = discrete_ind
       SET result->endorsements[pos].non_discrete_event_id = evaluate(discrete_ind,1,0,rep967140->
        endorsement_list[idx].event_id)
      ENDIF
      SET tcnt = (size(result->endorsements[pos].tasks,5)+ 1)
      SET stat = alterlist(result->endorsements[pos].tasks,tcnt)
      SET result->endorsements[pos].tasks[tcnt].task_id = rep967140->endorsement_list[idx].task_id
      SET result->endorsements[pos].tasks[tcnt].task_status_cd = rep967140->endorsement_list[idx].
      task_status_cd
      SET result->endorsements[pos].tasks[tcnt].task_status_disp = rep967140->endorsement_list[idx].
      task_status_display
      SET result->endorsements[pos].tasks[tcnt].task_status_meaning = rep967140->endorsement_list[idx
      ].task_status_meaning
      SET result->endorsements[pos].tasks[tcnt].task_dt_tm = rep967140->endorsement_list[idx].
      task_dt_tm
      SET result->endorsements[pos].tasks[tcnt].task_create_dt_tm = rep967140->endorsement_list[idx].
      task_create_dt_tm
      SET result->endorsements[pos].tasks[tcnt].reference_task_id = rep967140->endorsement_list[idx].
      reference_task_id
      SET result->endorsements[pos].tasks[tcnt].event_id = rep967140->endorsement_list[idx].event_id
      SET result->endorsements[pos].tasks[tcnt].event_tag = rep967140->endorsement_list[idx].
      event_tag
      SET result->endorsements[pos].tasks[tcnt].event_class_cd = rep967140->endorsement_list[idx].
      event_class_cd
      SET result->endorsements[pos].tasks[tcnt].event_class_meaning = rep967140->endorsement_list[idx
      ].event_class_meaning
      SET result->endorsements[pos].tasks[tcnt].event_end_dt_tm = rep967140->endorsement_list[idx].
      event_end_dt_tm
      SET result->endorsements[pos].tasks[tcnt].performed_prsnl_id = rep967140->endorsement_list[idx]
      .performed_prsnl_id
      SET result->endorsements[pos].tasks[tcnt].performed_prsnl_name = rep967140->endorsement_list[
      idx].performed_prsnl_name
      SET result->endorsements[pos].tasks[tcnt].result_status_cd = rep967140->endorsement_list[idx].
      result_status_cd
      SET result->endorsements[pos].tasks[tcnt].result_status_disp = rep967140->endorsement_list[idx]
      .result_status_display
      SET result->endorsements[pos].tasks[tcnt].event_set_cd = rep967140->endorsement_list[idx].
      event_set_cd
      SET result->endorsements[pos].tasks[tcnt].event_set_display = rep967140->endorsement_list[idx].
      event_set_display
      SET result->endorsements[pos].tasks[tcnt].parent_event_id = rep967140->endorsement_list[idx].
      parent_event_id
      SET result->endorsements[pos].tasks[tcnt].normalcy_cd = rep967140->endorsement_list[idx].
      normalcy_cd
      SET result->endorsements[pos].tasks[tcnt].comment = rep967140->endorsement_list[idx].comment
      SET result->endorsements[pos].tasks[tcnt].msg_sender_id = rep967140->endorsement_list[idx].
      msg_sender_id
      SET result->endorsements[pos].tasks[tcnt].msg_sender_name = rep967140->endorsement_list[idx].
      msg_sender_name
      SET result->endorsements[pos].tasks[tcnt].updt_dt_tm = rep967140->endorsement_list[idx].
      updt_dt_tm
      SET result->endorsements[pos].tasks[tcnt].encntr_id = rep967140->endorsement_list[idx].
      encntr_id
      SET result->endorsements[pos].tasks[tcnt].msg_subject = rep967140->endorsement_list[idx].
      msg_subject
    ENDFOR
    SET stat = alterlist(result->endorsements,ecnt)
    FOR (idx = 1 TO ecnt)
      SET tcnt = size(result->endorsements[idx].tasks,5)
      IF (tcnt=1)
       SET result->endorsements[idx].comment = result->endorsements[idx].tasks[1].comment
      ELSE
       FOR (kdx = 1 TO tcnt)
         IF (size(trim(result->endorsements[idx].tasks[kdx].comment,3)) > 0)
          SET result->endorsements[idx].comment = "Multiple"
          SET kdx = (tcnt+ 1)
         ENDIF
       ENDFOR
      ENDIF
      SET tpos = 1
      SET latest_task_dt_tm = result->endorsements[idx].tasks[tpos].task_dt_tm
      FOR (kdx = 2 TO tcnt)
        IF ((result->endorsements[idx].tasks[kdx].task_dt_tm > latest_task_dt_tm))
         SET tpos = kdx
         SET latest_task_dt_tm = result->endorsements[idx].tasks[kdx].task_dt_tm
        ENDIF
      ENDFOR
      IF (tcnt=1)
       SET result->endorsements[idx].subject = evaluate(size(trim(result->endorsements[idx].tasks[
          tpos].msg_subject,3)),0,result->endorsements[idx].tasks[tpos].event_tag,result->
        endorsements[idx].tasks[tpos].msg_subject)
      ELSE
       SET result->endorsements[idx].subject = result->endorsements[idx].tasks[tpos].msg_subject
      ENDIF
      SET status_cd = result->endorsements[idx].tasks[tpos].task_status_cd
      SET status_disp = result->endorsements[idx].tasks[tpos].task_status_disp
      SET folder_name = ""
      SET folder_weight = 0
      SET creation_dt_tm = 0.0
      SET updated_dt_tm = 0.0
      SET msg_sender_id = 0.0
      SET msg_from = ""
      FOR (jdx = 1 TO tcnt)
        SET pos = locateval(locidx,1,size(normalcy->list,5),result->endorsements[idx].tasks[jdx].
         normalcy_cd,normalcy->list[locidx].normalcy_cd)
        IF (pos > 0)
         IF ((normalcy->list[pos].folder_weight > folder_weight))
          SET folder_name = normalcy->list[pos].folder_name
          SET folder_weight = normalcy->list[pos].folder_weight
         ENDIF
        ELSE
         IF (10 > folder_weight)
          SET folder_name = c_folder_other
          SET folder_weight = 10
         ENDIF
        ENDIF
        IF ((result->endorsements[idx].tasks[jdx].normalcy_cd=c_critical_cd))
         SET folder_name = "Critical"
        ELSEIF ((((result->endorsements[idx].tasks[jdx].normalcy_cd=c_abnormal_cd)) OR ((result->
        endorsements[idx].tasks[jdx].normalcy_cd=c_vabnormal_cd)))
         AND folder_name != "Critical")
         SET folder_name = "Abnormal"
        ELSEIF (size(trim(folder_name,3))=0
         AND (result->endorsements[idx].tasks[jdx].normalcy_cd=c_normal_cd))
         SET folder_name = "Normal"
        ELSEIF (folder_name != "Critical"
         AND folder_name != "Abnormal"
         AND (result->endorsements[idx].tasks[jdx].normalcy_cd != c_normal_cd)
         AND (result->endorsements[idx].tasks[jdx].normalcy_cd != c_abnormal_cd)
         AND (result->endorsements[idx].tasks[jdx].normalcy_cd != c_vabnormal_cd)
         AND (result->endorsements[idx].tasks[jdx].normalcy_cd != c_critical_cd))
         SET folder_name = "Other"
        ENDIF
        IF (((creation_dt_tm=0.0) OR ((result->endorsements[idx].tasks[jdx].task_create_dt_tm <
        creation_dt_tm))) )
         SET creation_dt_tm = result->endorsements[idx].tasks[jdx].task_create_dt_tm
        ENDIF
        IF (((updated_dt_tm=0.0) OR ((result->endorsements[idx].tasks[jdx].updt_dt_tm > updated_dt_tm
        ))) )
         SET updated_dt_tm = result->endorsements[idx].tasks[jdx].updt_dt_tm
        ENDIF
        IF (msg_sender_id <= 0.0)
         SET msg_sender_id = result->endorsements[idx].tasks[jdx].msg_sender_id
         SET msg_from = result->endorsements[idx].tasks[jdx].msg_sender_name
        ELSEIF ((msg_sender_id != result->endorsements[idx].tasks[jdx].msg_sender_id))
         SET msg_from = "Multiple"
        ENDIF
      ENDFOR
      SET result->endorsements[idx].folder_name = folder_name
      SET result->endorsements[idx].creation_dt_tm = creation_dt_tm
      SET result->endorsements[idx].updated_dt_tm = updated_dt_tm
      SET result->endorsements[idx].status_cd = status_cd
      SET result->endorsements[idx].status_disp = status_disp
      SET result->endorsements[idx].msg_from = msg_from
    ENDFOR
    RETURN(success)
   ELSEIF ((rep967140->status_data.status="Z"))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
