CREATE PROGRAM delete_tool:dba
 PAINT
 SET modify = system
 SET width = 132
#1000_start
 CALL video(r)
 CALL box(1,1,8,132)
 CALL box(1,1,4,132)
 CALL clear(2,2,130)
 CALL text(02,40," DELETE TOOL")
 CALL clear(3,2,130)
 CALL video(n)
 CALL text(05,05,"Delete (T)able, (P)erson, or (E)ncounter:  ")
 CALL accept(05,48,"A;CU"
  WHERE curaccept IN ("T", "P", "E", "A", "Q"))
 SET tool_option = curaccept
 SET valid_table = "N"
 CASE (tool_option)
  OF "T":
   SET title = "DELETE TABLE TOOL"
   SET caption = "Table Name:"
  OF "P":
   SET title = "DELETE PERSON TOOL"
   SET caption = "Person Id:"
   CALL clear(24,1)
   CALL video(n)
   CALL text(24,2,"HELP AVAILABLE")
   SET help =
   SELECT
    p.person_id, p.name_last_key, p.name_first_key
    FROM person p
    WHERE p.name_last_key >= curaccept
    ORDER BY p.name_last_key, p.name_first_key
    WITH nocounter
   ;end select
  OF "E":
   SET title = "DELETE ENCNTR TOOL"
   SET caption = "Encntr Id:"
   CALL clear(24,1)
   CALL video(n)
   CALL text(24,2,"HELP AVAILABLE")
   SET help =
   SELECT
    e.encntr_id, p.name_last_key, p.name_first_key
    FROM encounter e,
     person p
    PLAN (e)
     JOIN (p
     WHERE p.name_last_key >= curaccept
      AND p.person_id=e.person_id)
   ;end select
  OF "A":
   SET title = "DEFINED TABLES DELETE"
   SET caption = "Password:"
  OF "Q":
   GO TO end_program
 ENDCASE
 CALL video(r)
 CALL box(1,1,8,132)
 CALL box(1,1,4,132)
 CALL clear(2,2,130)
 CALL clear(3,2,130)
 CALL text(02,40,title)
 CALL video(n)
 CALL text(06,05,caption)
 CALL accept(06,17,"P(31);CUP")
 SET help = off
 CALL text(23,01," ")
 CASE (tool_option)
  OF "T":
   SET table_name = concat(trim(curaccept,1))
   EXECUTE FROM 3000_delete_table TO 3099_delete_table_exit
  OF "P":
   SET person_id = cnvtint(curaccept)
   EXECUTE FROM 3000_delete_person TO 3099_delete_person_exit
  OF "E":
   SET encntr_id = cnvtint(curaccept)
   EXECUTE FROM 3000_delete_encounter TO 3099_delete_encounter_exit
  OF "A":
   IF (curaccept="QUONSET")
    EXECUTE FROM 3000_delete_all TO 3099_delete_all_exit
   ELSE
    GO TO end_program
   ENDIF
 ENDCASE
 EXECUTE FROM 4000_commit_yn TO 4099_commit_yn_exit
 EXECUTE FROM 4000_continue_yn TO 4099_continue_yn_exit
 GO TO end_program
#3000_delete_table
 EXECUTE FROM 5000_load_valid_tables TO 5099_load_valid_tables_exit
 FOR (x = 1 TO nbr_of_valid_tables)
   IF ((table_name=tables[x]))
    SET valid_table = "Y"
   ENDIF
 ENDFOR
 IF (valid_table="N")
  CALL text(10,02,"%ERROR - Invalid table name")
  GO TO 4000_continue_yn
 ENDIF
 SET parser_buffer[10] = fillstring(132," ")
 SET parser_buffer[1] = "DELETE FROM"
 SET parser_buffer[2] = table_name
 SET parser_buffer[3] = "T"
 SET parser_buffer[4] = "WHERE T.UPDT_CNT >= 0"
 SET parser_buffer[5] = "GO"
 FOR (x = 1 TO 5)
   CALL parser(parser_buffer[x])
 ENDFOR
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from ",table_name)
 CALL text(10,02,msg_lne)
#3099_delete_table_exit
#3000_delete_person
 DELETE  FROM person_name p
  WHERE p.person_id=person_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from PERSON_NAME")
 CALL text(10,02,msg_lne)
 DELETE  FROM person_alias p
  WHERE p.person_id=person_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from PERSON_ALIAS")
 CALL text(11,02,msg_lne)
 DELETE  FROM person_patient p
  WHERE p.person_id=person_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from PERSON_PATIENT")
 CALL text(12,02,msg_lne)
 DELETE  FROM person_person_reltn p
  WHERE p.person_id=person_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from PERSON_PERSON_RELTN")
 CALL text(13,02,msg_lne)
 DELETE  FROM person_prsnl_reltn p
  WHERE p.person_id=person_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from PERSON_PRSNL_RELTN")
 CALL text(14,02,msg_lne)
 DELETE  FROM person_info p
  WHERE p.person_id=person_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from PERSON_INFO")
 CALL text(15,02,msg_lne)
 DELETE  FROM person_matches p
  WHERE ((p.a_person_id=person_id) OR (p.b_person_id=person_id))
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from PERSON_MATCHES")
 CALL text(16,02,msg_lne)
 DELETE  FROM person_combine p
  WHERE ((p.from_person_id=person_id) OR (p.to_person_id=person_id))
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from PERSON_COMBINE")
 CALL text(17,02,msg_lne)
 DELETE  FROM address a
  WHERE a.parent_entity_id=person_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from ADDRESS")
 CALL text(18,02,msg_lne)
 DELETE  FROM phone p
  WHERE p.parent_entity_id=person_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from PHONE")
 CALL text(19,02,msg_lne)
 DELETE  FROM person p
  WHERE p.person_id=person_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from PERSON")
 CALL text(20,02,msg_lne)
