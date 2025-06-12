CREATE PROGRAM bed_get_profile_psn:dba
 FREE SET reply
 RECORD reply(
   1 plist[*]
     2 priv_loc_reltn_id = f8
     2 position_code_value = f8
     2 position_display = vc
     2 position_mean = vc
     2 updt_privilege_id = f8
     2 updt_priv_value_mean = vc
     2 updt_elist[*]
       3 privilege_exception_id = f8
       3 exception_id = f8
       3 exception_name = vc
       3 exception_entity_name = vc
     2 view_privilege_id = f8
     2 view_priv_value_mean = vc
     2 view_elist[*]
       3 privilege_exception_id = f8
       3 exception_id = f8
       3 exception_name = vc
       3 exception_entity_name = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 plist[*]
     2 priv_loc_reltn_id = f8
     2 position_code_value = f8
     2 position_display = vc
     2 position_mean = vc
     2 view_priv = vc
     2 view_privilege_id = f8
     2 view_elist[*]
       3 privilege_exception_id = f8
       3 priv_exception_id = f8
       3 priv_exception_name = vc
       3 exception_entity_name = vc
     2 updt_priv = vc
     2 updt_privilege_id = f8
     2 updt_elist[*]
       3 privilege_exception_id = f8
       3 priv_exception_id = f8
       3 priv_exception_name = vc
       3 exception_entity_name = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
 SET tot_count = 0
 SET count = 0
 SET tot_privcount = 0
 SET privcount = 0
 SET tot_ecount = 0
 SET ecount = 0
 SET last_priv_loc_reltn_id = 0.0
 SET yes_code_value = 0.0
 SET yes_cdf = fillstring(12," ")
 SET no_code_value = 0.0
 SET no_cdf = fillstring(12," ")
 SET inc_code_value = 0.0
 SET inc_cdf = fillstring(12," ")
 SET exc_code_value = 0.0
 SET exc_cdf = fillstring(12," ")
 DECLARE priv_mean1 = vc
 DECLARE priv_mean2 = vc
 DECLARE priv_cd1 = f8
 DECLARE priv_cd2 = f8
 SET in_synch = " "
 SET vecnt = 0
 SET uecnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6017
   AND cv.cdf_meaning IN ("YES", "INCLUDE", "EXCLUDE", "NO")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="YES")
    yes_code_value = cv.code_value, yes_cdf = cv.cdf_meaning
   ELSEIF (cv.cdf_meaning="INCLUDE")
    inc_code_value = cv.code_value, inc_cdf = cv.cdf_meaning
   ELSEIF (cv.cdf_meaning="EXCLUDE")
    exc_code_value = cv.code_value, exc_cdf = cv.cdf_meaning
   ELSEIF (cv.cdf_meaning="NO")
    no_code_value = cv.code_value, no_cdf = cv.cdf_meaning
   ENDIF
  WITH nocounter
 ;end select
 IF (((yes_code_value=0) OR (((no_code_value=0) OR (((inc_code_value=0) OR (exc_code_value=0)) )) ))
 )
  SET error_flag = "Y"
  SET error_msg = "Unable to find yes,include or exclude on cs 6017"
  GO TO exit_script
 ENDIF
 IF ((request->profile_mean="ALLERGY"))
  SET priv_mean1 = "VIEWALLERGY"
  SET priv_mean2 = "UPDTALLERGY"
 ELSEIF ((request->profile_mean="PROCEDURE"))
  SET priv_mean1 = "VIEWPROCHIS"
  SET priv_mean2 = "UPDTPROCHIS"
 ELSEIF ((request->profile_mean="PROBLEMCLASS"))
  SET priv_mean1 = "VIEWPROB"
  SET priv_mean2 = "UPDATEPROB"
 ELSEIF ((request->profile_mean="PROBLEM"))
  SET priv_mean1 = "VIEWPROBNOM"
  SET priv_mean2 = "UPDTPROBNOM"
 ELSEIF ((request->profile_mean="CLINDIAG"))
  SET priv_mean1 = "VIEWDIAGSEL"
  SET priv_mean2 = "UPDTDIAGSEL"
 ELSEIF ((request->profile_mean="ORDER"))
  SET priv_mean1 = "ORDER"
  SET priv_mean2 = "VIEWORDER"
 ENDIF
 SET view_priv_cd = 0
 SET updt_priv_cd = 0
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6016
    AND cv.cdf_meaning IN (priv_mean1, priv_mean2))
  HEAD cv.code_value
   IF (cv.cdf_meaning="VIEW*")
    view_priv_cd = cv.code_value
   ELSE
    updt_priv_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (((updt_priv_cd=0) OR (view_priv_cd=0)) )
  SET error_flag = "Y"
  SET error_msg = concat("Unable to find cs 6016 entry for ",priv_mean1," or ",priv_mean2)
  GO TO exit_script
 ENDIF
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM code_value cv,
   priv_loc_reltn plr
  PLAN (cv
   WHERE cv.code_set=88
    AND cv.active_ind=1)
   JOIN (plr
   WHERE plr.position_cd=outerjoin(cv.code_value))
  ORDER BY cv.display, cv.code_value
  HEAD REPORT
   tcnt = 0
  HEAD cv.code_value
   tcnt = (tcnt+ 1), stat = alterlist(temp->plist,tcnt), temp->plist[tcnt].position_code_value = cv
   .code_value,
   temp->plist[tcnt].position_display = cv.display, temp->plist[tcnt].position_mean = cv.cdf_meaning
   IF (plr.priv_loc_reltn_id > 0)
    temp->plist[tcnt].priv_loc_reltn_id = plr.priv_loc_reltn_id
   ELSE
    temp->plist[tcnt].priv_loc_reltn_id = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (tcnt=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = tcnt),
   privilege priv
  PLAN (d)
   JOIN (priv
   WHERE (priv.priv_loc_reltn_id=temp->plist[d.seq].priv_loc_reltn_id)
    AND priv.privilege_cd=view_priv_cd)
  DETAIL
   IF (priv.privilege_id > 0)
    temp->plist[d.seq].view_privilege_id = priv.privilege_id
    IF (priv.priv_value_cd=yes_code_value)
     temp->plist[d.seq].view_priv = "YES"
    ELSEIF (priv.priv_value_cd=inc_code_value)
     temp->plist[d.seq].view_priv = "INCLUDE"
    ELSEIF (priv.priv_value_cd=exc_code_value)
     temp->plist[d.seq].view_priv = "EXCLUDE"
    ELSE
     temp->plist[d.seq].view_priv = "NO"
    ENDIF
   ELSE
    temp->plist[d.seq].view_priv = "YES"
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = tcnt),
   privilege priv
  PLAN (d)
   JOIN (priv
   WHERE (priv.priv_loc_reltn_id=temp->plist[d.seq].priv_loc_reltn_id)
    AND priv.privilege_cd=updt_priv_cd)
  DETAIL
   IF (priv.privilege_id > 0)
    temp->plist[d.seq].updt_privilege_id = priv.privilege_id
    IF (priv.priv_value_cd=yes_code_value)
     temp->plist[d.seq].updt_priv = "YES"
    ELSEIF (priv.priv_value_cd=inc_code_value)
     temp->plist[d.seq].updt_priv = "INCLUDE"
    ELSEIF (priv.priv_value_cd=exc_code_value)
     temp->plist[d.seq].updt_priv = "EXCLUDE"
    ELSE
     temp->plist[d.seq].updt_priv = "NO"
    ENDIF
   ELSE
    temp->plist[d.seq].updt_priv = "YES"
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 IF ((request->profile_mode IN (1, 3, 4)))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tcnt),
    privilege_exception pe,
    (dummyt d2  WITH seq = 1),
    nomenclature n,
    code_value cv
   PLAN (d
    WHERE (temp->plist[d.seq].updt_priv IN ("INCLUDE", "EXCLUDE")))
    JOIN (pe
    WHERE (pe.privilege_id=temp->plist[d.seq].updt_privilege_id))
    JOIN (d2)
    JOIN (((n
    WHERE n.nomenclature_id=pe.exception_id
     AND pe.exception_entity_name="NOMENCLATURE")
    ) ORJOIN ((cv
    WHERE cv.code_value=pe.exception_id
     AND pe.exception_entity_name IN ("CLASSIFICATION", "ORDER CATALOG", "CATALOG TYPE",
    "ACTIVITY TYPE"))
    ))
   ORDER BY d.seq, pe.exception_id
   HEAD d.seq
    ecnt = 0
   DETAIL
    ecnt = (ecnt+ 1), stat = alterlist(temp->plist[d.seq].updt_elist,ecnt), temp->plist[d.seq].
    updt_elist[ecnt].privilege_exception_id = pe.privilege_exception_id,
    temp->plist[d.seq].updt_elist[ecnt].priv_exception_id = pe.exception_id, temp->plist[d.seq].
    updt_elist[ecnt].exception_entity_name = pe.exception_entity_name
    CASE (pe.exception_entity_name)
     OF "NOMENCLATURE":
      temp->plist[d.seq].updt_elist[ecnt].priv_exception_name = n.source_string
     OF "CLASSIFICATION":
      temp->plist[d.seq].updt_elist[ecnt].priv_exception_name = cv.display
     OF "ORDER CATALOG":
      temp->plist[d.seq].updt_elist[ecnt].priv_exception_name = cv.display
     OF "CATALOG TYPE":
      temp->plist[d.seq].updt_elist[ecnt].priv_exception_name = cv.display
     OF "ACTIVITY TYPE":
      temp->plist[d.seq].updt_elist[ecnt].priv_exception_name = cv.display
    ENDCASE
   WITH nocounter, outerjoin = d2
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tcnt),
    privilege_exception pe,
    (dummyt d2  WITH seq = 1),
    nomenclature n,
    code_value cv
   PLAN (d
    WHERE (temp->plist[d.seq].view_priv IN ("INCLUDE", "EXCLUDE")))
    JOIN (pe
    WHERE (pe.privilege_id=temp->plist[d.seq].view_privilege_id))
    JOIN (d2)
    JOIN (((n
    WHERE n.nomenclature_id=pe.exception_id
     AND pe.exception_entity_name="NOMENCLATURE")
    ) ORJOIN ((cv
    WHERE cv.code_value=pe.exception_id
     AND pe.exception_entity_name IN ("CLASSIFICATION", "ORDER CATALOG", "CATALOG TYPE",
    "ACTIVITY TYPE"))
    ))
   ORDER BY d.seq, pe.exception_id
   HEAD d.seq
    ecnt = 0
   DETAIL
    ecnt = (ecnt+ 1), stat = alterlist(temp->plist[d.seq].view_elist,ecnt), temp->plist[d.seq].
    view_elist[ecnt].privilege_exception_id = pe.privilege_exception_id,
    temp->plist[d.seq].view_elist[ecnt].priv_exception_id = pe.exception_id, temp->plist[d.seq].
    view_elist[ecnt].exception_entity_name = pe.exception_entity_name
    CASE (pe.exception_entity_name)
     OF "NOMENCLATURE":
      temp->plist[d.seq].view_elist[ecnt].priv_exception_name = n.source_string
     OF "CLASSIFICATION":
      temp->plist[d.seq].view_elist[ecnt].priv_exception_name = cv.display
     OF "ORDER CATALOG":
      temp->plist[d.seq].view_elist[ecnt].priv_exception_name = cv.display
     OF "CATALOG TYPE":
      temp->plist[d.seq].view_elist[ecnt].priv_exception_name = cv.display
     OF "ACTIVITY TYPE":
      temp->plist[d.seq].view_elist[ecnt].priv_exception_name = cv.display
    ENDCASE
   WITH nocounter, outerjoin = d2
  ;end select
 ENDIF
 SET rcnt = 0
 FOR (x = 1 TO tcnt)
   IF ((request->profile_mode=0))
    IF ((temp->plist[x].view_priv="YES")
     AND (temp->plist[x].updt_priv="YES"))
     SET rcnt = (rcnt+ 1)
     SET stat = alterlist(reply->plist,rcnt)
     SET reply->plist[rcnt].position_code_value = temp->plist[x].position_code_value
     SET reply->plist[rcnt].position_display = temp->plist[x].position_display
     SET reply->plist[rcnt].position_mean = temp->plist[x].position_mean
     SET reply->plist[rcnt].priv_loc_reltn_id = temp->plist[x].priv_loc_reltn_id
     SET reply->plist[rcnt].updt_priv_value_mean = "YES"
     SET reply->plist[rcnt].view_priv_value_mean = "YES"
     SET reply->plist[rcnt].updt_privilege_id = temp->plist[x].updt_privilege_id
     SET reply->plist[rcnt].view_privilege_id = temp->plist[x].view_privilege_id
    ENDIF
   ELSEIF ((request->profile_mode=1))
    IF ((((temp->plist[x].view_priv="INCLUDE")
     AND (temp->plist[x].updt_priv="INCLUDE")) OR ((temp->plist[x].view_priv="EXCLUDE")
     AND (temp->plist[x].updt_priv="EXCLUDE"))) )
     SET in_synch = "Y"
     SET vecnt = size(temp->plist[x].view_elist,5)
     SET uecnt = size(temp->plist[x].updt_elist,5)
     IF (vecnt=uecnt)
      FOR (y = 1 TO vecnt)
        IF ((temp->plist[x].view_elist[y].priv_exception_id != temp->plist[x].updt_elist[y].
        priv_exception_id))
         SET in_synch = "N"
         SET y = (vecnt+ 1)
        ENDIF
      ENDFOR
     ELSE
      SET in_synch = "N"
     ENDIF
     IF (in_synch="Y")
      SET rcnt = (rcnt+ 1)
      SET stat = alterlist(reply->plist,rcnt)
      SET reply->plist[rcnt].position_code_value = temp->plist[x].position_code_value
      SET reply->plist[rcnt].position_display = temp->plist[x].position_display
      SET reply->plist[rcnt].position_mean = temp->plist[x].position_mean
      SET reply->plist[rcnt].priv_loc_reltn_id = temp->plist[x].priv_loc_reltn_id
      SET reply->plist[rcnt].updt_priv_value_mean = temp->plist[x].updt_priv
      SET reply->plist[rcnt].view_priv_value_mean = temp->plist[x].view_priv
      SET reply->plist[rcnt].updt_privilege_id = temp->plist[x].updt_privilege_id
      SET reply->plist[rcnt].view_privilege_id = temp->plist[x].view_privilege_id
      SET stat = alterlist(reply->plist[rcnt].view_elist,vecnt)
      FOR (y = 1 TO vecnt)
        SET reply->plist[rcnt].view_elist[y].privilege_exception_id = temp->plist[x].view_elist[y].
        privilege_exception_id
        SET reply->plist[rcnt].view_elist[y].exception_id = temp->plist[x].view_elist[y].
        priv_exception_id
        SET reply->plist[rcnt].view_elist[y].exception_name = temp->plist[x].view_elist[y].
        priv_exception_name
        SET reply->plist[rcnt].view_elist[y].exception_entity_name = temp->plist[x].view_elist[y].
        exception_entity_name
      ENDFOR
      SET stat = alterlist(reply->plist[rcnt].updt_elist,uecnt)
      FOR (y = 1 TO uecnt)
        SET reply->plist[rcnt].updt_elist[y].privilege_exception_id = temp->plist[x].updt_elist[y].
        privilege_exception_id
        SET reply->plist[rcnt].updt_elist[y].exception_id = temp->plist[x].updt_elist[y].
        priv_exception_id
        SET reply->plist[rcnt].updt_elist[y].exception_name = temp->plist[x].updt_elist[y].
        priv_exception_name
        SET reply->plist[rcnt].updt_elist[y].exception_entity_name = temp->plist[x].updt_elist[y].
        exception_entity_name
      ENDFOR
     ENDIF
    ENDIF
   ELSEIF ((request->profile_mode=2))
    IF ((temp->plist[x].view_priv="YES")
     AND (temp->plist[x].updt_priv="NO"))
     SET rcnt = (rcnt+ 1)
     SET stat = alterlist(reply->plist,rcnt)
     SET reply->plist[rcnt].position_code_value = temp->plist[x].position_code_value
     SET reply->plist[rcnt].position_display = temp->plist[x].position_display
     SET reply->plist[rcnt].position_mean = temp->plist[x].position_mean
     SET reply->plist[rcnt].priv_loc_reltn_id = temp->plist[x].priv_loc_reltn_id
     SET reply->plist[rcnt].updt_priv_value_mean = "NO"
     SET reply->plist[rcnt].view_priv_value_mean = "YES"
     SET reply->plist[rcnt].updt_privilege_id = temp->plist[x].updt_privilege_id
     SET reply->plist[rcnt].view_privilege_id = temp->plist[x].view_privilege_id
    ENDIF
   ELSEIF ((request->profile_mode=3))
    IF ((temp->plist[x].updt_priv="NO")
     AND (((temp->plist[x].view_priv="EXCLUDE")) OR ((temp->plist[x].view_priv="INCLUDE"))) )
     SET rcnt = (rcnt+ 1)
     SET stat = alterlist(reply->plist,rcnt)
     SET reply->plist[rcnt].position_code_value = temp->plist[x].position_code_value
     SET reply->plist[rcnt].position_display = temp->plist[x].position_display
     SET reply->plist[rcnt].position_mean = temp->plist[x].position_mean
     SET reply->plist[rcnt].priv_loc_reltn_id = temp->plist[x].priv_loc_reltn_id
     SET reply->plist[rcnt].updt_priv_value_mean = temp->plist[x].updt_priv
     SET reply->plist[rcnt].view_priv_value_mean = temp->plist[x].view_priv
     SET reply->plist[rcnt].updt_privilege_id = temp->plist[x].updt_privilege_id
     SET reply->plist[rcnt].view_privilege_id = temp->plist[x].view_privilege_id
     SET vecnt = size(temp->plist[x].view_elist,5)
     SET stat = alterlist(reply->plist[rcnt].view_elist,vecnt)
     FOR (y = 1 TO vecnt)
       SET reply->plist[rcnt].view_elist[y].privilege_exception_id = temp->plist[x].view_elist[y].
       privilege_exception_id
       SET reply->plist[rcnt].view_elist[y].exception_id = temp->plist[x].view_elist[y].
       priv_exception_id
       SET reply->plist[rcnt].view_elist[y].exception_name = temp->plist[x].view_elist[y].
       priv_exception_name
       SET reply->plist[rcnt].view_elist[y].exception_entity_name = temp->plist[x].view_elist[y].
       exception_entity_name
     ENDFOR
    ENDIF
   ELSEIF ((request->profile_mode=4))
    IF ((((temp->plist[x].view_priv="NO")
     AND (temp->plist[x].updt_priv != "NO")) OR ((((temp->plist[x].view_priv="YES")
     AND (temp->plist[x].updt_priv IN ("INCLUDE", "EXCLUDE"))) OR ((((temp->plist[x].view_priv=
    "INCLUDE")
     AND (temp->plist[x].updt_priv IN ("EXCLUDE", "YES"))) OR ((((temp->plist[x].view_priv="EXCLUDE")
     AND (temp->plist[x].updt_priv IN ("INCLUDE", "YES"))) OR ((((temp->plist[x].updt_priv="EXCLUDE")
     AND (temp->plist[x].view_priv != "EXCLUDE")) OR ((temp->plist[x].updt_priv="INCLUDE")
     AND (temp->plist[x].view_priv != "INCLUDE"))) )) )) )) )) )
     SET vecnt = size(temp->plist[x].view_elist,5)
     SET uecnt = size(temp->plist[x].updt_elist,5)
     SET rcnt = (rcnt+ 1)
     SET stat = alterlist(reply->plist,rcnt)
     SET reply->plist[rcnt].position_code_value = temp->plist[x].position_code_value
     SET reply->plist[rcnt].position_display = temp->plist[x].position_display
     SET reply->plist[rcnt].position_mean = temp->plist[x].position_mean
     SET reply->plist[rcnt].priv_loc_reltn_id = temp->plist[x].priv_loc_reltn_id
     SET reply->plist[rcnt].updt_priv_value_mean = temp->plist[x].updt_priv
     SET reply->plist[rcnt].view_priv_value_mean = temp->plist[x].view_priv
     SET reply->plist[rcnt].updt_privilege_id = temp->plist[x].updt_privilege_id
     SET reply->plist[rcnt].view_privilege_id = temp->plist[x].view_privilege_id
     IF (vecnt > 0)
      SET stat = alterlist(reply->plist[rcnt].view_elist,vecnt)
      FOR (y = 1 TO vecnt)
        SET reply->plist[rcnt].view_elist[y].privilege_exception_id = temp->plist[x].view_elist[y].
        privilege_exception_id
        SET reply->plist[rcnt].view_elist[y].exception_id = temp->plist[x].view_elist[y].
        priv_exception_id
        SET reply->plist[rcnt].view_elist[y].exception_name = temp->plist[x].view_elist[y].
        priv_exception_name
        SET reply->plist[rcnt].view_elist[y].exception_entity_name = temp->plist[x].view_elist[y].
        exception_entity_name
      ENDFOR
     ENDIF
     IF (uecnt > 0)
      SET stat = alterlist(reply->plist[rcnt].updt_elist,uecnt)
      FOR (y = 1 TO uecnt)
        SET reply->plist[rcnt].updt_elist[y].privilege_exception_id = temp->plist[x].updt_elist[y].
        privilege_exception_id
        SET reply->plist[rcnt].updt_elist[y].exception_id = temp->plist[x].updt_elist[y].
        priv_exception_id
        SET reply->plist[rcnt].updt_elist[y].exception_name = temp->plist[x].updt_elist[y].
        priv_exception_name
        SET reply->plist[rcnt].updt_elist[y].exception_entity_name = temp->plist[x].updt_elist[y].
        exception_entity_name
      ENDFOR
     ENDIF
    ELSEIF ((((temp->plist[x].view_priv="INCLUDE")
     AND (temp->plist[x].updt_priv="INCLUDE")) OR ((temp->plist[x].view_priv="EXCLUDE")
     AND (temp->plist[x].updt_priv="EXCLUDE"))) )
     SET in_synch = "Y"
     SET vecnt = size(temp->plist[x].view_elist,5)
     SET uecnt = size(temp->plist[x].updt_elist,5)
     IF (vecnt=uecnt)
      FOR (y = 1 TO vecnt)
        IF ((temp->plist[x].view_elist[y].priv_exception_id != temp->plist[x].updt_elist[y].
        priv_exception_id))
         SET in_synch = "N"
         SET y = (vecnt+ 1)
        ENDIF
      ENDFOR
     ELSE
      SET in_synch = "N"
     ENDIF
     IF (in_synch="N")
      SET rcnt = (rcnt+ 1)
      SET stat = alterlist(reply->plist,rcnt)
      SET reply->plist[rcnt].position_code_value = temp->plist[x].position_code_value
      SET reply->plist[rcnt].position_display = temp->plist[x].position_display
      SET reply->plist[rcnt].position_mean = temp->plist[x].position_mean
      SET reply->plist[rcnt].priv_loc_reltn_id = temp->plist[x].priv_loc_reltn_id
      SET reply->plist[rcnt].updt_priv_value_mean = temp->plist[x].updt_priv
      SET reply->plist[rcnt].view_priv_value_mean = temp->plist[x].view_priv
      SET reply->plist[rcnt].updt_privilege_id = temp->plist[x].updt_privilege_id
      SET reply->plist[rcnt].view_privilege_id = temp->plist[x].view_privilege_id
      SET stat = alterlist(reply->plist[rcnt].view_elist,vecnt)
      FOR (y = 1 TO vecnt)
        SET reply->plist[rcnt].view_elist[y].privilege_exception_id = temp->plist[x].view_elist[y].
        privilege_exception_id
        SET reply->plist[rcnt].view_elist[y].exception_id = temp->plist[x].view_elist[y].
        priv_exception_id
        SET reply->plist[rcnt].view_elist[y].exception_name = temp->plist[x].view_elist[y].
        priv_exception_name
        SET reply->plist[rcnt].view_elist[y].exception_entity_name = temp->plist[x].view_elist[y].
        exception_entity_name
      ENDFOR
      SET stat = alterlist(reply->plist[rcnt].updt_elist,uecnt)
      FOR (y = 1 TO uecnt)
        SET reply->plist[rcnt].updt_elist[y].privilege_exception_id = temp->plist[x].updt_elist[y].
        privilege_exception_id
        SET reply->plist[rcnt].updt_elist[y].exception_id = temp->plist[x].updt_elist[y].
        priv_exception_id
        SET reply->plist[rcnt].updt_elist[y].exception_name = temp->plist[x].updt_elist[y].
        priv_exception_name
        SET reply->plist[rcnt].updt_elist[y].exception_entity_name = temp->plist[x].updt_elist[y].
        exception_entity_name
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 IF (rcnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reply->error_msg = error_msg
 ENDIF
 CALL echorecord(reply)
END GO
