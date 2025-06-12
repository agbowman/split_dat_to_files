CREATE PROGRAM bhs_create_practice_loc:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Existing Locations and Organizations" = "",
  "Enter a New Practice Name" = "",
  "Enter an Organization" = "",
  "Enter an email address. For multiple addresses separate with a space (optional)" = "",
  "Enter the password" = ""
  WITH outdev, elocs, loc,
  org, email, pass
 DECLARE loc_exists_ind = i2
 DECLARE created_ind = i2
 DECLARE exit_ind = i2
 IF (( $LOC=""))
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
 SELECT INTO "nl:"
  FROM bhs_practice_location b
  PLAN (b)
  DETAIL
   IF (cnvtupper(trim(b.location_description,4))=cnvtupper(trim( $LOC,4))
    AND cnvtupper(trim(b.organization,4))=cnvtupper(trim( $ORG,4)))
    loc_exists_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (loc_exists_ind=1)
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    col 0, "The practice organization pair already exists. You must choose a unique pairing"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 INSERT  FROM bhs_practice_location b
  SET b.location_description =  $LOC, b.organization =  $ORG, b.location_id = seq(
    location_resource_seq,nextval),
   b.email =  $EMAIL, b.passkey =  $PASS
  WITH nocounter
 ;end insert
 COMMIT
 SELECT INTO "nl:"
  FROM bhs_practice_location b
  PLAN (b
   WHERE (b.location_description= $LOC)
    AND (b.organization= $ORG))
  DETAIL
   created_ind = 1, exit_ind = 1
  WITH nocounter
 ;end select
#exit_script
 IF (exit_ind=1)
  IF (created_ind=1)
   SELECT INTO  $OUTDEV
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    DETAIL
     col 0, "Your practice was successfully created"
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    DETAIL
     col 0, "Your practice was not successfully created"
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
END GO
