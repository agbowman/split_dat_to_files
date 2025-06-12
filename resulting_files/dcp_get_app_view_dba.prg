CREATE PROGRAM dcp_get_app_view:dba
 RECORD reply(
   1 app
     2 application_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 nv_cnt = i4
     2 nv[*]
       3 name_value_prefs_id = f8
       3 nv_type_flag = i2
       3 pvc_name = c32
       3 pvc_value = vc
       3 merge_id = f8
       3 merge_name = vc
       3 sequence = i4
       3 updt_cnt = i4
   1 view_level_flag = i2
   1 view_cnt = i4
   1 pview[*]
     2 view_prefs_id = f8
     2 application_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 frame_type = c12
     2 view_name = c12
     2 view_seq = i4
     2 updt_cnt = i4
     2 nv_cnt = i4
     2 nv[*]
       3 name_value_prefs_id = f8
       3 nv_type_flag = i2
       3 pvc_name = c32
       3 pvc_value = vc
       3 merge_id = f8
       3 merge_name = vc
       3 sequence = i4
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nvi = i4 WITH noconstant(0)
 DECLARE x = i4 WITH noconstant(0)
 DECLARE count1 = i4 WITH noconstant(0)
 DECLARE system = i4 WITH noconstant(0)
 DECLARE position = i4 WITH noconstant(0)
 DECLARE prsnl = i4 WITH noconstant(0)
 DECLARE old_preftool_ind = i4 WITH noconstant(0)
 DECLARE expand_num = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET reply->view_cnt = 0
 SET reply->app.application_number = request->application_number
 SET reply->app.position_cd = request->position_cd
 SET reply->app.prsnl_id = request->prsnl_id
 SET reply->view_level_flag = - (1)
 IF ((request->position_cd > 0)
  AND (request->prsnl_id=0)
  AND (request->preftool_ind=0))
  SET old_preftool_ind = 1
 ENDIF
 IF (old_preftool_ind=1)
  SELECT INTO "nl:"
   ap.app_prefs_id, ap.prsnl_id, ap.position_cd,
   nv.pvc_name, nv.seq, ap.seq
   FROM app_prefs ap,
    name_value_prefs nv
   PLAN (ap
    WHERE (ap.application_number=request->application_number)
     AND ap.active_ind=1
     AND (ap.prsnl_id=request->prsnl_id)
     AND (ap.position_cd=request->position_cd))
    JOIN (nv
    WHERE nv.parent_entity_name="APP_PREFS"
     AND nv.parent_entity_id=ap.app_prefs_id
     AND nv.active_ind=1)
   ORDER BY nv.pvc_name, ap.prsnl_id DESC, ap.position_cd DESC
   HEAD REPORT
    nvi = 0
   HEAD nv.pvc_name
    nvi += 1
    IF (nvi > size(reply->app.nv,5))
     stat = alterlist(reply->app.nv,(nvi+ 10))
    ENDIF
    reply->app.nv[nvi].name_value_prefs_id = nv.name_value_prefs_id, reply->app.nv[nvi].pvc_name = nv
    .pvc_name, reply->app.nv[nvi].pvc_value = nv.pvc_value,
    reply->app.nv[nvi].merge_id = nv.merge_id, reply->app.nv[nvi].merge_name = nv.merge_name, reply->
    app.nv[nvi].sequence = nv.sequence
    IF (ap.prsnl_id > 0)
     reply->app.nv[nvi].nv_type_flag = 2, reply->app.prsnl_id = ap.prsnl_id
    ELSE
     IF (ap.position_cd > 0)
      reply->app.nv[nvi].nv_type_flag = 1, reply->app.position_cd = ap.position_cd
     ELSE
      reply->app.nv[nvi].nv_type_flag = 0
     ENDIF
    ENDIF
   DETAIL
    row + 0
   FOOT REPORT
    IF (nvi > 0)
     stat = alterlist(reply->app.nv,nvi), reply->app.nv_cnt = nvi
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF ((request->preftool_ind=1))
  SELECT INTO "nl:"
   ap.app_prefs_id, ap.prsnl_id, ap.position_cd,
   nv.pvc_name, nv.seq, ap.seq
   FROM app_prefs ap,
    name_value_prefs nv
   PLAN (ap
    WHERE (ap.application_number=request->application_number)
     AND ap.active_ind=1
     AND ap.prsnl_id > 0
     AND (ap.prsnl_id=request->prsnl_id)
     AND ap.position_cd=0)
    JOIN (nv
    WHERE nv.parent_entity_name="APP_PREFS"
     AND nv.parent_entity_id=ap.app_prefs_id
     AND nv.active_ind=1)
   ORDER BY nv.pvc_name, ap.prsnl_id DESC, ap.position_cd DESC
   HEAD REPORT
    nvi = 0
   HEAD nv.pvc_name
    nvi += 1
    IF (nvi > size(reply->app.nv,5))
     stat = alterlist(reply->app.nv,(nvi+ 10))
    ENDIF
    reply->app.nv[nvi].name_value_prefs_id = nv.name_value_prefs_id, reply->app.nv[nvi].pvc_name = nv
    .pvc_name, reply->app.nv[nvi].pvc_value = nv.pvc_value,
    reply->app.nv[nvi].merge_id = nv.merge_id, reply->app.nv[nvi].merge_name = nv.merge_name, reply->
    app.nv[nvi].sequence = nv.sequence,
    reply->app.nv[nvi].nv_type_flag = prsnl, reply->app.prsnl_id = ap.prsnl_id
   DETAIL
    row + 0
   FOOT REPORT
    IF (nvi > 0)
     stat = alterlist(reply->app.nv,nvi), reply->app.nv_cnt = nvi
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SELECT INTO "nl:"
    ap.app_prefs_id, ap.prsnl_id, ap.position_cd,
    nv.pvc_name, nv.seq, ap.seq
    FROM app_prefs ap,
     name_value_prefs nv
    PLAN (ap
     WHERE (ap.application_number=request->application_number)
      AND ap.active_ind=1
      AND ap.position_cd > 0
      AND ap.prsnl_id=0
      AND (ap.position_cd=request->position_cd))
     JOIN (nv
     WHERE nv.parent_entity_name="APP_PREFS"
      AND nv.parent_entity_id=ap.app_prefs_id
      AND nv.active_ind=1)
    ORDER BY nv.pvc_name, ap.prsnl_id DESC, ap.position_cd DESC
    HEAD REPORT
     nvi = 0
    HEAD nv.pvc_name
     nvi += 1
     IF (nvi > size(reply->app.nv,5))
      stat = alterlist(reply->app.nv,(nvi+ 10))
     ENDIF
     reply->app.nv[nvi].name_value_prefs_id = nv.name_value_prefs_id, reply->app.nv[nvi].pvc_name =
     nv.pvc_name, reply->app.nv[nvi].pvc_value = nv.pvc_value,
     reply->app.nv[nvi].merge_id = nv.merge_id, reply->app.nv[nvi].merge_name = nv.merge_name, reply
     ->app.nv[nvi].sequence = nv.sequence,
     reply->app.nv[nvi].nv_type_flag = position, reply->app.prsnl_id = ap.prsnl_id
    DETAIL
     row + 0
    FOOT REPORT
     IF (nvi > 0)
      stat = alterlist(reply->app.nv,nvi), reply->app.nv_cnt = nvi
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  IF (curqual=0)
   SELECT INTO "nl:"
    ap.app_prefs_id, ap.prsnl_id, ap.position_cd,
    nv.pvc_name, nv.seq, ap.seq
    FROM app_prefs ap,
     name_value_prefs nv
    PLAN (ap
     WHERE (ap.application_number=request->application_number)
      AND ap.active_ind=1
      AND ap.prsnl_id=0
      AND ap.position_cd=0)
     JOIN (nv
     WHERE nv.parent_entity_name="APP_PREFS"
      AND nv.parent_entity_id=ap.app_prefs_id
      AND nv.active_ind=1)
    ORDER BY nv.pvc_name, ap.prsnl_id DESC, ap.position_cd DESC
    HEAD REPORT
     nvi = 0
    HEAD nv.pvc_name
     nvi += 1
     IF (nvi > size(reply->app.nv,5))
      stat = alterlist(reply->app.nv,(nvi+ 10))
     ENDIF
     reply->app.nv[nvi].name_value_prefs_id = nv.name_value_prefs_id, reply->app.nv[nvi].pvc_name =
     nv.pvc_name, reply->app.nv[nvi].pvc_value = nv.pvc_value,
     reply->app.nv[nvi].merge_id = nv.merge_id, reply->app.nv[nvi].merge_name = nv.merge_name, reply
     ->app.nv[nvi].sequence = nv.sequence,
     reply->app.nv[nvi].nv_type_flag = system, reply->app.prsnl_id = ap.prsnl_id
    DETAIL
     row + 0
    FOOT REPORT
     IF (nvi > 0)
      stat = alterlist(reply->app.nv,nvi), reply->app.nv_cnt = nvi
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SELECT INTO "nl:"
   ap.app_prefs_id, ap.prsnl_id, ap.position_cd,
   nv.pvc_name, nv.seq, ap.seq
   FROM app_prefs ap,
    name_value_prefs nv
   PLAN (ap
    WHERE (ap.application_number=request->application_number)
     AND ap.active_ind=1
     AND ((ap.prsnl_id=0
     AND ap.position_cd=0) OR (((ap.position_cd=0
     AND (ap.prsnl_id=request->prsnl_id)) OR (ap.prsnl_id=0
     AND (ap.position_cd=request->position_cd))) )) )
    JOIN (nv
    WHERE nv.parent_entity_name="APP_PREFS"
     AND nv.parent_entity_id=ap.app_prefs_id
     AND nv.active_ind=1)
   ORDER BY nv.pvc_name, ap.prsnl_id DESC, ap.position_cd DESC
   HEAD REPORT
    nvi = 0
   DETAIL
    nvi += 1
    IF (nvi > size(reply->app.nv,5))
     stat = alterlist(reply->app.nv,(nvi+ 10))
    ENDIF
    reply->app.nv[nvi].name_value_prefs_id = nv.name_value_prefs_id, reply->app.nv[nvi].pvc_name = nv
    .pvc_name, reply->app.nv[nvi].pvc_value = nv.pvc_value,
    reply->app.nv[nvi].merge_id = nv.merge_id, reply->app.nv[nvi].merge_name = nv.merge_name, reply->
    app.nv[nvi].sequence = nv.sequence
    IF (ap.prsnl_id > 0)
     reply->app.nv[nvi].nv_type_flag = 2, reply->app.prsnl_id = ap.prsnl_id
    ELSE
     IF (ap.position_cd > 0)
      reply->app.nv[nvi].nv_type_flag = 1, reply->app.position_cd = ap.position_cd
     ELSE
      reply->app.nv[nvi].nv_type_flag = 0
     ENDIF
    ENDIF
    row + 0
   FOOT REPORT
    IF (nvi > 0)
     stat = alterlist(reply->app.nv,nvi), reply->app.nv_cnt = nvi
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->preftool_ind=1))
  SELECT INTO "nl:"
   vp.view_prefs_id
   FROM view_prefs vp
   WHERE (vp.prsnl_id=request->prsnl_id)
    AND vp.active_ind=1
    AND vp.prsnl_id > 0
    AND vp.position_cd=0
    AND (vp.application_number=request->application_number)
    AND expand(expand_num,1,request->top_view_list_cnt,vp.frame_type,trim(request->top_view_list[
     expand_num].frame_type))
   WITH nocounter, maxqual(vp,1)
  ;end select
 ENDIF
 IF ((((request->preftool_ind=1)
  AND curqual > 0) OR ((request->preftool_ind=0))) )
  SELECT INTO "nl:"
   vp.view_prefs_id, vp.seq, nv.seq
   FROM view_prefs vp,
    name_value_prefs nv
   PLAN (vp
    WHERE (vp.prsnl_id=request->prsnl_id)
     AND vp.active_ind=1
     AND vp.prsnl_id > 0
     AND vp.position_cd=0
     AND (vp.application_number=request->application_number))
    JOIN (nv
    WHERE nv.parent_entity_name="VIEW_PREFS"
     AND nv.parent_entity_id=vp.view_prefs_id
     AND nv.active_ind=1)
   ORDER BY vp.view_prefs_id
   HEAD REPORT
    count1 = 0, skip_view = "N"
   HEAD vp.view_prefs_id
    count1 += 1
    IF (count1 > size(reply->pview,5))
     stat = alterlist(reply->pview,(count1+ 10))
    ENDIF
    reply->pview[count1].view_prefs_id = vp.view_prefs_id, reply->pview[count1].application_number =
    vp.application_number, reply->pview[count1].position_cd = vp.position_cd,
    reply->pview[count1].prsnl_id = vp.prsnl_id, reply->pview[count1].frame_type = vp.frame_type,
    reply->pview[count1].view_name = vp.view_name,
    reply->pview[count1].view_seq = vp.view_seq, reply->pview[count1].updt_cnt = vp.updt_cnt, nvi = 0,
    skip_view = "N"
   DETAIL
    IF (skip_view="N")
     IF (nv.pvc_name="WWWFLAG"
      AND nv.pvc_value="2"
      AND (request->www_flag=0))
      skip_view = "Y", nvi = 0, count1 -= 1
     ELSE
      nvi += 1
      IF (nvi > size(reply->pview[count1].nv,5))
       stat = alterlist(reply->pview[count1].nv,(nvi+ 10))
      ENDIF
      reply->pview[count1].nv[nvi].name_value_prefs_id = nv.name_value_prefs_id, reply->pview[count1]
      .nv[nvi].pvc_name = nv.pvc_name, reply->pview[count1].nv[nvi].pvc_value = nv.pvc_value,
      reply->pview[count1].nv[nvi].merge_id = nv.merge_id, reply->pview[count1].nv[nvi].merge_name =
      nv.merge_name, reply->pview[count1].nv[nvi].sequence = nv.sequence,
      reply->pview[count1].nv[nvi].updt_cnt = nv.updt_cnt, reply->pview[count1].nv[nvi].nv_type_flag
       = prsnl
     ENDIF
    ENDIF
   FOOT  vp.view_prefs_id
    IF (nvi > 0)
     stat = alterlist(reply->pview[count1].nv,nvi), reply->pview[count1].nv_cnt = nvi
     IF ((request->preftool_ind=1))
      reply->view_level_flag = prsnl
     ENDIF
    ENDIF
   FOOT REPORT
    reply->view_cnt = count1
   WITH nocounter, orahint("index(vp xie3view_prefs) viewprefs")
  ;end select
 ENDIF
 IF ((reply->view_cnt > 0)
  AND (request->preftool_ind=1))
  SET reply->status_data.status = "S"
  GO TO exit_program
 ENDIF
 IF ((request->preftool_ind=1))
  SELECT INTO "nl:"
   vp.view_prefs_id
   FROM view_prefs vp
   WHERE (vp.position_cd=request->position_cd)
    AND vp.active_ind=1
    AND vp.position_cd > 0
    AND vp.prsnl_id=0
    AND (vp.application_number=request->application_number)
    AND expand(expand_num,1,request->top_view_list_cnt,vp.frame_type,trim(request->top_view_list[
     expand_num].frame_type))
   WITH nocounter, maxqual(vp,1)
  ;end select
 ENDIF
 IF ((((request->preftool_ind=1)
  AND curqual > 0) OR ((request->preftool_ind=0))) )
  SELECT INTO "nl:"
   vp.view_prefs_id, vp.seq, nv.seq
   FROM view_prefs vp,
    name_value_prefs nv
   PLAN (vp
    WHERE (vp.position_cd=request->position_cd)
     AND vp.active_ind=1
     AND vp.position_cd > 0
     AND vp.prsnl_id=0
     AND (vp.application_number=request->application_number))
    JOIN (nv
    WHERE nv.parent_entity_name="VIEW_PREFS"
     AND nv.parent_entity_id=vp.view_prefs_id
     AND nv.active_ind=1)
   ORDER BY vp.view_prefs_id
   HEAD REPORT
    skip_view = "N"
   HEAD vp.view_prefs_id
    count1 += 1
    IF (count1 > size(reply->pview,5))
     stat = alterlist(reply->pview,(count1+ 10))
    ENDIF
    reply->pview[count1].view_prefs_id = vp.view_prefs_id, reply->pview[count1].application_number =
    vp.application_number, reply->pview[count1].position_cd = vp.position_cd,
    reply->pview[count1].prsnl_id = vp.prsnl_id, reply->pview[count1].frame_type = vp.frame_type,
    reply->pview[count1].view_name = vp.view_name,
    reply->pview[count1].view_seq = vp.view_seq, reply->pview[count1].updt_cnt = vp.updt_cnt, nvi = 0,
    skip_view = "N"
   DETAIL
    IF (skip_view="N")
     IF (nv.pvc_name="WWWFLAG"
      AND nv.pvc_value="2"
      AND (request->www_flag=0))
      skip_view = "Y", nvi = 0, count1 -= 1
     ELSE
      nvi += 1
      IF (nvi > size(reply->pview[count1].nv,5))
       stat = alterlist(reply->pview[count1].nv,(nvi+ 10))
      ENDIF
      reply->pview[count1].nv[nvi].name_value_prefs_id = nv.name_value_prefs_id, reply->pview[count1]
      .nv[nvi].pvc_name = nv.pvc_name, reply->pview[count1].nv[nvi].pvc_value = nv.pvc_value,
      reply->pview[count1].nv[nvi].merge_id = nv.merge_id, reply->pview[count1].nv[nvi].merge_name =
      nv.merge_name, reply->pview[count1].nv[nvi].sequence = nv.sequence,
      reply->pview[count1].nv[nvi].updt_cnt = nv.updt_cnt, reply->pview[count1].nv[nvi].nv_type_flag
       = position
     ENDIF
    ENDIF
   FOOT  vp.view_prefs_id
    IF (nvi > 0)
     stat = alterlist(reply->pview[count1].nv,nvi), reply->pview[count1].nv_cnt = nvi
     IF ((request->preftool_ind=1))
      reply->view_level_flag = position
     ENDIF
    ENDIF
   FOOT REPORT
    reply->view_cnt = count1
   WITH nocounter, orahint("index(vp xie3view_prefs) posprefs")
  ;end select
 ENDIF
 IF ((reply->view_cnt > 0)
  AND (request->preftool_ind=1))
  SET reply->status_data.status = "S"
  GO TO exit_program
 ENDIF
 IF (old_preftool_ind=1)
  IF ((reply->app.nv_cnt=0)
   AND (reply->view_cnt=0))
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
  GO TO exit_program
 ENDIF
 IF (curqual=0)
  IF ((request->preftool_ind=1))
   SELECT INTO "nl:"
    vp.view_prefs_id
    FROM view_prefs vp
    WHERE vp.position_cd=0
     AND vp.active_ind=1
     AND vp.prsnl_id=0
     AND (vp.application_number=request->application_number)
     AND expand(expand_num,1,request->top_view_list_cnt,vp.frame_type,trim(request->top_view_list[
      expand_num].frame_type))
    WITH nocounter, maxqual(vp,1)
   ;end select
  ENDIF
  IF ((((request->preftool_ind=1)
   AND curqual > 0) OR ((request->preftool_ind=0))) )
   SELECT INTO "nl:"
    vp.view_prefs_id, vp.seq, nv.seq
    FROM view_prefs vp,
     name_value_prefs nv
    PLAN (vp
     WHERE vp.position_cd=0
      AND vp.prsnl_id=0
      AND (vp.application_number=request->application_number)
      AND vp.active_ind=1
      AND vp.application_number > 0)
     JOIN (nv
     WHERE nv.parent_entity_name="VIEW_PREFS"
      AND nv.parent_entity_id=vp.view_prefs_id
      AND nv.active_ind=1)
    ORDER BY vp.view_prefs_id
    HEAD REPORT
     skip_view = "N"
    HEAD vp.view_prefs_id
     count1 += 1
     IF (count1 > size(reply->pview,5))
      stat = alterlist(reply->pview,(count1+ 10))
     ENDIF
     reply->pview[count1].view_prefs_id = vp.view_prefs_id, reply->pview[count1].application_number
      = vp.application_number, reply->pview[count1].position_cd = vp.position_cd,
     reply->pview[count1].prsnl_id = vp.prsnl_id, reply->pview[count1].frame_type = vp.frame_type,
     reply->pview[count1].view_name = vp.view_name,
     reply->pview[count1].view_seq = vp.view_seq, reply->pview[count1].updt_cnt = vp.updt_cnt, nvi =
     0,
     skip_view = "N"
    DETAIL
     IF (skip_view="N")
      IF (nv.pvc_name="WWWFLAG"
       AND nv.pvc_value="2"
       AND (request->www_flag=0))
       skip_view = "Y", nvi = 0, count1 -= 1
      ELSE
       nvi += 1
       IF (nvi > size(reply->pview[count1].nv,5))
        stat = alterlist(reply->pview[count1].nv,(nvi+ 10))
       ENDIF
       reply->pview[count1].nv[nvi].name_value_prefs_id = nv.name_value_prefs_id, reply->pview[count1
       ].nv[nvi].pvc_name = nv.pvc_name, reply->pview[count1].nv[nvi].pvc_value = nv.pvc_value,
       reply->pview[count1].nv[nvi].merge_id = nv.merge_id, reply->pview[count1].nv[nvi].merge_name
        = nv.merge_name, reply->pview[count1].nv[nvi].sequence = nv.sequence,
       reply->pview[count1].nv[nvi].updt_cnt = nv.updt_cnt, reply->pview[count1].nv[nvi].nv_type_flag
        = system
      ENDIF
     ENDIF
    FOOT  vp.view_prefs_id
     IF (nvi > 0)
      stat = alterlist(reply->pview[count1].nv,nvi), reply->pview[count1].nv_cnt = nvi
      IF ((request->preftool_ind=1))
       reply->view_level_flag = system
      ENDIF
     ENDIF
    FOOT REPORT
     reply->view_cnt = count1
    WITH nocounter, orahint("index(vp xie3view_prefs) appviewprefs")
   ;end select
  ENDIF
  IF ((reply->view_cnt > 0)
   AND (request->preftool_ind=1))
   SET reply->status_data.status = "S"
   GO TO exit_program
  ENDIF
 ELSEIF ((request->preftool_ind=0))
  SELECT INTO "nl:"
   vp.view_prefs_id, vp.seq, nv.seq
   FROM view_prefs vp,
    name_value_prefs nv
   PLAN (vp
    WHERE vp.position_cd=0
     AND vp.prsnl_id=0
     AND (vp.application_number=request->application_number)
     AND vp.frame_type IN ("MPTASKLIST", "SPTASKLIST", "INBOXDISCERN")
     AND vp.active_ind=1
     AND vp.application_number > 0)
    JOIN (nv
    WHERE nv.parent_entity_name="VIEW_PREFS"
     AND nv.parent_entity_id=vp.view_prefs_id
     AND nv.active_ind=1)
   ORDER BY vp.view_prefs_id
   HEAD REPORT
    skip_view = "N"
   HEAD vp.view_prefs_id
    count1 += 1
    IF (count1 > size(reply->pview,5))
     stat = alterlist(reply->pview,(count1+ 10))
    ENDIF
    reply->pview[count1].view_prefs_id = vp.view_prefs_id, reply->pview[count1].application_number =
    vp.application_number, reply->pview[count1].position_cd = vp.position_cd,
    reply->pview[count1].prsnl_id = vp.prsnl_id, reply->pview[count1].frame_type = vp.frame_type,
    reply->pview[count1].view_name = vp.view_name,
    reply->pview[count1].view_seq = vp.view_seq, reply->pview[count1].updt_cnt = vp.updt_cnt, nvi = 0,
    skip_view = "N"
   DETAIL
    IF (skip_view="N")
     IF (nv.pvc_name="WWWFLAG"
      AND nv.pvc_value="2"
      AND (request->www_flag=0))
      skip_view = "Y", nvi = 0, count1 -= 1
     ELSE
      nvi += 1
      IF (nvi > size(reply->pview[count1].nv,5))
       stat = alterlist(reply->pview[count1].nv,(nvi+ 10))
      ENDIF
      reply->pview[count1].nv[nvi].name_value_prefs_id = nv.name_value_prefs_id, reply->pview[count1]
      .nv[nvi].pvc_name = nv.pvc_name, reply->pview[count1].nv[nvi].pvc_value = nv.pvc_value,
      reply->pview[count1].nv[nvi].merge_id = nv.merge_id, reply->pview[count1].nv[nvi].merge_name =
      nv.merge_name, reply->pview[count1].nv[nvi].sequence = nv.sequence,
      reply->pview[count1].nv[nvi].updt_cnt = nv.updt_cnt
     ENDIF
    ENDIF
   FOOT  vp.view_prefs_id
    IF (nvi > 0)
     stat = alterlist(reply->pview[count1].nv,nvi), reply->pview[count1].nv_cnt = nvi
    ENDIF
   FOOT REPORT
    reply->view_cnt = count1
   WITH nocounter, orahint("index(vp xie3view_prefs) restframes")
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
 IF ((reply->view_cnt > 0))
  SET stat = alterlist(reply->pview,reply->view_cnt)
 ENDIF
#exit_program
 IF ((reply->view_cnt > 0))
  SET stat = alterlist(reply->pview,reply->view_cnt)
 ENDIF
END GO
