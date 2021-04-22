%  VC i PSIV                                                      
%  Lab 1                                                          


clearvars,
close all,
clc,

%  Tasca 1 (+0.5) --------------------------------------------------

% Llistar imatges d’una carpeta.
path = "./highway/input/"
files = dir("./highway/input/*.jpg");

dataset = cell(1, 300);
i = 1;
for j=1:length(files)
    path_img = strcat(path, files(j).name);
    if files(j).name >= "in001051.jpg" && files(j).name <= "in001350.jpg"
        img = imread(path_img);
        dataset{i} = rgb2gray(img); %passar les img a escala de grisos
        i = i + 1;
    end
end

dataset_train_double = zeros(240,320,150);
dataset_test_double = zeros(240,320,150);
for i=1:300
    if i<151
        dataset_train_double(:,:,i) = dataset{i};
    else
        dataset_test_double(:,:,i-150) = dataset{i-150};
    end
end

dataset_train = cast(dataset_train_double, "uint8");
dataset_test = cast(dataset_test_double, "uint8");
 
%  Tasca 2 (+0.5) --------------------------------------------------

img_mean = cast(mean(dataset_train_double,3), "uint8");
img_std = cast(std(dataset_train_double,[], 3), "uint8");



figure(1)
imshow(img_mean);
figure(2)
imshow(img_std);

% Tasca 3 (+1.0) --------------------------------------------------
dataset_test_t3 = dataset_test - img_mean;
dataset_test_t3 = dataset_test_t3 > 20;
figure(3)
imshow(dataset_test_t3(:,:,1));

%  Tasca 4 (+1.0) --------------------------------------------------
alfa = 1.0
beta =60.0

img_mean_aux = cast(img_mean, "double");
img_std_aux = cast(img_std, "double");

dataset_test_t4 = abs(dataset_test_double - img_mean_aux) > (alfa*img_std_aux + beta);
figure(4)
imshow(dataset_test_t4(:,:,1));

%%
%  Tasca 5 (+2.0) --------------------------------------------------


dataset_test_t4_uint8 = cast(dataset_test_t4, "uint8");

dataset_test_t4_uint8(dataset_test_t4_uint8 > 0) = 255;

out = VideoWriter('tasca5Matlab.avi','Motion JPEG AVI');
open(out)

for j=1:150
    writeVideo(out,dataset_test_t4_uint8(:,:,j))
end
close(out)


% Tasca 6 (+1.0) --------------------------------------------------

% Llistar imatges d’una carpeta.
path_gt = "./highway/groundtruth/"
files_gt = dir("./highway/groundtruth/*.png");

gt_dataset_cell = cell(1, 150);
i = 1;
for j=1:length(files_gt)
    path_img_gt = strcat(path_gt, files_gt(j).name);
    if files_gt(j).name >= "gt001201.png" && files_gt(j).name <= "gt001350.png"
        gt_dataset_cell{i} = imread(path_img_gt);
        i = i + 1;
    end
end

gt_dataset=zeros(240,320,150);
gt_dataset=cast(gt_dataset,'uint8');

for i=1:150
    gt_dataset(:,:,i)=gt_dataset_cell{i};
end

gt_dataset(gt_dataset > 0) = 255; %Fix grey colours 


%Compare gt_dataset vs test_dataset_no_fondo_t4_uint8 to get accuracy

All_samples_N = size(gt_dataset, 1) * size(gt_dataset, 2) *  size(gt_dataset, 3);

True_negatives_plus_true_positives = sum(gt_dataset == dataset_test_t4_uint8, "all");

Accuracy = (True_negatives_plus_true_positives)/All_samples_N;


%Compare gt_dataset vs test_dataset_no_fondo_t3 to get accuracy

dataset_test_t3_uint8 = cast(dataset_test_t3,"uint8");

dataset_test_t3_uint8(dataset_test_t3_uint8 > 0) = 255;

