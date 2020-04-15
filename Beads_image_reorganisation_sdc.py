"""
 Renames and reorganises tile scans acquired using a 3i Spinning Disk Confocal and SlideBook 
 software (exported as TIFFs). The original, repeating 'left to right, right to left' sequence
 is changed to 'left to right' only, compatible with Beads_quantification_sdc.ijm.
 
 Dec 2017: Nuria Barber-Pérez wrote the original code.
 Apr 2020: Aleksi Isomursu converted to Python 3 (v3.7.7), modified the loop for reversing image
 order and added functionality for selecting a working directory via input prompt.
 
"""

import glob,os

# Define tile scan dimensions.
n_row = 12
n_col = 12

new_name_part1 = 'Gradient_N'

# Define current working directory based on input.
dir = input('Please input working directory:')
os.chdir(dir)

count = 0
modifier = 0

# Go through the images in the working directory, renaming and renumbering them as needed.
for imgName in glob.glob("*.tiff"):
    image_number = int(imgName[-11:-8])
    col = image_number/n_col + 1
    # Identify the beginning of a row that needs to be reversed.               
    if not col % 2:
        count = n_col
        modifier = n_col - 1
    # Determine if the current image number needs to be changed.
    if count > 0:
        new_image_number = image_number + modifier
        print('reverse', image_number, new_image_number)
        count = count - 1
        modifier = modifier - 2
    else:
        new_image_number = image_number
        print('retain', image_number)
    # Format the new image number as a string.
    if new_image_number >= 10 and new_image_number < 100:
        new_image_number = '0'  + str(new_image_number)
    elif new_image_number < 10:
        new_image_number = '00'  + str(new_image_number)
    new_name = new_name_part1 + str(new_image_number) + '_T' + imgName[-11:-8] + '.tiff'
    
    # Rename the current image.    
    old_image_path = os.path.join(os.getcwd(), imgName)
    new_image_path = os.path.join(os.getcwd(), new_name)
    os.rename(old_image_path, new_image_path)