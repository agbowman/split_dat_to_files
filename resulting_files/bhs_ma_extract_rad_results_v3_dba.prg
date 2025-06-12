CREATE PROGRAM bhs_ma_extract_rad_results_v3:dba
 PROMPT
  "Enter beginning date ( MMDDYY ) --> " = "042007",
  "Enter end date ( MMDDYY ) --> " = "042007"
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 order_id = f8
     2 event_id = f8
     2 text = vc
     2 facility_alias = c3
 )
 SET beg_dt =  $1
 SET end_dt =  $2
 SET order_id = 0
 SET previous_order_id = 0
 SET blobout = fillstring(32000," ")
 SET blobnortf = fillstring(32000," ")
 SET bsize = 0
 SET len1 = 0
 SET blob_ret_len = 0
 SET blobout2 = fillstring(32000," ")
 SET blobnortf2 = fillstring(32000," ")
 SET bsize2 = 0
 SET len2 = 0
 SET blob_ret_len2 = 0
 DECLARE cmrn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE fin_cd = f8 WITH public, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE cmrn_pool_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",263,"BHSCMRN"))
 DECLARE bmc_fin_pool_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",263,"BMCACCTNBR"))
 DECLARE fmc_fin_pool_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",263,"FMCACCTNBR"))
 DECLARE mlh_fin_pool_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",263,"MLHACCTNBR"))
 DECLARE ocf_cd = f8 WITH public, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE current_cd = f8 WITH public, constant(uar_get_code_by("MEANING",213,"CURRENT"))
 DECLARE doc_nbr_cd = f8 WITH public, constant(uar_get_code_by("MEANING",320,"DOCNBR"))
 DECLARE final_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE modified_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE contrib_system_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",89,"SMSRMS"))
 DECLARE contrib_source_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",73,"SMSRMS"))
 DECLARE doc_pool_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",263,"BHSORGNUMBER"))
 DECLARE rad_cat_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"RADIOLOGY"))
 DECLARE doc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",53,"DOC"))
 DECLARE filename = vc
 SET logical export_dir "/cerner/d_prod/radconv/"
 SET filename = concat("rad_extract","_",beg_dt,".dat")
 SELECT INTO concat("export_dir:",filename)
  mrn_alias = substring(1,10,trim(pa.alias)), fin_alias = substring(1,10,trim(ea.alias)), fin_pool =
  ea.alias_pool_cd,
  sex = substring(1,1,uar_get_code_display(p.sex_cd)), orddr_alias = substring(1,16,trim(pla.alias)),
  proc_desc = uar_get_code_display(ce.catalog_cd)
  FROM clinical_event ce,
   person p,
   person_alias pa,
   encntr_alias ea,
   orders o,
   order_action oa,
   prsnl_alias pla,
   person_name pn,
   code_value_alias cva
  PLAN (ce
   WHERE ce.updt_dt_tm >= cnvtdatetime(cnvtdate(beg_dt),0000)
    AND ce.updt_dt_tm <= cnvtdatetime(cnvtdate(end_dt),2359)
    AND ce.contributor_system_cd=contrib_system_cd
    AND ce.result_status_cd IN (final_cd, modified_cd)
    AND ce.view_level=1
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.event_class_cd=doc_cd)
   JOIN (p
   WHERE p.person_id=ce.person_id)
   JOIN (pa
   WHERE pa.person_id=outerjoin(ce.person_id)
    AND pa.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime))
    AND pa.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime))
    AND pa.person_alias_type_cd=outerjoin(cmrn_cd)
    AND pa.alias_pool_cd=outerjoin(cmrn_pool_cd))
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(ce.encntr_id)
    AND ea.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime))
    AND ea.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime))
    AND ea.encntr_alias_type_cd=outerjoin(fin_cd))
   JOIN (o
   WHERE o.order_id=outerjoin(ce.order_id))
   JOIN (oa
   WHERE oa.order_id=outerjoin(o.order_id)
    AND oa.action_sequence=outerjoin(o.last_action_sequence))
   JOIN (pla
   WHERE pla.person_id=outerjoin(oa.order_provider_id)
    AND pla.active_ind=outerjoin(1)
    AND pla.alias_pool_cd=outerjoin(doc_pool_cd))
   JOIN (pn
   WHERE pn.person_id=outerjoin(oa.order_provider_id)
    AND pn.name_type_cd=outerjoin(current_cd)
    AND pn.active_ind=outerjoin(1))
   JOIN (cva
   WHERE cva.code_value=outerjoin(ce.catalog_cd)
    AND cva.contributor_source_cd=outerjoin(contrib_source_cd))
  ORDER BY ce.order_id
  HEAD REPORT
   cnt = 0
  HEAD ce.order_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(temp->qual,(cnt+ 10))
   ENDIF
   IF (fin_pool=bmc_fin_pool_cd)
    temp->qual[cnt].facility_alias = "BMC"
   ELSEIF (fin_pool=fmc_fin_pool_cd)
    temp->qual[cnt].facility_alias = "FMC"
   ELSEIF (fin_pool=mlh_fin_pool_cd)
    temp->qual[cnt].facility_alias = "MLH"
   ENDIF
   temp->qual[cnt].order_id = ce.order_id, temp->qual[cnt].event_id = ce.event_id, temp->qual[cnt].
   text = concat(trim(mrn_alias),"|",trim(p.name_last_key),"|",trim(p.name_first_key),
    "|",trim(format(p.birth_dt_tm,"YYYYMMDDHHMMSS;;D")),"|",trim(sex),"|",
    trim(fin_alias),"|",temp->qual[cnt].facility_alias,"|",trim(ce.reference_nbr),
    "|",trim(cva.alias),"|",trim(proc_desc),"|",
    trim(orddr_alias),"|",trim(pn.name_last_key),"|",trim(pn.name_first_key),
    "|",format(ce.event_start_dt_tm,"YYYYMMDDHHMMSS;;D"),"|",trim(cnvtstring(ce.order_id)),"|")
  FOOT  ce.order_id
   col + 0
  FOOT REPORT
   stat = alterlist(temp->qual,cnt), temp->cnt = cnt
  WITH counter
 ;end select
 CALL echo(build("temp->cnt=>",temp->cnt))
 SELECT INTO "nl:"
  FROM (dummyt dd  WITH seq = value(temp->cnt)),
   ce_blob ceb
  PLAN (dd)
   JOIN (ceb
   WHERE (ceb.event_id=temp->qual[dd.seq].event_id)
    AND ceb.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
  DETAIL
   blobnortf = fillstring(32000," "), blobout = fillstring(32000," "),
   CALL uar_ocf_uncompress(ceb.blob_contents,textlen(ceb.blob_contents),blobout,size(blobout),
   blob_ret_len),
   blobnortf = trim(blobout,3), blobnortf = replace(blobnortf,char(10),"~",0), blobnortf = replace(
    blobnortf,char(13),"~",0),
   temp->qual[dd.seq].text = concat(temp->qual[dd.seq].text,trim(blobnortf,3))
  WITH nocounter
 ;end select
 FOR (i = 1 TO temp->cnt)
   SET temp->qual[i].text = concat(temp->qual[i].text,"|")
 ENDFOR
 SELECT INTO concat("export_dir:",filename)
  FROM (dummyt dd  WITH seq = value(temp->cnt))
  DETAIL
   IF (dd.seq > 1)
    row + 1
   ENDIF
   temp->qual[dd.seq].text
  WITH maxcol = 32000, maxrow = 1, noformfeed,
   format = variable
 ;end select
 FREE RECORD temp
END GO
