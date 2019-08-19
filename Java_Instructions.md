
# Usage Instructions (Java)

1- Install Java JRE 12  
2- Download the jar and library files [**here**](https://github.com/bloc97/Anime4K/releases/download/v0.9/Anime4K_Java.zip), or build the jar yourself with the maven source project.  
3- Extract the files  
4- Run as administrator this command `java -jar Anime4K.jar input.png output.png` for 2x scale  

Available parameters:  
`java -jar Anime4K.jar [File_In] [File_Out] (Scale) (Push_Grad_Strength) (Push_Strength)`  

Default Scale: `2`  
Default Push_Strength: `Scale / 6`  
Default Push_Grad_Strength: `Scale / 2`  

  
Examples:  
`java -jar Anime4K.jar test.png test_upscaled.png 4`  
`java -jar Anime4K.jar test.png test_upscaled.png 2 0.6 0`  
`java -jar Anime4K.jar test.png test_upscaled.png 3 1 1`    
