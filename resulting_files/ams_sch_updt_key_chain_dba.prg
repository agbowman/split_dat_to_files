CREATE PROGRAM ams_sch_updt_key_chain:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Existing postion" = 0,
  "Position to be added" = 0
  WITH outdev, e_position, add_pos
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
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
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 RECORD parent_key_chain(
   1 qual[*]
     2 parent_id = f8
 )
 DECLARE child_id = f8
 DECLARE new_posistion_id = f8
 DECLARE new_posistion_mnemonic = vc
 DECLARE new_posistion_mnemonic_key = vc
 FREE RECORD get_obj_request
 RECORD get_obj_request(
   1 call_echo_ind = i2
   1 qual[*]
     2 sch_object_id = f8
 )
 FREE RECORD get_obj_reply
 RECORD get_obj_reply(
   1 qual_cnt = i4
   1 qual[*]
     2 sch_object_id = f8
     2 mnemonic = vc
     2 description = vc
     2 object_type_cd = f8
     2 object_type_meaning = vc
     2 object_sub_cd = f8
     2 object_sub_meaning = vc
     2 info_sch_text_id = f8
     2 info_sch_text = vc
     2 text_updt_cnt = i4
     2 updt_cnt = i4
     2 active_ind = i2
     2 candidate_id = f8
     2 detail_qual_cnt = i4
     2 detail_qual[*]
       3 oe_field_id = f8
       3 oe_field_value = f8
       3 oe_field_display_value = vc
       3 oe_field_dt_tm_value = dq8
       3 oe_field_meaning_id = f8
       3 oe_field_meaning = vc
       3 field_seq = i4
       3 candidate_id = f8
     2 assoc_qual_cnt = i4
     2 assoc_qual[*]
       3 association_id = f8
       3 child_table = vc
       3 child_id = f8
       3 child_meaning = vc
       3 display_table = vc
       3 display_id = f8
       3 display_meaning = vc
       3 mnemonic = vc
       3 description = vc
       3 seq_nbr = i4
       3 assoc_type_cd = f8
       3 assoc_type_meaning = vc
       3 data_source_cd = f8
       3 data_source_meaning = vc
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
       3 detail_qual_cnt = i4
       3 detail_qual[*]
         4 oe_field_id = f8
         4 oe_field_value = f8
         4 oe_field_display_value = vc
         4 oe_field_dt_tm_value = dq8
         4 oe_field_meaning_id = f8
         4 oe_field_meaning = vc
         4 field_seq = i4
         4 candidate_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET request
 RECORD request(
   1 call_echo_ind = i2
   1 qual[*]
     2 association_id = f8
     2 parent_table = c32
     2 parent_id = f8
     2 parent_meaning = c12
     2 child_table = c32
     2 child_id = f8
     2 child_meaning = c12
     2 seq_nbr = i4
     2 assoc_type_cd = f8
     2 assoc_type_meaning = c12
     2 data_source_cd = f8
     2 data_source_meaning = c12
     2 active_ind = i2
     2 active_status_cd = f8
     2 candidate_id = f8
     2 display_table = c32
     2 display_id = f8
     2 display_meaning = c12
     2 allow_partial_ind = i2
 )
 FREE RECORD sec_key_chain
 RECORD sec_key_chain(
   1 qual[*]
     2 name = c200
 )
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE (cv.code_value= $E_POSITION)
   AND cv.active_ind=1
   AND cv.code_set=88
  DETAIL
   child_id = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM sch_assoc soa
  WHERE soa.child_id=child_id
  HEAD REPORT
   cnt = 0, stat = alterlist(parent_key_chain->qual,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > 10
    AND mod(cnt,10)=1)
    stat = alterlist(parent_key_chain->qual,(cnt+ 9))
   ENDIF
   parent_key_chain->qual[cnt].parent_id = soa.parent_id
  FOOT REPORT
   stat = alterlist(parent_key_chain->qual,cnt)
  WITH nocounter, format, separator = " "
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE (cv.code_value= $ADD_POS)
   AND cv.active_ind=1
   AND cv.code_set=88
  DETAIL
   new_posistion_id = cv.code_value, new_posistion_mnemonic_key = cv.display_key,
   new_posistion_mnemonic = cv.display
  WITH nocounter
 ;end select
 SET stat = alterlist(sec_key_chain->qual,value(size(parent_key_chain->qual,5)))
 SET stat = alterlist(get_obj_request->qual,1)
 SET stat = alterlist(update_obj_request->qual,1)
 FOR (ii = 1 TO value(size(parent_key_chain->qual,5)))
   SET get_obj_request->call_echo_ind = 0
   SET get_obj_request->qual[1].sch_object_id = parent_key_chain->qual[ii].parent_id
   EXECUTE sch_get_object_by_id  WITH replace("REQUEST","GET_OBJ_REQUEST"), replace("REPLY",
    "GET_OBJ_REPLY")
   SET sec_key_chain->qual[ii].name = get_obj_reply->qual[1].mnemonic
   SET request->call_echo_ind = 1
   SET stat = alterlist(request->qual,1)
   SET request->qual[1].parent_id = get_obj_reply->qual[1].sch_object_id
   SET request->qual[1].parent_table = "SCH_OBJECT"
   SET request->qual[1].allow_partial_ind = 1
   SET request->qual[1].child_id = new_posistion_id
   SET request->qual[1].child_meaning = new_posistion_mnemonic_key
   SET request->qual[1].display_id = new_posistion_id
   SET request->qual[1].display_meaning = new_posistion_mnemonic_key
   SET request->qual[1].child_table = "CODE_VALUE"
   SET request->qual[1].association_id = - (1)
   SET request->qual[1].candidate_id = - (1)
   SET request->qual[1].seq_nbr = 0
   SET request->qual[1].assoc_type_cd = uar_get_code_by("DISPLAY_KEY",16148,"PERSONNELKEYCHAIN")
   SET request->qual[1].assoc_type_meaning = uar_get_code_meaning(uar_get_code_by("DISPLAY_KEY",16148,
     "PERSONNELKEYCHAIN"))
   SET request->qual[1].data_source_cd = uar_get_code_by("DISPLAY_KEY",16149,"POSITION")
   SET request->qual[1].data_source_meaning = uar_get_code_meaning(uar_get_code_by("DISPLAY_KEY",
     16149,"POSITION"))
   SET request->qual[1].active_ind = 1
   SET request->qual[1].active_status_cd = cnvtreal(188)
   SET request->qual[1].display_table = "CODE_VALUE"
   EXECUTE sch_add_assoc
 ENDFOR
 SELECT INTO  $1
  qual_name = sec_key_chain->qual[d1.seq].name
  FROM (dummyt d1  WITH seq = value(size(sec_key_chain->qual,5)))
  PLAN (d1)
  ORDER BY qual_name
  HEAD REPORT
   row + 1, displayheader = build2("The position ",new_posistion_mnemonic," was associated to ",size(
     sec_key_chain->qual,5)," security key chains listed below"), col 10,
   displayheader, row + 2
  DETAIL
   row + 1, col 10, qual_name
  WITH nocounter, separator = " ", format,
   maxcol = 300
 ;end select
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO
