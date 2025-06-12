CREATE PROGRAM acm_write_prsnl_role_profile_a:dba
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE table_name = vc WITH protect, noconstant(" ")
 DECLARE call_echo_ind = i2 WITH protect, noconstant(0)
 DECLARE pmhc_contributory_system_cd = f8 WITH protect, noconstant(0.0)
 FREE RECORD xref
 RECORD xref(
   1 add_cnt = i4
   1 add[*]
     2 idx = i4
   1 chg_cnt = i4
   1 chg[*]
     2 idx = i4
   1 del_cnt = i4
   1 del[*]
     2 idx = i4
   1 act_cnt = i4
   1 act[*]
     2 idx = i4
     2 active_ind = i2
 )
 SET reply->prsnl_role_profile_addn_qual_cnt = size(acm_request->prsnl_role_profile_addn_qual,5)
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE lbound = i4 WITH protect, noconstant(1)
 DECLARE ubound = i4 WITH protect, noconstant(reply->prsnl_role_profile_addn_qual_cnt)
 SET stat = alterlist(reply->prsnl_role_profile_addn_qual,reply->prsnl_role_profile_addn_qual_cnt)
 IF (validate(acm_request_bounds,"-99") != "-99")
  SET lbound = acm_request_bounds->lbound
  SET ubound = acm_request_bounds->ubound
 ENDIF
 FOR (index = lbound TO ubound)
   CASE (acm_request->prsnl_role_profile_addn_qual[index].action_flag)
    OF add_action:
     SET xref->add_cnt = (xref->add_cnt+ 1)
     SET stat = alterlist(xref->add,xref->add_cnt)
     SET xref->add[xref->add_cnt].idx = index
    OF chg_action:
     SET xref->chg_cnt = (xref->chg_cnt+ 1)
     SET stat = alterlist(xref->chg,xref->chg_cnt)
     SET xref->chg[xref->chg_cnt].idx = index
    OF del_action:
     SET xref->del_cnt = (xref->del_cnt+ 1)
     SET stat = alterlist(xref->del,xref->del_cnt)
     SET xref->del[xref->del_cnt].idx = index
    OF act_action:
     SET xref->act_cnt = (xref->act_cnt+ 1)
     SET stat = alterlist(xref->act,xref->act_cnt)
     SET xref->act[xref->act_cnt].idx = index
     SET xref->act[xref->act_cnt].active_ind = 1
    OF ina_action:
     SET xref->act_cnt = (xref->act_cnt+ 1)
     SET stat = alterlist(xref->act,xref->act_cnt)
     SET xref->act[xref->act_cnt].idx = index
     SET xref->act[xref->act_cnt].active_ind = 0
    ELSE
     SET reply->prsnl_role_profile_addn_qual[index].prsnl_role_profile_addn_id = acm_request->
     prsnl_role_profile_addn_qual[index].prsnl_role_profile_addn_id
     SET reply->prsnl_role_profile_addn_qual[index].status = 1
     SET reply->status_data.status = "S"
   ENDCASE
 ENDFOR
 IF ((xref->del_cnt > 0))
  EXECUTE acm_del_prsnl_role_profile_addn
  IF ((reply->status_data.status="F"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((xref->act_cnt > 0))
  EXECUTE acm_act_prsnl_role_profile_addn
  IF ((reply->status_data.status="F"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((xref->chg_cnt > 0))
  EXECUTE acm_chg_prsnl_role_profile_addn
  IF ((reply->status_data.status="F"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((xref->add_cnt > 0))
  EXECUTE acm_add_prsnl_role_profile_addn
  IF ((reply->status_data.status="F"))
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
END GO
