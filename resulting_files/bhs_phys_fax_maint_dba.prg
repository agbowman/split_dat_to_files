CREATE PROGRAM bhs_phys_fax_maint:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Action:" = "",
  "Physician:" = 0,
  "Fax Number:" = ""
  WITH outdev, n_action, f_phys_id,
  s_fax
 DECLARE mf_phys_id = f8 WITH protect, constant(cnvtreal( $F_PHYS_ID))
 DECLARE ms_phys_name = vc WITH protect, noconstant(" ")
 DECLARE ms_fax_nbr = vc WITH protect, noconstant(" ")
 DECLARE ms_message = vc WITH protect, noconstant(" ")
 DECLARE mn_exists_ind = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE p.person_id=mf_phys_id
  DETAIL
   ms_phys_name = trim(p.name_full_formatted)
  WITH nocounter
 ;end select
 IF (trim(ms_phys_name) < " ")
  SET ms_message = "Physician Name not found."
  GO TO exit_script
 ENDIF
 SET ms_fax_nbr = trim(replace( $S_FAX,".","",0))
 SET ms_fax_nbr = trim(replace(ms_fax_nbr,"-","",0))
 SET ms_fax_nbr = trim(replace(ms_fax_nbr," ","",0))
 IF (cnvtint( $N_ACTION)=1)
  SELECT INTO "nl:"
   FROM bhs_physician_fax_list b
   PLAN (b
    WHERE b.person_id=mf_phys_id)
   DETAIL
    mn_exists_ind = 1
   WITH nocounter
  ;end select
  IF (mn_exists_ind=1)
   UPDATE  FROM bhs_physician_fax_list b
    SET b.active_ind = 1, b.fax = ms_fax_nbr, b.update_dt_tm = sysdate,
     b.updt_id = reqinfo->updt_id
    WHERE b.person_id=mf_phys_id
    WITH nocounter
   ;end update
   COMMIT
   IF (curqual > 0)
    SET ms_message = concat(ms_phys_name," updated with fax number: ",ms_fax_nbr)
   ELSE
    SET ms_message = "Unable to update physician"
   ENDIF
  ELSE
   INSERT  FROM bhs_physician_fax_list b
    SET b.active_ind = 1, b.fax = ms_fax_nbr, b.name = ms_phys_name,
     b.person_id = mf_phys_id, b.practice = " ", b.update_dt_tm = sysdate,
     b.updt_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   COMMIT
  ENDIF
  IF (curqual > 0)
   SET ms_message = concat(ms_phys_name," fax number set: ",ms_fax_nbr)
  ELSE
   SET ms_message = "Unable to set physician fax number."
  ENDIF
 ELSEIF (cnvtint( $N_ACTION)=2)
  UPDATE  FROM bhs_physician_fax_list b
   SET b.active_ind = 0, b.update_dt_tm = sysdate, b.updt_id = reqinfo->updt_id
   WHERE b.person_id=mf_phys_id
   WITH nocounter
  ;end update
  COMMIT
  IF (curqual > 0)
   SET ms_message = concat(ms_phys_name," inactivated.")
  ELSE
   SET ms_message = "Unable to delete physician"
  ENDIF
 ENDIF
#exit_script
 SELECT INTO value( $OUTDEV)
  DETAIL
   col 0, row 0, ms_message
  WITH nocounter
 ;end select
END GO
