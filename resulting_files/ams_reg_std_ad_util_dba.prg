CREATE PROGRAM ams_reg_std_ad_util:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encounter Type" = 0,
  "All Facilities?" = "",
  "Facility" = 0,
  "Enter number of days after the date in the Start Field to wait until Auto Discharge" = 0,
  "Start Field" = "",
  "End Field" = "",
  "Discharge Date Value" = 0,
  "Discharge Disposition" = 0,
  "Send Auto Discharge Transactions Outbound?" = 0
  WITH outdev, etype, global,
  fac, days, sfield,
  efield, endval, dispo,
  outbound
 SET fac_cnt = 0
 SET i = 0
 FREE RECORD orgs
 RECORD orgs(
   1 list[*]
     2 org_id = f8
 )
 SET enct = cnvtstring( $ETYPE)
 SET ddays = cnvtstring( $DAYS)
 SET start =  $SFIELD
 SET ending =  $EFIELD
 SET enval = cnvtstring( $ENDVAL)
 SET ddisp = cnvtstring( $DISPO)
 SET outind = cnvtstring( $OUTBOUND)
 DECLARE amsuser(prsnl_id=f8) = i2
 DECLARE updtdminfo(prog_name=vc) = null
 DECLARE sprogramname = vc WITH protect, constant("AMS_REG_STD_AD_UTIL")
 DECLARE run_ind = i2 WITH protect, noconstant(false)
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
 CALL updtdminfo(sprogramname)
 IF (( $GLOBAL="NO"))
  SELECT INTO "nl:"
   o.organization_id
   FROM organization o
   WHERE (o.organization_id= $FAC)
   DETAIL
    fac_cnt = (fac_cnt+ 1), stat = alterlist(orgs->list,fac_cnt), orgs->list[fac_cnt].org_id = o
    .organization_id
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   d.seq
   FROM dummyt d
   DETAIL
    fac_cnt = 1, stat = alterlist(orgs->list,fac_cnt), orgs->list[fac_cnt].org_id = 0
   WITH nocounter
  ;end select
 ENDIF
 FOR (ifdx = 1 TO fac_cnt)
   SELECT INTO "nl:"
    FROM encntr_type_params etp
    PLAN (etp
     WHERE (etp.encntr_type_cd= $ETYPE)
      AND (etp.organization_id=orgs->list[ifdx].org_id)
      AND etp.param_name="AUTO_DISCH_DAYS")
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM encntr_type_params etp
     SET etp.encntr_type_cd =  $ETYPE, etp.organization_id = orgs->list[i].org_id, etp.param_name =
      "AUTO_DISCH_DAYS",
      etp.value_nbr =  $DAYS, etp.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), etp
      .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 0")
     WITH nocounter
    ;end insert
    COMMIT
   ELSE
    UPDATE  FROM encntr_type_params etp
     SET etp.value_nbr =  $DAYS, etp.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), etp
      .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 0")
     PLAN (etp
      WHERE (etp.encntr_type_cd= $ETYPE)
       AND (etp.organization_id=orgs->list[i].org_id)
       AND etp.param_name="AUTO_DISCH_DAYS")
     WITH nocounter
    ;end update
    COMMIT
   ENDIF
   SELECT INTO "nl:"
    FROM encntr_type_params etp
    PLAN (etp
     WHERE (etp.encntr_type_cd= $ETYPE)
      AND (etp.organization_id=orgs->list[i].org_id)
      AND etp.param_name="AUTO_DISCH_START_FIELD")
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM encntr_type_params etp
     SET etp.encntr_type_cd =  $ETYPE, etp.organization_id = orgs->list[i].org_id, etp.param_name =
      "AUTO_DISCH_START_FIELD",
      etp.value_string =  $SFIELD, etp.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), etp
      .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 0")
     WITH nocounter
    ;end insert
    COMMIT
   ELSE
    UPDATE  FROM encntr_type_params etp
     SET etp.value_string =  $SFIELD, etp.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), etp
      .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 0")
     PLAN (etp
      WHERE (etp.encntr_type_cd= $ETYPE)
       AND (etp.organization_id=orgs->list[i].org_id)
       AND etp.param_name="AUTO_DISCH_START_FIELD")
     WITH nocounter
    ;end update
    COMMIT
   ENDIF
   SELECT INTO "nl:"
    FROM encntr_type_params etp
    PLAN (etp
     WHERE (etp.encntr_type_cd= $ETYPE)
      AND (etp.organization_id=orgs->list[i].org_id)
      AND etp.param_name="AUTO_DISCH_END_FIELD")
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM encntr_type_params etp
     SET etp.encntr_type_cd =  $ETYPE, etp.organization_id = orgs->list[i].org_id, etp.param_name =
      "AUTO_DISCH_END_FIELD",
      etp.value_string =  $EFIELD, etp.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), etp
      .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 0")
     WITH nocounter
    ;end insert
    COMMIT
   ELSE
    UPDATE  FROM encntr_type_params etp
     SET etp.value_string =  $EFIELD, etp.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), etp
      .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 0")
     PLAN (etp
      WHERE (etp.encntr_type_cd= $ETYPE)
       AND (etp.organization_id=orgs->list[i].org_id)
       AND etp.param_name="AUTO_DISCH_END_FIELD")
     WITH nocounter
    ;end update
    COMMIT
   ENDIF
   SELECT INTO "nl:"
    FROM encntr_type_params etp
    PLAN (etp
     WHERE (etp.encntr_type_cd= $ETYPE)
      AND (etp.organization_id=orgs->list[i].org_id)
      AND etp.param_name="AUTO_DISCH_END_VALUE")
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM encntr_type_params etp
     SET etp.encntr_type_cd =  $ETYPE, etp.organization_id = orgs->list[i].org_id, etp.param_name =
      "AUTO_DISCH_END_VALUE",
      etp.value_nbr =  $ENDVAL, etp.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), etp
      .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 0")
     WITH nocounter
    ;end insert
    COMMIT
   ELSE
    UPDATE  FROM encntr_type_params etp
     SET etp.value_nbr =  $ENDVAL, etp.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), etp
      .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 0")
     PLAN (etp
      WHERE (etp.encntr_type_cd= $ETYPE)
       AND (etp.organization_id=orgs->list[i].org_id)
       AND etp.param_name="AUTO_DISCH_END_VALUE")
     WITH nocounter
    ;end update
    COMMIT
   ENDIF
   SELECT INTO "nl:"
    FROM encntr_type_params etp
    PLAN (ept
     WHERE (etp.encntr_type_cd= $ETYPE)
      AND (etp.organization_id=orgs->list[i].org_id)
      AND etp.param_name="AUTO_DISCH_DISP_VALUE")
    WITH nocounter
   ;end select
   IF (curqual=0
    AND ( $DISPO > 0))
    INSERT  FROM encntr_type_params etp
     SET etp.encntr_type_cd =  $ETYPE, etp.organization_id = orgs->list[i].org_id, etp.param_name =
      "AUTO_DISCH_DISP_VALUE",
      etp.value_cd =  $DISPO, etp.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), etp
      .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 0")
     WITH nocounter
    ;end insert
    COMMIT
   ELSEIF (( $DISPO > 0))
    UPDATE  FROM encntr_type_params etp
     SET etp.value_cd =  $DISPO, etp.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), etp
      .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 0")
     PLAN (etp
      WHERE (etp.encntr_type_cd= $ETYPE)
       AND (etp.organization_id=orgs->list[i].org_id)
       AND etp.param_name="AUTO_DISCH_DISP_VALUE")
     WITH nocounter
    ;end update
    COMMIT
   ELSE
    DELETE  FROM encntr_type_params etp
     PLAN (etp
      WHERE etp.param_name="AUTO_DISCH_DISP_VALUE"
       AND (etp.encntr_type_cd= $ETYPE)
       AND (etp.organization_id=orgs->list[i].org_id))
     WITH nocounter
    ;end delete
    COMMIT
   ENDIF
   IF (( $OUTBOUND=1))
    SELECT INTO "nl:"
     FROM encntr_type_params etp
     PLAN (ept
      WHERE (etp.encntr_type_cd= $ETYPE)
       AND etp.param_name="AUTO_DISCH_OUTBOUND_IND")
     WITH nocounter
    ;end select
    IF (curqual=0)
     INSERT  FROM encntr_type_params etp
      SET etp.encntr_type_cd =  $ETYPE, etp.organization_id = 0, etp.param_name =
       "AUTO_DISCH_OUTBOUND_IND",
       etp.value_nbr = 1, etp.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), etp
       .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 0")
      WITH nocounter
     ;end insert
     COMMIT
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM encntr_type_params etp
     PLAN (etp
      WHERE (etp.encntr_type_cd= $ETYPE)
       AND etp.param_name="AUTO_DISCH_OUTBOUND_IND")
     WITH nocounter
    ;end select
    IF (curqual > 0)
     DELETE  FROM encntr_type_params etp
      PLAN (etp
       WHERE (etp.encntr_type_cd= $ETYPE)
        AND etp.param_name="AUTO_DISCH_OUTBOUND_IND")
      WITH nocounter
     ;end delete
     COMMIT
    ENDIF
   ENDIF
 ENDFOR
 SELECT INTO  $OUTDEV
  d.seq
  FROM dummyt d
  HEAD REPORT
   row + 1, col 1, "Encounter Type",
   col 20, "Org", col 25,
   "DAYS", col 30, "START_FIELD",
   col 50, "END_FIELD", col 70,
   "END_VALUE", col 100, "DISP_VALUE",
   col 126, "OUTBOUND_IND", row + 1,
   col 5,
"__________________________________________________________________________________________________________________________\
_____\
", row + 1
  DETAIL
   FOR (i = 1 TO fac_cnt)
     row + 1, col 1, enct,
     col 10, orgs->list[i].org_id, col 25,
     ddays, col 30, start,
     col 50, ending, col 70,
     enval, col 100, ddisp,
     col 126, outind, row + 1
   ENDFOR
  WITH nocounter, landscape, maxcol = 140,
   maxrow = 45
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
     SET d.info_domain = "AMS_TOOLKIT", d.info_name = a_prog_name, d.info_date = cnvtdatetime(curdate,
       curtime3),
      d.info_number = 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info d
     SET d.info_number = info_nbr
     WHERE d.info_domain="AMS_TOOLKIT"
      AND d.info_name=a_prog_name
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
#exit_script
END GO
