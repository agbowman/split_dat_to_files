CREATE PROGRAM dcp_ppr_override_report:dba
 EXECUTE cclseclogin
 DECLARE begdttm = vc WITH private, noconstant(fillstring(35," "))
 DECLARE output = vc WITH private, noconstant(fillstring(13," "))
 DECLARE override = vc WITH private, noconstant(fillstring(80," "))
 DECLARE status = vc WITH private, noconstant(fillstring(80," "))
 DECLARE relationships = vc WITH private, noconstant(fillstring(80," "))
 DECLARE user = vc WITH private, noconstant(fillstring(80," "))
 DECLARE reltnselect = vc WITH private, noconstant(fillstring(2," "))
 DECLARE reltndisplay = vc WITH private, noconstant(fillstring(100," "))
 DECLARE personclause = vc WITH private, noconstant(fillstring(80," "))
 DECLARE daterange = vc WITH public, noconstant(fillstring(100," "))
 DECLARE encntr_org_sec_ind = i2 WITH public, noconstant(0)
 DECLARE confid_ind = i2 WITH public, noconstant(0)
 DECLARE dminfo_ok = i2 WITH noconstant(0)
 SET dminfo_ok = validate(ccldminfo->mode,0)
 CALL echo(concat("Ccldminfo exists= ",build(dminfo_ok)))
 IF (dminfo_ok=1)
  SET encntr_org_sec_ind = ccldminfo->sec_org_reltn
  SET confid_ind = ccldminfo->sec_confid
 ELSE
  SELECT INTO "nl:"
   FROM dm_info di
   PLAN (di
    WHERE di.info_domain="SECURITY"
     AND di.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID"))
   DETAIL
    IF (di.info_name="SEC_ORG_RELTN"
     AND di.info_number=1)
     encntr_org_sec_ind = 1
    ELSEIF (di.info_name="SEC_CONFID"
     AND di.info_number=1)
     confid_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 CALL clear(1,1)
 CALL text(1,2,"Output File/Printer/Mine (MINE)? ")
 CALL accept(1,35,"PPPPPPPPP;CU","MINE")
 SET output = curaccept
 CALL text(3,2,"Override Type: (O)verride Only or (B)oth")
 IF (((encntr_org_sec_ind=1) OR (confid_ind=0)) )
  CALL accept(3,43,"A;CU","B"
   WHERE curaccept IN ("O", "B"))
 ELSE
  CALL accept(3,43,"A;CU","O"
   WHERE curaccept IN ("O", "B"))
 ENDIF
 IF (curaccept="O")
  SET override = 'cve.code_set = 331 and cve.field_name = "Override" and cve.field_value = "1"'
 ELSE
  SET override =
  'cve.code_set = 331 and cve.field_name = "Override" and cve.field_value in ("1", "2")'
 ENDIF
 CALL text(5,2,"Relationship Status: (A)LL, A(C)TIVE, (I)NACTIVE")
 CALL accept(5,52,"A;CU","C"
  WHERE curaccept IN ("A", "C", "I"))
 IF (curaccept="A")
  SET status = "ppr.active_ind in (0, 1)"
 ELSEIF (curaccept="I")
  SET status = "ppr.active_ind = 0"
 ELSE
  SET status = "ppr.active_ind = 1"
 ENDIF
 CALL text(7,2,"Display relationships activated in the last      days")
 CALL accept(7,46,"9999;C","30")
 SET daterange = "ppr.beg_effective_dt_tm >= cnvtdatetime(curdate - "
 SET daterange = concat(daterange,curaccept,", curtime)")
 CALL text(9,2,"(A)ll relationships, (S)elf-declared Only")
 CALL accept(9,47,"A;CU","S"
  WHERE curaccept IN ("A", "S"))
 SET reltnselect = curaccept
 IF (curaccept="S")
  SET relationships = "ppr.manual_create_by_id = ppr.prsnl_person_id and ppr.prsnl_person_id > 0"
 ELSE
  SET relationships = "ppr.prsnl_person_id > 0"
 ENDIF
 CALL text(11,2,"(A)ll users or enter prsnl_id")
 CALL accept(11,33,"P(15);C","A")
 IF (substring(1,1,curaccept) != "A"
  AND reltnselect="S")
  SET relationships = "ppr.prsnl_person_id = "
  SET user = "and ppr.manual_create_by_id = "
  SET relationships = concat(relationships,curaccept,user,curaccept)
 ELSEIF (substring(1,1,curaccept) != "A"
  AND reltnselect="A")
  SET relationships = "ppr.prsnl_person_id = "
  SET relationships = concat(relationships,curaccept)
 ENDIF
 IF (curaccept="A")
  CALL text(13,2,"(A)ll patients or enter person_id")
  CALL accept(13,40,"P(15);C","A")
  IF (substring(1,1,curaccept)="A")
   SET personclause = "ppr.person_id > 0"
  ELSE
   SET personclause = "ppr.person_id = "
   SET personclause = concat(personclause,curaccept)
  ENDIF
 ELSE
  SET personclause = "ppr.person_id > 0"
 ENDIF
 SELECT INTO value(output)
  FROM code_value_extension cve,
   person_prsnl_reltn ppr,
   person p,
   prsnl pr
  PLAN (cve
   WHERE parser(override))
   JOIN (ppr
   WHERE ppr.person_prsnl_r_cd=cve.code_value
    AND parser(status)
    AND parser(relationships)
    AND parser(personclause)
    AND parser(daterange))
   JOIN (p
   WHERE p.person_id=ppr.person_id)
   JOIN (pr
   WHERE pr.person_id=ppr.prsnl_person_id)
  ORDER BY pr.person_id, p.name_full_formatted
  HEAD pr.person_id
   "User: ", pr.name_full_formatted, row + 1,
   col 0, "Patient", col 30,
   "Begin", col 60, "Type",
   col 93, "Override Type", row + 1
  DETAIL
   begdttm = format(ppr.beg_effective_dt_tm,";;Q"), reltndisplay = uar_get_code_display(cve
    .code_value), col 0,
   p.name_full_formatted, col 30, begdttm,
   col 60, reltndisplay, col 93
   IF (cve.field_value="1")
    "Organizational Only"
   ELSE
    "Organizational/Confidentiality"
   ENDIF
   row + 1
  FOOT  pr.person_id
   row + 1
  WITH nocounter
 ;end select
END GO
