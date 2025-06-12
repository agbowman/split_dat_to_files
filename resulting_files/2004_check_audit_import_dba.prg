CREATE PROGRAM 2004_check_audit_import:dba
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
 FREE RECORD requestin
 RECORD requestin(
   1 list_0[*]
     2 name = vc
     2 name_desc = vc
     2 name_disp = vc
     2 type = vc
     2 type_desc = vc
     2 type_disp = vc
     2 req_nbr = i4
     2 name_nbr = i4
     2 type_nbr = i4
     2 event_nbr = i4
 )
 DECLARE rdm_unique_stat = i2 WITH protect, noconstant(0)
 DECLARE rdm_first_one = c1 WITH protect, noconstant(" ")
 DECLARE rdm_unique_cnt = i4 WITH protect, noconstant(0)
 DECLARE rdm_line_data = c2000 WITH protect, noconstant(" ")
 DECLARE rdm_field_number = i4 WITH protect, noconstant(0)
 DECLARE rdm_check_char = c1 WITH protect, noconstant(" ")
 DECLARE rdm_check_pos = i4 WITH protect, noconstant(0)
 DECLARE rdm_found_field = c255 WITH protect, noconstant(" ")
 DECLARE rdm_logical = c40 WITH protect, noconstant(" ")
 DECLARE audit_parser_string = vc WITH protect, noconstant(" ")
 IF (validate(rdm_2004_csv_file,"*")="*")
  DECLARE rdm_2004_csv_file = vc WITH protect, noconstant("cer_install:2004_audit_events.csv")
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Audit Event Data successfully imported."
 SET audit_parser_string = concat(audit_parser_string,'set logical rdm_logical "',rdm_2004_csv_file,
  '" go')
 CALL parser(audit_parser_string)
 FREE DEFINE rtl2
 DEFINE rtl2 "rdm_logical"
 SELECT INTO "nl:"
  t.line
  FROM rtl2t t
  WHERE t.line > " "
  HEAD REPORT
   rdm_unique_stat = alterlist(requestin->list_0,50), rdm_unique_cnt = 0, rdm_line_data = fillstring(
    2000," "),
   rdm_first_one = "Y"
  DETAIL
   IF (rdm_first_one="N")
    rdm_unique_cnt = (rdm_unique_cnt+ 1)
    IF (mod(rdm_unique_cnt,50)=1
     AND rdm_unique_cnt != 1)
     rdm_unique_stat = alterlist(requestin->list_0,(rdm_unique_cnt+ 49))
    ENDIF
    rdm_line_data = t.line, rdm_field_number = 1, rdm_check_pos = 0
    WHILE (rdm_field_number <= 7)
      IF (rdm_field_number IN (1, 2)
       AND '"'=substring(1,1,rdm_line_data))
       rdm_check_char = " ", rdm_check_pos = 1
       WHILE (rdm_check_pos <= 2000
        AND rdm_check_char != '"')
        rdm_check_pos = (rdm_check_pos+ 1),rdm_check_char = substring(rdm_check_pos,1,rdm_line_data)
       ENDWHILE
       rdm_found_field = substring(2,(rdm_check_pos - 2),rdm_line_data)
      ELSE
       rdm_check_char = " ", rdm_check_pos = 0
       WHILE (rdm_check_pos <= 2000
        AND rdm_check_char != ",")
        rdm_check_pos = (rdm_check_pos+ 1),rdm_check_char = substring(rdm_check_pos,1,rdm_line_data)
       ENDWHILE
       rdm_found_field = substring(1,(rdm_check_pos - 1),rdm_line_data)
      ENDIF
      rdm_field_number, col + 10, rdm_found_field,
      row + 1
      CASE (rdm_field_number)
       OF 1:
        requestin->list_0[rdm_unique_cnt].name = rdm_found_field
       OF 2:
        requestin->list_0[rdm_unique_cnt].name_desc = rdm_found_field
       OF 3:
        requestin->list_0[rdm_unique_cnt].name_disp = rdm_found_field
       OF 4:
        requestin->list_0[rdm_unique_cnt].type = rdm_found_field
       OF 5:
        requestin->list_0[rdm_unique_cnt].type_desc = rdm_found_field
       OF 6:
        requestin->list_0[rdm_unique_cnt].type_disp = rdm_found_field
       OF 7:
        requestin->list_0[rdm_unique_cnt].req_nbr = cnvtint(rdm_found_field)
      ENDCASE
      IF (rdm_field_number IN (1, 2)
       AND '"'=substring(1,1,rdm_line_data))
       rdm_line_data = substring((rdm_check_pos+ 2),2000,rdm_line_data)
      ELSE
       rdm_line_data = substring((rdm_check_pos+ 1),2000,rdm_line_data)
      ENDIF
      rdm_field_number = (rdm_field_number+ 1)
    ENDWHILE
    name_nbr = 0, type_nbr = 0, event_nbr = 0
   ENDIF
   rdm_first_one = "N"
  WITH nocounter, maxcol = 2100
 ;end select
 SET stat = alterlist(requestin->list_0,rdm_unique_cnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rdm_unique_cnt)),
   audit_name_def n
  PLAN (d)
   JOIN (n
   WHERE (requestin->list_0[d.seq].name=n.audit_name)
    AND (requestin->list_0[d.seq].name_desc=n.description)
    AND (requestin->list_0[d.seq].name_disp=n.display_name))
  DETAIL
   readme_data->status = "F", readme_data->message = "Failed inserting into the audit_name_def table"
  WITH outerjoin = d, dontexist
 ;end select
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rdm_unique_cnt)),
   audit_name_def n
  PLAN (d)
   JOIN (n
   WHERE (requestin->list_0[d.seq].name=n.audit_name)
    AND (requestin->list_0[d.seq].name_desc=n.description)
    AND (requestin->list_0[d.seq].name_disp=n.display_name))
  DETAIL
   requestin->list_0[d.seq].name_nbr = n.audit_name_def_nbr
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rdm_unique_cnt)),
   audit_type_def t
  PLAN (d)
   JOIN (t
   WHERE (requestin->list_0[d.seq].type=t.audit_type)
    AND (requestin->list_0[d.seq].type_desc=t.description)
    AND (requestin->list_0[d.seq].type_disp=t.display_name))
  DETAIL
   readme_data->status = "F", readme_data->message = "Failed inserting into the audit_type_def table"
  WITH outerjoin = d, dontexist
 ;end select
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rdm_unique_cnt)),
   audit_type_def t
  PLAN (d)
   JOIN (t
   WHERE (requestin->list_0[d.seq].type=t.audit_type)
    AND (requestin->list_0[d.seq].type_desc=t.description)
    AND (requestin->list_0[d.seq].type_disp=t.display_name))
  DETAIL
   requestin->list_0[d.seq].type_nbr = t.audit_type_def_nbr
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rdm_unique_cnt)),
   audit_event e
  PLAN (d)
   JOIN (e
   WHERE (requestin->list_0[d.seq].name_nbr=e.audit_name_def_nbr)
    AND (requestin->list_0[d.seq].type_nbr=e.audit_type_def_nbr))
  DETAIL
   readme_data->status = "F", readme_data->message = "Failed inserting into the audit_event table"
  WITH outerjoin = d, dontexist
 ;end select
 IF ((readme_data->status="F"))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rdm_unique_cnt)),
   audit_event e
  PLAN (d)
   JOIN (e
   WHERE (requestin->list_0[d.seq].name_nbr=e.audit_name_def_nbr)
    AND (requestin->list_0[d.seq].type_nbr=e.audit_type_def_nbr))
  DETAIL
   requestin->list_0[d.seq].event_nbr = e.audit_event_nbr
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rdm_unique_cnt)),
   audit_request r
  PLAN (d
   WHERE (requestin->list_0[d.seq].req_nbr != 0))
   JOIN (r
   WHERE (requestin->list_0[d.seq].event_nbr=r.audit_event_nbr)
    AND (requestin->list_0[d.seq].req_nbr=r.request_nbr))
  DETAIL
   readme_data->status = "F", readme_data->message = "Failed inserting into the audit_request table"
  WITH outerjoin = d, dontexist
 ;end select
#exit_script
END GO
