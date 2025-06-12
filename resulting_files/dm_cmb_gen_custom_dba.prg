CREATE PROGRAM dm_cmb_gen_custom:dba
 SET gen_table_name = rcmbchildren->qual3[maincount3].child_table
 SET gen_fk = rcmbchildren->qual3[maincount3].fk_col_name
 SET gen_pk = rcmbchildren->qual3[maincount3].pk_col_name
 SET gen_nbr_of_ak_col = size(rcmbchildren->qual3[maincount3].ak,5)
 CALL echo(build(gen_nbr_of_ak_col))
 SET gen_ak_col[5] = fillstring(30," ")
 FOR (gen_x = 1 TO gen_nbr_of_ak_col)
  SET gen_ak_col[gen_x] = rcmbchildren->qual3[maincount3].ak[gen_x].ak_col_name
  CALL echo(gen_ak_col[gen_x])
 ENDFOR
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[5]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
   1 to_rec[5]
     2 to_id = f8
 )
 SET count1 = 0
 SET count2 = 0
 SET parser_buffer[22] = fillstring(132," ")
 SET parser_buffer[1] = concat("select into 'nl:' FRM.",trim(gen_pk))
 SET parser_buffer[2] = concat("from ",trim(gen_table_name)," FRM")
 SET parser_buffer[3] = concat("where FRM.",trim(gen_fk),
  "= request->xxx_combine[iCombine]->from_xxx_id")
 SET parser_buffer[4] = "detail"
 SET parser_buffer[5] = "    count1 = count1 + 1"
 SET parser_buffer[6] = "    /* Resize record if needed */"
 SET parser_buffer[7] = "    if (mod(count1,5) = 1 and count1 != 1)"
 SET parser_buffer[8] = "       stat = alter(rRecList->from_rec, count1 + 4)"
 SET parser_buffer[9] = "    endif"
 SET parser_buffer[10] = concat("    rRecList->from_rec[count1]->from_id = FRM.",trim(gen_pk))
 SET parser_buffer[11] = "    rRecList->from_rec[count1]->active_ind = FRM.active_ind"
 SET parser_buffer[12] = "    rRecList->from_rec[count1]->active_status_cd = FRM.active_status_cd"
 SET parser_buffer[13] = "with forupdatewait(FRM) go"
 FOR (buff_cnt = 1 TO 13)
   CALL parser(parser_buffer[buff_cnt])
   CALL echo(parser_buffer[buff_cnt])
   SET parser_buffer[buff_cnt] = fillstring(132," ")
 ENDFOR
 IF (count1 > 0)
  SET parser_buffer[1] = concat("select into 'nl:' TU.",trim(gen_pk))
  SET parser_buffer[2] = concat("from ",trim(gen_table_name)," TU")
  SET parser_buffer[3] = concat("where TU.",trim(gen_fk),
   "= request->xxx_combine[iCombine]->to_xxx_id")
  SET parser_buffer[4] = "detail"
  SET parser_buffer[5] = "    count2 = count2 + 1"
  SET parser_buffer[6] = "    /* Resize record if needed */"
  SET parser_buffer[7] = "    if (mod(count2,5) = 1 and count2 != 1)"
  SET parser_buffer[8] = "       stat = alter(rRecList->to_rec, count2 + 4)"
  SET parser_buffer[9] = "    endif"
  SET parser_buffer[10] = concat("    rRecList->to_rec[count2]->to_id = TU.",trim(gen_pk))
  SET parser_buffer[11] = "with forupdatewait(TU) go"
  FOR (buff_cnt = 1 TO 11)
    CALL parser(parser_buffer[buff_cnt])
    CALL echo(parser_buffer[buff_cnt])
    SET parser_buffer[buff_cnt] = fillstring(132," ")
  ENDFOR
  SET cmb_dummy = 0
  IF (count2 > 0)
   FOR (loopcount = 1 TO count1)
     SET gen_match_ind = 0
     IF (gen_nbr_of_ak_col=0)
      SET gen_match_ind = 1
     ELSE
      SET parser_buffer[1] = "select into 'nl:' d.seq"
      SET parser_buffer[2] = concat("from   ",trim(gen_table_name)," FRM, ",trim(gen_table_name),
       " TU,")
      SET parser_buffer[3] = "       (dummyt d with seq = value(count2))"
      SET parser_buffer[4] = "plan d"
      SET parser_buffer[5] = concat("join TU  where TU.",trim(gen_pk),
       " = rRecList->to_rec[d.seq]->to_id")
      SET parser_buffer[6] = concat("join FRM where FRM.",trim(gen_pk),
       " = rRecList->from_rec[loopcount]->from_id")
      FOR (gen_b = 1 TO gen_nbr_of_ak_col)
        SET parser_buffer[(gen_b+ 6)] = concat("           and FRM.",trim(gen_ak_col[gen_b])," = ",
         "TU.",trim(gen_ak_col[gen_b]))
      ENDFOR
      SET parser_buffer[(gen_b+ 7)] = "detail"
      SET parser_buffer[(gen_b+ 8)] = "       gen_match_ind = gen_match_ind + 1"
      SET parser_buffer[(gen_b+ 9)] = "with   nocounter go"
      FOR (buff_cnt = 1 TO (gen_b+ 9))
        CALL parser(parser_buffer[buff_cnt])
        CALL echo(parser_buffer[buff_cnt])
        SET parser_buffer[buff_cnt] = fillstring(132," ")
      ENDFOR
     ENDIF
     IF (gen_match_ind=1)
      CALL echo("Match found on the 'to' records, inactivate the 'from' record.....")
      CALL del_from(cmb_dummy)
     ELSE
      CALL echo("No match is found on the 'to' records, update the 'from' record.....")
      CALL upt_from(cmb_dummy)
     ENDIF
   ENDFOR
  ELSE
   FOR (loopcount = 1 TO count1)
    CALL echo("Found no 'to' records, update the 'from' record.....")
    CALL upt_from(cmb_dummy)
   ENDFOR
  ENDIF
 ENDIF
 SET ecode = 0
 SET emsg = fillstring(132," ")
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET failed = ccl_error
 ENDIF
 SUBROUTINE del_from(dummy)
   FOR (buff_cnt = 1 TO 10)
     SET parser_buffer[buff_cnt] = fillstring(132," ")
   ENDFOR
   SET parser_buffer[1] = concat("UPDATE into ",trim(gen_table_name)," FRM set")
   SET parser_buffer[2] = "       FRM.active_status_cd = COMBINEDAWAY,"
   SET parser_buffer[3] = "       FRM.active_ind       = FALSE,"
   SET parser_buffer[4] = "       FRM.updt_cnt         = FRM.updt_cnt + 1,"
   SET parser_buffer[5] = "       FRM.updt_id          = ReqInfo->updt_id,"
   SET parser_buffer[6] = "       FRM.updt_applctx     = ReqInfo->updt_applctx,"
   SET parser_buffer[7] = "       FRM.updt_task        = ReqInfo->updt_task,"
   SET parser_buffer[8] = "       FRM.updt_dt_tm       = cnvtdatetime(curdate, curtime3)"
   SET parser_buffer[9] = concat("where  FRM.",trim(gen_pk),
    " = rRecList->from_rec[loopcount]->from_id go")
   FOR (buff_cnt = 1 TO 9)
     CALL parser(parser_buffer[buff_cnt])
     CALL echo(parser_buffer[buff_cnt])
     SET parser_buffer[buff_cnt] = fillstring(132," ")
   ENDFOR
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = rreclist->from_rec[loopcount].from_id
   SET request->xxx_combine_det[icombinedet].entity_name = gen_table_name
   SET request->xxx_combine_det[icombinedet].attribute_name = gen_fk
   SET request->xxx_combine_det[icombinedet].prev_active_ind = rreclist->from_rec[loopcount].
   active_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = rreclist->from_rec[loopcount].
   active_status_cd
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = concat("Couldn't inactivate ",trim(gen_table_name)," record with ",
     trim(gen_pk)," = ",
     cnvtstring(rreclist->from_rec[loopcount].from_id))
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE upt_from(dummy)
   FOR (buff_cnt = 1 TO 8)
     SET parser_buffer[buff_cnt] = fillstring(132," ")
   ENDFOR
   SET parser_buffer[1] = concat("UPDATE into ",trim(gen_table_name)," FRM set")
   SET parser_buffer[2] = concat("       FRM.",trim(gen_fk),
    " = request->xxx_combine[iCombine]->to_xxx_id")
   SET parser_buffer[3] = "       FRM.updt_cnt         = FRM.updt_cnt + 1,"
   SET parser_buffer[4] = "       FRM.updt_id          = ReqInfo->updt_id,"
   SET parser_buffer[5] = "       FRM.updt_applctx     = ReqInfo->updt_applctx,"
   SET parser_buffer[6] = "       FRM.updt_task        = ReqInfo->updt_task,"
   SET parser_buffer[7] = "       FRM.updt_dt_tm       = cnvtdatetime(curdate, curtime3)"
   SET parser_buffer[8] = concat(" where FRM.",trim(gen_pk),
    " = rRecList->from_rec[loopcount]->from_id go")
   FOR (buff_cnt = 1 TO 8)
     CALL parser(parser_buffer[buff_cnt])
     CALL echo(parser_buffer[buff_cnt])
     SET parser_buffer[buff_cnt] = fillstring(132," ")
   ENDFOR
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = rreclist->from_rec[loopcount].from_id
   SET request->xxx_combine_det[icombinedet].entity_name = gen_table_name
   SET request->xxx_combine_det[icombinedet].attribute_name = gen_fk
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = concat("Couldn't update ",trim(gen_table_name)," record with ",trim(
      gen_pk)," = ",
     cnvtstring(rreclist->from_rec[loopcount].from_id))
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 FREE SET rreclist
END GO
