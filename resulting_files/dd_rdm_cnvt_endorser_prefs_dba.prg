CREATE PROGRAM dd_rdm_cnvt_endorser_prefs:dba
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
 FREE RECORD rec_concat_detail_prefs
 RECORD rec_concat_detail_prefs(
   1 qual[*]
     2 prsnl_id = f8
     2 position_cd = f8
     2 pvc_list[*]
       3 pvc_name = c32
       3 pvc_value = vc
 )
 FREE RECORD rec_app_prefs
 RECORD rec_app_prefs(
   1 qual[*]
     2 application_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 nv[1]
       3 pvc_name = c32
       3 pvc_value = vc
       3 sequence = i2
       3 merge_id = f8
       3 merge_name = vc
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
 DECLARE concatdetailprefs(null) = null
 DECLARE insertappprefs(null) = null
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE detail_pvc_values = vc WITH protect, noconstant("")
 DECLARE app_pvc_value_unique = vc WITH protect
 DECLARE temp_pvc_value = vc WITH protect
 DECLARE nvcnt = i4 WITH protect
 DECLARE pref_dd_default_endorsers = vc WITH public, constant("DD_DEFAULT_ENDORSERS")
 DECLARE pref_dd_fav_endorsers = vc WITH public, constant("DD_FAV_ENDORSERS")
 DECLARE pref_dd_recent_endorsers = vc WITH public, constant("DD_RECENT_ENDORSERS")
 DECLARE pref_dd_num_default_endorsers = vc WITH public, constant("DD_NUM_DEFAULT_ENDORSERS")
 DECLARE pref_dd_num_fav_endorsers = vc WITH public, constant("DD_NUM_FAV_ENDORSERS")
 DECLARE pref_dd_num_recent_endorsers = vc WITH public, constant("DD_NUM_RECENT_ENDORSERS")
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Failed starting dd_rdm_cnvt_endorser_prefs..."
 CALL echo("*** Converting all DD_DEFAULT_ENDORSERS detail prefs to app prefs ***")
 CALL main(pref_dd_default_endorsers)
 CALL echo("*** Converting all DD_FAV_ENDORSERS detail prefs to app prefs ***")
 CALL main(pref_dd_fav_endorsers)
 CALL echo("*** Converting all DD_RECENT_ENDORSERS detail prefs to app prefs ***")
 CALL main(pref_dd_recent_endorsers)
 SET readme_data->status = "S"
 SET readme_data->message = "Success: All tasks completed successfully."
 SUBROUTINE (main(pvc_name=vc) =null)
   SET stat = initrec(rec_detail_prefs)
   SET stat = initrec(rec_concat_detail_prefs)
   SET stat = initrec(rec_app_prefs)
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
   CALL concatdetailprefs(null)
   CALL constructnewappprefs(app_number,pvc_name)
   CALL insertappprefs(null)
   CALL deletedetailprefs(app_number,pvc_name)
  ENDIF
 END ;Subroutine
 SUBROUTINE (getdetailprefs(app_number=i4,pvc_name=vc) =null)
  SELECT
   IF (pvc_name=pref_dd_default_endorsers)
    FROM name_value_prefs nvp,
     detail_prefs dp
    PLAN (nvp
     WHERE nvp.name_value_prefs_id != 0.0
      AND nvp.active_ind=1
      AND nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.pvc_name="DD_DEFAULT_ENDORSERS*")
     JOIN (dp
     WHERE nvp.parent_entity_id=dp.detail_prefs_id
      AND dp.application_number=app_number)
   ELSEIF (pvc_name=pref_dd_fav_endorsers)
    FROM name_value_prefs nvp,
     detail_prefs dp
    PLAN (nvp
     WHERE nvp.active_ind=1
      AND nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.pvc_name="DD_FAV_ENDORSERS*")
     JOIN (dp
     WHERE nvp.parent_entity_id=dp.detail_prefs_id
      AND dp.application_number=app_number)
   ELSEIF (pvc_name=pref_dd_recent_endorsers)
    FROM name_value_prefs nvp,
     detail_prefs dp
    PLAN (nvp
     WHERE nvp.active_ind=1
      AND nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.pvc_name="DD_RECENT_ENDORSERS*")
     JOIN (dp
     WHERE nvp.parent_entity_id=dp.detail_prefs_id
      AND dp.application_number=app_number)
   ELSE
   ENDIF
   INTO "nl:"
   FROM name_value_prefs nvp,
    detail_prefs dp
   PLAN (nvp
    WHERE nvp.active_ind=1
     AND nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.pvc_name="DD_DEFAULT_ENDORSERS*")
    JOIN (dp
    WHERE nvp.parent_entity_id=dp.detail_prefs_id
     AND dp.application_number=app_number)
   ORDER BY dp.prsnl_id, nvp.pvc_name
   HEAD REPORT
    pref_list_cnt = 0, stat = alterlist(rec_detail_prefs->pref_list,100)
   DETAIL
    IF ( NOT (nvp.pvc_value IN ("", " ", null)))
     pref_list_cnt += 1
     IF (pref_list_cnt > 100
      AND mod(pref_list_cnt,100)=1)
      stat = alterlist(rec_detail_prefs->pref_list,(pref_list_cnt+ 99))
     ENDIF
     rec_detail_prefs->pref_list[pref_list_cnt].application_number = dp.application_number,
     rec_detail_prefs->pref_list[pref_list_cnt].position_cd = dp.position_cd, rec_detail_prefs->
     pref_list[pref_list_cnt].prsnl_id = dp.prsnl_id,
     rec_detail_prefs->pref_list[pref_list_cnt].pvc_name = pvc_name, rec_detail_prefs->pref_list[
     pref_list_cnt].pvc_value = nvp.pvc_value, rec_detail_prefs->pref_list[pref_list_cnt].nvp_id =
     nvp.name_value_prefs_id
    ENDIF
   FOOT REPORT
    stat = alterlist(rec_detail_prefs->pref_list,pref_list_cnt)
   WITH nocounter
  ;end select
  IF (error(errmsg,0) > 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to query detail prefs: ",errmsg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE concatdetailprefs(null)
   RECORD temprec(
     1 qual[*]
       2 str = vc
   )
   SELECT INTO "nl:"
    prsnl_id = rec_detail_prefs->pref_list[d.seq].prsnl_id
    FROM (dummyt d  WITH seq = value(size(rec_detail_prefs->pref_list,5)))
    PLAN (d)
    ORDER BY prsnl_id
    HEAD REPORT
     stat = alterlist(rec_concat_detail_prefs->qual,100), prsnlcnt = 0
    HEAD prsnl_id
     prsnlcnt += 1
     IF (prsnlcnt > 100
      AND mod(prsnlcnt,100)=1)
      stat = alterlist(rec_concat_detail_prefs->qual,(prsnlcnt+ 99))
     ENDIF
     stat = initrec(temprec), idx = 0, detail_pvc_values = " "
    DETAIL
     tempstr = rec_detail_prefs->pref_list[d.seq].pvc_value, detail_pvc_values = concat(
      detail_pvc_values,tempstr)
     IF (size(tempstr)=254
      AND substring(253,254,tempstr)=",")
      row + 0
     ELSEIF (size(tempstr) < 254)
      detail_pvc_values = concat(detail_pvc_values,",")
     ENDIF
    FOOT  prsnl_id
     rec_concat_detail_prefs->qual[prsnlcnt].prsnl_id = prsnl_id, rec_concat_detail_prefs->qual[
     prsnlcnt].position_cd = rec_detail_prefs->pref_list[d.seq].position_cd, detail_pvc_values =
     substring(1,(size(detail_pvc_values) - 1),detail_pvc_values)
     IF (findstring(",",detail_pvc_values) > 0)
      CALL arraysplitbydelimiter(detail_pvc_values,",",temprec)
     ELSE
      stat = alterlist(temprec->qual,1), temprec->qual[1].str = detail_pvc_values
     ENDIF
     stat = alterlist(rec_concat_detail_prefs->qual[prsnlcnt].pvc_list,size(temprec->qual,5))
     FOR (i = 1 TO size(temprec->qual,5))
      rec_concat_detail_prefs->qual[prsnlcnt].pvc_list[i].pvc_name = rec_detail_prefs->pref_list[d
      .seq].pvc_name,rec_concat_detail_prefs->qual[prsnlcnt].pvc_list[i].pvc_value = temprec->qual[i]
      .str
     ENDFOR
    FOOT REPORT
     stat = alterlist(rec_concat_detail_prefs->qual,prsnlcnt)
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to concat the detail prefs: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE (constructnewappprefs(app_number=i4,pvc_name=vc) =null)
  SELECT INTO "nl:"
   prsnl_id = rec_concat_detail_prefs->qual[d1.seq].prsnl_id, pvc_value = cnvtreal(
    rec_concat_detail_prefs->qual[d1.seq].pvc_list[d2.seq].pvc_value)
   FROM (dummyt d1  WITH seq = value(size(rec_concat_detail_prefs->qual,5))),
    (dummyt d2  WITH seq = value(1))
   PLAN (d1
    WHERE maxrec(d2,size(rec_concat_detail_prefs->qual[d1.seq].pvc_list,5)))
    JOIN (d2)
   ORDER BY prsnl_id, pvc_value
   HEAD REPORT
    stat = alterlist(rec_app_prefs->qual,100), prsnlcnt = 0
   HEAD prsnl_id
    nvcnt = 0, app_pvc_value_unique = " "
   HEAD pvc_value
    temp_pvc_value = cnvtstring(pvc_value), app_pvc_value_unique = concat(app_pvc_value_unique,
     temp_pvc_value,",")
   FOOT  prsnl_id
    app_pvc_value_unique = substring(1,(size(app_pvc_value_unique) - 1),app_pvc_value_unique), len =
    size(app_pvc_value_unique)
    IF (len < 255)
     nvcnt += 1, prsnlcnt += 1
     IF (prsnlcnt > 100
      AND mod(prsnlcnt,100)=1)
      stat = alterlist(rec_app_prefs->qual,(prsnlcnt+ 99))
     ENDIF
     rec_app_prefs->qual[prsnlcnt].application_number = app_number, rec_app_prefs->qual[prsnlcnt].
     prsnl_id = prsnl_id, rec_app_prefs->qual[prsnlcnt].position_cd = rec_concat_detail_prefs->qual[
     d1.seq].position_cd,
     rec_app_prefs->qual[prsnlcnt].nv[1].pvc_name = pvc_name, rec_app_prefs->qual[prsnlcnt].nv[1].
     pvc_value = app_pvc_value_unique
    ELSE
     FOR (i = 1 TO len)
       nvcnt += 1, prsnlcnt += 1
       IF (prsnlcnt > 100
        AND mod(prsnlcnt,100)=1)
        stat = alterlist(rec_app_prefs->qual,(prsnlcnt+ 99))
       ENDIF
       rec_app_prefs->qual[prsnlcnt].application_number = app_number, rec_app_prefs->qual[prsnlcnt].
       prsnl_id = prsnl_id, rec_app_prefs->qual[prsnlcnt].position_cd = rec_concat_detail_prefs->
       qual[d1.seq].position_cd,
       rec_app_prefs->qual[prsnlcnt].nv[1].pvc_name = concat(pvc_name,cnvtstring(nvcnt)),
       rec_app_prefs->qual[prsnlcnt].nv[1].pvc_value = substring(i,(i+ 254),app_pvc_value_unique)
       IF (((i+ 254) < len))
        i += 254
       ELSE
        i = len
       ENDIF
     ENDFOR
    ENDIF
    prsnlcnt += 1
    IF (prsnlcnt > 100
     AND mod(prsnlcnt,100)=1)
     stat = alterlist(rec_app_prefs->qual,(prsnlcnt+ 99))
    ENDIF
    rec_app_prefs->qual[prsnlcnt].application_number = app_number, rec_app_prefs->qual[prsnlcnt].
    prsnl_id = prsnl_id, rec_app_prefs->qual[prsnlcnt].position_cd = rec_concat_detail_prefs->qual[d1
    .seq].position_cd
    IF (pvc_name=pref_dd_default_endorsers)
     rec_app_prefs->qual[prsnlcnt].nv[1].pvc_name = pref_dd_num_default_endorsers
    ELSEIF (pvc_name=pref_dd_fav_endorsers)
     rec_app_prefs->qual[prsnlcnt].nv[1].pvc_name = pref_dd_num_fav_endorsers
    ELSEIF (pvc_name=pref_dd_recent_endorsers)
     rec_app_prefs->qual[prsnlcnt].nv[1].pvc_name = pref_dd_num_recent_endorsers
    ENDIF
    rec_app_prefs->qual[prsnlcnt].nv[1].pvc_value = cnvtstring(nvcnt)
   FOOT REPORT
    stat = alterlist(rec_app_prefs->qual,prsnlcnt)
   WITH nocounter
  ;end select
  IF (error(errmsg,0) > 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to construct the new app prefs: ",errmsg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE insertappprefs(null)
  SET prsnlcnt = size(rec_app_prefs->qual,5)
  FOR (i = 1 TO prsnlcnt)
    SET stat = initrec(rec_app_prefs_req)
    SET stat = initrec(rec_app_prefs_rep)
    SET rec_app_prefs_req->application_number = rec_app_prefs->qual[i].application_number
    SET rec_app_prefs_req->position_cd = rec_app_prefs->qual[i].position_cd
    SET rec_app_prefs_req->prsnl_id = rec_app_prefs->qual[i].prsnl_id
    SET stat = alterlist(rec_app_prefs_req->nv,1)
    SET rec_app_prefs_req->nv[1].pvc_name = rec_app_prefs->qual[i].nv[1].pvc_name
    SET rec_app_prefs_req->nv[1].pvc_value = rec_app_prefs->qual[i].nv[1].pvc_value
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
   SELECT
    IF (pvc_name=pref_dd_default_endorsers)
     PLAN (nvp
      WHERE nvp.active_ind=1
       AND nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.pvc_name IN ("DD_DEFAULT_ENDORSERS*", pref_dd_num_default_endorsers))
      JOIN (dp
      WHERE dp.application_number=app_number
       AND dp.detail_prefs_id=nvp.parent_entity_id)
    ELSEIF (pvc_name=pref_dd_fav_endorsers)
     PLAN (nvp
      WHERE nvp.active_ind=1
       AND nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.pvc_name IN ("DD_FAV_ENDORSERS*", pref_dd_num_fav_endorsers))
      JOIN (dp
      WHERE dp.application_number=app_number
       AND dp.detail_prefs_id=nvp.parent_entity_id)
    ELSEIF (pvc_name=pref_dd_recent_endorsers)
     PLAN (nvp
      WHERE nvp.active_ind=1
       AND nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.pvc_name IN ("DD_RECENT_ENDORSERS*", pref_dd_num_recent_endorsers))
      JOIN (dp
      WHERE dp.application_number=app_number
       AND dp.detail_prefs_id=nvp.parent_entity_id)
    ELSE
    ENDIF
    INTO "nl:"
    FROM name_value_prefs nvp,
     detail_prefs dp
    PLAN (nvp
     WHERE nvp.name_value_prefs_id != 0.0
      AND nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.pvc_name IN ("DD_DEFAULT_ENDORSERS*", pref_dd_num_default_endorsers,
     "DD_FAV_ENDORSERS*", pref_dd_num_fav_endorsers, "DD_RECENT_ENDORSERS*",
     pref_dd_num_recent_endorsers))
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
 SUBROUTINE (arraysplitbydelimiter(detail_pvc_values=vc,delimiter=c1,temprec=vc(ref)) =null)
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE detail_pvc_value = vc WITH noconstant(" "), protect
   SET stat = alterlist(temprec->qual,10)
   WHILE (detail_pvc_value != "NotFound")
     SET idx += 1
     IF (mod(idx,10)=1
      AND idx != 1)
      SET stat = alterlist(temprec->qual,(idx+ 9))
     ENDIF
     SET detail_pvc_value = piece(detail_pvc_values,delimiter,idx,"NotFound")
     IF (detail_pvc_value != "NotFound")
      SET temprec->qual[idx].str = detail_pvc_value
     ELSE
      SET stat = alterlist(temprec->qual,(idx - 1))
     ENDIF
   ENDWHILE
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
