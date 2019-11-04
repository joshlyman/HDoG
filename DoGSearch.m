function [LOG Mask] = DoGSearch(IMG,type,sigma)
low=0.8;
up=1.5;
num_interval=(up-low)/0.1;
    if nargin<3 
        disp(['Searching best DoG Space ...']);
        t=1;
        maxt=0;maxi=0;T=zeros(t,1);
        for sigma=low:0.1:up
            TLOG=sigma.^(2-1).*(GaussianTransformer(IMG,sigma+0.001)-GaussianTransformer(IMG,sigma))./0.001;
            [Temp,T(t)]=ConvexDetector(TLOG,type);
            if T(t)>maxi
               LOG=TLOG;
               Mask=Temp;
               maxt=sigma;
               maxi=T(t);
            end
            t=t+1;
        end
       
        disp(['Optimum Space with sigma=',num2str(maxt)]);
%         LOG=CIMG(:,:,:,maxt+1)-CIMG(:,:,:,maxt-1);
%         [Mask tmp]=ConvexDetector(LOG,type);
        
    elseif nargin==3
        if sigma==0
            LOG=Laplacian(IMG);
            [Mask,T]=ConvexDetector(LOG,type);
        else
            LOG=sigma.^(2-1)*(GaussianTransformer(IMG,sigma+0.001)-GaussianTransformer(IMG,sigma))./0.001;
            [Mask,T]=ConvexDetector(LOG,type);
        end
    end
   