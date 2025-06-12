CREATE PROGRAM bhs_rw_scd_stats
 PROMPT
  "Enter output destination: " = "MINE",
  "(1) Detail (2) Sums (3) All: " = 0,
  "(1) Non-Cumulative (2) Cumulative (3) All: " = 0,
  "Enter begin date range: " = "",
  "Enter end date range: " = "",
  "Enter PowerNotes to lookup: " = ""
 RECORD work(
   1 o_cnt = i4
   1 output[*]
     2 output_str = vc
     2 email_ind = i2
   1 l_cnt = i4
   1 locations[*]
     2 desc = vc
     2 u_cnt = i4
     2 users[*]
       3 slot = i4
   1 s_cnt = i4
   1 sorted[*]
     2 slot = i4
   1 u_cnt = i4
   1 users[*]
     2 person_id = f8
     2 name = vc
     2 p_cnt = i4
     2 patterns[*]
       3 display = vc
       3 sign_cnt = i4
       3 save_cnt = i4
       3 cum_sign_cnt = i4
       3 cum_save_cnt = i4
   1 pattern_file = vc
   1 p_cnt = i4
   1 patterns[*]
     2 display = vc
     2 display_key = vc
     2 scr_pattern_id = f8
 )
 DECLARE output_dest = vc
 SET output_dest = trim( $1,3)
 IF (trim(output_dest,3) <= " ")
  CALL echo("No output location found. Exiting Script")
  GO TO exit_script
 ELSE
  WHILE (findstring(";",output_dest) > 0)
    SET work->o_cnt = (work->o_cnt+ 1)
    SET stat = alterlist(work->output,work->o_cnt)
    SET work->output[work->o_cnt].output_str = trim(substring(1,(findstring(";",output_dest) - 1),
      output_dest),3)
    SET output_dest = trim(substring((findstring(";",output_dest)+ 1),size(output_dest),output_dest),
     3)
    IF (findstring("@",work->output[work->o_cnt].output_str) > 0)
     SET work->output[work->o_cnt].email_ind = 1
    ENDIF
  ENDWHILE
  IF (trim(output_dest,3) > " ")
   SET work->o_cnt = (work->o_cnt+ 1)
   SET stat = alterlist(work->output,work->o_cnt)
   SET work->output[work->o_cnt].output_str = trim(output_dest,3)
   IF (findstring("@",work->output[work->o_cnt].output_str) > 0)
    SET work->output[work->o_cnt].email_ind = 1
   ENDIF
  ENDIF
  SET output_dest = trim(concat(cnvtlower(curprog),format(sysdate,"MMDDYYYY;;D")),4)
 ENDIF
 DECLARE print_ind = i2
 DECLARE cum_ind = i2
 IF (cnvtint( $2) >= 1
  AND cnvtint( $2) <= 3)
  SET print_ind =  $2
 ELSE
  CALL echo("Invalid print option ($2) selected. Using 3 - All")
  SET print_ind = 3
 ENDIF
 IF (cnvtint( $3) >= 1
  AND cnvtint( $3) <= 3)
  SET cum_ind =  $3
 ELSE
  CALL echo("Invalid print option ($3) selected. Using 3 - All")
  SET cum_ind = 3
 ENDIF
 IF (( $4="999"))
  SET var_beg_dt = datetimefind(cnvtdatetime((curdate - 20),0),"M","B","B")
 ELSE
  IF (isnumeric( $4)=1)
   IF (size(trim(cnvtstring( $4))) < 7)
    SET var_beg_dt = format((curdate - abs(cnvtint( $4))),"DD-MMM-YYYY 00:00:00;;D")
   ELSE
    SET var_beg_dt = format(cnvtdate(cnvtint( $4)),"DD-MMM-YYYY 00:00:00;;D")
   ENDIF
  ELSE
   IF (size(trim( $4,3))=8)
    IF (findstring("/", $4) > 0)
     SET var_beg_dt = format(cnvtdate2(trim( $4,3),"MM/DD/YY"),"DD-MMM-YYYY 00:00:00;;D")
    ELSEIF (findstring("-", $4) > 0)
     SET var_beg_dt = format(cnvtdate2(trim( $4,3),"MM-DD-YY"),"DD-MMM-YYYY 00:00:00;;D")
    ENDIF
   ELSEIF (size(trim( $4,3))=10)
    IF (findstring("/", $4) > 0)
     SET var_beg_dt = format(cnvtdate2(trim( $4,3),"MM/DD/YYYY"),"DD-MMM-YYYY 00:00:00;;D")
    ELSEIF (findstring("-", $4) > 0)
     SET var_beg_dt = format(cnvtdate2(trim( $4,3),"MM-DD-YYYY"),"DD-MMM-YYYY 00:00:00;;D")
    ENDIF
   ELSEIF (size(trim( $4,3))=11)
    SET var_beg_dt = format(cnvtdate2(trim( $4,3),"DD-MMM-YYYY"),"DD-MMM-YYYY 00:00:00;;D")
   ENDIF
  ENDIF
  IF (cnvtdatetime(var_beg_dt) <= 0.00)
   IF (cum_ind IN (1, 3))
    CALL echo("Invalid (or no) begin date ($4) was given. Using default of 30 days back.")
    SET var_beg_dt = format((curdate - 30),"DD-MMM-YYYY 00:00:00;;D")
   ELSE
    CALL echo("No begin date ($4) entered. Cumulative totals only - begin date ignored.")
   ENDIF
  ENDIF
 ENDIF
 IF (( $5="999"))
  SET var_end_dt = datetimefind(cnvtdatetime((curdate - 20),0),"M","E","E")
 ELSE
  IF (isnumeric( $5)=1)
   IF (size(trim(cnvtstring( $5))) < 7)
    SET var_end_dt = format((curdate - abs(cnvtint( $5))),"DD-MMM-YYYY 23:59:59;;D")
   ELSE
    SET var_end_dt = format(cnvtdate(cnvtint( $5)),"DD-MMM-YYYY 23:59:59;;D")
   ENDIF
  ELSE
   IF (size(trim( $5,3))=8)
    IF (findstring("/", $5) > 0)
     SET var_end_dt = format(cnvtdate2(trim( $5,3),"MM/DD/YY"),"DD-MMM-YYYY 23:59:59;;D")
    ELSEIF (findstring("-", $5) > 0)
     SET var_end_dt = format(cnvtdate2(trim( $5,3),"MM-DD-YY"),"DD-MMM-YYYY 23:59:59;;D")
    ENDIF
   ELSEIF (size(trim( $5,3))=10)
    IF (findstring("/", $5) > 0)
     SET var_end_dt = format(cnvtdate2(trim( $5,3),"MM/DD/YYYY"),"DD-MMM-YYYY 23:59:59;;D")
    ELSEIF (findstring("-", $5) > 0)
     SET var_end_dt = format(cnvtdate2(trim( $5,3),"MM-DD-YYYY"),"DD-MMM-YYYY 23:59:59;;D")
    ENDIF
   ELSEIF (size(trim( $5,3))=11)
    SET var_end_dt = format(cnvtdate2(trim( $5,3),"DD-MMM-YYYY"),"DD-MMM-YYYY 23:59:59;;D")
   ENDIF
  ENDIF
  IF (cnvtdatetime(var_end_dt) <= 0.00)
   CALL echo("Invalid (or no) end date ($5) was given. Using default of today.")
   SET var_end_dt = format(curdate,"DD-MMM-YYYY 23:59:59;;D")
  ENDIF
 ENDIF
 DECLARE cs14409_ep_cd = f8
 SET cs14409_ep_cd = uar_get_code_by("MEANING",14409,"EP")
 IF (trim( $6,4) <= " ")
  CALL echo("No Powernote data entered. Using all Encounter Pathways.")
  SELECT INTO "NL:"
   sp.display, sp.display_key, sp.scr_pattern_id
   FROM scr_pattern sp
   PLAN (sp
    WHERE sp.pattern_type_cd=cs14409_ep_cd
     AND sp.active_ind=1)
   DETAIL
    work->p_cnt = (work->p_cnt+ 1), stat = alterlist(work->patterns,work->p_cnt), work->patterns[work
    ->p_cnt].display = sp.display,
    work->patterns[work->p_cnt].display_key = sp.display_key, work->patterns[work->p_cnt].
    scr_pattern_id = sp.scr_pattern_id
   WITH nocounter
  ;end select
 ELSEIF (findfile(value( $6))=1)
  SET work->pattern_file = value( $6)
  DECLARE pattern_file = vc
  SET logical pattern_file value(work->pattern_file)
  FREE DEFINE rtl3
  DEFINE rtl3 "PATTERN_FILE"
  SELECT INTO "NL:"
   sp.display, sp.display_key, sp.scr_pattern_id
   FROM rtl3t r,
    scr_pattern sp
   PLAN (r
    WHERE r.line > " ")
    JOIN (sp
    WHERE r.line=sp.display_key)
   HEAD REPORT
    p_cnt = 0
   DETAIL
    IF (sp.scr_pattern_id > 0.0)
     p_cnt = (p_cnt+ 1), work->p_cnt = p_cnt, stat = alterlist(work->patterns,p_cnt),
     work->patterns[p_cnt].display = sp.display, work->patterns[p_cnt].display_key = sp.display_key,
     work->patterns[p_cnt].scr_pattern_id = sp.scr_pattern_id
    ENDIF
   WITH nocounter
  ;end select
  FREE DEFINE rtl3
  FREE SET pattern_file
 ELSEIF (trim( $6,4) > " ")
  RECORD temp(
    1 cnt = i4
    1 patterns[*]
      2 display_key = vc
  )
  DECLARE pattern_string = vc
  SET pattern_string = trim(value( $6),4)
  WHILE (findstring(";",pattern_string) > 0)
    SET temp->cnt = (temp->cnt+ 1)
    SET stat = alterlist(temp->patterns,temp->cnt)
    SET temp->patterns[temp->cnt].display_key = substring(1,(findstring(";",pattern_string) - 1),
     pattern_string)
    SET pattern_string = substring((findstring(";",pattern_string)+ 1),pattern_string)
  ENDWHILE
  IF (pattern_string > " ")
   SET temp->cnt = (temp->cnt+ 1)
   SET stat = alterlist(temp->patterns,temp->cnt)
   SET temp->patterns[temp->cnt].display_key = pattern_string
  ENDIF
  DECLARE tmp_cnt = i4 WITH noconstant(0)
  SELECT INTO "NL:"
   sp.display, sp.display_key, sp.scr_pattern_id
   FROM scr_pattern sp
   PLAN (sp
    WHERE expand(tmp_cnt,1,temp->cnt,sp.display_key,temp->patterns[tmp_cnt].display_key))
   HEAD REPORT
    p_cnt = 0
   DETAIL
    IF (sp.scr_pattern_id > 0.0)
     p_cnt = (p_cnt+ 1), work->p_cnt = p_cnt, stat = alterlist(work->patterns,p_cnt),
     work->patterns[p_cnt].display = sp.display, work->patterns[p_cnt].display_key = sp.display_key,
     work->patterns[p_cnt].scr_pattern_id = sp.scr_pattern_id
    ENDIF
   WITH nocounter
  ;end select
  FREE SET tmp_cnt
  FREE RECORD temp
 ENDIF
 IF ((work->p_cnt <= 0))
  CALL echo("No Powernotes successfully found. Exiting Script")
  GO TO exit_script
 ENDIF
 DECLARE cs15750_sign_cd = f8
 DECLARE cs15749_doc_cd = f8
 DECLARE cs48_active_cd = f8
 DECLARE cs88_dba_cd = f8
 DECLARE cs88_bhs_dba_cd = f8
 DECLARE cs88_dba_bhs_cd = f8
 DECLARE var_mock_org_id = f8
 DECLARE tmp_cnt1 = i4
 SET cs15750_sign_cd = uar_get_code_by("MEANING",15750,"SIGNED")
 SET cs15749_doc_cd = uar_get_code_by("MEANING",15749,"DOC")
 SET cs48_active_cd = uar_get_code_by("MEANING",48,"ACTIVE")
 SET cs88_dba_cd = uar_get_code_by("DISPLAYKEY",88,"DBA")
 SET cs88_bhs_dba_cd = uar_get_code_by("DISPLAYKEY",88,"BHSDBA")
 SET cs88_dba_bhs_cd = uar_get_code_by("DISPLAYKEY",88,"DBABHS")
 SELECT INTO "NL:"
  FROM organization o
  PLAN (o
   WHERE o.org_name_key="MOCKBAYSTATEHEALTHSYSTEM")
  DETAIL
   var_mock_org_id = o.organization_id
  WITH nocounter
 ;end select
 SET tmp_cnt1 = 0
 SELECT INTO "NL:"
  FROM scd_story ss,
   scd_story_pattern ssp,
   scr_pattern sp,
   prsnl pr
  PLAN (ss
   WHERE ss.story_type_cd=cs15749_doc_cd
    AND ss.active_ind=1
    AND ss.active_status_cd=cs48_active_cd
    AND ss.author_id > 0.00
    AND ((cum_ind IN (2, 3)
    AND ss.active_status_dt_tm <= cnvtdatetime(var_end_dt)) OR (cum_ind=1
    AND ss.active_status_dt_tm BETWEEN cnvtdatetime(var_beg_dt) AND cnvtdatetime(var_end_dt)))
    AND  NOT ( EXISTS (
   (SELECT
    e.encntr_id
    FROM encounter e
    WHERE ss.encounter_id=e.encntr_id
     AND ((e.organization_id+ 0)=var_mock_org_id))))
    AND  NOT ( EXISTS (
   (SELECT
    p.person_id
    FROM person p
    WHERE ss.person_id=p.person_id
     AND cnvtstring(p.name_last_key)="ZZZ*"))))
   JOIN (pr
   WHERE ss.author_id=pr.person_id
    AND  NOT ( EXISTS (
   (SELECT
    pr2.person_id
    FROM prsnl pr2
    WHERE pr.name_last_key=pr2.name_last_key
     AND pr.name_first_key=pr2.name_first_key
     AND pr2.active_status_cd=cs48_active_cd
     AND pr2.position_cd IN (cs88_bhs_dba_cd, cs88_dba_bhs_cd, cs88_dba_cd)))))
   JOIN (ssp
   WHERE ss.scd_story_id=ssp.scd_story_id)
   JOIN (sp
   WHERE ssp.scr_pattern_id=sp.scr_pattern_id
    AND sp.pattern_type_cd=cs14409_ep_cd
    AND expand(tmp_cnt1,1,work->p_cnt,sp.scr_pattern_id,work->patterns[tmp_cnt1].scr_pattern_id))
  ORDER BY pr.name_full_formatted, sp.display
  HEAD REPORT
   u_cnt = 0, p_cnt = 0
  HEAD pr.name_full_formatted
   u_cnt = (work->u_cnt+ 1), stat = alterlist(work->users,u_cnt), work->u_cnt = u_cnt,
   work->users[u_cnt].person_id = pr.person_id, work->users[u_cnt].name = trim(pr.name_full_formatted,
    3), p_cnt = 1,
   work->users[u_cnt].p_cnt = 1, stat = alterlist(work->users[u_cnt].patterns,1), work->users[u_cnt].
   patterns[p_cnt].display = "Total"
  HEAD sp.display
   p_cnt = (work->users[u_cnt].p_cnt+ 1), stat = alterlist(work->users[u_cnt].patterns,p_cnt), work->
   users[u_cnt].p_cnt = p_cnt,
   work->users[u_cnt].patterns[p_cnt].display = trim(sp.display,3)
  DETAIL
   IF (ss.story_completion_status_cd=cs15750_sign_cd)
    work->users[u_cnt].patterns[1].cum_sign_cnt = (work->users[u_cnt].patterns[1].cum_sign_cnt+ 1),
    work->users[u_cnt].patterns[p_cnt].cum_sign_cnt = (work->users[u_cnt].patterns[p_cnt].
    cum_sign_cnt+ 1)
    IF (cum_ind IN (1, 3)
     AND ss.active_status_dt_tm BETWEEN cnvtdatetime(var_beg_dt) AND cnvtdatetime(var_end_dt))
     work->users[u_cnt].patterns[1].sign_cnt = (work->users[u_cnt].patterns[1].sign_cnt+ 1), work->
     users[u_cnt].patterns[p_cnt].sign_cnt = (work->users[u_cnt].patterns[p_cnt].sign_cnt+ 1)
    ENDIF
   ELSE
    work->users[u_cnt].patterns[1].cum_save_cnt = (work->users[u_cnt].patterns[1].cum_save_cnt+ 1),
    work->users[u_cnt].patterns[p_cnt].cum_save_cnt = (work->users[u_cnt].patterns[p_cnt].
    cum_save_cnt+ 1)
    IF (cum_ind IN (1, 3)
     AND ss.active_status_dt_tm BETWEEN cnvtdatetime(var_beg_dt) AND cnvtdatetime(var_end_dt))
     work->users[u_cnt].patterns[1].save_cnt = (work->users[u_cnt].patterns[1].save_cnt+ 1), work->
     users[u_cnt].patterns[p_cnt].save_cnt = (work->users[u_cnt].patterns[p_cnt].save_cnt+ 1)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 FREE SET tmp_cnt1
 IF ((work->u_cnt <= 0))
  SELECT INTO value( $1)
   FROM dummyt d
   DETAIL
    row 20, col 45, "No activity found for selected date range"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 SET work->l_cnt = 1
 SET stat = alterlist(work->locations,1)
 SET work->locations[1].desc = " "
 SET work->locations[1].u_cnt = work->u_cnt
 SET stat = alterlist(work->locations[1].users,work->u_cnt)
 FOR (u = 1 TO work->locations[1].u_cnt)
   SET work->locations[1].users[u].slot = u
 ENDFOR
 SET work->s_cnt = 1
 SET stat = alterlist(work->sorted,1)
 SET work->sorted[1].slot = 1
 IF (findfile("ellyn_users.dat") != 1)
  CALL echo("Could not load 'ellyn_users.dat' - location not attached.")
 ELSE
  FREE DEFINE rtl2
  DEFINE rtl2 "ellyn_users.dat"
  DECLARE tmp_loc = vc
  DECLARE tmp_id = f8
  SELECT INTO "NL:"
   FROM rtl2t r
   HEAD REPORT
    l_cnt = 0, tmp_loc_slot = 0, tmp_id_slot = 0,
    tmp_s = 0
   DETAIL
    tmp_loc = trim(substring((findstring("|",r.line,1,1)+ 1),size(trim(r.line,3)),r.line),3), tmp_id
     = cnvtreal(substring(1,(findstring("|",r.line) - 1),r.line)), tmp_loc_slot = 0,
    tmp_id_slot = 0, tmp_s = 0
    FOR (l = 2 TO work->l_cnt)
      IF ((work->locations[l].desc=tmp_loc))
       tmp_loc_slot = l
      ENDIF
    ENDFOR
    IF (tmp_loc_slot=0)
     l_cnt = (work->l_cnt+ 1), stat = alterlist(work->locations,l_cnt), work->l_cnt = l_cnt,
     work->locations[l_cnt].desc = tmp_loc, tmp_loc_slot = work->l_cnt, work->s_cnt = work->l_cnt,
     stat = alterlist(work->sorted,work->s_cnt), work->sorted[work->s_cnt].slot = tmp_loc_slot, tmp_s
      = work->s_cnt
     WHILE (tmp_s > 2
      AND (work->locations[work->sorted[(tmp_s - 1)].slot].desc > work->locations[work->sorted[tmp_s]
     .slot].desc))
       work->sorted[tmp_s].slot = work->sorted[(tmp_s - 1)].slot, work->sorted[(tmp_s - 1)].slot =
       tmp_loc_slot, tmp_s = (tmp_s - 1)
     ENDWHILE
    ENDIF
    tmp_id_slot = 1
    WHILE ((tmp_id_slot < work->u_cnt)
     AND (work->users[tmp_id_slot].person_id != tmp_id))
      tmp_id_slot = (tmp_id_slot+ 1)
    ENDWHILE
    IF ((work->users[tmp_id_slot].person_id=tmp_id))
     tmp_u = 1
     WHILE ((tmp_u < work->locations[tmp_loc_slot].u_cnt)
      AND (work->locations[tmp_loc_slot].users[tmp_u].slot != tmp_id_slot))
       tmp_u = (tmp_u+ 1)
     ENDWHILE
     IF ((work->locations[tmp_loc_slot].users[tmp_u].slot != tmp_id_slot))
      u_cnt = (work->locations[tmp_loc_slot].u_cnt+ 1), stat = alterlist(work->locations[tmp_loc_slot
       ].users,u_cnt), work->locations[tmp_loc_slot].u_cnt = u_cnt,
      work->locations[tmp_loc_slot].users[u_cnt].slot = tmp_id_slot
     ENDIF
     FOR (x1 = 1 TO work->locations[1].u_cnt)
       IF ((work->locations[1].users[x1].slot=tmp_id_slot))
        FOR (x2 = x1 TO work->locations[1].u_cnt)
          IF ((x2=work->locations[1].u_cnt))
           work->locations[1].users[x2].slot = 0
          ELSE
           work->locations[1].users[x2].slot = work->locations[1].users[(x2+ 1)].slot
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
    ENDIF
   WITH nocounter
  ;end select
  FREE DEFINE rtl2
 ENDIF
 SET tmp_slot = work->locations[1].u_cnt
 WHILE ((work->locations[1].users[tmp_slot].slot=0)
  AND tmp_slot > 0)
   SET tmp_slot = (tmp_slot - 1)
 ENDWHILE
 SET work->locations[1].u_cnt = tmp_slot
 SET stat = alterlist(work->locations[1].users,tmp_slot)
 SELECT INTO value(output_dest)
  FROM dummyt d
  HEAD REPORT
   sorted_slot = 0, user_slot = 0, col 0,
   '"Location",', col + 0,
   CALL print(build2('"User',"'",'s Name",')),
   col + 0, '"PowerNote Pattern",', col + 0,
   '"Signed PowerNotes",', col + 0, '"Saved PowerNotes",'
   IF (cum_ind IN (2, 3))
    col + 0, '"Cumulative Signed PowerNotes",', col + 0,
    '"Cumulative Saved PowerNotes",'
   ENDIF
  DETAIL
   FOR (s = 1 TO work->s_cnt)
    sorted_slot = work->sorted[s].slot,
    FOR (u = 1 TO work->locations[sorted_slot].u_cnt)
      user_slot = work->locations[sorted_slot].users[u].slot
      IF (print_ind IN (1, 3))
       FOR (p = 2 TO work->users[user_slot].p_cnt)
         row + 1, col 0,
         CALL print(build2('"',work->locations[sorted_slot].desc,'",','"',work->users[user_slot].name,
          '",','"',work->users[user_slot].patterns[p].display,'",',cnvtstring(work->users[user_slot].
           patterns[p].sign_cnt),
          ",",cnvtstring(work->users[user_slot].patterns[p].save_cnt),","))
         IF (cum_ind IN (2, 3))
          col + 0,
          CALL print(build2(cnvtstring(work->users[user_slot].patterns[p].cum_sign_cnt),",",
           cnvtstring(work->users[user_slot].patterns[p].cum_save_cnt),","))
         ENDIF
       ENDFOR
      ENDIF
      IF (print_ind IN (2, 3))
       row + 1, col 0,
       CALL print(build2('"',work->locations[sorted_slot].desc,'",','"',work->users[user_slot].name,
        '",','"',work->users[user_slot].patterns[1].display,'",',cnvtstring(work->users[user_slot].
         patterns[1].sign_cnt),
        ",",cnvtstring(work->users[user_slot].patterns[1].save_cnt),","))
       IF (cum_ind IN (2, 3))
        col + 0,
        CALL print(build2(cnvtstring(work->users[user_slot].patterns[1].cum_sign_cnt),",",cnvtstring(
          work->users[user_slot].patterns[1].cum_save_cnt),","))
       ENDIF
      ENDIF
    ENDFOR
   ENDFOR
  WITH nocounter, maxcol = 32000, maxrow = 1,
   formfeed = none, format = variable
 ;end select
