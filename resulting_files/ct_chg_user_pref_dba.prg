CREATE PROGRAM ct_chg_user_pref:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD insertprefs(
   1 prsnls[*]
     2 prsnl_id = f8
     2 preference_shared = i2
 )
 RECORD updateprefs(
   1 prsnls[*]
     2 prsnl_id = f8
     2 preference_shared = i2
 )
 RECORD prsnlslist_request(
   1 prsnls[*]
     2 prsnl_id = f8
     2 functionality_type = i2
     2 prot_id = f8
 )
 RECORD prsnlslist(
   1 qual[*]
     2 prsnl_id = f8
     2 functionality_type = i2
     2 preference_shared = i2
     2 preference_txt = vc
     2 facilities[*]
       3 facility_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE share_list_cnt = i4 WITH protect, noconstant(0)
 DECLARE prsnl_found = i2 WITH protect, noconstant(0)
 DECLARE qual_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE idx_inner = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE add_cnt = i4 WITH protect, noconstant(0)
 DECLARE update_cnt = i4 WITH protect, noconstant(0)
 DECLARE ct_preference_id = f8 WITH protect, noconstant(0)
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE fac_group_id = f8 WITH protect, noconstant(0)
 DECLARE fac_size = i4 WITH protect, noconstant(0)
 DECLARE ct_fac_cd_group_id = f8 WITH protect, noconstant(0)
 DECLARE insert_error = i2 WITH private, constant(20)
 DECLARE update_error = i2 WITH private, constant(30)
 DECLARE retrieve_pref_error = i2 WITH private, constant(40)
 SET reply->status_data.status = "F"
 SET share_list_cnt = size(request->share_list,5)
 SET stat = alterlist(prsnlslist_request->prsnls,(share_list_cnt+ 1))
 SET prsnlslist_request->prsnls[1].prsnl_id = request->prsnl_id
 SET prsnlslist_request->prsnls[1].functionality_type = request->functionality_type
 SET prsnlslist_request->prsnls[1].prot_id = request->prot_id
 SET cnt = 2
 FOR (idx = 1 TO share_list_cnt)
   SET prsnlslist_request->prsnls[cnt].prsnl_id = request->share_list[idx].prsnl_id
   SET prsnlslist_request->prsnls[cnt].functionality_type = request->functionality_type
   SET prsnlslist_request->prsnls[cnt].prot_id = request->prot_id
   SET cnt += 1
 ENDFOR
 EXECUTE ct_get_users_pref  WITH replace("REQUEST","PRSNLSLIST_REQUEST"), replace("REPLY",
  "PRSNLSLIST")
 IF ((prsnlslist->status_data.status="F"))
  SET fail_flag = retrieve_pref_error
  GO TO check_error
 ENDIF
 SET qual_cnt = size(prsnlslist->qual,5)
 SET stat = alterlist(insertprefs->prsnls,10)
 SET stat = alterlist(updateprefs->prsnls,10)
 FOR (idx = 1 TO qual_cnt)
   IF ((request->prsnl_id=prsnlslist->qual[idx].prsnl_id))
    SET updateprefs->prsnls[1].prsnl_id = request->prsnl_id
    SET updateprefs->prsnls[1].preference_shared = 0
    SET update_cnt += 1
    SET prsnl_found = 1
    SET idx = qual_cnt
   ENDIF
 ENDFOR
 IF (prsnl_found=0)
  SET insertprefs->prsnls[1].prsnl_id = request->prsnl_id
  SET insertprefs->prsnls[1].preference_shared = 0
  SET add_cnt += 1
 ENDIF
 FOR (idx = 1 TO share_list_cnt)
   SET prsnl_found = 0
   FOR (idx_inner = 1 TO qual_cnt)
     IF ((request->share_list[idx].prsnl_id=prsnlslist->qual[idx_inner].prsnl_id))
      SET prsnl_found = 1
      IF ((prsnlslist->qual[idx_inner].preference_shared=1))
       SET update_cnt += 1
       IF (mod(update_cnt,10)=1)
        SET stat = alterlist(updateprefs->prsnls,(update_cnt+ 9))
       ENDIF
       SET updateprefs->prsnls[update_cnt].prsnl_id = prsnlslist->qual[idx_inner].prsnl_id
       SET updateprefs->prsnls[update_cnt].preference_shared = 1
      ENDIF
      SET idx_inner = qual_cnt
     ENDIF
   ENDFOR
   IF (prsnl_found=0)
    SET add_cnt += 1
    IF (mod(add_cnt,10)=1)
     SET stat = alterlist(insertprefs->prsnls,(add_cnt+ 9))
    ENDIF
    SET insertprefs->prsnls[add_cnt].prsnl_id = request->share_list[idx].prsnl_id
    SET insertprefs->prsnls[add_cnt].preference_shared = 1
   ENDIF
 ENDFOR
 SET stat = alterlist(insertprefs->prsnls,add_cnt)
 SET stat = alterlist(updateprefs->prsnls,update_cnt)
 CALL echorecord(insertprefs)
 CALL echorecord(updateprefs)
 SUBROUTINE (nextsequence(x=i2) =f8)
   DECLARE nsequence = f8 WITH protect
   SELECT INTO "nl:"
    nextseqnum = seq(protocol_def_seq,nextval)
    FROM dual
    DETAIL
     nsequence = nextseqnum
    WITH nocounter
   ;end select
   RETURN(nsequence)
 END ;Subroutine
 SET fac_size = size(request->facility_list,5)
 IF (fac_size=1
  AND (request->facility_list[1].facility_cd=0))
  SET fac_group_id = 0
 ELSE
  SET fac_group_id = nextsequence(0)
  SET ct_fac_cd_group_id = fac_group_id
  FOR (idx = 1 TO fac_size)
    IF (idx != 1)
     SET ct_fac_cd_group_id = nextsequence(0)
    ENDIF
    INSERT  FROM ct_facility_cd_group cfcg
     SET cfcg.ct_facility_cd_group_id = ct_fac_cd_group_id, cfcg.facility_group_id = fac_group_id,
      cfcg.facility_cd = request->facility_list[idx].facility_cd,
      cfcg.updt_dt_tm = cnvtdatetime(sysdate), cfcg.updt_id = reqinfo->updt_id, cfcg.updt_task =
      reqinfo->updt_task,
      cfcg.updt_applctx = reqinfo->updt_applctx, cfcg.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error inserting facility_cd to ct_facility_cd_group."
     SET fail_flag = insert_error
     GO TO check_error
    ENDIF
  ENDFOR
 ENDIF
 FOR (idx = 1 TO add_cnt)
   SET ct_preference_id = nextsequence(0)
   INSERT  FROM ct_user_preference cup
    SET cup.ct_user_preference_id = ct_preference_id, cup.prsnl_id = insertprefs->prsnls[idx].
     prsnl_id, cup.preference_text = request->preference_txt,
     cup.functionality_type_flag = request->functionality_type, cup.preference_status_flag =
     insertprefs->prsnls[idx].preference_shared, cup.prot_master_id = request->prot_id,
     cup.ct_facility_cd_group_id = fac_group_id, cup.active_ind = 1, cup.updt_dt_tm = cnvtdatetime(
      sysdate),
     cup.updt_id = reqinfo->updt_id, cup.updt_task = reqinfo->updt_task, cup.updt_applctx = reqinfo->
     updt_applctx,
     cup.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error inserting new prsnl into ct_user_preference."
    SET fail_flag = insert_error
    GO TO check_error
   ENDIF
 ENDFOR
 FOR (idx = 1 TO update_cnt)
  UPDATE  FROM ct_user_preference cup
   SET cup.preference_text = request->preference_txt, cup.preference_status_flag = updateprefs->
    prsnls[idx].preference_shared, cup.ct_facility_cd_group_id = fac_group_id,
    cup.updt_dt_tm = cnvtdatetime(sysdate), cup.updt_id = reqinfo->updt_id, cup.updt_cnt = (cup
    .updt_cnt+ 1)
   WHERE (cup.prsnl_id=updateprefs->prsnls[idx].prsnl_id)
    AND (cup.functionality_type_flag=request->functionality_type)
    AND (cup.prot_master_id=request->prot_id)
    AND cup.active_ind=1
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error updating into ct_user_preference table."
   SET fail_flag = update_error
   GO TO check_error
  ENDIF
 ENDFOR
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ELSE
  CASE (fail_flag)
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "I"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "U"
   OF retrieve_pref_error:
    SET reply->status_data.subeventstatus[1].operationname = "RETRIEVE"
    SET reply->status_data.subeventstatus[1].operationstatus = "R"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unknown error."
    SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  ENDCASE
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 SET last_mod = "000"
 SET mod_date = "June 14, 2018"
END GO
