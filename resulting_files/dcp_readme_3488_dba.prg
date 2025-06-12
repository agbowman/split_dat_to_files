CREATE PROGRAM dcp_readme_3488:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 FREE RECORD diluentprefs
 RECORD diluentprefs(
   1 pref_list[*]
     2 app_prefs_id = f8
     2 pvc_value = vc
 )
 SET readme_data->status = "F"
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE rdm_errmsg = c150 WITH noconstant(fillstring(150," "))
 DECLARE count = i4 WITH noconstant(0)
 SET rdm_errmsg = "Adding the DILUENTS_EVENTSET_NAME pref as an app_pref was unsuccessful"
 SELECT
  a.app_prefs_id, n.pvc_value
  FROM app_prefs a,
   detail_prefs d,
   name_value_prefs n
  PLAN (n
   WHERE n.pvc_name="DILUENTS_EVENTSET_NAME")
   JOIN (d
   WHERE d.detail_prefs_id=n.parent_entity_id)
   JOIN (a
   WHERE a.position_cd=d.position_cd
    AND a.prsnl_id=d.prsnl_id
    AND a.application_number=600005)
  ORDER BY a.app_prefs_id
  HEAD a.app_prefs_id
   IF (a.app_prefs_id > 0)
    count = (count+ 1)
    IF (mod(count,10)=1)
     stat = alterlist(diluentprefs->pref_list,(count+ 9))
    ENDIF
    diluentprefs->pref_list[count].app_prefs_id = a.app_prefs_id, diluentprefs->pref_list[count].
    pvc_value = n.pvc_value
   ENDIF
  FOOT REPORT
   stat = alterlist(diluentprefs->pref_list,count)
  WITH nocounter
 ;end select
 IF (count=0)
  SET failed = "Z"
  SET rdm_errmsg = "There was no DILUENTS_EVENTSET_NAME detail pref"
  GO TO exit_readme
 ENDIF
 FOR (x = 1 TO count)
   INSERT  FROM name_value_prefs nv
    SET nv.updt_task = reqinfo->updt_task, nv.updt_applctx = reqinfo->updt_applctx, nv
     .name_value_prefs_id = seq(carenet_seq,nextval),
     nv.parent_entity_name = "APP_PREFS", nv.parent_entity_id = diluentprefs->pref_list[x].
     app_prefs_id, nv.pvc_name = "DILUENTS_EVENTSET_NAME",
     nv.pvc_value = diluentprefs->pref_list[x].pvc_value, nv.updt_cnt = 0, nv.active_ind = 1,
     nv.updt_id = reqinfo->updt_id, nv.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   ;end insert
 ENDFOR
 SET failed = "S"
#exit_readme
 IF (failed="S")
  SET readme_data->status = "S"
  SET readme_data->message = "The DILUENTS_EVENTSET_NAME pref was successfully added to app level"
  COMMIT
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = rdm_errmsg
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
END GO
