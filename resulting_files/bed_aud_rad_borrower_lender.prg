CREATE PROGRAM bed_aud_rad_borrower_lender
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
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
  )
 ENDIF
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM borrower_lender b
   PLAN (b)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 15000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,10)
 SET reply->collist[1].header_text = "Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Relationship"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Mailing Street Address"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Street Address 2"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Mailing City"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Mailing State"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Mailing Zip Code"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Phone Number"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Loan Interval"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Contact Name"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SELECT INTO "NL:"
  b.name, b.borrower_lender_ind, a.street_addr,
  a.street_addr2, a.city, a.state_cd,
  c.display, a.zipcode, p.phone_num,
  be.def_loan_interval, b.contact_name, b.borrower_lender_id
  FROM borrower_lender b,
   borrowing_entity be,
   address a,
   phone p,
   dummyt d1,
   dummyt d2,
   code_value c
  PLAN (b
   WHERE b.active_ind=1)
   JOIN (be
   WHERE be.parent_entity_id=b.borrower_lender_id)
   JOIN (d1)
   JOIN (a
   WHERE a.parent_entity_id=b.borrower_lender_id)
   JOIN (d2)
   JOIN (p
   WHERE p.parent_entity_id=a.parent_entity_id)
   JOIN (c
   WHERE a.state_cd=c.code_value)
  ORDER BY b.borrower_lender_ind, b.name
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,25)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,25)=0)
    stat = alterlist(reply->rowlist,(25+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,10), reply->rowlist[cnt].celllist[1].string_value =
   b.name
   CASE (b.borrower_lender_ind)
    OF 0:
     reply->rowlist[cnt].celllist[2].string_value = "Borrower"
    OF 1:
     reply->rowlist[cnt].celllist[2].string_value = "Lender"
   ENDCASE
   reply->rowlist[cnt].celllist[3].string_value = a.street_addr, reply->rowlist[cnt].celllist[4].
   string_value = a.street_addr2, reply->rowlist[cnt].celllist[5].string_value = a.city,
   reply->rowlist[cnt].celllist[6].string_value = c.display, reply->rowlist[cnt].celllist[7].
   string_value = a.zipcode, reply->rowlist[cnt].celllist[8].string_value = p.phone_num,
   reply->rowlist[cnt].celllist[9].string_value = cnvtstring(be.def_loan_interval), reply->rowlist[
   cnt].celllist[10].string_value = b.contact_name
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading, outerjoin = d1,
   outerjoin = d2
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("radnet_borrower_lenders.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
