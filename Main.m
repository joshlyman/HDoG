clc;clear all;

path='E:\data\Rat2\';
MIR=dir([path,'*.hdr']);
for i=1
    tic;
    %% reading images
    % you need to change here
    % The input of image format here is Analyze 7.5 format
    disp(['Analyzing Object:',num2str(i), '-',MIR(i).name ]);
    hdr=analyze75info([path,MIR(i).name]);
    IMG=analyze75read(hdr);
    IMG=double(IMG);
    
    IMG=(IMG-min(IMG(:)))./(max(IMG(:))-min(IMG(:)));
    
    %% DoG transformation, DoGSearch(image, type of convexity, sigma)
    % Inputs: image: raw images format should be in double
    %         type of convexity: 'positive' or 'negative'
    %         sigma, smoothing parameter, if unset, DoGSearch will search for one
    % Outputs: LoG, DoG transformed image
    %          Mask: Hessian pre-segmented image
    
    [LoG Mask] = DoGSearch(IMG,'negative',1);
    
    
    %% Feature Extraction
    % Inputs: IMG raw image
    %         LoG DoG transformed Image
    %         Mask : Hessian pre-segmented image
    % Outputs:
    %        G: candidates with features
    %        G(1,:): index
    %        G(2,:): raw image intensity
    %        G(3,:): candidate distance to the kidney boundary, we are not
    %        using this feature in paper
    %        G(4,:): regional blobness
    %        G(5,:): Regional flatness
    
    [G L]=FeatureExtraction(IMG,LoG,Mask);
    
    %% Post-pruning: using VBGMM
    % Candidates are the indices of selected true glomeruli in G
    % List: is the final lists of glomeruli with features
    % NL: is the final segmentation of the image
    Candidates=vbcluster(G,3);
    [List,NL]=RefineResult(Candidates,L,1); 
    
    time=toc;
    %save([path,'resultc\',MIR(i).name,'_features.mat']);
    disp(['Finished, time elipse:',num2str(time)]);
end