CREATE PROGRAM dts_templates_by_provider:dba
 PAINT
#initialize_variables
 FREE SET dts_add_request
 RECORD dts_add_request(
   1 prsnl_id = f8
   1 templates[*]
     2 id = f8
 )
 FREE SET dts_add_template
 RECORD dts_add_template(
   1 template_id = f8
   1 template_name = vc
   1 template_active_ind = i2
   1 long_blob_id = f8
   1 smart_template_cd = f8
   1 smart_template_ind = i2
   1 owner_type_flag = i2
 )
 DECLARE template_id = f8 WITH public, noconstant(0.0)
#main_menu
 SET message = window
 CALL clear(1,1)
 CALL video(nw)
 CALL box(1,1,23,80)
 CALL text(3,20,"T E M P L A T E S   B Y   P R O V I D E R")
 CALL line(5,1,80,xhor)
 CALL text(08,07,"1) Add template(s) to a provider")
 CALL text(10,07,"2) Remove template(s) of a provider")
 CALL text(12,07,"3) List templates of a provider")
 CALL text(14,07,"4) Quit (don't save changes)")
 CALL text(16,07,"5) Exit")
 CALL text(20,07,"Enter a choice:   1")
 CALL accept(20,25,"9;",1
  WHERE curaccept IN (1, 2, 3, 4, 5))
 CASE (curaccept)
  OF 1:
   GO TO add_menu
  OF 2:
   GO TO remove_menu
  OF 3:
   GO TO list_menu
  OF 4:
   GO TO end_program
  OF 5:
   COMMIT
   GO TO end_program
 ENDCASE
 GO TO main_menu
#add_menu
 CALL clear(1,1)
 CALL video(n)
 SET v_temp_cnt = 0
 SET v_temp_line = 10
 SET v_temp_pos = 35
 SET v_rel_type = " "
 SET cnt = 0
 CALL box(1,1,23,80)
 CALL text(3,15,"A D D   T E M P L A T E S   TO   A   P R O V I D E R")
 CALL line(5,1,80,xhor)
 CALL text(08,07,"Select a provider: ")
 CALL text(10,07,"Select template name(s): ")
 CALL text(14,07,"Relationship (Inclusive or Exclusive) - I/E: E")
#add_prompt1
 CALL clear(24,01,131)
 CALL text(24,01,"Enter the last name of the provider and press enter")
 SET accept = change
 CALL accept(08,30,"P(35);CU")
 SET v_provider_name = curaccept
 IF (v_provider_name=" ")
  EXECUTE then
  GO TO main_menu
 ENDIF
 SET v_provider_name = concat(trim(v_provider_name),"*")
 CALL text(18,03,v_provider_name)
 SET help =
 SELECT DISTINCT INTO "nl:"
  full_name = cnvtupper(p.name_full_formatted)
  FROM prsnl p
  WHERE cnvtupper(trim(p.name_full_formatted))=patstring(v_provider_name)
  ORDER BY p.name_full_formatted
  WITH maxqual(p,100), nocounter
 ;end select
 CALL accept(08,30,"A(35);CUF")
 SET v_provider_name = curaccept
 SET v_provider_name = cnvtupper(trim(v_provider_name))
 CALL text(19,03,v_provider_name)
#add_prompt2
 CALL clear(24,01,131)
 CALL text(24,01,"Select template names (Enter 0 for the last). Help is available <Shift><F5>")
 SET accept = scroll
 SET accept = change
 SET help =
 SELECT INTO "nl:"
  c.template_id, trim(c.template_name)
  FROM clinical_note_template c
  WHERE c.template_active_ind=1
  ORDER BY c.template_name
  WITH nocounter
 ;end select
 CALL accept(v_temp_line,v_temp_pos,"9(11)","0")
 CASE (curscroll)
  OF 0:
   CALL text(v_temp_line,v_temp_pos,cnvtstring(curaccept))
   IF (size(dts_add_request->templates,5)=v_temp_cnt)
    SET v_temp_cnt = (v_temp_cnt+ 1)
    SET stat = alterlist(dts_add_request->templates,v_temp_cnt)
    SET dts_add_request->templates[v_temp_cnt].id = curaccept
   ELSE
    SET dts_add_request->templates[v_temp_cnt].id = curaccept
   ENDIF
   SET v_temp_pos = (v_temp_pos+ 12)
   IF (cnvtstring(curaccept)="0")
    SET v_temp_cnt = (v_temp_cnt - 1)
    SET stat = alterlist(dts_add_request->templates,v_temp_cnt)
    CALL clear(v_temp_line,(v_temp_pos - 13),12)
    GO TO add_prompt3
   ELSE
    IF (v_temp_pos >= 70)
     SET v_temp_line = (v_temp_line+ 1)
     SET v_temp_pos = 7
    ENDIF
    GO TO add_prompt2
   ENDIF
  OF 1:
   GO TO add_prompt2
  OF 2:
   GO TO add_prompt2
  ELSE
   GO TO add_prompt2
 ENDCASE
