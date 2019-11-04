function [Mask LoG]=ConvexDetector(IMG,type)
    [nx,ny,nz]=size(IMG);
    
    %disp(['Detecting Convex/Concave Regions']);
    [dx,dy,dz]=gradient(IMG);
    [dxx,dxy,dxz]=gradient(dx);
    [dxy,dyy,dyz]=gradient(dy);
    [dxz,dyz,dzz]=gradient(dz);
    U=zeros(nx,ny,nz);
    V=dxx.*dyy-dxy.*dxy;
    Q=(dxx.*dyy.*dzz+dxy.*dyz.*dxz.*2)-(dxz.*dxz.*dyy+dxy.*dxy.*dzz+dyz.*dyz.*dxx);
    
    switch type
        case 'positive'
            U(dxx>0)=1;
            V(V>0)=1;V(V<1)=0;
            Q(Q>0)=1;Q(Q<1)=0;
         case 'semi-positive'
            U(dxx>=0)=1;
            V(V>=0)=1;V(V<1)=0;
            Q(Q>=0)=1;Q(Q<1)=0;
          case 'negative'
            U(dxx<0)=1;
            V(V>0)=1;V(V<1)=0;
            Q(Q>0)=0;Q(Q<0)=1;
          case 'semi-negative'
            U(dxx<=0)=1;
            V(V>=0)=1;V(V<1)=0;
            Q(Q>0)=2;Q(Q<=0)=1;Q(Q==2)=0;
          otherwise
            error('Unknown filter type.')
    end
    Mask=U+Q+V;
    Mask(Mask<3)=0;Mask(Mask==3)=1;
    LoG=IMG.*Mask;
    LoG=sum(LoG(:))./sum(Mask(:));
    Mask=bwlabeln(Mask);
    
    %LoG=max(Mask(:));
    disp(['Generated:',num2str(max(Mask(:))-1),' regions with LoG: ',num2str(LoG) ]);
end