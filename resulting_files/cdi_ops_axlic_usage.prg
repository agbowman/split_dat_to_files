CREATE PROGRAM cdi_ops_axlic_usage
 DECLARE vrpt = vc WITH noconstant(""), public
 DECLARE voutputrpt = vc WITH noconstant(""), public
 DECLARE voutputcsv = vc WITH noconstant(""), public
 DECLARE vstartdate = vc WITH noconstant(""), public
 DECLARE venddate = vc WITH noconstant(""), public
 DECLARE vstarttime = vc WITH noconstant(""), public
 DECLARE vendtime = vc WITH noconstant(""), public
 DECLARE vlicname = vc WITH noconstant(""), public
 DECLARE vsepfiles = vc WITH noconstant(""), public
 DECLARE valllic = vc WITH noconstant(""), public
 DECLARE vlicgroups = vc WITH noconstant(""), public
 DECLARE startpos = i4 WITH noconstant(0), public
 DECLARE exeline = vc WITH noconstant(""), public
 SET startpos = 1
 SET a = findstring("^",request->batch_selection)
 SET vrpt = substring(startpos,(a - startpos),request->batch_selection)
 SET startpos = (a+ 1)
 SET a = findstring("^",request->batch_selection,startpos)
 SET voutputrpt = substring(startpos,(a - startpos),request->batch_selection)
 SET startpos = (a+ 1)
 SET a = findstring("^",request->batch_selection,startpos)
 SET voutputcsv = substring(startpos,(a - startpos),request->batch_selection)
 SET startpos = (a+ 1)
 SET a = findstring("^",request->batch_selection,startpos)
 SET vstartdate = substring(startpos,(a - startpos),request->batch_selection)
 SET startpos = (a+ 1)
 SET a = findstring("^",request->batch_selection,startpos)
 SET venddate = substring(startpos,(a - startpos),request->batch_selection)
 SET startpos = (a+ 1)
 SET a = findstring("^",request->batch_selection,startpos)
 SET vstarttime = substring(startpos,(a - startpos),request->batch_selection)
 SET startpos = (a+ 1)
 SET a = findstring("^",request->batch_selection,startpos)
 SET vendtime = substring(startpos,(a - startpos),request->batch_selection)
 SET startpos = (a+ 1)
 SET a = findstring("^",request->batch_selection,startpos)
 SET vlicname = substring(startpos,(a - startpos),request->batch_selection)
 SET startpos = (a+ 1)
 SET a = findstring("^",request->batch_selection,startpos)
 SET vsepfiles = substring(startpos,(a - startpos),request->batch_selection)
 SET startpos = (a+ 1)
 SET a = findstring("^",request->batch_selection,startpos)
 SET valllic = substring(startpos,(a - startpos),request->batch_selection)
 SET startpos = (a+ 1)
 SET a = findstring("^",request->batch_selection,startpos)
 IF (a > 0)
  SET vlicgroups = "Value("
  SET vlicgroups = concat(vlicgroups,'"',substring(startpos,(a - startpos),request->batch_selection),
   '"')
  SET startpos = (a+ 1)
  SET a = findstring("^",request->batch_selection,startpos)
  WHILE (a > 0)
    SET vlicgroups = concat(vlicgroups,',"',substring(startpos,(a - startpos),request->
      batch_selection),'"')
    SET startpos = (a+ 1)
    SET a = findstring("^",request->batch_selection,startpos)
  ENDWHILE
  SET vlicgroups = concat(vlicgroups,")")
 ENDIF
 IF (vrpt="0")
  SET exeline = "execute cdi_rpt_axlic_graph vOutputRpt, vStartDate, vEndDate, vStartTime,"
  SET exeline = concat(exeline," vEndTime, vLicName, vAllLic, ",vlicgroups," go")
  CALL echo(exeline)
  CALL parser(exeline)
 ELSEIF (vrpt="1")
  SET exeline = "execute CDI_RPT_AXLIC_CSV vOutputCsv, vStartDate, vEndDate, vStartTime,"
  SET exeline = concat(exeline," vEndTime, vLicName, vAllLic, ",vlicgroups,", vSepFiles go")
  CALL parser(exeline)
 ELSE
  SET exeline = "execute cdi_rpt_axlic_graph vOutputRpt, vStartDate, vEndDate, vStartTime,"
  SET exeline = concat(exeline," vEndTime, vLicName, vAllLic, ",vlicgroups," go")
  CALL parser(exeline)
  SET exeline = "execute CDI_RPT_AXLIC_CSV vOutputCsv, vStartDate, vEndDate, vStartTime,"
  SET exeline = concat(exeline," vEndTime, vLicName, vAllLic, ",vlicgroups,", vSepFiles go")
  CALL parser(exeline)
 ENDIF
END GO
