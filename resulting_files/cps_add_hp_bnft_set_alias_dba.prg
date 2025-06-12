CREATE PROGRAM cps_add_hp_bnft_set_alias:dba
 SET false = 0
 SET true = 1
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET replace_error = 6
 SET delete_error = 7
 SET undelete_error = 8
 SET remove_error = 9
 SET attribute_error = 10
 SET lock_error = 11
 SET none_found = 12
 SET select_error = 13
 SET failed = false
 SET table_name = fillstring(50," ")
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 hp_bnft_set_alias_qual = i2
    1 hp_bnft_set_alias[10]
      2 bnft_set_alias_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->hp_bnft_set_alias_qual
  SET reply->hp_bnft_set_alias_qual = request->hp_bnft_set_alias_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "HP_BNFT_SET_ALIAS"
 CALL add_hp_bnft_set_alias(action_begin,action_end)
 IF (failed != false)
  GO TO check_error
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
 GO TO end_program
 SUBROUTINE add_hp_bnft_set_alias(add_begin,add_end)
   FOR (x = add_begin TO add_end)
     SET active_code = 0.0
     IF ((request->hp_bnft_set_alias[x].active_status_cd=0))
      SELECT INTO "nl:"
       FROM code_value c
       WHERE c.code_set=48
        AND c.cdf_meaning="ACTIVE"
       DETAIL
        active_code = c.code_value
       WITH nocounter
      ;end select
     ENDIF
     SET data_status_code = 0
     IF ((request->hp_bnft_set_alias[x].data_status_cd=0))
      SELECT INTO "nl:"
       FROM code_value c
       WHERE c.code_set=8
        AND c.cdf_meaning="UNAUTH"
       DETAIL
        data_status_code = c.code_value
       WITH nocounter
      ;end select
     ENDIF
     SET new_nbr = 0
     SELECT INTO "nl:"
      y = seq(health_plan_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_nbr = cnvtreal(y)
      WITH format, counter
     ;end select
     IF (curqual=0)
      SET failed = gen_nbr_error
      RETURN
     ELSE
      SET request->hp_bnft_set_alias[x].bnft_set_alias_id = new_nbr
     ENDIF
     INSERT  FROM hp_bnft_set_alias h
      SET h.bnft_set_alias_id = new_nbr, h.hp_bnft_set_id =
       IF ((request->hp_bnft_set_alias[x].hp_bnft_set_id=0)) 0
       ELSE request->hp_bnft_set_alias[x].hp_bnft_set_id
       ENDIF
       , h.alias = request->hp_bnft_set_alias[x].alias,
       h.contributor_system_cd =
       IF ((request->hp_bnft_set_alias[x].contributor_system_cd=0)) 0
       ELSE request->hp_bnft_set_alias[x].contributor_system_cd
       ENDIF
       , h.data_status_cd =
       IF ((request->hp_bnft_set_alias[x].data_status_cd=0)) data_status_code
       ELSE request->hp_bnft_set_alias[x].data_status_cd
       ENDIF
       , h.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
       h.data_status_prsnl_id = reqinfo->updt_id, h.beg_effective_dt_tm =
       IF ((request->hp_bnft_set_alias[x].beg_effective_dt_tm <= 0)) cnvtdatetime(curdate,curtime3)
       ELSE cnvtdatetime(request->hp_bnft_set_alias[x].beg_effective_dt_tm)
       ENDIF
       , h.end_effective_dt_tm =
       IF ((request->hp_bnft_set_alias[x].end_effective_dt_tm <= 0)) cnvtdatetime(
         "31-DEC-2100 00:00:00.00")
       ELSE cnvtdatetime(request->hp_bnft_set_alias[x].end_effective_dt_tm)
       ENDIF
       ,
       h.active_ind =
       IF ((request->hp_bnft_set_alias[x].active_ind_ind=false)) true
       ELSE request->hp_bnft_set_alias[x].active_ind
       ENDIF
       , h.active_status_cd =
       IF ((request->hp_bnft_set_alias[x].active_status_cd=0)) active_code
       ELSE request->hp_bnft_set_alias[x].active_status_cd
       ENDIF
       , h.active_status_prsnl_id = reqinfo->updt_id,
       h.active_status_dt_tm = cnvtdatetime(curdate,curtime3), h.updt_cnt = 0, h.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       h.updt_id = reqinfo->updt_id, h.updt_applctx = reqinfo->updt_applctx, h.updt_task = reqinfo->
       updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = insert_error
      RETURN
     ELSE
      SET reply->hp_bnft_set_alias[x].bnft_set_alias_id = request->hp_bnft_set_alias[x].
      bnft_set_alias_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
