CREATE PROGRAM apsbczb_cl1300_cs_prd:dba
 SET identifier_2dbarcode = "Y"
 SET identifier_disp = "Y"
 SET identifier_type = "Y"
 SET domain = "Y"
 EXECUTE pcs_label_integration_util
 SELECT INTO value(reply->print_status_data.print_filename)
  data
  FROM (dummyt d1  WITH seq = 1)
  HEAD REPORT
   temp_str = fillstring(15," "), identifier_type_str = fillstring(15," "), identifier_disp_str =
   fillstring(40," "),
   domain_str = fillstring(15," "), label_x_pos = 0, label_y_pos = 0,
   label_pos = 1, max_r = 0, max_l = 0,
   y_offset = 0, linesleft = 0, startpos = 0,
   len = 0
  DETAIL
   home_x_pos = printer->label_x_pos, home_y_pos = printer->label_y_pos, max_r = size(data->resrc,5)
   FOR (r_index = 1 TO max_r)
    max_l = size(data->resrc[r_index].label,5),
    FOR (l_index = 1 TO max_l)
      CASE (label_pos)
       OF 1:
        label_x_pos = (home_x_pos+ 0)
       OF 2:
        label_x_pos = (home_x_pos+ 68)
       OF 3:
        label_x_pos = (home_x_pos+ 136)
       ELSE
        label_x_pos = (home_x_pos+ 204)
      ENDCASE
      label_y_pos = (home_y_pos+ 0),
      CALL print(calcpos((3+ label_x_pos),(2+ label_y_pos))), "{LPI/14}{CPI/17}{FONT/42/5}",
      CALL print(build("*",data->resrc[r_index].label[l_index].identifier_code,"*{font/0}")), row + 3,
      identifier_type_str = substring(1,15,data->resrc[r_index].label[l_index].identifier_type),
      y_offset = 29,
      CALL print(calcpos((0+ label_x_pos),(y_offset+ label_y_pos))), "{LPI/8}{CPI/17}{FONT/2}",
      identifier_type_str, row + 3, domain_str = substring(1,15,data->resrc[r_index].label[l_index].
       domain),
      y_offset = 36,
      CALL print(calcpos((0+ label_x_pos),(y_offset+ label_y_pos))), "{LPI/8}{CPI/17}{FONT/2}",
      domain_str, row + 3, identifier_disp_str = substring(1,40,data->resrc[r_index].label[l_index].
       identifier_disp),
      y_offset = 43, linesleft = 3, startpos = 1
      WHILE (linesleft > 0)
       len = getwraptextlen(trim(identifier_disp_str),startpos,15,linesleft),
       IF (len > 0)
        temp_disp = substring(startpos,len,identifier_disp_str),
        CALL print(calcpos((0+ label_x_pos),(y_offset+ label_y_pos))), "{lpi/8}{cpi/17}{font/2}",
        temp_disp, startpos = (startpos+ len), linesleft = (linesleft - 1),
        y_offset = (y_offset+ 7), row + 3
       ELSE
        linesleft = 0
       ENDIF
      ENDWHILE
      row + 3, label_pos = (label_pos+ 1)
      IF (label_pos > 4)
       label_pos = 1, row + 3, "{NP}"
      ENDIF
    ENDFOR
   ENDFOR
  WITH nocounter, dio = 16, format = undefined,
   noformfeed
 ;end select
END GO
