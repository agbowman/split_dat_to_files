CREATE PROGRAM dm_combine_scan:dba
 PAINT
 SET width = 132
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_prompt TO 2999_prompt_exit
 EXECUTE FROM 3000_scan TO 3999_scan_exit
 EXECUTE FROM 4000_report TO 4999_report_exit
 GO TO 9999_exit_program
 SUBROUTINE add_action(aa_from_id,aa_to_id,aa_style)
   SET aa_i = (size(work->problem[problem_index].action,5)+ 1)
   SET stat = alterlist(work->problem[problem_index].action,aa_i)
   SET work->problem[problem_index].action[aa_i].from_id = aa_from_id
   SET work->problem[problem_index].action[aa_i].to_id = aa_to_id
   SET work->problem[problem_index].action[aa_i].style = aa_style
 END ;Subroutine
 SUBROUTINE add_problem(ap_style,ap_id,ap_table,ap_column)
   SET ap_flag = 1
   FOR (ap_i = 1 TO size(work->problem,5))
     IF ((work->problem[ap_i].style=ap_style)
      AND (work->problem[ap_i].id=ap_id))
      SET ap_flag2 = 1
      FOR (ap_j = 1 TO size(work->problem[ap_i].owner,5))
        IF ((work->problem[ap_i].owner[ap_j].table_name=ap_table)
         AND (work->problem[ap_i].owner[ap_j].column_name=ap_column))
         SET ap_flag2 = 0
         SET ap_j = (size(work->problem[ap_i].owner,5)+ 1)
        ENDIF
      ENDFOR
      IF (ap_flag2)
       SET ap_j = (size(work->problem[ap_i].owner,5)+ 1)
       SET stat = alterlist(work->problem[ap_i].owner,ap_j)
       SET work->problem[ap_i].owner[ap_j].table_name = ap_table
       SET work->problem[ap_i].owner[ap_j].column_name = ap_column
      ENDIF
      SET ap_flag = 0
      SET ap_i = (size(work->problem,5)+ 1)
     ENDIF
   ENDFOR
   IF (ap_flag)
    SET ap_i = (size(work->problem,5)+ 1)
    SET stat = alterlist(work->problem,ap_i)
    SET work->problem[ap_i].style = ap_style
    SET work->problem[ap_i].id = ap_id
    SET stat = alterlist(work->problem[ap_i].owner,1)
    SET work->problem[ap_i].owner[1].table_name = ap_table
    SET work->problem[ap_i].owner[1].column_name = ap_column
    CALL text(2,124,format(ap_i,"#######;P "))
   ENDIF
 END ;Subroutine
 SUBROUTINE encounter_actions(ea_dummy)
   FREE RECORD ea_tree
   RECORD ea_tree(
     1 combine[*]
       2 from_id = f8
       2 to_id = f8
   )
   SET ea_count = 0
   SET ea_from_id = problem_id
   SET ea_to_id = 0.0
   SET ea_flag = 1
   WHILE (ea_flag)
     SET ea_to_id = 0.0
     SELECT INTO "nl:"
      c.to_encntr_id
      FROM encntr_combine c
      WHERE c.from_encntr_id=ea_from_id
       AND c.to_encntr_id > 0.0
       AND c.active_ind=1
      ORDER BY c.encntr_combine_id
      DETAIL
       ea_to_id = c.to_encntr_id
      WITH nocounter
     ;end select
     IF (ea_to_id)
      SET ea_count = (ea_count+ 1)
      SET stat = alterlist(ea_tree->combine,ea_count)
      SET ea_tree->combine[ea_count].from_id = ea_from_id
      SET ea_tree->combine[ea_count].to_id = ea_to_id
      SET ea_from_id = ea_to_id
      IF (ea_count >= cmax)
       SET ea_flag = 0
      ENDIF
     ELSE
      SET ea_flag = 0
     ENDIF
   ENDWHILE
   FOR (ea_i = 1 TO ea_count)
    SET ea_j = ((ea_count - ea_i)+ 1)
    CALL add_action(ea_tree->combine[ea_j].from_id,ea_tree->combine[ea_j].to_id,cuncombine)
   ENDFOR
   FOR (ea_i = 1 TO ea_count)
     CALL add_action(ea_tree->combine[ea_i].from_id,ea_tree->combine[ea_i].to_id,ccombine)
   ENDFOR
 END ;Subroutine
 SUBROUTINE move_actions(ma_dummy)
   SET ma_from_person_id = 0.0
   SET ma_to_person_id = 0.0
   SELECT INTO "nl:"
    c.to_person_id
    FROM person_combine c
    WHERE c.encntr_id=problem_id
     AND c.from_person_id > 0.0
     AND c.to_person_id > 0.0
     AND c.active_ind=1
    ORDER BY c.person_combine_id
    DETAIL
     ma_from_person_id = c.from_person_id, ma_to_person_id = c.to_person_id
    WITH nocounter
   ;end select
   CALL add_action(ma_to_person_id,ma_from_person_id,cmove)
   CALL add_action(ma_from_person_id,ma_to_person_id,cmove)
 END ;Subroutine
 SUBROUTINE person_actions(pa_dummy)
   FREE RECORD pa_tree
   RECORD pa_tree(
     1 combine[*]
       2 from_id = f8
       2 to_id = f8
   )
   SET pa_count = 0
   SET pa_from_id = problem_id
   SET pa_to_id = 0.0
   SET pa_flag = 1
   WHILE (pa_flag)
     SET pa_to_id = 0.0
     SELECT INTO "nl:"
      c.to_person_id
      FROM person_combine c
      WHERE c.from_person_id=pa_from_id
       AND c.to_person_id > 0.0
       AND c.encntr_id=0.0
       AND c.active_ind=1
      ORDER BY c.person_combine_id
      DETAIL
       pa_to_id = c.to_person_id
      WITH nocounter
     ;end select
     IF (pa_to_id)
      SET pa_count = (pa_count+ 1)
      SET stat = alterlist(pa_tree->combine,pa_count)
      SET pa_tree->combine[pa_count].from_id = pa_from_id
      SET pa_tree->combine[pa_count].to_id = pa_to_id
      SET pa_from_id = pa_to_id
      IF (pa_count >= cmax)
       SET pa_flag = 0
      ENDIF
     ELSE
      SET pa_flag = 0
     ENDIF
   ENDWHILE
   FOR (pa_i = 1 TO pa_count)
    SET pa_j = ((pa_count - pa_i)+ 1)
    CALL add_action(pa_tree->combine[pa_j].from_id,pa_tree->combine[pa_j].to_id,cuncombine)
   ENDFOR
   FOR (pa_i = 1 TO pa_count)
     CALL add_action(pa_tree->combine[pa_i].from_id,pa_tree->combine[pa_i].to_id,ccombine)
   ENDFOR
 END ;Subroutine
 SUBROUTINE push(p_text)
   SET p_i = (size(work->buffer,5)+ 1)
   SET p_stat = alterlist(work->buffer,p_i)
   SET work->buffer[p_i].text = p_text
 END ;Subroutine
 SUBROUTINE run(r_dummy)
  FOR (r_i = 1 TO size(work->buffer,5))
    CALL parser(work->buffer[r_i].text,1)
  ENDFOR
  SET stat = alterlist(work->buffer,0)
 END ;Subroutine
 SUBROUTINE skip_check(st_parent,st_table,st_column)
   IF (findstring("PRSNL_ID",st_column))
    RETURN(1)
   ENDIF
   IF (findstring("OMF_",st_table))
    RETURN(1)
   ENDIF
   IF (findstring("SCH_",st_table))
    RETURN(1)
   ENDIF
   IF (findstring("HARRY",st_table))
    RETURN(1)
   ENDIF
   CASE (st_table)
    OF "CHART_PROCESS":
     RETURN(1)
    OF "CUSTOM_PT_LIST":
     RETURN(1)
    OF "ENCNTR_ACCIDENT":
     RETURN(1)
    OF "ENCNTR_ALIAS":
     RETURN(1)
    OF "ENCNTR_DOMAIN":
     RETURN(1)
    OF "ENCNTR_INFO":
     RETURN(1)
    OF "ENCNTR_LOC_HIST":
     RETURN(1)
    OF "ENCNTR_PERSON_RELTN":
     RETURN(1)
    OF "ENCNTR_PLAN_RELTN":
     RETURN(1)
    OF "ENCNTR_PRSNL_RELTN":
     RETURN(1)
    OF "PERSON_ALIAS":
     RETURN(1)
    OF "PERSON_NAME":
     RETURN(1)
    OF "PERSON_MATCHES":
     RETURN(1)
    OF "PERSON_MATCH_REV":
     RETURN(1)
    OF "PERSON_ORG_RELTN":
     RETURN(1)
    OF "PERSON_PATIENT":
     RETURN(1)
    OF "PERSON_PERSON_RELTN":
     RETURN(1)
    OF "PERSON_PLAN_RELTN":
     RETURN(1)
    OF "PERSON_PRSNL_ACTIVITY":
     RETURN(1)
    OF "PERSON_PRSNL_RELTN":
     RETURN(1)
    OF "PRIV_LOC_RELTN":
     RETURN(1)
    OF "PRSNL":
     RETURN(1)
    OF "PRSNL_ALIAS":
     RETURN(1)
    OF "PRSNL_GROUP_RELTN":
     RETURN(1)
    OF "PRSNL_INFO":
     RETURN(1)
   ENDCASE
   CASE (st_table)
    OF "CHARGE":
     RETURN(1)
    OF "CHARGE_EVENT":
     RETURN(1)
    OF "INTERFACE_CHARGE":
     RETURN(1)
    OF "OMF_CHARGE_ST":
     RETURN(1)
    OF "PFT_ENCNTR":
     RETURN(1)
    OF "PFT_ENCNTR_HIST":
     RETURN(1)
    OF "UM_CHARGE_EVENT_ST":
     RETURN(1)
    OF "ACCT_BALANCE":
     RETURN(1)
    OF "AGED_TRIAL_BALANCE":
     RETURN(1)
    OF "BATCH_TRANS_FILE":
     RETURN(1)
    OF "CONS_BO_SCHED":
     RETURN(1)
    OF "ICLASS_PERSON_RELTN":
     RETURN(1)
    OF "FOLDER":
     RETURN(1)
   ENDCASE
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name=st_table
     AND l.attr_name=st_column
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    WITH nocounter
   ;end select
   IF ( NOT (curqual))
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    e.child_entity
    FROM dm_cmb_exception e
    WHERE e.operation_type="COMBINE"
     AND e.parent_entity=st_parent
     AND e.child_entity=st_table
     AND cnvtupper(e.script_name)="NONE"
    WITH nocounter
   ;end select
   IF (curqual)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE status(s_message)
   FREE SET s_temp
   SET s_temp = fillstring(130," ")
   SET s_temp = concat("  ",s_message)
   CALL text(24,1,s_temp)
 END ;Subroutine
