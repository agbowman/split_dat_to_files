CREATE PROGRAM cps_get_scd_patrn_list:dba
 RECORD reply(
   1 patterns[*]
     2 scr_pattern_id = f8
     2 cki_source = vc
     2 cki_identifier = vc
     2 pattern_type_cd = f8
     2 pattern_type_mean = vc
     2 display = vc
     2 definition = vc
     2 updt_cnt = i4
     2 active_status_cd = f8
     2 active_status_mean = vc
     2 active_ind = i2
     2 updt_dt_tm = dq8
     2 updt_name = vc
     2 entry_mode_cd = f8
     2 entry_mode_mean = vc
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
 DECLARE dummy_void = i4 WITH noconstant(0)
 DECLARE failed = i4 WITH noconstant(0)
 DECLARE concept_qual_sizeof = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 IF ((((request->selection_options.query_type < 1)) OR ((request->selection_options.query_type > 7)
 )) )
  CALL cps_add_error(cps_inval_data,cps_script_fail,"Invalid query type specified",cps_inval_data_msg,
   0,
   0,0)
  SET failed = 1
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->patterns,500)
 CASE (request->selection_options.query_type)
  OF 1:
   EXECUTE scdpatlistbyname
  OF 2:
   SET failed = 1
   CALL cps_add_error(cps_inval_data,cps_script_fail,
    "Pattern List by nomenclature not currently supported.",cps_inval_data_msg,0,
    0,0)
  OF 3:
   SET concept_qual_sizeof = size(request->selection_options.concept_qual,5)
   IF (concept_qual_sizeof=0
    AND (request->selection_options.concept_source_cd != 0))
    SET stat = alterlist(request->selection_options.concept_qual,1)
    SET request->selection_options.concept_qual[1].concept_source_cd = request->selection_options.
    concept_source_cd
    SET request->selection_options.concept_qual[1].concept_identifier = request->selection_options.
    concept_identifier
   ENDIF
   EXECUTE scdpatlistbyconcept parser(
    IF ((request->all_status_ind=0)) "pat.active_ind = 1"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->entry_mode_filter_ind=1)) "pat.entry_mode_cd = request->entry_mode_cd"
    ELSEIF ((request->entry_mode_filter_ind=2))
     "(pat.entry_mode_cd = request->entry_mode_cd) or (pat.entry_mode_cd = 0.0)"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->pattern_type_cd != 0.0)) "pat.pattern_type_cd = request->pattern_type_cd"
    ELSE "0 = 0"
    ENDIF
    )
  OF 4:
   EXECUTE scdpatlistbycki parser(
    IF ((request->all_status_ind=0)) "pat.active_ind = 1"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->entry_mode_filter_ind=1)) "pat.entry_mode_cd = request->entry_mode_cd"
    ELSEIF ((request->entry_mode_filter_ind=2))
     "(pat.entry_mode_cd = request->entry_mode_cd) or (pat.entry_mode_cd = 0.0)"
    ELSE "0 = 0"
    ENDIF
    )
  OF 5:
   EXECUTE scdpatlistbyid parser(
    IF ((request->all_status_ind=0)) "pat.active_ind = 1"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->entry_mode_filter_ind=1)) "pat.entry_mode_cd = request->entry_mode_cd"
    ELSEIF ((request->entry_mode_filter_ind=2))
     "(pat.entry_mode_cd = request->entry_mode_cd) or (pat.entry_mode_cd = 0.0)"
    ELSE "0 = 0"
    ENDIF
    )
  OF 6:
   EXECUTE scdpatlistbynotetype parser(
    IF ((request->all_status_ind=0)) "pat.active_ind = 1"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->entry_mode_filter_ind=1)) "pat.entry_mode_cd = request->entry_mode_cd"
    ELSEIF ((request->entry_mode_filter_ind=2))
     "(pat.entry_mode_cd = request->entry_mode_cd) or (pat.entry_mode_cd = 0.0)"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->pattern_type_cd != 0.0)) "pat.pattern_type_cd = request->pattern_type_cd"
    ELSE "0 = 0"
    ENDIF
    )
  OF 7:
   EXECUTE scdpatlistbymultiids parser(
    IF ((request->all_status_ind=0)) "pat.active_ind = 1"
    ELSE "0 = 0"
    ENDIF
    ), parser(
    IF ((request->entry_mode_filter_ind=1)) "pat.entry_mode_cd = request->entry_mode_cd"
    ELSEIF ((request->entry_mode_filter_ind=2))
     "(pat.entry_mode_cd = request->entry_mode_cd) or (pat.entry_mode_cd = 0.0)"
    ELSE "0 = 0"
    ENDIF
    )
  ELSE
   SET failed = 1
   CALL cps_add_error(cps_inval_data,cps_script_fail,"Unrecognized pattern list query type",
    cps_inval_data_msg,0,
    0,0)
 ENDCASE
#exit_script
 IF (failed=0)
  IF (idx=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 SET stat = alterlist(reply->patterns,idx)
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
