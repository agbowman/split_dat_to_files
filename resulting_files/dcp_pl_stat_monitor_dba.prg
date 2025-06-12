CREATE PROGRAM dcp_pl_stat_monitor:dba
 PAINT
 CALL video(n)
 DECLARE statvalue = i4 WITH noconstant(0)
 DECLARE statstring = c1 WITH noconstant("N")
 DECLARE initialize(null) = null
 DECLARE updatesettings(null) = null
 DECLARE displaysettings(null) = null
 DECLARE modifysettings(null) = null
 DECLARE modifystatistics(null) = null
 DECLARE confirmsettings(null) = null
 FREE RECORD request
 RECORD request(
   1 info_domain = c80
   1 info_name = c200
   1 info_date = dq8
   1 info_char = c255
   1 info_number = f8
   1 info_long_id = f8
 )
 FREE RECORD reply
 RECORD reply(
   1 error_ind = i4
   1 error_msg = c255
 )
 CALL initialize(null)
 CALL displaysettings(null)
 CALL clear(1,1)
 SUBROUTINE initialize(null)
   SET reqinfo->updt_id = 0.0
   SET reqinfo->updt_applctx = 0
   SET reqinfo->updt_task = 0
   SET request->info_domain = "PATIENT_LIST"
   SET request->info_name = "STATISTICS"
   SET request->info_number = 0.0
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="PATIENT_LIST"
     AND d.info_name="STATISTICS"
    DETAIL
     statvalue = cnvtint(d.info_number)
    WITH nocounter
   ;end select
   IF (statvalue=1)
    SET statstring = "Y"
   ELSE
    SET statstring = "N"
   ENDIF
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE p.username="SYSTEM"
     AND p.name_last_key="SYSTEM"
     AND p.name_first_key="SYSTEM"
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    DETAIL
     reqinfo->updt_id = p.person_id
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE updatesettings(null)
   SET request->info_domain = "PATIENT_LIST"
   SET request->info_name = "STATISTICS"
   SET request->info_number = cnvtreal(statvalue)
   EXECUTE dm_ins_upt_dm_info
   COMMIT
   CALL displaysettings(null)
 END ;Subroutine
 SUBROUTINE displaysettings(null)
   CALL clear(1,1)
   CALL box(2,1,23,80)
   CALL text(1,25,"Patient List Maintenance Tool")
   CALL text(06,10,"1) Gather Patient List Statistics: ")
   CALL text(06,50,statstring)
   CALL text(24,04,"Choice (M)odify, (Q)uit")
   CALL accept(24,28,"p(1);cu")
   SET usr_choice = curaccept
   CASE (usr_choice)
    OF "M":
     CALL modifysettings(null)
    OF "Q":
     SET usr_choice = "Q"
    ELSE
     CALL displaysettings(null)
   ENDCASE
 END ;Subroutine
 SUBROUTINE modifysettings(null)
   CALL modifystatistics(null)
 END ;Subroutine
 SUBROUTINE modifystatistics(null)
   CALL clear(24,1)
   CALL accept(06,50,"p(1);cus",statstring)
   SET accept_val = curaccept
   IF (accept_val="Y")
    SET statstring = accept_val
    SET statvalue = 1
    CALL confirmsettings(null)
   ELSEIF (accept_val="N")
    SET statstring = accept_val
    SET statvalue = 0
    CALL confirmsettings(null)
   ELSE
    CALL modifystatistics(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE confirmsettings(null)
   CALL text(06,50,statstring)
   CALL text(24,04,"Correct (Y)es, (N)o")
   CALL accept(24,32,"p(1);cu")
   SET usr_choice = curaccept
   CASE (usr_choice)
    OF "Y":
     CALL updatesettings(null)
    OF "N":
     CALL modifysettings(null)
    ELSE
     CALL confirmsettings(null)
   ENDCASE
 END ;Subroutine
END GO
