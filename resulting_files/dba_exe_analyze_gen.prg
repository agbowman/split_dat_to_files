CREATE PROGRAM dba_exe_analyze_gen
 PAINT
#initialize
 SET answer = "Y"
 SET custom = "Y"
 SET env_id = 0
 SET db_name = fillstring(30," ")
 SET db_sid = fillstring(30," ")
 SET db_link = fillstring(30," ")
 SET inst_id = 0
 SET queue_name = fillstring(30," ")
 SET cnt = 0
 SET parm_cnt = 0
 SET parm_cnt_save = 0
 SET notes = fillstring(100," ")
 SET requestor = fillstring(30," ")
 SET output_name = fillstring(20," ")
 SET connection = fillstring(30," ")
 FREE SET parm_vals
 RECORD parm_vals(
   1 qual[11]
     2 parm_cd = i4
     2 parm_value = c40
 )
#main
 CALL clear(1,1)
 SET width = 80
 CALL box(1,1,22,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,18,"***   DBA Analyze Database Generator   ***")
 CALL clear(3,2,78)
 CALL text(05,05,"PLEASE ENTER ENVIRONMENT_ID <HELP>:")
 CALL text(07,05,"DATABASE NAME:")
 CALL text(09,05,"DATABASE SID:")
 CALL text(11,05,"DATABASE LINK NAME:")
 CALL text(13,05,"CUSTOM PARMETERS (Y/N):")
 CALL text(15,05,"  Custom Parameters allow you to choose which users, tablespaces, and")
 CALL text(16,05,"  objects to ANALYZE.")
 CALL text(18,05,"  The standard Analyze Schema will be ran for the all tablespaces and")
 CALL text(19,05,"  all objects owned by V500 and V500_REF, with ANALYZE of 5% for tables")
 CALL text(20,05,"  only (indexes done implicitly).")
 SET help =
 SELECT INTO "nl:"
  ref.environment_id, db_name = substring(1,15,ref.db_name)
  FROM ref_instance_id ref
  ORDER BY db_name
  WITH nocounter
 ;end select
 CALL accept(5,40,"99999999.99;F",env_id)
 SET env_id = curaccept
 SET help = off
 SELECT INTO "nl:"
  ref.instance_cd, ref.db_name, ref.node_address,
  ref.instance_name
  FROM ref_instance_id ref
  WHERE ref.environment_id=env_id
  DETAIL
   inst_id = ref.instance_cd, db_name = ref.db_name, db_link = ref.node_address,
   db_sid = ref.instance_name
  WITH nocounter
 ;end select
 CALL text(7,40,db_name)
 CALL text(9,40,db_sid)
 CALL text(11,40,db_link)
 CALL accept(13,40,"A;CU","N"
  WHERE curaccept IN ("Y", "N"))
 SET custom = curaccept
#decision
 CALL text(23,30,"Correct (Y/N)? or X=Exit:")
 CALL accept(23,70,"A;CU","Y"
  WHERE curaccept IN ("Y", "N", "X"))
 SET answer = curaccept
 IF (answer="N")
  GO TO main
 ELSEIF (answer="Y"
  AND custom="Y")
  GO TO custom_menu
 ELSEIF (answer="Y"
  AND custom="N")
  EXECUTE FROM full TO full_end
  GO TO body
 ELSEIF (answer="X")
  GO TO end_99
 ELSE
  GO TO decision
 ENDIF
#full
 SET parm_vals->qual[1].parm_cd = 1
 SET parm_vals->qual[1].parm_value = concat("'",trim(cnvtstring(inst_id)),"'")
 SET parm_vals->qual[2].parm_cd = 2
 SET parm_vals->qual[2].parm_value = "'V500%'"
 SET parm_vals->qual[3].parm_cd = 3
 SET parm_vals->qual[3].parm_value = "'%'"
 SET parm_vals->qual[4].parm_cd = 4
 SET parm_vals->qual[4].parm_value = "'%'"
 SET parm_vals->qual[5].parm_cd = 5
 SET parm_vals->qual[5].parm_value = "'E'"
 SET parm_vals->qual[6].parm_cd = 6
 SET parm_vals->qual[6].parm_value = "'P'"
 SET parm_vals->qual[7].parm_cd = 7
 SET parm_vals->qual[7].parm_value = "'5'"
 SET parm_vals->qual[8].parm_cd = 8
 SET parm_vals->qual[8].parm_value = "'E'"
 SET parm_vals->qual[9].parm_cd = 9
 SET parm_vals->qual[9].parm_value = "'P'"
 SET parm_vals->qual[10].parm_cd = 10
 SET parm_vals->qual[10].parm_value = "'5'"
 SET parm_vals->qual[11].parm_cd = 11
 SET parm_vals->qual[11].parm_value = "'8192'"
 SET parm_cnt = 11
