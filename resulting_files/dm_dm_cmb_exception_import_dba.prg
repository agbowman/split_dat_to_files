CREATE PROGRAM dm_dm_cmb_exception_import:dba
 RECORD request(
   1 operation_type = c20
   1 parent_entity = c32
   1 child_entity = c32
   1 script_name = c50
   1 single_encntr_ind = i2
   1 script_run_order = i4
   1 del_chg_id_ind = i2
   1 delete_row_ind = i2
 )
 SET nbr = size(requestin->list_0,5)
 SET i = 0
 FOR (i = 1 TO nbr)
   SET request->operation_type = requestin->list_0[i].operation_type
   SET request->parent_entity = requestin->list_0[i].parent_entity
   SET request->child_entity = requestin->list_0[i].child_entity
   SET request->script_name = requestin->list_0[i].script_name
   SET request->single_encntr_ind = cnvtint(requestin->list_0[i].single_encntr_ind)
   IF (cnvtint(requestin->list_0[i].script_run_order)=0)
    SET request->script_run_order = 1
   ELSE
    SET request->script_run_order = cnvtint(requestin->list_0[i].script_run_order)
   ENDIF
   SET request->del_chg_id_ind = cnvtint(requestin->list_0[i].del_chg_id_ind)
   SET request->delete_row_ind = cnvtint(requestin->list_0[i].delete_row_ind)
   EXECUTE dm_dm_cmb_exception
 ENDFOR
END GO
