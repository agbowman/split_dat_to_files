CREATE PROGRAM bhs_clinical_trial_validate:dba
 PROMPT
  "runType" = "",
  "IRB" = "",
  "field" = "",
  "value" = ""
  WITH runtype, irb, field,
  value
 SET fieldval = trim(cnvtupper( $FIELD),3)
 DECLARE returnval = vc WITH noconstant(" ")
 CALL echo("inside bhs_clinical_trial_validate")
 IF (cnvtupper( $RUNTYPE)="VALIDATE")
  IF (cnvtupper( $FIELD)="IRB")
   SET returnval = "0"
   SELECT
    b.irb_number
    FROM bhs_clinical_trial b
    WHERE (b.irb_number= $IRB)
    ORDER BY b.clinical_trial_id DESC
    HEAD b.irb_number
     IF (b.active_ind=1)
      returnval = "1"
     ELSE
      returnval = "2"
     ENDIF
    WITH nocounter
   ;end select
   GO TO exit_script
  ENDIF
 ELSEIF (cnvtupper( $RUNTYPE)="VALUE")
  SELECT
   b.irb_number
   FROM bhs_clinical_trial b,
    prsnl p
   PLAN (b
    WHERE (b.irb_number= $IRB))
    JOIN (p
    WHERE p.person_id=outerjoin(b.pi_id))
   ORDER BY b.clinical_trial_id DESC
   HEAD b.irb_number
    IF (fieldval="TITLE")
     returnval = b.title
    ELSEIF (fieldval="ABBTITLE")
     returnval = b.short_title
    ELSEIF (fieldval="PI")
     returnval = cnvtstring(p.person_id)
    ELSEIF (fieldval="PHONE")
     returnval = b.phone_number
    ELSEIF (fieldval="PAGER")
     returnval = b.pager_number
    ELSEIF (fieldval="CONTACTEMAIL")
     returnval = b.email_address
    ELSEIF (fieldval="SPECIAL")
     returnval = b.instructions
    ELSEIF (fieldval="PHARMCHK")
     returnval = cnvtstring(b.pharmacy_notify_ind)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET ccl_prompt_api_disable = 1
 SET ccl_prompt_api_misc = 1
 EXECUTE ccl_prompt_api_dataset "misc"
 SET stat = setmiscsize(_out_,1)
 SET stat = setmiscrecord(_out_,1,returnval)
 SET stat = setstatus("s")
END GO
