CREATE PROGRAM bhs_sch_rptstd_res_appt_list:dba
 DECLARE mf_cs355_userdefined_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!13752"))
 DECLARE mf_cs100068_primary_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",100068,
   "PRIMARY"))
 DECLARE mf_cs356_phonepriority_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "PHONEPRIORITY"))
 DECLARE mf_cs356_cellpriority_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "CELLPRIORITY"))
 DECLARE mf_cs43_cell_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2510010055"))
 IF (validate(last_mod,"NO_MOD")="NO_MOD")
  DECLARE last_mod = c6 WITH noconstant(""), private
 ENDIF
 SET last_mod = "385585"
 IF (validate(action_none,- (1)) != 0)
  DECLARE action_none = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(action_add,- (1)) != 1)
  DECLARE action_add = i2 WITH protect, noconstant(1)
 ENDIF
 IF (validate(action_chg,- (1)) != 2)
  DECLARE action_chg = i2 WITH protect, noconstant(2)
 ENDIF
 IF (validate(action_del,- (1)) != 3)
  DECLARE action_del = i2 WITH protect, noconstant(3)
 ENDIF
 IF (validate(action_get,- (1)) != 4)
  DECLARE action_get = i2 WITH protect, noconstant(4)
 ENDIF
 IF (validate(action_ina,- (1)) != 5)
  DECLARE action_ina = i2 WITH protect, noconstant(5)
 ENDIF
 IF (validate(action_act,- (1)) != 6)
  DECLARE action_act = i2 WITH protect, noconstant(6)
 ENDIF
 IF (validate(action_temp,- (1)) != 999)
  DECLARE action_temp = i2 WITH protect, noconstant(999)
 ENDIF
 IF (validate(true,- (1)) != 1)
  DECLARE true = i2 WITH protect, noconstant(1)
 ENDIF
 IF (validate(false,- (1)) != 0)
  DECLARE false = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(gen_nbr_error,- (1)) != 3)
  DECLARE gen_nbr_error = i2 WITH protect, noconstant(3)
 ENDIF
 IF (validate(insert_error,- (1)) != 4)
  DECLARE insert_error = i2 WITH protect, noconstant(4)
 ENDIF
 IF (validate(update_error,- (1)) != 5)
  DECLARE update_error = i2 WITH protect, noconstant(5)
 ENDIF
 IF (validate(replace_error,- (1)) != 6)
  DECLARE replace_error = i2 WITH protect, noconstant(6)
 ENDIF
 IF (validate(delete_error,- (1)) != 7)
  DECLARE delete_error = i2 WITH protect, noconstant(7)
 ENDIF
 IF (validate(undelete_error,- (1)) != 8)
  DECLARE undelete_error = i2 WITH protect, noconstant(8)
 ENDIF
 IF (validate(remove_error,- (1)) != 9)
  DECLARE remove_error = i2 WITH protect, noconstant(9)
 ENDIF
 IF (validate(attribute_error,- (1)) != 10)
  DECLARE attribute_error = i2 WITH protect, noconstant(10)
 ENDIF
 IF (validate(lock_error,- (1)) != 11)
  DECLARE lock_error = i2 WITH protect, noconstant(11)
 ENDIF
 IF (validate(none_found,- (1)) != 12)
  DECLARE none_found = i2 WITH protect, noconstant(12)
 ENDIF
 IF (validate(select_error,- (1)) != 13)
  DECLARE select_error = i2 WITH protect, noconstant(13)
 ENDIF
 IF (validate(update_cnt_error,- (1)) != 14)
  DECLARE update_cnt_error = i2 WITH protect, noconstant(14)
 ENDIF
 IF (validate(not_found,- (1)) != 15)
  DECLARE not_found = i2 WITH protect, noconstant(15)
 ENDIF
 IF (validate(version_insert_error,- (1)) != 16)
  DECLARE version_insert_error = i2 WITH protect, noconstant(16)
 ENDIF
 IF (validate(inactivate_error,- (1)) != 17)
  DECLARE inactivate_error = i2 WITH protect, noconstant(17)
 ENDIF
 IF (validate(activate_error,- (1)) != 18)
  DECLARE activate_error = i2 WITH protect, noconstant(18)
 ENDIF
 IF (validate(version_delete_error,- (1)) != 19)
  DECLARE version_delete_error = i2 WITH protect, noconstant(19)
 ENDIF
 IF (validate(uar_error,- (1)) != 20)
  DECLARE uar_error = i2 WITH protect, noconstant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 IF (validate(failed,- (1)) != 0)
  DECLARE failed = i2 WITH protect, noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH protect, noconstant("")
 ELSE
  SET table_name = fillstring(100," ")
 ENDIF
 IF (validate(call_echo_ind,- (1)) != 0)
  DECLARE call_echo_ind = i2 WITH protect, noconstant(false)
 ENDIF
 IF (validate(i_version,- (1)) != 0)
  DECLARE i_version = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(program_name,"ZZZ")="ZZZ")
  DECLARE program_name = vc WITH protect, noconstant(fillstring(30," "))
 ENDIF
 IF (validate(sch_security_id,- (1)) != 0)
  DECLARE sch_security_id = f8 WITH protect, noconstant(0.0)
 ENDIF
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 IF (validate(schuar_def,999)=999)
  CALL echo("Declaring schuar_def")
  DECLARE schuar_def = i2 WITH persist
  SET schuar_def = 1
  DECLARE uar_sch_check_security(sec_type_cd=f8(ref),parent1_id=f8(ref),parent2_id=f8(ref),parent3_id
   =f8(ref),sec_id=f8(ref),
   user_id=f8(ref)) = i4 WITH image_axp = "shrschuar", image_aix = "libshrschuar.a(libshrschuar.o)",
  uar = "uar_sch_check_security",
  persist
  DECLARE uar_sch_security_insert(user_id=f8(ref),sec_type_cd=f8(ref),parent1_id=f8(ref),parent2_id=
   f8(ref),parent3_id=f8(ref),
   sec_id=f8(ref)) = i4 WITH image_axp = "shrschuar", image_aix = "libshrschuar.a(libshrschuar.o)",
  uar = "uar_sch_security_insert",
  persist
  DECLARE uar_sch_security_perform() = i4 WITH image_axp = "shrschuar", image_aix =
  "libshrschuar.a(libshrschuar.o)", uar = "uar_sch_security_perform",
  persist
  DECLARE uar_sch_check_security_ex(user_id=f8(ref),sec_type_cd=f8(ref),parent1_id=f8(ref),parent2_id
   =f8(ref),parent3_id=f8(ref),
   sec_id=f8(ref)) = i4 WITH image_axp = "shrschuar", image_aix = "libshrschuar.a(libshrschuar.o)",
  uar = "uar_sch_check_security_ex",
  persist
  DECLARE uar_sch_check_security_ex2(user_id=f8(ref),sec_type_cd=f8(ref),parent1_id=f8(ref),
   parent2_id=f8(ref),parent3_id=f8(ref),
   sec_id=f8(ref),position_cd=f8(ref)) = i4 WITH image_axp = "shrschuar", image_aix =
  "libshrschuar.a(libshrschuar.o)", uar = "uar_sch_check_security_ex2",
  persist
  DECLARE uar_sch_security_insert_ex2(user_id=f8(ref),sec_type_cd=f8(ref),parent1_id=f8(ref),
   parent2_id=f8(ref),parent3_id=f8(ref),
   sec_id=f8(ref),position_cd=f8(ref)) = i4 WITH image_axp = "shrschuar", image_aix =
  "libshrschuar.a(libshrschuar.o)", uar = "uar_sch_security_insert_ex2",
  persist
 ENDIF
 DECLARE s_format_utc_date(date,tz_index,option) = vc
 SUBROUTINE s_format_utc_date(date,tz_index,option)
   IF (curutc)
    IF (tz_index > 0)
     RETURN(format(datetimezone(date,tz_index),option))
    ELSE
     RETURN(format(datetimezone(date,curtimezonesys),option))
    ENDIF
   ELSE
    RETURN(format(date,option))
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(format_text_request,0)))
  RECORD format_text_request(
    1 call_echo_ind = i2
    1 raw_text = vc
    1 temp_str = vc
    1 chars_per_line = i4
  )
 ENDIF
 IF ( NOT (validate(format_text_reply,0)))
  RECORD format_text_reply(
    1 beg_index = i4
    1 end_index = i4
    1 temp_index = i4
    1 qual_alloc = i4
    1 qual_cnt = i4
    1 qual[*]
      2 text_string = vc
  )
 ENDIF
 SET format_text_reply->qual_cnt = 0
 SET format_text_reply->qual_alloc = 0
 SUBROUTINE format_text(null_index)
   SET format_text_request->raw_text = trim(format_text_request->raw_text,3)
   SET text_length = textlen(format_text_request->raw_text)
   SET format_text_request->temp_str = " "
   FOR (j_text = 1 TO text_length)
     SET temp_char = substring(j_text,1,format_text_request->raw_text)
     IF (temp_char=" ")
      SET temp_char = "^"
     ENDIF
     SET t_number = ichar(temp_char)
     IF (t_number != 10
      AND t_number != 13)
      SET format_text_request->temp_str = concat(format_text_request->temp_str,temp_char)
     ENDIF
     IF (t_number=13)
      SET format_text_request->temp_str = concat(format_text_request->temp_str,"^")
     ENDIF
   ENDFOR
   SET format_text_request->temp_str = replace(format_text_request->temp_str,"^"," ",0)
   SET format_text_request->raw_text = format_text_request->temp_str
   SET format_text_reply->beg_index = 0
   SET format_text_reply->end_index = 0
   SET format_text_reply->qual_cnt = 0
   SET text_len = textlen(format_text_request->raw_text)
   IF ((text_len > format_text_request->chars_per_line))
    WHILE ((text_len > format_text_request->chars_per_line))
      SET wrap_ind = 0
      SET format_text_reply->beg_index = 1
      WHILE (wrap_ind=0)
        SET format_text_reply->end_index = findstring(" ",format_text_request->raw_text,
         format_text_reply->beg_index)
        IF ((format_text_reply->end_index=0))
         SET format_text_reply->end_index = (format_text_request->chars_per_line+ 10)
        ENDIF
        IF ((format_text_reply->beg_index=1)
         AND (format_text_reply->end_index > format_text_request->chars_per_line))
         SET format_text_reply->qual_cnt += 1
         IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc))
          SET format_text_reply->qual_alloc += 10
          SET stat = alterlist(format_text_reply->qual,format_text_reply->qual_alloc)
         ENDIF
         SET format_text_reply->qual[format_text_reply->qual_cnt].text_string = substring(1,
          format_text_request->chars_per_line,format_text_request->raw_text)
         SET format_text_request->raw_text = substring((format_text_request->chars_per_line+ 1),(
          text_len - format_text_request->chars_per_line),format_text_request->raw_text)
         SET wrap_ind = 1
        ELSEIF ((format_text_reply->end_index > format_text_request->chars_per_line))
         SET format_text_reply->qual_cnt += 1
         IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc))
          SET format_text_reply->qual_alloc += 10
          SET stat = alterlist(format_text_reply->qual,format_text_reply->qual_alloc)
         ENDIF
         SET format_text_reply->qual[format_text_reply->qual_cnt].text_string = substring(1,(
          format_text_reply->beg_index - 1),format_text_request->raw_text)
         SET format_text_request->raw_text = substring(format_text_reply->beg_index,((text_len -
          format_text_reply->beg_index)+ 1),format_text_request->raw_text)
         SET wrap_ind = 1
        ENDIF
        SET format_text_reply->beg_index = (format_text_reply->end_index+ 1)
      ENDWHILE
      SET text_len = textlen(format_text_request->raw_text)
    ENDWHILE
    SET format_text_reply->qual_cnt += 1
    IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc))
     SET format_text_reply->qual_alloc += 10
     SET stat = alterlist(format_text_reply->qual,format_text_reply->qual_alloc)
    ENDIF
    SET format_text_reply->qual[format_text_reply->qual_cnt].text_string = format_text_request->
    raw_text
   ELSE
    SET format_text_reply->qual_cnt += 1
    IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc))
     SET format_text_reply->qual_alloc += 10
     SET stat = alterlist(format_text_reply->qual,format_text_reply->qual_alloc)
    ENDIF
    SET format_text_reply->qual[format_text_reply->qual_cnt].text_string = format_text_request->
    raw_text
   ENDIF
 END ;Subroutine
 SUBROUTINE inc_format_text(null_index)
  SET format_text_reply->qual_cnt += 1
  IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc))
   SET format_text_reply->qual_alloc += 10
   SET stat = alterlist(format_text_reply->qual,format_text_reply->qual_alloc)
  ENDIF
 END ;Subroutine
 IF ((validate(sch_font_metrics_times_rec_,- (99))=- (99)))
  DECLARE sch_font_metrics_times_rec_ = i2 WITH public, constant(1)
  FREE SET format_text
  RECORD format_text(
    1 output_string_cnt = i4
    1 output_string[*]
      2 string = vc
      2 x_offset = i4
      2 bold = i2
  )
  FREE SET metrics
  RECORD metrics(
    1 times_cnt = i4
    1 times[*]
      2 size = i2
    1 times_bold_cnt = i2
    1 times_bold[*]
      2 size = i2
  )
 ENDIF
 IF ((validate(sch_font_metrics_times_,- (99))=- (99)))
  DECLARE sch_font_metrics_times_ = i2 WITH public, constant(1)
  DECLARE inputstrlen = i4 WITH public, noconstant(0)
  DECLARE fontpoints = i4 WITH public, noconstant(0)
  DECLARE widthline = i4 WITH public, noconstant(0)
  DECLARE widthtotal = i4 WITH public, noconstant(0)
  DECLARE widthstring = i4 WITH public, noconstant(0)
  DECLARE widthword = i4 WITH public, noconstant(0)
  DECLARE widthchar = i2 WITH public, noconstant(0)
  DECLARE widthspace = i4 WITH public, noconstant(0)
  DECLARE spacecnt = i2 WITH public, noconstant(0)
  DECLARE asciinum = i2 WITH public, noconstant(0)
  DECLARE endword = i4 WITH public, noconstant(1)
  DECLARE startsubstr = i4 WITH public, noconstant(1)
  DECLARE endlastline = i2 WITH public, noconstant(0)
  DECLARE endlastlinepts = i4 WITH public, noconstant(0)
  DECLARE state = i2 WITH public, noconstant(0)
  DECLARE cnt = i4 WITH public, noconstant(1)
  DECLARE bold = i2 WITH public, noconstant(0)
  DECLARE boldstart = i4 WITH public, noconstant(0)
  DECLARE nonboldstart = i4 WITH public, noconstant(0)
  DECLARE temp_indx = i4 WITH public, noconstant(0)
  IF ((validate(sch_font_metrics_times_rec_,- (99))=- (99)))
   DECLARE sch_font_metrics_times_rec_ = i2 WITH public, constant(1)
   FREE SET format_text
   RECORD format_text(
     1 output_string_cnt = i2
     1 output_string[*]
       2 string = vc
       2 x_offset = i4
       2 bold = i2
   )
   FREE SET metrics
   RECORD metrics(
     1 times_cnt = i2
     1 times[*]
       2 size = i2
     1 times_bold_cnt = i2
     1 times_bold[*]
       2 size = i2
   )
  ENDIF
  SET format_text->output_string_cnt = 0
  SET metrics->times_cnt = 253
  SET stat = alterlist(metrics->times,metrics->times_cnt)
  FOR (t_indx = 1 TO 31)
    SET metrics->times[t_indx].size = 0
  ENDFOR
  SET metrics->times[32].size = 250
  SET metrics->times[33].size = 333
  SET metrics->times[34].size = 408
  SET metrics->times[35].size = 500
  SET metrics->times[36].size = 500
  SET metrics->times[37].size = 833
  SET metrics->times[38].size = 778
  SET metrics->times[39].size = 333
  SET metrics->times[40].size = 333
  SET metrics->times[41].size = 333
  SET metrics->times[42].size = 500
  SET metrics->times[43].size = 564
  SET metrics->times[44].size = 250
  SET metrics->times[45].size = 333
  SET metrics->times[46].size = 250
  SET metrics->times[47].size = 278
  SET metrics->times[48].size = 500
  SET metrics->times[49].size = 550
  SET metrics->times[50].size = 550
  SET metrics->times[51].size = 550
  SET metrics->times[52].size = 550
  SET metrics->times[53].size = 550
  SET metrics->times[54].size = 550
  SET metrics->times[55].size = 550
  SET metrics->times[56].size = 550
  SET metrics->times[57].size = 550
  SET metrics->times[58].size = 278
  SET metrics->times[59].size = 278
  SET metrics->times[60].size = 564
  SET metrics->times[61].size = 564
  SET metrics->times[62].size = 564
  SET metrics->times[63].size = 444
  SET metrics->times[64].size = 921
  SET metrics->times[65].size = 722
  SET metrics->times[66].size = 667
  SET metrics->times[67].size = 667
  SET metrics->times[68].size = 722
  SET metrics->times[69].size = 611
  SET metrics->times[70].size = 556
  SET metrics->times[71].size = 722
  SET metrics->times[72].size = 722
  SET metrics->times[73].size = 333
  SET metrics->times[74].size = 389
  SET metrics->times[75].size = 722
  SET metrics->times[76].size = 611
  SET metrics->times[77].size = 889
  SET metrics->times[78].size = 722
  SET metrics->times[79].size = 722
  SET metrics->times[80].size = 556
  SET metrics->times[81].size = 722
  SET metrics->times[82].size = 667
  SET metrics->times[83].size = 556
  SET metrics->times[84].size = 611
  SET metrics->times[85].size = 722
  SET metrics->times[86].size = 722
  SET metrics->times[87].size = 944
  SET metrics->times[88].size = 722
  SET metrics->times[89].size = 722
  SET metrics->times[90].size = 611
  SET metrics->times[91].size = 333
  SET metrics->times[92].size = 278
  SET metrics->times[93].size = 333
  SET metrics->times[94].size = 469
  SET metrics->times[95].size = 500
  SET metrics->times[96].size = 333
  SET metrics->times[97].size = 444
  SET metrics->times[98].size = 500
  SET metrics->times[99].size = 444
  SET metrics->times[100].size = 500
  SET metrics->times[101].size = 444
  SET metrics->times[102].size = 333
  SET metrics->times[103].size = 500
  SET metrics->times[104].size = 500
  SET metrics->times[105].size = 278
  SET metrics->times[106].size = 278
  SET metrics->times[107].size = 500
  SET metrics->times[108].size = 278
  SET metrics->times[109].size = 778
  SET metrics->times[110].size = 500
  SET metrics->times[111].size = 500
  SET metrics->times[112].size = 500
  SET metrics->times[113].size = 500
  SET metrics->times[114].size = 333
  SET metrics->times[115].size = 389
  SET metrics->times[116].size = 278
  SET metrics->times[117].size = 500
  SET metrics->times[118].size = 500
  SET metrics->times[119].size = 722
  SET metrics->times[120].size = 500
  SET metrics->times[121].size = 500
  SET metrics->times[122].size = 444
  SET metrics->times[123].size = 480
  SET metrics->times[124].size = 200
  SET metrics->times[125].size = 480
  SET metrics->times[126].size = 541
  FOR (t_indx = 127 TO 160)
    SET metrics->times[t_indx].size = 0
  ENDFOR
  SET metrics->times[161].size = 333
  SET metrics->times[162].size = 500
  SET metrics->times[163].size = 500
  SET metrics->times[164].size = 167
  SET metrics->times[165].size = 500
  SET metrics->times[166].size = 500
  SET metrics->times[167].size = 500
  SET metrics->times[168].size = 500
  SET metrics->times[169].size = 180
  SET metrics->times[170].size = 444
  SET metrics->times[171].size = 500
  SET metrics->times[172].size = 333
  SET metrics->times[173].size = 333
  SET metrics->times[174].size = 556
  SET metrics->times[175].size = 556
  SET metrics->times[176].size = 0
  SET metrics->times[177].size = 500
  SET metrics->times[178].size = 500
  SET metrics->times[179].size = 500
  SET metrics->times[180].size = 250
  SET metrics->times[181].size = 0
  SET metrics->times[182].size = 453
  SET metrics->times[183].size = 350
  SET metrics->times[184].size = 333
  SET metrics->times[185].size = 444
  SET metrics->times[186].size = 444
  SET metrics->times[187].size = 500
  SET metrics->times[188].size = 1000
  SET metrics->times[189].size = 1000
  SET metrics->times[190].size = 0
  SET metrics->times[191].size = 444
  SET metrics->times[192].size = 333
  SET metrics->times[193].size = 333
  SET metrics->times[194].size = 333
  SET metrics->times[195].size = 333
  SET metrics->times[196].size = 333
  SET metrics->times[197].size = 333
  SET metrics->times[198].size = 333
  SET metrics->times[199].size = 333
  SET metrics->times[200].size = 333
  SET metrics->times[201].size = 333
  SET metrics->times[202].size = 333
  SET metrics->times[203].size = 333
  SET metrics->times[204].size = 278
  SET metrics->times[205].size = 278
  SET metrics->times[206].size = 278
  SET metrics->times[207].size = 278
  SET metrics->times[208].size = 1000
  FOR (t_indx = 209 TO 224)
    SET metrics->times[t_indx].size = 0
  ENDFOR
  SET metrics->times[225].size = 889
  SET metrics->times[226].size = 0
  SET metrics->times[227].size = 276
  SET metrics->times[228].size = 0
  SET metrics->times[229].size = 0
  SET metrics->times[230].size = 0
  SET metrics->times[231].size = 0
  SET metrics->times[232].size = 611
  SET metrics->times[233].size = 722
  SET metrics->times[234].size = 889
  SET metrics->times[235].size = 310
  SET metrics->times[236].size = 0
  SET metrics->times[237].size = 0
  SET metrics->times[238].size = 0
  SET metrics->times[239].size = 0
  SET metrics->times[240].size = 0
  SET metrics->times[241].size = 667
  SET metrics->times[242].size = 0
  SET metrics->times[243].size = 0
  SET metrics->times[244].size = 0
  SET metrics->times[245].size = 278
  SET metrics->times[246].size = 0
  SET metrics->times[247].size = 0
  SET metrics->times[248].size = 278
  SET metrics->times[249].size = 500
  SET metrics->times[250].size = 722
  SET metrics->times[251].size = 500
  SET metrics->times[252].size = 0
  SET metrics->times[253].size = 0
  SET metrics->times_bold_cnt = 253
  SET stat = alterlist(metrics->times_bold,metrics->times_bold_cnt)
  FOR (t_indx = 1 TO 31)
    SET metrics->times_bold[t_indx].size = 0
  ENDFOR
  SET metrics->times_bold[32].size = 250
  SET metrics->times_bold[33].size = 333
  SET metrics->times_bold[34].size = 555
  SET metrics->times_bold[35].size = 500
  SET metrics->times_bold[36].size = 500
  SET metrics->times_bold[37].size = 1000
  SET metrics->times_bold[38].size = 833
  SET metrics->times_bold[39].size = 333
  SET metrics->times_bold[40].size = 333
  SET metrics->times_bold[41].size = 333
  SET metrics->times_bold[42].size = 500
  SET metrics->times_bold[43].size = 570
  SET metrics->times_bold[44].size = 250
  SET metrics->times_bold[45].size = 333
  SET metrics->times_bold[46].size = 250
  SET metrics->times_bold[47].size = 278
  SET metrics->times_bold[48].size = 500
  SET metrics->times_bold[49].size = 500
  SET metrics->times_bold[50].size = 500
  SET metrics->times_bold[51].size = 500
  SET metrics->times_bold[52].size = 500
  SET metrics->times_bold[53].size = 500
  SET metrics->times_bold[54].size = 500
  SET metrics->times_bold[55].size = 500
  SET metrics->times_bold[56].size = 500
  SET metrics->times_bold[57].size = 500
  SET metrics->times_bold[58].size = 333
  SET metrics->times_bold[59].size = 333
  SET metrics->times_bold[60].size = 570
  SET metrics->times_bold[61].size = 570
  SET metrics->times_bold[62].size = 570
  SET metrics->times_bold[63].size = 500
  SET metrics->times_bold[64].size = 930
  SET metrics->times_bold[65].size = 722
  SET metrics->times_bold[66].size = 667
  SET metrics->times_bold[67].size = 722
  SET metrics->times_bold[68].size = 722
  SET metrics->times_bold[69].size = 667
  SET metrics->times_bold[70].size = 611
  SET metrics->times_bold[71].size = 778
  SET metrics->times_bold[72].size = 778
  SET metrics->times_bold[73].size = 389
  SET metrics->times_bold[74].size = 500
  SET metrics->times_bold[75].size = 778
  SET metrics->times_bold[76].size = 667
  SET metrics->times_bold[77].size = 944
  SET metrics->times_bold[78].size = 722
  SET metrics->times_bold[79].size = 778
  SET metrics->times_bold[80].size = 556
  SET metrics->times_bold[81].size = 667
  SET metrics->times_bold[82].size = 722
  SET metrics->times_bold[83].size = 556
  SET metrics->times_bold[84].size = 667
  SET metrics->times_bold[85].size = 722
  SET metrics->times_bold[86].size = 722
  SET metrics->times_bold[87].size = 1000
  SET metrics->times_bold[88].size = 772
  SET metrics->times_bold[89].size = 772
  SET metrics->times_bold[90].size = 667
  SET metrics->times_bold[91].size = 333
  SET metrics->times_bold[92].size = 278
  SET metrics->times_bold[93].size = 333
  SET metrics->times_bold[94].size = 581
  SET metrics->times_bold[95].size = 500
  SET metrics->times_bold[96].size = 333
  SET metrics->times_bold[97].size = 500
  SET metrics->times_bold[98].size = 556
  SET metrics->times_bold[99].size = 444
  SET metrics->times_bold[100].size = 556
  SET metrics->times_bold[101].size = 444
  SET metrics->times_bold[102].size = 333
  SET metrics->times_bold[103].size = 500
  SET metrics->times_bold[104].size = 556
  SET metrics->times_bold[105].size = 278
  SET metrics->times_bold[106].size = 333
  SET metrics->times_bold[107].size = 556
  SET metrics->times_bold[108].size = 278
  SET metrics->times_bold[109].size = 833
  SET metrics->times_bold[110].size = 556
  SET metrics->times_bold[111].size = 500
  SET metrics->times_bold[112].size = 556
  SET metrics->times_bold[113].size = 556
  SET metrics->times_bold[114].size = 444
  SET metrics->times_bold[115].size = 389
  SET metrics->times_bold[116].size = 333
  SET metrics->times_bold[117].size = 556
  SET metrics->times_bold[118].size = 550
  SET metrics->times_bold[119].size = 722
  SET metrics->times_bold[120].size = 500
  SET metrics->times_bold[121].size = 500
  SET metrics->times_bold[122].size = 444
  SET metrics->times_bold[123].size = 394
  SET metrics->times_bold[124].size = 220
  SET metrics->times_bold[125].size = 394
  SET metrics->times_bold[126].size = 520
  FOR (t_indx = 127 TO 160)
    SET metrics->times_bold[t_indx].size = 0
  ENDFOR
  SET metrics->times_bold[161].size = 333
  SET metrics->times_bold[162].size = 500
  SET metrics->times_bold[163].size = 500
  SET metrics->times_bold[164].size = 167
  SET metrics->times_bold[165].size = 500
  SET metrics->times_bold[166].size = 500
  SET metrics->times_bold[167].size = 500
  SET metrics->times_bold[168].size = 500
  SET metrics->times_bold[169].size = 278
  SET metrics->times_bold[170].size = 500
  SET metrics->times_bold[171].size = 500
  SET metrics->times_bold[172].size = 333
  SET metrics->times_bold[173].size = 333
  SET metrics->times_bold[174].size = 556
  SET metrics->times_bold[175].size = 556
  SET metrics->times_bold[176].size = 0
  SET metrics->times_bold[177].size = 500
  SET metrics->times_bold[178].size = 500
  SET metrics->times_bold[179].size = 500
  SET metrics->times_bold[180].size = 250
  SET metrics->times_bold[181].size = 0
  SET metrics->times_bold[182].size = 540
  SET metrics->times_bold[183].size = 350
  SET metrics->times_bold[184].size = 333
  SET metrics->times_bold[185].size = 500
  SET metrics->times_bold[186].size = 500
  SET metrics->times_bold[187].size = 500
  SET metrics->times_bold[188].size = 1000
  SET metrics->times_bold[189].size = 1000
  SET metrics->times_bold[190].size = 0
  SET metrics->times_bold[191].size = 500
  SET metrics->times_bold[193].size = 333
  SET metrics->times_bold[194].size = 333
  SET metrics->times_bold[195].size = 333
  SET metrics->times_bold[196].size = 333
  SET metrics->times_bold[197].size = 333
  SET metrics->times_bold[198].size = 333
  SET metrics->times_bold[199].size = 333
  SET metrics->times_bold[200].size = 333
  SET metrics->times_bold[202].size = 333
  SET metrics->times_bold[203].size = 333
  SET metrics->times_bold[205].size = 333
  SET metrics->times_bold[206].size = 333
  SET metrics->times_bold[207].size = 333
  SET metrics->times_bold[208].size = 1000
  FOR (t_indx = 209 TO 224)
    SET metrics->times_bold[t_indx].size = 0
  ENDFOR
  SET metrics->times_bold[225].size = 1000
  SET metrics->times_bold[226].size = 0
  SET metrics->times_bold[227].size = 300
  SET metrics->times_bold[228].size = 0
  SET metrics->times_bold[229].size = 0
  SET metrics->times_bold[230].size = 0
  SET metrics->times_bold[231].size = 0
  SET metrics->times_bold[232].size = 667
  SET metrics->times_bold[233].size = 778
  SET metrics->times_bold[234].size = 1000
  SET metrics->times_bold[235].size = 330
  SET metrics->times_bold[236].size = 0
  SET metrics->times_bold[237].size = 0
  SET metrics->times_bold[238].size = 0
  SET metrics->times_bold[239].size = 0
  SET metrics->times_bold[240].size = 0
  SET metrics->times_bold[241].size = 722
  SET metrics->times_bold[242].size = 0
  SET metrics->times_bold[243].size = 0
  SET metrics->times_bold[244].size = 0
  SET metrics->times_bold[245].size = 278
  SET metrics->times_bold[246].size = 0
  SET metrics->times_bold[247].size = 0
  SET metrics->times_bold[248].size = 278
  SET metrics->times_bold[249].size = 500
  SET metrics->times_bold[250].size = 722
  SET metrics->times_bold[251].size = 556
  SET metrics->times_bold[252].size = 0
  SET metrics->times_bold[253].size = 0
  SUBROUTINE (cpitopoints(cpisize=i2) =i2)
    DECLARE pointsize = i2
    SET pointsize = floor(((120.0/ cpisize)+ 0.5))
    RETURN(pointsize)
  END ;Subroutine
  SUBROUTINE (stringwidthtimes(input_string=vc,cpi=i2,bold=i2) =i4)
    IF (cpi > 0)
     SET fontpoints = floor(((120.0/ cpi)+ 0.5))
    ELSE
     SET fontpoints = 0
    ENDIF
    SET inputstrlen = textlen(input_string)
    SET widthtotal = 0
    FOR (temp_indx = 1 TO inputstrlen)
     SET asciinum = ichar(substring(temp_indx,1,input_string))
     IF (asciinum <= 253)
      IF (bold=0)
       SET widthtotal += (fontpoints * metrics->times[asciinum].size)
      ELSE
       SET widthtotal += (fontpoints * metrics->times_bold[asciinum].size)
      ENDIF
     ENDIF
    ENDFOR
    SET widthtotal = floor(((widthtotal/ 1000.0)+ 0.5))
    RETURN(widthtotal)
  END ;Subroutine
  SUBROUTINE (centerstringtimes(input_string=vc,cpi=i2,x_start=i2,x_end=i2,bold_start=i2) =i2)
    IF (cpi > 0)
     SET fontpoints = floor(((120.0/ cpi)+ 0.5))
    ELSE
     SET fontpoints = 0
    ENDIF
    SET inputstrlen = textlen(input_string)
    SET widthline = ((x_end - x_start) * 1000)
    SET widthtotal = 0
    SET widthstring = 0
    SET startsubstr = 1
    SET bold = bold_start
    SET format_text->output_string_cnt = 0
    IF ((widthline > (1015 * fontpoints))
     AND fontpoints <= 120)
     SET cnt = 1
     WHILE (cnt <= inputstrlen)
       SET asciinum = ichar(substring(cnt,1,input_string))
       IF (((asciinum < 32) OR (asciinum > 253)) )
        SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(inputstrlen
           - cnt),input_string))
        SET inputstrlen -= 1
        SET cnt -= 1
       ELSEIF (asciinum=187)
        SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(inputstrlen
           - cnt),input_string))
        SET inputstrlen -= 1
        IF (bold=0
         AND widthstring > 0)
         SET format_text->output_string_cnt += 1
         IF (mod(format_text->output_string_cnt,10)=1)
          SET stat = alterlist(format_text->output_string,(format_text->output_string_cnt+ 9))
         ENDIF
         SET format_text->output_string[format_text->output_string_cnt].string = notrim(substring(
           startsubstr,(cnt - startsubstr),input_string))
         SET format_text->output_string[format_text->output_string_cnt].bold = bold
         SET format_text->output_string[format_text->output_string_cnt].x_offset = widthtotal
         SET widthtotal += widthstring
         SET widthstring = 0
         SET startsubstr = cnt
        ENDIF
        SET bold = 1
        SET cnt -= 1
       ELSEIF (asciinum=171)
        SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(inputstrlen
           - cnt),input_string))
        SET inputstrlen -= 1
        IF (bold=1
         AND widthstring > 0)
         SET format_text->output_string_cnt += 1
         IF (mod(format_text->output_string_cnt,10)=1)
          SET stat = alterlist(format_text->output_string,(format_text->output_string_cnt+ 9))
         ENDIF
         SET format_text->output_string[format_text->output_string_cnt].string = notrim(substring(
           startsubstr,(cnt - startsubstr),input_string))
         SET format_text->output_string[format_text->output_string_cnt].bold = bold
         SET format_text->output_string[format_text->output_string_cnt].x_offset = widthtotal
         SET widthtotal += widthstring
         SET widthstring = 0
         SET startsubstr = cnt
        ENDIF
        SET bold = 0
        SET cnt -= 1
       ELSE
        IF (bold=0)
         SET widthstring += (fontpoints * metrics->times[asciinum].size)
        ELSE
         SET widthstring += (fontpoints * metrics->times_bold[asciinum].size)
        ENDIF
       ENDIF
       SET cnt += 1
     ENDWHILE
    ENDIF
    IF (widthstring > 0)
     SET format_text->output_string_cnt += 1
     SET stat = alterlist(format_text->output_string,format_text->output_string_cnt)
     SET format_text->output_string[format_text->output_string_cnt].string = substring(startsubstr,((
      inputstrlen - startsubstr)+ 1),input_string)
     SET format_text->output_string[format_text->output_string_cnt].bold = bold
     SET format_text->output_string[format_text->output_string_cnt].x_offset = widthtotal
    ENDIF
    SET widthtotal += widthstring
    SET startsubstr = floor(((x_start+ ((widthline - widthtotal)/ 2.0))+ 0.5))
    IF (startsubstr <= 0)
     SET startsubstr = x_start
    ENDIF
    FOR (temp_indx = 1 TO format_text->output_string_cnt)
      SET format_text->output_string[temp_indx].x_offset = floor((((format_text->output_string[
       temp_indx].x_offset+ startsubstr)/ 1000.0)+ 0.5))
    ENDFOR
    RETURN(floor(((startsubstr/ 1000.0)+ 0.5)))
  END ;Subroutine
  SUBROUTINE (wordwraptimes(input_string=vc,cpi=i2,line_width=i2,bold_start=i2) =i2)
    IF (cpi > 0)
     SET fontpoints = floor(((120.0/ cpi)+ 0.5))
    ELSE
     SET fontpoints = 0
    ENDIF
    SET inputstrlen = textlen(input_string)
    SET widthline = (line_width * 1000)
    SET widthtotal = 0
    SET widthword = 0
    SET widthspace = 0
    SET spacecnt = 0
    SET endword = 1
    SET startsubstr = 1
    SET endlastline = 1
    SET endlastlinepts = 0
    SET state = 0
    SET bold = bold_start
    SET boldstart = 0
    SET nonboldstart = 0
    SET format_text->output_string_cnt = 0
    IF ((widthline > (1015 * fontpoints))
     AND fontpoints <= 120)
     SET cnt = 1
     WHILE (cnt <= inputstrlen)
       SET asciinum = ichar(substring(cnt,1,input_string))
       IF (((asciinum < 32) OR (asciinum > 253)) )
        SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(inputstrlen
           - cnt),input_string))
        SET inputstrlen -= 1
        SET cnt -= 1
       ELSEIF (asciinum=187)
        SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(inputstrlen
           - cnt),input_string))
        SET inputstrlen -= 1
        IF (bold=0)
         SET boldstart = cnt
         IF (((widthword+ widthspace) > 0))
          SET format_text->output_string_cnt += 1
          IF (mod(format_text->output_string_cnt,10)=1)
           SET stat = alterlist(format_text->output_string,(format_text->output_string_cnt+ 9))
          ENDIF
          SET format_text->output_string[format_text->output_string_cnt].string = notrim(substring(
            startsubstr,(cnt - startsubstr),input_string))
          SET format_text->output_string[format_text->output_string_cnt].bold = bold
          SET format_text->output_string[format_text->output_string_cnt].x_offset = floor(((
           endlastlinepts/ 1000.0)+ 0.5))
          IF (state=0)
           SET endlastlinepts = (widthtotal+ widthspace)
          ELSE
           SET endlastlinepts = ((widthtotal+ widthspace)+ widthword)
          ENDIF
          SET startsubstr = cnt
         ENDIF
         SET bold = 1
        ENDIF
        SET cnt -= 1
       ELSEIF (asciinum=171)
        SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(inputstrlen
           - cnt),input_string))
        SET inputstrlen -= 1
        IF (bold=1)
         SET nonboldstart = cnt
         IF (((widthword+ widthspace) > 0))
          SET format_text->output_string_cnt += 1
          IF (mod(format_text->output_string_cnt,10)=1)
           SET stat = alterlist(format_text->output_string,(format_text->output_string_cnt+ 9))
          ENDIF
          SET format_text->output_string[format_text->output_string_cnt].string = notrim(substring(
            startsubstr,(cnt - startsubstr),input_string))
          SET format_text->output_string[format_text->output_string_cnt].bold = bold
          SET format_text->output_string[format_text->output_string_cnt].x_offset = floor(((
           endlastlinepts/ 1000.0)+ 0.5))
          IF (state=0)
           SET endlastlinepts = (widthtotal+ widthspace)
          ELSE
           SET endlastlinepts = ((widthtotal+ widthspace)+ widthword)
          ENDIF
          SET startsubstr = cnt
         ENDIF
         SET bold = 0
        ENDIF
        SET cnt -= 1
       ELSEIF (asciinum=32)
        IF (state=1)
         SET state = 0
         SET spacecnt = 0
         SET widthtotal = ((widthtotal+ widthspace)+ widthword)
         SET widthspace = 0
         SET endword = cnt
        ENDIF
        SET spacecnt += 1
        IF (bold=1)
         SET widthspace += (fontpoints * metrics->times_bold[asciinum].size)
        ELSE
         SET widthspace += (fontpoints * metrics->times[asciinum].size)
        ENDIF
       ELSE
        IF (state=0)
         SET state = 1
         SET widthword = 0
        ENDIF
        IF (bold=1)
         SET widthchar = (fontpoints * metrics->times_bold[asciinum].size)
        ELSE
         SET widthchar = (fontpoints * metrics->times[asciinum].size)
        ENDIF
        IF (widthchar=0)
         SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(
           inputstrlen - cnt),input_string))
         SET inputstrlen -= 1
         SET cnt -= 1
        ELSE
         SET widthword += widthchar
         IF ((((widthtotal+ widthspace)+ widthword) >= widthline))
          IF (endlastline=endword)
           SET endword = cnt
          ENDIF
          IF (((endword - startsubstr) > 0))
           SET format_text->output_string_cnt += 1
           IF (mod(format_text->output_string_cnt,10)=1)
            SET stat = alterlist(format_text->output_string,(format_text->output_string_cnt+ 9))
           ENDIF
           IF (endlastlinepts=0)
            SET format_text->output_string[format_text->output_string_cnt].string = trim(substring(
              startsubstr,(endword - startsubstr),input_string),3)
           ELSE
            SET format_text->output_string[format_text->output_string_cnt].string = substring(
             startsubstr,(endword - startsubstr),input_string)
           ENDIF
           IF (endword=cnt)
            SET startsubstr = cnt
            SET widthword = widthchar
           ELSE
            SET startsubstr = (endword+ spacecnt)
           ENDIF
           SET format_text->output_string[format_text->output_string_cnt].x_offset = floor(((
            endlastlinepts/ 1000.0)+ 0.5))
           SET format_text->output_string[format_text->output_string_cnt].bold = bold
          ENDIF
          SET endlastline = endword
          SET endlastlinepts = 0
          SET widthtotal = 0
          SET widthspace = 0
         ENDIF
        ENDIF
       ENDIF
       SET cnt += 1
     ENDWHILE
     SET format_text->output_string_cnt += 1
     SET stat = alterlist(format_text->output_string,format_text->output_string_cnt)
     SET format_text->output_string[format_text->output_string_cnt].string = substring(startsubstr,((
      inputstrlen - startsubstr)+ 1),input_string)
     SET format_text->output_string[format_text->output_string_cnt].x_offset = floor(((endlastlinepts
      / 1000.0)+ 0.5))
     SET format_text->output_string[format_text->output_string_cnt].bold = bold
    ENDIF
  END ;Subroutine
  SUBROUTINE (characterwraptimes(input_string=vc,cpi=i2,line_width=i2,bold_start=i2) =i2)
    IF (cpi > 0)
     SET fontpoints = floor(((120.0/ cpi)+ 0.5))
    ELSE
     SET fontpoints = 0
    ENDIF
    SET inputstrlen = textlen(input_string)
    SET widthline = (line_width * 1000)
    SET widthtotal = 0
    SET widthword = 0
    SET widthspace = 0
    SET spacecnt = 0
    SET endword = 1
    SET startsubstr = 1
    SET endlastline = 1
    SET endlastlinepts = 0
    SET state = 0
    SET bold = bold_start
    SET boldstart = 0
    SET nonboldstart = 0
    SET format_text->output_string_cnt = 0
    IF ((widthline > (1015 * fontpoints))
     AND fontpoints <= 120)
     SET cnt = 1
     WHILE (cnt <= inputstrlen)
       SET asciinum = ichar(substring(cnt,1,input_string))
       IF (((asciinum < 32) OR (asciinum > 253)) )
        SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(inputstrlen
           - cnt),input_string))
        SET inputstrlen -= 1
        SET cnt -= 1
       ELSEIF (asciinum=187)
        SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(inputstrlen
           - cnt),input_string))
        SET inputstrlen -= 1
        IF (bold=0)
         SET boldstart = cnt
         IF (widthtotal > 0)
          SET endword = cnt
          SET format_text->output_string_cnt += 1
          IF (mod(format_text->output_string_cnt,10)=1)
           SET stat = alterlist(format_text->output_string,(format_text->output_string_cnt+ 9))
          ENDIF
          SET format_text->output_string[format_text->output_string_cnt].string = notrim(substring(
            startsubstr,(endword - startsubstr),input_string))
          SET format_text->output_string[format_text->output_string_cnt].bold = bold
          SET format_text->output_string[format_text->output_string_cnt].x_offset = floor(((
           endlastlinepts/ 1000.0)+ 0.5))
          SET endlastlinepts = widthtotal
          SET startsubstr = cnt
         ENDIF
         SET bold = 1
        ENDIF
        SET cnt -= 1
       ELSEIF (asciinum=171)
        SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(inputstrlen
           - cnt),input_string))
        SET inputstrlen -= 1
        IF (bold=1)
         SET nonboldstart = cnt
         IF (widthtotal > 0)
          SET endword = cnt
          SET format_text->output_string_cnt += 1
          IF (mod(format_text->output_string_cnt,10)=1)
           SET stat = alterlist(format_text->output_string,(format_text->output_string_cnt+ 9))
          ENDIF
          SET format_text->output_string[format_text->output_string_cnt].string = notrim(substring(
            startsubstr,(endword - startsubstr),input_string))
          SET format_text->output_string[format_text->output_string_cnt].bold = bold
          SET format_text->output_string[format_text->output_string_cnt].x_offset = floor(((
           endlastlinepts/ 1000.0)+ 0.5))
          SET endlastlinepts = widthtotal
          SET startsubstr = cnt
         ENDIF
         SET bold = 0
        ENDIF
        SET cnt -= 1
       ELSE
        IF (bold=1)
         SET widthchar = (fontpoints * metrics->times_bold[asciinum].size)
        ELSE
         SET widthchar = (fontpoints * metrics->times[asciinum].size)
        ENDIF
        IF (widthchar=0)
         SET input_string = concat(substring(1,(cnt - 1),input_string),substring((cnt+ 1),(
           inputstrlen - cnt),input_string))
         SET inputstrlen -= 1
         SET cnt -= 1
        ELSE
         IF (((widthtotal+ widthchar) >= widthline))
          SET endword = cnt
          IF (((endword - startsubstr) > 0))
           SET format_text->output_string_cnt += 1
           IF (mod(format_text->output_string_cnt,10)=1)
            SET stat = alterlist(format_text->output_string,(format_text->output_string_cnt+ 9))
           ENDIF
           IF (endlastlinepts=0)
            SET format_text->output_string[format_text->output_string_cnt].string = trim(substring(
              startsubstr,(endword - startsubstr),input_string),3)
           ELSE
            SET format_text->output_string[format_text->output_string_cnt].string = substring(
             startsubstr,(endword - startsubstr),input_string)
           ENDIF
           SET format_text->output_string[format_text->output_string_cnt].x_offset = floor(((
            endlastlinepts/ 1000.0)+ 0.5))
           SET format_text->output_string[format_text->output_string_cnt].bold = bold
          ENDIF
          SET startsubstr = cnt
          SET endlastlinepts = 0
          SET widthtotal = widthchar
         ELSE
          SET widthtotal += widthchar
         ENDIF
        ENDIF
       ENDIF
       SET cnt += 1
     ENDWHILE
     SET format_text->output_string_cnt += 1
     SET stat = alterlist(format_text->output_string,format_text->output_string_cnt)
     SET format_text->output_string[format_text->output_string_cnt].string = substring(startsubstr,((
      inputstrlen - startsubstr)+ 1),input_string)
     SET format_text->output_string[format_text->output_string_cnt].x_offset = floor(((endlastlinepts
      / 1000.0)+ 0.5))
     SET format_text->output_string[format_text->output_string_cnt].bold = bold
    ENDIF
  END ;Subroutine
 ENDIF
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 SUBROUTINE (getcodevalue(code_set=i4,cdf_meaning=c12,code_variable=f8(ref)) =f8)
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_variable)
  IF (((stat != 0) OR (code_variable <= 0)) )
   CALL echo(build("Invalid select on CODE_SET (",code_set,"),  CDF_MEANING(",cdf_meaning,1,
     code_variable,")"))
   SET failed = uar_error
   GO TO exit_script
  ENDIF
 END ;Subroutine
 RECORD t_list(
   1 sch_appt_id = f8
   1 appt_type_cd = f8
   1 appt_type_desc = vc
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 sch_state_cd = f8
   1 state_meaning = c12
   1 sch_event_id = f8
   1 location_cd = f8
   1 appt_reason_free = vc
   1 location_freetext = vc
   1 appt_synonym_cd = f8
   1 appt_synonym_free = vc
   1 duration = i4
   1 appt_scheme_id = f8
   1 req_prsnl_name = vc
   1 primary_resource_cd = f8
   1 primary_resource_mnem = vc
   1 list_cnt = i4
   1 patient[*]
     2 person_id = f8
     2 name = vc
     2 home_phone = vc
     2 mrn = vc
     2 birth_dt_tm = dq8
     2 birth_formatted = vc
     2 sex = vc
     2 age = vc
   1 text = vc
 )
 DECLARE getcodevalue_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE mrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE en_mrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE home_cd = f8 WITH public, noconstant(0.0)
 DECLARE beg_dt_tm2 = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE end_dt_tm2 = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE beg_day_num = i4 WITH public, noconstant(0)
 DECLARE end_day_num = i4 WITH public, noconstant(0)
 DECLARE field30 = c30 WITH public, noconstant(fillstring(30," "))
 DECLARE field15 = c15 WITH public, noconstant(fillstring(15," "))
 DECLARE field20 = c20 WITH public, noconstant(fillstring(20," "))
 DECLARE field25 = c25 WITH public, noconstant(fillstring(25," "))
 DECLARE count2 = i4 WITH public, noconstant(0)
 FREE SET t_record
 RECORD t_record(
   1 t_ind = i4
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 resource_cd = f8
 )
 SET t_record->t_ind = (findstring(" = ", $4,1)+ 3)
 SET t_record->resource_cd = cnvtreal(substring(t_record->t_ind,((size(trim( $4)) - t_record->t_ind)
   + 1), $4))
 SET t_record->t_ind = (findstring(char(34), $3,1)+ 1)
 SET t_record->beg_dt_tm = cnvtdatetime(substring(t_record->t_ind,23, $3))
 SET t_record->t_ind = (findstring(char(34), $2,1)+ 1)
 SET t_record->end_dt_tm = cnvtdatetime(substring(t_record->t_ind,23, $2))
 SET beg_dt_tm2 = substring(14,12, $3)
 SET end_dt_tm2 = substring(14,12, $2)
 SET beg_day_num = parser(value(concat("cnvtdate2(",beg_dt_tm2,'"',",",'"',
    "DD-MMM-YYYY",'"',")")))
 SET end_day_num = parser(value(concat("cnvtdate2(",end_dt_tm2,'"',",",'"',
    "DD-MMM-YYYY",'"',")")))
 DECLARE pref_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE system_disviewlongdur = i4 WITH protect, noconstant(0)
 SET cdf_meaning = "DISVIEWLDUR"
 CALL getcodevalue(23010,cdf_meaning,pref_type_cd)
 DECLARE max_appt_time = f8 WITH protect, noconstant(720)
 SELECT INTO "nl:"
  a.pref_id
  FROM sch_pref a
  PLAN (a
   WHERE a.pref_type_cd=pref_type_cd
    AND a.parent_table="SYSTEM"
    AND a.parent_id=0
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   system_disviewlongdur = a.pref_value,
   CALL echo(a.pref_value)
  WITH nocounter
 ;end select
 IF (system_disviewlongdur > 0)
  SET max_appt_time = (system_disviewlongdur * 25)
  IF (max_appt_time > 720)
   SET max_appt_time = 720
  ENDIF
 ENDIF
 SET getcodevalue_meaning = "MRN"
 CALL getcodevalue(4,getcodevalue_meaning,mrn_cd)
 CALL getcodevalue(319,getcodevalue_meaning,en_mrn_cd)
 SET getcodevalue_meaning = "HOME"
 CALL getcodevalue(43,getcodevalue_meaning,home_cd)
 SELECT INTO  $1
  res_mnem = trim(substring(1,40,r.mnemonic)), a.sch_appt_id, a.beg_dt_tm,
  ep.person_id, p.person_id, ev.sch_event_id,
  ed1.updt_cnt, state_meaning = uar_get_code_display(a.sch_state_cd), sex_disp = uar_get_code_display
  (p.sex_cd),
  req_prsnl_exist = decode(ed2.seq,1,0), reason_exist = decode(ed3.seq,1,0), ena_exist = decode(ena
   .seq,1,0),
  oapr_exist = decode(oapr.seq,1,0), ph_exist = decode(ph.seq,1,0)
  FROM sch_resource r,
   sch_appt a,
   sch_event ev,
   sch_event_patient ep,
   person p,
   person_info pi,
   phone ph2,
   dummyt d1,
   sch_event_disp ed1,
   dummyt d2,
   sch_event_disp ed2,
   dummyt d3,
   encntr_alias ena,
   location l,
   dummyt d4,
   org_alias_pool_reltn oapr,
   person_alias pa,
   dummyt d5,
   sch_event_disp ed3,
   dummyt d6,
   phone ph
  PLAN (r
   WHERE (r.resource_cd=t_record->resource_cd)
    AND r.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND r.active_ind=1)
   JOIN (a
   WHERE a.person_id=r.person_id
    AND a.resource_cd=r.resource_cd
    AND a.beg_dt_tm BETWEEN cnvtdatetime(datetimeadd(t_record->beg_dt_tm,- ((max_appt_time/ 24.0))))
    AND cnvtdatetime(datetimeadd(t_record->end_dt_tm,- ((1.0/ 1440.0))))
    AND a.end_dt_tm BETWEEN cnvtdatetime(datetimeadd(t_record->beg_dt_tm,(1.0/ 1440.0))) AND
   cnvtdatetime(datetimeadd(t_record->end_dt_tm,(max_appt_time/ 24.0)))
    AND a.sch_event_id > 0
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND a.state_meaning IN ("CHECKED IN", "CHECKED OUT", "CONFIRMED", "FINALIZED", "NOSHOW",
   "PENDING", "STANDBY", "SCHEDULED")
    AND ((a.role_meaning=null) OR (a.role_meaning != "PATIENT"))
    AND a.active_ind=1)
   JOIN (ev
   WHERE ev.sch_event_id=a.sch_event_id
    AND ev.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND ev.active_ind=1)
   JOIN (ep
   WHERE ep.sch_event_id=ev.sch_event_id
    AND ep.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND ep.active_ind=1)
   JOIN (p
   WHERE p.person_id=ep.person_id)
   JOIN (l
   WHERE l.location_cd=a.appt_location_cd)
   JOIN (pi
   WHERE (pi.person_id= Outerjoin(p.person_id))
    AND (pi.active_ind= Outerjoin(1))
    AND (pi.info_type_cd= Outerjoin(mf_cs355_userdefined_cd))
    AND (pi.info_sub_type_cd= Outerjoin(mf_cs356_phonepriority_cd))
    AND (pi.value_cd= Outerjoin(mf_cs100068_primary_cd)) )
   JOIN (ph2
   WHERE (ph2.parent_entity_id= Outerjoin(p.person_id))
    AND (ph2.active_ind= Outerjoin(1))
    AND (ph2.parent_entity_name= Outerjoin("PERSON"))
    AND (ph2.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (ph2.phone_type_cd= Outerjoin(mf_cs43_cell_cd)) )
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (ed1
   WHERE ed1.sch_event_id=ev.sch_event_id
    AND ((ed1.schedule_id=0) OR (ed1.schedule_id=a.schedule_id))
    AND ((ed1.sch_appt_id=0) OR (ed1.sch_appt_id=a.sch_appt_id))
    AND ed1.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND ed1.disp_field_id=5
    AND ed1.active_ind=1)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (ed2
   WHERE ed2.sch_event_id=ev.sch_event_id
    AND ed2.schedule_id=0.0
    AND ed2.disp_field_id=8)
   JOIN (d3
   WHERE d3.seq=1)
   JOIN (ena
   WHERE ena.encntr_id=ep.encntr_id
    AND ena.encntr_id > 0
    AND ena.encntr_alias_type_cd=en_mrn_cd
    AND ena.active_ind=1
    AND ena.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ena.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (d4
   WHERE d4.seq=1)
   JOIN (oapr
   WHERE oapr.organization_id=l.organization_id
    AND oapr.alias_entity_name="PERSON_ALIAS"
    AND oapr.alias_entity_alias_type_cd=mrn_cd
    AND oapr.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.alias_pool_cd=oapr.alias_pool_cd
    AND pa.person_alias_type_cd=mrn_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pa.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (d5
   WHERE d5.seq=1)
   JOIN (ed3
   WHERE ed3.sch_event_id=ev.sch_event_id
    AND ((ed3.schedule_id=0) OR (ed3.schedule_id=a.schedule_id))
    AND ((ed3.sch_appt_id=0) OR (ed3.sch_appt_id=a.sch_appt_id))
    AND ed3.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND ed3.disp_field_id=9
    AND ed3.active_ind=1)
   JOIN (d6
   WHERE d6.seq=1)
   JOIN (ph
   WHERE ph.parent_entity_id=p.person_id
    AND ph.parent_entity_name="PERSON"
    AND ph.phone_id != 0
    AND ph.phone_type_cd=home_cd
    AND ph.active_ind=1
    AND ph.phone_type_seq=1
    AND ph.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ph.end_effective_dt_tm >= cnvtdatetime(sysdate))
  ORDER BY cnvtdatetime(a.beg_dt_tm), a.sch_appt_id, p.person_id,
   ph2.phone_type_seq
  HEAD REPORT
   last_proc_day = (value(beg_day_num) - 1), last_appt_day = 0, y_pos = 0
  HEAD a.sch_appt_id
   t_list->sch_appt_id = a.sch_appt_id, t_list->beg_dt_tm = a.beg_dt_tm, t_list->end_dt_tm = a
   .end_dt_tm,
   t_list->sch_state_cd = a.sch_state_cd, t_list->state_meaning = trim(state_meaning,3), t_list->
   sch_event_id = a.sch_event_id,
   t_list->duration = a.duration, t_list->appt_scheme_id = a.appt_scheme_id, t_list->
   appt_synonym_free = trim(ev.appt_synonym_free,3)
   IF (reason_exist)
    t_list->appt_reason_free = trim(ed3.disp_display,3)
   ELSE
    t_list->appt_reason_free = ""
   ENDIF
   IF (req_prsnl_exist)
    t_list->req_prsnl_name = trim(ed2.disp_display,3)
   ELSE
    t_list->req_prsnl_name = ""
   ENDIF
   t_list->primary_resource_mnem = trim(ed1.disp_display,3), t_list->list_cnt = 0, count2 = 0
  HEAD p.person_id
   t_list->list_cnt += 1, count2 = t_list->list_cnt
   IF (mod(count2,10)=1)
    stat = alterlist(t_list->patient,(count2+ 9))
   ENDIF
   t_list->patient[count2].person_id = p.person_id, t_list->patient[count2].name = trim(p
    .name_full_formatted,3)
   IF (size(trim(ph.phone_num,3)) > 0)
    IF (pi.person_info_id > 0)
     t_list->patient[count2].home_phone = cnvtphone(cnvtalphanum(ph.phone_num),ph.phone_format_cd)
    ELSE
     t_list->patient[count2].home_phone = cnvtphone(cnvtalphanum(ph2.phone_num),ph2.phone_format_cd)
    ENDIF
   ELSE
    t_list->patient[count2].home_phone = cnvtphone(cnvtalphanum(ph2.phone_num),ph2.phone_format_cd)
   ENDIF
   t_list->patient[count2].birth_dt_tm = p.birth_dt_tm, t_list->patient[count2].birth_formatted =
   s_format_utc_date(p.birth_dt_tm,validate(p.birth_tz,0),"@SHORTDATE4YR;4;D"), t_list->patient[
   count2].age = cnvtage(cnvtdate(p.birth_dt_tm),1),
   t_list->patient[count2].sex = trim(sex_disp,3)
   IF (ena_exist
    AND ena.encntr_id > 0)
    t_list->patient[count2].mrn = substring(1,20,cnvtalias(ena.alias,ena.alias_pool_cd))
   ELSEIF (oapr_exist)
    t_list->patient[count2].mrn = substring(1,20,cnvtalias(pa.alias,pa.alias_pool_cd))
   ELSE
    t_list->patient[count2].mrn = ""
   ENDIF
  DETAIL
   cur_day = cnvtdate2(format(a.beg_dt_tm,"MMDDYYYY;;DATE"),"MMDDYYYY")
   IF ((last_proc_day < (cur_day - 1)))
    IF (last_appt_day != 0)
     row + 1, "{F/4}{CPI/12}{LPI/6}", y_pos += 26,
     CALL print(calcpos(216,y_pos)), "*** End of ", last_appt_day"@SHORTDATE",
     " appointments ***", BREAK
    ENDIF
    FOR (k = (last_proc_day+ 1) TO (cur_day - 1))
      row 0, row + 1, "{F/4}{CPI/12}{LPI/6}",
      "{POS/72/28}As of: ", curdate"@SHORTDATE", " ",
      curtime"@TIMENOSECONDS;;MTIME", col + 0, "{POS/540/28}Page ",
      curpage"###", row + 1, "{F/4}{CPI/9}{LPI/5}",
      "{POS/184/55}{B}S C H E D U L I N G   M A N A G E M E N T", row + 1,
      "{POS/222/70}{B}Non-worksheet Daily Summary",
      row + 1, "{F/4}{CPI/11}{LPI/6}", "{POS/72/100}{B}Resource: {ENDB}",
      res_mnem, row + 1, "{POS/72/113}{B}Date: {ENDB}",
      k"@SHORTDATE", row + 1, "{POS/72/139}{B}Time",
      "{POS/110/139}{B}Dur", "{POS/146/139}{B}Appointment Type", "{POS/330/139}{B}State",
      "{POS/432/139}{B}Requester", row + 1, "{POS/72/140}{B}{REPEAT/83/_/}",
      row + 1, "{ENDB}", "{POS/216/216}*** End of ",
      k"@SHORTDATE", " appointments ***", BREAK
    ENDFOR
    last_proc_day = (cur_day - 1)
   ENDIF
  FOOT  a.sch_appt_id
   stat = alterlist(t_list->patient,t_list->list_cnt),
   CALL echorecord(t_list), cur_day = cnvtdate2(format(a.beg_dt_tm,"MMDDYYYY;;DATE"),"MMDDYYYY")
   IF (y_pos > 666)
    "{F/4}{CPI/12}{LPI/6}"
    IF (last_appt_day=cur_day)
     row + 1, y_pos += 26,
     CALL print(calcpos(252,y_pos)),
     "*** To be continued ***"
    ELSE
     row + 1, y_pos += 26,
     CALL print(calcpos(216,y_pos)),
     "*** End of ", last_appt_day"@SHORTDATE", " appointments ***"
    ENDIF
    BREAK, row 0, row + 1,
    "{POS/72/28}As of: ", curdate"@SHORTDATE", " ",
    curtime"@TIMENOSECONDS;;MTIME", col + 0, "{POS/540/28}Page ",
    curpage"###", row + 1, "{F/4}{CPI/9}{LPI/5}",
    "{POS/184/55}{B}S C H E D U L I N G   M A N A G E M E N T", row + 1,
    "{POS/222/70}{B}Non-worksheet Daily Summary",
    row + 1, "{F/4}{CPI/11}{LPI/6}", "{POS/72/100}{B}Resource: {ENDB}",
    res_mnem, row + 1, "{POS/72/113}{B}Date: {ENDB}",
    cur_day"@SHORTDATE", row + 1, "{POS/72/139}{B}Time",
    "{POS/110/139}{B}Dur", "{POS/146/139}{B}Appointment Type", "{POS/330/139}{B}State",
    "{POS/432/139}{B}Requester", row + 1, "{POS/72/140}{B}{REPEAT/83/_/}",
    row + 1, "{ENDB}", y_pos = 153
   ENDIF
   IF ((last_proc_day=(cur_day - 1)))
    "{F/4}{CPI/12}{LPI/6}"
    IF ((last_appt_day=(cur_day - 1)))
     row + 1, y_pos += 26,
     CALL print(calcpos(216,y_pos)),
     "*** End of ", last_appt_day"@SHORTDATE", " appointments ***"
     IF (last_appt_day != 0)
      BREAK
     ENDIF
    ENDIF
    row 0, row + 1, "{POS/72/28}As of: ",
    curdate"@SHORTDATE", " ", curtime"@TIMENOSECONDS;;MTIME",
    col + 0, "{POS/540/28}Page ", curpage"###",
    row + 1, "{F/4}{CPI/9}{LPI/5}", "{POS/184/55}{B}S C H E D U L I N G   M A N A G E M E N T",
    row + 1, "{POS/222/70}{B}Non-worksheet Daily Summary", row + 1,
    "{F/4}{CPI/11}{LPI/6}", "{POS/72/100}{B}Resource: {ENDB}", res_mnem,
    row + 1, "{POS/72/113}{B}Date: {ENDB}", cur_day"@SHORTDATE",
    row + 1, "{POS/72/139}{B}Time", "{POS/110/139}{B}Dur",
    "{POS/146/139}{B}Appointment Type", "{POS/330/139}{B}State", "{POS/432/139}{B}Requester",
    row + 1, "{POS/72/140}{B}{REPEAT/83/_/}", row + 1,
    "{ENDB}", y_pos = 153, last_proc_day = cur_day
   ENDIF
   "{F/4}{CPI/12}{LPI/6}",
   CALL print(calcpos(72,y_pos)), t_list->beg_dt_tm"@TIMENOSECONDS",
   CALL print(calcpos(110,y_pos)), t_list->duration"####"
   IF (size(t_list->appt_synonym_free) > 30)
    field30 = substring(1,30,t_list->appt_synonym_free),
    CALL print(calcpos(146,y_pos)), field30
   ELSE
    CALL print(calcpos(146,y_pos)), t_list->appt_synonym_free
   ENDIF
   IF (size(t_list->state_meaning) > 12)
    field12 = substring(1,12,t_list->state_meaning),
    CALL print(calcpos(330,y_pos)), field12
   ELSE
    CALL print(calcpos(330,y_pos)), t_list->state_meaning
   ENDIF
   IF (size(t_list->req_prsnl_name) > 30)
    field30 = substring(1,30,t_list->req_prsnl_name),
    CALL print(calcpos(432,y_pos)), field30
   ELSE
    CALL print(calcpos(432,y_pos)), t_list->req_prsnl_name
   ENDIF
   IF ((t_list->list_cnt > 0))
    FOR (i = 1 TO t_list->list_cnt)
      y_pos += 13, col 0, row + 1,
      "{B}",
      CALL print(calcpos(72,y_pos)), "Person: ",
      "{ENDB}", col + 0
      IF (size(t_list->patient[i].name) > 25)
       field25 = substring(1,25,t_list->patient[i].name),
       CALL print(calcpos(112,y_pos)), field25
      ELSE
       CALL print(calcpos(112,y_pos)), t_list->patient[i].name
      ENDIF
      y_pos += 13, col 0, row + 1,
      "{B}",
      CALL print(calcpos(72,y_pos)), "Primary Phone: ",
      "{ENDB}", col + 0
      IF (size(t_list->patient[i].home_phone) > 25)
       field25 = substring(1,25,t_list->patient[i].home_phone),
       CALL print(calcpos(144,y_pos)), field25
      ELSE
       CALL print(calcpos(144,y_pos)), t_list->patient[i].home_phone
      ENDIF
      row + 1, "{B}",
      CALL print(calcpos(216,y_pos)),
      "MRN: ", "{ENDB}", col + 0
      IF (size(t_list->patient[i].mrn) > 20)
       field20 = substring(1,20,t_list->patient[i].mrn),
       CALL print(calcpos(250,y_pos)), field20
      ELSE
       CALL print(calcpos(250,y_pos)), t_list->patient[i].mrn
      ENDIF
      "{B}", col + 0,
      CALL print(calcpos(355,y_pos)),
      "DOB: ", "{ENDB}", col + 0,
      CALL print(calcpos(385,y_pos)), t_list->patient[i].birth_formatted, col + 0,
      "{B}",
      CALL print(calcpos(436,y_pos)), "Sex: ",
      "{ENDB}", col + 0,
      CALL print(calcpos(477,y_pos)),
      t_list->patient[i].sex
    ENDFOR
   ENDIF
   y_pos += 13, row + 1
   IF ((t_list->appt_reason_free > ""))
    "{B}", col + 0,
    CALL print(calcpos(72,y_pos)),
    "Reason: ", "{ENDB}", col + 0,
    CALL wordwraptimes(t_list->appt_reason_free,15,330,0), x_pos = 112
    FOR (k = 1 TO format_text->output_string_cnt)
      t_list->text = format_text->output_string[k].string,
      CALL print(calcpos(x_pos,y_pos)), t_list->text,
      y_pos += 13, row + 1
    ENDFOR
    row + 1
   ENDIF
   y_pos += 26, last_appt_day = cur_day
  FOOT REPORT
   "{F/4}{CPI/12}{LPI/6}"
   IF (last_proc_day <= end_day_num)
    row + 1, y_pos += 26
    IF (last_appt_day != 0)
     CALL print(calcpos(216,y_pos)), "*** End of ", last_appt_day"@SHORTDATE",
     " appointments ***"
    ENDIF
    IF (last_proc_day < end_day_num)
     IF (last_appt_day != 0)
      BREAK
     ENDIF
    ENDIF
    FOR (j = (last_proc_day+ 1) TO end_day_num)
      row 0, row + 1, "{POS/72/28}As of: ",
      curdate"@SHORTDATE", " ", curtime"@TIMENOSECONDS;;MTIME",
      col + 0, "{POS/540/28}Page ", curpage"###",
      row + 1, "{F/4}{CPI/9}{LPI/5}", "{POS/184/55}{B}S C H E D U L I N G   M A N A G E M E N T",
      row + 1, "{POS/222/70}{B}Non-worksheet Daily Summary", row + 1,
      "{F/4}{CPI/11}{LPI/6}", "{POS/72/100}{B}Resource: {ENDB}", res_mnem,
      row + 1, "{POS/72/113}{B}Date: {ENDB}", j"@SHORTDATE",
      row + 1, "{POS/72/139}{B}Time", "{POS/110/139}{B}Dur",
      "{POS/146/139}{B}Appointment Type", "{POS/330/139}{B}State", "{POS/432/139}{B}Requester",
      row + 1, "{POS/72/140}{B}{REPEAT/83/_/}", row + 1,
      "{ENDB}", "{POS/216/180}*** End of ", j"@SHORTDATE",
      " appointments ***"
      IF (j != end_day_num)
       BREAK
      ENDIF
    ENDFOR
   ENDIF
   y_pos += 18, "{F/4}{CPI/12}{LPI/6}", row + 1,
   col 0,
   CALL print(calcpos(234,756)), "* * * E N D   O F   R E P O R T * * *"
  WITH nullreport, nocounter, dio = postscript,
   maxcol = 220, outerjoin = d1, dontcare = ed1,
   outerjoin = d2, dontcare = ed2, outerjoin = d3,
   dontcare = ena, outerjoin = d4, dontcare = oapr,
   outerjoin = d5, dontcare = ed3, outerjoin = d6,
   dontcare = ph, formfeed = post, rdbcboreparse
 ;end select
 SUBROUTINE (getcodevalue(code_set=i4,cdf_meaning=c12,code_variable=f8(ref)) =f8)
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_variable)
  IF (((stat != 0) OR (code_variable <= 0)) )
   CALL echo(build("Invalid select on CODE_SET (",code_set,"),  CDF_MEANING(",cdf_meaning,")"))
   GO TO exit_script
  ENDIF
 END ;Subroutine
#exit_script
END GO
