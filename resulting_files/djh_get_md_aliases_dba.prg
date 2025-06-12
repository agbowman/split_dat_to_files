CREATE PROGRAM djh_get_md_aliases:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Physician's Last Name:" = "*",
  "Physician's First Name:" = "*"
  WITH outdev, drlastname, drfirstname
 RECORD md_list(
   1 qual[*]
     2 name = c30
     2 username = c20
     2 phys_flg = i2
     2 position = c40
     2 personid = f8
     2 alias[*]
       3 alias = c30
       3 alias_pool_cd = f8
       3 alias_type = c30
       3 alias_type_cd = f8
       3 alias_type_disp = c30
       3 active = i2
       3 begin_dt = dq8
       3 end_dt = dq8
 )
 SELECT INTO "nl:"
  FROM prsnl pr,
   prsnl_alias pa
  PLAN (pr
   WHERE pr.physician_ind >= 0
    AND pr.active_ind=1
    AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND pr.name_last_key="FRIEDMAN*"
    AND pr.name_first_key="J*")
   JOIN (pa
   WHERE pa.person_id=pr.person_id
    AND pa.active_ind=1)
  ORDER BY pr.name_last_key, pr.name_first_key, pr.person_id,
   pa.alias_pool_cd
  HEAD REPORT
   cnt1 = 0, cnt2 = 0
  HEAD pr.person_id
   cnt1 = (cnt1+ 1)
   IF (mod(cnt1,10)=1)
    stat = alterlist(md_list->qual,(cnt1+ 10))
   ENDIF
   md_list->qual[cnt1].name = pr.name_full_formatted, md_list->qual[cnt1].username = pr.username,
   md_list->qual[cnt1].phys_flg = pr.physician_ind,
   md_list->qual[cnt1].position = uar_get_code_display(pr.position_cd), md_list->qual[cnt1].personid
    = pr.person_id
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
   .end_dt = pa.end_effective_dt_tm
  FOOT  pr.person_id
   stat = alterlist(md_list->qual[cnt1].alias,cnt2), cnt2 = 0
  FOOT REPORT
   stat = alterlist(md_list->qual,cnt1)
  WITH nocounter, time = 60
 ;end select
 SELECT INTO  $1
  FROM (dummyt d  WITH seq = size(md_list->qual,5))
  WHERE d.seq > 0
  HEAD REPORT
   line = fillstring(120,"=")
  HEAD PAGE
   col 5, line, row + 1,
   col 50, "Physician Alias Report", row + 1,
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
   col + 5, "CID", col + 0,
   md_list->qual[d.seq].personid"############", row + 1, col 10,
   "CIS Position = ", col 25, position,
   col + 5, "Phys_flg set - ", col + 1,
   phys_flg, row + 2, col 5,
   "Aliases: ", col 82, "Start DT  End DT",
   row + 1
   FOR (y = 1 TO size(md_list->qual[d.seq].alias,5))
     b_dt = format(md_list->qual[d.seq].alias[y].begin_dt,"mm/dd/yy;;d"), e_dt = format(md_list->
      qual[d.seq].alias[y].end_dt,"mm/dd/yy;;d"), a = trim(md_list->qual[d.seq].alias[y].alias),
     at = trim(md_list->qual[d.seq].alias[y].alias_type), xat = md_list->qual[d.seq].alias[y].
     alias_pool_cd, xatcd = md_list->qual[d.seq].alias[y].alias_type_cd,
     xatdisp = md_list->qual[d.seq].alias[y].alias_type_disp, active = md_list->qual[d.seq].alias[y].
     active, col 10,
     xatdisp, " :", col 43,
     a, col 65, " Active: ",
     active"#;l", " ", "Date: ",
     b_dt, " ", e_dt,
     row + 1
   ENDFOR
   IF (row > 52)
    BREAK
   ENDIF
  FOOT PAGE
   row + 1, col 5, line,
   row + 1, col 5, curprog,
   col 25, curnode, col 40
   CASE (curnode)
    OF "cis1":
     "PROD"
    OF "cis3":
     "PROD"
    OF "cis5":
     "PROD"
    OF "cisr":
     "READonly"
    OF "casDtest":
     "BUILD"
    OF "casbtest":
     "CERT"
    OF "cismock1":
     "MOCK"
    OF "cismock2":
     "CISNEW"
    OF "cismock3":
     "CISNEW"
    ELSE
     "domain?"
   ENDCASE
   col 90, "Page:", curpage
  WITH maxrec = 10, maxrow = 66
 ;end select
END GO
