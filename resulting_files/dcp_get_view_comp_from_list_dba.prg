CREATE PROGRAM dcp_get_view_comp_from_list:dba
 RECORD reply(
   1 view_list_cnt = i4
   1 view_list[*]
     2 view_comp_cnt = i4
     2 application_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 view_name = c12
     2 view_seq = i4
     2 view_comp[*]
       3 view_comp_prefs_id = f8
       3 application_number = i4
       3 position_cd = f8
       3 prsnl_id = f8
       3 view_name = c12
       3 view_seq = i4
       3 comp_name = c12
       3 comp_seq = i4
       3 updt_cnt = i4
       3 nv_cnt = i4
       3 nv[*]
         4 name_value_prefs_id = f8
         4 pvc_name = c32
         4 pvc_value = vc
         4 sequence = i2
         4 merge_id = f8
         4 merge_name = vc
         4 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD reqtemp(
   1 view_list[*]
     2 view_name = c12
     2 view_seq = i4
 )
 SET reply->status_data.status = "F"
 DECLARE nvi = i4 WITH noconstant(0)
 DECLARE pos = i4 WITH noconstant(0)
 DECLARE batch_size = i4 WITH constant(40)
 DECLARE replysize = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE loop_cnt = i4
 SET loop_cnt = ceil((cnvtreal(size(request->view_list,5))/ batch_size))
 DECLARE num = i4 WITH noconstant(0)
 DECLARE start = i4 WITH noconstant(1)
 SET stat = alterlist(reqtemp->view_list,(loop_cnt * batch_size))
 FOR (i = 1 TO size(request->view_list,5))
  SET reqtemp->view_list[i].view_name = request->view_list[i].view_name
  SET reqtemp->view_list[i].view_seq = request->view_list[i].view_seq
 ENDFOR
 FOR (i = (size(request->view_list,5)+ 1) TO (batch_size * loop_cnt))
   SET reqtemp->view_list[i].view_seq = - (1)
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   dummyt d2,
   view_comp_prefs vcp,
   name_value_prefs nv
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (vcp
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),vcp.view_name,reqtemp->view_list[idx].view_name,
    vcp.view_seq,reqtemp->view_list[idx].view_seq)
    AND (vcp.view_seq > - (1))
    AND (vcp.prsnl_id=request->prsnl_id)
    AND vcp.prsnl_id > 0
    AND (vcp.application_number=request->application_number)
    AND vcp.active_ind=1)
   JOIN (d2)
   JOIN (nv
   WHERE nv.parent_entity_id=vcp.view_comp_prefs_id
    AND nv.parent_entity_name="VIEW_COMP_PREFS"
    AND nv.active_ind=1)
  HEAD vcp.view_comp_prefs_id
   pos = locateval(num,start,size(reply->view_list,5),vcp.view_name,reply->view_list[num].view_name,
    vcp.view_seq,reply->view_list[num].view_seq)
   IF (pos <= 0)
    replysize = (replysize+ 1)
    IF (replysize > size(reply->view_list,5))
     stat = alterlist(reply->view_list,(replysize+ 10))
    ENDIF
    pos = replysize
   ENDIF
   reply->view_list[pos].view_comp_cnt = (reply->view_list[pos].view_comp_cnt+ 1), view_comp_cnt =
   reply->view_list[pos].view_comp_cnt
   IF (view_comp_cnt > size(reply->view_list[pos].view_comp,5))
    stat = alterlist(reply->view_list[pos].view_comp,(view_comp_cnt+ 10))
   ENDIF
   reply->view_list[pos].view_comp[view_comp_cnt].view_comp_prefs_id = vcp.view_comp_prefs_id, reply
   ->view_list[pos].application_number = vcp.application_number, reply->view_list[pos].position_cd =
   vcp.position_cd,
   reply->view_list[pos].prsnl_id = vcp.prsnl_id, reply->view_list[pos].view_name = vcp.view_name,
   reply->view_list[pos].view_seq = vcp.view_seq,
   reply->view_list[pos].view_comp[view_comp_cnt].application_number = vcp.application_number, reply
   ->view_list[pos].view_comp[view_comp_cnt].position_cd = vcp.position_cd, reply->view_list[pos].
   view_comp[view_comp_cnt].prsnl_id = vcp.prsnl_id,
   reply->view_list[pos].view_comp[view_comp_cnt].view_name = vcp.view_name, reply->view_list[pos].
   view_comp[view_comp_cnt].view_seq = vcp.view_seq, reply->view_list[pos].view_comp[view_comp_cnt].
   comp_name = vcp.comp_name,
   reply->view_list[pos].view_comp[view_comp_cnt].comp_seq = vcp.comp_seq, reply->view_list[pos].
   view_comp[view_comp_cnt].updt_cnt = vcp.updt_cnt, nvi = 0
  DETAIL
   IF (nv.name_value_prefs_id > 0)
    reply->view_list[pos].view_comp[view_comp_cnt].nv_cnt = (reply->view_list[pos].view_comp[
    view_comp_cnt].nv_cnt+ 1), nvi = reply->view_list[pos].view_comp[view_comp_cnt].nv_cnt
    IF (nvi > size(reply->view_list[pos].view_comp[view_comp_cnt].nv,5))
     stat = alterlist(reply->view_list[pos].view_comp[view_comp_cnt].nv,(nvi+ 10))
    ENDIF
    reply->view_list[pos].view_comp[view_comp_cnt].nv[nvi].name_value_prefs_id = nv
    .name_value_prefs_id, reply->view_list[pos].view_comp[view_comp_cnt].nv[nvi].pvc_name = nv
    .pvc_name, reply->view_list[pos].view_comp[view_comp_cnt].nv[nvi].pvc_value = nv.pvc_value,
    reply->view_list[pos].view_comp[view_comp_cnt].nv[nvi].sequence = nv.sequence, reply->view_list[
    pos].view_comp[view_comp_cnt].nv[nvi].merge_id = nv.merge_id, reply->view_list[pos].view_comp[
    view_comp_cnt].nv[nvi].merge_name = nv.merge_name,
    reply->view_list[pos].view_comp[view_comp_cnt].nv[nvi].updt_cnt = nv.updt_cnt
   ENDIF
  FOOT  vcp.view_comp_prefs_id
   stat = alterlist(reply->view_list[pos].view_comp[view_comp_cnt].nv,nvi), stat = alterlist(reply->
    view_list[pos].view_comp,view_comp_cnt)
  FOOT REPORT
   stat = alterlist(reply->view_list,replysize), reply->view_list_cnt = replysize
  WITH nocounter, outerjoin = d2
 ;end select
 DECLARE reqcnt = i4 WITH noconstant(0)
 FOR (i = 1 TO size(request->view_list,5))
  SET pos = locateval(num,start,size(reply->view_list,5),request->view_list[i].view_name,reply->
   view_list[num].view_name,
   request->view_list[i].view_seq,reply->view_list[num].view_seq)
  IF (pos <= 0)
   SET reqcnt = (reqcnt+ 1)
   SET reqtemp->view_list[reqcnt].view_name = request->view_list[i].view_name
   SET reqtemp->view_list[reqcnt].view_seq = request->view_list[i].view_seq
  ENDIF
 ENDFOR
 IF (reqcnt=0)
  GO TO endscript
 ENDIF
 SET loop_cnt = ceil((cnvtreal(reqcnt)/ batch_size))
 SET stat = alterlist(reqtemp->view_list,(loop_cnt * batch_size))
 FOR (i = (reqcnt+ 1) TO (batch_size * loop_cnt))
  SET reqtemp->view_list[i].view_name = ""
  SET reqtemp->view_list[i].view_seq = - (1)
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   dummyt d2,
   view_comp_prefs vcp,
   name_value_prefs nv
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (vcp
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),vcp.view_name,reqtemp->view_list[idx].view_name,
    vcp.view_seq,reqtemp->view_list[idx].view_seq)
    AND (vcp.view_seq > - (1))
    AND (vcp.position_cd=request->position_cd)
    AND vcp.position_cd > 0
    AND (vcp.application_number=request->application_number)
    AND vcp.active_ind=1)
   JOIN (d2)
   JOIN (nv
   WHERE nv.parent_entity_id=vcp.view_comp_prefs_id
    AND nv.parent_entity_name="VIEW_COMP_PREFS"
    AND nv.active_ind=1)
  HEAD vcp.view_comp_prefs_id
   pos = locateval(num,start,size(reply->view_list,5),vcp.view_name,reply->view_list[num].view_name,
    vcp.view_seq,reply->view_list[num].view_seq)
   IF (pos <= 0)
    replysize = (replysize+ 1)
    IF (replysize > size(reply->view_list,5))
     stat = alterlist(reply->view_list,(replysize+ 10))
    ENDIF
    pos = replysize
   ENDIF
   reply->view_list[pos].view_comp_cnt = (reply->view_list[pos].view_comp_cnt+ 1), view_comp_cnt =
   reply->view_list[pos].view_comp_cnt
   IF (view_comp_cnt > size(reply->view_list[pos].view_comp,5))
    stat = alterlist(reply->view_list[pos].view_comp,(view_comp_cnt+ 10))
   ENDIF
   reply->view_list[pos].view_comp[view_comp_cnt].view_comp_prefs_id = vcp.view_comp_prefs_id, reply
   ->view_list[pos].application_number = vcp.application_number, reply->view_list[pos].position_cd =
   vcp.position_cd,
   reply->view_list[pos].prsnl_id = vcp.prsnl_id, reply->view_list[pos].view_name = vcp.view_name,
   reply->view_list[pos].view_seq = vcp.view_seq,
   reply->view_list[pos].view_comp[view_comp_cnt].application_number = vcp.application_number, reply
   ->view_list[pos].view_comp[view_comp_cnt].position_cd = vcp.position_cd, reply->view_list[pos].
   view_comp[view_comp_cnt].prsnl_id = vcp.prsnl_id,
   reply->view_list[pos].view_comp[view_comp_cnt].view_name = vcp.view_name, reply->view_list[pos].
   view_comp[view_comp_cnt].view_seq = vcp.view_seq, reply->view_list[pos].view_comp[view_comp_cnt].
   comp_name = vcp.comp_name,
   reply->view_list[pos].view_comp[view_comp_cnt].comp_seq = vcp.comp_seq, reply->view_list[pos].
   view_comp[view_comp_cnt].updt_cnt = vcp.updt_cnt, nvi = 0
  DETAIL
   IF (nv.name_value_prefs_id > 0)
    reply->view_list[pos].view_comp[view_comp_cnt].nv_cnt = (reply->view_list[pos].view_comp[
    view_comp_cnt].nv_cnt+ 1), nvi = reply->view_list[pos].view_comp[view_comp_cnt].nv_cnt
    IF (nvi > size(reply->view_list[pos].view_comp[view_comp_cnt].nv,5))
     stat = alterlist(reply->view_list[pos].view_comp[view_comp_cnt].nv,(nvi+ 10))
    ENDIF
    reply->view_list[pos].view_comp[view_comp_cnt].nv[nvi].name_value_prefs_id = nv
    .name_value_prefs_id, reply->view_list[pos].view_comp[view_comp_cnt].nv[nvi].pvc_name = nv
    .pvc_name, reply->view_list[pos].view_comp[view_comp_cnt].nv[nvi].pvc_value = nv.pvc_value,
    reply->view_list[pos].view_comp[view_comp_cnt].nv[nvi].sequence = nv.sequence, reply->view_list[
    pos].view_comp[view_comp_cnt].nv[nvi].merge_id = nv.merge_id, reply->view_list[pos].view_comp[
    view_comp_cnt].nv[nvi].merge_name = nv.merge_name,
    reply->view_list[pos].view_comp[view_comp_cnt].nv[nvi].updt_cnt = nv.updt_cnt
   ENDIF
  FOOT  vcp.view_comp_prefs_id
   stat = alterlist(reply->view_list[pos].view_comp[view_comp_cnt].nv,nvi), stat = alterlist(reply->
    view_list[pos].view_comp,view_comp_cnt)
  FOOT REPORT
   stat = alterlist(reply->view_list,replysize), reply->view_list_cnt = replysize
  WITH nocounter, outerjoin = d2
 ;end select
 SET reqcnt = 0
 FOR (i = 1 TO size(request->view_list,5))
  SET pos = locateval(num,start,size(reply->view_list,5),request->view_list[i].view_name,reply->
   view_list[num].view_name,
   request->view_list[i].view_seq,reply->view_list[num].view_seq)
  IF (pos <= 0)
   SET reqcnt = (reqcnt+ 1)
   SET reqtemp->view_list[reqcnt].view_name = request->view_list[i].view_name
   SET reqtemp->view_list[reqcnt].view_seq = request->view_list[i].view_seq
  ENDIF
 ENDFOR
 IF (reqcnt=0)
  GO TO endscript
 ENDIF
 SET loop_cnt = ceil((cnvtreal(reqcnt)/ batch_size))
 SET stat = alterlist(reqtemp->view_list,(loop_cnt * batch_size))
 FOR (i = (reqcnt+ 1) TO (batch_size * loop_cnt))
  SET reqtemp->view_list[i].view_name = ""
  SET reqtemp->view_list[i].view_seq = - (1)
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   dummyt d2,
   view_comp_prefs vcp,
   name_value_prefs nv
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (vcp
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),vcp.view_name,reqtemp->view_list[idx].view_name,
    vcp.view_seq,reqtemp->view_list[idx].view_seq)
    AND (vcp.view_seq > - (1))
    AND vcp.position_cd=0
    AND vcp.prsnl_id=0
    AND (vcp.application_number=request->application_number)
    AND vcp.active_ind=1)
   JOIN (d2)
   JOIN (nv
   WHERE nv.parent_entity_id=vcp.view_comp_prefs_id
    AND nv.parent_entity_name="VIEW_COMP_PREFS"
    AND nv.active_ind=1)
  HEAD vcp.view_comp_prefs_id
   pos = locateval(num,start,size(reply->view_list,5),vcp.view_name,reply->view_list[num].view_name,
    vcp.view_seq,reply->view_list[num].view_seq)
   IF (pos <= 0)
    replysize = (replysize+ 1)
    IF (replysize > size(reply->view_list,5))
     stat = alterlist(reply->view_list,(replysize+ 10))
    ENDIF
    pos = replysize
   ENDIF
   reply->view_list[pos].view_comp_cnt = (reply->view_list[pos].view_comp_cnt+ 1), view_comp_cnt =
   reply->view_list[pos].view_comp_cnt
   IF (view_comp_cnt > size(reply->view_list[pos].view_comp,5))
    stat = alterlist(reply->view_list[pos].view_comp,(view_comp_cnt+ 10))
   ENDIF
   reply->view_list[pos].view_comp[view_comp_cnt].view_comp_prefs_id = vcp.view_comp_prefs_id, reply
   ->view_list[pos].application_number = vcp.application_number, reply->view_list[pos].position_cd =
   vcp.position_cd,
   reply->view_list[pos].prsnl_id = vcp.prsnl_id, reply->view_list[pos].view_name = vcp.view_name,
   reply->view_list[pos].view_seq = vcp.view_seq,
   reply->view_list[pos].view_comp[view_comp_cnt].application_number = vcp.application_number, reply
   ->view_list[pos].view_comp[view_comp_cnt].position_cd = vcp.position_cd, reply->view_list[pos].
   view_comp[view_comp_cnt].prsnl_id = vcp.prsnl_id,
   reply->view_list[pos].view_comp[view_comp_cnt].view_name = vcp.view_name, reply->view_list[pos].
   view_comp[view_comp_cnt].view_seq = vcp.view_seq, reply->view_list[pos].view_comp[view_comp_cnt].
   comp_name = vcp.comp_name,
   reply->view_list[pos].view_comp[view_comp_cnt].comp_seq = vcp.comp_seq, reply->view_list[pos].
   view_comp[view_comp_cnt].updt_cnt = vcp.updt_cnt, nvi = 0
  DETAIL
   IF (nv.name_value_prefs_id > 0)
    reply->view_list[pos].view_comp[view_comp_cnt].nv_cnt = (reply->view_list[pos].view_comp[
    view_comp_cnt].nv_cnt+ 1), nvi = reply->view_list[pos].view_comp[view_comp_cnt].nv_cnt
    IF (nvi > size(reply->view_list[pos].view_comp[view_comp_cnt].nv,5))
     stat = alterlist(reply->view_list[pos].view_comp[view_comp_cnt].nv,(nvi+ 10))
    ENDIF
    reply->view_list[pos].view_comp[view_comp_cnt].nv[nvi].name_value_prefs_id = nv
    .name_value_prefs_id, reply->view_list[pos].view_comp[view_comp_cnt].nv[nvi].pvc_name = nv
    .pvc_name, reply->view_list[pos].view_comp[view_comp_cnt].nv[nvi].pvc_value = nv.pvc_value,
    reply->view_list[pos].view_comp[view_comp_cnt].nv[nvi].sequence = nv.sequence, reply->view_list[
    pos].view_comp[view_comp_cnt].nv[nvi].merge_id = nv.merge_id, reply->view_list[pos].view_comp[
    view_comp_cnt].nv[nvi].merge_name = nv.merge_name,
    reply->view_list[pos].view_comp[view_comp_cnt].nv[nvi].updt_cnt = nv.updt_cnt
   ENDIF
  FOOT  vcp.view_comp_prefs_id
   stat = alterlist(reply->view_list[pos].view_comp[view_comp_cnt].nv,nvi), stat = alterlist(reply->
    view_list[pos].view_comp,view_comp_cnt)
  FOOT REPORT
   stat = alterlist(reply->view_list,replysize), reply->view_list_cnt = replysize
  WITH nocounter, outerjoin = d2
 ;end select
 SET reqcnt = 0
 FOR (i = 1 TO size(request->view_list,5))
  SET pos = locateval(num,start,size(reply->view_list,5),request->view_list[i].view_name,reply->
   view_list[num].view_name,
   request->view_list[i].view_seq,reply->view_list[num].view_seq)
  IF (pos <= 0)
   SET reqcnt = (reqcnt+ 1)
   SET reqtemp->view_list[reqcnt].view_name = request->view_list[i].view_name
   SET reqtemp->view_list[reqcnt].view_seq = request->view_list[i].view_seq
  ENDIF
 ENDFOR
 IF (reqcnt=0)
  GO TO endscript
 ENDIF
 SET stat = alterlist(reqtemp->view_list,reqcnt)
 FOR (i = 1 TO size(reqtemp->view_list,5))
   SET replysize = (replysize+ 1)
   SET stat = alterlist(reply->view_list,replysize)
   SET reply->view_list_cnt = replysize
   SET reply->view_list[replysize].application_number = request->application_number
   SET reply->view_list[replysize].position_cd = request->position_cd
   SET reply->view_list[replysize].prsnl_id = request->prsnl_id
   SET reply->view_list[replysize].view_name = reqtemp->view_list[i].view_name
   SET reply->view_list[replysize].view_seq = reqtemp->view_list[i].view_seq
 ENDFOR
#endscript
 IF (replysize=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE RECORD reqtemp
 SET dcp_script_version = "001 04/17/09 NC014668"
END GO