#full_end
#custom_menu
 EXECUTE FROM environment TO environment_end
 EXECUTE FROM owner TO owner_end
 EXECUTE FROM tablespace TO tablespace_end
 EXECUTE FROM object TO object_end
 EXECUTE FROM details TO details_end
 GO TO body
#custom_menu_end
#environment
 SET parm_cnt = 1
 SET parm_vals->qual[1].parm_cd = 1
 SET parm_vals->qual[1].parm_value = concat("'",trim(cnvtstring(inst_id)),"'")
#environment_end
#owner
 CALL clear(1,1)
 CALL box(1,1,22,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,18,"***   DBA Analyze Database Generator   ***")
 CALL clear(3,2,78)
 CALL text(05,03,"OWNERS:")
 CALL text(06,03,"Which database owners do you wish to limit the ANALYZE on?")
 CALL text(07,03,"Up to five selections with one selection per line, see examples.")
 CALL text(08,03,"Return on a blank row to end selection and continue or select ")
 CALL text(09,03,"five owners.")
 CALL text(10,35,"Examples:")
 CALL text(11,35,"  All owners           -- %")
 CALL text(13,35,"  One owner            -- V500")
 CALL text(15,35,"  Use of wildcards     -- V%")
 CALL text(17,35,"  Multiple owners with -- V500")
 CALL text(18,35,"  wildcards            -- V500_REF%")
 CALL text(20,03,"NOTE:  Objects owned by SYS or SYSTEM will not be ANALYZED")
 CALL text(21,03,"       even if all owners are selected.")
 SET cnt = 1
 SET parm_cnt = 2
 WHILE (cnt < 6)
   CALL accept((cnt+ 10),3,"p(30);CU"," ")
   IF (curaccept=" "
    AND cnt=1)
    GO TO owner
   ENDIF
   IF (curaccept > " ")
    SET parm_vals->qual[parm_cnt].parm_cd = 2
    SET parm_vals->qual[parm_cnt].parm_value = concat("'",trim(curaccept),"'")
    SET cnt = (cnt+ 1)
    SET parm_cnt = (parm_cnt+ 1)
   ELSE
    SET cnt = 999
   ENDIF
 ENDWHILE
 CALL text(23,30,"Correct (Y/N)? or X=Exit:")
 CALL accept(23,70,"A;CU","Y"
  WHERE curaccept IN ("Y", "N", "X"))
 SET answer = curaccept
 IF (answer="N")
  GO TO owner
 ELSEIF (answer="X")
  GO TO end_99
 ENDIF
 SET parm_cnt_save = parm_cnt
