CREATE PROGRAM dm_solcap_get:dba
 IF (validate(dm_dsg_request->solution_name,"-123")="-123")
  FREE RECORD dm_dsg_request
  RECORD dm_dsg_request(
    1 start_dt_tm = dq8
    1 end_dt_tm = dq8
    1 solution_name = vc
    1 solcap_identifier = vc
  )
 ENDIF
 DECLARE parse_string(i_str=vc,i_delim=vc,i_delim2=vc,i_parse_rec=vc(ref)) = null
 DECLARE put_str_solcap(i_delim_rec=vc(ref),i_solcap_pos=i4,i_list_pos=i4) = null
 DECLARE solcap_cnt = i4 WITH protect, noconstant(0)
 DECLARE solcap_search_str = vc WITH protect, noconstant("")
 DECLARE dm_info_search_str = vc WITH protect, noconstant("")
 DECLARE facility_cnt = i4 WITH protect, noconstant(0)
 DECLARE fac_pos = i4 WITH protect, noconstant(0)
 DECLARE num_import = i4 WITH protect, noconstant(0)
 DECLARE search_str = vc WITH protect, noconstant("")
 DECLARE search_str_len = i4 WITH protect, noconstant(0)
 DECLARE token = i2 WITH protect, noconstant(0)
 DECLARE start = i4 WITH protect, noconstant(0)
 DECLARE stop = i4 WITH protect, noconstant(0)
 DECLARE len = i4 WITH protect, noconstant(0)
 DECLARE facility = vc WITH protect, noconstant("")
 DECLARE solcap_pos = i4 WITH protect, noconstant(0)
 DECLARE solcap_idx = i4 WITH protect, noconstant(0)
 DECLARE list_pos = i4 WITH protect, noconstant(0)
 DECLARE dsg_dminfo_loop = i4 WITH protect, noconstant(0)
 DECLARE dsg_err_msg = vc WITH protect, noconstant(" ")
 FREE RECORD parse_rec
 RECORD parse_rec(
   1 rec_cnt = i4
   1 rec[*]
     2 info_domain = vc
     2 info_name = vc
     2 info_char = vc
     2 info_num = i4
     2 info_dt = dq8
 )
 FREE RECORD delim_rec
 RECORD delim_rec(
   1 delim_cnt = i4
   1 delim[*]
     2 delimeter = vc
     2 pos_cnt = i4
     2 delim_val = vc
     2 name_str = vc
     2 value_str = vc
 )
 SET stat = initrec(reply)
 IF ((dm_dsg_request->solcap_identifier > " "))
  SET dm_info_search_str = build2(cnvtupper(dm_dsg_request->solution_name)," SOLCAP|",dm_dsg_request
   ->solcap_identifier,"*")
 ELSE
  SET dm_info_search_str = build2(cnvtupper(dm_dsg_request->solution_name)," SOLCAP|*")
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain=patstring(dm_info_search_str)
   AND di.info_date BETWEEN cnvtdatetime(dm_dsg_request->start_dt_tm) AND cnvtdatetime(dm_dsg_request
   ->end_dt_tm)
  DETAIL
   parse_rec->rec_cnt = (parse_rec->rec_cnt+ 1), stat = alterlist(parse_rec->rec,parse_rec->rec_cnt),
   parse_rec->rec[parse_rec->rec_cnt].info_domain = di.info_domain,
   parse_rec->rec[parse_rec->rec_cnt].info_name = di.info_name, parse_rec->rec[parse_rec->rec_cnt].
   info_char = di.info_char, parse_rec->rec[parse_rec->rec_cnt].info_num = di.info_number,
   parse_rec->rec[parse_rec->rec_cnt].info_dt = di.info_date
  WITH nocounter
 ;end select
 FOR (dsg_dminfo_loop = 1 TO size(parse_rec->rec,5))
   IF ((dm_dsg_request->solcap_identifier > " "))
    SET solcap_search_str = dm_dsg_request->solcap_identifier
   ELSE
    CALL parse_string(parse_rec->rec[dsg_dminfo_loop].info_domain,"|","",delim_rec)
    IF ((delim_rec->delim[1].delim_val != "DELIM NOT FOUND"))
     SET solcap_search_str = delim_rec->delim[2].delim_val
    ENDIF
   ENDIF
   IF (solcap_search_str != "DELIM NOT FOUND")
    SET solcap_size = size(reply->solcap,5)
    SET solcap_pos = locateval(solcap_idx,1,solcap_size,solcap_search_str,reply->solcap[solcap_idx].
     identifier)
    IF (solcap_pos=0)
     SET solcap_size = (solcap_size+ 1)
     SET stat = alterlist(reply->solcap,solcap_size)
     SET reply->solcap[solcap_size].identifier = solcap_search_str
     SET solcap_pos = solcap_size
    ENDIF
    SET reply->solcap[solcap_pos].degree_of_use_num = (reply->solcap[solcap_pos].degree_of_use_num+
    parse_rec->rec[dsg_dminfo_loop].info_num)
   ENDIF
   SET stat = initrec(delim_rec)
   CALL parse_string(parse_rec->rec[dsg_dminfo_loop].info_char,"|","=",delim_rec)
   CALL put_str_solcap(delim_rec,solcap_pos)
   SET stat = initrec(delim_rec)
 ENDFOR
 SUBROUTINE parse_string(i_str,i_delim,i_delim2,i_delim_rec)
   DECLARE s_found_ind = i2 WITH protect, noconstant(1)
   DECLARE s_delim_val = vc WITH protect, noconstant("")
   DECLARE s_delim_pos = i4 WITH protect, noconstant(0)
   SET s_delim_pos = 0
   WHILE (s_found_ind=1)
     SET s_delim_pos = (s_delim_pos+ 1)
     SET s_delim_val = piece(i_str,i_delim,s_delim_pos,"DELIM NOT FOUND")
     IF (s_delim_val="DELIM NOT FOUND")
      SET s_found_ind = 0
     ELSE
      SET i_delim_rec->delim_cnt = (i_delim_rec->delim_cnt+ 1)
      SET stat = alterlist(i_delim_rec->delim,i_delim_rec->delim_cnt)
      SET i_delim_rec->delim[i_delim_rec->delim_cnt].delimeter = i_delim
      SET i_delim_rec->delim[i_delim_rec->delim_cnt].pos_cnt = s_delim_pos
      SET i_delim_rec->delim[i_delim_rec->delim_cnt].delim_val = s_delim_val
      SET s_found_ind = 1
     ENDIF
     IF (i_delim2 > " ")
      SET s_delim_val = piece(i_delim_rec->delim[i_delim_rec->delim_cnt].delim_val,i_delim2,1,
       "DELIM NOT FOUND")
      SET i_delim_rec->delim[i_delim_rec->delim_cnt].name_str = s_delim_val
      SET s_delim_val = piece(i_delim_rec->delim[i_delim_rec->delim_cnt].delim_val,i_delim2,2,
       "DELIM NOT FOUND")
      IF (s_delim_val != "DELIM  NOT FOUND")
       SET i_delim_rec->delim[i_delim_rec->delim_cnt].value_str = s_delim_val
      ENDIF
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE put_str_solcap(i_delim_rec,i_solcap_pos)
   DECLARE s_fac_token = vc WITH constant("FAC_NAME")
   DECLARE s_pos_token = vc WITH constant("POS_NAME")
   DECLARE s_cat_token = vc WITH constant("CAT_NAME")
   DECLARE s_my_token = vc WITH protect, noconstant("")
   DECLARE s_token_type = vc WITH protect, noconstant("")
   DECLARE s_fac_idx = i4 WITH protect, noconstant(0)
   DECLARE s_pos_idx = i4 WITH protect, noconstant(0)
   DECLARE s_cat_idx = i4 WITH protect, noconstant(0)
   DECLARE s_delim_pos = i4 WITH protect, noconstant(0)
   DECLARE s_cur_pos = i4 WITH protect, noconstant(0)
   DECLARE s_cat_val_idx = i4 WITH protect, noconstant(0)
   DECLARE s_other_val_cnt = i4 WITH protect, noconstant(0)
   DECLARE cur_row_cnt = i4 WITH protect, noconstant(0)
   DECLARE s_pair_name = vc WITH protect, noconstant("")
   DECLARE s_pair_val = vc WITH protect, noconstant("")
   DECLARE s_cat_name = vc WITH protect, noconstant("")
   DECLARE s_other_size = i4 WITH protect, noconstant(0)
   DECLARE s_other_idx = i4 WITH protect, noconstant(0)
   FOR (s_delim_pos = 1 TO delim_rec->delim_cnt)
     SET s_my_token = delim_rec->delim[s_delim_pos].name_str
     SET s_pair_name = delim_rec->delim[s_delim_pos].name_str
     SET s_pair_val = delim_rec->delim[s_delim_pos].value_str
     CASE (s_my_token)
      OF s_fac_token:
       SET s_cur_pos = locateval(s_fac_idx,1,size(reply->solcap[i_solcap_pos].facility,5),s_pair_val,
        reply->solcap[i_solcap_pos].facility[s_fac_idx].display)
       IF (s_cur_pos=0)
        SET s_fac_idx = (size(reply->solcap[i_solcap_pos].facility,5)+ 1)
        SET stat = alterlist(reply->solcap[i_solcap_pos].facility,s_fac_idx)
        SET reply->solcap[i_solcap_pos].facility[s_fac_idx].display = s_pair_val
       ELSE
        SET reply->solcap[i_solcap_pos].facility[s_fac_idx].display = s_pair_val
       ENDIF
       SET s_token_type = s_fac_token
      OF s_pos_token:
       SET s_cur_pos = locateval(s_pos_idx,1,size(reply->solcap[i_solcap_pos].position,5),s_pair_val,
        reply->solcap[i_solcap_pos].position[s_pos_idx].display)
       IF (s_cur_pos=0)
        SET s_pos_idx = (size(reply->solcap[i_solcap_pos].position,5)+ 1)
        SET stat = alterlist(reply->solcap[i_solcap_pos].position,s_pos_idx)
        SET reply->solcap[i_solcap_pos].position[s_pos_idx].display = s_pair_val
       ELSE
        SET reply->solcap[i_solcap_pos].position[s_pos_idx].display = s_pair_val
       ENDIF
       SET s_token_type = s_pos_token
      OF s_cat_token:
       SET s_other_size = size(reply->solcap[i_solcap_pos].other,5)
       SET s_cat_pos = locateval(s_cat_idx,1,s_other_size,s_pair_val,reply->solcap[i_solcap_pos].
        other[s_cat_idx].category_name)
       IF (s_cat_pos=0)
        SET s_cat_idx = size(reply->solcap[i_solcap_pos].other,5)
        SET s_cat_idx = (s_cat_idx+ 1)
        SET stat = alterlist(reply->solcap[i_solcap_pos].other,s_cat_idx)
        SET reply->solcap[i_solcap_pos].other[s_cat_idx].category_name = s_pair_val
       ENDIF
       SET s_token_type = s_cat_token
      ELSE
       CASE (s_token_type)
        OF s_fac_token:
         IF (isnumeric(s_pair_val)=0)
          SET reply->solcap[i_solcap_pos].facility[s_fac_idx].value_str = s_pair_val
         ELSE
          SET reply->solcap[i_solcap_pos].facility[s_fac_idx].value_num = (cnvtint(s_pair_val)+ reply
          ->solcap[i_solcap_pos].facility[s_fac_idx].value_num)
         ENDIF
        OF s_pos_token:
         IF (isnumeric(s_pair_val)=0)
          SET reply->solcap[i_solcap_pos].position[s_pos_idx].value_str = s_pair_val
         ELSE
          SET reply->solcap[i_solcap_pos].position[s_pos_idx].value_num = (cnvtint(s_pair_val)+ reply
          ->solcap[i_solcap_pos].position[s_pos_idx].value_num)
         ENDIF
        OF s_cat_token:
         SET s_cat_pos = locateval(s_cat_val_idx,1,size(reply->solcap[i_solcap_pos].other[s_cat_idx].
           value,5),s_pair_name,reply->solcap[i_solcap_pos].other[s_cat_idx].value[s_cat_val_idx].
          display)
         IF (s_cat_pos=0)
          SET s_other_val_cnt = size(reply->solcap[i_solcap_pos].other[s_cat_idx].value,5)
          SET s_other_val_cnt = (s_other_val_cnt+ 1)
          SET stat = alterlist(reply->solcap[i_solcap_pos].other[s_cat_idx].value,s_other_val_cnt)
         ELSE
          SET s_other_val_cnt = s_cat_pos
         ENDIF
         SET reply->solcap[i_solcap_pos].other[s_cat_idx].value[s_other_val_cnt].display =
         s_pair_name
         IF (isnumeric(s_pair_val)=0)
          SET reply->solcap[i_solcap_pos].other[s_cat_idx].value[s_other_val_cnt].value_str =
          s_pair_val
         ELSE
          SET reply->solcap[i_solcap_pos].other[s_cat_idx].value[s_other_val_cnt].value_num = (
          cnvtint(s_pair_val)+ reply->solcap[i_solcap_pos].other[s_cat_idx].value[s_other_val_cnt].
          value_num)
         ENDIF
        ELSE
         CALL echo("TOKEN NOT FOUND")
       ENDCASE
     ENDCASE
   ENDFOR
   RETURN
 END ;Subroutine
 CALL echorecord(reply)
 DELETE  FROM dm_info di
  WHERE di.info_domain=patstring(dm_info_search_str)
   AND di.info_date < cnvtlookbehind("7,D")
  WITH nocounter
 ;end delete
 SET err_num = error(dsg_err_msg,1)
 IF (err_num > 0)
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
END GO
