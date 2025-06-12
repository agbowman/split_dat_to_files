CREATE PROGRAM apslabelhisto1l:dba
 RECORD label(
   1 qual[*]
     2 line[5]
       3 data = c15
 )
 RECORD row(
   1 qual[5]
     2 col[6]
       3 start = i2
 )
#script
 SET nmaxcols = 6
 SET nmaxrows = 5
 SET row->qual[1].col[1].start = 0
 SET row->qual[1].col[2].start = 17
 SET row->qual[1].col[3].start = 34
 SET row->qual[1].col[4].start = 51
 SET row->qual[1].col[5].start = 68
 SET row->qual[1].col[6].start = 85
 SET row->qual[2].col[1].start = 0
 SET row->qual[2].col[2].start = 17
 SET row->qual[2].col[3].start = 34
 SET row->qual[2].col[4].start = 51
 SET row->qual[2].col[5].start = 68
 SET row->qual[2].col[6].start = 85
 SET row->qual[3].col[1].start = 0
 SET row->qual[3].col[2].start = 17
 SET row->qual[3].col[3].start = 34
 SET row->qual[3].col[4].start = 51
 SET row->qual[3].col[5].start = 68
 SET row->qual[3].col[6].start = 85
 SET row->qual[4].col[1].start = 0
 SET row->qual[4].col[2].start = 17
 SET row->qual[4].col[3].start = 34
 SET row->qual[4].col[4].start = 51
 SET row->qual[4].col[5].start = 68
 SET row->qual[4].col[6].start = 85
 SET row->qual[5].col[1].start = 0
 SET row->qual[5].col[2].start = 17
 SET row->qual[5].col[3].start = 34
 SET row->qual[5].col[4].start = 51
 SET row->qual[5].col[5].start = 68
 SET row->qual[5].col[6].start = 85
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
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].sex_cd)
     SET data->resrc[r].label[l].sex_disp = cdinfo->display
     SET data->resrc[r].label[l].sex_desc = cdinfo->description
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
   lcnt = (lcnt+ 1), stat = alterlist(label->qual,lcnt), label->qual[lcnt].line[1].data = data->
   resrc[d1.seq].label[d2.seq].fmt_accession_nbr,
   label->qual[lcnt].line[2].data = substring(1,15,data->resrc[d1.seq].label[d2.seq].
    name_full_formatted), label->qual[lcnt].line[3].data = substring(1,15,data->resrc[d1.seq].label[
    d2.seq].spec_blk_sld_tag_disp), label->qual[lcnt].line[4].data = substring(1,15,data->resrc[d1
    .seq].label[d2.seq].mnemonic),
   label->qual[lcnt].line[5].data = substring(1,15,data->current_dt_tm_string)
  WITH nocounter
 ;end select
 EXECUTE cpm_create_file_name_logical "aps_hist1l", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO reply->print_status_data.print_filename
  x = 0
  DETAIL
   nclab = 0, nlab = 0
   FOR (labs = 1 TO ((size(label->qual,5)/ nmaxcols)+ 1))
     nrow = 0, row + 2
     WHILE (nrow < nmaxrows)
       nrow = (nrow+ 1), ncol = 0, row + 1,
       nlab = nclab
       WHILE (ncol < nmaxcols)
         ncol = (ncol+ 1), col row->qual[nrow].col[ncol].start, nlab = (nlab+ 1)
         IF (nlab <= size(label->qual,5))
          label->qual[nlab].line[nrow].data
         ENDIF
       ENDWHILE
     ENDWHILE
     nclab = (nclab+ nmaxcols)
   ENDFOR
  FOOT REPORT
   row + 1, col 20, "End of Label Run"
  WITH nocounter, noformfeed
 ;end select
END GO
