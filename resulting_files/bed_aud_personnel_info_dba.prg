CREATE PROGRAM bed_aud_personnel_info:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 position_code[*]
      2 position_code_value = f8
    1 physician = i2
    1 username = i2
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i8
      2 total_items = i8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 person[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 name_last = vc
     2 name_first = vc
     2 name_middle = vc
     2 username = vc
     2 position_cd = f8
     2 physician_ind = i2
     2 logical_domain_id = f8
     2 name_title = vc
     2 name_suffix = vc
     2 alias[*]
       3 alias = vc
       3 alias_pool_cd = f8
       3 person_alias_type_cd = f8
     2 address[*]
       3 address_type_cd = f8
       3 address_type_seq = i8
       3 street_addr = vc
       3 street_addr2 = vc
       3 street_addr3 = vc
       3 street_addr4 = vc
       3 city = vc
       3 state = vc
       3 zipcode = c25
       3 country = vc
     2 phone[*]
       3 phone_type_cd = f8
       3 phone_type_seq = i4
       3 phone_num = vc
 )
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET percount = 0
 DECLARE auth_cd = f8
 DECLARE parse_string = vc
 DECLARE poscount = i4
 SET auth_cd = uar_get_code_by("MEANING",8,"AUTH")
 DECLARE cs213_prsnl_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",213,"PRSNL"))
 IF (auth_cd=0)
  SET error_flag = "T"
  SET error_msg = "Unable to read AUTH code, code_set 8"
  GO TO exit_script
 ENDIF
 SET poscount = size(request->position_code,5)
 IF (poscount=0)
  GO TO exit_script
 ENDIF
 IF ((request->physician=1))
  SET parse_string = build(parse_string,"(pr.physician_ind = 1) and ")
 ENDIF
 IF ((request->username=1))
  SET parse_string = build(parse_string,"(textlen(trim(pr.username)) > 0) and ")
 ENDIF
 SET parse_string = build(parse_string,"(pr.data_status_cd = auth_cd)")
 IF ((request->skip_volume_check_ind=0))
  SET high_volume_cnt = 0
  FOR (x = 1 TO poscount)
    SELECT INTO "nl:"
     FROM prsnl pr,
      address a,
      phone ph,
      prsnl_alias pa
     PLAN (pr
      WHERE (pr.position_cd=request->position_code[x].position_code_value)
       AND parser(parse_string)
       AND pr.active_ind=1
       AND cnvtdatetime(curdate,curtime3) BETWEEN pr.beg_effective_dt_tm AND pr.end_effective_dt_tm)
      JOIN (a
      WHERE a.parent_entity_id=outerjoin(pr.person_id))
      JOIN (ph
      WHERE ph.parent_entity_id=outerjoin(pr.person_id))
      JOIN (pa
      WHERE pa.person_id=outerjoin(pr.person_id))
     DETAIL
      high_volume_cnt = (high_volume_cnt+ 1)
     WITH nocounter
    ;end select
  ENDFOR
  CALL echo(build("high volume cnt: ",high_volume_cnt))
  IF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 2
   SET reply->status_data.status = "S"
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   SET reply->status_data.status = "S"
   GO TO exit_script
  ENDIF
 ENDIF
 SET percount = 0
 SELECT INTO "nl:"
  FROM prsnl pr,
   person p,
   (dummyt d  WITH seq = value(size(request->position_code,5)))
  PLAN (pr)
   JOIN (d
   WHERE (pr.position_cd=request->position_code[d.seq].position_code_value)
    AND parser(parse_string)
    AND pr.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN pr.beg_effective_dt_tm AND pr.end_effective_dt_tm)
   JOIN (p
   WHERE p.person_id=pr.person_id)
  ORDER BY pr.name_full_formatted
  DETAIL
   percount = (percount+ 1), stat = alterlist(temp->person,percount), temp->person[percount].
   person_id = pr.person_id,
   temp->person[percount].name_full_formatted = pr.name_full_formatted, temp->person[percount].
   name_last = pr.name_last, temp->person[percount].name_first = pr.name_first,
   temp->person[percount].username = pr.username, temp->person[percount].position_cd = pr.position_cd,
   temp->person[percount].physician_ind = pr.physician_ind,
   temp->person[percount].logical_domain_id = pr.logical_domain_id
  WITH nocounter
 ;end select
 FOR (x = 1 TO percount)
  SET addresscount = 0
  SELECT INTO "nl:"
   FROM address a
   WHERE (a.parent_entity_id=temp->person[x].person_id)
    AND a.active_ind=1
   DETAIL
    addresscount = (addresscount+ 1), stat = alterlist(temp->person[x].address,addresscount), temp->
    person[x].address[addresscount].address_type_cd = a.address_type_cd,
    temp->person[x].address[addresscount].address_type_seq = a.address_type_seq, temp->person[x].
    address[addresscount].street_addr = a.street_addr, temp->person[x].address[addresscount].
    street_addr2 = a.street_addr2,
    temp->person[x].address[addresscount].street_addr3 = a.street_addr3, temp->person[x].address[
    addresscount].street_addr4 = a.street_addr4, temp->person[x].address[addresscount].city = a.city,
    temp->person[x].address[addresscount].state = a.state, temp->person[x].address[addresscount].
    zipcode = a.zipcode, temp->person[x].address[addresscount].country = a.country
   WITH nocounter
  ;end select
 ENDFOR
 FOR (x = 1 TO percount)
  SET phonecount = 0
  SELECT INTO "nl:"
   FROM phone ph
   WHERE (ph.parent_entity_id=temp->person[x].person_id)
    AND ph.active_ind=1
   DETAIL
    phonecount = (phonecount+ 1), stat = alterlist(temp->person[x].phone,phonecount), temp->person[x]
    .phone[phonecount].phone_type_cd = ph.phone_type_cd,
    temp->person[x].phone[phonecount].phone_type_seq = ph.phone_type_seq
    IF (ph.phone_format_cd != 0
     AND isnumeric(ph.phone_num)=1)
     temp->person[x].phone[phonecount].phone_num = cnvtphone(ph.phone_num,ph.phone_format_cd)
    ELSE
     temp->person[x].phone[phonecount].phone_num = ph.phone_num
    ENDIF
   WITH nocounter
  ;end select
 ENDFOR
 FOR (x = 1 TO percount)
  SET aliascount = 0
  SELECT INTO "nl:"
   FROM prsnl_alias pa
   WHERE (pa.person_id=temp->person[x].person_id)
    AND pa.active_ind=1
   DETAIL
    aliascount = (aliascount+ 1), stat = alterlist(temp->person[x].alias,aliascount), temp->person[x]
    .alias[aliascount].alias = pa.alias,
    temp->person[x].alias[aliascount].alias_pool_cd = pa.alias_pool_cd, temp->person[x].alias[
    aliascount].person_alias_type_cd = pa.prsnl_alias_type_cd
   WITH nocounter
  ;end select
 ENDFOR
 FOR (x = 1 TO percount)
   SELECT INTO "nl:"
    FROM person_name pn
    WHERE (pn.person_id=temp->person[x].person_id)
     AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pn.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND pn.name_type_cd=cs213_prsnl_cd
     AND pn.active_ind=1
    DETAIL
     temp->person[x].name_middle = pn.name_middle, temp->person[x].name_title = pn.name_title, temp->
     person[x].name_suffix = pn.name_suffix
    WITH nocounter
   ;end select
 ENDFOR
 SET stat = alterlist(reply->collist,27)
 SET reply->collist[1].header_text = "person_id"
 SET reply->collist[1].data_type = 2
 SET reply->collist[1].hide_ind = 1
 SET reply->collist[2].header_text = "Name Full Formatted"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Last Name"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "First Name"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Middle Name"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Name Title"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Name Suffix"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Username"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Position"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Physician Indicator"
 SET reply->collist[10].data_type = 3
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Logical Domain ID"
 SET reply->collist[11].data_type = 2
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Address Type"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Address Sequence"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Address Line 1"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Address Line 2"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Address Line 3"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = "Address Line 4"
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = "City"
 SET reply->collist[18].data_type = 1
 SET reply->collist[18].hide_ind = 0
 SET reply->collist[19].header_text = "State"
 SET reply->collist[19].data_type = 1
 SET reply->collist[19].hide_ind = 0
 SET reply->collist[20].header_text = "ZIP Code"
 SET reply->collist[20].data_type = 1
 SET reply->collist[20].hide_ind = 0
 SET reply->collist[21].header_text = "Country"
 SET reply->collist[21].data_type = 1
 SET reply->collist[21].hide_ind = 0
 SET reply->collist[22].header_text = "Phone Type"
 SET reply->collist[22].data_type = 1
 SET reply->collist[22].hide_ind = 0
 SET reply->collist[23].header_text = "Phone Sequence"
 SET reply->collist[23].data_type = 1
 SET reply->collist[23].hide_ind = 0
 SET reply->collist[24].header_text = "Phone Number"
 SET reply->collist[24].data_type = 1
 SET reply->collist[24].hide_ind = 0
 SET reply->collist[25].header_text = "Alias"
 SET reply->collist[25].data_type = 1
 SET reply->collist[25].hide_ind = 0
 SET reply->collist[26].header_text = "Alias Pool"
 SET reply->collist[26].data_type = 1
 SET reply->collist[26].hide_ind = 0
 SET reply->collist[27].header_text = "Alias Type"
 SET reply->collist[27].data_type = 1
 SET reply->collist[27].hide_ind = 0
 SET rowcount = 0
 FOR (x = 1 TO percount)
   SET sizealias = size(temp->person[x].alias,5)
   SET sizeaddress = size(temp->person[x].address,5)
   SET sizephone = size(temp->person[x].phone,5)
   SET maxlength = maxval(1,sizealias,sizeaddress,sizephone)
   FOR (y = 1 TO maxlength)
     SET rowcount = (rowcount+ 1)
     SET stat = alterlist(reply->rowlist,rowcount)
     SET stat = alterlist(reply->rowlist[rowcount].celllist,27)
     SET reply->rowlist[rowcount].celllist[1].double_value = temp->person[x].person_id
     SET reply->rowlist[rowcount].celllist[2].string_value = temp->person[x].name_full_formatted
     SET reply->rowlist[rowcount].celllist[3].string_value = temp->person[x].name_last
     SET reply->rowlist[rowcount].celllist[4].string_value = temp->person[x].name_first
     SET reply->rowlist[rowcount].celllist[5].string_value = temp->person[x].name_middle
     SET reply->rowlist[rowcount].celllist[6].string_value = temp->person[x].name_title
     SET reply->rowlist[rowcount].celllist[7].string_value = temp->person[x].name_suffix
     SET reply->rowlist[rowcount].celllist[8].string_value = temp->person[x].username
     SET reply->rowlist[rowcount].celllist[9].string_value = uar_get_code_display(temp->person[x].
      position_cd)
     SET reply->rowlist[rowcount].celllist[10].nbr_value = temp->person[x].physician_ind
     SET reply->rowlist[rowcount].celllist[11].double_value = temp->person[x].logical_domain_id
     IF (y <= sizeaddress)
      SET reply->rowlist[rowcount].celllist[12].string_value = uar_get_code_display(temp->person[x].
       address[y].address_type_cd)
      SET reply->rowlist[rowcount].celllist[13].string_value = cnvtstring(temp->person[x].address[y].
       address_type_seq)
      SET reply->rowlist[rowcount].celllist[14].string_value = temp->person[x].address[y].street_addr
      SET reply->rowlist[rowcount].celllist[15].string_value = temp->person[x].address[y].
      street_addr2
      SET reply->rowlist[rowcount].celllist[16].string_value = temp->person[x].address[y].
      street_addr3
      SET reply->rowlist[rowcount].celllist[17].string_value = temp->person[x].address[y].
      street_addr4
      SET reply->rowlist[rowcount].celllist[18].string_value = temp->person[x].address[y].city
      SET reply->rowlist[rowcount].celllist[19].string_value = temp->person[x].address[y].state
      SET reply->rowlist[rowcount].celllist[20].string_value = temp->person[x].address[y].zipcode
      SET reply->rowlist[rowcount].celllist[21].string_value = temp->person[x].address[y].country
     ENDIF
     IF (y <= sizephone)
      SET reply->rowlist[rowcount].celllist[22].string_value = uar_get_code_display(temp->person[x].
       phone[y].phone_type_cd)
      SET reply->rowlist[rowcount].celllist[23].string_value = cnvtstring(temp->person[x].phone[y].
       phone_type_seq)
      SET reply->rowlist[rowcount].celllist[24].string_value = temp->person[x].phone[y].phone_num
     ENDIF
     IF (y <= sizealias)
      SET reply->rowlist[rowcount].celllist[25].string_value = temp->person[x].alias[y].alias
      SET reply->rowlist[rowcount].celllist[26].string_value = uar_get_code_display(temp->person[x].
       alias[y].alias_pool_cd)
      SET reply->rowlist[rowcount].celllist[27].string_value = uar_get_code_display(temp->person[x].
       alias[y].person_alias_type_cd)
     ENDIF
   ENDFOR
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("personnel_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