True_negatives_plus_true_positives_2 = sum((gt_dataset == dataset_test_t3_uint8), "all");

Accuracy_2 = (True_negatives_plus_true_positives_2)/All_samples_N;

disp("Accuracy using Tasca 4 = ");
disp(Accuracy);
disp("Accuracy using Tasca 3 = ");
disp(Accuracy_2);


%%
% Tasca EXTRA LAB 4 -- MILLORA segmentacio de cotxes de les imatges
% binaries implementant el que hem apres al tema 4 de Binary Morphology i
% en els reptes
img_median = cast(median(dataset_train_double,3), "uint8");

dataset_LAB4 = abs(double(dataset_test) - double(img_median));

dataset_LAB4 = dataset_LAB4>10;
figure(2);imshow(dataset_LAB4(:,:,50));

dataset_LAB4 = imopen(dataset_LAB4, strel('disk',3)); %borrem els punts sols de fulles
figure(3);imshow(dataset_LAB4(:,:,50));

dataset_LAB4 = imclose(dataset_LAB4, ones(10)); %tanquem els lagos dels cotxes
x = 300
dataset_LAB4 = bwareaopen(dataset_LAB4, x); %borrem possibles clusters de punts no cotxes (clusters de menys de x punts fora)

figure(4);imshow(dataset_LAB4(:,:,50));


%create video of the new dataset
dataset_LAB4 = cast(dataset_LAB4, "uint8");

dataset_LAB4(dataset_LAB4 > 0) = 255;

out = VideoWriter('LAB4Matlab.avi','Motion JPEG AVI');
open(out)

for j=1:150
    writeVideo(out,dataset_LAB4(:,:,j))
end
close(out)


%Compare gt_dataset vs dataset_LAB4 to get accuracy
True_negatives_plus_true_positives_3 = sum(gt_dataset == dataset_LAB4, "all");

Accuracy_4 = (True_negatives_plus_true_positives_3)/All_samples_N;

disp("Accuracy using lab4 = ");
disp(Accuracy_4);
%%

% Tasca 8 (+1.0) ------------------------
%{
El primer que cal tenir si volem obtenir la mètrica de les imatges, en aquest cas la velocitat dels cotxes, és un sistema de referència, és a dir, necessitem saber la mida real d'un objecte estàtic de la imatge.

En el nostre exemple la millor referència que podem agafar són les línies de la carretera, ja que tenen un patró lineal, són totes de la mateixa mida i separades entre elles per la mateixa distancia, de manera que podrem tenir una referència no distorsionada compara'n on estan els cotxes amb les línies de la carretera.

Per altra banda, necessitarem obtenir la posició del cotxe en dos punts, al principi i al final del tros de carretera visible. Per a obtenir la referència inicial del cotxe en comparació les primeres línies de la carretera utilitzarem les imatges processades com les de la tasca 4, en blanc i negre, i per un punt de referència proper a les línies de referència, en el moment en què siguin blanques vol dir que un cotxe ha passat per allà, ja que en la carretera tenim un accuracy del 100%, quan un píxel es converteix a blanc és degut al fet que passa un cotxe. Fent el mateix per al final de la carretera obtindrem dos punts amb distància coneguda, i el nombre de frames que han passat (unitat temporal). Per passar de frames a segons senzillament necessitarem saber els frames per second a la que funcionava la càmera que ha gravat aquestes imatges.
Un cop tinguem ja la distancia en metres que ha recorregut el cotxe i el temps que ha tardat ja podem calcular la velocitat del cotxe.
Un dels punts més conflictius que ens trobarem en implementar aquesta funció serà la identificació dels cotxes, saber si hi han canviat de carril, si han avançat a un altre... Per solucionar aquest problema i saber exactament quan x cotxe entra i surt del tros de carretera necessitarem fer un seguiment del cotxe en concret durant els frames per estar segurs de què calculem la velocitat d'aquell cotxe i no una barreja de dos.

%}

%  THE END -----------------------------------------------------------

