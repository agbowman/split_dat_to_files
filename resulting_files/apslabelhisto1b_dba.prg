CREATE PROGRAM apslabelhisto1b:dba
 RECORD label(
   1 qual[*]
     2 field[*]
       3 data = c15
 )
 RECORD col(
   1 count = i2
   1 qual[*]
     2 xpos = i2
     2 ypos = i2
 )
#script
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET mrn_alias_type_cd = 0.0
 SET encounter_alias_type_cd = 0.0
 SET epr_admit_doc_cd = 0.0
 FOR (r = 1 TO size(data->resrc,5))
   FOR (l = 1 TO size(data->resrc[r].label,5))
     SELECT INTO "nl:"
      a.tag_disp
      FROM ap_tag a
      WHERE (data->resrc[r].label[l].case_specimen_tag_cd=a.tag_id)
      DETAIL
       data->resrc[r].label[l].case_specimen_tag_disp = a.tag_disp
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      a.tag_disp
      FROM ap_tag a
      PLAN (a
       WHERE (data->resrc[r].label[l].cassette_tag_cd=a.tag_id))
      DETAIL
       data->resrc[r].label[l].cassette_tag_disp = a.tag_disp
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      aptgr.tag_separator
      FROM ap_prefix_tag_group_r aptgr
      WHERE (data->resrc[r].label[l].prefix_cd=aptgr.prefix_id)
       AND 2=aptgr.tag_type_flag
      DETAIL
       data->resrc[r].label[l].cassette_sep_disp = aptgr.tag_separator
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      a.tag_disp
      FROM ap_tag a
      PLAN (a
       WHERE (data->resrc[r].label[l].slide_tag_cd=a.tag_id))
      DETAIL
       data->resrc[r].label[l].slide_tag_disp = a.tag_disp
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      aptgr.tag_separator
      FROM ap_prefix_tag_group_r aptgr
      WHERE (data->resrc[r].label[l].prefix_cd=aptgr.prefix_id)
       AND 3=aptgr.tag_type_flag
      DETAIL
       data->resrc[r].label[l].slide_sep_disp = aptgr.tag_separator
      WITH nocounter
     ;end select
     SET data->resrc[r].label[l].spec_blk_sld_tag_disp = build(data->resrc[r].label[l].
      case_specimen_tag_disp,data->resrc[r].label[l].cassette_sep_disp,data->resrc[r].label[l].
      cassette_tag_disp,data->resrc[r].label[l].slide_sep_disp,data->resrc[r].label[l].slide_tag_disp
      )
     SET data->resrc[r].label[l].spec_blk_tag_disp = build(data->resrc[r].label[l].
      case_specimen_tag_disp,data->resrc[r].label[l].cassette_sep_disp,data->resrc[r].label[l].
      cassette_tag_disp)
     SET data->resrc[r].label[l].blk_sld_tag_disp = build(data->resrc[r].label[l].cassette_sep_disp,
      data->resrc[r].label[l].cassette_tag_disp,data->resrc[r].label[l].slide_sep_disp,data->resrc[r]
      .label[l].slide_tag_disp)
     SET data->resrc[r].label[l].acc_site_pre_yy_nbr = build(substring(1,5,data->resrc[r].label[l].
       accession_nbr),"-",substring(6,2,data->resrc[r].label[l].accession_nbr),"-",substring(10,2,
       data->resrc[r].label[l].accession_nbr),
      "-",substring(12,7,data->resrc[r].label[l].accession_nbr))
     SET data->resrc[r].label[l].acc_site = build(substring(1,5,data->resrc[r].label[l].accession_nbr
       ))
     SET data->resrc[r].label[l].acc_pre = build(substring(6,2,data->resrc[r].label[l].accession_nbr)
      )
     SET data->resrc[r].label[l].acc_yy = build(substring(10,2,data->resrc[r].label[l].accession_nbr)
      )
     SET data->resrc[r].label[l].acc_yyyy = build(substring(8,4,data->resrc[r].label[l].accession_nbr
       ))
     SET data->resrc[r].label[l].acc_nbr = build(substring(12,7,data->resrc[r].label[l].accession_nbr
       ))
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  d1.seq, d2.seq
  FROM (dummyt d1  WITH seq = value(size(data->resrc,5))),
   (dummyt d2  WITH seq = value(data->maxlabel))
  PLAN (d1
   WHERE 1 <= d1.seq)
   JOIN (d2
   WHERE d2.seq <= size(data->resrc[d1.seq].label,5))
  HEAD REPORT
   lcnt = 0
  DETAIL
   lcnt = (lcnt+ 1), stat = alterlist(label->qual,lcnt), stat = alterlist(label->qual[lcnt].field,6),
   label->qual[lcnt].field[1].data = data->resrc[d1.seq].label[d2.seq].fmt_accession_nbr, label->
   qual[lcnt].field[2].data = substring(1,15,data->resrc[d1.seq].label[d2.seq].name_full_formatted),
   label->qual[lcnt].field[3].data = substring(1,15,data->resrc[d1.seq].label[d2.seq].mnemonic),
   label->qual[lcnt].field[4].data = substring(1,15,data->resrc[d1.seq].label[d2.seq].
    spec_blk_sld_tag_disp), label->qual[lcnt].field[5].data = substring(1,15,data->
    current_dt_tm_string), label->qual[lcnt].field[6].data = substring(6,15,data->resrc[d1.seq].
    label[d2.seq].accession_nbr)
  WITH nocounter
 ;end select
 SET col->count = 4
 SET stat = alterlist(col->qual,col->count)
 SET col->qual[1].xpos = 0
 SET col->qual[1].ypos = 0
 SET col->qual[2].xpos = 75
 SET col->qual[2].ypos = 0
 SET col->qual[3].xpos = 150
 SET col->qual[3].ypos = 0
 SET col->qual[4].xpos = 225
 SET col->qual[4].ypos = 0
 EXECUTE cpm_create_file_name_logical "aps_hist1b", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  x = 0
  HEAD REPORT
   labs = 0, nlab = 0
  DETAIL
   home_x_pos = printer->label_x_pos, home_y_pos = printer->label_y_pos
   FOR (labs = 1 TO ((size(label->qual,5)/ col->count)+ 1))
    FOR (ncol = 1 TO col->count)
     nlab = (nlab+ 1),
     IF (nlab <= size(label->qual,5))
      CALL print(calcpos(((home_x_pos+ col->qual[ncol].xpos)+ 0),((home_y_pos+ col->qual[ncol].ypos)
       + 0))), "{LPI/4}{CPI/18}{FONT/3}", label->qual[nlab].field[1].data,
      row + 1,
      CALL print(calcpos(((home_x_pos+ col->qual[ncol].xpos)+ 0),((home_y_pos+ col->qual[ncol].ypos)
       + 14))), "{LPI/8}{CPI/18}{FONT/0}",
      label->qual[nlab].field[2].data, row + 1,
      CALL print(calcpos(((home_x_pos+ col->qual[ncol].xpos)+ 0),((home_y_pos+ col->qual[ncol].ypos)
       + 21))),
      "{LPI/8}{CPI/18}{FONT/0}", label->qual[nlab].field[4].data, row + 1,
      CALL print(calcpos(((home_x_pos+ col->qual[ncol].xpos)+ 0),((home_y_pos+ col->qual[ncol].ypos)
       + 28))), "{LPI/8}{CPI/18}{FONT/0}", label->qual[nlab].field[3].data,
      row + 1,
      CALL print(calcpos(((home_x_pos+ col->qual[ncol].xpos)+ 2),((home_y_pos+ col->qual[ncol].ypos)
       + 36))), "{LPI/5}{CPI/18}{BCR/250}{FONT/31/1}",
      CALL print(build("*>:",substring(1,3,cnvtalphanum(label->qual[nlab].field[6].data)),">5",
       substring(4,12,cnvtalphanum(label->qual[nlab].field[6].data)),"03*{font/0}")), row + 1,
      CALL print(calcpos(((home_x_pos+ col->qual[ncol].xpos)+ 2),((home_y_pos+ col->qual[ncol].ypos)
       + 56))),
      "{FONT/0/1}{LPI/12}{CPI/34}", "Cerner PathNet AP", row + 1
     ENDIF
    ENDFOR
    ,
    IF (nlab <= size(label->qual,5))
     "{NP}"
    ENDIF
   ENDFOR
  WITH nocounter, dio = 16, format = undefined,
   noformfeed
 ;end select
END GO
