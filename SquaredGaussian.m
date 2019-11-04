function H=SquaredGaussian(sigma,size)
    if nargin==1
        size=[ceil(3*sigma),ceil(3*sigma),ceil(3*sigma)];
    end
        [x,y,z] = ndgrid(-size(1):size(1),-size(2):size(2),-size(3):size(3));
        H = exp(-(x.*x/2/sigma^2 + y.*y/2/sigma^2 + z.*z/2/sigma^2));
        H = H/sum(H(:));
