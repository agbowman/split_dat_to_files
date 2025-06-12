CREATE PROGRAM cps_ens_hp_providers:dba
 RECORD reply(
   1 providers[*]
     2 network_id = f8
     2 provider_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 cps_error
     2 cnt = i4
     2 data[*]
       3 code = i4
       3 severity_level = i4
       3 supp_err_txt = c32
       3 def_msg = vc
       3 row_data
         4 lvl_1_idx = i4
         4 lvl_2_idx = i4
         4 lvl_3_idx = i4
 )
 SET cps_lock = 100
 SET cps_no_seq = 101
 SET cps_updt_cnt = 102
 SET cps_insuf_data = 103
 SET cps_update = 104
 SET cps_insert = 105
 SET cps_delete = 106
 SET cps_select = 107
 SET cps_auth = 108
 SET cps_inval_data = 109
 SET cps_lock_msg = "Failed to lock all requested rows"
 SET cps_no_seq_msg = "Failed to get next sequence number"
 SET cps_updt_cnt_msg = "Failed to match update count"
 SET cps_insuf_data_msg = "Request did not supply sufficient data"
 SET cps_update_msg = "Failed on update request"
 SET cps_insert_msg = "Failed on insert request"
 SET cps_delete_msg = "Failed on delete request"
 SET cps_select_msg = "Failed on select request"
 SET cps_auth_msg = "Failed on authorization of request"
 SET cps_inval_data_msg = "Request contained some invalid data"
 SET cps_success = 0
 SET cps_success_info = 1
 SET cps_success_warn = 2
 SET cps_deadlock = 3
 SET cps_script_fail = 4
 SET cps_sys_fail = 5
 SET reply->status_data.status = "F"
 SET number_of_actions = size(request->providers,5)
 SET stat = alterlist(reply->providers,number_of_actions)
 SET failed = 0
 SET active_code = 0.0
 SET specialty_code = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=48
   AND c.cdf_meaning="ACTIVE"
  DETAIL
   active_code = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = 1
  CALL cps_add_error(cps_select,cps_script_fail,"Getting ACTIVE status code",cps_select_msg,0,
   0,0)
  GO TO exit_script
 ENDIF
 FOR (inx0 = 1 TO number_of_actions)
   CASE (request->providers[inx0].action_type)
    OF "ADD":
     EXECUTE cps_add_hp_providers
    OF "UPT":
     EXECUTE cps_upt_hp_providers
    ELSE
     CALL cps_add_error(cps_inval_data,cps_success_warn,"Invalid ACTION_CODE rcvd",cps_inval_data_msg,
      inx0,
      0,0)
   ENDCASE
 ENDFOR
#exit_script
 IF (failed=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 SUBROUTINE cps_add_error(cps_errcode,severity_level,supp_err_txt,def_msg,idx1,idx2,idx3)
   SET reply->cps_error.cnt = (reply->cps_error.cnt+ 1)
   SET errcnt = reply->cps_error.cnt
   SET stat = alterlist(reply->cps_error.data,errcnt)
   SET reply->cps_error.data[errcnt].code = cps_errcode
   SET reply->cps_error.data[errcnt].severity_level = severity_level
   SET reply->cps_error.data[errcnt].supp_err_txt = supp_err_txt
   SET reply->cps_error.data[errcnt].def_msg = def_msg
   SET reply->cps_error.data[errcnt].row_data.lvl_1_idx = idx1
   SET reply->cps_error.data[errcnt].row_data.lvl_2_idx = idx2
   SET reply->cps_error.data[errcnt].row_data.lvl_3_idx = idx3
 END ;Subroutine
END GO