#owner_end
#tablespace
 SET parm_cnt = parm_cnt_save
 CALL clear(1,1)
 CALL box(1,1,22,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,18,"***   DBA Analyze Database Generator   ***")
 CALL clear(3,2,78)
 CALL text(05,03,"TABLESPACES:")
 CALL text(06,03,"Which tablespaces do you wish to limit the ANALYZE on?")
 CALL text(07,03,"Up to ten selections with one selection per line, see examples.")
 CALL text(08,03,"Return on a blank row to end selection and continue or select")
 CALL text(09,03,"ten tablespaces.")
 CALL text(10,35,"Examples:")
 CALL text(11,35,"  All tablespaces      -- %")
 CALL text(13,35,"  One tablespace       -- D_PERSON")
 CALL text(15,35,"  Use of wildcards     -- D_%")
 CALL text(17,35,"  Multiple tablespaces -- D_%")
 CALL text(18,35,"  wildcards with       -- %PERSON%")
 CALL text(19,35,"                       -- I_CLINICAL_EVENT")
 SET cnt = 1
 WHILE (cnt < 11)
   IF (parm_cnt > size(parm_vals->qual,5))
    SET stat = alter(parm_vals->qual,(parm_cnt+ 10))
   ENDIF
   CALL accept((cnt+ 10),3,"p(30);CU"," ")
   IF (curaccept=" "
    AND cnt=1)
    GO TO tablespace
   ENDIF
   IF (curaccept > " ")
    SET parm_vals->qual[parm_cnt].parm_cd = 3
    SET parm_vals->qual[parm_cnt].parm_value = concat("'",trim(curaccept),"'")
    SET cnt = (cnt+ 1)
    SET parm_cnt = (parm_cnt+ 1)
   ELSE
    SET cnt = 999
   ENDIF
 ENDWHILE
 CALL text(23,30,"Correct (Y/N)? or X=Exit:")
 CALL accept(23,70,"A;CU","Y"
  WHERE curaccept IN ("Y", "N", "X"))
 SET answer = curaccept
 IF (answer="N")
  GO TO tablespace
 ELSEIF (answer="X")
  GO TO end_99
 ENDIF
 SET parm_cnt_save = parm_cnt
#tablespace_end
#object
 SET parm_cnt = parm_cnt_save
 CALL clear(1,1)
 CALL box(1,1,22,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,18,"***   DBA Analyze Database Generator   ***")
 CALL clear(3,2,78)
 CALL text(05,03,"OBJECTS:")
 CALL text(06,03,"Which objects do you wish to limit the ANALYZE on?")
 CALL text(07,03,"Up to ten selections with one selection per line, see examples.")
 CALL text(08,03,"Return on a blank row to end selection and continue or select")
 CALL text(09,03,"ten objects.")
 CALL text(10,35,"Examples:")
 CALL text(11,35,"  All objects           -- %")
 CALL text(13,35,"  One object            -- ENCNTR_ALIAS")
 CALL text(15,35,"  Use of wildcards      -- ENCNTR%")
 CALL text(17,35,"  Multiple objects with -- PERSON")
 CALL text(18,35,"  wildcards             -- %ENCNTR%")
 SET cnt = 1
 WHILE (cnt < 11)
   IF (parm_cnt > size(parm_vals->qual,5))
    SET stat = alter(parm_vals->qual,(parm_cnt+ 10))
   ENDIF
   CALL accept((cnt+ 10),3,"p(30);CU"," ")
   IF (curaccept=" "
    AND cnt=1)
    GO TO object
   ENDIF
   IF (curaccept > " ")
    SET parm_vals->qual[parm_cnt].parm_cd = 4
    SET parm_vals->qual[parm_cnt].parm_value = concat("'",trim(curaccept),"'")
    SET cnt = (cnt+ 1)
    SET parm_cnt = (parm_cnt+ 1)
   ELSE
    SET cnt = 999
   ENDIF
 ENDWHILE
 CALL text(23,30,"Correct (Y/N)? or X=Exit:")
 CALL accept(23,70,"A;CU","Y"
  WHERE curaccept IN ("Y", "N", "X"))
 SET answer = curaccept
 IF (answer="N")
  GO TO object
 ELSEIF (answer="X")
  GO TO end_99
 ENDIF
 SET parm_cnt_save = parm_cnt
