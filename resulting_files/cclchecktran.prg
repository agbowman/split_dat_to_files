CREATE PROGRAM cclchecktran
 CASE ( $3)
  OF 1:
   CALL parser(build2("translate into '", $1,"' ",build( $2,":GROUP", $4)," with load go"))
  OF 2:
   CALL parser(build2("translate into '", $1,"' ",build( $2,":GROUP", $4)," with check go"))
  OF 3:
   CALL parser(build2("translate into '", $1,"' ",build( $2,":GROUP", $4)," with check,append go"))
 ENDCASE
;#end
END GO
