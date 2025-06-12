CREATE PROGRAM dm_stat_gather_switch:dba
 SET width = 132
 SET message = window
 DECLARE dsgs_flag = c3
 DECLARE dsgs_accept = c3
 DECLARE dsgs_err_msg = c132
 DECLARE dsgs_get_flag(null) = c1
 DECLARE dsgs_upt_flag(duf_flag) = null
 DECLARE dsgs_err(null) = null
 CALL clear(1,1)
 CALL box(1,1,3,132)
 CALL text(2,3,"SYSTEM AND DATABASE MONITORING FLAG")
 CALL text(4,3,"The current SYSTEM AND DATABASE MONITORING flag is:")
 SET dsgs_flag = dsgs_get_flag(null)
 CALL text(4,80,dsgs_flag)
 CALL text(6,3,"Is the above setting correct Yes/No?")
 CALL accept(6,80,"P;CUS","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  GO TO exit_script
 ENDIF
#accept
 CALL clear(6,1)
 SET help = fix("ON,OFF")
 CALL accept(4,80,"P(3);CUF","   "
  WHERE curaccept IN ("ON", "OFF"))
 SET dsgs_accept = curaccept
 SET help = off
 CALL text(6,3,"Is the above setting correct Yes/No?")
 CALL accept(6,80,"P;CUS","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  CALL dsgs_upt_flag(dsgs_accept)
 ELSEIF (curaccept="N")
  GO TO accept
 ENDIF
 SUBROUTINE dsgs_get_flag(null)
   SELECT INTO "nl:"
    d.info_char
    FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="DM_STAT_GATHER_OFF"
     AND d.info_char="Y"
    DETAIL
     dsgs_flag = "OFF"
    WITH nocounter
   ;end select
   CALL dsgs_err(null)
   IF (curqual=0)
    SET dsgs_flag = "ON"
   ENDIF
   RETURN(dsgs_flag)
 END ;Subroutine
 SUBROUTINE dsgs_upt_flag(duf_flag)
   IF (dsgs_flag != duf_flag)
    IF (dsgs_flag="ON"
     AND duf_flag="OFF")
     INSERT  FROM dm_info
      SET info_domain = "DATA MANAGEMENT", info_name = "DM_STAT_GATHER_OFF", info_char = "Y",
       info_date = cnvtdatetime(curdate,curtime3), updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end insert
     CALL dsgs_err(null)
    ELSEIF (dsgs_flag="OFF"
     AND duf_flag="ON")
     DELETE  FROM dm_info
      WHERE info_domain="DATA MANAGEMENT"
       AND info_name="DM_STAT_GATHER_OFF"
       AND info_char="Y"
      WITH nocounter
     ;end delete
     CALL dsgs_err(null)
    ENDIF
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE dsgs_err(null)
   IF (error(dsgs_err_msg,1) > 0)
    SET message = nowindow
    ROLLBACK
    EXECUTE dm_stat_error cnvtdatetime(curdate,curtime3), dsgs_err_msg, "DM_STAT_GATHER_SWITCH"
    CALL echo("*************************************************")
    CALL echo(dsgs_err_msg)
    CALL echo("*************************************************")
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
END GO
