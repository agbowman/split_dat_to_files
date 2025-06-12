CREATE PROGRAM ecf_clean_be_oc:dba
 DECLARE rcnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE info_domain="MULTUM"
   AND info_name="ecf_clean_be_oc"
  DETAIL
   rcnt = 1
  WITH nocounter
 ;end select
 IF (rcnt > 0)
  CALL echo(concat("*** Backend Order Catalog Cleanup Already Complete."))
  CALL echo(concat("*** Backend Order Catalog Cleanup Already Complete."))
  CALL echo(concat("*** Backend Order Catalog Cleanup Already Complete."))
  GO TO exit_script
 ENDIF
 SET rcnt = 0
 INSERT  FROM dm_info
  SET info_domain = "MULTUM", info_name = "ecf_clean_be_oc", updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   updt_task = reqinfo->updt_task
  WITH nocounter
 ;end insert
 FREE SET cleanup
 RECORD cleanup(
   1 list[*]
     2 catalog_cd = f8
     2 catalog_cki = vc
     2 mnemonic = vc
     2 synonym_cki = vc
     2 synonym_id = f8
 )
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs,
   order_catalog oc,
   mltm_order_catalog_load mocl
  PLAN (ocs
   WHERE ocs.updt_dt_tm BETWEEN cnvtdatetime("25-may-2017") AND cnvtdatetime("30-jun-2017")
    AND (ocs.mnemonic_type_cd=
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6011
     AND cdf_meaning="PRIMARY"))
    AND ocs.cki IS NOT null
    AND  NOT (ocs.cki IN (
   (SELECT
    synonym_cki
    FROM mltm_order_catalog_load
    WHERE mnemonic_type="Primary")))
    AND ocs.cki IN (
   (SELECT
    synonym_cki
    FROM mltm_order_catalog_load)))
   JOIN (oc
   WHERE ocs.catalog_cd=oc.catalog_cd)
   JOIN (mocl
   WHERE oc.cki=mocl.catalog_cki
    AND mocl.mnemonic_type="Primary"
    AND mocl.catalog_cki IN ("MUL.ORD!d08501", "MUL.ORD!d08473", "MUL.ORD!d03697", "MUL.ORD!d08447",
   "MUL.ORD!d08483",
   "MUL.ORD!d08490", "MUL.ORD!d08513", "MUL.ORD!d08475", "MUL.ORD!d08187", "MUL.ORD!d05873",
   "MUL.ORD!d08441", "MUL.ORD!d08477", "MUL.ORD!d08531", "MUL.ORD!d08456", "MUL.ORD!d08311",
   "MUL.ORD!d08485"))
  DETAIL
   rcnt = (rcnt+ 1), stat = alterlist(cleanup->list,rcnt), cleanup->list[rcnt].catalog_cd = ocs
   .catalog_cd,
   cleanup->list[rcnt].catalog_cki = mocl.catalog_cki, cleanup->list[rcnt].mnemonic = mocl.mnemonic,
   cleanup->list[rcnt].synonym_cki = mocl.synonym_cki,
   cleanup->list[rcnt].synonym_id = ocs.synonym_id
  WITH check, nocounter
 ;end select
 CALL echo(concat("*** UPDATING ",build(rcnt)," CODE_VALUE ROWS."))
 CALL echo(concat("*** UPDATING ",build(rcnt)," CODE_VALUE ROWS."))
 CALL echo(concat("*** UPDATING ",build(rcnt)," CODE_VALUE ROWS."))
 UPDATE  FROM code_value cv,
   (dummyt d  WITH seq = value(rcnt))
  SET cv.display = substring(1,40,cleanup->list[d.seq].mnemonic), cv.display_key = cnvtupper(
    cnvtalphanum(substring(1,40,cleanup->list[d.seq].mnemonic))), cv.description = substring(1,60,
    cleanup->list[d.seq].mnemonic)
  PLAN (d
   WHERE d.seq > 0)
   JOIN (cv
   WHERE (cv.code_value=cleanup->list[d.seq].catalog_cd)
    AND cv.code_value > 0)
  WITH nocounter, check
 ;end update
 CALL echo(concat("*** UPDATED ",build(curqual)," CODE_VALUE ROWS."))
 CALL echo(concat("*** UPDATED ",build(curqual)," CODE_VALUE ROWS."))
 CALL echo(concat("*** UPDATED ",build(curqual)," CODE_VALUE ROWS."))
 CALL echo(concat("*** UPDATING ",build(rcnt)," ORDER_CATALOG ROWS."))
 CALL echo(concat("*** UPDATING ",build(rcnt)," ORDER_CATALOG ROWS."))
 CALL echo(concat("*** UPDATING ",build(rcnt)," ORDER_CATALOG ROWS."))
 UPDATE  FROM order_catalog oc,
   (dummyt d  WITH seq = value(rcnt))
  SET oc.description = cleanup->list[d.seq].mnemonic, oc.primary_mnemonic = cleanup->list[d.seq].
   mnemonic, oc.dept_display_name = cleanup->list[d.seq].mnemonic,
   oc.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d
   WHERE d.seq > 0)
   JOIN (oc
   WHERE (oc.catalog_cd=cleanup->list[d.seq].catalog_cd))
  WITH nocounter, check
 ;end update
 CALL echo(concat("*** UPDATED ",build(curqual)," ORDER_CATALOG ROWS."))
 CALL echo(concat("*** UPDATED ",build(curqual)," ORDER_CATALOG ROWS."))
 CALL echo(concat("*** UPDATED ",build(curqual)," ORDER_CATALOG ROWS."))
 CALL echo(concat("*** UPDATING ",build(rcnt)," ORDER_CATALOG_SYNONYM ROWS."))
 CALL echo(concat("*** UPDATING ",build(rcnt)," ORDER_CATALOG_SYNONYM ROWS."))
 CALL echo(concat("*** UPDATING ",build(rcnt)," ORDER_CATALOG SYNONYM ROWS."))
 UPDATE  FROM order_catalog_synonym ocs,
   (dummyt d  WITH seq = value(rcnt))
  SET ocs.mnemonic = cleanup->list[d.seq].mnemonic, ocs.mnemonic_key_cap = cnvtupper(cleanup->list[d
    .seq].mnemonic), ocs.cki = cleanup->list[d.seq].synonym_cki,
   updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d
   WHERE d.seq > 0)
   JOIN (ocs
   WHERE (ocs.synonym_id=cleanup->list[d.seq].synonym_id))
  WITH nocounter, check
 ;end update
 CALL echo(concat("*** UPDATED ",build(curqual)," ORDER_CATALOG_SYNONYM ROWS."))
 CALL echo(concat("*** UPDATED ",build(curqual)," ORDER_CATALOG_SYNONYM ROWS."))
 CALL echo(concat("*** UPDATED ",build(curqual)," ORDER_CATALOG_SYNONYM ROWS."))
 COMMIT
#exit_script
END GO
