CREATE PROGRAM bhs_usage_report
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = curdate,
  "End Date" = curdate
  WITH outdev, sdate, edate
 DECLARE radiology = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"RADIOLOGY")), protect
 DECLARE pharmacy = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"PHARMACY")), protect
 FREE RECORD usage
 RECORD usage(
   1 prsnl[*]
     2 pname = vc
     2 position = vc
     2 application = vc
     2 applid = i4
     2 poscd = f8
     2 logins = i4
     2 phyind = i2
     2 personid = f8
     2 pnuser = i2
     2 pfuser = i2
     2 pcouser = i2
   1 userswithord = i4
   1 totalradord = i4
   1 phaorders = i4
   1 userswithpn = i4
   1 userswithdoc = i4
 )
 FREE RECORD userid
 RECORD userid(
   1 qual[*]
     2 personid = f8
 )
 FREE RECORD usage2
 RECORD usage2(
   1 pcusers = i4
   1 pcousers = i4
   1 omfusers = i4
   1 userswithord = i4
   1 totalradord = i4
   1 phaorders = i4
   1 userswithpn = i4
   1 userswithdoc = i4
 )
 DECLARE pc_users = i4
 DECLARE pco_phy_users = i4
 DECLARE pn_users = i4
 DECLARE pf_users = i4
 DECLARE ph_orders = i4
 DECLARE omf_users = i4
 DECLARE users_ord = i4
 DECLARE min_oid = f8
 DECLARE max_oid = f8
 SELECT DISTINCT INTO "nl:"
  FROM omf_app_ctx_month_st ocx,
   prsnl pr
  PLAN (pr
   WHERE pr.active_status_cd=188
    AND pr.username IN ("EN*", "PN*")
    AND  NOT (pr.position_cd IN (441, 319324234, 686743, 227463062, 227477522,
   227479880, 227470547, 227493216, 227460684, 227463639,
   227467321, 227479357, 227479598, 228839068, 228839745,
   227455501, 227463714, 227464173, 227464799, 227468561,
   227469966, 227470094, 227470716, 227478988, 227479223,
   225116230, 241970625, 283540467, 228840170)))
   JOIN (ocx
   WHERE pr.person_id=ocx.person_id
    AND ocx.start_month BETWEEN cnvtdatetime(cnvtdate( $SDATE),0) AND cnvtdatetime(cnvtdate( $EDATE),
    235959)
    AND ocx.application_number IN (600005))
  ORDER BY ocx.person_id, ocx.application_number, 0
  HEAD REPORT
   cnt = 0, stat = alterlist(usage->prsnl,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(usage->prsnl,(cnt+ 10))
   ENDIF
   usage->prsnl[cnt].personid = pr.person_id, usage->prsnl[cnt].position = uar_get_code_display(pr
    .position_cd), usage->prsnl[cnt].pname = trim(pr.name_full_formatted),
   usage->prsnl[cnt].application =
   IF (ocx.application_number=380000) "PharmNet - Inpatient"
   ELSEIF (ocx.application_number=600005) "PowerChart"
   ELSEIF (ocx.application_number=961000) "PCO"
   ELSEIF (ocx.application_number=950001) "OMF"
   ENDIF
   , usage->prsnl[cnt].applid = ocx.application_number, usage->prsnl[cnt].phyind = pr.physician_ind,
   usage->prsnl[cnt].poscd = pr.position_cd
   IF (ocx.application_number=600005)
    pc_users = (pc_users+ 1)
   ELSEIF (ocx.application_number=950001)
    omf_users = (omf_users+ 1)
   ELSEIF (ocx.application_number=961000
    AND pr.physician_ind=1
    AND  NOT (pr.position_cd IN (925850, 966301, 966300)))
    pco_phy_users = (pco_phy_users+ 1), usage->prsnl[cnt].pcouser = 1
   ENDIF
  FOOT REPORT
   stat = alterlist(usage->prsnl,cnt), usage2->pcousers = pco_phy_users, usage2->pcusers = pc_users,
   usage2->omfusers = omf_users
  WITH nocounter
 ;end select
 CALL echo(build("pc_users:",pc_users))
 CALL echo(build("pco_phy_users:",pco_phy_users))
 CALL echo(build("omf_users:",omf_users))
 SELECT DISTINCT INTO "nl:"
  pid = usage->prsnl[d.seq].personid
  FROM (dummyt d  WITH seq = value(size(usage->prsnl,5)))
  ORDER BY pid, 0
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(userid->qual,cnt), userid->qual[cnt].personid = pid
  WITH nocounter
 ;end select
 SET usage_cnt = size(userid->qual,5)
 CALL echo(build("unique users:",usage_cnt))
 GO TO exit_script
 CALL echo(usage_cnt)
 FOR (x = 1 TO usage_cnt)
   SELECT INTO "nl:"
    FROM order_action oa
    WHERE (oa.action_personnel_id=userid->qual[x].personid)
     AND oa.template_order_flag != 0
    DETAIL
     usage2->userswithord = (usage2->userswithord+ 1)
    WITH nocounter, maxqual(oa,1)
   ;end select
   SELECT INTO "nl:"
    FROM dcp_forms_activity_prsnl dcp
    WHERE (dcp.prsnl_id=userid->qual[x].personid)
    DETAIL
     usage2->userswithdoc = (usage2->userswithdoc+ 1)
    WITH nocounter, maxqual(dcp,1)
   ;end select
   SELECT INTO "nl:"
    FROM scd_story s
    WHERE (s.author_id=userid->qual[x].personid)
    DETAIL
     usage2->userswithpn = (usage2->userswithpn+ 1)
    WITH nocounter, maxqual(s,1)
   ;end select
 ENDFOR
 SELECT INTO "nl:"
  FROM order_radiology ord
  WHERE ord.complete_dt_tm BETWEEN cnvtdatetime(cnvtdate( $SDATE),0) AND cnvtdatetime(cnvtdate(
     $EDATE),235959)
   AND ord.order_physician_id IN (
  (SELECT
   person_id
   FROM prsnl
   WHERE  NOT (position_cd IN (441, 319324234, 686743, 227463062, 227477522,
   227479880, 227470547, 227493216, 227460684, 227463639,
   227467321, 227479357, 227479598, 228839068, 228839745,
   227455501, 227463714, 227464173, 227464799, 227468561,
   227469966, 227470094, 227470716, 227478988, 227479223,
   225116230, 241970625, 283540467))))
  FOOT REPORT
   usage->totalradord = count(ord.order_id)
  WITH nocounter
 ;end select
 SELECT INTO "usage_rpt"
  name = usage->prsnl[d.seq].pname, position = usage->prsnl[d.seq].position, phy_ind = usage->prsnl[d
  .seq].phyind,
  pn_user = usage->prsnl[d.seq].pnuser, pf_user = usage->prsnl[d.seq].pfuser, pco_user = usage->
  prsnl[d.seq].pcouser,
  totalrad = usage->totalradord
  FROM (dummyt d  WITH seq = value(size(usage->prsnl,5)))
  WHERE d.seq > 0
  WITH nocounter, format, separator = " "
 ;end select
 CALL echorecord(usage2)
 CALL echo(build("Rads:",usage->totalradord))
 CALL echo(build("usage->UserswithDoc:",usage->userswithdoc))
 CALL echo(build("usage->UserswithOrd:",usage->userswithord))
 CALL echo(build("usage->UserswithPN:",usage->userswithpn))
#exit_script
END GO