#1000_initialize
 SET cencounter = 1
 SET cmove = 2
 SET cperson = 3
 SET ccombine = 4
 SET cuncombine = 5
 SET cmax = 100
 FREE RECORD work
 RECORD work(
   1 text = vc
   1 check[*]
     2 table_name = vc
     2 column_name = vc
     2 encounter = i2
     2 skip = i2
     2 multiple = i2
     2 encntr_col = vc
   1 problem[*]
     2 id = f8
     2 style = i2
     2 owner[*]
       3 table_name = vc
       3 column_name = vc
     2 action[*]
       3 from_id = f8
       3 to_id = f8
       3 style = i2
   1 buffer[*]
     2 text = vc
 )
#1999_initialize_exit
#2000_prompt
 CALL clear(1,1)
 CALL box(1,1,3,132)
 CALL text(2,3,"C O M B I N E   S C A N")
 CALL text(5,3,
  "This utility scans activity tables for rows with combined-away person or encounter IDs.  If any rows are     "
  )
 CALL text(6,3,
  "found, this may indicate that activity has been inadvertently added to a combined-away person or encounter   "
  )
 CALL text(7,3,
  "before the combine triggers were put in place (the combine triggers prevent this incorrect activity).  When  "
  )
 CALL text(8,3,
  "the scan is complete a report is generated indicating uncombine/re-combine steps that can be performed to    "
  )
 CALL text(9,3,
  "manually correct any problems.                                                                               "
  )
 CALL clear(11,1)
 CALL text(11,3,"Start (S)can or (Q)uit:")
 CALL accept(11,27,"P;CU","S"
  WHERE curaccept IN ("S", "Q"))
 IF (cnvtupper(trim(curaccept,3)) != "S")
  GO TO 9999_exit_program
 ENDIF
