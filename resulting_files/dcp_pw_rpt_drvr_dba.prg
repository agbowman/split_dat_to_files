CREATE PROGRAM dcp_pw_rpt_drvr:dba
 PAINT
 SET pathway_catalog_id = 0
 SET printer_name = "MINE"
 FREE SET request
 RECORD request(
   1 pathway_catalog_id = f8
   1 printer_name = vc
   1 print_id_ind = i2
 )
 FREE SET reqinfo
 RECORD reqinfo(
   1 commit_ind = i2
   1 updt_app = i4
   1 updt_id = f8
   1 updt_task = i4
   1 updt_applctx = i4
 )
 FREE SET reqdata
 RECORD reqdata(
   1 active_status_cd = f8
 )
#accept_over
 CALL text(2,2,"PATHWAY_ID:(O FOR ALL):")
 CALL accept(2,24,"9(8)",0)
 SET pathway_catalog_id = curaccept
 CALL text(3,2,"PRINTER NAME:")
 CALL accept(3,15,"PPPP;CU","MINE")
 SET printer_name = curaccept
 IF (pathway_catalog_id > 0)
  SELECT INTO "nl:"
   pwc.pathway_catalog_id, pwc.active_ind
   FROM pathway_catalog pwc
   WHERE pwc.pathway_catalog_id=pathway_catalog_id
    AND pwc.active_ind=1
   DETAIL
    request->pathway_catalog_id = pwc.pathway_catalog_id, request->printer_name = printer_name,
    request->print_id_ind = 1
  ;end select
  EXECUTE dcp_pw_ref_report  WITH nocounter
 ELSEIF (pathway_catalog_id=0)
  RECORD pathway(
    1 qual[*]
      2 pathway_cat_id = f8
  )
  SELECT INTO "nl:"
   pwc.pathway_catalog_id, pwc.active_ind
   FROM pathway_catalog pwc
   WHERE pwc.active_ind=1
   HEAD REPORT
    count = 0
   DETAIL
    count = (count+ 1), stat = alterlist(pathway->qual,count), pathway->qual[count].pathway_cat_id =
    pwc.pathway_catalog_id
   WITH nocounter
  ;end select
  SET pw_cnt = cnvtint(size(pathway->qual,5))
  FOR (z = 1 TO cnvtint(size(pathway->qual,5)))
    FREE SET request
    RECORD request(
      1 pathway_catalog_id = f8
      1 printer_name = vc
      1 print_id_ind = i2
    )
    FREE SET reqinfo
    RECORD reqinfo(
      1 commit_ind = i2
      1 updt_app = i4
      1 updt_id = f8
      1 updt_task = i4
      1 updt_applctx = i4
    )
    FREE SET reqdata
    RECORD reqdata(
      1 active_status_cd = f8
    )
    SET request->pathway_catalog_id = pathway->qual[z].pathway_cat_id
    SET request->printer_name = printer_name
    SET request->print_id_ind = 1
    CALL text((z+ 5),2,"PATHWAY_ID:(O FOR ALL):")
    EXECUTE dcp_pw_ref_report
  ENDFOR
 ENDIF
#abort_prg
END GO
