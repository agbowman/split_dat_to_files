CREATE PROGRAM dm_rmc_cur_state_test_wrp
 DECLARE drcs_get_func_name(dgfn_table_name,dgfn_type) = vc
 SUBROUTINE drcs_get_func_name(dgfn_table_name,dgfn_type)
   DECLARE dgfn_name_str = vc WITH protect, noconstant(" ")
   DECLARE dgfn_func_str = vc WITH protect, noconstant(" ")
   DECLARE dgfn_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgfn_str = vc WITH protect, noconstant(" ")
   DECLARE dgfn_idx = i4 WITH protect, noconstant(0)
   DECLARE dgfn_done = i2 WITH protect, noconstant(0)
   DECLARE dgfn_exist = i2 WITH protect, noconstant(0)
   DECLARE dgfn_file = vc WITH protect, noconstant(" ")
   FREE RECORD dgfn_func
   RECORD dgfn_func(
     1 func_cnt = i4
     1 qual[*]
       2 func_name = vc
       2 parm_exist_ind = i2
   )
   FREE RECORD dris_reply
   RECORD dris_reply(
     1 status = c1
     1 msg = vc
   )
   SET dm_err->eproc = concat("Determining ",dgfn_type," function for table ",dgfn_table_name)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   IF (dgfn_type="PK_WHERE")
    SET dgfn_name_str = "DM_PK_WHERE_TEMPLATE*"
   ELSEIF (dgfn_type="PTAM")
    SET dgfn_name_str = "DM_PTAM_TEMPLATE*"
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dgfn_type," is not a valid function type.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(dgfn_func_str)
   ENDIF
   SET dm_err->eproc = "Querying dm_info for current state function information."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="RDDS CURRENT STATE OBJECTS"
     AND di.info_char=dgfn_table_name
     AND di.info_name=patstring(dgfn_name_str)
    ORDER BY di.info_number
    HEAD REPORT
     dgfn_cnt = 0
    DETAIL
     dgfn_cnt = (dgfn_cnt+ 1), stat = alterlist(dgfn_func->qual,dgfn_cnt), dgfn_func->qual[dgfn_cnt].
     func_name = di.info_name,
     dgfn_func->qual[dgfn_cnt].parm_exist_ind = 1
    FOOT REPORT
     dgfn_func->func_cnt = dgfn_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(dgfn_func_str)
   ENDIF
   SET dm_err->eproc = "Checking if required parms exist."
   SELECT INTO "nl:"
    FROM dm_info di,
     (dummyt d  WITH seq = value(dgfn_func->func_cnt))
    PLAN (d)
     JOIN (di
     WHERE di.info_domain=concat("RDDS CURRENT STATE PARMS:",dgfn_func->qual[d.seq].func_name)
      AND (( NOT ( EXISTS (
     (SELECT
      "x"
      FROM user_tab_columns utc
      WHERE di.info_name=concat(utc.table_name,":",utc.column_name)
       AND utc.table_name=substring(1,(findstring(":",di.info_name) - 1),di.info_name))))) OR ( NOT (
      EXISTS (
     (SELECT
      "x"
      FROM dm_columns_doc_local dcdl
      WHERE di.info_name=concat(dcdl.table_name,":",dcdl.column_name)
       AND dcdl.table_name=substring(1,(findstring(":",di.info_name) - 1),di.info_name)))))) )
    DETAIL
     dgfn_func->qual[d.seq].parm_exist_ind = 0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(dgfn_func_str)
   ENDIF
   SET dgfn_idx = 0
   WHILE (dgfn_done=0
    AND (dgfn_idx < dgfn_func->func_cnt))
    SET dgfn_idx = (dgfn_idx+ 1)
    IF ((dgfn_func->qual[dgfn_idx].parm_exist_ind=1))
     SET dgfn_func_str = dgfn_func->qual[dgfn_idx].func_name
    ELSE
     SET dgfn_done = 1
    ENDIF
   ENDWHILE
   CALL echo(dgfn_func_str)
   IF (dgfn_func_str > " ")
    SET dm_err->eproc = "Verifying selected function exists."
    SELECT INTO "nl:"
     FROM user_objects uo
     WHERE uo.object_name=dgfn_func_str
      AND uo.object_type="FUNCTION"
      AND uo.status="VALID"
     DETAIL
      dgfn_exist = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(" ")
    ENDIF
    IF (dgfn_exist=0)
     SET dgfn_file = concat("cer_install:",dgfn_func_str,".sql")
     EXECUTE dm_refchg_include_sql dgfn_file, dgfn_func_str, "FUNCTION"
     IF ((dris_reply->status="F"))
      SET dm_err->err_ind = 1
      SET dm_err->emsg = dris_reply->msg
      RETURN(" ")
     ENDIF
    ENDIF
   ENDIF
   RETURN(dgfn_func_str)
 END ;Subroutine
 DECLARE drcs_num = i4 WITH protect, noconstant(0)
 DECLARE drcs_tab_name = vc WITH protect, noconstant(" ")
 DECLARE drcs_type = vc WITH protect, noconstant(" ")
 IF (validate(drcstw_request->table_name,"abc")="abc")
  FREE RECORD drcstw_request
  RECORD drcstw_request(
    1 table_name = vc
    1 sub_flag = i4
    1 function_type = vc
  )
  FREE RECORD drcstw_reply
  RECORD drcstw_reply(
    1 vc_return = vc
  )
  SET drcstw_request->sub_flag =  $1
  SET drcsw_request->table_name =  $2
  SET drcsw_request->function_type =  $3
 ENDIF
 SET drcs_num = drcstw_request->sub_flag
 SET drcs_tab_name = drcstw_request->table_name
 SET drcs_type = drcstw_request->function_type
 IF (drcs_num=1)
  SET drcstw_reply->vc_return = drcs_get_func_name(drcs_tab_name,drcs_type)
 ENDIF
END GO
