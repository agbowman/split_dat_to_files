CREATE PROGRAM da_rdm_core_filter_meanings:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Error beginning script da_rdm_core_filter_meanings."
 FREE SET omf_filters
 RECORD omf_filters(
   1 qual[*]
     2 meaning = vc
     2 cur_active = i2
     2 cur_core = i2
     2 new_active = i2
     2 new_core = i2
     2 found_on = vc
 )
 DECLARE flen = i4 WITH protect, noconstant(0)
 DECLARE fpos = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect
 DECLARE x = i4 WITH protect
 DECLARE errmsg = vc WITH protect
 DECLARE tc = i4 WITH protect
 SELECT INTO "nl:"
  FROM omf_filter_meaning m
  WHERE m.filter_meaning IS NOT null
   AND m.filter_meaning != " "
   AND ((m.core_ind != 1) OR (m.active_ind != 1))
  ORDER BY m.filter_meaning
  DETAIL
   fpos += 1
   IF (fpos > flen)
    flen += 200, stat = alterlist(omf_filters->qual,flen)
   ENDIF
   omf_filters->qual[fpos].meaning = m.filter_meaning, omf_filters->qual[fpos].cur_active = m
   .active_ind, omf_filters->qual[fpos].cur_core = m.core_ind,
   omf_filters->qual[fpos].new_active = m.active_ind, omf_filters->qual[fpos].new_core = m.core_ind
  FOOT REPORT
   flen = fpos, stat = alterlist(omf_filters->qual,flen)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error loading filter meanings: ",errmsg)
  GO TO end_now
 ENDIF
 DECLARE tbl_count = i4 WITH protect, noconstant(4)
 DECLARE filter_tables[4] = c30 WITH protect
 SET filter_tables[1] = "omf_indicator"
 SET filter_tables[2] = "omf_auth_attr"
 SET filter_tables[3] = "omf_cfgrn_item"
 SET filter_tables[4] = "omf_express_dictionary"
 DECLARE sel_clause = vc WITH protect
 DECLARE qual_clause = vc WITH protect
 DECLARE rptwriter = vc WITH protect
 SET sel_clause = 'select distinct into "nl:" x.filter_meaning from'
 SET rptwriter = concat("detail ",
  "stat = locateval(fpos, 1, flen, x.filter_meaning, omf_filters->qual[fpos]->meaning) ",
  "if (stat > 0) ","  tc = tc + 1 ","  omf_filters->qual[stat]->new_active = 1 ",
  "  omf_filters->qual[stat]->new_core = 1 ",
  "  omf_filters->qual[stat]->found_on = filter_tables[x] ","endif ","with nocounter go")
 FOR (x = 1 TO tbl_count)
   SET tc = 0
   CALL parser(concat(sel_clause," ",filter_tables[x]," x ",rptwriter))
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error reading from table ",filter_tables[x],": ",errmsg)
    GO TO end_now
   ENDIF
   CALL echo(concat("Found ",build(tc)," meanings on ",filter_tables[x]))
 ENDFOR
 SET tc = 0
 SELECT DISTINCT INTO "nl:"
  e.filter_meaning, e.active_ind
  FROM da_element e
  WHERE e.core_ind=1
  DETAIL
   stat = locateval(fpos,1,flen,e.filter_meaning,omf_filters->qual[fpos].meaning)
   IF (stat > 0)
    tc += 1, omf_filters->qual[stat].new_core = 1
    IF (e.active_ind=1
     AND (omf_filters->qual[stat].cur_active=0))
     omf_filters->qual[stat].new_active = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error reading from table DA_ELEMENT: ",errmsg)
  GO TO end_now
 ENDIF
 CALL echo(concat("Found ",build(tc)," meanings on DA_ELEMENT"))
 SET x = 0
 SET y = 0
 FOR (fpos = 1 TO flen)
   IF ((((omf_filters->qual[fpos].new_active != omf_filters->qual[fpos].cur_active)) OR ((omf_filters
   ->qual[fpos].new_core != omf_filters->qual[fpos].cur_core))) )
    UPDATE  FROM omf_filter_meaning m
     SET m.active_ind = omf_filters->qual[fpos].new_active, m.core_ind = omf_filters->qual[fpos].
      new_core, m.updt_cnt = (m.updt_cnt+ 1),
      m.updt_id = reqinfo->updt_id, m.updt_dt_tm = cnvtdatetime(sysdate), m.updt_applctx = reqinfo->
      updt_applctx,
      m.updt_task = reqinfo->updt_task
     WHERE (m.filter_meaning=omf_filters->qual[fpos].meaning)
     WITH nocounter
    ;end update
    IF (error(errmsg,0) != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Error updating filter meaning '",omf_filters->qual[fpos].
      meaning,"': ",errmsg)
     GO TO end_now
    ENDIF
    SET x += 1
   ENDIF
 ENDFOR
 CALL echo(concat("Updated ",build(x)," of ",build(size(omf_filters->qual,5))," filter meanings."))
 FREE RECORD omf_filters
 SET readme_data->status = "S"
 SET readme_data->message = "All filter meanings successfully updated."
#end_now
 IF ((readme_data->status="S"))
  CALL echo("Success; committing")
  COMMIT
 ELSE
  CALL echo("Script failure; rolling back")
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
