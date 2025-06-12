CREATE PROGRAM cdi_rpt_axlic_csv:dba
 PROMPT
  "Output to File" = "CCLUSERDIR:",
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Begin Time" = "CURTIME",
  "End Time" = "CURTIME",
  "License Type" = "AX License                                                                      ",
  "Select all license groups" = "1",
  "License Groups" = "",
  "Separate file for each license group" = "0"
  WITH outdev, begindate, enddate,
  begintime, endtime, licensetype,
  alllicenses, licensegroups, sepfile
 FREE SET temp
 RECORD temp(
   1 qual[*]
     2 licname = vc
 )
 DECLARE vcstartdatetime = vc WITH noconstant(""), protect
 DECLARE vcstartdate = vc WITH noconstant(""), protect
 DECLARE vcenddatetime = vc WITH noconstant(""), protect
 DECLARE vcenddate = vc WITH noconstant(""), protect
 DECLARE vclicname = vc WITH noconstant(""), protect
 DECLARE vcalllic = vc WITH noconstant(""), protect
 DECLARE vcsepfiles = vc WITH noconstant(""), protect
 DECLARE licstring = vc WITH protect
 DECLARE cnt_lic = i2 WITH protect, noconstant(0)
 DECLARE licgroupcount = i4 WITH noconstant(0), protect
 DECLARE tp = vc WITH protect
 DECLARE vcoutput = vc WITH noconstant(""), protect
 DECLARE vcfilename = vc WITH noconstant(""), protect
 DECLARE vctemplicname = vc WITH noconstant(""), protect
 DECLARE icount = i4 WITH protect, noconstant(0)
 DECLARE num = i4
 SET vcoutput = build(parameter(1,0))
 SET vcstartdatetime = build2(parameter(2,0)," ",parameter(4,0))
 SET vcstartdate = format(cnvtdate2(build(parameter(2,0)),"DD-MMM-YYYY"),"YYMMDD;;D")
 SET vcenddatetime = build2(parameter(3,0)," ",parameter(5,0))
 SET vcenddate = format(cnvtdate2(build(parameter(3,0)),"DD-MMM-YYYY"),"YYMMDD;;D")
 SET vclicname = build(parameter(6,0))
 SET vcalllic = build(parameter(7,0))
 SET vcsepfiles = build(parameter(9,0))
 IF (vcalllic="0")
  SET tp = reflect(parameter(8,0))
  IF (substring(1,1,tp)="L")
   WHILE (reflect(parameter(8,(licgroupcount+ 1))) > " ")
     SET licgroupcount += 1
     IF (licgroupcount > size(temp->qual,5))
      SET stat = alterlist(temp->qual,(licgroupcount+ 9))
     ENDIF
     SET temp->qual[licgroupcount].licname = build(parameter(8,licgroupcount))
   ENDWHILE
   SET stat = alterlist(temp->qual,licgroupcount)
  ELSEIF (substring(1,1,tp)="C")
   SET licgroupcount = 1
   SET stat = alterlist(temp->qual,licgroupcount)
   SET temp->qual[licgroupcount].licname = build(parameter(8,0))
  ENDIF
 ENDIF
 IF (vcsepfiles="0")
  SET vcfilename = concat(vcoutput,"CPDI-LM-Selected-",vcstartdate,"-",vcenddate,
   ".csv")
  SELECT
   IF (vcalllic="0")
    PLAN (cl
     WHERE cl.license_dt_tm >= cnvtdatetime(vcstartdatetime)
      AND cl.license_dt_tm <= cnvtdatetime(vcenddatetime)
      AND cl.cdi_axlic_usage_id != 0
      AND expand(num,1,size(temp->qual,5),cl.license_group_nm,temp->qual[num].licname))
     JOIN (dm
     WHERE dm.table_name="CDI_AXLIC_USAGE"
      AND dm.flag_value=cl.license_type_flag
      AND dm.definition=vclicname)
    ORDER BY cl.license_dt_tm, cl.license_group_nm
   ELSE
    PLAN (cl
     WHERE cl.license_dt_tm >= cnvtdatetime(vcstartdatetime)
      AND cl.license_dt_tm <= cnvtdatetime(vcenddatetime)
      AND cl.cdi_axlic_usage_id != 0)
     JOIN (dm
     WHERE dm.table_name="CDI_AXLIC_USAGE"
      AND dm.flag_value=cl.license_type_flag
      AND dm.definition=vclicname)
    ORDER BY cl.license_dt_tm, cl.license_group_nm
   ENDIF
   INTO value(vcfilename)
   FROM cdi_axlic_usage cl,
    dm_flags_all dm
   HEAD REPORT
    row_cnt = 0,
    "License Group,Date/Time,Number of Licenses in Use,Total Number of Licenses in Group", row + 1
   DETAIL
    ivalid = 0
    IF (hour(cl.license_dt_tm) >= hour(cnvtdatetime(vcstartdatetime))
     AND hour(cl.license_dt_tm) <= hour(cnvtdatetime(vcenddatetime)))
     IF (hour(cl.license_dt_tm)=hour(cnvtdatetime(vcstartdatetime)))
      IF (minute(cl.license_dt_tm) >= minute(cnvtdatetime(vcstartdatetime)))
       ivalid = 1
      ENDIF
     ELSEIF (hour(cl.license_dt_tm)=hour(cnvtdatetime(vcenddatetime)))
      IF (minute(cl.license_dt_tm) <= minute(cnvtdatetime(vcenddatetime)))
       ivalid = 1
      ENDIF
     ELSE
      ivalid = 1
     ENDIF
    ENDIF
    IF (ivalid=1)
     col 1, cl.license_group_nm, col 31,
     ",", col 32, cl.license_dt_tm"DD-MMM-YYYY HH:MM:SS",
     col 55, ",", col 56,
     cl.licenses_in_use_nbr"#####", col 63, ",",
     col 64, cl.total_licenses_nbr"#####", row + 1
    ENDIF
   WITH nocounter, separator = " ", format
  ;end select
 ELSE
  IF (vcalllic="1")
   SELECT DISTINCT INTO "nl:"
    c.license_group_nm
    FROM cdi_axlic_usage c
    WHERE c.cdi_axlic_usage_id != 0
    ORDER BY c.license_group_nm
    HEAD REPORT
     cnt_lic = 0
    DETAIL
     cnt_lic += 1
     IF (cnt_lic > size(temp->qual,5))
      stat = alterlist(temp->qual,(cnt_lic+ 9))
     ENDIF
     temp->qual[cnt_lic].licname = c.license_group_nm
    WITH nocounter
   ;end select
   SET stat = alterlist(temp->qual,cnt_lic)
   SET licgroupcount = cnt_lic
  ENDIF
  FOR (i = 1 TO size(temp->qual,5))
    IF (size(trim(temp->qual[i].licname),1) > 17)
     SET vctemplicname = substring(1,17,trim(temp->qual[i].licname))
    ELSE
     SET vctemplicname = trim(temp->qual[i].licname)
    ENDIF
    SET vcfilename = concat(vcoutput,"CPDI-LM-",vctemplicname,"-",vcstartdate,
     "-",vcenddate,".csv")
    SET licstring = build("cl.license_group_nm = '",temp->qual[i].licname,"'")
    SELECT INTO value(vcfilename)
     FROM cdi_axlic_usage cl,
      dm_flags_all dm
     PLAN (cl
      WHERE cl.license_dt_tm >= cnvtdatetime(vcstartdatetime)
       AND cl.license_dt_tm <= cnvtdatetime(vcenddatetime)
       AND cl.cdi_axlic_usage_id != 0
       AND parser(licstring))
      JOIN (dm
      WHERE dm.table_name="CDI_AXLIC_USAGE"
       AND dm.flag_value=cl.license_type_flag
       AND dm.definition=vclicname)
     ORDER BY cl.license_dt_tm, cl.license_group_nm
     HEAD REPORT
      row_cnt = 0,
      "License Group,Date/Time,Number of Licenses in Use,Total Number of Licenses in Group", row + 1
     DETAIL
      ivalid = 0
      IF (hour(cl.license_dt_tm) >= hour(cnvtdatetime(vcstartdatetime))
       AND hour(cl.license_dt_tm) <= hour(cnvtdatetime(vcenddatetime)))
       IF (hour(cl.license_dt_tm)=hour(cnvtdatetime(vcstartdatetime)))
        IF (minute(cl.license_dt_tm) >= minute(cnvtdatetime(vcstartdatetime)))
         ivalid = 1
        ENDIF
       ELSEIF (hour(cl.license_dt_tm)=hour(cnvtdatetime(vcenddatetime)))
        IF (minute(cl.license_dt_tm) <= minute(cnvtdatetime(vcenddatetime)))
         ivalid = 1
        ENDIF
       ELSE
        ivalid = 1
       ENDIF
      ENDIF
      IF (ivalid=1)
       col 1, cl.license_group_nm, col 31,
       ",", col 32, cl.license_dt_tm"DD-MMM-YYYY HH:MM:SS",
       col 55, ",", col 56,
       cl.licenses_in_use_nbr"#####", col 63, ",",
       col 64, cl.total_licenses_nbr"#####", row + 1
      ENDIF
     WITH nocounter, separator = " ", format
    ;end select
  ENDFOR
 ENDIF
END GO
