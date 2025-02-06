%%

clear variables
close all

%% Import python utility

pyenv(Version="C:\\Users\\avieth\\AppData\\Local\\miniconda3\\envs\\MATLAB\\python.exe")
py.importlib.import_module('python_utility');
rng(123);

dataset_loaders = {@loadPines, @loadPaviaCenter, @loadPaviaUniversity, @loadSalinas, @loadSalinasA};

for i = 1:length(dataset_loaders)
    % Load dataset
    [dataset_images, dataset_gt, bg_value, datase_name] = dataset_loaders{i}();
    image = dataset_images{1};
    gt = dataset_gt{1};
    
    fprintf('Processing dataset: %s\n', datase_name);
  
    %imshow(image(:,:,100), []);
    %imshow(gt, []);
    
    % Superpixel segmetation
    
    ms = [0.0 0.1 0.2];          % spatial distance
    m_clusts = [0.4 0.6 0.8];    % cluster distance
    n_clusters = [10 50 100 250 500 1000, 2500, 5000];

    % Generate all combinations
    [MS, MCS, NCS] = ndgrid(ms, m_clusts, n_clusters);
    combinations = [MS(:), MCS(:), NCS(:)]; % Convert grids to a list

    for j = 1:size(combinations, 1)
        m = combinations(j, 1);
        m_clust = combinations(j, 2);
        n_cluster = combinations(j, 3);

        fprintf('Combination: m %0.2f, m_clust %0.2f, n_cluster %i (%i of %i)\n', ...
            m, ...
            m_clust, ...
            n_cluster, ...
            j, ...
            size(combinations, 1));
        
        [sp_labels, sp_centers] = augmented_h_slic(image,...
            n_cluster,...
            m,...
            m_clust,...
            bandwidth=NaN,...
            quantile=0.48,...
            perc=NaN,...
            threshold=0.01);
        
        % Evaluation of superpixel segmetation
        
        percentange = 15;
        UE = undersegmentation_error(sp_labels, gt, percentange, bg_value);
        
        % Save output
        out = consistent_random_remap(int32(sp_labels));
        
        saveName = "nc" + num2str(n_cluster);
        
        saveDir = '..\Output\' + datase_name + "\" + "m" + num2str(m) + "_mc" + num2str(m_clust);

        if ~exist(saveDir, 'dir')
            mkdir(saveDir);
        end

        saveP = saveDir  + "\" + saveName + '.tiff';

        t = Tiff(saveP, 'w');
        
        % Set TIFF tags for 32-bit integer storage
        tagstruct.ImageLength = size(out, 1);
        tagstruct.ImageWidth = size(out, 2);
        tagstruct.SampleFormat = Tiff.SampleFormat.Int;  % Store as integer
        tagstruct.BitsPerSample = 32;  % 32-bit
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        
        % Apply tags
        t.setTag(tagstruct);
        
        % Write data
        t.write(out);
        t.close();
        
        fprintf('Saved outpt image: %s\n', saveP);
    end

end

