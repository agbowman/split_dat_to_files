CREATE PROGRAM dm_chk_for_active_trigger:dba
 IF (validate(act_reply->status,"X")="X")
  FREE RECORD act_reply
  RECORD act_reply(
    1 status = c1
    1 active_trigger_ind = i2
  ) WITH persistscript
 ENDIF
 SET act_reply->status = "F"
 SET act_reply->active_trigger_ind = 0
 FREE RECORD act
 RECORD act(
   1 sch_install_ind = i2
   1 table_name = vc
   1 column_cnt = i4
   1 active_trigger_ind = i2
   1 str = vc
 )
 SET act->table_name = cnvtupper( $1)
 SET act->column_cnt = 0
 SET act->sch_install_ind = 0
 SET act->active_trigger_ind = 0
 IF (validate(tgtdb->tbl_cnt,- (1)) > 0)
  SET act->sch_install_ind = 1
 ENDIF
 IF ((act->sch_install_ind=1))
  SET atbl_idx = 0
  FOR (ati = 1 TO tgtdb->tbl_cnt)
    IF ((tgtdb->tbl[ati].tbl_name=act->table_name))
     SET atbl_idx = ati
     SET ati = tgtdb->tbl_cnt
    ENDIF
  ENDFOR
  IF (atbl_idx > 0)
   FOR (ati = 1 TO tgtdb->tbl[atbl_idx].tbl_col_cnt)
     IF ((tgtdb->tbl[atbl_idx].tbl_col[ati].col_name="ACTIVE_IND"))
      SET act->column_cnt = (act->column_cnt+ 1)
     ENDIF
     IF ((tgtdb->tbl[atbl_idx].tbl_col[ati].col_name="ACTIVE_STATUS_DT_TM")
      AND (tgtdb->tbl[atbl_idx].tbl_col[ati].data_type="DATE"))
      SET act->column_cnt = (act->column_cnt+ 1)
     ENDIF
     IF ((tgtdb->tbl[atbl_idx].tbl_col[ati].col_name="ACTIVE_STATUS_PRSNL_ID")
      AND (tgtdb->tbl[atbl_idx].tbl_col[ati].data_type IN ("NUMBER", "FLOAT")))
      SET act->column_cnt = (act->column_cnt+ 1)
     ENDIF
     IF ((tgtdb->tbl[atbl_idx].tbl_col[ati].col_name="UPDT_ID")
      AND (tgtdb->tbl[atbl_idx].tbl_col[ati].data_type IN ("NUMBER", "FLOAT")))
      SET act->column_cnt = (act->column_cnt+ 1)
     ENDIF
   ENDFOR
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM user_tab_columns u
   WHERE (u.table_name=act->table_name)
   DETAIL
    IF (u.column_name="ACTIVE_IND")
     act->column_cnt = (act->column_cnt+ 1)
    ENDIF
    IF (u.column_name="ACTIVE_STATUS_DT_TM"
     AND u.data_type="DATE")
     act->column_cnt = (act->column_cnt+ 1)
    ENDIF
    IF (u.column_name="ACTIVE_STATUS_PRSNL_ID"
     AND u.data_type IN ("NUMBER", "FLOAT"))
     act->column_cnt = (act->column_cnt+ 1)
    ENDIF
    IF (u.column_name="UPDT_ID"
     AND u.data_type IN ("NUMBER", "FLOAT"))
     act->column_cnt = (act->column_cnt+ 1)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((act->column_cnt=4))
  SET act->active_trigger_ind = 1
  SET act_reply->active_trigger_ind = 1
 ENDIF
#exit_program
 SET act_reply->status = "S"
END GO
