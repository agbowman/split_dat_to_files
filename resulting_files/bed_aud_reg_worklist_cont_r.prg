CREATE PROGRAM bed_aud_reg_worklist_cont_r
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM pm_que_work_list p
   PLAN (p
    WHERE p.active_ind=1)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 1500)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 1000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
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
  )
 ENDIF
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "Worklist Description"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Worklist Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Right-Click Conversation Name"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Double-click conversation Name"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Last Updated By"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SELECT INTO "nl:"
  pq.display, p.description, pm.display,
  p2.description, pq.script, pq.task_list_ind
  FROM pm_flx_conversation p,
   pm_flx_conversation p2,
   pm_que_work_list pq,
   pm_conv_reltn pc,
   pm_que_method pm,
   pm_que_value pv,
   prsnl prsnl
  PLAN (pq
   WHERE pq.active_ind=1)
   JOIN (pm
   WHERE pm.method_id=outerjoin(pq.method_id)
    AND pm.active_ind=outerjoin(1))
   JOIN (pc
   WHERE pc.parent_entity_id=outerjoin(pq.work_list_id)
    AND pc.active_ind=outerjoin(1))
   JOIN (p
   WHERE p.conversation_id=outerjoin(pc.conversation_id)
    AND p.active_ind=outerjoin(1))
   JOIN (pv
   WHERE pv.work_list_id=outerjoin(pq.work_list_id)
    AND pv.property_id=outerjoin(589749.00)
    AND pv.active_ind=outerjoin(1))
   JOIN (p2
   WHERE p2.task=outerjoin(cnvtreal(pv.value))
    AND p2.active_ind=outerjoin(1))
   JOIN (prsnl
   WHERE prsnl.person_id=outerjoin(pc.updt_id)
    AND prsnl.active_ind=outerjoin(1))
  ORDER BY pq.display
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,100)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,100)=0)
    stat = alterlist(reply->rowlist,(100+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,5), reply->rowlist[cnt].celllist[1].string_value =
   pq.display
   CASE (pq.task_list_ind)
    OF 0:
     reply->rowlist[cnt].celllist[2].string_value = "Associated Conversation"
    OF 1:
     IF (pq.script=" ")
      reply->rowlist[cnt].celllist[2].string_value = "List Only"
     ELSE
      reply->rowlist[cnt].celllist[2].string_value = "Simple Task"
     ENDIF
   ENDCASE
   reply->rowlist[cnt].celllist[3].string_value = p.description, reply->rowlist[cnt].celllist[4].
   string_value = p2.description, reply->rowlist[cnt].celllist[5].string_value = prsnl
   .name_full_formatted
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("erm_worklist_cont_r.csv")
 ENDIF
 CALL echorecord(reply)
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
