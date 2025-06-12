CREATE PROGRAM cps_get_scd_patrn_concept:dba
 RECORD reply(
   1 scr_pattern_id = f8
   1 concepts[*]
     2 concept_source_cd = f8
     2 concept_source_mean = vc
     2 concept_identifier = vc
     2 concept_name = vc
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
 DECLARE cps_lock = i4 WITH public, constant(100)
 DECLARE cps_no_seq = i4 WITH public, constant(101)
 DECLARE cps_updt_cnt = i4 WITH public, constant(102)
 DECLARE cps_insuf_data = i4 WITH public, constant(103)
 DECLARE cps_update = i4 WITH public, constant(104)
 DECLARE cps_insert = i4 WITH public, constant(105)
 DECLARE cps_delete = i4 WITH public, constant(106)
 DECLARE cps_select = i4 WITH public, constant(107)
 DECLARE cps_auth = i4 WITH public, constant(108)
 DECLARE cps_inval_data = i4 WITH public, constant(109)
 DECLARE cps_ens_note_story_not_locked = i4 WITH public, constant(110)
 DECLARE cps_lock_msg = c33 WITH public, constant("Failed to lock all requested rows")
 DECLARE cps_no_seq_msg = c34 WITH public, constant("Failed to get next sequence number")
 DECLARE cps_updt_cnt_msg = c28 WITH public, constant("Failed to match update count")
 DECLARE cps_insuf_data_msg = c38 WITH public, constant("Request did not supply sufficient data")
 DECLARE cps_update_msg = c24 WITH public, constant("Failed on update request")
 DECLARE cps_insert_msg = c24 WITH public, constant("Failed on insert request")
 DECLARE cps_delete_msg = c24 WITH public, constant("Failed on delete request")
 DECLARE cps_select_msg = c24 WITH public, constant("Failed on select request")
 DECLARE cps_auth_msg = c34 WITH public, constant("Failed on authorization of request")
 DECLARE cps_inval_data_msg = c35 WITH public, constant("Request contained some invalid data")
 DECLARE cps_success = i4 WITH public, constant(0)
 DECLARE cps_success_info = i4 WITH public, constant(1)
 DECLARE cps_success_warn = i4 WITH public, constant(2)
 DECLARE cps_deadlock = i4 WITH public, constant(3)
 DECLARE cps_script_fail = i4 WITH public, constant(4)
 DECLARE cps_sys_fail = i4 WITH public, constant(5)
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
 SET failed = 0
 SET reply->status_data.status = "F"
 IF ((request->scr_pattern_id=0.0))
  CALL cps_add_error(cps_inval_data,cps_script_fail,"No Pattern ID specified.",cps_inval_data_msg,0,
   0,0)
  SET failed = 1
  GO TO exit_script
 ENDIF
 SET idx = 0
 SET pat_cons = 0
 CALL getpatconcepts(pat_cons)
#exit_script
 IF (failed=0)
  IF (idx=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 SUBROUTINE getpatconcepts(dummy)
   SELECT INTO "NL:"
    FROM cmt_concept con,
     scr_pattern_concept pc
    WHERE (pc.scr_pattern_id=request->scr_pattern_id)
     AND con.concept_cki=outerjoin(pc.concept_cki)
     AND con.concept_identifier=outerjoin(pc.concept_identifier)
    HEAD REPORT
     row + 0
    DETAIL
     idx = (idx+ 1)
     IF (mod(idx,10)=1)
      stat = alterlist(reply->concepts,(idx+ 10))
     ENDIF
     reply->concepts[idx].concept_source_cd = pc.concept_source_cd, reply->concepts[idx].
     concept_identifier = pc.concept_identifier, reply->concepts[idx].concept_name = con.concept_name
    FOOT REPORT
     stat = alterlist(reply->concepts,idx)
    WITH nocounter
   ;end select
 END ;Subroutine
END GO