#object_end
#details
 SET parm_cnt = parm_cnt_save
 CALL clear(1,1)
 CALL box(1,1,22,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,18,"***   DBA Analyze Database Generator   ***")
 CALL clear(3,2,78)
 CALL text(05,03,"DETAILS:   (Help is Available)")
 CALL text(07,03,"TABLE ANALYZE METHOD:")
 CALL text(08,03,"     e(X)act or (E)stimate")
 CALL text(10,03,"TABLE ANALYZE TYPE:")
 CALL text(11,03,"     (R)ows, (P)ercent")
 CALL text(13,03,"TABLE ESTIMATE NUMBER:")
 CALL text(14,03,"     # of rows or percentage")
 CALL text(07,40,"INDEX ANALYZE METHOD:")
 CALL text(08,40,"     e(X)act or (E)stimate")
 CALL text(10,40,"INDEX ANALYZE TYPE:")
 CALL text(11,40,"     (R)ows, (P)ercent")
 CALL text(13,40,"INDEX ESTIMATE NUMBER:")
 CALL text(14,40,"     # of rows or percentage")
 CALL text(16,03,"NOTE:  Objects owned by SYS or SYSTEM will not be ANALYZED. ")
 CALL text(17,03,"       If the analyze is successful for tables, then the Oracle statistics")
 CALL text(18,03,"       for the corresponding indexes are already updated by the table")
 CALL text(19,03,"       analyze.  Indexes will only be analyzed if (a) the analyze on the ")
 CALL text(20,03,"       table fails for whatever reason or (b) the analyze method and")
 CALL text(21,03,"       estimate numbers are different for table and indexes.")
 SET cnt = 1
 SET help = fix('E   "Estimate",X   "Exact"')
 CALL accept(07,30,"P;CU","E"
  WHERE curaccept IN ("E", "X"))
 IF (parm_cnt > size(parm_vals->qual,5))
  SET stat = alter(parm_vals->qual,(parm_cnt+ 1))
 ENDIF
 SET parm_vals->qual[parm_cnt].parm_cd = 5
 SET parm_vals->qual[parm_cnt].parm_value = concat("'",curaccept,"'")
 SET parm_cnt = (parm_cnt+ 1)
 SET help = off
 IF ((parm_vals->qual[(parm_cnt - 1)].parm_value="'E'"))
  SET help = fix('P   "Percent",R   "Rows"')
  CALL accept(10,30,"P;CU","P"
   WHERE curaccept IN ("P", "R"))
  IF (parm_cnt > size(parm_vals->qual,5))
   SET stat = alter(parm_vals->qual,(parm_cnt+ 1))
  ENDIF
  SET parm_vals->qual[parm_cnt].parm_cd = 6
  SET parm_vals->qual[parm_cnt].parm_value = concat("'",curaccept,"'")
  SET parm_cnt = (parm_cnt+ 1)
  SET help = off
  CALL accept(13,30,"n(10)",5)
  IF (parm_cnt > size(parm_vals->qual,5))
   SET stat = alter(parm_vals->qual,(parm_cnt+ 1))
  ENDIF
  SET parm_vals->qual[parm_cnt].parm_cd = 7
  SET parm_vals->qual[parm_cnt].parm_value = concat("'",trim(cnvtstring(curaccept)),"'")
  SET parm_cnt = (parm_cnt+ 1)
 ELSE
  IF (parm_cnt > size(parm_vals->qual,5))
   SET stat = alter(parm_vals->qual,(parm_cnt+ 1))
  ENDIF
  SET parm_vals->qual[parm_cnt].parm_cd = 6
  SET parm_vals->qual[parm_cnt].parm_value = "''"
  SET parm_cnt = (parm_cnt+ 1)
  IF (parm_cnt > size(parm_vals->qual,5))
   SET stat = alter(parm_vals->qual,(parm_cnt+ 1))
  ENDIF
  SET parm_vals->qual[parm_cnt].parm_cd = 7
  SET parm_vals->qual[parm_cnt].parm_value = "''"
  SET parm_cnt = (parm_cnt+ 1)
 ENDIF
 SET help = fix('E   "Estimate",X   "Exact"')
 CALL accept(07,68,"P;CU","E"
  WHERE curaccept IN ("E", "X"))
 IF (parm_cnt > size(parm_vals->qual,5))
  SET stat = alter(parm_vals->qual,(parm_cnt+ 1))
 ENDIF
 SET parm_vals->qual[parm_cnt].parm_cd = 8
 SET parm_vals->qual[parm_cnt].parm_value = concat("'",curaccept,"'")
 SET parm_cnt = (parm_cnt+ 1)
 SET help = off
 IF ((parm_vals->qual[(parm_cnt - 1)].parm_value="'E'"))
  SET help = fix('P   "PERCENT",R   "Rows"')
  CALL accept(10,68,"P;CU","P"
   WHERE curaccept IN ("P", "R"))
  IF (parm_cnt > size(parm_vals->qual,5))
   SET stat = alter(parm_vals->qual,(parm_cnt+ 1))
  ENDIF
  SET parm_vals->qual[parm_cnt].parm_cd = 9
  SET parm_vals->qual[parm_cnt].parm_value = concat("'",curaccept,"'")
  SET parm_cnt = (parm_cnt+ 1)
  SET help = off
  CALL accept(13,68,"n(10)",5)
  IF (parm_cnt > size(parm_vals->qual,5))
   SET stat = alter(parm_vals->qual,(parm_cnt+ 1))
  ENDIF
  SET parm_vals->qual[parm_cnt].parm_cd = 10
  SET parm_vals->qual[parm_cnt].parm_value = concat("'",trim(cnvtstring(curaccept)),"'")
  SET parm_cnt = (parm_cnt+ 1)
 ELSE
  IF (parm_cnt > size(parm_vals->qual,5))
   SET stat = alter(parm_vals->qual,(parm_cnt+ 1))
  ENDIF
  SET parm_vals->qual[parm_cnt].parm_cd = 9
  SET parm_vals->qual[parm_cnt].parm_value = "''"
  SET parm_cnt = (parm_cnt+ 1)
  IF (parm_cnt > size(parm_vals->qual,5))
   SET stat = alter(parm_vals->qual,(parm_cnt+ 1))
  ENDIF
  SET parm_vals->qual[parm_cnt].parm_cd = 10
  SET parm_vals->qual[parm_cnt].parm_value = "''"
  SET parm_cnt = (parm_cnt+ 1)
 ENDIF
 IF (parm_cnt > size(parm_vals->qual,5))
  SET stat = alter(parm_vals->qual,(parm_cnt+ 1))
 ENDIF
 SET parm_vals->qual[parm_cnt].parm_cd = 11
 SET parm_vals->qual[parm_cnt].parm_value = "'8192'"
 CALL text(23,30,"Correct (Y/N)? or X=Exit:")
 CALL accept(23,70,"A;CU","Y"
  WHERE curaccept IN ("Y", "N", "X"))
 SET answer = curaccept
 IF (answer="N")
  GO TO details
 ELSEIF (answer="X")
  GO TO end_99
 ENDIF
