CREATE PROGRAM ams_unlock_powernote
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter FIN of Encounter With Locked Note" = "",
  "Select the Note to Unlock (Title, Lock Dt/Tm,Lock User)" = 0
  WITH outdev, fin, storyid
 DECLARE story = vc WITH protect, constant(cnvtstring( $STORYID))
 DECLARE prog_name = vc
 DECLARE run_ind = i2
 SET prog_name = "AMS_UNLOCK_POWERNOTE"
 SET run_ind = 0
 SET run_ind = amsuser(reqinfo->updt_id)
 IF (run_ind=1)
  UPDATE  FROM scd_story scd
   SET scd.update_lock_user_id = 0.0, scd.update_lock_dt_tm = null
   PLAN (scd
    WHERE (scd.scd_story_id= $STORYID))
   WITH nocounter
  ;end update
  COMMIT
  SELECT INTO  $OUTDEV
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "UNLOCKED SELECTED NOTE.....:",
    row 4, col 20, "SCD_STORY_ID:",
    story
   WITH nocounter
  ;end select
  CALL updtdminfo(prog_name)
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
END GO
