CREATE PROGRAM ams_no_chg_audit_gen_lab
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility to View Data" = 0,
  "Enter Start Date" = "CURDATE",
  "Enter End Date" = "CURDATE",
  "Detail or Group?" = ""
  WITH outdev, org, startdt,
  enddt, mode
 RECORD black_list(
   1 list[*]
     2 org_id = f8
     2 catalog_cd = f8
 )
 RECORD org(
   1 org[*]
     2 org_id = f8
 )
 RECORD chg(
   1 chg[*]
     2 org_name = c60
     2 type = c40
     2 fin = vc
     2 patient_name = vc
     2 order_id = f8
     2 accession = vc
     2 order_mnemonic = c100
     2 order_set_mnemonic = c100
     2 catalog_cd = f8
     2 primary_syn = c100
     2 order_dt_tm = dq8
     2 order_status = vc
     2 dept_status = vc
     2 action_type = vc
     2 action_personnel_id = f8
     2 action_personnel_name = vc
     2 order_provider_id = f8
     2 order_provider_name = vc
 )
 DECLARE logdomain(p1=f8) = f8
 DECLARE orgfilter(p1=f8) = i2
 DECLARE gen_lab_cd = f8
 DECLARE fin_cd = f8
 DECLARE order_cd = f8
 DECLARE completed_cd = f8
 DECLARE primary_cd = f8
 DECLARE dept_completed_cd = f8
 DECLARE user_log_domain = f8
 DECLARE num = i4
 DECLARE num1 = i4
 DECLARE num2 = i4
 SET gen_lab_cd = uar_get_code_by("MEANING",106,"GLB")
 SET fin_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 SET order_cd = uar_get_code_by("MEANING",6003,"ORDER")
 SET completed_cd = uar_get_code_by("MEANING",6004,"COMPLETED")
 SET primary_cd = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET dept_completed_cd = uar_get_code_by("MEANING",14281,"COMPLETED")
 SET user_log_domain = logdomain(reqinfo->updt_id)
 SET has_orgs = orgfilter(reqinfo->updt_id)
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_number=user_log_domain
   AND d.info_domain="NOCHG-GENLAB"
   AND (cnvtreal(d.info_name)= $ORG)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(black_list->list,cnt), black_list->list[cnt].org_id = cnvtreal(d
    .info_name),
   black_list->list[cnt].catalog_cd = cnvtreal(d.info_domain_id)
  WITH nocounter
 ;end select
 IF (size(black_list->list,5)=0)
  SET stat = alterlist(black_list->list,1)
  SET black_list->list[1].catalog_cd = 0
  SET black_list->list[1].org_id = 0
 ENDIF
 IF (( $MODE="0"))
  SELECT INTO "nl:"
   org.org_name, fin = ea.alias, p.name_full_formatted,
   o.order_id, aor.accession, o.order_mnemonic,
   o.catalog_cd, primary_synonym = ocs.mnemonic, o.orig_order_dt_tm,
   o_order_status_disp = uar_get_code_display(o.order_status_cd), o_dept_status_disp =
   uar_get_code_display(o.dept_status_cd), oa.action_type_cd,
   oa_action_type_disp = uar_get_code_display(oa.action_type_cd), oa.action_personnel_id,
   action_personnel = p1.name_full_formatted,
   oa.order_provider_id, order_provider = p2.name_full_formatted
   FROM orders o,
    person p,
    order_catalog_synonym ocs,
    accession_order_r aor,
    encounter e,
    organization org,
    encntr_alias ea,
    order_action oa,
    prsnl p1,
    prsnl p2
   PLAN (o
    WHERE o.orig_order_dt_tm >= cnvtdatetime(cnvtdate( $STARTDT),000000)
     AND o.orig_order_dt_tm <= cnvtdatetime(cnvtdate( $ENDDT),235959)
     AND ((o.activity_type_cd+ 0)=gen_lab_cd)
     AND ((o.order_status_cd+ 0)=completed_cd)
     AND ((o.dept_status_cd+ 0)=dept_completed_cd)
     AND o.template_order_flag != 1
     AND o.cs_flag=0
     AND  NOT ( EXISTS (
    (SELECT
     c.order_id
     FROM charge c
     WHERE c.order_id=o.order_id)))
     AND  NOT (expand(num1,1,size(black_list->list,5),o.catalog_cd,black_list->list[num1].catalog_cd)
    ))
    JOIN (p
    WHERE o.person_id=p.person_id)
    JOIN (ocs
    WHERE o.catalog_cd=ocs.catalog_cd
     AND ocs.mnemonic_type_cd=primary_cd)
    JOIN (oa
    WHERE o.order_id=oa.order_id
     AND oa.action_type_cd=order_cd)
    JOIN (p1
    WHERE oa.action_personnel_id=p1.person_id)
    JOIN (p2
    WHERE oa.order_provider_id=p2.person_id)
    JOIN (e
    WHERE e.encntr_id=o.encntr_id
     AND e.active_ind=1
     AND (e.organization_id= $ORG))
    JOIN (org
    WHERE org.organization_id=e.organization_id
     AND org.logical_domain_id=user_log_domain
     AND expand(num,1,size(org->org,5),org.organization_id,org->org[num].org_id))
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.encntr_alias_type_cd=fin_cd
     AND ea.active_ind=1)
    JOIN (aor
    WHERE outerjoin(o.order_id)=aor.order_id)
   ORDER BY p.name_full_formatted, o.order_id
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(chg->chg,(cnt+ 9))
    ENDIF
    chg->chg[cnt].org_name = org.org_name, chg->chg[cnt].type = "Basic Order", chg->chg[cnt].fin = ea
    .alias,
    chg->chg[cnt].patient_name = p.name_full_formatted, chg->chg[cnt].order_id = o.order_id, chg->
    chg[cnt].accession = aor.accession,
    chg->chg[cnt].order_mnemonic = o.order_mnemonic, chg->chg[cnt].catalog_cd = o.catalog_cd, chg->
    chg[cnt].primary_syn = ocs.mnemonic,
    chg->chg[cnt].order_dt_tm = o.orig_order_dt_tm, chg->chg[cnt].order_status = uar_get_code_display
    (o.order_status_cd), chg->chg[cnt].dept_status = uar_get_code_display(o.dept_status_cd),
    chg->chg[cnt].action_type = uar_get_code_display(oa.action_type_cd), chg->chg[cnt].
    action_personnel_id = oa.action_personnel_id, chg->chg[cnt].action_personnel_name = p1
    .name_full_formatted,
    chg->chg[cnt].order_provider_id = oa.order_provider_id, chg->chg[cnt].order_provider_name = p2
    .name_full_formatted
   FOOT REPORT
    stat = alterlist(chg->chg,cnt)
   WITH format(date,";;q")
  ;end select
  SELECT INTO "nl:"
   org.org_name, fin = ea.alias, p.name_full_formatted,
   o.order_id, aor.accession, o.order_mnemonic,
   o.catalog_cd, primary_synonym = ocs.mnemonic, o.orig_order_dt_tm,
   o_order_status_disp = uar_get_code_display(o.order_status_cd), o_dept_status_disp =
   uar_get_code_display(o.dept_status_cd), oa.action_type_cd,
   oa_action_type_disp = uar_get_code_display(oa.action_type_cd), oa.action_personnel_id,
   action_personnel = p1.name_full_formatted,
   oa.order_provider_id, order_provider = p2.name_full_formatted
   FROM orders o,
    orders o3,
    person p,
    order_catalog_synonym ocs,
    accession_order_r aor,
    encounter e,
    organization org,
    encntr_alias ea,
    order_action oa,
    prsnl p1,
    prsnl p2
   PLAN (o
    WHERE o.orig_order_dt_tm >= cnvtdatetime(cnvtdate( $STARTDT),000000)
     AND o.orig_order_dt_tm <= cnvtdatetime(cnvtdate( $ENDDT),235959)
     AND ((o.activity_type_cd+ 0)=gen_lab_cd)
     AND ((o.order_status_cd+ 0)=completed_cd)
     AND ((o.dept_status_cd+ 0)=dept_completed_cd)
     AND o.template_order_flag != 1
     AND o.cs_flag=2
     AND  NOT ( EXISTS (
    (SELECT
     c.order_id
     FROM charge c
     WHERE c.order_id=o.order_id)))
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM orders o2
     WHERE o2.order_id=o.cs_order_id
      AND o2.cs_flag=1
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM charge c2
      WHERE c2.order_id=o2.order_id))))))
     AND  NOT (expand(num1,1,size(black_list->list,5),o.catalog_cd,black_list->list[num1].catalog_cd)
    ))
    JOIN (o3
    WHERE o.cs_order_id=o3.order_id)
    JOIN (p
    WHERE o.person_id=p.person_id)
    JOIN (ocs
    WHERE o.catalog_cd=ocs.catalog_cd
     AND ocs.mnemonic_type_cd=primary_cd)
    JOIN (oa
    WHERE o.order_id=oa.order_id
     AND oa.action_type_cd=order_cd)
    JOIN (p1
    WHERE oa.action_personnel_id=p1.person_id)
    JOIN (p2
    WHERE oa.order_provider_id=p2.person_id)
    JOIN (e
    WHERE e.encntr_id=o.encntr_id
     AND e.active_ind=1
     AND (e.organization_id= $ORG))
    JOIN (org
    WHERE org.organization_id=e.organization_id
     AND org.logical_domain_id=user_log_domain
     AND expand(num,1,size(org->org,5),org.organization_id,org->org[num].org_id))
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.encntr_alias_type_cd=fin_cd
     AND ea.active_ind=1)
    JOIN (aor
    WHERE outerjoin(o.order_id)=aor.order_id)
   ORDER BY p.name_full_formatted, o.order_id
   HEAD REPORT
    cnt = size(chg->chg,5),
    CALL echo(build2("cnt: ",cnt)),
    CALL echo(build2("size: ",size(chg->chg,5))),
    add_size = (10 - mod(cnt,10)), stat = alterlist(chg->chg,(cnt+ add_size)),
    CALL echo(build2("size2: ",size(chg->chg,5)))
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(chg->chg,(cnt+ 9))
    ENDIF
    chg->chg[cnt].org_name = org.org_name, chg->chg[cnt].type = "Order Set Member", chg->chg[cnt].fin
     = ea.alias,
    chg->chg[cnt].patient_name = p.name_full_formatted, chg->chg[cnt].order_id = o.order_id, chg->
    chg[cnt].accession = aor.accession,
    chg->chg[cnt].order_mnemonic = o.order_mnemonic, chg->chg[cnt].order_set_mnemonic = o3
    .order_mnemonic, chg->chg[cnt].catalog_cd = o.catalog_cd,
    chg->chg[cnt].primary_syn = ocs.mnemonic, chg->chg[cnt].order_dt_tm = o.orig_order_dt_tm, chg->
    chg[cnt].order_status = uar_get_code_display(o.order_status_cd),
    chg->chg[cnt].dept_status = uar_get_code_display(o.dept_status_cd), chg->chg[cnt].action_type =
    uar_get_code_display(oa.action_type_cd), chg->chg[cnt].action_personnel_id = oa
    .action_personnel_id,
    chg->chg[cnt].action_personnel_name = p1.name_full_formatted, chg->chg[cnt].order_provider_id =
    oa.order_provider_id, chg->chg[cnt].order_provider_name = p2.name_full_formatted
   FOOT REPORT
    stat = alterlist(chg->chg,cnt)
   WITH format(date,";;q")
  ;end select
  SELECT INTO  $OUTDEV
   org_name = chg->chg[d.seq].org_name, type = chg->chg[d.seq].type, fin = chg->chg[d.seq].fin,
   patient_name = chg->chg[d.seq].patient_name, order_id = chg->chg[d.seq].order_id, accession = chg
   ->chg[d.seq].accession,
   order_mnemonic = chg->chg[d.seq].order_mnemonic, order_set_mnemonic = chg->chg[d.seq].
   order_set_mnemonic, catalog_cd = chg->chg[d.seq].catalog_cd,
   primary_syn = chg->chg[d.seq].primary_syn, order_dt = format(chg->chg[d.seq].order_dt_tm,
    "mm/dd/yyyy hh:mm;;q"), order_status = chg->chg[d.seq].order_status,
   dept_status = chg->chg[d.seq].dept_status, action_type = chg->chg[d.seq].action_type,
   action_personnel_id = chg->chg[d.seq].action_personnel_id,
   action_personnel_name = chg->chg[d.seq].action_personnel_name, order_provider_id = chg->chg[d.seq]
   .order_provider_id, order_provider_name = chg->chg[d.seq].order_provider_name
   FROM (dummyt d  WITH seq = size(chg->chg,5))
   PLAN (d)
   WITH nocounter, maxcol = 50000, skipreport = 1,
    format, separator = " "
  ;end select
 ELSEIF (( $MODE="1"))
  SELECT INTO  $OUTDEV
   org.org_name, o.order_mnemonic, o.catalog_cd,
   ocs.mnemonic, count(1)
   FROM orders o,
    order_catalog_synonym ocs,
    encounter e,
    organization org
   PLAN (o
    WHERE o.orig_order_dt_tm >= cnvtdatetime(cnvtdate( $STARTDT),000000)
     AND o.orig_order_dt_tm <= cnvtdatetime(cnvtdate( $ENDDT),235959)
     AND ((o.activity_type_cd+ 0)=gen_lab_cd)
     AND ((o.order_status_cd+ 0)=completed_cd)
     AND ((o.dept_status_cd+ 0)=dept_completed_cd)
     AND o.template_order_flag != 1
     AND o.cs_flag=0
     AND  NOT ( EXISTS (
    (SELECT
     c.order_id
     FROM charge c
     WHERE c.order_id=o.order_id)))
     AND  NOT (expand(num1,1,size(black_list->list,5),o.catalog_cd,black_list->list[num1].catalog_cd)
    ))
    JOIN (ocs
    WHERE o.catalog_cd=ocs.catalog_cd
     AND ocs.mnemonic_type_cd=primary_cd)
    JOIN (e
    WHERE e.encntr_id=o.encntr_id
     AND e.active_ind=1
     AND (e.organization_id= $ORG))
    JOIN (org
    WHERE org.organization_id=e.organization_id
     AND org.logical_domain_id=user_log_domain
     AND expand(num,1,size(org->org,5),org.organization_id,org->org[num].org_id))
   GROUP BY org.org_name, o.order_mnemonic, o.catalog_cd,
    ocs.mnemonic
   ORDER BY count(1) DESC
   WITH format(date,";;q"), format, separator = " "
  ;end select
 ENDIF
 SUBROUTINE logdomain(person_id)
   DECLARE logical_domain_id = f8
   SET logical_domain_id = 0.0
   SELECT INTO "nl:"
    p.logical_domain_id
    FROM prsnl p
    WHERE (p.person_id=reqinfo->updt_id)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    DETAIL
     IF (p.person_id > 0)
      logical_domain_id = p.logical_domain_id
     ENDIF
    WITH nocounter
   ;end select
   RETURN(logical_domain_id)
 END ;Subroutine
 SUBROUTINE orgfilter(person_id)
   DECLARE has_orgs = i2
   SELECT INTO "nl:"
    FROM prsnl_org_reltn por
    WHERE (por.person_id=reqinfo->updt_id)
     AND por.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(org->org,cnt), org->org[cnt].org_id = por.organization_id
    FOOT REPORT
     IF (cnt > 0)
      has_orgs = 1
     ENDIF
    WITH nocounter
   ;end select
   RETURN(has_orgs)
 END ;Subroutine
END GO
