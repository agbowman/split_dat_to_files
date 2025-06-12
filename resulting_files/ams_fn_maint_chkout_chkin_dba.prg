CREATE PROGRAM ams_fn_maint_chkout_chkin:dba
 PROMPT
  "Output Device" = "MINE",
  "Enter the FIN to remove" = "",
  "Select Tracking Group" = 0,
  "Enter Check-in date/time" = "SYSDATE",
  "Enter Check-out Date/Time" = "SYSDATE"
  WITH outdev, p_fin, p_tracking_checkin_id,
  p_chk_in_dt, p_chk_out_dt
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
 DECLARE smessage = vc WITH protect, noconstant("")
 DECLARE prog_name = vc
 DECLARE run_ind = i2
 SET prog_name = "AMS_FN_MAINT_CHKOUT_CHKIN"
 SET run_ind = 0
 SET run_ind = amsuser(reqinfo->updt_id)
 IF (run_ind=true)
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM tracking_checkin tc
   SET tc.checkin_dt_tm = cnvtdatetime( $P_CHK_IN_DT), tc.checkout_dt_tm = cnvtdatetime(
      $P_CHK_OUT_DT), tc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    tc.updt_cnt = (tc.updt_cnt+ 1), tc.updt_id = reqinfo->updt_id
   PLAN (tc
    WHERE (tc.tracking_checkin_id= $P_TRACKING_CHECKIN_ID))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET smessage = concat("ERROR UPDATING TRACKING_CHECKIN: ",trim(serrmsg,3))
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     row 3, col 10, smessage
    WITH nocounter
   ;end select
   ROLLBACK
   GO TO exit_script
  ENDIF
  COMMIT
  CALL updtdminfo(prog_name)
  COMMIT
  SET smessage = concat("Successfully Updated Checkin and Checkout Date/Time")
  SELECT INTO  $OUTDEV
   FROM dummyt d
   HEAD REPORT
    row 3, col 10, smessage
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "THIS PROGRAM IS INTENDED FOR USE BY AMS ASSOCIATES ONLY"
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE updtdminfo(prog_name)
   DECLARE found = i2
   DECLARE info_nbr = i4
   SET found = 0
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="AMS_TOOLKIT"
     AND d.info_name=prog_name
    DETAIL
     found = 1, info_nbr = (d.info_number+ 1)
    WITH nocounter
   ;end select
   IF (found=0)
    INSERT  FROM dm_info d
     SET d.info_domain = "AMS_TOOLKIT", d.info_name = prog_name, d.info_date = cnvtdatetime(curdate,
       curtime3),
      d.info_number = 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info d
     SET d.info_number = info_nbr
     WHERE d.info_domain="AMS_TOOLKIT"
      AND d.info_name=prog_name
     WITH nocounter
    ;end update
   ENDIF
   COMMIT
 END ;Subroutine
 SUBROUTINE amsuser(person_id)
   DECLARE user_ind = i2
   DECLARE prsnl_cd = f8
   SET user_ind = 0
   SET prsnl_cd = uar_get_code_by("MEANING",213,"PRSNL")
   SELECT
    p.person_id
    FROM person_name p
    WHERE (p.person_id=reqinfo->updt_id)
     AND p.name_type_cd=prsnl_cd
     AND p.name_title="Cerner AMS"
    DETAIL
     IF (p.person_id > 0)
      user_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   RETURN(user_ind)
 END ;Subroutine
#exit_script
 SET script_ver = "000 04/07/2014 Initial Release"
END GO
