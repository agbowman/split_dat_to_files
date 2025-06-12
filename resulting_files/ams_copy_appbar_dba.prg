CREATE PROGRAM ams_copy_appbar:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Username to copy from" = "",
  "Select the Position to copy to" = 0,
  "Select the USERS" = 0
  WITH outdev, username, position,
  users
 RECORD rinidata(
   1 parameter_data = c32000
   1 application = i4
   1 domain = vc
 )
 RECORD rusers(
   1 position[*]
     2 person_id = f8
     2 username = vc
 )
 DECLARE amsuser(prsnl_id=f8) = i2
 DECLARE updtdminfo(prog_name=vc) = null
 DECLARE sprogramname = vc WITH protect, constant("AMS_CORRUPTED_PT_LIST_FIX")
 DECLARE run_ind = i2 WITH protect, noconstant(false)
 DECLARE iknt = i4 WITH protect, noconstant(0)
 SET run_ind = amsuser(reqinfo->updt_id)
 IF (run_ind=false)
  SELECT INTO  $OUTDEV
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "THIS PROGRAM IS INTENDED FOR USE BY AMS ASSOCIATES ONLY"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  a.parameter_data, a.application_number, a.section
  FROM application_ini a
  PLAN (a
   WHERE (a.person_id=
   (SELECT
    p.person_id
    FROM prsnl p
    WHERE p.username=value( $USERNAME)))
    AND a.application_number=9000)
  DETAIL
   rinidata->parameter_data = a.parameter_data, rinidata->application = a.application_number,
   rinidata->domain = substring((findstring(".",a.section)+ 1),50,a.section)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.person_id, p.username
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id= $USERS)
    AND (p.position_cd= $POSITION))
  HEAD REPORT
   iknt = 0
  DETAIL
   iknt = (iknt+ 1)
   IF (iknt > size(rusers->position,5))
    stat = alterlist(rusers->position,(iknt+ 4999))
   ENDIF
   rusers->position[iknt].person_id = p.person_id, rusers->position[iknt].username = p.username
  FOOT REPORT
   stat = alterlist(rusers->position,iknt)
  WITH maxqual(0,5000)
 ;end select
 FOR (ifdx = 1 TO iknt)
   UPDATE  FROM application_ini a
    SET a.parameter_data = rinidata->parameter_data, a.section = concat(rusers->position[ifdx].
      username,".",rinidata->domain), a.updt_cnt = (a.updt_cnt+ 1),
     a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (a
     WHERE (a.person_id=rusers->position[ifdx].person_id)
      AND a.application_number=9000
      AND a.section=concat(rusers->position[ifdx].username,".",rinidata->domain))
    WITH nocounter
   ;end update
   IF (curqual > 0)
    COMMIT
   ELSE
    INSERT  FROM application_ini a
     SET a.application_number = rinidata->application, a.parameter_data = rinidata->parameter_data, a
      .person_id = rusers->position[ifdx].person_id,
      a.section = concat(rusers->position[ifdx].username,".",rinidata->domain), a.updt_cnt = 0, a
      .updt_id = 0,
      a.updt_task = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
   ENDIF
   IF (mod(ifdx,100)=1)
    COMMIT
   ENDIF
 ENDFOR
 COMMIT
 CALL updtdminfo(sprogramname)
 SELECT INTO  $OUTDEV
  p.username, a.parameter_data, a.section,
  a.updt_cnt, a.updt_dt_tm"@SHORTDATETIME", p_position_disp = uar_get_code_display(p.position_cd),
  a.application_number
  FROM prsnl p,
   application_ini a
  PLAN (p
   WHERE (p.person_id= $USERS))
   JOIN (a
   WHERE a.person_id=p.person_id
    AND a.application_number=9000)
  WITH nocounter, format, separator = " "
 ;end select
 SUBROUTINE amsuser(a_prsnl_id)
   DECLARE user_ind = i2 WITH protect, noconstant(false)
   DECLARE prsnl_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",213,"PRSNL"))
   SELECT INTO "nl:"
    p.person_id
    FROM person_name p
    PLAN (p
     WHERE p.person_id=a_prsnl_id
      AND p.name_type_cd=prsnl_cd
      AND p.name_title="Cerner AMS"
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    DETAIL
     IF (p.person_id > 0)
      user_ind = true
     ENDIF
    WITH nocounter
   ;end select
   RETURN(user_ind)
 END ;Subroutine
 SUBROUTINE updtdminfo(a_prog_name)
   DECLARE found = i2 WITH protect, noconstant(false)
   DECLARE info_nbr = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dm_info d
    PLAN (d
     WHERE d.info_domain="AMS_TOOLKIT"
      AND d.info_name=a_prog_name)
    DETAIL
     found = true, info_nbr = (d.info_number+ 1)
    WITH nocounter
   ;end select
   IF (found=false)
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
#exit_script
 SET script_ver = "001  07/13/2012  Copy to AMS Standard"
END GO
