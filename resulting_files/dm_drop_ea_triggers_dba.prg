CREATE PROGRAM dm_drop_ea_triggers:dba
 DECLARE fill_trg(null) = i4
 DECLARE get_select_trg_name = null
 DECLARE o_drop_triggers(null) = i4
 DECLARE d_drop_triggers(null) = i4
 DECLARE trg_cnt = i4
 DECLARE row_cnt = i4
 DECLARE trg_status = c1
 SET v_drop_str = fillstring(255," ")
 SET trg_msg = fillstring(255," ")
 RECORD trg(
   1 tab[*]
     2 table_name = c32
     2 trigger_name = vc
     2 eains_trigger_name = vc
     2 eaupd_trigger_name = vc
     2 inactive_ind = i4
     2 qual[*]
       3 trg_c_exists = i2
       3 trg_reg_exists = i2
       3 trg_c_name = vc
       3 trg_reg_name = vc
       3 trg_eains_reg_name = vc
       3 trg_eains_reg_exists = i2
       3 trg_eains_c_name = vc
       3 trg_eains_c_exists = i2
       3 trg_eaupd_reg_name = vc
       3 trg_eaupd_reg_exists = i2
       3 trg_eaupd_c_exists = i2
       3 trg_eaupd_c_name = vc
 )
 IF ( NOT (fill_trg(null)))
  SET trg_status = "F"
  SET trg_msg = "Failure selecting table names"
  GO TO exit_script
 ENDIF
 CALL get_select_trg_name(null)
 IF (currdb="ORACLE")
  IF ( NOT (o_drop_triggers(null)))
   SET trg_status = "F"
   SET trg_msg = "Failure dropping triggers"
   GO TO exit_script
  ENDIF
 ELSEIF (currdb="DB2UDB")
  IF ( NOT (d_drop_triggers(null)))
   SET trg_status = "F"
   SET trg_msg = "Failure dropping triggers"
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE fill_trg(null)
  SELECT INTO "nl:"
   ea.table_name
   FROM dm_entity_activity_trigger ea
   ORDER BY ea.table_name
   HEAD REPORT
    tab_cnt = 0
   HEAD ea.table_name
    tab_cnt = (tab_cnt+ 1)
    IF (mod(tab_cnt,10)=1)
     stat = alterlist(trg->tab,(tab_cnt+ 9))
    ENDIF
    trg->tab[tab_cnt].table_name = cnvtupper(ea.table_name), trg->tab[tab_cnt].inactive_ind = 1
   FOOT REPORT
    stat = alterlist(trg->tab,tab_cnt)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE get_select_trg_name(null)
   SET cnt = 0
   DECLARE len = i4
   DECLARE trg_name = vc
   DECLARE t_name = vc
   FOR (x = 1 TO size(trg->tab,5))
     IF (currdb="ORACLE")
      SET trg->tab[x].trigger_name = cnvtupper(concat(trim(substring(1,28,concat(trim(substring(1,27,
             concat("TRG",trim(trg->tab[x].table_name,3))),3),"_EA")),3),"*"))
     ELSEIF (currdb="DB2UDB")
      SET len = textlen(trim(trg->tab[x].table_name,3))
      SET trg_name = concat("trg",trim(substring((len - 3),len,trg->tab[x].table_name),3),"_EA")
      SET trg->tab[x].trigger_name = cnvtupper(concat(trim(trg_name,3),"*"))
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE o_drop_triggers(null)
   FOR (x = 1 TO size(trg->tab,5))
     SELECT INTO "nl:"
      FROM user_triggers ut
      WHERE ut.trigger_name=patstring(trg->tab[x].trigger_name)
       AND ut.table_name=trim(trg->tab[x].table_name,3)
      ORDER BY ut.table_name
      HEAD REPORT
       cnt = 0
      HEAD ut.table_name
       cnt = (cnt+ 1), stat = alterlist(trg->tab[x].qual,cnt)
      DETAIL
       len = textlen(trim(ut.trigger_name,3)),
       CALL echo(ut.trigger_name)
       IF (substring((len - 1),2,trim(ut.trigger_name,3))="$C")
        trg->tab[x].qual[cnt].trg_c_exists = 1, trg->tab[x].qual[cnt].trg_c_name = ut.trigger_name
       ELSE
        trg->tab[x].qual[cnt].trg_reg_exists = 1, trg->tab[x].qual[cnt].trg_reg_name = ut
        .trigger_name
       ENDIF
      WITH nocounter
     ;end select
   ENDFOR
   FOR (tcnt = 1 TO size(trg->tab,5))
     FOR (cnt = 1 TO size(trg->tab[tcnt].qual,5))
      IF ((trg->tab[tcnt].qual[cnt].trg_c_exists=1))
       CALL parser(concat("rdb drop trigger ",trg->tab[tcnt].qual[cnt].trg_c_name," go"))
      ENDIF
      IF ((trg->tab[tcnt].qual[cnt].trg_reg_exists=1))
       CALL parser(concat("rdb drop trigger ",trg->tab[tcnt].qual[cnt].trg_reg_name," go"))
      ENDIF
     ENDFOR
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE d_drop_triggers(null)
   DECLARE trg_name = vc
   FOR (x = 1 TO size(trg->tab,5))
     SELECT INTO "nl:"
      FROM dm2_user_triggers ut
      WHERE ut.trigger_name=patstring(trg->tab[x].trigger_name)
       AND ut.table_name=trim(trg->tab[x].table_name,3)
      ORDER BY ut.table_name
      HEAD REPORT
       cnt = 0
      HEAD ut.table_name
       cnt = (cnt+ 1), stat = alterlist(trg->tab[x].qual,cnt)
      DETAIL
       len = textlen(trim(ut.trigger_name,3))
       IF (substring((len - 1),2,trim(ut.trigger_name,3))="$C")
        IF (substring((len - 7),6,trim(ut.trigger_name,3))="_EAINS")
         trg->tab[x].qual[cnt].trg_eains_c_exists = 1, trg->tab[x].qual[cnt].trg_eains_c_name = ut
         .trigger_name
        ELSEIF (substring((len - 7),6,trim(ut.trigger_name,3))="_EAUPD")
         trg->tab[x].qual[cnt].trg_eaupd_c_exists = 1, trg->tab[x].qual[cnt].trg_eaupd_c_name = ut
         .trigger_name
        ENDIF
       ELSE
        IF (substring((len - 5),6,trim(ut.trigger_name,3))="_EAINS")
         trg->tab[x].qual[cnt].trg_eains_reg_exists = 1, trg->tab[x].qual[cnt].trg_eains_reg_name =
         ut.trigger_name
        ELSEIF (substring((len - 5),6,trim(ut.trigger_name,3))="_EAUPD")
         trg->tab[x].qual[cnt].trg_eaupd_reg_exists = 1, trg->tab[x].qual[cnt].trg_eaupd_reg_name =
         ut.trigger_name
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
   ENDFOR
   FOR (tcnt = 1 TO size(trg->tab,5))
     FOR (cnt = 1 TO size(trg->tab[tcnt].qual,5))
       IF ((trg->tab[tcnt].qual[cnt].trg_eains_c_exists=1))
        CALL parser(concat("rdb drop trigger ",trg->tab[tcnt].qual[cnt].trg_eains_c_name," go"))
       ENDIF
       IF ((trg->tab[tcnt].qual[cnt].trg_eaupd_c_exists=1))
        CALL parser(concat("rdb drop trigger ",trg->tab[tcnt].qual[cnt].trg_eaupd_c_name," go"))
       ENDIF
       IF ((trg->tab[tcnt].qual[cnt].trg_eains_reg_exists=1))
        CALL parser(concat("rdb drop trigger ",trg->tab[tcnt].qual[cnt].trg_eains_reg_name," go"))
       ENDIF
       IF ((trg->tab[tcnt].qual[cnt].trg_eaupd_reg_exists=1))
        CALL parser(concat("rdb drop trigger ",trg->tab[tcnt].qual[cnt].trg_eaupd_reg_name," go"))
       ENDIF
     ENDFOR
   ENDFOR
   RETURN(1)
 END ;Subroutine
#exit_script
 CALL echo(build("Status:",trg_status))
 CALL echo(trg_msg)
 FREE RECORD trg
 FREE RECORD temp_trg
END GO
