CREATE PROGRAM aprlabelreserve:dba
 DECLARE uar_fmt_accession(p1,p2) = c25
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
 FOR (r = 1 TO size(data->qual,5))
   SET data->qual[r].acc_site_pre_yy_nbr = uar_fmt_accession(data->qual[r].accession_nbr,size(data->
     qual[r].accession_nbr))
 ENDFOR
 SELECT INTO "nl:"
  d1.seq
  FROM (dummyt d1  WITH seq = value(size(data->qual,5)))
  PLAN (d1
   WHERE 1 <= d1.seq)
  HEAD REPORT
   lcnt = 0
  DETAIL
   lcnt = (lcnt+ 1), stat = alterlist(label->qual,lcnt), stat = alterlist(label->qual[lcnt].field,4),
   label->qual[lcnt].field[1].data = substring(3,15,data->qual[d1.seq].acc_site_pre_yy_nbr), label->
   qual[lcnt].field[2].data = substring(1,15,data->qual[d1.seq].person_name), label->qual[lcnt].
   field[3].data = substring(1,15,data->current_dt_tm_string),
   label->qual[lcnt].field[4].data = substring(6,15,data->qual[d1.seq].accession_nbr)
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
       + 28))),
      "{LPI/8}{CPI/18}{FONT/0}", label->qual[nlab].field[3].data, row + 1,
      CALL print(calcpos(((home_x_pos+ col->qual[ncol].xpos)+ 2),((home_y_pos+ col->qual[ncol].ypos)
       + 36))), "{LPI/5}{CPI/18}{BCR/250}{FONT/31/1}",
      CALL print(build("*>:",substring(1,3,cnvtalphanum(label->qual[nlab].field[4].data)),">5",
       substring(4,12,cnvtalphanum(label->qual[nlab].field[4].data)),"03*{font/0}")),
      row + 1,
      CALL print(calcpos(((home_x_pos+ col->qual[ncol].xpos)+ 2),((home_y_pos+ col->qual[ncol].ypos)
       + 56))), "{FONT/0/1}{LPI/12}{CPI/34}",
      "Cerner PathNet AP", row + 1
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
