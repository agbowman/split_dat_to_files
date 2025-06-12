CREATE PROGRAM dd_rdm_cnvt_sign_prefs:dba
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
 FREE RECORD rec_detail_prefs
 RECORD rec_detail_prefs(
   1 pref_list[*]
     2 application_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 pvc_name = c32
     2 pvc_value = vc
     2 sequence = i2
     2 merge_id = f8
     2 merge_name = vc
     2 nvp_id = f8
     2 status = i2
 )
 FREE RECORD rec_app_prefs_req
 RECORD rec_app_prefs_req(
   1 application_number = i4
   1 position_cd = f8
   1 prsnl_id = f8
   1 nv[*]
     2 pvc_name = c32
     2 pvc_value = vc
     2 sequence = i2
     2 merge_id = f8
     2 merge_name = vc
 )
 FREE RECORD rec_app_prefs_rep
 RECORD rec_app_prefs_rep(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD rec_del_name_value
 RECORD rec_del_name_value(
   1 nv[*]
     2 name_value_prefs_id = f8
 )
 DECLARE insertappprefs(null) = null
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE nvcnt = i4
 DECLARE pref_dd_sign_dlg_state = vc WITH public, constant("DD_SIGN_DLG_STATE")
 DECLARE pref_dd_sign_dlg_size = vc WITH public, constant("DD_SIGN_DLG_SIZE")
 DECLARE pref_dd_sign_last_tab = vc WITH public, constant("DD_SIGN_LAST_TAB")
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Failed starting dd_rdm_cnvt_sign_prefs..."
 CALL echo("*** Converting all DD_SIGN_DLG_STATE detail prefs to app prefs ***")
 CALL main(pref_dd_sign_dlg_state)
 CALL echo("*** Converting all DD_SIGN_DLG_SIZE detail prefs to app prefs ***")
 CALL main(pref_dd_sign_dlg_size)
 CALL echo("*** Converting all DD_SIGN_LAST_TAB detail prefs to app prefs ***")
 CALL main(pref_dd_sign_last_tab)
 SET readme_data->status = "S"
 SET readme_data->message = "Success: All tasks completed successfully."
 SUBROUTINE (main(pvc_name=vc) =null)
   SET stat = initrec(rec_detail_prefs)
   SET stat = initrec(rec_del_name_value)
   CALL convertprefs(600005,pvc_name)
   CALL convertprefs(820000,pvc_name)
   CALL convertprefs(4250111,pvc_name)
   CALL convertprefs(610000,pvc_name)
   COMMIT
 END ;Subroutine
 SUBROUTINE (convertprefs(app_number=i4,pvc_name=vc) =null)
  CALL getdetailprefs(app_number,pvc_name)
  IF (size(rec_detail_prefs->pref_list,5) > 0)
   CALL insertappprefs(null)
   CALL deletedetailprefs(app_number,pvc_name)
  ENDIF
 END ;Subroutine
 SUBROUTINE (getdetailprefs(app_number=i4,pvc_name=vc) =null)
  SELECT INTO "nl:"
   FROM name_value_prefs nvp,
    detail_prefs dp
   PLAN (nvp
    WHERE nvp.active_ind=1
     AND nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.pvc_name=pvc_name)
    JOIN (dp
    WHERE nvp.parent_entity_id=dp.detail_prefs_id
     AND dp.application_number=app_number)
   ORDER BY dp.prsnl_id, nvp.pvc_name, dp.updt_dt_tm DESC
   HEAD REPORT
    prsnlcnt = 0, stat = alterlist(rec_detail_prefs->pref_list,100)
   HEAD dp.prsnl_id
    IF ( NOT (nvp.pvc_value IN ("", " ", null)))
     prsnlcnt += 1
     IF (prsnlcnt > 100
      AND mod(prsnlcnt,100)=1)
      stat = alterlist(rec_detail_prefs->pref_list,(prsnlcnt+ 99))
     ENDIF
     rec_detail_prefs->pref_list[prsnlcnt].application_number = dp.application_number,
     rec_detail_prefs->pref_list[prsnlcnt].position_cd = dp.position_cd, rec_detail_prefs->pref_list[
     prsnlcnt].prsnl_id = dp.prsnl_id,
     rec_detail_prefs->pref_list[prsnlcnt].pvc_name = pvc_name, rec_detail_prefs->pref_list[prsnlcnt]
     .pvc_value = nvp.pvc_value, rec_detail_prefs->pref_list[prsnlcnt].nvp_id = nvp
     .name_value_prefs_id
    ENDIF
   FOOT REPORT
    stat = alterlist(rec_detail_prefs->pref_list,prsnlcnt)
   WITH nocounter
  ;end select
  IF (error(errmsg,0) > 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to query detail prefs: ",errmsg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE insertappprefs(null)
  SET prsnlcnt = size(rec_detail_prefs->pref_list,5)
  FOR (i = 1 TO prsnlcnt)
    SET stat = initrec(rec_app_prefs_req)
    SET stat = initrec(rec_app_prefs_rep)
    SET rec_app_prefs_req->application_number = rec_detail_prefs->pref_list[i].application_number
    SET rec_app_prefs_req->position_cd = rec_detail_prefs->pref_list[i].position_cd
    SET rec_app_prefs_req->prsnl_id = rec_detail_prefs->pref_list[i].prsnl_id
    SET stat = alterlist(rec_app_prefs_req->nv,1)
    SET rec_app_prefs_req->nv[1].pvc_name = rec_detail_prefs->pref_list[i].pvc_name
    SET rec_app_prefs_req->nv[1].pvc_value = rec_detail_prefs->pref_list[i].pvc_value
    EXECUTE dcp_add_app_prefs  WITH replace("REQUEST",rec_app_prefs_req), replace("REPLY",
     rec_app_prefs_rep)
    IF ((rec_app_prefs_rep->status_data.status="F"))
     SET readme_data->status = "F"
     SET readme_data->message = "Readme failure: Could not insert the app prefs"
     GO TO exit_script
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE (deletedetailprefs(app_number=i4,pvc_name=vc) =null)
   SELECT INTO "nl:"
    FROM name_value_prefs nvp,
     detail_prefs dp
    PLAN (nvp
     WHERE nvp.name_value_prefs_id != 0.0
      AND nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.pvc_name=pvc_name)
     JOIN (dp
     WHERE dp.application_number=app_number
      AND dp.detail_prefs_id=nvp.parent_entity_id)
    HEAD REPORT
     nvcnt = 0, stat = alterlist(rec_del_name_value->nv,100)
    DETAIL
     nvcnt += 1
     IF (nvcnt > 100
      AND mod(nvcnt,100)=1)
      stat = alterlist(rec_del_name_value->nv,(nvcnt+ 99))
     ENDIF
     rec_del_name_value->nv[nvcnt].name_value_prefs_id = nvp.name_value_prefs_id
    FOOT REPORT
     stat = alterlist(rec_del_name_value->nv,nvcnt)
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to query detail prefs: ",errmsg)
    GO TO exit_script
   ENDIF
   IF (nvcnt > 0)
    DELETE  FROM name_value_prefs nvp,
      (dummyt d1  WITH seq = value(nvcnt))
     SET nvp.seq = 1
     PLAN (d1
      WHERE (rec_del_name_value->nv[d1.seq].name_value_prefs_id != 0))
      JOIN (nvp
      WHERE (nvp.name_value_prefs_id=rec_del_name_value->nv[d1.seq].name_value_prefs_id))
     WITH nocounter
    ;end delete
    IF (error(errmsg,0) > 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to delete detail prefs: ",errmsg)
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