#details_end
#display_parameters
 SELECT
  s.seq
  FROM dummyt s
  WHERE s.seq=1
  HEAD REPORT
   cnt = 0, total = size(parm_vals->qual,5), col 0,
   total, row + 2
  DETAIL
   FOR (cnt = 1 TO parm_cnt)
     col 0, parm_vals->qual[cnt].parm_cd, col 20,
     parm_vals->qual[cnt].parm_value, row + 1
   ENDFOR
  WITH maxcol = 300
 ;end select
#body
 CALL clear(1,1)
 SET notes = fillstring(75," ")
 SET requestor = fillstring(30," ")
 SET output_name = fillstring(20," ")
 SET connection = fillstring(30," ")
 CALL box(1,1,22,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,18,"***   DBA Analyze Database Generator   ***")
 CALL clear(3,2,78)
 CALL text(5,3,"Output File Name:")
 CALL text(6,3,"    (Example:  analyze_prod_full )")
 CALL text(8,3,"Database User/Password@Link:")
 CALL text(9,3,"    (Example:  v500/secret@prod1 )")
 CALL text(13,03,"REQUESTOR:")
 CALL text(15,03,"NOTES:")
 CALL accept(5,50,"C(20);C")
 SET output_name = curaccept
 CALL accept(8,50,"p(30);C")
 SET connection = curaccept
 CALL accept(13,20,"p(30);CU")
 SET requestor = trim(curaccept)
 CALL accept(16,03,"p(75);c")
 SET notes = curaccept
 CALL text(23,30,"Correct (Y/N)? or X=Exit:")
 CALL accept(23,70,"A;CU","Y"
  WHERE curaccept IN ("Y", "N", "X"))
 SET answer = curaccept
 IF (answer="N")
  GO TO body
 ELSEIF (answer="X")
  GO TO end_99
 ENDIF
 SELECT INTO concat(trim(output_name),".sql")
  d.seq
  FROM (dummyt d  WITH seq = value(parm_cnt))
  HEAD REPORT
   cnt = 1, col 0, "--  This script is generated by the DBA Toolkit and ",
   row + 1, col 0, "--  should NOT be modified.  Please regenerate the script",
   row + 1, col 0, "--  through the DBA Toolkit if changes are needed.",
   row + 1, col 0, "declare                            ",
   row + 1, col 0, "        inpparmcds      dba_pkg_reports_control.parmcdstab;  ",
   row + 1, col 0, "        inpparmvals     dba_pkg_reports_control.parmvalstab; ",
   row + 1, col 0, "                                   ",
   row + 1, col 0, "begin                              ",
   row + 1, col 0, "                                   ",
   row + 1
   FOR (cnt = 1 TO parm_cnt)
     col 0, "       inpparmcds( ", col + 0,
     cnt, col + 0, " ) := ",
     col + 0, parm_vals->qual[cnt].parm_cd, col + 0,
     " ; ", row + 1
   ENDFOR
   cnt = 1
  DETAIL
   col 0, "       inpparmvals( ", col + 0,
   cnt, col + 0, ") := ",
   col + 0, parm_vals->qual[d.seq].parm_value, col + 0,
   " ; ", row + 1, cnt = (cnt+ 1)
  FOOT REPORT
   col 0, "                                                                          ", row + 1,
   col 0, "     dba_pkg_reports_control.sp_setup_report( 4, '", col + 0,
   requestor, col + 0, "', inpparmcds, ",
   row + 1, col 0, "                                                inpparmvals,              ",
   row + 1, col 0, "'",
   col + 0, notes, col + 0,
   "');", row + 1, col 0,
   "            ", row + 1, col 0,
   "end;        ", row + 1, col 0,
   "/           ", row + 1, col 0,
   "exit;"
  WITH maxcol = 120, format = variable
 ;end select
 SET sql_name = concat(trim(output_name),".sql")
 DECLARE oracle_version = i4
 SELECT INTO "NL:"
  p.*
  FROM product_component_version p
  WHERE cnvtupper(p.product)="ORACLE*"
  DETAIL
   oracle_version = cnvtint(substring(1,(findstring(".",p.version) - 1),p.version))
  WITH nocounter
 ;end select
 FREE RECORD ora_home
 RECORD ora_home(
   1 val = vc
 )
 IF (((cursys="AXP") OR (cursys="VMS")) )
  SELECT INTO "analyze_tmp.com"
   "hello"
   FROM dual
   DETAIL
    col 0, "$define/job analyze_tmp '", col + 0,
    'f$parse("ccluserdir",', col + 0, '"',
    col + 0, sql_name, col + 0,
    '",,,"no_conceal")', col + 0, "'",
    row + 1, col 0, "$exit"
   WITH nocounter
  ;end select
  SET dclcom = "@ccluserdir:analyze_tmp.com"
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  SELECT
   IF (oracle_version >= 9)INTO concat("run_",trim(output_name),".com")
    inst_id = concat("'",trim(cnvtstring(ref.instance_cd),3),"'"), ora_root = trim(logical(
      "ORACLE_HOME")), cer_data = logical("ANALYZE_TMP")
    FROM ref_instance_id ref
    WHERE ref.instance_cd=inst_id
   ELSE INTO concat("run_",trim(output_name),".com")
    inst_id = concat("'",trim(cnvtstring(ref.instance_cd),3),"'"), ora_root = trim(logical("ORA_ROOT"
      )), cer_data = logical("ANALYZE_TMP")
    FROM ref_instance_id ref
    WHERE ref.instance_cd=inst_id
   ENDIF
   HEAD REPORT
    col 0, " "
   DETAIL
    col 0, "$!  This script is generated by the DBA Toolkit.", row + 1,
    col 0, "$!  If the scripts are to be moved from CCLUSERDIR, ", row + 1,
    col 0, "$!  then modify the path below for the SQL script. ", row + 1
    IF (oracle_version >= 9)
     ora_home->val = trim(ora_root), col 0, "$@",
     col + 0, ora_home->val, col + 0,
     "orauser.com", row + 1
    ELSE
     len_space = findstring(" ",ora_root), len = textlen(ora_root), len_diff = ((len - len_space)+ 2),
     col 0, "$@", col + 0,
     ora_root, col- (len_diff), "util]orauser.com",
     row + 1
    ENDIF
    len_space = findstring(" ",cer_data), len = textlen(cer_data), len_diff = ((len - len_space)+ 2),
    col 0, "$sqlplus ", col + 1,
    connection, col + 1, " @",
    col + 0, cer_data, row + 1,
    col 0, "$exit"
   WITH format = variable
  ;end select
 ENDIF
 IF (cursys="AIX")
  SELECT INTO concat("run_",trim(output_name),".ksh")
   inst_id = concat("'",trim(cnvtstring(ref.instance_cd),3),"'"), ora_home = logical("ORACLE_HOME"),
   ccluserdir = logical("CCLUSERDIR")
   FROM ref_instance_id ref
   WHERE ref.instance_cd=inst_id
   HEAD REPORT
    col 0, " "
   DETAIL
    col 0, "#!/usr/bin/ksh", row + 1,
    col 0, "#  This script is generated by the DBA Toolkit.", row + 1,
    col 0, "#  If the scripts are to be moved from CCLUSERDIR, ", row + 1,
    col 0, "#  then modify the path below for the SQL script. ", row + 1,
    col 0, "export ORACLE_HOME=", col + 0,
    ora_home, row + 1, col 0,
    "export PATH=$PATH:$ORACLE_HOME/bin", row + 1, col 0,
    "sqlplus ", col + 0, connection,
    col + 1, " \", row + 1,
    col + 0, "@", len_space = findstring(" ",ccluserdir),
    len = textlen(ccluserdir), len_diff = ((len - len_space)+ 1), col + 0,
    ccluserdir, col- (len_diff), "/",
    col + 0, sql_name, row + 1,
    col 0, "exit", row + 1
   WITH format = variable
  ;end select
  SET dclcom = concat("chmod 775 $CCLUSERDIR/run_",trim(output_name),".ksh")
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
 ENDIF
 IF (((cursys="AXP") OR (cursys="VMS")) )
  SET run_name = concat("run_",trim(output_name),".com")
 ENDIF
 IF (cursys="AIX")
  SET run_name = concat("run_",trim(output_name),".ksh")
 ENDIF
