CREATE PROGRAM ce_retrieve_action_comment:dba
 RECORD reply(
   1 event_prsnl_list[*]
     2 ce_event_prsnl_id = f8
     2 event_prsnl_id = f8
     2 person_id = f8
     2 event_id = f8
     2 valid_from_dt_tm = dq8
     2 valid_from_dt_tm_ind = i2
     2 valid_until_dt_tm = dq8
     2 valid_until_dt_tm_ind = i2
     2 action_type_cd = f8
     2 action_type_cd_disp = vc
     2 request_dt_tm = dq8
     2 request_dt_tm_ind = i2
     2 request_prsnl_id = f8
     2 request_prsnl_ft = vc
     2 request_comment = vc
     2 action_dt_tm = dq8
     2 action_dt_tm_ind = i2
     2 action_prsnl_id = f8
     2 action_prsnl_ft = vc
     2 proxy_prsnl_id = f8
     2 proxy_prsnl_ft = vc
     2 action_status_cd = f8
     2 action_status_cd_disp = vc
     2 action_comment = vc
     2 change_since_action_flag = i2
     2 change_since_action_flag_ind = i2
     2 updt_dt_tm = dq8
     2 updt_dt_tm_ind = i2
     2 updt_id = f8
     2 updt_task = i4
     2 updt_task_ind = i2
     2 updt_cnt = i4
     2 updt_cnt_ind = i2
     2 updt_applctx = i4
     2 updt_applctx_ind = i2
     2 long_text_id = f8
     2 long_text = vc
     2 linked_event_id = f8
     2 request_tz = i4
     2 action_tz = i4
     2 system_comment = vc
     2 digital_signature_ident = vc
     2 action_prsnl_group_id = f8
     2 request_prsnl_group_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD longtxtidlist
 RECORD longtxtidlist(
   1 from_ep_rec[*]
     2 long_text_id = f8
 )
 FREE RECORD audit_person_qual
 RECORD audit_person_qual(
   1 person_list[*]
     2 person_id = f8
 )
 SUBROUTINE checkerrors(operation)
   DECLARE errormsg = c255 WITH noconstant("")
   DECLARE errorcode = i4 WITH noconstant(0)
   SET errorcode = error(errormsg,0)
   IF (errorcode != 0)
    SET reply->status_data.subeventstatus[1].operationname = substring(1,25,trim(operation))
    SET reply->status_data.subeventstatus[1].targetobjectname = cnvtstring(errorcode)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errormsg
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SET reply->status_data.status = "F"
 DECLARE list_nsize = i2 WITH constant(40)
 DECLARE prsnl_size = i4 WITH constant(size(request->event_prsnl_id_list,5))
 DECLARE audit_size = i4 WITH noconstant(0)
 DECLARE prsnl_ndx = i4 WITH noconstant(1)
 DECLARE prsnl_nstart = i4 WITH protect, noconstant(1)
 DECLARE ntotal = i4 WITH noconstant(0)
 DECLARE ntotal2 = i4 WITH noconstant(0)
 DECLARE text_ndx = i4 WITH noconstant(1)
 DECLARE text_nstart = i4 WITH protect, noconstant(1)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE cnt2 = i4 WITH noconstant(0)
 DECLARE person_cnt = i4 WITH noconstant(0)
 DECLARE person_id = f8 WITH noconstant(0.0)
 DECLARE loop_count = i4 WITH noconstant(0)
 DECLARE new_size = i4 WITH noconstant(0)
 DECLARE pos = i4 WITH noconstant(0)
 DECLARE lastpos = i4 WITH noconstant(1)
 DECLARE num = i4 WITH noconstant(1)
 IF (prsnl_size <= 0)
  GO TO exit_script
 ENDIF
 SET loop_count = ceil((cnvtreal(prsnl_size)/ list_nsize))
 SET new_size = (loop_count * list_nsize)
 IF (new_size > prsnl_size)
  SET stat = alterlist(request->event_prsnl_id_list,new_size)
  FOR (i = (prsnl_size+ 1) TO new_size)
    SET request->event_prsnl_id_list[i].event_prsnl_id = request->event_prsnl_id_list[prsnl_size].
    event_prsnl_id
  ENDFOR
 ENDIF
 SELECT DISTINCT INTO "nl"
  cep.event_id, valid_from_dt_tm_ind = nullind(cep.valid_from_dt_tm), valid_until_dt_tm_ind = nullind
  (cep.valid_until_dt_tm),
  request_dt_tm_ind = nullind(cep.request_dt_tm), action_dt_tm_ind = nullind(cep.action_dt_tm),
  change_since_action_flag_ind = nullind(cep.change_since_action_flag),
  updt_dt_tm_ind = nullind(cep.updt_dt_tm), updt_task_ind = nullind(cep.updt_task), updt_cnt_ind =
  nullind(cep.updt_cnt),
  updt_applctx_ind = nullind(cep.updt_applctx)
  FROM ce_event_prsnl cep,
   (dummyt d  WITH seq = loop_count)
  PLAN (d
   WHERE assign(prsnl_nstart,evaluate(d.seq,1,1,(prsnl_nstart+ list_nsize))))
   JOIN (cep
   WHERE expand(prsnl_ndx,prsnl_nstart,((prsnl_nstart+ list_nsize) - 1),cep.event_prsnl_id,request->
    event_prsnl_id_list[prsnl_ndx].event_prsnl_id))
  ORDER BY cep.event_prsnl_id, cep.valid_from_dt_tm DESC
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->event_prsnl_list,(cnt+ 9))
   ENDIF
   IF (cep.long_text_id > 0)
    cnt2 = (cnt2+ 1)
    IF (mod(cnt2,10)=1)
     stat = alterlist(longtxtidlist->from_ep_rec,(cnt2+ 9))
    ENDIF
    longtxtidlist->from_ep_rec[cnt2].long_text_id = cep.long_text_id
   ENDIF
   IF (person_id != cep.person_id)
    IF (person_id > 0.0)
     person_id = cep.person_id, pos = locateval(num,lastpos,person_cnt,person_id,audit_person_qual->
      person_list[num].person_id)
     IF (pos=0)
      person_cnt = (person_cnt+ 1), stat = alterlist(audit_person_qual->person_list,person_cnt),
      audit_person_qual->person_list[person_cnt].person_id = person_id
     ENDIF
     pos = 0, lastpos = 1
    ELSE
     person_id = cep.person_id, person_cnt = (person_cnt+ 1), stat = alterlist(audit_person_qual->
      person_list,person_cnt),
     audit_person_qual->person_list[person_cnt].person_id = person_id
    ENDIF
   ENDIF
   reply->event_prsnl_list[cnt].ce_event_prsnl_id = cep.ce_event_prsnl_id, reply->event_prsnl_list[
   cnt].event_prsnl_id = cep.event_prsnl_id, reply->event_prsnl_list[cnt].person_id = cep.person_id,
   reply->event_prsnl_list[cnt].event_id = cep.event_id, reply->event_prsnl_list[cnt].
   valid_from_dt_tm = cep.valid_from_dt_tm, reply->event_prsnl_list[cnt].valid_from_dt_tm_ind =
   valid_from_dt_tm_ind,
   reply->event_prsnl_list[cnt].valid_until_dt_tm = cep.valid_until_dt_tm, reply->event_prsnl_list[
   cnt].valid_until_dt_tm_ind = valid_until_dt_tm_ind, reply->event_prsnl_list[cnt].action_type_cd =
   cep.action_type_cd,
   reply->event_prsnl_list[cnt].request_dt_tm = cep.request_dt_tm, reply->event_prsnl_list[cnt].
   request_dt_tm_ind = request_dt_tm_ind, reply->event_prsnl_list[cnt].request_prsnl_id = cep
   .request_prsnl_id,
   reply->event_prsnl_list[cnt].request_prsnl_ft = cep.request_prsnl_ft, reply->event_prsnl_list[cnt]
   .request_comment = cep.request_comment, reply->event_prsnl_list[cnt].action_dt_tm = cep
   .action_dt_tm,
   reply->event_prsnl_list[cnt].action_dt_tm_ind = action_dt_tm_ind, reply->event_prsnl_list[cnt].
   action_prsnl_id = cep.action_prsnl_id, reply->event_prsnl_list[cnt].action_prsnl_ft = cep
   .action_prsnl_ft,
   reply->event_prsnl_list[cnt].proxy_prsnl_id = cep.proxy_prsnl_id, reply->event_prsnl_list[cnt].
   proxy_prsnl_ft = cep.proxy_prsnl_ft, reply->event_prsnl_list[cnt].action_status_cd = cep
   .action_status_cd,
   reply->event_prsnl_list[cnt].action_comment = cep.action_comment, reply->event_prsnl_list[cnt].
   change_since_action_flag = cep.change_since_action_flag, reply->event_prsnl_list[cnt].
   change_since_action_flag_ind = change_since_action_flag_ind,
   reply->event_prsnl_list[cnt].updt_dt_tm = cep.updt_dt_tm, reply->event_prsnl_list[cnt].
   updt_dt_tm_ind = updt_dt_tm_ind, reply->event_prsnl_list[cnt].updt_id = cep.updt_id,
   reply->event_prsnl_list[cnt].updt_task = cep.updt_task, reply->event_prsnl_list[cnt].updt_task_ind
    = updt_task_ind, reply->event_prsnl_list[cnt].updt_cnt = cep.updt_cnt,
   reply->event_prsnl_list[cnt].updt_cnt_ind = updt_cnt_ind, reply->event_prsnl_list[cnt].
   updt_applctx = cep.updt_applctx, reply->event_prsnl_list[cnt].updt_applctx_ind = updt_applctx_ind,
   reply->event_prsnl_list[cnt].long_text_id = cep.long_text_id, reply->event_prsnl_list[cnt].
   linked_event_id = cep.linked_event_id, reply->event_prsnl_list[cnt].request_tz = cep.request_tz,
   reply->event_prsnl_list[cnt].action_tz = cep.action_tz, reply->event_prsnl_list[cnt].
   system_comment = cep.system_comment, reply->event_prsnl_list[cnt].digital_signature_ident = cep
   .digital_signature_ident,
   reply->event_prsnl_list[cnt].action_prsnl_group_id = cep.action_prsnl_group_id, reply->
   event_prsnl_list[cnt].request_prsnl_group_id = cep.request_prsnl_group_id
  WITH memsort, nocounter
 ;end select
 SET stat = alterlist(reply->event_prsnl_list,cnt)
 SET stat = alterlist(longtxtidlist->from_ep_rec,cnt2)
 SET ntotal2 = cnt2
 IF (ntotal2 < 1)
  GO TO skip_long_text
 ENDIF
 SET pos = 0
 SET lastpos = 1
 SET ntotal = (ceil((cnvtreal(ntotal2)/ list_nsize)) * list_nsize)
 SET stat = alterlist(longtxtidlist->from_ep_rec,ntotal)
 FOR (j = (ntotal2+ 1) TO ntotal)
   SET longtxtidlist->from_ep_rec[j].long_text_id = longtxtidlist->from_ep_rec[ntotal2].long_text_id
 ENDFOR
 SELECT INTO "nl:"
  lt.long_text
  FROM (dummyt d2  WITH seq = value((1+ ((ntotal - 1)/ list_nsize)))),
   long_text lt
  PLAN (d2
   WHERE initarray(text_nstart,evaluate(d2.seq,1,1,(text_nstart+ list_nsize))))
   JOIN (lt
   WHERE expand(text_ndx,text_nstart,(text_nstart+ (list_nsize - 1)),lt.long_text_id,longtxtidlist->
    from_ep_rec[text_ndx].long_text_id))
  DETAIL
   pos = locateval(num,lastpos,cnt,lt.long_text_id,reply->event_prsnl_list[num].long_text_id)
   WHILE (pos)
     reply->event_prsnl_list[pos].long_text = lt.long_text, lastpos = (pos+ 1)
     IF (pos <= cnt)
      pos = locateval(num,lastpos,cnt,lt.long_text_id,reply->event_prsnl_list[num].long_text_id)
     ELSE
      pos = 0
     ENDIF
   ENDWHILE
   lastpos = 1
  WITH nocounter
 ;end select
#skip_long_text
 SET audit_size = size(audit_person_qual->person_list,5)
 IF (audit_size=1)
  EXECUTE cclaudit 0, "Access Person", "Results",
  "Person", "Patient", "Patient Number",
  "Access/Use", audit_person_qual->person_list[1].person_id, " "
 ELSE
  FOR (auditcnt = 1 TO audit_size)
   IF (auditcnt=1)
    SET auditmode = 1
   ELSEIF (auditcnt < audit_size)
    SET auditmode = 2
   ELSEIF (auditcnt=audit_size)
    SET auditmode = 3
   ENDIF
   EXECUTE cclaudit auditmode, "Access Person", "Results",
   "Person", "Patient", "Patient Number",
   "Access/Use", audit_person_qual->person_list[auditcnt].person_id, " "
  ENDFOR
 ENDIF
 CALL checkerrors("CE_RETRIEVE_ACTION_COMMENT query")
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
