CREATE PROGRAM dcp_get_tasks_with_form:dba
 SET modify = predeclare
 RECORD reply(
   1 tasks[*]
     2 reference_task_id = f8
     2 task_description = vc
     2 dcp_forms_ref_id = f8
     2 form_description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE highvalues = vc
 DECLARE highbuffer = c20 WITH noconstant(fillstring(20," "))
 DECLARE ssearchstring = vc
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE batch_size = i4 WITH protect, noconstant(20)
 DECLARE cur_size = i4 WITH protect, noconstant(0)
 DECLARE loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE new_size = i4 WITH protect, noconstant(0)
 DECLARE start = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE nfoundindex = i4 WITH protect, noconstant(0)
 SET i18nhandle = uar_i18nalphabet_init()
 CALL uar_i18nalphabet_highchar(i18nhandle,highbuffer,size(highbuffer))
 SET highvalues = trim(highbuffer)
 CALL uar_i18nalphabet_end(i18nhandle)
 SET ssearchstring = cnvtupper(trim(request->task_description))
 SET highvalues = concat(ssearchstring,highvalues)
 RECORD taskdescriptionlist(
   1 list[*]
     2 reference_task_id = f8
     2 task_description = vc
     2 dcp_forms_ref_id = f8
     2 form_description = vc
     2 active_ind = i2
 )
 SET stat = alterlist(taskdescriptionlist->list,10)
 SELECT INTO "nl:"
  FROM order_task ot
  PLAN (ot
   WHERE ot.task_description_key BETWEEN ssearchstring AND highvalues)
  HEAD REPORT
   cnt = 0
  DETAIL
   IF (ot.reference_task_id != 0
    AND ot.active_ind=1
    AND ot.dcp_forms_ref_id > 0)
    cnt = (cnt+ 1)
    IF (cnt > value(size(taskdescriptionlist->list,5)))
     stat = alterlist(taskdescriptionlist->list,(cnt+ 20))
    ENDIF
    taskdescriptionlist->list[cnt].reference_task_id = ot.reference_task_id, taskdescriptionlist->
    list[cnt].task_description = ot.task_description, taskdescriptionlist->list[cnt].dcp_forms_ref_id
     = ot.dcp_forms_ref_id
   ENDIF
  FOOT REPORT
   stat = alterlist(taskdescriptionlist->list,cnt)
  WITH nocounter
 ;end select
 IF (value(size(taskdescriptionlist->list,5)) <= 0)
  SET cfailed = "T"
  GO TO exit_script
 ENDIF
 SET cur_size = value(size(taskdescriptionlist->list,5))
 SET loop_cnt = ceil((cnvtreal(cur_size)/ batch_size))
 SET new_size = (loop_cnt * batch_size)
 SET stat = alterlist(taskdescriptionlist->list,new_size)
 FOR (i = (cur_size+ 1) TO new_size)
   SET taskdescriptionlist->list[i].dcp_forms_ref_id = taskdescriptionlist->list[cur_size].
   dcp_forms_ref_id
 ENDFOR
 SET start = 1
 SET num = 0
 SELECT INTO "nl:"
  dfr.dcp_forms_ref_id
  FROM (dummyt d  WITH seq = value(loop_cnt)),
   dcp_forms_ref dfr
  PLAN (d
   WHERE initarray(start,evaluate(d.seq,1,1,(start+ batch_size))))
   JOIN (dfr
   WHERE expand(num,start,((start+ batch_size) - 1),dfr.dcp_forms_ref_id,taskdescriptionlist->list[
    num].dcp_forms_ref_id)
    AND dfr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND dfr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND dfr.active_ind=1)
  ORDER BY dfr.dcp_forms_ref_id
  HEAD REPORT
   idx = 0
  HEAD dfr.dcp_forms_ref_id
   start = 1, nfoundindex = 0, nfoundindex = locateval(idx,start,cur_size,dfr.dcp_forms_ref_id,
    taskdescriptionlist->list[idx].dcp_forms_ref_id)
   WHILE (nfoundindex > 0)
     taskdescriptionlist->list[idx].form_description = dfr.description, taskdescriptionlist->list[idx
     ].active_ind = 1, nfoundindex = locateval(idx,(nfoundindex+ 1),cur_size,dfr.dcp_forms_ref_id,
      taskdescriptionlist->list[idx].dcp_forms_ref_id)
   ENDWHILE
  DETAIL
   dummy = 0
  FOOT  dfr.dcp_forms_ref_id
   idx = 0
  FOOT REPORT
   idx = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  staskdescriptionstring = cnvtupper(taskdescriptionlist->list[d2.seq].task_description)
  FROM (dummyt d2  WITH seq = value(size(taskdescriptionlist->list,5)))
  PLAN (d2
   WHERE (taskdescriptionlist->list[d2.seq].active_ind=1)
    AND (taskdescriptionlist->list[d2.seq].reference_task_id > 0.0))
  ORDER BY staskdescriptionstring
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > value(size(reply->tasks,5)))
    stat = alterlist(reply->tasks,(cnt+ 20))
   ENDIF
   reply->tasks[cnt].reference_task_id = taskdescriptionlist->list[d2.seq].reference_task_id, reply->
   tasks[cnt].task_description = taskdescriptionlist->list[d2.seq].task_description, reply->tasks[cnt
   ].dcp_forms_ref_id = taskdescriptionlist->list[d2.seq].dcp_forms_ref_id,
   reply->tasks[cnt].form_description = taskdescriptionlist->list[d2.seq].form_description
  FOOT REPORT
   stat = alterlist(reply->tasks,cnt)
  WITH nocounter
 ;end select
 FREE RECORD taskdescriptionlist
#exit_script
 IF (cfailed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
