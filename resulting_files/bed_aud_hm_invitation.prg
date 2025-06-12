CREATE PROGRAM bed_aud_hm_invitation
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
        3 data_blob = gvc
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
 FREE RECORD temp
 RECORD temp(
   1 tlist[*]
     2 prog = vc
     2 loc_group = vc
     2 expectation = vc
     2 ltemplate = vc
     2 wf_name = vc
     2 wf_status = vc
     2 status_seq = i2
     2 ltext = vc
     2 active_ind = i2
 )
 FREE RECORD sort_temp
 RECORD sort_temp(
   1 tlist[*]
     2 prog = vc
     2 loc_group = vc
     2 expectation = vc
     2 ltemplate = vc
     2 wf_name = vc
     2 wf_status = vc
     2 status_seq = i2
     2 ltext = vc
     2 active_ind = i2
 )
 SET stat = alterlist(reply->collist,8)
 SET reply->collist[1].header_text = "Program"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Active"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Location Group"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Expectation"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Letter Template"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Workflow Name"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Workflow Status"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Letter Text"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM invtn_program inv,
    invtn_program_group invgrp,
    invtn_workflow invw,
    invtn_workflow_status invws,
    hm_expect exp
   PLAN (inv)
    JOIN (invgrp
    WHERE invgrp.program_group_id=inv.program_group_id)
    JOIN (exp
    WHERE exp.expect_meaning=inv.source_meaning)
    JOIN (invw
    WHERE invw.workflow_id=inv.workflow_id)
    JOIN (invws
    WHERE invws.workflow_id=invw.workflow_id)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 8000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE blobout = vc
 DECLARE blobnortf = vc
 DECLARE bsize = i4
 DECLARE text = vc
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM invtn_program inv,
   invtn_program_group invgrp,
   invtn_workflow invw,
   invtn_workflow_status invws,
   invtn_fragment invf,
   invtn_fragment invf1,
   code_value cv,
   long_blob lb,
   long_blob lb1,
   hm_expect exp
  PLAN (inv)
   JOIN (invgrp
   WHERE invgrp.program_group_id=inv.program_group_id)
   JOIN (exp
   WHERE exp.expect_meaning=inv.source_meaning)
   JOIN (invw
   WHERE invw.workflow_id=inv.workflow_id)
   JOIN (invws
   WHERE invws.workflow_id=invw.workflow_id)
   JOIN (cv
   WHERE cv.code_value=invws.tracking_status_cd
    AND cv.code_set=66500)
   JOIN (invf
   WHERE invf.program_group_id=inv.program_group_id
    AND invf.program_id=inv.program_id
    AND invf.tracking_status_cd=invws.tracking_status_cd)
   JOIN (lb
   WHERE outerjoin(invf.content_blob_id)=lb.long_blob_id)
   JOIN (invf1
   WHERE invf1.program_group_id=outerjoin(inv.program_group_id)
    AND invf1.program_id=outerjoin(inv.program_id)
    AND invf1.tracking_status_cd=outerjoin(0))
   JOIN (lb1
   WHERE outerjoin(invf1.content_blob_id)=lb1.long_blob_id)
  ORDER BY inv.program_name, invgrp.program_group_name, inv.source_meaning,
   cv.display
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(temp->tlist,tcnt), temp->tlist[tcnt].prog = inv.program_name,
   temp->tlist[tcnt].loc_group = invgrp.program_group_name, temp->tlist[tcnt].expectation = exp
   .expect_name, temp->tlist[tcnt].ltemplate = invgrp.communication_template,
   temp->tlist[tcnt].wf_name = invw.workflow_name, temp->tlist[tcnt].wf_status = cv.display, temp->
   tlist[tcnt].status_seq = invws.workflow_status_sequence,
   temp->tlist[tcnt].active_ind = inv.active_ind
   IF (invws.schedule_communication_ind=0)
    temp->tlist[tcnt].ltext = "None"
   ENDIF
   IF (invws.schedule_communication_ind=1)
    IF (invf.active_ind=1)
     lenblob = size(lb.long_blob), blobout = notrim(fillstring(32768," ")), blobnortf = notrim(
      fillstring(32768," ")),
     stat = uar_rtf(lb.long_blob,lenblob,blobnortf,size(blobnortf),bsize,
      1), temp->tlist[tcnt].ltext = blobnortf
    ELSEIF (invf1.tracking_status_cd=0
     AND invf1.active_ind=1)
     lenblob = size(lb1.long_blob), blobout = notrim(fillstring(32768," ")), blobnortf = notrim(
      fillstring(32768," ")),
     stat = uar_rtf(lb1.long_blob,lenblob,blobnortf,size(blobnortf),bsize,
      1), temp->tlist[tcnt].ltext = blobnortf
    ELSEIF (invf1.tracking_status_cd=0
     AND invf1.active_ind=0)
     temp->tlist[tcnt].ltext = "Default"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET tcnt1 = size(temp->tlist,5)
 SELECT INTO "nl:"
  FROM invtn_program inv,
   invtn_program_group invgrp,
   invtn_workflow invw,
   invtn_workflow_status invws,
   invtn_fragment invf,
   invtn_fragment invf1,
   code_value cv,
   long_blob lb1,
   hm_expect exp,
   dummyt d1
  PLAN (inv)
   JOIN (invgrp
   WHERE invgrp.program_group_id=inv.program_group_id)
   JOIN (exp
   WHERE exp.expect_meaning=inv.source_meaning)
   JOIN (invw
   WHERE invw.workflow_id=inv.workflow_id)
   JOIN (invws
   WHERE invws.workflow_id=invw.workflow_id)
   JOIN (cv
   WHERE cv.code_value=invws.tracking_status_cd
    AND cv.code_set=66500)
   JOIN (invf1
   WHERE invf1.program_id=outerjoin(inv.program_id)
    AND invf1.program_group_id=outerjoin(inv.program_group_id)
    AND invf1.tracking_status_cd=outerjoin(0))
   JOIN (lb1
   WHERE lb1.long_blob_id=outerjoin(invf1.content_blob_id))
   JOIN (d1)
   JOIN (invf
   WHERE invf.program_id=inv.program_id
    AND invf.program_group_id=invgrp.program_group_id
    AND invf.tracking_status_cd=invws.tracking_status_cd)
  DETAIL
   tcnt1 = (tcnt1+ 1), stat = alterlist(temp->tlist,tcnt1), temp->tlist[tcnt1].prog = inv
   .program_name,
   temp->tlist[tcnt1].loc_group = invgrp.program_group_name, temp->tlist[tcnt1].expectation = exp
   .expect_name, temp->tlist[tcnt1].ltemplate = invgrp.communication_template,
   temp->tlist[tcnt1].wf_name = invw.workflow_name, temp->tlist[tcnt1].wf_status = cv.display, temp->
   tlist[tcnt1].status_seq = invws.workflow_status_sequence,
   temp->tlist[tcnt1].active_ind = inv.active_ind
   IF (invws.schedule_communication_ind=0)
    temp->tlist[tcnt1].ltext = "None"
   ENDIF
   IF (invws.schedule_communication_ind=1)
    IF (invf1.active_ind=1)
     lenblob = size(lb1.long_blob), blobout = notrim(fillstring(32768," ")), blobnortf = notrim(
      fillstring(32768," ")),
     stat = uar_rtf(lb1.long_blob,lenblob,blobnortf,size(blobnortf),bsize,
      1), temp->tlist[tcnt1].ltext = blobnortf
    ELSEIF (invf1.tracking_status_cd=0
     AND invf1.active_ind=0)
     temp->tlist[tcnt1].ltext = "Default"
    ELSEIF (invf1.tracking_status_cd=0
     AND invf1.active_ind=1)
     lenblob = size(lb1.long_blob), blobout = notrim(fillstring(32768," ")), blobnortf = notrim(
      fillstring(32768," ")),
     stat = uar_rtf(lb1.long_blob,lenblob,blobnortf,size(blobnortf),bsize,
      1), temp->tlist[tcnt1].ltext = blobnortf
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d1, dontexist
 ;end select
 IF (tcnt1 > 0)
  SET stat = alterlist(sort_temp->tlist,tcnt1)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tcnt1)
   PLAN (d)
   ORDER BY temp->tlist[d.seq].prog, temp->tlist[d.seq].loc_group, temp->tlist[d.seq].expectation,
    temp->tlist[d.seq].status_seq
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), sort_temp->tlist[cnt].prog = temp->tlist[d.seq].prog, sort_temp->tlist[cnt].
    loc_group = temp->tlist[d.seq].loc_group,
    sort_temp->tlist[cnt].expectation = temp->tlist[d.seq].expectation, sort_temp->tlist[cnt].
    ltemplate = temp->tlist[d.seq].ltemplate, sort_temp->tlist[cnt].wf_name = temp->tlist[d.seq].
    wf_name,
    sort_temp->tlist[cnt].wf_status = temp->tlist[d.seq].wf_status, sort_temp->tlist[cnt].ltext =
    temp->tlist[d.seq].ltext, sort_temp->tlist[cnt].active_ind = temp->tlist[d.seq].active_ind
   WITH nocounter
  ;end select
  FOR (t = 1 TO tcnt1)
    SET temp->tlist[t].prog = sort_temp->tlist[t].prog
    SET temp->tlist[t].loc_group = sort_temp->tlist[t].loc_group
    SET temp->tlist[t].expectation = sort_temp->tlist[t].expectation
    SET temp->tlist[t].ltemplate = sort_temp->tlist[t].ltemplate
    SET temp->tlist[t].wf_name = sort_temp->tlist[t].wf_name
    SET temp->tlist[t].wf_status = sort_temp->tlist[t].wf_status
    SET temp->tlist[t].ltext = sort_temp->tlist[t].ltext
    SET temp->tlist[t].active_ind = sort_temp->tlist[t].active_ind
  ENDFOR
 ENDIF
 IF (tcnt1=0)
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO tcnt1)
   SET row_tot_cnt = (size(reply->rowlist,5)+ 1)
   SET stat = alterlist(reply->rowlist,row_tot_cnt)
   SET stat = alterlist(reply->rowlist[row_tot_cnt].celllist,8)
   SET reply->rowlist[row_tot_cnt].celllist[1].string_value = temp->tlist[x].prog
   IF ((temp->tlist[x].active_ind=1))
    SET reply->rowlist[row_tot_cnt].celllist[2].string_value = "X"
   ELSE
    SET reply->rowlist[row_tot_cnt].celllist[2].string_value = " "
   ENDIF
   SET reply->rowlist[row_tot_cnt].celllist[3].string_value = temp->tlist[x].loc_group
   SET reply->rowlist[row_tot_cnt].celllist[4].string_value = temp->tlist[x].expectation
   IF ((temp->tlist[x].ltemplate=" "))
    SET reply->rowlist[row_tot_cnt].celllist[5].string_value = "None"
   ELSE
    SET reply->rowlist[row_tot_cnt].celllist[5].string_value = temp->tlist[x].ltemplate
   ENDIF
   SET reply->rowlist[row_tot_cnt].celllist[6].string_value = temp->tlist[x].wf_name
   SET reply->rowlist[row_tot_cnt].celllist[7].string_value = temp->tlist[x].wf_status
   SET reply->rowlist[row_tot_cnt].celllist[8].string_value = temp->tlist[x].ltext
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("hm_invitation.csv")
 ENDIF
 CALL echorecord(temp)
END GO
