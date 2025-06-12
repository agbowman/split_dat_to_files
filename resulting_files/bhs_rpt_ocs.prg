CREATE PROGRAM bhs_rpt_ocs
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE bhs_sys_stand_subroutine
 IF (findstring("@", $1) > 0)
  SET email_ind = 1
  SET output_dest = build(cnvtlower(curprog),format(cnvtdatetime(curdate,curtime3),
    "YYYYMMDDHHMMSS;;d"))
 ELSE
  SET email_ind = 2
  SET output_dest =  $1
 ENDIF
 DECLARE output_string = vc
 SELECT DISTINCT INTO value(output_dest)
  ocs.catalog_cd, oc.primary_mnemonic, ocs.synonym_id,
  ocs.mnemonic_type_cd, ocs.active_ind, ocs.hide_flag,
  ocs.mnemonic, ocs.virtual_view
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   ocs_facility_r ofr
  PLAN (ofr)
   JOIN (ocs
   WHERE ofr.synonym_id=ocs.synonym_id
    AND ocs.catalog_type_cd=2516
    AND ocs.active_ind=1
    AND ocs.hide_flag=1)
   JOIN (oc
   WHERE ocs.catalog_cd=oc.catalog_cd)
  ORDER BY oc.primary_mnemonic
  HEAD REPORT
   output_string = build(
    ',"Catalog cd","Primary Mnemonic","Synonym id","Mnemonic type cd","Mnemonic type"',
    ',"Active ind","Hide flag","Mnemonic","Virtual view",'), col 1, output_string,
   row + 1
  DETAIL
   output_string = build(',"',ocs.catalog_cd,'","',trim(oc.primary_mnemonic),'","',
    ocs.synonym_id,'","',ocs.mnemonic_type_cd,'","',uar_get_code_display(ocs.mnemonic_type_cd),
    '","',ocs.active_ind,'","',ocs.hide_flag,'","',
    trim(ocs.mnemonic),'",',trim(ocs.virtual_view),'"'), col 1, output_string,
   row + 1
  WITH formfeed = none, maxrow = 1, format = variable,
   maxcol = 10000
 ;end select
 IF (email_ind=1)
  SET filename_in = concat(trim(output_dest),".dat")
  SET filename_out = concat(format(cnvtdatetime(curdate,curtime3),"MMDDYYYY;;D"),".csv")
  FREE SET dclcom
  DECLARE dclcom = vc
  SET dclcom = concat('sed "s/$/`echo \\\r`/" ',filename_in)
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  CALL emailfile(filename_in,filename_out, $1,curprog,1)
 ENDIF
END GO
