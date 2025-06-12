CREATE PROGRAM bed_ext_srvres_hier:dba
 DECLARE line = vc
 SET line = fillstring(300," ")
 CALL echo(build("start = ",line))
 SET latest_start_version = 0
 SELECT DISTINCT INTO "NL:"
  b.start_version_nbr
  FROM br_client b
  ORDER BY b.start_version_nbr
  DETAIL
   latest_start_version = b.start_version_nbr
  WITH skipbedrock = 1, nocounter
 ;end select
 CALL echo(build("start version nbr = ",cnvtstring(latest_start_version)))
 SELECT INTO "CER_INSTALL:srvres_hier.csv"
  FROM br_proposed_srvres b,
   code_value cv6000,
   code_value cv106,
   code_value cv5801
  PLAN (b)
   JOIN (cv6000
   WHERE cv6000.code_value=b.catalog_type_cd
    AND cv6000.start_version_nbr=latest_start_version)
   JOIN (cv106
   WHERE cv106.code_value=outerjoin(b.activity_type_cd)
    AND cv106.start_version_nbr=outerjoin(latest_start_version))
   JOIN (cv5801
   WHERE cv5801.code_value=outerjoin(b.activity_subtype_cd)
    AND cv5801.start_version_nbr=outerjoin(latest_start_version))
  ORDER BY b.br_proposed_srvres_id
  HEAD REPORT
   "option,level,display,description,meaning,catalog_type,activity_type,activity_subtype,proposed_ind,auto_manual_ind"
  DETAIL
   description = concat('"',trim(b.description),'",'), display = concat('"',trim(b.display),'",'),
   mean = concat('"',trim(b.meaning),'",'),
   catalog_type = concat('"',trim(cv6000.cdf_meaning),'",'), activity_type = fillstring(40," "),
   activity_type = '"",'
   IF (cv106.display > " ")
    activity_type = concat('"',trim(cv106.cdf_meaning),'",')
   ENDIF
   activity_sub_type = fillstring(40," "), activity_sub_type = '"",'
   IF (cv5801.display > " ")
    activity_sub_type = concat('"',trim(cv5801.cdf_meaning),'",')
   ENDIF
   row + 1, line = concat(trim(cnvtstring(b.srvres_option_nbr)),",",trim(cnvtstring(b.srvres_level)),
    ",",trim(display),
    trim(description),trim(mean),trim(catalog_type),trim(activity_type),trim(activity_sub_type))
   IF (b.proposed_ind=1)
    line = concat(trim(line),"Y")
   ENDIF
   line = concat(trim(line),",")
   IF (b.automated_ind=1)
    line = concat(trim(line),"AUTOMATED")
   ENDIF
   line
  WITH maxcol = 500, noformfeed, format = variable,
   nocounter
 ;end select
END GO
