CREATE PROGRAM bhs_rw_update_osd_defaults:dba
 RECORD work(
   1 field_cnt = i4
   1 fields[*]
     2 oe_format_id = f8
     2 order_sentence_id = f8
     2 start_dt_tm_seq = i4
     2 start_dt_tm_value = vc
     2 priority_seq = i4
     2 priority_value = vc
     2 priority_default_dt_tm = vc
     2 update_ind = i2
     2 error = i4
     2 err_msg = vc
 )
 SELECT INTO "NL:"
  os.oe_format_id, os.order_sentence_id, osd1.sequence,
  osd1.oe_field_display_value, osd2.sequence, osd2.oe_field_display_value,
  osd2.default_parent_entity_id, opf.oe_format_id, opf.priority_cd,
  opf.default_start_dt_tm
  FROM order_sentence_detail osd1,
   order_sentence os,
   order_sentence_detail osd2,
   dummyt d,
   order_priority_flexing opf
  PLAN (osd1
   WHERE osd1.oe_field_id=12620.00
    AND osd1.oe_field_display_value <= " ")
   JOIN (os
   WHERE osd1.order_sentence_id=os.order_sentence_id)
   JOIN (osd2
   WHERE outerjoin(os.order_sentence_id)=osd2.order_sentence_id
    AND osd2.oe_field_id=outerjoin(12657.00))
   JOIN (d)
   JOIN (opf
   WHERE os.oe_format_id=opf.oe_format_id
    AND osd2.default_parent_entity_id=opf.priority_cd)
  HEAD REPORT
   f_cnt = 0
  DETAIL
   f_cnt = (f_cnt+ 1), stat = alterlist(work->fields,f_cnt), work->fields[f_cnt].oe_format_id = os
   .oe_format_id,
   work->fields[f_cnt].order_sentence_id = os.order_sentence_id, work->fields[f_cnt].start_dt_tm_seq
    = osd1.sequence, work->fields[f_cnt].start_dt_tm_value = osd1.oe_field_display_value,
   work->fields[f_cnt].priority_seq = osd2.sequence, work->fields[f_cnt].priority_value = osd2
   .oe_field_display_value
   IF (opf.oe_format_id <= 0.00)
    work->fields[f_cnt].priority_default_dt_tm = "T;N"
   ELSE
    work->fields[f_cnt].priority_default_dt_tm = opf.default_start_dt_tm
   ENDIF
  FOOT REPORT
   work->field_cnt = f_cnt
  WITH outerjoin = d
 ;end select
 IF ((work->field_cnt <= 0))
  CALL echo("No blank 'Request Start Dt/Tm' fields found. Exitting Script")
  GO TO exit_script
 ENDIF
 DECLARE tmp_err = i4 WITH noconstant(0)
 DECLARE tmp_msg = vc WITH noconstant(" ")
 FOR (f = 1 TO work->field_cnt)
   SET tmp_err = 0
   SET tmp_msg = " "
   UPDATE  FROM order_sentence_detail osd
    SET osd.oe_field_display_value = work->fields[f].priority_default_dt_tm, osd.updt_dt_tm =
     cnvtdatetime(curdate,curtime3), osd.updt_id = 589892.00,
     osd.updt_cnt = (osd.updt_cnt+ 1)
    WHERE (osd.order_sentence_id=work->fields[f].order_sentence_id)
     AND (osd.sequence=work->fields[f].start_dt_tm_seq)
    WITH nocounter
   ;end update
   SET tmp_err = error(tmp_msg,0)
   IF (tmp_err != 0)
    SET work->fields[f].update_ind = - (1)
    SET work->fields[f].error = tmp_err
    SET work->fields[f].err_msg = tmp_msg
    ROLLBACK
   ELSE
    SET work->fields[f].update_ind = 1
    COMMIT
   ENDIF
 ENDFOR
#exit_script
 SELECT INTO "UPDATE_OSD_DEFAULTS.CSV"
  FROM (dummyt d  WITH seq = value(work->field_cnt))
  HEAD REPORT
   col 0, "OE_FORMAT_ID,ORDER_SENTENCE_ID,START_DT_TM_SEQ,START_DT_TM_VALUE,",
   "PRIORITY_SEQ,PRIORITY_VALUE,PRIORITY_DEFAULT_DT_TM,UPDATE_IND,ERROR,ERR_MSG"
  DETAIL
   row + 1, col 0,
   CALL print(build2(work->fields[d.seq].oe_format_id,",",work->fields[d.seq].order_sentence_id,",",
    work->fields[d.seq].start_dt_tm_seq,
    ",",'"',work->fields[d.seq].start_dt_tm_value,'",',work->fields[d.seq].priority_seq,
    ",",'"',work->fields[d.seq].priority_value,'",','"',
    work->fields[d.seq].priority_default_dt_tm,'",',work->fields[d.seq].update_ind,",",work->fields[d
    .seq].error,
    ",",'"',work->fields[d.seq].err_msg,'"'))
  WITH nocounter, nullreport, maxcol = 32000,
   maxrow = 1, formfeed = none, format = variable
 ;end select
END GO
