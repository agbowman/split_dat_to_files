CREATE PROGRAM dm_readme_estimate_log:dba
 PAINT
 SET width = 132
 CALL box(1,10,10,120)
 CALL text(2,50,"README ESTIMATE REPORTS")
 CALL text(3,11,"<1> Summary View for readme")
 CALL text(5,11,"<2> Detail View for readme")
 CALL text(20,1,"Enter selection (0 to exit program).")
 CALL accept(20,45,"9",1
  WHERE curaccept IN (0, 1, 2))
 CASE (curaccept)
  OF 0:
   GO TO end_program
  OF 1:
   EXECUTE dm_readme_estimator
  OF 2:
   SET drel_ocd = 0
   EXECUTE dm_readme_mass_move_log drel_ocd
 ENDCASE
#end_program
END GO
