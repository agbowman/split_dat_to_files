CREATE PROGRAM cclstation:dba
 PROMPT
  "Enter MINE/CRT/printer/file:    " = mine,
  "Enter terminal or printer name: " = "*",
  "Enter processor node:           " = "*"
 SELECT INTO  $1
  station = s.station_id, node = s.processor_node, rpt = s.rpt_printer_id,
  status = s.station_status, control = s.printer_control, dio_type = s.dio_ptrt_type,
  printer_ind = s.printer_indicator, queue = s.prt_que
  FROM (sr9930_1 s  WITH datatype(station_id,"C"))
  WHERE (s.station_id= $2)
   AND (s.processor_node= $3)
  WITH format, counter, separator = " ",
   check
 ;end select
END GO
