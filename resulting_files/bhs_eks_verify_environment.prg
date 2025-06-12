CREATE PROGRAM bhs_eks_verify_environment
 EXECUTE bhs_check_domain
 IF (cnvtupper(opt_param)="PROD"
  AND gl_bhs_prod_flag=1)
  SET retval = 100
 ELSEIF (cnvtupper(opt_param)=gs_bhs_env_name)
  SET retval = 100
 ELSE
  SET retval = 0
 ENDIF
END GO
