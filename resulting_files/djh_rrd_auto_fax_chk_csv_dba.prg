CREATE PROGRAM djh_rrd_auto_fax_chk_csv:dba
 PROMPT
  "Output to File/Printer/MINE" = "David.Hounshell@baystatehealth.org",
  "Enter Last Name:" = "*"
  WITH outdev, prompt2
 IF (findstring("@", $1) > 0)
  SET output_dest = build(format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;D"))
  SET email_ind = 1
 ELSE
  SET output_dest =  $1
  SET email_ind = 0
 ENDIF
 CALL echo(output_dest)
 DECLARE date_qual = dq8
 CALL echo(format(date_qual,"YYYY/MM/DD;;D"))
 DECLARE output_string = vc
 DECLARE rresphys = f8
 DECLARE refphys = f8
 DECLARE refphys = f8
 DECLARE devdisp = f8
 SET rresphys = uar_get_code_by("display",88,"BHS Rad Resident")
 SET resphys = uar_get_code_by("display",88,"BHS Resident")
 SET refphys = uar_get_code_by("display",88,"Reference Physician")
 SET devdisp = uar_get_code_by("display",3000,"fax")
 RECORD temp_file(
   1 qual[*]
     2 dname = vc
     2 ddevice_cd = f8
     2 ddescription = vc
     2 ddevice_tp_cd = f8
     2 ddevice_disp = vc
     2 d_updt = dq8
     2 d_updt_id = f8
     2 rdarea_code = c25
     2 rdexchange = vc
     2 rdphone_suffix = vc
     2 rddevice_addr_typ_cd = f8
     2 rddevice_cd = f8
     2 rdphone_mask = f8
     2 rdremote_dev_typ = f8
     2 rd_local_flg = i2
     2 rd_updt = dq8
     2 dxr_parentname = c30
     2 dxr_updt = dq8
 )
 SELECT INTO "nl:"
  FROM device d
  PLAN (d
   WHERE (cnvtupper(d.name)= $PROMPT2)
    AND d.device_type_cd=devdisp)
  ORDER BY d.name
  HEAD REPORT
   cnt1 = 0
  HEAD d.name
   cnt1 = (cnt1+ 1), stat = alterlist(temp_file->qual,cnt1), temp_file->qual[cnt1].dname = d.name,
   temp_file->qual[cnt1].ddevice_cd = d.device_cd, temp_file->qual[cnt1].ddescription = d.description,
   temp_file->qual[cnt1].ddevice_tp_cd = d.device_type_cd,
   temp_file->qual[cnt1].ddevice_disp = uar_get_code_display(d.device_type_cd), temp_file->qual[cnt1]
   .d_updt = d.updt_dt_tm, temp_file->qual[cnt1].d_updt_id = d.updt_id
  WITH nocounter, time = 90
 ;end select
 SELECT INTO "nl:"
  FROM remote_device rd,
   (dummyt d  WITH seq = value(size(temp_file->qual,5)))
  PLAN (d)
   JOIN (rd
   WHERE (rd.device_cd=temp_file->qual[d.seq].ddevice_cd))
  DETAIL
   temp_file->qual[d.seq].rdarea_code = rd.area_code, temp_file->qual[d.seq].rdexchange = rd.exchange,
   temp_file->qual[d.seq].rdphone_suffix = rd.phone_suffix,
   temp_file->qual[d.seq].rddevice_addr_typ_cd = rd.device_address_type_cd, temp_file->qual[d.seq].
   rddevice_cd = rd.device_cd, temp_file->qual[d.seq].rdphone_mask = rd.phone_mask_id,
   temp_file->qual[d.seq].rdremote_dev_typ = rd.remote_dev_type_id, temp_file->qual[d.seq].
   rd_local_flg = rd.local_flag, temp_file->qual[d.seq].rd_updt = rd.updt_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM device_xref dxr,
   (dummyt d  WITH seq = value(size(temp_file->qual,5)))
  PLAN (d)
   JOIN (dxr
   WHERE (dxr.device_cd=temp_file->qual[d.seq].ddevice_cd)
    AND dxr.parent_entity_name="PRSNL")
  DETAIL
   temp_file->qual[d.seq].dxr_parentname = dxr.parent_entity_name, temp_file->qual[d.seq].dxr_updt =
   dxr.updt_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO value(output_dest)
  temp_file->qual[d.seq].dname
  FROM (dummyt d  WITH seq = size(temp_file->qual,5))
  WHERE d.seq > 0
  HEAD REPORT
   col 1, ",", "Node: ",
   curnode, ",", ",",
   "Run Date: ", curdate, row + 1,
   col 1, ",", "prg: ",
   curprog, ",", row + 1,
   col 1, ",", "Device TBL Name",
   ",", "DEV Disp", ",",
   "Device TBL updt", ",", "DEV tbl UPDT ID",
   ",", "Local", ",",
   "Area Code", ",", "exchange",
   ",", "phone Suffix", ",",
   "Remote Device Type", ",", "Remote Device TBL updt",
   ",", "parent name", ",",
   "XFER TBL updt", ",", row + 1,
   display_line = build(temp_file->qual[d.seq].dname)
   FOR (y = 1 TO size(temp_file->qual[d.seq],5))
     localflg =
     IF ((temp_file->qual[y].rd_local_flg=1)) "Yes"
     ELSE
      IF ((temp_file->qual[y].rd_local_flg=2)) "No"
      ELSE " "
      ENDIF
     ENDIF
     , output_string = build(y,',"',temp_file->qual[y].dname,'","',temp_file->qual[y].ddevice_disp,
      '","',format(temp_file->qual[y].d_updt,"yyyy-mm-dd hh:mm:ss;;d"),'","',format(temp_file->qual[y
       ].d_updt_id,"###########"),'","',
      localflg,'","',temp_file->qual[y].rdarea_code,'","',temp_file->qual[y].rdexchange,
      '","',temp_file->qual[y].rdphone_suffix,'","',temp_file->qual[y].rdremote_dev_typ,'","',
      format(temp_file->qual[y].rd_updt,"yyyy-mm-dd hh:mm:ss;;d"),'","',temp_file->qual[y].
      dxr_parentname,'","',format(temp_file->qual[y].dxr_updt,"yyyy-mm-dd hh:mm:ss;;d"),
      '",'), col 1,
     output_string
     IF ( NOT (curendreport))
      row + 1
     ENDIF
   ENDFOR
  WITH format = variable, formfeed = none, maxcol = 550
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD;;D"),"_RRD_autoFAX_chk.csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog,"-V1.x - PHYS AutoFAX info ",curnode)
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
END GO
