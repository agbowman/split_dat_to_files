CREATE PROGRAM ams_sched_keychain_updates:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "FROM User Search:" = "",
  "Copy FROM user:" = 0,
  "Select Keychain(s) To Copy:" = 0,
  "TO User Search:" = "",
  "Copy TO user:" = 0,
  "Existing TO User Keychain(s):" = 0
  WITH outdev, textfromuser, selfromuser,
  selfromkeychain, texttouser, seltouser,
  disptouserkeychain
 DECLARE getkeychainstoupdate(null) = null WITH protect
 DECLARE createoutputreport(null) = null WITH protect
 DECLARE loadrequest(null) = null WITH protect
 DECLARE addnewkeychain(null) = null WITH protect
 RECORD request_sch_chgw_object(
   1 call_echo_ind = i2
   1 allow_partial_ind = i2
   1 qual[*]
     2 sch_object_id = f8
     2 version_dt_tm = dq8
     2 mnemonic = vc
     2 description = vc
     2 info_sch_text_id = f8
     2 object_type_cd = f8
     2 object_type_meaning = vc
     2 object_sub_cd = f8
     2 object_sub_meaning = vc
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
     2 ref_detail_qual[*]
       3 oe_field_id = f8
       3 seq_nbr = i4
       3 oe_field_display_value = vc
       3 oe_field_dt_tm_value = dq8
       3 oe_field_meaning = vc
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
     2 assoc_qual[*]
       3 association_id = f8
       3 parent_meaning = vc
       3 child_table = vc
       3 child_id = f8
       3 child_meaning = vc
       3 seq_nbr = i4
       3 assoc_type_cd = f8
       3 assoc_type_meaning = vc
       3 data_source_cd = f8
       3 data_source_meaning = vc
       3 active_ind = i2
       3 active_status_cd = f8
       3 updt_cnt = i4
       3 candidate_id = f8
       3 display_table = vc
       3 display_id = f8
       3 display_meaning = vc
       3 action = i2
       3 force_updt_ind = i2
       3 version_ind = i2
       3 ref_detail_partial_ind = i2
       3 ref_detail_qual[*]
         4 oe_field_id = f8
         4 seq_nbr = i4
         4 oe_field_display_value = vc
         4 oe_field_dt_tm_value = dq8
         4 oe_field_meaning = vc
         4 oe_field_value = f8
         4 oe_field_meaning_id = f8
         4 candidate_id = f8
         4 active_ind = i2
         4 active_status_cd = f8
         4 updt_cnt = i4
         4 action = i2
         4 force_updt_ind = i2
         4 version_ind = i2
 ) WITH protect
 RECORD keychain_info(
   1 list[*]
     2 sch_object_id = f8
     2 mnemonic = vc
     2 description = vc
     2 updt_cnt = i4
     2 updt_status = vc
     2 updt_ind = i2
 ) WITH protect
 RECORD reply(
   1 qual_cnt = i4
   1 qual[*]
     2 status = i2
     2 info_sch_text_id = f8
     2 ref_detail_qual_cnt = i4
     2 ref_detail_qual[*]
       3 candidate_id = f8
       3 status = i2
     2 assoc_qual_cnt = i4
     2 assoc_qual[*]
       3 association_id = f8
       3 candidate_id = f8
       3 status = i2
       3 ref_detail_qual_cnt = i4
       3 ref_detail_qual[*]
         4 candidate_id = f8
         4 status = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 EXECUTE ams_define_toolkit_common
 DECLARE object_type_cd = f8 WITH constant(uar_get_code_by("MEANING",16146,"SECCHAIN")), protect
 DECLARE object_sub_cd = f8 WITH constant(uar_get_code_by("MEANING",16147,"SECCHAIN")), protect
 DECLARE data_source_cd = f8 WITH constant(uar_get_code_by("MEANING",16149,"PRSNL")), protect
 DECLARE assoc_type_cd = f8 WITH constant(uar_get_code_by("MEANING",16148,"PRSNLCHAIN")), protect
 DECLARE script_name = c26 WITH constant("AMS_SCHED_KEYCHAIN_UPDATES")
 DECLARE keychainmnemonic = vc WITH protect
 DECLARE keychaindescription = vc WITH protect
 DECLARE keychainid = f8 WITH protect
 DECLARE status = vc WITH protect
 DECLARE statusstr = vc WITH protect
 DECLARE successstr = vc WITH protect
 DECLARE errormsg = vc WITH protect
 DECLARE sasequence = i4 WITH protect
 DECLARE soupdtcnt = i4 WITH protect
 DECLARE updtpersonid = f8 WITH protect
 DECLARE updtpersonname = vc WITH protect
 DECLARE incrementcount = i4 WITH protect
 DECLARE keychaincnt = i4 WITH protect
 DECLARE tempstring = vc WITH protect
 DECLARE tempstringlen = vc WITH protect
 DECLARE maxkeychainmnemonic = i4 WITH protect
 SET incrementcount = 0
 SET updtpersonid =  $SELTOUSER
 SET maxkeychainmnemonic = 0
 CALL getkeychainstoupdate(null)
 FOR (keychaincnt = 1 TO size(keychain_info->list,5))
   IF ((keychain_info->list[keychaincnt].sch_object_id < 0))
    SET status = "F"
    SET statusstr = concat("The selected keychain (sch_object_id: ",cnvtstring(keychainid),
     ") doesn't exist on the sch_object table.")
    GO TO exit_script
   ELSE
    SET keychainid = keychain_info->list[keychaincnt].sch_object_id
    SET keychainmnemonic = keychain_info->list[keychaincnt].mnemonic
    SET keychaindescription = keychain_info->list[keychaincnt].description
    SET soupdtcnt = keychain_info->list[keychaincnt].updt_cnt
    IF (maxkeychainmnemonic < textlen(keychainmnemonic))
     SET maxkeychainmnemonic = textlen(keychainmnemonic)
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    p.name_full_formatted
    FROM prsnl p
    WHERE p.person_id=updtpersonid
    DETAIL
     updtpersonname = p.name_full_formatted
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET status = "F"
    SET statusstr = "The update TO user wasn't found on the prsnl table."
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    sa.parent_id
    FROM sch_assoc sa
    PLAN (sa
     WHERE sa.active_ind=1
      AND sa.child_id=updtpersonid
      AND sa.parent_id=keychainid
      AND sa.data_source_meaning="PRSNL"
      AND sa.assoc_type_meaning="PRSNLCHAIN"
      AND sa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND sa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET keychain_info->list[keychaincnt].updt_ind = 0
    SET keychain_info->list[keychaincnt].updt_status = "Exists"
    SET status = "S"
   ELSE
    SET keychain_info->list[keychaincnt].updt_ind = 1
   ENDIF
   IF ((keychain_info->list[keychaincnt].updt_ind=1))
    SELECT INTO "nl:"
     max_seq = max(sa.seq_nbr)
     FROM sch_assoc sa
     WHERE sa.parent_table="SCH_OBJECT"
      AND sa.child_table="PERSON"
      AND sa.data_source_meaning="PRSNL"
      AND sa.assoc_type_meaning="PRSNLCHAIN"
      AND sa.parent_id=keychainid
     DETAIL
      sasequence = cnvtint((max_seq+ 1))
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET status = "F"
     SET statusstr = "The next sequence on the sch_assoc table wasn't found."
     GO TO exit_script
    ENDIF
    CALL loadrequest(null)
    CALL addnewkeychain(null)
    IF (status="S")
     SET keychain_info->list[keychaincnt].updt_status = "Added"
    ELSE
     SET statusstr = "Erorr returned in the script sch_chgw_object."
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 IF (status="S")
  GO TO exit_script
 ELSE
  SET statusstr = "Erorr returned in the script sch_chgw_object2."
  GO TO exit_script
 ENDIF
 SUBROUTINE getkeychainstoupdate(null)
   DECLARE tempcnt = i4
   SELECT INTO "nl:"
    FROM sch_object so
    WHERE (so.sch_object_id= $SELFROMKEYCHAIN)
    HEAD REPORT
     tempcnt = 0
    DETAIL
     tempcnt = (tempcnt+ 1)
     IF (tempcnt > size(keychain_info->list,5))
      stat = alterlist(keychain_info->list,(tempcnt+ 5))
     ENDIF
     keychain_info->list[tempcnt].sch_object_id = so.sch_object_id, keychain_info->list[tempcnt].
     mnemonic = so.mnemonic, keychain_info->list[tempcnt].description = so.description,
     keychain_info->list[tempcnt].updt_cnt = so.updt_cnt
    FOOT REPORT
     stat = alterlist(keychain_info->list,tempcnt)
    WITH nocounter
   ;end select
   IF (size(keychain_info->list,5) < 1)
    SET status = "F"
    SET statusstr = "No keychain was selected."
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE loadrequest(null)
   SET request_sch_chgw_object->call_echo_ind = 0
   SET request_sch_chgw_object->allow_partial_ind = 0
   SET stat = alterlist(request_sch_chgw_object->qual,1)
   SET request_sch_chgw_object->qual[1].sch_object_id = keychainid
   SET request_sch_chgw_object->qual[1].version_dt_tm = cnvtdatetime("00-000-0000  00:00:00")
   SET request_sch_chgw_object->qual[1].mnemonic = keychainmnemonic
   SET request_sch_chgw_object->qual[1].description = keychaindescription
   SET request_sch_chgw_object->qual[1].info_sch_text_id = 0.00
   SET request_sch_chgw_object->qual[1].object_type_cd = object_type_cd
   SET request_sch_chgw_object->qual[1].object_type_meaning = "SECCHAIN"
   SET request_sch_chgw_object->qual[1].object_sub_cd = object_sub_cd
   SET request_sch_chgw_object->qual[1].object_sub_meaning = "SECCHAIN"
   SET request_sch_chgw_object->qual[1].updt_cnt = soupdtcnt
   SET request_sch_chgw_object->qual[1].action = 2
   SET request_sch_chgw_object->qual[1].force_updt_ind = 0
   SET request_sch_chgw_object->qual[1].version_ind = 0
   SET request_sch_chgw_object->qual[1].text_updt_cnt = 0
   SET request_sch_chgw_object->qual[1].text_active_ind = 1
   SET request_sch_chgw_object->qual[1].text_active_status_cd = 0.00
   SET request_sch_chgw_object->qual[1].info_sch_text = ""
   SET request_sch_chgw_object->qual[1].text_action = 0
   SET request_sch_chgw_object->qual[1].ref_detail_partial_ind = 0
   SET request_sch_chgw_object->qual[1].assoc_partial_ind = 0
   SET stat = alterlist(request_sch_chgw_object->qual[1].assoc_qual,1)
   SET request_sch_chgw_object->qual[1].assoc_qual[1].association_id = 0.00
   SET request_sch_chgw_object->qual[1].assoc_qual[1].parent_meaning = ""
   SET request_sch_chgw_object->qual[1].assoc_qual[1].child_table = "PERSON"
   SET request_sch_chgw_object->qual[1].assoc_qual[1].child_id = updtpersonid
   SET request_sch_chgw_object->qual[1].assoc_qual[1].child_meaning = ""
   SET request_sch_chgw_object->qual[1].assoc_qual[1].seq_nbr = sasequence
   SET request_sch_chgw_object->qual[1].assoc_qual[1].assoc_type_cd = assoc_type_cd
   SET request_sch_chgw_object->qual[1].assoc_qual[1].assoc_type_meaning = "PRSNLCHAIN"
   SET request_sch_chgw_object->qual[1].assoc_qual[1].data_source_cd = data_source_cd
   SET request_sch_chgw_object->qual[1].assoc_qual[1].data_source_meaning = "PRSNL"
   SET request_sch_chgw_object->qual[1].assoc_qual[1].active_ind = 1
   SET request_sch_chgw_object->qual[1].assoc_qual[1].active_status_cd = 0.00
   SET request_sch_chgw_object->qual[1].assoc_qual[1].updt_cnt = 0
   SET request_sch_chgw_object->qual[1].assoc_qual[1].candidate_id = 0.00
   SET request_sch_chgw_object->qual[1].assoc_qual[1].display_table = "PERSON"
   SET request_sch_chgw_object->qual[1].assoc_qual[1].display_id = updtpersonid
   SET request_sch_chgw_object->qual[1].assoc_qual[1].display_meaning = ""
   SET request_sch_chgw_object->qual[1].assoc_qual[1].action = 1
   SET request_sch_chgw_object->qual[1].assoc_qual[1].force_updt_ind = 0
   SET request_sch_chgw_object->qual[1].assoc_qual[1].version_ind = 0
   SET request_sch_chgw_object->qual[1].assoc_qual[1].ref_detail_partial_ind = 0
 END ;Subroutine
 SUBROUTINE addnewkeychain(null)
   EXECUTE sch_chgw_object  WITH replace("REQUEST",request_sch_chgw_object)
   SET status = reply->status_data.status
   SET incrementcount = (incrementcount+ 1)
 END ;Subroutine
#exit_script
 IF (status="F")
  ROLLBACK
  SELECT INTO value( $OUTDEV)
   DETAIL
    row + 1, "-------", row + 1,
    "FAILURE", row + 1, "-------",
    row + 1, statusstr, row + 1,
    "No changes have been made."
  ;end select
 ELSEIF (status="S")
  COMMIT
  SET statusstr = concat("The following keychains now exist for ",updtpersonname,".")
  IF (incrementcount > 0)
   CALL updtdminfo(script_name,cnvtreal(incrementcount))
  ENDIF
  SELECT INTO value( $OUTDEV)
   DETAIL
    row + 1, "-------", row + 1,
    "SUCCESS", row + 1, "-------",
    row + 1, "Please allow up to four hours for changes to take effect.", row + 1,
    "If new access is not granted after four hours, please log a request to AMS asking", row + 1,
    "for the scheduling security servers to be cycled. Thank you.",
    row + 2, row + 1, statusstr,
    row + 2, tempstring = concat("STATUS",char(9),"|"), row + 1,
    tempstring, tempstring = "KEYCHAIN NAME", col + 1,
    tempstring, row + 1
    FOR (i = 1 TO size(keychain_info->list,5))
      tempstring = concat(keychain_info->list[i].updt_status,char(9),"|"), row + 1, tempstring,
      tempstring = keychain_info->list[i].mnemonic, col + 1, tempstring
    ENDFOR
  ;end select
 ELSE
  ROLLBACK
  SET statusstr = concat("An unknown error has occured.")
  SELECT INTO value( $OUTDEV)
   DETAIL
    row + 1, "-----", row + 1,
    "ERROR", row + 1, "-----",
    row + 1, statusstr, row + 1,
    "No changes have been made."
  ;end select
 ENDIF
 SET last_mod = "000"
END GO
