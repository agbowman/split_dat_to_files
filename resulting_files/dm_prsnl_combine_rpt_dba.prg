CREATE PROGRAM dm_prsnl_combine_rpt:dba
 PAINT
 SET modify = system
 SET width = 132
#100_start
 SET true = 1
 SET false = 0
 SET dm_from_id = 0
 SET dm_to_id = 0
 SET childcount1 = 0
 SET childcount2 = 0
 SET maincount1 = 0
 SET maincount2 = 0
 SET maindummy = 0
 SET row_cnt = 0
 SET dm_next_to_id = 0
 SET ssn_cd = 0
 SET mrn_cd = 0
 SET a_name_full = fillstring(40," ")
 SET a_birth_dt_tm = cnvtdatetime(curdate,curtime)
 SET a_sex = fillstring(40," ")
 SET a_ssn = fillstring(20," ")
 SET a_prsnl_id = 0
 SET b_name_full = fillstring(40," ")
 SET b_birth_dt_tm = cnvtdatetime(curdate,curtime)
 SET b_sex = fillstring(40," ")
 SET b_ssn = fillstring(20," ")
 SET b_prsnl_id = 0
#200_menu
 FOR (x = 1 TO 24)
   CALL clear(x,1)
 ENDFOR
 CALL video(n)
 CALL box(1,1,23,132)
 CALL text(3,52,"Prsnl Combine Maintenance Tool")
 CALL line(5,1,132,xhorizontal)
 CALL video(n)
 CALL text(7,5,"Combined away Person_ID (0 to exit) :  ")
 CALL accept(7,44,"9(9);h",0)
 SET dm_from_id = curaccept
 IF (dm_from_id=0)
  GO TO 9999_end
 ENDIF
 CALL text(9,5,"Master Person_ID                    :  ")
 CALL accept(9,44,"9(9)")
 SET dm_to_id = curaccept
