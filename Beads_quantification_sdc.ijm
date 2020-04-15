/* 
 Counts fluorescent beads from a multi-level (z stack) tile scan montage. For downstream analysis with
 Beads_convert_to_matrix.py, the input should include 12 x 12 images, numbered left to right and top to 
 bottom. Generates a .csv file that contains the number of beads for each image, and saves a single 
 segmented image from each row as an example. Appropriate threshold value varies depending on the image
 set, prior testing with individual images is recommended.
 
 Dec 2017: Nuria Barber-Pérez wrote the original code.
 Apr 2020: Aleksi Isomursu commented parts of the code and added functionality for selecting a working 
 directory and parameters through a dialog.
*/
 

// Define the working directory.
dir1 = getDirectory("Select a folder that contains the images to process.");
list = getFileList(dir1);

// Create a directory for the output.
dir2 = dir1 + "Results_beads\\";
File.makeDirectory(dir2);

// Define a grey value for thresholding and segmenting the beads.
Dialog.create("Set the threshold for bead segmentation.");
Dialog.addNumber("Grey value:", 1000);
Dialog.show();
thr = Dialog.getNumber();


image_number = 0;
first_image = -1;
save_image = -1;


setBatchMode(true);
for (i=0; i<list.length; i++){
	save_image++;
	first_image++;
	
	if (endsWith(list[i],".tiff")){
	    
		open (dir1+list[i]);
		
		title=getTitle();
		  	
		w = getWidth(); 
		h = getHeight();
		A = w/2;
		
		run("Z Project...", "projection=[Max Intensity]");
		setAutoThreshold("Default dark");
		// Threshold the image to segment the beads.
		setThreshold(thr,65535);		
		setOption("BlackBackground", false);
		run("Convert to Mask");
		if (save_image == 12 || first_image == 5 ) {
			selectWindow("MAX_"+ title);
			
			saveAs("Tiff", dir2 + "MAX_" + title);
			
			save_image = 0;
		}		
		
		image_number=0;
		
		for (ii=0; ii<h/A; ii++){ 
        	for (j=0; j<w/A; j++){ 
            	image_number++;
            	selectWindow("MAX_" + title);
            	x = j * A; 
            	y = ii * A; 
            	makeRectangle(x, y, A, A); 
                        
		run("Analyze Particles...", "size=3-Infinity pixel show=Ellipses clear summarize");
						
            	print(title + "," + image_number + "," + nResults); 
            	selectWindow("Drawing of MAX_" + title);
				close();
        	}
		}

        selectWindow(title); 
		close();
		selectWindow("MAX_" + title);
		close();
	}	
}                      
						
selectWindow("Log");
saveAs("Text", dir2 + "grid_2x2_Beads_Log.csv");
						
// Save the final bead counts into a .csv file.               
selectWindow("Summary");
saveAs("Results", dir2 + "grid_2x2_Beads_Summary.csv");
