CREATE PROGRAM dm_import_prsnl:dba
 RECORD pool_cds(
   1 qual[7]
     2 cdf_meaning = c12
     2 alias_type_cd = f8
     2 alias_pool_cd = f8
 )
 RECORD reply(
   1 person_qual = i4
   1 person[*] = i4
     2 person_id = f8
   1 person_alias_qual = i4
   1 person_alias[*]
     2 person_alias_id = f8
   1 person_name_qual = i4
   1 person_name[*]
     2 person_name_id = f8
   1 person_info_qual = i4
   1 person_info[*]
     2 person_info_id = f8
   1 long_text_qual = i4
   1 long_text[10]
     2 long_text_id = f8
   1 address_qual = i4
   1 address[*] = i4
     2 address_id = f8
   1 phone_qual = i4
   1 phone[*] = i4
     2 phone_id = f8
   1 prsnl_qual = i4
   1 prsnl[*] = i4
     2 person_id = f8
   1 prsnl_alias_qual = i4
   1 prsnl_alias[*] = i4
     2 prsnl_alias_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD prsnl_alias_status(
   1 prsnl_alias_qual = i4
   1 prsnl_alias[10] = i4
     2 prsnl_alias_id = f8
     2 status = c1
     2 org_name = c40
     2 org_nbr = c20
     2 org_found = c1
 )
 RECORD org_rel_status(
   1 qual = i4
   1 list[100] = i4
     2 org_id = f8
     2 status = c1
     2 org_name = c40
     2 org_found = c1
     2 org_rel_found = c1
 )
 SET code_set = 0.0
 SET code_value = 0.0
 SET numorg = 0
 SET relorg = 0
 SET cdf_meaning = fillstring(12," ")
 SET org_name = fillstring(100," ")
 SET pool_cds->qual[1].cdf_meaning = "PRSNLID"
 SET pool_cds->qual[2].cdf_meaning = "EXTERNALID"
 SET pool_cds->qual[3].cdf_meaning = "DOCDEA"
 SET pool_cds->qual[4].cdf_meaning = "DOCUPIN"
 SET pool_cds->qual[5].cdf_meaning = "DOCNBR"
 SET pool_cds->qual[6].cdf_meaning = "DOCCNBR"
 SET reqinfo->updt_id = 0
 SET reqinfo->updt_applctx = 1
 SET reqinfo->updt_task = 1
 SET person_id = 0.0
 SET person_alias_id = 0.0
 SET current_person_name_id = 0.0
 SET prsnl_person_name_id = 0.0
 SET home_address_id = 0.0
 SET business_address_id = 0.0
 SET home_phone_id = 0.0
 SET business_phone_id = 0.0
 SET pers_pager_phone_id = 0.0
 SET bus_pager_phone_id = 0.0
 SET pers_fax_phone_id = 0.0
 SET bus_fax_phone_id = 0.0
 SET prsnlid_id = 0.0
 SET docdea_id = 0.0
 SET docupin_id = 0.0
 SET docnbr_id = 0.0
 SET asn_docnbr_id = 0.0
 SET doccnbr_id = 0.0
 SET person_type_cd = 0.0
 SET prsnl_type_cd = 0.0
 SET current_name_type_cd = 0.0
 SET prsnl_name_type_cd = 0.0
 SET home_address_type_cd = 0.0
 SET business_address_type_cd = 0.0
 SET home_phone_type_cd = 0.0
 SET business_phone_type_cd = 0.0
 SET bus_fax_phone_type_cd = 0.0
 SET bus_pgr_phone_type_cd = 0.0
 SET pers_fax_phone_type_cd = 0.0
 SET pers_pgr_phone_type_cd = 0.0
 SET person_ssn_alias_pool_cd = 0.0
 SET person_ssn_alias_type_cd = 0.0
 SET asn_org_alias_pool_cd = 0.0
 SET facility_cd = 0.0
 SET client_cd = 0.0
 SET prsnl_found = "N"
 SET prsnlid_found = "N"
 SET externalid_found = "N"
 SET docdea_found = "N"
 SET docupin_found = "N"
 SET docnbr_found = "N"
 SET doccnbr_found = "N"
 SET person_found = "N"
 SET person_ssn_alias_found = "N"
 SET current_person_name_found = "N"
 SET prsnl_person_name_found = "N"
 SET home_address_found = "N"
 SET business_address_found = "N"
 SET home_phone_found = "N"
 SET business_phone_found = "N"
 SET bus_fax_phone_found = "N"
 SET bus_pgr_phone_found = "N"
 SET pers_fax_phone_found = "N"
 SET pers_pgr_phone_found = "N"
 DECLARE usernamex = c100
 DECLARE passwordx = c100
 DECLARE home_address_pct_status = c1
 DECLARE home_address_dha_status = c1
 DECLARE business_address_pct_status = c1
 DECLARE business_address_dha_status = c1
 SET person_status = fillstring(1," ")
 SET person_ssn_alias_status = fillstring(1," ")
 SET prsnl_status = fillstring(1," ")
 SET person_name_status = fillstring(1," ")
 SET home_address_status = fillstring(1," ")
 SET home_address_pct_status = fillstring(1," ")
 SET home_address_dha_status = fillstring(1," ")
 SET business_address_status = fillstring(1," ")
 SET business_address_pct_status = fillstring(1," ")
 SET business_address_dha_status = fillstring(1," ")
 SET home_phone_status = fillstring(1," ")
 SET business_phone_status = fillstring(1," ")
 SET prsnlid_alias_status = fillstring(1," ")
 SET externalid_alias_status = fillstring(1," ")
 SET docdea_alias_status = fillstring(1," ")
 SET docupin_alias_status = fillstring(1," ")
 SET docnbr_alias_status = fillstring(1," ")
 SET doccnbr_alias_status = fillstring(1," ")
 SET code_set = 4
 SET cdf_meaning = "SSN"
 EXECUTE cpm_get_cd_for_cdf
 SET person_ssn_alias_type_cd = code_value
 SET code_set = 8
 SET cdf_meaning = "AUTH"
 EXECUTE cpm_get_cd_for_cdf
 SET reqdata->data_status_cd = code_value
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 SET reqdata->active_status_cd = code_value
 SET code_set = 48
 SET cdf_meaning = "INACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 SET reqdata->inactive_status_cd = code_value
 SET code_set = 302
 SET cdf_meaning = "PERSON"
 EXECUTE cpm_get_cd_for_cdf
 SET person_type_cd = code_value
 SET code_set = 309
 SET cdf_meaning = "USER"
 EXECUTE cpm_get_cd_for_cdf
 SET prsnl_type_cd = code_value
 SET code_set = 213
 SET cdf_meaning = "CURRENT"
 EXECUTE cpm_get_cd_for_cdf
 SET current_name_type_cd = code_value
 SET code_set = 213
 SET cdf_meaning = "PRSNL"
 EXECUTE cpm_get_cd_for_cdf
 SET prsnl_name_type_cd = code_value
 SET code_set = 212
 SET cdf_meaning = "HOME"
 EXECUTE cpm_get_cd_for_cdf
 SET home_address_type_cd = code_value
 SET code_set = 212
 SET cdf_meaning = "BUSINESS"
 EXECUTE cpm_get_cd_for_cdf
 SET business_address_type_cd = code_value
 SET code_set = 43
 SET cdf_meaning = "HOME"
 EXECUTE cpm_get_cd_for_cdf
 SET home_phone_type_cd = code_value
 SET code_set = 43
 SET cdf_meaning = "BUSINESS"
 EXECUTE cpm_get_cd_for_cdf
 SET business_phone_type_cd = code_value
 SET code_set = 43
 SET cdf_meaning = "FAX BUS"
 EXECUTE cpm_get_cd_for_cdf
 SET bus_fax_phone_type_cd = code_value
 SET code_set = 43
 SET cdf_meaning = "PAGER BUS"
 EXECUTE cpm_get_cd_for_cdf
 SET bus_pgr_phone_type_cd = code_value
 SET code_set = 43
 SET cdf_meaning = "FAX PERS"
 EXECUTE cpm_get_cd_for_cdf
 SET pers_fax_phone_type_cd = code_value
 SET code_set = 43
 SET cdf_meaning = "PAGER PERS"
 EXECUTE cpm_get_cd_for_cdf
 SET pers_pgr_phone_type_cd = code_value
 SET code_set = 278
 SET cdf_meaning = "FACILITY"
 EXECUTE cpm_get_cd_for_cdf
 SET facility_cd = code_value
 SET code_set = 278
 SET cdf_meaning = "CLIENT"
 EXECUTE cpm_get_cd_for_cdf
 SET client_cd = code_value
 SET numelts = size(requestin->list_0,5)
 FOR (lvar = 1 TO numelts)
   SET full_name = fillstring(100," ")
   SET add_user = 1
   SET org_class_cd = 0.0
   SET org_id = 0.0
   SELECT INTO "nl:"
    c.code_value
    FROM code_value c
    PLAN (c
     WHERE c.code_set=396.0
      AND c.cdf_meaning="ORG")
    DETAIL
     org_class_cd = c.code_value
    WITH nocounter
   ;end select
   SET org_name = substring(1,100,cnvtupper(cnvtalphanum(requestin->list_0[lvar].organization_name)))
   CALL echo(org_name)
   CALL echo(org_class_cd)
   SELECT INTO "nl:"
    o.organization_id
    FROM organization o,
     org_type_reltn otr
    PLAN (o
     WHERE o.org_name_key=org_name
      AND o.org_class_cd=org_class_cd
      AND (o.data_status_cd=reqdata->data_status_cd)
      AND o.active_ind=1
      AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND o.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (otr
     WHERE otr.organization_id=o.organization_id
      AND ((otr.org_type_cd=facility_cd) OR (otr.org_type_cd=client_cd)) )
    DETAIL
     org_id = o.organization_id
    WITH counter
   ;end select
   IF (org_id <= 0)
    SET reqinfo->commit_ind = 3
    CALL echo("org_id <= 0")
   ENDIF
   SET userid = 0.0
   SET numqual = 0
   SELECT INTO "nl:"
    c.code_value
    FROM code_value c,
     (dummyt d  WITH seq = 6)
    PLAN (d)
     JOIN (c
     WHERE (pool_cds->qual[d.seq].cdf_meaning=c.cdf_meaning)
      AND 320.0=c.code_set)
    DETAIL
     x = cnvtint(d.seq), pool_cds->qual[x].alias_type_cd = c.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    o.alias_pool_cd
    FROM (dummyt d  WITH seq = 6),
     org_alias_pool_reltn o
    PLAN (d)
     JOIN (o
     WHERE o.organization_id=org_id
      AND o.alias_entity_name="PRSNL_ALIAS"
      AND (o.alias_entity_alias_type_cd=pool_cds->qual[d.seq].alias_type_cd))
    DETAIL
     x = cnvtint(d.seq), pool_cds->qual[x].alias_pool_cd = o.alias_pool_cd
    WITH counter
   ;end select
   SELECT INTO "nl:"
    o.alias_pool_cd
    FROM org_alias_pool_reltn o
    WHERE o.organization_id=org_id
     AND o.alias_entity_name="PERSON_ALIAS"
     AND o.alias_entity_alias_type_cd=person_ssn_alias_type_cd
    DETAIL
     person_ssn_alias_pool_cd = o.alias_pool_cd
    WITH counter
   ;end select
   SET person_id = 0.0
   SELECT INTO "nl:"
    p.person_id
    FROM prsnl_alias p
    PLAN (p
     WHERE (p.prsnl_alias_type_cd=pool_cds->qual[2].alias_type_cd)
      AND (p.alias_pool_cd=pool_cds->qual[2].alias_pool_cd)
      AND (p.alias=requestin->list_0[lvar].external_id))
    DETAIL
     person_id = p.person_id
    WITH counter
   ;end select
   SET numqual = maxval(numqual,curqual)
   IF (numqual > 0)
    SET externalid_found = "Y"
   ELSE
    SET externalid_found = "N"
   ENDIF
   IF ((requestin->list_0[lvar].last_name <= " "))
    SET requestin->list_0[lvar].last_name = requestin->list_0[lvar].external_id
   ENDIF
   IF ((requestin->list_0[lvar].first_name <= " "))
    SET requestin->list_0[lvar].first_name = requestin->list_0[lvar].external_id
   ENDIF
   IF (org_id > 0.0
    AND (pool_cds->qual[2].alias_pool_cd > 0)
    AND (requestin->list_0[lvar].last_name > " ")
    AND (requestin->list_0[lvar].first_name > " "))
    SET org_rel_status->list[1].org_name = org_name
    SET org_rel_status->list[1].org_id = org_id
    SET org_rel_status->list[1].org_found = "F"
    EXECUTE FROM call_pm_ens_person TO call_pm_ens_person_exit
    IF (person_status="S")
     SET person_id = reply->person[1].person_id
     EXECUTE FROM call_pm_ens_prsnl TO call_pm_ens_prsnl_exit
     EXECUTE FROM call_pm_ens_prsnl_alias TO call_pm_ens_prsnl_alias_exit
     EXECUTE FROM call_pm_ens_person_name_for_person TO call_pm_ens_person_name_for_person_exit
     EXECUTE FROM call_pm_ens_person_name_for_prsnl TO call_pm_ens_person_name_for_prsnl_exit
     EXECUTE FROM call_pm_ens_person_alias TO call_pm_ens_person_alias_exit
     EXECUTE FROM call_pm_ens_address TO call_pm_ens_address_exit
     EXECUTE FROM call_pm_ens_phone TO call_pm_ens_phone_exit
     EXECUTE FROM add_prsnl_org_reltn TO add_prsnl_org_reltn_exit
    ENDIF
   ENDIF
   COMMIT
   SET fname = concat(trim(requestin->list_0[lvar].last_name),", ",trim(requestin->list_0[lvar].
     first_name)," ",trim(requestin->list_0[lvar].middle_name),
    " ")
   SELECT INTO "dm_import_prsnl.errlog"
    d.seq
    FROM (dummyt d  WITH seq = 6)
    HEAD REPORT
     row + 1, col 0, "EXTID: ",
     requestin->list_0[lvar].external_id, col 18, "PERSON: ",
     fname
     IF (externalid_found="N")
      " ADD "
     ELSE
      " UPDATE "
     ENDIF
     " PERSON ID: ", person_id"############;l"
     IF (person_status="S")
      " SUCCESS "
     ELSE
      " FAILED  "
     ENDIF
     curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m"
     IF (facility_cd <= 0)
      row + 1, col 0, "  **ERROR--Facility_Cd (cvs278) not found: ",
      org_name
     ENDIF
     IF (client_cd <= 0)
      row + 1, col 0, "  **ERROR--Client_Cd (cvs278) not found: ",
      org_name
     ENDIF
     IF (((org_id <= 0) OR ((((requestin->list_0[lvar].last_name <= " ")) OR ((requestin->list_0[lvar
     ].first_name <= " "))) )) )
      IF (org_id <= 0)
       row + 1, col 0, "  **ERROR--Organization not found: ",
       org_name
      ENDIF
      IF ((((requestin->list_0[lvar].last_name <= " ")) OR ((requestin->list_0[lvar].first_name <=
      " "))) )
       row + 1, col 0, "  **ERROR--FIRST OR LAST NAME IS BLANK: "
      ENDIF
      reqinfo->commit_ind = 3
     ELSE
      row + 1, col 2, "PERSON_NAME "
      IF (current_person_name_found="N")
       "ADD "
      ELSE
       "UPDATE "
      ENDIF
      IF (person_name_status="S")
       "SUCCESS"
      ELSE
       "FAILED"
      ENDIF
      row + 1, col 2, "PERSON_SSN "
      IF (person_ssn_alias_found="N")
       "ADD "
      ELSE
       "UPDATE "
      ENDIF
      IF (person_ssn_alias_status="S")
       "SUCCESS"
      ELSE
       "FAILED ", "alias_pool_cd: ", person_ssn_alias_pool_cd,
       "alias_type_cd: ", person_ssn_alias_type_cd
      ENDIF
      row + 1, col 0, "  HOME_ADDRESS "
      IF (home_address_found="N")
       "ADD "
      ELSE
       "UPDATE "
      ENDIF
      IF (home_address_status="S")
       "SUCCESS"
      ELSEIF (home_address_status="F")
       "FAILED"
      ELSE
       "NOT DONE"
      ENDIF
      IF (home_address_pct_status="F")
       " *** ERROR--Primary Care (cvs29880) not found: ", requestin->list_0[lvar].home_primary_care,
       row + 1,
       col 35
      ENDIF
      IF (home_address_dha_status="F")
       " *** ERROR--District Health (cvs29881) not found: ", requestin->list_0[lvar].
       home_district_health
      ENDIF
      row + 1, col 0, "  BUSINESS_ADDRESS "
      IF (business_address_found="N")
       "ADD "
      ELSE
       "UPDATE "
      ENDIF
      IF (business_address_status="S")
       "SUCCESS"
      ELSEIF (business_address_status="F")
       "FAILED"
      ELSE
       "NOT DONE"
      ENDIF
      IF (business_address_pct_status="F")
       " *** ERROR--Primary Care (cvs29880) not found: ", requestin->list_0[lvar].
       business_primary_care, row + 1,
       col 35
      ENDIF
      IF (business_address_dha_status="F")
       " *** ERROR--District Health (cvs29881) not found: ", requestin->list_0[lvar].
       business_district_health
      ENDIF
      row + 1, col 0, "  HOME_PHONE "
      IF (home_phone_found="N")
       "ADD "
      ELSE
       "UPDATE "
      ENDIF
      IF (home_phone_status="S")
       "SUCCESS"
      ELSEIF (home_phone_status="F")
       "FAILED"
      ELSE
       "NOT DONE"
      ENDIF
      row + 1, col 0, "  BUSINESS_PHONE "
      IF (business_phone_found="N")
       "ADD "
      ELSE
       "UPDATE "
      ENDIF
      IF (business_phone_status="S")
       "SUCCESS"
      ELSEIF (business_phone_status="F")
       "FAILED"
      ELSE
       "NOT DONE"
      ENDIF
      row + 1, col 0, "  PRSNL "
      IF (prsnl_found="N")
       "ADD "
      ELSE
       "UPDATE "
      ENDIF
      IF (prsnl_status="S")
       "SUCCESS"
      ELSEIF (prsnl_status="F")
       "FAILED"
      ELSE
       "NOT DONE"
      ENDIF
      row + 1, col 0, "  PRSNLID ALIAS(User_id): ",
      requestin->list_0[lvar].user_id
      IF (prsnlid_found="N")
       " ADD "
      ELSE
       " UPDATE "
      ENDIF
      IF (prsnlid_alias_status="S")
       "SUCCESS"
      ELSEIF (prsnlid_alias_status="F")
       "FAILED"
      ELSE
       "NOT DONE"
      ENDIF
      row + 1, col 0, "  EXTERNALID ALIAS: ",
      requestin->list_0[lvar].external_id
      IF (externalid_found="N")
       " ADD "
      ELSE
       " UPDATE "
      ENDIF
      IF (externalid_alias_status="S")
       "SUCCESS"
      ELSEIF (externalid_alias_status="F")
       "FAILED"
      ELSE
       "NOT DONE"
      ENDIF
      IF (cnvtupper(requestin->list_0[lvar].physician_ind)="Y")
       row + 1, col 0, "  DOCDEA ALIAS: ",
       requestin->list_0[lvar].dea_no
       IF (docdea_found="N")
        " ADD "
       ELSE
        " UPDATE "
       ENDIF
       IF (docdea_alias_status="S")
        "SUCCESS"
       ELSEIF (docdea_alias_status="F")
        "FAILED"
       ELSE
        "NOT DONE"
       ENDIF
       row + 1, col 0, "  DOCUPIN ALIAS: ",
       requestin->list_0[lvar].upin
       IF (docupin_found="N")
        " ADD "
       ELSE
        " UPDATE "
       ENDIF
       IF (docupin_alias_status="S")
        "SUCCESS"
       ELSEIF (docupin_alias_status="F")
        "FAILED"
       ELSE
        "NOT DONE"
       ENDIF
       row + 1, col 0, "  DOCNBR ALIAS: ",
       requestin->list_0[lvar].organization_no
       IF (docnbr_found="N")
        " ADD "
       ELSE
        " UPDATE "
       ENDIF
       IF (docnbr_alias_status="S")
        "SUCCESS"
       ELSEIF (docnbr_alias_status="F")
        "FAILED"
       ELSE
        "NOT DONE"
       ENDIF
       row + 1, col 0, "  DOCCNBR ALIAS: ",
       requestin->list_0[lvar].community_nbr
       IF (doccnbr_found="N")
        " ADD "
       ELSE
        " UPDATE "
       ENDIF
       IF (doccnbr_alias_status="S")
        "SUCCESS"
       ELSEIF (doccnbr_alias_status="F")
        "FAILED"
       ELSE
        "NOT DONE"
       ENDIF
       IF (numorg > 0)
        FOR (ovar = 1 TO numorg)
          row + 1, col 0, "  ASSIGN ORG ALIAS: ",
          prsnl_alias_status->prsnl_alias[ovar].org_nbr, "  FOR ORGANIZATION: ", prsnl_alias_status->
          prsnl_alias[ovar].org_name
          IF ((prsnl_alias_status->prsnl_alias[ovar].org_found="N"))
           " ADD "
          ELSE
           " UPDATE "
          ENDIF
          IF ((prsnl_alias_status->prsnl_alias[ovar].status="S"))
           "SUCCESS"
          ELSEIF ((prsnl_alias_status->prsnl_alias[ovar].status="F"))
           "FAILED"
          ELSE
           "NOT DONE"
          ENDIF
        ENDFOR
       ENDIF
       IF ((org_rel_status->qual > 0))
        row + 1, col 0, "  nbr RELATED ORGs: ",
        org_rel_status->qual
        FOR (ovar = 1 TO org_rel_status->qual)
          IF ((org_rel_status->list[ovar].org_found="N"))
           row + 1, col 0, "  RELATED ORGANIZATION NOT FOUND: ",
           org_rel_status->list[ovar].org_name
          ELSE
           row + 1, col 0, "  ORGANIZATION RELATION FOR: ",
           org_rel_status->list[ovar].org_name
           IF ((org_rel_status->list[ovar].org_rel_found="N"))
            " ADD "
           ENDIF
           IF ((org_rel_status->list[ovar].status="S"))
            "SUCCESS"
           ELSEIF ((org_rel_status->list[ovar].status="F"))
            "FAILED"
           ELSE
            "ALREADY EXISTS"
           ENDIF
          ENDIF
        ENDFOR
       ENDIF
      ENDIF
     ENDIF
     IF (cnvtupper(requestin->list_0[lvar].system_user_ind)="Y")
      IF (add_user=0)
       IF (prsnl_found="N")
        row + 1, col 0, "  Added user ",
        requestin->list_0[lvar].username, " to Security on add (0)"
       ELSE
        row + 1, col 0, "  Added user ",
        requestin->list_0[lvar].username, " to Security on update (0)"
       ENDIF
      ENDIF
      IF (add_user=1)
       row + 1, col 0, "  **ERROR--Unable to Add user ",
       requestin->list_0[lvar].username, " to Security - invalid user (1)", reqinfo->commit_ind = 3
      ENDIF
      IF (add_user=2)
       row + 1, col 0, "  Security entry for User ",
       requestin->list_0[lvar].username, " already exists (2)"
      ENDIF
      IF (add_user=3)
       row + 1, col 0, "  Security entry for User ",
       requestin->list_0[lvar].username, " not added - Failure (3) ", reqinfo->commit_ind = 3
      ENDIF
      IF (add_user=4)
       row + 1, col 0, "  Security entry for User ",
       requestin->list_0[lvar].username, " not added - No Access (4) ", reqinfo->commit_ind = 3
      ENDIF
      IF (add_user=5)
       row + 1, col 0, "  Security entry for User ",
       requestin->list_0[lvar].username, " not added - Auth not exist (5) ", reqinfo->commit_ind = 3
      ENDIF
      IF ((add_user=- (1)))
       row + 1, col 0, "  Security entry for User ",
       requestin->list_0[lvar].username, " not added - Server Error or not authorized (-1) ", reqinfo
       ->commit_ind = 3
      ENDIF
     ELSE
      row + 1, col 0, "  User ",
      requestin->list_0[lvar].username, " NOT added to Security  "
     ENDIF
     IF ((reqinfo->commit_ind=3))
      row + 2, col 0, "**** IMPORT TERMINATED BECAUSE OF DATA ERROR **** "
     ENDIF
    DETAIL
     x = d.seq
     IF (org_id > 0
      AND (requestin->list_0[lvar].last_name > " ")
      AND (requestin->list_0[lvar].first_name > " "))
      IF ((pool_cds->qual[x].alias_type_cd <= 0.0))
       row + 1, col 0, "  **No Alias type code for: '",
       CALL print(pool_cds->qual[x].cdf_meaning), "'"
      ELSEIF ((pool_cds->qual[x].alias_pool_cd <= 0.0))
       row + 1, col 0, "  **No alias pool cd for (org): '",
       CALL print(trim(requestin->list_0[lvar].organization_name)), "'", row + 1,
       col 0, "                 (meaning): '",
       CALL print(pool_cds->qual[x].cdf_meaning)
      ENDIF
     ENDIF
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 200, maxrow = 1
   ;end select
   SET person_id = 0.0
 ENDFOR
 GO TO exit_pgm
#call_pm_ens_person
 DECLARE dynamic_request_status = i2
 SET pn = 0
 SET pb[40000] = fillstring(140," ")
 SET pn = 1
 SET pb[pn] = "record request ("
 IF (validate(stash_request->built,9)=9)
  DECLARE create_request_err_msg = vc
  DECLARE happ = i4
  DECLARE hreply = i4
  DECLARE htask = i4
  DECLARE hreq = i4
  DECLARE crmstatus = i2
  DECLARE stat = i4
  DECLARE appnum = i4
  DECLARE tasknum = i4
  DECLARE reqnum = i4
  DECLARE hstep = i4
  DECLARE hstatus = i4
  DECLARE hlist = i4
  DECLARE statusvalue = c1
  SET appnum = 100000
  SET tasknum = 100000
  SET reqnum = 114434
  EXECUTE crmrtl
  EXECUTE srvrtl
  SET crmstatus = uar_crmbeginapp(appnum,happ)
  IF (crmstatus=0)
   SET crmstatus = uar_crmbegintask(happ,tasknum,htask)
   IF (crmstatus=0)
    SET crmstatus = uar_crmbeginreq(htask,"",reqnum,hstep)
    IF (crmstatus=0)
     SET hreq = uar_crmgetrequest(hstep)
     SET stat = uar_srvsetlong(hreq,"step_nbr",101101)
     SET stat = uar_srvsetstring(hreq,"structure_name","")
     SET stat = uar_crmperform(hstep)
     IF (stat=0)
      SET hreply = uar_crmgetreply(hstep)
      SET hstatus = uar_srvgetstruct(hreply,"status_data")
      SET statusvalue = uar_srvgetstringptr(hstatus,"status")
      IF (statusvalue="S")
       SET total = 0
       SET total = uar_srvgetitemcount(hreply,"lines")
       SET loop_total = (total - 1)
       FREE SET stash_request
       SET trace = recpersist
       RECORD stash_request(
         1 built = i2
         1 lines[*]
           2 line = vc
       )
       SET trace = norecpersist
       SET stash_count = 0
       FOR (i = 0 TO loop_total)
         SET hlist = uar_srvgetitem(hreply,"lines",i)
         SET next_line = trim(uar_srvgetstringptr(hlist,"line"))
         IF (next_line != " "
          AND next_line != "")
          SET stash_count = (stash_count+ 1)
          SET stat = alterlist(stash_request->lines,stash_count)
          SET stash_request->lines[stash_count].line = next_line
          SET pn = (pn+ 1)
          SET pb[pn] = next_line
         ENDIF
       ENDFOR
       SET stash_request->built = 1
       SET dynamic_request_status = 1
      ELSE
       SET create_request_err_msg = concat("STATUS=",statusvalue)
      ENDIF
      CALL uar_crmendreq(hstep)
     ELSE
      SET create_request_err_msg = concat("CRMPERFORM=",cnvtstring(stat))
     ENDIF
    ELSE
     SET create_request_err_msg = concat("BEGINREQ=",cnvtstring(crmstatus))
    ENDIF
    CALL uar_crmendtask(htask)
   ELSE
    SET create_request_err_msg = concat("BEGINTASK=",cnvtstring(crmstatus))
   ENDIF
   CALL uar_crmendapp(happ)
  ELSE
   SET create_request_err_msg = concat("BEGINAPP=",cnvtstring(crmstatus))
  ENDIF
 ELSE
  SET total = 0
  SET total = size(stash_request->lines,5)
  FOR (i = 1 TO total)
   SET pn = (pn+ 1)
   SET pb[pn] = trim(stash_request->lines[i].line)
  ENDFOR
  SET dynamic_request_status = 1
 ENDIF
 SET pn = (pn+ 1)
 SET pb[pn] = ") with persistscript go"
 FOR (x = 1 TO pn)
   CALL parser(pb[x])
 ENDFOR
 IF (dynamic_request_status=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = trim(create_request_err_msg)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "req101101"
  GO TO exit_pgm
 ELSEIF (validate(request->person_qual,9999999)=9999999)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "No person req"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "req101101"
  GO TO exit_pgm
 ENDIF
 SET request->person_qual = 1
 SET stat = alterlist(request->person,1)
 IF (externalid_found="N")
  SET request->person[1].action_type = "ADD"
  SET prsnl_found = "N"
  SET prsnlid_found = "N"
  SET externalid_found = "N"
  SET docdea_found = "N"
  SET docupin_found = "N"
  SET docnbr_found = "N"
  SET doccnbr_found = "N"
  SET person_found = "N"
  SET current_person_name_found = "N"
  SET prsnl_person_name_found = "N"
  SET home_address_found = "N"
  SET business_address_found = "N"
  SET home_phone_found = "N"
  SET business_phone_found = "N"
  SET pers_pgr_phone_found = "N"
  SET pers_fax_phone_found = "N"
  SET bus_pgr_phone_found = "N"
  SET bus_fax_phone_found = "N"
 ELSE
  EXECUTE FROM set_exists_flags TO set_exists_flags_exit
  SET request->person[1].action_type = "UPT"
 ENDIF
 SET request->person[1].person_id = person_id
 SET request->person[1].active_ind_ind = true
 SET request->person[1].active_ind = 1
 SET request->person[1].active_status_cd = reqdata->active_status_cd
 SET request->person[1].data_status_cd = reqdata->data_status_cd
 SET request->person[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
 SET request->person[1].person_type_cd = person_type_cd
 SET request->person[1].name_last = requestin->list_0[lvar].last_name
 SET request->person[1].name_last_key = trim(cnvtupper(cnvtalphanum(requestin->list_0[lvar].last_name
    )))
 SET request->person[1].name_first = requestin->list_0[lvar].first_name
 SET request->person[1].name_first_key = trim(cnvtupper(cnvtalphanum(requestin->list_0[lvar].
    first_name)))
 IF ((requestin->list_0[lvar].name_full_formatted > " "))
  SET request->person[1].name_full_formatted = requestin->list_0[lvar].name_full_formatted
 ELSE
  SET request->person[1].name_full_formatted = concat(trim(requestin->list_0[lvar].last_name),", ",
   trim(requestin->list_0[lvar].first_name)," ",trim(requestin->list_0[lvar].middle_name),
   " ")
 ENDIF
 SET request->person[1].name_phonetic = soundex(cnvtupper(requestin->list_0[lvar].last_name))
 IF ((requestin->list_0[lvar].sex > " "))
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE c.code_set=57
    AND c.display_key=trim(requestin->list_0[lvar].sex)
   DETAIL
    request->person[1].sex_cd = c.code_value
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET request->person[1].sex_cd = 0
  ENDIF
 ELSE
  SET request->person[1].sex_cd = 0
 ENDIF
 IF ((requestin->list_0[lvar].birth_date > " "))
  SET request->person[1].birth_dt_tm = cnvtdatetime(requestin->list_0[lvar].birth_date)
 ENDIF
 EXECUTE pm_ens_person
 SET person_status = reply->status_data.status
#call_pm_ens_person_exit
#call_pm_ens_person_name_for_person
 FREE SET request
 RECORD request(
   1 person_name_qual = i4
   1 esi_ensure_type = c3
   1 person_name[10]
     2 action_type = c3
     2 new_person = c1
     2 person_name_id = f8
     2 person_id = f8
     2 name_type_cd = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 name_original = c100
     2 name_format_cd = f8
     2 name_full = c100
     2 name_first = c100
     2 name_middle = c100
     2 name_last = c100
     2 name_degree = c100
     2 name_title = c100
     2 name_prefix = c100
     2 name_suffix = c100
     2 name_initials = c100
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 contributor_system_cd = f8
     2 updt_cnt = i4
 )
 SET request->person_name_qual = 1
 IF (current_person_name_found="N")
  SET request->person_name[1].action_type = "ADD"
  SET request->person_name[1].new_person = "Y"
  SET person_name_id = 0.0
 ELSE
  SET request->person_name[1].action_type = "UPT"
  SET request->person_name[1].new_person = "N"
 ENDIF
 SET request->person_name[1].person_name_id = current_person_name_id
 SET request->person_name[1].person_id = person_id
 SET request->person_name[1].active_ind_ind = true
 SET request->person_name[1].active_ind = 1
 SET request->person_name[1].active_status_cd = reqdata->active_status_cd
 SET request->person_name[1].data_status_cd = reqdata->data_status_cd
 SET request->person_name[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
 SET request->person_name[1].name_type_cd = current_name_type_cd
 SET request->person_name[1].name_last = requestin->list_0[lvar].last_name
 SET request->person_name[1].name_first = requestin->list_0[lvar].first_name
 SET request->person_name[1].name_middle = requestin->list_0[lvar].middle_name
 SET request->person_name[1].name_initials = build(substring(1,1,requestin->list_0[lvar].first_name),
  substring(1,1,requestin->list_0[lvar].middle_name),substring(1,1,requestin->list_0[lvar].last_name)
  )
 IF ((requestin->list_0[lvar].name_full_formatted > " "))
  SET request->person_name[1].name_full = requestin->list_0[lvar].name_full_formatted
 ELSE
  SET request->person_name[1].name_full = concat(trim(requestin->list_0[lvar].last_name),", ",trim(
    requestin->list_0[lvar].first_name)," ",trim(requestin->list_0[lvar].middle_name),
   " ")
 ENDIF
 SET request->person_name[1].name_degree = requestin->list_0[lvar].degree
 SET request->person_name[1].name_title = requestin->list_0[lvar].title
 EXECUTE pm_ens_person_name
 SET person_name_status = reply->status_data.status
 CALL echo("person_name_status")
 CALL echo(person_name_status)
#call_pm_ens_person_name_for_person_exit
#call_pm_ens_person_name_for_prsnl
 FREE SET request
 RECORD request(
   1 person_name_qual = i4
   1 esi_ensure_type = c3
   1 person_name[10]
     2 action_type = c3
     2 new_person = c1
     2 person_name_id = f8
     2 person_id = f8
     2 name_type_cd = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 name_original = c100
     2 name_format_cd = f8
     2 name_full = c100
     2 name_first = c100
     2 name_middle = c100
     2 name_last = c100
     2 name_degree = c100
     2 name_title = c100
     2 name_prefix = c100
     2 name_suffix = c100
     2 name_initials = c100
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 contributor_system_cd = f8
     2 updt_cnt = i4
 )
 SET request->person_name_qual = 1
 IF (prsnl_person_name_found="N")
  SET request->person_name[1].action_type = "ADD"
  SET request->person_name[1].new_person = "Y"
  SET prsnl_person_name_id = 0.0
 ELSE
  SET request->person_name[1].action_type = "UPT"
  SET request->person_name[1].new_person = "N"
 ENDIF
 SET request->person_name[1].person_name_id = prsnl_person_name_id
 SET request->person_name[1].person_id = person_id
 SET request->person_name[1].active_ind_ind = true
 SET request->person_name[1].active_ind = 1
 SET request->person_name[1].active_status_cd = reqdata->active_status_cd
 SET request->person_name[1].data_status_cd = reqdata->data_status_cd
 SET request->person_name[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
 SET request->person_name[1].name_type_cd = prsnl_name_type_cd
 SET request->person_name[1].name_last = requestin->list_0[lvar].last_name
 SET request->person_name[1].name_first = requestin->list_0[lvar].first_name
 SET request->person_name[1].name_middle = requestin->list_0[lvar].middle_name
 SET request->person_name[1].name_initials = build(substring(1,1,requestin->list_0[lvar].first_name),
  substring(1,1,requestin->list_0[lvar].middle_name),substring(1,1,requestin->list_0[lvar].last_name)
  )
 IF ((requestin->list_0[lvar].name_full_formatted > " "))
  SET request->person_name[1].name_full = requestin->list_0[lvar].name_full_formatted
 ELSE
  SET request->person_name[1].name_full = concat(trim(requestin->list_0[lvar].last_name),", ",trim(
    requestin->list_0[lvar].first_name)," ",trim(requestin->list_0[lvar].middle_name),
   " ")
 ENDIF
 SET request->person_name[1].name_degree = requestin->list_0[lvar].degree
 SET request->person_name[1].name_title = requestin->list_0[lvar].title
 EXECUTE pm_ens_person_name
 SET person_name_status = reply->status_data.status
 CALL echo("person_name_status")
 CALL echo(person_name_status)
#call_pm_ens_person_name_for_prsnl_exit
#call_pm_ens_person_alias
 FREE SET request
 RECORD request(
   1 person_alias_qual = i4
   1 esi_ensure_type = c3
   1 person_alias[10]
     2 action_type = c3
     2 new_person = c1
     2 person_alias_id = f8
     2 person_id = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 alias_pool_cd = f8
     2 person_alias_type_cd = f8
     2 alias = c200
     2 person_alias_sub_type_cd = f8
     2 check_digit = i4
     2 check_digit_method_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 contributor_system_cd = f8
     2 visit_seq_nbr = i4
     2 health_card_province = c3
     2 health_card_ver_code = c3
     2 health_card_type = c32
     2 health_card_issue_dt_tm = dq8
     2 health_card_expiry_dt_tm = dq8
     2 updt_cnt = i4
     2 assign_authority_sys_cd = f8
 )
 IF (size(trim(requestin->list_0[lvar].soc_sec_nbr,3)) > 0)
  SET request->person_alias_qual = 1
  IF (person_ssn_alias_found="N")
   SET request->person_alias[1].action_type = "ADD"
   SET request->person_alias[1].new_person = "Y"
   SET person_alias_id = 0.0
  ELSE
   SET request->person_alias[1].action_type = "UPT"
   SET request->person_alias[1].new_person = "N"
  ENDIF
  SET request->person_alias[1].person_alias_id = person_alias_id
  SET request->person_alias[1].person_id = person_id
  SET request->person_alias[1].active_ind_ind = true
  SET request->person_alias[1].active_ind = 1
  SET request->person_alias[1].active_status_cd = reqdata->active_status_cd
  SET request->person_alias[1].data_status_cd = reqdata->data_status_cd
  SET request->person_alias[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
  SET request->person_alias[1].alias_pool_cd = person_ssn_alias_pool_cd
  SET request->person_alias[1].person_alias_type_cd = person_ssn_alias_type_cd
  SET request->person_alias[1].alias = requestin->list_0[lvar].soc_sec_nbr
  EXECUTE pm_ens_person_alias
  SET person_ssn_alias_status = reply->status_data.status
 ELSE
  SET person_ssn_alias_status = "S"
 ENDIF
 CALL echo("person_ssn_alias_status")
 CALL echo(person_ssn_alias_status)
#call_pm_ens_person_alias_exit
#call_pm_ens_prsnl
 FREE SET request
 RECORD request(
   1 prsnl_qual = i4
   1 esi_ensure_type = c3
   1 prsnl[10]
     2 action_type = c3
     2 new_person = c1
     2 person_id = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 name_last_key = c100
     2 name_first_key = c100
     2 prsnl_type_cd = f8
     2 name_full_formatted = c100
     2 password = c100
     2 email = c100
     2 physician_ind_ind = i2
     2 physician_ind = i2
     2 position_cd = f8
     2 department_cd = f8
     2 free_text_ind_ind = i2
     2 free_text_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 section_cd = f8
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 contributor_system_cd = f8
     2 name_last = c200
     2 name_first = c200
     2 username = c50
     2 ft_entity_name = c32
     2 ft_entity_id = f8
     2 prim_assign_loc_cd = f8
     2 log_level = i4
     2 log_access_ind_ind = i2
     2 log_access_ind = i2
     2 updt_cnt = i4
 )
 SET request->prsnl_qual = 1
 IF (prsnl_found="N")
  SET request->prsnl[1].action_type = "ADD"
  SET request->prsnl[1].new_person = "Y"
 ELSE
  SET request->prsnl[1].action_type = "UPT"
  SET request->prsnl[1].new_person = "N"
 ENDIF
 SET request->prsnl[1].person_id = person_id
 SET request->prsnl[1].active_ind = 1
 SET request->prsnl[1].active_status_cd = reqdata->active_status_cd
 SET request->prsnl[1].data_status_cd = reqdata->data_status_cd
 SET request->prsnl[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
 SET request->prsnl[1].prsnl_type_cd = prsnl_type_cd
 SET request->prsnl[1].name_last = requestin->list_0[lvar].last_name
 SET request->prsnl[1].name_last_key = trim(cnvtupper(cnvtalphanum(requestin->list_0[lvar].last_name)
   ))
 SET request->prsnl[1].name_first = requestin->list_0[lvar].first_name
 SET request->prsnl[1].name_first_key = trim(cnvtupper(cnvtalphanum(requestin->list_0[lvar].
    first_name)))
 IF ((requestin->list_0[lvar].name_full_formatted > " "))
  SET request->prsnl[1].name_full_formatted = requestin->list_0[lvar].name_full_formatted
 ELSE
  SET request->prsnl[1].name_full_formatted = concat(trim(requestin->list_0[lvar].last_name),", ",
   trim(requestin->list_0[lvar].first_name)," ",trim(requestin->list_0[lvar].middle_name),
   " ")
 ENDIF
 SET full_name = request->prsnl[1].name_full_formatted
 IF (trim(requestin->list_0[lvar].username)="")
  SET request->prsnl[1].username = null
 ELSE
  SET request->prsnl[1].username = cnvtupper(requestin->list_0[lvar].username)
 ENDIF
 SET request->prsnl[1].physician_ind_ind = true
 IF (cnvtupper(requestin->list_0[lvar].physician_ind)="Y")
  SET request->prsnl[1].physician_ind = 1
 ELSE
  SET request->prsnl[1].physician_ind = 0
 ENDIF
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  PLAN (c
   WHERE c.code_set=88
    AND c.display_key=trim(cnvtupper(cnvtalphanum(requestin->list_0[lvar].position))))
  DETAIL
   request->prsnl[1].position_cd = c.code_value
  WITH nocounter
 ;end select
 EXECUTE pm_ens_prsnl
 SET prsnl_status = reply->status_data.status
 IF (cnvtupper(requestin->list_0[lvar].system_user_ind)="Y")
  SET add_user = uar_sec_user(nullterm(requestin->list_0[lvar].username),nullterm(requestin->list_0[
    lvar].username),full_name)
  IF (add_user != 2
   AND add_user != 0)
   SET reqinfo->commit_ind = 3
  ENDIF
 ENDIF
 CALL echo("uar_sec_user status")
 CALL echo(add_user)
#call_pm_ens_prsnl_exit
#call_pm_ens_address
 FREE SET request
 RECORD request(
   1 address_qual = i4
   1 esi_ensure_type = c3
   1 address[10]
     2 action_type = c3
     2 new_person = c1
     2 address_id = f8
     2 parent_entity_name = c32
     2 parent_entity_id = f8
     2 address_type_cd = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 address_format_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 contact_name = c200
     2 residence_type_cd = f8
     2 comment_txt = c200
     2 street_addr = c100
     2 street_addr2 = c100
     2 street_addr3 = c100
     2 street_addr4 = c100
     2 city = c100
     2 state = c100
     2 state_cd = f8
     2 zipcode = c25
     2 zip_code_group_cd = f8
     2 postal_barcode_info = c100
     2 county = c100
     2 county_cd = f8
     2 country = c100
     2 country_cd = f8
     2 primary_care_cd = f8
     2 district_health_cd = f8
     2 residence_cd = f8
     2 mail_stop = c100
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 address_type_seq = i4
     2 beg_effective_mm_dd = i4
     2 end_effective_mm_dd = i4
     2 contributor_system_cd = f8
     2 operation_hours = c255
     2 long_text_id = f8
     2 updt_cnt = i4
 )
 IF ((((requestin->list_0[lvar].home_contact > " ")) OR ((((requestin->list_0[lvar].home_street_addr1
  > " ")) OR ((((requestin->list_0[lvar].home_street_addr2 > " ")) OR ((((requestin->list_0[lvar].
 home_street_addr3 > " ")) OR ((((requestin->list_0[lvar].home_street_addr4 > " ")) OR ((((requestin
 ->list_0[lvar].home_comment > " ")) OR ((((requestin->list_0[lvar].home_city > " ")) OR ((((
 requestin->list_0[lvar].home_state > " ")) OR ((((requestin->list_0[lvar].home_zipcode > " ")) OR (
 (((requestin->list_0[lvar].home_county > " ")) OR ((requestin->list_0[lvar].home_country > " ")))
 )) )) )) )) )) )) )) )) )) )
  SET request->address_qual = 1
  IF (home_address_found="N")
   SET request->address[1].action_type = "ADD"
   SET request->address[1].new_person = "Y"
   SET home_address_id = 0.0
  ELSE
   SET request->address[1].action_type = "UPT"
   SET request->address[1].new_person = "N"
  ENDIF
  SET request->address[1].address_id = home_address_id
  SET request->address[1].parent_entity_name = "PERSON"
  SET request->address[1].parent_entity_id = person_id
  SET request->address[1].address_type_cd = home_address_type_cd
  SET request->address[1].active_status_cd = reqdata->active_status_cd
  SET request->address[1].data_status_cd = reqdata->data_status_cd
  SET request->address[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
  SET request->address[1].active_ind_ind = true
  SET request->address[1].active_ind = 1
  SET request->address[1].contact_name = requestin->list_0[lvar].home_contact
  SET request->address[1].street_addr = requestin->list_0[lvar].home_street_addr1
  SET request->address[1].street_addr2 = requestin->list_0[lvar].home_street_addr2
  SET request->address[1].street_addr3 = requestin->list_0[lvar].home_street_addr3
  SET request->address[1].street_addr4 = requestin->list_0[lvar].home_street_addr4
  SET request->address[1].comment_txt = requestin->list_0[lvar].home_comment
  SET request->address[1].city = requestin->list_0[lvar].home_city
  SET request->address[1].state = requestin->list_0[lvar].home_state
  SET request->address[1].zipcode = requestin->list_0[lvar].home_zipcode
  SET request->address[1].county = requestin->list_0[lvar].home_county
  SET request->address[1].country = requestin->list_0[lvar].home_country
  SET request->address[1].address_type_seq = 1
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE c.code_set=62
    AND c.display_key=trim(request->address[1].state)
   DETAIL
    request->address[1].state_cd = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE c.code_set=15
    AND c.display_key=trim(request->address[1].country)
   DETAIL
    request->address[1].country_cd = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE c.code_set=74
    AND c.display_key=trim(request->address[1].county)
   DETAIL
    request->address[1].county_cd = c.code_value
   WITH nocounter
  ;end select
  SET home_address_pct_status = "N"
  IF (validate(requestin->list_0[lvar].home_primary_care,"9999999") != "9999999")
   IF (size(trim(requestin->list_0[lvar].home_primary_care,3)) > 0)
    SELECT INTO "nl:"
     c.code_value
     FROM code_value c
     WHERE c.code_set=29880
      AND c.display_key=cnvtupper(cnvtalphanum(requestin->list_0[lvar].home_primary_care))
     DETAIL
      request->address[1].primary_care_cd = c.code_value, home_address_pct_status = "S"
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET home_address_pct_status = "F"
    ENDIF
   ENDIF
  ENDIF
  SET home_address_dha_status = "N"
  IF (validate(requestin->list_0[lvar].home_district_health,"9999999") != "9999999")
   IF (size(trim(requestin->list_0[lvar].home_district_health,3)) > 0)
    SELECT INTO "nl:"
     c.code_value
     FROM code_value c
     WHERE c.code_set=29881
      AND c.display_key=cnvtupper(cnvtalphanum(requestin->list_0[lvar].home_district_health))
     DETAIL
      request->address[1].district_health_cd = c.code_value, home_address_dha_status = "S"
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET home_address_dha_status = "F"
    ENDIF
   ENDIF
  ENDIF
  EXECUTE pm_ens_address
  SET home_address_status = reply->status_data.status
 ELSE
  SET home_address_status = "N"
 ENDIF
 IF ((((requestin->list_0[lvar].business_contact > " ")) OR ((((requestin->list_0[lvar].
 business_street_addr1 > " ")) OR ((((requestin->list_0[lvar].business_street_addr2 > " ")) OR ((((
 requestin->list_0[lvar].business_street_addr3 > " ")) OR ((((requestin->list_0[lvar].
 business_street_addr4 > " ")) OR ((((requestin->list_0[lvar].business_comment > " ")) OR ((((
 requestin->list_0[lvar].business_city > " ")) OR ((((requestin->list_0[lvar].business_state > " "))
  OR ((((requestin->list_0[lvar].business_zipcode > " ")) OR ((((requestin->list_0[lvar].
 business_county > " ")) OR ((requestin->list_0[lvar].business_country > " "))) )) )) )) )) )) )) ))
 )) )) )
  SET request->address_qual = 1
  IF (business_address_found="N")
   SET request->address[1].action_type = "ADD"
   SET request->address[1].new_person = "Y"
   SET business_address_id = 0.0
  ELSE
   SET request->address[1].action_type = "UPT"
   SET request->address[1].new_person = "N"
  ENDIF
  SET request->address[1].address_id = business_address_id
  SET request->address[1].parent_entity_name = "PERSON"
  SET request->address[1].parent_entity_id = person_id
  SET request->address[1].address_type_cd = business_address_type_cd
  SET request->address[1].active_status_cd = reqdata->active_status_cd
  SET request->address[1].data_status_cd = reqdata->data_status_cd
  SET request->address[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
  SET request->address[1].active_ind_ind = true
  SET request->address[1].active_ind = 1
  SET request->address[1].contact_name = requestin->list_0[lvar].business_contact
  SET request->address[1].street_addr = requestin->list_0[lvar].business_street_addr1
  SET request->address[1].street_addr2 = requestin->list_0[lvar].business_street_addr2
  SET request->address[1].street_addr3 = requestin->list_0[lvar].business_street_addr3
  SET request->address[1].street_addr4 = requestin->list_0[lvar].business_street_addr4
  SET request->address[1].comment_txt = requestin->list_0[lvar].business_comment
  SET request->address[1].city = requestin->list_0[lvar].business_city
  SET request->address[1].state = requestin->list_0[lvar].business_state
  SET request->address[1].zipcode = requestin->list_0[lvar].business_zipcode
  SET request->address[1].county = requestin->list_0[lvar].business_county
  SET request->address[1].country = requestin->list_0[lvar].business_country
  SET request->address[1].address_type_seq = 1
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE c.code_set=62
    AND c.display_key=trim(request->address[1].state)
   DETAIL
    request->address[1].state_cd = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE c.code_set=15
    AND c.display_key=trim(request->address[1].country)
   DETAIL
    request->address[1].country_cd = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE c.code_set=74
    AND c.display_key=trim(request->address[1].county)
   DETAIL
    request->address[1].county_cd = c.code_value
   WITH nocounter
  ;end select
  SET business_address_pct_status = "N"
  IF (validate(requestin->list_0[lvar].business_primary_care,"9999999") != "9999999")
   IF (size(trim(requestin->list_0[lvar].business_primary_care,3)) > 0)
    SELECT INTO "nl:"
     c.code_value
     FROM code_value c
     WHERE c.code_set=29880
      AND c.display_key=cnvtupper(cnvtalphanum(requestin->list_0[lvar].business_primary_care))
     DETAIL
      request->address[1].primary_care_cd = c.code_value, business_address_pct_status = "S"
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET business_address_pct_status = "F"
    ENDIF
   ENDIF
  ENDIF
  SET business_address_dha_status = "N"
  IF (validate(requestin->list_0[lvar].business_district_health,"9999999") != "9999999")
   IF (size(trim(requestin->list_0[lvar].business_district_health,3)) > 0)
    SELECT INTO "nl:"
     c.code_value
     FROM code_value c
     WHERE c.code_set=29881
      AND c.display_key=cnvtupper(cnvtalphanum(requestin->list_0[lvar].business_district_health))
     DETAIL
      request->address[1].district_health_cd = c.code_value, business_address_dha_status = "S"
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET business_address_dha_status = "F"
    ENDIF
   ENDIF
  ENDIF
  EXECUTE pm_ens_address
  SET business_address_status = reply->status_data.status
 ELSE
  SET business_address_status = "N"
 ENDIF
#call_pm_ens_address_exit
#call_pm_ens_prsnl_alias
 CALL echo("CALL_PM_ENS_PRSNL_ALIAS")
 FREE SET request
 RECORD request(
   1 prsnl_alias_qual = i4
   1 esi_ensure_type = c3
   1 prsnl_alias[10]
     2 action_type = c3
     2 new_person = c1
     2 prsnl_alias_id = f8
     2 person_id = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 alias_pool_cd = f8
     2 prsnl_alias_type_cd = f8
     2 alias = c200
     2 prsnl_alias_sub_type_cd = f8
     2 check_digit = i4
     2 check_digit_method_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 contributor_system_cd = f8
     2 updt_cnt = i4
 )
 IF ((requestin->list_0[lvar].user_id > " ")
  AND (pool_cds->qual[1].alias_pool_cd > 0))
  SET request->prsnl_alias_qual = 1
  IF (prsnlid_found="N")
   SET request->prsnl_alias[1].action_type = "ADD"
   SET request->prsnl_alias[1].new_person = "Y"
   SET prsnlid_id = 0.0
  ELSE
   SET request->prsnl_alias[1].action_type = "UPT"
   SET request->prsnl_alias[1].new_person = "N"
  ENDIF
  SET request->prsnl_alias[1].prsnl_alias_id = prsnlid_id
  SET request->prsnl_alias[1].person_id = person_id
  SET request->prsnl_alias[1].active_ind_ind = true
  SET request->prsnl_alias[1].active_ind = 1
  SET request->prsnl_alias[1].active_status_cd = reqdata->active_status_cd
  SET request->prsnl_alias[1].data_status_cd = reqdata->data_status_cd
  SET request->prsnl_alias[1].prsnl_alias_type_cd = pool_cds->qual[1].alias_type_cd
  SET request->prsnl_alias[1].alias = requestin->list_0[lvar].user_id
  SET request->prsnl_alias[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
  SET request->prsnl_alias[1].alias_pool_cd = pool_cds->qual[1].alias_pool_cd
  EXECUTE pm_ens_prsnl_alias
  SET prsnlid_alias_status = reply->status_data.status
 ELSE
  SET prsnlid_alias_status = "N"
 ENDIF
 IF ((requestin->list_0[lvar].external_id > " ")
  AND externalid_found="N")
  CALL echo("externalid_found = N ")
  CALL echo(requestin->list_0[lvar].external_id)
  SET request->prsnl_alias_qual = 1
  SET request->prsnl_alias[1].action_type = "ADD"
  SET request->prsnl_alias[1].new_person = "Y"
  SET request->prsnl_alias[1].prsnl_alias_id = 0.0
  SET request->prsnl_alias[1].person_id = person_id
  SET request->prsnl_alias[1].active_ind_ind = true
  SET request->prsnl_alias[1].active_ind = 1
  SET request->prsnl_alias[1].active_status_cd = reqdata->active_status_cd
  SET request->prsnl_alias[1].data_status_cd = reqdata->data_status_cd
  SET request->prsnl_alias[1].prsnl_alias_type_cd = pool_cds->qual[2].alias_type_cd
  SET request->prsnl_alias[1].alias = requestin->list_0[lvar].external_id
  SET request->prsnl_alias[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
  SET request->prsnl_alias[1].alias_pool_cd = pool_cds->qual[2].alias_pool_cd
  EXECUTE pm_ens_prsnl_alias
  SET externalid_alias_status = reply->status_data.status
 ELSE
  SET externalid_alias_status = "N"
 ENDIF
 CALL echo(externalid_alias_status)
 IF (cnvtupper(requestin->list_0[lvar].physician_ind)="Y")
  IF ((requestin->list_0[lvar].dea_no > " ")
   AND (pool_cds->qual[3].alias_pool_cd > 0))
   SET request->prsnl_alias_qual = 1
   IF (docdea_found="N")
    SET request->prsnl_alias[1].action_type = "ADD"
    SET request->prsnl_alias[1].new_person = "Y"
    SET docdea_id = 0.0
   ELSE
    SET request->prsnl_alias[1].action_type = "UPT"
    SET request->prsnl_alias[1].new_person = "N"
   ENDIF
   SET request->prsnl_alias[1].prsnl_alias_id = docdea_id
   SET request->prsnl_alias[1].person_id = person_id
   SET request->prsnl_alias[1].active_ind_ind = true
   SET request->prsnl_alias[1].active_ind = 1
   SET request->prsnl_alias[1].active_status_cd = reqdata->active_status_cd
   SET request->prsnl_alias[1].data_status_cd = reqdata->data_status_cd
   SET request->prsnl_alias[1].prsnl_alias_type_cd = pool_cds->qual[3].alias_type_cd
   SET request->prsnl_alias[1].alias = requestin->list_0[lvar].dea_no
   SET request->prsnl_alias[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
   SET request->prsnl_alias[1].alias_pool_cd = pool_cds->qual[3].alias_pool_cd
   EXECUTE pm_ens_prsnl_alias
   SET docdea_alias_status = reply->status_data.status
  ELSE
   SET docdea_alias_status = "N"
  ENDIF
  IF ((requestin->list_0[lvar].upin > " ")
   AND (pool_cds->qual[4].alias_pool_cd > 0))
   SET request->prsnl_alias_qual = 1
   IF (docupin_found="N")
    SET request->prsnl_alias[1].action_type = "ADD"
    SET request->prsnl_alias[1].new_person = "Y"
    SET docupin_id = 0.0
   ELSE
    SET request->prsnl_alias[1].action_type = "UPT"
    SET request->prsnl_alias[1].new_person = "N"
   ENDIF
   SET request->prsnl_alias[1].prsnl_alias_id = docupin_id
   SET request->prsnl_alias[1].person_id = person_id
   SET request->prsnl_alias[1].active_ind_ind = true
   SET request->prsnl_alias[1].active_ind = 1
   SET request->prsnl_alias[1].active_status_cd = reqdata->active_status_cd
   SET request->prsnl_alias[1].data_status_cd = reqdata->data_status_cd
   SET request->prsnl_alias[1].prsnl_alias_type_cd = pool_cds->qual[4].alias_type_cd
   SET request->prsnl_alias[1].alias = requestin->list_0[lvar].upin
   SET request->prsnl_alias[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
   SET request->prsnl_alias[1].alias_pool_cd = pool_cds->qual[4].alias_pool_cd
   EXECUTE pm_ens_prsnl_alias
   SET docupin_alias_status = reply->status_data.status
  ELSE
   SET docupin_alias_status = "N"
  ENDIF
  IF ((requestin->list_0[lvar].organization_no > " ")
   AND (pool_cds->qual[5].alias_pool_cd > 0))
   SET request->prsnl_alias_qual = 1
   IF (docnbr_found="N")
    SET request->prsnl_alias[1].action_type = "ADD"
    SET request->prsnl_alias[1].new_person = "Y"
    SET docnbr_id = 0.0
   ELSE
    SET request->prsnl_alias[1].action_type = "UPT"
    SET request->prsnl_alias[1].new_person = "N"
   ENDIF
   SET request->prsnl_alias[1].prsnl_alias_id = docnbr_id
   SET request->prsnl_alias[1].person_id = person_id
   SET request->prsnl_alias[1].active_ind_ind = true
   SET request->prsnl_alias[1].active_ind = 1
   SET request->prsnl_alias[1].active_status_cd = reqdata->active_status_cd
   SET request->prsnl_alias[1].data_status_cd = reqdata->data_status_cd
   SET request->prsnl_alias[1].prsnl_alias_type_cd = pool_cds->qual[5].alias_type_cd
   SET request->prsnl_alias[1].alias = requestin->list_0[lvar].organization_no
   SET request->prsnl_alias[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
   SET request->prsnl_alias[1].alias_pool_cd = pool_cds->qual[5].alias_pool_cd
   EXECUTE pm_ens_prsnl_alias
   SET docnbr_alias_status = reply->status_data.status
  ELSE
   SET docnbr_alias_status = "N"
  ENDIF
  IF ((requestin->list_0[lvar].community_nbr > " ")
   AND (pool_cds->qual[6].alias_pool_cd > 0))
   SET request->prsnl_alias_qual = 1
   IF (doccnbr_found="N")
    SET request->prsnl_alias[1].action_type = "ADD"
    SET request->prsnl_alias[1].new_person = "Y"
    SET doccnbr_id = 0.0
   ELSE
    SET request->prsnl_alias[1].action_type = "UPT"
    SET request->prsnl_alias[1].new_person = "N"
   ENDIF
   SET request->prsnl_alias[1].prsnl_alias_id = doccnbr_id
   SET request->prsnl_alias[1].person_id = person_id
   SET request->prsnl_alias[1].active_ind_ind = true
   SET request->prsnl_alias[1].active_ind = 1
   SET request->prsnl_alias[1].active_status_cd = reqdata->active_status_cd
   SET request->prsnl_alias[1].data_status_cd = reqdata->data_status_cd
   SET request->prsnl_alias[1].prsnl_alias_type_cd = pool_cds->qual[6].alias_type_cd
   SET request->prsnl_alias[1].alias = requestin->list_0[lvar].community_nbr
   SET request->prsnl_alias[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
   SET request->prsnl_alias[1].alias_pool_cd = pool_cds->qual[6].alias_pool_cd
   EXECUTE pm_ens_prsnl_alias
   SET doccnbr_alias_status = reply->status_data.status
  ELSE
   SET doccnbr_alias_status = "N"
  ENDIF
  SET numorg = size(requestin->list_0[lvar].list_1,5)
  SET prsnl_alias_status->prsnl_alias_qual = numorg
  FOR (ovar = 1 TO numorg)
    IF ((requestin->list_0[lvar].list_1[ovar].assign_org_name > " ")
     AND (requestin->list_0[lvar].list_1[ovar].assign_org_nbr > " ")
     AND (pool_cds->qual[5].alias_type_cd > 0))
     SET asn_org_id = 0.0
     SET asn_org_name = substring(1,100,cnvtupper(cnvtalphanum(requestin->list_0[lvar].list_1[ovar].
        assign_org_name)))
     SELECT INTO "nl:"
      o.organization_id
      FROM organization o,
       org_type_reltn otr
      PLAN (o
       WHERE o.org_name_key=asn_org_name
        AND o.org_class_cd=org_class_cd
        AND (o.data_status_cd=reqdata->data_status_cd))
       JOIN (otr
       WHERE otr.organization_id=o.organization_id
        AND ((otr.org_type_cd=facility_cd) OR (otr.org_type_cd=client_cd)) )
      DETAIL
       asn_org_id = o.organization_id
      WITH counter
     ;end select
     IF (asn_org_id > 0)
      SELECT INTO "nl:"
       o.alias_pool_cd
       FROM org_alias_pool_reltn o
       WHERE o.organization_id=asn_org_id
        AND o.alias_entity_name="PRSNL_ALIAS"
        AND (o.alias_entity_alias_type_cd=pool_cds->qual[5].alias_type_cd)
       DETAIL
        asn_org_alias_pool_cd = o.alias_pool_cd
       WITH counter
      ;end select
     ENDIF
     SET prsnl_alias_status->prsnl_alias[ovar].org_name = asn_org_name
     SET prsnl_alias_status->prsnl_alias[ovar].org_nbr = requestin->list_0[lvar].list_1[ovar].
     assign_org_nbr
     IF (curqual=1
      AND asn_org_id > 0)
      SELECT INTO "nl:"
       p.person_id
       FROM prsnl_alias p
       PLAN (p
        WHERE p.person_id=person_id
         AND (p.prsnl_alias_type_cd=pool_cds->qual[5].alias_type_cd)
         AND p.alias_pool_cd=asn_org_alias_pool_cd)
       DETAIL
        asn_docnbr_id = p.prsnl_alias_id, asn_docnbr_alias = p.alias
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET asn_docnbr_found = "N"
      ELSE
       SET asn_docnbr_found = "Y"
      ENDIF
      SET request->prsnl_alias_qual = 1
      IF (asn_docnbr_found="N")
       SET request->prsnl_alias[1].action_type = "ADD"
       SET request->prsnl_alias[1].new_person = "Y"
       SET asn_docnbr_id = 0.0
      ELSE
       SET request->prsnl_alias[1].action_type = "UPT"
       SET request->prsnl_alias[1].new_person = "N"
      ENDIF
      SET request->prsnl_alias[1].prsnl_alias_id = asn_docnbr_id
      SET request->prsnl_alias[1].person_id = person_id
      SET request->prsnl_alias[1].active_ind_ind = true
      SET request->prsnl_alias[1].active_ind = 1
      SET request->prsnl_alias[1].active_status_cd = reqdata->active_status_cd
      SET request->prsnl_alias[1].data_status_cd = reqdata->data_status_cd
      SET request->prsnl_alias[1].prsnl_alias_type_cd = pool_cds->qual[5].alias_type_cd
      SET request->prsnl_alias[1].alias = requestin->list_0[lvar].list_1[ovar].assign_org_nbr
      SET request->prsnl_alias[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
      SET request->prsnl_alias[1].alias_pool_cd = asn_org_alias_pool_cd
      EXECUTE pm_ens_prsnl_alias
      SET prsnl_alias_status->prsnl_alias[ovar].status = reply->status_data.status
     ELSE
      SET prsnl_alias_status->prsnl_alias[ovar].status = "F"
     ENDIF
    ELSE
     SET prsnl_alias_status->prsnl_alias[ovar].status = "F"
    ENDIF
  ENDFOR
 ENDIF
#call_pm_ens_prsnl_alias_exit
#call_pm_ens_phone
 FREE SET request
 RECORD request(
   1 phone_qual = i4
   1 esi_ensure_type = c3
   1 phone[*]
     2 action_type = c3
     2 new_person = c1
     2 phone_id = f8
     2 parent_entity_name = c32
     2 parent_entity_id = f8
     2 phone_type_cd = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 phone_format_cd = f8
     2 phone_num = c100
     2 phone_type_seq = i4
     2 description = c100
     2 contact = c100
     2 call_instruction = c100
     2 modem_capability_cd = f8
     2 extension = c100
     2 paging_code = c100
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = dq8
     2 beg_effective_mm_dd = i4
     2 end_effective_mm_dd = i4
     2 contributor_system_cd = f8
     2 operation_hours = c255
     2 long_text_id = f8
     2 updt_cnt = i4
 )
 IF ((((requestin->list_0[lvar].home_phone_number > " ")) OR ((((requestin->list_0[lvar].
 home_phone_description > " ")) OR ((((requestin->list_0[lvar].home_phone_contact > " ")) OR ((
 requestin->list_0[lvar].home_phone_call_instruction > " "))) )) )) )
  SET request->phone_qual = 1
  SET stat = alterlist(request->phone,1)
  IF (home_phone_found="N")
   SET request->phone[1].action_type = "ADD"
   SET request->phone[1].new_person = "Y"
   SET home_phone_id = 0.0
  ELSE
   SET request->phone[1].action_type = "UPT"
   SET request->phone[1].new_person = "N"
  ENDIF
  SET request->phone[1].phone_id = home_phone_id
  SET request->phone[1].parent_entity_name = "PERSON"
  SET request->phone[1].parent_entity_id = person_id
  SET request->phone[1].active_ind_ind = true
  SET request->phone[1].active_ind = 1
  SET request->phone[1].active_status_cd = reqdata->active_status_cd
  SET request->phone[1].data_status_cd = reqdata->data_status_cd
  SET request->phone[1].phone_num = requestin->list_0[lvar].home_phone_number
  SET request->phone[1].extension = ""
  SET request->phone[1].phone_type_cd = home_phone_type_cd
  SET request->phone[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
  SET request->phone[1].description = requestin->list_0[lvar].home_phone_description
  SET request->phone[1].contact = requestin->list_0[lvar].home_phone_contact
  SET request->phone[1].call_instruction = requestin->list_0[lvar].home_phone_call_instruction
  SET request->phone[1].phone_type_seq = 1
  EXECUTE pm_ens_phone
  SET home_phone_status = reply->status_data.status
 ELSE
  SET home_phone_status = "N"
 ENDIF
 IF ((requestin->list_0[lvar].pers_fax_number > " "))
  SET stat = alterlist(request->phone,0)
  SET stat = alterlist(request->phone,1)
  SET request->phone_qual = 1
  IF (bus_fax_phone_found="N")
   SET request->phone[1].action_type = "ADD"
   SET request->phone[1].new_person = "Y"
   SET home_phone_id = 0.0
  ELSE
   SET request->phone[1].action_type = "UPT"
   SET request->phone[1].new_person = "N"
  ENDIF
  SET request->phone[1].phone_id = pers_fax_phone_id
  SET request->phone[1].parent_entity_name = "PERSON"
  SET request->phone[1].parent_entity_id = person_id
  SET request->phone[1].active_ind_ind = true
  SET request->phone[1].active_ind = 1
  SET request->phone[1].active_status_cd = reqdata->active_status_cd
  SET request->phone[1].data_status_cd = reqdata->data_status_cd
  SET request->phone[1].phone_num = requestin->list_0[lvar].pers_fax_number
  SET request->phone[1].extension = ""
  SET request->phone[1].phone_type_cd = pers_fax_phone_type_cd
  SET request->phone[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
  SET request->phone[1].description = ""
  SET request->phone[1].contact = ""
  SET request->phone[1].call_instruction = ""
  SET request->phone[1].phone_type_seq = 1
  EXECUTE pm_ens_phone
  SET home_phone_status = reply->status_data.status
 ELSE
  SET home_phone_status = "N"
 ENDIF
 IF ((requestin->list_0[lvar].pers_pager_number > " "))
  SET stat = alterlist(request->phone,0)
  SET stat = alterlist(request->phone,1)
  SET request->phone_qual = 1
  IF (home_phone_found="N")
   SET request->phone[1].action_type = "ADD"
   SET request->phone[1].new_person = "Y"
   SET home_phone_id = 0.0
  ELSE
   SET request->phone[1].action_type = "UPT"
   SET request->phone[1].new_person = "N"
  ENDIF
  SET request->phone[1].phone_id = pers_pager_phone_id
  SET request->phone[1].parent_entity_name = "PERSON"
  SET request->phone[1].parent_entity_id = person_id
  SET request->phone[1].active_ind_ind = true
  SET request->phone[1].active_ind = 1
  SET request->phone[1].active_status_cd = reqdata->active_status_cd
  SET request->phone[1].data_status_cd = reqdata->data_status_cd
  SET request->phone[1].phone_num = requestin->list_0[lvar].pers_pager_number
  SET request->phone[1].extension = requestin->list_0[lvar].pers_pager_ext
  SET request->phone[1].phone_type_cd = pers_pgr_phone_type_cd
  SET request->phone[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
  SET request->phone[1].description = ""
  SET request->phone[1].contact = ""
  SET request->phone[1].call_instruction = ""
  SET request->phone[1].phone_type_seq = 1
  EXECUTE pm_ens_phone
  SET home_phone_status = reply->status_data.status
 ELSE
  SET home_phone_status = "N"
 ENDIF
 IF ((requestin->list_0[lvar].business_fax_number > " "))
  SET stat = alterlist(request->phone,0)
  SET stat = alterlist(request->phone,1)
  SET request->phone_qual = 1
  IF (home_phone_found="N")
   SET request->phone[1].action_type = "ADD"
   SET request->phone[1].new_person = "Y"
   SET home_phone_id = 0.0
  ELSE
   SET request->phone[1].action_type = "UPT"
   SET request->phone[1].new_person = "N"
  ENDIF
  SET request->phone[1].phone_id = bus_fax_phone_id
  SET request->phone[1].parent_entity_name = "PERSON"
  SET request->phone[1].parent_entity_id = person_id
  SET request->phone[1].active_ind_ind = true
  SET request->phone[1].active_ind = 1
  SET request->phone[1].active_status_cd = reqdata->active_status_cd
  SET request->phone[1].data_status_cd = reqdata->data_status_cd
  SET request->phone[1].phone_num = requestin->list_0[lvar].business_fax_number
  SET request->phone[1].extension = ""
  SET request->phone[1].phone_type_cd = bus_fax_phone_type_cd
  SET request->phone[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
  SET request->phone[1].description = ""
  SET request->phone[1].contact = ""
  SET request->phone[1].call_instruction = ""
  SET request->phone[1].phone_type_seq = 1
  EXECUTE pm_ens_phone
  SET home_phone_status = reply->status_data.status
 ELSE
  SET home_phone_status = "N"
 ENDIF
 IF ((requestin->list_0[lvar].business_pager_number > " "))
  SET stat = alterlist(request->phone,0)
  SET stat = alterlist(request->phone,1)
  SET request->phone_qual = 1
  IF (home_phone_found="N")
   SET request->phone[1].action_type = "ADD"
   SET request->phone[1].new_person = "Y"
   SET home_phone_id = 0.0
  ELSE
   SET request->phone[1].action_type = "UPT"
   SET request->phone[1].new_person = "N"
  ENDIF
  SET request->phone[1].phone_id = bus_pager_phone_id
  SET request->phone[1].parent_entity_name = "PERSON"
  SET request->phone[1].parent_entity_id = person_id
  SET request->phone[1].active_ind_ind = true
  SET request->phone[1].active_ind = 1
  SET request->phone[1].active_status_cd = reqdata->active_status_cd
  SET request->phone[1].data_status_cd = reqdata->data_status_cd
  SET request->phone[1].phone_num = requestin->list_0[lvar].business_pager_number
  SET request->phone[1].extension = requestin->list_0[lvar].business_pager_ext
  SET request->phone[1].phone_type_cd = bus_pgr_phone_type_cd
  SET request->phone[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
  SET request->phone[1].description = ""
  SET request->phone[1].contact = ""
  SET request->phone[1].call_instruction = ""
  SET request->phone[1].phone_type_seq = 1
  EXECUTE pm_ens_phone
  SET home_phone_status = reply->status_data.status
 ELSE
  SET home_phone_status = "N"
 ENDIF
 IF ((((requestin->list_0[lvar].business_phone_number > " ")) OR ((((requestin->list_0[lvar].
 business_phone_description > " ")) OR ((((requestin->list_0[lvar].business_phone_contact > " ")) OR
 ((requestin->list_0[lvar].business_phone_call_instruction > " "))) )) )) )
  SET stat = alterlist(request->phone,0)
  SET stat = alterlist(request->phone,1)
  SET request->phone_qual = 1
  IF (business_phone_found="N")
   SET request->phone[1].action_type = "ADD"
   SET request->phone[1].new_person = "Y"
   SET business_phone_id = 0.0
  ELSE
   SET request->phone[1].action_type = "UPT"
   SET request->phone[1].new_person = "N"
  ENDIF
  SET request->phone[1].phone_id = business_phone_id
  SET request->phone[1].parent_entity_name = "PERSON"
  SET request->phone[1].parent_entity_id = person_id
  SET request->phone[1].active_ind_ind = true
  SET request->phone[1].active_ind = 1
  SET request->phone[1].active_status_cd = reqdata->active_status_cd
  SET request->phone[1].data_status_cd = reqdata->data_status_cd
  SET request->phone[1].phone_num = requestin->list_0[lvar].business_phone_number
  SET request->phone[1].extension = requestin->list_0[lvar].business_phone_extension
  SET request->phone[1].phone_type_cd = business_phone_type_cd
  SET request->phone[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime)
  SET request->phone[1].description = requestin->list_0[lvar].business_phone_description
  SET request->phone[1].contact = requestin->list_0[lvar].business_phone_contact
  SET request->phone[1].call_instruction = requestin->list_0[lvar].business_phone_call_instruction
  SET request->phone[1].phone_type_seq = 1
  EXECUTE pm_ens_phone
  SET business_phone_status = reply->status_data.status
 ELSE
  SET business_phone_status = "N"
 ENDIF
#call_pm_ens_phone_exit
#add_prsnl_org_reltn
 SELECT INTO "nl:"
  r.prsnl_org_reltn_id
  FROM prsnl_org_reltn r
  WHERE r.person_id=person_id
   AND (r.organization_id=org_rel_status->list[1].org_id)
  WITH nocounter
 ;end select
 SET rel_org_id = org_rel_status->list[1].org_id
 IF (curqual=0)
  SET org_rel_status->list[1].org_rel_found = "N"
  SET new_nbr = 0
  SELECT INTO "nl:"
   y = seq(prsnl_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    new_nbr = cnvtreal(y)
   WITH format, counter
  ;end select
  IF (curqual=0)
   SET org_rel_status->list[1].status = "F"
  ELSE
   INSERT  FROM prsnl_org_reltn p
    SET p.prsnl_org_reltn_id = new_nbr, p.person_id = person_id, p.organization_id = rel_org_id,
     p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100 00:00:00.00"), p.active_ind = 1,
     p.active_status_cd = reqdata->active_status_cd, p.active_status_prsnl_id = reqinfo->updt_id, p
     .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id,
     p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.confid_level_cd = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET org_rel_status->list[1].status = "F"
   ELSE
    SET org_rel_status->list[1].status = "S"
   ENDIF
  ENDIF
 ELSE
  SET org_rel_status->list[1].org_rel_found = "F"
  SET org_rel_status->list[1].status = "E"
 ENDIF
 SET relorg = size(requestin->list_0[lvar].list_2,5)
 SET org_rel_status->qual = (relorg+ 1)
 SET rel_org_id = 0
 FOR (ovar = 1 TO relorg)
   SET xvar = (ovar+ 1)
   SET org_rel_status->list[xvar].org_name = requestin->list_0[lvar].list_2[ovar].relation_org_name
   IF ((requestin->list_0[lvar].list_2[ovar].relation_org_name > " ")
    AND (pool_cds->qual[5].alias_type_cd > 0)
    AND ovar < 101)
    SET rel_org_name = substring(1,100,cnvtupper(cnvtalphanum(requestin->list_0[lvar].list_2[ovar].
       relation_org_name)))
    SELECT INTO "nl:"
     o.organization_id
     FROM organization o,
      org_type_reltn otr
     PLAN (o
      WHERE o.org_name_key=rel_org_name
       AND o.org_class_cd=org_class_cd
       AND (o.data_status_cd=reqdata->data_status_cd)
       AND o.active_ind=1
       AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND o.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
      JOIN (otr
      WHERE otr.organization_id=o.organization_id
       AND ((otr.org_type_cd=facility_cd) OR (otr.org_type_cd=client_cd)) )
     DETAIL
      rel_org_id = o.organization_id
     WITH counter
    ;end select
    IF (rel_org_id > 0)
     SET org_rel_status->list[xvar].org_found = "F"
     SET org_rel_status->list[xvar].org_id = rel_org_id
     SELECT INTO "nl:"
      r.prsnl_org_reltn_id
      FROM prsnl_org_reltn r
      WHERE r.person_id=person_id
       AND r.organization_id=rel_org_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET org_rel_status->list[xvar].org_rel_found = "N"
      SET new_nbr = 0
      SELECT INTO "nl:"
       y = seq(prsnl_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_nbr = cnvtreal(y)
       WITH format, counter
      ;end select
      IF (curqual=0)
       SET org_rel_status->list[xvar].status = "F"
      ELSE
       INSERT  FROM prsnl_org_reltn p
        SET p.prsnl_org_reltn_id = new_nbr, p.person_id = person_id, p.organization_id = rel_org_id,
         p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime
         ("31-DEC-2100 00:00:00.00"), p.active_ind = 1,
         p.active_status_cd = reqdata->active_status_cd, p.active_status_prsnl_id = reqinfo->updt_id,
         p.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
         p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id,
         p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.confid_level_cd
          = 0
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET org_rel_status->list[xvar].status = "F"
       ELSE
        SET org_rel_status->list[xvar].status = "S"
       ENDIF
      ENDIF
     ELSE
      SET org_rel_status->list[xvar].org_rel_found = "F"
      SET org_rel_status->list[xvar].status = "E"
     ENDIF
    ELSE
     SET org_rel_status->list[xvar].org_found = "N"
    ENDIF
   ENDIF
 ENDFOR
#add_prsnl_org_reltn_exit
#set_exists_flags
 SELECT INTO "nl:"
  p.person_id
  FROM person p
  PLAN (p
   WHERE p.person_id=person_id)
  DETAIL
   person_id = p.person_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET person_found = "N"
 ELSE
  SET person_found = "Y"
 ENDIF
 SELECT INTO "nl:"
  p.person_name_id
  FROM person_name p
  PLAN (p
   WHERE p.person_id=person_id
    AND p.name_type_cd=current_name_type_cd)
  DETAIL
   current_person_name_id = p.person_name_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET current_person_name_found = "N"
 ELSE
  SET current_person_name_found = "Y"
 ENDIF
 SELECT INTO "nl:"
  p.person_name_id
  FROM person_name p
  PLAN (p
   WHERE p.person_id=person_id
    AND p.name_type_cd=prsnl_name_type_cd)
  DETAIL
   prsnl_person_name_id = p.person_name_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET prsnl_person_name_found = "N"
 ELSE
  SET prsnl_person_name_found = "Y"
 ENDIF
 SELECT INTO "nl:"
  p.person_alias_id
  FROM person_alias p
  PLAN (p
   WHERE p.person_id=person_id
    AND p.person_alias_type_cd=person_ssn_alias_type_cd
    AND p.alias_pool_cd=person_ssn_alias_pool_cd)
  DETAIL
   person_alias_id = p.person_alias_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET person_ssn_alias_found = "N"
 ELSE
  SET person_ssn_alias_found = "Y"
 ENDIF
 SELECT INTO "nl:"
  a.address_id
  FROM address a
  PLAN (a
   WHERE a.parent_entity_id=person_id
    AND a.parent_entity_name="PERSON"
    AND a.address_type_cd=home_address_type_cd)
  DETAIL
   home_address_id = a.address_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET home_address_found = "N"
 ELSE
  SET home_address_found = "Y"
 ENDIF
 SELECT INTO "nl:"
  a.address_id
  FROM address a
  PLAN (a
   WHERE a.parent_entity_id=person_id
    AND a.parent_entity_name="PERSON"
    AND a.address_type_cd=business_address_type_cd)
  DETAIL
   business_address_id = a.address_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET business_address_found = "N"
 ELSE
  SET business_address_found = "Y"
 ENDIF
 SELECT INTO "nl:"
  a.phone_id
  FROM phone a
  PLAN (a
   WHERE a.parent_entity_id=person_id
    AND a.parent_entity_name="PERSON"
    AND a.phone_type_cd=home_phone_type_cd)
  DETAIL
   home_phone_id = a.phone_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET home_phone_found = "N"
 ELSE
  SET home_phone_found = "Y"
 ENDIF
 SELECT INTO "nl:"
  a.phone_id
  FROM phone a
  PLAN (a
   WHERE a.parent_entity_id=person_id
    AND a.parent_entity_name="PERSON"
    AND a.phone_type_cd=business_phone_type_cd)
  DETAIL
   business_phone_id = a.phone_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET business_phone_found = "N"
 ELSE
  SET business_phone_found = "Y"
 ENDIF
 SELECT INTO "nl:"
  a.phone_id
  FROM phone a
  PLAN (a
   WHERE a.parent_entity_id=person_id
    AND a.parent_entity_name="PERSON"
    AND a.phone_type_cd=bus_fax_phone_type_cd)
  DETAIL
   bus_fax_phone_id = a.phone_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET bus_fax_phone_found = "N"
 ELSE
  SET bus_fax_phone_found = "Y"
 ENDIF
 SELECT INTO "nl:"
  a.phone_id
  FROM phone a
  PLAN (a
   WHERE a.parent_entity_id=person_id
    AND a.parent_entity_name="PERSON"
    AND a.phone_type_cd=bus_pgr_phone_type_cd)
  DETAIL
   bus_pager_phone_id = a.phone_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET bus_pgr_phone_found = "N"
 ELSE
  SET bus_pgr_phone_found = "Y"
 ENDIF
 SELECT INTO "nl:"
  a.phone_id
  FROM phone a
  PLAN (a
   WHERE a.parent_entity_id=person_id
    AND a.parent_entity_name="PERSON"
    AND a.phone_type_cd=pers_fax_phone_type_cd)
  DETAIL
   pers_fax_phone_id = a.phone_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET pers_fax_phone_found = "N"
 ELSE
  SET pers_fax_phone_found = "Y"
 ENDIF
 SELECT INTO "nl:"
  a.phone_id
  FROM phone a
  PLAN (a
   WHERE a.parent_entity_id=person_id
    AND a.parent_entity_name="PERSON"
    AND a.phone_type_cd=pers_pgr_phone_type_cd)
  DETAIL
   pers_pager_phone_id = a.phone_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET pers_pgr_phone_found = "N"
 ELSE
  SET pers_pgr_phone_found = "Y"
 ENDIF
 SELECT INTO "nl:"
  p.person_id
  FROM prsnl p
  PLAN (p
   WHERE p.person_id=person_id)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET prsnl_found = "N"
 ELSE
  SET prsnl_found = "Y"
 ENDIF
 SELECT INTO "nl:"
  p.person_id
  FROM prsnl_alias p
  PLAN (p
   WHERE p.person_id=person_id
    AND (p.prsnl_alias_type_cd=pool_cds->qual[1].alias_type_cd)
    AND (p.alias_pool_cd=pool_cds->qual[1].alias_pool_cd))
  DETAIL
   prsnlid_id = p.prsnl_alias_id, prsnlid_alias = p.alias
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET prsnlid_found = "N"
 ELSE
  SET prsnlid_found = "Y"
 ENDIF
 SELECT INTO "nl:"
  p.person_id
  FROM prsnl_alias p
  PLAN (p
   WHERE p.person_id=person_id
    AND (p.prsnl_alias_type_cd=pool_cds->qual[3].alias_type_cd)
    AND (p.alias_pool_cd=pool_cds->qual[3].alias_pool_cd))
  DETAIL
   docdea_id = p.prsnl_alias_id, docdea_alias = p.alias
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET docdea_found = "N"
 ELSE
  SET docdea_found = "Y"
 ENDIF
 SELECT INTO "nl:"
  p.person_id
  FROM prsnl_alias p
  PLAN (p
   WHERE p.person_id=person_id
    AND (p.prsnl_alias_type_cd=pool_cds->qual[4].alias_type_cd)
    AND (p.alias_pool_cd=pool_cds->qual[4].alias_pool_cd))
  DETAIL
   docupin_id = p.prsnl_alias_id, docupin_alias = p.alias
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET docupin_found = "N"
 ELSE
  SET docupin_found = "Y"
 ENDIF
 SELECT INTO "nl:"
  p.person_id
  FROM prsnl_alias p
  PLAN (p
   WHERE p.person_id=person_id
    AND (p.prsnl_alias_type_cd=pool_cds->qual[5].alias_type_cd)
    AND (p.alias_pool_cd=pool_cds->qual[5].alias_pool_cd))
  DETAIL
   docnbr_id = p.prsnl_alias_id, docnbr_alias = p.alias
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET docnbr_found = "N"
 ELSE
  SET docnbr_found = "Y"
 ENDIF
 SELECT INTO "nl:"
  p.person_id
  FROM prsnl_alias p
  PLAN (p
   WHERE p.person_id=person_id
    AND (p.prsnl_alias_type_cd=pool_cds->qual[6].alias_type_cd)
    AND (p.alias_pool_cd=pool_cds->qual[6].alias_pool_cd))
  DETAIL
   doccnbr_id = p.prsnl_alias_id, doccnbr_alias = p.alias
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET doccnbr_found = "N"
 ELSE
  SET doccnbr_found = "Y"
 ENDIF
#set_exists_flags_exit
#exit_pgm
END GO