#300_load
 CALL video(n)
 CALL box(1,1,23,132)
 CALL text(24,2,"Working...")
 SELECT INTO "nl:"
  FROM person_combine pc
  WHERE pc.active_ind=1
   AND pc.encntr_id=0
   AND pc.from_person_id=dm_from_id
   AND pc.to_person_id=dm_to_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  FOR (x = 10 TO 17)
    CALL clear(x,35,50)
  ENDFOR
  CALL clear(24,1)
  CALL box(8,42,17,89)
  CALL video(r)
  CALL text(9,43,"   ******* COMBINE RECORD NOT FOUND *******   ")
  CALL video(n)
  CALL text(11,43,"   These 2 Person IDs were not found on any   ")
  CALL text(12,43,"   of active PERSON_COMBINE rows.             ")
  CALL text(13,43,"   Make sure you enter the right ids.         ")
  CALL text(14,43,"                                              ")
  CALL video(r)
  CALL text(16,43,"                        <Enter> to continue   ")
  CALL video(n)
  CALL accept(16,87,"p;cudh","C"
   WHERE curaccept IN ("C"))
  GO TO 100_start
 ENDIF
 SELECT INTO "nl:"
  FROM person p
  WHERE p.person_id=dm_to_id
   AND p.active_ind=1
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   FROM person_combine pc
   WHERE pc.active_ind=1
    AND pc.encntr_id=0
    AND pc.from_person_id=dm_to_id
   DETAIL
    dm_next_to_id = pc.to_person_id
   WITH nocounter
  ;end select
  FOR (x = 10 TO 17)
    CALL clear(x,35,50)
  ENDFOR
  CALL box(8,42,17,89)
  CALL video(r)
  CALL text(9,43,"           ******* IMPORTANT *******           ")
  CALL video(n)
  CALL text(11,43,"   The master person was also combined away    ")
  CALL text(12,43,"   to person_id          (write this down).    ")
  CALL text(12,59,format(dm_next_to_id,"########"))
  CALL text(13,43,"   Please run this tool again later to         ")
  CALL text(14,43,"   clean up.                                   ")
  CALL video(r)
  CALL text(16,43,"                        <Enter> to continue   ")
  CALL video(n)
  CALL accept(16,87,"p;cudh","C"
   WHERE curaccept IN ("C"))
  FOR (x = 1 TO 24)
    CALL clear(x,1)
  ENDFOR
 ENDIF
 CALL text(24,2,"Working...")
 FREE SET rcmbchildren
 RECORD rcmbchildren(
   1 qual[*]
     2 child_table = c30
     2 fk_name = c30
     2 pk_name = c30
 )
 SELECT INTO "nl:"
  b.table_name, c.column_name
  FROM user_constraints a,
   user_constraints b,
   user_cons_columns c
  WHERE a.owner=currdbuser
   AND a.table_name="PRSNL"
   AND a.constraint_type="P"
   AND a.owner=b.owner
   AND a.constraint_name=b.r_constraint_name
   AND b.constraint_type="R"
   AND b.owner=c.owner
   AND b.constraint_name=c.constraint_name
  DETAIL
   childcount1 += 1, stat = alterlist(rcmbchildren->qual,childcount1), rcmbchildren->qual[childcount1
   ].child_table = b.table_name,
   rcmbchildren->qual[childcount1].fk_name = c.column_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ucc.column_name
  FROM user_constraints uc,
   user_cons_columns ucc,
   (dummyt d  WITH seq = value(childcount1))
  PLAN (d)
   JOIN (uc
   WHERE uc.owner=currdbuser
    AND (uc.table_name=rcmbchildren->qual[d.seq].child_table)
    AND uc.constraint_type="P")
   JOIN (ucc
   WHERE uc.owner=ucc.owner
    AND uc.constraint_name=ucc.constraint_name
    AND ucc.position=1)
  DETAIL
   rcmbchildren->qual[d.seq].pk_name = ucc.column_name
  WITH nocounter
 ;end select
 FREE SET rrpt
 RECORD rrpt(
   1 qual[*]
     2 child_table = c30
     2 pk_name = c30
     2 pk_id = f8
     2 fk_name = c30
 )
 SET parser_buffer[20] = fillstring(132," ")
 FOR (maincount1 = 1 TO childcount1)
   FOR (x = 1 TO 11)
     SET parser_buffer[x] = fillstring(132," ")
   ENDFOR
   SET parser_buffer[1] = "select into 'nl:' ct.seq"
   SET parser_buffer[2] = concat("from   ",rcmbchildren->qual[maincount1].child_table," ct")
   SET parser_buffer[3] = concat("where  ct.",rcmbchildren->qual[maincount1].fk_name," = ",build(
     dm_from_id))
   SET parser_buffer[4] = "detail"
   SET parser_buffer[5] = "       childcount2 = childcount2 + 1"
   SET parser_buffer[6] = "       stat = alterlist(rRpt->qual, childcount2)"
   SET parser_buffer[7] =
   "rRpt->qual[childcount2]->child_table = rCmbChildren->qual[maincount1]->child_table"
   SET parser_buffer[8] =
   "rRpt->qual[childcount2]->pk_name = rCmbChildren->qual[maincount1]->pk_name"
   SET parser_buffer[9] = concat("rRpt->qual[childcount2]->pk_id = ct.",trim(rcmbchildren->qual[
     maincount1].pk_name))
   SET parser_buffer[10] =
   "rRpt->qual[childcount2]->fk_name = rCmbChildren->qual[maincount1]->fk_name"
   SET parser_buffer[11] = "with   nocounter go"
   FOR (x = 1 TO 11)
     CALL parser(parser_buffer[x])
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=4
   AND c.cdf_meaning="SSN"
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   ssn_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.name_full_formatted, p.birth_dt_tm, c.display
  FROM person p,
   code_value c
  PLAN (p
   WHERE p.person_id=dm_from_id)
   JOIN (c
   WHERE c.code_value=p.sex_cd)
  DETAIL
   a_name_full = substring(1,28,p.name_full_formatted), a_birth_dt_tm = p.birth_dt_tm, a_sex = c
   .display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.person_id
  FROM prsnl p
  WHERE p.person_id=dm_from_id
  DETAIL
   a_prsnl_id = p.person_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.name_full_formatted, p.birth_dt_tm, c.display
  FROM person p,
   code_value c
  PLAN (p
   WHERE p.person_id=dm_to_id)
   JOIN (c
   WHERE c.code_value=p.sex_cd)
  DETAIL
   b_name_full = substring(1,28,p.name_full_formatted), b_birth_dt_tm = p.birth_dt_tm, b_sex = c
   .display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.alias
  FROM person_alias p
  WHERE p.person_id=dm_to_id
   AND p.person_alias_type_cd=ssn_cd
   AND p.active_ind=true
   AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   b_ssn = substring(1,28,p.alias)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.person_id
  FROM prsnl p
  WHERE p.person_id=dm_to_id
  DETAIL
   b_prsnl_id = p.person_id
  WITH nocounter
 ;end select