#2999_prompt_exit
#3000_scan
 CALL status("Loading the list of activity tables...")
 SET i = 0
 SELECT INTO "nl:"
  c.child_table
  FROM dm_cmb_children c
  WHERE c.parent_table IN ("PERSON", "ENCOUNTER")
   AND c.child_column > " "
   AND c.child_pk > " "
  ORDER BY c.child_table, c.child_column
  DETAIL
   i = (i+ 1), stat = alterlist(work->check,i), work->check[i].table_name = cnvtupper(trim(c
     .child_table,3)),
   work->check[i].column_name = cnvtupper(trim(c.child_column,3))
   IF (c.parent_table="ENCOUNTER")
    work->check[i].encounter = 1
   ENDIF
   IF (c.child_table="ENCNTR_PLAN_RELTN")
    work->check[i].multiple = 1
   ENDIF
  WITH nocounter
 ;end select
 FOR (i = 1 TO size(work->check,5))
   IF (work->check[i].encounter)
    SET work->check[i].skip = skip_check("ENCOUNTER",work->check[i].table_name,work->check[i].
     column_name)
   ELSE
    SET work->check[i].skip = skip_check("PERSON",work->check[i].table_name,work->check[i].
     column_name)
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  c.child_table
  FROM dm_cmb_children c,
   (dummyt d  WITH seq = value(size(work->check,5)))
  PLAN (d
   WHERE (work->check[d.seq].encounter=0)
    AND (((work->check[d.seq].table_name != "OMF_ENCNTR_ST")) OR ((work->check[d.seq].column_name !=
   "PERSON_ID"))) )
   JOIN (c
   WHERE c.parent_table="PERSON"
    AND (c.child_table=work->check[d.seq].table_name)
    AND (c.child_column != work->check[d.seq].column_name))
  DETAIL
   work->check[d.seq].multiple = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.child_column
  FROM dm_cmb_children c,
   (dummyt d  WITH seq = value(size(work->check,5)))
  PLAN (d
   WHERE (work->check[d.seq].encounter=0)
    AND (work->check[d.seq].multiple=0))
   JOIN (c
   WHERE c.parent_table="ENCOUNTER"
    AND (c.child_table=work->check[d.seq].table_name)
    AND c.child_column > " ")
  DETAIL
   work->check[d.seq].encntr_col = cnvtupper(trim(c.child_column,3))
  WITH nocounter
 ;end select
 SET now = cnvtdatetime(curdate,curtime3)
 SET now2 = cnvtdatetime((curdate - 2),curtime3)
 FOR (i = 1 TO size(work->check,5))
  CALL status(concat("Performing scan ",trim(cnvtstring(i),3)," of ",trim(cnvtstring(size(work->check,
       5)),3)," (",
    work->check[i].table_name,"/",work->check[i].column_name,")..."))
  IF ( NOT (work->check[i].skip))
   SET active_check = 0
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE (a.table_name=work->check[i].table_name)
     AND l.attr_name="ACTIVE_IND"
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    DETAIL
     active_check = 1
    WITH nocounter
   ;end select
   IF (work->check[i].encounter)
    CALL push("select into 'nl:' c.from_encntr_id")
    CALL push(concat("  from ",work->check[i].table_name," x, encntr_combine c"))
    CALL push("  plan c")
    CALL push(" where c.from_encntr_id > 0.0")
    CALL push("   and c.to_encntr_id > 0.0")
    CALL push("   and c.updt_dt_tm >= cnvtdatetime(now2)")
    CALL push("   and c.active_ind = 1")
    CALL push("  join x")
    CALL push(concat(" where x.",work->check[i].column_name," = c.from_encntr_id"))
    IF (active_check)
     CALL push("   and x.active_ind = 1")
    ENDIF
    CALL push("detail")
    CALL push(
     "  call add_problem(cENCOUNTER, c.from_encntr_id, work->check[i]->table_name, work->check[i]->column_name)"
     )
    CALL push("with nocounter go")
    CALL run(0)
   ELSE
    IF (size(trim(work->check[i].encntr_col,3)))
     CALL push("select into 'nl:' c.encntr_id")
     CALL push(concat("  from ",work->check[i].table_name," x, person_combine c"))
     CALL push("  plan c")
     CALL push(" where c.from_person_id > 0.0")
     CALL push("   and c.to_person_id > 0.0")
     CALL push("   and c.encntr_id > 0.0")
     CALL push("   and c.updt_dt_tm >= cnvtdatetime(now2)")
     CALL push("   and c.active_ind = 1")
     CALL push("   and not exists(select z.from_person_id")
     CALL push("                    from person_combine z")
     CALL push("                   where z.from_person_id = c.to_person_id")
     CALL push("                     and z.person_combine_id > c.person_combine_id")
     CALL push("                     and z.active_ind = 1")
     CALL push("                     and z.encntr_id = 0)")
     CALL push("   and not exists(select p.encntr_id")
     CALL push("                    from person_combine p")
     CALL push("                   where p.encntr_id = c.encntr_id")
     CALL push("                     and p.person_combine_id > c.person_combine_id")
     CALL push("                     and p.active_ind = 1)")
     CALL push("  join x")
     CALL push(concat(" where x.",work->check[i].encntr_col," = c.encntr_id"))
     CALL push(concat("   and x.",work->check[i].column_name," != c.to_person_id"))
     IF (active_check)
      CALL push("   and x.active_ind = 1")
     ENDIF
     CALL push("detail")
     CALL push(
      "  call add_problem(cMOVE, c.encntr_id, work->check[i]->table_name, work->check[i]->column_name)"
      )
     CALL push("with nocounter go")
     CALL run(0)
    ENDIF
    CALL push("select into 'nl:' c.from_person_id")
    CALL push(concat("  from ",work->check[i].table_name," x, person_combine c"))
    CALL push("  plan c")
    CALL push(" where c.from_person_id > 0.0")
    CALL push("   and c.to_person_id > 0.0")
    CALL push("   and c.encntr_id = 0.0")
    CALL push("   and c.updt_dt_tm >= cnvtdatetime(now2)")
    CALL push("   and c.active_ind = 1")
    CALL push("  join x")
    CALL push(concat(" where x.",work->check[i].column_name," = c.from_person_id"))
    IF (active_check)
     CALL push("   and x.active_ind = 1")
    ENDIF
    CALL push("detail")
    CALL push(
     "  call add_problem(cPERSON, c.from_person_id, work->check[i]->table_name, work->check[i]->column_name)"
     )
    CALL push("with nocounter go")
    CALL run(0)
   ENDIF
  ENDIF
 ENDFOR
