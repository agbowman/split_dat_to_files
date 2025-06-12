CREATE PROGRAM dm_cmb_chk_missing_rows:dba
 SET dm_cmb_parent =  $1
 SET combine_id =  $2
 FREE SET rcmbcheck
 RECORD rcmbcheck(
   1 qual[*]
     2 table_name = c32
     2 pk_name = c32
   1 notexist[*]
     2 table_name = c32
     2 pk_id = f8
     2 combine_id = f8
     2 combine_dt_tm = dq8
     2 combine_det_id = f8
     2 from_id = f8
     2 to_id = f8
     2 pk_name = c32
 )
 IF (cnvtupper(dm_cmb_parent)="PERSON")
  SET dm_cmb = "PERSON_COMBINE"
  SET dm_cmb_det = "PERSON_COMBINE_DET"
  SET dm_cmb_id = "PERSON_COMBINE_ID"
  SET dm_cmb_det_id = "PERSON_COMBINE_DET_ID"
  SET dm_abb = "PERSON_ID"
 ELSEIF (cnvtupper(dm_cmb_parent)="ENCOUNTER")
  SET dm_cmb = "ENCNTR_COMBINE"
  SET dm_cmb_det = "ENCNTR_COMBINE_DET"
  SET dm_cmb_id = "ENCNTR_COMBINE_ID"
  SET dm_cmb_det_id = "ENCNTR_COMBINE_DET_ID"
  SET dm_abb = "ENCNTR_ID"
 ELSEIF (cnvtupper(dm_cmb_parent)="LOCATION")
  SET dm_cmb = "LOC_COMBINE"
  SET dm_cmb_det = "LOC_COMBINE_DET"
  SET dm_cmb_id = "LOC_COMBINE_ID"
  SET dm_cmb_det_id = "LOC_COMBINE_DET_ID"
  SET dm_abb = "LOC_CD"
 ELSEIF (cnvtupper(dm_cmb_parent)="ORGANIZATION")
  SET dm_cmb = "ORG_COMBINE"
  SET dm_cmb_det = "ORG_COMBINE_DET"
  SET dm_cmb_id = "ORG_COMBINE_ID"
  SET dm_cmb_det_id = "ORG_COMBINE_DET_ID"
  SET dm_abb = "ORG_ID"
 ELSEIF (cnvtupper(dm_cmb_parent)="HEALTH_PLAN")
  SET dm_cmb = "HP_COMBINE"
  SET dm_cmb_det = "HP_COMBINE_DET"
  SET dm_cmb_id = "HP_COMBINE_ID"
  SET dm_abb = "HP_ID"
  SET dm_cmb_det_id = "HP_COMBINE_DET_ID"
 ENDIF
 SET entitycount = 0
 SET parser_buffer[21] = fillstring(132," ")
 SET parser_buffer[1] = "select distinct into 'nl:' dcd.entity_name"
 SET parser_buffer[2] = concat("from ",dm_cmb_det," dcd")
 IF (combine_id != 0)
  SET parser_buffer[3] = concat("where dcd.active_ind = 1 and dcd.",dm_cmb_id," = ",build(combine_id)
   )
 ELSE
  SET parser_buffer[3] = concat("where dcd.active_ind = 1")
 ENDIF
 SET parser_buffer[4] = 'and dcd.entity_name not in ("CHARGE", "CHARGE_MOD", "PERSON_MATCHES")'
 SET parser_buffer[5] = "detail"
 SET parser_buffer[6] = "entitycount = entitycount + 1"
 SET parser_buffer[7] = "stat = alterlist(rCmbCheck->qual, entitycount)"
 SET parser_buffer[8] = "rCmbCheck->qual[entitycount]->table_name = dcd.entity_name"
 SET parser_buffer[9] = "with nocounter go"
 FOR (call_buffer = 1 TO 9)
   CALL parser(parser_buffer[call_buffer])
 ENDFOR
 SELECT INTO "nl:"
  d.seq
  FROM dm_user_cons_columns dccc,
   (dummyt d  WITH seq = value(entitycount))
  PLAN (d)
   JOIN (dccc
   WHERE (dccc.table_name=rcmbcheck->qual[d.seq].table_name)
    AND dccc.constraint_type="P"
    AND dccc.position=1)
  DETAIL
   rcmbcheck->qual[d.seq].pk_name = dccc.column_name
  WITH nocounter
 ;end select
 SET notexistcount = 0
 FOR (buffer_cnt = 1 TO entitycount)
   FOR (x = 1 TO 21)
     SET parser_buffer[x] = fillstring(132," ")
   ENDFOR
   SET parser_buffer[1] = concat("select into 'nl:' dcd.",dm_cmb_det_id)
   SET parser_buffer[2] = concat("from ",dm_cmb_det," dcd, ",dm_cmb," dc")
   SET parser_buffer[3] = concat("where dcd.",dm_cmb_id," = dc.",dm_cmb_id)
   SET parser_buffer[4] =
   "and dcd.active_ind = 1 and dcd.entity_name = rCmbCheck->qual[buffer_cnt]->table_name"
   IF (combine_id != 0)
    SET parser_buffer[5] = concat("and dcd.",dm_cmb_id," = ",build(combine_id))
   ENDIF
   SET parser_buffer[6] = "and not exists"
   SET parser_buffer[7] = "(select 'x'"
   SET parser_buffer[8] = concat("from ",rcmbcheck->qual[buffer_cnt].table_name," ct")
   SET parser_buffer[9] = concat("where dcd.entity_id = ct.",rcmbcheck->qual[buffer_cnt].pk_name,")")
   SET parser_buffer[10] = "detail"
   SET parser_buffer[11] = "notexistcount = notexistcount + 1"
   SET parser_buffer[12] = "stat = alterlist(rCmbCheck->notexist, notexistcount)"
   SET parser_buffer[13] = "rCmbCheck->notexist[notexistcount]->table_name = dcd.entity_name"
   SET parser_buffer[14] = "rCmbCheck->notexist[notexistcount]->pk_id = dcd.entity_id"
   SET parser_buffer[15] =
   "rCmbCheck->notexist[notexistcount]->pk_name = rCmbCheck->qual[buffer_cnt]->pk_name"
   SET parser_buffer[16] = concat("rCmbCheck->notexist[notexistcount]->combine_id = dcd.",dm_cmb_id)
   SET parser_buffer[17] = concat("rCmbCheck->notexist[notexistcount]->combine_det_id = dcd.",build(
     dm_cmb_det_id))
   SET parser_buffer[18] = concat("rCmbCheck->notexist[notexistcount]->from_id = dc.from_",dm_abb)
   SET parser_buffer[19] = concat("rCmbCheck->notexist[notexistcount]->to_id = dc.to_",dm_abb)
   SET parser_buffer[20] = "rCmbCheck->notexist[notexistcount]->combine_dt_tm = dc.updt_dt_tm"
   SET parser_buffer[21] = "with nocounter go"
   FOR (call_buffer = 1 TO 21)
     CALL parser(parser_buffer[call_buffer])
   ENDFOR
 ENDFOR
 SELECT
  combine_type = dm_cmb_parent, combine_id_r = rcmbcheck->notexist[d.seq].combine_id, from_id =
  rcmbcheck->notexist[d.seq].from_id,
  to_id = rcmbcheck->notexist[d.seq].to_id, combine_dt_tm = rcmbcheck->notexist[d.seq].combine_dt_tm,
  combine_det_id = rcmbcheck->notexist[d.seq].combine_det_id,
  entity_name = trim(rcmbcheck->notexist[d.seq].table_name), pk_id = rcmbcheck->notexist[d.seq].pk_id,
  pk_name = trim(rcmbcheck->notexist[d.seq].pk_name)
  FROM (dummyt d  WITH seq = value(notexistcount))
  PLAN (d)
  ORDER BY combine_id_r, from_id, to_id,
   combine_det_id, entity_name, pk_id
  HEAD PAGE
   col 0, "MISSING ", dm_cmb_parent,
   " COMBINE ROWS REPORT", row + 1, col 0,
   "=======================================", row + 2
  HEAD combine_id_r
   IF (combine_id_r != 0)
    col 0, "Combine_id     =   ", combine_id_r";i",
    row + 1, col 0, "From_id        =   ",
    from_id";i", row + 1, col 0,
    "To_id          =   ", to_id";i", row + 1,
    col 0, "Date/Time      = ",
    CALL print(format(combine_dt_tm,"MM/DD/YYYY HH:MM;;d")),
    row + 1
   ENDIF
  DETAIL
   IF (combine_id_r != 0)
    col 0, "Combine_det_id =   ", combine_det_id";r;i",
    ",    ", col + 1, "Child table = ",
    CALL print(substring(1,20,entity_name)), " with ",
    CALL print(substring(1,20,pk_name)),
    " = ", pk_id";l;i", row + 1
   ELSE
    col 0, "None of the combine detail rows are missing."
   ENDIF
  FOOT  combine_id_r
   row + 1
  WITH nocounter
 ;end select
END GO