#3099_delete_person_exit
#3000_delete_encounter
 DELETE  FROM encntr_alias e
  WHERE e.encntr_id=encntr_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from ENCNTR_ALIAS")
 CALL text(10,02,msg_lne)
 DELETE  FROM encntr_domain e
  WHERE e.encntr_id=encntr_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from ENCNTR_DOMAIN")
 CALL text(11,02,msg_lne)
 DELETE  FROM encntr_accident e
  WHERE e.encntr_id=encntr_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from ENCNTR_ACCIDENT")
 CALL text(12,02,msg_lne)
 DELETE  FROM encntr_loc_hist e
  WHERE e.encntr_id=encntr_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from ENCNTR_LOC_HIST")
 CALL text(13,02,msg_lne)
 DELETE  FROM encntr_prsnl_reltn e
  WHERE e.encntr_id=encntr_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from ENCNTR_PRSNL_RELTN")
 CALL text(14,02,msg_lne)
 DELETE  FROM encntr_info e
  WHERE e.encntr_id=encntr_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from ENCNTR_INFO")
 CALL text(15,02,msg_lne)
 DELETE  FROM encntr_org_reltn e
  WHERE e.encntr_id=encntr_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from ENCNTR_ORG_RELTN")
 CALL text(16,02,msg_lne)
 DELETE  FROM encntr_person_reltn e
  WHERE e.encntr_id=encntr_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from ENCNTR_PERSON_RELTN")
 CALL text(17,02,msg_lne)
 DELETE  FROM encntr_plan_reltn e
  WHERE e.encntr_id=encntr_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from ENCNTR_PLAN_RELTN")
 CALL text(18,02,msg_lne)
 DELETE  FROM diagnosis e
  WHERE e.encntr_id=encntr_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from DIAGNOSIS")
 CALL text(19,02,msg_lne)
 DELETE  FROM allergy e
  WHERE e.encntr_id=encntr_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from ALLERGY")
 CALL text(20,02,msg_lne)
 DELETE  FROM procedure e
  WHERE e.encntr_id=encntr_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from PROCEDURE")
 CALL text(21,02,msg_lne)
 DELETE  FROM encounter e
  WHERE e.encntr_id=encntr_id
 ;end delete
 SET qualifiers = cnvtstring(curqual)
 SET msg_lne = concat("Deleted ",trim(qualifiers,1)," record(s) from ENCOUNTER")
 CALL text(22,02,msg_lne)
#3099_delete_encounter_exit
#3000_delete_all
 SET line_number = 10
 SET row_number = 2
 EXECUTE FROM 5000_load_valid_tables TO 5099_load_valid_tables_exit
 FOR (x = 1 TO nbr_of_valid_tables)
   SET table_name = tables[x]
   SET msg_lne = concat("Deleting all rows from ",table_name)
   IF (line_number > 22)
    SET line_number = 10
    SET row_number = 50
   ENDIF
   CALL text(line_number,row_number,msg_lne)
   SET line_number = (line_number+ 1)
   SET parser_buffer[10] = fillstring(132," ")
   SET parser_buffer[1] = "DELETE FROM"
   SET parser_buffer[2] = table_name
   SET parser_buffer[3] = "T"
   SET parser_buffer[4] = "WHERE T.UPDT_CNT >= 0"
   SET parser_buffer[5] = "GO"
   FOR (y = 1 TO 5)
     CALL parser(parser_buffer[y])
   ENDFOR
 ENDFOR
#3099_delete_all_exit
#4000_clear_screen
 FOR (x = 1 TO 24)
   CALL clear(x,1,132)
 ENDFOR
#4099_clear_screen_exit
#4000_commit_yn
 CALL text(24,02,"COMMIT   (Y/N)")
 CALL accept(24,17,"A;CU"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
#4099_commit_yn_exit
#4000_continue_yn
 CALL text(24,02,"CONTINUE (Y/N)")
 CALL accept(24,17,"A;CU"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  EXECUTE FROM 4000_clear_screen TO 4099_clear_screen_exit
  GO TO 1000_start
 ELSE
  GO TO end_program
 ENDIF
#4099_continue_yn_exit
#5000_load_valid_tables
 SET tables[50] = fillstring(32," ")
 SET tables[01] = "ENCNTR_ALIAS"
 SET tables[02] = "ENCNTR_DOMAIN"
 SET tables[03] = "ENCNTR_ACCIDENT"
 SET tables[04] = "ENCNTR_LOC_HIST"
 SET tables[05] = "ENCNTR_PRSNL_RELTN"
 SET tables[06] = "ENCOUNTER"
 SET tables[07] = "PRSNL_ALIAS"
 SET tables[08] = "PRSNL"
 SET tables[09] = "PHONE"
 SET tables[10] = "ADDRESS"
 SET tables[11] = "PERSON_ALIAS"
 SET tables[12] = "PERSON_NAME"
 SET tables[13] = "PERSON_PATIENT"
 SET tables[14] = "PERSON_PERSON_RELTN"
 SET tables[15] = "PERSON_PRSNL_RELTN"
 SET tables[16] = "PERSON_INFO"
 SET tables[17] = "PERSON_LINK"
 SET tables[18] = "PERSON_MATCHES"
 SET tables[19] = "PERSON_COMBINE_DET"
 SET tables[20] = "PERSON_COMBINE"
 SET tables[21] = "PERSON"
 SET nbr_of_valid_tables = 21
#5099_load_valid_tables_exit
#end_program
END GO
