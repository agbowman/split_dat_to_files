CREATE PROGRAM bhs_change_physician_loc:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Choose a Physician" = 0,
  "Choose a Location/Organization" = 0
  WITH outdev, phys, loc
 DECLARE changed_ind = i2
 DECLARE exit_ind = i2
 IF (( $PHYS=0.00))
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    col 0, "You must choose a physician."
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
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
 UPDATE  FROM bhs_physician_location b
  SET b.location_id =  $LOC
  WHERE (b.person_id= $PHYS)
  WITH nocounter
 ;end update
 COMMIT
 SELECT INTO "nl:"
  FROM bhs_physician_location b
  PLAN (b
   WHERE (b.person_id= $PHYS)
    AND (b.location_id= $LOC))
  DETAIL
   changed_ind = 1, exit_ind = 1
  WITH nocounter
 ;end select
#exit_script
 IF (exit_ind=1)
  IF (changed_ind=1)
   SELECT INTO  $OUTDEV
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    DETAIL
     col 0, "Your physician was successfully changed"
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    DETAIL
     col 0, "Your physician was not successfully changed"
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
END GO