#end_report
 CALL clear(1,1)
 CALL box(1,1,22,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(2,18,"***   DBA Analyze Database Generator   ***")
 CALL clear(3,2,78)
 CALL text(5,3,"The generated output files are located in the CCLUSERDIR directory with the")
 CALL text(6,3,"names of:")
 CALL text(7,10,sql_name)
 CALL text(7,40,run_name)
 CALL text(9,3,"Please note that the 'run' program is used to execute the SQL command.")
 CALL text(11,3,"You MUST execute these files from the O/S account from which the scripts were")
 CALL text(12,3,"generated OR verify that the user has the proper execute permissions.")
 CALL text(14,3,"You MUST modify the 'run' program if you wish to move the scripts from the")
 CALL text(15,3,"CCLUSERDIR to another directory (CUST_PROC for instance) in order for the")
 CALL text(16,3,"PATH to be correct for the SQL script.")
 IF (cursys != "AIX")
  CALL text(18,3,"VMS/AXP Example:")
  CALL text(19,3,"    submit/queue=<queue_name>/notify/log=<log_name> -")
  CALL text(20,2,"       ccluserdir:")
  CALL text(20,24,run_name)
 ELSE
  CALL text(18,3,"    AIX Example:    nohup $CCLUSERDIR/")
  CALL text(18,41,run_name)
  CALL text(18,73,"&")
 ENDIF
 CALL text(23,50,"Hit RETURN to Continue")
 CALL accept(23,73,"A;CU"," ")
#end_99
END GO
