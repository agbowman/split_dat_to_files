CREATE PROGRAM dcp_mu_patient_list_cod:dba
 EXECUTE ccl_prompt_api_dataset "autoset"
 DECLARE islogicaldomainsactive(null) = i2
 SUBROUTINE islogicaldomainsactive(null)
   DECLARE return_val = i4 WITH noconstant(0), protect
   DECLARE b_logicaldomain = i4 WITH noconstant(column_exists("LOGICAL_DOMAIN","LOGICAL_DOMAIN_ID")),
   protect
   DECLARE ld_id = f8 WITH noconstant(0.0), protect
   DECLARE cnt = i4 WITH noconstant(0), protect
   IF (b_logicaldomain)
    SELECT INTO "nl:"
     FROM logical_domain ld
     PLAN (ld
      WHERE ld.logical_domain_id > 0.0
       AND ld.active_ind=1)
     ORDER BY ld.logical_domain_id
     HEAD ld.logical_domain_id
      return_val = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE column_exists(stable=vc,scolumn=vc) = i4
 SUBROUTINE column_exists(stable,scolumn)
   DECLARE return_val = i4 WITH noconstant(0), protect
   DECLARE ce_temp = vc WITH noconstant(""), protect
   SET stable = cnvtupper(stable)
   SET scolumn = cnvtupper(scolumn)
   IF (((currev=8
    AND currevminor=2
    AND currevminor2 >= 4) OR (((currev=8
    AND currevminor > 2) OR (currev > 8)) )) )
    SET ce_temp = build('"',stable,".",scolumn,'"')
    SET stat = checkdic(parser(ce_temp),"A",0)
    IF (stat > 0)
     SET return_val = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     l.attr_name
     FROM dtableattr a,
      dtableattrl l
     WHERE a.table_name=stable
      AND l.attr_name=scolumn
      AND l.structtype="F"
      AND btest(l.stat,11)=0
     DETAIL
      return_val = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE logical_domain_id = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  key_id = cv.code_value, display = cv.display
  FROM code_value cv
  WHERE cv.code_set=27300
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
  ORDER BY cv.display_key
  HEAD REPORT
   stat = makedataset(10)
  DETAIL
   stat = writerecord(0)
  FOOT REPORT
   stat = closedataset(0)
  WITH reporthelp, check
 ;end select
 IF (curqual > 0)
  GO TO exit_script
 ENDIF
 IF (islogicaldomainsactive(null))
  SELECT INTO "nl:"
   FROM prsnl p
   PLAN (p
    WHERE (p.person_id=reqinfo->updt_id))
   HEAD REPORT
    logical_domain_id = p.logical_domain_id
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  key_id = bdv.parent_entity_id, display = uar_get_code_display(bdv.parent_entity_id)
  FROM br_datamart_category bdc,
   br_datamart_filter bdf,
   br_datamart_value bdv
  PLAN (bdc
   WHERE bdc.category_mean="MUSE_FUNCTIONAL_2")
   JOIN (bdf
   WHERE bdf.br_datamart_category_id=bdc.br_datamart_category_id
    AND bdf.filter_mean="MUSE_DEATH_CAUSE_EVENT")
   JOIN (bdv
   WHERE bdv.br_datamart_category_id=bdf.br_datamart_category_id
    AND bdv.br_datamart_filter_id=bdf.br_datamart_filter_id
    AND bdv.logical_domain_id=logical_domain_id)
  ORDER BY display
  HEAD REPORT
   stat = makedataset(10)
  DETAIL
   stat = writerecord(0)
  FOOT REPORT
   stat = closedataset(0)
  WITH reporthelp, check
 ;end select
#exit_script
 CALL echo("last mod: 03/19/2013  Chris Jolley")
END GO
