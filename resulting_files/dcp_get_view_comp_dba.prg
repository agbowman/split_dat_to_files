CREATE PROGRAM dcp_get_view_comp:dba
 RECORD reply(
   1 view_comp_cnt = i4
   1 application_number = i4
   1 position_cd = f8
   1 prsnl_id = f8
   1 view_name = c12
   1 view_seq = i4
   1 view_comp[*]
     2 view_comp_prefs_id = f8
     2 application_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 view_name = c12
     2 view_seq = i4
     2 comp_name = c12
     2 comp_seq = i4
     2 updt_cnt = i4
     2 nv_cnt = i4
     2 nv[*]
       3 name_value_prefs_id = f8
       3 pvc_name = c32
       3 pvc_value = vc
       3 sequence = i2
       3 merge_id = f8
       3 merge_name = vc
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET reply->view_comp_cnt = 0
 SET nvi = 0
 SET reply->application_number = request->application_number
 SET reply->position_cd = request->position_cd
 SET reply->prsnl_id = request->prsnl_id
 SET reply->view_name = request->view_name
 SET reply->view_seq = request->view_seq
 SELECT INTO "nl:"
  vcp.view_comp_prefs_id, nv.seq
  FROM view_comp_prefs vcp,
   (dummyt d1  WITH seq = 1),
   name_value_prefs nv
  PLAN (vcp
   WHERE (vcp.application_number=request->application_number)
    AND (vcp.prsnl_id=request->prsnl_id)
    AND vcp.prsnl_id > 0
    AND (vcp.view_name=request->view_name)
    AND (vcp.view_seq=request->view_seq)
    AND vcp.active_ind=1)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (nv
   WHERE nv.parent_entity_name="VIEW_COMP_PREFS"
    AND nv.parent_entity_id=vcp.view_comp_prefs_id
    AND nv.active_ind=1)
  HEAD REPORT
   count1 = 0
  HEAD vcp.view_comp_prefs_id
   count1 = (count1+ 1)
   IF (count1 > size(reply->view_comp,5))
    stat = alterlist(reply->view_comp,(count1+ 10))
   ENDIF
   reply->view_comp[count1].view_comp_prefs_id = vcp.view_comp_prefs_id, reply->application_number =
   vcp.application_number, reply->position_cd = vcp.position_cd,
   reply->prsnl_id = vcp.prsnl_id, reply->view_comp[count1].application_number = vcp
   .application_number, reply->view_comp[count1].position_cd = vcp.position_cd,
   reply->view_comp[count1].prsnl_id = vcp.prsnl_id, reply->view_comp[count1].view_name = vcp
   .view_name, reply->view_comp[count1].view_seq = vcp.view_seq,
   reply->view_comp[count1].comp_name = vcp.comp_name, reply->view_comp[count1].comp_seq = vcp
   .comp_seq, reply->view_comp[count1].updt_cnt = vcp.updt_cnt,
   nvi = 0
  DETAIL
   nvi = (nvi+ 1)
   IF (nvi > size(reply->view_comp[count1].nv,5))
    stat = alterlist(reply->view_comp[count1].nv,(nvi+ 10))
   ENDIF
   reply->view_comp[count1].nv[nvi].name_value_prefs_id = nv.name_value_prefs_id, reply->view_comp[
   count1].nv[nvi].pvc_name = nv.pvc_name, reply->view_comp[count1].nv[nvi].pvc_value = nv.pvc_value,
   reply->view_comp[count1].nv[nvi].sequence = nv.sequence, reply->view_comp[count1].nv[nvi].merge_id
    = nv.merge_id, reply->view_comp[count1].nv[nvi].merge_name = nv.merge_name,
   reply->view_comp[count1].nv[nvi].updt_cnt = nv.updt_cnt
  FOOT  vcp.view_comp_prefs_id
   IF (nvi > 0)
    stat = alterlist(reply->view_comp[count1].nv,nvi)
   ENDIF
   reply->view_comp[count1].nv_cnt = nvi
  FOOT REPORT
   reply->view_comp_cnt = count1
  WITH outerjoin = d1, nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   vcp.view_comp_prefs_id, nv.seq
   FROM view_comp_prefs vcp,
    (dummyt d1  WITH seq = 1),
    name_value_prefs nv
   PLAN (vcp
    WHERE (vcp.application_number=request->application_number)
     AND (vcp.position_cd=request->position_cd)
     AND vcp.position_cd > 0
     AND (vcp.view_name=request->view_name)
     AND (vcp.view_seq=request->view_seq)
     AND vcp.active_ind=1)
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (nv
    WHERE nv.parent_entity_name="VIEW_COMP_PREFS"
     AND nv.parent_entity_id=vcp.view_comp_prefs_id
     AND nv.active_ind=1)
   HEAD REPORT
    count1 = 0
   HEAD vcp.view_comp_prefs_id
    count1 = (count1+ 1)
    IF (count1 > size(reply->view_comp,5))
     stat = alterlist(reply->view_comp,(count1+ 10))
    ENDIF
    reply->view_comp[count1].view_comp_prefs_id = vcp.view_comp_prefs_id, reply->application_number
     = vcp.application_number, reply->position_cd = vcp.position_cd,
    reply->prsnl_id = vcp.prsnl_id, reply->view_comp[count1].application_number = vcp
    .application_number, reply->view_comp[count1].position_cd = vcp.position_cd,
    reply->view_comp[count1].prsnl_id = vcp.prsnl_id, reply->view_comp[count1].view_name = vcp
    .view_name, reply->view_comp[count1].view_seq = vcp.view_seq,
    reply->view_comp[count1].comp_name = vcp.comp_name, reply->view_comp[count1].comp_seq = vcp
    .comp_seq, reply->view_comp[count1].updt_cnt = vcp.updt_cnt,
    nvi = 0
   DETAIL
    nvi = (nvi+ 1)
    IF (nvi > size(reply->view_comp[count1].nv,5))
     stat = alterlist(reply->view_comp[count1].nv,(nvi+ 10))
    ENDIF
    reply->view_comp[count1].nv[nvi].name_value_prefs_id = nv.name_value_prefs_id, reply->view_comp[
    count1].nv[nvi].pvc_name = nv.pvc_name, reply->view_comp[count1].nv[nvi].pvc_value = nv.pvc_value,
    reply->view_comp[count1].nv[nvi].sequence = nv.sequence, reply->view_comp[count1].nv[nvi].
    merge_id = nv.merge_id, reply->view_comp[count1].nv[nvi].merge_name = nv.merge_name,
    reply->view_comp[count1].nv[nvi].updt_cnt = nv.updt_cnt
   FOOT  vcp.view_comp_prefs_id
    IF (nvi > 0)
     stat = alterlist(reply->view_comp[count1].nv,nvi)
    ENDIF
    reply->view_comp[count1].nv_cnt = nvi
   FOOT REPORT
    reply->view_comp_cnt = count1
   WITH outerjoin = d1, nocounter
  ;end select
  IF (curqual=0)
   SELECT INTO "nl:"
    vcp.view_comp_prefs_id, nv.seq
    FROM view_comp_prefs vcp,
     (dummyt d1  WITH seq = 1),
     name_value_prefs nv
    PLAN (vcp
     WHERE (vcp.application_number=request->application_number)
      AND vcp.position_cd=0
      AND vcp.prsnl_id=0
      AND (vcp.view_name=request->view_name)
      AND (vcp.view_seq=request->view_seq)
      AND vcp.active_ind=1)
     JOIN (d1
     WHERE d1.seq=1)
     JOIN (nv
     WHERE nv.parent_entity_name="VIEW_COMP_PREFS"
      AND nv.parent_entity_id=vcp.view_comp_prefs_id
      AND nv.active_ind=1)
    HEAD REPORT
     count1 = 0
    HEAD vcp.view_comp_prefs_id
     count1 = (count1+ 1)
     IF (count1 > size(reply->view_comp,5))
      stat = alterlist(reply->view_comp,(count1+ 10))
     ENDIF
     reply->view_comp[count1].view_comp_prefs_id = vcp.view_comp_prefs_id, reply->application_number
      = vcp.application_number, reply->position_cd = vcp.position_cd,
     reply->prsnl_id = vcp.prsnl_id, reply->view_comp[count1].application_number = vcp
     .application_number, reply->view_comp[count1].position_cd = vcp.position_cd,
     reply->view_comp[count1].prsnl_id = vcp.prsnl_id, reply->view_comp[count1].view_name = vcp
     .view_name, reply->view_comp[count1].view_seq = vcp.view_seq,
     reply->view_comp[count1].comp_name = vcp.comp_name, reply->view_comp[count1].comp_seq = vcp
     .comp_seq, reply->view_comp[count1].updt_cnt = vcp.updt_cnt,
     nvi = 0
    DETAIL
     nvi = (nvi+ 1)
     IF (nvi > size(reply->view_comp[count1].nv,5))
      stat = alterlist(reply->view_comp[count1].nv,(nvi+ 10))
     ENDIF
     reply->view_comp[count1].nv[nvi].name_value_prefs_id = nv.name_value_prefs_id, reply->view_comp[
     count1].nv[nvi].pvc_name = nv.pvc_name, reply->view_comp[count1].nv[nvi].pvc_value = nv
     .pvc_value,
     reply->view_comp[count1].nv[nvi].sequence = nv.sequence, reply->view_comp[count1].nv[nvi].
     merge_id = nv.merge_id, reply->view_comp[count1].nv[nvi].merge_name = nv.merge_name,
     reply->view_comp[count1].nv[nvi].updt_cnt = nv.updt_cnt
    FOOT  vcp.view_comp_prefs_id
     IF (nvi > 0)
      stat = alterlist(reply->view_comp[count1].nv,nvi)
     ENDIF
     reply->view_comp[count1].nv_cnt = nvi
    FOOT REPORT
     reply->view_comp_cnt = count1
    WITH outerjoin = d1, nocounter
   ;end select
  ENDIF
 ENDIF
#exit_program
 IF (curqual != 0)
  SET reply->status_data.status = "S"
  SET stat = alterlist(reply->view_comp,reply->view_comp_cnt)
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echo(build("view name =",reply->view_name))
 CALL echo(build("view seq =",reply->view_seq))
 CALL echo(build("view comp cnt =",reply->view_comp_cnt))
 FOR (nvi = 1 TO reply->view_comp_cnt)
  CALL echo(build("view comp nv cnt =",reply->view_comp[nvi].nv_cnt))
  FOR (w = 1 TO reply->view_comp[nvi].nv_cnt)
    CALL echo(build("name",reply->view_comp[nvi].nv[w].pvc_name))
    CALL echo(build("value",reply->view_comp[nvi].nv[w].pvc_value))
    CALL echo(build("value",reply->view_comp[nvi].nv[w].sequence))
    CALL echo(build("value",reply->view_comp[nvi].nv[w].merge_id))
    CALL echo(build("value",reply->view_comp[nvi].nv[w].merge_name))
  ENDFOR
 ENDFOR
END GO
