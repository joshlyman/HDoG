function IMG = GaussianTransformer(IMG,sigma)
    H=SquaredGaussian(sigma);
    %disp(['Transforming to Gaussian space with sigma=',num2str(sigma)]);
    IMG=convn(IMG,H,'same');