#exit_script
 DECLARE report_output = vc
 DECLARE email_attachment = vc
 DECLARE email_address = vc
 DECLARE email_subject = vc
 DECLARE del_output_ind = i2
 DECLARE dcl_command = vc
 DECLARE dcl_com_len = i4
 DECLARE dcl_status = i4
 DECLARE tmp_err = vc
 EXECUTE bhs_ma_email_file
 SET report_output = build(trim(cnvtlower(output_dest),3),".dat")
 SET email_attachment = build(format(curdate,"MMDDYYYY;;D"),".csv")
 SET email_subject = trim(build2(curprog," - Baystate Medical Center PowerNote Usage Report"),3)
 SET del_output_ind = 0
 IF (findfile(report_output)=1)
  FOR (o = 1 TO work->o_cnt)
    IF ((work->output[o].email_ind=0))
     SET dcl_command = build2("lpq -P ",work->output[o].output_str)
     SET dcl_com_len = size(trim(dcl_command,3))
     SET dcl_status = 0
     CALL dcl(dcl_command,dcl_com_len,dcl_status)
     IF (dcl_status=1)
      SET spool value(report_output) value(work->output[o].output_str)
      SET stat = error(tmp_err,0)
      IF (stat != 0)
       CALL echo(build2("Error printing to ",work->output[o].output_str))
      ENDIF
     ELSE
      SET dcl_command = build2("cp -E force ",report_output," ",work->output[o].output_str,".csv")
      SET dcl_com_len = size(trim(dcl_command,3))
      SET dcl_status = 0
      CALL dcl(dcl_command,dcl_com_len,dcl_status)
      IF (dcl_status != 1)
       CALL echo(build2("Error creating file ",work->output[o].output_str,".csv"))
      ENDIF
     ENDIF
    ELSE
     SET email_address = trim(work->output[o].output_str,3)
     CALL emailfile(report_output,email_attachment,email_address,email_subject,del_output_ind)
    ENDIF
  ENDFOR
  SET stat = remove(report_output)
 ENDIF
 FREE SET output_dest
 FREE SET report_output
 FREE SET email_attachment
 FREE SET email_address
 FREE SET email_subject
 FREE SET del_output_ind
 FREE SET dcl_command
 FREE SET dcl_com_len
 FREE SET dcl_status
 FREE SET tmp_err
END GO
