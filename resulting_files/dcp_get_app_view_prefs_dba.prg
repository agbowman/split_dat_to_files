CREATE PROGRAM dcp_get_app_view_prefs:dba
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
       3 sequence = i2
       3 merge_id = f8
       3 merge_name = vc
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
       3 sequence = i2
       3 merge_id = f8
       3 merge_name = vc
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nvi = i2
 DECLARE x = i2
 DECLARE count1 = i2
 DECLARE system = i2
 DECLARE position = i2
 DECLARE prsnl = i2
 DECLARE old_preftool_ind = i2
 SET reply->status_data.status = "F"
 SET reply->view_cnt = 0
 SET nvi = 0
 SET x = 0
 SET count1 = 0
 SET reply->app.application_number = request->application_number
 SET reply->app.position_cd = request->position_cd
 SET reply->app.prsnl_id = request->prsnl_id
 SET reply->view_level_flag = - (1)
 SET system = 0
 SET position = 1
 SET prsnl = 2
 SET old_preftool_ind = 0
 CALL echo(build("Preftool_ind = ",request->preftool_ind))
 CALL echo(build("It is from old PrefTool: ",old_preftool_ind))
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
  ORDER BY nv.pvc_name, nv.sequence
  HEAD REPORT
   nvi = 0, pvc_cnt = 0, seq_cnt = 0
  HEAD nv.pvc_name
   pvc_cnt = (pvc_cnt+ 1)
  HEAD nv.sequence
   seq_cnt = (seq_cnt+ 1)
  DETAIL
   nvi = (nvi+ 1)
   IF (nvi > size(reply->app.nv,5))
    stat = alterlist(reply->app.nv,(nvi+ 10))
   ENDIF
   reply->app.nv[nvi].name_value_prefs_id = nv.name_value_prefs_id, reply->app.nv[nvi].pvc_name = nv
   .pvc_name, reply->app.nv[nvi].pvc_value = nv.pvc_value,
   reply->app.nv[nvi].sequence = nv.sequence, reply->app.nv[nvi].merge_id = nv.merge_id, reply->app.
   nv[nvi].merge_name = nv.merge_name
   IF (ap.prsnl_id > 0)
    reply->app.nv[nvi].nv_type_flag = 2, reply->app.prsnl_id = ap.prsnl_id
   ELSE
    IF (ap.position_cd > 0)
     reply->app.nv[nvi].nv_type_flag = 1, reply->app.position_cd = ap.position_cd
    ELSE
     reply->app.nv[nvi].nv_type_flag = 0
    ENDIF
   ENDIF
  FOOT  nv.sequence
   seq_cnt = seq_cnt
  FOOT  nv.pvc_name
   pvc_cnt = pvc_cnt
  FOOT REPORT
   CALL echo(build("NVI = ",nvi))
   IF (nvi > 0)
    stat = alterlist(reply->app.nv,nvi), reply->app.nv_cnt = nvi
   ENDIF
  WITH nocounter, dontcare(nv)
 ;end select
 IF (curqual=0)
  CALL echo("There is NO app prefs for PC!")
 ELSE
  CALL echo(build("PowerChart nv_cnt = ",reply->app.nv_cnt))
  FOR (x = 1 TO reply->app.nv_cnt)
    CALL echo(build(" name = ",reply->app.nv[x].pvc_name))
    CALL echo(build("      value = ",reply->app.nv[x].pvc_value))
    CALL echo(build("      sequence =",reply->app.nv[x].sequence))
    CALL echo(build("      merge_id =",reply->app.nv[x].merge_id))
    CALL echo(build("      merge_name =",reply->app.nv[x].merge_name))
  ENDFOR
 ENDIF
 IF ((request->preftool_ind=1)
  AND (request->prsnl_id > 0))
  SELECT INTO "nl:"
   vp.view_prefs_id
   FROM view_prefs vp,
    (dummyt d  WITH seq = value(request->top_view_list_cnt))
   PLAN (d)
    JOIN (vp
    WHERE (vp.prsnl_id=request->prsnl_id)
     AND vp.active_ind=1
     AND vp.position_cd=0
     AND (vp.application_number=request->application_number)
     AND vp.frame_type=trim(request->top_view_list[d.seq].frame_type))
   WITH nocounter
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
    count1 = (count1+ 1)
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
     nvi = (nvi+ 1)
     IF (nvi > size(reply->pview[count1].nv,5))
      stat = alterlist(reply->pview[count1].nv,(nvi+ 10))
     ENDIF
     reply->pview[count1].nv[nvi].name_value_prefs_id = nv.name_value_prefs_id, reply->pview[count1].
     nv[nvi].pvc_name = nv.pvc_name, reply->pview[count1].nv[nvi].pvc_value = nv.pvc_value,
     reply->pview[count1].nv[nvi].sequence = nv.sequence, reply->pview[count1].nv[nvi].merge_id = nv
     .merge_id, reply->pview[count1].nv[nvi].merge_name = nv.merge_name,
     reply->pview[count1].nv[nvi].updt_cnt = nv.updt_cnt, reply->pview[count1].nv[nvi].nv_type_flag
      = prsnl
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
 IF ((request->preftool_ind=1)
  AND (request->top_view_list_cnt > 0))
  SELECT INTO "nl:"
   vp.view_prefs_id
   FROM view_prefs vp,
    (dummyt d  WITH seq = value(request->top_view_list_cnt))
   PLAN (vp
    WHERE (vp.position_cd=request->position_cd)
     AND vp.active_ind=1
     AND vp.position_cd > 0
     AND vp.prsnl_id=0
     AND (vp.application_number=request->application_number))
    JOIN (d
    WHERE vp.frame_type=trim(request->top_view_list[d.seq].frame_type))
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(build("curqual Position b = ",curqual))
 IF ((((request->preftool_ind=1)
  AND curqual > 0) OR ((request->preftool_ind=0))) )
  SELECT INTO "nl:"
   vp.view_prefs_id, vp.seq, nv.seq
   FROM view_prefs vp,
    name_value_prefs nv
   PLAN (vp
    WHERE (vp.position_cd=request->position_cd)
     AND vp.active_ind=1
     AND (vp.position_cd=request->position_cd)
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
    count1 = (count1+ 1)
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
     nvi = (nvi+ 1)
     IF (nvi > size(reply->pview[count1].nv,5))
      stat = alterlist(reply->pview[count1].nv,(nvi+ 10))
     ENDIF
     reply->pview[count1].nv[nvi].name_value_prefs_id = nv.name_value_prefs_id, reply->pview[count1].
     nv[nvi].pvc_name = nv.pvc_name, reply->pview[count1].nv[nvi].pvc_value = nv.pvc_value,
     reply->pview[count1].nv[nvi].sequence = nv.sequence, reply->pview[count1].nv[nvi].merge_id = nv
     .merge_id, reply->pview[count1].nv[nvi].merge_name = nv.merge_name,
     reply->pview[count1].nv[nvi].updt_cnt = nv.updt_cnt, reply->pview[count1].nv[nvi].nv_type_flag
      = position
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
  IF ((request->preftool_ind=1)
   AND (request->top_view_list_cnt > 0))
   SELECT INTO "nl:"
    vp.view_prefs_id
    FROM view_prefs vp,
     (dummyt d  WITH seq = value(request->top_view_list_cnt))
    PLAN (d)
     JOIN (vp
     WHERE vp.position_cd=0
      AND vp.active_ind=1
      AND vp.prsnl_id=0
      AND (vp.application_number=request->application_number)
      AND vp.frame_type=trim(request->top_view_list[d.seq].frame_type))
    WITH nocounter
   ;end select
  ENDIF
  CALL echo(build("curqual  Position b = ",curqual))
  IF ((((request->preftool_ind=1)
   AND curqual > 0) OR ((request->preftool_ind=0))) )
   SELECT INTO "nl:"
    vp.view_prefs_id
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
     count1 = (count1+ 1)
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
      nvi = (nvi+ 1)
      IF (nvi > size(reply->pview[count1].nv,5))
       stat = alterlist(reply->pview[count1].nv,(nvi+ 10))
      ENDIF
      reply->pview[count1].nv[nvi].name_value_prefs_id = nv.name_value_prefs_id, reply->pview[count1]
      .nv[nvi].pvc_name = nv.pvc_name, reply->pview[count1].nv[nvi].pvc_value = nv.pvc_value,
      reply->pview[count1].nv[nvi].sequence = nv.sequence, reply->pview[count1].nv[nvi].merge_id = nv
      .merge_id, reply->pview[count1].nv[nvi].merge_name = nv.merge_name,
      reply->pview[count1].nv[nvi].updt_cnt = nv.updt_cnt, reply->pview[count1].nv[nvi].nv_type_flag
       = system
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
  CALL echo(build("# of views from system = ",reply->view_cnt))
  IF ((reply->view_cnt > 0)
   AND (request->preftool_ind=1))
   SET reply->status_data.status = "S"
   GO TO exit_program
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 IF ((reply->view_cnt > 0))
  SET stat = alterlist(reply->pview,reply->view_cnt)
 ENDIF
#exit_program
 IF ((reply->view_cnt > 0))
  SET stat = alterlist(reply->pview,reply->view_cnt)
 ENDIF
 CALL echo(build("Total view cnt =",reply->view_cnt))
 FOR (nvi = 1 TO reply->view_cnt)
   CALL echo(build("view view name =",reply->pview[nvi].view_name))
 ENDFOR
 CALL echo(build("Pref_level_flag = ",reply->view_level_flag))
END GO
