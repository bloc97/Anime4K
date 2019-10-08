
# Usage Instructions (Java)

1- Install Java JDK 12.  
2- Build the jar with the maven source project using the appropriate cmd/shell script.  
3- Run as administrator this command `java -jar Anime4K.jar input.png output.png` for 2x scale  

Available parameters:  
`java -jar Anime4K.jar [File_In] [File_Out] (Scale) (Push_Grad_Strength) (Push_Strength)`  

Default Scale: `2`  
Default Push_Grad_Strength: `Scale / 2`  
Default Push_Strength: `Scale / 6`  

Examples:  
`java -jar Anime4K.jar test.png test_upscaled.png 4`  
`java -jar Anime4K.jar test.png test_upscaled.png 2 0.6 0`  
`java -jar Anime4K.jar test.png test_upscaled.png 3 1 1`    

Note to developers:
For faster batch processing please look at Main.java and modify the code so that the Kernel is not re-created for each picture. (Kernel reuse will accelerate processing greatly.)
