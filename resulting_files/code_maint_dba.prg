CREATE PROGRAM code_maint:dba
 PAINT
 SET width = 132
 SET modify = system
 CALL clear(1,1)
 CALL box(3,1,23,132)
 CALL text(2,1,"Code Maintenance Menu",w)
 CALL text(7,20,"NOTE: ")
 CALL text(8,20,"As of the Cerner Millennium Production Release 2018.03, the back-end")
 CALL text(9,20,"CodeSet Maintenance tool (Code_Maint) is now obsolete.  All authorized")
 CALL text(10,20,"workflows have been added to the Core Code Builder (CoreCodeBuilder.exe)")
 CALL text(11,20,"solution.  Any new functionality requests will be added only to Core Code")
 CALL text(12,20,"Builder going forward.")
 CALL text(14,20,"If for some reason the tasks that required the usage of Code_Maint cannot")
 CALL text(15,20,"be performed in Core Code Builder, please log a service request with the")
 CALL text(16,20,"Millennium Code Set Owner to provide the required support.")
 CALL text(19,20,"Press Any Key to Continue")
 CALL accept(19,50,"P;CU")
 GO TO the_end
#the_end
END GO
