CREATE PROGRAM ams_get_app_context:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Username" = "",
  "Enter Start Date" = "CURDATE",
  "Enter End Date" = "CURDATE",
  "Select Application" = 0
  WITH outdev, username, startdate,
  enddate, app
 DECLARE sbegdate = vc WITH protect, constant(trim( $STARTDATE))
 DECLARE senddate = vc WITH protect, constant(concat(trim( $ENDDATE,3)," 23:59:59"))
 DECLARE prog_name = vc
 DECLARE in_domain = f8
 DECLARE logical_domain_id = f8
 SET prog_name = "AMS_GET_APP_CONTEXT"
 SET in_domain = 0
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE (p.username= $USERNAME)
  DETAIL
   logical_domain_id = p.logical_domain_id
  WITH nocounter
 ;end select
 SET in_domain = isuserindomain(reqinfo->updt_id,logical_domain_id)
 IF (in_domain IN (- (1), 1))
  SELECT
   IF (( $APP > 0))
    PLAN (ac
     WHERE (ac.username= $USERNAME)
      AND ac.start_dt_tm >= cnvtdatetime(sbegdate)
      AND ac.start_dt_tm <= cnvtdatetime(senddate)
      AND ((ac.application_number+ 0)= $APP))
   ELSE
    PLAN (ac
     WHERE (ac.username= $USERNAME)
      AND ac.start_dt_tm >= cnvtdatetime(sbegdate)
      AND ac.start_dt_tm <= cnvtdatetime(senddate))
   ENDIF
   INTO  $OUTDEV
   ac.username, ac.application_number, ac.application_image,
   ac.client_node_name, ac.logdirectory, ac.start_dt_tm,
   ac.end_dt_tm, ac.client_start_dt_tm
   FROM application_context ac
   PLAN (ac
    WHERE (ac.username= $USERNAME)
     AND ac.start_dt_tm >= cnvtdatetime(sbegdate)
     AND ac.start_dt_tm <= cnvtdatetime(senddate))
   ORDER BY ac.start_dt_tm
   WITH format(date,"mm/dd/yyyy hh:mm:ss;;q"), format, separator = " "
  ;end select
  CALL updtdminfo(prog_name)
 ELSE
  SELECT INTO  $1
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "NO USERS QUALIFIED"
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
 SUBROUTINE column_exists(stable,scolumn)
   DECLARE ce_flag = i4
   SET ce_flag = 0
   DECLARE ce_temp = vc WITH noconstant("")
   SET stable = cnvtupper(stable)
   SET scolumn = cnvtupper(scolumn)
   IF (((currev=8
    AND currevminor=2
    AND currevminor2 >= 4) OR (((currev=8
    AND currevminor > 2) OR (currev > 8)) )) )
    SET ce_temp = build('"',stable,".",scolumn,'"')
    SET stat = checkdic(parser(ce_temp),"A",0)
    IF (stat > 0)
     SET ce_flag = 1
    ENDIF
    SELECT INTO "nl:"
     l.attr_name
     FROM dtableattr a,
      dtableattrl l
     WHERE a.table_name=stable
      AND l.attr_name=scolumn
      AND l.structtype="F"
      AND btest(l.stat,11)=0
     DETAIL
      ce_flag = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(ce_flag)
 END ;Subroutine
 DECLARE isuserindomain(user_id=f8,log_domain_id=f8) = i2
 SUBROUTINE isuserindomain(user_id,log_domain_id)
   DECLARE return_val = i2 WITH noconstant(- (1)), protect
   DECLARE b_logicaldomain = i4 WITH constant(column_exists("PRSNL","LOGICAL_DOMAIN_ID")), protect
   DECLARE user_domain_grp_id = f8 WITH noconstant(0.0), protect
   IF (b_logicaldomain)
    SELECT INTO "nl:"
     FROM prsnl p
     PLAN (p
      WHERE (p.person_id=reqinfo->updt_id))
     HEAD p.person_id
      user_domain_grp_id = p.logical_domain_grp_id
      IF (user_domain_grp_id=0.0)
       IF (p.logical_domain_id=log_domain_id)
        return_val = 1
       ELSE
        return_val = 0
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (user_domain_grp_id > 0.0)
     SELECT INTO "nl:"
      FROM logical_domain_grp_reltn ld
      PLAN (ld
       WHERE ld.logical_domain_grp_id=user_domain_grp_id
        AND ld.active_ind=1
        AND ld.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND ld.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      HEAD ld.logical_domain_grp_id
       return_val = 0
      HEAD ld.logical_domain_id
       IF (ld.logical_domain_id=log_domain_id)
        return_val = 1
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
END GO
