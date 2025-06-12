CREATE PROGRAM dm_cmeta_rdds_alg5_tab:dba
 IF ((validate(dm_cmb_cust_script->called_by_readme_ind,- (9))=- (9)))
  RECORD dm_cmb_cust_script(
    1 called_by_readme_ind = i2
    1 exc_maint_ind = i2
  )
 ENDIF
 SUBROUTINE (dm_cmb_get_context(dummy=i2) =null)
   SET dm_cmb_cust_script->called_by_readme_ind = 0
   IF (validate(readme_data->status,"b") != "b"
    AND validate(readme_data->message,"CUSTCMBVALIDATE") != "CUSTCMBVALIDATE")
    SET dm_cmb_cust_script->called_by_readme_ind = 1
   ENDIF
   SET dm_cmb_cust_script->exc_maint_ind = 0
   IF ((validate(dcue_context_rec->called_by_dcue_ind,- (11)) != - (11))
    AND (validate(dcue_context_rec->called_by_dcue_ind,- (22)) != - (22)))
    SET dm_cmb_cust_script->exc_maint_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE cust_chk_ccl_def_col(ftbl_name,fcol_name)
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name=cnvtupper(trim(ftbl_name,3))
     AND l.attr_name=cnvtupper(trim(fcol_name,3))
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (dm_cmb_exc_maint_status(s_dcems_status=c1,s_dcems_msg=c255,s_dcems_tname=vc) =null)
   SET dcue_upt_exc_reply->status = s_dcems_status
   SET dcue_upt_exc_reply->message = s_dcems_msg
   SET dcue_upt_exc_reply->error_table = s_dcems_tname
 END ;Subroutine
 IF ((validate(dcmm_request->qual[1].active_only_flag,- (1))=- (1)))
  FREE RECORD dcmm_request
  RECORD dcmm_request(
    1 qual[*]
      2 active_only_flag = i2
      2 child_column = vc
      2 child_cons_name = vc
      2 child_pe_name1_txt = vc
      2 child_pe_name2_txt = vc
      2 child_pe_name3_txt = vc
      2 child_pe_name_column = vc
      2 child_pk = vc
      2 child_table = vc
      2 combine_action_type_cd = f8
      2 parent_table = vc
      2 delete_row_ind = i2
  )
 ENDIF
 IF (validate(dcmm_reply->status,"B")="B")
  FREE RECORD dcmm_reply
  RECORD dcmm_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 CALL dm_cmb_get_context(0)
 CALL echorecord(dm_cmb_cust_script)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcmm_request->qual,1)
  SET dcmm_request->qual[1].active_only_flag = 0
  SET dcmm_request->qual[1].child_column = "RNDM_VALUE"
  SET dcmm_request->qual[1].child_cons_name = "RNDM_CONS"
  SET dcmm_request->qual[1].child_pe_name1_txt = "PERSON"
  SET dcmm_request->qual[1].child_pe_name2_txt = ""
  SET dcmm_request->qual[1].child_pe_name3_txt = ""
  SET dcmm_request->qual[1].child_pe_name_column = "PARENT_ENTITY_NAME"
  SET dcmm_request->qual[1].child_pk = "DM_RDDS_ALG5_TAB_ID"
  SET dcmm_request->qual[1].child_table = "RDDS_ALG5_TAB"
  SET dcmm_request->qual[1].combine_action_type_cd = 1103.0
  SET dcmm_request->qual[1].parent_table = "PERSON"
  EXECUTE dm_cmb_metadata_maint
  CALL dm_cmb_exc_maint_status(dcmm_reply->status,dcmm_reply->err_msg,dcmm_request->qual[1].
   child_table)
  GO TO exit_sub
 ENDIF
#exit_sub
END GO
