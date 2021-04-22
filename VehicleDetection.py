######################################################################
### VC i PSIV                                                      ###
### Lab 1                                                          ###
######################################################################

import os, sys
from skimage import io

import time
import cv2
import numpy as np
from matplotlib import pyplot as plt


## Tasca 1 (+0.5) --------------------------------------------------

# Llistar imatges d’una carpeta.
path = "highway/input/"
files = os.listdir(path);

train_dataset_l = []
test_dataset_l = []

for file in files:
    if file >= "in001051.jpg" and file < "in001201.jpg" :
        # Llegir una imatge en escala de gris.
        train_dataset_l.append(cv2.imread("highway/input/" + file, 0))
        
    if file >= "in001201.jpg" and file <= "in001350.jpg" :
        # Llegir una imatge en escala de gris.
        test_dataset_l.append(cv2.imread("highway/input/" + file, 0))

train_dataset = np.array(train_dataset_l)
test_dataset = np.array(test_dataset_l)

## Tasca 2 (+0.5) --------------------------------------------------
mitjana = np.mean(train_dataset)
print("mitjana tasca 2 = ", mitjana)

mitjana_plot = np.mean(train_dataset, axis = 0)
mitjana_plot = mitjana_plot.astype("uint8")
plt.imshow(mitjana_plot,cmap='gray')
plt.show()

sd = np.std(train_dataset)
print("standard deviation tasca 2 = ", sd)

sd_plot = np.std(train_dataset, axis = 0)
sd_plot = sd_plot.astype("uint8")
plt.imshow(sd_plot,cmap='gray')
plt.show()

## Tasca 3 (+1.0) --------------------------------------------------

test_dataset_no_fondo_t3 = (test_dataset - mitjana_plot )>60
#plot example
plt.imshow(test_dataset_no_fondo_t3[0],cmap='gray')
plt.show()


## Tasca 4 (+1.0) --------------------------------------------------

alfa =1
beta = 40

test_dataset_aux = test_dataset.astype(int)
mitjana_plot_aux = mitjana_plot.astype(int)
sd_plot_aux = sd_plot.astype(int)



test_dataset_no_fondo_t4 = abs(test_dataset_aux - mitjana_plot_aux) > (alfa*sd_plot_aux + beta)
#plot example
plt.imshow(test_dataset_no_fondo_t4[0],cmap='gray')
plt.show()


## Tasca 5 (+2.0) --------------------------------------------------
test_dataset_no_fondo_t4_uint8 = test_dataset_no_fondo_t4.astype("uint8")

test_dataset_no_fondo_t4_uint8[test_dataset_no_fondo_t4_uint8 > 0] = 255

frameSize =  (test_dataset_no_fondo_t4_uint8.shape[2],test_dataset_no_fondo_t4_uint8.shape[1])


out = cv2.VideoWriter('tasca5.avi',cv2.VideoWriter_fourcc(*'DIVX'), 25, frameSize, False)

for image in test_dataset_no_fondo_t4_uint8:
    #img = cv2.cvtColor(image, cv2.COLOR_GRAY2RGB)
    out.write(image)

    
out.release()

## Tasca 6 (+1.0) --------------------------------------------------

path = "highway/groundtruth/"
files = os.listdir(path);

gt_dataset_l = []

for file in files:        
    if file >= "gt001201.png" and file <= "gt001350.png" :
        # Llegir una imatge en escala de gris.
        gt_dataset_l.append(cv2.imread(path + file, 0))

gt_dataset = np.array(gt_dataset_l)
gt_dataset[gt_dataset > 0] = 255 #Fix grey colours

#Compare gt_dataset vs test_dataset_no_fondo_t4_uint8 to get accuracy

All_samples_N = gt_dataset.shape[0] *  gt_dataset.shape[1] *  gt_dataset.shape[2]

True_negatives_plus_true_positives = np.count_nonzero(gt_dataset == test_dataset_no_fondo_t4_uint8)

Accuracy = (True_negatives_plus_true_positives)/All_samples_N


#Compare gt_dataset vs test_dataset_no_fondo_t3 to get accuracy

test_dataset_no_fondo_t3_uint8 = test_dataset_no_fondo_t3.astype("uint8")

test_dataset_no_fondo_t3_uint8[test_dataset_no_fondo_t3_uint8 > 0] = 255

True_negatives_plus_true_positives_2 = np.count_nonzero(gt_dataset == test_dataset_no_fondo_t3_uint8)

Accuracy_2 = (True_negatives_plus_true_positives_2)/All_samples_N

print("Accuracy using Tasca 4 = ", Accuracy)
print("Accuracy using Tasca 3 = ", Accuracy_2)

## Tasca 8 (+1.0) ------------------------



## THE END -----------------------------------------------------------

