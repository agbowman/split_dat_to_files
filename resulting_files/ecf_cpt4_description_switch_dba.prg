CREATE PROGRAM ecf_cpt4_description_switch:dba
 PAINT
 CALL video("R")
 CALL clear(1,1,80)
 CALL text(1,5,"CPT4 Short, Medim or Long String Utility")
 CALL video("N")
#pick_mode
 CALL text(3,10,"    PROGRAM OPTIONS              ")
 CALL text(5,10,"01  Short String                 ")
 CALL text(6,10,"02  Medium String                ")
 CALL text(7,10,"03  Long String                  ")
 CALL text(8,10,"99  EXIT PROGRAM                 ")
 CALL text(23,1,"Choose an option:")
 CALL accept(23,19,"99;",99
  WHERE curaccept IN (1, 2, 3, 99))
#restart
 CASE (curaccept)
  OF 1:
   EXECUTE FROM short_string TO short_string_exit
  OF 2:
   EXECUTE FROM medium_string TO medium_string_exit
  OF 3:
   EXECUTE FROM long_string TO long_string_exit
  OF 99:
   GO TO exit_program
 ENDCASE
 GO TO pick_mode
#short_string
 CALL viewwhereusedmsg(1)
 EXECUTE dm_dbimport "cer_install:cpt4_upd_syntax_st.csv", "kia_upd_term_syntax", 500,
 0
 CALL cpt4_dm_info_create(1)
 CALL viewwhereusedmsg(0)
#short_string_exit
#medium_string
 CALL viewwhereusedmsg(2)
 EXECUTE dm_dbimport "cer_install:cpt4_upd_syntax.csv", "kia_upd_term_syntax", 500,
 0
 CALL cpt4_dm_info_create(2)
 CALL viewwhereusedmsg(0)
#medium_string_exit
#long_string
 CALL viewwhereusedmsg(3)
 EXECUTE dm_dbimport "cer_install:cpt4_upd_syntax_lg.csv", "kia_upd_term_syntax", 500,
 0
 CALL cpt4_dm_info_create(3)
 CALL viewwhereusedmsg(0)
#long_string_exit
#exit_program
 SUBROUTINE cpt4_dm_info_create(x)
   DECLARE info_char_var = vc
   SELECT INTO "nl:"
    FROM dm_info d
    PLAN (d
     WHERE d.info_name="CPT4"
      AND d.info_domain="External Content Factory")
    DETAIL
     info_char_var = d.info_char
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info d
     SET d.info_domain = "External Content Factory", d.info_name = "CPT4", d.info_number = 1,
      d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = 15301
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
   IF (x=1)
    UPDATE  FROM dm_info d
     SET d.info_char = "SHORT", d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE d.info_domain="External Content Factory"
      AND d.info_name="CPT4"
     WITH nocounter
    ;end update
    COMMIT
   ELSEIF (x=2)
    UPDATE  FROM dm_info d
     SET d.info_char = "MEDIUM", d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE d.info_domain="External Content Factory"
      AND d.info_name="CPT4"
     WITH nocounter
    ;end update
    COMMIT
   ELSEIF (x=3)
    UPDATE  FROM dm_info d
     SET d.info_char = "LONG", d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE d.info_domain="External Content Factory"
      AND d.info_name="CPT4"
     WITH nocounter
    ;end update
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE viewwhereusedmsg(var)
   IF (var=1)
    CALL clear_screen(0)
    CALL text(4,3,"Executing the Short string...")
   ELSEIF (var=2)
    CALL clear_screen(0)
    CALL text(4,3,"Executing the Medium string...")
   ELSEIF (var=3)
    CALL clear_screen(0)
    CALL text(4,3,"Executing the Long string...")
   ELSE
    CALL clear_screen(0)
    CALL text(4,3,"Executed the command...")
    CALL text(23,1,"Press <Enter> to return to the main menu:")
    CALL accept(23,43,";","")
    CALL clear_screen(1)
    GO TO pick_mode
   ENDIF
 END ;Subroutine
 SUBROUTINE clear_screen(abc)
   IF (abc=0)
    CALL clear(3,1)
   ELSE
    CALL clear(1,1)
    CALL video("R")
    CALL clear(1,1,80)
    CALL text(1,5,"CPT4 Short, Medim or Long String Utility")
    CALL video("N")
   ENDIF
 END ;Subroutine
END GO
