function [dataset_images, dataset_gt, bg_value, name] = loadPaviaUniversity()
    
    bg_value = 0;
    dataset_images = cell(0);
    dataset_gt = cell(0);
    name = "PaviaU";

    path_dataset = "..\Datasets\Pavia_university\";
    
    image = load(path_dataset + "PaviaU.mat");
    image = image.paviaU;

    % Normalization
    image = normalization(image,95);
    image = double(image)/max(double(image), [], 'all');
    dataset_images{1} = image;

    gt = load(path_dataset + "PaviaU_gt.mat");
    gt = gt.paviaU_gt;
    dataset_gt{1} = gt;
    
    %[dataset_images, dataset_gt] = preprocessing_data(dataset_images, dataset_gt)
    
end