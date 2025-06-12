CREATE PROGRAM ams_security_lock_to_key_chain:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Audit/Commit" = ""
  WITH outdev, auditcommit
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed_mess = false
 SET table_name = fillstring(50," ")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed_mess = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 DECLARE sec_key = vc
 DECLARE sec_lock = vc
 FOR (o = 1 TO value(size(file_content->qual,5)))
   FREE RECORD request_details
   RECORD request_details(
     1 call_echo_ind = i2
     1 allow_partial_ind = i2
     1 qual[1]
       2 sch_object_id = f8
       2 version_dt_tm = di8
       2 mnemonic = vc
       2 description = vc
       2 info_sch_text_id = f8
       2 object_type_cd = f8
       2 object_type_meaning = c12
       2 object_sub_cd = f8
       2 object_sub_meaning = c12
       2 updt_cnt = i4
       2 action = i2
       2 force_updt_ind = i2
       2 version_ind = i2
       2 text_updt_cnt = i4
       2 text_active_ind = i2
       2 text_active_status_cd = f8
       2 info_sch_text = vc
       2 text_action = i2
       2 ref_detail_partial_ind = i2
       2 ref_detail_qual[0]
         3 oe_field_id = f8
         3 seq_nbr = i4
         3 oe_field_display_value = vc
         3 oe_field_dt_tm_value = di8
         3 oe_field_meaning = c25
         3 oe_field_value = f8
         3 oe_field_meaning_id = f8
         3 candidate_id = f8
         3 active_ind = i2
         3 active_status_cd = f8
         3 updt_cnt = i4
         3 action = i2
         3 force_updt_ind = i2
         3 version_ind = i2
       2 assoc_partial_ind = i2
       2 assoc_qual[1]
         3 association_id = f8
         3 parent_meaning = c12
         3 child_table = c32
         3 child_id = f8
         3 child_meaning = c12
         3 seq_nbr = i4
         3 assoc_type_cd = f8
         3 assoc_type_meaning = c12
         3 data_source_cd = f8
         3 data_source_meaning = c12
         3 active_ind = i2
         3 active_status_cd = f8
         3 updt_cnt = i4
         3 candidate_id = f8
         3 display_table = c32
         3 display_id = f8
         3 display_meaning = c12
         3 action = i2
         3 force_updt_ind = i2
         3 version_ind = i2
         3 ref_detail_partial_ind = i2
         3 ref_detail_qual[0]
           4 oe_field_id = f8
           4 seq_nbr = i4
           4 oe_field_display_value = vc
           4 oe_field_dt_tm_value = di8
           4 oe_field_meaning = c25
           4 oe_field_value = f8
           4 oe_field_meaning_id = f8
           4 candidate_id = f8
           4 active_ind = i2
           4 active_status_cd = f8
           4 updt_cnt = i4
           4 action = i2
           4 force_updt_ind = i2
           4 version_ind = i2
   )
   SET sec_key = trim(cnvtupper(file_content->qual[o].security_key_name))
   SELECT
    s.sch_object_id
    FROM sch_object s
    WHERE s.mnemonic_key=sec_key
     AND s.object_type_cd=625791.00
    DETAIL
     request_details->qual[1].sch_object_id = s.sch_object_id
    WITH nocounter
   ;end select
   SELECT
    seq = max(a.seq_nbr)
    FROM sch_assoc a
    WHERE (a.parent_id=request_details->qual[1].sch_object_id)
    DETAIL
     request_details->qual[1].assoc_qual[1].seq_nbr = (seq+ 1)
    WITH nocounter
   ;end select
   SET sec_lock = trim(cnvtupper(file_content->qual[o].security_key_lock))
   SELECT
    s.sch_object_id
    FROM sch_object s
    WHERE s.mnemonic_key=sec_lock
    DETAIL
     request_details->qual[1].child_id = s.sch_object_id, request_details->qual[1].assoc_qual[1].
     display_id = s.sch_object_id
    WITH nocounter
   ;end select
   SET request_details->qual[1].object_type_cd = 625791.0000000
   SET request_details->qual[1].object_sub_cd = 625796.000000
   SET request_details->qual[1].assoc_qual[1].assoc_type_cd = 625810.0000000
   SET request_details->qual[1].assoc_qual[1].data_source_cd = 625836.0000000
   SET request_details->qual[1].object_sub_meaning = "SECCHAIN"
   SET request_details->qual[1].assoc_qual[1].child_table = "SCH_OBJECT"
   SET request_details->qual[1].assoc_qual[1].assoc_type_meaning = "SECCHAINKEY"
   SET request_details->qual[1].assoc_qual[1].data_source_cd = 625836.0000000
   SET request_details->qual[1].assoc_qual[1].data_source_meaning = "SECLOCK"
   SET request_details->qual[1].assoc_qual[1].active_ind = 1
   SET request_details->qual[1].assoc_qual[1].action = 1
   SET request_details->qual[1].assoc_qual[1].display_table = "SCH_OBJECT"
   CALL echorecord(request_details)
   EXECUTE sch_chgw_object  WITH replace("REQUEST",request_details)
 ENDFOR
#exit_script
 SET script_ver = " 000 19/06/15 MS035369         Initial Release "
END GO
