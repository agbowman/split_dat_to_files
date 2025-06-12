CREATE PROGRAM dm_active_ind_trigger:dba
 SET dai_tbl_name = "ALLTABLES"
 RECORD str(
   1 str = vc
 )
 FREE RECORD tlist
 RECORD tlist(
   1 tlist_cnt = i4
   1 qual[*]
     2 tname = vc
     2 short_tname = vc
 ) WITH persistscript
 SELECT
  IF (dai_tbl_name="ALLTABLES")
   FROM user_tab_columns utc1,
    user_tab_columns utc2,
    user_tab_columns utc3,
    user_tab_columns utc4,
    user_tables u,
    dm_tables_doc d
   PLAN (u)
    JOIN (d
    WHERE d.table_name=u.table_name
     AND d.drop_ind=0)
    JOIN (utc1
    WHERE utc1.table_name=d.table_name
     AND utc1.column_name="ACTIVE_IND")
    JOIN (utc2
    WHERE utc2.table_name=utc1.table_name
     AND utc2.column_name="ACTIVE_STATUS_DT_TM"
     AND utc2.data_type="DATE")
    JOIN (utc3
    WHERE utc3.table_name=utc1.table_name
     AND utc3.column_name="ACTIVE_STATUS_PRSNL_ID"
     AND utc3.data_type IN ("NUMBER", "FLOAT"))
    JOIN (utc4
    WHERE utc4.table_name=utc1.table_name
     AND utc4.column_name="UPDT_ID"
     AND utc4.data_type IN ("NUMBER", "FLOAT"))
   ORDER BY utc1.table_name
  ELSEIF (dai_tbl_name="OCDMODE")
   FROM user_tab_columns utc1,
    user_tab_columns utc2,
    user_tab_columns utc3,
    user_tab_columns utc4,
    dm_afd_tables a,
    dm_tables_doc d
   PLAN (a
    WHERE a.alpha_feature_nbr=ai_ocd_nbr)
    JOIN (d
    WHERE d.table_name=a.table_name
     AND d.drop_ind=0)
    JOIN (utc1
    WHERE utc1.column_name="ACTIVE_IND"
     AND utc1.table_name=d.table_name)
    JOIN (utc2
    WHERE utc2.table_name=utc1.table_name
     AND utc2.column_name="ACTIVE_STATUS_DT_TM"
     AND utc2.data_type="DATE")
    JOIN (utc3
    WHERE utc3.table_name=utc1.table_name
     AND utc3.column_name="ACTIVE_STATUS_PRSNL_ID"
     AND utc3.data_type IN ("NUMBER", "FLOAT"))
    JOIN (utc4
    WHERE utc4.table_name=utc1.table_name
     AND utc4.column_name="UPDT_ID"
     AND utc4.data_type IN ("NUMBER", "FLOAT"))
   ORDER BY utc1.table_name
  ELSE
   FROM user_tab_columns utc1,
    user_tab_columns utc2,
    user_tab_columns utc3,
    user_tab_columns utc4,
    user_tables u,
    dm_tables_doc d
   PLAN (u
    WHERE u.table_name=patstring(dai_tbl_name))
    JOIN (d
    WHERE d.table_name=u.table_name
     AND d.drop_ind=0)
    JOIN (utc1
    WHERE utc1.table_name=d.table_name
     AND utc1.column_name="ACTIVE_IND")
    JOIN (utc2
    WHERE utc2.table_name=utc1.table_name
     AND utc2.column_name="ACTIVE_STATUS_DT_TM"
     AND utc2.data_type="DATE")
    JOIN (utc3
    WHERE utc3.table_name=utc1.table_name
     AND utc3.column_name="ACTIVE_STATUS_PRSNL_ID"
     AND utc3.data_type IN ("NUMBER", "FLOAT"))
    JOIN (utc4
    WHERE utc4.table_name=utc1.table_name
     AND utc4.column_name="UPDT_ID"
     AND utc4.data_type IN ("NUMBER", "FLOAT"))
   ORDER BY utc1.table_name
  ENDIF
  INTO "nl:"
  utc1.table_name
  DETAIL
   tlist->tlist_cnt = (tlist->tlist_cnt+ 1), stat = alterlist(tlist->qual,tlist->tlist_cnt), tlist->
   qual[tlist->tlist_cnt].tname = utc1.table_name,
   tlist->qual[tlist->tlist_cnt].short_tname = trim(substring(1,27,utc1.table_name))
  WITH nocounter, formfeed = none
 ;end select
 IF ((tlist->tlist_cnt > 0))
  SET str->str = concat("RDB ASIS('create or replace procedure dm_get_date",
   "(new_date IN date,old_date IN date,current_date OUT date) ') ")
  CALL echo(str->str)
  CALL parser(str->str)
  SET str->str = "ASIS(' as begin ') "
  CALL echo(str->str)
  CALL parser(str->str)
  SET str->str = "ASIS('  if (new_date is null or new_date=old_date) then ') "
  CALL echo(str->str)
  CALL parser(str->str)
  SET str->str = "ASIS('     select sysdate into current_date from dual; ') "
  CALL echo(str->str)
  CALL parser(str->str)
  SET str->str = "ASIS('  else ') "
  CALL echo(str->str)
  CALL parser(str->str)
  SET str->str = "ASIS('     current_date:=new_date; ') "
  CALL echo(str->str)
  CALL parser(str->str)
  SET str->str = "ASIS('  end if; ') "
  CALL echo(str->str)
  CALL parser(str->str)
  SET str->str = "ASIS(' end; ') "
  CALL echo(str->str)
  CALL parser(str->str)
  SET str->str = "end go "
  CALL echo(str->str)
  CALL parser(str->str,1)
 ENDIF
 FOR (i = 1 TO tlist->tlist_cnt)
   SET str->str = concat("RDB ASIS(' create or replace trigger trg",tlist->qual[i].short_tname," ') "
    )
   CALL echo(str->str)
   CALL parser(str->str)
   SET str->str = concat("ASIS(' before update of active_ind on ",tlist->qual[i].tname," ') ")
   CALL echo(str->str)
   CALL parser(str->str)
   SET str->str = "ASIS(' for each row when (OLD.active_ind <> NEW.active_ind) ') "
   CALL echo(str->str)
   CALL parser(str->str)
   SET str->str = "ASIS(' BEGIN ') "
   CALL echo(str->str)
   CALL parser(str->str)
   SET str->str = "ASIS('  :NEW.active_status_prsnl_id := :NEW.updt_id; ') "
   CALL echo(str->str)
   CALL parser(str->str)
   SET str->str =
   "ASIS('  dm_get_date(:new.active_status_dt_tm, :old.active_status_dt_tm, :new.active_status_dt_tm); ') "
   CALL echo(str->str)
   CALL parser(str->str)
   SET str->str = "ASIS(' END; ') "
   CALL echo(str->str)
   CALL parser(str->str)
   SET str->str = "end go "
   CALL echo(str->str)
   CALL parser(str->str,1)
 ENDFOR
END GO
