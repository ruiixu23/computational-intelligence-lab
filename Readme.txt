This file explains the structure the files and the steps to start experiments we have implemented


AUTHORS
-----------------
Group name: RMS
* Marica Bertarini (maricab@student.ethz.ch, m.bertarini@yahoo.it (on submission system))
* Sevgi Kaya (skaya@student.ethz.ch)
* Ruifeng Xu (ruxu@student.ethz.ch)

ACKNOWLEGEMENT
-----------------
We would like to thank Sharon Wulff, Alkis Gotovos and Brian McWilliams for their great help and availability.


FILE STRUCTURE
-----------------

 \|---Readme.txt
  |
  |---baseline_ksvd     Implementation of baseline using K-SVD
  |
  |--baseline_overdct    Implementation of baseline using overcomplete dictionary
  |
  |--baseline_svd       Implementation of baseline using SVD
  |
  |--final_project      Implementation of our final project
       |
       |--data          Data folder we used to store training/test images
       |
       |--dictionaries  Data folder that contains most of the dictionaries we learned
       |
       |--final_project_offline_parallel Contains the only files that are different from our basic final_project that allow to:
       |                                 learn dictionaries offline and apply them online by solving the sparse coding problem
       |                                 for all the bands at the same time
       |
       |--final_project_online_parallel  Contains the only files that are different from our basic final_project that allow to:
       |                                 learn dictionaries online from the image to restore, by learning all the dictionaries
       |                                 (1 per band) at the same time; then, it applies them in parallel as explained for
       |                                 final_project_offline_parallel
       |
       |--judge_submission Data folder that contains only the files we submitted to the judge
       |


INSTRUCTIONS
-----------------
The following contains general instructions to start the evaluation process.

BASELINES
    * Step 1: Adding Image and Mask Files
    Please add images and masks to the same folder. Note that, the name of mask file should follow the convention "imageName_mask.png" and all
    the image names should end with "2.png".

    * Step 2: Run Evaluate Inpainting Sscript
    Run EvaluateInpainting.m

    * Note: Dictionary Learning:
    To learn a new dictionary, the dictionary.mat in baseline_ksvd needs to be deleted first. In order to learn a dictionary from several images, please run EvaluateInpaintingImgConcat.m. To simply use the dictionary, run EvaluateInpainting.m.

 FINAL_PROJECT
    * Step 1: Dictionary Learning
    To learn dictionaries, add training images to the folder final_project. Please refer to the documentation in the file mdwt.m to start the learning process. For example, mdwt('dictionary.mat', 'haar', 1, 256, 64) learns dictionaries consisting of 256 atoms using Haar transform in 1 scale with patch size of sqrt(64). Please note that, your learned dictionary filename should be changed to 'dictionary.mat' if you use other names in order for the evaluation script to run correctly.

    * Step 2: Adding Image and Mask Files for Evaluation
    Please add images and masks to the final_project/data/ folder. Note that, the name of mask file should follow the convention "imageName_mask.png" and all the image names should end with "2.png".

    * Step 3: Run Evaluate Inpainting Script
    Run EvaluateInpainting.m
    To test out parallel offline inpainting, replace the content of file final_project/sparseCoding.m with the content of file final_project/final_project_offline_parallel/inPaintingParallel.m and then start script EvaluateInpainting.m

    * Note 1: Test Other Pixel Inferring Methods
    Please go the file inPainting.m and uncomment the fillingMissingPixels* method you want to test out

    * Note 2: Learning Dictionary Online
    To learn dictionaries and run evaluation online, please add images and masks to the final_project/ folder. Note that, the name of mask file should follow the convention "imageName_mask.png" and all the image names should end with "2.png". To change parameters for online dictionary learning, the are located in the file inPaintingOnline.m
    Then copy and paste the file from folder final_project/final_project_online_parallel/ to the folder final_project/ and run script EvaluateInpaintingOnline.m




