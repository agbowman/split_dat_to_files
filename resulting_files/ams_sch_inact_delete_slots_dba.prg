CREATE PROGRAM ams_sch_inact_delete_slots:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Choose the action, delete or inactivate" = "Inactivate",
  "Slots not associated to templates" = 0,
  "Inactive Slots" = 0
  WITH outdev, option, unlinkedslots,
  inactiveslots
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
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 IF (( $OPTION="Inactivate"))
  FREE SET temp_request
  RECORD temp_request(
    1 call_echo_ind = i2
    1 allow_partial_ind = i2
    1 qual[*]
      2 slot_type_id = f8
      2 info_sch_text_id = f8
      2 text_updt_cnt = i4
      2 updt_cnt = i4
      2 force_updt_ind = i2
      2 version_dt_tm = di8
      2 active_status_cd = f8
      2 version_ind = i2
  )
  SET temp_request->call_echo_ind = 1
  SET temp_request->allow_partial_ind = 0
  SET t_index = 0
  SELECT INTO "nl:"
   FROM sch_slot_type sst,
    long_text_reference t
   PLAN (sst
    WHERE sst.slot_type_id IN ( $UNLINKEDSLOTS))
    JOIN (t
    WHERE t.long_text_id=sst.info_sch_text_id)
   DETAIL
    t_index = (t_index+ 1), stat = alterlist(temp_request->qual,t_index), temp_request->qual[t_index]
    .slot_type_id = sst.slot_type_id,
    temp_request->qual[t_index].info_sch_text_id = sst.info_sch_text_id, temp_request->qual[t_index].
    updt_cnt = sst.updt_cnt, temp_request->qual[t_index].text_updt_cnt = t.updt_cnt,
    temp_request->qual[t_index].force_updt_ind = false, temp_request->qual[t_index].version_dt_tm = 0,
    temp_request->qual[t_index].active_status_cd = 0,
    temp_request->qual[t_index].version_ind = false
   WITH nocounter
  ;end select
  EXECUTE sch_inaw_slot_type  WITH replace("REQUEST",temp_request)
  SELECT INTO value( $OUTDEV)
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    col 5, "Selected Slots were inactivated."
   WITH nocounter
  ;end select
 ELSE
  FREE SET temp_request
  RECORD temp_request(
    1 call_echo_ind = i2
    1 allow_partial_ind = i2
    1 qual[*]
      2 slot_type_id = f8
      2 info_sch_text_id = f8
      2 text_updt_cnt = i4
      2 updt_cnt = i4
      2 force_updt_ind = i2
  )
  SET t_index2 = 0
  SELECT INTO "nl:"
   FROM sch_slot_type sst,
    long_text_reference t
   PLAN (sst
    WHERE sst.slot_type_id IN ( $INACTIVESLOTS))
    JOIN (t
    WHERE t.long_text_id=sst.info_sch_text_id)
   DETAIL
    t_index2 = (t_index2+ 1), stat = alterlist(temp_request->qual,t_index), temp_request->qual[
    t_index2].slot_type_id = sst.slot_type_id,
    temp_request->qual[t_index2].info_sch_text_id = sst.info_sch_text_id, temp_request->qual[t_index2
    ].text_updt_cnt = t.updt_cnt, temp_request->qual[t_index2].updt_cnt = sst.updt_cnt,
    temp_request->qual[t_index2].force_updt_ind = false
   WITH nocounter
  ;end select
  EXECUTE sch_delw_slot_type  WITH replace("REQUEST",temp_request)
  SELECT INTO value( $OUTDEV)
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    col 5, "Selected Slots were deleted."
   WITH nocounter
  ;end select
 ENDIF
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
 SET last_mod = "001 06/29/14 ZA030646  Initial Release"
END GO