#400_report
 CALL clear(24,1)
 FOR (x = 2 TO 22)
   CALL clear(x,2,130)
 ENDFOR
 CALL video(n)
 CALL text(3,56,"Prsnl Combine Report")
 CALL line(5,1,132,xhorizontal)
 CALL text(7,47,"Person #1")
 CALL text(7,76,"Person #2")
 CALL line(8,30,74,horizontal)
 CALL text(10,30,"PRSNL_ID :")
 CALL text(11,30,"Name     :")
 CALL text(12,30,"DOB      :")
 CALL text(13,30,"SEX      :")
 CALL text(14,30,"SSN      :")
 CALL video(l)
 IF (a_prsnl_id > 0)
  CALL text(10,47,format(a_prsnl_id,"########;l"))
 ENDIF
 CALL text(11,47,a_name_full)
 CALL text(12,47,format(a_birth_dt_tm,"DD-MMM-YYYY;3;d"))
 CALL text(13,47,a_sex)
 IF (b_prsnl_id > 0)
  CALL text(10,76,format(b_prsnl_id,"########;l"))
 ENDIF
 CALL text(11,76,b_name_full)
 CALL text(12,76,format(b_birth_dt_tm,"DD-MMM-YYYY;3;d"))
 CALL text(13,76,b_sex)
 CALL text(14,76,b_ssn)
 CALL text(24,2,"<Enter> to continue...")
 CALL accept(24,25,"p;cudh","C"
  WHERE curaccept IN ("C"))
 CALL clear(24,1)
 FOR (x = 2 TO 22)
   CALL clear(x,2,130)
 ENDFOR
 CALL dm_header(maindummy)
 SET dm_size = size(rrpt->qual,5)
 IF (dm_size=0)
  CALL text(8,3,"**** No leftover prsnl records ****")
  CALL text(24,2,"<Enter> to continue...")
  CALL accept(24,25,"p;cudh","C"
   WHERE curaccept IN ("C"))
  GO TO 100_start
 ENDIF
 FOR (maincount2 = 1 TO childcount2)
   IF (row_cnt < 22)
    CALL text(row_cnt,3,rrpt->qual[maincount2].child_table)
    CALL text(row_cnt,36,rrpt->qual[maincount2].pk_name)
    CALL text(row_cnt,70,format(rrpt->qual[maincount2].pk_id,"###########"))
    SET row_cnt += 1
   ELSE
    CALL text(24,2,"<Enter> to continue...")
    CALL accept(24,25,"p;cudh","C"
     WHERE curaccept IN ("C"))
    CALL clear(24,1)
    FOR (x = 2 TO 22)
      CALL clear(x,2,130)
    ENDFOR
    CALL dm_header(maindummy)
    CALL text(row_cnt,3,rrpt->qual[maincount2].child_table)
    CALL text(row_cnt,36,rrpt->qual[maincount2].pk_name)
    CALL text(row_cnt,70,format(rrpt->qual[maincount2].pk_id,"###########"))
    SET row_cnt += 1
   ENDIF
 ENDFOR
 CALL text(24,2,"<Enter> to continue...")
 CALL accept(24,25,"p;cudh","C"
  WHERE curaccept IN ("C"))
