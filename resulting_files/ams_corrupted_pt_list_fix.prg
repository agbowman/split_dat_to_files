CREATE PROGRAM ams_corrupted_pt_list_fix
 PROMPT
  "Output Device" = "MINE",
  "Enter the Username of the User Needing Patient Lists Reset" = "",
  "Verify the Personnel Information" = 0
  WITH outdev, username, prsnlid
 DECLARE prog_name = vc
 DECLARE run_ind = i2
 SET prog_name = "AMS_CORRUPTED_PT_LIST_FIX"
 SET run_ind = 0
 FREE SET request
 RECORD request(
   1 prsnl_id = f8
   1 viewname = vc
 )
 SET run_ind = amsuser(reqinfo->updt_id)
 IF (run_ind=1)
  IF (( $PRSNLID > 0))
   FREE SET reqinfo
   RECORD reqinfo(
     1 commit_ind = i2
     1 updt_id = f8
     1 updt_task = i4
     1 updt_applctx = i4
   )
   SET reqinfo->updt_task = 500017
   SET request->prsnl_id = cnvtreal( $PRSNLID)
   SET request->viewname = "PATLISTVIEW"
   EXECUTE dcp_del_viewname_prefs
   COMMIT
   CALL updtdminfo(prog_name)
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     row 3, col 20, "CLEANED UP PATIENT LISTS FOR THE FOLLOWING USER:",
     row 4, col 20, "USERNAME:",
      $USERNAME
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     row 3, col 20, "YOU MUST VERIFY THE CORRECT PERSONNEL BY SELECTING A USER FROM THE FINAL PROMPT"
    WITH nocounter
   ;end select
  ENDIF
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
