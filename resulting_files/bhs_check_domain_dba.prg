CREATE PROGRAM bhs_check_domain:dba
 DECLARE gl_bhs_prod_flag = i2 WITH persist, noconstant(0)
 DECLARE gs_bhs_domain_name = vc WITH persist, noconstant(trim(cnvtupper(curdomain),3))
 DECLARE gs_bhs_env_name = vc WITH persist, noconstant(trim(cnvtupper(logical("ENVIRONMENT")),3))
 DECLARE gs_bhs_node_name = vc WITH persist, noconstant(trim(cnvtupper(curnode),3))
 DECLARE gs_bhs_db_name = vc WITH persist, noconstant("")
 SELECT INTO "nl:"
  FROM v$database d
  DETAIL
   gs_bhs_db_name = d.name
  WITH nocounter
 ;end select
 IF (gs_bhs_domain_name IN ("PROD", "P627", "CP627")
  AND gs_bhs_db_name IN ("PROD", "P627", "CP627"))
  SET gl_bhs_prod_flag = 1
 ENDIF
 IF (size(gs_bhs_domain_name)=0
  AND gs_bhs_db_name IN ("PROD", "P627", "CP627"))
  SET gl_bhs_prod_flag = 1
 ENDIF
 CALL echo(concat("PROD flag = ",trim(cnvtstring(gl_bhs_prod_flag),3)))
 CALL echo(concat("Domain Name = ",gs_bhs_domain_name))
 CALL echo(concat("Environment Name = ",gs_bhs_env_name))
 CALL echo(concat("Node Name = ",gs_bhs_node_name))
 CALL echo(concat("Database Name = ",gs_bhs_db_name))
#exit_script
END GO
