CREATE PROGRAM cps_set_detail_prefs:dba
 FREE SET input
 RECORD input(
   1 application_number = i4
   1 position_cd = f8
   1 prsnl_id = f8
   1 person_id = f8
   1 view_name = c12
   1 view_seq = i4
   1 comp_name = c12
   1 comp_seq = i4
   1 nv_cnt = i4
   1 nv[1]
     2 name_value_prefs_id = f8
     2 pvc_name = c32
     2 pvc_value = vc
     2 updt_cnt = i4
 )
 SET input->application_number = 961000
 SET input->position_cd = 0
 SET input->prsnl_id = 0
 SET input->person_id = 0
 SET input->view_name = "FLOWSHEET"
 SET input->view_seq = 1
 SET input->comp_name = "FLOWSHEET"
 SET input->comp_seq = 1
 SET input->nv_cnt = 0
 SET det_prefs_id = 0
 SET failed = "F"
 SET updt_cnt = 0
 IF ((input->position_cd > 0)
  AND (input->prsnl_id > 0))
  SET input->position_cd = 0
 ENDIF
 SELECT INTO "nl:"
  dp.seq
  FROM detail_prefs dp
  PLAN (dp
   WHERE (dp.application_number=input->application_number)
    AND (dp.position_cd=input->position_cd)
    AND (dp.prsnl_id=input->prsnl_id)
    AND (dp.view_name=input->view_name)
    AND (dp.view_seq=input->view_seq)
    AND (dp.comp_name=input->comp_name)
    AND (dp.comp_seq=input->comp_seq))
  HEAD REPORT
   det_prefs_id = 0
  DETAIL
   det_prefs_id = dp.detail_prefs_id
  WITH nocounter, maxqual(dp,1)
 ;end select
 IF (curqual=0)
  GO TO add_det_prefs
 ENDIF
 FOR (x = 1 TO input->nv_cnt)
  IF ((input->nv[x].name_value_prefs_id > 0))
   UPDATE  FROM name_value_prefs nvp
    SET nvp.pvc_name = input->nv[x].pvc_name, nvp.pvc_value = input->nv[x].pvc_value, nvp.updt_dt_tm
      = cnvtdatetime(curdate,curtime3),
     nvp.updt_id = 0.0, nvp.updt_task = 0.0, nvp.updt_applctx = 0.0,
     nvp.updt_cnt = (nvp.updt_cnt+ 1)
    WHERE (nvp.name_value_prefs_id=input->nv[x].name_value_prefs_id)
    WITH nocounter
   ;end update
  ELSE
   INSERT  FROM name_value_prefs nvp
    SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = "DETAIL_PREFS",
     nvp.parent_entity_id = det_prefs_id,
     nvp.pvc_name = input->nv[x].pvc_name, nvp.pvc_value = input->nv[x].pvc_value, nvp.active_ind = 1,
     nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = 0.0, nvp.updt_task = 0.0,
     nvp.updt_applctx = 0.0, nvp.updt_cnt = 0
    WITH nocounter
   ;end insert
  ENDIF
  IF (curqual=0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDFOR
 GO TO exit_script
#add_det_prefs
 SELECT INTO "nl:"
  j = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   det_prefs_id = cnvtint(j)
  WITH format, nocounter
 ;end select
 INSERT  FROM detail_prefs dp
  SET dp.detail_prefs_id = det_prefs_id, dp.application_number = input->application_number, dp
   .position_cd = input->position_cd,
   dp.prsnl_id = input->prsnl_id, dp.person_id = input->person_id, dp.view_name = input->view_name,
   dp.view_seq = input->view_seq, dp.comp_name = input->comp_name, dp.comp_seq = input->comp_seq,
   dp.active_ind = 1, dp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dp.updt_id = 0.0,
   dp.updt_task = 0.0, dp.updt_applctx = 0.0, dp.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF ((input->nv_cnt > 0))
  INSERT  FROM name_value_prefs nvp,
    (dummyt d1  WITH seq = value(input->nv_cnt))
   SET nvp.seq = 1, nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name =
    "DETAIL_PREFS",
    nvp.parent_entity_id = det_prefs_id, nvp.pvc_name = input->nv[d1.seq].pvc_name, nvp.pvc_value =
    input->nv[d1.seq].pvc_value,
    nvp.active_ind = 1, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = 0.0,
    nvp.updt_task = 0.0, nvp.updt_applctx = 0.0, nvp.updt_cnt = 0
   PLAN (d1)
    JOIN (nvp)
   WITH nocounter
  ;end insert
  IF ((curqual != input->nv_cnt))
   SET failed = "T"
  ENDIF
 ENDIF
#exit_script
 CALL echo(" ")
 IF (failed="F")
  COMMIT
  CALL echo("SUCCESS")
 ELSE
  ROLLBACK
  CALL echo("FAILURE")
 ENDIF
 CALL echo(" ")
END GO
