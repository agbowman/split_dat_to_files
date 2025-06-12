CREATE PROGRAM ec_updt_oef:dba
 RECORD syns(
   1 qual[*]
     2 syn_id = f8
     2 oef_name = vc
     2 oef_id = f8
 )
 FREE DEFINE rtl
 FREE SET file_loc
 SET logical file_loc "ccluserdir:med_oefs.csv"
 DEFINE rtl "file_loc"
 CALL echo("Getting OEF list...")
 SET icnt = 0
 SELECT INTO "nl:"
  sline = trim(r.line)
  FROM rtlt r
  DETAIL
   icnt = (icnt+ 1), stat = alterlist(syns->qual,icnt), sdelim = findstring(",",sline,1,1),
   syns->qual[icnt].syn_id = cnvtreal(substring(1,(sdelim - 1),sline)), syns->qual[icnt].oef_name =
   substring((sdelim+ 1),size(sline),sline)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_entry_format_parent oef,
   (dummyt d  WITH seq = value(icnt))
  PLAN (d)
   JOIN (oef
   WHERE (oef.oe_format_name=syns->qual[d.seq].oef_name))
  DETAIL
   syns->qual[d.seq].oef_id = oef.oe_format_id
  WITH nocounter
 ;end select
 UPDATE  FROM order_catalog_synonym ocs,
   (dummyt d  WITH seq = value(icnt))
  SET ocs.oe_format_id = syns->qual[d.seq].oef_id, ocs.updt_id = - (9090), ocs.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   ocs.updt_cnt = (ocs.updt_cnt+ 1)
  PLAN (d)
   JOIN (ocs
   WHERE (ocs.synonym_id=syns->qual[d.seq].syn_id))
  WITH nocounter
 ;end update
END GO
