CREATE PROGRAM djh_phys_detail_rpt_v5:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Physician's Last Name:" = "*",
  "Physician's First Name:" = "*"
  WITH outdev, drlastname, drfirstname
 EXECUTE bhs_check_domain:dba
 DECLARE ms_domain = vc WITH protect, noconstant("")
 RECORD md_list(
   1 qual[*]
     2 name = c30
     2 username = c20
     2 phys_flg = i2
     2 position = c40
     2 personid = f8
     2 createdt = dq8
     2 createid = f8
     2 update_dt = dq8
     2 updateid = f8
     2 alias[*]
       3 alias = c30
       3 alias_pool_cd = f8
       3 alias_type = c30
       3 alias_type_cd = f8
       3 alias_type_disp = c30
       3 active = i2
       3 begin_dt = dq8
       3 update_dt = dq8
       3 end_dt = dq8
       3 updt_id = f8
     2 phone[*]
       3 phone_num = c12
       3 p_phone_type_disp = c20
       3 phone_type_cd = f8
       3 phone_type_seq = i4
       3 active = i2
       3 begin_dt = dq8
       3 update_dt = dq8
       3 end_dt = dq8
     2 address[*]
       3 address_type_cd = f8
       3 address_type_disp = c15
       3 address_type_seq = i4
       3 city = c40
       3 country_cd = f8
       3 state = c4
       3 street1 = c40
       3 street2 = c40
       3 street3 = c40
       3 street4 = c40
       3 zipcode = c12
       3 active = i2
       3 parent_entity_name = c32
       3 addr_updt = dq8
     2 user_group[*]
       3 prsnl_group_id = f8
       3 prsnl_group_desc = c50
       3 prsnl_group_name = f8
 )
 SELECT INTO "nl:"
  FROM prsnl pr,
   prsnl_alias pa
  PLAN (pr
   WHERE pr.physician_ind >= 0
    AND pr.active_ind >= 0
    AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND (pr.name_last_key= $DRLASTNAME)
    AND (pr.name_first_key= $DRFIRSTNAME))
   JOIN (pa
   WHERE pa.person_id=pr.person_id
    AND pa.active_ind >= 0)
  ORDER BY pr.name_last_key, pr.name_first_key, pr.person_id,
   pa.active_ind DESC, pa.alias_pool_cd
  HEAD REPORT
   cnt1 = 0, cnt2 = 0, cnt3 = 0,
   cnt4 = 0, cnt5 = 0
  HEAD pr.person_id
   cnt1 = (cnt1+ 1)
   IF (mod(cnt1,10)=1)
    stat = alterlist(md_list->qual,(cnt1+ 10))
   ENDIF
   md_list->qual[cnt1].name = pr.name_full_formatted, md_list->qual[cnt1].username = pr.username,
   md_list->qual[cnt1].phys_flg = pr.physician_ind,
   md_list->qual[cnt1].position = uar_get_code_display(pr.position_cd), md_list->qual[cnt1].personid
    = pr.person_id, md_list->qual[cnt1].createdt = pr.create_dt_tm,
   md_list->qual[cnt1].createid = pr.create_prsnl_id, md_list->qual[cnt1].update_dt = pr.updt_dt_tm,
   md_list->qual[cnt1].updateid = pr.updt_id
  DETAIL
   cnt2 = (cnt2+ 1)
   IF (mod(cnt2,10)=1)
    stat = alterlist(md_list->qual[cnt1].alias,(cnt2+ 10))
   ENDIF
   md_list->qual[cnt1].alias[cnt2].alias = pa.alias, md_list->qual[cnt1].alias[cnt2].alias_pool_cd =
   pa.alias_pool_cd, md_list->qual[cnt1].alias[cnt2].alias_type = uar_get_code_display(pa
    .alias_pool_cd),
   md_list->qual[cnt1].alias[cnt2].alias_type_cd = pa.prsnl_alias_type_cd, md_list->qual[cnt1].alias[
   cnt2].alias_type_disp = uar_get_code_display(pa.prsnl_alias_type_cd), md_list->qual[cnt1].alias[
   cnt2].active = pa.active_ind,
   md_list->qual[cnt1].alias[cnt2].begin_dt = pa.beg_effective_dt_tm, md_list->qual[cnt1].alias[cnt2]
   .end_dt = pa.end_effective_dt_tm, md_list->qual[cnt1].alias[cnt2].update_dt = pa.updt_dt_tm,
   md_list->qual[cnt1].alias[cnt2].updt_id = pa.updt_id
  FOOT  pr.person_id
   stat = alterlist(md_list->qual[cnt1].alias,cnt2), cnt2 = 0
  FOOT REPORT
   stat = alterlist(md_list->qual,cnt1)
  WITH nocounter, time = 60
 ;end select
 SELECT INTO "nl:"
  FROM phone ph,
   (dummyt d  WITH seq = value(size(md_list->qual,5)))
  PLAN (d)
   JOIN (ph
   WHERE (ph.parent_entity_id=md_list->qual[d.seq].personid))
  HEAD REPORT
   cnt3 = 0
  DETAIL
   cnt3 = (cnt3+ 1), stat = alterlist(md_list->qual[d.seq].phone,cnt3), md_list->qual[d.seq].phone[
   cnt3].phone_num = ph.phone_num,
   md_list->qual[d.seq].phone[cnt3].p_phone_type_disp = uar_get_code_display(ph.phone_type_cd),
   md_list->qual[d.seq].phone[cnt3].phone_type_cd = ph.phone_type_cd, md_list->qual[d.seq].phone[cnt3
   ].phone_type_seq = ph.phone_type_seq,
   md_list->qual[d.seq].phone[cnt3].active = ph.active_ind, md_list->qual[d.seq].phone[cnt3].begin_dt
    = ph.beg_effective_dt_tm, md_list->qual[d.seq].phone[cnt3].end_dt = ph.end_effective_dt_tm,
   md_list->qual[d.seq].phone[cnt3].update_dt = ph.updt_dt_tm
  WITH nocounter
 ;end select
 CALL echorecord(md_list)
 SELECT INTO "nl:"
  FROM address a,
   (dummyt d  WITH seq = value(size(md_list->qual,5)))
  PLAN (d)
   JOIN (a
   WHERE (a.parent_entity_id=md_list->qual[d.seq].personid))
  HEAD REPORT
   cnt4 = 0
  DETAIL
   cnt4 = (cnt4+ 1), stat = alterlist(md_list->qual[d.seq].address,cnt4), md_list->qual[d.seq].
   address[cnt4].address_type_disp = uar_get_code_display(a.address_type_cd),
   md_list->qual[d.seq].address[cnt4].street1 = a.street_addr, md_list->qual[d.seq].address[cnt4].
   street2 = a.street_addr2, md_list->qual[d.seq].address[cnt4].street3 = a.street_addr3,
   md_list->qual[d.seq].address[cnt4].street4 = a.street_addr4, md_list->qual[d.seq].address[cnt4].
   city = a.city, md_list->qual[d.seq].address[cnt4].state = a.state,
   md_list->qual[d.seq].address[cnt4].zipcode = a.zipcode, md_list->qual[d.seq].address[cnt4].active
    = a.active_ind, md_list->qual[d.seq].address[cnt4].parent_entity_name = a.parent_entity_name,
   md_list->qual[d.seq].address[cnt4].addr_updt = a.updt_dt_tm
  WITH nocounter
 ;end select
 CALL echorecord(md_list)
 SELECT INTO "nl:"
  FROM prsnl_group_reltn pgr,
   prsnl_group pg,
   (dummyt d  WITH seq = value(size(md_list->qual,5)))
  PLAN (d)
   JOIN (pgr
   WHERE (pgr.person_id=md_list->qual[d.seq].personid))
   JOIN (pg
   WHERE pgr.prsnl_group_id=pg.prsnl_group_id)
  HEAD REPORT
   cnt5 = 0
  DETAIL
   cnt5 = (cnt5+ 1), stat = alterlist(md_list->qual[d.seq].user_group,cnt5), md_list->qual[d.seq].
   user_group[cnt5].prsnl_group_id = pgr.prsnl_group_id,
   md_list->qual[d.seq].user_group[cnt5].prsnl_group_desc = pg.prsnl_group_desc
  WITH nocounter
 ;end select
 CALL echorecord(md_list)
 SELECT INTO  $1
  FROM (dummyt d  WITH seq = size(md_list->qual,5))
  WHERE d.seq > 0
  HEAD REPORT
   line = fillstring(120,"="), name = fillstring(30," "), username = fillstring(20," "),
   position = fillstring(40," "), phys_flg = fillstring(3," "), xcreatedt = format(md_list->qual[d
    .seq].createdt,"mm/dd/yy;;d"),
   xupdate_dt = format(md_list->qual[d.seq].update_dt,"mm/dd/yy HH:MM;;d")
  HEAD PAGE
   col 5, line, row + 1,
   col 50, "Physician Detail Report", row + 1,
   col 5, line, row + 1
  DETAIL
   name = trim(md_list->qual[d.seq].name)
   IF (trim(md_list->qual[d.seq].username) > "")
    username = trim(md_list->qual[d.seq].username)
   ELSE
    username = "Not Assigned"
   ENDIF
   IF (trim(md_list->qual[d.seq].position) > "")
    position = trim(md_list->qual[d.seq].position)
   ELSE
    position = "Not Assigned"
   ENDIF
   IF ((md_list->qual[d.seq].phys_flg=1))
    phys_flg = "YES"
   ELSE
    phys_flg = "NO"
   ENDIF
   row + 1, x = d.seq, display_line = build(name,"  -",username," CIS position =",position),
   col 10, name, col + 5,
   "Log-In ID -", col + 1, username,
   col + 5, "CID:", col + 1,
   md_list->qual[d.seq].personid"############", row + 1, col 10,
   "CIS Position = ", col 25, position,
   col + 5, "Phys_flg set - ", col + 1,
   phys_flg, row + 1, col 10,
   "Created: ", xcreatedt, col + 3,
   "Create ID: ", md_list->qual[d.seq].createid"###########", col + 3,
   "Updated: ", xupdate_dt, col + 3,
   "Update ID: ", md_list->qual[d.seq].updateid"###########", row + 2,
   col 5, "Aliases: --------------------------------------------", col 70,
   "Start DT   Chg DT    End DT", row + 1
   FOR (y = 1 TO size(md_list->qual[d.seq].alias,5))
     b_dt = format(md_list->qual[d.seq].alias[y].begin_dt,"mm/dd/yy;;d"), e_dt = format(md_list->
      qual[d.seq].alias[y].end_dt,"mm/dd/yy;;d"), a = trim(md_list->qual[d.seq].alias[y].alias),
     at = trim(md_list->qual[d.seq].alias[y].alias_type), xat = md_list->qual[d.seq].alias[y].
     alias_pool_cd, xatcd = md_list->qual[d.seq].alias[y].alias_type_cd,
     xatdisp = md_list->qual[d.seq].alias[y].alias_type_disp, active = md_list->qual[d.seq].alias[y].
     active, actalias =
     IF ((md_list->qual[d.seq].alias[y].active=0)) "*OLD*"
     ELSE ""
     ENDIF
     ,
     col 4, actalias, col 10,
     xatdisp, " :", col 43,
     a, col 65, actalias,
     b_dt, "  ", u_dt,
     "  ", e_dt, actalias,
     row + 1
   ENDFOR
   row + 2, col 5, "Phone Numbers: ------------------------------    Start DT  Chg DT   End DT",
   row + 1
   IF (size(md_list->qual[d.seq].phone,5) > 0)
    FOR (y = 1 TO size(md_list->qual[d.seq].phone,5))
      actphone =
      IF ((md_list->qual[d.seq].phone[y].active=0)) "*OLD*"
      ELSE ""
      ENDIF
      , col 4, actphone,
      col 10, md_list->qual[d.seq].phone[y].p_phone_type_disp, actphone,
      md_list->qual[d.seq].phone[y].phone_num"(###)###-####", actphone, col + 1,
      md_list->qual[d.seq].phone[y].begin_dt"mm/dd/yy;;d", col + 1, md_list->qual[d.seq].phone[y].
      update_dt"mm/dd/yy;;d",
      col + 1, md_list->qual[d.seq].phone[y].end_dt"mm/dd/yy;;d", actphone,
      col + 1, md_list->qual[d.seq].phone[y].phone_type_cd, row + 1
    ENDFOR
   ELSE
    col 10, "No Phone Numbers Entered", row + 1
   ENDIF
   row + 2, col 5, "Address: --------------------------------------------",
   row + 1
   IF (size(md_list->qual[d.seq].address,5) > 0)
    FOR (y = 1 TO size(md_list->qual[d.seq].address,5))
      xaddrupdt = format(md_list->qual[d.seq].address[y].addr_updt,"mm/dd/yy;;d"), actaddr =
      IF ((md_list->qual[d.seq].address[y].active=0)) "*OLD*"
      ELSE ""
      ENDIF
      , col 4,
      actaddr, col 10, md_list->qual[d.seq].address[y].address_type_disp,
      col 26, md_list->qual[d.seq].address[y].parent_entity_name, col 60,
      "Updated: ", xaddrupdt, actaddr,
      row + 1, col 30, md_list->qual[d.seq].address[y].street1,
      row + 1
      IF ((md_list->qual[d.seq].address[y].street2 > " "))
       col 4, actaddr, col 30,
       md_list->qual[d.seq].address[y].street2, row + 1
      ENDIF
      IF ((md_list->qual[d.seq].address[y].street3 > " "))
       col 30, md_list->qual[d.seq].address[y].street3, row + 1
      ENDIF
      IF ((md_list->qual[d.seq].address[y].street4 > " "))
       col 30, md_list->qual[d.seq].address[y].street4, row + 1
      ENDIF
      col 30, md_list->qual[d.seq].address[y].city, md_list->qual[d.seq].address[y].state,
      md_list->qual[d.seq].address[y].zipcode, row + 2
    ENDFOR
   ELSE
    col 10, "No Address Entered", row + 1
   ENDIF
   IF (row > 52)
    BREAK
   ENDIF
   row + 2, col 5, "User Groups: --------------------------------------------",
   row + 1
   IF (size(md_list->qual[d.seq].user_group,5) > 0)
    FOR (y = 1 TO size(md_list->qual[d.seq].user_group,5))
      col 10, md_list->qual[d.seq].user_group[y].prsnl_group_id"########", col 25,
      md_list->qual[d.seq].user_group[y].prsnl_group_desc
    ENDFOR
   ELSE
    col 10, "No User Groups Assigned", row + 1
   ENDIF
  FOOT PAGE
   row + 1, col 5, line,
   row + 1, col 5, curprog,
   col 30, curnode
   IF (gl_bhs_prod_flag=1)
    ms_domain = "PROD"
   ELSEIF (curnode="casdtest")
    ms_domain = "BUILD"
   ELSEIF (curnode="casbtest")
    ms_domain = "CERT"
   ELSEIF (curnode="casetest")
    ms_domain = "TEST"
   ELSE
    ms_domain = "domain?"
   ENDIF
   col 40, ms_domain, col 90,
   "Page:", curpage
  WITH maxrec = 10, maxrow = 66
 ;end select
END GO
