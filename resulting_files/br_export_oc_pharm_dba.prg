CREATE PROGRAM br_export_oc_pharm:dba
 RECORD temp(
   1 oclist[*]
     2 drug_synonym_id = f8
     2 mmdc = f8
     2 dnum = c6
     2 mnemonic = vc
     2 desc = vc
     2 nlist[*]
       3 ndc_formatted = c13
       3 ndc_code = c11
       3 brand_name = vc
       3 dose = vc
       3 pkg_size = f8
 )
 SET ncnt = 0
 SET tot_ncnt = 0
 SET stat = alterlist(temp->oclist,5000)
 SET cnt = 0
 SET tot_cnt = 0
 SET start_version = 3
 SELECT INTO "NL:"
  FROM mltm_drug_name mdn,
   mltm_drug_id mdi,
   mltm_ndc_main_drug_code mmdc
  PLAN (mdn
   WHERE mdn.is_obsolete="F"
    AND mdn.start_version_nbr=start_version)
   JOIN (mdi
   WHERE mdi.drug_synonym_id=mdn.drug_synonym_id
    AND mdi.start_version_nbr=start_version)
   JOIN (mmdc
   WHERE mmdc.drug_identifier=mdi.drug_identifier
    AND mmdc.start_version_nbr=start_version)
  ORDER BY mdn.drug_synonym_id
  HEAD mdn.drug_synonym_id
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 5000)
    cnt = 1, stat = alterlist(temp->oclist,(tot_cnt+ 5000))
   ENDIF
  DETAIL
   temp->oclist[tot_cnt].desc = mdn.drug_name, temp->oclist[tot_cnt].drug_synonym_id = mdn
   .drug_synonym_id, temp->oclist[tot_cnt].dnum = mdi.drug_identifier,
   temp->oclist[tot_cnt].mmdc = mmdc.main_multum_drug_code
  WITH nocounter
 ;end select
 SET stat = alterlist(temp->oclist,tot_cnt)
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = tot_cnt),
   mltm_ndc_core_description mncd,
   mltm_ndc_brand_name mbrand
  PLAN (d)
   JOIN (mncd
   WHERE (mncd.main_multum_drug_code=temp->oclist[d.seq].mmdc)
    AND mncd.start_version_nbr=start_version)
   JOIN (mbrand
   WHERE mbrand.brand_code=mncd.brand_code
    AND mbrand.start_version_nbr=start_version)
  ORDER BY d.seq
  HEAD d.seq
   ncnt = 0, tot_ncnt = 0, stat = alterlist(temp->oclist[d.seq].nlist,20)
  DETAIL
   tot_ncnt = (tot_ncnt+ 1), ncnt = (ncnt+ 1)
   IF (ncnt > 20)
    ncnt = 1, stat = alterlist(temp->oclist[d.seq].nlist,(tot_ncnt+ 20))
   ENDIF
   temp->oclist[d.seq].nlist[tot_ncnt].ndc_formatted = mncd.ndc_formatted, temp->oclist[d.seq].nlist[
   tot_ncnt].ndc_code = mncd.ndc_code, temp->oclist[d.seq].nlist[tot_ncnt].pkg_size = mncd
   .inner_package_size,
   temp->oclist[d.seq].nlist[tot_ncnt].brand_name = mbrand.brand_description
  FOOT  d.seq
   stat = alterlist(temp->oclist[d.seq].nlist,tot_ncnt)
  WITH nocounter
 ;end select
 DECLARE line = vc
 DECLARE front_line = vc
 SELECT INTO "br_export_oc_pharm.csv"
  DETAIL
   "desc,brand_name,ndc_code,ndc_formatted,dose,pkg_size"
  WITH nocounter
 ;end select
 DECLARE desc = vc
 DECLARE brand_name = vc
 FOR (i = 1 TO tot_cnt)
  SELECT INTO "br_export_oc_pharm.csv"
   DETAIL
    desc = concat('"',trim(temp->oclist[i].desc),'"'), brand_name = concat('"',trim(temp->oclist[i].
      nlist.brand_name),'"'), front_line = concat(trim(desc),","),
    front_line = concat(front_line,trim(brand_name),",")
   WITH append, nocounter, format = variable,
    maxcol = 1999, noformfeed, maxrow = 1
  ;end select
  SELECT INTO "br_export_oc_pharm.csv"
   FROM (dummyt d  WITH seq = size(temp->oclist[i].nlist,5))
   DETAIL
    line = concat(front_line,trim(temp->oclist[i].nlist[d.seq].ndc_code),","), line = concat(line,
     trim(temp->oclist[i].nlist[d.seq].ndc_formatted),","), col 0,
    line, row + 1
   WITH append, nocounter, format = variable,
    maxcol = 1999, noformfeed, maxrow = 1
  ;end select
 ENDFOR
END GO