#500_menu2
 CALL clear(24,1)
 FOR (x = 2 TO 22)
   CALL clear(x,2,130)
 ENDFOR
 CALL text(3,3,"1  Move prsnl records")
 CALL text(5,3,"2  Restart and enter new person_ids")
 CALL text(24,2,"Select Option? ")
 CALL accept(24,18,"9;",2
  WHERE curaccept IN (1, 2))
 CALL clear(24,1)
 SET dm_choice = curaccept
 CASE (dm_choice)
  OF 1:
   CALL text(24,2,"Option # 1 selected.  Continue (Y/N)?")
   CALL accept(24,40,"p;cud","Y"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    CALL clear(24,1)
    CALL text(24,2,"Working...")
    SET dm_today = cnvtdatetime(sysdate)
    SELECT INTO prsnl_combine_log
     d.seq
     FROM dummyt d
     DETAIL
      col 0, "PRSNL COMBINE LOG", row + 1,
      "-----------------", row + 1, "Date/Time :",
      col + 1, dm_today"MM/DD/YYYY  HH:MM;;d", row + 2,
      "TABLE NAME                       PK COLUMN NAME                   PK ID       STATUS/ERROR",
      row + 1,
      "------------------------------   ------------------------------   ---------   ------------"
     WITH nocounter, format = variable, noformfeed,
      maxrow = 6, maxcol = 211, noheading
    ;end select
    CALL dm_prsnl_combine(maindummy)
    CALL clear(24,1)
    CALL text(24,2,"You can view the log in CCLUSERDIR:PRSNL_COMBINE_LOG.DAT. <Enter> to continue..."
     )
    CALL accept(24,82,"p;cudh","C"
     WHERE curaccept IN ("C"))
   ELSEIF (curaccept="N")
    GO TO 500_menu2
   ENDIF
  OF 2:
   CALL text(24,2,"Option # 2 selected.  Continue (Y/N)?")
   CALL accept(24,40,"p;cud","Y"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    CALL clear(24,1)
    GO TO 100_start
   ELSEIF (curaccept="N")
    GO TO 500_menu2
   ENDIF
 ENDCASE
 GO TO 100_start
#9999_end
 FOR (x = 1 TO 24)
   CALL clear(x,1)
 ENDFOR
 SUBROUTINE dm_header(dummy)
   FOR (x = 1 TO 24)
     CALL clear(x,1)
   ENDFOR
   CALL box(1,1,23,132)
   CALL text(3,3,"Tables that will be affected")
   CALL text(5,3,"TABLE NAME                       PRIMARY KEY COLUMN NAME          PRIMARY KEY ID")
   CALL line(6,3,80,horizontal)
   SET row_cnt = 7
 END ;Subroutine
 SUBROUTINE dm_prsnl_combine(dummy)
   FOR (maincount2 = 1 TO childcount2)
     FOR (x = 1 TO 10)
       SET parser_buffer[x] = fillstring(132," ")
     ENDFOR
     SET parser_buffer[1] = concat("update into ",rrpt->qual[maincount2].child_table," ct set")
     SET parser_buffer[2] = concat("ct.",rrpt->qual[maincount2].fk_name,"= dm_to_id,")
     SET parser_buffer[3] = "ct.updt_cnt = ct.updt_cnt + ct.updt_cnt + 1,"
     SET parser_buffer[4] = "ct.updt_id = 1234,"
     SET parser_buffer[5] = "ct.updt_dt_tm = cnvtdatetime(curdate,curtime3),"
     SET parser_buffer[6] = "ct.updt_task = 1234,"
     SET parser_buffer[7] = "ct.updt_applctx = 1234"
     SET parser_buffer[8] = concat("where ct.",rrpt->qual[maincount2].fk_name," = dm_from_id")
     SET parser_buffer[9] = concat("and ct.",rrpt->qual[maincount2].pk_name," = ",build(rrpt->qual[
       maincount2].pk_id))
     SET parser_buffer[10] = "with nocounter go"
     FOR (x = 1 TO 10)
      CALL parser(parser_buffer[x])
      CALL echo(parser_buffer[x])
     ENDFOR
     SET dm_pk_id = 0
     SET ecode = 0
     SET emsg = fillstring(132," ")
     SET ecode = error(emsg,0)
     SET dm_child_table = rrpt->qual[maincount2].child_table
     SET dm_pk_name = rrpt->qual[maincount2].pk_name
     SET dm_pk_id = rrpt->qual[maincount2].pk_id
     SET dm_emsg = substring(1,132,emsg)
     SELECT INTO prsnl_combine_log
      d.seq
      FROM dummyt d
      DETAIL
       col 0, dm_child_table, col 33,
       dm_pk_name, col 66, dm_pk_id"#########"
       IF (ecode=0)
        col 78, "OK"
       ELSE
        col 78, dm_emsg
       ENDIF
      WITH nocounter, format = variable, noformfeed,
       maxrow = 1, maxcol = 211, noheading,
       append
     ;end select
   ENDFOR
 END ;Subroutine
END GO