#add_prompt3
 CALL clear(24,01,131)
 CALL text(24,02,"Exclusive - Updates a row; Inclusive - Adds a row")
 CALL accept(14,52,"P;CU","E"
  WHERE curaccept IN ("I", "E"))
 SET v_rel_type = curaccept
 CALL text(20,03,concat("Relationship Type = ",v_rel_type))
#correct_yn
 CALL clear(24,01,131)
 CALL text(24,2,"CORRECT? (Y/N/Q)  Y")
 CALL accept(24,20,"P;CU","Y"
  WHERE curaccept IN ("Y", "N", "Q"))
 IF (curaccept="N")
  GO TO add_menu
 ENDIF
 IF (curaccept="Q")
  GO TO main_menu
 ENDIF
#process_add
 SELECT INTO "nl:"
  p.person_id
  FROM prsnl p
  WHERE cnvtupper(trim(p.name_full_formatted))=v_provider_name
  DETAIL
   dts_add_request->prsnl_id = p.person_id
  WITH nocounter
 ;end select
 IF ((dts_add_request->prsnl_id > 0.0))
  CALL text(21,03,concat("person_id = ",cnvtstring(dts_add_request->prsnl_id)))
 ELSE
  CALL text(21,03,"person_id not found")
 ENDIF
 IF (v_rel_type="E")
  FOR (cnt = 1 TO v_temp_cnt)
   UPDATE  FROM clinical_note_template c
    SET c.prsnl_id = dts_add_request->prsnl_id
    WHERE (c.template_id=dts_add_request->templates[cnt].id)
    WITH nocounter
   ;end update
   CALL text(22,(cnt+ 10),concat(cnvtstring(dts_add_request->templates[cnt].id)))
  ENDFOR
 ELSE
  FOR (cnt = 1 TO v_temp_cnt)
    SET temp_cnt = 0
    SET template_id = 0
    SELECT INTO "nl:"
     c.template_id, c.long_blob_id, c.template_name,
     c.template_active_ind, c.owner_type_flag, c.smart_template_ind,
     c.smart_template_cd
     FROM clinical_note_template c
     WHERE (c.template_id=dts_add_request->templates[cnt].id)
     DETAIL
      temp_cnt = (temp_cnt+ 1), dts_add_template->long_blob_id = c.long_blob_id, dts_add_template->
      template_name = c.template_name,
      dts_add_template->template_active_ind = c.template_active_ind, dts_add_template->
      owner_type_flag = c.owner_type_flag, dts_add_template->smart_template_ind = c
      .smart_template_ind,
      dts_add_template->smart_template_cd = c.smart_template_cd
     WITH nocounter
    ;end select
    IF (temp_cnt=1)
     SELECT INTO "nl:"
      j = seq(reference_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       template_id = cnvtreal(j)
      WITH format, nocounter
     ;end select
     INSERT  FROM clinical_note_template nt
      SET nt.template_id = template_id, nt.template_name = dts_add_template->template_name, nt
       .template_active_ind = 1,
       nt.long_blob_id = dts_add_template->long_blob_id, nt.owner_type_flag = dts_add_template->
       owner_type_flag, nt.prsnl_id = dts_add_request->prsnl_id,
       nt.smart_template_ind = dts_add_template->smart_template_ind, nt.smart_template_cd =
       dts_add_template->smart_template_cd, nt.updt_dt_tm = cnvtdatetime(curdate,curtime),
       nt.updt_id = reqinfo->updt_id, nt.updt_task = reqinfo->updt_task, nt.updt_applctx = reqinfo->
       updt_applctx,
       nt.updt_cnt = 0
      WITH nocounter
     ;end insert
    ENDIF
  ENDFOR
 ENDIF
 GO TO main_menu
#remove_menu
 CALL clear(1,1)
 CALL video(n)
 SET v_temp_cnt = 0
 SET v_temp_line = 10
 SET v_temp_pos = 35
 SET v_rel_type = " "
 SET cnt = 0
 SET prsnl_id = 0
 CALL box(1,1,23,80)
 CALL text(3,15,"R E M O V E   T E M P L A T E S   FOR   A   P R O V I D E R")
 CALL line(5,1,80,xhor)
 CALL text(08,07,"Select a provider: ")
 CALL text(10,07,"Select template name(s): ")
#remove_prompt1
 CALL clear(24,01,131)
 CALL text(24,01,"Enter the last name of the provider and press enter")
 SET accept = change
 CALL accept(08,30,"P(35);CU")
 SET v_provider_name = curaccept
 IF (v_provider_name=" ")
  EXECUTE then
  GO TO main_menu
 ENDIF
 SET v_provider_name = concat(trim(v_provider_name),"*")
 SET help =
 SELECT DISTINCT INTO "nl:"
  full_name = cnvtupper(p.name_full_formatted)
  FROM prsnl p
  WHERE cnvtupper(trim(p.name_full_formatted))=patstring(v_provider_name)
  ORDER BY p.name_full_formatted
  WITH maxqual(p,100), nocounter
 ;end select
 CALL accept(08,30,"A(35);CUF")
 SET v_provider_name = curaccept
 SET v_provider_name = cnvtupper(trim(v_provider_name))
 SET prsnl_id = p.person_id
 CALL text(19,03,v_provider_name)
#remove_prompt2
 CALL clear(24,01,131)
 CALL text(24,01,"Select template (Enter 0 for the last).  Help is available <Shift><F5>")
 SET accept = scroll
 SET accept = change
 SET help =
 SELECT INTO "nl:"
  c.template_id, trim(c.template_name)
  FROM clinical_note_template c,
   prsnl p
  PLAN (p
   WHERE cnvtupper(trim(p.name_full_formatted))=patstring(v_provider_name))
   JOIN (c
   WHERE c.template_active_ind=1
    AND c.prsnl_id=p.person_id)
  ORDER BY c.template_name
  WITH nocounter
 ;end select
 CALL accept(v_temp_line,v_temp_pos,"9(11)")
 CASE (curscroll)
  OF 0:
   CALL text(v_temp_line,v_temp_pos,cnvtstring(curaccept))
   IF (size(dts_add_request->templates,5)=v_temp_cnt)
    SET v_temp_cnt = (v_temp_cnt+ 1)
    SET stat = alterlist(dts_add_request->templates,v_temp_cnt)
    SET dts_add_request->templates[v_temp_cnt].id = curaccept
   ELSE
    SET dts_add_request->templates[v_temp_cnt].id = curaccept
   ENDIF
   SET v_temp_pos = (v_temp_pos+ 12)
   IF (cnvtstring(curaccept)="0")
    SET v_temp_cnt = (v_temp_cnt - 1)
    SET stat = alterlist(dts_add_request->templates,v_temp_cnt)
    CALL clear(v_temp_line,(v_temp_pos - 13),12)
    GO TO remove_correct_yn
   ELSE
    IF (v_temp_pos >= 70)
     SET v_temp_line = (v_temp_line+ 1)
     SET v_temp_pos = 7
    ENDIF
    GO TO remove_prompt2
   ENDIF
  OF 1:
   GO TO remove_prompt2
  OF 2:
   GO TO remove_prompt2
  ELSE
   GO TO remove_prompt2
 ENDCASE
#remove_correct_yn
 CALL clear(24,01,131)
 CALL text(24,2,"CORRECT? (Y/N/Q)  Y")
 CALL accept(24,20,"P;CU","Y"
  WHERE curaccept IN ("Y", "N", "Q"))
 IF (curaccept="N")
  GO TO remove_menu
 ENDIF
 IF (curaccept="Q")
  GO TO main_menu
 ENDIF
#process_remove
 UPDATE  FROM clinical_note_template c
  SET c.prsnl_id = 0
  WHERE (c.template_id=dts_add_request->templates[cnt].id)
  WITH nocounter
 ;end update
 GO TO main_menu
#list_menu
 CALL clear(1,1)
 CALL video(n)
 CALL box(1,1,23,80)
 CALL text(3,15,"L I S T    T E M P L A T E S   OF   A   P R O V I D E R")
 CALL line(5,1,80,xhor)
 CALL text(08,07,"Select a provider: ")
#list_prompt1
 CALL clear(24,01,131)
 CALL text(24,01,"Enter the last name of the provider and press enter")
 SET accept = change
 CALL accept(08,30,"P(35);CU")
 SET v_provider_name = curaccept
 SET v_provider_name = concat(trim(v_provider_name),"*")
 CALL text(18,03,v_provider_name)
 SET help =
 SELECT DISTINCT INTO "nl:"
  full_name = cnvtupper(p.name_full_formatted)
  FROM prsnl p
  WHERE cnvtupper(trim(p.name_full_formatted))=patstring(v_provider_name)
  ORDER BY p.name_full_formatted
  WITH maxqual(p,100), nocounter
 ;end select
 CALL accept(08,30,"A(35);CUF")
 SET v_provider_name = curaccept
 SET v_provider_name = cnvtupper(trim(v_provider_name))
 CALL text(19,03,v_provider_name)
 SELECT INTO "nl:"
  p.person_id
  FROM prsnl p
  WHERE cnvtupper(trim(p.name_full_formatted))=v_provider_name
  DETAIL
   dts_add_request->prsnl_id = p.person_id
  WITH nocounter
 ;end select
 IF ((dts_add_request->prsnl_id > 0.0))
  CALL text(21,03,concat("person_id = ",cnvtstring(dts_add_request->prsnl_id)))
 ELSE
  CALL text(21,03,"person_id not found")
 ENDIF
 SELECT
  c.template_id, c.template_name
  FROM clinical_note_template c
  WHERE (c.prsnl_id=dts_add_request->prsnl_id)
  WITH nocounter
 ;end select
 GO TO main_menu
#end_program
 CALL clear(1,1)
END GO
