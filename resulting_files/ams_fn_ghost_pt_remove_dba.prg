CREATE PROGRAM ams_fn_ghost_pt_remove:dba
 PROMPT
  "Output Device" = "MINE",
  "Execute Global Cleanup Script?" = "",
  "Enter the FIN to remove" = "",
  "Select the correct encounter" = 0,
  "Enter the check-out date/time to stamp on the encounter" = "SYSDATE"
  WITH outdev, global, fin,
  encntrinfo, outdttm
 DECLARE prog_name = vc
 DECLARE run_ind = i2
 SET prog_name = "AMS_FN_GHOST_PT_REMOVE"
 SET run_ind = 0
 SET run_ind = amsuser(reqinfo->updt_id)
 IF (run_ind=1)
  IF (( $GLOBAL="0"))
   DECLARE trackingid = f8
   DECLARE locatorid = f8
   DECLARE checkinid = f8
   SELECT INTO "nl:"
    FROM encntr_alias ea,
     tracking_item ti,
     person p,
     tracking_locator tl,
     tracking_checkin tc
    PLAN (ea
     WHERE (ea.alias= $FIN))
     JOIN (ti
     WHERE ea.encntr_id=ti.encntr_id
      AND ti.end_tracking_dt_tm = null)
     JOIN (p
     WHERE p.person_id=ti.person_id)
     JOIN (tl
     WHERE tl.tracking_id=ti.tracking_id
      AND tl.depart_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (tc
     WHERE tc.tracking_id=ti.tracking_id
      AND tc.checkout_dt_tm >= cnvtdatetime(curdate,curtime3))
    DETAIL
     trackingid = ti.tracking_id, locatorid = tl.tracking_locator_id, checkinid = tc
     .tracking_checkin_id
    WITH nocounter
   ;end select
   UPDATE  FROM tracking_item
    SET end_tracking_dt_tm = cnvtdatetime( $OUTDTTM), updt_dt_tm = cnvtdatetime(curdate,curtime),
     updt_id = reqinfo->updt_id,
     updt_cnt = (updt_cnt+ 1)
    WHERE tracking_id=trackingid
    WITH nocounter
   ;end update
   UPDATE  FROM tracking_locator
    SET depart_dt_tm = cnvtdatetime( $OUTDTTM), updt_dt_tm = cnvtdatetime(curdate,curtime), updt_id
      = reqinfo->updt_id,
     updt_cnt = (updt_cnt+ 1)
    WHERE tracking_locator_id=locatorid
     AND tracking_id=trackingid
    WITH nocounter
   ;end update
   UPDATE  FROM tracking_checkin
    SET checkout_dt_tm = cnvtdatetime( $OUTDTTM), updt_dt_tm = cnvtdatetime(curdate,curtime), updt_id
      = reqinfo->updt_id,
     updt_cnt = (updt_cnt+ 1)
    WHERE tracking_checkin_id=checkinid
     AND tracking_id=trackingid
    WITH nocounter
   ;end update
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     row 3, col 20, "REMOVED THE FOLLOWING ENCOUNTER FROM THE TRACKING BOARD:",
     row 4, col 20, "FIN:",
      $FIN, row 5, col 20,
     "DATE/TIME:",  $OUTDTTM
    WITH nocounter
   ;end select
  ELSE
   EXECUTE trkfn_tracking_cleanup
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     row 3, col 20, "RAN GLOBAL TRACKING BOARD CLEANUP...."
    WITH nocounter
   ;end select
  ENDIF
  CALL updtdminfo(prog_name)
  COMMIT
 ELSE
  SELECT INTO  $1
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
 SET script_ver = "001 04/11/2012"
END GO
