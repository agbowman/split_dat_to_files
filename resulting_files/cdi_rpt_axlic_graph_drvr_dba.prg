CREATE PROGRAM cdi_rpt_axlic_graph_drvr:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Begin Time" = "CURTIME",
  "End Time" = "CURTIME",
  "License Type" = "AX License                                                                      ",
  "Select all license groups" = "1",
  "License Groups" = ""
  WITH outdev, begindate, enddate,
  begintime, endtime, licensetype,
  alllicenses, licensegroups
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 licgrpnm = vc
 )
 FREE RECORD templic
 RECORD templic(
   1 qual[*]
     2 licgrpnm = vc
 )
 DECLARE vcstartdatetime = vc WITH noconstant(""), protect
 DECLARE vcenddatetime = vc WITH noconstant(""), protect
 DECLARE vclicname = vc WITH noconstant(""), protect
 DECLARE vcalllic = vc WITH noconstant(""), protect
 DECLARE licgroupcount = i4 WITH noconstant(0), protect
 DECLARE maxcount = i4 WITH constant(10), protect
 DECLARE tp = vc WITH protect
 DECLARE licstring = vc WITH protect
 DECLARE cnt_lic = i2 WITH public, noconstant(0)
 DECLARE g_alloc_num = i2 WITH public, constant(10)
 DECLARE row_cnt = i2 WITH noconstant(0), protect
 DECLARE ifound = i2 WITH noconstant(0), protect
 DECLARE ilistsize = i2 WITH noconstant(0), protect
 DECLARE ivalid = i2 WITH public, noconstant(0)
 DECLARE num = i4
 SET vcstartdatetime = build2(parameter(2,0)," ",parameter(4,0))
 SET vcenddatetime = build2(parameter(3,0)," ",parameter(5,0))
 SET vclicname = build(parameter(6,0))
 SET vcalllic = build(parameter(7,0))
 IF (vcalllic="0")
  SET tp = reflect(parameter(8,0))
  IF (substring(1,1,tp)="L")
   WHILE (reflect(parameter(8,(licgroupcount+ 1))) > " ")
     SET licgroupcount += 1
     IF (licgroupcount > size(templic->qual,5))
      SET stat = alterlist(templic->qual,(licgroupcount+ 9))
     ENDIF
     SET templic->qual[licgroupcount].licgrpnm = build(parameter(8,licgroupcount))
   ENDWHILE
   SET stat = alterlist(templic->qual,licgroupcount)
  ELSEIF (substring(1,1,tp)="C")
   SET licgroupcount = 1
   SET stat = alterlist(templic->qual,licgroupcount)
   SET templic->qual[licgroupcount].licgrpnm = build(parameter(8,0))
  ENDIF
 ENDIF
 SELECT
  IF (vcalllic="0")
   PLAN (cl
    WHERE cl.license_dt_tm >= cnvtdatetime(vcstartdatetime)
     AND cl.license_dt_tm <= cnvtdatetime(vcenddatetime)
     AND cl.cdi_axlic_usage_id != 0
     AND expand(num,1,size(templic->qual,5),cl.license_group_nm,templic->qual[num].licgrpnm))
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
  cl.license_dt_tm, cl.license_group_nm, cl.licenses_in_use_nbr,
  cl.total_licenses_nbr, pct1 = ((100.0 * cl.licenses_in_use_nbr)/ cl.total_licenses_nbr), time =
  cnvtmin(cl.license_dt_tm)
  FROM cdi_axlic_usage cl,
   dm_flags_all dm
  HEAD REPORT
   row_cnt = 0, stat = alterlist(batch_lyt->batch_details,10)
  FOOT  cl.license_dt_tm
   ivalid = 0
  FOOT  cl.license_group_nm
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
    ifound = 0
    FOR (i = 1 TO ilistsize)
      IF ((cl.license_group_nm=batch_lyt->batch_details[i].licgrpnm))
       ifound = 1
       IF ((batch_lyt->batch_details[i].pctusage < pct1))
        batch_lyt->batch_details[i].conndatetime = cl.license_dt_tm, batch_lyt->batch_details[i].
        pctusage = pct1, batch_lyt->batch_details[i].numused = cl.licenses_in_use_nbr,
        batch_lyt->batch_details[i].numavail = cl.total_licenses_nbr
       ENDIF
      ENDIF
    ENDFOR
    IF (ifound=0)
     ilistsize += 1
     IF (ilistsize > size(batch_lyt->batch_details,5))
      stat = alterlist(batch_lyt->batch_details,(ilistsize+ g_alloc_num))
     ENDIF
     batch_lyt->batch_details[ilistsize].licgrpnm = cl.license_group_nm, batch_lyt->batch_details[
     ilistsize].conndatetime = cl.license_dt_tm, batch_lyt->batch_details[ilistsize].pctusage = pct1,
     batch_lyt->batch_details[ilistsize].numused = cl.licenses_in_use_nbr, batch_lyt->batch_details[
     ilistsize].numavail = cl.total_licenses_nbr
    ENDIF
   ENDIF
  WITH nocounter, separator = " ", format
 ;end select
 SET stat = alterlist(batch_lyt->batch_details,ilistsize)
 SELECT INTO "nl:"
  licname = substring(1,30,batch_lyt->batch_details[d2.seq].licgrpnm), pctusage = batch_lyt->
  batch_details[d2.seq].pctusage, proctime = cnvttime(batch_lyt->batch_details[ilistsize].
   conndatetime)
  FROM (dummyt d2  WITH seq = value(size(batch_lyt->batch_details,5)))
  PLAN (d2)
  ORDER BY pctusage DESC
  HEAD REPORT
   cnt_lic = 0, stat = alterlist(temp->qual,10)
  DETAIL
   cnt_lic += 1
   IF (cnt_lic > size(temp->qual,5))
    stat = alterlist(temp->qual,(cnt_lic+ g_alloc_num))
   ENDIF
   temp->qual[cnt_lic].licgrpnm = licname
  WITH maxrec = 10, nocounter, separator = " ",
   format
 ;end select
 SET stat = alterlist(temp->qual,cnt_lic)
 IF (cnt_lic > 10)
  SET cnt_lic = 10
 ENDIF
 SELECT
  cl.license_dt_tm, cl.license_group_nm, cl.licenses_in_use_nbr,
  cl.total_licenses_nbr, dm.description, pct1 = ((100.0 * cl.licenses_in_use_nbr)/ cl
  .total_licenses_nbr),
  time = cnvtmin(cl.license_dt_tm)
  FROM cdi_axlic_usage cl,
   dm_flags_all dm
  PLAN (cl
   WHERE cl.license_dt_tm >= cnvtdatetime(vcstartdatetime)
    AND cl.license_dt_tm <= cnvtdatetime(vcenddatetime)
    AND cl.cdi_axlic_usage_id != 0
    AND expand(num,1,size(temp->qual,5),cl.license_group_nm,temp->qual[num].licgrpnm))
   JOIN (dm
   WHERE dm.table_name="CDI_AXLIC_USAGE"
    AND dm.flag_value=cl.license_type_flag
    AND dm.definition=vclicname)
  ORDER BY cl.license_dt_tm, cl.license_group_nm
  HEAD REPORT
   stat = alterlist(rptgraphrec->m_series,maxcount), rptgraphrec->m_series[1].color =
   uar_rptencodecolor(0,128,255), rptgraphrec->m_series[2].color = uar_rptencodecolor(255,128,128),
   rptgraphrec->m_series[3].color = uar_rptencodecolor(255,255,128), rptgraphrec->m_series[4].color
    = uar_rptencodecolor(25,25,112), rptgraphrec->m_series[5].color = uar_rptencodecolor(255,255,0),
   rptgraphrec->m_series[6].color = uar_rptencodecolor(255,165,0), rptgraphrec->m_series[7].color =
   uar_rptencodecolor(255,0,0), rptgraphrec->m_series[8].color = uar_rptencodecolor(0,255,0),
   rptgraphrec->m_series[9].color = uar_rptencodecolor(160,32,240), rptgraphrec->m_series[10].color
    = uar_rptencodecolor(255,181,197), stat = alterlist(rptgraphrec->m_series,cnt_lic)
   FOR (i = 1 TO cnt_lic)
     rptgraphrec->m_series[i].name = temp->qual[i].licgrpnm
   ENDFOR
   _nfieldscnt = 1
  HEAD cl.license_dt_tm
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
    FOR (i = 1 TO cnt_lic)
      stat = alterlist(rptgraphrec->m_series[i].y_values,_nfieldscnt)
    ENDFOR
   ENDIF
  FOOT  cl.license_group_nm
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
    FOR (i = 1 TO cnt_lic)
      IF ((cl.license_group_nm=temp->qual[i].licgrpnm))
       rptgraphrec->m_series[i].y_values[_nfieldscnt].y_f8 = pct1
      ENDIF
    ENDFOR
   ENDIF
  FOOT  cl.license_dt_tm
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
    stat = alterlist(rptgraphrec->m_labels,_nfieldscnt), rptgraphrec->m_labels[_nfieldscnt].label =
    format(cl.license_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"), _nfieldscnt += 1
   ENDIF
  WITH nocounter, separator = " ", format
 ;end select
END GO
