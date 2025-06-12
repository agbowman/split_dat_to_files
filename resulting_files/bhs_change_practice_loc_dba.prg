CREATE PROGRAM bhs_change_practice_loc:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Choose a Practice" = 0,
  "Practice Name" = "",
  "Organization Name" = "",
  "Email" = "",
  "Password" = ""
  WITH outdev, loc, prac,
  org, email, pass
 DECLARE changed_ind = i2
 DECLARE exit_ind = i2
 DECLARE email_null_ind = i2
 DECLARE pass_null_ind = i2
 IF (( $LOC=0.00))
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    col 0, "You must choose a practice."
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF (( $PRAC=""))
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    col 0, "You must enter a practice name."
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF (( $ORG=""))
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    col 0, "You must enter an organization name."
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF (( $EMAIL=""))
  SET email_null_ind = 1
 ENDIF
 IF (( $PASS=""))
  SET pass_null_ind = 1
 ENDIF
 IF (textlen( $PRAC) > 100)
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    col 0, "The practice name must be 100 characters or less"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF (textlen( $ORG) > 20)
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    col 0, "The organization name must be 20 characters or less"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF (textlen( $EMAIL) > 250)
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    col 0, "The email string must be 250 characters or less"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF (textlen( $PASS) > 10)
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    col 0, "The password must be 10 characters or less"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 UPDATE  FROM bhs_practice_location b
  SET b.location_description =  $PRAC, b.organization =  $ORG, b.email =  $EMAIL,
   b.passkey =  $PASS
  WHERE (b.location_id= $LOC)
  WITH nocounter
 ;end update
 COMMIT
 IF (email_null_ind=1
  AND pass_null_ind=1)
  SELECT INTO "nl:"
   FROM bhs_practice_location b
   PLAN (b
    WHERE (b.location_description= $PRAC)
     AND (b.organization= $ORG))
   DETAIL
    changed_ind = 1, exit_ind = 1
   WITH nocounter
  ;end select
 ELSEIF (email_null_ind=0
  AND pass_null_ind=1)
  SELECT INTO "nl:"
   FROM bhs_practice_location b
   PLAN (b
    WHERE (b.location_description= $PRAC)
     AND (b.organization= $ORG)
     AND (b.email= $EMAIL))
   DETAIL
    changed_ind = 1, exit_ind = 1
   WITH nocounter
  ;end select
 ELSEIF (email_null_ind=1
  AND pass_null_ind=0)
  SELECT INTO "nl:"
   FROM bhs_practice_location b
   PLAN (b
    WHERE (b.location_description= $PRAC)
     AND (b.organization= $ORG)
     AND (b.passkey= $PASS))
   DETAIL
    changed_ind = 1, exit_ind = 1
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM bhs_practice_location b
   PLAN (b
    WHERE (b.location_description= $PRAC)
     AND (b.organization= $ORG)
     AND (b.email= $EMAIL)
     AND (b.passkey= $PASS))
   DETAIL
    changed_ind = 1, exit_ind = 1
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (exit_ind=1)
  IF (changed_ind=1)
   SELECT INTO  $OUTDEV
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    DETAIL
     col 0, "Your practice was successfully changed"
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    DETAIL
     col 0, "Your practice was not successfully changed"
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
END GO
