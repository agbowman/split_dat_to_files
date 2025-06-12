CREATE PROGRAM bhs_eks_check_prsnl_reltn
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "enconter_id" = "",
  "Prsnl Relationship Display Keys (separate with a |)" = ""
  WITH outdev, encounter_id, list
 IF (validate(trigger_encntrid)=1)
  SET eid = trigger_encntrid
 ELSE
  SET eid =  $ENCOUNTER_ID
 ENDIF
 SET curr_user = reqinfo->updt_id
 SET opt_list_type = trim( $LIST,3)
 CALL echo(curr_user)
 DECLARE tempval = vc WITH noconstant(" ")
 DECLARE listvals = vc WITH noconstant(" ")
 DECLARE log_message = vc
 SET log_message = "relationship NOT Found"
 SET x = 0
 SET listvals = "c.display_key in ("
 CALL echo("parseList")
 WHILE (x < 100
  AND x != 100)
   SET x = (x+ 1)
   SET tempval = piece(opt_list_type,"|",x,"1",0)
   IF (tempval="1"
    AND x=1)
    SET listvals = build(listvals,"'",trim(opt_list_type,3),"'")
   ELSEIF (tempval != "1")
    IF (x > 1)
     SET listvals = build(listvals,",")
    ENDIF
    SET listvals = build(listvals,"'",trim(tempval,3),"'")
   ELSE
    SET x = 100
   ENDIF
 ENDWHILE
 SET listvals = replace(listvals,"''","'")
 SET listvals = build(listvals,")")
 CALL echo(listvals)
 SET retval = 0
 CALL echo("check relationship")
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   code_value c
  PLAN (epr
   WHERE epr.encntr_id=eid
    AND epr.prsnl_person_id=curr_user
    AND epr.active_ind=1)
   JOIN (c
   WHERE c.code_value=epr.encntr_prsnl_r_cd
    AND c.code_set=333
    AND c.active_ind=1
    AND parser(listvals))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET log_message = "relationship Found"
  SET retval = 100
 ENDIF
 CALL echo(log_message)
END GO
