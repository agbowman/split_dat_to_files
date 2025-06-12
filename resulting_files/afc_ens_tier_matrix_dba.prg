CREATE PROGRAM afc_ens_tier_matrix:dba
 FREE SET addrequest
 RECORD addrequest(
   1 tier_matrix_qual = i4
   1 tier_matrix[*]
     2 action_type = c3
     2 tier_cell_id = f8
     2 tier_group_cd = f8
     2 tier_col_num = i4
     2 tier_row_num = i4
     2 tier_cell_type_cd = f8
     2 tier_cell_value_ind = i2
     2 tier_cell_value = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 tier_cell_string = c50
 )
 RECORD uptrequest(
   1 tier_matrix_qual = i4
   1 tier_matrix[*]
     2 action_type = c3
     2 tier_cell_id = f8
     2 tier_group_cd = f8
     2 tier_col_num = i4
     2 tier_row_num = i4
     2 tier_cell_type_cd = f8
     2 tier_cell_value_ind = i2
     2 tier_cell_value = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 tier_cell_string = c50
 )
 RECORD delrequest(
   1 tier_matrix_qual = i4
   1 tier_matrix[*]
     2 action_type = c3
     2 tier_cell_id = f8
     2 tier_group_cd = f8
     2 tier_col_num = i4
     2 tier_row_num = i4
     2 tier_cell_type_cd = f8
     2 tier_cell_value_ind = i2
     2 tier_cell_value = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 tier_cell_string = c50
 )
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
 RECORD reply(
   1 tier_matrix_qual = i4
   1 tier_matrix[*]
     2 tier_cell_id = f8
     2 tier_col_num = i4
     2 tier_row_num = i4
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET hafc_ens_tier_matrix = 0
 SET istatus = 0
 SET serrmsg = fillstring(132," ")
 SET reply->status_data.status = "F"
 SET table_name = "TIER_MATRIX"
 IF ((request->tier_matrix_qual > 0))
  FOR (inx0 = 1 TO request->tier_matrix_qual)
    CASE (request->tier_matrix[inx0].action_type)
     OF "ADD":
      SET stat = alterlist(addrequest->tier_matrix,(addrequest->tier_matrix_qual+ 1))
      SET addrequest->tier_matrix_qual = (addrequest->tier_matrix_qual+ 1)
      SET addrequest->tier_matrix[addrequest->tier_matrix_qual].action_type = request->tier_matrix[
      inx0].action_type
      SET addrequest->tier_matrix[addrequest->tier_matrix_qual].tier_cell_id = request->tier_matrix[
      inx0].tier_cell_id
      SET addrequest->tier_matrix[addrequest->tier_matrix_qual].tier_group_cd = request->tier_matrix[
      inx0].tier_group_cd
      SET addrequest->tier_matrix[addrequest->tier_matrix_qual].tier_col_num = request->tier_matrix[
      inx0].tier_col_num
      SET addrequest->tier_matrix[addrequest->tier_matrix_qual].tier_row_num = request->tier_matrix[
      inx0].tier_row_num
      SET addrequest->tier_matrix[addrequest->tier_matrix_qual].tier_cell_type_cd = request->
      tier_matrix[inx0].tier_cell_type_cd
      SET addrequest->tier_matrix[addrequest->tier_matrix_qual].tier_cell_value_ind = request->
      tier_matrix[inx0].tier_cell_value_ind
      SET addrequest->tier_matrix[addrequest->tier_matrix_qual].tier_cell_value = request->
      tier_matrix[inx0].tier_cell_value
      SET addrequest->tier_matrix[addrequest->tier_matrix_qual].active_ind_ind = request->
      tier_matrix[inx0].active_ind_ind
      SET addrequest->tier_matrix[addrequest->tier_matrix_qual].active_ind = request->tier_matrix[
      inx0].active_ind
      SET addrequest->tier_matrix[addrequest->tier_matrix_qual].active_status_cd = request->
      tier_matrix[inx0].active_status_cd
      SET addrequest->tier_matrix[addrequest->tier_matrix_qual].active_status_dt_tm = request->
      tier_matrix[inx0].active_status_dt_tm
      SET addrequest->tier_matrix[addrequest->tier_matrix_qual].active_status_prsnl_id = request->
      tier_matrix[inx0].active_status_prsnl_id
      SET addrequest->tier_matrix[addrequest->tier_matrix_qual].beg_effective_dt_tm = request->
      tier_matrix[inx0].beg_effective_dt_tm
      SET addrequest->tier_matrix[addrequest->tier_matrix_qual].end_effective_dt_tm = request->
      tier_matrix[inx0].end_effective_dt_tm
      SET addrequest->tier_matrix[addrequest->tier_matrix_qual].tier_cell_string = request->
      tier_matrix[inx0].tier_cell_string
     OF "UPT":
      SET stat = alterlist(uptrequest->tier_matrix,(uptrequest->tier_matrix_qual+ 1))
      SET uptrequest->tier_matrix_qual = (uptrequest->tier_matrix_qual+ 1)
      SET uptrequest->tier_matrix[uptrequest->tier_matrix_qual].action_type = request->tier_matrix[
      inx0].action_type
      SET uptrequest->tier_matrix[uptrequest->tier_matrix_qual].tier_cell_id = request->tier_matrix[
      inx0].tier_cell_id
      SET uptrequest->tier_matrix[uptrequest->tier_matrix_qual].tier_group_cd = request->tier_matrix[
      inx0].tier_group_cd
      SET uptrequest->tier_matrix[uptrequest->tier_matrix_qual].tier_col_num = request->tier_matrix[
      inx0].tier_col_num
      SET uptrequest->tier_matrix[uptrequest->tier_matrix_qual].tier_row_num = request->tier_matrix[
      inx0].tier_row_num
      SET uptrequest->tier_matrix[uptrequest->tier_matrix_qual].tier_cell_type_cd = request->
      tier_matrix[inx0].tier_cell_type_cd
      SET uptrequest->tier_matrix[uptrequest->tier_matrix_qual].tier_cell_value_ind = request->
      tier_matrix[inx0].tier_cell_value_ind
      SET uptrequest->tier_matrix[uptrequest->tier_matrix_qual].tier_cell_value = request->
      tier_matrix[inx0].tier_cell_value
      SET uptrequest->tier_matrix[uptrequest->tier_matrix_qual].active_ind_ind = request->
      tier_matrix[inx0].active_ind_ind
      SET uptrequest->tier_matrix[uptrequest->tier_matrix_qual].active_ind = request->tier_matrix[
      inx0].active_ind
      SET uptrequest->tier_matrix[uptrequest->tier_matrix_qual].active_status_cd = request->
      tier_matrix[inx0].active_status_cd
      SET uptrequest->tier_matrix[uptrequest->tier_matrix_qual].active_status_dt_tm = request->
      tier_matrix[inx0].active_status_dt_tm
      SET uptrequest->tier_matrix[uptrequest->tier_matrix_qual].active_status_prsnl_id = request->
      tier_matrix[inx0].active_status_prsnl_id
      SET uptrequest->tier_matrix[uptrequest->tier_matrix_qual].beg_effective_dt_tm = request->
      tier_matrix[inx0].beg_effective_dt_tm
      SET uptrequest->tier_matrix[uptrequest->tier_matrix_qual].end_effective_dt_tm = request->
      tier_matrix[inx0].end_effective_dt_tm
      SET uptrequest->tier_matrix[uptrequest->tier_matrix_qual].tier_cell_string = request->
      tier_matrix[inx0].tier_cell_string
     OF "DEL":
      SET stat = alterlist(delrequest->tier_matrix,(delrequest->tier_matrix_qual+ 1))
      SET delrequest->tier_matrix_qual = (delrequest->tier_matrix_qual+ 1)
      SET delrequest->tier_matrix[delrequest->tier_matrix_qual].action_type = request->tier_matrix[
      inx0].action_type
      SET delrequest->tier_matrix[delrequest->tier_matrix_qual].tier_cell_id = request->tier_matrix[
      inx0].tier_cell_id
      SET delrequest->tier_matrix[delrequest->tier_matrix_qual].tier_group_cd = request->tier_matrix[
      inx0].tier_group_cd
      SET delrequest->tier_matrix[delrequest->tier_matrix_qual].tier_col_num = request->tier_matrix[
      inx0].tier_col_num
      SET delrequest->tier_matrix[delrequest->tier_matrix_qual].tier_row_num = request->tier_matrix[
      inx0].tier_row_num
      SET delrequest->tier_matrix[delrequest->tier_matrix_qual].tier_cell_type_cd = request->
      tier_matrix[inx0].tier_cell_type_cd
      SET delrequest->tier_matrix[delrequest->tier_matrix_qual].tier_cell_value_ind = request->
      tier_matrix[inx0].tier_cell_value_ind
      SET delrequest->tier_matrix[delrequest->tier_matrix_qual].tier_cell_value = request->
      tier_matrix[inx0].tier_cell_value
      SET delrequest->tier_matrix[delrequest->tier_matrix_qual].active_ind_ind = request->
      tier_matrix[inx0].active_ind_ind
      SET delrequest->tier_matrix[delrequest->tier_matrix_qual].active_ind = request->tier_matrix[
      inx0].active_ind
      SET delrequest->tier_matrix[delrequest->tier_matrix_qual].active_status_cd = request->
      tier_matrix[inx0].active_status_cd
      SET delrequest->tier_matrix[delrequest->tier_matrix_qual].active_status_dt_tm = request->
      tier_matrix[inx0].active_status_dt_tm
      SET delrequest->tier_matrix[delrequest->tier_matrix_qual].active_status_prsnl_id = request->
      tier_matrix[inx0].active_status_prsnl_id
      SET delrequest->tier_matrix[delrequest->tier_matrix_qual].beg_effective_dt_tm = request->
      tier_matrix[inx0].beg_effective_dt_tm
      SET delrequest->tier_matrix[delrequest->tier_matrix_qual].end_effective_dt_tm = request->
      tier_matrix[inx0].end_effective_dt_tm
      SET delrequest->tier_matrix[delrequest->tier_matrix_qual].tier_cell_string = request->
      tier_matrix[inx0].tier_cell_string
     ELSE
      SET failed = true
      GO TO check_error
    ENDCASE
  ENDFOR
  IF ((addrequest->tier_matrix_qual > 0))
   SET action_begin = 1
   SET action_end = addrequest->tier_matrix_qual
   CALL echorecord(addrequest)
   EXECUTE afc_add_tier_matrix  WITH replace("REQUEST","ADDREQUEST")
   IF (failed != false)
    GO TO check_error
   ENDIF
  ENDIF
  IF ((uptrequest->tier_matrix_qual > 0))
   SET action_begin = 1
   SET action_end = uptrequest->tier_matrix_qual
   EXECUTE afc_upt_tier_matrix  WITH replace("REQUEST","UPTREQUEST")
   IF (failed != false)
    GO TO check_error
   ENDIF
  ENDIF
  IF ((delrequest->tier_matrix_qual > 0))
   SET action_begin = 1
   SET action_end = delrequest->tier_matrix_qual
   EXECUTE afc_del_tier_matrix  WITH replace("REQUEST","DELREQUEST")
   IF (failed != false)
    GO TO check_error
   ENDIF
  ENDIF
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
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
  SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
  SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[2].operationname = "RECEIVE"
  SET reply->status_data.subeventstatus[2].operationstatus = "S"
 ENDIF
#end_program
 FREE SET addrequest
 FREE SET uptrequest
 FREE SET delrequest
END GO
