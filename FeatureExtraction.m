function [G L]=FeatureExtraction(IMG,LoG,Mask)
    %LoG=LoGTransformer(IMG,sigma);
    %Mask=ConvexDetector(LoG,type);

 
    [dx,dy,dz]=gradient(LoG);
    [dxx,dxy,dxz]=gradient(dx);
    [dxy,dyy,dyz]=gradient(dy);
    [dxz,dyz,dzz]=gradient(dz);
    
     % morpholgical operation 

%     det3=(dxx.*dyy.*dzz+dxy.*dyz.*dxz.*2)-(dxz.*dxz.*dyy+dxy.*dxy.*dzz+dyz.*dyz.*dxx);
%     trace3=dxx+dyy+dzz;
%     
%     Blob1=trace3./det3.^(1/3)./3;
%     
%     principle_minor=(dxx.*dyy-dxy.*dxy+dyy.*dzz-dyz.*dyz+dxx.*dzz-dxz.*dxz);
%     
%     Blob2=principle_minor./det3.^(2/3)./3;
%     
%     flatness=sqrt((trace3).^2-2.*principle_minor);
%     flatness=(flatness-min(flatness(:)))./(max(flatness(:))-min(flatness(:)));
    clear dx dy dz;
    L=bwlabeln(Mask); 
    disp(['Extracting Feature Set...']);
   Dist=bwdist(1-logical(IMG));    
    infd=find(L>0);
    
%    LoGI=LoG;
    Int=IMG;

    LL=L(infd);
    dxx=dxx(infd);dxx=dxx(:);
    dxy=dxy(infd);dxy=dxy(:);
    dxz=dxz(infd);dxz=dxz(:);
    dyy=dyy(infd);dyy=dyy(:);
    dyz=dyz(infd);dyz=dyz(:);
    dzz=dzz(infd);dzz=dzz(:);
    
 %   LoGI=LoGI(infd);LoGI=LoGI(:);
    Int=Int(infd);Int=Int(:);
   Dist = Dist(infd);Dist=Dist(:);
%     Blob1=Blob1(infd);Blob1=Blob1(:);
%     Blob2=Blob2(infd);Blob2=Blob2(:);
%     flatness=flatness(infd);flatness=flatness(:);
     ns=ones(size(LL));
    
    
    
    Tol=max(LL);
    G=zeros(Tol,4);
    G(:,1)=1:Tol;
    G(:,2)=accumarray(LL,Int,[], @(x) mean(x));
%   G(:,2)=accumarray(LL,LoGI,[], @(x) mean(x));
   G(:,3)=accumarray(LL,Dist,[],@(x) mean(x));
%     G(:,5)=accumarray(LL,ns,[],@(x) sum(x));
%    
    dxx=accumarray(LL,dxx,[],@(x) sum(x));
    dxy=accumarray(LL,dxy,[],@(x) sum(x));
    dxz=accumarray(LL,dxz,[],@(x) sum(x));
    dyy=accumarray(LL,dyy,[],@(x) sum(x));
    dyz=accumarray(LL,dyz,[],@(x) sum(x));
    dzz=accumarray(LL,dzz,[],@(x) sum(x));
    
    det3=abs((dxx.*dyy.*dzz+dxy.*dyz.*dxz.*2)-(dxz.*dxz.*dyy+dxy.*dxy.*dzz+dyz.*dyz.*dxx));
    trace3=abs(dxx+dyy+dzz);
    
%     G(:,6)=1./(trace3./det3.^(1/3)./3);
     principle_minor=(dxx.*dyy-dxy.*dxy)+(dyy.*dzz-dyz.*dyz)+(dxx.*dzz-dxz.*dxz);
%     
    G(:,4)=1./(principle_minor./det3.^(2/3)./3);
    
    flatness=sqrt((trace3).^2-2.*principle_minor);
    G(:,5)=(flatness-min(flatness(:)))./(max(flatness(:))-min(flatness(:)));
    
    
    
    