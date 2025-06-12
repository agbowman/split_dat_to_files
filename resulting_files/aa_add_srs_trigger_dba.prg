CREATE PROGRAM aa_add_srs_trigger:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 RECORD tlist(
   1 qual[*]
     2 tbl_name = vc
     2 trig_name = vc
 )
 RECORD str(
   1 str = vc
   1 str2 = vc
 )
 SET tcnt = 1
 SET stat = alterlist(tlist->qual,tcnt)
 SET tlist->qual[tcnt].tbl_name = "PRSNL_SERVICE_RESOURCE_RELTN"
 SET tlist->qual[tcnt].trig_name = "TRG_SRS_INS_UPDT"
 FOR (cnt = 1 TO tcnt)
   SET str->str = concat("RDB ASIS('create or replace trigger ",tlist->qual[cnt].trig_name," ')")
   CALL echo(str->str)
   CALL parser(str->str)
   SET str->str = concat("ASIS(' after update or insert or delete on ",tlist->qual[cnt].tbl_name,
    " ')")
   CALL echo(str->str)
   CALL parser(str->str)
   SET str->str = "ASIS(' for each row begin ')"
   CALL echo(str->str)
   CALL parser(str->str)
   SET str->str = "ASIS(' update dm_info set ')"
   CALL echo(str->str)
   CALL parser(str->str)
   SET str->str = "ASIS(' info_date = sysdate, updt_dt_tm = sysdate, updt_cnt = updt_cnt + 1, ') "
   CALL echo(str->str)
   CALL parser(str->str)
   SET str->str2 = build("'",tlist->qual[cnt].tbl_name,"'")
   SET str->str = concat('ASIS(" info_char = ',str->str2,'")')
   CALL echo(str->str)
   CALL parser(str->str)
   SET str->str = "ASIS(^ where info_domain = 'SRS' ^)"
   CALL echo(str->str)
   CALL parser(str->str)
   SET str->str = "ASIS(^ and info_name = 'SRS UPDATE' ; ^)"
   CALL echo(str->str)
   CALL parser(str->str)
   SET str->str = "ASIS(' if sql%notfound then ')"
   CALL echo(str->str)
   CALL parser(str->str)
   SET str->str = "ASIS(' insert into dm_info ')"
   CALL echo(str->str)
   CALL parser(str->str)
   SET str->str =
   "ASIS(' (info_domain, info_name, info_char, info_date,  updt_dt_tm, updt_cnt) values ')"
   CALL echo(str->str)
   CALL parser(str->str)
   SET str->str = concat(^ASIS(" ('SRS', 'SRS UPDATE', ^,str->str2,', sysdate,  sysdate, 0); ")')
   CALL echo(str->str)
   CALL parser(str->str)
   SET str->str = "ASIS(' end if; end; ')"
   CALL echo(str->str)
   CALL parser(str->str)
   SET str->str = "end go "
   CALL echo(str->str)
   CALL parser(str->str)
 ENDFOR
 SET triggerqual = 0
 SELECT INTO "nl:"
  t.trigger_name
  FROM user_triggers t,
   (dummyt d  WITH seq = value(tcnt))
  PLAN (d)
   JOIN (t
   WHERE (t.trigger_name=tlist->qual[d.seq].trig_name))
  DETAIL
   triggerqual += 1
  WITH nocounter
 ;end select
 IF (triggerqual < tcnt)
  SET readme_data->status = "F"
  SET readme_data->message = "Not all triggers were found"
  CALL echo(build("FAILED:  Not all triggers were found.  Cnt:",triggerqual))
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Service Resource Security Create Trigger Completed"
  CALL echo("SUCCESS:  All triggers were found.")
 ENDIF
 EXECUTE dm_readme_status
END GO