#3999_scan_exit
#4000_report
 IF ( NOT (size(work->problem,5)))
  CALL clear(24,1)
  CALL text(24,3,"No problems found.  Press <RETURN> to exit...")
  CALL accept(24,49,"P;E"," ")
  GO TO 9999_exit_program
 ENDIF
 CALL status("Generating report...")
 FOR (i = 1 TO size(work->problem,5))
   SET problem_index = i
   SET problem_id = work->problem[i].id
   CASE (work->problem[i].style)
    OF cperson:
     CALL person_actions(0)
    OF cencounter:
     CALL encounter_actions(0)
    OF cmove:
     CALL move_actions(0)
   ENDCASE
 ENDFOR
 SET problems = 0
 SET actions = 0
 SET owners = 0
 SET page_number = 0
 SET cols = 80
 SELECT
  style = work->problem[d.seq].style, id = work->problem[d.seq].id
  FROM (dummyt d  WITH seq = value(size(work->problem,5)))
  PLAN (d)
  ORDER BY style, id
  HEAD REPORT
   CALL center("*** C O M B I N E   S C A N   R E P O R T ***",1,cols), row + 1,
   CALL center(concat(trim(format(now2,"MM/DD/YY HH:MM;3;D"),3)," to ",trim(format(now,
      "MM/DD/YY HH:MM;3;D"),3)),1,cols),
   row + 2, divider = 0
  HEAD style
   IF (style > 1)
    IF (divider)
     " -------------------", row + 2
    ELSE
     divider = 1
    ENDIF
   ENDIF
  DETAIL
   actions = size(work->problem[d.seq].action,5)
   IF (actions
    AND actions < cmax)
    problems = (problems+ 1), col 0
    CASE (style)
     OF cperson:
      CALL print(concat(" ",trim(cnvtstring(problems),3),") Combined-away person ",trim(cnvtstring(id
         ),3)," has activity data."))
     OF cencounter:
      CALL print(concat(" ",trim(cnvtstring(problems),3),") Combined-away encounter ",trim(cnvtstring
        (id),3)," has activity data."))
     OF cmove:
      CALL print(concat(" ",trim(cnvtstring(problems),3),") Encounter ",trim(cnvtstring(id),3),
       " was moved but not all data got carried forward."))
    ENDCASE
    row + 2,
    CALL print("    Tables : "), work->text = "",
    owners = size(work->problem[d.seq].owner,5)
    FOR (i = 1 TO owners)
     IF (size(trim(work->text,3)))
      work->text = concat(work->text,", ",work->problem[d.seq].owner[i].table_name)
     ELSE
      work->text = work->problem[d.seq].owner[i].table_name
     ENDIF
     ,
     IF ((((size(work->text) > (cols - 30))) OR (i >= owners)) )
      col 14, work->text, row + 1,
      work->text = ""
     ENDIF
    ENDFOR
    row + 1,
    CALL print("    Actions: "), actions = size(work->problem[d.seq].action,5)
    FOR (i = 1 TO actions)
      work->text = concat(char((i+ 96)),") ")
      CASE (work->problem[d.seq].action[i].style)
       OF ccombine:
        IF (style=cencounter)
         work->text = concat(work->text," Combine encounter ",trim(cnvtstring(work->problem[d.seq].
            action[i].from_id),3)," into encounter ",trim(cnvtstring(work->problem[d.seq].action[i].
            to_id),3),
          ".")
        ELSE
         work->text = concat(work->text," Combine person ",trim(cnvtstring(work->problem[d.seq].
            action[i].from_id),3)," into person ",trim(cnvtstring(work->problem[d.seq].action[i].
            to_id),3),
          ".")
        ENDIF
       OF cuncombine:
        IF (style=cencounter)
         work->text = concat(work->text," Uncombine encounter ",trim(cnvtstring(work->problem[d.seq].
            action[i].from_id),3)," from encounter ",trim(cnvtstring(work->problem[d.seq].action[i].
            to_id),3),
          ".")
        ELSE
         work->text = concat(work->text," Uncombine person ",trim(cnvtstring(work->problem[d.seq].
            action[i].from_id),3)," from person ",trim(cnvtstring(work->problem[d.seq].action[i].
            to_id),3),
          ".")
        ENDIF
       OF cmove:
        work->text = concat(work->text," Move encounter ",trim(cnvtstring(id),3)," to person ",trim(
          cnvtstring(work->problem[d.seq].action[i].to_id),3),
         ".")
      ENDCASE
      col 14, work->text, row + 1
    ENDFOR
    row + 2
   ENDIF
  FOOT REPORT
   CALL center("*** end of report ***",1,cols)
  WITH nocounter, nocompress
 ;end select
#4999_report_exit
#9999_exit_program
 CALL clear(1,1)
END GO
