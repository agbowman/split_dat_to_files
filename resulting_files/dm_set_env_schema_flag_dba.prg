CREATE PROGRAM dm_set_env_schema_flag:dba
 PAINT
 SET width = 132
 DECLARE dse_flag = c1
 SET dse_flag = "N"
 DECLARE dse_get_flag(dgf_desc,dgf_flag) = c1
 DECLARE dse_upt_flag(duf_desc,duf_flag) = null
 CALL clear(1,1)
 CALL box(1,1,3,132)
 CALL text(2,3,"SET ENVIRONMENT SCHEMA FLAG")
 CALL text(4,3,"Below are current environment settings:")
 SET dse_flag = dse_get_flag("INDEX UNRECOVERABLE FLAG","N")
 CALL text(5,3,"Index UNRECOVERABLE/NOLOGGING flag:")
 CALL text(5,50,dse_flag)
 CALL text(6,3,
  "Note: UNRECOVERABLE/NOLOGGING flag should only be off for database that is run in ARCHIVELOG mode."
  )
 CALL text(10,3,"Are the current environment settings correct?")
#accept
 CALL accept(10,65,"P;CUS","N"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  GO TO end_of_script
 ELSEIF (curaccept="N")
  CALL accept(5,50,"P;CU","N"
   WHERE curaccept IN ("Y", "N"))
  CALL dse_upt_flag("INDEX UNRECOVERABLE FLAG",curaccept)
  GO TO accept
 ENDIF
 SUBROUTINE dse_get_flag(dgf_desc,dgf_flag)
   SELECT INTO "nl:"
    d.info_char
    FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name=dgf_desc
    DETAIL
     IF (d.info_char="Y")
      dgf_flag = "Y"
     ELSEIF (d.info_char="N")
      dgf_flag = "N"
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL dse_upt_flag(dgf_desc,dgf_flag)
   ENDIF
   RETURN(dgf_flag)
 END ;Subroutine
 SUBROUTINE dse_upt_flag(duf_desc,duf_flag)
   UPDATE  FROM dm_info
    SET info_char = duf_flag, updt_dt_tm = cnvtdatetime(curdate,curtime)
    WHERE info_domain="DATA MANAGEMENT"
     AND info_name=duf_desc
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_info
     SET info_domain = "DATA MANAGEMENT", info_name = duf_desc, info_char = duf_flag,
      updt_dt_tm = cnvtdatetime(curdate,curtime)
     WITH nocounter
    ;end insert
   ENDIF
   COMMIT
 END ;Subroutine
#end_of_script
END GO
