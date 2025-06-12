CREATE PROGRAM dm2_dar_get_bulk_seq:dba
 DECLARE ms_struct_str = vc WITH protect, constant( $1)
 DECLARE ml_seq_cnt = i4 WITH protect, constant( $2)
 DECLARE ms_seq_var = vc WITH protect, constant( $3)
 DECLARE ml_item_start = i4 WITH protect, constant( $4)
 DECLARE ms_from_seq = vc WITH protect, constant(cnvtupper( $5))
 DECLARE ms_parse_str = vc WITH protect, noconstant(" ")
 DECLARE mn_fail_ind = i2 WITH protect, noconstant(0)
 DECLARE ml_size = i4 WITH protect, noconstant(0)
 DECLARE ml_size_b4 = i4 WITH protect, noconstant(0)
 DECLARE ms_string = vc WITH protect, noconstant("")
 DECLARE ms_data_type = vc WITH protect, noconstant("")
 DECLARE mn_val_rec_ind = i2 WITH protect, noconstant(1)
 DECLARE mn_debug_ind = i2 WITH protect, noconstant(0)
 DECLARE mn_stat = i4 WITH protect, noconstant(0)
 DECLARE mn_seq_stat_ind = i2 WITH protect, noconstant(1)
 DECLARE ml_cnt_seqs = i4 WITH protect, noconstant(0)
 DECLARE ml_num_ids_remaining = i4 WITH protect, noconstant(0)
 DECLARE ml_index = i4 WITH protect, noconstant(0)
 DECLARE ml_maxqual = i4 WITH protect, noconstant(0)
 DECLARE sbr_get_bulk_seqs(ms_seq_name=vc,ms_str=vc,ml_start=i4,ms_seq=vc,ml_cnt=i4) = i2
 DECLARE sbr_get_minimum(ml_x=i4,ml_y=i4) = i4
 IF ((validate(m_dm2_seq_stat->n_status,- (1))=- (1)))
  SET mn_fail_ind = 1
  SET mn_seq_stat_ind = 0
  CALL echo("m_dm2_seq_stat is not properly defined in the parent script")
  GO TO exit_program
 ENDIF
 IF (validate(m_dm2_seq_stat->s_error_msg,"ZZZ")="ZZZ")
  SET mn_fail_ind = 1
  SET mn_seq_stat_ind = 0
  CALL echo("m_dm2_seq_stat is not properly defined in the parent script")
  GO TO exit_program
 ENDIF
 IF (ml_seq_cnt < 1)
  SET m_dm2_seq_stat->s_error_msg = "This script should only be used to grab at least one sequence"
  CALL echo(m_dm2_seq_stat->s_error_msg)
  SET mn_val_rec_ind = 0
  SET mn_fail_ind = 1
  GO TO exit_program
 ENDIF
 IF (ml_item_start < 1)
  SET mn_fail_ind = 1
  SET m_dm2_seq_stat->s_error_msg = "Must start updating the list from 1 or above"
  CALL echo(m_dm2_seq_stat->s_error_msg)
  SET mn_val_rec_ind = 0
  GO TO exit_program
 ENDIF
 IF (mn_debug_ind=1)
  CALL echo("Checking that a valid record structure pathname was passed in")
 ENDIF
 SET ms_string = concat("set mn_stat = validate(",ms_struct_str,"[1]->",ms_seq_var,", -1) go")
 CALL parser(ms_string,1)
 IF ((mn_stat=- (1)))
  SET m_dm2_seq_stat->s_error_msg = "Record structure path name does not exist"
  CALL echo(m_dm2_seq_stat->s_error_msg)
  SET mn_val_rec_ind = 0
  SET mn_fail_ind = 1
  GO TO exit_program
 ENDIF
 IF (mn_debug_ind=1)
  CALL echo("Adjusting the record structure size")
 ENDIF
 SET ml_size = ((ml_item_start+ ml_seq_cnt) - 1)
 SET ms_string = concat("set ml_size_b4 = size(",ms_struct_str,", 5) go")
 CALL parser(ms_string,1)
 IF (mn_debug_ind=1)
  CALL echo("Verifying that there is enough storage space")
 ENDIF
 IF (ml_size > ml_size_b4)
  SET ms_string = concat("set mn_stat = alterlist(",ms_struct_str,",",cnvtstring(ml_size),") go")
  CALL parser(ms_string,1)
 ENDIF
 IF (mn_debug_ind=1)
  CALL echo("Verify the record structure stores F8's")
 ENDIF
 SET ms_string = concat("set ms_data_type = reflect(",ms_struct_str,"[1].",ms_seq_var,") go")
 CALL parser(ms_string,1)
 IF (ms_data_type != "F8")
  SET m_dm2_seq_stat->s_error_msg = "Must use an F8 to store the sequences in the record structure"
  CALL echo(m_dm2_seq_stat->s_error_msg)
  SET mn_fail_ind = 1
  GO TO exit_program
 ENDIF
 IF (mn_debug_ind=1)
  CALL echo("Verifying the Sequence exists")
 ENDIF
 IF (ms_from_seq != "DM2_DAR_SEQ")
  SELECT INTO "nl:"
   FROM all_sequences a
   WHERE a.sequence_name=ms_from_seq
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET mn_fail_ind = 1
   SET m_dm2_seq_stat->s_error_msg = "Sequence name doesn't exist on all_sequences table"
   CALL echo(m_dm2_seq_stat->s_error_msg)
   GO TO exit_program
  ENDIF
 ENDIF
 IF (mn_debug_ind=1)
  CALL echo("Getting the new sequences")
 ENDIF
 IF (ml_seq_cnt < 50)
  FOR (i = 1 TO ml_seq_cnt)
   SET ms_parse_str = concat(" select into 'nl:'","   y = seq(",ms_from_seq,", nextval)"," from dual",
    " detail"," ",ms_struct_str,"[ml_ITEM_START + i-1].",ms_seq_var,
    " = y"," with nocounter go")
   CALL parser(ms_parse_str,1)
  ENDFOR
 ELSEIF (ml_seq_cnt <= 500)
  IF (sbr_get_bulk_seqs(ms_from_seq,ms_struct_str,ml_item_start,ms_seq_var,ml_seq_cnt) != 1)
   GO TO exit_program
  ENDIF
 ELSE
  SET ml_num_ids_remaining = ml_seq_cnt
  SET ml_index = ml_item_start
  WHILE (ml_num_ids_remaining != 0)
    SET ml_maxqual = sbr_get_minimum(ml_num_ids_remaining,500)
    IF (sbr_get_bulk_seqs(ms_from_seq,ms_struct_str,ml_index,ms_seq_var,ml_maxqual) != 1)
     GO TO exit_program
    ENDIF
    SET ml_num_ids_remaining = (ml_num_ids_remaining - ml_maxqual)
    SET ml_index = (ml_index+ ml_maxqual)
  ENDWHILE
 ENDIF
 SUBROUTINE sbr_get_bulk_seqs(ms_seq_name,ms_str,ml_start,ms_seq,ml_cnt)
   DECLARE ml_cnt_seqs = i4 WITH protect, noconstant(0)
   SET ms_parse_str = concat(" select into 'nl:'","   y = seq(",ms_seq_name,", nextval)",
    " from code_value cv",
    " head report","   ml_cnt_seqs = 0"," detail"," ",ms_str,
    "[ml_start + ml_cnt_seqs].",ms_seq," = y","   ml_cnt_seqs = ml_cnt_seqs + 1",
    " with nocounter, maxqual(cv, ",
    trim(cnvtstring(ml_cnt)),") go")
   CALL parser(ms_parse_str,1)
   IF (ml_cnt_seqs != ml_cnt)
    SET m_dm2_seq_stat->s_error_msg = "Error retrieving sequence numbers"
    CALL echo(m_dm2_seq_stat->s_error_msg)
    SET mn_fail_ind = 1
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_get_minimum(ml_x,ml_y)
   IF (ml_x < ml_y)
    RETURN(ml_x)
   ELSE
    RETURN(ml_y)
   ENDIF
 END ;Subroutine
#exit_program
 IF (mn_fail_ind=1
  AND mn_seq_stat_ind=1)
  SET m_dm2_seq_stat->n_status = 0
  IF (mn_val_rec_ind=1)
   FOR (i = ml_item_start TO ml_cnt_seqs)
    SET ms_string = concat("set ",ms_struct_str,"[i].",ms_seq_var," = 0.0 go")
    CALL parser(ms_string,1)
   ENDFOR
   SET ms_string = concat("set mn_stat = alterlist(",ms_struct_str,",",cnvtstring(ml_size_b4),") go")
   CALL parser(ms_string,1)
  ENDIF
 ELSE
  SET m_dm2_seq_stat->n_status = 1
  SET m_dm2_seq_stat->s_error_msg = "Successful sequence gather"
 ENDIF
END GO
